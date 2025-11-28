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

#define PI 3.14159265

long cycle = 0;
long nextSpeedUpdate = 0;
bool enabled = true;

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
				nextCarBehind = cycle + 200;

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
			
			if (carBehind && (cycle > nextCarBehind)) {
				if (!carBehindReported) {
					if (carBehindLeft || carBehindRight || (carBehindCount < 20)) {
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

int thresholdSpeed = 60;

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
					if (speed < (avgSpeed / 2))
					{
						long distanceAhead = (long)(((vehicle.mCurrentLapDistance > driver.mCurrentLapDistance) ? vehicle.mCurrentLapDistance
							: (vehicle.mCurrentLapDistance + sharedData->mTrackLength)) - driver.mCurrentLapDistance);

						clearAverageSpeed(running);

						if (speed < (avgSpeed / 5))
						{
							if (distanceAhead < aheadAccidentDistance)
								accidentsAhead.push_back(SlowCarInfo(i + 1, distanceAhead));

							long distanceBehind = (long)(((vehicle.mCurrentLapDistance < driver.mCurrentLapDistance) ? driver.mCurrentLapDistance
								: (driver.mCurrentLapDistance + sharedData->mTrackLength)) - vehicle.mCurrentLapDistance);

							if (distanceBehind < behindAccidentDistance)
								accidentsBehind.push_back(SlowCarInfo(i + 1, distanceBehind));
						}
						else if (distanceAhead < slowCarDistance)
							slowCarsAhead.push_back(SlowCarInfo(i + 1, distanceAhead));
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
				int vehicle = 0;

				for (int i = 0; i < accidentsAhead.size(); i++)
					if (distance > accidentsAhead[i].distance) {
						distance = accidentsAhead[i].distance;
						vehicle = accidentsAhead[i].vehicle;
					}

				if ((distance > 50) && (vehicle > 0)) {
					nextAccidentAhead = cycle + 400;
					nextAccidentBehind = cycle + 200;
					nextSlowCarAhead = cycle + 200;

					char message[80] = "accidentAlert:Ahead;";
					char numBuffer[20];

					sprintf_s(numBuffer, "%d", distance);
					strcat_s(message, numBuffer);
					strcat_s(message, ";");
					sprintf_s(numBuffer, "%d", vehicle);
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
				int vehicle = 0;

				for (int i = 0; i < accidentsBehind.size(); i++)
					if (distance > accidentsBehind[i].distance) {
						distance = accidentsBehind[i].distance;
						vehicle = accidentsBehind[i].vehicle;
					}

				if ((distance > 50) && (vehicle > 0)) {
					nextAccidentBehind = cycle + 400;

					char message[80] = "accidentAlert:Behind;";
					char numBuffer[20];

					sprintf_s(numBuffer, "%d", distance);
					strcat_s(message, numBuffer);
					strcat_s(message, ";");
					sprintf_s(numBuffer, "%d", vehicle);
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

float initialX = 0.0;
float initialY = 0.0;
int coordCount = 0;

bool circuit = true;
bool mapStarted = false;
int mapLap = -1;

bool writeCoordinates(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];
	int carID = sharedData->mViewedParticipantIndex;

	if (!mapStarted)
		if (mapLap == -1) {
			mapLap = sharedData->mParticipantInfo[carID].mLapsCompleted;

			return true;
		}
		else if (sharedData->mParticipantInfo[carID].mLapsCompleted == mapLap)
			return true;

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
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
char* triggerType = "Automation";

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

					if (strcmp(triggerType, "Automation") == 0)
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
double lastRunning = -1;

void collectCarTelemetry(const SharedMemory* sharedData) {
	ParticipantInfo vehicle = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex];
	
	try {
		if ((vehicle.mLapsCompleted + 1) != telemetryLap) {
			try {
				telemetryFile.close();

				remove((telemetryDirectory + "\\Lap " + std::to_string(telemetryLap) + ".telemetry").c_str());

				rename((telemetryDirectory + "\\Lap " + std::to_string(telemetryLap) + ".tmp").c_str(),
					   (telemetryDirectory + "\\Lap " + std::to_string(telemetryLap) + ".telemetry").c_str());
			}
			catch (...) {
			}

			telemetryLap = (vehicle.mLapsCompleted + 1);

			telemetryFile.open(telemetryDirectory + "\\Lap " + std::to_string(telemetryLap) + ".tmp", std::ios::out | std::ios::trunc);
			
			lastRunning = -1;
		}

		if (vehicle.mCurrentLapDistance > lastRunning) {
			telemetryFile << vehicle.mCurrentLapDistance << ";"
						  << sharedData->mThrottle << ";"
						  << sharedData->mBrake << ";"
						  << sharedData->mSteering << ";"
						  << sharedData->mGear << ";"
						  << sharedData->mRpm << ";"
						  << (sharedData->mSpeed * 3.6) << ";"
						  << "n/a" << ";"
						  << "n/a" << ";"
						  << - sharedData->mLocalAcceleration[VEC_Z] / 9.807f << ";"
						  << sharedData->mLocalAcceleration[VEC_X] / 9.807f << ";"
						  << sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mWorldPosition[VEC_X] << ";"
						  << -sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mWorldPosition[VEC_Z] << ";"
						  << round(sharedData->mCurrentTime * 1000) << std::endl;

			if (fileExists(telemetryDirectory + "\\Telemetry.cmd"))
				try {
					std::ofstream file;

					file.open(telemetryDirectory + "\\Telemetry.section", std::ios::out | std::ios::ate | std::ios::app);

					file << vehicle.mCurrentLapDistance << ";"
						 << sharedData->mThrottle << ";"
						 << sharedData->mBrake << ";"
						 << sharedData->mSteering << ";"
						 << sharedData->mGear << ";"
						 << sharedData->mRpm << ";"
						 << (sharedData->mSpeed * 3.6) << ";"
						 << "n/a" << ";"
						 << "n/a" << ";"
						 << -sharedData->mLocalAcceleration[VEC_Z] / 9.807f << ";"
						 << sharedData->mLocalAcceleration[VEC_X] / 9.807f << ";"
						 << sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mWorldPosition[VEC_X] << ";"
						 << -sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mWorldPosition[VEC_Z] << ";"
						 << round(sharedData->mCurrentTime * 1000) << std::endl;

					file.close();
				}
				catch (...) {}

			lastRunning = vehicle.mCurrentLapDistance;
		}
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
	bool carTelemetry = false;

	if (argc > 1) {
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		positionTrigger = (strcmp(argv[1], "-Automation") == 0);
		carTelemetry = (strcmp(argv[1], "-Telemetry") == 0);

		if (mapTrack && argc > 2)
			circuit = (strcmp(argv[2], "Circuit") == 0);

		if (positionTrigger) {
			for (int i = 2; i < (argc - 1); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				if (++numCoordinates > 59)
					break;
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

			if (argc > 6)
				thresholdSpeed = atoi(argv[6]);
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
			
			if (mapTrack) {
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

				if (running)
					running = ((localCopy->mGameState == GAME_INGAME_PLAYING) || (localCopy->mGameState == GAME_INGAME_INMENU_TIME_TICKING));

				if (running) {
					if (carTelemetry)
						collectCarTelemetry(sharedData);
					else {
						if (localCopy->mGameState != GAME_INGAME_PAUSED && localCopy->mPitMode == PIT_MODE_NONE) {
							updateTopSpeed(localCopy);

							if (cycle > nextSpeedUpdate)
							{
								nextSpeedUpdate = cycle + 50;

								if (((localCopy->mSpeed * 3.6) >= thresholdSpeed) && !enabled)
								{
									enabled = TRUE;

									sendSpotterMessage("enableSpotter");
								}
								else if (((localCopy->mSpeed * 3.6) < thresholdSpeed) && enabled)
								{
									enabled = FALSE;

									sendSpotterMessage("disableSpotter");
								}
							}

							cycle += 1;

							if (!startGo || !greenFlag(localCopy))
								if (enabled)
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

			if (carTelemetry || positionTrigger)
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
