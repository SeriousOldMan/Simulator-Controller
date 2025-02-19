/*
Copyright (c) 2023, iRacing.com Motorsport Simulations, LLC.
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

using System;

namespace iRacing.IRSDK
{
	public enum irsdk_StatusField
	{
		irsdk_stDisconnected = 0,
		irsdk_stConnected = 1
	};

	public enum irsdk_VarType
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
		//irsdk_ETCount
	};

	//public static readonly int[] irsdk_VarTypeBytes, see IRSDKHelper.getVarTypeBytes() 

	// status 
	public enum irsdk_TrkLoc
	{
		irsdk_NotInWorld = -1,
		irsdk_OffTrack = 0,
		irsdk_InPitStall,
		irsdk_AproachingPits,
		irsdk_OnTrack
	};

	public enum irsdk_TrkSurf
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

	public enum irsdk_SessionState
	{
		irsdk_StateInvalid = 0,
		irsdk_StateGetInCar,
		irsdk_StateWarmup,
		irsdk_StateParadeLaps,
		irsdk_StateRacing,
		irsdk_StateCheckered,
		irsdk_StateCoolDown
	};

	public enum irsdk_CarLeftRight
	{
		irsdk_LROff = 0,
		irsdk_LRClear,			// no cars around us.
		irsdk_LRCarLeft,		// there is a car to our left.
		irsdk_LRCarRight,		// there is a car to our right.
		irsdk_LRCarLeftRight,	// there are cars on each side.
		irsdk_LR2CarsLeft,		// there are two cars to our left.
		irsdk_LR2CarsRight		// there are two cars to our right.
	};

	public enum irsdk_PitSvStatus
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

	public enum irsdk_PaceMode
	{
		irsdk_PaceModeSingleFileStart = 0,
		irsdk_PaceModeDoubleFileStart,
		irsdk_PaceModeSingleFileRestart,
		irsdk_PaceModeDoubleFileRestart,
		irsdk_PaceModeNotPacing,
	};

	public enum irsdk_WeatherDynamics
	{
		irsdk_WeatherDynamics_Specified_FixedSky = 0, // specified  weather / fixed sky
		irsdk_WeatherDynamics_Generated_SkyMoves,     // generated weather / dynamic sky
		irsdk_WeatherDynamics_Generated_FixedSky,     // generated weather / fixed sky
		irsdk_WeatherDynamics_Specified_SkyMoves,     // constant  weather / dynamic sky             
	};

	public enum irsdk_WeatherVersion
	{
		irsdk_WeatherVersion_Classic = 0,   // 0 : default init in replays prior to W2 being rolled out (no rain)
		irsdk_WeatherVersion_ForecastBased, // 1 : usual way to handle realistic weather in W2
		irsdk_WeatherVersion_StaticTest_Day,// 2 : W2 version of "WEATHER_DYNAMICS_GENERATED_FIXEDSKY" that adds possibility of track water
		irsdk_WeatherVersion_TimelineBased, // 3 : a timeline of desired specific events in W2
	};

	//----

	//****Note, the following are bit fields, not enums!

	[Flags]
	public enum irsdk_EngineWarnings
	{
		irsdk_waterTempWarning		= 0x0001,
		irsdk_fuelPressureWarning	= 0x0002,
		irsdk_oilPressureWarning	= 0x0004,
		irsdk_engineStalled			= 0x0008,
		irsdk_pitSpeedLimiter		= 0x0010,
		irsdk_revLimiterActive		= 0x0020,
		irsdk_oilTempWarning		= 0x0040,
	};

	[Flags]
	public enum irsdk_Flags : ulong
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

	[Flags]
	public enum irsdk_CameraState
	{
		irsdk_IsSessionScreen		= 0x0001, // the camera tool can only be activated if viewing the session screen (out of car)
		irsdk_IsScenicActive		= 0x0002, // the scenic camera is active (no focus car)

		//these can be changed with a broadcast message
		irsdk_CamToolActive			= 0x0004,
		irsdk_UIHidden				= 0x0008,
		irsdk_UseAutoShotSelection	= 0x0010,
		irsdk_UseTemporaryEdits		= 0x0020,
		irsdk_UseKeyAcceleration	= 0x0040,
		irsdk_UseKey10xAcceleration	= 0x0080,
		irsdk_UseMouseAimMode		= 0x0100
	};

	[Flags]
	public enum irsdk_PitSvFlags
	{
		irsdk_LFTireChange			= 0x0001,
		irsdk_RFTireChange			= 0x0002,
		irsdk_LRTireChange			= 0x0004,
		irsdk_RRTireChange			= 0x0008,

		irsdk_FuelFill				= 0x0010,
		irsdk_WindshieldTearoff		= 0x0020,
		irsdk_FastRepair			= 0x0040
	};

	[Flags]
	public enum irsdk_PaceFlags
	{
		irsdk_PaceFlagsEndOfLine	= 0x0001,
		irsdk_PaceFlagsFreePass		= 0x0002,
		irsdk_PaceFlagsWavedAround	= 0x0004,
	};

	//---

	// helper functions useful across files
	public static class IRSDKHelper
	{
		public static int getVarTypeBytes(irsdk_VarType type)
		{
			switch (type)
			{
				// 1 byte
				case irsdk_VarType.irsdk_char:
				case irsdk_VarType.irsdk_bool:
					return 1;

				// 4 bytes
				case irsdk_VarType.irsdk_int:
				case irsdk_VarType.irsdk_bitField:
				case irsdk_VarType.irsdk_float:
					return 4;

				// 8 bytes
				case irsdk_VarType.irsdk_double:
					return 8;

				default:
					throw new NotSupportedException();
			}
		}
	}
}
