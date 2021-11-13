using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Access {
    [Table("Access_Contracts")]
    public class Contract : ModelObject {
        public string Account { get; set; }

        public string Password { get; set; }

        public int MinutesLeft { get; set; }

        [Ignore]
        public List<Token> Tokens {
            get {
                return ObjectManager.GetContractTokensAsync(this).Result;
            }
        }

        public override Task Delete() {
            foreach (Token token in Tokens)
                token.Delete();

            return base.Delete();
        }
    }

    [Table("Access_Tokens")]
    public class Token : ModelObject {
        public Guid Identifier { get; set; }

        public DateTime Created { get; set; }

        public int ContractID { get; set; }

        [Ignore]
        public Contract Contract {
            get {
                return ObjectManager.GetTokenContractAsync(this).Result;
            }
        }

        public bool IsValid() {
            return (DateTime.Now < (Created + new TimeSpan(7, 0, 0, 0)));
        }
    }
}