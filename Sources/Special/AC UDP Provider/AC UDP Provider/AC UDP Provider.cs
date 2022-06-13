using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;

namespace ACUDPProvider
{
    
    public class LapData
    {
        public int LaptimeMS { get; private set; } = 0;
        
        internal void Update(LapInfo lapUpdate)
        {
            LaptimeMS = (int)lapUpdate.lapTime.TotalMilliseconds;
        }
    }

    public class CarData
    {
        public string CarIndex { get; }
        public string CarModel { get; private set; }
        public string RaceNumber { get; private set; }
        public string DriverFirstName { get; private set; }
        public string DriverLastName { get; private set; }
        public string DriverNickName { get; private set; }
        public int Position { get; private set ; }
        public float SplinePosition { get; private set; }
        public int Laps { get; private set; }
        public int BestLap { get; private set; }
        public int LastLap { get; private set; }
        public int CurrentLap { get; private set; }

        public CarData(string carIndex)
        {
            CarIndex = carIndex;
        }

        internal void Update(LapInfo lapUpdate)
        {
            DriverFirstName = GetForname(lapUpdate.driverName);
            DriverLastName = GetSurname(lapUpdate.driverName);
            DriverNickName = GetNickname(lapUpdate.driverName);

            CarModel = lapUpdate.carName;

            Laps = lapUpdate.lapNumber;

            LastLap = (int)lapUpdate.lapTime.TotalMilliseconds;

            if (LastLap > 0)
                if (BestLap > 0)
                    BestLap = Math.Min(LastLap, BestLap);
                else
                    BestLap = LastLap;
        }

        internal void Update(CarInfo carUpdate)
        {
            RaceNumber = carUpdate.identifier;

            CurrentLap = (int)carUpdate.currentLapTime.TotalMilliseconds;

            Position = carUpdate.position;
            SplinePosition = carUpdate.splinePosition;
        }

        public string GetForname(string name)
        {
            if (name.Contains(" "))
            {
                string[] names = name.Split(' ');

                return names[0];
            }
            else
                return name;
        }

        public string GetSurname(string name)
        {
            if (name.Contains(" "))
            {
                string[] names = name.Split(' ');

                return names[1];
            }
            else
                return "";
        }

        public string GetNickname(string name)
        {
            if (name.Contains(" "))
            {
                string[] names = name.Split(' ');

                return names[0].Substring(0, 1) + names[1].Substring(0, 1);
            }
            else
                return "";
        }
    }

    public class UDPProvider {
		public ObservableCollection<CarData> Cars { get; set; } = new ObservableCollection<CarData>();

        private string cmdFileName;
        private string outFileName;

        public UDPProvider(string cmdFileName, string outFileName) {
            this.cmdFileName = cmdFileName;
            this.outFileName = outFileName;
        }
		
		public void Reset() {
			Cars = new ObservableCollection<CarData>();
		}

		public void ReadStandings(string ip, int port) {
			/*
            TextWriterTraceListener listener = new TextWriterTraceListener(this.outFileName + ".Trace");
            Debug.Listeners.Add(listener);
			*/

            Debug.WriteLine("Starting UDP Client...");

			bool done = false;
			bool firstRun = true;
        
			while (!done) {
                AcUdpConnection lapClient = new AcUdpConnection(ip, port, AcUdpConnection.ConnectionType.LapTime);
                // AcUdpConnection carClient = new AcUdpConnection(ip, port, AcUdpConnection.ConnectionType.CarInfo);

                try
                {
                    lapClient.Connect();
                    // carClient.Connect();

                    lapClient.LapUpdate += UpdateLap;
                    // carClient.CarUpdate += UpdateCar;
                }
                catch {
                }

                if (firstRun) {
					firstRun = false;
					
					int retries = 3;

					while (retries > 0) {
                        int count = Cars.Count;

						Thread.Sleep(500);

						if (Cars.Count == count)
							retries -= 1;
						else
							retries = 1;
					}
				}

				int requests = 0;
				
				while (!done && (requests < 5)) {
					try {
						Debug.Flush();
						// listener.Flush();

						if (File.Exists(cmdFileName)) {
							// requests += 1;
							
							StreamReader cmdStream = new StreamReader(cmdFileName);

							string command = cmdStream.ReadLine();

							if (command == "Exit")
								done = true;
							else if (true || command == "Read") {
								StreamWriter outStream = new StreamWriter(outFileName, false, Encoding.Unicode);

								outStream.WriteLine("[Position Data]");

								outStream.Write("Car.Count="); outStream.WriteLine(Cars.Count);

								int index = 1;

								foreach (CarData car in Cars) {
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Nr="); outStream.WriteLine(car.RaceNumber);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Position="); outStream.WriteLine(car.Position);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Lap="); outStream.WriteLine(car.Laps);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Lap.Running="); outStream.WriteLine(car.SplinePosition);

									outStream.Write("Car."); outStream.Write(index); outStream.WriteLine(".Lap.Valid=true");

									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Time=");
									outStream.WriteLine(car.LastLap);

									outStream.Write("Car."); outStream.Write(index);
									if (car.LastLap != 0) {
										string split1MS = "";
										string split2MS = "";
										string split3MS = "";

										if (split1MS.Length == 0)
											split1MS = "0";

										if (split2MS.Length == 0)
											split2MS = "0";

										if (split3MS.Length == 0)
											split3MS = "0";

										outStream.Write(".Time.Sectors="); outStream.WriteLine(split1MS + "," + split2MS + "," + split3MS);
									}
									else
										outStream.WriteLine(".Time.Sectors=0,0,0");
									
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Car="); outStream.WriteLine(car.CarModel);

									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Driver.Forname="); outStream.WriteLine(car.DriverFirstName);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Driver.Surname="); outStream.WriteLine(car.DriverLastName);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Driver.Nickname="); outStream.WriteLine(car.DriverNickName);
									
									index += 1;
								}

								outStream.Close();
							}

							cmdStream.Close();

							File.Delete(cmdFileName);
						}
						else
							Thread.Sleep(100);
					}
					catch (Exception ex) {
						Debug.WriteLine(ex.Message);
					}
				}

                lapClient.Disconnect();
                // carClient.Disconnect();
            }
        }

        private void UpdateLap(object sender, AcUdpConnection.AcUpdateEventArgs e)
        {
            LapInfo lapInfo = e.lapInfo;
            string identifier = lapInfo.carIdentifier.ToString();

            try
            {
                CarData car = Cars.SingleOrDefault(x => x.CarIndex == identifier);

                if (car == null)
                {
                    car = new CarData(identifier);

                    Cars.Add(car);
                }

                car.Update(lapInfo);
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }
        }

        private void UpdateCar(object sender, AcUdpConnection.AcUpdateEventArgs e)
        {
            CarInfo carInfo = e.carInfo;

            try
            {
                CarData car = Cars.SingleOrDefault(x => x.CarIndex == carInfo.identifier);

                if (car == null)
                {
                    car = new CarData(carInfo.identifier);

                    Cars.Add(car);
                }

                car.Update(carInfo);
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }
        }
    }
}
