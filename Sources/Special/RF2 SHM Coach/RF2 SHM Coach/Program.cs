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

            if (args.Length > 0 && args[0] == "-Trigger")
            {
                coach.initializeTrigger("Trigger", args);

                coach.Run(true, false, false);
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
            else if (args.Length > 0 && args[0] == "-BrakeHints")
            {
                coach.initializeBrakeHints("BrakeHints", args);

                coach.Run(false, true, false);
            }
        }
    }
}
