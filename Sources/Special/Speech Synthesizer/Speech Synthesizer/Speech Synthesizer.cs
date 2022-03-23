using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using System;
using System.Net.Http;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Reflection;
using System.Collections;

// 
// https://github.com/Azure-Samples/cognitive-services-speech-sdk/blob/master/samples/csharp/sharedcontent/console/speech_synthesis_samples.cs
// 

namespace Speech {
    public static class SpeechApiReflectionHelper
    {
        private const string PROP_VOICE_SYNTHESIZER = "VoiceSynthesizer";
        private const string FIELD_INSTALLED_VOICES = "_installedVoices";

        private const string ONE_CORE_VOICES_REGISTRY = @"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore\Voices";

        private static readonly Type ObjectTokenCategoryType = typeof(System.Speech.Synthesis.SpeechSynthesizer).Assembly
            .GetType("System.Speech.Internal.ObjectTokens.ObjectTokenCategory")!;

        private static readonly Type VoiceInfoType = typeof(System.Speech.Synthesis.SpeechSynthesizer).Assembly
            .GetType("System.Speech.Synthesis.VoiceInfo")!;

        private static readonly Type InstalledVoiceType = typeof(System.Speech.Synthesis.SpeechSynthesizer).Assembly
            .GetType("System.Speech.Synthesis.InstalledVoice")!;


        public static void InjectOneCoreVoices(this System.Speech.Synthesis.SpeechSynthesizer synthesizer)
        {
            var voiceSynthesizer = GetProperty(synthesizer, PROP_VOICE_SYNTHESIZER);
            if (voiceSynthesizer == null) throw new NotSupportedException($"Property not found: {PROP_VOICE_SYNTHESIZER}");

            var installedVoices = GetField(voiceSynthesizer, FIELD_INSTALLED_VOICES) as IList;
            if (installedVoices == null)
                throw new NotSupportedException($"Field not found or null: {FIELD_INSTALLED_VOICES}");

            if (ObjectTokenCategoryType
                    .GetMethod("Create", BindingFlags.Static | BindingFlags.NonPublic)?
                    .Invoke(null, new object?[] { ONE_CORE_VOICES_REGISTRY }) is not IDisposable otc)
                throw new NotSupportedException($"Failed to call Create on {ObjectTokenCategoryType} instance");

            using (otc)
            {
                if (ObjectTokenCategoryType
                        .GetMethod("FindMatchingTokens", BindingFlags.Instance | BindingFlags.NonPublic)?
                        .Invoke(otc, new object?[] { null, null }) is not IList tokens)
                    throw new NotSupportedException($"Failed to list matching tokens");

                foreach (var token in tokens)
                {
                    if (token == null || GetProperty(token, "Attributes") == null) continue;

                    var voiceInfo =
                        typeof(System.Speech.Synthesis.SpeechSynthesizer).Assembly
                            .CreateInstance(VoiceInfoType.FullName!, true,
                                BindingFlags.Instance | BindingFlags.NonPublic, null,
                                new object[] { token }, null, null);

                    if (voiceInfo == null)
                        throw new NotSupportedException($"Failed to instantiate {VoiceInfoType}");

                    var installedVoice =
                        typeof(System.Speech.Synthesis.SpeechSynthesizer).Assembly
                            .CreateInstance(InstalledVoiceType.FullName!, true,
                                BindingFlags.Instance | BindingFlags.NonPublic, null,
                                new object[] { voiceSynthesizer, voiceInfo }, null, null);

                    if (installedVoice == null)
                        throw new NotSupportedException($"Failed to instantiate {InstalledVoiceType}");

                    installedVoices.Add(installedVoice);
                }
            }
        }

        private static object? GetProperty(object target, string propName)
        {
            return target.GetType().GetProperty(propName, BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(target);
        }

        private static object? GetField(object target, string propName)
        {
            return target.GetType().GetField(propName, BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(target);
        }
    }

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

                try {
                    synth.InjectOneCoreVoices();
                }
                catch {
                }

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
                using var synth = new System.Speech.Synthesis.SpeechSynthesizer();

                try {
                    synth.InjectOneCoreVoices();
                }
                catch {
                }

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