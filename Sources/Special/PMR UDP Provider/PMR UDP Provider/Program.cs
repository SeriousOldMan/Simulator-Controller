using System;
using System.Globalization;
using System.Threading;

namespace PMRUDPProvider
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            string multiCastGroup = (args.Length > 0) ? args[0] : "224.0.0.150";
            int multiCastPort = (args.Length > 1) ? int.Parse(args[1]) : 7576;
            bool useMultiCast = true;
                
            if (args.Length > 2)
            {
                if (args[2].ToLower() == "true")
                    useMultiCast = true;
                else if (args[2].ToLower() == "false")
                    useMultiCast = false;
                else {
                    try
                    {
                        if (int.Parse(args[2]) == 0)
                            useMultiCast = false;
                    }
                    catch { }
                }
            }

            string request = args.Length > 3 ? args[3] : "";
            PMRUDPConnector.PMRUDPConnector connector = new PMRUDPConnector.PMRUDPConnector();
            
            if (!connector.Open(multiCastGroup, multiCastPort, useMultiCast))
            {
                Console.WriteLine("[Session Data]");
                Console.WriteLine("Active=false");
                return;
            }

            try
            {
                string output = connector.Call(request);
                Console.Write(output);
            }
            finally
            {
                connector.Close();
            }
        }
    }
}
