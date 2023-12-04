/*
RF2 SHM Provider entry point.

Based on the work of: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using RF2SHMProvider.rFactor2Data;
using static RF2SHMProvider.rFactor2Constants;

namespace RF2SHMProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");
            string request = args.Length > 0 ? args[0] : "";
            SHMProvider provider = new SHMProvider();

            if (request.StartsWith("Pitstop"))
            {
                request = request.Split(new char[] { '=' }, 2)[1];

                string[] arguments = request.Split('=');
                string[] message = arguments[1].Split(':');

                if (arguments[0] == "Set")
                    provider.ExecutePitstopSetCommand(message[0], message[1].Split(';'));
                else if ((arguments[0] == "Increase") || (arguments[0] == "Decrease"))
                    provider.ExecutePitstopChangeCommand(message[0], arguments[0], message[1].Split(';'));
            }
            else if (request.StartsWith("Setup"))
                provider.ReadSetup();
            else if (request.StartsWith("Standings"))
                provider.ReadStandings();
            else
            {
                provider.ReadData();
                provider.ReadSetup();
            }
            }
    }
}
