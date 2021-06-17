using System;
using System.Globalization;
using System.Threading;

namespace ACCUDPReader {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            UDPReader reader = new UDPReader();

            reader.ReadStandings("127.0.0.1", 9000, "", "asd", "");
        }
    }
}
