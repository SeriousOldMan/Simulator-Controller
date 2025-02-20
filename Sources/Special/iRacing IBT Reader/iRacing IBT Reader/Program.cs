using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;

using iRacing.IRSDK;

namespace iRacingIBTReader
{
    internal class Program
    {
        static void Main(string[] args)
        {
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
            }

            while (true)
                if (++record < ibtFile.getNumRecords())
                {
                    ibtFile.readNextRecordLine();

                    int currentLap = (int)ibtFile.getVarValue(lapIdx);

                    if (currentLap != lap)
                    {
                        lap = currentLap;

                        if (csvFile != null)
                        {
                            csvFile.Close();

                            csvFile = null;
                        }
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

                        csvFile.WriteLine();
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
