using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using SQLite;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer {

    public class Settings {
        public class Account {
            public string Name { get; set; }
            public string Password { get; set; }
            public int Minutes { get; set; } = 0;
            public bool Session { get; set; } = true;
            public bool Data { get; set; } = false;
            public bool Administrator { get; set; } = false;
            public bool Reset { get; set; } = false;
        }

        public string DBPath { get; set; }

        public int TokenLifeTime { get; set; }

        public int ConnectionLifeTime { get; set; }

        public IList<Account> Accounts { get; set; } = null;
    }

    public class Program {
        public static void Main(string[] args) {
            string json = File.ReadAllText(Path.Combine(Environment.CurrentDirectory, "Settings.json"));
            Settings settings = JsonSerializer.Deserialize<Settings>(json);

            SQLiteAsyncConnection connection;

            if (settings.DBPath.ToLower() == ":memory:")
                connection = new SQLiteAsyncConnection(":memory:");
            else if (settings.DBPath.ToLower() == ":local:")
                connection = new SQLiteAsyncConnection(Path.Combine(Environment.CurrentDirectory, "TeamServer.db"));
            else
                connection = new SQLiteAsyncConnection(Path.Combine(Environment.CurrentDirectory, "TeamServer.db"));

            var objectManager = new ObjectManager(connection);

            new ModelManager(connection).CreateTables();

            CreateAccounts(objectManager, settings.Accounts);

            new Server.TeamServer(objectManager, settings.TokenLifeTime, Math.Max(settings.ConnectionLifeTime, 300));

            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder => {
                    webBuilder.UseStartup<Startup>();
                });

        static void CreateAccounts(ObjectManager objectManager, IList<Settings.Account> accounts) {
            foreach (Settings.Account descriptor in accounts) {
                Account account = objectManager.GetAccountAsync(descriptor.Name).Result;

                if (account == null)
                    new Account {
                        Name = descriptor.Name,
                        Password = descriptor.Password,
                        Virgin = false,
                        Administrator = descriptor.Administrator,
                        AvailableMinutes = descriptor.Minutes,
                        SessionAccess = descriptor.Session,
                        DataAccess = descriptor.Data
                    }.Save();
                else if (descriptor.Reset) {
                    account.Password = descriptor.Password;
                    account.AvailableMinutes = descriptor.Minutes;
                    account.SessionAccess = descriptor.Session;
                    account.DataAccess = descriptor.Data;

                    account.Save();
                }
            }
        }
    }
}
