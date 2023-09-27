using Azure;
using Azure.AI.OpenAI;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

namespace OpenAI {
    public class OpenAIConnector {
		public class Conversation
        {
            public string Question;
            public string Answer;
        }

        public string Server { get; set; } = "";
        public string Key { get; set; } = "";

        public OpenAIClient Service;
        public string Model = "";
        public int MaxToken = 2048;

        public string System { get; set; } = "";
        
        public List<Conversation> Transcript = new List<Conversation>();

        public OpenAIConnector() {
        }
        public void Connect(string server, string key, string model, int maxToken = 2048, string system = null)
		{
            string exeDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            Directory.SetCurrentDirectory(exeDir);

            Server = server;
            Key = key;
            MaxToken = maxToken;

            Service = (server != "") ? new OpenAIClient(new Uri(server), new AzureKeyCredential(key)) : new OpenAIClient(key, new OpenAIClientOptions());

            Transcript = new List<Conversation>();

            switch (model)
            {
                case "GPT 4":
                    Model = "gpt-4";

                    break;
                case "GPT 4 32k":
                    Model = "gpt-4-32k";

                    break;
                case "GPT 3.5 turbo":
                    Model = "gpt-3.5-turbo";

                    break;
                case "GPT 3.5 turbo 16k":
                    Model = "gpt-3.5-turbo-16k";

                    break;
                default:
                    Model = model;

                    break;
            }

            if (system != null)
                SetSystem(system);
        }

        public void SetSystem(string system)
        {
            System = system;
        }

        public void AddConversation(string question, string answer)
        {
            Transcript.Add(new Conversation() { Question = question, Answer = answer });
        }

        public void DiscardConversations()
        {
            /*
            int GetTokenCount() {
                int count = TokenizerGpt3.TokenCount(System);

                foreach (var message in Transcript)
                    count += (TokenizerGpt3.TokenCount(message.Question) + TokenizerGpt3.TokenCount(message.Answer));

                return count;
            }

            while ((GetTokenCount() > MaxToken) && (Transcript.Count > 0))
                Transcript.RemoveAt(0);
            */
        }

        public string Ask(string question)
        {
            List<ChatMessage> messages = new List<ChatMessage>();

            if (System != "")
                messages.Add(new ChatMessage(ChatRole.System, System));

            foreach (var message in Transcript)
            {
                messages.Add(new ChatMessage(ChatRole.User, message.Question));
                messages.Add(new ChatMessage(ChatRole.Assistant, message.Answer));
            }

            messages.Add(new ChatMessage(ChatRole.User, question));

            var options = new ChatCompletionsOptions();

            foreach (ChatMessage chatMessage in messages)
                options.Messages.Add(chatMessage);

            string answer = Service.GetChatCompletions(Model, options).ToString();

            AddConversation(question, answer);

            DiscardConversations();

            return answer;
        }
    }
}