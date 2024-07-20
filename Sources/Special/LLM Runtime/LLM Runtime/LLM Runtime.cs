using LLama.Common;
using LLama;
using System.Globalization;
using System.Text;

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
        using var context = Model.CreateContext(Parameters);
        Executor = new InteractiveExecutor(context);
    }

    public string ParsePrompt(ChatHistory chatHistory, string prompt)
    {
        void addMessage(AuthorRole role, string message)
        {
            if (role != AuthorRole.Unknown)
                chatHistory.AddMessage(role, message);
        }

        AuthorRole role = AuthorRole.Unknown;
        string message = "";

        foreach (string line in prompt.Split(new string[] { Environment.NewLine }, StringSplitOptions.None))
        {
            string input = line.Trim();

            if (input.StartsWith("<|###"))
            {
                addMessage(role, message);

                message = "";

                if (input == "<|### System ###|>")
                    role = AuthorRole.System;
                else if (input == "<|### Assistant ###|>")
                    role = AuthorRole.Assistant;
                else if (input == "<|### User ###|>")
                    role = AuthorRole.User;
            }
            else
                message += input;
        }

        return (role == AuthorRole.User) ? message : "";
    }

    public async Task<string> Ask(string prompt)
    {
        // Add chat histories as prompt to tell AI how to act.
        var chatHistory = new ChatHistory();

        string userInput = ParsePrompt(chatHistory, prompt);
        
        ChatSession session = new(Executor, chatHistory);

        InferenceParams inferenceParams = new InferenceParams()
        {
            MaxTokens = MaxTokens,
            AntiPrompts = new List<string> { "User:" }
        };

        string result = "";

        await foreach (
            var text
            in session.ChatAsync(
                new ChatHistory.Message(AuthorRole.User, userInput),
                inferenceParams))
            result += text;

        return result;
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
                    Task<string> answer = executor.Ask(prompt);

                    StreamWriter outStream = new StreamWriter(args[1], false, Encoding.Unicode);

                    outStream.Write(answer.Result);

                    outStream.Close();
                }
                catch (Exception e)
                {
                    StreamWriter outStream = new StreamWriter(args[1], false, Encoding.Unicode);

                    outStream.Write("Error");

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