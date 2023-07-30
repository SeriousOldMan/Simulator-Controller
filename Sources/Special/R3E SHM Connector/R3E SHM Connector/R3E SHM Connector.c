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
        long time = (map_buffer->session_type != R3E_SESSION_PRACTICE) ? (long)map_buffer->lap_time_previous_self * 1000 : (long)map_buffer->lap_time_best_self * 1000;

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
        long time = (long)((map_buffer->race_session_minutes[map_buffer->session_iteration - 1] * 60) -
						   (normalize(map_buffer->lap_time_best_self) * normalize(map_buffer->completed_laps)));

		if (time > 0)
			return time * 1000;
		else
			return 0;
    }
    else {
        return (long)(getRemainingLaps() * map_buffer->lap_time_previous_self) * 1000;
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

inline void writeString(char* output, char* str, int* pos) {
	for (int i = 0; i < strlen(str); i++) {
		output[*pos] = str[i];

		(*pos) += 1;
	}
}

inline void writeInt(char* output, long nr, int* pos) {
	char buffer[128];

	sprintf_s(buffer, 128, "%ld", nr);

	writeString(output, buffer, pos);
}

inline void writeFloat(char* output, float nr, int* pos) {
	char buffer[128];

	sprintf_s(buffer, 128, "%f", nr);

	writeString(output, buffer, pos);
}

inline void writeLine(char* output, int* pos) {
	writeString(output, "\n", pos);
}

inline void writeStringOption(char* output, char* str, char* value, int* pos) {
	writeString(output, str, pos);
	writeString(output, value, pos);
	writeLine(output, pos);
}

inline void writeIntOption(char* output, char* str, long nr, int* pos) {
	writeString(output, str, pos);
	writeInt(output, nr, pos);
	writeLine(output, pos);
}

inline void writeFloatOption(char* output, char* str, float nr, int* pos) {
	writeString(output, str, pos);
	writeFloat(output, nr, pos);
	writeLine(output, pos);
}

inline void writeNAValue(char* output, long value, int* pos) {
	if (value == -1)
		writeString(output, "n/a", pos);
	else
		writeInt(output, value, pos);
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

BOOL mapped_r3e = FALSE;

extern __declspec(dllexport) int __stdcall open() {
	if (!mapped_r3e && map_exists())
	{
		int err_code = map_init();

		if (err_code)
			return err_code;

		mapped_r3e = TRUE;
	}

	return mapped_r3e ? 0 : -1;
}

extern __declspec(dllexport) int __stdcall close() {
	map_close();

	return 0;
}

extern __declspec(dllexport) int __stdcall call(char* request, char* result, int size) {
	char buffer[255];
	int pos = 0;

	BOOL writeStandings = getArgument(buffer, request, "Standings");
	BOOL writeTelemetry = !writeStandings;

	if (writeStandings) {
		writeString(result, "[Position Data]\n", &pos);

		if (!mapped_r3e) {
			writeString(result, "Active=false\n", &pos);
			writeString(result, "Car.Count=0\n", &pos);
			writeString(result, "Driver.Car=0\n", &pos);
		}
		else {
			writeIntOption(result, "Car.Count=", map_buffer->num_cars, &pos);
			writeIntOption(result, "Driver.Car=", getPlayerCarID() + 1, &pos);

			for (int i = 1; i <= map_buffer->num_cars; ++i) {
				r3e_driver_data vehicle = map_buffer->all_drivers_data_1[i - 1];

				int position = vehicle.place;

				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".ID=", vehicle.driver_info.slot_id, &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".Nr=", vehicle.driver_info.car_number, &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".Class=", vehicle.driver_info.class_id, &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".Position=", position, &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".Laps=", vehicle.completed_laps, &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeFloatOption(result, ".Lap.Running=", (float)((double)(vehicle.lap_distance / map_buffer->lap_distance) * map_buffer->lap_distance_fraction), &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeString(result, vehicle.current_lap_valid ? "true\n" : "false\n", &pos);

				long sector1Time = ((long)vehicle.sector_time_previous_self[0] * 1000);
				long sector2Time = ((long)vehicle.sector_time_previous_self[1] * 1000);
				long sector3Time = ((long)vehicle.sector_time_previous_self[2] * 1000);

				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".Time=", sector1Time + sector2Time + sector3Time, &pos);
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeString(result, ".Time.Sectors=", &pos);
				writeInt(result, sector1Time, &pos); writeString(result, ",", &pos);
				writeInt(result, sector2Time, &pos); writeString(result, ",", &pos);
				writeInt(result, sector3Time, &pos); writeLine(result, &pos);

				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeIntOption(result, ".Car=", vehicle.driver_info.model_id, &pos);
				
				char* name = (char*)vehicle.driver_info.name;

				if (strchr((char*)name, ' ')) {
					char forName[100];
					char surName[100];
					char nickName[10];

					size_t length = strcspn(name, " ");

					substring(name, forName, 0, length);
					substring(name, surName, length + 1, strlen(name) - length - 1);
					nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

					writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".Driver.Forname=", forName, &pos);
					writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".Driver.Surname=", surName, &pos);
					writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".Driver.Nickname=", nickName, &pos);
				}
				else {
					writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".Driver.Forname=", name, &pos);
					writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".Driver.Surname=", "", &pos);
					writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".Driver.Nickname=", "", &pos);
				}

				
				writeString(result, "Car.", &pos); writeInt(result, i, &pos); writeStringOption(result, ".InPitLane=", vehicle.in_pitlane ? "true" : "false", &pos);
			}
		}
	}

	if (writeTelemetry) {
		BOOL practice = FALSE;

		writeString(result, "[Session Data]\n", &pos);
		writeStringOption(result, "Active=", mapped_r3e ? ((map_buffer->completed_laps >= 0) ? "true" : "false") : "false", &pos);
		if (mapped_r3e) {
			writeStringOption(result, "Paused=", map_buffer->game_paused ? "true" : "false", &pos);
			
			if (map_buffer->session_type != R3E_SESSION_PRACTICE && map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED &&
				map_buffer->race_session_laps[map_buffer->session_iteration - 1] - normalize(map_buffer->completed_laps) <= 0)
				writeString(result, "Session=Finished\n", &pos);
			else if (map_buffer->session_type == R3E_SESSION_QUALIFY)
				writeString(result, "Session=Qualification\n", &pos);
			else if (map_buffer->session_type == R3E_SESSION_RACE)
				writeString(result, "Session=Race\n", &pos);
			else if (map_buffer->session_type == R3E_SESSION_PRACTICE) {
				writeString(result, "Session=Practice\n", &pos);

				practice = TRUE;
			}
			else
				writeString(result, "Session=Other\n", &pos);

			writeIntOption(result, "Car=", map_buffer->vehicle_info.model_id, &pos);
			
			writeString(result, "Track=", &pos); writeString(result, map_buffer->track_name, &pos); writeString(result, "-", &pos); writeString(result, map_buffer->layout_name, &pos); writeLine(result, &pos);
			writeIntOption(result, "FuelAmount=", (long)map_buffer->fuel_capacity , &pos);
			writeStringOption(result, "SessionFormat=", (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) ? "Laps" : "Time", &pos);

			writeIntOption(result, "SessionTimeRemaining=", getRemainingTime(), &pos);
			writeIntOption(result, "SessionLapsRemaining=", getRemainingLaps(), &pos);
		}

		writeString(result, "[Car Data]\n", &pos);
		if (mapped_r3e) {
			double suspDamage = normalizeDamage(map_buffer->car_damage.suspension);

			writeString(result, "MAP=", &pos); writeNAValue(result, map_buffer->engine_map_setting, &pos); writeLine(result, &pos);
			writeString(result, "TC=", &pos); writeNAValue(result, map_buffer->aid_settings.tc, &pos); writeLine(result, &pos);
			writeString(result, "ABS=", &pos); writeNAValue(result, map_buffer->aid_settings.abs, &pos); writeLine(result, &pos);

			writeString(result, "BodyworkDamage=", &pos);
			writeFloat(result, 0.0, &pos); writeString(result, ", ", &pos);
			writeFloat(result, 0.0, &pos); writeString(result, ", ", &pos);
			writeFloat(result, 0.0, &pos); writeString(result, ", ", &pos);
			writeFloat(result, 0.0, &pos); writeString(result, ", ", &pos);
			writeFloat(result, normalizeDamage(map_buffer->car_damage.aerodynamics), &pos); writeLine(result, &pos);

			writeString(result, "SuspensionDamage=", &pos);
			writeFloat(result, suspDamage, &pos); writeString(result, ", ", &pos);
			writeFloat(result, suspDamage, &pos); writeString(result, ", ", &pos);
			writeFloat(result, suspDamage, &pos); writeString(result, ", ", &pos);
			writeFloat(result, suspDamage, &pos); writeLine(result, &pos);

			double engineDamage = normalizeDamage(map_buffer->car_damage.engine);

			writeFloatOption(result, "EngineDamage=", (engineDamage > 20) ? round(engineDamage / 10) * 10 : 0, &pos);

			writeFloatOption(result, "FuelRemaining=", map_buffer->fuel_left, &pos);

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

			writeStringOption(result, "TyreCompoundRaw=", tyreCompoundRaw, &pos);

			writeString(result, "TyreTemperature=", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeLine(result, &pos);

			writeString(result, "TyreInnerTemperature=", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_RIGHT], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_LEFT], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_RIGHT], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_LEFT], &pos); writeLine(result, &pos);

			writeString(result, "TyreMiddleTemperature=", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER], &pos); writeLine(result, &pos);

			writeString(result, "TyreOuterTemperature=", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_LEFT], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_RIGHT], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_LEFT], &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_RIGHT], &pos); writeLine(result, &pos);
			
			writeString(result, "TyrePressure=", &pos);
			writeFloat(result, map_buffer->tire_pressure[R3E_TIRE_FRONT_LEFT] / 6.895, &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_pressure[R3E_TIRE_FRONT_RIGHT] / 6.895, &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_pressure[R3E_TIRE_REAR_LEFT] / 6.895, &pos); writeString(result, ", ", &pos);
			writeFloat(result, map_buffer->tire_pressure[R3E_TIRE_REAR_RIGHT] / 6.895, &pos); writeLine(result, &pos);
			
			if (map_buffer->tire_wear_active > 0) {
				writeString(result, "TyreWear=", &pos);
				writeFloat(result, (int)round(normalize(map_buffer->tire_wear[R3E_TIRE_FRONT_LEFT]) * 100), &pos); writeString(result, ", ", &pos);
				writeFloat(result, (int)round(normalize(map_buffer->tire_wear[R3E_TIRE_FRONT_RIGHT]) * 100), &pos); writeString(result, ", ", &pos);
				writeFloat(result, (int)round(normalize(map_buffer->tire_wear[R3E_TIRE_REAR_LEFT]) * 100), &pos); writeString(result, ", ", &pos);
				writeFloat(result, (int)round(normalize(map_buffer->tire_wear[R3E_TIRE_REAR_RIGHT]) * 100), &pos); writeLine(result, &pos);
			}
			else
				writeString(result, "TyreWear=0,0,0,0\n", &pos);

			if (map_buffer->brake_temp[R3E_TIRE_FRONT_LEFT].current_temp != -1) {
				writeString(result, "BrakeTemperature=", &pos);
				writeFloat(result, map_buffer->brake_temp[R3E_TIRE_FRONT_LEFT].current_temp, &pos); writeString(result, ", ", &pos);
				writeFloat(result, map_buffer->brake_temp[R3E_TIRE_FRONT_RIGHT].current_temp, &pos); writeString(result, ", ", &pos);
				writeFloat(result, map_buffer->brake_temp[R3E_TIRE_REAR_LEFT].current_temp, &pos); writeString(result, ", ", &pos);
				writeFloat(result, map_buffer->brake_temp[R3E_TIRE_REAR_RIGHT].current_temp, &pos); writeLine(result, &pos);
			}
			else
				writeString(result, "BrakeTemperature=0,0,0,0\n", &pos);
		}

		writeString(result, "[Stint Data]\n", &pos);
		if (mapped_r3e) {
			if (strchr((char*)map_buffer->player_name, ' ')) {
				char forName[100];
				char surName[100];
				char nickName[3];

				size_t length = strcspn((char*)map_buffer->player_name, " ");

				substring((char*)map_buffer->player_name, forName, 0, length);
				substring((char*)map_buffer->player_name, surName, length + 1, strlen((char*)map_buffer->player_name) - length - 1);
				nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

				writeStringOption(result, "DriverForname=", forName, &pos);
				writeStringOption(result, "DriverSurname=", surName, &pos);
				writeStringOption(result, "DriverNickname=", nickName, &pos);
			}
			else {
				writeStringOption(result, "DriverForname=", map_buffer->player_name, &pos);
				writeStringOption(result, "DriverSurname=", "", &pos);
				writeStringOption(result, "DriverNickname=", "", &pos);
			}

			writeStringOption(result, "Position=", map_buffer->all_drivers_data_1[getPlayerCarID()].place, &pos);

			writeStringOption(result, "LapValid=", map_buffer->current_lap_valid ? "true" : "false", &pos);

			writeIntOption(result, "LapLastTime=", (long)(normalize(map_buffer->lap_time_previous_self) * 1000), &pos);

			if (normalize(map_buffer->lap_time_best_self))
				writeIntOption(result, "LapBestTime=", (long)(normalize(map_buffer->lap_time_best_self) * 1000), &pos);
			else
				writeIntOption(result, "LapBestTime=", (long)(normalize(map_buffer->lap_time_previous_self) * 1000), &pos);

			writeIntOption(result, "Sector=", (long)normalize(map_buffer->track_sector == 0 ? 3 : map_buffer->track_sector), &pos);
			writeIntOption(result, "Laps=", (long)normalize(map_buffer->completed_laps), &pos);

			char* penalty = getPenalty(map_buffer->penalties);

			if (penalty)
				writeStringOption(result, "Penalty=", penalty, &pos);

			writeIntOption(result, "Warnings=", (long)normalize(map_buffer->cut_track_warnings), &pos);

			long timeRemaining = getRemainingTime();

			writeIntOption(result, "StintTimeRemaining=", timeRemaining, &pos);
			writeIntOption(result, "DriverTimeRemaining=", timeRemaining, &pos);
			writeStringOption(result, "InPit=", (map_buffer->pit_state == 3) ? "true" : "false", &pos);
		}

		writeString(result, "[Track Data]\n", &pos);
		if (mapped_r3e) {
			writeString(result, "Temperature=26\n", &pos);
			writeString(result, "Grip=Optimum\n", &pos);

			for (int id = 0; id < map_buffer->num_cars; id++) {
				r3e_driver_data vehicle = map_buffer->all_drivers_data_1[id];

				writeString(result, "Car.", &pos); writeInt(result, id + 1, &pos); writeIntOption(result, ".ID=", vehicle.driver_info.slot_id, &pos);

				writeString(result, "Car.", &pos); writeInt(result, id + 1, &pos); writeString(result, ".Position=", &pos);
				writeFloat(result, vehicle.position.x, &pos); writeString(result, ",", &pos);
				writeFloat(result, -vehicle.position.z, &pos); writeLine(result, &pos);
			}
		}

		writeString(result, "[Weather Data]\n", &pos);
		if (mapped_r3e) {
			writeString(result, "Temperature=24\n", &pos);
			writeString(result, "Weather=Dry\n", &pos);
			writeString(result, "Weather10Min=Dry\n", &pos);
			writeString(result, "Weather30Min=Dry\n", &pos);
		}

		writeString(result, "[Pit Menu State]\n", &pos);
		if (mapped_r3e) {
			writeString(result, "Selected=", &pos);

			switch (map_buffer->pit_menu_selection) {
			case R3E_PIT_MENU_UNAVAILABLE:
				writeString(result, "Unavailable\n", &pos);

				break;
			case R3E_PIT_MENU_PRESET:
				writeString(result, "Strategy\n", &pos);

				break;
			case R3E_PIT_MENU_PENALTY:
				writeString(result, "Serve Penalty\n", &pos);

				break;
			case R3E_PIT_MENU_DRIVERCHANGE:
				writeString(result, "Driver\n", &pos);

				break;
			case R3E_PIT_MENU_FUEL:
				writeString(result, "Refuel\n", &pos);

				break;
			case R3E_PIT_MENU_FRONTTIRES:
				writeString(result, "Change Front Tyres\n", &pos);

				break;
			case R3E_PIT_MENU_REARTIRES:
				writeString(result, "Change Rear Tyres\n", &pos);

				break;
			case R3E_PIT_MENU_FRONTWING:
				writeString(result, "Repair Front Aero\n", &pos);

				break;
			case R3E_PIT_MENU_REARWING:
				writeString(result, "Repair Rear Aero\n", &pos);

				break;
				/*
				case R3E_PIT_MENU_SUSPENSION:
					writeString(result, "Repair Suspension\n", &pos);

					break;
				*/
			case R3E_PIT_MENU_BUTTON_TOP:
				writeString(result, "Top Button\n", &pos);

				break;
			case R3E_PIT_MENU_BUTTON_BOTTOM:
				writeString(result, "Bottom Button\n", &pos);

				break;
			case R3E_PIT_MENU_MAX:
				writeString(result, "false\n", &pos);

				break;
			default:
				writeString(result, "false\n", &pos);

				break;
			}

			for (int i = 0; i < R3E_PIT_MENU_MAX; i++) {
				switch (i) {
				case R3E_PIT_MENU_PRESET:
					writeString(result, "Strategy=", &pos);

					break;
				case R3E_PIT_MENU_PENALTY:
					writeString(result, "Serve Penalty=", &pos);

					break;
				case R3E_PIT_MENU_DRIVERCHANGE:
					writeString(result, "Driver=", &pos);

					break;
				case R3E_PIT_MENU_FUEL:
					writeString(result, "Refuel=", &pos);

					break;
				case R3E_PIT_MENU_FRONTTIRES:
					writeString(result, "Change Front Tyres=", &pos);

					break;
				case R3E_PIT_MENU_REARTIRES:
					writeString(result, "Change Rear Tyres=", &pos);

					break;
				case R3E_PIT_MENU_FRONTWING:
					writeString(result, "Repair Front Aero=", &pos);

					break;
				case R3E_PIT_MENU_REARWING:
					writeString(result, "Repair Rear Aero=", &pos);

					break;
					/*
					case R3E_PIT_MENU_SUSPENSION:
						writeString(result, "Repair Suspension=", &pos);

						break;
					*/
				case R3E_PIT_MENU_BUTTON_TOP:
					writeString(result, "Top Button=", &pos);

					break;
				case R3E_PIT_MENU_BUTTON_BOTTOM:
					writeString(result, "Bottom Button=", &pos);

					break;
				default:
					writeString(result, "Unknown=", &pos);

					break;
				}

				switch (map_buffer->pit_menu_state[i]) {
				case 0:
					writeString(result, "false\n", &pos);

					break;
				case 1:
					writeString(result, "true\n", &pos);

					break;
				default:
					writeString(result, "Unavailable\n", &pos);

					break;
				}
			}
		}

		writeString(result, "[Test Data]\n", &pos);
		if (mapped_r3e) {
			writeFloatOption(result, "Aero Damage=", map_buffer->car_damage.aerodynamics, &pos);
			writeFloatOption(result, "Susp Damage=", map_buffer->car_damage.suspension, &pos);
			writeFloatOption(result, "Lap Time=", map_buffer->lap_time_current_self, &pos);
			writeFloatOption(result, "Best Lap Time=", map_buffer->lap_time_best_self, &pos);
			writeFloatOption(result, "Prev Lap Time=", map_buffer->lap_time_previous_self, &pos);
			writeIntOption(result, "Session Index=", map_buffer->session_iteration, &pos);
			if (map_buffer->session_iteration >= 0) {
				writeIntOption(result, "Session Minutes=", map_buffer->race_session_minutes[map_buffer->session_iteration - 1], &pos);
				writeIntOption(result, "Session Laps=", map_buffer->race_session_laps[map_buffer->session_iteration - 1], &pos);
			}
			writeIntOption(result, "Completed Laps=", map_buffer->completed_laps, &pos);
			writeIntOption(result, "Session Format=", map_buffer->session_length_format, &pos);
			writeIntOption(result, "Pit State=", map_buffer->pit_state, &pos);
			writeIntOption(result, "Tyre Type=", map_buffer->tire_type_front, &pos);
			writeIntOption(result, "Tyre Subtype=", map_buffer->tire_subtype_front, &pos);
		}
	}

	result[pos] = '\0';

	return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}