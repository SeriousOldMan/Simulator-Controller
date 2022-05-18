#include "stdafx.h"
#include <stdio.h>
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

void sendMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Race Spotter.exe");

	if (winHandle == 0)
		FindWindowEx(0, 0, 0, L"Race Spotter.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Race Spotter:" + message);
}

#define PI 3.14159265

int sessionDuration = 0;

const float nearByXYDistance = 10.0;
const float nearByZDistance = 6.0;
const float longitudinalDistance = 4;
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

const int YELLOW_SECTOR_1 = 1;
const int YELLOW_SECTOR_2 = 2;
const int YELLOW_SECTOR_3 = 4;

const int YELLOW_FULL = (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3);

const int BLUE = 16;

int blueCount = 0;

int lastFlagState = 0;

bool pitWindowOpenReported = false;
bool pitWindowClosedReported = true;

string computeAlert(int newSituation) {
	string alert = noAlert;

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

		if ((abs(transY) < longitudinalDistance) && (abs(transX) < lateralDistance) && (abs(otherZ - carZ) < verticalDistance))
			return (transX < 0) ? RIGHT : LEFT;
		else {
			if (transY < 0) {
				carBehind = true;

				if ((faster && transY < longitudinalDistance * 1.5) ||
					(transY < longitudinalDistance * 2 && abs(transX) > lateralDistance / 2))
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

		string alert = computeAlert(newSituation);

		if (alert != noAlert) {
			if (alert != "Hold")
				carBehindReported = false;

			sendMessage("proximityAlert:" + alert);

			return true;
		}
		else if (carBehind) {
			if (!carBehindReported) {
				carBehindReported = true;

				sendMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
											(carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

				return true;
			}
		}
		else
			carBehindReported = false;
	}
	else {
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

	if (gf->flag == AC_BLUE_FLAG) {
		if ((lastFlagState & BLUE) == 0) {
			sendMessage("blueFlag");

			lastFlagState |= BLUE;

			return true;
		}
		else if (blueCount++ > 1000) {
			lastFlagState &= ~BLUE;

			blueCount = 0;
		}
	}
	else {
		lastFlagState &= ~BLUE;

		blueCount = 0;
	}

	if (gf->GlobalYellow1 && gf->GlobalYellow2 && gf->GlobalYellow3) {
		if ((lastFlagState & YELLOW_FULL) == 0) {
			sendMessage("yellowFlag:Full");

			lastFlagState |= YELLOW_FULL;

			return true;
		}
	}
	else if (gf->GlobalYellow1) {
		if ((lastFlagState & YELLOW_SECTOR_1) == 0) {
			sendMessage("yellowFlag:Sector;1");

			lastFlagState |= YELLOW_SECTOR_1;

			return true;
		}
	}
	else if (gf->GlobalYellow2) {
		if ((lastFlagState & YELLOW_SECTOR_2) == 0) {
			sendMessage("yellowFlag:Sector;2");

			lastFlagState |= YELLOW_SECTOR_2;

			return true;
		}
	}
	else if (gf->GlobalYellow3) {
		if ((lastFlagState & YELLOW_SECTOR_3) == 0) {
			sendMessage("yellowFlag:Sector;3");

			lastFlagState |= YELLOW_SECTOR_3;

			return true;
		}
	}
	else {
		if ((lastFlagState & YELLOW_SECTOR_1) != 0 || (lastFlagState & YELLOW_SECTOR_2) != 0 ||
			(lastFlagState & YELLOW_SECTOR_3) != 0) {
			sendMessage("yellowFlag:Clear");

			lastFlagState &= ~YELLOW_FULL;

			return true;
		}
	}

	return false;
}

void checkPitWindow() {
	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	int currentTime = sessionDuration - gf->sessionTimeLeft;
	
	if (sf->PitWindowStart < currentTime && sf->PitWindowEnd > currentTime && !pitWindowOpenReported) {
		pitWindowOpenReported = true;
		pitWindowClosedReported = false;

		sendMessage("pitWindow:Open");
	}
	else if (sf->PitWindowEnd < currentTime && !pitWindowClosedReported) {
		pitWindowClosedReported = true;
		pitWindowOpenReported = false;

		sendMessage("pitWindow:Closed");
	}
}

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();
	
	bool running = false;

	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

	int countdown = 4000;
	int safety = 200;

	while (true) {
		if (!running)
			running = ((gf->flag == AC_GREEN_FLAG) || (countdown-- <= 0) || (pf->speedKmh >= 200));

		if (running) {
			if (pf->speedKmh > 120)
				safety = 200;

			if (safety-- <= 0)
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
					checkPitWindow();
			}
			else {
				lastSituation = CLEAR;
				carBehind = false;
				carBehindLeft = false;
				carBehindRight = false;
				carBehindReported = false;

				lastFlagState = 0;
			}
		}

		Sleep(50);
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


