/*
Based on sample code by iRacing Motorsport Simulations, LLC.

The following apply:

Copyright (c) 2013, iRacing.com Motorsport Simulations, LLC.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of iRacing.com Motorsport Simulations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//------
#define MIN_WIN_VER 0x0501

#ifndef WINVER
#	define WINVER			MIN_WIN_VER
#endif

#ifndef _WIN32_WINNT
#	define _WIN32_WINNT		MIN_WIN_VER 
#endif

#pragma warning(disable:4996) //_CRT_SECURE_NO_WARNINGS

#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <signal.h>
#include <time.h>

#include "irsdk_defines.h"
#include "yaml_parser.h"

// for timeBeginPeriod
#pragma comment(lib, "Winmm")

// 32 ms timeout
#define TIMEOUT 32

char *g_data = NULL;
int g_nData = 0;

void initData(const irsdk_header* header, char*& data, int& nData)
{
	if (data) delete[] data;
	nData = header->bufLen;
	data = new char[nData];
}

inline double normalize(double value) {
	return (value < 0) ? 0.0 : value;
}

inline double GetPsi(double kPa) {
	return kPa / 6.895;
}

inline double GetKpa(double psi) {
	return psi * 6.895;
}

void substring(const char s[], char sub[], int p, int l) {
	int c = 0;

	while (c < l) {
		sub[c] = s[p + c];

		c++;
	}
	sub[c] = '\0';
}

inline void extractString(char* string, const char* value, int valueLength) {
	substring(value, string, 0, valueLength);
}

bool getYamlValue(char* result, const char* sessionInfo, char* path) {
	int length = -1;
	const char* string;

	if (parseYaml(sessionInfo, path, &string, &length)) {
		extractString(result, string, length);

		return true;
	}
	else
		return false;
}

bool getYamlValue(char* result, const char* sessionInfo, char* path, char* value) {
	char buffer[256];
	int pos = 0;

	sprintf(buffer, path, value);

	return getYamlValue(result, sessionInfo, buffer);
}

bool getYamlValue(char* result, const char* sessionInfo, char* path, char* value1, char* value2) {
	char buffer[256];
	int pos = 0;

	sprintf(buffer, path, value1, value2);

	return getYamlValue(result, sessionInfo, buffer);
}

int getCurrentSessionID(const char* sessionInfo) {
	char id[10];
	char result[100];
	int sID = 0;

	while (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsOfficial:", itoa(sID, id, 10))) {
		if (strcmp(result, "0") == 0)
			return sID;

		sID += 1;
	}

	return -1;
}

bool getRawDataValue(char* &value, const irsdk_header* header, const char* data, const char* variable) {
	if (header && data) {
		for (int i = 0; i < header->numVars; i++) {
			const irsdk_varHeader* rec = irsdk_getVarHeaderEntry(i);

			if (strcmp(rec->name, variable) == 0) {
				value = (char*)(data + rec->offset);

				return true;
			}
		}
	}

	return false;
}

bool getDataValue(char* value, const irsdk_header* header, const char* data, const char* variable) {
	if (header && data) {
		for (int i = 0; i < header->numVars; i++) {
			const irsdk_varHeader* rec = irsdk_getVarHeaderEntry(i);

			if (strcmp(rec->name, variable) == 0) {
				switch (rec->type)
				{
				case irsdk_char:
					sprintf(value, "%s", (char*)(data + rec->offset)); break;
				case irsdk_bool:
					sprintf(value, "%d", ((bool*)(data + rec->offset))[0]); break;
				case irsdk_bitField:
				case irsdk_int:
					sprintf(value, "%d", ((int*)(data + rec->offset))[0]); break;
				case irsdk_float:
					sprintf(value, "%0.2f", ((float*)(data + rec->offset))[0]); break;
				case irsdk_double:
					sprintf(value, "%0.2f", ((double*)(data + rec->offset))[0]); break;
				default:
					return false;
				}

				return true;
			}
		}
	}

	return false;
}

float getDataFloat(const irsdk_header* header, const char* data, const char* variable) {
	char result[32];

	if (getDataValue(result, header, data, variable))
		return atof(result);
	else
		return 0;
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

void sendMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, "Race Spotter.exe");

	if (winHandle == 0)
		FindWindowEx(0, 0, 0, "Race Spotter.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

#define PI 3.14159265

const float nearByDistance = 8.0;
const float longitudinalDistance = 4;
const float lateralDistance = 6;
const float verticalDistance = 4;

const int CLEAR = 1;
const int LEFT = 2;
const int RIGHT = 3;
const int THREE = 4;

const int situationRepeat = 5;

const char* noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

bool carBehind = false;
bool carBehindReported = false;

const int YELLOW = 1;
const int BLUE = 16;

int blueCount = 0;

int lastFlagState = 0;

bool pitWindowOpenReported = false;
bool pitWindowClosedReported = true;

const char* computeAlert(int newSituation) {
	const char* alert = noAlert;

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

bool checkPositions(const irsdk_header* header, const char* data) {
	char buffer[64];

	getDataValue(buffer, header, data, "CarLeftRight");

	int newSituation = atoi(buffer);

	if (newSituation < CLEAR)
		newSituation = CLEAR;
	else if (newSituation == 5)
		newSituation = LEFT;
	else if (newSituation == 6)
		newSituation = RIGHT;
	else if (newSituation > CLEAR)
		newSituation = newSituation;

	const char* alert = computeAlert(newSituation);

	if (alert != noAlert) {
		carBehindReported = FALSE;

		char buffer2[128];
		int offset = 0;

		strcpy_s(buffer2, 128, "proximityAlert:");
		offset = strlen("proximityAlert:");
		strcpy_s(buffer2 + offset, 128 - offset, alert);

		sendMessage(buffer2);

		return true;
	}

	return false;
}

bool checkFlagState(const irsdk_header* header, const char* data) {
	char buffer[64];

	getDataValue(buffer, header, data, "SessionFlags");

	int flags = atoi(buffer);

	if ((flags & irsdk_blue) != 0) {
		if ((lastFlagState & BLUE) == 0) {
			sendMessage("blueFlag");

			lastFlagState |= BLUE;

			return true;
		}
		else if (blueCount++ > 100) {
			lastFlagState &= ~BLUE;

			blueCount = 0;
		}
	}
	else {
		lastFlagState &= ~BLUE;

		blueCount = 0;
	}

	if ((flags & irsdk_yellow) != 0 || (flags & irsdk_yellowWaving) != 0) {
		if ((lastFlagState & YELLOW) == 0) {
			sendMessage("yellowFlag:Ahead");

			lastFlagState |= YELLOW;

			return true;
		}
	}
	else if ((lastFlagState & YELLOW) != 0) {
		sendMessage("yellowFlag:Clear");

		lastFlagState &= ~YELLOW;

		return true;
	}

	return false;
}

void checkPitWindow(const irsdk_header* header, const char* data) {
	// No support in iRacing
}

int main(int argc, char* argv[])
{
	// bump priority up so we get time from the sim
	SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);

	// ask for 1ms timer so sleeps are more precise
	timeBeginPeriod(1);

	while (true) {
		g_data = NULL;
		int tries = 3;

		while (tries-- > 0) {
			// wait for new data and copy it into the g_data buffer, if g_data is not null
			if (irsdk_waitForDataReady(TIMEOUT, g_data)) {
				const irsdk_header* pHeader = irsdk_getHeader();

				if (pHeader) {
					if (!g_data || g_nData != pHeader->bufLen) {
						// realocate our g_data buffer to fit, and lookup some data offsets
						initData(pHeader, g_data, g_nData);

						continue;
					}
					else
						tries = 0;

					char result[64];
					bool running = true;
					/*
					getDataValue(result, pHeader, g_data, "IsInGarage");
					if (atoi(result))
						running = true;
					
					getDataValue(result, pHeader, g_data, "IsOnTrack");
					if (!atoi(result))
						running = false;

					getDataValue(result, pHeader, g_data, "IsOnTrackCar");
					if (atoi(result))
						running = true;
					*/

					getDataValue(result, pHeader, g_data, "IsReplayPlaying");
					if (atoi(result))
						running = false;

					bool inPit = false;

					char* rawValue;
					char playerCarIdx[10] = "";
					
					getYamlValue(playerCarIdx, irsdk_getSessionInfoStr(), "DriverInfo:DriverCarIdx:");
					getRawDataValue(rawValue, pHeader, g_data, "CarIdxOnPitRoad");

					if (((bool*)rawValue)[atoi(playerCarIdx)])
						inPit = true;

					/*
					else {
						getRawDataValue(rawValue, pHeader, g_data, "CarIdxTrackSurface");

						irsdk_TrkLoc trkLoc = ((irsdk_TrkLoc*)rawValue)[atoi(playerCarIdx)];

						inPit = (trkLoc & irsdk_InPitStall);
					}
					*/
					
					if (running && !inPit) {
						if (!checkFlagState(pHeader, g_data) && !checkPositions(pHeader, g_data))
							checkPitWindow(pHeader, g_data);

						continue;
					}
					else {
						lastSituation = CLEAR;
						carBehind = false;
						carBehindReported = false;

						lastFlagState = 0;

						Sleep(1000);
					}
				}
				else
					Sleep(1000);
			}
		}

		Sleep(200);
	}

	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

