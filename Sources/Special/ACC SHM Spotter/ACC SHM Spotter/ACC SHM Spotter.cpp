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

void sendAnalyzerMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Analyzer:" + message);
}

#define PI 3.14159265

long cycle = 0;

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
			
			if (carBehind) {
				if (!carBehindReported) {
					if (carBehindLeft || carBehindRight || ((carBehindCount < 20) && (cycle > nextCarBehind))) {
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

			if (distance > 0) {
				if (buildTrackSpline->size() > 100 && fabs(newPosX - startPosX) < 30.0 && fabs(newPosY - startPosY) < 30.0) {
					trackSplineBuilding = false;

					if (!trackSplineReady || ((gf->iLastTime > 0) && ((gf->iLastTime * 1.002) < bestLapTime))) {
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

							buildTrackSpline->erase("#" + std::to_string(i));
						}

						activeTrackSpline = buildTrackSpline;
						activeTrackSplineLength = buildTrackSplineRunning;

						trackSplineReady = true;
						trackSplineBuilding = false;

						if (traceFileName != "") {
							std::ofstream output;

							output.open(traceFileName, std::ios::out | std::ios::app);

							output << "========== Finished mapping track (" << buildTrackSplineRunning << ", " << maxX - minX << ", " << maxY - minY << ") ==========" << std::endl;

							output.close();
						}
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

bool startTrackSplineBuilder(int driverIdx) {
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

							if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
							{
								clearAverageSpeed(running);
								
								float distance = running * trackLength;

								long distanceAhead = (long)(((distance > driverDistance) ? distance : (distance + trackLength)) - driverDistance);

								if (speed < (avgSpeed / 5))
								{
									if (distanceAhead < aheadAccidentDistance) {
										accidentsAhead.push_back(SlowCarInfo(i, distanceAhead));

										if (traceFileName != "") {
											std::ofstream output;

											output.open(traceFileName, std::ios::out | std::ios::app);

											output << endl << "Accident Ahead: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceAhead) << std::endl;

											output.close();
										}
									}

									long distanceBehind = (long)(((distance < driverDistance) ? driverDistance : (driverDistance + trackLength)) - distance);

									if (distanceBehind < behindAccidentDistance) {
										accidentsBehind.push_back(SlowCarInfo(i, distanceBehind));

										if (traceFileName != "") {
											std::ofstream output;

											output.open(traceFileName, std::ios::out | std::ios::app);

											output << endl << "Accident Behind: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceBehind) << std::endl;

											output.close();
										}
									}
								}
								else if (distanceAhead < slowCarDistance) {
									slowCarsAhead.push_back(SlowCarInfo(i, distanceAhead));

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

template <typename T> int sgn(T val) {
    return (T(0) < val) - (val < T(0));
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
	vector <float>::iterator iter;
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

string dataFile = "";
int understeerLightThreshold = 12;
int understeerMediumThreshold = 20;
int understeerHeavyThreshold = 35;
int oversteerLightThreshold = 2;
int oversteerMediumThreshold = -6;
int oversteerHeavyThreshold = -10;
int lowspeedThreshold = 100;
int steerLock = 480;
int steerRatio = 12;
int wheelbase = 267;
int trackWidth = 150;

int lastCompletedLaps = 0;
float lastSpeed = 0.0;
long lastSound = 0;

bool triggerUSOSBeep(string soundsDirectory, string audioDevice, float usos) {
	string wavFile = "";

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
			sendAnalyzerMessage("acousticFeedback:" + wavFile);
		else
			PlaySoundA(wavFile.c_str(), NULL, SND_FILENAME | SND_ASYNC);

		return true;
	}
	else
		return false;
}

bool collectTelemetry(string soundsDirectory, string audioDevice, bool calibrate) {
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	if ((gf->status != AC_LIVE) || gf->isInPit || gf->isInPitLane)
		return true;

	float steerAngle = smoothValue(recentSteerAngles, pf->steerAngle);
	float acceleration = pf->speedKmh - lastSpeed;
		
	lastSpeed = pf->speedKmh;

	pushValue(recentGLongs, acceleration);

	float angularVelocity = smoothValue(recentRealAngVels, pf->localAngularVel[1]);
	float steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	double steerAngleRadians = -steeredAngleDegs / 57.2958;
	double wheelBaseMeter = (float)wheelbase / 100;
	double radius = wheelBaseMeter / steerAngleRadians;
	double perimeter = radius * PI * 2;
	double perimeterSpeed = lastSpeed / 3.6;
	float idealAngularVelocity = smoothValue(recentIdealAngVels, perimeterSpeed / perimeter * 2 * PI);

	if (fabs(steerAngle) > 0.1 && pf->speedKmh > 60) {
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

		CornerDynamics cd = CornerDynamics(pf->speedKmh, 0, gf->completedLaps, phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			double slip = fabs(angularVelocity - idealAngularVelocity);
			
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

		int completedLaps = gf->completedLaps;

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

void writeTelemetry(bool calibrate) {
	ofstream output;

	try {
		output.open(dataFile + ".tmp", ios::out | ios::trunc);

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

		vector <CornerDynamics>::iterator cornerIter;
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
			output << "[Understeer.Slow]" << endl;

			output << "Entry=" << slowUSMax[0] << endl;
			output << "Apex=" << slowUSMax[1] << endl;
			output << "Exit=" << slowUSMax[2] << endl;
			
			output << "[Understeer.Fast]" << endl;

			output << "Entry=" << fastUSMax[0] << endl;
			output << "Apex=" << fastUSMax[1] << endl;
			output << "Exit=" << fastUSMax[2] << endl;
			
			output << "[Oversteer.Slow]" << endl;

			output << "Entry=" << slowOSMin[0] << endl;
			output << "Apex=" << slowOSMin[1] << endl;
			output << "Exit=" << slowOSMin[2] << endl;
			
			output << "[Oversteer.Fast]" << endl;

			output << "Entry=" << fastOSMin[0] << endl;
			output << "Apex=" << fastOSMin[1] << endl;
			output << "Exit=" << fastOSMin[2] << endl;
		}
		else {
			output << "[Understeer.Slow.Light]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowLightUSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowLightUSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowLightUSNum[2] / slowTotalNum) << endl;
			}

			output << "[Understeer.Slow.Medium]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowMediumUSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowMediumUSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowMediumUSNum[2] / slowTotalNum) << endl;
			}

			output << "[Understeer.Slow.Heavy]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum) << endl;
			}

			output << "[Understeer.Fast.Light]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastLightUSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastLightUSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastLightUSNum[2] / fastTotalNum) << endl;
			}

			output << "[Understeer.Fast.Medium]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastMediumUSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastMediumUSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastMediumUSNum[2] / fastTotalNum) << endl;
			}

			output << "[Understeer.Fast.Heavy]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum) << endl;
			}

			output << "[Oversteer.Slow.Light]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowLightOSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowLightOSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowLightOSNum[2] / slowTotalNum) << endl;
			}

			output << "[Oversteer.Slow.Medium]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowMediumOSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowMediumOSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowMediumOSNum[2] / slowTotalNum) << endl;
			}

			output << "[Oversteer.Slow.Heavy]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum) << endl;
			}

			output << "[Oversteer.Fast.Light]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastLightOSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastLightOSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastLightOSNum[2] / fastTotalNum) << endl;
			}

			output << "[Oversteer.Fast.Medium]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastMediumOSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastMediumOSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastMediumOSNum[2] / fastTotalNum) << endl;
			}

			output << "[Oversteer.Fast.Heavy]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum) << endl;
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

bool writeCoordinates() {
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	float velocityX = pf->velocity[0];
	float velocityY = pf->velocity[2];
	float velocityZ = pf->velocity[1];

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

void collectCarTelemetry() {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	int carID = gf->playerCarID;

	for (int i = 0; i < gf->activeCars; i++)
		if (gf->carID[i] == carID) {
			carID = i;

			break;
		}

	if (trackSplineBuilding)
		updateTrackSpline();
	else
		startTrackSplineBuilder(carID);

	if (trackSplineReady) {
		float driverRunning = getRunning(carID);

		if (driverRunning >= 0)
			try {
				SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
			
				if ((gf->completedLaps + 1) != telemetryLap) {
					try {
						telemetryFile.close();
					}
					catch (...) {
					}

					telemetryLap = (gf->completedLaps + 1);

					telemetryFile.open(telemetryDirectory + "\\Lap " + to_string(telemetryLap) + ".tlm", ios::out | ios::app);
				}
				
				telemetryFile << (driverRunning * trackLength) << ";"
							  << (pf->gas >= 0 ? pf->gas : 0) << ";"
							  << (pf->brake >= 0 ? pf->brake : 0) << ";"
							  << (pf->steerAngle >= 0 ? pf->steerAngle : 0) << ";"
							  << pf->gear << ";"
							  << pf->rpms << ";"
							  << pf->speedKmh << ";"
							  << pf->tc << ";"
							  << pf->abs << endl;
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
	bool calibrateTelemetry = false;
	bool analyzeTelemetry = false;
	bool positionTrigger = false;
	bool carTelemetry = false;

	char* soundsDirectory = 0;
	char* audioDevice = 0;

	if (argc > 1) {
		calibrateTelemetry = (strcmp(argv[1], "-Calibrate") == 0);
		analyzeTelemetry = calibrateTelemetry || (strcmp(argv[1], "-Analyze") == 0);
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);
		carTelemetry = (strcmp(argv[1], "-Telemetry") == 0);

		if (mapTrack && argc >  2)
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
			trackLength = atof(argv[2]);
			telemetryDirectory = argv[3];
		}
		else {
			if (argc > 1)
				trackLength = atof(argv[1]);

			if (argc > 2)
				aheadAccidentDistance = atoi(argv[2]);

			if (argc > 3)
				behindAccidentDistance = atoi(argv[3]);

			if (argc > 4)
				slowCarDistance = atoi(argv[4]);

			if (argc > 5)
				semFileName = argv[5];

			if (argc > 6) {
				traceFileName = argv[6];

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

		if (analyzeTelemetry) {
			if (collectTelemetry(soundsDirectory ? soundsDirectory : "", audioDevice ? audioDevice : "", calibrateTelemetry)) {
				if (remainder(counter, 20) == 0)
					writeTelemetry(calibrateTelemetry);
			}
			else
				break;
		}
		else if (mapTrack) {
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

			if (running) {
				if (carTelemetry)
					collectCarTelemetry();
				else {
					if ((sessionDuration == 0) && (gf->sessionTimeLeft > 0))
						sessionDuration = gf->sessionTimeLeft;

					if ((gf->status == AC_LIVE) && !gf->isInPit && !gf->isInPitLane) {
						updateTopSpeed();

						cycle += 1;

						if (!startGo || !greenFlag())
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
		
		if (analyzeTelemetry || positionTrigger || carTelemetry)
			Sleep(10);
		else if (wait)
			Sleep(50);
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}