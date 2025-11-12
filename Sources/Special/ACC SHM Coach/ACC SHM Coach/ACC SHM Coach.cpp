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
		cds.dwData = (256 * 'D' + 'C');
		cds.cbData = sizeof(char) * (msg.length() + 1);
		cds.lpData = (char *)msg.c_str();

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendTriggerMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Driving Coach:" + message);
}

bool fileExists(std::string name) {
	FILE* file;

	if (!fopen_s(&file, name.c_str(), "r")) {
		fclose(file);

		return true;
	}
	else
		return false;
}

std::vector<std::string> splitString(const std::string& s, const std::string& delimiter, int count = 0) {
	std::vector<std::string> parts;
	size_t pos = 0;
	size_t offset = 0;
	int numParts = 0;

	while ((pos = s.find(delimiter, offset)) != std::string::npos) {
		if (count != 0 && ++numParts >= count)
			break;

		parts.push_back(s.substr(offset, pos));

		offset += pos + delimiter.length();
	}

	parts.push_back(s.substr(offset));

	return parts;
}

float xCoordinates[256];
float yCoordinates[256];
int numCoordinates = 0;
time_t lastUpdate = 0;
const char* triggerType = "Trigger";

string audioDevice = "";
string hintFile = "";

string hintSounds[256];
time_t lastHintsUpdate = 0;

void checkCoordinates() {
	if ((triggerType == "BrakeHints") ? true : time(NULL) > (lastUpdate + 2)) {
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
					if (strcmp(triggerType, "Trigger") == 0) {
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

						sendTriggerMessage(buffer);
					}
					else if (strcmp(triggerType, "BrakeHints") == 0)
						sendTriggerMessage("acousticFeedback:" + hintSounds[i]);

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
	if ((hintFile != "") && fileExists(hintFile))
	{
		struct stat result;
		time_t mod_time = 0;

		if (stat(hintFile.c_str(), &result) == 0)
			mod_time = result.st_mtime;

		if (numCoordinates == 0 || (mod_time > lastHintsUpdate))
		{
			numCoordinates = 0;
			lastHintsUpdate = mod_time;

			std::ifstream infile(hintFile);
			string line;

			while (std::getline(infile, line)) {
				auto parts = splitString(line, " ", 3);

				xCoordinates[numCoordinates] = (float)atof(parts[0].c_str());
				yCoordinates[numCoordinates] = (float)atof(parts[1].c_str());
				hintSounds[numCoordinates] = parts[3];

				if (++numCoordinates > 255)
					break;
			}
		}
	}
}

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();
	
	bool positionTrigger = false;
	bool brakeHints = false;

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

	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

	while (true) {
		if (positionTrigger) {
			checkCoordinates();

			Sleep(10);
		}
		else if (positionTrigger) {
			loadBrakeHints();

			checkCoordinates();

			Sleep(10);
		}
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}