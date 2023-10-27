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

        private string _model;
        private string _language;
        private dynamic _callback;

        public GoogleSpeechRecognizer()
        {
        }

        public bool Connect(string mode, string credentials, dynamic callback)
        {
            this._engineType = "Google";
            this._credentials = credentials;
            this._callback = callback;

            return true;
        }

        public void SetEngine(string engine)
        {
            _engineType = engine;
        }

        public string GetModel()
        {
            return _model;
        }

        public void SetModel(string model)
        {
            _model = model;
        }

        public string GetLanguage()
        {
            return _language;
        }

        public void SetLanguage(string language)
        {
            _language = language.ToLower();
        }

        public string OkCheck()
        {
            return "Ok";
        }

        public int GetRecognizerCount()
        {
            return 1;
        }

        public void SetContinuous(dynamic callback)
        {
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
        private bool recording = false;

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

            waveSource = new WaveIn();
            waveSource.WaveFormat = new WaveFormat(44100, 1);

            waveSource.DataAvailable += new EventHandler<WaveInEventArgs>(waveSource_DataAvailable);
            
            waveFile = new WaveFileWriter(fileName, waveSource.WaveFormat);

            recording = true;

            waveSource.StartRecording();
        }

        private void StopRecording()
        {
            if ((waveSource != null) && recording)
            {
                waveSource.StopRecording();

                waveSource.Dispose();

                waveFile.Flush();

                waveFile.Close();

                waveFile.Dispose();
            }

            recording = false;
            waveSource = null;
            waveFile = null;
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

                input.Position = 0;
                input.SetLength(0);
                    
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