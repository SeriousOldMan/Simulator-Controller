using System;
using TeamServer.Model;

namespace TeamServer.Server {
    public class UpdateManager : ManagerBase {
        public UpdateManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        public Lap GetCurrentLap(Session session) {
            ValidateSession(session);

            Stint stint = session.GetCurrentStint();

            if (stint != null)
                return stint.GetCurrentLap();
            else
                return null;
        }

        public Lap GetCurrentLap(string identifier) {
            return GetCurrentLap(ObjectManager.GetSessionAsync(identifier).Result);
        }
    }
}
