using LLama;
using LLama.Batched;
using LLama.Common;
using LLama.Sampling;
using LlamaSharp.ToolCallEnvelopes;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Text.Json;
using static System.Collections.Specialized.BitVector32;

namespace LLMRuntime;

public class LLMExecutor
{
    string ModelPath;
    double Temperature;
    int MaxTokens;
    int GPULayers;

    ModelParams Parameters;
    LLamaWeights Model;
    InteractiveExecutor Executor;

    public LLMExecutor(string modelPath, double temperature, int maxTokens, int gpuLayers)
    {
        ModelPath = modelPath;
        Temperature = temperature;
        MaxTokens = maxTokens;
        GPULayers = gpuLayers;

        Parameters = new ModelParams(modelPath)
        {
            ContextSize = 32768,
            GpuLayerCount = gpuLayers 
        };
        Model = LLamaWeights.LoadFromFile(Parameters);
        Executor = new InteractiveExecutor(Model.CreateContext(Parameters));
    }

    public string ParsePrompt(ChatHistory chatHistory, string prompt, out List<ToolDefinition> tools)
    {
        List<string> toolDefs = new List<string>();
        string userMessage = "";

        void addMessage(AuthorRole role, string message)
        {
            if (userMessage != "") {
                chatHistory.AddMessage(AuthorRole.User, userMessage);

                userMessage = "";
            }

            if (role == AuthorRole.User)
                userMessage = message;
            else if (role != AuthorRole.Unknown)
                chatHistory.AddMessage(role, message);
        }
		
        void addTool(string message)
        {
            toolDefs.Add(message);
        }

        AuthorRole role = AuthorRole.Unknown;
        string message = "";
        bool hasTools = false;

        foreach (string line in prompt.Split(new string[] { Environment.NewLine, "\n" }, StringSplitOptions.None))
        {
            string input = line.Trim();
			
			if (hasTools && input.StartsWith("<|### --- ###|>"))
			{
				addTool(message);
				
				message = "";
			}
            else if (input.StartsWith("<|###"))
            {
                addMessage(role, message);

                message = "";

                if (input == "<|### System ###|>")
                    role = AuthorRole.System;
                else if (input == "<|### Assistant ###|>")
                    role = AuthorRole.Assistant;
                else if (input == "<|### User ###|>")
                    role = AuthorRole.User;
                else if (input == "<|### Tools ###|>")
					hasTools = true;
            }
            else
                message += (input + Environment.NewLine);
        }

        if (message != "")
            if (hasTools)
                addTool(message);
            else
                userMessage = (role == AuthorRole.User) ? message : "";

        tools = BuildTools(chatHistory, toolDefs);

        return userMessage;
    }

    public List<ToolDefinition> BuildTools(ChatHistory chatHistory, List<string> toolDefs) {
        List<ToolDefinition> tools = new List<ToolDefinition>();

        foreach (string toolDef in toolDefs)
        {
            var function = JsonDocument.Parse(toolDef).RootElement.GetProperty("function");
            var tool = new ToolDefinition(function.GetProperty("name").GetString() ?? throw new InvalidOperationException("Tool name is required."),
                                          function.TryGetProperty("description", out var description) ? description.GetString() ?? string.Empty
                                                                                                      : string.Empty,
                                          function.GetProperty("parameters").Clone());

            tools.Add(tool);
        }

        return tools;
    }

    public string BuildGrammar(List<ToolDefinition> tools)
    {
        return LlamaSharpToolGrammar.Build(ToolChoice.Auto, parallelCalls: true, tools: tools, strict: true);
	}

    public async Task<string> AskAsync(string prompt)
    {
        // Add chat histories as prompt to tell AI how to act.
        var chatHistory = new ChatHistory();
        List<ToolDefinition> tools;
        string userInput = ParsePrompt(chatHistory, prompt, out tools);
        ChatSession session = new(Executor, chatHistory);
            
        if (tools.Count == 0)
        {
            InferenceParams inferenceParams = new InferenceParams()
            {
                MaxTokens = MaxTokens,
                AntiPrompts = new List<string> { "User:" }
            };
            string result = "<|### Answer ###|>\n";

            await foreach (var text in session.ChatAsync(new ChatHistory.Message(AuthorRole.User, userInput), inferenceParams))
                result += text;

            return result;
        }
        else
        {
            var pipeline = new DefaultSamplingPipeline { Grammar = new Grammar(BuildGrammar(tools), "root") };
            InferenceParams inferenceParams =
				new InferenceParams()
					{
						MaxTokens = MaxTokens,
						AntiPrompts = new List<string> { "User:" },
						SamplingPipeline = pipeline
					};
            var promptHistory =
                LlamaSharpToolPromptBuilder.Build(
                    systemPrompt: "You are concise and use tools when they are needed.",
                    messages: new List<ToolAwareMessage> { ToolAwareMessage.User(userInput) },
                    tools: tools, strictTools: true);
            var userMessage = new ChatHistory();

            foreach (var message in promptHistory.Messages)
            {
                var role = message.Role switch
                {
                    ToolPromptRole.System => AuthorRole.System,
                    ToolPromptRole.User => AuthorRole.User,
                    ToolPromptRole.Assistant => AuthorRole.Assistant,
                    _ => throw new InvalidOperationException($"Unsupported prompt role '{message.Role}'.")
                };

                userMessage.AddMessage(role, message.Content);
            }

            var output = new StringBuilder();

            await foreach (var text in session.ChatAsync(userMessage, inferenceParams))
                output.Append(text);

            var result = LlamaSharpToolEnvelopeParser.Parse(output.ToString().Trim());

            switch (result.Mode)
            {
                case LlamaSharpToolEnvelopeParser.ToolCallsMode:
                    string toolCalls = "<|### Tool Calls ###|>\n";
                    bool first = true;

                    foreach (var call in result.ToolCalls)
                    {
                        if (first)
                            first = false;
                        else
                            toolCalls += "\n<|### --- ###|>\n";

                        toolCalls += "{ \"function\": { \"name\": \"" + call.Name + "\", \"arguments\": " + call.ArgumentsJson + "} }";
                    }

                    return toolCalls;

                case LlamaSharpToolEnvelopeParser.MessageMode:
                    return "<|### Answer ###|>\n" + result.Content;

                case LlamaSharpToolEnvelopeParser.RefusalMode:
                    return "<|### Answer ###|>\n";
            }

            return "<|### Answer ###|>\n";
        }
    }

    public string Ask(string prompt)
    {
        return AskAsync(prompt).Result;
    }
}

static class Program
{
    static string WaitForPrompt(string fileName)
    {
        while (true)
        {
            if (File.Exists(fileName))
            {
                StreamReader promptStream = new StreamReader(fileName);

                string prompt = promptStream.ReadToEnd();

                promptStream.Close();

                File.Delete(fileName);

                return prompt;
            }

            Thread.Sleep(100);
        }
    }

    [STAThread]
    static void Main(string[] args)
    {
        Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

        try
        {
            LLMExecutor executor = new LLMExecutor(args[2],
                                                   (args.Length > 3) ? Double.Parse(args[3]) : 0.5,
                                                   (args.Length > 4) ? int.Parse(args[4]) : 2048,
                                                   (args.Length > 5) ? int.Parse(args[5]) : 0);

            while (true)
            {
                string prompt = WaitForPrompt(args[0]);

                if (prompt.Trim() == "Exit")
                    break;

                try
                {
                    string answer = executor.Ask(prompt);
                    StreamWriter outStream = new StreamWriter(args[1], false, Encoding.Unicode);

                    outStream.Write(answer);
                    outStream.Flush();

                    outStream.Close();
                }
                catch (Exception e)
                {
                    StreamWriter outStream = new StreamWriter(args[1], false, Encoding.Unicode);

                    outStream.Write("Error");
                    outStream.Flush();

                    outStream.Close();
                }
            }
        }
        catch (Exception e)
        {
            System.Environment.Exit(1);
        }
    }
}