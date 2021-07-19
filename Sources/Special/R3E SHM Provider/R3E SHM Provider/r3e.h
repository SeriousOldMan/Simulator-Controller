#pragma once

#include <stdint.h>

typedef int32_t r3e_int32;
typedef float r3e_float32;
typedef double r3e_float64;
typedef uint8_t r3e_u8char; // UTF-8 code unit

#define R3E_SHARED_MEMORY_NAME "$R3E"

enum
{
    // Major version number to test against
    R3E_VERSION_MAJOR = 2
};

enum
{
    // Minor version number to test against
    R3E_VERSION_MINOR = 9
};

enum
{
    R3E_NUM_DRIVERS_MAX = 128
};

typedef enum
{
    R3E_SESSION_UNAVAILABLE = -1,
    R3E_SESSION_PRACTICE = 0,
    R3E_SESSION_QUALIFY = 1,
    R3E_SESSION_RACE = 2,
	R3E_SESSION_WARMUP = 3,
} r3e_session;

typedef enum
{
    R3E_SESSION_PHASE_UNAVAILABLE = -1,

    // Currently in garage
    R3E_SESSION_PHASE_GARAGE = 1,

    // Gridwalk or track walkthrough
    R3E_SESSION_PHASE_GRIDWALK = 2,

    // Formation lap, rolling start etc.
    R3E_SESSION_PHASE_FORMATION = 3,

    // Countdown to race is ongoing
    R3E_SESSION_PHASE_COUNTDOWN = 4,

    // Race is ongoing
    R3E_SESSION_PHASE_GREEN = 5,

    // End of session
    R3E_SESSION_PHASE_CHECKERED = 6,
} r3e_session_phase;

typedef enum
{
    R3E_CONTROL_UNAVAILABLE = -1,

    // Controlled by the actual player
    R3E_CONTROL_PLAYER = 0,

    // Controlled by AI
    R3E_CONTROL_AI = 1,

    // Controlled by a network entity of some sort
    R3E_CONTROL_REMOTE = 2,

    // Controlled by a replay or ghost
    R3E_CONTROL_REPLAY = 3,
} r3e_control;

typedef enum
{
    R3E_PIT_WINDOW_UNAVAILABLE = -1,

    // Pit stops are not enabled for this session
    R3E_PIT_WINDOW_DISABLED = 0,

    // Pit stops are enabled, but you're not allowed to perform one right now
    R3E_PIT_WINDOW_CLOSED = 1,

    // Allowed to perform a pit stop now
    R3E_PIT_WINDOW_OPEN = 2,

    // Currently performing the pit stop changes (changing driver, etc.)
    R3E_PIT_WINDOW_STOPPED = 3,

    // After the current mandatory pitstop have been completed
    R3E_PIT_WINDOW_COMPLETED = 4,
} r3e_pit_window;

typedef enum
{	
    // Pit menu unavailable
    R3E_PIT_MENU_UNAVAILABLE = -1,

    // Pit menu preset
    R3E_PIT_MENU_PRESET = 0,

    // Pit menu actions
    R3E_PIT_MENU_PENALTY = 1,
    R3E_PIT_MENU_DRIVERCHANGE = 2,
    R3E_PIT_MENU_FUEL = 3,
    R3E_PIT_MENU_FRONTTIRES = 4,
    R3E_PIT_MENU_REARTIRES = 5,
    R3E_PIT_MENU_FRONTWING = 6,
    R3E_PIT_MENU_REARWING = 7,
    R3E_PIT_MENU_SUSPENSION = 8,
	
    // Pit menu buttons
    R3E_PIT_MENU_BUTTON_TOP = 9,
    R3E_PIT_MENU_BUTTON_BOTTOM = 10,
	
    // Pit menu nothing selected
    R3E_PIT_MENU_MAX = 11,
} r3e_pit_menu_selection;

typedef enum
{
    R3E_TIRE_TYPE_UNAVAILABLE = -1,
    R3E_TIRE_TYPE_OPTION = 0,
    R3E_TIRE_TYPE_PRIME = 1,
} r3e_tire_type;

typedef enum
{
	R3E_TIRE_SUBTYPE_UNAVAILABLE = -1,
	R3E_TIRE_SUBTYPE_PRIMARY = 0,
	R3E_TIRE_SUBTYPE_ALTERNATE = 1,
	R3E_TIRE_SUBTYPE_SOFT = 2,
	R3E_TIRE_SUBTYPE_MEDIUM = 3,
	R3E_TIRE_SUBTYPE_HARD = 4,
} r3e_tire_subtype;

typedef enum
{
    // No mandatory pitstops
    R3E_PITSTOP_STATUS_UNAVAILABLE = -1,

    // Mandatory pitstop not served yet
    R3E_PITSTOP_STATUS_UNSERVED = 0,

    // Mandatory pitstop served
    R3E_PITSTOP_STATUS_SERVED = 1,
} r3e_pitstop_status;

typedef enum
{
    R3E_TIRE_FRONT_LEFT = 0,
    R3E_TIRE_FRONT_RIGHT = 1,
    R3E_TIRE_REAR_LEFT = 2,
    R3E_TIRE_REAR_RIGHT = 3,
    R3E_TIRE_INDEX_MAX = 4,
} r3e_tire_index_enum;

typedef enum
{
    R3E_TIRE_TEMP_LEFT = 0,
    R3E_TIRE_TEMP_CENTER = 1,
    R3E_TIRE_TEMP_RIGHT = 2,
    R3E_TIRE_TEMP_INDEX_MAX = 3,
} r3e_tire_temp_enum;

typedef enum
{
    R3E_ENGINE_TYPE_COMBUSTION = 0,
    R3E_ENGINE_TYPE_ELECTRIC = 1,
    R3E_ENGINE_TYPE_HYBRID = 2,
    R3E_ENGINE_TYPE_INDEX_MAX = 3,
} r3e_engine_type_enum;

typedef enum
{
    // N/A
    R3E_FINISH_STATUS_UNAVAILABLE = -1,

    // Still on track, not finished
    R3E_FINISH_STATUS_NONE = 0,

    // Finished session normally
    R3E_FINISH_STATUS_FINISHED = 1,

    // Did not finish
    R3E_FINISH_STATUS_DNF = 2,

    // Did not qualify
    R3E_FINISH_STATUS_DNQ = 3,

    // Did not start
    R3E_FINISH_STATUS_DNS = 4,

    // Disqualified
    R3E_FINISH_STATUS_DQ = 5,
} r3e_finish_status;

typedef enum
{
    // N/A
    R3E_SESSION_LENGTH_UNAVAILABLE = -1,

    R3E_SESSION_LENGTH_TIME_BASED = 0,

    R3E_SESSION_LENGTH_LAP_BASED = 1,

    // Time and lap based session means there will be an extra lap after the time has run out
    R3E_SESSION_LENGTH_TIME_AND_LAP_BASED = 2,
} r3e_session_length_format;

// Make sure everything is tightly packed, to prevent the compiler from adding any hidden padding
#pragma pack(push, 1)

typedef struct
{
    r3e_float32 x;
    r3e_float32 y;
    r3e_float32 z;
} r3e_vec3_f32;

typedef struct
{
    r3e_float64 x;
    r3e_float64 y;
    r3e_float64 z;
} r3e_vec3_f64;

typedef struct
{
    r3e_float32 pitch;
    r3e_float32 yaw;
    r3e_float32 roll;
} r3e_ori_f32;

typedef struct
{
    r3e_float32 sector1;
    r3e_float32 sector2;
    r3e_float32 sector3;
} r3e_sectorStarts;

// High precision data for player's vehicle only
typedef struct
{
    // Virtual physics time
    // Unit: Ticks (1 tick = 1/400th of a second)
    r3e_int32 game_simulation_ticks;

    // Virtual physics time
    // Unit: Seconds
    r3e_float64 game_simulation_time;

    // Car world-space position
    r3e_vec3_f64 position;

    // Car world-space velocity
    // Unit: Meter per second (m/s)
    r3e_vec3_f64 velocity;

    // Car local-space velocity
    // Unit: Meter per second (m/s)
    r3e_vec3_f64 local_velocity;

    // Car world-space acceleration
    // Unit: Meter per second squared (m/s^2)
    r3e_vec3_f64 acceleration;

    // Car local-space acceleration
    // Unit: Meter per second squared (m/s^2)
    r3e_vec3_f64 local_acceleration;

    // Car body orientation
    // Unit: Euler angles
    r3e_vec3_f64 orientation;

    // Car body rotation
    r3e_vec3_f64 rotation;

    // Car body angular acceleration (torque divided by inertia)
    r3e_vec3_f64 angular_acceleration;

    // Car world-space angular velocity
    // Unit: Radians per second
    r3e_vec3_f64 angular_velocity;

    // Car local-space angular velocity
    // Unit: Radians per second
    r3e_vec3_f64 local_angular_velocity;

    // Driver g-force local to car
    r3e_vec3_f64 local_g_force;

    // Total steering force coming through steering bars
    r3e_float64 steering_force;
    r3e_float64 steering_force_percentage;
	
    // Current engine torque
    r3e_float64 engine_torque;

    // Current downforce
    // Unit: Newtons (N)
    r3e_float64 current_downforce;
	
    // Currently unused
    r3e_float64 voltage;
    r3e_float64 ers_level;
    r3e_float64 power_mgu_h;
    r3e_float64 power_mgu_k;
    r3e_float64 torque_mgu_k;

    // Car setup (radians, meters, meters per second)
    r3e_float64 suspension_deflection[R3E_TIRE_INDEX_MAX];
    r3e_float64 suspension_velocity[R3E_TIRE_INDEX_MAX];
    r3e_float64 camber[R3E_TIRE_INDEX_MAX];
    r3e_float64 ride_height[R3E_TIRE_INDEX_MAX];
    r3e_float64 front_wing_height;
    r3e_float64 front_roll_angle;
    r3e_float64 rear_roll_angle;
    r3e_float64 third_spring_suspension_deflection_front;
    r3e_float64 third_spring_suspension_velocity_front;
    r3e_float64 third_spring_suspension_deflection_rear;
    r3e_float64 third_spring_suspension_velocity_rear;

    // Reserved data
    r3e_float64 unused1;
} r3e_playerdata;

typedef struct
{
    // Whether yellow flag is currently active
    // -1 = no data
    //  0 = not active
    //  1 = active
    r3e_int32 yellow;

    // Whether yellow flag was caused by current slot
    // -1 = no data
    //  0 = didn't cause it
    //  1 = caused it
    r3e_int32 yellowCausedIt;

    // Whether overtake of car in front by current slot is allowed under yellow flag
    // -1 = no data
    //  0 = not allowed
    //  1 = allowed
    r3e_int32 yellowOvertake;

    // Whether you have gained positions illegaly under yellow flag to give back
    // -1 = no data
    //  0 = no positions gained
    //  n = number of positions gained
    r3e_int32 yellowPositionsGained;
	
    // Yellow flag for each sector; -1 = no data, 0 = not active, 1 = active
    r3e_int32 sector_yellow[3];

    // Distance into track for closest yellow, -1.0 if no yellow flag exists
    // Unit: Meters (m)
    r3e_float32 closest_yellow_distance_into_track;

    // Whether blue flag is currently active
    // -1 = no data
    //  0 = not active
    //  1 = active
    r3e_int32 blue;

    // Whether black flag is currently active
    // -1 = no data
    //  0 = not active
    //  1 = active
    r3e_int32 black;

    // Whether green flag is currently active
    // -1 = no data
    //  0 = not active
    //  1 = active
    r3e_int32 green;

    // Whether checkered flag is currently active
    // -1 = no data
    //  0 = not active
    //  1 = active
    r3e_int32 checkered;

    // Whether white flag is currently active
    // -1 = no data
    //  0 = not active
    //  1 = active
    r3e_int32 white;

    // Whether black and white flag is currently active and reason
    // -1 = no data
    //  0 = not active
    //  1 = blue flag 1st warning
    //  2 = blue flag 2nd warning
    //  3 = wrong way
    //  4 = cutting track
    r3e_int32 black_and_white;
} r3e_flags;

typedef struct
{
    // Range: 0.0 - 1.0
    // Note: -1.0 = N/A
    r3e_float32 engine;

    // Range: 0.0 - 1.0
    // Note: -1.0 = N/A
    r3e_float32 transmission;

    // Range: 0.0 - 1.0
    // Note: A bit arbitrary at the moment. 0.0 doesn't necessarily mean completely destroyed.
    // Note: -1.0 = N/A
    r3e_float32 aerodynamics;

    // Range: 0.0 - 1.0
    // Note: -1.0 = N/A
    r3e_float32 suspension;

    // Reserved data
    r3e_float32 unused1;
    r3e_float32 unused2;
} r3e_car_damage;

typedef struct
{
    r3e_int32 drive_through;
    r3e_int32 stop_and_go;
    r3e_int32 pit_stop;
    r3e_int32 time_deduction;
    r3e_int32 slow_down;
} r3e_cut_track_penalties;

typedef struct
{
    // If DRS is equipped and allowed
    // 0 = No, 1 = Yes, -1 = N/A
    r3e_int32 equipped;
    // Got DRS activation left
    // 0 = No, 1 = Yes, -1 = N/A
    r3e_int32 available;
    // Number of DRS activations left this lap
    // Note: In sessions with 'endless' amount of drs activations per lap this value starts at int32::max
    // -1 = N/A
    r3e_int32 numActivationsLeft;
    // DRS engaged
    // 0 = No, 1 = Yes, -1 = N/A
    r3e_int32 engaged;
} r3e_drs;

typedef struct
{
    r3e_int32 available;
    r3e_int32 engaged;
    r3e_int32 amount_left;
    r3e_float32 engaged_time_left;
    r3e_float32 wait_time_left;
} r3e_push_to_pass;

typedef struct
{
    r3e_float32 current_temp[R3E_TIRE_TEMP_INDEX_MAX];
    r3e_float32 optimal_temp;
    r3e_float32 cold_temp;
    r3e_float32 hot_temp;
} r3e_tire_temp;

typedef struct
{
    r3e_float32 current_temp;
    r3e_float32 optimal_temp;
    r3e_float32 cold_temp;
    r3e_float32 hot_temp;
} r3e_brake_temp;

typedef struct
{
    // ABS; -1 = N/A, 0 = off, 1 = on, 5 = currently active
    r3e_int32 abs;
    // TC; -1 = N/A, 0 = off, 1 = on, 5 = currently active
    r3e_int32 tc;
    // ESP; -1 = N/A, 0 = off, 1 = on low, 2 = on medium, 3 = on high, 5 = currently active
    r3e_int32 esp;
    // Countersteer; -1 = N/A, 0 = off, 1 = on, 5 = currently active
    r3e_int32 countersteer;
    // Cornering; -1 = N/A, 0 = off, 1 = on, 5 = currently active
    r3e_int32 cornering;
} r3e_aid_settings;

typedef struct
{
    r3e_u8char name[64];
    r3e_int32 car_number;
    r3e_int32 class_id;
    r3e_int32 model_id;
    r3e_int32 team_id;
    r3e_int32 livery_id;
    r3e_int32 manufacturer_id;
    r3e_int32 user_id;
    r3e_int32 slot_id;
    r3e_int32 class_performance_index;
    r3e_int32 engine_type;

    // Reserved data
    r3e_int32 unused1;
    r3e_int32 unused2;
} r3e_driver_info;

typedef struct
{
    r3e_driver_info driver_info;
    r3e_finish_status finish_status;
    r3e_int32 place;
    r3e_int32 place_class;
    r3e_float32 lap_distance;
    r3e_vec3_f32 position;
    r3e_int32 track_sector;
    r3e_int32 completed_laps;
    r3e_int32 current_lap_valid;
    r3e_float32 lap_time_current_self;
    r3e_float32 sector_time_current_self[3];
    r3e_float32 sector_time_previous_self[3];
    r3e_float32 sector_time_best_self[3];
    r3e_float32 time_delta_front;
    r3e_float32 time_delta_behind;
    r3e_pitstop_status pitstop_status;
    r3e_int32 in_pitlane;
    r3e_int32 num_pitstops;
    r3e_cut_track_penalties penalties;
    r3e_float32 car_speed;
    r3e_int32 tire_type_front;
	r3e_int32 tire_type_rear;
	r3e_int32 tire_subtype_front;
	r3e_int32 tire_subtype_rear;
    r3e_float32 base_penalty_weight;
    r3e_float32 aid_penalty_weight;

    // -1 unavailable, 0 = not engaged, 1 = engaged
    r3e_int32 drs_state;
    r3e_int32 ptp_state;

    // -1 unavailable, DriveThrough = 0, StopAndGo = 1, Pitstop = 2, Time = 3, Slowdown = 4, Disqualify = 5,
    r3e_int32 penaltyType;

	// Based on the PenaltyType you can assume the reason is:

    // DriveThroughPenaltyInvalid = 0,
    // DriveThroughPenaltyCutTrack = 1,
    // DriveThroughPenaltyPitSpeeding = 2,
    // DriveThroughPenaltyFalseStart = 3,
    // DriveThroughPenaltyIgnoredBlue = 4,
    // DriveThroughPenaltyDrivingTooSlow = 5,
    // DriveThroughPenaltyIllegallyPassedBeforeGreen = 6,
    // DriveThroughPenaltyIllegallyPassedBeforeFinish = 7,
    // DriveThroughPenaltyIllegallyPassedBeforePitEntrance = 8,
    // DriveThroughPenaltyIgnoredSlowDown = 9,
    // DriveThroughPenaltyMax = 10

    // StopAndGoPenaltyInvalid = 0,
    // StopAndGoPenaltyCutTrack1st = 1,
    // StopAndGoPenaltyCutTrackMult = 2,
    // StopAndGoPenaltyYellowFlagOvertake = 3,
    // StopAndGoPenaltyMax = 4

    // PitstopPenaltyInvalid = 0,
    // PitstopPenaltyIgnoredPitstopWindow = 1,
    // PitstopPenaltyMax = 2

    // ServableTimePenaltyInvalid = 0,
    // ServableTimePenaltyServedMandatoryPitstopLate = 1,
    // ServableTimePenaltyIgnoredMinimumPitstopDuration = 2,
    // ServableTimePenaltyMax = 3

    // SlowDownPenaltyInvalid = 0,
    // SlowDownPenaltyCutTrack1st = 1,
    // SlowDownPenaltyCutTrackMult = 2,
    // SlowDownPenaltyMax = 3

    // DisqualifyPenaltyInvalid = -1,
    // DisqualifyPenaltyFalseStart = 0,
    // DisqualifyPenaltyPitlaneSpeeding = 1,
    // DisqualifyPenaltyWrongWay = 2,
    // DisqualifyPenaltyEnteringPitsUnderRed = 3,
    // DisqualifyPenaltyExitingPitsUnderRed = 4,
    // DisqualifyPenaltyFailedDriverChange = 5,
    // DisqualifyPenaltyThreeDriveThroughsInLap = 6,
    // DisqualifyPenaltyLappedFieldMultipleTimes = 7,
    // DisqualifyPenaltyIgnoredDriveThroughPenalty = 8,
    // DisqualifyPenaltyIgnoredStopAndGoPenalty = 9,
    // DisqualifyPenaltyIgnoredPitStopPenalty = 10,
    // DisqualifyPenaltyIgnoredTimePenalty = 11,
    // DisqualifyPenaltyExcessiveCutting = 12,
    // DisqualifyPenaltyIgnoredBlueFlag = 13,
    // DisqualifyPenaltyMax = 14
    r3e_int32 penaltyReason;

    // Reserved data
    r3e_int32 unused1;
    r3e_int32 unused2;
    r3e_float32 unused3;
    r3e_float32 unused4;
} r3e_driver_data;

typedef struct
{
    //////////////////////////////////////////////////////////////////////////
    // Version
    //////////////////////////////////////////////////////////////////////////

    r3e_int32 version_major;
    r3e_int32 version_minor;
    r3e_int32 all_drivers_offset; // Offset to num_cars
    r3e_int32 driver_data_size; // size of the driver data struct

    //////////////////////////////////////////////////////////////////////////
    // Game State
    //////////////////////////////////////////////////////////////////////////

    r3e_int32 game_paused;
    r3e_int32 game_in_menus;
    r3e_int32 game_in_replay;
    r3e_int32 game_using_vr;

    // Reserved data
    r3e_int32 game_unused1;

    //////////////////////////////////////////////////////////////////////////
    // High detail
    //////////////////////////////////////////////////////////////////////////

    // High detail player vehicle data
    r3e_playerdata player;

    //////////////////////////////////////////////////////////////////////////
    // Event and session
    //////////////////////////////////////////////////////////////////////////

    r3e_u8char track_name[64];
    r3e_u8char layout_name[64];

    r3e_int32 track_id;
    r3e_int32 layout_id;
    r3e_float32 layout_length;
	r3e_sectorStarts sector_start_factors;
	
    // Race session durations
    // Note: Index 0-2 = race 1-3
    // Note: Value -1 = N/A
    // Note: If both laps and minutes are more than 0, race session starts with minutes then adds laps
    r3e_int32 race_session_laps[3];
    r3e_int32 race_session_minutes[3];

    // The current race event index, for championships with multiple events
    // Note: 0-indexed, -1 = N/A
    r3e_int32 event_index;
    // Which session the player is in (practice, qualifying, race, etc.)
    // Note: See the r3e_session enum
    r3e_int32 session_type;
    // The current iteration of the current type of session
    // Note: 1 = first, 2 = second etc, -1 = N/A
    r3e_int32 session_iteration;	
    // If the session is time based, lap based or time based with an extra lap at the end
    r3e_session_length_format session_length_format;
    // Unit: Meter per second (m/s)
    r3e_float32 session_pit_speed_limit;

    // Which phase the current session is in (gridwalk, countdown, green flag, etc.)
    // Note: See the r3e_session_phase enum
    r3e_int32 session_phase;

    // Which phase start lights are in; -1 = unavailable, 0 = off, 1-5 = redlight on and counting down, 6 = greenlight on
    // Note: See the r3e_session_phase enum
    r3e_int32 start_lights;

    // If tire wear is active (-1 = N/A, 0 = Off, 1 = 1x, 2 = 2x, 3 = 3x, 4 = 4x)
    r3e_int32 tire_wear_active;
    // If fuel usage is active (-1 = N/A, 0 = Off, 1 = 1x, 2 = 2x, 3 = 3x, 4 = 4x)
    r3e_int32 fuel_use_active;

    // Total number of laps in the race, or -1 if player is not in race mode (practice, test mode, etc.)
    r3e_int32 number_of_laps;

    // Amount of time and time remaining for the current session
    // Note: Only available in time-based sessions, -1.0 = N/A
    // Units: Seconds
    r3e_float32 session_time_duration;
    r3e_float32 session_time_remaining;

    // Server max incident points, -1 = N/A
    r3e_int32 max_incident_points;

    // Reserved data
    r3e_float32 event_unused2;

    //////////////////////////////////////////////////////////////////////////
    // Pit
    //////////////////////////////////////////////////////////////////////////

    // Current status of the pit stop
    // Note: See the r3e_pit_window enum
    r3e_int32 pit_window_status;

    // The minute/lap from which you're obligated to pit (-1 = N/A)
    // Unit: Minutes in time-based sessions, otherwise lap
    r3e_int32 pit_window_start;

    // The minute/lap into which you need to have pitted (-1 = N/A)
    // Unit: Minutes in time-based sessions, otherwise lap
    r3e_int32 pit_window_end;

    // If current vehicle is in pitlane (-1 = N/A)
    r3e_int32 in_pitlane;

    // What is currently selected in pit menu, and array of states (preset/buttons: -1 = not selectable, 1 = selectable) (actions: -1 = N/A, 0 = unmarked for fix, 1 = marked for fix)
    r3e_pit_menu_selection pit_menu_selection;
    r3e_int32 pit_menu_state[R3E_PIT_MENU_MAX];

    // Current vehicle pit state (-1 = N/A, 0 = None, 1 = Requested stop, 2 = Entered pitlane heading for pitspot, 3 = Stopped at pitspot, 4 = Exiting pitspot heading for pit exit)
    r3e_int32 pit_state;
	
	// Current vehicle pitstop actions duration
    r3e_float32 pit_total_duration;
    r3e_float32 pit_elapsed_time;

	// Current vehicle pit action (-1 = N/A, 0 = None, 1 = Preparing, (combination of 2 = Penalty serve, 4 = Driver change, 8 = Refueling, 16 = Front tires, 32 = Rear tires, 64 = Front wing, 128 = Rear wing, 256 = Suspension))
	r3e_int32 pit_action;

    // Number of pitstops the current vehicle has performed (-1 = N/A)
    r3e_int32 num_pitstops;

    // Pitstop with min duration (-1.0 = N/A, else seconds)
    r3e_float32 pit_min_duration_total;
    r3e_float32 pit_min_duration_left;

    //////////////////////////////////////////////////////////////////////////
    // Scoring & Timings
    //////////////////////////////////////////////////////////////////////////

    // The current state of each type of flag
    r3e_flags flags;

    // Current position (1 = first place)
    r3e_int32 position;
    r3e_int32 position_class;

    r3e_finish_status finish_status;

    // Total number of cut track warnings (-1 = N/A)
    r3e_int32 cut_track_warnings;
    // The number of penalties the car currently has pending of each type (-1 = N/A)
    r3e_cut_track_penalties penalties;
    // Total number of penalties pending for the car
    // Note: See the 'penalties' field
    r3e_int32 num_penalties;

    // How many laps the car has completed. If this value is 6, the car is on it's 7th lap. -1 = n/a
    r3e_int32 completed_laps;
    r3e_int32 current_lap_valid;
    r3e_int32 track_sector;
    r3e_float32 lap_distance;
    // fraction of lap completed, 0.0-1.0, -1.0 = N/A
    r3e_float32 lap_distance_fraction;

    // The current best lap time for the leader of the session
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_best_leader;
    // The current best lap time for the leader of the current/viewed vehicle's class in the current session
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_best_leader_class;
    // Sector times of fastest lap by anyone in session
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 session_best_lap_sector_times[3];
    // Best lap time
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_best_self;
    r3e_float32 sector_time_best_self[3];
    // Previous lap
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_previous_self;
    r3e_float32 sector_time_previous_self[3];
    // Current lap time
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_current_self;
    r3e_float32 sector_time_current_self[3];
    // The time delta between this car's time and the leader
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_delta_leader;
    // The time delta between this car's time and the leader of the car's class
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 lap_time_delta_leader_class;
    // Time delta between this car and the car placed in front
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 time_delta_front;
    // Time delta between this car and the car placed behind
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 time_delta_behind;
    // Time delta between this car's current laptime and this car's best laptime
    // Unit: Seconds (-1000.0 = N/A)
    r3e_float32 time_delta_best_self;
    // Best time for each individual sector no matter lap
    // Unit: Seconds (-1.0 = N/A)
    r3e_float32 best_individual_sector_time_self[3];
    r3e_float32 best_individual_sector_time_leader[3];
    r3e_float32 best_individual_sector_time_leader_class[3];
    // Incident points (-1 = N/A)
    r3e_int32 incident_points;

    // Reserved data
    r3e_int32 score_unused1;
    r3e_float32 score_unused3;
    r3e_float32 score_unused4;

    //////////////////////////////////////////////////////////////////////////
    // Vehicle information
    //////////////////////////////////////////////////////////////////////////

    r3e_driver_info vehicle_info;
    r3e_u8char player_name[64];

    //////////////////////////////////////////////////////////////////////////
    // Vehicle state
    //////////////////////////////////////////////////////////////////////////

    // Which controller is currently controlling the vehicle (AI, player, remote, etc.)
    // Note: See the r3e_control enum
    r3e_int32 control_type;

    // Unit: Meter per second (m/s)
    r3e_float32 car_speed;

    // Unit: Radians per second (rad/s)
    r3e_float32 engine_rps;
    r3e_float32 max_engine_rps;
    r3e_float32 upshift_rps;

    // -2 = N/A, -1 = reverse, 0 = neutral, 1 = first gear, ... (for electric cars, gear is set to 2 if regenerative braking is enabled)
    r3e_int32 gear;
    // -1 = N/A
    r3e_int32 num_gears;

    // Physical location of car's center of gravity in world space (X, Y, Z) (Y = up)
    r3e_vec3_f32 car_cg_location;
    // Pitch, yaw, roll
    // Unit: Radians (rad)
    r3e_ori_f32 car_orientation;
    // Acceleration in three axes (X, Y, Z) of car body in local-space.
    // From car center, +X=left, +Y=up, +Z=back.
    // Unit: Meter per second squared (m/s^2)
    r3e_vec3_f32 local_acceleration;
	
    // Unit: Kilograms (kg)
    // Note: Car + penalty weight + fuel
    r3e_float32 total_mass;
    // Unit: Liters (l)
    // Note: Fuel per lap show estimation when not enough data, then max recorded fuel per lap
    // Note: Not valid for remote players
    r3e_float32 fuel_left;
    r3e_float32 fuel_capacity;
    r3e_float32 fuel_per_lap;
    // Unit: Celsius (C)
    // Note: Not valid for AI or remote players
    r3e_float32 engine_water_temp;
    r3e_float32 engine_oil_temp;
    // Unit: Kilopascals (KPa)
    // Note: Not valid for AI or remote players
    r3e_float32 fuel_pressure;
    r3e_float32 engine_oil_pressure;
    // Unit: (Bar)
    // Note: Not valid for AI or remote players (-1.0 = N/A)
    r3e_float32 turbo_pressure;

    // How pressed the throttle pedal is
    // Range: 0.0 - 1.0 (-1.0 = N/A)
    // Note: Not valid for AI or remote players
    r3e_float32 throttle;
    r3e_float32 throttle_raw;
    // How pressed the brake pedal is
    // Range: 0.0 - 1.0 (-1.0 = N/A)
    // Note: Not valid for AI or remote players
    r3e_float32 brake;
    r3e_float32 brake_raw;
    // How pressed the clutch pedal is
    // Range: 0.0 - 1.0 (-1.0 = N/A)
    // Note: Not valid for AI or remote players
    r3e_float32 clutch;
    r3e_float32 clutch_raw;
    // How much the steering wheel is turned
    // Range: -1.0 - 1.0
    // Note: Not valid for AI or remote players
    r3e_float32 steer_input_raw;
    // How many degrees in steer lock (center to full lock)
    // Note: Not valid for AI or remote players
    r3e_int32 steer_lock_degrees;
    // How many degrees in wheel range (degrees full left to rull right)
    // Note: Not valid for AI or remote players
    r3e_int32 steer_wheel_range_degrees;

	// Aid settings
	r3e_aid_settings aid_settings;

    // DRS data
    r3e_drs drs;

    // Pit limiter (-1 = N/A, 0 = inactive, 1 = active)
    r3e_int32 pit_limiter;

    // Push to pass data
    r3e_push_to_pass push_to_pass;

    // How much the vehicle's brakes are biased towards the back wheels (0.3 = 30%, etc.) (-1.0 = N/A)
    // Note: Not valid for AI or remote players
    r3e_float32 brake_bias;

    // DRS activations available in total (-1 = N/A or endless), placed outside of drs struct to keep backwards compatibility
    r3e_int32 drs_numActivationsTotal;

    // PTP activations available in total (-1 = N/A, or there's no restriction per lap, or endless), placed outside of ptp struct to keep backwards compatibility
    r3e_int32 ptp_numActivationsTotal;

    // Reserved data
    r3e_float32 vehicle_unused1;
    r3e_float32 vehicle_unused2;
    r3e_ori_f32 vehicle_unused3;

    //////////////////////////////////////////////////////////////////////////
    // Tires
    //////////////////////////////////////////////////////////////////////////

    // Which type of tires the car has (option, prime, etc.)
    // Note: See the r3e_tire_type enum, deprecated - use the values further down instead
    r3e_int32 tire_type;
    // Rotation speed
    // Uint: Radians per second
    r3e_float32 tire_rps[R3E_TIRE_INDEX_MAX];
    // Wheel speed
    // Uint: Meters per second
    r3e_float32 tire_speed[R3E_TIRE_INDEX_MAX];
    // Range: 0.0 - 1.0 (-1.0 = N/A)
    r3e_float32 tire_grip[R3E_TIRE_INDEX_MAX];
    // Range: 0.0 - 1.0 (-1.0 = N/A)
    r3e_float32 tire_wear[R3E_TIRE_INDEX_MAX];
    // (-1 = N/A, 0 = false, 1 = true)
    r3e_int32 tire_flatspot[R3E_TIRE_INDEX_MAX];
    // Unit: Kilopascals (KPa) (-1.0 = N/A)
    // Note: Not valid for AI or remote players
    r3e_float32 tire_pressure[R3E_TIRE_INDEX_MAX];
    // Percentage of dirt on tire (-1.0 = N/A)
    // Range: 0.0 - 1.0
    r3e_float32 tire_dirt[R3E_TIRE_INDEX_MAX];
    // Current temperature of three points across the tread of the tire (-1.0 = N/A)
    // Optimum temperature
    // Cold temperature
    // Hot temperature
    // Unit: Celsius (C)
    // Note: Not valid for AI or remote players
    r3e_tire_temp tire_temp[R3E_TIRE_INDEX_MAX];
	// Which type of tires the car has (option, prime, etc.)
	// Note: See the r3e_tire_type enum
	r3e_int32 tire_type_front;
	r3e_int32 tire_type_rear;
	// Which subtype of tires the car has
	// Note: See the r3e_tire_subtype enum
	r3e_int32 tire_subtype_front;
	r3e_int32 tire_subtype_rear;
    // Current brake temperature (-1.0 = N/A)
    // Optimum temperature
    // Cold temperature
    // Hot temperature
    // Unit: Celsius (C)
    // Note: Not valid for AI or remote players
    r3e_brake_temp brake_temp[R3E_TIRE_INDEX_MAX];
    // Brake pressure (-1.0 = N/A)
    // Unit: Kilo Newtons (kN)
    // Note: Not valid for AI or remote players
    r3e_float32 brake_pressure[R3E_TIRE_INDEX_MAX];

    //////////////////////////////////////////////////////////////////////////
    // Electronics
    //////////////////////////////////////////////////////////////////////////
	
    // -1 = N/A
    r3e_int32 traction_control_setting;
    r3e_int32 engine_map_setting;
    r3e_int32 engine_brake_setting;
	
    // Reserved data
    r3e_float32 tire_unused1;
    r3e_float32 tire_unused2[R3E_TIRE_INDEX_MAX];

    // Tire load (N)
    // -1.0 = N/A
    r3e_float32 tire_load[R3E_TIRE_INDEX_MAX];

    //////////////////////////////////////////////////////////////////////////
    // Damage
    //////////////////////////////////////////////////////////////////////////

    // The current state of various parts of the car
    // Note: Not valid for AI or remote players
    r3e_car_damage car_damage;

    //////////////////////////////////////////////////////////////////////////
    // Driver info
    //////////////////////////////////////////////////////////////////////////

    // Number of cars (including the player) in the race
    r3e_int32 num_cars;

    // Contains name and basic vehicle info for all drivers in place order
    r3e_driver_data all_drivers_data_1[R3E_NUM_DRIVERS_MAX];
} r3e_shared;

#pragma pack(pop)
