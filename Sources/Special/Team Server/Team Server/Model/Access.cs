using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Access {
    [Table("Access_Tokens")]
    public class Token : ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        public Guid GUID { get; set; }

        public string Password { get; set; }

        public int TimeLeft { get; set; }

        [Ignore]
        public Task<List<Session>> Sessions {
            get {
                return ObjectManager.GetTokenSessionsAsync(this);
            }
        }
    }
}