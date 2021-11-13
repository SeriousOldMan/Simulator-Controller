using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class ContractManager : ManagerBase {
        public ContractManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        public Contract CreateContract(string account, string password, int minutes) {
            Contract contract = new Contract { Account = account, Password = password, MinutesLeft = minutes };

            contract.Save();

            return contract;
        }

        public void DeleteContract(Contract contract) {
            ValidateContract(contract);

            contract.Delete();
        }

        public void DeleteContract(string account, string password) {
            DeleteContract(ObjectManager.GetContractAsync(account, password).Result);
        }

        public void AddMinutes(Contract contract, int minutes) {
            ValidateContract(contract);

            contract.MinutesLeft += minutes;

            contract.Save();
        }

        public void AddMinutes(string account, string password, int minutes) {
            AddMinutes(ObjectManager.GetContractAsync(account, password).Result, minutes);
        }
    }
}
