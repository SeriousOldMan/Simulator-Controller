using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Task {

    [Table("Task_Tasks")]
    public class Task : ModelObject {
        public enum Type : int { Token = 1, Session = 2, Account = 3 };

        public enum Operation : int { Delete = 1, Cleanup = 2, Reset = 3, Renew = 4 };

        public enum Frequency : int { Daily = 1, Weekly = 2, Monthly = 3 };

        public bool Active { get; set; } = true;

        public Type Which { get; set; } = Type.Token;

        public Operation What { get; set; } = Operation.Delete;

        public Frequency When { get; set; } = Frequency.Daily;

        public DateTime Next { get; set; } = DateTime.MinValue;
    }
}