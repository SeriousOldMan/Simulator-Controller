using NAudio.Wave;

namespace Speech
{
    public class AudioRecorder
    {
        WaveInEvent waveIn = null;
        WaveFileWriter writer = null;

        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        public AudioRecorder()
        {
        }

        public bool StartRecognizer(string fileName) {
            if (writer != null)
                StopRecognizer();

            waveIn = new WaveInEvent();

            waveIn.StartRecording();

            writer = new WaveFileWriter(fileName, waveIn.WaveFormat);

            waveIn.DataAvailable += (s, a) =>
            {
                writer.Write(a.Buffer, 0, a.BytesRecorded);

                /*
                if (writer.Position > waveIn.WaveFormat.AverageBytesPerSecond * 30)
                {
                    waveIn.StopRecording();
                }
                */
            };

            return true;
        }

        public bool StopRecognizer() {
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
