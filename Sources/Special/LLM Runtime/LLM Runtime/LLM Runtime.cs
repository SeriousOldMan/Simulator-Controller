using LLama;
using LLama.Abstractions;
using LLama.Common;
using LLama.Sampling;
using LlamaSharp.ToolCallEnvelopes;
using System.Diagnostics;
using System.Globalization;
using System.Text;
using System.Text.Json;

// For a good explanation of the approach of this solution, see:
//
// https://thirty25.blog/blog/2025/04/intro-to-local-models-with-dotnet/
//
// and
//
// https://github.com/Supprocom/LlamaSharp.ToolCallEnvelopes/blob/main/docs/getting-started.md

namespace LLMRuntime;

public class LLMExecutor
{
    string ModelPath;
    double Temperature;
    int MaxTokens;
    int GPULayers;
	bool Strict;

    ModelParams Parameters;
    LLamaWeights Model;
    InteractiveExecutor Executor;

    public LLMExecutor(string modelPath, double temperature, int maxTokens, int gpuLayers, bool strict,
					   uint contextSize = 32768, uint batchSize = 128, int threads = -1)
    {
        ModelPath = modelPath;
        Temperature = temperature;
        MaxTokens = maxTokens;
        GPULayers = gpuLayers;
		Strict = strict;
		
		if (threads < 0)
			threads = Math.Max(1, Environment.ProcessorCount / 2);

        Parameters = new ModelParams(modelPath)
        {
            ContextSize = contextSize,
            GpuLayerCount = gpuLayers,
			BatchSize = batchSize,
			Threads = threads
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
            
            tools.Add(new ToolDefinition(function.GetProperty("name").GetString() ?? throw new InvalidOperationException("Tool name is required."),
										 function.TryGetProperty("description", out var description) ? description.GetString() ?? string.Empty
																									 : string.Empty,
										 function.GetProperty("parameters").Clone()));
        }

        return tools;
    }

    public string BuildGrammar(List<ToolDefinition> tools)
    {
        return LlamaSharpToolGrammar.BuildCompleteEnvelopeGrammar(
            tools,
            new ToolEnvelopeGrammarOptions
            {
                ToolChoice = ToolChoice.Auto,
                EnvelopeMode = ToolEnvelopeMode.StrictDeclared,
                ParallelToolCalls = true,
                StrictTools = Strict
            });
    }

    public ISamplingPipeline BuildPipeline(List<ToolDefinition> tools)
    {
        return new DefaultSamplingPipeline { Grammar = new Grammar(BuildGrammar(tools), "root") };
    }

    public IInferenceParams BuildInferenceParams()
    {
        return new InferenceParams() { MaxTokens = MaxTokens };
    }

    public IInferenceParams BuildInferenceParams(ISamplingPipeline pipeline)
    {
        return new InferenceParams() { MaxTokens = MaxTokens, SamplingPipeline = pipeline };
    }

    public ToolPromptHistory BuildToolPromptHistory(List<ToolDefinition> tools, string userInput)
    {
        return LlamaSharpToolPromptBuilder.Build(
            systemPrompt: "You will use tools when they are needed.",
            messages: new List<ToolAwareMessage> { ToolAwareMessage.User(userInput) },
            tools: tools, strictTools: Strict);
    }

    public ChatHistory BuildUserMessage(ToolPromptHistory promptHistory, ref ChatHistory chatHistory)
    {
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

            if (role == AuthorRole.System)
                chatHistory.AddMessage(role, message.Content);
            else
                userMessage.AddMessage(role, message.Content);
        }

        return userMessage;
    }

    public async Task<string> CreateAnswer(ChatHistory chatHistory, string userInput)
    {
        var session = new ChatSession(Executor, chatHistory);
        var outputBuilder = new StringBuilder();

		outputBuilder.Append("<|### Answer ###|>\n");
		
        await foreach (var text in session.ChatAsync(new ChatHistory.Message(AuthorRole.User, userInput),
                                                     BuildInferenceParams()))
            outputBuilder.Append(text);

        return outputBuilder.ToString();
    }

    public async Task<string> CreateAnswer(ChatHistory chatHistory, List<ToolDefinition> tools,
                                           string userInput)
    {
        var userMessage = BuildUserMessage(BuildToolPromptHistory(tools, userInput), ref chatHistory);
        var session = new ChatSession(Executor, chatHistory);
        var outputBuilder = new StringBuilder();
        int nlCount = 0;

        await foreach (var text in session.ChatAsync(userMessage, BuildInferenceParams(BuildPipeline(tools))))
        {
            if ((text == Environment.NewLine) || (text == "\n"))
            {
                if (nlCount++ > 5)
                    break;
            }
            else
                nlCount = 0;

            outputBuilder.Append(text);
        }

        var result = LlamaSharpToolEnvelopeParser.Parse(outputBuilder.ToString().Trim());

        switch (result.Mode)
        {
            case LlamaSharpToolEnvelopeParser.ToolCallsMode:
				var answerBuilder = new StringBuilder();
                bool first = true;
				
				answerBuilder.Append("<|### Tool Calls ###|>\n");

                foreach (var call in result.ToolCalls)
                {
                    if (first)
                        first = false;
                    else
						answerBuilder.Append("\n<|### --- ###|>\n");

                    answerBuilder.Append("{ \"function\": { \"name\": \"" + call.Name +
													   "\", \"arguments\": " + call.ArgumentsJson + "} }");
                }

                return answerBuilder.ToString();

            case LlamaSharpToolEnvelopeParser.MessageMode:
                return "<|### Answer ###|>\n" + result.Content;

            default:
                return "<|### Answer ###|>\n";
        }
    }

    public async Task<string> AskAsync(string prompt)
    {
        // Add chat histories as prompt to tell AI how to act.
        var chatHistory = new ChatHistory();
        List<ToolDefinition> tools;
        string userInput = ParsePrompt(chatHistory, prompt, out tools);
            
        if (tools.Count == 0)
            return await CreateAnswer(chatHistory, userInput);
        else
            return await CreateAnswer(chatHistory, tools, userInput);
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
		using (Process p = Process.GetCurrentProcess()) 
			p.PriorityClass = ProcessPriorityClass.BelowNormal; 

        while (true)
        {
            if (File.Exists(fileName))
                try {
                    StreamReader promptStream = new StreamReader(fileName);

                    string prompt = promptStream.ReadToEnd();

                    promptStream.Close();

                    File.Delete(fileName);

                    return prompt;
                }
                catch { }

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
                                                   (args.Length > 5) ? int.Parse(args[5]) : 0,
												   ((args.Length > 6) ? args[6] : "Strict") == "Strict",
												   (args.Length > 7) ? uint.Parse(args[7]) : 32768,
												   (args.Length > 8) ? uint.Parse(args[8]) : 256,
												   (args.Length > 9) ? int.Parse(args[9]) : Math.Max(1, Environment.ProcessorCount / 2));

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