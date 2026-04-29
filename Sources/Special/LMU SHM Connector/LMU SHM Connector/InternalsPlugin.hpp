/******************************************************************************
 *  Copyright (c) 2025 Studio 397 BV and Motorsport Games Inc.
 *  All rights reserved.
 *
 *  This header is part of the Studio 397 Plugin SDK. It may be used solely
 *  for the purpose of developing plugins or extensions for supported Studio 397
 *  products. Redistribution or modification of this header is not permitted.
 *
 *  This file contains proprietary information of Studio 397 B.V. and is
 *  provided on a strictly "as is" basis, without warranty of any kind, either
 *  express or implied. Studio 397 B.V. shall not be liable for any damages
 *  arising out of the use of this file or any plugins created with it.
 ******************************************************************************/

#ifndef _INTERNALS_PLUGIN_HPP_
#define _INTERNALS_PLUGIN_HPP_

#include "PluginObjects.hpp"     // base class for plugin objects to derive from
#include <cmath>                 // for sqrt()
#include <windows.h>             // for HWND
// rF2 and plugins must agree on structure packing, so set it explicitly here.
// Whatever the current packing is will be restored at the end of this include
// with another #pragma.
#pragma pack( push, 4 )

enum class IP_VehicleClass : uint8_t {
    Hypercar = 0x00,
    LMP2_ELMS = 0x02,
    LMP2,
    LMP3,
    GTE,
    GT3,
    PaceCar = 0x08,
    Unknown = 0xFF
};

enum class IP_VehicleChampionship : uint8_t {
    WEC_2023 = 0x00, WEC_2024, WEC_2025, WEC_2026,
    ELMS_2025 = 0X10, ELMS_2026,
    Unknown = 0xFF
};

//#########################################################################
//# Version01 Structures                                                   #
//##########################################################################

struct TelemVect3
{
    union
    {
        struct
        {
            double x, y, z;
        };

        double data[3];
    };


  void Set( const double a, const double b, const double c )  { x = a; y = b; z = c; }

  // Allowed to reference as [0], [1], or [2], instead of .x, .y, or .z, respectively
        double &operator[]( long i )               { return( data [ i ] ); }
  const double &operator[]( long i ) const         { return( data [ i ] ); }
};


struct TelemQuat
{
  double w, x, y, z;

  // Convert this quaternion to a matrix
  void ConvertQuatToMat( TelemVect3 ori[3] ) const
  {
    const double x2 = x + x;
    const double xx = x * x2;
    const double y2 = y + y;
    const double yy = y * y2;
    const double z2 = z + z;
    const double zz = z * z2;
    const double xz = x * z2;
    const double xy = x * y2;
    const double wy = w * y2;
    const double wx = w * x2;
    const double wz = w * z2;
    const double yz = y * z2;
    ori[0][0] = (double) 1.0 - ( yy + zz );
    ori[0][1] = xy - wz;
    ori[0][2] = xz + wy;
    ori[1][0] = xy + wz;
    ori[1][1] = (double) 1.0 - ( xx + zz );
    ori[1][2] = yz - wx;
    ori[2][0] = xz - wy;
    ori[2][1] = yz + wx;
    ori[2][2] = (double) 1.0 - ( xx + yy );
  }

  // Convert a matrix to this quaternion
  void ConvertMatToQuat( const TelemVect3 ori[3] )
  {
    const double trace = ori[0][0] + ori[1][1] + ori[2][2] + (double) 1.0;
    if( trace > 0.0625f )
    {
      const double sqrtTrace = sqrt( trace );
      const double s = (double) 0.5 / sqrtTrace;
      w = (double) 0.5 * sqrtTrace;
      x = ( ori[2][1] - ori[1][2] ) * s;
      y = ( ori[0][2] - ori[2][0] ) * s;
      z = ( ori[1][0] - ori[0][1] ) * s;
    }
    else if( ( ori[0][0] > ori[1][1] ) && ( ori[0][0] > ori[2][2] ) )
    {
      const double sqrtTrace = sqrt( (double) 1.0 + ori[0][0] - ori[1][1] - ori[2][2] );
      const double s = (double) 0.5 / sqrtTrace;
      w = ( ori[2][1] - ori[1][2] ) * s;
      x = (double) 0.5 * sqrtTrace;
      y = ( ori[0][1] + ori[1][0] ) * s;
      z = ( ori[0][2] + ori[2][0] ) * s;
    }
    else if( ori[1][1] > ori[2][2] )
    {
      const double sqrtTrace = sqrt( (double) 1.0 + ori[1][1] - ori[0][0] - ori[2][2] );
      const double s = (double) 0.5 / sqrtTrace;
      w = ( ori[0][2] - ori[2][0] ) * s;
      x = ( ori[0][1] + ori[1][0] ) * s;
      y = (double) 0.5 * sqrtTrace;
      z = ( ori[1][2] + ori[2][1] ) * s;
    }
    else
    {
      const double sqrtTrace = sqrt( (double) 1.0 + ori[2][2] - ori[0][0] - ori[1][1] );
      const double s = (double) 0.5 / sqrtTrace;
      w = ( ori[1][0] - ori[0][1] ) * s;
      x = ( ori[0][2] + ori[2][0] ) * s;
      y = ( ori[1][2] + ori[2][1] ) * s;
      z = (double) 0.5 * sqrtTrace;
    }
  }
};


struct TelemWheelV01
{
  double mSuspensionDeflection;  // meters
  double mRideHeight;            // meters
  double mSuspForce;             // pushrod load in Newtons
  double mBrakeTemp;             // Celsius
  double mBrakePressure;         // currently 0.0-1.0, depending on driver input and brake balance; will convert to true brake pressure (kPa) in future

  double mRotation;              // radians/sec
  double mLateralPatchVel;       // lateral velocity at contact patch
  double mLongitudinalPatchVel;  // longitudinal velocity at contact patch
  double mLateralGroundVel;      // lateral velocity at contact patch
  double mLongitudinalGroundVel; // longitudinal velocity at contact patch
  double mCamber;                // radians (positive is left for left-side wheels, right for right-side wheels)
  double mLateralForce;          // Newtons
  double mLongitudinalForce;     // Newtons
  double mTireLoad;              // Newtons

  double mGripFract;             // an approximation of what fraction of the contact patch is sliding
  double mPressure;              // kPa (tire pressure)
  double mTemperature[3];        // Kelvin (subtract 273.15 to get Celsius), left/center/right (not to be confused with inside/center/outside!)
  double mWear;                  // wear (0.0-1.0, fraction of maximum) ... this is not necessarily proportional with grip loss
  char mTerrainName[16];         // the material prefixes from the TDF file
  unsigned char mSurfaceType;    // 0=dry, 1=wet, 2=grass, 3=dirt, 4=gravel, 5=rumblestrip, 6=special
  bool mFlat;                    // whether tire is flat
  bool mDetached;                // whether wheel is detached
  unsigned char mStaticUndeflectedRadius; // tire radius in centimeters

  double mVerticalTireDeflection;// how much is tire deflected from its (speed-sensitive) radius
  double mWheelYLocation;        // wheel's y location relative to vehicle y location
  double mToe;                   // current toe angle w.r.t. the vehicle

  double mTireCarcassTemperature;       // rough average of temperature samples from carcass (Kelvin)
  double mTireInnerLayerTemperature[3]; // rough average of temperature samples from innermost layer of rubber (before carcass) (Kelvin)

  float_t mOptimalTemp;
  unsigned char mCompoundIndex;
  unsigned char mCompoundType;
  unsigned char mExpansion[18];
};


// Our world coordinate system is left-handed, with +y pointing up.
// The local vehicle coordinate system is as follows:
//   +x points out the left side of the car (from the driver's perspective)
//   +y points out the roof
//   +z points out the back of the car
// Rotations are as follows:
//   +x pitches up
//   +y yaws to the right
//   +z rolls to the right
// Note that ISO vehicle coordinates (+x forward, +y right, +z upward) are
// right-handed.  If you are using that system, be sure to negate any rotation
// or torque data because things rotate in the opposite direction.  In other
// words, a -z velocity in rFactor is a +x velocity in ISO, but a -z rotation
// in rFactor is a -x rotation in ISO!!!

struct TelemInfoV01
{
  // Time
  long mID;                      // slot ID (note that it can be re-used in multiplayer after someone leaves)
  double mDeltaTime;             // time since last update (seconds)
  double mElapsedTime;           // game session time
  long mLapNumber;               // current lap number
  double mLapStartET;            // time this lap was started
  char mVehicleName[64];         // current vehicle name
  char mTrackName[64];           // current track name

  // Position and derivatives
  TelemVect3 mPos;               // world position in meters
  TelemVect3 mLocalVel;          // velocity (meters/sec) in local vehicle coordinates
  TelemVect3 mLocalAccel;        // acceleration (meters/sec^2) in local vehicle coordinates

  // Orientation and derivatives
  TelemVect3 mOri[3];            // rows of orientation matrix (use TelemQuat conversions if desired), also converts local
                                 // vehicle vectors into world X, Y, or Z using dot product of rows 0, 1, or 2 respectively
  TelemVect3 mLocalRot;          // rotation (radians/sec) in local vehicle coordinates
  TelemVect3 mLocalRotAccel;     // rotational acceleration (radians/sec^2) in local vehicle coordinates

  // Vehicle status
  long mGear;                    // -1=reverse, 0=neutral, 1+=forward gears
  double mEngineRPM;             // engine RPM
  double mEngineWaterTemp;       // Celsius
  double mEngineOilTemp;         // Celsius
  double mClutchRPM;             // clutch RPM

  // Driver input
  double mUnfilteredThrottle;    // ranges  0.0-1.0
  double mUnfilteredBrake;       // ranges  0.0-1.0
  double mUnfilteredSteering;    // ranges -1.0-1.0 (left to right)
  double mUnfilteredClutch;      // ranges  0.0-1.0

  // Filtered input (various adjustments for rev or speed limiting, TC, ABS?, speed sensitive steering, clutch work for semi-automatic shifting, etc.)
  double mFilteredThrottle;      // ranges  0.0-1.0
  double mFilteredBrake;         // ranges  0.0-1.0
  double mFilteredSteering;      // ranges -1.0-1.0 (left to right)
  double mFilteredClutch;        // ranges  0.0-1.0

  // Misc
  double mSteeringShaftTorque;   // torque around steering shaft (used to be mSteeringArmForce, but that is not necessarily accurate for feedback purposes)
  double mFront3rdDeflection;    // deflection at front 3rd spring
  double mRear3rdDeflection;     // deflection at rear 3rd spring

  // Aerodynamics
  double mFrontWingHeight;       // front wing height
  double mFrontRideHeight;       // front ride height
  double mRearRideHeight;        // rear ride height
  double mDrag;                  // drag
  double mFrontDownforce;        // front downforce
  double mRearDownforce;         // rear downforce

  // State/damage info
  double mFuel;                  // amount of fuel (liters)
  double mEngineMaxRPM;          // rev limit
  unsigned char mScheduledStops; // number of scheduled pitstops
  bool  mOverheating;            // whether overheating icon is shown
  bool  mDetached;               // whether any parts (besides wheels) have been detached
  bool  mHeadlights;             // whether headlights are on
  unsigned char mDentSeverity[8];// dent severity at 8 locations around the car (0=none, 1=some, 2=more)
  double mLastImpactET;          // time of last impact
  double mLastImpactMagnitude;   // magnitude of last impact
  TelemVect3 mLastImpactPos;     // location of last impact

  // Expanded
  double mEngineTorque;          // current engine torque (including additive torque) (used to be mEngineTq, but there's little reason to abbreviate it)
  long mCurrentSector;           // the current sector (zero-based) with the pitlane stored in the sign bit (example: entering pits from third sector gives 0x80000002)
  unsigned char mSpeedLimiter;   // whether speed limiter is on
  unsigned char mMaxGears;       // maximum forward gears
  unsigned char mFrontTireCompoundIndex;   // index within brand
  unsigned char mRearTireCompoundIndex;    // index within brand
  double mFuelCapacity;          // capacity in liters
  unsigned char mFrontFlapActivated;       // whether front flap is activated
  unsigned char mRearFlapActivated;        // whether rear flap is activated
  unsigned char mRearFlapLegalStatus;      // 0=disallowed, 1=criteria detected but not allowed quite yet, 2=allowed
  unsigned char mIgnitionStarter;          // 0=off 1=ignition 2=ignition+starter

  char mFrontTireCompoundName[18];         // name of front tire compound
  char mRearTireCompoundName[18];          // name of rear tire compound

  unsigned char mSpeedLimiterAvailable;    // whether speed limiter is available
  unsigned char mAntiStallActivated;       // whether (hard) anti-stall is activated
  unsigned char mUnused[2];                //
  float mVisualSteeringWheelRange;         // the *visual* steering wheel range

  double mRearBrakeBias;                   // fraction of brakes on rear
  double mTurboBoostPressure;              // current turbo boost pressure if available
  float mPhysicsToGraphicsOffset[3];       // offset from static CG to graphical center
  float mPhysicalSteeringWheelRange;       // the *physical* steering wheel range

  // deltabest
  double mDeltaBest;

  double mBatteryChargeFraction; // Battery charge as fraction [0.0-1.0]

  // electric boost motor
  double mElectricBoostMotorTorque; // current torque of boost motor (can be negative when in regenerating mode)
  double mElectricBoostMotorRPM; // current rpm of boost motor
  double mElectricBoostMotorTemperature; // current temperature of boost motor
  double mElectricBoostWaterTemperature; // current water temperature of boost motor cooler if present (0 otherwise)
  unsigned char mElectricBoostMotorState; // 0=unavailable 1=inactive, 2=propulsion, 3=regeneration
  bool mLapInvalidated;
  bool mABSActive;
  bool mTCActive;
  bool mSpeedLimiterActive;
  uint8_t mWiperState;
  uint8_t mTC;
  uint8_t mTCMax;
  uint8_t mTCSlip;
  uint8_t mTCSlipMax;
  uint8_t mTCCut;
  uint8_t mTCCutMax;
  uint8_t mABS;
  uint8_t mABSMax;
  uint8_t mMotorMap;
  uint8_t mMotorMapMax;
  uint8_t mMigration;
  uint8_t mMigrationMax;
  uint8_t mFrontAntiSway;
  uint8_t mFrontAntiSwayMax;
  uint8_t mRearAntiSway;
  uint8_t mRearAntiSwayMax;
  uint8_t mLiftAndCoastProgress;
  uint8_t mTrackLimitsSteps; // Normalized track limits points (TrackLimitPoints * TrackLimitStepsPerPoint)
  float mRegen; //kW
  float mSoC;
  float mVirtualEnergy;
  float mTimeGapCarAhead;
  float mTimeGapCarBehind;
  float mTimeGapPlaceAhead;
  float mTimeGapPlaceBehind;
  char mVehicleModel[30];
  IP_VehicleClass mVehicleClass;
  IP_VehicleChampionship mVehicleChampionship;

  // Future use
  unsigned char mExpansion[20]; // for future use (note that the slot ID has been moved to mID above)

  // keeping this at the end of the structure to make it easier to replace in future versions
  TelemWheelV01 mWheel[4];       // wheel info (front left, front right, rear left, rear right)
};

struct GraphicsInfoV01
{
  TelemVect3 mCamPos;            // camera position
  TelemVect3 mCamOri[3];         // rows of orientation matrix (use TelemQuat conversions if desired), also converts local
  HWND mHWND;                    // app handle

  double mAmbientRed;
  double mAmbientGreen;
  double mAmbientBlue;
};


struct GraphicsInfoV02 : public GraphicsInfoV01
{
  long mID;                      // slot ID being viewed (-1 if invalid)

  // Camera types (some of these may only be used for *setting* the camera type in WantsToViewVehicle())
  //    0  = TV cockpit
  //    1  = cockpit
  //    2  = nosecam
  //    3  = swingman
  //    4  = trackside (nearest)
  //    5  = onboard000
  //       :
  //       :
  // 1004  = onboard999
  // 1005+ = (currently unsupported, in the future may be able to set/get specific trackside camera)
  long mCameraType;              // see above comments for possible values

  unsigned char mExpansion[128]; // for future use (possibly camera name)
};


struct CameraControlInfoV01
{
  // Cameras
  long mID;                      // slot ID to view
  long mCameraType;              // see GraphicsInfoV02 comments for values

  // Replays (note that these are asynchronous)
  bool mReplayActive;            // This variable is an *input* filled with whether the replay is currently active (as opposed to realtime).
  bool mReplayUnused;            //
  unsigned char mReplayCommand;  // 0=do nothing, 1=begin, 2=end, 3=rewind, 4=fast backwards, 5=backwards, 6=slow backwards, 7=stop, 8=slow play, 9=play, 10=fast play, 11=fast forward

  bool mReplaySetTime;           // Whether to skip to the following replay time:
  float mReplaySeconds;          // The replay time in seconds to skip to (note: the current replay maximum ET is passed into this variable in case you need it)

  //
  unsigned char mExpansion[120]; // for future use (possibly camera name & positions/orientations)
};


struct MessageInfoV01
{
  char mText[128];               // message to display

  unsigned char mDestination;    // 0 = message center, 1 = chat (can be used for multiplayer chat commands)
  unsigned char mTranslate;      // 0 = do not attempt to translate, 1 = attempt to translate

  unsigned char mExpansion[126]; // for future use (possibly what color, what font, and seconds to display)
};


struct VehicleScoringInfoV01
{
  long mID;                      // slot ID (note that it can be re-used in multiplayer after someone leaves)
  char mDriverName[32];          // driver name
  char mVehicleName[64];         // vehicle name
  short mTotalLaps;              // laps completed
  signed char mSector;           // 0=sector3, 1=sector1, 2=sector2 (don't ask why)
  signed char mFinishStatus;     // 0=none, 1=finished, 2=dnf, 3=dq
  double mLapDist;               // current distance around track
  double mPathLateral;           // lateral position with respect to *very approximate* "center" path
  double mTrackEdge;             // track edge (w.r.t. "center" path) on same side of track as vehicle

  double mBestSector1;           // best sector 1
  double mBestSector2;           // best sector 2 (plus sector 1)
  double mBestLapTime;           // best lap time
  double mLastSector1;           // last sector 1
  double mLastSector2;           // last sector 2 (plus sector 1)
  double mLastLapTime;           // last lap time
  double mCurSector1;            // current sector 1 if valid
  double mCurSector2;            // current sector 2 (plus sector 1) if valid
  // no current laptime because it instantly becomes "last"

  short mNumPitstops;            // number of pitstops made
  short mNumPenalties;           // number of outstanding penalties
  bool mIsPlayer;                // is this the player's vehicle

  signed char mControl;          // who's in control: -1=nobody (shouldn't get this), 0=local player, 1=local AI, 2=remote, 3=replay (shouldn't get this)
  bool mInPits;                  // between pit entrance and pit exit (not always accurate for remote vehicles)
  unsigned char mPlace;          // 1-based position
  char mVehicleClass[32];        // vehicle class

  // Dash Indicators
  double mTimeBehindNext;        // time behind vehicle in next higher place
  long mLapsBehindNext;          // laps behind vehicle in next higher place
  double mTimeBehindLeader;      // time behind leader
  long mLapsBehindLeader;        // laps behind leader
  double mLapStartET;            // time this lap was started

  // Position and derivatives
  TelemVect3 mPos;               // world position in meters
  TelemVect3 mLocalVel;          // velocity (meters/sec) in local vehicle coordinates
  TelemVect3 mLocalAccel;        // acceleration (meters/sec^2) in local vehicle coordinates

  // Orientation and derivatives
  TelemVect3 mOri[3];            // rows of orientation matrix (use TelemQuat conversions if desired), also converts local
                                 // vehicle vectors into world X, Y, or Z using dot product of rows 0, 1, or 2 respectively
  TelemVect3 mLocalRot;          // rotation (radians/sec) in local vehicle coordinates
  TelemVect3 mLocalRotAccel;     // rotational acceleration (radians/sec^2) in local vehicle coordinates

  // tag.2012.03.01 - stopped casting some of these so variables now have names and mExpansion has shrunk, overall size and old data locations should be same
  unsigned char mHeadlights;     // status of headlights
  unsigned char mPitState;       // 0=none, 1=request, 2=entering, 3=stopped, 4=exiting
  unsigned char mServerScored;   // whether this vehicle is being scored by server (could be off in qualifying or racing heats)
  unsigned char mIndividualPhase;// game phases (described below) plus 9=after formation, 10=under yellow, 11=under blue (not used)

  long mQualification;           // 1-based, can be -1 when invalid

  double mTimeIntoLap;           // estimated time into lap
  double mEstimatedLapTime;      // estimated laptime used for 'time behind' and 'time into lap' (note: this may changed based on vehicle and setup!?)

  char mPitGroup[24];            // pit group (same as team name unless pit is shared)
  unsigned char mFlag;           // primary flag being shown to vehicle (currently only 0=green or 6=blue)
  bool mUnderYellow;             // whether this car has taken a full-course caution flag at the start/finish line
  unsigned char mCountLapFlag;   // 0 = do not count lap or time, 1 = count lap but not time, 2 = count lap and time
  bool mInGarageStall;           // appears to be within the correct garage stall

  unsigned char mUpgradePack[16];  // Coded upgrades
  float mPitLapDist;             // location of pit in terms of lap distance

  float mBestLapSector1;         // sector 1 time from best lap (not necessarily the best sector 1 time)
  float mBestLapSector2;         // sector 2 time from best lap (not necessarily the best sector 2 time)

  unsigned long long mSteamID;            // SteamID of the current driver (if any)

  char mVehFilename[32];		// filename of veh file used to identify this vehicle.

  short mAttackMode;

  // 2020.11.12 - Took 1 byte from mExpansion to transmit fuel percentage
  unsigned char mFuelFraction; // Percentage of fuel or battery left in vehicle. 0x00 = 0%; 0xFF = 100%

  // 2021.05.28 - Took 1 byte from mExpansion to transmit DRS (RearFlap) state - consider making this a bitfield if further bools are needed later on
  bool mDRSState;

  // Future use
    unsigned char mExpansion[4];		// for future use
  };


struct ScoringInfoV01
{
  char mTrackName[64];           // current track name
  long mSession;                 // current session (0=testday 1-4=practice 5-8=qual 9=warmup 10-13=race)
  double mCurrentET;             // current time
  double mEndET;                 // ending time
  long  mMaxLaps;                // maximum laps
  double mLapDist;               // distance around track
  char *mResultsStream;          // results stream additions since last update (newline-delimited and NULL-terminated)

  long mNumVehicles;             // current number of vehicles

  // Game phases:
  // 0 Before session has begun
  // 1 Reconnaissance laps (race only)
  // 2 Grid walk-through (race only)
  // 3 Formation lap (race only)
  // 4 Starting-light countdown has begun (race only)
  // 5 Green flag
  // 6 Full course yellow / safety car
  // 7 Session stopped
  // 8 Session over
  // 9 Paused (tag.2015.09.14 - this is new, and indicates that this is a heartbeat call to the plugin)
  unsigned char mGamePhase;

  // Yellow flag states (applies to full-course only)
  // -1 Invalid
  //  0 None
  //  1 Pending
  //  2 Pits closed
  //  3 Pit lead lap
  //  4 Pits open
  //  5 Last lap
  //  6 Resume
  //  7 Race halt (not currently used)
  signed char mYellowFlagState;

  signed char mSectorFlag[3];      // whether there are any local yellows at the moment in each sector (not sure if sector 0 is first or last, so test)
  unsigned char mStartLight;       // start light frame (number depends on track)
  unsigned char mNumRedLights;     // number of red lights in start sequence
  bool mInRealtime;                // in realtime as opposed to at the monitor
  char mPlayerName[32];            // player name (including possible multiplayer override)
  char mPlrFileName[64];           // may be encoded to be a legal filename

  // weather
  double mDarkCloud;               // cloud darkness? 0.0-1.0
  double mRaining;                 // raining severity 0.0-1.0
  double mAmbientTemp;             // temperature (Celsius)
  double mTrackTemp;               // temperature (Celsius)
  TelemVect3 mWind;                // wind speed
  double mMinPathWetness;          // minimum wetness on main path 0.0-1.0
  double mMaxPathWetness;          // maximum wetness on main path 0.0-1.0

  // multiplayer
  unsigned char mGameMode; // 1 = server, 2 = client, 3 = server and client
  bool mIsPasswordProtected; // is the server password protected
  unsigned short mServerPort; // the port of the server (if on a server)
  unsigned long mServerPublicIP; // the public IP address of the server (if on a server)
  long mMaxPlayers; // maximum number of vehicles that can be in the session
  char mServerName[32]; // name of the server
  float mStartET; // start time (seconds since midnight) of the event

  //
  double mAvgPathWetness;          // average wetness on main path 0.0-1.0
  float mSessionTimeRemaining;
  float mTimeOfDay;
  bool mIsFixedSetup;
  uint8_t mTrackGripLevel;
  uint8_t mCloudCoverage;
  uint8_t mTrackLimitsStepsPerPenalty;
  uint8_t mTrackLimitsStepsPerPoint;
  // Future use
  unsigned char mExpansion[187];

  // keeping this at the end of the structure to make it easier to replace in future versions
  VehicleScoringInfoV01 *mVehicle; // array of vehicle scoring info's
};


struct CommentaryRequestInfoV01
{
  char mName[32];                  // one of the event names in the commentary INI file
  double mInput1;                  // first value to pass in (if any)
  double mInput2;                  // first value to pass in (if any)
  double mInput3;                  // first value to pass in (if any)
  bool mSkipChecks;                // ignores commentary detail and random probability of event

  // constructor (for noobs, this just helps make sure everything is initialized to something reasonable)
  CommentaryRequestInfoV01()       { mName[0] = 0; mInput1 = 0.0; mInput2 = 0.0; mInput3 = 0.0; mSkipChecks = false; }
};


//#########################################################################
//# Version02 Structures                                                   #
//##########################################################################

struct PhysicsOptionsV01
{
  unsigned char mTractionControl;  // 0 (off) - 3 (high)
  unsigned char mAntiLockBrakes;   // 0 (off) - 2 (high)
  unsigned char mStabilityControl; // 0 (off) - 2 (high)
  unsigned char mAutoShift;        // 0 (off), 1 (upshifts), 2 (downshifts), 3 (all)
  unsigned char mAutoClutch;       // 0 (off), 1 (on)
  unsigned char mInvulnerable;     // 0 (off), 1 (on)
  unsigned char mOppositeLock;     // 0 (off), 1 (on)
  unsigned char mSteeringHelp;     // 0 (off) - 3 (high)
  unsigned char mBrakingHelp;      // 0 (off) - 2 (high)
  unsigned char mSpinRecovery;     // 0 (off), 1 (on)
  unsigned char mAutoPit;          // 0 (off), 1 (on)
  unsigned char mAutoLift;         // 0 (off), 1 (on)
  unsigned char mAutoBlip;         // 0 (off), 1 (on)

  unsigned char mFuelMult;         // fuel multiplier (0x-7x)
  unsigned char mTireMult;         // tire wear multiplier (0x-7x)
  unsigned char mMechFail;         // mechanical failure setting; 0 (off), 1 (normal), 2 (timescaled)
  unsigned char mAllowPitcrewPush; // 0 (off), 1 (on)
  unsigned char mRepeatShifts;     // accidental repeat shift prevention (0-5; see PLR file)
  unsigned char mHoldClutch;       // for auto-shifters at start of race: 0 (off), 1 (on)
  unsigned char mAutoReverse;      // 0 (off), 1 (on)
  unsigned char mAlternateNeutral; // Whether shifting up and down simultaneously equals neutral

  // tag.2014.06.09 - yes these are new, but no they don't change the size of the structure nor the address of the other variables in it (because we're just using the existing padding)
  unsigned char mAIControl;        // Whether player vehicle is currently under AI control
  unsigned char mUnused1;          //
  unsigned char mUnused2;          //

  float mManualShiftOverrideTime;  // time before auto-shifting can resume after recent manual shift
  float mAutoShiftOverrideTime;    // time before manual shifting can resume after recent auto shift
  float mSpeedSensitiveSteering;   // 0.0 (off) - 1.0
};


struct EnvironmentInfoV01
{
  // TEMPORARY buffers (you should copy them if needed for later use) containing various paths that may be needed.  Each of these
  // could be relative ("UserData\") or full ("C:\BlahBlah\rFactorProduct\UserData\").
  // mPath[ 0 ] points to the UserData directory.
  // mPath[ 1 ] points to the CustomPluginOptions.JSON filename.
  // mPath[ 2 ] points to the latest results file
  // (in the future, we may add paths for the current garage setup, fully upgraded physics files, etc., any other requests?)
  const char *mPath[ 16 ];
  unsigned char mExpansion[256];   // future use
};


// deprecated (callbacks are no longer invoked in DX11) since V8
struct ScreenInfoV01
{
  HWND mAppWindow;                      // Application window handle
  void *mDevice;                        // Cast type to LPDIRECT3DDEVICE9
  void *mRenderTarget;                  // Cast type to LPDIRECT3DTEXTURE9
  long mDriver;                         // Current video driver index

  long mWidth;                          // Screen width
  long mHeight;                         // Screen height
  long mPixelFormat;                    // Pixel format
  long mRefreshRate;                    // Refresh rate
  long mWindowed;                       // Really just a boolean whether we are in windowed mode

  long mOptionsWidth;                   // Width dimension of screen portion used by UI
  long mOptionsHeight;                  // Height dimension of screen portion used by UI
  long mOptionsLeft;                    // Horizontal starting coordinate of screen portion used by UI
  long mOptionsUpper;                   // Vertical starting coordinate of screen portion used by UI

  unsigned char mOptionsLocation;       // 0=main UI, 1=track loading, 2=monitor, 3=on track
  char mOptionsPage[ 31 ];              // the name of the options page

  unsigned char mExpansion[ 224 ];      // future use
};


// replaces the ScreenInfoV01 structure that was deprecated since V8
struct ApplicationStateV01 {
  HWND mAppWindow;                      // application window handle
  unsigned long mWidth;                 // screen width
  unsigned long mHeight;                // screen height
  unsigned long mRefreshRate;           // refresh rate
  unsigned long mWindowed;              // really just a boolean whether we are in windowed mode
  unsigned char mOptionsLocation;       // 0=main UI, 1=track loading, 2=monitor, 3=on track
  char mOptionsPage[ 31 ];              // the name of the options page
  unsigned char mExpansion[ 204 ];      // future use
};


struct CustomControlInfoV01
{
  // The name passed through CheckHWControl() will be the mUntranslatedName prepended with an underscore (e.g. "Track Map Toggle" -> "_Track Map Toggle")
  char mUntranslatedName[ 64 ];         // name of the control that will show up in UI (but translated if available)
  long mRepeat;                         // 0=registers once per hit, 1=registers once, waits briefly, then starts repeating quickly, 2=registers as long as key is down
  unsigned char mExpansion[ 64 ];       // future use
};


struct WeatherControlInfoV01
{
  // The current conditions are passed in with the API call. The following ET (Elapsed Time) value should typically be far
  // enough in the future that it can be interpolated smoothly, and allow clouds time to roll in before rain starts. In
  // other words you probably shouldn't have mCloudiness and mRaining suddenly change from 0.0 to 1.0 and expect that
  // to happen in a few seconds without looking crazy.
  double mET;                           // when you want this weather to take effect

  // mRaining[1][1] is at the origin (2013.12.19 - and currently the only implemented node), while the others
  // are spaced at <trackNodeSize> meters where <trackNodeSize> is the maximum absolute value of a track vertex
  // coordinate (and is passed into the API call).
  double mRaining[ 3 ][ 3 ];            // rain (0.0-1.0) at different nodes

  double mCloudiness;                   // general cloudiness (0.0=clear to 1.0=dark), will be automatically overridden to help ensure clouds exist over rainy areas
  double mAmbientTempK;                 // ambient temperature (Kelvin)
  double mWindMaxSpeed;                 // maximum speed of wind (ground speed, but it affects how fast the clouds move, too)

  bool mApplyCloudinessInstantly;       // preferably we roll the new clouds in, but you can instantly change them now
  bool mUnused1;                        //
  bool mUnused2;                        //
  bool mUnused3;                        //

  unsigned char mExpansion[ 508 ];      // future use (humidity, pressure, air density, etc.)
};


//#########################################################################
//# Version07 Structures                                                   #
//##########################################################################

struct CustomVariableV01
{
  char mCaption[ 128 ];                 // Name of variable. This will be used for storage. In the future, this may also be used in the UI (after attempting to translate).
  long mNumSettings;                    // Number of available settings. The special value 0 should be used for types that have limitless possibilities, which will be treated as a string type.
  long mCurrentSetting;                 // Current setting (also the default setting when returned in GetCustomVariable()). This is zero-based, so: ( 0 <= mCurrentSetting < mNumSettings )

  // future expansion
  unsigned char mExpansion[ 256 ];
};

struct CustomSettingV01
{
  char mName[ 128 ];                    // Enumerated name of setting (only used if CustomVariableV01::mNumSettings > 0). This will be stored in the JSON file for informational purposes only. It may also possibly be used in the UI in the future.
};

struct MultiSessionParticipantV01
{
  // input only
  long mID;                             // slot ID (if loaded) or -1 (if currently disconnected)
  char mDriverName[ 32 ];               // driver name
  char mVehicleName[ 64 ];              // vehicle name
  unsigned char mUpgradePack[ 16 ];     // coded upgrades

  float mBestPracticeTime;              // best practice time
  long mQualParticipantIndex;           // once qualifying begins, this becomes valid and ranks participants according to practice time if possible
  float mQualificationTime[ 4 ];        // best qualification time in up to 4 qual sessions
  float mFinalRacePlace[ 4 ];           // final race place in up to 4 race sessions
  float mFinalRaceTime[ 4 ];            // final race time in up to 4 race sessions

  // input/output
  bool mServerScored;                   // whether vehicle is allowed to participate in current session
  long mGridPosition;                   // 1-based grid position for current race session (or upcoming race session if it is currently warmup), or -1 if currently disconnected
// long mPitIndex;
// long mGarageIndex;

  // future expansion
  unsigned char mExpansion[ 128 ];
};

struct MultiSessionRulesV01
{
  // input only
  long mSession;                        // current session (0=testday 1-4=practice 5-8=qual 9=warmup 10-13=race)
  long mSpecialSlotID;                  // slot ID of someone who just joined, or -2 requesting to update qual order, or -1 (default/general)
  char mTrackType[ 32 ];                // track type from GDB
  long mNumParticipants;                // number of participants (vehicles)

  // input/output
  MultiSessionParticipantV01 *mParticipant;       // array of partipants (vehicles)
  long mNumQualSessions;                // number of qualifying sessions configured
  long mNumRaceSessions;                // number of race sessions configured
  long mMaxLaps;                        // maximum laps allowed in current session (LONG_MAX = unlimited) (note: cannot currently edit in *race* sessions)
  long mMaxSeconds;                     // maximum time allowed in current session (LONG_MAX = unlimited) (note: cannot currently edit in *race* sessions)
  char mName[ 32 ];                     // untranslated name override for session (please use mixed case here, it should get uppercased if necessary)

  // future expansion
  unsigned char mExpansion[ 256 ];
};


enum TrackRulesCommandV01               //
{
  TRCMD_ADD_FROM_TRACK = 0,             // crossed s/f line for first time after full-course yellow was called
  TRCMD_ADD_FROM_PIT,                   // exited pit during full-course yellow
  TRCMD_ADD_FROM_UNDQ,                  // during a full-course yellow, the admin reversed a disqualification
  TRCMD_REMOVE_TO_PIT,                  // entered pit during full-course yellow
  TRCMD_REMOVE_TO_DNF,                  // vehicle DNF'd during full-course yellow
  TRCMD_REMOVE_TO_DQ,                   // vehicle DQ'd during full-course yellow
  TRCMD_REMOVE_TO_UNLOADED,             // vehicle unloaded (possibly kicked out or banned) during full-course yellow
  TRCMD_MOVE_TO_BACK,                   // misbehavior during full-course yellow, resulting in the penalty of being moved to the back of their current line
  TRCMD_LONGEST_LINE,                   // misbehavior during full-course yellow, resulting in the penalty of being moved to the back of the longest line
  //------------------
  TRCMD_MAXIMUM                         // should be last
};

struct TrackRulesActionV01
{
  // input only
  TrackRulesCommandV01 mCommand;        // recommended action
  long mID;                             // slot ID if applicable
  unsigned char mLine;                  // line this command applies to (if applicable)
};

enum TrackRulesColumnV01
{
  TRCOL_LEFT_LANE = 0,                  // left (inside)
  TRCOL_MIDDLE_LANE,                    // middle
  TRCOL_RIGHT_LANE,                     // right (outside)
  //------------------
  TRCOL_MAX_LANES,                      // should be after the valid static lane choices
  //------------------
  TRCOL_INVALID = TRCOL_MAX_LANES,      // currently invalid (hasn't crossed line or in pits/garage)
  TRCOL_FREECHOICE,                     // free choice (dynamically chosen by driver)
  TRCOL_PENDING,                        // depends on another participant's free choice (dynamically set after another driver chooses)
  //------------------
  TRCOL_MAXIMUM                         // should be last
};

struct TrackRulesParticipantV01
{
  // input only
  long mID;                             // slot ID
  short mFrozenOrder;                   // 0-based place when caution came out (not valid for formation laps)
  short mPlace;                         // 1-based place (typically used for the initialization of the formation lap track order)
  float mYellowSeverity;                // a rating of how much this vehicle is contributing to a yellow flag (the sum of all vehicles is compared to TrackRulesV01::mSafetyCarThreshold)
  double mCurrentRelativeDistance;      // equal to ( ( ScoringInfoV01::mLapDist * this->mRelativeLaps ) + VehicleScoringInfoV01::mLapDist )

  // input/output
  long mRelativeLaps;                   // current formation/caution laps relative to safety car (should generally be zero except when safety car crosses s/f line); this can be decremented to implement 'wave around' or 'beneficiary rule' (a.k.a. 'lucky dog' or 'free pass')
  TrackRulesColumnV01 mColumnAssignment;// which column (line/lane) that participant is supposed to be in
  long mPositionAssignment;             // 0-based position within column (line/lane) that participant is supposed to be located at (-1 is invalid)
  unsigned char mPitsOpen;              // whether the rules allow this particular vehicle to enter pits right now (input is 2=false or 3=true; if you want to edit it, set to 0=false or 1=true)
  bool mUpToSpeed;                      // while in the frozen order, this flag indicates whether the vehicle can be followed (this should be false for somebody who has temporarily spun and hasn't gotten back up to speed yet)
  bool mUnused[ 2 ];                    //
  double mGoalRelativeDistance;         // calculated based on where the leader is, and adjusted by the desired column spacing and the column/position assignments
  char mMessage[ 96 ];                  // a message for this participant to explain what is going on (untranslated; it will get run through translator on client machines)

  // future expansion
  unsigned char mExpansion[ 192 ];
};

enum TrackRulesStageV01                 //
{
  TRSTAGE_FORMATION_INIT = 0,           // initialization of the formation lap
  TRSTAGE_FORMATION_UPDATE,             // update of the formation lap
  TRSTAGE_NORMAL,                       // normal (non-yellow) update
  TRSTAGE_CAUTION_INIT,                 // initialization of a full-course yellow
  TRSTAGE_CAUTION_UPDATE,               // update of a full-course yellow
  //------------------
  TRSTAGE_MAXIMUM                       // should be last
};

struct TrackRulesV01
{
  // input only
  double mCurrentET;                    // current time
  TrackRulesStageV01 mStage;            // current stage
  TrackRulesColumnV01 mPoleColumn;      // column assignment where pole position seems to be located
  long mNumActions;                     // number of recent actions
  TrackRulesActionV01 *mAction;         // array of recent actions
  long mNumParticipants;                // number of participants (vehicles)

  bool mYellowFlagDetected;             // whether yellow flag was requested or sum of participant mYellowSeverity's exceeds mSafetyCarThreshold
  unsigned char mYellowFlagLapsWasOverridden;     // whether mYellowFlagLaps (below) is an admin request (0=no 1=yes 2=clear yellow)

  bool mSafetyCarExists;                // whether safety car even exists
  bool mSafetyCarActive;                // whether safety car is active
  long mSafetyCarLaps;                  // number of laps
  float mSafetyCarThreshold;            // the threshold at which a safety car is called out (compared to the sum of TrackRulesParticipantV01::mYellowSeverity for each vehicle)
  double mSafetyCarLapDist;             // safety car lap distance
  float mSafetyCarLapDistAtStart;       // where the safety car starts from

  float mPitLaneStartDist;              // where the waypoint branch to the pits breaks off (this may not be perfectly accurate)
  float mTeleportLapDist;               // the front of the teleport locations (a useful first guess as to where to throw the green flag)

  // future input expansion
  unsigned char mInputExpansion[ 256 ];

  // input/output
  signed char mYellowFlagState;         // see ScoringInfoV01 for values
  short mYellowFlagLaps;                // suggested number of laps to run under yellow (may be passed in with admin command)

  long mSafetyCarInstruction;           // 0=no change, 1=go active, 2=head for pits
  float mSafetyCarSpeed;                // maximum speed at which to drive
  float mSafetyCarMinimumSpacing;       // minimum spacing behind safety car (-1 to indicate no limit)
  float mSafetyCarMaximumSpacing;       // maximum spacing behind safety car (-1 to indicate no limit)

  float mMinimumColumnSpacing;          // minimum desired spacing between vehicles in a column (-1 to indicate indeterminate/unenforced)
  float mMaximumColumnSpacing;          // maximum desired spacing between vehicles in a column (-1 to indicate indeterminate/unenforced)

  float mMinimumSpeed;                  // minimum speed that anybody should be driving (-1 to indicate no limit)
  float mMaximumSpeed;                  // maximum speed that anybody should be driving (-1 to indicate no limit)

  char mMessage[ 96 ];                  // a message for everybody to explain what is going on (which will get run through translator on client machines)
  TrackRulesParticipantV01 *mParticipant;         // array of partipants (vehicles)

  // future input/output expansion
  unsigned char mInputOutputExpansion[ 256 ];
};


struct PitMenuV01
{
  long mCategoryIndex;                  // index of the current category
  char mCategoryName[ 32 ];             // name of the current category (untranslated)

  long mChoiceIndex;                    // index of the current choice (within the current category)
  char mChoiceString[ 32 ];             // name of the current choice (may have some translated words)
  long mNumChoices;                     // total number of choices (0 <= mChoiceIndex < mNumChoices)

  unsigned char mExpansion[ 256 ];      // for future use
};


//#########################################################################
//# Plugin classes used to access internals                                #
//##########################################################################

// Note: use class InternalsPluginV01 and have exported function GetPluginVersion() return 1, or
//       use class InternalsPluginV02 and have exported function GetPluginVersion() return 2, etc.
class InternalsPlugin : public PluginObject
{
 public:

  // General internals methods
  InternalsPlugin() {}
  virtual ~InternalsPlugin() {}

  // GAME FLOW NOTIFICATIONS
  virtual void Startup( long version ) {}                      // sim startup with version * 1000
  virtual void Shutdown() {}                                   // sim shutdown

  virtual void Load() {}                                       // scene/track load
  virtual void Unload() {}                                     // scene/track unload

  virtual void StartSession() {}                               // session started
  virtual void EndSession() {}                                 // session ended

  virtual void EnterRealtime() {}                              // entering realtime (where the vehicle can be driven)
  virtual void ExitRealtime() {}                               // exiting realtime

  // SCORING OUTPUT
  virtual bool WantsScoringUpdates() { return( false ); }      // whether we want scoring updates
  virtual void UpdateScoring( const ScoringInfoV01 &info ) {}  // update plugin with scoring info (approximately five times per second)

  // GAME OUTPUT
  virtual long WantsTelemetryUpdates() { return( 0 ); }        // whether we want telemetry updates (0=no 1=player-only 2=all vehicles)
  virtual void UpdateTelemetry( const TelemInfoV01 &info ) {}  // update plugin with telemetry info

  virtual bool WantsGraphicsUpdates() { return( false ); }     // whether we want graphics updates
  virtual void UpdateGraphics( const GraphicsInfoV01 &info ) {}// update plugin with graphics info

  // COMMENTARY INPUT
  virtual bool RequestCommentary( CommentaryRequestInfoV01 &info ) { return( false ); } // to use our commentary event system, fill in data and return true

  // GAME INPUT
  virtual bool HasHardwareInputs() { return( false ); }        // whether plugin has hardware plugins
  virtual void UpdateHardware( const double fDT ) {}           // update the hardware with the time between frames
  virtual void EnableHardware() {}                             // message from game to enable hardware
  virtual void DisableHardware() {}                            // message from game to disable hardware

  // See if the plugin wants to take over a hardware control.  If the plugin takes over the
  // control, this method returns true and sets the value of the double pointed to by the
  // second arg.  Otherwise, it returns false and leaves the double unmodified.
  virtual bool CheckHWControl( const char * const controlName, double &fRetVal ) { return false; }

  virtual bool ForceFeedback( double &forceValue ) { return( false ); } // alternate force feedback computation - return true if editing the value

  // ERROR FEEDBACK
  virtual void Error( const char * const msg ) {} // Called with explanation message if there was some sort of error in a plugin callback
};


class InternalsPluginV01 : public InternalsPlugin  // Version 01 is the exact same as the original
{
  // REMINDER: exported function GetPluginVersion() should return 1 if you are deriving from this InternalsPluginV01!
};


class InternalsPluginV02 : public InternalsPluginV01  // V02 contains everything from V01 plus the following:
{
  // REMINDER: exported function GetPluginVersion() should return 2 if you are deriving from this InternalsPluginV02!

 public:

  // This function is called occasionally
  virtual void SetPhysicsOptions( PhysicsOptionsV01 &options ) {}
};


class InternalsPluginV03 : public InternalsPluginV02  // V03 contains everything from V02 plus the following:
{
  // REMINDER: exported function GetPluginVersion() should return 3 if you are deriving from this InternalsPluginV03!

 public:

  virtual unsigned char WantsToViewVehicle( CameraControlInfoV01 &camControl ) { return( 0 ); } // return values: 0=do nothing, 1=set ID and camera type, 2=replay controls, 3=both

  // EXTENDED GAME OUTPUT
  virtual void UpdateGraphics( const GraphicsInfoV02 &info )          {} // update plugin with extended graphics info

  // MESSAGE BOX INPUT
  virtual bool WantsToDisplayMessage( MessageInfoV01 &msgInfo )       { return( false ); } // set message and return true
};


class InternalsPluginV04 : public InternalsPluginV03  // V04 contains everything from V03 plus the following:
{
  // REMINDER: exported function GetPluginVersion() should return 4 if you are deriving from this InternalsPluginV04!

 public:

  // EXTENDED GAME FLOW NOTIFICATIONS
  virtual void SetEnvironment( const EnvironmentInfoV01 &info )       {} // may be called whenever the environment changes
};


class InternalsPluginV05 : public InternalsPluginV04  // V05 contains everything from V04 plus the following:
{
  // REMINDER: exported function GetPluginVersion() should return 5 if you are deriving from this InternalsPluginV05!

 public:

  // Note: these callbacks below for ScreenInfoV01 are all deprecated and will no longer be invoked in DX11
  // SCREEN INFO NOTIFICATIONS
  virtual void InitScreen( const ScreenInfoV01 &info )                {} // Now happens right after graphics device initialization
  virtual void UninitScreen( const ScreenInfoV01 &info )              {} // Now happens right before graphics device uninitialization

  virtual void DeactivateScreen( const ScreenInfoV01 &info )          {} // Window deactivation
  virtual void ReactivateScreen( const ScreenInfoV01 &info )          {} // Window reactivation

  virtual void RenderScreenBeforeOverlays( const ScreenInfoV01 &info ){} // before rFactor overlays
  virtual void RenderScreenAfterOverlays( const ScreenInfoV01 &info ) {} // after rFactor overlays

  virtual void PreReset( const ScreenInfoV01 &info )                  {} // after detecting device lost but before resetting
  virtual void PostReset( const ScreenInfoV01 &info )                 {} // after resetting

  // CUSTOM CONTROLS
  virtual bool InitCustomControl( CustomControlInfoV01 &info )        { return( false ); } // called repeatedly at startup until false is returned
};


class InternalsPluginV06 : public InternalsPluginV05  // V06 contains everything from V05 plus the following:
{
  // REMINDER: exported function GetPluginVersion() should return 6 if you are deriving from this InternalsPluginV06!

 public:

  // CONDITIONS CONTROL
  virtual bool WantsWeatherAccess()                                   { return( false ); } // change to true in order to read or write weather with AccessWeather() call:
  virtual bool AccessWeather( double trackNodeSize, WeatherControlInfoV01 &info ) { return( false ); } // current weather is passed in; return true if you want to change it

  // ADDITIONAL GAMEFLOW NOTIFICATIONS
  virtual void ThreadStarted( long type )                             {} // called just after a primary thread is started (type is 0=multimedia or 1=simulation)
  virtual void ThreadStopping( long type )                            {} // called just before a primary thread is stopped (type is 0=multimedia or 1=simulation)
};


class InternalsPluginV07 : public InternalsPluginV06  // V07 contains everything from V06 plus the following:
{
  // REMINDER: exported function GetPluginVersion() should return 7 if you are deriving from this InternalsPluginV07!

 public:

  // CUSTOM PLUGIN VARIABLES
  // This relatively simple feature allows plugins to store settings in a shared location without doing their own
  // file I/O. Direct UI support may also be added in the future so that end users can control plugin settings within
  // rFactor. But for now, users can access the data in UserData\Player\CustomPluginOptions.JSON.
  // Plugins should only access these variables through this interface, though:
  virtual bool GetCustomVariable( long i, CustomVariableV01 &var )   { return( false ); } // At startup, this will be called with increasing index (starting at zero) until false is returned. Feel free to add/remove/rearrange the variables when updating your plugin; the index does not have to be consistent from run to run.
  virtual void AccessCustomVariable( CustomVariableV01 &var )        {}                   // This will be called at startup, shutdown, and any time that the variable is changed (within the UI).
  virtual void GetCustomVariableSetting( CustomVariableV01 &var, long i, CustomSettingV01 &setting ) {} // This gets the name of each possible setting for a given variable.

  // SCORING CONTROL (only available in single-player or on multiplayer server)
  virtual bool WantsMultiSessionRulesAccess()                         { return( false ); } // change to true in order to read or write multi-session rules
  virtual bool AccessMultiSessionRules( MultiSessionRulesV01 &info )  { return( false ); } // current internal rules passed in; return true if you want to change them

  virtual bool WantsTrackRulesAccess()                                { return( false ); } // change to true in order to read or write track order (during formation or caution laps)
  virtual bool AccessTrackRules( TrackRulesV01 &info )                { return( false ); } // current track order passed in; return true if you want to change it (note: this will be called immediately after UpdateScoring() when appropriate)

  // PIT MENU INFO (currently, the only way to edit the pit menu is to use this in conjunction with CheckHWControl())
  virtual bool WantsPitMenuAccess()                                   { return( false ); } // change to true in order to view pit menu info
  virtual bool AccessPitMenu( PitMenuV01 &info )                      { return( false ); } // currently, the return code should always be false (because we may allow more direct editing in the future)
};


class InternalsPluginV08 : public InternalsPluginV07 {
  // REMINDER: exported function GetPluginVersion() should return 8 if you are deriving from this InternalsPluginV08!

public:
  // APPLICATION STATE NOTIFICATIONS
  virtual void InitApplication( const ApplicationStateV01 &state )                {} // Now happens right after graphics device initialization
  virtual void UninitApplication( const ApplicationStateV01 &state )              {} // Now happens right before graphics device uninitialization

  virtual void DeactivateApplication( const ApplicationStateV01 &state )          {} // Application window deactivation
  virtual void ReactivateApplication( const ApplicationStateV01 &state )          {} // Application window reactivation

  virtual void ApplicationRenderBeforeOverlays( const ApplicationStateV01 &state ){} // before rFactor 2 overlays
  virtual void ApplicationRenderAfterOverlays( const ApplicationStateV01 &state ) {} // after rFactor 2 overlays

  virtual void PreResetApplication( const ApplicationStateV01 &state )                  {} // after detecting device lost but before resetting
  virtual void PostResetApplication( const ApplicationStateV01 &state )                 {} // after resetting
};

//#########################################################################
//##########################################################################

// See #pragma at top of file
#pragma pack( pop )

#endif // _INTERNALS_PLUGIN_HPP_

