using NAudio.Wave;

namespace Audio
{
    public class AudioCapture
    {
        WaveInEvent waveIn = null;
        WaveFileWriter writer = null;

        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        public AudioCapture()
        {
        }

        public string OkCheck()
        {
            return "Ok";
        }

        public bool StartRecognizer(string fileName)
        {
            if (writer != null)
                StopRecognizer();

            waveIn = new WaveInEvent();

            writer = new WaveFileWriter(fileName, waveIn.WaveFormat);

            waveIn.DataAvailable += (s, a) =>
            {
                writer.Write(a.Buffer, 0, a.BytesRecorded);
            };

            waveIn.StartRecording();

            return true;
        }

        public bool StopRecognizer()
        {
            if (writer != null)
            {
                waveIn.StopRecording();

                writer?.Dispose();
                writer = null;

                waveIn?.Dispose();
                waveIn = null;

                return true;
            }
            else
                return false;
        }
    }
}