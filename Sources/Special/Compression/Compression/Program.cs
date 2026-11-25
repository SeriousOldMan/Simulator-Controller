using System;
using System.IO.Compression;

namespace Compression
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length > 0 && args[0] == "-Zip")
                ZipFile.CreateFromDirectory(args[1], args[2]);
            else if (args.Length > 0 && args[0] == "-Unzip")
                ZipFile.ExtractToDirectory(args[1], args[2]);
        }
    }
}
