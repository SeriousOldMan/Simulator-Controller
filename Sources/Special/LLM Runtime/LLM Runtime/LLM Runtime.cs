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
    int MaxTokens;
    int GPULayers;
	bool Strict;

    ModelParams Parameters;
    LLamaWeights Model;
    InteractiveExecutor Executor;

	public class Answer {
		public string Text;
		public string File;
		
		public Answer() { }
	}
	
    public LLMExecutor(string modelPath, int maxTokens, int gpuLayers, bool strict,
					   uint contextSize = 32768, uint batchSize = 128, int threads = -1)
    {
        ModelPath = modelPath;
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

    public string ParsePrompt(string prompt, ChatHistory chatHistory,
							  out List<ToolDefinition> tools, out float temperature, out string answerFile)
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
		bool inOptions = false;
		
		temperature = 0.5f;
		answerFile = "";

        foreach (string line in prompt.Split(new string[] { Environment.NewLine, "\n" }, StringSplitOptions.None))
        {
            string input = line.Trim();
			
			if (inOptions && !input.StartsWith("<|###")) {
				if (input.Contains("Temperature"))
					temperature = float.Parse(input.Replace("Temperature=", ""));
				else if (input.Contains("Output"))
					answerFile = input.Replace("Output=", "");
			}
			else if (input.StartsWith("<|### Options ###|>"))
				inOptions = true;
			else if (hasTools && input.StartsWith("<|### --- ###|>"))
			{
				addTool(message);
				
				message = "";
			}
            else if (input.StartsWith("<|###"))
            {
				inOptions = false;
				
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

    public ISamplingPipeline BuildPipeline(float temperature)
    {
        return new DefaultSamplingPipeline
        {
            Temperature = temperature
        };
    }

    public ISamplingPipeline BuildPipeline(List<ToolDefinition> tools, float temperature)
    {
        return new DefaultSamplingPipeline
        {
            Grammar = new Grammar(BuildGrammar(tools), "root"),
            Temperature = temperature
        };
    }

    public IInferenceParams BuildInferenceParams()
    {
        return new InferenceParams() {
            MaxTokens = MaxTokens
        };
    }

    public IInferenceParams BuildInferenceParams(ISamplingPipeline pipeline)
    {
        return new InferenceParams() {
            MaxTokens = MaxTokens,
            SamplingPipeline = pipeline };
    }

    public ToolPromptHistory BuildToolInstructions(List<ToolDefinition> tools)
    {
        return LlamaSharpToolPromptBuilder.Build(
            systemPrompt: "You will use tools when they are needed.",
            messages: new List<ToolAwareMessage>(),
            tools: tools, strictTools: Strict);
    }

    public ChatHistory BuildChatHistory(ChatHistory chatHistory, ToolPromptHistory toolsInstructions)
    {
        ChatHistory combinedChatHistory = new ChatHistory();

        foreach (var message in chatHistory.Messages)
            if (message.AuthorRole == AuthorRole.System)
                combinedChatHistory.AddMessage(AuthorRole.System, message.Content);

        foreach (var message in toolsInstructions.Messages)
            if (message.Role == ToolPromptRole.System)
                combinedChatHistory.AddMessage(AuthorRole.System, message.Content);

        foreach (var message in chatHistory.Messages)
            if (message.AuthorRole != AuthorRole.System)
                combinedChatHistory.AddMessage(message.AuthorRole, message.Content);

        return combinedChatHistory;
    }

    public async Task<string> CreateAnswer(ChatHistory chatHistory, float temperature, string userInput)
    {
        var session = new ChatSession(Executor, chatHistory);
        var outputBuilder = new StringBuilder();
        int nlCount = 0;

        outputBuilder.Append("<|### Answer ###|>\n");

        await foreach (var text in session.ChatAsync(new ChatHistory.Message(AuthorRole.User, userInput),
                                                     BuildInferenceParams(BuildPipeline(temperature))))
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

        return outputBuilder.ToString().Trim();
    }

    public async Task<string> CreateAnswer(ChatHistory chatHistory, List<ToolDefinition> tools,
										   float temperature, string userInput)
    {
        var session = new ChatSession(Executor, BuildChatHistory(chatHistory, BuildToolInstructions(tools)));
        var outputBuilder = new StringBuilder();
        int nlCount = 0;

        await foreach (var text in session.ChatAsync(new ChatHistory.Message(AuthorRole.User, userInput),
                                                     BuildInferenceParams(BuildPipeline(tools, temperature))))
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

    public async Task<Answer> AskAsync(string prompt)
    {
        var chatHistory = new ChatHistory();
        List<ToolDefinition> tools;
		float temperature;
		string answerFile;
        string userInput = ParsePrompt(prompt, chatHistory, out tools, out temperature, out answerFile);
        string answer = ((tools.Count == 0) ? CreateAnswer(chatHistory, temperature, userInput).Result
											: CreateAnswer(chatHistory, tools, temperature, userInput).Result);
		
        return new Answer { Text = answer, File = answerFile };
    }

    public string Ask(string prompt, out string answerFile)
    {
		Answer answer = AskAsync(prompt).Result;
		
		answerFile = answer.File;
		
        return answer.Text;
    }
}

static class Program
{
    static async void ReadPrompts(List<string> prompts, string fileName)
    {
        while (true)
        {
            if (File.Exists(fileName))
                try {
                    StreamReader promptStream = new StreamReader(fileName);

                    string prompt = promptStream.ReadToEnd();

                    promptStream.Close();

                    File.Delete(fileName);

					lock(prompts) {
						prompts.Add(prompt);
					}
                }
                catch { }

            Thread.Sleep(100);
        }
    }
	
    static string WaitForPrompt(List<string> prompts)
    {
		using (Process p = Process.GetCurrentProcess()) 
			p.PriorityClass = ProcessPriorityClass.BelowNormal; 

        while (true)
        {
			lock(prompts) {
				if (prompts.Count > 0) {
					string prompt = prompts[0];

					prompts.Remove(prompt);
					
					return prompt;
				}
			}

            Thread.Sleep(100);
        }
    }

    [STAThread]
    static void Main(string[] args)
    {
		List<string> prompts = new List<string>();
		
        Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

		try
        {
            LLMExecutor executor = new LLMExecutor(args[1],
                                                   (args.Length > 2) ? int.Parse(args[2]) : 2048,
                                                   (args.Length > 3) ? int.Parse(args[3]) : 0,
												   ((args.Length > 4) ? args[4] : "Strict") == "Strict",
												   (args.Length > 5) ? uint.Parse(args[5]) : 32768,
												   (args.Length > 6) ? uint.Parse(args[6]) : 256,
												   (args.Length > 7) ? int.Parse(args[7]) : Math.Max(1, Environment.ProcessorCount / 2));

			Task.Run(() => ReadPrompts(prompts, args[0]));
			
            while (true)
            {
                string prompt = WaitForPrompt(prompts);

                if (prompt.Trim() == "Exit")
                    break;

                try
                {
					string answerFile;
                    string answer = executor.Ask(prompt, out answerFile);
                    StreamWriter outStream = new StreamWriter(answerFile, false, Encoding.Unicode);

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