using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace CSSpeech {
    public class SpeechSynthesizer {
        private string tokenIssuerEndpoint;
        private string subscriptionKey;
        private string token = null;
        private SpeechConfig config = null;

        public SpeechSynthesizer() {
        }
        
        public bool Connect(string tokenIssuerEndpoint, string subscriptionKey) {
            this.tokenIssuerEndpoint = tokenIssuerEndpoint;
            this.subscriptionKey = subscriptionKey;

            this.config = SpeechConfig.FromEndpoint(new System.Uri(tokenIssuerEndpoint), subscriptionKey);

            try {
                RenewToken();

                return true;
            }
            catch {
                return false;
            }
        }

        public string GetAccessToken() {
            return this.token;
        }

        public async void SpeakToFile(string outputFile, string ssml) {
            RenewToken();

            await SynthesizeAudioAsync(config, outputFile, ssml);
        }

        private void RenewToken() {
            if (token == null) {
                this.token = FetchTokenAsync(this.tokenIssuerEndpoint, this.subscriptionKey).Result;

                config.AuthorizationToken = this.token;
            }
        }

        private async Task SynthesizeAudioAsync(SpeechConfig config, string outputFile, string ssml) {
            using var audioConfig = AudioConfig.FromWavFileOutput(outputFile);
            using var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, audioConfig);

            await synthesizer.SpeakSsmlAsync(ssml);
        }

        private async Task<string> FetchTokenAsync(string fetchUri, string subscriptionKey) {
            using (var client = new HttpClient()) {
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", subscriptionKey);
                UriBuilder uriBuilder = new UriBuilder(fetchUri);

                var result = await client.PostAsync(uriBuilder.Uri.AbsoluteUri, null);
                // Console.WriteLine("Token Uri: {0}", uriBuilder.Uri.AbsoluteUri);
                return await result.Content.ReadAsStringAsync();
            }
        }

        /*
        private bool finished = false;

        public void SpeakToFile(string outputFile, string ssml) {
            using var audioConfig = AudioConfig.FromWavFileOutput(outputFile);
            using var synthesizer = new Microsoft.CognitiveServices.Speech.SpeechSynthesizer(config, audioConfig);

            finished = false;

            synthesizer.SynthesisCompleted += OnSynthesisCompleted;

            synthesizer.SpeakSsmlAsync(ssml);

            while (!finished)
                Thread.Sleep(100);
        }

        private void OnSynthesisCompleted(object sender, SpeechSynthesisEventArgs e) {
            finished = true;
        }
        */
    }
}