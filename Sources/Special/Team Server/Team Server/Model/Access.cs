using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Access {
    [Table("Access_Accounts")]
    public class Account : ModelObject {
        public enum ContractType : int { Expired = 0, OneTime = 1, FixedMinutes = 2, AdditionalMinutes = 3 };

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
        public List<SessionToken> SessionTokens
        {
            get {
                return ObjectManager.GetAccountSessionTokensAsync(this).Result;
            }
        }

        [Ignore]
        public StoreToken StoreToken
        {
            get {
                return ObjectManager.GetAccountStoreTokenAsync(this).Result;
            }
        }

        [Ignore]
        public List<Team> Teams {
            get {
                return ObjectManager.GetAccountTeamsAsync(this).Result;
            }
        }

        [Ignore]
        public List<Session> Sessions
        {
            get {
                return ObjectManager.GetAccountSessionsAsync(this).Result;
            }
        }

        [Ignore]
        public List<Store.StoreData> Data
        {
            get {
                return ObjectManager.GetAccountStoreDataAsync(this).Result;
            }
        }

        public override System.Threading.Tasks.Task Delete() {
            foreach (Team team in Teams)
                team.Delete();

            foreach (Session session in Sessions)
                session.Delete();

            ObjectManager.DoAccountTokensAsync(this, (Token token) => token.Delete());

            ObjectManager.DoAccountStoreDataAsync(this, (Store.StoreData data) => data.Delete());

            return base.Delete();
        }
    }

    public abstract class Token : ModelObject
    {
        [Indexed]
        public int AccountID { get; set; }

        [Ignore]
        public Account Account
        {
            get {
                return ObjectManager.GetTokenAccountAsync(this).Result;
            }
        }

        public DateTime Created { get; set; }

        public DateTime Until { get; set; }

        public DateTime Used { get; set; } = DateTime.MinValue;

        public virtual bool IsValid()
        {
            return (Until == null) || (DateTime.Now < Until);
        }

        public virtual int GetRemainingMinutes()
        {
            return 0;
        }
    }

    [Table("Session_Tokens")]
    public class SessionToken : Token
    {
        public virtual bool IsValid() {
            if (base.IsValid())
                return true;
            else {
                if (Used != null)
                    return (DateTime.Now < Used + new TimeSpan(0, 5, 0));
                else
                    return false;
            }
        }

        public virtual int GetRemainingMinutes() {
            int usedMinutes = (int)(DateTime.Now - Created).TotalMinutes;

            return (7 * 24 * 60) - usedMinutes;
        }
    }

    [Table("Store_Tokens")]
    public class StoreToken : Token
    {
    }

    public class AdminToken : Token { }
}