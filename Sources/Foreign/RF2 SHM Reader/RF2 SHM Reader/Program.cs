/*
RF2 SHM Reader entry point.

Based on the work of: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using RF2SHMReader.rFactor2Data;
using static RF2SHMReader.rFactor2Constants;

namespace RF2SHMReader {
    static class Program {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main() {   
            SHMReader reader = new SHMReader();

            reader.Run();
        }
    }
}
