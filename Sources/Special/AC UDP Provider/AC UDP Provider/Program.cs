using System;
using System.Globalization;
using System.Threading;

namespace ACUDPProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            // UDPProvider provider = new UDPProvider(args[0], args[1]);

            UDPProvider provider = new UDPProvider("D:\\Dateien\\Dokumente\\Simulator Controller\\Temp\\ACUDP.cmd",
                                                   "D:\\Dateien\\Dokumente\\Simulator Controller\\Temp\\ACUDP.out");

            String ip = "127.0.0.1";
			int port = 9996;

            if ((args.Length > 2) && (args[2] == "-Connect")) {
                string[] arguments = args[3].Split(',');

                ip = arguments[0];
                port = (int)Double.Parse(arguments[1]);
            }
			
            provider.ReadStandings(ip, port);
        }
    }
}
