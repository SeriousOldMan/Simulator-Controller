using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace ACSHMCoach {
	enum AC_MEMORY_STATUS { DISCONNECTED, CONNECTING, CONNECTED }

	public class SHMCoach
	{
		bool connected = false;

		private AC_MEMORY_STATUS memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
		public bool IsRunning { get { return (memoryStatus == AC_MEMORY_STATUS.CONNECTED); } }

		Physics physics;
		Graphics graphics;
		Cars cars;
		StaticInfo staticInfo;

		public SHMCoach()
		{
			connected = ConnectToSharedMemory();
		}

		string GetSession(AC_SESSION_TYPE session)
		{
			switch (session)
			{
				case AC_SESSION_TYPE.AC_PRACTICE:
					return "Practice";
				case AC_SESSION_TYPE.AC_QUALIFY:
					return "Qualification";
				case AC_SESSION_TYPE.AC_RACE:
					return "Race";
				default:
					return "Other";
			}
		}

		private bool ConnectToSharedMemory()
		{
			try
			{
				memoryStatus = AC_MEMORY_STATUS.CONNECTING;

				// Connect to shared memory
				physicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_physics");
				graphicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_graphics");
				staticInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_static");
				carsInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_cars");

				physics = ReadPhysics();
				graphics = ReadGraphics();
				staticInfo = ReadStaticInfo();
				cars = ReadCars();

				memoryStatus = AC_MEMORY_STATUS.CONNECTED;

				return true;
			}
			catch (FileNotFoundException)
			{
				return false;
			}
		}

		public void Close()
		{
			memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
		}

		MemoryMappedFile physicsMMF;
		MemoryMappedFile graphicsMMF;
		MemoryMappedFile staticInfoMMF;
		MemoryMappedFile carsInfoMMF;

		public Physics ReadPhysics()
		{
			using (var stream = physicsMMF.CreateViewStream())
			{
				using (var reader = new BinaryReader(stream))
				{
					var size = Marshal.SizeOf(typeof(Physics));
					var bytes = reader.ReadBytes(size);
					var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
					var data = (Physics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Physics));
					handle.Free();
					return data;
				}
			}
		}

		public Graphics ReadGraphics()
		{
			using (var stream = graphicsMMF.CreateViewStream())
			{
				using (var reader = new BinaryReader(stream))
				{
					var size = Marshal.SizeOf(typeof(Graphics));
					var bytes = reader.ReadBytes(size);
					var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
					var data = (Graphics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Graphics));
					handle.Free();
					return data;
				}
			}
		}

		public StaticInfo ReadStaticInfo()
		{
			using (var stream = staticInfoMMF.CreateViewStream())
			{
				using (var reader = new BinaryReader(stream))
				{
					var size = Marshal.SizeOf(typeof(StaticInfo));
					var bytes = reader.ReadBytes(size);
					var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
					var data = (StaticInfo)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(StaticInfo));
					handle.Free();
					return data;
				}
			}
        }

        public Cars ReadCars()
        {
            using (var stream = carsInfoMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    while (true)
                    {
                        var size = Marshal.SizeOf(typeof(Cars));
                        var bytes = reader.ReadBytes(size);
                        var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                        var data = (Cars)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Cars));

                        int packetID = data.packetID;

                        if (packetID == -1)
                        {
                            handle.Free();

                            Thread.Sleep(10);

                            continue;
                        }

                        data = (Cars)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Cars));

                        handle.Free();

                        if (packetID == data.packetID)
                            return data;
                        else
                            Thread.Sleep(10);
                    }
                }
            }
        }

        private static string GetStringFromBytes(byte[] bytes)
		{
			if (bytes == null)
				return "";

			var nullIdx = Array.IndexOf(bytes, (byte)0);

			return nullIdx >= 0 ? Encoding.Default.GetString(bytes, 0, nullIdx) : Encoding.Default.GetString(bytes);
		}

		const int WM_COPYDATA = 0x004A;

		public struct COPYDATASTRUCT
		{
			public IntPtr dwData;
			public int cbData;
			[MarshalAs(UnmanagedType.LPStr)]
			public string lpData;
		}

		[DllImport("user32.dll")]
		public static extern int FindWindowEx(int hwndParent, int hwndChildAfter, string lpszClass, string lpszWindow);

		[DllImport("user32.dll")]
		public static extern int SendMessage(int hWnd, int uMsg, int wParam, ref COPYDATASTRUCT lParam);

		public int SendStringMessage(int hWnd, int wParam, string msg)
		{
			int result = 0;

			if (hWnd > 0)
			{
				byte[] sarr = System.Text.Encoding.Default.GetBytes(msg);
				int len = sarr.Length;
				COPYDATASTRUCT cds;

				cds.dwData = (IntPtr)(256 * 'D' + 'C');
				cds.lpData = msg;
				cds.cbData = len + 1;

				result = SendMessage(hWnd, WM_COPYDATA, wParam, ref cds);
			}

			return result;
		}

        void SendTriggerMessage(string message)
        {
            int winHandle = FindWindowEx(0, 0, null, "Driving Coach.exe");

            if (winHandle == 0)
                winHandle = FindWindowEx(0, 0, null, "Driving Coach.ahk");

            if (winHandle != 0)
                SendStringMessage(winHandle, 0, "Driving Coach:" + message);
        }

		float[] xCoordinates = new float[256];
		float[] yCoordinates = new float[256];
		int numCoordinates = 0;
		long lastUpdate = 0;
		string triggerType = "Trigger";

		void checkCoordinates()
		{
			if ((triggerType == "BrakeHints") ? true : DateTimeOffset.Now.ToUnixTimeMilliseconds() > (lastUpdate + 2000))
			{
				double velocityX = physics.LocalVelocity[0];
				double velocityY = physics.LocalVelocity[2];
				double velocityZ = physics.LocalVelocity[1];

				if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
					int carID = 0;

					float coordinateX = cars.cars[carID].worldPosition.x;
					float coordinateY = cars.cars[carID].worldPosition.z;

					if ((coordinateX != 0) || (coordinateY != 0))
						for (int i = 0; i < numCoordinates; i++)
						{
							if (Math.Abs(xCoordinates[i] - coordinateX) < 20 && Math.Abs(yCoordinates[i] - coordinateY) < 20)
							{
								if (triggerType == "Trigger")
									SendTriggerMessage("positionTrigger:" + (i + 1) + ";" + xCoordinates[i] + ";" + yCoordinates[i]);
                                else if (triggerType == "BrakeHints")
                                    if (audioDevice != "")
                                        SendTriggerMessage("acousticFeedback:" + hintSounds[i]);
                                    else
                                        new System.Media.SoundPlayer(hintSounds[i]).Play();

                                lastUpdate = DateTimeOffset.Now.ToUnixTimeMilliseconds();

								break;
							}
						}
				}
			}
        }

        public void initializeTrigger(string type, string[] args)
        {
			triggerType = type;

            for (int i = 1; i < (args.Length - 1); i += 2)
            {
                xCoordinates[numCoordinates] = float.Parse(args[i]);
                yCoordinates[numCoordinates] = float.Parse(args[i + 1]);

                if (++numCoordinates > 255)
                    break;
            }
        }

        string[] hintSounds = new string[256];
        DateTime lastHintsUpdate = DateTime.Now;

        public void loadBrakeHints()
        {
            if ((hintFile != "") && System.IO.File.Exists(hintFile))
            {
                if (numCoordinates == 0 || (System.IO.File.GetLastWriteTime(hintFile) > lastHintsUpdate))
                {
                    numCoordinates = 0;
					lastHintsUpdate = System.IO.File.GetLastWriteTime(hintFile);

                    foreach (var line in System.IO.File.ReadLines(hintFile))
                    {
                        var parts = line.Split(new char[] { ' ' }, 3);

                        xCoordinates[numCoordinates] = float.Parse(parts[0]);
                        yCoordinates[numCoordinates] = float.Parse(parts[1]);
                        hintSounds[numCoordinates] = parts[2];

                        if (++numCoordinates > 255)
                            break;
                    }
                }
            }
        }

        string audioDevice = string.Empty;
        string hintFile = string.Empty;

        public void initializeBrakeHints(string type, string[] args)
        {
            triggerType = type;

            hintFile = args[1];

            if (args.Length > 2)
                audioDevice = args[2];
        }

        public void Run(bool positionTrigger, bool brakeHints)
		{
            while (true)
			{
				physics = ReadPhysics();
				graphics = ReadGraphics();
				staticInfo = ReadStaticInfo();

				if (positionTrigger)
				{
					checkCoordinates();

					Thread.Sleep(10);
                }
                else if (brakeHints)
                {
                    loadBrakeHints();

                    checkCoordinates();

                    Thread.Sleep(10);
                }
            }

			Close();
		}
	}
}
