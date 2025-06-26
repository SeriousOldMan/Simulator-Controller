#include "r3e.h"
#include "utils.h"

#define _USE_MATH_DEFINES

#include <math.h>
#include <stdio.h>
#include <time.h>
#include <Windows.h>
#include <tchar.h>

#define ALIVE_SEC 600
#define INTERVAL_MS 100

HANDLE map_handle = INVALID_HANDLE_VALUE;
r3e_shared* map_buffer = NULL;

HANDLE map_open()
{
    return OpenFileMapping(
        FILE_MAP_READ,
        FALSE,
        TEXT(R3E_SHARED_MEMORY_NAME));
}

BOOL map_exists()
{
    HANDLE handle = map_open();

    if (handle != NULL)
        CloseHandle(handle);
        
    return handle != NULL;
}

int map_init()
{
    map_handle = map_open();

    if (map_handle == NULL)
    {
        return 1;
    }

    map_buffer = (r3e_shared*)MapViewOfFile(map_handle, FILE_MAP_READ, 0, 0, sizeof(r3e_shared));
    if (map_buffer == NULL)
    {
        return 1;
    }

    return 0;
}

void map_close()
{
    if (map_buffer) UnmapViewOfFile(map_buffer);
    if (map_handle) CloseHandle(map_handle);
}

int getPlayerCarID() {
    for (int i = 0; i < map_buffer->num_cars; i++)
        if (map_buffer->all_drivers_data_1[i].place == map_buffer->position)
            return i;

    return -1;
}

inline double normalize(double value) {
    return (value < 0) ? 0.0 : value;
}

inline double normalizeDamage(double value) {
    if (value < 0)
        return 0.0;
    else
        return ((1.0 - value) * 100);
}

long getRemainingTime();

long getRemainingLaps() {
    if (map_buffer->session_iteration < 1)
        return 0;

    if (map_buffer->session_type != R3E_SESSION_PRACTICE && map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) {
        return (long)(map_buffer->race_session_laps[map_buffer->session_iteration - 1] - normalize(map_buffer->completed_laps));
    }
    else {
        long time = (map_buffer->session_type != R3E_SESSION_PRACTICE) ? (long)normalize(map_buffer->lap_time_previous_self) * 1000 : (long)normalize(map_buffer->lap_time_best_self) * 1000;

        if (time > 0)
            return (long)(getRemainingTime() / time);
        else
            return 0;
    }
}

long getRemainingTime() {
    if (map_buffer->session_iteration < 1)
        return 0;

    if (map_buffer->session_type == R3E_SESSION_PRACTICE || map_buffer->session_length_format != R3E_SESSION_LENGTH_LAP_BASED) {
		long time = (long)map_buffer->session_time_remaining;
		
		if (time < 0)
			time = (long)((map_buffer->race_session_minutes[map_buffer->session_iteration - 1] * 60) -
						  (normalize(map_buffer->lap_time_best_self) * normalize(map_buffer->completed_laps)));

		if (time > 0)
			return time * 1000;
		else
			return 0;
    }
    else {
        return (long)(getRemainingLaps() * normalize(map_buffer->lap_time_previous_self)) * 1000;
    }
}

char* getPenalty(r3e_cut_track_penalties penalties) {
	if (penalties.stop_and_go > 0)
		return 0;
	else if (penalties.slow_down > 0)
		return "Slow";
	else if (penalties.time_deduction > 0)
		return "Time";
	else if (penalties.drive_through > 0)
		return "DT";
	else
		return 0;
}

void substring(char s[], char sub[], int p, int l) {
   int c = 0;
   
   while (c < l) {
      sub[c] = s[p + c];

      c++;
   }
   sub[c] = '\0';
}

void printNAValue(long value) {
	if (value == -1)
		wprintf_s(L"n/a\n");
	else
		wprintf_s(L"%d\n", value);
}

BOOL getArgument(char* output, char* request, char* key) {
	char buffer[255];

	strcpy_s(buffer, 255, key);
	strcat_s(buffer, 255 - strlen(key), "=");

	if (strncmp(request, buffer, strlen(buffer)) == 0) {
		substring(output, request, strlen(buffer), strlen(request) - strlen(buffer));

		return TRUE;
	}
	else
		return FALSE;
}

int main(int argc, char* argv[])
{
	char* request = (argc > 1) ? argv[1] : "";
	char buffer[255]; 
	int err_code = 0;
    BOOL mapped_r3e = FALSE;

    if (!mapped_r3e && map_exists())
    {
        err_code = map_init();
        
        if (err_code)
            return err_code;

        mapped_r3e = TRUE;
	}

	BOOL writeStandings = getArgument(buffer, request, "Standings");
	BOOL writeTelemetry = !writeStandings;

	writeStandings = TRUE;
	writeTelemetry = TRUE;
	
	if (writeStandings) {
		wprintf_s(L"[Position Data]\n");
		
		if (!mapped_r3e) {
			wprintf_s(L"Active=false\n");
			wprintf_s(L"Car.Count=%d\n", 0);
			wprintf_s(L"Driver.Car=%d\n", 0);
		}
		else {
			wprintf_s(L"Car.Count=%d\n", map_buffer->num_cars);
			wprintf_s(L"Driver.Car=%d\n", map_buffer->all_drivers_data_1[getPlayerCarID()].driver_info.slot_id + 1);
			
			for (int i = 1; i <= map_buffer->num_cars; ++i) {
				r3e_driver_data vehicle = map_buffer->all_drivers_data_1[i - 1];

				int position = vehicle.place;
				int id = vehicle.driver_info.slot_id + 1;

				wprintf_s(L"Car.%d.ID=%d\n", id, vehicle.driver_info.slot_id);
				wprintf_s(L"Car.%d.Nr=%d\n", id, vehicle.driver_info.car_number);
				wprintf_s(L"Car.%d.Class=%d\n", id, vehicle.driver_info.class_id);
				wprintf_s(L"Car.%d.Position=%d\n", id, position);
				wprintf_s(L"Car.%d.Laps=%d\n", id, vehicle.completed_laps);
				wprintf_s(L"Car.%d.Lap.Running=%f\n", id, (float)((double)(vehicle.lap_distance / map_buffer->lap_distance) * map_buffer->lap_distance_fraction));
				wprintf_s(L"Car.%d.Lap.Running.Valid=%s\n", id, vehicle.current_lap_valid ? L"true" : L"false");
				wprintf_s(L"Car.%d.Lap.Running.Time=%ld\n", id, (long)(normalize(vehicle.lap_time_current_self) * 1000));

				long sector1Time = (long)(normalize(vehicle.sector_time_previous_self[0]) * 1000);
				long sector2Time = (long)(normalize(vehicle.sector_time_previous_self[1]) * 1000) - sector1Time;
				long sector3Time = (long)(normalize(vehicle.sector_time_previous_self[2]) * 1000) - sector1Time - sector2Time;

				wprintf_s(L"Car.%d.Time=%ld\n", id, sector1Time + sector2Time + sector3Time);
				wprintf_s(L"Car.%d.Time.Sectors=%ld,%ld,%ld\n", id, sector1Time, sector2Time, sector3Time);

				_itoa_s(vehicle.driver_info.model_id, buffer, 32, 10);

				wprintf_s(L"Car.%d.Car=%S\n", id, buffer);
				
				char* name = (char*)vehicle.driver_info.name;
				
				if (strchr((char *)name, ' ')) {		
					char forName[100];
					char surName[100];
					char nickName[3];

					size_t length = strcspn(name, " ");

					substring(name, forName, 0, length);
					substring(name, surName, length + 1, strlen(name) - length - 1);
					nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

					wprintf_s(L"Car.%d.Driver.Forname=%S\n", id, forName);
					wprintf_s(L"Car.%d.Driver.Surname=%S\n", id, surName);
					wprintf_s(L"Car.%d.Driver.Nickname=%S\n", id, nickName);
				}
				else {
					wprintf_s(L"Car.%d.Driver.Forname=%S\n", id, name);
					wprintf_s(L"Car.%d.Driver.Surname=%S\n", id, "");
					wprintf_s(L"Car.%d.Driver.Nickname=%S\n", id, "");
				}

				wprintf_s(L"Car.%d.InPitLane=%S\n", id, vehicle.in_pitlane ? "true" : "false");
			}
		}
	}
	
	if (writeTelemetry) {
		BOOL practice = FALSE;

		wprintf_s(L"[Session Data]\n");
		wprintf_s(L"Active=%S\n", mapped_r3e ? ((map_buffer->completed_laps >= 0) ? "true" : "false") : "false");
		if (mapped_r3e) {
			wprintf_s(L"Paused=%S\n", map_buffer->game_paused ? "true" : "false");
			/*
			if (map_buffer->session_type != R3E_SESSION_PRACTICE && map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED &&
				map_buffer->race_session_laps[map_buffer->session_iteration - 1] - normalize(map_buffer->completed_laps) <= 0)
				wprintf_s(L"Session=Finished\n");
			else if (map_buffer->flags.checkered)
				wprintf_s(L"Session=Finished\n");
			else */
			if (map_buffer->session_type == R3E_SESSION_QUALIFY)
				wprintf_s(L"Session=Qualification\n");
			else if (map_buffer->session_type == R3E_SESSION_RACE)
				wprintf_s(L"Session=Race\n");
			else if ((map_buffer->session_type == R3E_SESSION_WARMUP) || (map_buffer->session_type == R3E_SESSION_PRACTICE)) {
				wprintf_s(L"Session=Practice\n");

				practice = TRUE;
			}
			else
				wprintf_s(L"Session=Other\n");
			
			_itoa_s(map_buffer->vehicle_info.model_id, buffer, 32, 10);

			wprintf_s(L"Car=%S\n", buffer);
			wprintf_s(L"Track=%S-%S\n", map_buffer->track_name, map_buffer->layout_name);
			wprintf_s(L"FuelAmount=%ld\n", (long)map_buffer->fuel_capacity);
			wprintf_s(L"SessionFormat=%S\n", (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) ? "Laps" : "Time");

			/*
			if (practice) {
				wprintf_s(L"SessionTimeRemaining=3600000\n");

				wprintf_s(L"SessionLapsRemaining=30\n");
			}
			else {
			*/
				wprintf_s(L"SessionTimeRemaining=%ld\n", getRemainingTime());

				wprintf_s(L"SessionLapsRemaining=%ld\n", getRemainingLaps());
			/*
			}
			*/
		}

		wprintf_s(L"[Car Data]\n");
		if (mapped_r3e) {
			double suspDamage = normalizeDamage(map_buffer->car_damage.suspension);

			wprintf_s(L"MAP="); printNAValue(map_buffer->engine_map_setting);
			wprintf_s(L"TC="); printNAValue(map_buffer->aid_settings.tc);
			wprintf_s(L"ABS="); printNAValue(map_buffer->aid_settings.abs);

			wprintf_s(L"BodyworkDamage=%f, %f, %f, %f, %f\n", 0.0, 0.0, 0.0, 0.0, normalizeDamage(map_buffer->car_damage.aerodynamics));
			wprintf_s(L"SuspensionDamage=%f, %f, %f, %f\n", suspDamage / 4, suspDamage / 4, suspDamage / 4, suspDamage / 4);

			double engineDamage = normalizeDamage(map_buffer->car_damage.engine);

			wprintf_s(L"EngineDamage=%f\n", (engineDamage > 20) ? round(engineDamage / 10) * 10 : 0);
			wprintf_s(L"FuelRemaining=%f\n", map_buffer->fuel_left);
			
			char tyreCompoundRaw[11] = "Unknown";
			
			if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_PRIMARY)
				strcpy_s(tyreCompoundRaw, 10, "Primary");
			else if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_ALTERNATE)
				strcpy_s(tyreCompoundRaw, 10, "Alternate");
			else if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_SOFT)
				strcpy_s(tyreCompoundRaw, 10, "Soft");
			else if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_MEDIUM)
				strcpy_s(tyreCompoundRaw, 10, "Medium");
			else if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_HARD)
				strcpy_s(tyreCompoundRaw, 10, "Hard");
				
			wprintf_s(L"TyreCompoundRaw=%S\n", tyreCompoundRaw);
			wprintf_s(L"TyreCompoundRawFront=%S\n", tyreCompoundRaw);

			if (map_buffer->tire_subtype_rear == R3E_TIRE_SUBTYPE_PRIMARY)
				strcpy_s(tyreCompoundRaw, 10, "Primary");
			else if (map_buffer->tire_subtype_rear == R3E_TIRE_SUBTYPE_ALTERNATE)
				strcpy_s(tyreCompoundRaw, 10, "Alternate");
			else if (map_buffer->tire_subtype_rear == R3E_TIRE_SUBTYPE_SOFT)
				strcpy_s(tyreCompoundRaw, 10, "Soft");
			else if (map_buffer->tire_subtype_rear == R3E_TIRE_SUBTYPE_MEDIUM)
				strcpy_s(tyreCompoundRaw, 10, "Medium");
			else if (map_buffer->tire_subtype_rear == R3E_TIRE_SUBTYPE_HARD)
				strcpy_s(tyreCompoundRaw, 10, "Hard");
			else
				strcpy_s(tyreCompoundRaw, 10, "Unknown");
			
			wprintf_s(L"TyreCompoundRawRear=%S\n", tyreCompoundRaw);
			
			wprintf_s(L"TyreTemperature=%f,%f,%f,%f\n",
				map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER]);

			wprintf_s(L"TyreInnerTemperature=%f,%f,%f,%f\n",
				map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_RIGHT],
				map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_LEFT],
				map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_RIGHT],
				map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_LEFT]);

			wprintf_s(L"TyreMiddleTemperature=%f,%f,%f,%f\n",
				map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER]);

			wprintf_s(L"TyreOuterTemperature=%f,%f,%f,%f\n",
				map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_LEFT],
				map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_RIGHT],
				map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_LEFT],
				map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_RIGHT]);

			wprintf_s(L"TyrePressure=%f,%f,%f,%f\n",
				map_buffer->tire_pressure[R3E_TIRE_FRONT_LEFT] / 6.895,
				map_buffer->tire_pressure[R3E_TIRE_FRONT_RIGHT] / 6.895,
				map_buffer->tire_pressure[R3E_TIRE_REAR_LEFT] / 6.895,
				map_buffer->tire_pressure[R3E_TIRE_REAR_RIGHT] / 6.895);
			
			if (map_buffer->tire_wear_active > 0)
				wprintf_s(L"TyreWear=%d,%d,%d,%d\n",
					(int)round(100 - normalize(map_buffer->tire_wear[R3E_TIRE_FRONT_LEFT]) * 100),
					(int)round(100 - normalize(map_buffer->tire_wear[R3E_TIRE_FRONT_RIGHT]) * 100),
					(int)round(100 - normalize(map_buffer->tire_wear[R3E_TIRE_REAR_LEFT]) * 100),
					(int)round(100 - normalize(map_buffer->tire_wear[R3E_TIRE_REAR_RIGHT]) * 100));
			else
				wprintf_s(L"TyreWear=0,0,0,0\n");
			if (map_buffer->brake_temp[R3E_TIRE_FRONT_LEFT].current_temp != -1)
				wprintf_s(L"BrakeTemperature=%f,%f,%f,%f\n",
					map_buffer->brake_temp[R3E_TIRE_FRONT_LEFT].current_temp,
					map_buffer->brake_temp[R3E_TIRE_FRONT_RIGHT].current_temp,
					map_buffer->brake_temp[R3E_TIRE_REAR_LEFT].current_temp,
					map_buffer->brake_temp[R3E_TIRE_REAR_RIGHT].current_temp);
			else
				wprintf_s(L"BrakeTemperature=0,0,0,0\n");

			if ((int)map_buffer->engine_water_temp)
				wprintf_s(L"WaterTemperature=%d\n", (int)map_buffer->engine_water_temp);

			if ((int)map_buffer->engine_oil_temp)
				wprintf_s(L"OilTemperature=%d\n", (int)map_buffer->engine_oil_temp);
		}

		wprintf_s(L"[Stint Data]\n");
		if (mapped_r3e) {
			if (strchr((char *)map_buffer->player_name, ' ')) {		
				char forName[100];
				char surName[100];
				char nickName[3];

				size_t length = strcspn((char *)map_buffer->player_name, " ");

				substring((char *)map_buffer->player_name, forName, 0, length);
				substring((char *)map_buffer->player_name, surName, length + 1, strlen((char *)map_buffer->player_name) - length - 1);
				nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

				wprintf_s(L"DriverForname=%S\n", forName);
				wprintf_s(L"DriverSurname=%S\n", surName);
				wprintf_s(L"DriverNickname=%S\n", nickName);
			}
			else {
				wprintf_s(L"DriverForname=%S\n", map_buffer->player_name);
				wprintf_s(L"DriverSurname=%S\n", "");
				wprintf_s(L"DriverNickname=%S\n", "");
			}

			wprintf_s(L"Position=%ld\n", map_buffer->all_drivers_data_1[getPlayerCarID()].place);

			wprintf_s(L"LapValid=%S\n", map_buffer->current_lap_valid ? "true" : "false");

			wprintf_s(L"LapLastTime=%ld\n", (long)(normalize(map_buffer->lap_time_previous_self) * 1000));

			if (normalize(map_buffer->lap_time_best_self))
				wprintf_s(L"LapBestTime=%ld\n", (long)(normalize(map_buffer->lap_time_best_self) * 1000));
			else
				wprintf_s(L"LapBestTime=%ld\n", (long)(normalize(map_buffer->lap_time_previous_self) * 1000));

			wprintf_s(L"Sector=%ld\n", (long)normalize(map_buffer->track_sector == 0 ? 3 : map_buffer->track_sector));
			wprintf_s(L"Laps=%ld\n", (long)normalize(map_buffer->completed_laps));

			char* penalty = getPenalty(map_buffer->penalties);

			if (penalty)
				wprintf_s(L"Penalty=%S\n", penalty);

			wprintf_s(L"Warnings=%ld\n", (long)normalize(map_buffer->cut_track_warnings));

			/*
			if (practice) {
				wprintf_s(L"StintTimeRemaining=3600000\n");
				wprintf_s(L"DriverTimeRemaining=3600000\n");
			}
			else {
			*/
				long timeRemaining = getRemainingTime();

				wprintf_s(L"StintTimeRemaining=%ld\n", timeRemaining);
				wprintf_s(L"DriverTimeRemaining=%ld\n", timeRemaining);
			/*
			}
			*/
			wprintf_s(L"InPit=%S\n", (map_buffer->pit_state == 3) ? "true" : "false");
		}

		wprintf_s(L"[Track Data]\n");
		wprintf_s(L"Length=%f\n", map_buffer->layout_length);
		wprintf_s(L"Temperature=26\n");
		wprintf_s(L"Grip=Optimum\n");

		for (int id = 0; id < map_buffer->num_cars; id++) {
			r3e_driver_data vehicle = map_buffer->all_drivers_data_1[id];

			wprintf_s(L"Car.%d.ID=%d\n", id + 1, vehicle.driver_info.slot_id);
			wprintf_s(L"Car.%d.Position=%f,%f\n", id + 1, vehicle.position.x, - vehicle.position.z);
		}

		wprintf_s(L"[Weather Data]\n");
		wprintf_s(L"Temperature=24\n");
		wprintf_s(L"Weather=Dry\n");
		wprintf_s(L"Weather10Min=Dry\n");
		wprintf_s(L"Weather30Min=Dry\n");

		wprintf_s(L"[Pit Menu State]\n");
		if (mapped_r3e) {
			wprintf(L"Selected=");

			switch (map_buffer->pit_menu_selection) {
				case R3E_PIT_MENU_UNAVAILABLE:
					wprintf(L"Unavailable\n");

					break;
				case R3E_PIT_MENU_PRESET:
					wprintf(L"Strategy\n");

					break;
				case R3E_PIT_MENU_PENALTY:
					wprintf(L"Serve Penalty\n");

					break;
				case R3E_PIT_MENU_DRIVERCHANGE:
					wprintf(L"Driver\n");

					break;
				case R3E_PIT_MENU_FUEL:
					wprintf(L"Refuel\n");

					break;
				case R3E_PIT_MENU_FRONTTIRES:
					wprintf(L"Change Front Tyres\n");

					break;
				case R3E_PIT_MENU_REARTIRES:
					wprintf(L"Change Rear Tyres\n");

					break;
				case R3E_PIT_MENU_FRONTWING:
					wprintf(L"Repair Front Aero\n");

					break;
				case R3E_PIT_MENU_REARWING:
					wprintf(L"Repair Rear Aero\n");

					break;
				/*
				case R3E_PIT_MENU_SUSPENSION:
					wprintf(L"Repair Suspension\n");

					break;
				*/
				case R3E_PIT_MENU_BUTTON_TOP:
					wprintf(L"Top Button\n");

					break;
				case R3E_PIT_MENU_BUTTON_BOTTOM:
					wprintf(L"Bottom Button\n");

					break;
				case R3E_PIT_MENU_MAX:
					wprintf(L"false\n");

					break;
				default:
					wprintf(L"false\n");

					break;
			}

			for (int i = 0; i < R3E_PIT_MENU_MAX; i++) {
				switch (i) {
					case R3E_PIT_MENU_PRESET:
						wprintf(L"Strategy=");

						break;
					case R3E_PIT_MENU_PENALTY:
						wprintf(L"Serve Penalty=");

						break;
					case R3E_PIT_MENU_DRIVERCHANGE:
						wprintf(L"Driver=");

						break;
					case R3E_PIT_MENU_FUEL:
						wprintf(L"Refuel=");

						break;
					case R3E_PIT_MENU_FRONTTIRES:
						wprintf(L"Change Front Tyres=");

						break;
					case R3E_PIT_MENU_REARTIRES:
						wprintf(L"Change Rear Tyres=");

						break;
					case R3E_PIT_MENU_FRONTWING:
						wprintf(L"Repair Front Aero=");

						break;
					case R3E_PIT_MENU_REARWING:
						wprintf(L"Repair Rear Aero=");

						break;
					/*
					case R3E_PIT_MENU_SUSPENSION:
						wprintf(L"Repair Suspension=");

						break;
					*/
					case R3E_PIT_MENU_BUTTON_TOP:
						wprintf(L"Top Button=");

						break;
					case R3E_PIT_MENU_BUTTON_BOTTOM:
						wprintf(L"Bottom Button=");

						break;
					default:
						wprintf(L"Unknown=");

						break;
				}

				switch (map_buffer->pit_menu_state[i]) {
					case 0:
						wprintf(L"false\n");

						break;
					case 1:
						wprintf(L"true\n");

						break;
					default:
						wprintf(L"Unavailable\n");

						break;
				}
			}

			wprintf(L"\n");
		}

		wprintf_s(L"[Test Data]\n");
		if (mapped_r3e) {
			wprintf_s(L"Aero Damage=%f\n", map_buffer->car_damage.aerodynamics);
			wprintf_s(L"Susp Damage=%f\n", map_buffer->car_damage.suspension);
			wprintf_s(L"Lap Time=%f\n", map_buffer->lap_time_current_self);
			wprintf_s(L"Best Lap Time=%f\n", map_buffer->lap_time_best_self);
			wprintf_s(L"Prev Lap Time=%f\n", map_buffer->lap_time_previous_self);
			wprintf_s(L"Session Index=%d\n", map_buffer->session_iteration);
			if (map_buffer->session_iteration >= 0) {
				wprintf_s(L"Session Minutes=%d\n", map_buffer->race_session_minutes[map_buffer->session_iteration - 1]);
				wprintf_s(L"Session Laps=%d\n", map_buffer->race_session_laps[map_buffer->session_iteration - 1]);
			}
			wprintf_s(L"Completed Laps=%d\n", map_buffer->completed_laps);
			wprintf_s(L"Session Format=%d\n", map_buffer->session_length_format);
			wprintf_s(L"Pit State=%d\n", map_buffer->pit_state);
			wprintf_s(L"Tyre Type=%d\n", map_buffer->tire_type_front);
			wprintf_s(L"Tyre Subtype=%d\n", map_buffer->tire_subtype_front);
		}
	}

    map_close();

    return 0;
}