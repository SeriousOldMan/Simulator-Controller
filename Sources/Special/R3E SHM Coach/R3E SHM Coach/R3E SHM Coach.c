#include "r3e.h"
#include "utils.h"

#define _USE_MATH_DEFINES

#include <math.h>
#include <stdio.h>
#include <time.h>
#include <Windows.h>
#include <tchar.h>

#pragma comment(lib, "winmm")

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

int getPlayerIndex() {
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
		cds.dwData = (256 * 'D' + 'C');
		cds.cbData = sizeof(char) * (strlen(msg) + 1);
		cds.lpData = msg;

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendTriggerMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Driving Coach:");
		strcpy_s(buffer + strlen("Driving Coach:"), 128 - strlen("Driving Coach:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

BOOL fileExists(char* name) {
	FILE* file;

	if (!fopen_s(&file, name, "r")) {
		fclose(file);

		return TRUE;
	}
	else
		return FALSE;
}

void splitString(const char* s, const char* delimiter, int count, char** parts) {
	char* pos = strstr(s, delimiter);
	int numParts = 0;

	while (pos) {
		if (count != 0 && numParts < (count - 1))
			break;

		int i = 0;

		for (char* c = (char *)s; c < pos; c++)
			parts[numParts][i++] = *c;

		parts[numParts][i] = '\0';

		s = (pos + 1);

		numParts += 1;
		pos = strstr(s, delimiter);
	}

	strcpy_s(parts[numParts], 256, s);
}

float xCoordinates[256];
float yCoordinates[256];
int numCoordinates = 0;
time_t lastUpdate = 0;
char* triggerType = "Trigger";

char* audioDevice = "";
char* hintFile = "";

char* hintSounds[256][256];
time_t lastHintsUpdate = 0;

void checkCoordinates(int playerID) {
	if ((strcmp(triggerType, "BrakeHints") == 0) ? TRUE : time(NULL) > (lastUpdate + 2)) {
		r3e_float64 velocityX = map_buffer->player.velocity.x;
		r3e_float64 velocityY = map_buffer->player.velocity.z;
		r3e_float64 velocityZ = map_buffer->player.velocity.y;

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int index = 0;

			for (int id = 0; id < map_buffer->num_cars; id++)
				if (map_buffer->all_drivers_data_1[id].driver_info.user_id == playerID) {
					index = id;

					break;
				}

			r3e_float32 coordinateX = map_buffer->all_drivers_data_1[index].position.x;
			r3e_float32 coordinateY = - map_buffer->all_drivers_data_1[index].position.z;

			for (int i = 0; i < numCoordinates; i += 1) {
				if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
					char buffer[512] = "";
					
					if (strcmp(triggerType, "Trigger") == 0) {
						char numBuffer[60];

						strcat_s(buffer, 60, "positionTrigger:");
						_itoa_s(i + 1, numBuffer, 60, 10);
						strcat_s(buffer, 60, numBuffer);
						strcat_s(buffer, 60, ";");
						sprintf_s(numBuffer, 60, "%f", xCoordinates[i]);
						strcat_s(buffer, 60, numBuffer);
						strcat_s(buffer, 60, ";");
						sprintf_s(numBuffer, 60, "%f", yCoordinates[i]);
						strcat_s(buffer, 60, numBuffer);

						sendTriggerMessage(buffer);
					}
					else if (strcmp(triggerType, "BrakeHints") == 0) {
						strcat_s(buffer, 512, "acousticFeedback:");
						strcat_s(buffer, 512, (char *)hintSounds[i]);

						sendTriggerMessage(buffer);
					}

					lastUpdate = time(NULL);

					break;
				}
			}
		}
	}
}

#ifdef WIN32
#define stat _stat
#endif

void loadBrakeHints()
{
	if ((strcmp(hintFile, "") != 0) && fileExists(hintFile))
	{
		struct stat result;
		time_t mod_time = 0;

		if (stat(hintFile, &result) == 0)
			mod_time = result.st_mtime;

		if (numCoordinates == 0 || (mod_time > lastHintsUpdate))
		{
			numCoordinates = 0;
			lastHintsUpdate = mod_time;

			char xPart[255];
			char yPart[255];
			char hintPart[255];

			char* parts[3] = { xPart, yPart, hintPart };

			FILE* file = fopen(hintFile, "r");

			char line[512];

			if (file != NULL) {
				while (fgets(line, sizeof(line), file)) {
					splitString(line, " ", 3, parts);

					xCoordinates[numCoordinates] = (float)atof(parts[0]);
					yCoordinates[numCoordinates] = (float)atof(parts[1]);
					
					strcpy_s((char *)hintSounds[numCoordinates], 256, parts[2]);

					if (++numCoordinates > 255)
						break;
				}

				fclose(file);
			}
		}
	}
}

int main(int argc, char* argv[])
{
    BOOL mapped_r3e = FALSE;
	int playerID = 0;
	BOOL positionTrigger = FALSE;
	BOOL brakeHints = FALSE;

	if (argc > 1) {
		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		if (positionTrigger) {
			triggerType = "Trigger";

			for (int i = 2; i < (argc - 1); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				if (++numCoordinates > 255)
					break;
			}
		}

		brakeHints = (strcmp(argv[1], "-BrakeHints") == 0);

		if (brakeHints) {
			triggerType = "BrakeHints";

			hintFile = argv[2];

			if (argc > 3)
				audioDevice = argv[3];
		}
	}

	while (TRUE) {
		if (!mapped_r3e && map_exists())
			if (!map_init())
				mapped_r3e = TRUE;

		if (mapped_r3e) {
			playerID = getPlayerID();

			if (playerID == -1)
				continue;

			if (positionTrigger) {
				checkCoordinates(playerID);

				Sleep(10);
			}
			else if (positionTrigger) {
				loadBrakeHints();

				checkCoordinates(playerID);

				Sleep(10);
			}
		}
		else
			Sleep(1000);
    }

    map_close();

    return 0;
}