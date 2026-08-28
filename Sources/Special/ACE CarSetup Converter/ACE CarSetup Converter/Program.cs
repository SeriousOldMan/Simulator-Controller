using ProtoBufJsonConverter;
using ProtoBufJsonConverter.Models;
using System.Globalization;
using System.IO;
using System.Threading;

namespace ACECarSetupConverter
{
    internal class Program
    {
        static string protoDefinition;

        static void readSetup(string protoFile, string jsonFile)
        {
            var bytes = File.ReadAllBytes(protoFile);
            var request = new ConvertToJsonRequest(protoDefinition, "CarSetupData", bytes);

            File.WriteAllText(jsonFile, new Converter().ConvertAsync(request).Result);
        }

        static void writeSetup(string jsonFile, string protoFile)
        {
            var json = File.ReadAllText(jsonFile);
            var request = new ConvertToProtoBufRequest(protoDefinition, "CarSetupData", json);

            File.WriteAllBytes(protoFile, new Converter().ConvertAsync(request).Result);
        }

        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            protoDefinition = File.ReadAllText(args[0]);

            if (args[1].ToLower() == "-read")
                readSetup(args[2], args[3]);
            else if (args[0].ToLower() == "-write")
                writeSetup(args[2], args[3]);
        }
    }
}
