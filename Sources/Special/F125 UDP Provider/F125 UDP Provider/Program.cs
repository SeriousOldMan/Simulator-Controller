using System;
using System.Globalization;
using System.Threading;

namespace F125UDPProvider
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            string host = (args.Length > 0) ? args[0] : "127.0.0.1";
            int port = (args.Length > 1) ? int.Parse(args[1]) : 20777;
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
            F125UDPConnector.F125UDPConnector connector = new F125UDPConnector.F125UDPConnector();

            if (!connector.Open(host, port, useMultiCast))
            {
                Console.WriteLine("[Session Data]");
                Console.WriteLine("Active=false");
                return;
            }

            try
            {
                for (int i = 0; i < 15; i++)
                    if (connector.HasData())
                        break;
                    else
                        Thread.Sleep(100);

                Console.Write(connector.Call(request));
            }
            finally
            {
                connector.Close();
            }
        }
    }
}
