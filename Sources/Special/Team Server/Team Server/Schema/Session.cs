namespace TeamServer.Schema {
    public class Session {
        public int SessionId {
            get;
            set;
        }

        public int TeamId {
            get;
            set;
        }

        public string Track {
            get;
            set;
        }

        public string Car {
            get;
            set;
        }

        public string GridNr {
            get;
            set;
        }
    }

    public class Stint {
        public int StintId {
            get;
            set;
        }

        public int SessionId {
            get;
            set;
        }

        public int DriverId {
            get;
            set;
        }

        public int Nr {
            get;
            set;
        }
    }

    public class Lap {
        public int LapId {
            get;
            set;
        }

        public int StintId {
            get;
            set;
        }

        public int Nr {
            get;
            set;
        }

        public string TelemetryData {
            get;
            set;
        }
        public string CarData {
            get;
            set;
        }
    }
}