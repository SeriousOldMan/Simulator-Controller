using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.IO;
using System.Text;
using System.Diagnostics.Contracts;
using System.Xml.Linq;
using System.Net.Http.Headers;

namespace YandexConnector
{
    public class SpeechRecognizer
    {
        static readonly HttpClient httpClient = new HttpClient();

        public class Parameters : Dictionary<string, string> { }

        private string ServerURL = "https://stt.api.cloud.yandex.net";
        private string Language = "ru-Ru";
        private string Model = "general";

        public SpeechRecognizer() {
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
        }

        #region Requests
        public void ValidateResult(string result)
        {
            if (result.StartsWith("Error:"))
                throw new Exception(result.Replace("Error:", "").Trim());
        }

        public string BuildBody(Parameters parameters)
        {
            string keyValues = "";

            if (parameters.Count > 0)
                foreach (var kv in parameters)
                {
                    if (keyValues.Length > 0)
                        keyValues += '\n';

                    keyValues += kv.Key + "=" + kv.Value;
                }

            return keyValues;
        }

        public string BuildRequest(string request, Parameters parameters = null)
        {
            string arguments = "";

            if ((parameters != null) && (parameters.Count > 0))
            {
                foreach (var kv in parameters)
                {
                    if (arguments.Length > 0)
                        arguments += "&";

                    arguments += kv.Key + "=" + kv.Value;
                }
            }

            if (arguments.Length > 0)
                arguments = "?" + arguments;

            return ServerURL + request + arguments;
        }

        public string Post(string request, Parameters arguments = null, string fileName = "")
        {
            string result;

            try
            {
                HttpContent content = new StreamContent(new FileStream(fileName, FileMode.Open));

                HttpResponseMessage response = httpClient.PostAsync(BuildRequest(request, arguments), content).Result;

                response.EnsureSuccessStatusCode();

                result = response.Content.ReadAsStringAsync().Result;
            }
            catch (Exception e)
            {
                result = "Error: " + e.Message;
            }

            ValidateResult(result);

            return result;
        }
        #endregion

        public void Initialize(string url, string language, string apiKey)
        {
            this.ServerURL = url + "/";
            this.Language = language;

            httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Api-Key", apiKey);
        }

        public void SetModel(string model)
        {
            this.Model = model;
        }

        public string Recognize(string rawAudioFile)
        {
            return Post("speech/v1/stt:recognize",
                        arguments: new Parameters() { { "lang", this.Language },
                                                      { "topic", this.Model },
                                                      { "format", "lpcm" },
                                                      { "sampleRateHertz", "16000" } },
                        fileName: rawAudioFile);
}
}
}
