using Newtonsoft.Json;
using System.Globalization;

static class Program
{
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

        StreamWriter outStream = new StreamWriter(output);
        JsonTextReader reader = new JsonTextReader(new StreamReader(input));

        while (reader.Read())
        {
            /*
            if (reader.Value != null)
            {
                outStream.WriteLine("Token: {0}, Value: {1}", reader.TokenType, reader.Value);
            }
            else
            {
                outStream.WriteLine("Token: {0}", reader.TokenType);
            }
            */
        }

        outStream.Close();
    }
}