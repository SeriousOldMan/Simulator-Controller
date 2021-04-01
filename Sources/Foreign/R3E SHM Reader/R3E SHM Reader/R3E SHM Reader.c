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
    return (value = -1.0) ? 0.0 : value;
}

long getRemainingTime();

long getRemainingLaps() {
    if (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) {
        return (long)normalize(map_buffer->race_session_laps[map_buffer->session_iteration]) - map_buffer->completed_laps;
    }
    else {
        long time = (long)normalize(map_buffer->lap_time_best_self);

        if (time > 0)
            return (long)(getRemainingTime() / time);
        else
            return getRemainingTime();
    }
}

long getRemainingTime() {
    if (map_buffer->session_length_format != R3E_SESSION_LENGTH_LAP_BASED) {
        return (long)((normalize(map_buffer->race_session_minutes[map_buffer->session_iteration]) * 60) - normalize(map_buffer->lap_time_previous_self * map_buffer->completed_laps));
    }
    else {
        return (long)(getRemainingLaps() * normalize(map_buffer->lap_time_previous_self));
    }
}

int main()
{
    int err_code = 0;
    BOOL mapped_r3e = FALSE;

    if (!mapped_r3e /* && is_r3e_running()*/ && map_exists())
    {
        err_code = map_init();
        
        if (err_code)
            return err_code;

        mapped_r3e = TRUE;
    }

    wprintf_s(L"[Race Data]\n");
    if (mapped_r3e) {
        int modelID = map_buffer->vehicle_info.model_id;
        char buffer[33];

        _itoa_s(modelID, buffer, 32, 10);

        wprintf_s(L"Car=Unknown-%S\n", buffer);
        wprintf_s(L"Track=%S\n", map_buffer->track_name);
        wprintf_s(L"FuelAmount=%d\n", (long)map_buffer->fuel_capacity);
        wprintf_s(L"RaceFormat=%S\n", (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) ? "Lap" : "Time");
    }

    wprintf_s(L"[Car Data]\n");
    if (mapped_r3e) {
        double suspDamage = normalize(map_buffer->car_damage.suspension);

        wprintf_s(L"BodyworkDamage=%f, %f, %f, %f, %f\n", 0.0, 0.0, 0.0, 0.0, normalize(map_buffer->car_damage.aerodynamics));
        wprintf_s(L"SuspensionDamage=%f, %f, %f, %f\n", suspDamage, suspDamage, suspDamage, suspDamage);
        wprintf_s(L"FuelRemaining=%f\n", map_buffer->fuel_left);
        wprintf_s(L"TyreCompound=Dry\n");
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
    wprintf_s(L"Active=%S\n", mapped_r3e ? "true" : "false");
    if (mapped_r3e) {
        wprintf_s(L"Paused=%S\n", map_buffer->game_paused ? "true" : "false");
        if (map_buffer->session_type == R3E_SESSION_QUALIFY)
            wprintf_s(L"Session=QUALIFY\n");
        else if (map_buffer->session_type == R3E_SESSION_RACE)
            wprintf_s(L"Session=RACE\n");
        else if (map_buffer->session_type == R3E_SESSION_PRACTICE)
            wprintf_s(L"Session=PRACTICE\n");
        else
            wprintf_s(L"Session=OTHER\n");
        wprintf_s(L"DriverForname=%S\n", map_buffer->player_name);
        wprintf_s(L"DriverSurname=%S\n", "");
        wprintf_s(L"DriverNickname=%S\n", "");
        wprintf_s(L"LapLastTime=%d\n", (long)(normalize(map_buffer->lap_time_current_self) * 1000));
        wprintf_s(L"LapBestTime=%d\n", (long)(normalize(map_buffer->lap_time_best_self) * 1000));
        wprintf_s(L"Laps=%d\n", map_buffer->completed_laps);

        wprintf_s(L"RaceLapsRemaining=%d\n", getRemainingLaps());

        long timeRemaining = getRemainingTime() * 1000;

        wprintf_s(L"RaceTimeRemaining=%d\n", timeRemaining);
        wprintf_s(L"StintTimeRemaining=%d\n", timeRemaining);
        wprintf_s(L"DriverTimeRemaining=%d\n", timeRemaining);
        wprintf_s(L"InPit=%S\n", (map_buffer->pit_state == 3) ? "true" : "false");
    }

    wprintf_s(L"[Track Data]\n");
    wprintf_s(L"Temperature=26\n");
    wprintf_s(L"Grip=OPTIMUM\n");

    wprintf_s(L"[Weather Data]\n");
    wprintf_s(L"Temperature=24\n");
    wprintf_s(L"Weather=Dry\n");
    wprintf_s(L"Weather10Min=Dry\n");
    wprintf_s(L"Weather30Min=Dry\n");

    wprintf_s(L"[Test Data]\n");
    wprintf_s(L"Aero Damage=%f\n", map_buffer->car_damage.aerodynamics);
    wprintf_s(L"Susp Damage=%f\n", map_buffer->car_damage.suspension);
    wprintf_s(L"Lap Time=%f\n", map_buffer->lap_time_current_self);
    wprintf_s(L"Best Lap Time=%f\n", map_buffer->lap_time_best_self);
    wprintf_s(L"Prev Lap Time=%f\n", map_buffer->lap_time_previous_self);
    wprintf_s(L"Session Index=%d\n", map_buffer->session_iteration);
    wprintf_s(L"Session Minutes=%d\n", map_buffer->race_session_minutes[map_buffer->session_iteration]);
    wprintf_s(L"Completed Laps=%d\n", map_buffer->completed_laps);

    map_close();

    return 0;
}