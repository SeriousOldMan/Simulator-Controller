using System;
using TeamServer.Model;

namespace TeamServer.Server {
    public class TeamServer {
        public static ObjectManager ObjectManager = null;
        public static TokenIssuer TokenIssuer = null;

        public readonly int ConnectionLifeTime;

        public static TeamServer Instance;

        public TeamServer(ObjectManager objectManager, int tokenLifeTime, int connectionLifeTime)
        {
            Instance = this;

            ObjectManager = objectManager;
            TokenIssuer = new TokenIssuer(objectManager, tokenLifeTime);

            ConnectionLifeTime = connectionLifeTime;

            new TaskManager(objectManager, TokenIssuer.InternalToken).RunBackgroundTasksAsync();
        }
    }
}