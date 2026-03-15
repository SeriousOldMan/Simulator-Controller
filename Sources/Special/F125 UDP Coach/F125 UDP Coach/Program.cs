using System;
using System.Globalization;
using System.Threading;
using System.Windows.Forms;

namespace F125UDPCoach {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            string host = args[0];
            int port = int.Parse(args[1]);
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

            UDPCoach coach = new UDPCoach(host, port, useMultiCast);

            if (args.Length > 3 && args[3] == "-Trigger")
            {
                coach.initializeTrigger("Trigger", args, 4);

                coach.Run(true, false, false);
            }
            else if (args.Length > 3 && args[3] == "-Calibrate")
            {
                coach.initializeAnalyzer(true, args, 4);

                coach.Run(false, false, true);
            }
            else if (args.Length > 3 && args[3] == "-Analyze")
            {
                coach.initializeAnalyzer(false, args, 4);

                coach.Run(false, false, true);
            }
            else if (args.Length > 3 && args[3] == "-TrackHints")
            {
                coach.initializeTrackHints("TrackHints", args, 4);

                coach.Run(false, true, false);
            }
        }
    }
}
