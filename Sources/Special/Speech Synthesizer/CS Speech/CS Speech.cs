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

namespace CSSpeech {
    public class SpeechSynthesizer {
        private string tokenIssuerEndpoint;
        private string subscriptionKey;
        private SpeechConfig config = null;

        private DateTimeOffset nextTokenRenewal = DateTime.Now;

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
                this.config = SpeechConfig.FromEndpoint(new System.Uri(tokenIssuerEndpoint), subscriptionKey);

                nextTokenRenewal = new DateTimeOffset(DateTime.Now + new TimeSpan(TimeSpan.TicksPerMinute * 9));
            }
        }

        private bool finished = false;

        private void SynthesizeAudio(string outputFile, bool isSsml, string text) {
            using var audioConfig = AudioConfig.FromWavFileOutput(outputFile);
            using var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, audioConfig);

            RenewToken();

            finished = false;

            synthesizer.SynthesisCompleted += OnSynthesisCompleted;

            if (isSsml)
                synthesizer.SpeakSsmlAsync(text);
            else
                synthesizer.SpeakTextAsync(text);

            while (!finished)
                Thread.Sleep(100);
        }

        public void SpeakSsmlToFile(string outputFile, string text) {
            SynthesizeAudio(outputFile, true, text);
        }

        public void SpeakTextToFile(string outputFile, string text) {
            SynthesizeAudio(outputFile, false, text);
        }

        private void OnSynthesisCompleted(object sender, SpeechSynthesisEventArgs e) {
            finished = true;
        }

        private string voices = "";

        public string GetVoices() {
            RenewToken();

            finished = false;
            voices = "";

            _ = SynthesisGetAvailableVoicesAsync();

            while (!finished)
                Thread.Sleep(100);

            string result = voices;

            voices = "";

            return result;
        }

        private async Task SynthesisGetAvailableVoicesAsync() {
            using (var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, null as AudioConfig)) {
                using (var result = await synthesizer.GetVoicesAsync("")) {
                    if (result.Reason == ResultReason.VoicesListRetrieved) {
                        foreach (var voice in result.Voices) {
                            if (voices.Length > 0)
                                voices += "|";

                            voices += voice.Name + " (" + voice.Locale + ")";
                        }

                        finished = true;
                    }
                    else {
                        finished = true;
                    }
                }
            }
        }
    }
}