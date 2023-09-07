/*************************************************************************************************
  Description: 
    Storage structure for storing and updating shared memory

    Copyright (c) MWL. All rights reserved.
*************************************************************************************************/

#ifndef _SHARED_MEMORY_HPP_
#define _SHARED_MEMORY_HPP_

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NOTES:
// 
//  -The shared memory variables will be updated once per graphics frame.
//
//  -Each variable comes with a UNIT, RANGE, and UNSET description where applicable.
//     UNITS - Is the numeric form which a variable is stored in (e.g. KPH, Celsius)
//     RANGE - Is the min-max ranges for a variable
//     UNSET - Is the initialised/default/invalid value, depending on the variables usage
//
//  -Constant/unchanging values are included in the data, such as 'maxRPM', 'fuelCapacity' - this is done to allow percentage calculations.
//
//  -Also included are 12 unique enumerated types, to be used against the mentioned flag/state variables
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// *** Types ***

// Header version number to test against
enum
{
  SHARED_MEMORY_VERSION = 13
};

// Maximum allowed length of string
enum
{
  STRING_LENGTH_MAX = 64
};

// Maximum number of general participant information allowed to be stored in memory-mapped file
enum
{
  STORED_PARTICIPANTS_MAX = 64
};

// Maximum length of a tyre compound name
enum
{
 TYRE_COMPOUND_NAME_LENGTH_MAX = 40
};

// Tyres
enum 
{
  TYRE_FRONT_LEFT = 0,
  TYRE_FRONT_RIGHT,
  TYRE_REAR_LEFT,
  TYRE_REAR_RIGHT,
  //--------------
  TYRE_MAX
};

// Vector
enum
{
  VEC_X = 0,
  VEC_Y,
  VEC_Z,
  //-------------
  VEC_MAX
};

// (Type#1) GameState (to be used with 'mGameState')
enum
{
  GAME_EXITED = 0,
  GAME_FRONT_END,
  GAME_INGAME_PLAYING,
  GAME_INGAME_PAUSED,
	GAME_INGAME_INMENU_TIME_TICKING,
  GAME_INGAME_RESTARTING,
  GAME_INGAME_REPLAY,
  GAME_FRONT_END_REPLAY,
  //-------------
  GAME_MAX
};

// (Type#2) Session state (to be used with 'mSessionState')
enum
{
  SESSION_INVALID = 0,
  SESSION_PRACTICE,
  SESSION_TEST,
  SESSION_QUALIFY,
  SESSION_FORMATION_LAP,
  SESSION_RACE,
  SESSION_TIME_ATTACK,
  //-------------
  SESSION_MAX
};

// (Type#3) RaceState (to be used with 'mRaceState' and 'mRaceStates')
enum
{
  RACESTATE_INVALID,
  RACESTATE_NOT_STARTED,
  RACESTATE_RACING,
  RACESTATE_FINISHED,
  RACESTATE_DISQUALIFIED,
  RACESTATE_RETIRED,
  RACESTATE_DNF,
  //-------------
  RACESTATE_MAX
};

// (Type#5) Flag Colours (to be used with 'mHighestFlagColour')
enum
{
  FLAG_COLOUR_NONE = 0,             // Not used for actual flags, only for some query functions
  FLAG_COLOUR_GREEN,                // End of danger zone, or race started
  FLAG_COLOUR_BLUE,                 // Faster car wants to overtake the participant
  FLAG_COLOUR_WHITE_SLOW_CAR,       // Slow car in area
  FLAG_COLOUR_WHITE_FINAL_LAP,      // Final Lap
  FLAG_COLOUR_RED,                  // Huge collisions where one or more cars become wrecked and block the track
  FLAG_COLOUR_YELLOW,               // Danger on the racing surface itself
  FLAG_COLOUR_DOUBLE_YELLOW,        // Danger that wholly or partly blocks the racing surface
  FLAG_COLOUR_BLACK_AND_WHITE,      // Unsportsmanlike conduct
  FLAG_COLOUR_BLACK_ORANGE_CIRCLE,  // Mechanical Failure
  FLAG_COLOUR_BLACK,                // Participant disqualified
  FLAG_COLOUR_CHEQUERED,            // Chequered flag
  //-------------
  FLAG_COLOUR_MAX
};

// (Type#6) Flag Reason (to be used with 'mHighestFlagReason')
enum
{
  FLAG_REASON_NONE = 0,
  FLAG_REASON_SOLO_CRASH,
  FLAG_REASON_VEHICLE_CRASH,
  FLAG_REASON_VEHICLE_OBSTRUCTION,
  //-------------
  FLAG_REASON_MAX
};

// (Type#7) Pit Mode (to be used with 'mPitMode')
enum
{
  PIT_MODE_NONE = 0,
  PIT_MODE_DRIVING_INTO_PITS,
  PIT_MODE_IN_PIT,
  PIT_MODE_DRIVING_OUT_OF_PITS,
  PIT_MODE_IN_GARAGE,
  PIT_MODE_DRIVING_OUT_OF_GARAGE,
  //-------------
  PIT_MODE_MAX
};

// (Type#8) Pit Stop Schedule (to be used with 'mPitSchedule')
enum
{
  PIT_SCHEDULE_NONE = 0,            // Nothing scheduled
  PIT_SCHEDULE_PLAYER_REQUESTED,    // Used for standard pit sequence - requested by player
  PIT_SCHEDULE_ENGINEER_REQUESTED,  // Used for standard pit sequence - requested by engineer
  PIT_SCHEDULE_DAMAGE_REQUESTED,    // Used for standard pit sequence - requested by engineer for damage
  PIT_SCHEDULE_MANDATORY,           // Used for standard pit sequence - requested by engineer from career enforced lap number
  PIT_SCHEDULE_DRIVE_THROUGH,       // Used for drive-through penalty
  PIT_SCHEDULE_STOP_GO,             // Used for stop-go penalty
  PIT_SCHEDULE_PITSPOT_OCCUPIED,    // Used for drive-through when pitspot is occupied
  //-------------
  PIT_SCHEDULE_MAX
};

// (Type#9) Car Flags (to be used with 'mCarFlags')
enum CarFlags
{
  CAR_HEADLIGHT         = (1<<0),
  CAR_ENGINE_ACTIVE     = (1<<1),
  CAR_ENGINE_WARNING    = (1<<2),
  CAR_SPEED_LIMITER     = (1<<3),
  CAR_ABS               = (1<<4),
  CAR_HANDBRAKE         = (1<<5),
  CAR_TCS               = (1<<6),
  CAR_SCS               = (1<<7),
};

// (Type#10) Tyre Flags (to be used with 'mTyreFlags')
enum
{
  TYRE_ATTACHED         = (1<<0),
  TYRE_INFLATED         = (1<<1),
  TYRE_IS_ON_GROUND     = (1<<2),
};

// (Type#11) Terrain Materials (to be used with 'mTerrain')
enum
{
  TERRAIN_ROAD = 0,
  TERRAIN_LOW_GRIP_ROAD,
  TERRAIN_BUMPY_ROAD1,
  TERRAIN_BUMPY_ROAD2,
  TERRAIN_BUMPY_ROAD3,
  TERRAIN_MARBLES,
  TERRAIN_GRASSY_BERMS,
  TERRAIN_GRASS,
  TERRAIN_GRAVEL,
  TERRAIN_BUMPY_GRAVEL,
  TERRAIN_RUMBLE_STRIPS,
  TERRAIN_DRAINS,
  TERRAIN_TYREWALLS,
  TERRAIN_CEMENTWALLS,
  TERRAIN_GUARDRAILS,
  TERRAIN_SAND,
  TERRAIN_BUMPY_SAND,
  TERRAIN_DIRT,
  TERRAIN_BUMPY_DIRT,
  TERRAIN_DIRT_ROAD,
  TERRAIN_BUMPY_DIRT_ROAD,
  TERRAIN_PAVEMENT,
  TERRAIN_DIRT_BANK,
  TERRAIN_WOOD,
  TERRAIN_DRY_VERGE,
  TERRAIN_EXIT_RUMBLE_STRIPS,
  TERRAIN_GRASSCRETE,
  TERRAIN_LONG_GRASS,
  TERRAIN_SLOPE_GRASS,
  TERRAIN_COBBLES,
  TERRAIN_SAND_ROAD,
  TERRAIN_BAKED_CLAY,
  TERRAIN_ASTROTURF,
  TERRAIN_SNOWHALF,
  TERRAIN_SNOWFULL,
  TERRAIN_DAMAGED_ROAD1,
  TERRAIN_TRAIN_TRACK_ROAD,
  TERRAIN_BUMPYCOBBLES,
  TERRAIN_ARIES_ONLY,
  TERRAIN_ORION_ONLY,
  TERRAIN_B1RUMBLES,
  TERRAIN_B2RUMBLES,
  TERRAIN_ROUGH_SAND_MEDIUM,
  TERRAIN_ROUGH_SAND_HEAVY,
  TERRAIN_SNOWWALLS,
  TERRAIN_ICE_ROAD,
  TERRAIN_RUNOFF_ROAD,
  TERRAIN_ILLEGAL_STRIP,
	TERRAIN_PAINT_CONCRETE,
	TERRAIN_PAINT_CONCRETE_ILLEGAL,
	TERRAIN_RALLY_TARMAC,

  //-------------
  TERRAIN_MAX
};

// (Type#12) Crash Damage State  (to be used with 'mCrashState')
enum
{
  CRASH_DAMAGE_NONE = 0,
  CRASH_DAMAGE_OFFTRACK,
  CRASH_DAMAGE_LARGE_PROP,
  CRASH_DAMAGE_SPINNING,
  CRASH_DAMAGE_ROLLING,
  //-------------
  CRASH_MAX
};

// (Type#13) ParticipantInfo struct  (to be used with 'mParticipantInfo')
typedef struct
{
  bool mIsActive;
  char mName[STRING_LENGTH_MAX];                   // [ string ]
  float mWorldPosition[VEC_MAX];                   // [ UNITS = World Space  X  Y  Z ]
  float mCurrentLapDistance;                       // [ UNITS = Metres ]   [ RANGE = 0.0f->... ]    [ UNSET = 0.0f ]
  unsigned int mRacePosition;                      // [ RANGE = 1->... ]   [ UNSET = 0 ]
  unsigned int mLapsCompleted;                     // [ RANGE = 0->... ]   [ UNSET = 0 ]
  unsigned int mCurrentLap;                        // [ RANGE = 0->... ]   [ UNSET = 0 ]
  int mCurrentSector;                              // [ RANGE = 0->... ]   [ UNSET = -1 ]
} ParticipantInfo;

// (Type#14) DrsState Flags (to be used with 'mDrsState')
enum DrsState
{
	DRS_INSTALLED       = (1<<0),  // Vehicle has DRS capability
	DRS_ZONE_RULES      = (1<<1),  // 1 if DRS uses F1 style rules
	DRS_AVAILABLE_NEXT  = (1<<2),  // detection zone was triggered (only applies to f1 style rules)
	DRS_AVAILABLE_NOW   = (1<<3),  // detection zone was triggered and we are now in the zone (only applies to f1 style rules)
	DRS_ACTIVE          = (1<<4),  // Wing is in activated state
};

// (Type#15) ErsDeploymentMode (to be used with 'mErsDeploymentMode')
enum ErsDeploymentMode
{
  ERS_DEPLOYMENT_MODE_NONE = 0, // The vehicle does not support deployment modes
	ERS_DEPLOYMENT_MODE_OFF, // Regen only, no deployment
	ERS_DEPLOYMENT_MODE_BUILD, // Heavy emphasis towards regen
	ERS_DEPLOYMENT_MODE_BALANCED, // Deployment map automatically adjusted to try and maintain target SoC
	ERS_DEPLOYMENT_MODE_ATTACK,  // More aggressive deployment, no target SoC
	ERS_DEPLOYMENT_MODE_QUAL, // Maximum deployment, no target Soc
};

// (Type#16) YellowFlagState represents current FCY state (to be used with 'mYellowFlagState')
enum YellowFlagState
{
	YFS_INVALID = -1,
	YFS_NONE,           // No yellow flag pending on track
	YFS_PENDING,        // Flag has been thrown, but not yet taken by leader
	YFS_PITS_CLOSED,    // Flag taken by leader, pits not yet open
	YFS_PIT_LEAD_LAP,   // Those on the lead lap may pit
	YFS_PITS_OPEN,      // Everyone may pit
	YFS_PITS_OPEN2,     // Everyone may pit
	YFS_LAST_LAP,       // On the last caution lap
	YFS_RESUME,         // About to restart (pace car will duck out)
	YFS_RACE_HALT,      // Safety car will lead field into pits
	//-------------
	YFS_MAXIMUM,
};

// *** Shared Memory ***

typedef struct
{
  // Version Number
  unsigned int mVersion;                           // [ RANGE = 0->... ]
  unsigned int mBuildVersionNumber;                // [ RANGE = 0->... ]   [ UNSET = 0 ]

  // Game States
  unsigned int mGameState;                         // [ enum (Type#1) Game state ]
  unsigned int mSessionState;                      // [ enum (Type#2) Session state ]
  unsigned int mRaceState;                         // [ enum (Type#3) Race State ]

  // Participant Info
  int mViewedParticipantIndex;                                  // [ RANGE = 0->STORED_PARTICIPANTS_MAX ]   [ UNSET = -1 ]
  int mNumParticipants;                                         // [ RANGE = 0->STORED_PARTICIPANTS_MAX ]   [ UNSET = -1 ]
  ParticipantInfo mParticipantInfo[STORED_PARTICIPANTS_MAX];    // [ struct (Type#13) ParticipantInfo struct ]

  // Unfiltered Input
  float mUnfilteredThrottle;                        // [ RANGE = 0.0f->1.0f ]
  float mUnfilteredBrake;                           // [ RANGE = 0.0f->1.0f ]
  float mUnfilteredSteering;                        // [ RANGE = -1.0f->1.0f ]
  float mUnfilteredClutch;                          // [ RANGE = 0.0f->1.0f ]

  // Vehicle information
  char mCarName[STRING_LENGTH_MAX];                 // [ string ]
  char mCarClassName[STRING_LENGTH_MAX];            // [ string ]

  // Event information
  unsigned int mLapsInEvent;                        // [ RANGE = 0->... ]   [ UNSET = 0 ]
  char mTrackLocation[STRING_LENGTH_MAX];           // [ string ] - untranslated shortened English name
  char mTrackVariation[STRING_LENGTH_MAX];          // [ string ]- untranslated shortened English variation description
  float mTrackLength;                               // [ UNITS = Metres ]   [ RANGE = 0.0f->... ]    [ UNSET = 0.0f ]

  // Timings
  int mNumSectors;                                  // [ RANGE = 0->... ]   [ UNSET = -1 ]
  bool mLapInvalidated;                             // [ UNITS = boolean ]   [ RANGE = false->true ]   [ UNSET = false ]
  float mBestLapTime;                               // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mLastLapTime;                               // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mCurrentTime;                               // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mSplitTimeAhead;                            // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mSplitTimeBehind;                           // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mSplitTime;                                 // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mEventTimeRemaining;                        // [ UNITS = milli-seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mPersonalFastestLapTime;                    // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mWorldFastestLapTime;                       // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mCurrentSector1Time;                        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mCurrentSector2Time;                        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mCurrentSector3Time;                        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mFastestSector1Time;                        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mFastestSector2Time;                        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mFastestSector3Time;                        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mPersonalFastestSector1Time;                // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mPersonalFastestSector2Time;                // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mPersonalFastestSector3Time;                // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mWorldFastestSector1Time;                   // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mWorldFastestSector2Time;                   // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  float mWorldFastestSector3Time;                   // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]

  // Flags
  unsigned int mHighestFlagColour;                 // [ enum (Type#5) Flag Colour ]
  unsigned int mHighestFlagReason;                 // [ enum (Type#6) Flag Reason ]

  // Pit Info
  unsigned int mPitMode;                           // [ enum (Type#7) Pit Mode ]
  unsigned int mPitSchedule;                       // [ enum (Type#8) Pit Stop Schedule ]

  // Car State
  unsigned int mCarFlags;                          // [ enum (Type#9) Car Flags ]
  float mOilTempCelsius;                           // [ UNITS = Celsius ]   [ UNSET = 0.0f ]
  float mOilPressureKPa;                           // [ UNITS = Kilopascal ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mWaterTempCelsius;                         // [ UNITS = Celsius ]   [ UNSET = 0.0f ]
  float mWaterPressureKPa;                         // [ UNITS = Kilopascal ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mFuelPressureKPa;                          // [ UNITS = Kilopascal ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mFuelLevel;                                // [ RANGE = 0.0f->1.0f ]
  float mFuelCapacity;                             // [ UNITS = Liters ]   [ RANGE = 0.0f->1.0f ]   [ UNSET = 0.0f ]
  float mSpeed;                                    // [ UNITS = Metres per-second ]   [ RANGE = 0.0f->... ]
  float mRpm;                                      // [ UNITS = Revolutions per minute ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mMaxRPM;                                   // [ UNITS = Revolutions per minute ]   [ RANGE = 0.0f->... ]   [ UNSET = 0.0f ]
  float mBrake;                                    // [ RANGE = 0.0f->1.0f ]
  float mThrottle;                                 // [ RANGE = 0.0f->1.0f ]
  float mClutch;                                   // [ RANGE = 0.0f->1.0f ]
  float mSteering;                                 // [ RANGE = -1.0f->1.0f ]
  int mGear;                                       // [ RANGE = -1 (Reverse)  0 (Neutral)  1 (Gear 1)  2 (Gear 2)  etc... ]   [ UNSET = 0 (Neutral) ]
  int mNumGears;                                   // [ RANGE = 0->... ]   [ UNSET = -1 ]
  float mOdometerKM;                               // [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
  bool mAntiLockActive;                            // [ UNITS = boolean ]   [ RANGE = false->true ]   [ UNSET = false ]
  int mLastOpponentCollisionIndex;                 // [ RANGE = 0->STORED_PARTICIPANTS_MAX ]   [ UNSET = -1 ]
  float mLastOpponentCollisionMagnitude;           // [ RANGE = 0.0f->... ]
  bool mBoostActive;                               // [ UNITS = boolean ]   [ RANGE = false->true ]   [ UNSET = false ]
  float mBoostAmount;                              // [ RANGE = 0.0f->100.0f ] 

  // Motion & Device Related
  float mOrientation[VEC_MAX];                     // [ UNITS = Euler Angles ]
  float mLocalVelocity[VEC_MAX];                   // [ UNITS = Metres per-second ]
  float mWorldVelocity[VEC_MAX];                   // [ UNITS = Metres per-second ]
  float mAngularVelocity[VEC_MAX];                 // [ UNITS = Radians per-second ]
  float mLocalAcceleration[VEC_MAX];               // [ UNITS = Metres per-second ]
  float mWorldAcceleration[VEC_MAX];               // [ UNITS = Metres per-second ]
  float mExtentsCentre[VEC_MAX];                   // [ UNITS = Local Space  X  Y  Z ]

  // Wheels / Tyres
  unsigned int mTyreFlags[TYRE_MAX];               // [ enum (Type#10) Tyre Flags ]
  unsigned int mTerrain[TYRE_MAX];                 // [ enum (Type#11) Terrain Materials ]
  float mTyreY[TYRE_MAX];                          // [ UNITS = Local Space  Y ]
  float mTyreRPS[TYRE_MAX];                        // [ UNITS = Revolutions per second ]
	float mTyreSlipSpeed[TYRE_MAX];                  // OBSOLETE, kept for backward compatibility only
  float mTyreTemp[TYRE_MAX];                       // [ UNITS = Celsius ]   [ UNSET = 0.0f ]
	float mTyreGrip[TYRE_MAX];                       // OBSOLETE, kept for backward compatibility only
  float mTyreHeightAboveGround[TYRE_MAX];          // [ UNITS = Local Space  Y ]
	float mTyreLateralStiffness[TYRE_MAX];           // OBSOLETE, kept for backward compatibility only
  float mTyreWear[TYRE_MAX];                       // [ RANGE = 0.0f->1.0f ]
  float mBrakeDamage[TYRE_MAX];                    // [ RANGE = 0.0f->1.0f ]
  float mSuspensionDamage[TYRE_MAX];               // [ RANGE = 0.0f->1.0f ]
  float mBrakeTempCelsius[TYRE_MAX];               // [ UNITS = Celsius ]
  float mTyreTreadTemp[TYRE_MAX];                  // [ UNITS = Kelvin ]
  float mTyreLayerTemp[TYRE_MAX];                  // [ UNITS = Kelvin ]
  float mTyreCarcassTemp[TYRE_MAX];                // [ UNITS = Kelvin ]
  float mTyreRimTemp[TYRE_MAX];                    // [ UNITS = Kelvin ]
  float mTyreInternalAirTemp[TYRE_MAX];            // [ UNITS = Kelvin ]

  // Car Damage
  unsigned int mCrashState;                        // [ enum (Type#12) Crash Damage State ]
  float mAeroDamage;                               // [ RANGE = 0.0f->1.0f ]
  float mEngineDamage;                             // [ RANGE = 0.0f->1.0f ]

  // Weather
  float mAmbientTemperature;                       // [ UNITS = Celsius ]   [ UNSET = 25.0f ]
  float mTrackTemperature;                         // [ UNITS = Celsius ]   [ UNSET = 30.0f ]
  float mRainDensity;                              // [ UNITS = How much rain will fall ]   [ RANGE = 0.0f->1.0f ]
  float mWindSpeed;                                // [ RANGE = 0.0f->100.0f ]   [ UNSET = 2.0f ]
  float mWindDirectionX;                           // [ UNITS = Normalised Vector X ]
  float mWindDirectionY;                           // [ UNITS = Normalised Vector Y ]
  float mCloudBrightness;                          // [ RANGE = 0.0f->... ]

  //PCars2 additions start, version 8
	// Sequence Number to help slightly with data integrity reads
	volatile unsigned int mSequenceNumber;          // 0 at the start, incremented at start and end of writing, so odd when Shared Memory is being filled, even when the memory is not being touched

	//Additional car variables
	float mWheelLocalPositionY[TYRE_MAX];           // [ UNITS = Local Space  Y ]
	float mSuspensionTravel[TYRE_MAX];              // [ UNITS = meters ] [ RANGE 0.f =>... ]  [ UNSET =  0.0f ]
	float mSuspensionVelocity[TYRE_MAX];            // [ UNITS = Rate of change of pushrod deflection ] [ RANGE 0.f =>... ]  [ UNSET =  0.0f ]
	float mAirPressure[TYRE_MAX];                   // [ UNITS = PSI ]  [ RANGE 0.f =>... ]  [ UNSET =  0.0f ]
	float mEngineSpeed;                             // [ UNITS = Rad/s ] [UNSET = 0.f ]
	float mEngineTorque;                            // [ UNITS = Newton Meters] [UNSET = 0.f ] [ RANGE = 0.0f->... ]
	float mWings[2];                                // [ RANGE = 0.0f->1.0f ] [UNSET = 0.f ]
	float mHandBrake;                               // [ RANGE = 0.0f->1.0f ] [UNSET = 0.f ]

	// additional race variables
	float	mCurrentSector1Times[STORED_PARTICIPANTS_MAX];        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mCurrentSector2Times[STORED_PARTICIPANTS_MAX];        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mCurrentSector3Times[STORED_PARTICIPANTS_MAX];        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mFastestSector1Times[STORED_PARTICIPANTS_MAX];        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mFastestSector2Times[STORED_PARTICIPANTS_MAX];        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mFastestSector3Times[STORED_PARTICIPANTS_MAX];        // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mFastestLapTimes[STORED_PARTICIPANTS_MAX];            // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	float	mLastLapTimes[STORED_PARTICIPANTS_MAX];               // [ UNITS = seconds ]   [ RANGE = 0.0f->... ]   [ UNSET = -1.0f ]
	bool	mLapsInvalidated[STORED_PARTICIPANTS_MAX];            // [ UNITS = boolean for all participants ]   [ RANGE = false->true ]   [ UNSET = false ]
	unsigned int	mRaceStates[STORED_PARTICIPANTS_MAX];         // [ enum (Type#3) Race State ]
	unsigned int	mPitModes[STORED_PARTICIPANTS_MAX];           // [ enum (Type#7)  Pit Mode ]
	float mOrientations[STORED_PARTICIPANTS_MAX][VEC_MAX];      // [ UNITS = Euler Angles ]
	float mSpeeds[STORED_PARTICIPANTS_MAX];                     // [ UNITS = Metres per-second ]   [ RANGE = 0.0f->... ]
	char mCarNames[STORED_PARTICIPANTS_MAX][STRING_LENGTH_MAX]; // [ string ]
	char mCarClassNames[STORED_PARTICIPANTS_MAX][STRING_LENGTH_MAX]; // [ string ]

																											// additional race variables
	int		mEnforcedPitStopLap;                          // [ UNITS = in which lap there will be a mandatory pitstop] [ RANGE = 0.0f->... ] [ UNSET = -1 ]
	char	mTranslatedTrackLocation[STRING_LENGTH_MAX];  // [ string ]
	char	mTranslatedTrackVariation[STRING_LENGTH_MAX]; // [ string ]
	float	mBrakeBias;																		// [ RANGE = 0.0f->1.0f... ]   [ UNSET = -1.0f ]
	float mTurboBoostPressure;													//	 RANGE = 0.0f->1.0f... ]   [ UNSET = -1.0f ]
	char	mTyreCompound[TYRE_MAX][TYRE_COMPOUND_NAME_LENGTH_MAX];// [ strings  ]
	unsigned int	mPitSchedules[STORED_PARTICIPANTS_MAX];  // [ enum (Type#7)  Pit Mode ]
	unsigned int	mHighestFlagColours[STORED_PARTICIPANTS_MAX];                 // [ enum (Type#5) Flag Colour ]
	unsigned int	mHighestFlagReasons[STORED_PARTICIPANTS_MAX];                 // [ enum (Type#6) Flag Reason ]
	unsigned int	mNationalities[STORED_PARTICIPANTS_MAX];										  // [ nationality table , SP AND UNSET = 0 ]
	float	mSnowDensity;																// [ UNITS = How much snow will fall ]   [ RANGE = 0.0f->1.0f ], this is non zero only in Winter and Snow seasons
	
  // AMS2 Additions (v10...)

  // Session info
  float mSessionDuration;           // [ UNITS = minutes ]   [ UNSET = 0.0f ]  The scheduled session Length (unset means laps race. See mLapsInEvent)
  int   mSessionAdditionalLaps;     // The number of additional complete laps lead lap drivers must complete to finish a timed race after the session duration has elapsed.

  // Tyres
	float mTyreTempLeft[TYRE_MAX];    // [ UNITS = Celsius ]   [ UNSET = 0.0f ]
  float mTyreTempCenter[TYRE_MAX];  // [ UNITS = Celsius ]   [ UNSET = 0.0f ]
  float mTyreTempRight[TYRE_MAX];   // [ UNITS = Celsius ]   [ UNSET = 0.0f ]

  // DRS
  unsigned int mDrsState;           // [ enum (Type#14) DrsState ]

  // Suspension
  float mRideHeight[TYRE_MAX];      // [ UNITS = cm ]

  // Input
	unsigned int mJoyPad0;            // button mask
  unsigned int mDPad;               // button mask

  int mAntiLockSetting;             // [ UNSET = -1 ] Current ABS garage setting. Valid under player control only.
  int mTractionControlSetting;      // [ UNSET = -1 ] Current ABS garage setting. Valid under player control only.

  // ERS
  int mErsDeploymentMode;           // [ enum (Type#15)  ErsDeploymentMode ]
  bool mErsAutoModeEnabled;         // true if the deployment mode was selected by auto system. Valid only when mErsDeploymentMode > ERS_DEPLOYMENT_MODE_NONE

	// Clutch State & Damage
	float	mClutchTemp;                // [ UNITS = Kelvin ] [ UNSET = -273.16 ]
	float	mClutchWear;                // [ RANGE = 0.0f->1.0f... ]
	bool  mClutchOverheated;          // true if clutch performance is degraded due to overheating
	bool  mClutchSlipping;            // true if clutch is slipping (can be induced by overheating or wear)

  int mYellowFlagState;             // [ enum (Type#16) YellowFlagState ]

} SharedMemory;


#endif  // _SHARED_MEMORY_HPP_
