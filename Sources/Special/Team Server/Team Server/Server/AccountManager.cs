using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class AccountManager : ManagerBase {
        public AccountManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        public string CreatePassword(int length) {
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";

            StringBuilder result = new StringBuilder();
            Random random = new Random();
            
            while (0 < length--)
                result.Append(valid[random.Next(valid.Length)]);
            
            return result.ToString();
        }

        #region Account
        #region Query
        public List<Account> GetAllAccounts() {
            return TeamServer.ObjectManager.Connection.QueryAsync<Account>(
                @"
                    Select * From Accounts
                ").Result;
        }

        public Account FindAccount(Guid identifier) {
            return ObjectManager.GetAccountAsync(identifier).Result;
        }

        public Account FindAccount(string identifier) {
            Task<Account> task = ObjectManager.GetAccountAsync(identifier);
            Account Account;

            try {
                Account = FindAccount(new Guid(identifier));
            }
            catch {
                Account = null;
            }

            return Account ?? task.Result;
        }

        public Account FindAccount(string name, string password) {
            return ObjectManager.GetAccountAsync(name, password).Result;
        }

        public Account LookupAccount(Guid identifier) {
            Account account = FindAccount(identifier);

            ValidateAccount(account);

            return account;
        }

        public Account LookupAccount(string identifier) {
            Account account = FindAccount(identifier);

            return account ?? LookupAccount(new Guid(identifier));
        }

        public Account LookupAccount(string name, string password) {
            Account account = FindAccount(name, password);

            ValidateAccount(account);

            return account;
        }
        #endregion

        #region CRUD
        public Account CreateAccount(string name) {
            string password = CreatePassword(20);

            Account account = new Account { Name = name, Password = password, MinutesLeft = 0 };

            account.Save();

            return account;
        }

        public Account CreateAccount(string name, string password, int minutes) {
            Account account = new Account { Name = name, Password = password, MinutesLeft = minutes, Virgin = false };

            account.Save();

            return account;
        }

        public void DeleteAccount(Account account) {
            ValidateAccount(account);

            account.Delete();
        }

        public void DeleteAccount(Guid identifier) {
            DeleteAccount(LookupAccount(identifier));
        }

        public void DeleteAccount(string account, string password) {
            DeleteAccount(LookupAccount(account, password));
        }

        public void DeleteAccount(string identifier) {
            DeleteAccount(LookupAccount(identifier));
        }
        #endregion

        #region Operations
        public void SetMinutes(Account account, int minutes) {
            ValidateAccount(account);

            account.MinutesLeft = minutes;

            account.Save();
        }

        public void SetMinutes(string account, string password, int minutes) {
            AddMinutes(ObjectManager.GetAccountAsync(account, password).Result, minutes);
        }

        public void AddMinutes(Account account, int minutes) {
            ValidateAccount(account);

            account.MinutesLeft += minutes;

            account.Save();
        }

        public void AddMinutes(string account, string password, int minutes) {
            AddMinutes(ObjectManager.GetAccountAsync(account, password).Result, minutes);
        }
        #endregion
        #endregion
    }
}
