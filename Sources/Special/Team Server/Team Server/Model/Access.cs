using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Access {
    [Table("Access_Accounts")]
    public class Account : ModelObject {
        public enum ContractType : int { Expired = 0, OneTime = 1, FixedMinutes = 2, AdditionalMinutes = 3, Unlimited = 4 };

        [Unique]
        public string Name { get; set; }

        public string EMail { get; set; }

        public string Password { get; set; }

        public bool Virgin { get; set; } = true;

        public bool Administrator { get; set; } = false;

        public int AvailableMinutes { get; set; }

        public bool DataAccess { get; set; } = false;

        public bool SessionAccess { get; set; } = false;

        public ContractType Contract { get; set; } = ContractType.OneTime;

        public int ContractMinutes { get; set; } = 0;

        [Ignore]
        public List<Token> Tokens
        {
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
        public List<Session> Sessions
        {
            get {
                return ObjectManager.GetAccountSessionsAsync(this).Result;
            }
        }

        [Ignore]
        public List<Data.DataObject> Data
        {
            get {
                return ObjectManager.GetAccountDataAsync(this).Result;
            }
        }

        public override System.Threading.Tasks.Task Delete() {
            foreach (Team team in Teams)
                team.Delete();

            foreach (Session session in Sessions)
                session.Delete();

            ObjectManager.DoAccountTokensAsync(this, (Token token) => token.Delete());

            ObjectManager.DoAccountDataAsync(this, (Data.DataObject data) => data.Delete());

            return base.Delete();
        }
    }

    [Table("Token")]
    public class Token : ModelObject
    {
        public enum TokenType
        {
            Invalid = 0,
            Internal = 1,
            Account = 2,
            Session = 3,
            Data = 4
        }

        [Indexed]
        public int AccountID { get; set; }

        [Ignore]
        public Account Account
        {
            get {
                return ObjectManager.GetTokenAccountAsync(this).Result;
            }
        }

        [Ignore]
        public List<Connection> Connections
        {
            get {
                return ObjectManager.GetTokenConnectionsAsync(this).Result;
            }
        }

        public TokenType Type { get; set; } = TokenType.Invalid;

        public DateTime Created { get; set; }

        public DateTime Until { get; set; }

        public DateTime Used { get; set; } = DateTime.MinValue;

        public bool IsValid()
        {
            return Type != TokenType.Invalid || Until == null || DateTime.Now < Until || DateTime.Now < Used + new TimeSpan(0, 5, 0);
        }

        public bool HasAccess(TokenType type)
        {
            switch (type)
            {
                case TokenType.Session:
                    return Type == TokenType.Session || Type == TokenType.Account || Type == TokenType.Internal;
                case TokenType.Data:
                    return Type == TokenType.Data || Type == TokenType.Account || Type == TokenType.Internal;
                case TokenType.Account:
                    return Type == TokenType.Account || Type == TokenType.Internal;
                case TokenType.Internal:
                    return Type == TokenType.Internal;
                default:
                    return false;
            }
        }

        public override System.Threading.Tasks.Task Delete()
        {
            foreach (Connection connection in Connections)
                connection.Delete();

            return base.Delete();
        }
    }

    public class InternalToken : Token { }

    [Table("Access_Connections")]
    public class Connection : ModelObject
    {
        public enum ConnectionType
        {
            Unknown = 0,
            Internal = 1,
            Admin = 2,
            Manager = 3,
            Driver = 4
        }

        [Indexed]
        public int TokenID { get; set; }

        [Indexed]
        public int SessionID { get; set; }

        [Ignore]
        public Token Token
        {
            get {
                return ObjectManager.GetTokenAsync(this.TokenID).Result;
            }
        }

        [Ignore]
        public Session Session
        {
            get {
                return ObjectManager.GetSessionAsync(this.SessionID).Result;
            }
        }

        public ConnectionType Type { get; set; }

        public string Client { get; set; }

        public string Name { get; set; }

        public DateTime Created { get; set; }

        public DateTime Valid { get; set; } = DateTime.MinValue;

        public void Renew()
        {
            Valid = DateTime.Now + TimeSpan.FromSeconds(Server.TeamServer.Instance.ConnectionLifeTime);

            Save();
        }

        public bool IsConnected()
        {
            return (DateTime.Now <= Valid);
        }
    }
}