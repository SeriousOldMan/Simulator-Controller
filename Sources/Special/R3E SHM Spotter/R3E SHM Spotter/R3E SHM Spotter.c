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
		cds.dwData = (256 * 'R' + 'S');
		cds.cbData = sizeof(char) * (strlen(msg) + 1);
		cds.lpData = msg;

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendSpotterMessage(char* message) {
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

void sendAutomationMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Simulator Controller.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Simulator Controller.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
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

#define PI 3.14159265

long cycle = 0;
long nextSpeedUpdate = 0;
BOOL enabled = TRUE;

#define nearByXYDistance 10.0
#define nearByZDistance 6.0
float longitudinalFrontDistance = 4;
float longitudinalRearDistance = 5;
#define lateralDistance 8
#define verticalDistance 2

#define CLEAR 0
#define LEFT 1
#define RIGHT 2
#define THREE 3

#define situationRepeat 50

char* noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

BOOL carBehind = FALSE;
BOOL carBehindLeft = FALSE;
BOOL carBehindRight = FALSE;
BOOL carBehindReported = FALSE;
int carBehindCount = 0;
long nextCarBehind = 0;

#define YELLOW_SECTOR_1 1
#define YELLOW_SECTOR_2 2
#define YELLOW_SECTOR_3 4

#define YELLOW_ALL (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3)

#define BLUE 16

int blueCount = 0;
int yellowCount = 0;
long nextBlueFlag = 0;

int lastFlagState = 0;
int waitYellowFlagState = 0;

int aheadAccidentDistance = 800;
int behindAccidentDistance = 500;
int slowCarDistance = 500;

long nextSlowCarAhead = 0;
long nextAccidentAhead = 0;
long nextAccidentBehind = 0;

BOOL pitWindowOpenReported = FALSE;
BOOL pitWindowClosedReported = TRUE;

char* computeAlert(int newSituation) {
	char* alert = noAlert;

	if (lastSituation == newSituation) {
		if (lastSituation > CLEAR) {
			if (situationCount > situationRepeat) {
				situationCount = 0;

				alert = "Hold";
			}
			else
				situationCount += 1;
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

				carBehindReported = TRUE;
				carBehindCount = 21;

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

inline r3e_float64 vectorLength(r3e_float64 x, r3e_float64 y) {
	return sqrt((x * x) + (y * y));
}

r3e_float32 vectorAngle(r3e_float64 x, r3e_float64 y) {
	r3e_float64 scalar = (x * 0) + (y * 1);
	r3e_float64 length = vectorLength(x, y);

	r3e_float64 angle = (length > 0) ? acos(scalar / length) * 180 / PI : 0;

	if (x < 0)
		angle = 360 - angle;

	return (r3e_float32)angle;
}

inline BOOL sameHeading(r3e_float64 x1, r3e_float64 y1, r3e_float64 x2, r3e_float64 y2) {
	return vectorLength(x1 + x2, y1 + y2) > vectorLength(x1, y1);
}

BOOL nearBy(r3e_float32 car1X, r3e_float32 car1Y, r3e_float32 car1Z,
			r3e_float32 car2X, r3e_float32 car2Y, r3e_float32 car2Z) {
	return (fabs(car1X - car2X) < nearByXYDistance) &&
		   (fabs(car1Y - car2Y) < nearByXYDistance) &&
		   (fabs(car1Z - car2Z) < nearByZDistance);
}

void rotateBy(r3e_float32* x, r3e_float32* y, r3e_float64 angle) {
	r3e_float32 sinus = (r3e_float32)sin(angle * PI / 180);
	r3e_float32 cosinus = (r3e_float32)cos(angle * PI / 180);

	r3e_float32 newX = (*x * cosinus) - (*y * sinus);
	r3e_float32 newY = (*x * sinus) + (*y * cosinus);

	*x = newX;
	*y = newY;
}

int checkCarPosition(r3e_float32 carX, r3e_float32 carY, r3e_float32 carZ, r3e_float32 angle, BOOL faster,
					 r3e_float32 otherX, r3e_float32 otherY, r3e_float32 otherZ) {
	if (nearBy(carX, carY, carZ, otherX, otherY, otherZ)) {
		r3e_float32 transX = (otherX - carX);
		r3e_float32 transY = (otherY - carY);

		rotateBy(&transX, &transY, angle);

		if ((fabs(transY) < ((transY > 0) ? longitudinalFrontDistance : longitudinalRearDistance)) &&
			(fabs(transX) < lateralDistance) && (fabs(otherZ - carZ) < verticalDistance))
			return (transX > 0) ? RIGHT : LEFT;
		else {
			if (transY < 0) {
				carBehind = TRUE;

				if ((faster && fabs(transY) < longitudinalFrontDistance * 1.5) ||
					(fabs(transY) < longitudinalFrontDistance * 2 && fabs(transX) > lateralDistance / 2))
					if (transX > 0)
						carBehindRight = TRUE;
					else
						carBehindLeft = FALSE;
			}

			return CLEAR;
		}
	}
	else
		return CLEAR;
}

float lastCoordinates[R3E_NUM_DRIVERS_MAX][3];
BOOL hasLastCoordinates = FALSE;

BOOL checkPositions(int playerID) {
	r3e_float64 velocityX = map_buffer->player.velocity.x;
	r3e_float64 velocityY = map_buffer->player.velocity.z;
	r3e_float64 velocityZ = map_buffer->player.velocity.y;

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		r3e_float32 angle = vectorAngle(velocityX, velocityY);

		int index = 0;

		for (int id = 0; id < map_buffer->num_cars; id++)
			if (map_buffer->all_drivers_data_1[id].driver_info.user_id == playerID) {
				index = id;
				break;
			}

		r3e_float32 coordinateX = map_buffer->all_drivers_data_1[index].position.x;
		r3e_float32 coordinateY = map_buffer->all_drivers_data_1[index].position.z;
		r3e_float32 coordinateZ = map_buffer->all_drivers_data_1[index].position.y;
		r3e_float64 speed = 0.0;

		if (hasLastCoordinates)
			speed = vectorLength(lastCoordinates[index][0] - coordinateX, lastCoordinates[index][2] - coordinateY);

		int newSituation = CLEAR;

		carBehind = FALSE;
		carBehindLeft = FALSE;
		carBehindRight = FALSE;

		for (int id = 0; id < map_buffer->num_cars; id++) {
			if ((map_buffer->all_drivers_data_1[id].driver_info.user_id != playerID) &&
					(map_buffer->all_drivers_data_1[id].in_pitlane == 0)) {
				r3e_float64 otherSpeed = vectorLength(lastCoordinates[id][0] - map_buffer->all_drivers_data_1[id].position.x,
													  lastCoordinates[id][2] - map_buffer->all_drivers_data_1[id].position.z);

				if ((fabs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[index][0] - coordinateX,
																			lastCoordinates[index][2] - coordinateY,
																			lastCoordinates[id][0] - map_buffer->all_drivers_data_1[id].position.x,
																			lastCoordinates[id][2] - map_buffer->all_drivers_data_1[id].position.z)) {
					BOOL faster = FALSE;

					if (hasLastCoordinates)
						faster = otherSpeed > speed * 1.05;

					newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
						map_buffer->all_drivers_data_1[id].position.x,
						map_buffer->all_drivers_data_1[id].position.z,
						map_buffer->all_drivers_data_1[id].position.y);

					if ((newSituation == THREE) && carBehind)
						break;
				}
			}
		}

		for (int id = 0; id < map_buffer->num_cars; id++) {
			lastCoordinates[id][0] = map_buffer->all_drivers_data_1[id].position.x;
			lastCoordinates[id][1] = map_buffer->all_drivers_data_1[id].position.y;
			lastCoordinates[id][2] = map_buffer->all_drivers_data_1[id].position.z;
		}

		hasLastCoordinates = TRUE;

		if (newSituation != CLEAR) {
			carBehind = FALSE;
			carBehindLeft = FALSE;
			carBehindRight = FALSE;
			carBehindReported = FALSE;
		}

		if (carBehindCount++ > 200)
			carBehindCount = 0;

		char* alert = computeAlert(newSituation);

		if (alert != noAlert) {
			longitudinalRearDistance = 4;

			char buffer[128];

			strcpy_s(buffer, 128, "proximityAlert:");
			strcpy_s(buffer + strlen("proximityAlert:"), 128 - strlen("proximityAlert:"), alert);

			sendSpotterMessage(buffer);

			return TRUE;
		}
		else {
			longitudinalRearDistance = 5;
		
			if (carBehind) {
				if (!carBehindReported) {
					if (carBehindLeft || carBehindRight || ((carBehindCount < 20) && (cycle > nextCarBehind))) {
						nextCarBehind = cycle + 200;
						carBehindReported = TRUE;

						sendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
														   (carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

						return TRUE;
					}
				}
			}
			else
				carBehindReported = FALSE;
		}
	}
	else {
		longitudinalRearDistance = 5;
		
		lastSituation = CLEAR;
		carBehind = FALSE;
		carBehindLeft = FALSE;
		carBehindRight = FALSE;
		carBehindReported = FALSE;
	}

	return FALSE;
}

#define NumIdealLines 10000
typedef struct {
	int count;

	float speeds[1000];

	float speed;
	float posX;
	float posY;
} ideal_line;
ideal_line idealLine[NumIdealLines];

int idealLineSize = 0;

inline float il_get_speed(ideal_line* il) {
	return (il->count > 3) ? il->speed : -1;
}

float il_average(ideal_line* il) {
	int length = il->count;
	double average = 0;

	for (int i = 0; i < length; ++i)
		average += il->speeds[i];

	return (float)(average / length);
}

float il_stdDeviation(ideal_line* il) {
	int length = il->count;
	float avg = il_average(il);
	double sqrSum = 0;

	for (int i = 0; i < length; ++i) {
		float speed = il->speeds[i];

		sqrSum += (speed - avg) * (speed - avg);
	}

	return (float)sqrt(sqrSum / length);
}

void il_cleanup(ideal_line* il) {
	int length = il->count;
	float avg = il_average(il);
	float stdDev = il_stdDeviation(il);
	int i = 0;

	while (i < length) {
		float speed = il->speeds[i];

		if (fabs(speed - avg) > stdDev) {
			for (int j = (i + 1); j < length; j++)
				il->speeds[j - 1] = il->speeds[j];

			length -= 1;
		}
		else
			i += 1;
	}

	il->count = length;
	il->speed = il_average(il);
}

void il_update(ideal_line* il, float s, float x, float y) {
	if (il->count == 0)
	{
		il->speeds[0] = s;

		il->count = 1;

		il->speed = s;

		il->posX = x;
		il->posY = y;
	}
	else if (il->count < 1000)
	{
		il->speeds[il->count] = s;

		il->count += 1;

		il->speed = ((il->speed * il->count) + s) / (il->count + 1);

		il->posX = ((il->posX * il->count) + x) / (il->count + 1);
		il->posY = ((il->posY * il->count) + y) / (il->count + 1);

		if (il->count % 50 == 0 || (il->count > 20 && fabs(il->speed - s) > (il->speed / 10)))
			il_cleanup(il);
	}
}

void il_clear(ideal_line* il) {
	il->count = 0;

	il->posX = 0;
	il->posY = 0;
}

void updateIdealLine(int vehicleId, double running, double speed) {
	il_update(&idealLine[(int)round(running * (idealLineSize - 1))], (float)speed,
			  map_buffer->all_drivers_data_1[vehicleId].position.x,
			  -map_buffer->all_drivers_data_1[vehicleId].position.z);
}

typedef struct
{
	int vehicle;
	long distance;
} slow_car_info;

slow_car_info accidentsAhead[10];
slow_car_info accidentsBehind[10];
slow_car_info slowCarsAhead[10];

inline double getAverageSpeed(double running) {
	int last = (idealLineSize - 1);
	int index = min(last, max(0, (int)round(running * last)));

	return il_get_speed(&idealLine[index]);
}

inline void clearAverageSpeed(double running) {
	int last = (idealLineSize - 1);
	int index = min(last, max(0, (int)round(running * last)));

	il_clear(&idealLine[index]);
	
	index -= 1;
	
	if (index >= 0)
		il_clear(&idealLine[index]);
	
	index += 2;
	
	if (index <= last)
		il_clear(&idealLine[index]);
}

double bestLapTime = INT_LEAST32_MAX;

int completedLaps = 0;
int numAccidents = 0;

char* semFileName = "";

int thresholdSpeed = 60;

BOOL fileExists(char* name) {
	FILE* file;

	if (!fopen_s(&file, name, "r")) {
		fclose(file);

		return TRUE;
	}
	else
		return FALSE;
}

BOOL checkAccident() {
	int accidentsAheadCount = 0;
	int accidentsBehindCount = 0;
	int slowCarsAheadCount = 0;
	int playerIdx = getPlayerIndex();
	BOOL accident = FALSE;

	if (idealLineSize == 0)
		idealLineSize = (int)min(NumIdealLines, map_buffer->layout_length / 4);

	if (map_buffer->all_drivers_data_1[playerIdx].in_pitlane > 0) {
		bestLapTime = INT_LEAST32_MAX;

		return FALSE;
	}

	if ((map_buffer->lap_time_previous_self > 0) && ((map_buffer->lap_time_previous_self * 1.002) < bestLapTime))
	{
		bestLapTime = map_buffer->lap_time_previous_self;

		for (int i = 0; i < idealLineSize; i++)
			il_clear(&idealLine[i]);
	}

	if ((strlen(semFileName) > 0) && fileExists(semFileName))
	{
		remove(semFileName);

		for (int i = 0; i < idealLineSize; i++)
			il_clear(&idealLine[i]);
	}
	
	if (map_buffer->completed_laps > completedLaps) {
		if (numAccidents >= (map_buffer->layout_length / 1000)) {
			for (int i = 0; i < idealLineSize; i++)
				il_clear(&idealLine[i]);
		}
		
		completedLaps = map_buffer->completed_laps;
		numAccidents = 0;
	}

	double driverDistance = map_buffer->all_drivers_data_1[playerIdx].lap_distance;

	for (int id = 0; id < map_buffer->num_cars; id++) {
		if (map_buffer->all_drivers_data_1[id].in_pitlane > 0)
			continue;

		double speed = map_buffer->all_drivers_data_1[id].car_speed * 3.6;
		double carDistance = map_buffer->all_drivers_data_1[id].lap_distance;
		double running = max(0, min(1, fabs(carDistance / map_buffer->layout_length)));
		double avgSpeed = getAverageSpeed(running);

		if (id != playerIdx) {
			if (speed >= 1) {
				if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
				{
					long distanceAhead = (long)(((carDistance > driverDistance) ? carDistance : (carDistance + map_buffer->layout_length)) - driverDistance);

					clearAverageSpeed(running);
					
					if (speed < (avgSpeed / 5))
					{
						if ((distanceAhead < aheadAccidentDistance) && (accidentsAheadCount < 10)) {
							accidentsAhead[accidentsAheadCount].vehicle = id;
							accidentsAhead[accidentsAheadCount].distance = distanceAhead;

							accidentsAheadCount += 1;
						}

						long distanceBehind = (long)(((carDistance < driverDistance) ? driverDistance : (driverDistance + map_buffer->layout_length)) - carDistance);

						if ((distanceBehind < behindAccidentDistance) && (accidentsBehindCount < 10)) {
							accidentsBehind[accidentsBehindCount].vehicle = id;
							accidentsBehind[accidentsBehindCount].distance = distanceBehind;

							accidentsBehindCount += 1;
						}
					}
					else if ((distanceAhead < slowCarDistance) && (slowCarsAheadCount < 10)) {
						slowCarsAhead[slowCarsAheadCount].vehicle = id;
						slowCarsAhead[slowCarsAheadCount].distance = distanceAhead;

						slowCarsAheadCount += 1;
					}
				}
				else
					updateIdealLine(id, running, speed);
			}
		}
		else {
			if (speed >= 1) {
				if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
					accident = TRUE;
			}
		}
	}
	
	if (!accident) {
		if (accidentsAheadCount > 0)
		{
			if (cycle > nextAccidentAhead)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < accidentsAheadCount; i++)
					distance = ((distance < accidentsAhead[i].distance) ? distance : accidentsAhead[i].distance);

				if (distance > 50) {
					nextAccidentAhead = cycle + 400;
					nextAccidentBehind = cycle + 200;
					nextSlowCarAhead = cycle + 200;

					char message[40] = "accidentAlert:Ahead;";
					char numBuffer[20];

					sprintf_s(numBuffer, 20, "%d", distance);
					strcat_s(message, 40, numBuffer);

					sendSpotterMessage(message);
					
					numAccidents += 1;

					return TRUE;
				}
			}
		}

		if (slowCarsAheadCount > 0)
		{
			if (cycle > nextSlowCarAhead)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < slowCarsAheadCount; i++)
					distance = ((distance < slowCarsAhead[i].distance) ? distance : slowCarsAhead[i].distance);

				if (distance > 100) {
					nextSlowCarAhead = cycle + 200;
					nextAccidentBehind = cycle + 200;

					char message[40] = "slowCarAlert:";
					char numBuffer[20];

					sprintf_s(numBuffer, 20, "%d", distance);
					strcat_s(message, 40, numBuffer);

					sendSpotterMessage(message);
					
					numAccidents += 1;

					return TRUE;
				}
			}
		}

		if (accidentsBehindCount > 0)
		{
			if (cycle > nextAccidentBehind)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < accidentsBehindCount; i++)
					distance = ((distance < accidentsBehind[i].distance) ? distance : accidentsBehind[i].distance);

				if (distance > 50) {
					nextAccidentBehind = cycle + 400;

					char message[40] = "accidentAlert:Behind;";
					char numBuffer[20];

					sprintf_s(numBuffer, 20, "%d", distance);
					strcat_s(message, 40, numBuffer);

					sendSpotterMessage(message);
					
					numAccidents += 1;

					return TRUE;
				}
			}
		}
	}

	return FALSE;
}

BOOL checkFlagState() {
	int sector = 0;
	
	if ((waitYellowFlagState & YELLOW_SECTOR_1) != 0 || (waitYellowFlagState & YELLOW_SECTOR_2) != 0 || (waitYellowFlagState & YELLOW_SECTOR_3) != 0) {
		if (yellowCount > 50) {
			if (map_buffer->flags.sector_yellow[0] == 0)
				waitYellowFlagState &= ~YELLOW_SECTOR_1;

			if (map_buffer->flags.sector_yellow[1] == 0)
				waitYellowFlagState &= ~YELLOW_SECTOR_2;

			if (map_buffer->flags.sector_yellow[2] == 0)
				waitYellowFlagState &= ~YELLOW_SECTOR_3;

			yellowCount = 0;

			if ((waitYellowFlagState & YELLOW_SECTOR_1) != 0) {
				waitYellowFlagState &= ~YELLOW_SECTOR_1;

				sector = 1;
			}

			if ((waitYellowFlagState & YELLOW_SECTOR_2) != 0) {
				waitYellowFlagState &= ~YELLOW_SECTOR_2;

				sector = 2;
			}

			if ((waitYellowFlagState & YELLOW_SECTOR_3) != 0) {
				waitYellowFlagState &= ~YELLOW_SECTOR_3;

				sector = 3;
			}
		}
		else
			yellowCount += 1;
	}
	else
		yellowCount = 0;

	if (!sector)
		if (map_buffer->flags.blue == 1) {
			if ((lastFlagState & BLUE) == 0 && cycle > nextBlueFlag) {
				nextBlueFlag = cycle + 400;

				sendSpotterMessage("blueFlag");

				lastFlagState |= BLUE;

				return TRUE;
			}
			else if (blueCount > 1000) {
				lastFlagState &= ~BLUE;

				blueCount = 0;
			}
			else
				blueCount += 1;
		}
		else {
			lastFlagState &= ~BLUE;

			blueCount = 0;
		}

	int distance = (int)map_buffer->flags.closest_yellow_distance_into_track;

	if (distance > 1000 || distance < 0)
		distance = 0;
	else
		distance = (int)round(distance / 10.0) * 10;

	if (!sector)
		if ((map_buffer->flags.yellow == 1) &&
			map_buffer->flags.sector_yellow[0] == 1 &&
			map_buffer->flags.sector_yellow[1] == 1 &&
			map_buffer->flags.sector_yellow[2] == 1) {
			if ((lastFlagState & YELLOW_ALL) == 0) {
				sendSpotterMessage("yellowFlag:All");

				lastFlagState |= YELLOW_ALL;

				return TRUE;
			}
		}
		else if (map_buffer->flags.yellow && map_buffer->flags.sector_yellow[0] == 1) {
			if ((lastFlagState & YELLOW_SECTOR_1) == 0) {
				/*
				sector = 1;

				lastFlagState |= YELLOW_SECTOR_1;
				*/

				lastFlagState |= YELLOW_SECTOR_1;
				waitYellowFlagState |= YELLOW_SECTOR_1;
				yellowCount = 0;
			}
		}
		else if (map_buffer->flags.yellow && map_buffer->flags.sector_yellow[1] == 1) {
			if ((lastFlagState & YELLOW_SECTOR_2) == 0) {
				/*
				sector = 2;

				lastFlagState |= YELLOW_SECTOR_2;
				*/

				lastFlagState |= YELLOW_SECTOR_2;
				waitYellowFlagState |= YELLOW_SECTOR_2;
				yellowCount = 0;
			}
		}
		else if (map_buffer->flags.yellow && map_buffer->flags.sector_yellow[2] == 1) {
			if ((lastFlagState & YELLOW_SECTOR_3) == 0) {
				/*
				sector = 3;

				lastFlagState |= YELLOW_SECTOR_3;
				*/

				lastFlagState |= YELLOW_SECTOR_2;
				waitYellowFlagState |= YELLOW_SECTOR_2;
				yellowCount = 0;
			}
		}
		else {
			if ((lastFlagState & YELLOW_SECTOR_1) != 0 || (lastFlagState & YELLOW_SECTOR_2) != 0 ||
				(lastFlagState & YELLOW_SECTOR_3) != 0) {
				if (waitYellowFlagState != lastFlagState)
					sendSpotterMessage("yellowFlag:Clear");

				lastFlagState &= ~YELLOW_ALL;
				waitYellowFlagState &= ~YELLOW_ALL;
				yellowCount = 0;

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
		
		sendSpotterMessage(buffer);

		return TRUE;
	}
	else
		return FALSE;
}

BOOL checkPitWindow() {
	if ((map_buffer->pit_window_status == R3E_PIT_WINDOW_OPEN) && !pitWindowOpenReported) {
		pitWindowOpenReported = TRUE;
		pitWindowClosedReported = FALSE;

		sendSpotterMessage("pitWindow:Open");

		return TRUE;
	}
	else if ((map_buffer->pit_window_status == R3E_PIT_WINDOW_CLOSED) && !pitWindowClosedReported) {
		pitWindowClosedReported = TRUE;
		pitWindowOpenReported = FALSE;

		sendSpotterMessage("pitWindow:Closed");

		return TRUE;
	}

	return FALSE;
}

BOOL greenFlagReported = FALSE;

BOOL greenFlag() {
	if (!greenFlagReported && (map_buffer->start_lights >= R3E_SESSION_PHASE_GREEN) && (map_buffer->session_type == R3E_SESSION_RACE)) {
		greenFlagReported = TRUE;
		
		sendSpotterMessage("greenFlag");
		
		Sleep(2000);
		
		return TRUE;
	}
	else
		return FALSE;
}

float lastTopSpeed = 0;
int lastLaps = 0;

void updateTopSpeed() {
	float speed = map_buffer->car_speed * 3.6f;

	if (speed > lastTopSpeed)
		lastTopSpeed = speed;

	if (map_buffer->completed_laps > lastLaps) {
		char message[40] = "speedUpdate:";
		char numBuffer[20];

		sprintf_s(numBuffer, 20, "%f", lastTopSpeed);
		strcat_s(message, 40, numBuffer);

		sendSpotterMessage(message);

		lastTopSpeed = 0;
		lastLaps = map_buffer->completed_laps;;
	}
}

#define MAXVALUES 6

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

BOOL triggerUSOSBeep(char* soundsDirectory, char* audioDevice, double usos) {
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
		if (audioDevice) {
			char buffer[512];

			strcpy_s(buffer, 512, "acousticFeedback:");
			strcpy_s(buffer + strlen("acousticFeedback:"), 512 - strlen("acousticFeedback:"), wavFile);

			sendAnalyzerMessage(buffer);
		}
		else
			PlaySoundA(wavFile, NULL, SND_FILENAME | SND_ASYNC);

		return TRUE;
	}
	else
		return FALSE;
}

BOOL collectTelemetry(char* soundsDirectory, char* audioDevice, BOOL calibrate) {
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
				if (triggerUSOSBeep(soundsDirectory, audioDevice, cd.usos))
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

float initialX = 0.0;
float initialY = 0.0;
int coordCount = 0;
BOOL mapStarted = FALSE;
int mapLap = -1;

BOOL writeCoordinates(int playerID) {
	r3e_float64 velocityX = map_buffer->player.velocity.x;
	r3e_float64 velocityY = map_buffer->player.velocity.z;
	r3e_float64 velocityZ = map_buffer->player.velocity.y;

	if (!mapStarted)
		if (mapLap == -1) {
			mapLap = map_buffer->completed_laps;

			return TRUE;
		}
		else if (map_buffer->completed_laps == mapLap)
			return TRUE;

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		int index = 0;

		mapStarted = TRUE;

		for (int id = 0; id < map_buffer->num_cars; id++)
			if (map_buffer->all_drivers_data_1[id].driver_info.user_id == playerID) {
				index = id;

				break;
			}

		r3e_float32 coordinateX = map_buffer->all_drivers_data_1[index].position.x;
		r3e_float32 coordinateY = - map_buffer->all_drivers_data_1[index].position.z;

		printf("%f,%f\n", coordinateX, coordinateY);

		if (coordCount == 0) {
			initialX = coordinateX;
			initialY = coordinateY;
		}
		else if (coordCount > 100 && fabs(coordinateX - initialX) < 10.0 && fabs(coordinateY - initialY) < 10.0)
			return FALSE;
		
		coordCount += 1;
	}

	return TRUE;
}

float xCoordinates[60];
float yCoordinates[60];
int numCoordinates = 0;
time_t lastUpdate = 0;
char* triggerType = "Automation";

void checkCoordinates(int playerID) {
	if (time(NULL) > (lastUpdate + 2)) {
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
					char buffer[60] = "";
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

					if (strcmp(triggerType, "Automation") == 0)
						sendAutomationMessage(buffer);
					else
						sendTriggerMessage(buffer);

					lastUpdate = time(NULL);

					break;
				}
			}
		}
	}
}

char* telemetryDirectory = "";
FILE* telemetryFile = 0;
int telemetryLap = -1;
double lastRunning = -1;

inline void printNAValue(FILE* file, float value) {
	if (value == -1)
		fprintf(file, "n/a;");
	else
		fprintf(file, "%f;", value);
}

void collectCarTelemetry(int playerID) {
	char telemetryFileName[512] = "";
	char tmpFileName[512] = "";
	char buffer[60] = "";
	int index = -1;

	for (int id = 0; id < map_buffer->num_cars; id++)
		if (map_buffer->all_drivers_data_1[id].driver_info.user_id == playerID) {
			index = id;
			break;
		}

	if (index == -1)
		return;

	int carLaps = map_buffer->completed_laps;

	if ((carLaps + 1) != telemetryLap) {
		if (telemetryFile) {
			fclose(telemetryFile);

			int offset = strlen(telemetryDirectory);

			sprintf_s(buffer, 60, "%d", telemetryLap);

			strcpy_s(tmpFileName, 512, telemetryDirectory);
			strcpy_s(tmpFileName + offset, 512 - offset, "\\Lap ");
			offset += strlen("\\Lap ");
			strcpy_s(tmpFileName + offset, 512 - offset, buffer);
			offset += strlen(buffer);
			strcpy_s(tmpFileName + offset, 512 - offset, ".tmp");

			offset = strlen(telemetryDirectory);

			strcpy_s(telemetryFileName, 512, telemetryDirectory);
			offset = strlen(telemetryDirectory);
			strcpy_s(telemetryFileName + offset, 512 - offset, "\\Lap ");
			offset += strlen("\\Lap ");
			strcpy_s(telemetryFileName + offset, 512 - offset, buffer);
			offset += strlen(buffer);
			strcpy_s(telemetryFileName + offset, 512 - offset, ".telemetry");

			remove(telemetryFileName);

			rename(tmpFileName, telemetryFileName);
		}
			
		telemetryLap = (carLaps + 1);

		int offset = strlen(telemetryDirectory);

		sprintf_s(buffer, 60, "%d", telemetryLap);

		strcpy_s(tmpFileName, 512, telemetryDirectory);
		strcpy_s(tmpFileName + offset, 512 - offset, "\\Lap ");
		offset += strlen("\\Lap ");
		strcpy_s(tmpFileName + offset, 512 - offset, buffer);
		offset += strlen(buffer);
		strcpy_s(tmpFileName + offset, 512 - offset, ".tmp");

		if (fopen_s(&telemetryFile, tmpFileName, "w")) {
			telemetryFile = 0;

			return;
		}
		
		lastRunning = -1;
	}

	double carDistance = map_buffer->all_drivers_data_1[index].lap_distance;
	float running = (float)max(0, min(1, fabs(carDistance / map_buffer->layout_length)));

	if (running > lastRunning) {
		/*
		fprintf(telemetryFile, "%f;%f;%f;%f;%d;%d;%f;%d;%d;%f;%f;%f;%f;%d\n",
							   running, map_buffer->throttle, map_buffer->brake, map_buffer->steer_input_raw,
							   map_buffer->gear, (int)round(map_buffer->engine_rps), map_buffer->car_speed * 3.6f,
							   (map_buffer->aid_settings.tc == 5) ? 1 : 0, (map_buffer->aid_settings.abs == 5) ? 1 : 0,
							   -(map_buffer->local_acceleration.z / 9.807),
							   (map_buffer->local_acceleration.x / 9.807),
							   map_buffer->all_drivers_data_1[index].position.x,
							   -map_buffer->all_drivers_data_1[index].position.z,
							   (int)round(map_buffer->lap_time_current_self * 1000));
		*/

		printNAValue(telemetryFile, running);
		printNAValue(telemetryFile, map_buffer->throttle);
		printNAValue(telemetryFile, map_buffer->brake);
		fprintf(telemetryFile, "%f;%d;%d;%f;%d;%d;%f;%f;%f;%f;", map_buffer->steer_input_raw, map_buffer->gear,
																 (int)round(map_buffer->engine_rps * 2 * PI), map_buffer->car_speed * 3.6f,
																 (map_buffer->aid_settings.tc == 5) ? 1 : 0, (map_buffer->aid_settings.abs == 5) ? 1 : 0,
																 - (map_buffer->local_acceleration.z / 9.807),
																 (map_buffer->local_acceleration.x / 9.807),
																 map_buffer->all_drivers_data_1[index].position.x,
																 -map_buffer->all_drivers_data_1[index].position.z);

		if (map_buffer->lap_time_current_self != -1)
			fprintf(telemetryFile, "%d\n", (long)round(map_buffer->lap_time_current_self * 1000));
		else
			fprintf(telemetryFile, "n/a\n");

		int offset = strlen(telemetryDirectory);

		strcpy_s(tmpFileName, 512, telemetryDirectory);
		strcpy_s(tmpFileName + offset, 512 - offset, "\\Telemetry.cmd");

		if (fileExists(tmpFileName)) {
			FILE* file;

			strcpy_s(tmpFileName, 512, telemetryDirectory);
			strcpy_s(tmpFileName + offset, 512 - offset, "\\Telemetry.section");

			if (fopen_s(&file, tmpFileName, "a")) {
				printNAValue(file, running);
				printNAValue(file, map_buffer->throttle);
				printNAValue(file, map_buffer->brake);
				fprintf(file, "%f;%d;%d;%f;%d;%d;%f;%f;%f;%f;", map_buffer->steer_input_raw, map_buffer->gear,
																(int)round(map_buffer->engine_rps * 2 * PI), map_buffer->car_speed * 3.6f,
																(map_buffer->aid_settings.tc == 5) ? 1 : 0, (map_buffer->aid_settings.abs == 5) ? 1 : 0,
																-(map_buffer->local_acceleration.z / 9.807),
																(map_buffer->local_acceleration.x / 9.807),
																map_buffer->all_drivers_data_1[index].position.x,
																-map_buffer->all_drivers_data_1[index].position.z);

				if (map_buffer->lap_time_current_self != -1)
					fprintf(file, "%d\n", (long)round(map_buffer->lap_time_current_self * 1000));
				else
					fprintf(file, "n/a\n");

				fclose(file);
			}
		}

		lastRunning = running;
	}
}

BOOL started = FALSE;

inline const BOOL active() {
	if (started)
		return TRUE;
	else if ((map_buffer->session_type == R3E_SESSION_RACE) && (map_buffer->start_lights < R3E_SESSION_PHASE_GREEN) && (map_buffer->completed_laps <= 0))
		return FALSE;
	
	started = TRUE;

	return TRUE;
}

int main(int argc, char* argv[])
{
    BOOL mapped_r3e = FALSE;
	int playerID = 0;
	BOOL running = FALSE;
	int countdown = 4000;
	BOOL mapTrack = FALSE;
	BOOL positionTrigger = FALSE;
	BOOL calibrateTelemetry = FALSE;
	BOOL analyzeTelemetry = FALSE;
	BOOL carTelemetry = FALSE;
	long counter = 0;

	char* soundsDirectory = "";
	char* audioDevice = NULL;

	if (argc > 1) {
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		calibrateTelemetry = (strcmp(argv[1], "-Calibrate") == 0);
		analyzeTelemetry = calibrateTelemetry || (strcmp(argv[1], "-Analyze") == 0);
		positionTrigger = (strcmp(argv[1], "-Automation") == 0);
		carTelemetry = (strcmp(argv[1], "-Telemetry") == 0);

		if (!positionTrigger) {
			positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

			if (positionTrigger)
				triggerType = "Trigger";
		}

		if (analyzeTelemetry) {
			strcpy_s(dataFile, 512, argv[2]);

			if (calibrateTelemetry) {
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
		else if (positionTrigger) {
			for (int i = 2; i < (argc - 1); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				numCoordinates += 1;
			}
		}
		else if (carTelemetry) {
			// char* trackLength = argv[2];

			telemetryDirectory = argv[3];
		}
		else {
			if (argc > 1) {
				// char* trackLength = argv[1];
			}

			if (argc > 2)
				aheadAccidentDistance = atoi(argv[2]);

			if (argc > 3)
				behindAccidentDistance = atoi(argv[3]);

			if (argc > 4)
				slowCarDistance = atoi(argv[4]);

			if (argc > 5)
				semFileName = argv[5];

			if (argc > 6)
				thresholdSpeed = atoi(argv[6]);
		}
	}

	while (++counter) {
		BOOL wait = TRUE;

		if (!mapped_r3e && map_exists())
			if (!map_init())
				mapped_r3e = TRUE;

		if (mapped_r3e) {
			playerID = getPlayerID();

			if (playerID == -1)
				continue;

			if (analyzeTelemetry) {
				if (collectTelemetry(soundsDirectory, audioDevice, calibrateTelemetry)) {
					if (remainder(counter, 20) == 0)
						writeTelemetry(calibrateTelemetry);
				}
				else
					break;
			}
			else if (mapTrack) {
				if (!writeCoordinates(playerID))
					break;
			}
			else if (positionTrigger)
				checkCoordinates(playerID);
			else if (active()) {
				BOOL startGo = (map_buffer->start_lights >= R3E_SESSION_PHASE_GREEN);

				if (!greenFlagReported && (counter > 8000))
					greenFlagReported = TRUE;
				
				if (!running) {
					countdown -= 1;

					running = (startGo || (countdown <= 0));
				}

				if (map_buffer->game_paused)
					running = FALSE;

				if (running) {
					if (mapped_r3e && (map_buffer->completed_laps >= 0) && !map_buffer->game_paused) {
						if (carTelemetry)
							collectCarTelemetry(playerID);
						else {
							updateTopSpeed();

							if (cycle > nextSpeedUpdate)
							{
								nextSpeedUpdate = cycle + 50;

								if (((map_buffer->car_speed * 3.6f) >= thresholdSpeed) && !enabled)
								{
									enabled = TRUE;

									sendSpotterMessage("enableSpotter");
								}
								else if (((map_buffer->car_speed * 3.6f) < thresholdSpeed) && enabled)
								{
									enabled = FALSE;

									sendSpotterMessage("disableSpotter");
								}
							}

							cycle += 1;

							if (!startGo || !greenFlag())
								if (enabled)
									if (checkAccident())
										wait = FALSE;
									else if (checkFlagState() || checkPositions(playerID))
										wait = FALSE;
									else
										wait = !checkPitWindow();
						}
					}
					else {
						longitudinalRearDistance = 5;
						
						lastSituation = CLEAR;
						carBehind = FALSE;
						carBehindLeft = FALSE;
						carBehindRight = FALSE;
						carBehindReported = FALSE;

						lastFlagState = 0;
					}
				}
				else
					wait = TRUE;
			}
			else
				wait = TRUE;
		}
        
		if (carTelemetry || analyzeTelemetry || positionTrigger)
			Sleep(10);
		else if (wait)
			Sleep(50);
    }

    map_close();

    return 0;
}