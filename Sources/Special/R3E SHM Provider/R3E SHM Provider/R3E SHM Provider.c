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
    for (int i = 0; i < map_buffer->num_cars; i++) {
        if (map_buffer->all_drivers_data_1[i].place == map_buffer->position) {
            return i;
         }
    }

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

    if (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) {
        return (long)(map_buffer->race_session_laps[map_buffer->session_iteration - 1] - normalize(map_buffer->completed_laps));
    }
    else {
        long time = (long)map_buffer->lap_time_previous_self;

        if (time > 0)
            return (long)(getRemainingTime() / time);
        else
            return 0;
    }
}

long getRemainingTime() {
    if (map_buffer->session_iteration < 1)
        return 0;

    if (map_buffer->session_length_format != R3E_SESSION_LENGTH_LAP_BASED) {
        return (long)((map_buffer->race_session_minutes[map_buffer->session_iteration - 1] * 60) -
                      (normalize(map_buffer->lap_time_previous_self) * normalize(map_buffer->completed_laps)));
    }
    else {
        return (long)(getRemainingLaps() * map_buffer->lap_time_previous_self);
    }
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

int main(int argc, char* argv[])
{
    int err_code = 0;
    BOOL mapped_r3e = FALSE;

    if (!mapped_r3e && map_exists())
    {
        err_code = map_init();
        
        if (err_code)
            return err_code;

        mapped_r3e = TRUE;
    }
	
	if ((argc > 1) && (strcmp(argv[1], "-Standings") == 0)) {
		wprintf_s(L"[Position Data]\n");
		
		wprintf_s(L"Car.Count=%d\n", map_buffer->num_cars);
		wprintf_s(L"Driver.Car=%d\n", getPlayerCarID() + 1);
		
		for (int i = 1; i <= map_buffer->num_cars; ++i) {
			r3e_driver_data vehicle = map_buffer->all_drivers_data_1[i - 1];

			wprintf_s(L"Car.%d.Nr=%d\n", i, i);
			wprintf_s(L"Car.%d.Position=%d\n", i, vehicle.place);
			wprintf_s(L"Car.%d.Lap=%d\n", i, vehicle.completed_laps);
			wprintf_s(L"Car.%d.Lap.Running=%f\n", i, (float)((double)(vehicle.lap_distance / map_buffer->lap_distance) * map_buffer->lap_distance_fraction));
			wprintf_s(L"Car.%d.Time=%ld\n", i, (long)((vehicle.sector_time_previous_self[0] + vehicle.sector_time_previous_self[1] + vehicle.sector_time_previous_self[2]) * 1000));
			
			char buffer[33];

			_itoa_s(vehicle.driver_info.model_id, buffer, 32, 10);

			wprintf_s(L"Car.%d.Car=%S\n", i, buffer);
			
			char* name = (char*)vehicle.driver_info.name;
			
			if (strchr((char *)name, ' ')) {		
				char forName[100];
				char surName[100];
				char nickName[3];

				size_t length = strcspn(name, " ");

				substring(name, forName, 0, length);
				substring(name, surName, length + 1, strlen(name) - length - 1);
				nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

				wprintf_s(L"Car.%d.Driver.Forname=%S\n", i, forName);
				wprintf_s(L"Car.%d.Driver.Surname=%S\n", i, surName);
				wprintf_s(L"Car.%d.Driver.Nickname=%S\n", i, nickName);
			}
			else {
				wprintf_s(L"Car.%d.Driver.Forname=%S\n", i, name);
				wprintf_s(L"Car.%d.Driver.Surname=%S\n", i, "");
				wprintf_s(L"Car.%d.Driver.Nickname=%S\n", i, "");
			}
		}
	}
	else {
		wprintf_s(L"[Session Data]\n");
		wprintf_s(L"Active=%S\n", mapped_r3e ? ((map_buffer->completed_laps >= 0) ? "true" : "false") : "false");
		if (mapped_r3e) {
			wprintf_s(L"Paused=%S\n", map_buffer->game_paused ? "true" : "false");
			if (map_buffer->session_type == R3E_SESSION_QUALIFY)
				wprintf_s(L"Session=Qualification\n");
			else if (map_buffer->session_type == R3E_SESSION_RACE)
				wprintf_s(L"Session=Race\n");
			else if (map_buffer->session_type == R3E_SESSION_PRACTICE)
				wprintf_s(L"Session=Practice\n");
			else
				wprintf_s(L"Session=Other\n");
			
			char buffer[33];

			_itoa_s(map_buffer->vehicle_info.model_id, buffer, 32, 10);

			wprintf_s(L"Car=%S\n", buffer);
			wprintf_s(L"Track=%S-%S\n", map_buffer->track_name, map_buffer->layout_name);
			wprintf_s(L"FuelAmount=%ld\n", (long)map_buffer->fuel_capacity);
			wprintf_s(L"SessionFormat=%S\n", (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) ? "Lap" : "Time");

			long timeRemaining = (getRemainingTime() * 1000);

			wprintf_s(L"SessionTimeRemaining=%ld\n", timeRemaining);

			wprintf_s(L"SessionLapsRemaining=%ld\n", getRemainingLaps());
		}

		wprintf_s(L"[Car Data]\n");
		if (mapped_r3e) {

			double suspDamage = normalizeDamage(map_buffer->car_damage.suspension);

			wprintf_s(L"MAP="); printNAValue(map_buffer->engine_map_setting);
			wprintf_s(L"TC="); printNAValue(map_buffer->aid_settings.tc);
			wprintf_s(L"ABS="); printNAValue(map_buffer->aid_settings.abs);

			wprintf_s(L"BodyworkDamage=%f, %f, %f, %f, %f\n", 0.0, 0.0, 0.0, 0.0, normalizeDamage(map_buffer->car_damage.aerodynamics));
			wprintf_s(L"SuspensionDamage=%f, %f, %f, %f\n", suspDamage, suspDamage, suspDamage, suspDamage);
			wprintf_s(L"FuelRemaining=%f\n", map_buffer->fuel_left);
			
			char tyreCompoundColor[11] = "Black";
			
			if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_SOFT)
				strcpy_s(tyreCompoundColor, 10, "Red");
			else if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_MEDIUM)
				strcpy_s(tyreCompoundColor, 10, "White");
			else if (map_buffer->tire_subtype_front == R3E_TIRE_SUBTYPE_HARD)
				strcpy_s(tyreCompoundColor, 10, "Blue");
				
			wprintf_s(L"TyreCompound=Dry\n");
			wprintf_s(L"TyreCompoundColor=%S\n", tyreCompoundColor);
			wprintf_s(L"TyreTemperature = %f, %f, %f, %f\n",
				map_buffer->tire_temp[R3E_TIRE_FRONT_LEFT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_FRONT_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_REAR_LEFT].current_temp[R3E_TIRE_TEMP_CENTER],
				map_buffer->tire_temp[R3E_TIRE_REAR_RIGHT].current_temp[R3E_TIRE_TEMP_CENTER]);
			wprintf_s(L"TyrePressure = %f, %f, %f, %f\n",
				map_buffer->tire_pressure[R3E_TIRE_FRONT_LEFT] / 6.895,
				map_buffer->tire_pressure[R3E_TIRE_FRONT_RIGHT] / 6.895,
				map_buffer->tire_pressure[R3E_TIRE_REAR_LEFT] / 6.895,
				map_buffer->tire_pressure[R3E_TIRE_REAR_RIGHT] / 6.895);
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
			
			wprintf_s(L"LapLastTime=%ld\n", (long)(normalize(map_buffer->lap_time_previous_self) * 1000));

			if (normalize(map_buffer->lap_time_best_self))
				wprintf_s(L"LapBestTime=%ld\n", (long)(normalize(map_buffer->lap_time_best_self) * 1000));
			else
				wprintf_s(L"LapBestTime=%ld\n", (long)(normalize(map_buffer->lap_time_previous_self) * 1000));

			wprintf_s(L"Laps=%ld\n", (long)normalize(map_buffer->completed_laps));

			long timeRemaining = (getRemainingTime() * 1000);

			wprintf_s(L"StintTimeRemaining=%ld\n", timeRemaining);
			wprintf_s(L"DriverTimeRemaining=%ld\n", timeRemaining);
			wprintf_s(L"InPit=%S\n", (map_buffer->pit_state == 3) ? "true" : "false");
		}

		wprintf_s(L"[Track Data]\n");
		wprintf_s(L"Temperature=26\n");
		wprintf_s(L"Grip=Optimum\n");

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
					wprintf(L"Closed\n");

					break;
				case R3E_PIT_MENU_PRESET:
					wprintf(L"Strategy\n");

					break;
				case R3E_PIT_MENU_PENALTY:
					wprintf(L"Penalty\n");

					break;
				case R3E_PIT_MENU_DRIVERCHANGE:
					wprintf(L"Driver\n");

					break;
				case R3E_PIT_MENU_FUEL:
					wprintf(L"Fuel\n");

					break;
				case R3E_PIT_MENU_FRONTTIRES:
					wprintf(L"Front Tyres\n");

					break;
				case R3E_PIT_MENU_REARTIRES:
					wprintf(L"Rear Tyres\n");

					break;
				case R3E_PIT_MENU_FRONTWING:
					wprintf(L"Front Aero\n");

					break;
				case R3E_PIT_MENU_REARWING:
					wprintf(L"Rear Aero\n");

					break;
				case R3E_PIT_MENU_SUSPENSION:
					wprintf(L"Suspension\n");

					break;
				case R3E_PIT_MENU_BUTTON_TOP:
					wprintf(L"Top\n");

					break;
				case R3E_PIT_MENU_BUTTON_BOTTOM:
					wprintf(L"Bottom\n");

					break;
				case R3E_PIT_MENU_MAX:
					wprintf(L"false\n");

					break;
			}

			for (int i = 0; i < R3E_PIT_MENU_MAX; i++) {
				switch (i) {
					case R3E_PIT_MENU_PRESET:
						wprintf(L"Strategy=");

						break;
					case R3E_PIT_MENU_PENALTY:
						wprintf(L"Penalty=");

						break;
					case R3E_PIT_MENU_DRIVERCHANGE:
						wprintf(L"Driver=");

						break;
					case R3E_PIT_MENU_FUEL:
						wprintf(L"Fuel=");

						break;
					case R3E_PIT_MENU_FRONTTIRES:
						wprintf(L"Front Tyres=");

						break;
					case R3E_PIT_MENU_REARTIRES:
						wprintf(L"Rear Tyres=");

						break;
					case R3E_PIT_MENU_FRONTWING:
						wprintf(L"Front Aero=");

						break;
					case R3E_PIT_MENU_REARWING:
						wprintf(L"Rear Aero=");

						break;
					case R3E_PIT_MENU_SUSPENSION:
						wprintf(L"Suspension=");

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