#include "stdafx.h"
#include <stdio.h>
#include <fstream>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include <comdef.h>
#include <iostream>
#include "SharedFileOut.h"
#include <codecvt>
#include <vector>
#include <string>
#include <thread>
#include <unordered_map>

#pragma comment( lib, "winmm.lib" )

#pragma optimize("",off)
using namespace std;

template <typename T, unsigned S>
inline unsigned arraysize(const T(&v)[S])
{
	return S;
}

struct SMElement
{
	HANDLE hMapFile;
	unsigned char* mapFileBuffer;
};

SMElement m_graphics;
SMElement m_physics;
SMElement m_static;

void initPhysics()
{
	TCHAR szName[] = TEXT("Local\\acpmf_physics");
	m_physics.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFilePhysics), szName);
	if (!m_physics.hMapFile)
	{
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACCS", MB_OK);
	}
	m_physics.mapFileBuffer = (unsigned char*)MapViewOfFile(m_physics.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFilePhysics));
	if (!m_physics.mapFileBuffer)
	{
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACCS", MB_OK);
	}
}

void initGraphics()
{
	TCHAR szName[] = TEXT("Local\\acpmf_graphics");
	m_graphics.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFileGraphic), szName);
	if (!m_graphics.hMapFile)
	{
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACCS", MB_OK);
	}
	m_graphics.mapFileBuffer = (unsigned char*)MapViewOfFile(m_graphics.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFileGraphic));
	if (!m_graphics.mapFileBuffer)
	{
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACCS", MB_OK);
	}
}

void initStatic()
{
	TCHAR szName[] = TEXT("Local\\acpmf_static");
	m_static.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFileStatic), szName);
	if (!m_static.hMapFile)
	{
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACCS", MB_OK);
	}
	m_static.mapFileBuffer = (unsigned char*)MapViewOfFile(m_static.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFileStatic));
	if (!m_static.mapFileBuffer)
	{
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACCS", MB_OK);
	}
}

void dismiss(SMElement element)
{
	UnmapViewOfFile(element.mapFileBuffer);
	CloseHandle(element.hMapFile);
}

int sendStringMessage(HWND hWnd, int wParam, string msg) {
	int result = 0;

	if (hWnd) {
		COPYDATASTRUCT cds;
		cds.dwData = (256 * 'R' + 'S');
		cds.cbData = sizeof(char) * (msg.length() + 1);
		cds.lpData = (char *)msg.c_str();

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendSpotterMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Race Spotter.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Race Spotter.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Race Spotter:" + message);
}

void sendAutomationMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Simulator Controller.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Simulator Controller.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Race Spotter:" + message);
}

#define PI 3.14159265

long cycle = 0;
long nextSpeedUpdate = 0;
bool enabled = true;

int sessionDuration = 0;

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

const string noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

bool carBehind = false;
bool carBehindLeft = false;
bool carBehindRight = false;
bool carBehindReported = false;
int carBehindCount = 0;
long nextCarBehind = 0;

const int YELLOW_SECTOR_1 = 1;
const int YELLOW_SECTOR_2 = 2;
const int YELLOW_SECTOR_3 = 4;

const int YELLOW_ALL = (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3);

const int BLUE = 16;

int blueCount = 0;
int yellowCount = 0;
long nextBlueFlag = 0;

int lastFlagState = 0;
int waitYellowFlagState = 0;

float trackLength = 4500;
int aheadAccidentDistance = 800;
int behindAccidentDistance = 500;
int slowCarDistance = 500;

long nextSlowCarAhead = 0;
long nextAccidentAhead = 0;
long nextAccidentBehind = 0;

bool pitWindowOpenReported = false;
bool pitWindowClosedReported = true;

string computeAlert(int newSituation) {
	string alert = noAlert;

	if (lastSituation == newSituation) {
		if (lastSituation > CLEAR) {
			situationCount += 1;

			if (situationCount > situationRepeat) {
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

inline bool sameHeading(float x1, float y1, float x2, float y2) {
	return vectorLength(x1 + x2, y1 + y2) > vectorLength(x1, y1);
}

bool nearBy(float car1X, float car1Y, float car1Z,
			float car2X, float car2Y, float car2Z) {
	return (abs(car1X - car2X) < nearByXYDistance) &&
		   (abs(car1Y - car2Y) < nearByXYDistance) &&
		   (abs(car1Z - car2Z) < nearByZDistance);
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

		if ((abs(transY) < ((transY > 0) ? longitudinalFrontDistance : longitudinalRearDistance)) &&
			(abs(transX) < lateralDistance) && (abs(otherZ - carZ) < verticalDistance))
			return (transX < 0) ? RIGHT : LEFT;
		else {
			if (transY < 0) {
				carBehind = true;

				if ((faster && abs(transY) < longitudinalFrontDistance * 1.5) ||
					(abs(transY) < longitudinalFrontDistance * 2 && abs(transX) > lateralDistance / 2))
					if (transX < 0)
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

float lastCoordinates[60][3];
bool hasLastCoordinates = false;

bool checkPositions() {
	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	float velocityX = pf->velocity[0];
	float velocityY = pf->velocity[2];
	float velocityZ = pf->velocity[1];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		float angle = vectorAngle(velocityX, velocityY);

		int carID = gf->playerCarID;

		int index = 0;

		for (int i = 0; i < gf->activeCars; i++)
			if (gf->carID[i] == carID) {
				carID = i;

				break;
			}

		float coordinateX = gf->carCoordinates[carID][0];
		float coordinateY = gf->carCoordinates[carID][2];
		float coordinateZ = gf->carCoordinates[carID][1];
		float speed = 0.0;

		if (hasLastCoordinates)
			speed = vectorLength(lastCoordinates[carID][0] - coordinateX, lastCoordinates[carID][2] - coordinateY);

		int newSituation = CLEAR;

		carBehind = false;
		carBehindLeft = false;
		carBehindRight = false;

		for (int id = 0; id < gf->activeCars; id++) {
			if (id != carID) {
				float otherSpeed = vectorLength(lastCoordinates[id][0] - gf->carCoordinates[id][0],
												lastCoordinates[id][2] - gf->carCoordinates[id][2]);

				if ((abs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[carID][0] - coordinateX,
																		   lastCoordinates[carID][2] - coordinateY,
																		   lastCoordinates[id][0] - gf->carCoordinates[id][0],
																		   lastCoordinates[id][2] - gf->carCoordinates[id][2])) {
					bool faster = false;

					if (hasLastCoordinates)
						faster = otherSpeed > speed * 1.05;

					newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
						gf->carCoordinates[id][0], gf->carCoordinates[id][2], gf->carCoordinates[id][1]);

					if ((newSituation == THREE) && carBehind)
						break;
				}
			}
		}

		for (int id = 0; id < gf->activeCars; id++) {
			lastCoordinates[id][0] = gf->carCoordinates[id][0];
			lastCoordinates[id][1] = gf->carCoordinates[id][1];
			lastCoordinates[id][2] = gf->carCoordinates[id][2];
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

		string alert = computeAlert(newSituation);

		if (alert != noAlert) {
			longitudinalRearDistance = 4;

			sendSpotterMessage("proximityAlert:" + alert);

			return true;
		}
		else {
			longitudinalRearDistance = 5;
			
			if (carBehind && (cycle > nextCarBehind)) {
				if (!carBehindReported) {
					if (carBehindLeft || carBehindRight || (carBehindCount < 20)) {
						nextCarBehind = cycle + 200;
						carBehindReported = true;

						sendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
							(carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

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

class TrackSplinePoint {
public:
	string key;
	float distance;

	TrackSplinePoint() :
		key(""),
		distance(0) {}

	TrackSplinePoint(string k, float d) :
		key(k),
		distance(d) {}
};

typedef std::unordered_map<std::string, TrackSplinePoint> TrackSpline;

TrackSpline trackSpline1 = TrackSpline();
TrackSpline trackSpline2 = TrackSpline();
TrackSpline* buildTrackSpline = NULL;

float startPosX, startPosY, referenceDriverPosX, referenceDriverPosY;
float buildTrackSplineRunning;

int referenceDriverIdx;
long lastTrackSplineUpdate = 0;

bool trackSplineBuilding = false;
bool trackSplineRebuild = false;
long bestLapTime = LONG_MAX;

int minX = INT_MAX;
int maxX = INT_MIN;
int minY = INT_MAX;
int maxY = INT_MIN;

string traceFileName = "";

TrackSpline* activeTrackSpline = NULL;
float activeTrackSplineLength;

bool trackSplineReady = false;

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

void updateIdealLine(int carIdx, double running, double speed) {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	idealLine[(int)std::round(running * (idealLine.size() - 1))].update(speed, gf->carCoordinates[carIdx][0], gf->carCoordinates[carIdx][2]);
}

class CarPosition {
public:
	long lastUpdate;

	float posX;
	float posY;

	CarPosition() :
		lastUpdate(0), posX(0), posY(0) {}

	CarPosition(long lu, float x, float y) :
		lastUpdate(lu),
		posX(x),
		posY(y) {}
};

std::unordered_map<int, CarPosition> lastCarCoordinates;

long lastCarCoordinatesCount = 0;
long lastCarCoordinatesUpdate = 0;

inline bool getLastCarCoordinates(int carIndex, float* posX, float* posY) {
	int carID = ((SPageFileGraphic*)m_graphics.mapFileBuffer)->carID[carIndex];

	if (lastCarCoordinates.contains(carID) && (lastCarCoordinates[carID].lastUpdate == lastCarCoordinatesCount)) {
		(*posX) = lastCarCoordinates[carID].posX;
		(*posY) = lastCarCoordinates[carID].posY;

		return true;
	}
	else
		return false;
}

bool getLastCarCoordinates(int carIndex, long milliSeconds, float* speed) {
	float lastX, lastY;

	if (getLastCarCoordinates(carIndex, &lastX, &lastY)) {
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		float newPosX = gf->carCoordinates[carIndex][0];
		float newPosY = gf->carCoordinates[carIndex][2];

		(*speed) = (vectorLength(lastX - newPosX, lastY - newPosY) / ((float)milliSeconds / 1000.0f)) * 3.6f;

		return true;
	}
	else
		return false;
}

void updateLastCarCoordinates(bool init) {
	lastCarCoordinatesUpdate = GetTickCount();

	if (init) {
		lastCarCoordinates.clear();
		lastCarCoordinatesCount = 0;
	}
	else {
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		lastCarCoordinatesCount += 1;

		for (int i = 0; i < gf->activeCars; i++) {
			int carID = gf->carID[i];

			if (lastCarCoordinates.contains(carID)) {
				lastCarCoordinates[carID].lastUpdate = lastCarCoordinatesCount;
				lastCarCoordinates[carID].posX = gf->carCoordinates[i][0];
				lastCarCoordinates[carID].posY = gf->carCoordinates[i][2];
			}
			else
				lastCarCoordinates[carID] = CarPosition(lastCarCoordinatesCount, gf->carCoordinates[i][0], gf->carCoordinates[i][2]);
		}
	}
}

inline bool hasValidCarCoordinates(long* milliSeconds) {
	(*milliSeconds) = GetTickCount() - lastCarCoordinatesUpdate;
	
	if ((*milliSeconds) < 75)
		return false;
	else if ((*milliSeconds) > 200) {
		updateLastCarCoordinates(false);

		return false;
	}
	else
		return true;
}

void updateTrackSpline() {
	try {
		if (trackSplineBuilding) {
			if ((GetTickCount() - lastTrackSplineUpdate) < 50)
				return;

			SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
			
			float newPosX = gf->carCoordinates[referenceDriverIdx][0];
			float newPosY = gf->carCoordinates[referenceDriverIdx][2];
			double distance = vectorLength(referenceDriverPosX - newPosX, referenceDriverPosY - newPosY);
			
			referenceDriverPosX = newPosX;
			referenceDriverPosY = newPosY;

			bool done = false;

			/*
			if (trackLength > 0)
				done = (buildTrackSplineRunning > (trackLength * 0.8) && fabs(newPosX - startPosX) < 25.0 && fabs(newPosY - startPosY) < 25.0);
			else
			*/
				done = (buildTrackSpline->size() > 100 && fabs(newPosX - startPosX) < 25.0 && fabs(newPosY - startPosY) < 25.0);

			if (distance > 0) {
				if (done) {
					trackSplineBuilding = false;

					if (!trackSplineReady || trackSplineRebuild || ((gf->iLastTime > 0) && ((gf->iLastTime * 1.002) < bestLapTime))) {
						bestLapTime = gf->iLastTime;

						int length = idealLine.size();

						for (int i = 0; i < length; i++)
							idealLine[i].clear();

						updateLastCarCoordinates(true);

						int last = (int)(buildTrackSpline->size() / 2) - 1;

						buildTrackSplineRunning = 0;

						for (int i = 0; i <= last; i++) {
							TrackSplinePoint point = (*buildTrackSpline)["#" + std::to_string(i)];

							if (point.distance < buildTrackSplineRunning)
								buildTrackSpline->erase(point.key);
							else
								buildTrackSplineRunning = point.distance;

							// buildTrackSpline->erase("#" + std::to_string(i));
						}

						activeTrackSpline = buildTrackSpline;
						activeTrackSplineLength = buildTrackSplineRunning;

						if (traceFileName != "") {
							std::ofstream output;

							output.open(traceFileName, std::ios::out | std::ios::app);

							output << "========== Finished mapping track (" << buildTrackSplineRunning << ", " << maxX - minX << ", " << maxY - minY << ") ==========" << std::endl;

							output.close();
						}
						
						int zeroCount = 0;
						last = (int)(activeTrackSpline->size() / 2) - 1;
						
						for (int i = 0; i <= last; i++) {
							TrackSplinePoint point = (*activeTrackSpline)["#" + std::to_string(i)];
							
							if (point.distance == 0)
								zeroCount += 1;
						}

						trackSplineReady = (last > 100 && ((float)zeroCount / (float)last) < 0.1);
						trackSplineBuilding = false;
					}
				}
				else {
					string key = std::to_string((long)round(newPosX / 5)) + "|" + std::to_string((long)round(newPosY / 5));

					if (!buildTrackSpline->contains(key)) {
						buildTrackSplineRunning += distance;

						TrackSplinePoint point = TrackSplinePoint(key, buildTrackSplineRunning);
						int index = (int)(buildTrackSpline->size() / 2);

						(*buildTrackSpline)[key] = point;
						(*buildTrackSpline)["#" + std::to_string(index)] = point;
					}
					else {
						buildTrackSplineRunning = (*buildTrackSpline)[key].distance;

						distance = 0;
					}

					lastTrackSplineUpdate = GetTickCount();

					minX = min(minX, (int)round(newPosX));
					maxX = max(maxX, (int)round(newPosX));
					minY = min(minY, (int)round(newPosX));
					maxY = max(maxY, (int)round(newPosX));

					/*
					if ((distance > 0) && (traceFileName != "")) {
						std::ofstream output;

						output.open(traceFileName, std::ios::out | std::ios::app);

						output << buildTrackSpline->size() << ": Track: " << buildTrackSplineRunning << "; Distance: " << round(distance) << "; Key: " << key << std::endl;

						output.close();
					}
					*/
				}
			}
		}
	}
	catch (const std::exception& ex) {
		sendSpotterMessage("internalError:" + std::string(ex.what()));
	}
	catch (const std::string& ex) {
		sendSpotterMessage("internalError:" + ex);
	}
	catch (...) {
		sendSpotterMessage("internalError");
	}
}

int baseLap = -1;

bool startTrackSplineBuilder(int driverIdx, bool rebuild = false) {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	if (baseLap == -1)
		baseLap = gf->completedLaps + 1;
	else if (baseLap <= gf->completedLaps) {
		if ((int)activeTrackSpline == (int)&trackSpline1) {
			trackSpline2.clear();
			trackSpline2.reserve(2000);

			buildTrackSpline = &trackSpline2;
		}
		else {
			trackSpline1.clear();
			trackSpline1.reserve(2000);

			buildTrackSpline = &trackSpline1;
		}

		trackSplineBuilding = true;
		trackSplineRebuild = rebuild;
		buildTrackSplineRunning = 0;

		referenceDriverPosX = gf->carCoordinates[driverIdx][0];
		referenceDriverPosY = gf->carCoordinates[driverIdx][2];

		startPosX = referenceDriverPosX;
		startPosY = referenceDriverPosY;

		referenceDriverIdx = driverIdx;

		lastTrackSplineUpdate = GetTickCount();

		if (traceFileName != "") {
			minX = INT_MAX;
			maxX = INT_MIN;
			minY = INT_MAX;
			maxY = INT_MIN;

			std::ofstream output;

			output.open(traceFileName, std::ios::out | std::ios::app);

			output << "========== Start mapping track (" << (int)activeTrackSpline << ", " << (int)buildTrackSpline << ") ==========" << std::endl;

			output.close();
		}

		return true;
	}

	return false;
}

float getRunning(int carIdx) {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	string key = std::to_string((long)round(gf->carCoordinates[carIdx][0] / 5)) + "|" +
				 std::to_string((long)round(gf->carCoordinates[carIdx][2] / 5));

	if (activeTrackSpline->contains(key)) {
		float distance = activeTrackSpline->at(key).distance;

		/*
		if (traceFileName != "") {
			std::ofstream output;

			output.open(traceFileName, std::ios::out | std::ios::app);

			output << "D " << distance << "; " << distance / activeTrackSplineLength << endl;

			output.close();
		}
		*/

		return distance / activeTrackSplineLength;
	}
	else
		return -1;
}

inline float getSpeed(int carIdx, long milliSeconds) {
	float speed;

	if (getLastCarCoordinates(carIdx, milliSeconds, &speed))
		return speed;
	else
		return -1;
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

int completedLaps = 0;
int numAccidents = 0;

string semFileName = "";

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

bool checkAccident() {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	bool accident = false;
	
	if (gf->isInPit || gf->isInPitLane) {
		trackSplineBuilding = false;

		baseLap = -1;
		bestLapTime = LONG_MAX;

		return false;
	}
	
	if (gf->completedLaps > completedLaps) {
		if (numAccidents >= (trackLength / 1000)) {
			int length = idealLine.size();

			for (int i = 0; i < length; i++)
				idealLine[i].clear();
		}
		
		completedLaps = gf->completedLaps;
		numAccidents = 0;
	}

	int carID = gf->playerCarID;

	for (int i = 0; i < gf->activeCars; i++)
		if (gf->carID[i] == carID) {
			carID = i;

			break;
		}

	if (idealLine.size() == 0) {
		idealLine.reserve(trackLength / 4);

		for (int i = 0; i < (trackLength / 4); i++)
			idealLine.push_back(IdealLine());
	}

	if (trackSplineBuilding) {
		if ((strlen(semFileName.c_str()) > 0) && fileExists(semFileName))
		{
			std::remove(semFileName.c_str());

			int length = idealLine.size();

			for (int i = 0; i < length; i++)
				idealLine[i].clear();

			startTrackSplineBuilder(carID);
		}
		else
			updateTrackSpline();
	}
	else
		startTrackSplineBuilder(carID);

	if (!trackSplineReady)
		return false;

	long milliSeconds;

	if (!hasValidCarCoordinates(&milliSeconds))
		return false;

	accidentsAhead.clear();
	accidentsBehind.clear();
	slowCarsAhead.clear();

	float driverRunning = getRunning(carID);
	
	if (traceFileName != "") {
		std::ofstream output;

		output.open(traceFileName, std::ios::out | std::ios::app);

		output << "D (" << carID << "): " << driverRunning << endl;

		output.close();
	}

	if (driverRunning >= 0) {
		try
		{
			float driverDistance = driverRunning * trackLength;

			for (int i = 0; i < gf->activeCars; i++) {
				double speed = getSpeed(i, milliSeconds);
				double running = getRunning(i);
				double avgSpeed = -1;
				
				if (i != carID) {
					if (speed >= 5) {
						if (running >= 0) {				
							avgSpeed = getAverageSpeed(running);
				
							if (traceFileName != "") {
								std::ofstream output;

								output.open(traceFileName, std::ios::out | std::ios::app);

								output << "S (" << i << "): " << running << "; " << speed << "; " << avgSpeed << endl;

								output.close();
							}

							if (speed < (avgSpeed / 2))
							{
								clearAverageSpeed(running);
								
								float distance = running * trackLength;

								long distanceAhead = (long)(((distance > driverDistance) ? distance : (distance + trackLength)) - driverDistance);

								if (speed < (avgSpeed / 5))
								{
									if (distanceAhead < aheadAccidentDistance) {
										accidentsAhead.push_back(SlowCarInfo(gf->carID[i], distanceAhead));

										if (traceFileName != "") {
											std::ofstream output;

											output.open(traceFileName, std::ios::out | std::ios::app);

											output << endl << "Accident Ahead: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceAhead) << std::endl;

											output.close();
										}
									}

									long distanceBehind = (long)(((distance < driverDistance) ? driverDistance : (driverDistance + trackLength)) - distance);

									if (distanceBehind < behindAccidentDistance) {
										accidentsBehind.push_back(SlowCarInfo(gf->carID[i], distanceBehind));

										if (traceFileName != "") {
											std::ofstream output;

											output.open(traceFileName, std::ios::out | std::ios::app);

											output << endl << "Accident Behind: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceBehind) << std::endl;

											output.close();
										}
									}
								}
								else if (distanceAhead < slowCarDistance) {
									slowCarsAhead.push_back(SlowCarInfo(gf->carID[i], distanceAhead));

									if (traceFileName != "") {
										std::ofstream output;

										output.open(traceFileName, std::ios::out | std::ios::app);

										output << endl << "Slow: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceAhead) << std::endl;

										output.close();
									}
								}
							}
							else
								updateIdealLine(i, running, speed);
						}
					}
				}
				else {
					if (speed >= 5) {
						if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
							accident = true;
					}
				}
			}
		}
		catch (const std::exception& ex) {
			if (traceFileName != "") {
				std::ofstream output;

				output.open(traceFileName, std::ios::out | std::ios::app);

				output << endl << "Error: " << std::string(ex.what()) << std::endl;

				output.close();
			}

			sendSpotterMessage("internalError:" + std::string(ex.what()));
		}
		catch (const std::string& ex) {
			if (traceFileName != "") {
				std::ofstream output;

				output.open(traceFileName, std::ios::out | std::ios::app);

				output << endl << "Error: " << ex << std::endl;

				output.close();
			}

			sendSpotterMessage("internalError:" + ex);
		}
		catch (...) {
			if (traceFileName != "") {
				std::ofstream output;

				output.open(traceFileName, std::ios::out | std::ios::app);

				output << std::endl << "Error: Unknown" << std::endl;

				output.close();
			}

			sendSpotterMessage("internalError");
		}
	}

	updateLastCarCoordinates(false);

	if (!accident) {
		if (accidentsAhead.size() > 0)
		{
			if (cycle > nextAccidentAhead)
			{
				long distance = LONG_MAX;
				int vehicle = INT_MAX;

				for (int i = 0; i < accidentsAhead.size(); i++)
					if (distance > accidentsAhead[i].distance) {
						distance = accidentsAhead[i].distance;
						vehicle = accidentsAhead[i].vehicle;
					}

				if ((distance > 50) && (vehicle < INT_MAX)) {
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
				int vehicle = INT_MAX;

				for (int i = 0; i < accidentsBehind.size(); i++)
					if (distance > accidentsBehind[i].distance) {
						distance = accidentsBehind[i].distance;
						vehicle = accidentsBehind[i].vehicle;
					}

				if ((distance > 50) && (vehicle < INT_MAX)) {
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

bool checkFlagState() {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	if ((waitYellowFlagState & YELLOW_SECTOR_1) != 0 || (waitYellowFlagState & YELLOW_SECTOR_2) != 0 || (waitYellowFlagState & YELLOW_SECTOR_3) != 0) {
		yellowCount += 1;

		if (yellowCount > 50) {
			if (!gf->GlobalYellow1)
				waitYellowFlagState &= ~YELLOW_SECTOR_1;

			if (!gf->GlobalYellow2)
				waitYellowFlagState &= ~YELLOW_SECTOR_2;

			if (!gf->GlobalYellow3)
				waitYellowFlagState &= ~YELLOW_SECTOR_3;

			yellowCount = 0;

			if ((waitYellowFlagState & YELLOW_SECTOR_1) != 0) {
				sendSpotterMessage("yellowFlag:Sector;1");

				waitYellowFlagState &= ~YELLOW_SECTOR_1;

				return true;
			}

			if ((waitYellowFlagState & YELLOW_SECTOR_2) != 0) {
				sendSpotterMessage("yellowFlag:Sector;2");

				waitYellowFlagState &= ~YELLOW_SECTOR_2;

				return true;
			}

			if ((waitYellowFlagState & YELLOW_SECTOR_3) != 0) {
				sendSpotterMessage("yellowFlag:Sector;3");

				waitYellowFlagState &= ~YELLOW_SECTOR_3;

				return true;
			}
		}
	}
	else
		yellowCount = 0;

	if (gf->flag == AC_BLUE_FLAG) {
		if (((lastFlagState & BLUE) == 0) && (cycle > nextBlueFlag)) {
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

	if (gf->GlobalYellow1 && gf->GlobalYellow2 && gf->GlobalYellow3) {
		if ((lastFlagState & YELLOW_ALL) == 0) {
			sendSpotterMessage("yellowFlag:All");

			lastFlagState |= YELLOW_ALL;

			return true;
		}
	}
	else if (gf->GlobalYellow1) {
		if ((lastFlagState & YELLOW_SECTOR_1) == 0) {
			/*
			sendSpotterMessage("yellowFlag:Sector;1");

			lastFlagState |= YELLOW_SECTOR_1;

			return true;
			*/

			lastFlagState |= YELLOW_SECTOR_1;
			waitYellowFlagState |= YELLOW_SECTOR_1;
			yellowCount = 0;
		}
	}
	else if (gf->GlobalYellow2) {
		if ((lastFlagState & YELLOW_SECTOR_2) == 0) {
			/*
			sendSpotterMessage("yellowFlag:Sector;2");

			lastFlagState |= YELLOW_SECTOR_2;

			return true;
			*/

			lastFlagState |= YELLOW_SECTOR_2;
			waitYellowFlagState |= YELLOW_SECTOR_2;
			yellowCount = 0;
		}
	}
	else if (gf->GlobalYellow3) {
		if ((lastFlagState & YELLOW_SECTOR_3) == 0) {
			/*
			sendSpotterMessage("yellowFlag:Sector;3");

			lastFlagState |= YELLOW_SECTOR_3;

			return true;
			*/

			lastFlagState |= YELLOW_SECTOR_3;
			waitYellowFlagState |= YELLOW_SECTOR_3;
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

			return true;
		}
	}

	return false;
}

bool checkPitWindow() {
	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	int pitWindow = (sf->PitWindowEnd - sf->PitWindowStart);
	
	if (pitWindow > 0) {
		int currentTime = sessionDuration - gf->sessionTimeLeft;
	
		int pitWindowStart = (int)((sessionDuration / 2) - (pitWindow / 2));
		int pitWindowEnd = (int)((sessionDuration / 2) + (pitWindow / 2));
		
		if (pitWindowStart < currentTime && pitWindowEnd > currentTime && !pitWindowOpenReported) {
			pitWindowOpenReported = true;
			pitWindowClosedReported = false;

			sendSpotterMessage("pitWindow:Open");

			return true;
		}
		else if (pitWindowEnd < currentTime && !pitWindowClosedReported) {
			pitWindowClosedReported = true;
			pitWindowOpenReported = false;

			sendSpotterMessage("pitWindow:Closed");

			return true;
		}
	}

	return false;
}

bool greenFlagReported = false;

bool greenFlag() {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	if (!greenFlagReported && (gf->flag == AC_GREEN_FLAG) && (gf->session == AC_RACE)) {
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

void updateTopSpeed() {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	
	if (pf->speedKmh > lastTopSpeed)
		lastTopSpeed = pf->speedKmh;

	if (gf->completedLaps > lastLaps) {
		char message[40] = "speedUpdate:";
		char numBuffer[20];

		sprintf_s(numBuffer, "%f", lastTopSpeed);
		strcat_s(message, numBuffer);

		sendSpotterMessage(message);

		lastTopSpeed = 0;
		lastLaps = gf->completedLaps;
	}
}

float initialX = 0.0;
float initialY = 0.0;
int coordCount = 0;

bool circuit = true;
bool mapStarted = false;
int mapLap = -1;

bool writeCoordinates() {
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	float velocityX = pf->velocity[0];
	float velocityY = pf->velocity[2];
	float velocityZ = pf->velocity[1];

	if (!mapStarted)
		if (mapLap == -1) {
			mapLap = gf->completedLaps;
		
			return true;
		}
		else if (gf->completedLaps == mapLap)
			return true;

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		int carID = gf->playerCarID;

		mapStarted = true;

		for (int i = 0; i < gf->activeCars; i++)
			if (gf->carID[i] == carID) {
				carID = i;

				break;
			}

		float coordinateX = gf->carCoordinates[carID][0];
		float coordinateY = gf->carCoordinates[carID][2];

		cout << coordinateX << "," << coordinateY << endl;

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
char* triggerType = (char *)"Automation";

void checkCoordinates() {
	if (time(NULL) > (lastUpdate + 2)) {
		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		float velocityX = pf->velocity[0];
		float velocityY = pf->velocity[2];
		float velocityZ = pf->velocity[1];

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int carID = gf->playerCarID;

			for (int i = 0; i < gf->activeCars; i++)
				if (gf->carID[i] == carID) {
					carID = i;

					break;
				}

			float coordinateX = gf->carCoordinates[carID][0];
			float coordinateY = gf->carCoordinates[carID][2];

			for (int i = 0; i < numCoordinates; i++) {
				if (abs(xCoordinates[i] - coordinateX) < 20.0 && abs(yCoordinates[i] - coordinateY) < 20.0) {
					char buffer[60] = "";
					char numBuffer[60] = "";

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

string telemetryDirectory = "";
ofstream telemetryFile;
int telemetryLap = -1;
float lastRunning = -1;

void collectCarTelemetry() {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	int carID = gf->playerCarID;

	for (int i = 0; i < gf->activeCars; i++)
		if (gf->carID[i] == carID) {
			carID = i;

			break;
		}

	if (trackSplineReady) {
		float driverRunning = getRunning(carID);

		if (driverRunning > 0)
			try {
				SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
			
				if ((gf->completedLaps + 1) != telemetryLap) {
					try {
						telemetryFile.close();

						remove((telemetryDirectory + "\\Lap " + to_string(telemetryLap) + ".telemetry").c_str());

						rename((telemetryDirectory + "\\Lap " + to_string(telemetryLap) + ".tmp").c_str(),
							   (telemetryDirectory + "\\Lap " + to_string(telemetryLap) + ".telemetry").c_str());

						lastRunning = -1;
					}
					catch (...) {
					}

					telemetryLap = (gf->completedLaps + 1);

					telemetryFile.open(telemetryDirectory + "\\Lap " + to_string(telemetryLap) + ".tmp", ios::out | ios::trunc);
				}

				float velocityX = pf->velocity[0];
				float velocityY = pf->velocity[2];
				float velocityZ = pf->velocity[1];

				if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
					float angle = vectorAngle(velocityX, velocityY);

					float latG = pf->accG[0];
					float longG = pf->accG[2];

					// rotateBy(&longG, &latG, angle);

					// latG *= -1;

					if (driverRunning > lastRunning) {
						telemetryFile << (driverRunning * trackLength) << ";"
							<< (pf->gas >= 0 ? pf->gas : 0) << ";"
							<< (pf->brake >= 0 ? pf->brake : 0) << ";"
							<< pf->steerAngle << ";"
							<< (pf->gear - 1) << ";"
							<< pf->rpms << ";"
							<< pf->speedKmh << ";"
							<< pf->tc << ";"
							<< pf->abs << ";"
							<< longG << ";" << latG << ";"
							<< gf->carCoordinates[carID][0] << ";" << gf->carCoordinates[carID][2] << ";"
							<< gf->iCurrentTime << endl;

						if (fileExists(telemetryDirectory + "\\Telemetry.cmd"))
							try {
								ofstream file;

								file.open(telemetryDirectory + "\\Telemetry.section", ios::out | ios::ate | ios::app);

								file << (driverRunning * trackLength) << ";"
									<< (pf->gas >= 0 ? pf->gas : 0) << ";"
									<< (pf->brake >= 0 ? pf->brake : 0) << ";"
									<< pf->steerAngle << ";"
									<< (pf->gear - 1) << ";"
									<< pf->rpms << ";"
									<< pf->speedKmh << ";"
									<< pf->tc << ";"
									<< pf->abs << ";"
									<< longG << ";" << latG << ";"
									<< gf->carCoordinates[carID][0] << ";" << gf->carCoordinates[carID][2] << ";"
									<< gf->iCurrentTime << endl;

								file.close();
							}
							catch (...) {}
						
						lastRunning = driverRunning;
					}
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
	else if (trackSplineBuilding)
		updateTrackSpline();
	else
		startTrackSplineBuilder(carID, true);
}

bool started = false;

inline const bool active() {
	if (started)
		return true;
	else {
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		if ((gf->session == AC_RACE) && (gf->flag != AC_GREEN_FLAG) && (gf->completedLaps == 0))
			return false;
	}
	
	started = true;

	return true;
}

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();
	
	bool running = false;
	bool mapTrack = false;
	bool positionTrigger = false;
	bool carTelemetry = false;

	if (argc > 1) {
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		positionTrigger = (strcmp(argv[1], "-Automation") == 0);
		carTelemetry = (strcmp(argv[1], "-Telemetry") == 0);

		if (mapTrack) {
			if (argc > 2)
				circuit = (strcmp(argv[2], "Circuit") == 0);

			trackLength = (argc > 3) ? atof(argv[3]) : 0;
		}

		if (positionTrigger) {
			for (int i = 2; i < (argc - 1); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				if (++numCoordinates > 59)
					break;
			}
		}
		else if (carTelemetry) {
			trackLength = atof(argv[2]);
			telemetryDirectory = argv[3];
		}
		else if (!mapTrack) {
			trackLength = (argc > 1) ? atof(argv[1]) : 0;

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

			if (argc > 7) {
				traceFileName = argv[7];

				if (traceFileName == "-")
					traceFileName = "";
			}
		}
	}

	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

	int countdown = 4000;
	int safety = 200;
	long counter = 0;

	while (++counter) {
		bool wait = true;

		if (mapTrack) {
			if (!writeCoordinates())
				break;
		}
		else if (positionTrigger)
			checkCoordinates();
		else if (active()) {
			bool startGo = (gf->flag == AC_GREEN_FLAG);

			if (!greenFlagReported && (counter > 8000))
				greenFlagReported = true;
			
			if (!running) {
				countdown -= 1;

				running = (startGo || (countdown <= 0) || (pf->speedKmh >= 200));
			}

			if (running) {
				if (pf->speedKmh > 120)
					safety = 200;

				if ((safety-- <= 0) && !waitYellowFlagState)
					running = false;
			}
			else if ((safety <= 0) && (pf->speedKmh > 120)) {
				running = true;
				safety = 200;
			}
			
			if ((gf->status == AC_PAUSE) || (gf->status == AC_REPLAY))
				running  = false;

			if (running) {
				if (carTelemetry)
					collectCarTelemetry();
				else {
					if ((sessionDuration == 0) && (gf->sessionTimeLeft > 0))
						sessionDuration = gf->sessionTimeLeft;

					if ((gf->status == AC_LIVE) && !gf->isInPit && !gf->isInPitLane) {
						updateTopSpeed();

						if (cycle > nextSpeedUpdate)
						{
							nextSpeedUpdate = cycle + 50;

							if ((pf->speedKmh >= thresholdSpeed) && !enabled)
							{
								enabled = TRUE;

								sendSpotterMessage("enableSpotter");
							}
							else if ((pf->speedKmh < thresholdSpeed) && enabled)
							{
								enabled = FALSE;

								sendSpotterMessage("disableSpotter");
							}
						}

						cycle += 1;

						if (!startGo || !greenFlag())
							if (enabled)
								if (checkAccident())
									wait = false;
								else if (checkFlagState() || checkPositions())
									wait = false;
								else
									wait = !checkPitWindow();
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

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}