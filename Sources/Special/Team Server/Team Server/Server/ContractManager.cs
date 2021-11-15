using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class AccountManager : ManagerBase {
        public AccountManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        #region Account
        #region CRUD
        public Account CreateAccount(string name, string password, int minutes) {
            Account account = new Account { Name = name, Password = password, MinutesLeft = minutes };

            account.Save();

            return account;
        }

        public void DeleteAccount(Account account) {
            ValidateAccount(account);

            account.Delete();
        }

        public void DeleteAccount(string account, string password) {
            DeleteAccount(ObjectManager.GetAccountAsync(account, password).Result);
        }
        #endregion

        #region Operations
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
