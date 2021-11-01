using System;
using System.IO;
using System.IO.Pipes;
using System.Security.Principal;
using System.Text;

namespace StreamDeckMessage {
    public class StreamString {
        private Stream ioStream;
        private UnicodeEncoding streamEncoding;

        public StreamString(Stream ioStream) {
            this.ioStream = ioStream;

            streamEncoding = new UnicodeEncoding();
        }

        public string ReadString() {
            int len = 0;

            len = ioStream.ReadByte() * 256;
            len += ioStream.ReadByte();

            byte[] inBuffer = new byte[len];

            ioStream.Read(inBuffer, 0, len);

            return streamEncoding.GetString(inBuffer);
        }

        public int WriteString(string outString) {
            byte[] outBuffer = streamEncoding.GetBytes(outString);

            int len = outBuffer.Length;

            if (len > UInt16.MaxValue) {
                len = (int)UInt16.MaxValue;
            }

            ioStream.WriteByte((byte)(len / 256));
            ioStream.WriteByte((byte)(len & 255));
            ioStream.Write(outBuffer, 0, len);
            ioStream.Flush();

            return outBuffer.Length + 2;
        }
    }

    class Program {
        static void Main(string[] args) {
            var pipeClient = new NamedPipeClientStream(".", "SCFunctionOperation", PipeDirection.InOut, PipeOptions.None,
                                                       TokenImpersonationLevel.Impersonation);

            Console.WriteLine("Connecting to server...\n");
            
            pipeClient.Connect();

            var ss = new StreamString(pipeClient);
            
            ss.WriteString("Button.11:Text:Hello there...");

            pipeClient.Close();
        }
    }
}
