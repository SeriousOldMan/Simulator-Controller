using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace Speech
{
    public class GoogleSpeechRecognizer
    {
        private string _engineType = "Unknown";

        private string _credentials;

        private string _language;
        private dynamic _callback;

        public GoogleSpeechRecognizer()
        {
        }

        public bool Connect(string mode, string credentials, string language, dynamic callback)
        {
            this._engineType = "Google";
            this._credentials = credentials;
            this._language = language.ToLower();
            this._callback = callback;

            return true;
        }

        public void SetEngine(string engine)
        {
            _engineType = engine;
        }

        public string GetLanguage()
        {
            return _language;
        }

        public void SetLanguage(string language)
        {
            _language = language;
        }

        public string OkCheck()
        {
            return "Ok";
        }

        public int GetRecognizerCount()
        {
            return 1;
        }

        public string GetRecognizerName(int recognizerId)
        {
            return "Neural speech to text engine";
        }

        public string GetRecognizerCultureName(int recognizerId)
        {
            return GetLanguage() + "_XX";
        }

        public string GetRecognizerTwoLetterISOLanguageName(int recognizerId)
        {
            return GetLanguage();
        }

        public string GetRecognizerLanguageDisplayName(int recognizerId)
        {
            return "Universal (" + GetLanguage() + ")";
        }

        private WaveIn waveSource = null;
        private WaveFileWriter waveFile = null;

        private void StartRecording(string fileName)
        {
            void waveSource_DataAvailable(object sender, WaveInEventArgs e)
            {
                if (waveFile != null)
                {
                    waveFile.Write(e.Buffer, 0, e.BytesRecorded);
                    waveFile.Flush();
                }
            }

            void waveSource_RecordingStopped(object sender, StoppedEventArgs e)
            {
                if (waveSource != null)
                {
                    waveSource.Dispose();
                    waveSource = null;
                }

                if (waveFile != null)
                {
                    waveFile.Dispose();
                    waveFile = null;
                }
            }

            waveSource = new WaveIn();
            waveSource.WaveFormat = new WaveFormat(44100, 1);

            waveSource.DataAvailable += new EventHandler<WaveInEventArgs>(waveSource_DataAvailable);
            waveSource.RecordingStopped += new EventHandler<StoppedEventArgs>(waveSource_RecordingStopped);

            waveFile = new WaveFileWriter(fileName, waveSource.WaveFormat);

            waveSource.StartRecording();
        }

        private void StopRecording()
        {
            waveSource.StopRecording();
        }

        public bool StartRecognizer(string fileName)
        {
            bool stopped = StopRecognizer();

            if (stopped)
                StartRecording(fileName);

            return stopped;
        }

        public bool StopRecognizer()
        {
            StopRecording();

            return true;
        }

        public string ReadAudio(string audioFile)
        {
            using (var input = File.Open(audioFile, FileMode.Open))
            {
                byte[] bytes = new byte[input.Length];
                    
                input.Read(bytes, 0, bytes.Length);

                input.Close();

                return System.Convert.ToBase64String(bytes);
            }
        }

        public float Compare(string s1, string s2)
        {
            return (float)new Matcher(s1, s2).GetCoefficient();
        }
    }
}