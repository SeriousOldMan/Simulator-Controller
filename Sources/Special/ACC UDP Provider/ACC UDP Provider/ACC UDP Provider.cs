using ksBroadcastingNetwork;
using ksBroadcastingNetwork.Structs;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;

namespace ACCUDPProvider {
    public class DriverData : KSObservableObject {
        public int DriverIndex { get; }
        public string FirstName { get => Get<string>(); private set => Set(value); }
        public string LastName { get => Get<string>(); private set => Set(value); }
        public string ShortName { get => Get<string>(); private set => Set(value); }
        public string DisplayName { get => Get<string>(); private set => Set(value); }
        public DriverCategory Category { get => Get<DriverCategory>(); private set => Set(value); }

        public DriverData(DriverInfo driverUpdate, int driverIndex) {
            DriverIndex = driverIndex;
            FirstName = driverUpdate.FirstName;
            LastName = driverUpdate.LastName;
            ShortName = driverUpdate.ShortName;
            Category = driverUpdate.Category;

            var displayName = $"{FirstName} {LastName}".Trim();
            if (displayName.Length > 35)
                displayName = $"{FirstName?.First()}. {LastName}".TrimStart('.').Trim();
            if (displayName.Length > 35)
                displayName = $"{LastName}".Trim();
            if (displayName.Length > 35)
                displayName = $"{LastName.Substring(0, 33)}...".Trim();

            if (string.IsNullOrEmpty(displayName))
                displayName = "NO NAME";

            DisplayName = displayName;
        }
    }

    public class LapData : KSObservableObject {
        public int? LaptimeMS { get => Get<int?>(); private set => Set(value); }
        public string LaptimeString { get => Get<string>(); private set => Set(value); }
        public int? Split1MS { get => Get<int?>(); private set => Set(value); }
        public string Split1String { get => Get<string>(); private set => Set(value); }
        public int? Split2MS { get => Get<int?>(); private set => Set(value); }
        public string Split2String { get => Get<string>(); private set => Set(value); }
        public int? Split3MS { get => Get<int?>(); private set => Set(value); }
        public string Split3String { get => Get<string>(); private set => Set(value); }

        public LapType Type { get => Get<LapType>(); private set => Set(value); }
        public bool IsValid { get => Get<bool>(); private set => Set(value); }
        public string LapHint { get => Get<string>(); private set => Set(value); }

        internal void Update(LapInfo lapUpdate) {
            var isChanged = LaptimeMS != lapUpdate.LaptimeMS;
            if (isChanged) {
                LaptimeMS = lapUpdate.LaptimeMS;
                if (LaptimeMS == null)
                    LaptimeString = "--";
                else
                    LaptimeString = $"{TimeSpan.FromMilliseconds(LaptimeMS.Value):mm\\:ss\\.fff}";

                Split1MS = lapUpdate.Splits.FirstOrDefault();
                if (Split1MS != null)
                    Split1String = $"{TimeSpan.FromMilliseconds(Split1MS.Value):ss\\.f}";
                else
                    Split1String = "";

                Split2MS = lapUpdate.Splits.Skip(1).FirstOrDefault();
                if (Split2MS != null)
                    Split2String = $"{TimeSpan.FromMilliseconds(Split2MS.Value):ss\\.f}";
                else
                    Split2String = "";

                Split3MS = lapUpdate.Splits.Skip(2).FirstOrDefault();
                if (Split3MS != null)
                    Split3String = $"{TimeSpan.FromMilliseconds(Split3MS.Value):ss\\.f}";
                else
                    Split3String = "";

                Type = lapUpdate.Type;
                IsValid = lapUpdate.IsValidForBest;

                if (Type == LapType.Outlap)
                    LapHint = "OUT";
                else if (Type == LapType.Inlap)
                    LapHint = "IN";
                else
                    LapHint = "";
            }
        }
    }

    public class CarData : KSObservableObject {
        public int CarIndex { get; }
        public int RaceNumber { get => Get<int>(); private set => Set(value); }
        public int CarModelEnum { get => Get<int>(); private set => Set(value); }
        public string TeamName { get => Get<string>(); private set => Set(value); }
        public int CupCategoryEnum { get => Get<int>(); private set => Set(value); }
        public DriverData CurrentDriver { get => Get<DriverData>(); private set => Set(value); }

        public IEnumerable<DriverData> InactiveDrivers { get { return Drivers.Where(x => x.DriverIndex != CurrentDriver?.DriverIndex); } }
        public ObservableCollection<DriverData> Drivers { get; } = new ObservableCollection<DriverData>();

        public CarLocationEnum CarLocation { get => Get<CarLocationEnum>(); private set => Set(value); }
        public int Delta { get => Get<int>(); private set => Set(value); }
        public string DeltaString { get => Get<string>(); private set => Set(value); }
        public int Gear { get => Get<int>(); private set => Set(value); }
        public int Kmh { get => Get<int>(); private set => Set(value); }
        public int Position { get => Get<int>(); private set => Set(value); }
        public int CupPosition { get => Get<int>(); private set => Set(value); }
        public int TrackPosition { get => Get<int>(); private set => Set(value); }
        public float SplinePosition { get => Get<float>(); private set => Set(value); }
        public float WorldX { get => Get<float>(); private set => Set(value); }
        public float WorldY { get => Get<float>(); private set => Set(value); }
        public float Yaw { get => Get<float>(); private set => Set(value); }
        public int Laps { get => Get<int>(); private set => Set(value); }
        public LapData BestLap { get => Get<LapData>(); private set => Set(value); }
        public LapData LastLap { get => Get<LapData>(); private set => Set(value); }
        public LapData CurrentLap { get => Get<LapData>(); private set => Set(value); }
        public string LocationHint { get => Get<string>(); private set => Set(value); }

        public float GapFrontMeters {
            get => Get<float>(); set {
                if (Set(value)) {
                    NotifyUpdate(nameof(GapText));
                }
            }
        }

        public string GapText {
            get {
                if (Kmh < 10)
                    return "Gap: ---";
                return $"Gap: {GapFrontMeters / Kmh * 3.6:F1}s ⇅";
            }
        }

        public CarData(ushort carIndex) {
            CarIndex = carIndex;
        }

        internal void Update(CarInfo carUpdate) {
            RaceNumber = carUpdate.RaceNumber;
            CarModelEnum = carUpdate.CarModelType;
            TeamName = carUpdate.TeamName;
            CupCategoryEnum = carUpdate.CupCategory;

            if (carUpdate.Drivers.Count != Drivers.Count) {
                Drivers.Clear();
                int driverIndex = 0;
                foreach (DriverInfo driver in carUpdate.Drivers) {
                    Drivers.Add(new DriverData(driver, driverIndex++));
                }
                NotifyUpdate(nameof(InactiveDrivers));
            }
        }

        internal void Update(RealtimeCarUpdate carUpdate) {
            if (carUpdate.CarIndex != CarIndex) {
                System.Diagnostics.Debug.WriteLine($"Wrong {nameof(RealtimeCarUpdate)}.CarIndex {carUpdate.CarIndex} for {nameof(CarData)}.CarIndex {CarIndex}");
                return;
            }

            if (CurrentDriver?.DriverIndex != carUpdate.DriverIndex) {
                // The driver has changed!
                CurrentDriver = Drivers.SingleOrDefault(x => x.DriverIndex == carUpdate.DriverIndex);
                NotifyUpdate(nameof(InactiveDrivers));
            }

            CarLocation = carUpdate.CarLocation;
            Delta = carUpdate.Delta;
            DeltaString = $"{TimeSpan.FromMilliseconds(Delta):ss\\.f}";

            Gear = carUpdate.Gear;
            Kmh = carUpdate.Kmh;
            Position = carUpdate.Position;
            CupPosition = carUpdate.CupPosition;
            TrackPosition = carUpdate.TrackPosition;
            SplinePosition = carUpdate.SplinePosition;
            WorldX = carUpdate.WorldPosX;
            WorldY = carUpdate.WorldPosY;
            Yaw = carUpdate.Yaw;
            Laps = carUpdate.Laps;

            if (BestLap == null && carUpdate.BestSessionLap != null)
                BestLap = new LapData();
            if (carUpdate.BestSessionLap != null)
                BestLap.Update(carUpdate.BestSessionLap);

            if (LastLap == null && carUpdate.LastLap != null)
                LastLap = new LapData();
            if (carUpdate.LastLap != null)
                LastLap.Update(carUpdate.LastLap);

            if (CurrentLap == null && carUpdate.CurrentLap != null)
                CurrentLap = new LapData();
            if (carUpdate.CurrentLap != null)
                CurrentLap.Update(carUpdate.CurrentLap);

            // The location hint will combine stuff like pits, in/outlap
            if (CarLocation == CarLocationEnum.PitEntry)
                LocationHint = "IN";
            else if (CarLocation == CarLocationEnum.Pitlane)
                LocationHint = "PIT";
            else if (CarLocation == CarLocationEnum.PitExit)
                LocationHint = "OUT";
            else
                LocationHint = CurrentLap?.LapHint;
        }
    }

    public class UDPProvider {
        public ObservableCollection<CarData> Cars { get; set; } = new ObservableCollection<CarData>();
        public ObservableCollection<DriverData> Drivers { get; set; } = new ObservableCollection<DriverData>();
        public ObservableCollection<LapData> Laps { get; set; } = new ObservableCollection<LapData>();

        private float trackMeters = 0;
        private string cmdFileName;
        private string outFileName;

        public UDPProvider(string cmdFileName, string outFileName) {
            this.cmdFileName = cmdFileName;
            this.outFileName = outFileName;
        }
		
		public void Reset() {
			Cars = new ObservableCollection<CarData>();
			Drivers = new ObservableCollection<DriverData>();
			Laps = new ObservableCollection<LapData>();
			
			trackMeters = 0;
		}

		public void ReadStandings(string ip, int port, string displayName, string connectionPassword, string commandPassword) {
            TextWriterTraceListener listener = new TextWriterTraceListener(this.outFileName + ".Trace");
            Debug.Listeners.Add(listener);

            Debug.WriteLine("Starting UDP Client...");

			bool done = false;
			bool firstRun = true;
        
			while (!done) {
				ACCUdpRemoteClient client = new ACCUdpRemoteClient(ip, port, displayName, connectionPassword, commandPassword, 100);

				client.MessageHandler.OnRealtimeUpdate += OnRealtimeUpdate;
				client.MessageHandler.OnTrackDataUpdate += OnTrackDataUpdate;
				client.MessageHandler.OnEntrylistUpdate += OnEntryListUpdate;
				client.MessageHandler.OnRealtimeCarUpdate += OnRealtimeCarUpdate;
				client.MessageHandler.OnBroadcastingEvent += OnBroadcastingEvent;

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
						listener.Flush();

						if (File.Exists(cmdFileName)) {
							requests += 1;
							
							StreamReader cmdStream = new StreamReader(cmdFileName);

							string command = cmdStream.ReadLine();

							if (command == "Exit")
								done = true;
							else if (command == "Read") {
								StreamWriter outStream = new StreamWriter(outFileName, false, Encoding.Unicode);

								outStream.WriteLine("[Position Data]");

								outStream.Write("Car.Count="); outStream.WriteLine(Cars.Count);

								int index = 1;

								foreach (CarData car in Cars) {
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Nr="); outStream.WriteLine(car.RaceNumber);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Position="); outStream.WriteLine(car.Position);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Lap="); outStream.WriteLine(car.Laps);
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Lap.Running="); outStream.WriteLine(car.SplinePosition);

									LapData lastLap = car.LastLap;

									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Lap.Valid="); outStream.WriteLine(lastLap != null ? (lastLap.IsValid ? "true" : "false") : "true");

									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Time=");
									outStream.WriteLine(lastLap != null ? (lastLap.LaptimeMS != null ? lastLap.LaptimeMS : 0) : 0);

									outStream.Write("Car."); outStream.Write(index);
									if (lastLap != null) {
										string split1MS = lastLap.Split1MS + "";
										string split2MS = lastLap.Split2MS + "";
										string split3MS = lastLap.Split3MS + "";

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
									
									outStream.Write("Car."); outStream.Write(index); outStream.Write(".Car="); outStream.WriteLine(car.CarModelEnum);

									DriverData currentDriver = car.CurrentDriver;

									if (currentDriver != null) {
										outStream.Write("Car."); outStream.Write(index); outStream.Write(".Driver.Forname="); outStream.WriteLine(currentDriver.FirstName);
										outStream.Write("Car."); outStream.Write(index); outStream.Write(".Driver.Surname="); outStream.WriteLine(currentDriver.LastName);
										outStream.Write("Car."); outStream.Write(index); outStream.Write(".Driver.Nickname="); outStream.WriteLine(currentDriver.ShortName);
									}

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

				client.MessageHandler.OnRealtimeUpdate -= OnRealtimeUpdate;
				client.MessageHandler.OnTrackDataUpdate -= OnTrackDataUpdate;
				client.MessageHandler.OnEntrylistUpdate -= OnEntryListUpdate;
				client.MessageHandler.OnRealtimeCarUpdate -= OnRealtimeCarUpdate;
				client.MessageHandler.OnBroadcastingEvent -= OnBroadcastingEvent;

				client.Shutdown();
			}
        }

        private void OnBroadcastingEvent(string sender, BroadcastingEvent evt) {
        }

        private void OnTrackDataUpdate(string sender, TrackData trackData) {
            trackMeters = trackData.TrackMeters;
        }

        private void OnEntryListUpdate(string sender, CarInfo carInfo) {
            try {
                CarData car = Cars.SingleOrDefault(x => x.CarIndex == carInfo.CarIndex);

                if (car == null) {
                    car = new CarData(carInfo.CarIndex);

                    Cars.Add(car);
                }

                car.Update(carInfo);
            }
            catch (Exception ex) {
                Debug.WriteLine(ex.Message);
            }
        }

        private void OnRealtimeCarUpdate(string sender, RealtimeCarUpdate carInfo) {
            try {
                CarData car = Cars.FirstOrDefault(x => x.CarIndex == carInfo.CarIndex);

                if (car != null)
                    car.Update(carInfo);
            }
            catch (Exception ex) {
                Debug.WriteLine(ex.Message);
            }
        }

        private void OnRealtimeUpdate(string sender, RealtimeUpdate realtimeUpdate) {
            try {
                if (trackMeters > 0) {
                    var sortedCars = Cars.OrderBy(x => x.SplinePosition).ToArray();

                    for (int i = 1; i < sortedCars.Length; i++) {
                        var carAhead = sortedCars[i - 1];
                        var carBehind = sortedCars[i];
                        var splineDistance = Math.Abs(carAhead.SplinePosition - carBehind.SplinePosition);

                        while (splineDistance > 1f)
                            splineDistance -= 1f;

                        carBehind.GapFrontMeters = splineDistance * trackMeters;
                    }
                }
            }
            catch (Exception ex) {
                Debug.WriteLine(ex.Message);
            }
        }
    }
}
