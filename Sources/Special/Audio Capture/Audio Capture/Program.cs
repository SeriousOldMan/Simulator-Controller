using NAudio.Wave;
using System.IO;
using System.Threading;

namespace Audio
{
    internal class Program
    {
        static WaveInEvent waveIn = null;
        static WaveFileWriter writer = null;

        static void Main(string[] args)
        {
            bool done = false;
            string ctrlFile = args[0];

            StartRecognizer(args[1]);

            while (!done)
                if (!File.Exists(ctrlFile))
                    Thread.Sleep(100);
                else
                {
                    File.Delete(ctrlFile);

                    StopRecognizer();

                    done = true;
                }
        }

        static void StartRecognizer(string fileName)
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
        }

        static void StopRecognizer()
        {
            if (writer != null)
            {
                waveIn.StopRecording();

                writer?.Dispose();
                writer = null;

                waveIn?.Dispose();
                waveIn = null;
            }
        }
    }
}
