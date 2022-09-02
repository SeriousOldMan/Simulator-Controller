using System;
using System.Globalization;
using System.Threading;

namespace ACSHMProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            SHMProvider provider = new SHMProvider();

            if (args.Length > 0 && args[0] == "-Setup")
                provider.ReadSetup();
            else if (args.Length > 0 && args[0] == "-Standings")
                provider.ReadStandings();
            else
            {
                provider.ReadData();
                provider.ReadStandings();
            }

            provider.Close();
        }
    }
}
