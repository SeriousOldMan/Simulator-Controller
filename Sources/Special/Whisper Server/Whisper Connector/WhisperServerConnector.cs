using System.Net;
using System.Text;

namespace WhisperServerConnector
{
    public class WhisperServerConnector
    {
        static readonly HttpClient httpClient = new HttpClient();

        public class Parameters : Dictionary<string, string>
        {
            public Parameters() { }

            public Parameters(string keyValues)
            {
                foreach (var kv in ParseKeyValues(keyValues))
                    this[kv.Key] = kv.Value;
            }

            public static Dictionary<string, string> ParseKeyValues(string text)
            {
                var keyValues = text.Replace("\r", "").Split('\n');

                return keyValues.Select(value => value.Split('=')).ToDictionary(pair => pair[0].Trim(), pair => pair[1].Trim());
            }
        }

        string ServerURL = "";
        string Language = "";
        string Model = "";

        public WhisperServerConnector()
        {
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
        }

        public void Initialize(string url, string language, string model)
        {
            ServerURL = url + ((url[url.Length - 1] == '/') ? "Whisper/" : "/Whisper/");
            Language = language.ToLower();
            Model = model.ToLower();
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

        public string Get(string request, Parameters arguments = null, string body = null)
        {
            string result;

            try
            {
                string uri = BuildRequest(request, arguments);

                if (body == null)
                    result = httpClient.GetStringAsync(uri).Result;
                else
                {
                    var httpRequest = new HttpRequestMessage
                    {
                        Method = HttpMethod.Get,
                        RequestUri = new Uri(uri),
                        Content = new StringContent(body, Encoding.Unicode)
                    };

                    var response = httpClient.SendAsync(httpRequest).Result;

                    response.EnsureSuccessStatusCode();

                    result = response.Content.ReadAsStringAsync().Result;
                }
            }
            catch (Exception e)
            {
                result = "Error: " + e.Message;
            }

            ValidateResult(result);

            return result;
        }

        public string Put(string request, Parameters arguments = null, string body = "")
        {
            string result;

            try
            {
                HttpContent content = new StringContent(body, Encoding.Unicode);

                HttpResponseMessage response = httpClient.PutAsync(BuildRequest(request, arguments), content).Result;

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

        public string Post(string request, Parameters arguments = null, string body = "")
        {
            string result;

            try
            {
                HttpContent content = new StringContent(body, Encoding.Unicode);

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

        public void Delete(string request, Parameters arguments = null)
        {
            string result;

            try
            {
                HttpResponseMessage response = httpClient.DeleteAsync(BuildRequest(request, arguments)).Result;

                response.EnsureSuccessStatusCode();

                result = response.Content.ReadAsStringAsync().Result;
            }
            catch (Exception e)
            {
                result = "Error: " + e.Message;
            }

            ValidateResult(result);
        }
        #endregion

        #region SpeechToText
        public string Recognize(string audioFileName)
        {
            string result;

            try
            {
                string audio = Convert.ToBase64String(File.ReadAllBytes(audioFileName));

                result = Post("recognize", new Parameters() { { "Language", Language }, { "Model", Model } }, body: audio);
            }
            catch (Exception e)
            {
                result = "Error: " + "Error reading audio file: " + e.Message;
            }
            
            ValidateResult(result);

            return result;
        }
        #endregion
    }
}
