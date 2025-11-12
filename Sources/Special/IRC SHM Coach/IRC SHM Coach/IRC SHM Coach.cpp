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
#include <vector>


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
					sprintf(value, "%0.6f", ((float*)(data + rec->offset))[0]); break;
				case irsdk_double:
					sprintf(value, "%0.8f", ((double*)(data + rec->offset))[0]); break;
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
		cds.dwData = (256 * 'D' + 'C');
		cds.cbData = sizeof(char) * (strlen(msg) + 1);
		cds.lpData = msg;

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendTriggerMessage(const char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, "Driving Coach.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, "Driving Coach.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Driving Coach:");
		strcpy_s(buffer + strlen("Driving Coach:"), 128 - strlen("Driving Coach:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

float rXCoordinates[1000];
float rYCoordinates[1000];
bool hasTrackCoordinates = false;

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

	hasTrackCoordinates = true;
}

float xCoordinates[256];
float yCoordinates[256];
float trackDistances[60];
int numCoordinates = 0;
time_t lastUpdate = 0;
char* triggerType = "Trigger";

void checkCoordinates(const irsdk_header* header, const char* data, float trackLength) {
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

		getDataValue(buffer, header, data, "Speed");

		if (atof(buffer) > 0) {
			float distance;
			int index = 0;

			for (int i = 0; i < numCoordinates; i++) {
				float cDistance = abs(trackDistances[i] - running);

				if (i == 0)
					distance = cDistance;
				else if (cDistance < distance) {
					distance = cDistance;
					index = i;
				}
			}

			if (distance < (30 / trackLength)) {
				char buffer[60] = "";
				char numBuffer[60] = "";

				strcat_s(buffer, "positionTrigger:");
				_itoa_s(index + 1, numBuffer, 10);
				strcat_s(buffer, numBuffer);
				strcat_s(buffer, ";");
				sprintf_s(numBuffer, "%f", xCoordinates[index]);
				strcat_s(buffer, numBuffer);
				strcat_s(buffer, ";");
				sprintf_s(numBuffer, "%f", yCoordinates[index]);
				strcat_s(buffer, numBuffer);

				if (strcmp(triggerType, "Trigger") == 0)
					sendTriggerMessage(buffer);

				lastUpdate = time(NULL);
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

	bool positionTrigger = false;
	bool brakeHints = false;

	if (argc > 1) {
		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		if (positionTrigger) {
			loadTrackCoordinates(argv[2]);

			for (int i = 3; i < (argc - 2); i = i + 2) {
				float x = (float)atof(argv[i]);
				float y = (float)atof(argv[i + 1]);

				xCoordinates[numCoordinates] = x;
				yCoordinates[numCoordinates] = y;

				int candidate;
				float cDistance;

				for (int c = 0; c < 1000; c++) {
					float cX = rXCoordinates[c];
					float cY = rYCoordinates[c];

					float distance = sqrt((cX - x) * (cX - x) + (cY - y) * (cY - y));

					if (c == 0 || distance < cDistance) {
						cDistance = distance;
						candidate = c;
					}
				}

				trackDistances[numCoordinates] = ((float)candidate) / 1000.0;
	
				if (++numCoordinates > 255)
					break;
			}

			if (numCoordinates == 0)
				positionTrigger = false;
		}
		
	}

	float trackLength = 0.0;
	int playerCarIndex = -1;

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

					if (trackLength == 0.0) {
						char buffer[64];

						getYamlValue(buffer, irsdk_getSessionInfoStr(), "WeekendInfo:TrackLength:");

						trackLength = atof(buffer) * 1000;
					}

					if (playerCarIndex == -1) {
						char playerCarIdx[10] = "";

						getYamlValue(playerCarIdx, irsdk_getSessionInfoStr(), "DriverInfo:DriverCarIdx:");

						playerCarIndex = atoi(playerCarIdx);
					}

					if (positionTrigger) {
						checkCoordinates(pHeader, g_data, trackLength);

						Sleep(10);
					}
				}
				else
					Sleep(1000);
			}

			if (g_data)
				delete g_data;
		}
	}

	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

