﻿/*
RF2 SHM Spotter entry point.

Based partly upon the work of: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using RF2SHMSpotter.rFactor2Data;
using static RF2SHMSpotter.rFactor2Constants;

namespace RF2SHMSpotter {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            SHMSpotter spotter = new SHMSpotter();

            if (args.Length > 0 && args[0] == "-Automation")
            {
                spotter.initializeTrigger("Automation", args);

                spotter.Run(false, true, false);
            }
            else if (args.Length > 0 && args[0] == "-Trigger")
            {
                spotter.initializeTrigger("Trigger", args);

                spotter.Run(false, true, false);
            }
            else if (args.Length > 0 && args[0] == "-Calibrate")
            {
                spotter.initializeAnalyzer(true, args);

                spotter.Run(false, false, true);
            }
            else if (args.Length > 0 && args[0] == "-Analyze")
            {
                spotter.initializeAnalyzer(false, args);

                spotter.Run(false, false, true);
            }
            else if (args.Length > 0 && args[0] == "-Map")
                new SHMSpotter().Run(true, false, false);
            else if (args.Length > 0 && args[0] == "-Telemetry")
                new SHMSpotter().Run(false, false, false, args[2]);
            else
            {
                spotter.initializeSpotter(args);

                spotter.Run(false, false, false);
            }
        }
    }
}
