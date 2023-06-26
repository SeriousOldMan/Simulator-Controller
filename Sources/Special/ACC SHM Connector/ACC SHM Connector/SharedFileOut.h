#pragma once

enum class PenaltyShortcut : int {
    None,
    DriveThrough_Cutting,
    StopAndGo_10_Cutting,
    StopAndGo_20_Cutting,
    StopAndGo_30_Cutting,
    Disqualified_Cutting,
    RemoveBestLaptime_Cutting,

    DriveThrough_PitSpeeding,
    StopAndGo_10_PitSpeeding,
    StopAndGo_20_PitSpeeding,
    StopAndGo_30_PitSpeeding,
    Disqualified_PitSpeeding,
    RemoveBestLaptime_PitSpeeding,

    Disqualified_IgnoredMandatoryPit,

    PostRaceTime,
    Disqualified_Trolling,
    Disqualified_PitEntry,
    Disqualified_PitExit,
    Disqualified_WrongWay,

    DriveThrough_IgnoredDriverStint,
    Disqualified_IgnoredDriverStint,

    Disqualified_ExceededDriverStintLimit,
};

typedef int AC_STATUS;

#define AC_OFF 0
#define AC_REPLAY 1
#define AC_LIVE 2
#define AC_PAUSE 3

typedef int AC_SESSION_TYPE;

#define AC_UNKNOWN -1
#define AC_PRACTICE 0
#define AC_QUALIFY 1
#define AC_RACE 2
#define AC_HOTLAP 3
#define AC_TIME_ATTACK 4
#define AC_DRIFT 5
#define AC_DRAG 6
#define AC_HOTSTINT 7
#define AC_HOTLAPSUPERPOLE 8

typedef int AC_FLAG_TYPE;

#define AC_NO_FLAG 0
#define AC_BLUE_FLAG 1
#define AC_YELLOW_FLAG 2
#define AC_BLACK_FLAG 3
#define AC_WHITE_FLAG 4
#define AC_CHECKERED_FLAG 5
#define AC_PENALTY_FLAG 6

typedef int ACC_TRACK_GRIP_STATUS;

#define ACC_GREEN 0
#define ACC_FAST 1
#define ACC_OPTIMUM 2
#define ACC_GREASY 3
#define ACC_DAMP 4
#define ACC_WET 5
#define ACC_FLOODED 6

typedef int ACC_RAIN_INTENSITY;

#define ACC_NO_RAIN 0
#define ACC_DRIZZLE 1
#define ACC_LIGHT_RAIN 2
#define ACC_MEDIUM_RAIN 3
#define ACC_HEAVY_RAIN 4
#define ACC_THUNDERSTORM 5



#pragma pack(push)
#pragma pack(4)

struct SPageFilePhysics
{

    int packetId = 0;
    float gas = 0;
    float brake = 0;
    float fuel = 0;
    int gear = 0;
    int rpms = 0;
    float steerAngle = 0;
    float speedKmh = 0;
    float velocity[3];
    float accG[3];
    float wheelSlip[4];
    float wheelLoad[4];
    float wheelsPressure[4];
    float wheelAngularSpeed[4];
    float tyreWear[4];
    float tyreDirtyLevel[4];
    float tyreCoreTemperature[4];
    float camberRAD[4];
    float suspensionTravel[4];
    float drs = 0;
    float tc = 0;
    float heading = 0;
    float pitch = 0;
    float roll = 0;
    float cgHeight;
    float carDamage[5];
    int numberOfTyresOut = 0;
    int pitLimiterOn = 0;
    float abs = 0;
    float kersCharge = 0;
    float kersInput = 0;
    int autoShifterOn = 0;
    float rideHeight[2];
    float turboBoost = 0;
    float ballast = 0;
    float airDensity = 0;
    float airTemp = 0;
    float roadTemp = 0;
    float localAngularVel[3];
    float finalFF = 0;
    float performanceMeter = 0;

    int engineBrake = 0;
    int ersRecoveryLevel = 0;
    int ersPowerLevel = 0;
    int ersHeatCharging = 0;
    int ersIsCharging = 0;
    float kersCurrentKJ = 0;

    int drsAvailable = 0;
    int drsEnabled = 0;

    float brakeTemp[4];
    float clutch = 0;

    float tyreTempI[4];
    float tyreTempM[4];
    float tyreTempO[4];

    int isAIControlled;

    float tyreContactPoint[4][3];
    float tyreContactNormal[4][3];
    float tyreContactHeading[4][3];

    float brakeBias = 0;

    float localVelocity[3];

    int P2PActivations = 0;
    int P2PStatus = 0;

    int currentMaxRpm = 0;

    float mz[4];
    float fx[4];
    float fy[4];
    float slipRatio[4];
    float slipAngle[4];


    int tcinAction = 0;
    int absInAction = 0;
    float suspensionDamage[4];
    float tyreTemp[4];

    float waterTemp = 0;
    float brakePressure[4];
    int frontBrakeCompound = 0;
    int rearBrakeCompound = 0;
    float padLife[4];
    float discLife[4];

    int ignitionOn = 0;
    int starterEngineOn = 0;
    int isEngineRunning = 0;
    float kerbVibration = 0;
    float slipVibrations = 0;
    float gVibrations = 0;
    float absVibrations = 0;
};


struct SPageFileGraphic
{
    int packetId = 0;
    AC_STATUS status = AC_OFF;
    AC_SESSION_TYPE session = AC_PRACTICE;
    wchar_t currentTime[15];
    wchar_t lastTime[15];
    wchar_t bestTime[15];
    wchar_t split[15];
    int completedLaps = 0;
    int position = 0;
    int iCurrentTime = 0;
    int iLastTime = 0;
    int iBestTime = 0;
    float sessionTimeLeft = 0;
    float distanceTraveled = 0;
    int isInPit = 0;
    int currentSectorIndex = 0;
    int lastSectorTime = 0;
    int numberOfLaps = 0;
    wchar_t tyreCompound[33];
    float replayTimeMultiplier = 0;
    float normalizedCarPosition = 0;

    int activeCars = 0;
    float carCoordinates[60][3];
    int carID[60];
    int playerCarID = 0;
    float penaltyTime = 0;
    AC_FLAG_TYPE flag = AC_NO_FLAG;
    PenaltyShortcut penalty = PenaltyShortcut::None;
    int idealLineOn = 0;
    int isInPitLane = 0;

    float surfaceGrip = 0;
    int mandatoryPitDone = 0;

    float windSpeed = 0;
    float windDirection = 0;


    int isSetupMenuVisible = 0;

    int mainDisplayIndex = 0;
    int secondaryDisplayIndex = 0;
    int TC = 0;
    int TCCut = 0;
    int EngineMap = 0;
    int ABS = 0;
    int fuelXLap = 0;
    int rainLights = 0;
    int flashingLights = 0;
    int lightsStage = 0;
    float exhaustTemperature = 0.0f;
    int wiperLV = 0;
    int DriverStintTotalTimeLeft = 0;
    int DriverStintTimeLeft = 0;
    int rainTyres = 0;

    int sessionIndex = 0;
    float usedFuel = 0;
    wchar_t deltaLapTime[15];
    int iDeltaLapTime = 0;
    wchar_t estimatedLapTime[15];
    int iEstimatedLapTime = 0;
    int isDeltaPositive = 0;
    int iSplit = 0;
    int isValidLap = 0;
    float fuelEstimatedLaps = 0;
    wchar_t trackStatus[33]; // Map this
    int missingMandatoryPits = 0;
    float Clock = 0;
    int directionLightsLeft = 0;
    int directionLightsRight = 0;

    int GlobalYellow = 0;
    int GlobalYellow1 = 0;
    int GlobalYellow2 = 0;
    int GlobalYellow3 = 0;
    int GlobalWhite = 0;
    int GlobalGreen = 0;
    int GlobalChequered = 0;
    int GlobalRed = 0;

    int mfdTyreSet = 0; // Map this
    float mfdFuelToAdd = 0; // Map this
    float mfdTyrePressureFL = 0; // Map this
    float mfdTyrePressureFR = 0; // Map this
    float mfdTyrePressureRL = 0; // Map this
    float mfdTyrePressureRR = 0; // Map this

    ACC_TRACK_GRIP_STATUS trackGripStatus = 0; // Map this
    ACC_RAIN_INTENSITY rainIntensity = 0; // Map this
    ACC_RAIN_INTENSITY rainIntensityIn10min = 0; // Map this
    ACC_RAIN_INTENSITY rainIntensityIn30min = 0; // Map this

    int currentTyreSet = 0;
    int strategyTyreSet = 0;

    int gapAhead = 0;
    int gapBehind = 0;
};


struct SPageFileStatic
{
    wchar_t smVersion[15];
    wchar_t acVersion[15];

    // session static info
    int numberOfSessions = 0;
    int numCars = 0;
    wchar_t carModel[33];
    wchar_t track[33];
    wchar_t playerName[33];
    wchar_t playerSurname[33];
    wchar_t playerNick[33];
    int sectorCount = 0;

    // car static info
    float maxTorque = 0;
    float maxPower = 0;
    int	maxRpm = 0;
    float maxFuel = 0;
    float suspensionMaxTravel[4];
    float tyreRadius[4];
    float maxTurboBoost = 0;

    float deprecated_1 = -273;
    float deprecated_2 = -273;

    int penaltiesEnabled = 0;

    float aidFuelRate = 0;
    float aidTireRate = 0;
    float aidMechanicalDamage = 0;
    int aidAllowTyreBlankets = 0;
    float aidStability = 0;
    int aidAutoClutch = 0;
    int aidAutoBlip = 0;

    int hasDRS = 0;
    int hasERS = 0;
    int hasKERS = 0;
    float kersMaxJ = 0;
    int engineBrakeSettingsCount = 0;
    int ersPowerControllerCount = 0;
    float trackSPlineLength = 0;
    wchar_t trackConfiguration[33];
    float ersMaxJ = 0;

    int isTimedRace = 0;
    int hasExtraLap = 0;

    wchar_t carSkin[33];
    int reversedGridPositions = 0;
    int PitWindowStart = 0;
    int PitWindowEnd = 0;
    int isOnline = 0;

    wchar_t dryTyresName[33];
    wchar_t wetTyresName[33];
};


#pragma pack(pop)
