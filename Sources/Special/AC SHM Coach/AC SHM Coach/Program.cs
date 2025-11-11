using System;
using System.Globalization;
using System.Threading;

namespace ACSHMCoach {
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
            {
                if (args.Length > 1)
                    coach.initializeMapper(args[1]);

                coach.Run(true, false, false);
            }
            else if (args.Length > 0 && args[0] == "-Telemetry")
                coach.Run(false, false, false, args[2]);
            else
            {
                coach.initializeCoach(args);

                coach.Run(false, false, false);
            }
        }
    }
}
