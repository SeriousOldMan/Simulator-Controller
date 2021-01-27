using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Microsoft.Speech.Recognition;

// Get Started with Speech Recognition (Microsoft.Speech):
// https://msdn.microsoft.com/en-us/library/hh378426(v=office.14).aspx

// Namespace Reference
// https://msdn.microsoft.com/en-us/library/microsoft.speech.recognition(v=office.14).aspx

// Install stuff from here:
// https://msdn.microsoft.com/en-us/library/hh362873(v=office.14).aspx#Anchor_2

// Plus a recognizer:
// https://www.microsoft.com/en-us/download/details.aspx?id=27224

namespace HotVoice
{
    public partial class HotVoice
    {
        private SpeechRecognitionEngine _recognizer;
        private dynamic _volumeCallback;
        private int _volumeLevel = 0;
        private bool _recognizerRunning;
        private readonly List<RecognizerInfo> _recognizers;
        private readonly  Dictionary<string, Choices> _choicesDictionary = new Dictionary<string, Choices>(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, LoadedGrammar> _loadedHotGrammarDictionary = new Dictionary<string, LoadedGrammar>(StringComparer.OrdinalIgnoreCase);

        #region Startup
        public HotVoice()
        {
            _recognizers = SpeechRecognitionEngine.InstalledRecognizers().ToList();
            var percentileChoices = new Choices();
            for (var i = 0; i <= 100; i++)
                percentileChoices.Add(i.ToString());
            _choicesDictionary.Add("Percent", percentileChoices);
        }

        /// <summary>
        /// Checks that you can speak to this Library
        /// </summary>
        /// <returns>OK</returns>
        public string OkCheck()
        {
            return "OK";
        }

        /// <summary>
        /// Start the Recognizer
        /// </summary>
        /// <param name="recognizerId">The RecognizerID to use</param>
        public void Initialize(int recognizerId = 0)
        {
            if (_recognizer != null) // If recognizer already initialized, stop it, as we may be loading a new language
            {
                StopRecognizer();
                _recognizer.SpeechRecognized -= Recognizer_SpeechRecognized;
            }
            AssertRecognizerExists(recognizerId);

            _recognizer = new SpeechRecognitionEngine(_recognizers[recognizerId].Culture);

            // Add a handler for the speech recognized event.
            _recognizer.SpeechRecognized += Recognizer_SpeechRecognized;

            // Configure the input to the speech recognizer.
            _recognizer.SetInputToDefaultAudioDevice();
        }

        /// <summary>
        /// Loads a HotGrammar object into the recognizer
        /// </summary>
        /// <param name="hotGrammar"></param>
        /// <param name="name">The name to give the Grammar</param>
        /// <param name="callback">The code to fire when the Grammar is spoken</param>
        /// <returns></returns>
        public string LoadGrammar(HotGrammar hotGrammar, string name, dynamic callback)
        {
            _loadedHotGrammarDictionary.Add(name, new LoadedGrammar { HotGrammar = hotGrammar, Callback = callback });
            var g = new Grammar(hotGrammar.GrammarBuilder) { Name = name };
            _recognizer.LoadGrammar(g);
            return hotGrammar.GetPhrases();
        }

        /// <summary>
        /// Request a callback when the Mic Volume changes
        /// </summary>
        /// <param name="callback">The code to call when the volume changes</param>
        /// <returns></returns>
        public bool SubscribeVolume(dynamic callback)
        {
            try
            {
                _volumeCallback = callback;
                _recognizer.AudioLevelUpdated += Recognizer_AudioLevelUpdated;
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Starts listening for voice input
        /// </summary>
        public bool StartRecognizer()
        {
            if (_recognizerRunning)
            {
                StopRecognizer();
            }
            if (!_recognizerRunning)
            {
                try
                {
                    // Start asynchronous, continuous speech recognition.
                    _recognizer.RecognizeAsync(RecognizeMode.Multiple);
                    _recognizerRunning = true;

                    return true;
                }
                catch
                {
                    return false;
                }
            }
            else
                return true;

        }

        public bool StopRecognizer()
        {
            if (_recognizerRunning)
            {
                try
                {
                    _recognizer.RecognizeAsyncStop();
                    _recognizerRunning = false;

                    return true;
                }
                catch
                {
                    return false;
                }
            }
            else
                return true;
        }
        #endregion

        #region Grammar and Choice Dictionary manipulation
        public HotGrammar GetLoadedHotGrammar(string name)
        {
            return _loadedHotGrammarDictionary[name].HotGrammar;
        }

        public Choices GetChoices(string name)
        {
            if (!_choicesDictionary.ContainsKey(name))
            {
                throw new Exception($"Could not find Choice Var {name}");
            }

            return _choicesDictionary[name];
        }

        public void SetChoices(string name, Choices choices)
        {
            _choicesDictionary.Add(name, choices);
        }
        #endregion

        #region Recognizers

        public int GetRecognizerCount()
        {
            return _recognizers.Count;
        }

        public void AssertRecognizerExists(int recognizerId)
        {
            if (_recognizers.Count() < recognizerId)
            {
                throw new Exception($"Recognizer ID {recognizerId} does not exist");
            }
        }

        public string GetRecognizerName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Name;
        }

        public string GetRecognizerTwoLetterISOLanguageName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Culture.TwoLetterISOLanguageName;
        }

        public string GetRecognizerLanguageDisplayName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Culture.DisplayName;
        }

        public List<RecognizerInfo> GetRecognizerInfos()
        {
            return _recognizers;
        }

        #endregion

        #region Event Handling
        // Handle the SpeechRecognized event.
        private void Recognizer_SpeechRecognized(object sender, SpeechRecognizedEventArgs e)
        {
            var name = e.Result.Grammar.Name;
            var words = new string[e.Result.Words.Count];
            for (var i = 0; i < e.Result.Words.Count; i++)
            {
                words[i] = e.Result.Words[i].Text;
            }

            try
            {
                _loadedHotGrammarDictionary[name].Callback(name, words);
                //_loadedHotGrammarDictionary[name](name, words);
            }
            catch
            {
                // ignore for now
            }
        }

        // Write the audio level to the console when the AudioLevelUpdated event is raised.
        private void Recognizer_AudioLevelUpdated(object sender, AudioLevelUpdatedEventArgs e)
        {
            if (e.AudioLevel != _volumeLevel)
            {
                _volumeLevel = e.AudioLevel;
                _volumeCallback(_volumeLevel);
            }
        }
    #endregion
    }

    public class LoadedGrammar
    {
        public HotGrammar HotGrammar { get; set; }
        public dynamic Callback { get; set; }
    }

}

