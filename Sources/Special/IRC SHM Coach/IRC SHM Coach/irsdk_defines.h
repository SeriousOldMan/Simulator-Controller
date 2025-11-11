/*
Copyright (c) 2013, iRacing.com Motorsport Simulations, LLC.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of iRacing.com Motorsport Simulations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef IRSDK_DEFINES_H
#define IRSDK_DEFINES_H

/*
 The IRSDK is a simple api that lets clients access telemetry data from the 
 iRacing simulator. It is broken down into several parts:

 - Live data
   Live data is output from the sim into a shared memory mapped file.  Any
   application can open this memory mapped file and read the telemetry data
   out.  The format of this data was laid out in such a way that it should be
   possible to access from any language that can open a windows memory mapped
   file, without needing an external api.

   There are two different types of data that the telemetry outputs,
   sessionInfo and variables: 
   
   Session info is for data that only needs to be updated every once in a
   while.  This data is output as a YAML formatted string.

   Variables, on the other hand, are output at a rate of 60 times a second.
   The varHeader struct defines each variable that the sim will output, while
   the varData struct gives details about the current line buffer that the vars
   are being written into.  Each variable is packed into a binary array with 
   an offset and length stored in the varHeader.  The number of variables 
   available can change depending on the car or session loaded.  But once the
   sim is running the variable list is locked down and will not change during a
   session.

   The sim writes a new line of variables every 16 ms, and then signals any
   listeners in order to wake them up to read the data.  Because the sim has no
   way of knowing when a listener is done reading the data, we triple buffer
   it in order to give all the clients enough time to read the data out.  This
   gives you a minimum of 16 ms to read the data out and process it.  So it is
   best to copy the data out before processing it.  You can use the function
   irsdk_waitForDataReady() to both wait for new data and copy the data to a
   local buffer.

 - Logged data
   Detailed information about the local drivers car can be logged to disk in
   the form of an ibt binary file.  This logging is enabled in the sim by
   typing alt-L at any time.  The ibt file format directly mirrors the format
   of the live data.

   It is stored as an irsdk_header followed immediately by an irsdk_diskSubHeader.
   After that the offsets in the irsdk_header point to the sessionInfo string, 
   the varHeader, and the varBuffer.

 - Remote Conrol
   You can control the camera selections and playback of a replay tape, from
   any external application by sending a windows message with the 
   irsdk_broadcastMsg() function.
*/

// Constant Definitions

#include <tchar.h>

static const _TCHAR IRSDK_DATAVALIDEVENTNAME[] = _T("Local\\IRSDKDataValidEvent");
static const _TCHAR IRSDK_MEMMAPFILENAME[]     = _T("Local\\IRSDKMemMapFileName");
static const _TCHAR IRSDK_BROADCASTMSGNAME[]   = _T("IRSDK_BROADCASTMSG");

static const int IRSDK_MAX_BUFS = 4;
static const int IRSDK_MAX_STRING = 32;
// descriptions can be longer than max_string!
static const int IRSDK_MAX_DESC = 64; 

// define markers for unlimited session lap and time
static const int IRSDK_UNLIMITED_LAPS = 32767;
static const float IRSDK_UNLIMITED_TIME = 604800.0f;

// latest version of our telemetry headers
static const int IRSDK_VER = 2;

enum irsdk_StatusField
{
	irsdk_stConnected   = 1
};

enum irsdk_VarType
{
	// 1 byte
	irsdk_char = 0,
	irsdk_bool,

	// 4 bytes
	irsdk_int,
	irsdk_bitField,
	irsdk_float,

	// 8 bytes
	irsdk_double,

	//index, don't use
	irsdk_ETCount
};

static const int irsdk_VarTypeBytes[irsdk_ETCount] =
{
	1,		// irsdk_char
	1,		// irsdk_bool

	4,		// irsdk_int
	4,		// irsdk_bitField
	4,		// irsdk_float

	8		// irsdk_double
};

//---

// status 
enum irsdk_TrkLoc
{
	irsdk_NotInWorld = -1,
	irsdk_OffTrack = 0,
	irsdk_InPitStall,
	// This indicates the lead in to pit road, as well as the pit road itself (where speed limits are enforced)
	// if you just want to know that your on the pit road surface look at the live value 'OnPitRoad'
	irsdk_AproachingPits, 
	irsdk_OnTrack
};

enum irsdk_TrkSurf
{
	irsdk_SurfaceNotInWorld = -1,
	irsdk_UndefinedMaterial = 0,

	irsdk_Asphalt1Material,
	irsdk_Asphalt2Material,
	irsdk_Asphalt3Material,
	irsdk_Asphalt4Material,
	irsdk_Concrete1Material,
	irsdk_Concrete2Material,
	irsdk_RacingDirt1Material,
	irsdk_RacingDirt2Material,
	irsdk_Paint1Material,
	irsdk_Paint2Material,
	irsdk_Rumble1Material,
	irsdk_Rumble2Material,
	irsdk_Rumble3Material,
	irsdk_Rumble4Material,

	irsdk_Grass1Material,
	irsdk_Grass2Material,
	irsdk_Grass3Material,
	irsdk_Grass4Material,
	irsdk_Dirt1Material,
	irsdk_Dirt2Material,
	irsdk_Dirt3Material,
	irsdk_Dirt4Material,
	irsdk_SandMaterial,
	irsdk_Gravel1Material,
	irsdk_Gravel2Material,
	irsdk_GrasscreteMaterial,
	irsdk_AstroturfMaterial,
};

enum irsdk_SessionState
{
	irsdk_StateInvalid = 0,
	irsdk_StateGetInCar,
	irsdk_StateWarmup,
	irsdk_StateParadeLaps,
	irsdk_StateRacing,
	irsdk_StateCheckered,
	irsdk_StateCoolDown
};

enum irsdk_CarLeftRight
{
	irsdk_LROff = 0,
	irsdk_LRClear,			// no cars around us.
	irsdk_LRCarLeft,		// there is a car to our left.
	irsdk_LRCarRight,		// there is a car to our right.
	irsdk_LRCarLeftRight,	// there are cars on each side.
	irsdk_LR2CarsLeft,		// there are two cars to our left.
	irsdk_LR2CarsRight		// there are two cars to our right.
};

enum irsdk_PitSvStatus
{
	// status
	irsdk_PitSvNone = 0,
	irsdk_PitSvInProgress,
	irsdk_PitSvComplete,

	// errors
	irsdk_PitSvTooFarLeft = 100,
	irsdk_PitSvTooFarRight,
	irsdk_PitSvTooFarForward,
	irsdk_PitSvTooFarBack,
	irsdk_PitSvBadAngle,
	irsdk_PitSvCantFixThat,
};

enum irsdk_PaceMode
{
	irsdk_PaceModeSingleFileStart = 0,
	irsdk_PaceModeDoubleFileStart,
	irsdk_PaceModeSingleFileRestart,
	irsdk_PaceModeDoubleFileRestart,
	irsdk_PaceModeNotPacing,
};

enum irsdk_TrackWetness
{
  irsdk_TrackWetness_UNKNOWN = 0,
  irsdk_TrackWetness_Dry,
  irsdk_TrackWetness_MostlyDry,
  irsdk_TrackWetness_VeryLightlyWet,
  irsdk_TrackWetness_LightlyWet,
  irsdk_TrackWetness_ModeratelyWet,
  irsdk_TrackWetness_VeryWet,
  irsdk_TrackWetness_ExtremelyWet
};

//---

// bit fields
enum irsdk_EngineWarnings 
{
	irsdk_waterTempWarning		= 0x0001,
	irsdk_fuelPressureWarning	= 0x0002,
	irsdk_oilPressureWarning	= 0x0004,
	irsdk_engineStalled			= 0x0008,
	irsdk_pitSpeedLimiter		= 0x0010,
	irsdk_revLimiterActive		= 0x0020,
	irsdk_oilTempWarning		= 0x0040,
};

// global flags
enum irsdk_Flags
{
	// global flags
	irsdk_checkered				= 0x00000001,
	irsdk_white					= 0x00000002,
	irsdk_green					= 0x00000004,
	irsdk_yellow				= 0x00000008,
	irsdk_red					= 0x00000010,
	irsdk_blue					= 0x00000020,
	irsdk_debris				= 0x00000040,
	irsdk_crossed				= 0x00000080,
	irsdk_yellowWaving			= 0x00000100,
	irsdk_oneLapToGreen			= 0x00000200,
	irsdk_greenHeld				= 0x00000400,
	irsdk_tenToGo				= 0x00000800,
	irsdk_fiveToGo				= 0x00001000,
	irsdk_randomWaving			= 0x00002000,
	irsdk_caution				= 0x00004000,
	irsdk_cautionWaving			= 0x00008000,

	// drivers black flags
	irsdk_black					= 0x00010000,
	irsdk_disqualify			= 0x00020000,
	irsdk_servicible			= 0x00040000, // car is allowed service (not a flag)
	irsdk_furled				= 0x00080000,
	irsdk_repair				= 0x00100000,

	// start lights
	irsdk_startHidden			= 0x10000000,
	irsdk_startReady			= 0x20000000,
	irsdk_startSet				= 0x40000000,
	irsdk_startGo				= 0x80000000,
};

enum irsdk_CameraState
{
	irsdk_IsSessionScreen       = 0x0001, // the camera tool can only be activated if viewing the session screen (out of car)
	irsdk_IsScenicActive        = 0x0002, // the scenic camera is active (no focus car)

	//these can be changed with a broadcast message
	irsdk_CamToolActive         = 0x0004,
	irsdk_UIHidden              = 0x0008,
	irsdk_UseAutoShotSelection  = 0x0010,
	irsdk_UseTemporaryEdits     = 0x0020,
	irsdk_UseKeyAcceleration    = 0x0040,
	irsdk_UseKey10xAcceleration = 0x0080,
	irsdk_UseMouseAimMode       = 0x0100
};

enum irsdk_PitSvFlags
{
	irsdk_LFTireChange			= 0x0001,
	irsdk_RFTireChange			= 0x0002,
	irsdk_LRTireChange			= 0x0004,
	irsdk_RRTireChange			= 0x0008,

	irsdk_FuelFill				= 0x0010,
	irsdk_WindshieldTearoff		= 0x0020,
	irsdk_FastRepair			= 0x0040
};

enum irsdk_PaceFlags
{
	irsdk_PaceFlagsEndOfLine	= 0x0001,
	irsdk_PaceFlagsFreePass		= 0x0002,
	irsdk_PaceFlagsWavedAround	= 0x0004,
};

//----
//

struct irsdk_varHeader
{
	int type;			// irsdk_VarType
	int offset;			// offset fron start of buffer row
	int count;			// number of entrys (array)
						// so length in bytes would be irsdk_VarTypeBytes[type] * count
	bool countAsTime;
	char pad[3];		// (16 byte align)

	char name[IRSDK_MAX_STRING];
	char desc[IRSDK_MAX_DESC];
	char unit[IRSDK_MAX_STRING];	// something like "kg/m^2"

	void clear()
	{
		type = 0;
		offset = 0;
		count = 0;
		countAsTime = false;
		memset(name, 0, sizeof(name));
		memset(desc, 0, sizeof(name));
		memset(unit, 0, sizeof(name));
	}
};

struct irsdk_varBuf
{
	int tickCount;		// used to detect changes in data
	int bufOffset;		// offset from header
	int pad[2];			// (16 byte align)
};

struct irsdk_header
{
	int ver;				// this api header version, see IRSDK_VER
	int status;				// bitfield using irsdk_StatusField
	int tickRate;			// ticks per second (60 or 360 etc)

	// session information, updated periodicaly
	int sessionInfoUpdate;	// Incremented when session info changes
	int sessionInfoLen;		// Length in bytes of session info string
	int sessionInfoOffset;	// Session info, encoded in YAML format

	// State data, output at tickRate

	int numVars;			// length of arra pointed to by varHeaderOffset
	int varHeaderOffset;	// offset to irsdk_varHeader[numVars] array, Describes the variables received in varBuf

	int numBuf;				// <= IRSDK_MAX_BUFS (3 for now)
	int bufLen;				// length in bytes for one line
	//****ToDo, add these in
	//int curBufTickCount;	// stashed copy of the current tickCount, can read this to see if new data is available
	//byte curBuf;			// index of the most recently written buffer (0 to IRSDK_MAX_BUFS-1)
	//byte pad1[3];			// 16 byte align
	int pad1[2];			// (16 byte align)
	irsdk_varBuf varBuf[IRSDK_MAX_BUFS]; // buffers of data being written to
};

// sub header used when writing telemetry to disk
struct irsdk_diskSubHeader
{
	time_t sessionStartDate;
	double sessionStartTime;
	double sessionEndTime;
	int sessionLapCount;
	int sessionRecordCount;
};

//----
// Client function definitions

bool irsdk_startup();
void irsdk_shutdown();

bool irsdk_getNewData(char *data);
bool irsdk_waitForDataReady(int timeOut, char *data);
bool irsdk_isConnected();

const irsdk_header *irsdk_getHeader();
const char *irsdk_getData(int index);
const char *irsdk_getSessionInfoStr();
int irsdk_getSessionInfoStrUpdate(); // incrementing index that indicates new session info string

const irsdk_varHeader *irsdk_getVarHeaderPtr();
const irsdk_varHeader *irsdk_getVarHeaderEntry(int index);

int irsdk_varNameToIndex(const char *name);
int irsdk_varNameToOffset(const char *name);

//----
// Remote controll the sim by sending these windows messages
// camera and replay commands only work when you are out of your car, 
// pit commands only work when in your car
enum irsdk_BroadcastMsg 
{
	irsdk_BroadcastCamSwitchPos = 0,      // car position, group, camera
	irsdk_BroadcastCamSwitchNum,	      // driver #, group, camera
	irsdk_BroadcastCamSetState,           // irsdk_CameraState, unused, unused 
	irsdk_BroadcastReplaySetPlaySpeed,    // speed, slowMotion, unused
	irskd_BroadcastReplaySetPlayPosition, // irsdk_RpyPosMode, Frame Number (high, low)
	irsdk_BroadcastReplaySearch,          // irsdk_RpySrchMode, unused, unused
	irsdk_BroadcastReplaySetState,        // irsdk_RpyStateMode, unused, unused
	irsdk_BroadcastReloadTextures,        // irsdk_ReloadTexturesMode, carIdx, unused
	irsdk_BroadcastChatComand,		      // irsdk_ChatCommandMode, subCommand, unused
	irsdk_BroadcastPitCommand,            // irsdk_PitCommandMode, parameter
	irsdk_BroadcastTelemCommand,		  // irsdk_TelemCommandMode, unused, unused
	irsdk_BroadcastFFBCommand,		      // irsdk_FFBCommandMode, value (float, high, low)
	irsdk_BroadcastReplaySearchSessionTime, // sessionNum, sessionTimeMS (high, low)
	irsdk_BroadcastVideoCapture,          // irsdk_VideoCaptureMode, unused, unused
	irsdk_BroadcastLast                   // unused placeholder
};

enum irsdk_ChatCommandMode
{
	irsdk_ChatCommand_Macro = 0,		// pass in a number from 1-15 representing the chat macro to launch
	irsdk_ChatCommand_BeginChat,		// Open up a new chat window
	irsdk_ChatCommand_Reply,			// Reply to last private chat
	irsdk_ChatCommand_Cancel			// Close chat window
};

enum irsdk_PitCommandMode				// this only works when the driver is in the car
{
	irsdk_PitCommand_Clear = 0,			// Clear all pit checkboxes
	irsdk_PitCommand_WS,				// Clean the winshield, using one tear off
	irsdk_PitCommand_Fuel,				// Add fuel, optionally specify the amount to add in liters or pass '0' to use existing amount
	irsdk_PitCommand_LF,				// Change the left front tire, optionally specifying the pressure in KPa or pass '0' to use existing pressure
	irsdk_PitCommand_RF,				// right front
	irsdk_PitCommand_LR,				// left rear
	irsdk_PitCommand_RR,				// right rear
	irsdk_PitCommand_ClearTires,		// Clear tire pit checkboxes
	irsdk_PitCommand_FR,				// Request a fast repair
	irsdk_PitCommand_ClearWS,			// Uncheck Clean the winshield checkbox
	irsdk_PitCommand_ClearFR,			// Uncheck request a fast repair
	irsdk_PitCommand_ClearFuel,			// Uncheck add fuel
	irsdk_PitCommand_TC,				// Change tire compound
};

enum irsdk_TelemCommandMode				// You can call this any time, but telemtry only records when driver is in there car
{
	irsdk_TelemCommand_Stop = 0,		// Turn telemetry recording off
	irsdk_TelemCommand_Start,			// Turn telemetry recording on
	irsdk_TelemCommand_Restart,			// Write current file to disk and start a new one
};

enum irsdk_RpyStateMode
{
	irsdk_RpyState_EraseTape = 0,		// clear any data in the replay tape
	irsdk_RpyState_Last					// unused place holder
};

enum irsdk_ReloadTexturesMode
{
	irsdk_ReloadTextures_All = 0,		// reload all textuers
	irsdk_ReloadTextures_CarIdx			// reload only textures for the specific carIdx
};

// Search replay tape for events
enum irsdk_RpySrchMode
{
	irsdk_RpySrch_ToStart = 0,
	irsdk_RpySrch_ToEnd,
	irsdk_RpySrch_PrevSession,
	irsdk_RpySrch_NextSession,
	irsdk_RpySrch_PrevLap,
	irsdk_RpySrch_NextLap,
	irsdk_RpySrch_PrevFrame,
	irsdk_RpySrch_NextFrame,
	irsdk_RpySrch_PrevIncident,
	irsdk_RpySrch_NextIncident,
	irsdk_RpySrch_Last                   // unused placeholder
};

enum irsdk_RpyPosMode
{
	irsdk_RpyPos_Begin = 0,
	irsdk_RpyPos_Current,
	irsdk_RpyPos_End,
	irsdk_RpyPos_Last                   // unused placeholder
};

enum irsdk_FFBCommandMode				// You can call this any time
{
	irsdk_FFBCommand_MaxForce = 0,		// Set the maximum force when mapping steering torque force to direct input units (float in Nm)
	irsdk_FFBCommand_Last               // unused placeholder
};

// irsdk_BroadcastCamSwitchPos or irsdk_BroadcastCamSwitchNum camera focus defines
// pass these in for the first parameter to select the 'focus at' types in the camera system.
enum irsdk_csMode
{
	irsdk_csFocusAtIncident = -3,
	irsdk_csFocusAtLeader   = -2,
	irsdk_csFocusAtExiting  = -1,
	// ctFocusAtDriver + car number...
	irsdk_csFocusAtDriver   = 0
};

enum irsdk_VideoCaptureMode
{
	irsdk_VideoCapture_TriggerScreenShot = 0,	// save a screenshot to disk
	irsdk_VideoCaptuer_StartVideoCapture,		// start capturing video
	irsdk_VideoCaptuer_EndVideoCapture,			// stop capturing video
	irsdk_VideoCaptuer_ToggleVideoCapture,		// toggle video capture on/off
	irsdk_VideoCaptuer_ShowVideoTimer,			// show video timer in upper left corner of display
	irsdk_VideoCaptuer_HideVideoTimer,			// hide video timer
};

//send a remote controll message to the sim
// var1, var2, and var3 are all 16 bits signed
void irsdk_broadcastMsg(irsdk_BroadcastMsg msg, int var1, int var2, int var3);
// var2 can be a full 32 bits
void irsdk_broadcastMsg(irsdk_BroadcastMsg msg, int var1, int var2);
// var2 can be a full 32 bit float
void irsdk_broadcastMsg(irsdk_BroadcastMsg msg, int var1, float var2);

// add a leading zero (or zeros) to a car number
// to encode car #001 call padCarNum(1,2)
int irsdk_padCarNum(int num, int zero);

#endif //IRSDK_DEFINES_H
