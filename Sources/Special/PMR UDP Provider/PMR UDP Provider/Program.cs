using System;
using System.Globalization;
using System.Threading;
using PMR_UDP_Connector;

namespace PMR_UDP_Provider
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");
            
            string request = args.Length > 0 ? args[0] : "";
            PMRUDPConnector connector = new PMRUDPConnector();
            
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
