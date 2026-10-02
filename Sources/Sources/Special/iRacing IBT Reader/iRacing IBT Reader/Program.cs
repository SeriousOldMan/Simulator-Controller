using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;

using iRacing.IRSDK;

namespace iRacingIBTReader
{
    internal class Program
    {
        static void Main(string[] args)
        {
			Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");
			
            convertTelemetry(args[0], args[1]);
        }

        static void convertTelemetry(string ibtFileName, string telemetryDirectory)
        {
            IRSDKDiskReader ibtFile = new IRSDKDiskReader(ibtFileName);

            int lap = 0;
            long record = 0;

            StreamWriter csvFile = null;

            int lapIdx = 0;
            int lapDistIdx = 0;
            int lapDistPctIdx = 0;
            int speedIdx = 0;
            int throttleIdx = 0;
            int brakeIdx = 0;
            int steerAngleMaxIdx = 0;
            int steerAngleIdx = 0;
            int gearIdx = 0;
            int rpmsIdx = 0;
            int longGIdx = 0;
            int latGIdx = 0;
			
			int lapTimeIdx = 0;
			
			int yawRateIdx = 0;
			
			int lfShockDeflIdx = 0;
			int rfShockDeflIdx = 0;
			int lrShockDeflIdx = 0;
			int rrShockDeflIdx = 0;

            for (int i = 0; i < ibtFile.getNumVars(); i++)
            {
                string name = ibtFile.getVarName(i);

                if (name == "Lap")
                    lapIdx = i;
                else if (name == "LapDist")
                    lapDistIdx = i;
                else if (name == "LapDistPct")
                    lapDistPctIdx = i;
                else if (name == "Speed")
                    speedIdx = i;
                else if (name == "Throttle")
                    throttleIdx = i;
                else if (name == "Brake")
                    brakeIdx = i;
                else if (name == "SteeringWheelAngleMax")
                    steerAngleMaxIdx = i;
                else if (name == "SteeringWheelAngle")
                    steerAngleIdx = i;
                else if (name == "Gear")
                    gearIdx = i;
                else if (name == "RPM")
                    rpmsIdx = i;
                else if (name == "LongAccel")
                    longGIdx = i;
                else if (name == "LatAccel")
                    latGIdx = i;
                else if (name == "LapLastLapTime")
					lapTimeIdx = i;
                else if (name == "YawRate")
					yawRateIdx = i;
                else if (name == "LFshockDefl")
					lfShockDeflIdx = i;
                else if (name == "RFshockDefl")
					rfShockDeflIdx = i;
                else if (name == "LRshockDefl")
					lrShockDeflIdx = i;
                else if (name == "RRshockDefl")
					rrShockDeflIdx = i;
            }

            while (true)
                if (++record < ibtFile.getNumRecords())
                {
                    ibtFile.readNextRecordLine();

                    int currentLap = (int)ibtFile.getVarValue(lapIdx);

                    if (currentLap != lap)
                    {
                        if (csvFile != null)
                        {
                            csvFile.Close();

                            csvFile = null;
							
							StreamWriter infoFile = new StreamWriter(telemetryDirectory + "\\Lap " + lap + ".info", false);

							infoFile.WriteLine("[Info]");
							infoFile.WriteLine("Source=iRacing");
							infoFile.Write("Lap="); infoFile.WriteLine(lap);
							infoFile.Write("LapTime="); infoFile.WriteLine((float)ibtFile.getVarValue(lapTimeIdx));

							infoFile.Close();
                        }
						
                        lap = currentLap;
                    }

                    if (lap > 0)
                    {
                        if (csvFile == null)
                            csvFile = new StreamWriter(telemetryDirectory + "\\Lap " + lap + ".irc", false);

                        float playerRunning = (float)ibtFile.getVarValue(lapDistIdx);
                        float speed = (float)ibtFile.getVarValue(speedIdx) * 3.6f;
                        float throttle = (float)ibtFile.getVarValue(throttleIdx);
                        float brake = (float)ibtFile.getVarValue(brakeIdx);
                        float steerAngle = (float)ibtFile.getVarValue(steerAngleIdx) / (float)ibtFile.getVarValue(steerAngleMaxIdx);
                        int gear = (int)ibtFile.getVarValue(gearIdx);
                        int rpms = (int)(float)ibtFile.getVarValue(rpmsIdx);
                        float longG = (float)ibtFile.getVarValue(longGIdx) / 9.807f;
                        float latG = (float)ibtFile.getVarValue(latGIdx) / 9.807f;
                        float playerRunningPct = (float)ibtFile.getVarValue(lapDistPctIdx);
						float yawRate = (float)ibtFile.getVarValue(yawRateIdx);
						float lfShockDefl = (float)ibtFile.getVarValue(lfShockDeflIdx);
						float rfShockDefl = (float)ibtFile.getVarValue(rfShockDeflIdx);
						float lrShockDefl = (float)ibtFile.getVarValue(lrShockDeflIdx);
						float rrShockDefl = (float)ibtFile.getVarValue(rrShockDeflIdx);

                        csvFile.Write(playerRunning + ";");
                        csvFile.Write(throttle + ";");
                        csvFile.Write(brake + ";");
                        csvFile.Write(steerAngle + ";");
                        csvFile.Write(gear + ";");
                        csvFile.Write(rpms + ";");
                        csvFile.Write(speed + ";");
                        csvFile.Write("N/A" + ";");
                        csvFile.Write("N/A" + ";");
                        csvFile.Write(longG + ";");
                        csvFile.Write(-latG + ";");
                        csvFile.Write(playerRunningPct + ";");
                        csvFile.Write(yawRate + ";");
                        csvFile.Write(lfShockDefl + ";");
                        csvFile.Write(rfShockDefl + ";");
                        csvFile.Write(lrShockDefl + ";");
                        csvFile.WriteLine(rrShockDefl);
                    }
                }
                else
                    break;

            if (csvFile != null)
                csvFile.Close();

            ibtFile.closeFile();
        }
    }
}
