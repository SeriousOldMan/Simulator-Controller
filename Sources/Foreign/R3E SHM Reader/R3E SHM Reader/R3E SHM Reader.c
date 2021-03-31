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

int main()
{
    int err_code = 0;
    BOOL mapped_r3e = FALSE;

    if (!mapped_r3e && is_r3e_running() && map_exists())
    {
        err_code = map_init();
        
        if (err_code)
            return err_code;

        mapped_r3e = TRUE;
    }

    wprintf_s(L"[Race Data]\n");
    
    if (mapped_r3e)
    {
        /*
        wprintf_s(L"Car=%s", L"Unknown");
        wprintf_s(L"Track=%s", map_buffer->track_name);
        wprintf_s(L"FuelAmount=%d", map_buffer->fuel_capacity);
        */
    }

    wprintf_s(L"[Car Data]\n");

    wprintf_s(L"[Stint Data]\n");
    wprintf_s(L"Active=true\n");
    wprintf_s(L"Paused=%s\n", map_buffer->game_paused ? L"true" : L"false");
    if (map_buffer->session_type == R3E_SESSION_QUALIFY)
        wprintf_s(L"Session=QUALIFY\n");
    else if (map_buffer->session_type == R3E_SESSION_RACE)
        wprintf_s(L"Session=RACE\n");
    else if (map_buffer->session_type == R3E_SESSION_PRACTICE)
        wprintf_s(L"Session=PRACTICE\n");
    else
        wprintf_s(L"Session=OTHER\n");
    wprintf_s(L"DriverForname=%s\n", (unsigned short *)map_buffer->player_name);
    wprintf_s(L"DriverSurname=%s\n", (unsigned short*)map_buffer->player_name);
    wprintf_s(L"DriverNickname=XXX\n");
    wprintf_s(L"LapLastTime=%d\n", (long)map_buffer->lap_time_current_self * 1000);
    wprintf_s(L"LapBestTime=%d\n", (long)map_buffer->lap_time_best_self * 1000);
    wprintf_s(L"Laps=%d\n", map_buffer->completed_laps);
    /*
        RaceTimeRemaining = 1.41874e+06
        StintTimeRemaining = 1.41874e+06
        DriverTimeRemaining = 1.41874e+06
        InPit = false
    */

    wprintf_s(L"[Track Data]\n");
    wprintf_s(L"Temperature=26\n");
    wprintf_s(L"Grip=OPTIMUM\n");

    wprintf_s(L"[Pitstop Data]\n");

    wprintf_s(L"[Weather Data]\n");
    wprintf_s(L"Temperature=24\n");
    wprintf_s(L"Weather=Dry\n");
    wprintf_s(L"Weather10Min=Dry\n");
    wprintf_s(L"Weather30Min=Dry\n");

    map_close();

    system("PAUSE");

    return 0;
}