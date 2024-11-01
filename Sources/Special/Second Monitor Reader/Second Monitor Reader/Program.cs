using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Globalization;

static class Program
{
    static StreamWriter outStream = null;

    static float lastRunning = -1;

    static float running = 0.0f;
    static float speed = 0.0f;
    static float throttle = 0.0f;
    static float brake = 0.0f;
    static float steering = 0.0f;
    static int gear = 0;
    static int rpms = 0;
    static int tc = 0;
    static int abs = 0;
    static float longG = 0.0f;
    static float latG = 0.0f;
    static float posX = 0.0f;
    static float posY = 0.0f;

    static string driver = "John Doe (JD)";
    static int lapNumber = 0;
    static float lapTime = 0.0f;
    static float sector1Time = 0.0f;
    static float sector2Time = 0.0f;
    static float sector3Time = 0.0f;

    static void skipObject(JsonTextReader reader)
    {
        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
    }

    static void skipArray(JsonTextReader reader)
    {
        while (reader.Read())
            if (reader.TokenType == JsonToken.EndArray)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
    }

    static void readSummary(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "DriverName":
                        reader.Read();
                        driver = reader.Value.ToString();
                        break;
                    case "LapNumber":
                        reader.Read();
                        lapNumber = int.Parse(reader.Value.ToString());
                        break;
                    case "LapTimeSeconds":
                        reader.Read();
                        lapTime = float.Parse(reader.Value.ToString());
                        break;
                    case "Sector1TimeSeconds":
                        reader.Read();
                        sector1Time = float.Parse(reader.Value.ToString());
                        break;
                    case "Sector2TimeSeconds":
                        reader.Read();
                        sector2Time = float.Parse(reader.Value.ToString());
                        break;
                    case "Sector3TimeSeconds":
                        reader.Read();
                        sector3Time = float.Parse(reader.Value.ToString());
                        break;
                }

    }

    static void readPoints(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndArray)
                break;
            else
                readPoint(reader);
    }

    static void readPoint(JsonTextReader reader)
    {
        running = 0.0f;
        speed = 0.0f;
        throttle = 0.0f;
        brake = 0.0f;
        steering = 0.0f;
        gear = 0;
        rpms = 0;
        tc = 0;
        abs = 0;
        longG = 0.0f;
        latG = 0.0f;
        int time = 0;

        while (reader.Read())
        {
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "InputInfo":
                        readDriverInput(reader);
                        break;
                    case "PlayerData":
                        readData(reader);
                        break;
                    case "LapTimeSeconds":
                        reader.Read();
                        time = (int)Math.Round(float.Parse(reader.Value.ToString()) * 1000);
                        break;
                }
        }

        if (running > lastRunning)
        {
            outStream.Write(running + ";");
            outStream.Write(throttle + ";");
            outStream.Write(brake + ";");
            outStream.Write(steering + ";");
            outStream.Write(gear + ";");
            outStream.Write(rpms + ";");
            outStream.Write(speed + ";");
            outStream.Write(tc + ";");
            outStream.Write(abs + ";");
            outStream.Write(longG + ";");
            outStream.Write(latG + ";");
            outStream.Write("n/a" + ";");
            outStream.Write("n/a" + ";");
            outStream.WriteLine(time);

            lastRunning = running;
        }
    }

    static void readDriverInput(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "BrakePedalPosition":
                        reader.Read();
                        brake = float.Parse(reader.Value.ToString());
                        break;
                    case "ThrottlePedalPosition":
                        reader.Read();
                        throttle = float.Parse(reader.Value.ToString());
                        break;
                    case "SteeringInput":
                        reader.Read();
                        steering = float.Parse(reader.Value.ToString());
                        break;
                }
    }

    static void readData(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "LapDistance":
                        reader.Read();
                        running = float.Parse(reader.Value.ToString());
                        break;
                    case "Speed":
                        readSpeed(reader);
                        break;
                    case "CarInfo":
                        readCarData(reader);
                        break;
                    case "WorldPosition":
                        readPosition(reader);
                        break;
                }
    }

    static void readCarData(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "CurrentGear":
                        reader.Read();

                        string value = reader.Value.ToString();

                        
                        if (String.Compare(value, "N", comparisonType: StringComparison.OrdinalIgnoreCase) == 0)
                            value = "0";

                        if (String.Compare(value, "R", comparisonType: StringComparison.OrdinalIgnoreCase) == 0)
                            value = "-1";

                        gear = int.Parse(value);
                        break;
                    case "EngineRpm":
                        reader.Read();
                        rpms = int.Parse(reader.Value.ToString());
                        break;
                    case "Acceleration":
                        readAcceleration(reader);
                        break;
                    case "AbsInfo":
                        readABS(reader);
                        break;
                    case "TcInfo":
                        readTC(reader);
                        break;
                }
    }

    static void readSpeed(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "InMs":
                        reader.Read();
                        speed = float.Parse(reader.Value.ToString()) * 3.6f;
                        break;
                }
    }

    static void readPosition(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "X":
                        reader.Read();
                        reader.Read();
                        reader.Read();
                        posX = float.Parse(reader.Value.ToString());
                        reader.Read();
                        break;
                    case "Z":
                        reader.Read();
                        reader.Read();
                        reader.Read();
                        posY = float.Parse(reader.Value.ToString());
                        reader.Read();
                        break;
                }
    }

    static void readAcceleration(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "XinMs":
                        reader.Read();
                        latG = float.Parse(reader.Value.ToString()) / 9.807f;
                        break;
                    case "ZinMs":
                        reader.Read();
                        longG = float.Parse(reader.Value.ToString()) / 9.807f;
                        break;
                }
    }

    static void readABS(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "IsActive":
                        reader.Read();
                        abs = (String.Compare(reader.Value.ToString(), "true", comparisonType: StringComparison.OrdinalIgnoreCase) == 0 ? 1 : 0);
                        break;
                }
    }

    static void readTC(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "IsActive":
                        reader.Read();
                        tc = (String.Compare(reader.Value.ToString(), "true", comparisonType: StringComparison.OrdinalIgnoreCase) == 0 ? 1 : 0);
                        break;
                }
    }

    [STAThread]
    static void Main(string[] args)
    {
        Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

        string input = "";
        string output = "";

        if (args.Length > 0)
            input = args[0];

        if (args.Length > 1)
            output = args[1];

        outStream = new StreamWriter(output);
        
        JsonTextReader reader = new JsonTextReader(new StreamReader(input));

        reader.Read();

        while (reader.Read())
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.TokenType == JsonToken.StartObject)
                skipObject(reader);
            else if (reader.TokenType == JsonToken.StartArray)
                skipArray(reader);
            else if (reader.Value != null)
                switch (reader.Value.ToString())
                {
                    case "DataPoints":
                        readPoints(reader);
                        break;
                    case "LapSummary":
                        readSummary(reader);
                        break;
                }

        outStream.Close();

        if (args.Length > 2)
        {
            outStream = new StreamWriter(args[2]);

            outStream.WriteLine("[Info]");
            outStream.WriteLine("Source=Second Monitor");
            outStream.Write("Driver="); outStream.WriteLine(driver);
            outStream.Write("Lap="); outStream.WriteLine(lapNumber);
            outStream.Write("LapTime="); outStream.WriteLine(lapTime);
            outStream.Write("SectorTimes="); outStream.Write(sector1Time); outStream.Write(",");
                                             outStream.Write(sector2Time); outStream.Write(","); outStream.WriteLine(sector3Time);

            outStream.Close();
        }
    }
}