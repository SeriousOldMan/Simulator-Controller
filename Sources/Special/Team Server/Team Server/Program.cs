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
            public int Minutes { get; set; }
            public bool Administrator { get; set; }
        }

        public string DBPath { get; set; }

        public int TokenLifeTime { get; set; }

        public IList<Account> Accounts { get; set; } = null;
    }

    public class Program {
        public static void Main(string[] args) {
            string json = File.ReadAllText(Path.Combine(Environment.CurrentDirectory, "Settings.json"));
            Settings settings= JsonSerializer.Deserialize<Settings>(json);

            SQLiteAsyncConnection connection;

            if (settings.DBPath == ":memory:")
                connection = new SQLiteAsyncConnection(":memory:");
            else if (settings.DBPath == ":local:")
                connection = new SQLiteAsyncConnection(Path.Combine(Environment.CurrentDirectory, "TeamServer.db"));
            else
                connection = new SQLiteAsyncConnection(Path.Combine(Environment.CurrentDirectory, "TeamServer.db"));

            var objectManager = new ObjectManager(connection);

            new ModelManager(connection).CreateTables();

            CreateAccounts(objectManager, settings.Accounts);

            new Server.TeamServer(objectManager, settings.TokenLifeTime);

            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder => {
                    webBuilder.UseStartup<Startup>();
                });

        static void CreateAccounts(ObjectManager objectManager, IList<Settings.Account> accounts) {
            foreach (Settings.Account account in accounts)
                if (objectManager.GetAccountAsync(account.Name, account.Password).Result == null)
                    new Account { Name = account.Name, Password = account.Password, Virgin = false,
                                  Administrator = account.Administrator, MinutesLeft = account.Minutes }.Save();
        }
    }
}
