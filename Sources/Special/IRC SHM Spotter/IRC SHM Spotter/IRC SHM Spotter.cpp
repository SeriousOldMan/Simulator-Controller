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
const float longitudinalDistance = 5;
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
int carBehindCount = 0;

const int YELLOW = 1;
const int BLUE = 16;

int blueCount = 0;
int yellowCount = 0;

int lastFlagState = 0;
int waitYellowFlagState = 0;

bool pitWindowOpenReported = false;
bool pitWindowClosedReported = true;

float rXCoordinates[1000];
float rYCoordinates[1000];
bool hasTrackCoordinates = false;

bool getCarCoordinates(const irsdk_header* header, const char* data, const char* sessionInfo,
	const int carIdx, float& coordinateX, float& coordinateY) {
	char* trackPositions;

	if (hasTrackCoordinates) {
		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct")) {
			int index = min((int)round(((float*)trackPositions)[carIdx] * 1000), 999);

			coordinateX = rXCoordinates[index];
			coordinateY = rYCoordinates[index];

			return true;
		}
	}

	return false;
}

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

bool checkPositions(const irsdk_header* header, const char* data, const int playerCarIndex, float trackLength) {
	char buffer[64];
	const char* sessionInfo = irsdk_getSessionInfoStr();
	char sessionID[10] = "";

	itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

	getDataValue(buffer, header, data, "CarLeftRight");

	int newSituation = atoi(buffer);

	if (newSituation < CLEAR)
		newSituation = CLEAR;
	else if (newSituation == 5)
		newSituation = LEFT;
	else if (newSituation == 6)
		newSituation = RIGHT;
	else if (newSituation >= THREE)
		newSituation = THREE;

	carBehind = false;

	if (newSituation == CLEAR) {
		char* trackPositions;
		char* pitLaneStates;

		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct") &&
				getRawDataValue(pitLaneStates, header, data, "CarIdxOnPitRoad")) {
			float playerRunning = ((float*)trackPositions)[playerCarIndex];

			for (int i = 1; ; i++) {
				char posIdx[10];
				char carIdx[10];

				itoa(i, posIdx, 10);

				if (getYamlValue(carIdx, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:Position:{%s}CarIdx:", sessionID, posIdx)) {
					int carIndex = atoi(carIdx);
					
					if ((carIndex != playerCarIndex) && !((bool*)pitLaneStates)[carIndex]) {
						float carRunning = ((float*)trackPositions)[carIndex];

						if (carRunning < playerRunning)
							if (abs(carRunning - playerRunning) < (nearByDistance / trackLength)) {
								carBehind = true;

								break;
							}
					}
				}
				else
					break;
			}
		}
	}
	else
		carBehindReported = false;

	if (carBehindCount++ > 200)
		carBehindCount = 0;

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
	else if (carBehind)
	{
		if (!carBehindReported) {
			if (carBehindCount < 20) {
				carBehindReported = true;

				sendSpotterMessage("proximityAlert:Behind");

				return true;
			}
		}
	}
	else
		carBehindReported = false;

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
		if (yellowCount > 50) {
			if ((flags & irsdk_yellow) == 0 && (flags & irsdk_yellowWaving) == 0)
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

	if (laps > 0 && (flags & irsdk_blue) != 0) {
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

bool checkPitWindow(const irsdk_header* header, const char* data) {
	// No support in iRacing

	return false;
}

bool greenFlagReported = false;

bool greenFlag(const irsdk_header* header, const char* data) {
	if (greenFlagReported)
		return false;
	else {
		char result[64];
		
		getDataValue(result, header, data, "SessionFlags");

		int flags = atoi(result);

		if (flags & irsdk_startGo) {
			greenFlagReported = true;
			
			sendSpotterMessage("greenFlag");
			
			Sleep(2000);
			
			return true;
		}
		else
			return false;
	}
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

std::vector<float> recentSteerAngles;
const int numRecentSteerAngles = 6;

std::vector<float> recentGLongs;
const int numRecentGLongs = 6;

std::vector<CornerDynamics> cornerDynamicsList;

std::string dataFile = "";
int understeerLightThreshold = 12;
int understeerMediumThreshold = 20;
int understeerHeavyThreshold = 35;
int oversteerLightThreshold = 2;
int oversteerMediumThreshold = -6;
int oversteerHeavyThreshold = -10;
int lowspeedThreshold = 100;
int steerLock = 900;
int steerRatio = 14;
int wheelbase = 270;
int trackWidth = 150;

int lastCompletedLaps = 0;
float lastSpeed = 0.0;

bool collectTelemetry(const irsdk_header* header, const char* data) {
	char result[64];
	bool onTrack = true;

	getDataValue(result, header, data, "IsInGarage");
	if (atoi(result))
		onTrack = false;

	getDataValue(result, header, data, "IsReplayPlaying");
	if (atoi(result))
		onTrack = false;

	bool inPit = false;

	char* rawValue;
	char playerCarIdx[10] = "";

	getYamlValue(playerCarIdx, irsdk_getSessionInfoStr(), "DriverInfo:DriverCarIdx:");

	int playerCarIndex = atoi(playerCarIdx);

	getRawDataValue(rawValue, header, data, "CarIdxOnPitRoad");

	if (((bool*)rawValue)[playerCarIndex])
		inPit = true;

	if (!onTrack || inPit)
		return true;

	getRawDataValue(rawValue, header, data, "SteeringWheelAngle");

	float steerAngle = -atof(rawValue) * 57.2958;

	recentSteerAngles.push_back(steerAngle);
	if ((int)recentSteerAngles.size() > numRecentSteerAngles) {
		recentSteerAngles.erase(recentSteerAngles.begin());
	}

	getRawDataValue(rawValue, header, data, "Speed");

	float speed = atof(rawValue) * 3.6;
	float acceleration = speed - lastSpeed;

	lastSpeed = speed;

	recentGLongs.push_back(acceleration);
	if ((int)recentGLongs.size() > numRecentGLongs) {
		recentGLongs.erase(recentGLongs.begin());
	}

	// Get the average recent GLong
	std::vector<float>::iterator glongIter;
	float sumGLong = 0.0;
	int numGLong = 0;
	for (glongIter = recentGLongs.begin(); glongIter != recentGLongs.end(); glongIter++) {
		sumGLong += *glongIter;
		numGLong++;
	}

	int phase = 0;
	if (numGLong > 0) {
		float recentGLong = sumGLong / numGLong;
		if (recentGLong < -0.2) {
			// Braking
			phase = -1;
		}
		else if (recentGLong > 0.1) {
			// Accelerating
			phase = 1;
		}
	}

	if (fabs(steerAngle) > 0.1 && lastSpeed > 60) {
		getRawDataValue(rawValue, header, data, "Lap");

		int completedLaps = atoi(rawValue);

		getRawDataValue(rawValue, header, data, "YawRate");

		float angularVelocity = atof(rawValue);

		CornerDynamics cd = CornerDynamics(atof(rawValue) * 3.6, 0, completedLaps, phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			float steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;

			/*
			if (fabs(steeredAngleDegs) > 0.33f)
				cd.usos = 10 * -steeredAngleDegs / angularVelocity;
			*/

			float steerAngleRadians = -steeredAngleDegs / 57.2958;
			float wheelBaseMeter = (float)wheelbase / 10;
			float radius = wheelBaseMeter / steerAngleRadians;

			float perimeter = radius * PI * 2;
			float perimeterSpeed = lastSpeed / 3.6;
			float idealAngularVelocity = perimeterSpeed / perimeter * 2 * PI;

			float slip = fabs(idealAngularVelocity) - fabs(angularVelocity);

			if (steerAngle > 0) {
				if (angularVelocity < idealAngularVelocity)
					slip *= -1;
			}
			else {
				if (angularVelocity > idealAngularVelocity)
					slip *= -1;
			}

			cd.usos = slip * 57.2989 * 10;

			if (false) {
				std::ofstream output;

				output.open(dataFile + ".trace", std::ios::out | std::ios::app);

				output << steerAngle << "  " << steeredAngleDegs << "  " << steerAngleRadians << "  " <<
						  lastSpeed << "  " << idealAngularVelocity << "  " << angularVelocity << "  " << slip << "  " <<
						  cd.usos << std::endl;

				output.close();
			}
		}

		cornerDynamicsList.push_back(cd);

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

void writeTelemetry(const irsdk_header* header, const char* data) {
	std::ofstream output;

	try {
		output.open(dataFile + ".tmp", std::ios::out, std::ios::trunc);

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

		std::vector<CornerDynamics>::iterator cornerIter;
		for (cornerIter = cornerDynamicsList.begin(); cornerIter != cornerDynamicsList.end(); cornerIter++) {
			CornerDynamics corner = *cornerIter;
			int phase = corner.phase + 1;

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

		output << "[Understeer.Slow.Light]" << std::endl;

		if (slowTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * slowLightUSNum[0] / slowTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * slowLightUSNum[1] / slowTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * slowLightUSNum[2] / slowTotalNum) << std::endl;
		}

		output << "[Understeer.Slow.Medium]" << std::endl;

		if (slowTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * slowMediumUSNum[0] / slowTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * slowMediumUSNum[1] / slowTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * slowMediumUSNum[2] / slowTotalNum) << std::endl;
		}

		output << "[Understeer.Slow.Heavy]" << std::endl;

		if (slowTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum) << std::endl;
		}

		output << "[Understeer.Fast.Light]" << std::endl;

		if (fastTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * fastLightUSNum[0] / fastTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * fastLightUSNum[1] / fastTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * fastLightUSNum[2] / fastTotalNum) << std::endl;
		}

		output << "[Understeer.Fast.Medium]" << std::endl;

		if (fastTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * fastMediumUSNum[0] / fastTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * fastMediumUSNum[1] / fastTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * fastMediumUSNum[2] / fastTotalNum) << std::endl;
		}

		output << "[Understeer.Fast.Heavy]" << std::endl;

		if (fastTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum) << std::endl;
		}

		output << "[Oversteer.Slow.Light]" << std::endl;

		if (slowTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * slowLightOSNum[0] / slowTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * slowLightOSNum[1] / slowTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * slowLightOSNum[2] / slowTotalNum) << std::endl;
		}

		output << "[Oversteer.Slow.Medium]" << std::endl;

		if (slowTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * slowMediumOSNum[0] / slowTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * slowMediumOSNum[1] / slowTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * slowMediumOSNum[2] / slowTotalNum) << std::endl;
		}

		output << "[Oversteer.Slow.Heavy]" << std::endl;

		if (slowTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum) << std::endl;
		}

		output << "[Oversteer.Fast.Light]" << std::endl;

		if (fastTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * fastLightOSNum[0] / fastTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * fastLightOSNum[1] / fastTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * fastLightOSNum[2] / fastTotalNum) << std::endl;
		}

		output << "[Oversteer.Fast.Medium]" << std::endl;

		if (fastTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * fastMediumOSNum[0] / fastTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * fastMediumOSNum[1] / fastTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * fastMediumOSNum[2] / fastTotalNum) << std::endl;
		}

		output << "[Oversteer.Fast.Heavy]" << std::endl;

		if (fastTotalNum > 0) {
			output << "Entry=" << (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum) << std::endl;
			output << "Apex=" << (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum) << std::endl;
			output << "Exit=" << (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum) << std::endl;
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
float lastX = 0.0;
float lastY = 0.0;
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
			lastLap = laps;
			
			printf("0.0,0.0,0.0\n");

			recording = true;
		}
	}
	else if (laps != lastLap) 
		return false;
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

float xCoordinates[60];
float yCoordinates[60];
float trackDistances[60];
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

	hasTrackCoordinates = true;
}

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

		getDataValue(buffer, header, data, "Yaw");

		float yaw = atof(buffer);

		getDataValue(buffer, header, data, "VelocityX");

		float velocityX = atof(buffer) * 3.6;

		float dx = velocityX * sin(yaw);
		float dy = velocityX * cos(yaw);

		if ((dx > 0) || (dy > 0)) {
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

				sendAutomationMessage(buffer);

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

	bool running = false;
	int countdown = 1000;
	bool mapTrack = false;
	bool positionTrigger = false;
	bool analyzeTelemetry = false;

	if (argc > 1) {
		analyzeTelemetry = (strcmp(argv[1], "-Analyze") == 0);
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		if (analyzeTelemetry) {
			dataFile = argv[2];

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
		}
		else if (positionTrigger) {
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
	
				numCoordinates += 1;
			}

			if (numCoordinates == 0)
				positionTrigger = false;
		}
	}

	float trackLength = 0.0;
	bool done = false;
	long counter = 0;

	while (!done) {
		g_data = NULL;
		int tries = 3;

		bool wait = true;

		while (tries-- > 0) {
			counter++;

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

					if (trackLength == 0.0) {
						char buffer[64];

						getYamlValue(buffer, irsdk_getSessionInfoStr(), "WeekendInfo:TrackLength:");

						trackLength = atof(buffer) * 1000;
					}

					if (analyzeTelemetry) {
						if (collectTelemetry(pHeader, g_data)) {
							if (remainder(counter, 20) == 0)
								writeTelemetry(pHeader, g_data);
						}
						else
							break;
					}
					else if (mapTrack) {
						if (!writeCoordinates(pHeader, g_data)) {
							done = true;

							break;
						}
					}
					else if (positionTrigger)
						checkCoordinates(pHeader, g_data, trackLength);
					else {
						if (!running) {
							countdown -= 1;

							getDataValue(result, pHeader, g_data, "SessionFlags");

							int flags = atoi(result);

							if (!greenFlagReported && (countdown <= 0))
								greenFlagReported = true;

							running = (((flags & irsdk_startGo) != 0) || ((flags & irsdk_startSet) != 0) || (countdown <= 0));
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

							int playerCarIndex = atoi(playerCarIdx);

							getRawDataValue(rawValue, pHeader, g_data, "CarIdxOnPitRoad");

							if (((bool*)rawValue)[playerCarIndex])
								inPit = true;
							/*
							else {
								getRawDataValue(rawValue, pHeader, g_data, "CarIdxTrackSurface");

								irsdk_TrkLoc trkLoc = ((irsdk_TrkLoc*)rawValue)[atoi(playerCarIdx)];

								inPit = (trkLoc & irsdk_InPitStall);
							}
							*/

							if (onTrack && !inPit) {
								if (!greenFlag(pHeader, g_data) && !checkFlagState(pHeader, g_data) && !checkPositions(pHeader, g_data, playerCarIndex, trackLength))
									wait = !checkPitWindow(pHeader, g_data);
								else
									wait = false;

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

		if (analyzeTelemetry)
			Sleep(100);
		else if (mapTrack)
			Sleep(1);
		else if (positionTrigger)
			Sleep(10);
		else if (wait)
			Sleep(50);
	}

	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

