using Newtonsoft.Json;
using System.Globalization;

static class Program
{
    static StreamWriter outStream = null;

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
                }
        }

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
        outStream.WriteLine(latG);
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

                        if (value == "N")
                            value = "0";

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
                        longG = float.Parse(reader.Value.ToString());
                        break;
                    case "ZinMs":
                        reader.Read();
                        latG = float.Parse(reader.Value.ToString());
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
                        abs = (reader.Value.ToString() == "true" ? 1 : 0);
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
                        tc = (reader.Value.ToString() == "true" ? 1 : 0);
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

        while (reader.Read())
            if (reader.Value != null && reader.Value.ToString() == "DataPoints") {
                readPoints(reader);

                break;
            }

        outStream.Close();
    }
}