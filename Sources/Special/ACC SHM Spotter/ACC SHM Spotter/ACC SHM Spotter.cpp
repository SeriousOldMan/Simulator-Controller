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

inline const string getSession(AC_SESSION_TYPE session) {
	switch (session) {
	case AC_PRACTICE:
		return "Practice";
		break;
	case AC_QUALIFY:
		return "Qualification";
		break;
	case AC_RACE:
		return "Race";
		break;
	default:
		return "Other";
		break;
	}
}

#define PI 3.14159265

const float nearByDistance = 8.0;
const float longitudinalDistance = 3.5;
const float lateralDistance = 5;
const float verticalDistance = 4;

const int CLEAR = 0;
const int LEFT = 1;
const int RIGHT = 2;
const int BOTH = 3;

int lastSituation = CLEAR;
int situationCount = 0;
const int situationRepeat = 5;

bool carBehind = false;
bool carBehindReported = false;

const string noAlert = "NoAlert";

string computeAlert(int newSituation) {
	string alert = noAlert;

	if (lastSituation && (lastSituation == newSituation)) {
		if (situationCount++ > situationRepeat) {
			situationCount = 0;

			alert = "Hold";
		}
	}
	else {
		situationCount = 0;

		if (!lastSituation) {
			switch (newSituation) {
			case LEFT:
				alert = "Left";
				break;
			case RIGHT:
				alert = "Right";
				break;
			case BOTH:
				alert = "Three";
				break;
			}
		}
		else {
			switch (newSituation) {
			case CLEAR:
				if (lastSituation == BOTH)
					alert = "ClearAll";
				else
					alert = (lastSituation == RIGHT) ? "ClearRight" : "ClearLeft";
				break;
			case LEFT:
				if (lastSituation == BOTH)
					alert = "ClearRight";
				else
					alert = "Three";
				break;
			case RIGHT:
				if (lastSituation == BOTH)
					alert = "ClearLeft";
				else
					alert = "Three";
				break;
			}
		}
	}

	lastSituation = newSituation;

	return alert;
}

float vectorAngle(float x, float y) {
	float scalar = (x * 0) + (y * 1);
	float length = sqrt((x * x) + (y * y));
	
	float angle = (length > 0) ? acos(scalar / length) * 180 / PI : 0;

	if (x < 0)
		angle = 360 - angle;

	return angle;
}

bool nearBy(float car1X, float car1Y, float car1Z,
			float car2X, float car2Y, float car2Z) {
	return (abs(car1X - car2X) < nearByDistance) &&
		   (abs(car1Y - car2Y) < nearByDistance) &&
		   (abs(car1Z - car2Z) < nearByDistance);
}

void rotateBy(float* x, float* y, float angle) {
	float sinus = sin(angle * PI / 180);
	float cosinus = cos(angle * PI / 180);

	float newX = (*x * cosinus) - (*y * sinus);
	float newY = (*x * sinus) + (*y * cosinus);

	*x = newX;
	*y = newY;
}

int checkCarPosition(float carX, float carY, float carZ, float angle,
					 float otherX, float otherY, float otherZ) {
	if (nearBy(carX, carY, carZ, otherX, otherY, otherZ)) {
		otherX -= carX;
		otherY -= carY;
		
		rotateBy(&otherX, &otherY, angle);

		if ((abs(otherY) < longitudinalDistance) && (abs(otherX) < lateralDistance) && (abs(otherZ - carZ) < verticalDistance))
			return (otherX > 0) ? RIGHT : LEFT;
		else {
			if (otherY < 0)
				carBehind = true;

			return CLEAR;
		}
	}
	else
		return CLEAR;
}

void checkPositions() {
	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	float velocityX = pf->velocity[0];
	float velocityY = pf->velocity[1];

	float angle = vectorAngle(velocityX, velocityY);

	int carID = gf->playerCarID;
	float coordinateX = gf->carCoordinates[carID][0];
	float coordinateY = gf->carCoordinates[carID][1];
	float coordinateZ = gf->carCoordinates[carID][2];

	int newSituation = CLEAR;

	carBehind = false;

	for (int id = 0; id < gf->activeCars; id++) {
		wcout << id << "; " << gf->carCoordinates[id][0] << "; " << gf->carCoordinates[id][1] << "; " << gf->carCoordinates[id][2] << endl;

		if (id != carID)
			newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle,
											 gf->carCoordinates[id][0],
											 gf->carCoordinates[id][1],
											 gf->carCoordinates[id][2]);

		if ((newSituation == BOTH) && carBehind)
			break;
	}

	exit(0);

	string alert = computeAlert(newSituation);

	if (alert != noAlert) {
		carBehindReported = false;

		sendMessage("alert:" + alert);
	}
	else if (carBehind) {
		if (!carBehindReported) {
			carBehindReported = true;

			sendMessage("alert:Behind");
		}
	}
	else
		carBehindReported = false;
}

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();

	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	while (true) {
		if ((gf->status == AC_LIVE) && !gf->isInPit && !gf->isInPitLane)
			checkPositions();
		else
			lastSituation = CLEAR;

		Sleep(200);
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


