using System;
using System.Globalization;
using System.Threading;

namespace PMR_UDP_Provider
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");
            
            string request = args.Length > 0 ? args[0] : "";
            SHMConnector.SHMConnector connector = new SHMConnector.SHMConnector();
            
            if (!connector.Open())
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
