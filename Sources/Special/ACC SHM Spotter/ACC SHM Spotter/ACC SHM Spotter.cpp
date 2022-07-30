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

	if (hWnd > 0) {
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

int sessionDuration = 0;

const float nearByXYDistance = 10.0;
const float nearByZDistance = 6.0;
float longitudinalFrontDistance = 4;
float longitudinalRearDistance = 5;
const float lateralDistance = 6;
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

const int YELLOW_SECTOR_1 = 1;
const int YELLOW_SECTOR_2 = 2;
const int YELLOW_SECTOR_3 = 4;

const int YELLOW_FULL = (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3);

const int BLUE = 16;

int blueCount = 0;
int yellowCount = 0;

int lastFlagState = 0;
int waitYellowFlagState = 0;

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
				bool faster = false;

				if (hasLastCoordinates)
					faster = vectorLength(lastCoordinates[id][0] - gf->carCoordinates[id][0],
										  lastCoordinates[id][2] - gf->carCoordinates[id][2]) > speed * 1.05;

				newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
												 gf->carCoordinates[id][0], gf->carCoordinates[id][2], gf->carCoordinates[id][1]);

				if ((newSituation == THREE) && carBehind)
					break;
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
					if (carBehindLeft || carBehindRight || (carBehindCount < 20)) {
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
		if ((lastFlagState & BLUE) == 0) {
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
		if ((lastFlagState & YELLOW_FULL) == 0) {
			sendSpotterMessage("yellowFlag:Full");

			lastFlagState |= YELLOW_FULL;

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

			lastFlagState &= ~YELLOW_FULL;
			waitYellowFlagState &= ~YELLOW_FULL;
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

float initialX = 0.0;
float initialY = 0.0;
int coordCount = 0;

bool writeCoordinates() {
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
		
		cout << coordinateX << "," << coordinateY << endl;

		if (coordCount == 0) {
			initialX = coordinateX;
			initialY = coordinateY;
		}
		else if (coordCount > 100 && fabs(coordinateX - initialX) < 10.0 && fabs(coordinateY - initialY) < 10.0)
			return false;
		
		coordCount += 1;
	}

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

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();
	
	bool running = false;
	bool mapTrack = false;
	bool positionTrigger = false;

	if (argc > 1) {
		mapTrack = (strcmp(argv[1], "-Map") == 0);

		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		if (positionTrigger) {
			for (int i = 2; i < (argc - 1); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				numCoordinates += 1;
			}
		}
	}

	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

	int countdown = 4000;
	int safety = 200;

	while (true) {
		bool wait = true;

		if (mapTrack) {
			if (!writeCoordinates())
				break;
		}
		else if (positionTrigger)
			checkCoordinates();
		else {
			if (!running)
				running = ((gf->flag == AC_GREEN_FLAG) || (countdown-- <= 0) || (pf->speedKmh >= 200));

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
				if ((sessionDuration == 0) && (gf->sessionTimeLeft > 0))
					sessionDuration = gf->sessionTimeLeft;

				if ((gf->status == AC_LIVE) && !gf->isInPit && !gf->isInPitLane) {
					if (!checkFlagState() && !checkPositions())
						wait = !checkPitWindow();
					else
						wait = false;
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
		
		if (positionTrigger)
			Sleep(10);
		else if (wait)
			Sleep(50);
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


