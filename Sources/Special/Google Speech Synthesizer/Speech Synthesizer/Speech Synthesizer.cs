using Google.Cloud.TextToSpeech.V1;
using Google.Apis.Auth.OAuth2;

namespace Speech
{
    public class GoogleSpeechSynthesizer
    {
        private string synthesizerType = "Google";

        private string credentials = "";

        public GoogleSpeechSynthesizer()
        {
        }

        public bool Connect(string mode, string credentials)
        {
            this.synthesizerType = "Google";
            this.credentials = credentials;

            return true;
        }

        private string voice;
        private string gender;
        private string culture;

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

        public bool SpeakSsmlToFile(string outputFile, string text)
        {
            return SynthesizeAudio(outputFile, true, text);
        }

        public bool SpeakTextToFile(string outputFile, string text)
        {
            return SynthesizeAudio(outputFile, false, text);
        }

        public string GetVoices(string language)
        {
            if (this.synthesizerType == "Google")
            {
                var credentials = GoogleCredential.FromFile(this.credentials);
                TextToSpeechClient client = TextToSpeechClient.Create();

                string voices = "";
                var response = client.ListVoices(language);
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