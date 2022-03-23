using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

// Get Started with Speech Recognition (Microsoft.Speech):
// https://msdn.microsoft.com/en-us/library/hh378426(v=office.14).aspx

// Namespace Reference
// https://msdn.microsoft.com/en-us/library/microsoft.speech.recognition(v=office.14).aspx

// Install stuff from here:
// https://msdn.microsoft.com/en-us/library/hh362873(v=office.14).aspx#Anchor_2

// Plus a recognizer:
// https://www.microsoft.com/en-us/download/details.aspx?id=27224

namespace Speech
{
    public class SpeechRecognizer
    {
        private string _engineType = "Unknown";
        private ServerSpeechRecognizer _serverRecognizer;
        private DesktopSpeechRecognizer _desktopRecognizer;

        public void SetEngine(string engine)
        {
            _engineType = engine;

            if (engine == "Server")
                _serverRecognizer = new ServerSpeechRecognizer();
            else if (engine == "Desktop")
                _desktopRecognizer = new DesktopSpeechRecognizer();
        }

        /// <summary>
        /// Checks that you can speak to this Library
        /// </summary>
        /// <returns>OK</returns>
        public string OkCheck()
        {
            if (_engineType == "Server" || _engineType == "Desktop")
                return "OK";
            else
                return "Error";
        }

        public int GetRecognizerCount()
        {
            return (_engineType == "Server") ? _serverRecognizer._recognizers.Count : _desktopRecognizer._recognizers.Count;
        }

        public string GetRecognizerName(int recognizerId)
        {
            return (_engineType == "Server") ? _serverRecognizer.GetRecognizerName(recognizerId) : _desktopRecognizer.GetRecognizerName(recognizerId);
        }

        public string GetRecognizerCultureName(int recognizerId)
        {
            return (_engineType == "Server") ? _serverRecognizer.GetRecognizerCultureName(recognizerId) : _desktopRecognizer.GetRecognizerCultureName(recognizerId);
        }

        public string GetRecognizerTwoLetterISOLanguageName(int recognizerId)
        {
            return (_engineType == "Server") ? _serverRecognizer.GetRecognizerTwoLetterISOLanguageName(recognizerId) : _desktopRecognizer.GetRecognizerTwoLetterISOLanguageName(recognizerId);
        }

        public string GetRecognizerLanguageDisplayName(int recognizerId)
        {
            return (_engineType == "Server") ? _serverRecognizer.GetRecognizerLanguageDisplayName(recognizerId) : _desktopRecognizer.GetRecognizerLanguageDisplayName(recognizerId);
        }

        public void Initialize(int recognizerId = 0)
        {
            if (_engineType == "Server")
                _serverRecognizer.Initialize(recognizerId);
            else
                _desktopRecognizer.Initialize(recognizerId);
        }

        public bool StartRecognizer()
        {
            return (_engineType == "Server") ? _serverRecognizer.StartRecognizer() : _desktopRecognizer.StartRecognizer();
        }

        public bool StopRecognizer()
        {
            return (_engineType == "Server") ? _serverRecognizer.StopRecognizer() : _desktopRecognizer.StopRecognizer();
        }

        public Microsoft.Speech.Recognition.Choices GetServerChoices(string name)
        {
            return _serverRecognizer.GetChoices(name);
        }

        public System.Speech.Recognition.Choices GetDesktopChoices(string name)
        {
            return _desktopRecognizer.GetChoices(name);
        }

        public ServerGrammar NewServerGrammar()
        {
            return _serverRecognizer.NewGrammar();
        }

        public DesktopGrammar NewDesktopGrammar()
        {
            return _desktopRecognizer.NewGrammar();
        }

        public Microsoft.Speech.Recognition.Choices NewServerChoices(string choiceListStr)
        {
            return _serverRecognizer.NewChoices(choiceListStr);
        }

        public System.Speech.Recognition.Choices NewDesktopChoices(string choiceListStr)
        {
            return _desktopRecognizer.NewChoices(choiceListStr);
        }

        public string LoadGrammar(object grammar, string name, dynamic callback)
        {
            if (_engineType == "Server")
                return _serverRecognizer.LoadGrammar((ServerGrammar)grammar, name, callback);
            else
                return _desktopRecognizer.LoadGrammar((DesktopGrammar)grammar, name, callback);
        }

        public bool SubscribeVolume(dynamic callback)
        {
            if (_engineType == "Server")
                return _serverRecognizer.SubscribeVolume(callback);
            else
                return _desktopRecognizer.SubscribeVolume(callback);
        }
    }

    public partial class ServerSpeechRecognizer
    {
        private Microsoft.Speech.Recognition.SpeechRecognitionEngine _recognizer;
        private dynamic _volumeCallback;
        private int _volumeLevel = 0;
        private bool _recognizerRunning;
        internal readonly List<Microsoft.Speech.Recognition.RecognizerInfo> _recognizers;
        private readonly  Dictionary<string, Microsoft.Speech.Recognition.Choices> _choicesDictionary =
            new Dictionary<string, Microsoft.Speech.Recognition.Choices>(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, LoadedGrammar> _loadedGrammarDictionary = new Dictionary<string, LoadedGrammar>(StringComparer.OrdinalIgnoreCase);

        #region Startup
        public ServerSpeechRecognizer()
        {
            _recognizers = Microsoft.Speech.Recognition.SpeechRecognitionEngine.InstalledRecognizers().ToList();

            var percentileChoices = new Microsoft.Speech.Recognition.Choices();

            for (var i = 0; i <= 100; i++)
                percentileChoices.Add(i.ToString());

            _choicesDictionary.Add("Percent", percentileChoices);
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

            _recognizer = new Microsoft.Speech.Recognition.SpeechRecognitionEngine(_recognizers[recognizerId].Culture);

            // Add a handler for the speech recognized event.
            _recognizer.SpeechRecognized += Recognizer_SpeechRecognized;

            // Configure the input to the speech recognizer.
            _recognizer.SetInputToDefaultAudioDevice();
        }

        /// <summary>
        /// Loads a Grammar object into the recognizer
        /// </summary>
        /// <param name="grammar"></param>
        /// <param name="name">The name to give the Grammar</param>
        /// <param name="callback">The code to fire when the Grammar is spoken</param>
        /// <returns></returns>
        public string LoadGrammar(ServerGrammar grammar, string name, dynamic callback)
        {
            _loadedGrammarDictionary.Add(name, new LoadedGrammar { Grammar = grammar, Callback = callback });
            var g = new Microsoft.Speech.Recognition.Grammar(grammar.GrammarBuilder) { Name = name };
            _recognizer.LoadGrammar(g);
            return grammar.GetPhrases();
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
                    _recognizer.RecognizeAsync(Microsoft.Speech.Recognition.RecognizeMode.Multiple);
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
        public ServerGrammar GetLoadedGrammar(string name)
        {
            return (ServerGrammar)_loadedGrammarDictionary[name].Grammar;
        }

        public Microsoft.Speech.Recognition.Choices GetChoices(string name)
        {
            if (!_choicesDictionary.ContainsKey(name))
            {
                throw new Exception($"Could not find Choice Var {name}");
            }

            return _choicesDictionary[name];
        }

        public void SetChoices(string name, Microsoft.Speech.Recognition.Choices choices)
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

        public string GetRecognizerCultureName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Culture.Name;
        }

        public string GetRecognizerLanguageDisplayName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Culture.DisplayName;
        }

        public List<Microsoft.Speech.Recognition.RecognizerInfo> GetRecognizerInfos()
        {
            return _recognizers;
        }

        #endregion

        #region Event Handling
        // Handle the SpeechRecognized event.
        private void Recognizer_SpeechRecognized(object sender, Microsoft.Speech.Recognition.SpeechRecognizedEventArgs e)
        {
            var name = e.Result.Grammar.Name;
            var words = new string[e.Result.Words.Count];
            for (var i = 0; i < e.Result.Words.Count; i++)
            {
                words[i] = e.Result.Words[i].Text;
            }

            try
            {
                _loadedGrammarDictionary[name].Callback(name, words);
                //_loadedGrammarDictionary[name](name, words);
            }
            catch
            {
                // ignore for now
            }
        }

        // Write the audio level to the console when the AudioLevelUpdated event is raised.
        private void Recognizer_AudioLevelUpdated(object sender, Microsoft.Speech.Recognition.AudioLevelUpdatedEventArgs e)
        {
            if (e.AudioLevel != _volumeLevel)
            {
                _volumeLevel = e.AudioLevel;
                _volumeCallback(_volumeLevel);
            }
        }
    #endregion
    }

    public partial class DesktopSpeechRecognizer
    {
        private System.Speech.Recognition.SpeechRecognitionEngine _recognizer;
        private dynamic _volumeCallback;
        private int _volumeLevel = 0;
        private bool _recognizerRunning;
        internal readonly List<System.Speech.Recognition.RecognizerInfo> _recognizers;
        private readonly Dictionary<string, System.Speech.Recognition.Choices> _choicesDictionary =
            new Dictionary<string, System.Speech.Recognition.Choices>(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, LoadedGrammar> _loadedGrammarDictionary = new Dictionary<string, LoadedGrammar>(StringComparer.OrdinalIgnoreCase);

        #region Startup
        public DesktopSpeechRecognizer()
        {
            _recognizers = System.Speech.Recognition.SpeechRecognitionEngine.InstalledRecognizers().ToList();

            var percentileChoices = new System.Speech.Recognition.Choices();

            for (var i = 0; i <= 100; i++)
                percentileChoices.Add(i.ToString());

            _choicesDictionary.Add("Percent", percentileChoices);
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

            _recognizer = new System.Speech.Recognition.SpeechRecognitionEngine(_recognizers[recognizerId].Culture);

            // Add a handler for the speech recognized event.
            _recognizer.SpeechRecognized += Recognizer_SpeechRecognized;

            // Configure the input to the speech recognizer.
            _recognizer.SetInputToDefaultAudioDevice();
        }

        /// <summary>
        /// Loads a Grammar object into the recognizer
        /// </summary>
        /// <param name="grammar"></param>
        /// <param name="name">The name to give the Grammar</param>
        /// <param name="callback">The code to fire when the Grammar is spoken</param>
        /// <returns></returns>
        public string LoadGrammar(DesktopGrammar grammar, string name, dynamic callback)
        {
            _loadedGrammarDictionary.Add(name, new LoadedGrammar { Grammar = grammar, Callback = callback });
            var g = new System.Speech.Recognition.Grammar(grammar.GrammarBuilder) { Name = name };
            _recognizer.LoadGrammar(g);
            return grammar.GetPhrases();
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
                    _recognizer.RecognizeAsync(System.Speech.Recognition.RecognizeMode.Multiple);
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
        public DesktopGrammar GetLoadedGrammar(string name)
        {
            return (DesktopGrammar)_loadedGrammarDictionary[name].Grammar;
        }

        public System.Speech.Recognition.Choices GetChoices(string name)
        {
            if (!_choicesDictionary.ContainsKey(name))
            {
                throw new Exception($"Could not find Choice Var {name}");
            }

            return _choicesDictionary[name];
        }

        public void SetChoices(string name, System.Speech.Recognition.Choices choices)
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

        public string GetRecognizerCultureName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Culture.Name;
        }

        public string GetRecognizerLanguageDisplayName(int recognizerId)
        {
            AssertRecognizerExists(recognizerId);
            return _recognizers[recognizerId].Culture.DisplayName;
        }

        public List<System.Speech.Recognition.RecognizerInfo> GetRecognizerInfos()
        {
            return _recognizers;
        }

        #endregion

        #region Event Handling
        // Handle the SpeechRecognized event.
        private void Recognizer_SpeechRecognized(object sender, System.Speech.Recognition.SpeechRecognizedEventArgs e)
        {
            var name = e.Result.Grammar.Name;
            var words = new string[e.Result.Words.Count];
            for (var i = 0; i < e.Result.Words.Count; i++)
            {
                words[i] = e.Result.Words[i].Text;
            }

            try
            {
                _loadedGrammarDictionary[name].Callback(name, words);
                //_loadedGrammarDictionary[name](name, words);
            }
            catch
            {
                // ignore for now
            }
        }

        // Write the audio level to the console when the AudioLevelUpdated event is raised.
        private void Recognizer_AudioLevelUpdated(object sender, System.Speech.Recognition.AudioLevelUpdatedEventArgs e)
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
        public object Grammar { get; set; }
        public dynamic Callback { get; set; }
    }

}

