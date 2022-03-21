using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

// 
// https://github.com/Azure-Samples/cognitive-services-speech-sdk/blob/master/samples/csharp/sharedcontent/console/speech_synthesis_samples.cs
// 

namespace Speech {
    public class SpeechSynthesizer {
        private string synthesizerType = "Windows";

        private string tokenIssuerEndpoint;
        private string subscriptionKey;
        private string region = "";

        private SpeechConfig config = null;
        private string token = null;

        private int rate;
        private int volume;


        private DateTimeOffset nextTokenRenewal = DateTime.Now - new TimeSpan(0, 10, 0);

        public SpeechSynthesizer() {
        }
        
        public bool Connect(string tokenIssuerEndpoint, string subscriptionKey) {
            this.synthesizerType = "Azure";

            this.tokenIssuerEndpoint = tokenIssuerEndpoint;
            this.subscriptionKey = subscriptionKey;

            region = tokenIssuerEndpoint.Substring(8);
            region = region.Substring(0, region.IndexOf(".api."));

            try {
                RenewToken();

                return true;
            }
            catch (Exception e) {
                return false;
            }
        }

        private void RenewToken() {
            if (token == null || DateTime.Now >= nextTokenRenewal) {
                config = SpeechConfig.FromEndpoint(new System.Uri(tokenIssuerEndpoint), subscriptionKey);

                try {
                    token = GetToken();
                }
                catch (Exception e) {
                    token = null;
                }
                
                nextTokenRenewal = new DateTimeOffset(DateTime.Now + new TimeSpan(TimeSpan.TicksPerMinute * 9));
            }
        }

        public string GetToken() {
            var httpClient = new HttpClient();
            
            httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", subscriptionKey);

            var result = httpClient.PostAsync(tokenIssuerEndpoint, null).Result;
            
            if (result.IsSuccessStatusCode)
                return result.Content.ReadAsStringAsync().Result;
            else
                throw new HttpRequestException($"Cannot get token from {tokenIssuerEndpoint}. Error: {result.StatusCode}");
        }

        public void SetProsody(int rate, int volume)
        {
            this.rate = rate;
            this.volume = volume;
        }

        private bool finished = false;
        private bool failed = false;

        private bool SynthesizeAudio(string outputFile, bool isSsml, string text) {
            if (this.synthesizerType == "Windows")
            {
                using var synth = new System.Speech.Synthesis.SpeechSynthesizer();

                synth.Rate = rate;
                synth.Volume = volume;

                synth.SetOutputToWaveFile(outputFile);

                finished = false;
                failed = false;

                synth.SpeakCompleted += OnSpeakCompleted;

                if (isSsml)
                    synth.SpeakSsmlAsync(text);
                else
                    synth.SpeakAsync(text);

                while (!finished)
                    Thread.Sleep(100);

                return true;
            }
            else
            {
                RenewToken();

                using var audioConfig = AudioConfig.FromWavFileOutput(outputFile);
                using var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, audioConfig);

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

        private void OnSpeakCompleted(object sender, System.Speech.Synthesis.SpeakCompletedEventArgs e) {
            finished = true;

        }

        public string GetVoices() {
            if (this.synthesizerType == "Azure")
            {
                RenewToken();

                return SynthesisGetAvailableVoicesAsync().Result;
            }
            else
            {
                var synth = new System.Speech.Synthesis.SpeechSynthesizer();
                string voices = "";

                foreach (var voice in synth.GetInstalledVoices())
                {
                    if (voices.Length > 0)
                        voices += "|";

                    voices += voice.VoiceInfo.Name + " (" + voice.VoiceInfo.Culture.Name + ")";
                }

                return voices;
            }
        }

        private async Task<string> SynthesisGetAvailableVoicesAsync() {
            try {
                string voices = "";

                var config = SpeechConfig.FromSubscription(subscriptionKey, region);

                using (var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, null)) {
                    using (var result = await synthesizer.GetVoicesAsync()) {
                        if (result.Reason == ResultReason.VoicesListRetrieved) {
                            foreach (var voice in result.Voices) {
                                if (voices.Length > 0)
                                    voices += "|";

                                voices += voice.ShortName + " (" + voice.Locale + ")";
                            }
                        }
                    }
                }

                return voices;
            }
            catch (Exception e) {
                return "";
            }
        }
    }
}