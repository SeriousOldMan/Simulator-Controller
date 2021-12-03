using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Access {
    [Table("Access_Accounts")]
    public class Account : ModelObject {
        public enum ContractType : int { Terminated = 0, OneTime = 1, FixedMinutes = 2, AdditionalMinutes = 3 };

        [Unique]
        public string Name { get; set; }

        public string EMail { get; set; }

        public string Password { get; set; }

        public bool Virgin { get; set; } = true;

        public bool Administrator { get; set; } = false;

        public int AvailableMinutes { get; set; }

        public ContractType Contract { get; set; } = ContractType.OneTime;

        public int ContractMinutes { get; set; } = 0;

        [Ignore]
        public List<Token> Tokens {
            get {
                return ObjectManager.GetAccountTokensAsync(this).Result;
            }
        }

        [Ignore]
        public List<Team> Teams {
            get {
                return ObjectManager.GetAccountTeamsAsync(this).Result;
            }
        }

        [Ignore]
        public List<Session> Sessions {
            get {
                return ObjectManager.GetAccountSessionsAsync(this).Result;
            }
        }

        public override System.Threading.Tasks.Task Delete() {
            foreach (Team team in Teams)
                team.Delete();

            foreach (Session session in Sessions)
                session.Delete();

            foreach (Token token in Tokens)
                token.Delete();

            return base.Delete();
        }
    }

    [Table("Access_Tokens")]
    public class Token : ModelObject {
        [Indexed]
        public int AccountID { get; set; }

        [Ignore]
        public Account Account {
            get {
                return ObjectManager.GetTokenAccountAsync(this).Result;
            }
        }

        public DateTime Created { get; set; }

        public DateTime Until { get; set; }

        public DateTime Used { get; set; } = DateTime.MinValue;

        public bool IsValid() {
            if ((Used != null) && (DateTime.Now < Used + new TimeSpan(0, 5, 0)))
                return true;
            else
                return DateTime.Now < Until;
        }

        public int GetRemainingMinutes() {
            int usedMinutes = (int)(DateTime.Now - Created).TotalMinutes;

            return (7 * 24 * 60) - usedMinutes;
        }
    }
}