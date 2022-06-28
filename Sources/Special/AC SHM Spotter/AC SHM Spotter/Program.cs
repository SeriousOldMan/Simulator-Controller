using System;
using System.Globalization;
using System.Threading;

namespace ACSHMSpotter {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            new SHMSpotter().Run();
        }
    }
}
