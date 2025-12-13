/*
RF2 SHM Spotter entry point.

Based partly upon the work of: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;

namespace PMRUDPSpotter {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");
            
            string multiCastGroup = args[0];
            int multiCastPort = int.Parse(args[1]);
            bool useMultiCast = true;

            if (args[2].ToLower() == "true")
                useMultiCast = true;
            else if (args[2].ToLower() == "false")
                useMultiCast = false;
            else
            {
                try
                {
                    if (int.Parse(args[2]) == 0)
                        useMultiCast = false;
                }
                catch { }
            }

            UDPSpotter spotter = new UDPSpotter(multiCastGroup, multiCastPort, useMultiCast);

            if (args.Length > 3 && args[3] == "-Automation")
            {
                spotter.initializeTrigger("Automation", args, 4);

                spotter.Run(false, true);
            }
            else if (args.Length > 3 && args[3] == "-Map")
                spotter.Run(true, false);
            else if (args.Length > 3 && args[3] == "-Telemetry")
                spotter.Run(false, false, args[5]);
            else
            {
                spotter.initializeSpotter(args, 3);

                spotter.Run(false, false);
            }
        }
    }
}
