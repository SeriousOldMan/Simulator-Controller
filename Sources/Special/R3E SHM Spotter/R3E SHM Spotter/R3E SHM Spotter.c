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

int getPlayerID() {
    for (int i = 0; i < map_buffer->num_cars; i++) {
        if (map_buffer->all_drivers_data_1[i].place == map_buffer->position) {
            return map_buffer->all_drivers_data_1[i].driver_info.user_id;
         }
    }

    return -1;
}

int sendStringMessage(HWND hWnd, int wParam, char* msg) {
	int result = 0;

	if (hWnd > 0) {
		COPYDATASTRUCT cds;
		cds.dwData = (256 * 'R' + 'S');
		cds.cbData = sizeof(char) * (strlen(msg) + 1);
		cds.lpData = msg;

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Race Spotter.exe");

	if (winHandle == 0)
		FindWindowEx(0, 0, 0, L"Race Spotter.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

#define PI 3.14159265

#define nearByDistance 8.0
#define longitudinalDistance 4
#define lateralDistance 6
#define verticalDistance 4

#define CLEAR 0
#define LEFT 1
#define RIGHT 2
#define THREE 3

#define situationRepeat 5

char* noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

BOOL carBehind = FALSE;
BOOL carBehindReported = FALSE;

#define YELLOW_SECTOR_1 1
#define YELLOW_SECTOR_2 2
#define YELLOW_SECTOR_3 4

#define YELLOW_FULL (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3)

#define BLUE 16

int blueCount = 0;

int lastFlagState = 0;

BOOL pitWindowOpenReported = FALSE;
BOOL pitWindowClosedReported = TRUE;

char* computeAlert(int newSituation) {
	char* alert = noAlert;

	if (lastSituation == newSituation) {
		if (lastSituation > CLEAR) {
			if (situationCount++ > situationRepeat) {
				situationCount = 0;

				alert = "Hold";
			}
		}
		else
			situationCount = 0;
	}
	else {
		situationCount = 0;

		if (lastSituation == CLEAR) {
			switch (newSituation) {
			case LEFT:
				alert = "Left";
				break;
			case RIGHT:
				alert = "Right";
				break;
			case THREE:
				alert = "Three";
				break;
			}
		}
		else {
			switch (newSituation) {
			case CLEAR:
				if (lastSituation == THREE)
					alert = "ClearAll";
				else
					alert = (lastSituation == RIGHT) ? "ClearRight" : "ClearLeft";
				break;
			case LEFT:
				if (lastSituation == THREE)
					alert = "ClearRight";
				else
					alert = "Three";
				break;
			case RIGHT:
				if (lastSituation == THREE)
					alert = "ClearLeft";
				else
					alert = "Three";
				break;
			case THREE:
				alert = "Three";
				break;
			}
		}
	}

	lastSituation = newSituation;

	return alert;
}

r3e_float32 vectorAngle(r3e_float64 x, r3e_float64 y) {
	r3e_float64 scalar = (x * 0) + (y * 1);
	r3e_float64 length = sqrt((x * x) + (y * y));

	r3e_float64 angle = (length > 0) ? acos(scalar / length) * 180 / PI : 0;

	if (x < 0)
		angle = 360 - angle;

	return (r3e_float32)angle;
}

BOOL nearBy(r3e_float32 car1X, r3e_float32 car1Y, r3e_float32 car1Z,
			r3e_float32 car2X, r3e_float32 car2Y, r3e_float32 car2Z) {
	return (fabs(car1X - car2X) < nearByDistance) &&
		   (fabs(car1Y - car2Y) < nearByDistance) &&
		   (fabs(car1Z - car2Z) < nearByDistance);
}

void rotateBy(r3e_float32* x, r3e_float32* y, r3e_float64 angle) {
	r3e_float32 sinus = (r3e_float32)sin(angle * PI / 180);
	r3e_float32 cosinus = (r3e_float32)cos(angle * PI / 180);

	r3e_float32 newX = (*x * cosinus) - (*y * sinus);
	r3e_float32 newY = (*x * sinus) + (*y * cosinus);

	*x = newX;
	*y = newY;
}

int checkCarPosition(r3e_float32 carX, r3e_float32 carY, r3e_float32 carZ, r3e_float32 angle,
					 r3e_float32 otherX, r3e_float32 otherY, r3e_float32 otherZ) {
	if (nearBy(carX, carY, carZ, otherX, otherY, otherZ)) {
		r3e_float32 transX = (otherX - carX);
		r3e_float32 transY = (otherY - carY);

		rotateBy(&transX, &transY, angle);

		if ((fabs(transY) < longitudinalDistance) && (fabs(transX) < lateralDistance) && (fabs(otherZ - carZ) < verticalDistance))
			return (transX > 0) ? RIGHT : LEFT;
		else {
			if (transY < 0)
				carBehind = TRUE;

			return CLEAR;
		}
	}
	else
		return CLEAR;
}

BOOL checkPositions(int playerID) {
	r3e_float64 velocityX = map_buffer->player.velocity.x;
	r3e_float64 velocityY = map_buffer->player.velocity.y;
	r3e_float64 velocityZ = map_buffer->player.velocity.z;

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		r3e_float32 angle = vectorAngle(velocityX, velocityY);

		int index = 0;

		for (int id = 0; id < map_buffer->num_cars; id++)
			if (map_buffer->all_drivers_data_1[id].driver_info.user_id == playerID) {
				index = id;
				break;
			}

		r3e_float32 coordinateX = map_buffer->all_drivers_data_1[index].position.x;
		r3e_float32 coordinateY = map_buffer->all_drivers_data_1[index].position.y;
		r3e_float32 coordinateZ = map_buffer->all_drivers_data_1[index].position.z;

		int newSituation = CLEAR;

		carBehind = FALSE;

		for (int id = 0; id < map_buffer->num_cars; id++) {
			if (map_buffer->all_drivers_data_1[id].driver_info.user_id != playerID)
				newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle,
												 map_buffer->all_drivers_data_1[id].position.x,
												 map_buffer->all_drivers_data_1[id].position.y,
												 map_buffer->all_drivers_data_1[id].position.z);

			if ((newSituation == THREE) && carBehind)
				break;
		}

		char* alert = computeAlert(newSituation);

		if (alert != noAlert) {
			carBehindReported = FALSE;

			char buffer[128];

			strcpy_s(buffer, 128, "proximityAlert:");
			strcpy_s(buffer + strlen("proximityAlert:"), 128 - strlen("proximityAlert:"), alert);

			sendMessage(buffer);

			return TRUE;
		}
		else if (carBehind) {
			if (!carBehindReported) {
				carBehindReported = FALSE;

				sendMessage("proximityAlert:Behind");

				return TRUE;
			}
		}
		else
			carBehindReported = FALSE;
	}
	else {
		lastSituation = CLEAR;
		carBehind = FALSE;
		carBehindReported = FALSE;
	}

	return FALSE;
}

BOOL checkFlagState() {
	if (map_buffer->flags.blue == 1) {
		if ((lastFlagState & BLUE) == 0) {
			sendMessage("blueFlag");

			lastFlagState |= BLUE;

			return TRUE;
		}
		else if (blueCount++ > 100) {
			lastFlagState &= ~BLUE;

			blueCount = 0;
		}
	}
	else {
		lastFlagState &= ~BLUE;

		blueCount = 0;
	}

	int sector = 0;
	int distance = (int)map_buffer->flags.closest_yellow_distance_into_track;

	if (distance > 1000 || distance < 0)
		distance = 0;

	if ((map_buffer->flags.yellow == 1) &&
		map_buffer->flags.sector_yellow[0] == 1 &&
		map_buffer->flags.sector_yellow[1] == 1 &&
		map_buffer->flags.sector_yellow[2] == 1) {
		if ((lastFlagState & YELLOW_FULL) == 0) {
			sendMessage("yellowFlag:Full");

			lastFlagState |= YELLOW_FULL;

			return TRUE;
		}
	}
	else if (map_buffer->flags.yellow && map_buffer->flags.sector_yellow[0] == 1) {
		if ((lastFlagState & YELLOW_SECTOR_1) == 0) {
			sector = 1;

			lastFlagState |= YELLOW_SECTOR_1;
		}
	}
	else if (map_buffer->flags.yellow && map_buffer->flags.sector_yellow[1] == 1) {
		if ((lastFlagState & YELLOW_SECTOR_2) == 0) {
			sector = 2;

			lastFlagState |= YELLOW_SECTOR_2;
		}
	}
	else if (map_buffer->flags.yellow && map_buffer->flags.sector_yellow[2] == 1) {
		if ((lastFlagState & YELLOW_SECTOR_3) == 0) {
			sector = 3;

			lastFlagState |= YELLOW_SECTOR_3;
		}
	}
	else {
		if ((lastFlagState & YELLOW_SECTOR_1) != 0 || (lastFlagState & YELLOW_SECTOR_2) != 0 ||
			(lastFlagState & YELLOW_SECTOR_3) != 0) {
			sendMessage("yellowFlag:Clear");

			lastFlagState &= ~YELLOW_FULL;

			return TRUE;
		}
	}

	if (sector) {
		char buffer[128];
		char buffer2[10];
		int offset = 0;

		strcpy_s(buffer, 128, "yellowFlag:Sector;");

		offset = strlen("yellowFlag:Sector;");
		_itoa_s(sector, buffer2, 10, 10);

		strcpy_s(buffer + offset, 128 - offset, buffer2);

		if (distance) {
			offset += strlen(buffer2);

			strcpy_s(buffer + offset, 128 - offset, ";");

			offset += 1;
			_itoa_s(distance, buffer2, 10, 10);

			strcpy_s(buffer + offset, 128 - offset, buffer2);
		}
		
		sendMessage(buffer);

		return TRUE;
	}
	else
		return FALSE;
}

void checkPitWindow() {
	if ((map_buffer->pit_window_status == R3E_PIT_WINDOW_OPEN) && !pitWindowOpenReported) {
		pitWindowOpenReported = TRUE;
		pitWindowClosedReported = FALSE;

		sendMessage("pitWindow:Open");
	}
	else if ((map_buffer->pit_window_status == R3E_PIT_WINDOW_CLOSED) && !pitWindowClosedReported) {
		pitWindowClosedReported = TRUE;
		pitWindowOpenReported = FALSE;

		sendMessage("pitWindow:Closed");
	}
}

int main()
{
    BOOL mapped_r3e = FALSE;
	int playerID = 0;
	
	while (TRUE) {
		if (!mapped_r3e && map_exists())
			if (!map_init()) {
				mapped_r3e = TRUE;

				playerID = getPlayerID();
			}

		if (mapped_r3e && (map_buffer->completed_laps >= 0) && !map_buffer->game_paused) {
			if (!checkFlagState() && !checkPositions(playerID))
				checkPitWindow();
		}
        else {
            lastSituation = CLEAR;
            carBehind = FALSE;
            carBehindReported = FALSE;

			lastFlagState = 0;
        }

        Sleep(50);
    }

    map_close();

    return 0;
}