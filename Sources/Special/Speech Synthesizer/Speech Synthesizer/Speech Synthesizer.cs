using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

// 
// https://github.com/Azure-Samples/cognitive-services-speech-sdk/blob/master/samples/csharp/sharedcontent/console/speech_synthesis_samples.cs
// 

namespace Speech {
    public class SpeechSynthesizer {
        private string tokenIssuerEndpoint;
        private string subscriptionKey;

        private string token;
        private string region;

        private SpeechConfig config = null;

        private DateTimeOffset nextTokenRenewal = DateTime.Now - new TimeSpan(0, 10, 0);

        public SpeechSynthesizer() {
        }
        
        public bool Connect(string tokenIssuerEndpoint, string subscriptionKey) {
            this.tokenIssuerEndpoint = tokenIssuerEndpoint;
            this.subscriptionKey = subscriptionKey;

            try {
                RenewToken();

                return true;
            }
            catch (Exception e) {
                return false;
            }
        }

        private void RenewToken() {
            if (DateTime.Now >= nextTokenRenewal) {
                config = SpeechConfig.FromEndpoint(new System.Uri(tokenIssuerEndpoint), subscriptionKey);

                region = tokenIssuerEndpoint.Substring(8);
                region = region.Substring(0, region.IndexOf(".api."));

                token = GetToken().Result;
                
                nextTokenRenewal = new DateTimeOffset(DateTime.Now + new TimeSpan(TimeSpan.TicksPerMinute * 9));
            }
        }

        public async Task<string> GetToken() {
            using (var client = new HttpClient()) {
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", subscriptionKey);
                UriBuilder uriBuilder = new UriBuilder(tokenIssuerEndpoint);

                using (var result = await client.PostAsync(uriBuilder.Uri.AbsoluteUri, null)) {
                    if (result.IsSuccessStatusCode) {
                        return await result.Content.ReadAsStringAsync();
                    }
                    else {
                        throw new HttpRequestException($"Cannot get token from {uriBuilder.ToString()}. Error: {result.StatusCode}");
                    }
                }
            }
        }

        private bool finished = false;
        private bool failed = false;

        private bool SynthesizeAudio(string outputFile, bool isSsml, string text) {
            using var audioConfig = AudioConfig.FromWavFileOutput(outputFile);
            using var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, audioConfig);

            RenewToken();

            finished = false;
			failed = false;

            synthesizer.SynthesisCanceled += OnSynthesisCanceled;
            synthesizer.SynthesisCompleted += OnSynthesisCompleted;

            if (isSsml)
                synthesizer.SpeakSsmlAsync(text);
            else
                synthesizer.SpeakTextAsync(text);

            while (!finished)
                Thread.Sleep(100);

            return !failed;
        }

        public bool SpeakSsmlToFile(string outputFile, string text) {
            return SynthesizeAudio(outputFile, true, text);
        }

        public bool SpeakTextToFile(string outputFile, string text) {
            return SynthesizeAudio(outputFile, false, text);
        }

        private void OnSynthesisCanceled(object sender, SpeechSynthesisEventArgs e) {
            failed = true;
            finished = true;
        }

        private void OnSynthesisCompleted(object sender, SpeechSynthesisEventArgs e) {
            finished = true;
        }

        public string GetVoices() {
            RenewToken();

            return SynthesisGetAvailableVoicesAsync().Result;
        }

        private async Task<string> SynthesisGetAvailableVoicesAsync() {
            string voices = "";

            var config = SpeechConfig.FromAuthorizationToken(token, region);

            using (var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, null)) {
                using (var result = await synthesizer.GetVoicesAsync()) {
                    if (result.Reason == ResultReason.VoicesListRetrieved) {
                        foreach (var voice in result.Voices) {
                            if (voices.Length > 0)
                                voices += "|";

                            voices += voice.Name + " (" + voice.Locale + ")";
                        }
                    }
                }
            }

            return voices;
        }
    }
}