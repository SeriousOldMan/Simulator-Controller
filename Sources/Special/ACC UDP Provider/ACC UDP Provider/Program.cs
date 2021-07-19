using System;
using System.Globalization;
using System.Threading;

namespace ACCUDPProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            UDPProvider provider = new UDPProvider(args[0], args[1]);

            provider.ReadStandings("127.0.0.1", 9000, "", "asd", "");
        }
    }
}
