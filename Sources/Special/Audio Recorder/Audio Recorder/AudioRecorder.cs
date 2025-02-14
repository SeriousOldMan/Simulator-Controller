using NAudio.Wave;

namespace AudioRecorder
{
    public class AudioRecorder
    {
        WaveInEvent waveIn = null;
        WaveFileWriter writer = null;

        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        AudioRecorder()
        {
        }

        void StartRecording(string fileName) {
            if (writer != null)
                StopRecording();

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
        }

        void StopRecording() {
            if (writer != null)
            {
                waveIn.StopRecording();

                writer?.Dispose();
                writer = null;

                waveIn = null;
            }
        }
    }
}
