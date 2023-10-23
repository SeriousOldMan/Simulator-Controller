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

        public bool Connect(string credentials)
        {
            this.synthesizerType = "Google";
            this.credentials = credentials;

            return true;
        }

        private bool SynthesizeAudio(string outputFile, bool isSsml, string text)
        {
            return false;
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