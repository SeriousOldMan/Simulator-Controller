/*
RF2 SHM Coach entry point.

Based partly upon the work of: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using RF2SHMCoach.rFactor2Data;
using static RF2SHMCoach.rFactor2Constants;

namespace RF2SHMCoach {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            SHMCoach coach = new SHMCoach();

            if (args.Length > 0 && args[0] == "-Automation")
            {
                coach.initializeTrigger("Automation", args);

                coach.Run(false, true, false);
            }
            else if (args.Length > 0 && args[0] == "-Trigger")
            {
                coach.initializeTrigger("Trigger", args);

                coach.Run(false, true, false);
            }
            else if (args.Length > 0 && args[0] == "-Calibrate")
            {
                coach.initializeAnalyzer(true, args);

                coach.Run(false, false, true);
            }
            else if (args.Length > 0 && args[0] == "-Analyze")
            {
                coach.initializeAnalyzer(false, args);

                coach.Run(false, false, true);
            }
            else if (args.Length > 0 && args[0] == "-Map")
                new SHMCoach().Run(true, false, false);
            else if (args.Length > 0 && args[0] == "-Telemetry")
                new SHMCoach().Run(false, false, false, args[2]);
            else
            {
                coach.initializeCoach(args);

                coach.Run(false, false, false);
            }
        }
    }
}
