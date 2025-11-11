using System;
using System.Globalization;
using System.Threading;

namespace ACSHMCoach {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            SHMCoach coach = new SHMCoach();

            if (args.Length > 0 && args[0] == "-Trigger")
            {
                coach.initializeTrigger("Trigger", args);

                coach.Run(true, false);
            }
        }
    }
}
