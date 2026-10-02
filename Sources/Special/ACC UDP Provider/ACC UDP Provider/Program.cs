using System;
using System.Globalization;
using System.Threading;

namespace ACCUDPProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

			if (args[0] == "-Persistent") {
				UDPProvider provider = new UDPProvider(args[1], args[2]);
				
				String ip = "127.0.0.1";
				int port = 9000;
				String login = "asd";
				String pwd = "";
				
				if ((args.Length > 3) && (args[3] == "-Connect")) {
					string[] arguments = args[4].Split(',');

					ip = arguments[0];
					port = (int)Double.Parse(arguments[1]);
					login = arguments[2];
					pwd = arguments[3];
				}
				
				provider.ReadStandings(ip, port, "", login, pwd);
			}
			else if (args[0] == "-Collect") {
				UDPProvider provider = new UDPProvider(args[1]);
				
				String ip = "127.0.0.1";
				int port = 9000;
				String login = "asd";
				String pwd = "";
				int index = 2;
				
				if ((args.Length > 2) && (args[2] == "-Connect")) {
					string[] arguments = args[3].Split(',');

					ip = arguments[0];
					port = (int)Double.Parse(arguments[1]);
					login = arguments[2];
					pwd = arguments[3];
				}
				
				provider.ReadStandings(ip, port, "", login, pwd);
			}
        }
    }
}
