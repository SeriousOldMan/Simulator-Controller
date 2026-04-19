#pragma once

typedef int ACEVO_STATUS;
#define AC_OFF 0
#define AC_REPLAY 1
#define AC_LIVE 2
#define AC_PAUSE 3

typedef int ACEVO_SESSION_TYPE;
#define AC_UNKNOWN -1
#define AC_TIME_ATTACK 0
#define AC_RACE 1
#define AC_HOT_STINT 2
#define AC_CRUISE 3

typedef int ACEVO_FLAG_TYPE;
#define AC_NO_FLAG 0
#define AC_WHITE_FLAG 1
#define AC_GREEN_FLAG 2
#define AC_RED_FLAG 3
#define AC_BLUE_FLAG 4
#define AC_YELLOW_FLAG 5
#define AC_BLACK_FLAG 6
#define AC_BLACK_WHITE_FLAG 7
#define AC_CHECKERED_FLAG 8
#define AC_ORANGE_CIRCLE_FLAG 9
#define AC_RED_YELLOW_STRIPES_FLAG 10

typedef int ACEVO_CAR_LOCATION;
#define ACEVO_UNASSIGNED 0
#define ACEVO_PITLANE 1
#define ACEVO_PITENTRY 2
#define ACEVO_PITEXIT 3
#define ACEVO_TRACK 4

typedef int ACEVO_ENGINE_TYPE;
#define ACEVO_INTERNAL_COMBUSTION 0
#define ACEVO_ELECTRIC_MOTOR 1

typedef int ACEVO_STARTING_GRIP;
#define ACEVO_GREEN 0
#define ACEVO_FAST 1
#define ACEVO_OPTIMUM 2

//

#pragma pack(push)
#pragma pack(4)

struct SPageFilePhysics {

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
	float waterTemp = 0.0f;
	float brakeTorque[4];

	int frontBrakeCompound = 0;
	int rearBrakeCompound = 0;
	float padLife[4];
	float discLife[4];
	int ignitionOn = 0;
	int starterEngineOn = 0;
	int isEngineRunning = 0;

	float kerbVibration = 0.0f;
	float slipVibrations = 0.0f;
	float roadVibrations = 0.0f;
	float absVibrations = 0.0f;
};

struct SMEvoTyreState {
	float slip = 0.f;
	bool lock = 0;
	float tyre_pression = 0.f;
	float tyre_temperature_c = 0.f;
	float brake_temperature_c = 0.f;
	float brake_pressure = 0.f;
	float tyre_temperature_left = 0.f;
	float tyre_temperature_center = 0.f;
	float tyre_temperature_right = 0.f;
	char tyre_compound_front[33];
	char tyre_compound_rear[33];

	float tyre_normalized_pressure = 0.f;
	float tyre_normalized_temperature_left = 0.f;
	float tyre_normalized_temperature_center = 0.f;
	float tyre_normalized_temperature_right = 0.f;
	float brake_normalized_temperature = 0.f;
	float tyre_normalized_temperature_core = 0.f;

	char place_holder[128];
};
static_assert(sizeof(SMEvoTyreState) == 256, "SMEvoTyreState must be 256 bytes");

struct SMEvoDamageState {
	float damage_front = 0.f;
	float damage_rear = 0.f;
	float damage_left = 0.f;
	float damage_right = 0.f;
	float damage_center = 0.f;
	float damage_suspension_lf = 0.f;
	float damage_suspension_rf = 0.f;
	float damage_suspension_lr = 0.f;
	float damage_suspension_rr = 0.f;
	char place_holder[92];
};
static_assert(sizeof(SMEvoDamageState) == 128, "SMEvoDamageState must be 128 bytes");

struct SMEvoPitInfo {
	int8_t damage = 0;	 // (-1 == will not repair damage, 0 = damage repaired, 1 = repairing damage)
	int8_t fuel = 0;	 // (-1 == will not refuel, 0 = refueled, 1 = refueling)
	int8_t tyres_lf = 0; // (-1 == will not change, 0 = changed, 1 = changing)
	int8_t tyres_rf = 0;
	int8_t tyres_lr = 0;
	int8_t tyres_rr = 0;
	char place_holder[58];
};
static_assert(sizeof(SMEvoPitInfo) == 64, "SMEvoPitInfo must be 64 bytes");

struct SMEvoElectronics {
	int8_t tc_level = 0;
	int8_t tc_cut_level = 0;
	int8_t abs_level = 0;
	int8_t esc_level = 0;
	int8_t ebb_level = 0;
	float brake_bias = 0.0f;
	int8_t engine_map_level = 0;
	float turbo_level = 0.0f;
	int8_t ers_deployment_map = 0;
	float ers_recharge_map = 0.0f;
	bool is_ers_heat_charging_on = false;
	bool is_ers_overtake_mode_on = false;
	bool is_drs_open = false;
	int8_t diff_power_level = 0;
	int8_t diff_coast_level = 0;
	int8_t front_bump_damper_level = 0;
	int8_t front_rebound_damper_level = 0;
	int8_t rear_bump_damper_level = 0;
	int8_t rear_rebound_damper_level = 0;
	bool is_ignition_on = false;
	bool is_pitlimiter_on = false;
	int8_t active_performance_mode = 0;

	char place_holder[88];
};
static_assert(sizeof(SMEvoElectronics) == 128, "SMEvoElectronics must be 128 bytes");

struct SMEvoInstrumentation {
	int8_t main_light_stage = 0;
	int8_t special_light_stage = 0;
	int8_t cockpit_light_stage = 0;

	int8_t wiper_level = 0;
	bool rain_lights = false;
	bool direction_light_left = false;
	bool direction_light_right = false;
	bool flashing_lights = false;
	bool warning_lights = false;

	int8_t selected_display_index = 0;

	int8_t display_current_page_index[16];

	bool are_headlights_visible = false;

	char place_holder[101];
};
static_assert(sizeof(SMEvoInstrumentation) == 128, "SMEvoInstrumentation must be 128 bytes");

struct SMEvoSessionState {
	char phase_name[33];

	char time_left[15];
	int32_t time_left_ms = 0;
	char wait_time[15];
	int32_t total_lap = 0;
	int32_t current_lap = 0;
	int32_t lights_on = 0;
	int32_t lights_mode = 0;
	float lap_length_km = 0.f;

	int32_t end_session_flag = 0;

	char time_to_next_session[15];
	bool disconnected_from_server = false;
	bool restart_season_enabled = false;

	bool ui_enable_drive = false;
	bool ui_enable_setup = false;

	bool is_ready_to_next_blinking = false;
	bool show_waiting_for_players = false;

	char place_holder[140];
};
static_assert(sizeof(SMEvoSessionState) == 256, "SMEvoSessionState must be 256 bytes");

struct SMEvoTimingState {
	char current_laptime[15];	 // formatted text
	char delta_current[15];		 // formatted text
	int32_t delta_current_p = 0; // 1 positive, -1 negative, 0 don't display
	char last_laptime[15];		 // formatted text
	char delta_last[15];		 // formatted text
	int32_t delta_last_p = 0;	 // 1 positive, -1 negative, 0 don't display
	char best_laptime[15];		 // formatted text
	char ideal_laptime[15];		 // formatted text
	char total_time[15]; // formatted text
	bool is_invalid = false;

	char place_holder[137];
};
static_assert(sizeof(SMEvoTimingState) == 256, "SMEvoTimingState must be 256 bytes");

struct SMEvoAssistsState {
	uint8_t auto_gear = 0;
	uint8_t auto_blip = 0;
	uint8_t auto_clutch = 0;
	uint8_t auto_clutch_on_start = 0;
	uint8_t manual_ignition_e_start = 0;
	uint8_t auto_pit_limiter = 0;
	uint8_t standing_start_assist = 0;

	float auto_steer = 0.f;
	float arcade_stability_control = 0.f;

	char place_holder[48];
};
static_assert(sizeof(SMEvoAssistsState) == 64, "SMEvoAssistsState must be 64 bytes");

struct SPageFileGraphicEvo {
	int packetId = 0; //
	ACEVO_STATUS status = AC_OFF;

	uint64_t focused_car_id_a = 0;
	uint64_t focused_car_id_b = 0;

	uint64_t player_car_id_a = 0;
	uint64_t player_car_id_b = 0;

	unsigned short rpm = 0;

	bool is_rpm_limiter_on = false;
	bool is_change_up_rpm = false;
	bool is_change_down_rpm = false;
	bool tc_active = false;
	bool abs_active = false;
	bool esc_active = false;
	bool launch_active = false;
	bool is_ignition_on = false;
	bool is_engine_running = false;
	bool kers_is_charging = false;
	bool is_wrong_way = false;
	bool is_drs_available = false;
	bool battery_is_charging = false;
	bool is_max_kj_per_lap_reached = false;
	bool is_max_charge_kj_per_lap_reached = false;

	short display_speed_kmh = 0;
	short display_speed_mph = 0;
	short display_speed_ms = 0;

	float pitspeeding_delta = 0.f;
	short gear_int = 0;

	float rpm_percent = 0.f;
	float gas_percent = 0.f;
	float brake_percent = 0.f;
	float handbrake_percent = 0.f;
	float clutch_percent = 0.f;
	float steering_percent = 0.f;

	float ffb_strength = 0.f;
	float car_ffb_mupliplier = 0.f;

	float water_temperature_percent = 0.f;

	float water_pressure_bar = 0.f;
	float fuel_pressure_bar = 0.f;

	int8_t water_temperature_c = 0;
	int8_t air_temperature_c = 0;
	float oil_temperature_c = 0.f;
	float oil_pressure_bar = 0.f;
	float exhaust_temperature_c = 0.f;

	float g_forces_x = 0.f;
	float g_forces_y = 0.f;
	float g_forces_z = 0.f;

	float turbo_boost = 0.f;
	float turbo_boost_level = 0.f;
	float turbo_boost_perc = 0.f;

	int32_t steer_degrees = 0;
	float current_km = 0.f;
	uint32_t total_km = 0;
	uint32_t total_driving_time_s = 0;

	int32_t time_of_day_hours = 0;
	int32_t time_of_day_minutes = 0;
	int32_t time_of_day_seconds = 0;

	int32_t delta_time_ms = 0;
	int32_t current_lap_time_ms = 0;
	int32_t predicted_lap_time_ms = 0;

	float fuel_liter_current_quantity = 0.f;
	float fuel_liter_current_quantity_percent = 0.f;
	float fuel_liter_per_km = 0.f;
	float km_per_fuel_liter = 0.f;

	float current_torque = 0.f;
	int32_t current_bhp = 0;

	SMEvoTyreState tyre_lf{};
	SMEvoTyreState tyre_rf{};
	SMEvoTyreState tyre_lr{};
	SMEvoTyreState tyre_rr{};

	float npos = 0.f;

	float kers_charge_perc = 0.f;
	float kers_current_perc = 0.f;

	float control_lock_time = 0.f;

	SMEvoDamageState car_damage{};

	ACEVO_CAR_LOCATION car_location = 0;

	SMEvoPitInfo pit_info{};

	float fuel_liter_used = 0.f;
	float fuel_liter_per_lap = 0.f;
	float laps_possible_with_fuel = 0.f;

	float battery_temperature = 0.f;
	float battery_voltage = 0.f;

	float instantaneous_fuel_liter_per_km = 0.f;
	float instantaneous_km_per_fuel_liter = 0.f;

	float gear_rpm_window = 0.f; // 1 is full ok

	SMEvoInstrumentation instrumentation{};
	SMEvoInstrumentation instrumentation_min_limit{};
	SMEvoInstrumentation instrumentation_max_limit{};

	SMEvoElectronics electronics{};
	SMEvoElectronics electronics_min_limit{};
	SMEvoElectronics electronics_max_limit{};
	SMEvoElectronics electronics_is_modifiable{};

	int32_t total_lap_count = 0;
	uint32_t current_pos = 0;
	uint32_t total_drivers = 0;

	int32_t last_laptime_ms = 0;
	int32_t best_laptime_ms = 0;

	ACEVO_FLAG_TYPE flag = 0;
	ACEVO_FLAG_TYPE global_flag = 0;

	uint32_t max_gears = 0;
	ACEVO_ENGINE_TYPE engine_type = 0;
	bool has_kers = false;
	bool is_last_lap = false;

	char performance_mode_name[33];
	float diff_coast_raw_value = 0.f;
	float diff_power_raw_value = 0.f;

	int32_t race_cut_gained_time_ms = 0;
	int32_t distance_to_deadline = 0;
	float race_cut_current_delta = 0.f;

	SMEvoSessionState session_state{};
	SMEvoTimingState timing_state{};

	int32_t player_ping = 0;
	int32_t player_latency = 0;
	int32_t player_cpu_usage = 0;
	int32_t player_cpu_usage_avg = 0;
	int32_t player_qos = 0;
	int32_t player_qos_avg = 0;
	int32_t player_fps = 0;
	int32_t player_fps_avg = 0;

	char driver_name[33];
	char driver_surname[33];
	char car_model[33];

	bool is_in_pit_box = 0;
	bool is_in_pit_lane = 0;
	bool is_valid_lap = false;

	float car_coordinates[60][3];

	float gap_ahead = 0;
	float gap_behind = 0;

	uint8_t active_cars = 0;
	float fuel_per_lap = 0;
	float fuel_estimated_laps = 0;

	SMEvoAssistsState assists_state{};

	float max_fuel = 0;
	float max_turbo_boost = 0;
	bool use_single_compound = false;
};

struct SPageFileStaticEvo {
	char sm_version[15];
	char ac_evo_version[15];

	ACEVO_SESSION_TYPE session = -1;

	char session_name[33];
	uint8_t event_id = 0;
	uint8_t session_id = 0;

	ACEVO_STARTING_GRIP starting_grip = 0;
	float starting_ambient_temperature_c = 0.f;
	float starting_ground_temperature_c = 0.f;

	bool is_static_weather = false;
	bool is_timed_race = 0;
	bool is_online = 0;
	int number_of_sessions = 0;

	char nation[33];
	float longitude = 0.f;
	float latitude = 0.f;

	char track[33];
	char track_configuration[33];
	float track_length_m = 0;
};

#pragma pack(pop)
