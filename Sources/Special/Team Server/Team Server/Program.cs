using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using SQLite;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer {
    public class Program {
        public static void Main(string[] args) {
            // string path1 = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "TeamServer.db");
            // string path2 = Path.Combine(Environment.CurrentDirectory, "TeamServer.db");

            var connection = new SQLiteAsyncConnection(":memory:");
            var objectManager = new ObjectManager(connection);

            new ModelManager(connection).CreateTables();

            CreateTestData(objectManager);

            new Server.TeamServer(objectManager);

            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder => {
                    webBuilder.UseStartup<Startup>();
                });

        static void CreateTestData(ObjectManager objectManager) {
            Account account = new Account { Name = "TestAccount", Password = "TestPassword", MinutesLeft = 3600 };
            
            account.Save();

            Team team = new Team { AccountID = objectManager.GetAccountAsync("TestAccount", "TestPassword").Result.ID, Name = "TestTeam" };

            team.Save();
        }
    }
}
