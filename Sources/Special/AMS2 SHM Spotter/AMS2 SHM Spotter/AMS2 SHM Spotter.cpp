// Used for memory-mapped functionality
#include <windows.h>
#include <math.h>
#include "sharedmemory.h"

// Used for this example
#include <stdio.h>
#include <conio.h>
#include <time.h>
#include <vector>
#include <string>
#include <fstream>
#include <iostream>

#pragma comment( lib, "winmm.lib" )

// Name of the pCars memory mapped file
#define MAP_OBJECT_NAME "$pcars2$"

inline double normalize(double value) {
	return (value < 0) ? 0.0 : value;
}

void substring(char s[], char sub[], int p, int l) {
	int c = 0;

	while (c < l) {
		sub[c] = s[p + c];

		c++;
	}
	sub[c] = '\0';
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

void sendSpotterMessage(const char* message) {
	HWND winHandle = FindWindowExA(0, 0, 0, "Race Spotter.exe");

	if (winHandle == 0)
		FindWindowExA(0, 0, 0, "Race Spotter.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

void sendAutomationMessage(const char* message) {
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

void sendAnalyzerMessage(const char* message) {
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

const float nearByXYDistance = 10.0;
const float nearByZDistance = 6.0;
float longitudinalFrontDistance = 4;
float longitudinalRearDistance = 5;
const float lateralDistance = 8;
const float verticalDistance = 2;

const int CLEAR = 0;
const int LEFT = 1;
const int RIGHT = 2;
const int THREE = 3;

const int situationRepeat = 50;

const char* noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

bool carBehind = false;
bool carBehindLeft = false;
bool carBehindRight = false;
bool carBehindReported = false;
int carBehindCount = 0;
long nextCarBehind = 0;

const int YELLOW = 1;

const int BLUE = 16;

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

bool pitWindowOpenReported = false;
bool pitWindowClosedReported = true;

const char* computeAlert(int newSituation) {
	const char* alert = noAlert;

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

				carBehindReported = true;
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

inline float vectorLength(float x, float y) {
	return sqrt((x * x) + (y * y));
}

float vectorAngle(float x, float y) {
	float scalar = (x * 0) + (y * 1);
	float length = vectorLength(x, y);

	float angle = (length > 0) ? acos(scalar / length) * 180 / PI : 0;

	if (x < 0)
		angle = 360 - angle;

	return angle;
}

bool sameHeading(float x1, float y1, float x2, float y2) {
	return vectorLength(x1 + x2, y1 + y2) > vectorLength(x1, y1);
}

bool nearBy(float car1X, float car1Y, float car1Z,
	float car2X, float car2Y, float car2Z) {
	return (fabs(car1X - car2X) < nearByXYDistance) &&
		(fabs(car1Y - car2Y) < nearByXYDistance) &&
		(fabs(car1Z - car2Z) < nearByZDistance);
}

void rotateBy(float* x, float* y, float angle) {
	float sinus = sin(angle * PI / 180);
	float cosinus = cos(angle * PI / 180);

	float newX = (*x * cosinus) - (*y * sinus);
	float newY = (*x * sinus) + (*y * cosinus);

	*x = newX;
	*y = newY;
}

int checkCarPosition(float carX, float carY, float carZ, float angle, bool faster,
					 float otherX, float otherY, float otherZ) {
	if (nearBy(carX, carY, carZ, otherX, otherY, otherZ)) {
		float transX = (otherX - carX);
		float transY = (otherY - carY);

		rotateBy(&transX, &transY, angle);

		if ((fabs(transY) < ((transY > 0) ? longitudinalFrontDistance : longitudinalRearDistance)) && (fabs(transX) < lateralDistance) && (fabs(otherZ - carZ) < verticalDistance))
			return (transX > 0) ? RIGHT : LEFT;
		else {
			if (transY < 0) {
				carBehind = true;

				if ((faster && fabs(transY) < longitudinalFrontDistance * 1.5) ||
					(fabs(transY) < longitudinalFrontDistance * 2 && fabs(transX) > lateralDistance / 2))
					if (transX > 0)
						carBehindRight = true;
					else
						carBehindLeft = true;
			}

			return CLEAR;
		}
	}
	else
		return CLEAR;
}

float lastCoordinates[STORED_PARTICIPANTS_MAX][3];
bool hasLastCoordinates = false;

bool checkPositions(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		float angle = vectorAngle(velocityX, velocityY);

		int carID = sharedData->mViewedParticipantIndex;

		float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
		float coordinateY = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];
		float coordinateZ = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Y];
		float speed = 0.0;

		if (hasLastCoordinates)
			speed = vectorLength(lastCoordinates[carID][VEC_X] - coordinateX, lastCoordinates[carID][VEC_Z] - coordinateY);

		int newSituation = CLEAR;

		carBehind = false;
		carBehindLeft = false;
		carBehindRight = false;
		
		for (int id = 0; id < sharedData->mNumParticipants; id++) {
			if ((id != carID) && (sharedData->mPitModes[id] == PIT_MODE_NONE)) {
				float otherSpeed = vectorLength(lastCoordinates[id][VEC_X] - sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
												lastCoordinates[id][VEC_Z] - sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z]);

				if ((abs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[carID][VEC_X] - coordinateX,
																		   lastCoordinates[carID][VEC_Z] - coordinateY,
																		   lastCoordinates[id][VEC_X] - sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
																		   lastCoordinates[id][VEC_Z] - sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z])) {
					bool faster = false;

					if (hasLastCoordinates)
						faster = otherSpeed > speed * 1.05;

					newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
						sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
						sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z],
						sharedData->mParticipantInfo[id].mWorldPosition[VEC_Y]);

					if ((newSituation == THREE) && carBehind)
						break;
				}
			}
		}

		for (int id = 0; id < sharedData->mNumParticipants; id++) {
			ParticipantInfo participantInfo = sharedData->mParticipantInfo[id];

			lastCoordinates[id][VEC_X] = participantInfo.mWorldPosition[VEC_X];
			lastCoordinates[id][VEC_Y] = participantInfo.mWorldPosition[VEC_Y];
			lastCoordinates[id][VEC_Z] = participantInfo.mWorldPosition[VEC_Z];
		}

		hasLastCoordinates = true;

		if (newSituation != CLEAR) {
			carBehind = false;
			carBehindLeft = false;
			carBehindRight = false;
			carBehindReported = false;
		}

		if (carBehindCount++ > 200)
			carBehindCount = 0;

		const char* alert = computeAlert(newSituation);

		if (alert != noAlert) {
			longitudinalRearDistance = 4;

			char buffer[128];

			strcpy_s(buffer, 128, "proximityAlert:");
			strcpy_s(buffer + strlen("proximityAlert:"), 128 - strlen("proximityAlert:"), alert);

			sendSpotterMessage(buffer);

			return true;
		}
		else {
			longitudinalRearDistance = 5;
			
			if (carBehind) {
				if (!carBehindReported) {
					if (carBehindLeft || carBehindRight || ((carBehindCount < 20) && (cycle > nextCarBehind))) {
						nextCarBehind = cycle + 200;
						carBehindReported = true;

						sendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft"
														 : (carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

						return true;
					}
				}
			}
			else
				carBehindReported = false;
		}
	}
	else {
		longitudinalRearDistance = 5;
		
		lastSituation = CLEAR;
		carBehind = false;
		carBehindLeft = false;
		carBehindRight = false;
		carBehindReported = false;
	}

	return false;
}

class IdealLine
{
public:
	int count = 0;

	std::vector<float> speeds;

	float speed = 0;
	float posX = 0;
	float posY = 0;

	inline float getSpeed() {
		return (count > 3) ? speed : -1;
	}

	float average() {
		int length = speeds.size();
		double average = 0;

		for (int i = 0; i < length; ++i)
			average += speeds[i];

		return average / length;
	}

	float stdDeviation() {
		int length = speeds.size();
		float avg = average();
		double sqrSum = 0;

		for (int i = 0; i < length; ++i) {
			float speed = speeds[i];

			sqrSum += (speed - avg) * (speed - avg);
		}

		return sqrt(sqrSum / length);
	}

	void cleanup() {
		int length = speeds.size();
		float avg = average();
		float stdDev = stdDeviation();
		int i = 0;

		while (i < length) {
			float speed = speeds[i];

			if (abs(speed - avg) > stdDev) {
				speeds.erase(speeds.begin() + i);

				length -= 1;
			}
			else
				i += 1;
		}

		count = length;
		speed = average();
	}

	void update(float s, float x, float y) {
		if (count == 0)
		{
			speeds.reserve(1000);

			speeds.push_back(s);

			count = 1;

			speed = s;

			posX = x;
			posY = y;
		}
		else if (count < 1000)
		{
			count += 1;

			speeds.push_back(s);

			speed = ((speed * count) + s) / (count + 1);

			posX = ((posX * count) + x) / (count + 1);
			posY = ((posY * count) + y) / (count + 1);

			if (speeds.size() % 50 == 0 || (count > 20 && abs(speed - s) > (speed / 10)))
				cleanup();
		}
	}

	void clear() {
		count = 0;

		speeds.clear();
		speeds.reserve(1000);

		posX = 0;
		posY = 0;
	}
};

std::vector<IdealLine> idealLine;

void updateIdealLine(ParticipantInfo vehicle, double running, double speed) {
	idealLine[(int)std::round(running * (idealLine.size() - 1))].update(speed, vehicle.mWorldPosition[VEC_X], vehicle.mWorldPosition[VEC_Z]);
}

class SlowCarInfo
{
public:
	int vehicle;
	long distance;

public:
	SlowCarInfo() :
		vehicle(0),
		distance(0) {}

	SlowCarInfo(int v, long d) :
		vehicle(v),
		distance(d) {}
};

std::vector<SlowCarInfo> accidentsAhead;
std::vector<SlowCarInfo> accidentsBehind;
std::vector<SlowCarInfo> slowCarsAhead;

inline double getAverageSpeed(double running) {
	int last = (idealLine.size() - 1);
	int index = min(last, max(0, (int)std::round(running * last)));

	return idealLine[index].getSpeed();
}

inline void clearAverageSpeed(double running) {
	int last = (idealLine.size() - 1);
	int index = min(last, max(0, (int)std::round(running * last)));

	idealLine[index].clear();
	
	index -= 1;
	
	if (index >= 0)
		idealLine[index].clear();
	
	index += 2;
	
	if (index <= last)
		idealLine[index].clear();
}

double bestLapTime = INT_LEAST32_MAX;

int completedLaps = 0;
int numAccidents = 0;

std::string semFileName = "";

bool fileExists(std::string name) {
	FILE* file;

	if (!fopen_s(&file, name.c_str(), "r")) {
		fclose(file);

		return true;
	}
	else
		return false;
}

bool checkAccident(const SharedMemory* sharedData)
{
	bool accident = false;

	if (sharedData->mPitModes[sharedData->mViewedParticipantIndex] > PIT_MODE_NONE) {
		bestLapTime = LONG_MAX;

		return false;
	}

	if (idealLine.size() == 0) {
		idealLine.reserve(sharedData->mTrackLength / 4);

		for (int i = 0; i < (sharedData->mTrackLength / 4); i++)
			idealLine.push_back(IdealLine());
	}

	accidentsAhead.clear();
	accidentsBehind.clear();
	slowCarsAhead.clear();

	ParticipantInfo driver = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex];
	double lastLapTime = sharedData->mLastLapTimes[sharedData->mViewedParticipantIndex];

	if ((lastLapTime > 0) && ((lastLapTime * 1.002) < bestLapTime))
	{
		bestLapTime = INT_LEAST32_MAX;

		int length = idealLine.size();

		for (int i = 0; i < length; i++)
			idealLine[i].clear();
	}
	
	if ((strlen(semFileName.c_str()) > 0) && fileExists(semFileName))
	{
		std::remove(semFileName.c_str());

		int length = idealLine.size();

		for (int i = 0; i < length; i++)
			idealLine[i].clear();
	}

	if (sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted > completedLaps) {
		if (numAccidents >= (sharedData->mTrackLength / 1000)) {
			int length = idealLine.size();

			for (int i = 0; i < length; i++)
				idealLine[i].clear();
		}
		
		completedLaps = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted;
		numAccidents = 0;
	}

	try
	{
		for (int i = 0; i < sharedData->mNumParticipants; i++) {
			if (sharedData->mPitModes[i] > PIT_MODE_NONE)
				continue;

			ParticipantInfo vehicle = sharedData->mParticipantInfo[i];
			double speed = sharedData->mSpeeds[i] * 3.6;
			double running = max(0, min(1, std::abs(vehicle.mCurrentLapDistance / sharedData->mTrackLength)));
			double avgSpeed = getAverageSpeed(running);

			if (sharedData->mViewedParticipantIndex != i)
			{
				if (speed >= 1) {
					if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
					{
						long distanceAhead = (long)(((vehicle.mCurrentLapDistance > driver.mCurrentLapDistance) ? vehicle.mCurrentLapDistance
							: (vehicle.mCurrentLapDistance + sharedData->mTrackLength)) - driver.mCurrentLapDistance);

						clearAverageSpeed(running);

						if (speed < (avgSpeed / 5))
						{
							if (distanceAhead < aheadAccidentDistance)
								accidentsAhead.push_back(SlowCarInfo(i, distanceAhead));

							long distanceBehind = (long)(((vehicle.mCurrentLapDistance < driver.mCurrentLapDistance) ? driver.mCurrentLapDistance
								: (driver.mCurrentLapDistance + sharedData->mTrackLength)) - vehicle.mCurrentLapDistance);

							if (distanceBehind < behindAccidentDistance)
								accidentsBehind.push_back(SlowCarInfo(i, distanceBehind));
						}
						else if (distanceAhead < slowCarDistance)
							slowCarsAhead.push_back(SlowCarInfo(i, distanceAhead));
					}
					else
						updateIdealLine(vehicle, running, speed);
				}
			}
			else {
				if (speed >= 1) {
					if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
						accident = true;
				}
			}
		}
	}
	catch (const std::exception& ex) {
		sendSpotterMessage(("internalError:" + std::string(ex.what())).c_str());
	}
	catch (const std::string& ex) {
		sendSpotterMessage(("internalError:" + ex).c_str());
	}
	catch (...) {
		sendSpotterMessage("internalError");
	}

	if (!accident) {
		if (accidentsAhead.size() > 0)
		{
			if (cycle > nextAccidentAhead)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < accidentsAhead.size(); i++)
					distance = ((distance < accidentsAhead[i].distance) ? distance : accidentsAhead[i].distance);

				if (distance > 50) {
					nextAccidentAhead = cycle + 400;
					nextAccidentBehind = cycle + 200;
					nextSlowCarAhead = cycle + 200;

					char message[40] = "accidentAlert:Ahead;";
					char numBuffer[20];

					sprintf_s(numBuffer, "%d", distance);
					strcat_s(message, numBuffer);

					sendSpotterMessage(message);
					
					numAccidents += 1;

					return true;
				}
			}
		}

		if (slowCarsAhead.size() > 0)
		{
			if (cycle > nextSlowCarAhead)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < slowCarsAhead.size(); i++)
					distance = ((distance < slowCarsAhead[i].distance) ? distance : slowCarsAhead[i].distance);

				if (distance > 100) {
					nextSlowCarAhead = cycle + 200;
					nextAccidentBehind = cycle + 200;

					char message[40] = "slowCarAlert:";
					char numBuffer[20];

					sprintf_s(numBuffer, "%d", distance);
					strcat_s(message, numBuffer);

					sendSpotterMessage(message);
					
					numAccidents += 1;

					return true;
				}
			}
		}

		if (accidentsBehind.size() > 0)
		{
			if (cycle > nextAccidentBehind)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < accidentsBehind.size(); i++)
					distance = ((distance < accidentsBehind[i].distance) ? distance : accidentsBehind[i].distance);

				if (distance > 50) {
					nextAccidentBehind = cycle + 400;

					char message[40] = "accidentAlert:Behind;";
					char numBuffer[20];

					sprintf_s(numBuffer, "%d", distance);
					strcat_s(message, numBuffer);

					sendSpotterMessage(message);
					
					numAccidents += 1;

					return true;
				}
			}
		}
	}

	return false;
}

bool checkFlagState(const SharedMemory* sharedData) {
	if ((waitYellowFlagState & YELLOW) != 0) {
		if (yellowCount > 50) {
			if (!(sharedData->mHighestFlagColour == FLAG_COLOUR_YELLOW || sharedData->mHighestFlagColour == FLAG_COLOUR_DOUBLE_YELLOW))
				waitYellowFlagState &= ~YELLOW;

			yellowCount = 0;

			if ((waitYellowFlagState & YELLOW) != 0) {
				sendSpotterMessage("yellowFlag:Ahead");

				waitYellowFlagState &= ~YELLOW;

				return true;
			}
		}
		else
			yellowCount += 1;
	}
	else
		yellowCount = 0;

	if (sharedData->mHighestFlagColour == FLAG_COLOUR_BLUE) {
		if ((lastFlagState & BLUE) == 0 && cycle > nextBlueFlag) {
			nextBlueFlag = cycle + 400;

			sendSpotterMessage("blueFlag");

			lastFlagState |= BLUE;

			return true;
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

	if (sharedData->mHighestFlagColour == FLAG_COLOUR_YELLOW || sharedData->mHighestFlagColour == FLAG_COLOUR_DOUBLE_YELLOW) {
		if ((lastFlagState & YELLOW) == 0) {
			/*
			sendSpotterMessage("yellowFlag:Ahead");

			lastFlagState |= YELLOW;

			return true;
			*/

			lastFlagState |= YELLOW;
			waitYellowFlagState |= YELLOW;
			yellowCount = 0;
		}
	}
	else if ((lastFlagState & YELLOW) != 0) {
		if (waitYellowFlagState != lastFlagState)
			sendSpotterMessage("yellowFlag:Clear");

		lastFlagState &= ~YELLOW;
		waitYellowFlagState &= ~YELLOW;
		yellowCount = 0;

		return true;
	}

	return false;
}

bool checkPitWindow(const SharedMemory* sharedData) {
	if (sharedData->mEnforcedPitStopLap > 0)
		if ((sharedData->mEnforcedPitStopLap == sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted + 1) &&
			!pitWindowOpenReported) {
			pitWindowOpenReported = true;
			pitWindowClosedReported = false;

			sendSpotterMessage("pitWindow:Open");

			return true;
		}
		else if ((sharedData->mEnforcedPitStopLap < sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted) &&
			!pitWindowClosedReported) {
			pitWindowClosedReported = true;
			pitWindowOpenReported = false;

			sendSpotterMessage("pitWindow:Closed");

			return true;
		}

	return false;
}

bool greenFlagReported = false;

bool greenFlag(SharedMemory* shm) {
	if (!greenFlagReported && (shm->mHighestFlagColour == FLAG_COLOUR_GREEN) && ((shm->mSessionState == SESSION_FORMATION_LAP) || (shm->mSessionState == SESSION_RACE))) {
		greenFlagReported = true;
		
		sendSpotterMessage("greenFlag");
		
		Sleep(2000);
		
		return true;
	}
	else
		return false;
}

class CornerDynamics {
public:
	float speed;
	float usos;
	int completedLaps;
	int phase;
public:
	CornerDynamics(float speed, float usos, int completedLaps, int phase) :
		speed(speed),
		usos(usos),
		completedLaps(completedLaps),
		phase(phase) {}
};

float lastTopSpeed = 0;
int lastLaps = 0;

void updateTopSpeed(const SharedMemory* sharedData)
{
	float speed = sharedData->mSpeed * 3.6;

	if (speed > lastTopSpeed)
		lastTopSpeed = speed;

	if (sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted > lastLaps)
	{
		char message[40] = "speedUpdate:";
		char numBuffer[20];

		sprintf_s(numBuffer, "%f", lastTopSpeed);
		strcat_s(message, numBuffer);

		sendSpotterMessage(message);

		lastTopSpeed = 0;
		lastLaps = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted;
	}
}

const int MAXVALUES = 6;

std::vector<float> recentSteerAngles;
std::vector<float> recentGLongs;
std::vector<float> recentIdealAngVels;
std::vector<float> recentRealAngVels;

void pushValue(std::vector<float>& values, float value) {
	values.push_back(value);

	if ((int)values.size() > MAXVALUES)
		values.erase(values.begin());
}

float averageValue(std::vector<float>& values, int& num) {
	std::vector <float>::iterator iter;
	float sum = 0.0;

	num = 0;

	for (iter = values.begin(); iter != values.end(); iter++) {
		sum += *iter;
		num++;
	}

	return (num > 0) ? sum / num : 0.0;
}

float smoothValue(std::vector<float>& values, float value) {
	int ignore;

	if (false) {
		pushValue(values, value);

		return averageValue(values, ignore);
	}
	else
		return value;
}

std::vector<CornerDynamics> cornerDynamicsList;

std::string dataFile = "";
int understeerLightThreshold = 12;
int understeerMediumThreshold = 20;
int understeerHeavyThreshold = 35;
int oversteerLightThreshold = 2;
int oversteerMediumThreshold = -6;
int oversteerHeavyThreshold = -10;
int lowspeedThreshold = 100;
int steerLock = 900;
int steerRatio = 14;
int wheelbase = 270;
int trackWidth = 150;

int lastCompletedLaps = 0;
float lastSpeed = 0.0;
long lastSound = 0;

bool triggerUSOSBeep(std::string soundsDirectory, std::string audioDevice, float usos) {
	std::string wavFile = "";

	if (usos < oversteerHeavyThreshold)
		wavFile = soundsDirectory + "\\Oversteer Heavy.wav";
	else if (usos < oversteerMediumThreshold)
		wavFile = soundsDirectory + "\\Oversteer Medium.wav";
	else if (usos < oversteerLightThreshold)
		wavFile = soundsDirectory + "\\Oversteer Light.wav";
	else if (usos > understeerHeavyThreshold)
		wavFile = soundsDirectory + "\\Understeer Heavy.wav";
	else if (usos > understeerMediumThreshold)
		wavFile = soundsDirectory + "\\Understeer Medium.wav";
	else if (usos > understeerLightThreshold)
		wavFile = soundsDirectory + "\\Understeer Light.wav";

	if (wavFile != "") {
		if (audioDevice != "")
			sendAnalyzerMessage(("acousticFeedback:" + wavFile).c_str());
		else
			PlaySoundA(wavFile.c_str(), NULL, SND_FILENAME | SND_ASYNC);

		return true;
	}
	else
		return false;
}

bool collectTelemetry(const SharedMemory* sharedData, std::string soundsDirectory, std::string audioDevice, bool calibrate) {
	if (sharedData->mGameState == GAME_INGAME_PAUSED && sharedData->mPitMode != PIT_MODE_NONE)
		return true;

	float steerAngle = smoothValue(recentSteerAngles, sharedData->mSteering);

	float acceleration = sharedData->mSpeed * 3.6 - lastSpeed;

	lastSpeed = sharedData->mSpeed * 3.6;

	pushValue(recentGLongs, acceleration);

	double angularVelocity = smoothValue(recentRealAngVels, sharedData->mAngularVelocity[VEC_Y]);
	double steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	double steerAngleRadians = -steeredAngleDegs / 57.2958;
	double wheelBaseMeter = (float)wheelbase / 100;
	double radius = wheelBaseMeter / steerAngleRadians;
	double perimeter = radius * PI * 2;
	double perimeterSpeed = lastSpeed / 3.6;
	double idealAngularVelocity = smoothValue(recentIdealAngVels, perimeterSpeed / perimeter * 2 * PI);

	if (fabs(steerAngle) > 0.1 && lastSpeed > 60) {
		// Get the average recent GLong
		int numGLong = 0;
		float glongAverage = averageValue(recentGLongs, numGLong);

		int phase = 0;
		if (numGLong > 0) {
			if (glongAverage < -0.2) {
				// Braking
				phase = -1;
			}
			else if (glongAverage > 0.1) {
				// Accelerating
				phase = 1;
			}
		}

		CornerDynamics cd = CornerDynamics(sharedData->mSpeed * 3.6, 0,
										   sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted,
										   phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			double slip = fabs(idealAngularVelocity - angularVelocity);

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

			if ((soundsDirectory != "") && GetTickCount() > (lastSound + 300))
				if (triggerUSOSBeep(soundsDirectory, audioDevice, cd.usos))
					lastSound = GetTickCount();

			if (false) {
				std::ofstream output;

				output.open(dataFile + ".trace", std::ios::out | std::ios::app);

				output << steerAngle << "  " << steeredAngleDegs << "  " << steerAngleRadians << "  " <<
					      lastSpeed << "  " << idealAngularVelocity << "  " << angularVelocity << "  " << slip << "  " <<
						  cd.usos << std::endl;

				output.close();
				
				Sleep(200);
			}
		}

		cornerDynamicsList.push_back(cd);

		int completedLaps = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted;

		if (lastCompletedLaps != completedLaps) {
			lastCompletedLaps = completedLaps;

			// Delete all corner data nore than 2 laps old.
			cornerDynamicsList.erase(
				std::remove_if(cornerDynamicsList.begin(), cornerDynamicsList.end(),
					[completedLaps](const CornerDynamics& o) { return o.completedLaps < completedLaps - 1; }),
				cornerDynamicsList.end());
		}
	}

	return true;
}

void writeTelemetry(const SharedMemory* sharedData, bool calibrate) {
	std::ofstream output;

	try {
		output.open(dataFile + ".tmp", std::ios::out | std::ios::trunc);

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

		std::vector <CornerDynamics>::iterator cornerIter;
		for (cornerIter = cornerDynamicsList.begin(); cornerIter != cornerDynamicsList.end(); cornerIter++) {
			CornerDynamics corner = *cornerIter;
			int phase = corner.phase + 1;

			if (calibrate) {
				if (corner.speed < lowspeedThreshold) {
					slowOSMin[phase] = min(slowOSMin[phase], (int)corner.usos);
					slowUSMax[phase] = max(slowUSMax[phase], (int)corner.usos);
				}
				else {
					fastOSMin[phase] = min(fastOSMin[phase], (int)corner.usos);
					fastUSMax[phase] = max(fastUSMax[phase], (int)corner.usos);
				}
			}
			else {
				if (corner.speed < lowspeedThreshold) {
					slowTotalNum++;

					if (corner.usos < oversteerHeavyThreshold) {
						slowHeavyOSNum[phase]++;
					}
					else if (corner.usos < oversteerMediumThreshold) {
						slowMediumOSNum[phase]++;
					}
					else if (corner.usos < oversteerLightThreshold) {
						slowLightOSNum[phase]++;
					}
					else if (corner.usos > understeerHeavyThreshold) {
						slowHeavyUSNum[phase]++;
					}
					else if (corner.usos > understeerMediumThreshold) {
						slowMediumUSNum[phase]++;
					}
					else if (corner.usos > understeerLightThreshold) {
						slowLightUSNum[phase]++;
					}
				}
				else {
					fastTotalNum++;
					
					if (corner.usos < oversteerHeavyThreshold) {
						fastHeavyOSNum[phase]++;
					}
					else if (corner.usos < oversteerMediumThreshold) {
						fastMediumOSNum[phase]++;
					}
					else if (corner.usos < oversteerLightThreshold) {
						fastLightOSNum[phase]++;
					}
					else if (corner.usos > understeerHeavyThreshold) {
						fastHeavyUSNum[phase]++;
					}
					else if (corner.usos > understeerMediumThreshold) {
						fastMediumUSNum[phase]++;
					}
					else if (corner.usos > understeerLightThreshold) {
						fastLightUSNum[phase]++;
					}
				}
			}
		}

		if (calibrate) {
			output << "[Understeer.Slow]" << std::endl;

			output << "Entry=" << slowUSMax[0] << std::endl;
			output << "Apex=" << slowUSMax[1] << std::endl;
			output << "Exit=" << slowUSMax[2] << std::endl;
			
			output << "[Understeer.Fast]" << std::endl;

			output << "Entry=" << fastUSMax[0] << std::endl;
			output << "Apex=" << fastUSMax[1] << std::endl;
			output << "Exit=" << fastUSMax[2] << std::endl;
			
			output << "[Oversteer.Slow]" << std::endl;

			output << "Entry=" << slowOSMin[0] << std::endl;
			output << "Apex=" << slowOSMin[1] << std::endl;
			output << "Exit=" << slowOSMin[2] << std::endl;
			
			output << "[Oversteer.Fast]" << std::endl;

			output << "Entry=" << fastOSMin[0] << std::endl;
			output << "Apex=" << fastOSMin[1] << std::endl;
			output << "Exit=" << fastOSMin[2] << std::endl;
		}
		else {
			output << "[Understeer.Slow.Light]" << std::endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowLightUSNum[0] / slowTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * slowLightUSNum[1] / slowTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * slowLightUSNum[2] / slowTotalNum) << std::endl;
			}

			output << "[Understeer.Slow.Medium]" << std::endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowMediumUSNum[0] / slowTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * slowMediumUSNum[1] / slowTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * slowMediumUSNum[2] / slowTotalNum) << std::endl;
			}

			output << "[Understeer.Slow.Heavy]" << std::endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum) << std::endl;
			}

			output << "[Understeer.Fast.Light]" << std::endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastLightUSNum[0] / fastTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * fastLightUSNum[1] / fastTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * fastLightUSNum[2] / fastTotalNum) << std::endl;
			}

			output << "[Understeer.Fast.Medium]" << std::endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastMediumUSNum[0] / fastTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * fastMediumUSNum[1] / fastTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * fastMediumUSNum[2] / fastTotalNum) << std::endl;
			}

			output << "[Understeer.Fast.Heavy]" << std::endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum) << std::endl;
			}

			output << "[Oversteer.Slow.Light]" << std::endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowLightOSNum[0] / slowTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * slowLightOSNum[1] / slowTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * slowLightOSNum[2] / slowTotalNum) << std::endl;
			}

			output << "[Oversteer.Slow.Medium]" << std::endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowMediumOSNum[0] / slowTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * slowMediumOSNum[1] / slowTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * slowMediumOSNum[2] / slowTotalNum) << std::endl;
			}

			output << "[Oversteer.Slow.Heavy]" << std::endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum) << std::endl;
			}

			output << "[Oversteer.Fast.Light]" << std::endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastLightOSNum[0] / fastTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * fastLightOSNum[1] / fastTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * fastLightOSNum[2] / fastTotalNum) << std::endl;
			}

			output << "[Oversteer.Fast.Medium]" << std::endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastMediumOSNum[0] / fastTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * fastMediumOSNum[1] / fastTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * fastMediumOSNum[2] / fastTotalNum) << std::endl;
			}

			output << "[Oversteer.Fast.Heavy]" << std::endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum) << std::endl;
				output << "Apex=" << (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum) << std::endl;
				output << "Exit=" << (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum) << std::endl;
			}
		}

		output.close();

		remove(dataFile.c_str());

		rename((dataFile + ".tmp").c_str(), dataFile.c_str());
	}
	catch (...) {
		try {
			output.close();
		}
		catch (...) {
		}

		// retry next round...
	}
}

float initialX = 0.0;
float initialY = 0.0;
int coordCount = 0;

bool circuit = true;
bool mapStarted = false;

bool writeCoordinates(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		int carID = sharedData->mViewedParticipantIndex;

		float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
		float coordinateY = -sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

		mapStarted = true;

		printf("%f,%f\n", coordinateX, coordinateY);

		if (coordCount == 0) {
			initialX = coordinateX;
			initialY = coordinateY;
		}
		else if (circuit && coordCount > 100 && fabs(coordinateX - initialX) < 10.0 && fabs(coordinateY - initialY) < 10.0)
			return false;

		coordCount += 1;
	}
	else if (mapStarted && !circuit)
		return false;

	return true;
}

float xCoordinates[60];
float yCoordinates[60];
int numCoordinates = 0;
time_t lastUpdate = 0;

void checkCoordinates(const SharedMemory* sharedData) {
	if (time(NULL) > (lastUpdate + 2)) {
		float velocityX = sharedData->mWorldVelocity[VEC_X];
		float velocityY = sharedData->mWorldVelocity[VEC_Z];
		float velocityZ = sharedData->mWorldVelocity[VEC_Y];

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int carID = sharedData->mViewedParticipantIndex;

			float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
			float coordinateY = - sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

			for (int i = 0; i < numCoordinates; i += 1) {
				if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
					char buffer[60] = "";
					char numBuffer[60];

					strcat_s(buffer, "positionTrigger:");
					_itoa_s(i + 1, numBuffer, 10);
					strcat_s(buffer, numBuffer);
					strcat_s(buffer, ";");
					sprintf_s(numBuffer, "%f", xCoordinates[i]);
					strcat_s(buffer, numBuffer);
					strcat_s(buffer, ";");
					sprintf_s(numBuffer, "%f", yCoordinates[i]);
					strcat_s(buffer, numBuffer);

					sendAutomationMessage(buffer);

					lastUpdate = time(NULL);

					break;
				}
			}
		}
	}
}

std::string telemetryDirectory = "";
std::ofstream telemetryFile;
int telemetryLap = -1;

void collectCarTelemetry(const SharedMemory* sharedData) {
	ParticipantInfo vehicle = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex];
	
	try {
		if ((vehicle.mLapsCompleted + 1) != telemetryLap) {
			try {
				telemetryFile.close();
			}
			catch (...) {
			}

			telemetryLap = (vehicle.mLapsCompleted + 1);

			telemetryFile.open(telemetryDirectory + "\\Lap " + std::to_string(telemetryLap) + ".telemetry", std::ios::out | std::ios::app);
		}

		telemetryFile << vehicle.mCurrentLapDistance << ";"
					  << sharedData->mThrottle << ";"
					  << sharedData->mBrake << ";"
					  << sharedData->mSteering << ";"
					  << sharedData->mGear << ";"
					  << sharedData->mRpm << ";"
					  << (sharedData->mSpeed * 3.6) << ";"
					  << "n/a" << ";"
					  << "n/a" << std::endl;
	}
	catch (...) {
		try {
			telemetryFile.close();
		}
		catch (...) {
		}

		// retry next round...
	}
}

bool started = false;

inline const bool active(SharedMemory* shm) {
	if (started)
		return true;
	else if (((shm->mSessionState == SESSION_FORMATION_LAP) || (shm->mSessionState == SESSION_RACE))
				&& (shm->mHighestFlagColour != FLAG_COLOUR_GREEN)
				&& ((long)normalize(shm->mParticipantInfo[shm->mViewedParticipantIndex].mLapsCompleted) == 0))
		return false;

	started = true;

	return true;
}

int main(int argc, char* argv[]) {
	// Open the memory-mapped file
	HANDLE fileHandle = OpenFileMappingA(PAGE_READONLY, FALSE, MAP_OBJECT_NAME);

	const SharedMemory* sharedData = NULL;
	SharedMemory* localCopy = NULL;
	bool mapTrack = false;
	bool positionTrigger = false;
	bool calibrateTelemetry = false;
	bool analyzeTelemetry = false;
	bool carTelemetry = false;

	char* soundsDirectory = "";
	char* audioDevice = "";

	if (argc > 1) {
		calibrateTelemetry = (strcmp(argv[1], "-Calibrate") == 0);
		analyzeTelemetry = calibrateTelemetry || (strcmp(argv[1], "-Analyze") == 0);
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);
		carTelemetry = (strcmp(argv[1], "-Telemetry") == 0);

		if (mapTrack && argc > 2)
			circuit = (strcmp(argv[2], "Circuit") == 0);

		if (analyzeTelemetry) {
			dataFile = argv[2];

			if (calibrateTelemetry) {
				lowspeedThreshold = atoi(argv[3]);
				steerLock = atoi(argv[4]);
				steerRatio = atoi(argv[5]);
				wheelbase = atoi(argv[6]);
				trackWidth = atoi(argv[7]);
			}
			else {
				understeerLightThreshold = atoi(argv[3]);
				understeerMediumThreshold = atoi(argv[4]);
				understeerHeavyThreshold = atoi(argv[5]);
				oversteerLightThreshold = atoi(argv[6]);
				oversteerMediumThreshold = atoi(argv[7]);
				oversteerHeavyThreshold = atoi(argv[8]);
				lowspeedThreshold = atoi(argv[9]);
				steerLock = atoi(argv[10]);
				steerRatio = atoi(argv[11]);
				wheelbase = atoi(argv[12]);
				trackWidth = atoi(argv[13]);

				if (argc > 14) {
					soundsDirectory = argv[14];

					if (argc > 15)
						audioDevice = argv[15];
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
			char* trackLength = argv[2];

			telemetryDirectory = argv[3];
		}
		else {
			if (argc > 1)
				char* trackLength = argv[1];
			
			if (argc > 2)
				aheadAccidentDistance = atoi(argv[2]);

			if (argc > 3)
				behindAccidentDistance = atoi(argv[3]);

			if (argc > 4)
				slowCarDistance = atoi(argv[4]);

			if (argc > 5)
				semFileName = argv[5];
		}
	}

	if (fileHandle != NULL) {
		sharedData = (SharedMemory*)MapViewOfFile(fileHandle, PAGE_READONLY, 0, 0, sizeof(SharedMemory));
		localCopy = new SharedMemory;

		if (sharedData == NULL) {
			CloseHandle(fileHandle);

			fileHandle = NULL;
		}
	}

	if (sharedData != NULL) {
		//------------------------------------------------------------------------------
		// TEST DISPLAY CODE
		//------------------------------------------------------------------------------
		unsigned int updateIndex(0);
		unsigned int indexChange(0);

		bool running = false;
		int countdown = 400;
		long counter = 0;

		while (++counter)
		{
			bool wait = true;

			if (sharedData->mSequenceNumber % 2)
			{
				// Odd sequence number indicates, that write into the shared memory is just happening
				continue;
			}

			indexChange = sharedData->mSequenceNumber - updateIndex;
			updateIndex = sharedData->mSequenceNumber;

			//Copy the whole structure before processing it, otherwise the risk of the game writing into it during processing is too high.
			memcpy(localCopy, sharedData, sizeof(SharedMemory));

			if (localCopy->mSequenceNumber != updateIndex)
			{
				// More writes had happened during the read. Should be rare, but can happen.
				continue;
			}
			
			if (analyzeTelemetry) {
				if (collectTelemetry(localCopy, soundsDirectory, audioDevice, calibrateTelemetry)) {
					if (remainder(counter, 20) == 0)
						writeTelemetry(localCopy, calibrateTelemetry);
				}
				else
					break;
			}
			else if (mapTrack) {
				if (!writeCoordinates(sharedData))
					break;
			}
			else if (positionTrigger)
				checkCoordinates(sharedData);
			else if (active(localCopy)) {
				bool startGo = (localCopy->mHighestFlagColour == FLAG_COLOUR_GREEN);

				if (!greenFlagReported && (counter > 8000))
					greenFlagReported = true;

				if (!running) {
					countdown -= 1;

					running = (startGo || (countdown <= 0));
				}

				if (running) {
					if (carTelemetry)
						collectCarTelemetry(sharedData);
					else {
						if (localCopy->mGameState != GAME_INGAME_PAUSED && localCopy->mPitMode == PIT_MODE_NONE) {
							updateTopSpeed(localCopy);

							cycle += 1;

							if (!startGo || !greenFlag(localCopy))
								if (checkAccident(localCopy))
									wait = false;
								else if (checkFlagState(localCopy) || checkPositions(localCopy))
									wait = false;
								else
									wait = !checkPitWindow(localCopy);
						}
						else {
							longitudinalRearDistance = 5;

							lastSituation = CLEAR;
							carBehind = false;
							carBehindLeft = false;
							carBehindRight = false;
							carBehindReported = false;

							lastFlagState = 0;
						}
					}
				}
				else
					wait = true;
			}
			else
				wait = true;

			if (carTelemetry)
				Sleep(20);
			else if (analyzeTelemetry || positionTrigger)
				Sleep(10);
			else if (wait)
				Sleep(50);
		}
	}

	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}
