using System;
using System.Globalization;
using System.Threading;

namespace ACSHMSpotter {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");


            SHMSpotter spotter = new SHMSpotter();

            if (args.Length > 0 && args[0] == "-Trigger")
            {
                spotter.initializeTrigger(args);

                spotter.Run(false, true, false);
            }
            else if (args.Length > 0 && args[0] == "-Analyze")
            {
                spotter.initializeAnalyzer(args);

                spotter.Run(false, false, true);
            }
            else
                new SHMSpotter().Run(args.Length > 0 && args[0] == "-Map", false, false);
        }
    }
}
