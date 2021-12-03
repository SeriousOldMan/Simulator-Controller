using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class AccountManager : ManagerBase {
        public AccountManager(ObjectManager objectManager, Token token) : base(objectManager, token) {
        }

        public string CreatePassword(int length) {
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";

            StringBuilder result = new StringBuilder();
            Random random = new Random();
            
            while (0 < length--)
                result.Append(valid[random.Next(valid.Length)]);
            
            return result.ToString();
        }

        #region Validation
        public void ValidateAccount(Account account) {
            if (account == null)
                throw new Exception("Not a valid account...");
        }
        #endregion

        #region Account
        #region Query
        public List<Account> GetAllAccounts() {
            return TeamServer.ObjectManager.Connection.QueryAsync<Account>(
                @"
                    Select * From Access_Accounts
                ").Result;
        }

        public Account FindAccount(Guid identifier) {
            return ObjectManager.GetAccountAsync(identifier).Result;
        }

        public Account FindAccount(string identifier) {
            Task<Account> finder = ObjectManager.GetAccountAsync(identifier);
            Account account;

            try {
                account = FindAccount(new Guid(identifier));
            }
            catch {
                account = null;
            }

            return account ?? finder.Result;
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
            return FindAccount(identifier) ?? LookupAccount(new Guid(identifier));
        }

        public Account LookupAccount(string name, string password) {
            Account account = FindAccount(name, password);

            ValidateAccount(account);

            return account;
        }
        #endregion

        #region CRUD
        public Account CreateAccount(string name, string eMail = "", string password = null, int initialMinutes = 0,
                                     Account.ContractType contract = Account.ContractType.OneTime, int renewalMinutes = 0) {
            if (FindAccount(name) == null) {
                bool virgin = false;

                if (password == null) {
                    password = CreatePassword(20);

                    virgin = true;
                }

                Account account = new Account {
                    Name = name, EMail = eMail, Password = password, Virgin = virgin, AvailableMinutes = initialMinutes,
                    Contract = contract, ContractMinutes = renewalMinutes
                };

                account.Save();

                return account;
            }
            else
                throw new Exception("Duplicate account name...");
        }

        public void ChangePassword(Account account, string password) {
            ValidateAccount(account);

            account.Password = password;
            account.Virgin = false;

            account.Save().Wait();
        }

        public void ChangeContract(Account account, Account.ContractType contract, int renewalMinutes) {
            ValidateAccount(account);

            account.Contract = contract;
            account.ContractMinutes = renewalMinutes;

            account.Save().Wait();
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

            account.AvailableMinutes = minutes;

            account.Save();
        }

        public void SetMinutes(string account, string password, int minutes) {
            SetMinutes(ObjectManager.GetAccountAsync(account, password).Result, minutes);
        }

        public void AddMinutes(Account account, int minutes) {
            ValidateAccount(account);

            account.AvailableMinutes += minutes;

            account.Save();
        }

        public void AddMinutes(string account, string password, int minutes) {
            AddMinutes(ObjectManager.GetAccountAsync(account, password).Result, minutes);
        }

        public async void RenewAccountsAsync() {
            TeamServer.TokenIssuer.ElevateToken(Token);

            await ObjectManager.Connection.QueryAsync<Account>(
                @"
                    Select * From Access_Accounts
                ").ContinueWith(t => t.Result.ForEach(a => {
                    if (a.Contract == Account.ContractType.Expired)
                        a.Delete();
                    else if ((a.Contract == Account.ContractType.OneTime) && (a.AvailableMinutes <= 0))
                        a.Delete();
                    else if (a.Contract == Account.ContractType.FixedMinutes)
                        SetMinutes(a, a.ContractMinutes);
                    else if (a.Contract == Account.ContractType.AdditionalMinutes)
                        AddMinutes(a, a.ContractMinutes);
                }));
        }
        #endregion
        #endregion
    }
}
