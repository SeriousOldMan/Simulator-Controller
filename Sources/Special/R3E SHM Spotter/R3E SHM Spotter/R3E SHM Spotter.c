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

int nearBy(r3e_float64 car1X, r3e_float64 car1Y, r3e_float64 car1Z,
		   r3e_float32 car2X, r3e_float32 car2Y, r3e_float32 car2Z) {
	return (fabs(car1X - car2X) < nearByDistance) &&
		   (fabs(car1Y - car2Y) < nearByDistance) &&
		   (fabs(car1Z - car2Z) < nearByDistance);
}

void rotateBy(r3e_float64* x, r3e_float64* y, r3e_float64 angle) {
	r3e_float64 sinus = sin(angle * PI / 180);
	r3e_float64 cosinus = cos(angle * PI / 180);

	r3e_float64 newX = (*x * cosinus) - (*y * sinus);
	r3e_float64 newY = (*x * sinus) + (*y * cosinus);

	*x = newX;
	*y = newY;
}

int checkCarPosition(r3e_float64 carX, r3e_float64 carY, r3e_float64 carZ, r3e_float64 angle,
					 r3e_float32 otherX, r3e_float32 otherY, r3e_float32 otherZ) {
	if (nearBy(carX, carY, carZ, otherX, otherY, otherZ)) {
		r3e_float64 transX = (otherX - carX);
		r3e_float64 transY = (otherY - carY);

		rotateBy(&transX, &transY, angle);

		if ((fabs(transY) < longitudinalDistance) && (fabs(transX) < lateralDistance) && (fabs(otherZ - carZ) < verticalDistance))
			return (transX < 0) ? RIGHT : LEFT;
		else {
			if (transY < 0)
				carBehind = TRUE;

			return CLEAR;
		}
	}
	else
		return CLEAR;
}

void checkPositions() {
	r3e_float64 velocityX = map_buffer->player.velocity.x;
	r3e_float64 velocityY = map_buffer->player.velocity.y;
	r3e_float64 velocityZ = map_buffer->player.velocity.z;

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		r3e_float64 angle = vectorAngle(velocityX, velocityY);

		int carID = getPlayerCarID();

		r3e_float64 coordinateX = map_buffer->player.position.x;
		r3e_float64 coordinateY = map_buffer->player.position.y;
		r3e_float64 coordinateZ = map_buffer->player.position.z;

		int newSituation = CLEAR;

		carBehind = FALSE;

		for (int id = 0; id < map_buffer->num_cars; id++) {
			// wcout << id << "; " << gf->carCoordinates[id][0] << "; " << gf->carCoordinates[id][1] << "; " << gf->carCoordinates[id][2] << endl;

			if (id != carID)
				newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle,
												 map_buffer->all_drivers_data_1->position.x,
												 map_buffer->all_drivers_data_1->position.y,
												 map_buffer->all_drivers_data_1->position.z);

			if ((newSituation == THREE) && carBehind)
				break;
		}

		char* alert = computeAlert(newSituation);

		if (alert != noAlert) {
			carBehindReported = FALSE;

			char buffer[128];

			strcpy_s(buffer, 128, "alert:");
			strcpy_s(buffer + strlen("alert:"), 128 - strlen("alert:"), alert);

			sendMessage(buffer);
		}
		else if (carBehind) {
			if (!carBehindReported) {
				carBehindReported = FALSE;

				sendMessage("alert:Behind");
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
}

int main()
{
    BOOL mapped_r3e = FALSE;
	
	while (TRUE) {
		if (!mapped_r3e && map_exists())
			if (!map_init())
				mapped_r3e = TRUE;

		if (mapped_r3e && ((map_buffer->completed_laps >= 0)) && !map_buffer->game_paused)
            checkPositions();
        else {
            lastSituation = CLEAR;
            carBehind = FALSE;
            carBehindReported = FALSE;
        }

        Sleep(200);
    }

    map_close();

    return 0;
}