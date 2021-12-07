using System;
using TeamServer.Model;

namespace TeamServer.Server {
    public class TeamServer {
        public static ObjectManager ObjectManager = null;
        public static TokenIssuer TokenIssuer = null;

        static TeamServer Instance;

        public TeamServer(ObjectManager objectManager, int tokenLifeTime) {
            Instance = this;

            ObjectManager = objectManager;
            TokenIssuer = new TokenIssuer(objectManager, tokenLifeTime);

            new TaskManager(objectManager, TokenIssuer.AdminToken).RunBackgroundTasksAsync();
        }
    }
}