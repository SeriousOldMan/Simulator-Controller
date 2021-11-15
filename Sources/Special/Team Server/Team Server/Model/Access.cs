using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Access {
    [Table("Access_Accounts")]
    public class Account : ModelObject {
        [Indexed]
        public string Name { get; set; }

        public string Password { get; set; }

        public int MinutesLeft { get; set; }

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

        public override Task Delete() {
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

        public bool IsValid() {
            return (DateTime.Now < (Created + new TimeSpan(7, 0, 0, 0)));
        }
    }
}