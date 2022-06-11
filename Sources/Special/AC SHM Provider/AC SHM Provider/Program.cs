using System;
using System.Globalization;
using System.Threading;

namespace ACSHMProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            SHMProvider provider = new SHMProvider();

            /*
            if (args.Length > 0 && args[0] == "-Pitstop") {
                string[] arguments = args[1].Split(':');

                if (arguments[0] == "Set")
                    provider.ExecutePitstopSetCommand(arguments[1], arguments[2].Split(';'));
                else if ((arguments[0] == "Increase") || (arguments[0] == "Decrease"))
                    provider.ExecutePitstopChangeCommand(arguments[1], arguments[0], arguments[2].Split(';'));
            }
            else if (args.Length > 0 && args[0] == "-Setup")
                provider.ReadSetup();
            else if (args.Length > 0 && args[0] == "-Standings")
                provider.ReadStandings();
            else
            */
            provider.ReadData();

            provider.Close();
        }
    }
}
