using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using SQLite;
using System;
using System.IO;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer {
    public class Program {
        public static void Main(string[] args) {
            SQLiteAsyncConnection connection = null;

            if (Array.IndexOf<string>(args, "-Memory") != -1)
                connection = new SQLiteAsyncConnection(":memory:");
            else
                connection = new SQLiteAsyncConnection(Path.Combine(Environment.CurrentDirectory, "TeamServer.db"));

            var objectManager = new ObjectManager(connection);

            new ModelManager(connection).CreateTables();

            if (Array.IndexOf<string>(args, "-Local") != -1)
                CreateLocalAccount(objectManager);

            new Server.TeamServer(objectManager);

            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder => {
                    webBuilder.UseStartup<Startup>();
                });

        static void CreateLocalAccount(ObjectManager objectManager) {
            if (objectManager.GetAccountAsync("", "").Result == null) {
                Account account = new Account { Name = "", Password = "", MinutesLeft = Int32.MaxValue };

                account.Save();
            }
        }
    }
}
