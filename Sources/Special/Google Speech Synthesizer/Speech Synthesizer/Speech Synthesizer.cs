using Google.Cloud.TextToSpeech.V1;
using Google.Apis.Auth.OAuth2;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json.Linq;
using System.Drawing;
using static Google.Rpc.Context.AttributeContext.Types;

namespace Speech
{
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

    public class GoogleSpeechSynthesizer
    {
        static readonly HttpClient httpClient = new HttpClient();

        private string synthesizerType = "Google";

        private string credentials = "";

        private string ServerURL = "https://texttospeech.googleapis.com/v1/";
        private String Token = "";


        public GoogleSpeechSynthesizer()
        {
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
            string arguments = (Token.Length > 0) ? "key=" + Token : "";

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

        public bool Connect(string mode, string credentials)
        {
            this.synthesizerType = "Google";
            this.credentials = credentials;

            return true;
        }

        private string voice = "";
        private string gender = "";
        private string culture = "";

        public void SetVoice(string voice, string gender, string culture)
        {
            this.voice = voice;
            this.gender = gender;
            this.culture = culture;
        }

        private bool SynthesizeAudio(string outputFile, bool isSsml, string text)
        {
            var client = TextToSpeechClient.Create();

            // The input to be synthesized, can be provided as text or SSML.
            var input = new SynthesisInput { Text = text };

            // Build the voice request.
            var voiceSelection = new VoiceSelectionParams
            {
                LanguageCode = this.culture,
                SsmlGender = this.gender == "Male" ? SsmlVoiceGender.Male : SsmlVoiceGender.Female,
                Name = this.voice
            };

            // Specify the type of audio file.
            var audioConfig = new Google.Cloud.TextToSpeech.V1.AudioConfig
            {
                AudioEncoding = Google.Cloud.TextToSpeech.V1.AudioEncoding.Linear16
            };

            // Perform the text-to-speech request.
            var response = client.SynthesizeSpeech(input, voiceSelection, audioConfig);

            // Write the response to the output file.
            using (var output = File.Create(outputFile))
            {
                response.AudioContent.WriteTo(output);

                output.Close();
            }

            return true;
        }

        public void WriteAudio(string decodedAudio, string outputFile)
        {
            using (var output = File.Create(outputFile))
            {
                byte[] bytes = System.Convert.FromBase64String(decodedAudio);

                output.Write(bytes, 0, bytes.Length);

                output.Close();
            }
        }

        public bool SpeakSsmlToFile(string outputFile, string text)
        {
            return SynthesizeAudio(outputFile, true, text);
        }

        public bool SpeakTextToFile(string outputFile, string text)
        {
            return SynthesizeAudio(outputFile, false, text);
        }

        public string GetVoices()
        {
            if (this.synthesizerType == "Google")
            {
                var credentials = GoogleCredential.FromFile(this.credentials);
                TextToSpeechClient client = TextToSpeechClient.Create();

                string voices = "";
                var response = client.ListVoices(new ListVoicesRequest());
                foreach (var voice in response.Voices)
                {
                    if (voices.Length > 0)
                        voices += "|";

                    voices += (voice.Name + " (" + voice.SsmlGender + ") (" + string.Join(", ", voice.LanguageCodes) + ")");
                }

                return voices;
            }
            else
                return "";
        }
    }
}