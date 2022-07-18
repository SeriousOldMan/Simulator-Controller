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
#include <cmath>
#include <fstream>

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

void sendSpotterMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, "Race Spotter.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, "Race Spotter.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

void sendAutomationMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, "Simulator Controller.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, "Simulator Controller.ahk");

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
const float verticalDistance = 2;

const int CLEAR = 1;
const int LEFT = 2;
const int RIGHT = 3;
const int THREE = 4;

const int situationRepeat = 50;

const char* noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

bool carBehind = false;
bool carBehindReported = false;

const int YELLOW = 1;
const int BLUE = 16;

int blueCount = 0;
int yellowCount = 0;

int lastFlagState = 0;
int waitYellowFlagState = 0;

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
		if (strcmp(alert, "Hold") == 0)
			carBehindReported = FALSE;

		char buffer2[128];
		int offset = 0;

		strcpy_s(buffer2, 128, "proximityAlert:");
		offset = strlen("proximityAlert:");
		strcpy_s(buffer2 + offset, 128 - offset, alert);

		sendSpotterMessage(buffer2);

		return true;
	}

	return false;
}

bool checkFlagState(const irsdk_header* header, const char* data) {
	char buffer[64];
	const char* sessionInfo = irsdk_getSessionInfoStr();
	char playerCarIdx[10] = "";
	char sessionID[10] = "";

	getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");
	
	itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

	int laps = 0;
	
	if (getYamlValue(buffer, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LapsComplete:", sessionID, playerCarIdx))
		laps = atoi(buffer);

	getDataValue(buffer, header, data, "SessionFlags");

	int flags = atoi(buffer);

	if ((waitYellowFlagState & YELLOW) != 0) {
		if (yellowCount++ > 50) {
			if ((flags & irsdk_yellow) == 0 && (flags & irsdk_yellowWaving) == 0)
				waitYellowFlagState &= ~YELLOW;

			yellowCount = 0;

			if ((waitYellowFlagState & YELLOW) != 0) {
				sendSpotterMessage("yellowFlag:Ahead");

				waitYellowFlagState &= ~YELLOW;

				return true;
			}
		}
	}
	else
		yellowCount = 0;

	if (laps > 0 && (flags & irsdk_blue) != 0) {
		if ((lastFlagState & BLUE) == 0) {
			sendSpotterMessage("blueFlag");

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

	if ((flags & irsdk_yellow) != 0 || (flags & irsdk_yellowWaving) != 0) {
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

void checkPitWindow(const irsdk_header* header, const char* data) {
	// No support in iRacing
}

float initialX = 0.0;
float initialY = 0.0;
float lastX = 0.0;
float lastY = 0.0;
int coordCount = 0;
int lastLap = 0;
float lastRunning = 0.0;
bool recording = false;

bool writeCoordinates(const irsdk_header* header, const char* data) {
	char buffer[60];

	const char* sessionInfo = irsdk_getSessionInfoStr();
	char playerCarIdx[10] = "";
	char sessionID[10] = "";

	getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");
	itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

	int laps = 0;

	if (getYamlValue(buffer, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LapsComplete:", sessionID, playerCarIdx))
		laps = atoi(buffer);

	if (lastLap == 0)
		lastLap = laps;
	else if (!recording) {
		if (laps != lastLap) {
			printf("0.0;0.0;0.0\n");

			recording = true;
		}
	}
	else {
		int carIdx = atoi(playerCarIdx);

		char* trackPositions;
		float running = 0.0;

		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct"))
			running = ((float*)trackPositions)[carIdx];

		if (running < lastRunning)
			return false;
		else
			lastRunning = running;

		getDataValue(buffer, header, data, "Yaw");

		float yaw = atof(buffer);

		getDataValue(buffer, header, data, "VelocityX");

		float velocityX = atof(buffer);

		float dx = velocityX * sin(yaw);
		float dy = velocityX * cos(yaw);

		lastX += dx;
		lastY += dy;

		printf("%f,%f,%f\n", running, lastX, lastY);

		if (fabs(lastX - initialX) < 10.0 && fabs(lastY - initialY) < 10.0)
			return false;
	}

	return true;
}

float rXCoordinates[1000];
float rYCoordinates[1000];

float xCoordinates[60];
float yCoordinates[60];
int numCoordinates = 0;
time_t lastUpdate = 0;

void loadTrackCoordinates(char* fileName) {
	std::ifstream infile(fileName);
	int index = 0;

	float x, y;

	while (infile >> x >> y) {
		rXCoordinates[index] = x;
		rYCoordinates[index] = y;

		if (++index > 999)
			break;
	}
}

void checkCoordinates(const irsdk_header* header, const char* data) {
	if (time(NULL) > (lastUpdate + 2)) {
		char buffer[60];

		const char* sessionInfo = irsdk_getSessionInfoStr();
		char playerCarIdx[10] = "";
		char sessionID[10] = "";

		getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");
		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		int carIdx = atoi(playerCarIdx);

		char* trackPositions;
		float running = 0.0;

		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct"))
			running = ((float*)trackPositions)[carIdx];

		getDataValue(buffer, header, data, "Yaw");

		float yaw = atof(buffer);

		getDataValue(buffer, header, data, "VelocityX");

		float velocityX = atof(buffer) * 3.6;

		float dx = velocityX * sin(yaw);
		float dy = velocityX * cos(yaw);

		if ((dx > 0) || (dy > 0)) {
			running = max(floor(running * 1000), 999);

			float coordinateX = rXCoordinates[(int)running];
			float coordinateY = rYCoordinates[(int)running];

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
	// bump priority up so we get time from the sim
	SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);

	// ask for 1ms timer so sleeps are more precise
	timeBeginPeriod(1);

	bool running = false;
	int countdown = 4000;
	bool mapTrack = false;
	bool positionTrigger = false;

	if (argc > 1) {
		mapTrack = (strcmp(argv[1], "-Map") == 0);

		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		if (positionTrigger) {
			loadTrackCoordinates(argv[2]);

			for (int i = 3; i < (argc - 2); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				numCoordinates += 1;
			}
		}
	}

	bool done = false;

	while (!done) {
		g_data = NULL;
		int tries = 3;

		while (tries-- > 0) {
			// wait for new data and copy it into the g_data buffer, if g_data is not null
			if (irsdk_waitForDataReady(TIMEOUT, g_data)) {
				const irsdk_header* pHeader = irsdk_getHeader();

				if (pHeader) {
					char result[64];

					if (!g_data || g_nData != pHeader->bufLen) {
						// realocate our g_data buffer to fit, and lookup some data offsets
						initData(pHeader, g_data, g_nData);

						continue;
					}
					else
						tries = 0;

					if (mapTrack) {
						if (!writeCoordinates(pHeader, g_data)) {
							done = true;

							break;
						}
					}
					else if (positionTrigger)
						checkCoordinates(pHeader, g_data);
					else {
						if (!running) {
							getDataValue(result, pHeader, g_data, "SessionFlags");

							int flags = atoi(result);

							running = (((flags & irsdk_startGo) != 0) || ((flags & irsdk_startSet) != 0) || (countdown-- <= 0));
						}

						if (running) {
							bool onTrack = true;

							getDataValue(result, pHeader, g_data, "IsInGarage");
							if (atoi(result))
								onTrack = false;

							getDataValue(result, pHeader, g_data, "IsReplayPlaying");
							if (atoi(result))
								onTrack = false;

							/*
							getDataValue(result, pHeader, g_data, "IsOnTrack");
							if (!atoi(result))
								onTrack = false;

							getDataValue(result, pHeader, g_data, "IsOnTrackCar");
							if (atoi(result))
								onTrack = true;
							*/

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

							if (onTrack && !inPit) {
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
					}
				}
				else
					Sleep(1000);
			}
		}

		if (mapTrack)
			Sleep(1);
		else if (positionTrigger)
			Sleep(10);
		else
			Sleep(50);
	}

	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

