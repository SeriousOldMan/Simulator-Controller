using Newtonsoft.Json;
using System.Globalization;

static class Program
{
    static StreamWriter outStream = null;

    static float playerRunning = 0.0f;
    static float speed = 0.0f;
    static float throttle = 0.0f;
    static float brake = 0.0f;
    static float steering = 0.0f;
    static int gear = 0;
    static int rpms = 0;
    static float longG = 0.0f;
    static float latG = 0.0f;

    static void readPoints(JsonTextReader reader)
    {
        reader.Read();

        while (reader.Read())
        {
            if (reader.TokenType == JsonToken.EndArray)
                break;
            else
                readPoint(reader);
        }
    }

    static void readPoint(JsonTextReader reader)
    {
        while (reader.Read())
        {
            if (reader.TokenType == JsonToken.EndObject)
                break;
            else if (reader.Value != null && reader.Value.ToString() == "InputInfo")
                while (reader.Read())
                {
                    if (reader.TokenType == JsonToken.EndObject)
                        break;
                    else if (reader.Value != null)
                    {
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
                }

            outStream.Write(playerRunning + ";");
            outStream.Write(throttle + ";");
            outStream.Write(brake + ";");
            outStream.Write(steering + ";");
            outStream.Write(gear + ";");
            outStream.Write(rpms + ";");
            outStream.Write(speed + ";");
            outStream.Write("n/a" + ";");
            outStream.Write("n/a" + ";");
            outStream.Write(longG + ";");
            outStream.WriteLine(latG);
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