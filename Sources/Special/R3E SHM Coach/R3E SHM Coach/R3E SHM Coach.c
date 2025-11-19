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

void sendAnalyzerMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Analyzer:");
		strcpy_s(buffer + strlen("Analyzer:"), 128 - strlen("Analyzer:"), message);

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

inline r3e_float64 vectorLength(r3e_float64 x, r3e_float64 y) {
	return sqrt((x * x) + (y * y));
}


char* player = "";
char* audioDevice = "";
float volume = 0;
STARTUPINFOA si = { sizeof(si) };

void playSound(char* wavFile, BOOL wait) {
	PROCESS_INFORMATION pi;

	char buffer[512];
	
	if (strcmp(audioDevice, "") == 0)
		sprintf_s(buffer, 256, "\"%s\" \"%s\" -T waveaudio vol %f", player, wavFile, volume);
	else
		sprintf_s(buffer, 256, "\"%s\" \"%s\" -T waveaudio \"%s\" vol %f", player, wavFile, audioDevice, volume);

	if (CreateProcessA(
		NULL,               // Application name
		buffer,				// Command line
		NULL,               // Process handle not inheritable
		NULL,               // Thread handle not inheritable
		FALSE,              // Set handle inheritance to FALSE
		0,                  // No creation flags
		NULL,               // Use parent's environment block
		NULL,               // Use parent's starting directory 
		&si,                // Pointer to STARTUPINFO structure
		&pi)                // Pointer to PROCESS_INFORMATION structure
		)
	{
		if (wait)
			// Wait until process exits
			WaitForSingleObject(pi.hProcess, INFINITE);

		// Close process and thread handles
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	}
}

#define MAXVALUES 6
#define PI 3.14159265

float recentSteerAngles[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentSteerAnglesCount = 0;

float recentGLongs[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentGLongsCount = 0;

float recentRealAngVels[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentRealAngVelsCount = 0;

float recentIdealAngVels[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentIdealAngVelsCount = 0;

void pushValue(float* values, int* count, float value) {
	if (*count == MAXVALUES) {
		for (int i = 1; i < *count; i++)
			values[i - 1] = values[i];

		(*count)--;
	}

	values[(*count)++] = value;
}

float averageValue(float* values, int count) {
	float sum = 0.0;
	for (int i = 0; i < count; i++)
		sum += values[i];

	return (count > 0) ? sum / count : 0.0f;
}

float smoothValue(float* values, int* count, float value) {
	if (FALSE) {
		pushValue(values, count, value);

		return averageValue(values, *count);
	}
	else
		return value;
}

#define NumCornerDynamics 4096
typedef struct {
	float speed;
	double usos;
	int completedLaps;
	int phase;
} corner_dynamics;
corner_dynamics cornerDynamicsRing[NumCornerDynamics];
int cornerDynamicsStart = 0;
int cornerDynamicsEnd = 0;

void appendCornerDynamics(corner_dynamics* cd) {
	cornerDynamicsRing[cornerDynamicsEnd] = *cd;

	if (cornerDynamicsStart <= cornerDynamicsEnd) {
		if (++cornerDynamicsEnd == NumCornerDynamics) {
			cornerDynamicsEnd = 0;
			cornerDynamicsStart++;
		}
	}
	else {
		if (++cornerDynamicsEnd == NumCornerDynamics)
			cornerDynamicsEnd = 0;

		if (++cornerDynamicsStart == NumCornerDynamics)
			cornerDynamicsStart = 0;
	}
}

corner_dynamics* nextCornerDynamics(int* index) {
	corner_dynamics* result;

	while (TRUE) {
		if (*index == cornerDynamicsEnd)
			return NULL;

		if (*index == NumCornerDynamics)
			*index = 0;
		else {
			result = &cornerDynamicsRing[(*index)++];

			if (result->speed != 0)
				return result;
		}
	}
}

corner_dynamics* firstCornerDynamics(int* index) {
	*index = cornerDynamicsStart;

	return nextCornerDynamics(index);
}

void clearCornerDynamics(int lastLap) {
	int index;

	for (corner_dynamics* corner = firstCornerDynamics(&index); corner != NULL; corner = nextCornerDynamics(&index))
		if (corner->completedLaps < lastLap - 1)
			corner->speed = 0;
}

char dataFile[512];
int understeerLightThreshold = 12;
int understeerMediumThreshold = 20;
int understeerHeavyThreshold = 35;
int oversteerLightThreshold = 2;
int oversteerMediumThreshold = -6;
int oversteerHeavyThreshold = -10;
int lowspeedThreshold = 100;
int wheelbase = 270;
int trackWidth = 150;

int lastCompletedLaps = 0;
r3e_float32 lastSpeed = 0.0f;
long lastSound = 0;

BOOL triggerUSOSBeep(char* soundsDirectory, double usos) {
	BOOL sound = TRUE;
	char wavFile[255];

	strcpy_s(wavFile, 255, soundsDirectory);
	strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "");

	if (usos < oversteerHeavyThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Oversteer Heavy.wav");
	else if (usos < oversteerMediumThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Oversteer Medium.wav");
	else if (usos < oversteerLightThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Oversteer Light.wav");
	else if (usos > understeerHeavyThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Understeer Heavy.wav");
	else if (usos > understeerMediumThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Understeer Medium.wav");
	else if (usos > understeerLightThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Understeer Light.wav");
	else
		sound = FALSE;

	if (sound) {
		if (strcmp(audioDevice, "") != 0) {
			if (strcmp(player, "") == 0) {
				char buffer[512];

				strcpy_s(buffer, 512, "acousticFeedback:");
				strcpy_s(buffer + strlen("acousticFeedback:"), 512 - strlen("acousticFeedback:"), wavFile);

				sendAnalyzerMessage(buffer);
			}
			else
				playSound(wavFile, FALSE);
		}
		else
			PlaySoundA(wavFile, NULL, SND_FILENAME | SND_ASYNC);

		return TRUE;
	}
	else
		return FALSE;
}

BOOL collectTelemetry(char* soundsDirectory, BOOL calibrate) {
	int playerIdx = getPlayerIndex();

	if (map_buffer->game_paused || (map_buffer->all_drivers_data_1[playerIdx].in_pitlane != 0))
		return TRUE;

	r3e_float32 steerAngle = smoothValue(recentSteerAngles, &recentSteerAnglesCount, map_buffer->steer_input_raw);
	r3e_int32 steerLock = map_buffer->steer_wheel_range_degrees;
	r3e_float32 steerRatio = ((float)steerLock / 2) / map_buffer->steer_lock_degrees;

	r3e_float32 acceleration = map_buffer->car_speed * 3.6f - lastSpeed;

	lastSpeed = map_buffer->car_speed * 3.6f;

	smoothValue(recentGLongs, &recentGLongsCount, acceleration);

	r3e_float64 angularVelocity = smoothValue(recentRealAngVels, &recentRealAngVelsCount,
											  (float)map_buffer->player.local_angular_velocity.y);
	r3e_float64 steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	r3e_float64 steerAngleRadians = -steeredAngleDegs / 57.2958;
	r3e_float64 wheelBaseMeter = (float)wheelbase / 100;
	r3e_float64 radius = wheelBaseMeter / steerAngleRadians;
	r3e_float64 perimeter = radius * PI * 2;
	r3e_float64 perimeterSpeed = lastSpeed / 3.6;
	r3e_float64 idealAngularVelocity = smoothValue(recentIdealAngVels, &recentIdealAngVelsCount,
												   (float)(perimeterSpeed / perimeter * 2 * PI));

	if (fabs(steerAngle) > 0.1 && lastSpeed > 60) {
		// Get the average recent GLong
		float glongAverage = averageValue(recentGLongs, recentGLongsCount);

		int phase = 0;
		if (recentGLongsCount > 0)
			if (glongAverage < -0.2) {
				// Braking
				phase = -1;
			}
			else if (glongAverage > 0.1) {
				// Accelerating
				phase = 1;
			}

		corner_dynamics cd = { map_buffer->car_speed * 3.6f, 0, map_buffer->completed_laps, phase };

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			r3e_float64 slip = fabs(idealAngularVelocity - angularVelocity);

			if (steerAngle > 0) {
				if (angularVelocity > 0)
				{
					if (calibrate)
						slip *= -1;
					else
						slip = (oversteerHeavyThreshold - 1) / 57.2989;
				}
				else if (angularVelocity < idealAngularVelocity)
					slip *= -1;
			}
			else {
				if (angularVelocity < 0)
				{
					if (calibrate)
						slip *= -1;
					else
						slip = (oversteerHeavyThreshold - 1) / 57.2989;
				}
				else if (angularVelocity > idealAngularVelocity)
					slip *= -1;
			}

			cd.usos = slip * 57.2989 * 1;

			if ((strlen(soundsDirectory) > 0) && (long)GetTickCount() > (lastSound + 300))
				if (triggerUSOSBeep(soundsDirectory, cd.usos))
					lastSound = GetTickCount();

			if (FALSE) {
				char fileName[512];
				FILE* output;

				strcpy_s(fileName, 512, dataFile);
				strcpy_s(fileName + strlen(dataFile), 512 - strlen(dataFile), ".trace");

				if (!fopen_s(&output, fileName, "a")) {
					fprintf(output, "%f  %f  %f  %f  %f  %f  %f  %f\n", steerAngle, steeredAngleDegs, steerAngleRadians, lastSpeed, idealAngularVelocity, angularVelocity, slip, cd.usos);

					fclose(output);

					Sleep(200);
				}
			}
		}

		appendCornerDynamics(&cd);

		if (lastCompletedLaps != map_buffer->completed_laps) {
			lastCompletedLaps = map_buffer->completed_laps;

			clearCornerDynamics(lastCompletedLaps);
		}
	}

	return TRUE;
}

void writeTelemetry(BOOL calibrate) {
	char fileName[512];
	FILE* output;

	strcpy_s(fileName, 512, dataFile);
	strcpy_s(fileName + strlen(dataFile), 512 - strlen(dataFile), ".tmp");

	if (!fopen_s(&output, fileName, "w")) {
		int slowLightUSNum[] = { 0, 0, 0 };
		int slowMediumUSNum[] = { 0, 0, 0 };
		int slowHeavyUSNum[] = { 0, 0, 0 };
		int slowLightOSNum[] = { 0, 0, 0 };
		int slowMediumOSNum[] = { 0, 0, 0 };
		int slowHeavyOSNum[] = { 0, 0, 0 };
		int slowTotalNum = 0;
		int fastLightUSNum[] = { 0, 0, 0 };
		int fastMediumUSNum[] = { 0, 0, 0 };
		int fastHeavyUSNum[] = { 0, 0, 0 };
		int fastLightOSNum[] = { 0, 0, 0 };
		int fastMediumOSNum[] = { 0, 0, 0 };
		int fastHeavyOSNum[] = { 0, 0, 0 };
		int fastTotalNum = 0;

		int slowOSMin[] = { 0, 0, 0 };
		int fastOSMin[] = { 0, 0, 0 };
		int slowUSMax[] = { 0, 0, 0 };
		int fastUSMax[] = { 0, 0, 0 };

		int index = 0;

		for (corner_dynamics* corner = firstCornerDynamics(&index); corner != NULL; corner = nextCornerDynamics(&index)) {
			int phase = corner->phase + 1;

			if (calibrate) {
				if (corner->speed < lowspeedThreshold) {
					slowOSMin[phase] = min(slowOSMin[phase], (int)corner->usos);
					slowUSMax[phase] = max(slowUSMax[phase], (int)corner->usos);
				}
				else {
					fastOSMin[phase] = min(fastOSMin[phase], (int)corner->usos);
					fastUSMax[phase] = max(fastUSMax[phase], (int)corner->usos);
				}
			}
			else {
				if (corner->speed < lowspeedThreshold) {
					slowTotalNum++;
					if (corner->usos < oversteerHeavyThreshold) {
						slowHeavyOSNum[phase]++;
					}
					else if (corner->usos < oversteerMediumThreshold) {
						slowMediumOSNum[phase]++;
					}
					else if (corner->usos < oversteerLightThreshold) {
						slowLightOSNum[phase]++;
					}
					else if (corner->usos > understeerHeavyThreshold) {
						slowHeavyUSNum[phase]++;
					}
					else if (corner->usos > understeerMediumThreshold) {
						slowMediumUSNum[phase]++;
					}
					else if (corner->usos > understeerLightThreshold) {
						slowLightUSNum[phase]++;
					}
				}
				else {
					fastTotalNum++;
					if (corner->usos < oversteerHeavyThreshold) {
						fastHeavyOSNum[phase]++;
					}
					else if (corner->usos < oversteerMediumThreshold) {
						fastMediumOSNum[phase]++;
					}
					else if (corner->usos < oversteerLightThreshold) {
						fastLightOSNum[phase]++;
					}
					else if (corner->usos > understeerHeavyThreshold) {
						fastHeavyUSNum[phase]++;
					}
					else if (corner->usos > understeerMediumThreshold) {
						fastMediumUSNum[phase]++;
					}
					else if (corner->usos > understeerLightThreshold) {
						fastLightUSNum[phase]++;
					}
				}
			}
		}

		if (calibrate) {
			fprintf(output, "[Understeer.Slow]");

			fprintf(output, "Entry=%d", slowUSMax[0]);
			fprintf(output, "Apex=%d", slowUSMax[1]);
			fprintf(output, "Exit=%d", slowUSMax[2]);

			fprintf(output, "[Understeer.Fast]");

			fprintf(output, "Entry=%d", fastUSMax[0]);
			fprintf(output, "Apex=%d", fastUSMax[1]);
			fprintf(output, "Exit=%d", fastUSMax[2]);

			fprintf(output, "[Oversteer.Slow]");

			fprintf(output, "Entry=%d", slowOSMin[0]);
			fprintf(output, "Apex=%d", slowOSMin[1]);
			fprintf(output, "Exit=%d", slowOSMin[2]);

			fprintf(output, "[Oversteer.Fast]");

			fprintf(output, "Entry=%d", fastOSMin[0]);
			fprintf(output, "Apex=%d", fastOSMin[1]);
			fprintf(output, "Exit=%d", fastOSMin[2]);
		}
		else {
			fprintf(output, "[Understeer.Slow.Light]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowLightUSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowLightUSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowLightUSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Understeer.Slow.Medium]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowMediumUSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowMediumUSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowMediumUSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Understeer.Slow.Heavy]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Understeer.Fast.Light]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastLightUSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastLightUSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastLightUSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Understeer.Fast.Medium]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastMediumUSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastMediumUSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastMediumUSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Understeer.Fast.Heavy]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Oversteer.Slow.Light]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowLightOSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowLightOSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowLightOSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Oversteer.Slow.Medium]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowMediumOSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowMediumOSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowMediumOSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Oversteer.Slow.Heavy]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Oversteer.Fast.Light]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastLightOSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastLightOSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastLightOSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Oversteer.Fast.Medium]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastMediumOSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastMediumOSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastMediumOSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Oversteer.Fast.Heavy]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum));
			}
		}

		fclose(output);

		remove(dataFile);

		rename(fileName, dataFile);
	}
}

float xCoordinates[256];
float yCoordinates[256];
int numCoordinates = 0;
time_t nextUpdate = 0;
char* triggerType = "Trigger";

char* hintFile = "";

char hintSounds[256][256];
float hintDistances[256];
time_t lastHintsUpdate = 0;
int lastLap = 0;
int lastHint = -1;

void checkCoordinates(int playerID) {
	if (time(NULL) > nextUpdate) {
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
			
			if (strcmp(triggerType, "Trigger") == 0) {
				for (int i = 0; i < numCoordinates; i += 1) {
					if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
						char buffer[512] = "";
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

						nextUpdate = time(NULL) + 2;

						break;
					}
				}
			}
			else {
				if (lastLap != map_buffer->completed_laps) {
					lastLap = map_buffer->completed_laps;

					lastHint = -1;
				}

				int bestHint = -1;

				for (int i = lastHint +1; i < numCoordinates; i += 1) {
					if (vectorLength(xCoordinates[i] - coordinateX, yCoordinates[i] - coordinateY) < hintDistances[i])
						bestHint = i;
					else if (bestHint > -1) {
						lastHint = bestHint;

						if (strcmp(audioDevice, "") == 0)
						{
							if (strcmp(player, "") == 0) {
								char buffer[512] = "";
								
								strcat_s(buffer, 512, "acousticFeedback:");
								strcat_s(buffer, 512, hintSounds[bestHint]);

								sendTriggerMessage(buffer);
							}
							else
								playSound(hintSounds[bestHint], FALSE);

							nextUpdate = time(NULL) + 1;
						}
						else {
							PlaySoundA(NULL, NULL, SND_ASYNC);
							PlaySoundA(hintSounds[bestHint], NULL, SND_ASYNC);
						}

						break;
					}
				}
			}
		}
	}
}

#ifdef WIN32
#define stat _stat
#endif

void loadTrackHints()
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
			char distancePart[255];
			char hintPart[255];

			char* parts[5] = { xPart, yPart, distancePart, hintPart };

			FILE* file = fopen(hintFile, "r");

			char line[512];

			if (file != NULL) {
				while (fgets(line, sizeof(line), file)) {
					splitString(line, " ", 5, parts);

					xCoordinates[numCoordinates] = (float)atof(parts[0]);
					yCoordinates[numCoordinates] = (float)atof(parts[1]);
					hintDistances[numCoordinates] = (float)atof(parts[2]);
					
					strcpy_s((char *)hintSounds[numCoordinates], 256, parts[4]);

					if (++numCoordinates > 255)
						break;
				}

				lastHint = -1;

				fclose(file);
			}
		}
	}
}

int main(int argc, char* argv[])
{
    BOOL mapped_r3e = FALSE;
	int playerID = 0;
	BOOL handlingCalibrator = FALSE;
	BOOL handlingAnalyzer = FALSE;
	BOOL positionTrigger = FALSE;
	BOOL trackHints = FALSE;
	char* soundsDirectory = "";

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

		trackHints = (strcmp(argv[1], "-TrackHints") == 0);

		if (trackHints) {
			triggerType = "TrackHints";

			hintFile = argv[2];

			if (argc > 3)
				audioDevice = argv[3];

			if (argc > 4)
				volume = (float)atof(argv[4]);

			if (argc > 5)
				player = argv[5];
		}

		handlingCalibrator = (strcmp(argv[1], "-Calibrate") == 0);
		handlingAnalyzer = handlingCalibrator || (strcmp(argv[1], "-Analyze") == 0);

		if (handlingAnalyzer) {
			strcpy_s(dataFile, 512, argv[2]);

			if (handlingCalibrator) {
				lowspeedThreshold = atoi(argv[3]);
				wheelbase = atoi(argv[4]);
				trackWidth = atoi(argv[5]);
			}
			else {
				understeerLightThreshold = atoi(argv[3]);
				understeerMediumThreshold = atoi(argv[4]);
				understeerHeavyThreshold = atoi(argv[5]);
				oversteerLightThreshold = atoi(argv[6]);
				oversteerMediumThreshold = atoi(argv[7]);
				oversteerHeavyThreshold = atoi(argv[8]);
				lowspeedThreshold = atoi(argv[9]);
				wheelbase = atoi(argv[10]);
				trackWidth = atoi(argv[11]);

				if (argc > 12) {
					soundsDirectory = argv[12];

					if (argc > 13)
						audioDevice = argv[13];
				}
			}
		}
	}

	long counter = 0;

	while (TRUE) {
		counter += 1;

		if (!mapped_r3e && map_exists())
			if (!map_init())
				mapped_r3e = TRUE;

		if (mapped_r3e) {
			playerID = getPlayerID();

			if (playerID == -1)
				continue;

			if (handlingAnalyzer) {
				if (collectTelemetry(soundsDirectory, handlingCalibrator)) {
					if (remainder(counter, 20) == 0)
						writeTelemetry(handlingCalibrator);

					Sleep(10);
				}
				else
					break;
			}
			else if (positionTrigger) {
				checkCoordinates(playerID);

				Sleep(10);
			}
			else if (positionTrigger) {
				loadTrackHints();

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