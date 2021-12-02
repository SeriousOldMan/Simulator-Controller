using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Task {

    [Table("Task_Tasks")]
    public class Task : ModelObject {
        public enum Period : int { Daily = 1, Weekly = 2, Monthly = 3 };

        public enum Type : int { Cleanup = 1, Renewal = 2 };

        [Unique]
        public string Name { get; set; }

        public bool Active { get; set; } = false;

        public Period When { get; set; } = Period.Daily;

        public Type What { get; set; } = Type.Cleanup;

        public DateTime Next { get; set; } = DateTime.MinValue;
    }
}