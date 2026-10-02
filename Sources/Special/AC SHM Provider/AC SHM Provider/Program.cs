using System;
using System.Globalization;
using System.Threading;

namespace ACSHMProvider {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            if (args.Length > 0 && args[0].Equals("test", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("[Position Data]");
                Console.WriteLine("Car.Count=1");
                Console.WriteLine("Car.1.ID=1");
                Console.WriteLine("Car.1.Nr=1");
                Console.WriteLine("Car.1.Position=1");
                Console.WriteLine("Car.1.Laps=3");
                Console.WriteLine("Car.1.Lap.Running=0.45");
                Console.WriteLine("Car.1.Lap.Running.Valid=true");
                Console.WriteLine("Car.1.Time=89234");
                Console.WriteLine("Car.1.Time.Sectors=28120,30450,30664");
                Console.WriteLine("Car.1.Car=bmw_m3_e30");
                Console.WriteLine("Car.1.Driver.Forname=Test");
                Console.WriteLine("Car.1.Driver.Surname=Driver");
                Console.WriteLine("Car.1.Driver.Nickname=TD");
                Console.WriteLine("Car.1.InPitLane=false");
                Console.WriteLine("Car.1.InPit=false");
                Console.WriteLine("Driver.Car=1");
                return;
            }

            SHMProvider provider = new SHMProvider();

            if (args.Length > 0 && args[0].StartsWith("Setup"))
                provider.ReadSetup();
            else if (args.Length > 0 && args[0].StartsWith("Standings"))
                provider.ReadStandings();
            else
            {
                provider.ReadData();
                provider.ReadSetup();
            }

            provider.Close();
        }
    }
}
