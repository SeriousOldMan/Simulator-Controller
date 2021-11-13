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
            Contract contract = new Contract { Account = "TestAccount", Password = "TestPassword", MinutesLeft = 3600 };
            Team team = new Team { Name = "TestTeam" };

            contract.Save();
            team.Save();
        }
    }
}
