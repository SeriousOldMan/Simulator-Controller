/*
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

            new SHMSpotter().Run(args.Length > 0 && args[0] == "-Map");
        }
    }
}
