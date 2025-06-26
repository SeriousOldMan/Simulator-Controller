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
		cds.dwData = (256 * 'R' + 'S');
		cds.cbData = sizeof(char) * (strlen(msg) + 1);
		cds.lpData = msg;

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendSpotterMessage(const char* message) {
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

void sendAutomationMessage(const char* message) {
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

void sendAnalyzerMessage(const char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, "Setup Workbench.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, "Setup Workbench.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Analyzer:");
		strcpy_s(buffer + strlen("Analyzer:"), 128 - strlen("Analyzer:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

#define PI 3.14159265

long cycle = 0;
long nextSpeedUpdate = 0;
bool enabled = true;

const float nearByDistance = 8.0;
const float longitudinalDistance = 5;
const float lateralDistance = 8;
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
long nextCarBehind = 0;

const int YELLOW = 1;
const int BLUE = 16;

int blueCount = 0;
int yellowCount = 0;
long nextBlueFlag = 0;

int lastFlagState = 0;
int waitYellowFlagState = 0;

int aheadAccidentDistance = 800;
int behindAccidentDistance = 500;
int slowCarDistance = 500;

long nextSlowCarAhead = 0;
long nextAccidentAhead = 0;
long nextAccidentBehind = 0;

bool pitWindowOpenReported = false;
bool pitWindowClosedReported = true;

float rXCoordinates[1000];
float rYCoordinates[1000];
bool hasTrackCoordinates = false;

bool getCarCoordinates(const irsdk_header* header, const char* data, const int carIdx, float& coordinateX, float& coordinateY) {
	char* trackPositions;

	if (hasTrackCoordinates) {
		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct")) {
			int index = max(0, min((int)round(((float*)trackPositions)[carIdx] * 999), 999));

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

	if (getDataValue(buffer, header, data, "CarLeftRight")) {
		int newSituation = atoi(buffer);

		if (newSituation <= CLEAR)
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
				char result[60];
				int numStarters = 0;

				if (getYamlValue(result, sessionInfo, "WeekendInfo:WeekendOptions:NumStarters:"))
					numStarters = atoi(result);

				for (int i = 1; i <= numStarters; i++) {
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
				if (carBehindCount < 20 && cycle > nextCarBehind) {
					nextCarBehind = cycle + 200;
					carBehindReported = true;

					sendSpotterMessage("proximityAlert:Behind");

					return true;
				}
			}
		}
		else
			carBehindReported = false;
	}

	return false;
}

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

void updateIdealLine(const irsdk_header* header, const char* data, int carIndex, double running, double speed) {
	float coordinateX;
	float coordinateY;

	if (getCarCoordinates(header, data, carIndex, coordinateX, coordinateY))
		idealLine[(int)std::round(running * (idealLine.size() - 1))].update(speed, coordinateX, coordinateY);
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

long lastTickCount = 0;
double lastRunnings[512];

std::string traceFileName = "";

long bestLapTime = LONG_MAX;

int completedLaps = 0;
int numAccidents = 0;

std::string semFileName = "";

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

bool checkAccident(const irsdk_header* header, const char* data, const int playerCarIndex, float trackLength)
{
	bool accident = false;

	accidentsAhead.clear();
	accidentsBehind.clear();
	slowCarsAhead.clear();

	if (idealLine.size() == 0) {
		idealLine.reserve(trackLength / 4);

		for (int i = 0; i < (trackLength / 4); i++)
			idealLine.push_back(IdealLine());
	}

	const char* sessionInfo = irsdk_getSessionInfoStr();
	char result[64];
	char posIdx[10];
	char carIdx[10];
	char sessionID[10];
	bool first = lastTickCount == 0;
	char* trackPositions;

	itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

	long milliSeconds = GetTickCount() - lastTickCount;

	if (milliSeconds < 200)
		return false;

	if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct")) {
		float driverRunning = ((float*)trackPositions)[playerCarIndex];
		int numStarters = 0;
		char* pitLaneStates;

		if (getYamlValue(result, sessionInfo, "WeekendInfo:WeekendOptions:NumStarters:"))
			numStarters = atoi(result);

		if (!getRawDataValue(pitLaneStates, header, data, "CarIdxOnPitRoad"))
			pitLaneStates = 0;

		if (pitLaneStates && ((bool*)pitLaneStates)[playerCarIndex]) {
			bestLapTime = LONG_MAX;

			return false;
		}

		long lastTime = 0;
		char playerCarIdx[10] = "";

		sprintf(playerCarIdx, "%d", playerCarIndex);
		
		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LastTime:", sessionID, playerCarIdx))
			lastTime = (long)(normalize(atof(result)) * 1000);

		if ((lastTime > 0) && ((lastTime * 1.002) < bestLapTime))
		{
			bestLapTime = lastTime;

			int length = idealLine.size();

			for (int i = 0; i < length; i++)
				idealLine[i].clear();
		}

		if ((strlen(semFileName.c_str()) > 0) && fileExists(semFileName))
		{
			std::remove(semFileName.c_str());

			int length = idealLine.size();

			for (int i = 0; i < length; i++)
				idealLine[i].clear();
		}
	
		char* rawValue;
		
		getRawDataValue(rawValue, header, data, "Lap");

		int carLaps = *((int*)rawValue);
	
		if (carLaps > completedLaps) {
			if (numAccidents >= (trackLength / 1000)) {
				int length = idealLine.size();

				for (int i = 0; i < length; i++)
					idealLine[i].clear();
			}
			
			completedLaps = carLaps;
			numAccidents = 0;
		}

		lastTickCount += milliSeconds;

		try
		{
			for (int i = 1; i <= numStarters; i++) {
				itoa(i, posIdx, 10);

				if (getYamlValue(carIdx, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:Position:{%s}CarIdx:", sessionID, posIdx)) {
					int carIndex = atoi(carIdx);
					float lastRunning = lastRunnings[carIndex];
					float running = min(1, max(0, ((float*)trackPositions)[carIndex]));
					
					lastRunnings[carIndex] = running;
					
					if (!first && (lastRunning != 0)) {
						float speed;

						if (pitLaneStates && ((bool*)pitLaneStates)[carIndex])
							continue;

						if (running >= lastRunning)
							speed = (((running - lastRunning) * trackLength) / ((float)milliSeconds / 1000.0f)) * 3.6f;
						else
							continue;

						float avgSpeed = getAverageSpeed(running);

						if (carIndex != playerCarIndex) {
							if (speed >= 1) {
								if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
								{
									long distanceAhead = (long)(((running > driverRunning) ? (running * trackLength)
																						   : ((running * trackLength) + trackLength)) - (driverRunning * trackLength));

									clearAverageSpeed(running);

									if (speed < (avgSpeed / 5))
									{
										if (distanceAhead < aheadAccidentDistance) {
											accidentsAhead.push_back(SlowCarInfo(i, distanceAhead));

											if (traceFileName != "") {
												std::ofstream output;

												output.open(traceFileName, std::ios::out | std::ios::app);

												output << "Accident Ahead: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceAhead) << std::endl;

												output.close();
											}
										}

										long distanceBehind = (long)(((running < driverRunning) ? (driverRunning * trackLength)
																								: ((driverRunning * trackLength) + trackLength)) - (running * trackLength));

										if (distanceBehind < behindAccidentDistance) {
											accidentsBehind.push_back(SlowCarInfo(i, distanceBehind));

											if (traceFileName != "") {
												std::ofstream output;

												output.open(traceFileName, std::ios::out | std::ios::app);

												output << "Accident Behind: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceBehind) << std::endl;

												output.close();
											}
										}
									}
									else if (distanceAhead < slowCarDistance) {
										slowCarsAhead.push_back(SlowCarInfo(i, distanceAhead));

										if (traceFileName != "") {
											std::ofstream output;

											output.open(traceFileName, std::ios::out | std::ios::app);

											output << "Slow: " << i << "; Speed: " << round(speed) << "; Distance: " << round(distanceAhead) << std::endl;

											output.close();
										}
									}
								}
								else
									updateIdealLine(header, data, carIndex, running, speed);
							}
						}
						else {
							if (speed >= 1) {
								if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
									accident = true;
							}
						}
					}
				}
			}
		}
		catch (const std::exception& ex) {
			if (traceFileName != "") {
				std::ofstream output;

				output.open(traceFileName, std::ios::out | std::ios::app);

				output << std::endl << "Error: " << std::string(ex.what()) << std::endl;

				output.close();
			}

			sendSpotterMessage(("internalError:" + std::string(ex.what())).c_str());
		}
		catch (const std::string& ex) {
			if (traceFileName != "") {
				std::ofstream output;

				output.open(traceFileName, std::ios::out | std::ios::app);

				output << std::endl << "Error: " << ex << std::endl;

				output.close();
			}

			sendSpotterMessage(("internalError:" + ex).c_str());
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

	if (!accident) {
		if (accidentsAhead.size() > 0)
		{
			if (cycle > nextAccidentAhead)
			{
				long distance = LONG_MAX;

				for (int i = 0; i < accidentsAhead.size(); i++)
					distance = min(distance, accidentsAhead[i].distance);

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
					distance = min(distance, slowCarsAhead[i].distance);

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
					distance = min(distance, accidentsBehind[i].distance);

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
		const char* sessionInfo = irsdk_getSessionInfoStr();
		char sessionID[10] = "";
		char result[64];
		bool race = false;
		
		getDataValue(result, header, data, "SessionFlags");

		int flags = atoi(result);

		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionType:", sessionID))
			if (strstr(result, "Race"))
				race = true;

		if ((flags & irsdk_startGo) && race) {
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

float lastTopSpeed = 0;
int lastLaps = 0;

void updateTopSpeed(const irsdk_header* header, const char* data) {
	char* rawValue;

	getRawDataValue(rawValue, header, data, "Speed");

	float speed = *((float*)rawValue) * 3.6;

	if (speed > lastTopSpeed)
		lastTopSpeed = speed;

	getRawDataValue(rawValue, header, data, "Lap");

	int completedLaps = *((int*)rawValue);

	if (completedLaps > lastLaps) {
		char message[40] = "speedUpdate:";
		char numBuffer[20];

		sprintf_s(numBuffer, "%f", lastTopSpeed);
		strcat_s(message, numBuffer);

		sendSpotterMessage(message);

		lastTopSpeed = 0;
		lastLaps = completedLaps;
	}
}

const int MAXVALUES = 6;

std::vector<float> recentSteerAngles;
std::vector<float> recentGLongs;
std::vector<float> recentIdealAngVels;
std::vector<float> recentRealAngVels;

std::vector<float> recentLatAccels;

void pushValue(std::vector<float>& values, float value) {
	values.push_back(value);

	if ((int)values.size() > MAXVALUES)
		values.erase(values.begin());
}

float averageValue(std::vector<float>& values, int& num) {
	std::vector <float>::iterator iter;
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
long lastSound = 0;

bool triggerUSOSBeep(std::string soundsDirectory, std::string audioDevice, float usos) {
	std::string wavFile = "";

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
			sendAnalyzerMessage(("acousticFeedback:" + wavFile).c_str());
		else
			PlaySoundA(wavFile.c_str(), NULL, SND_FILENAME | SND_ASYNC);

		return true;
	}
	else
		return false;
}

bool collectTelemetry(const irsdk_header* header, const char* data, std::string soundsDirectory, std::string audioDevice, bool calibrate) {
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

	getRawDataValue(rawValue, header, data, "SteeringWheelAngleMax");

	float maxSteerAngle = *((float*)rawValue);
	
	steerLock = maxSteerAngle * 2 * 57.2958;

	getRawDataValue(rawValue, header, data, "SteeringWheelAngle");

	float rawSteerAngle = -*((float*)rawValue);

	float steerAngle = smoothValue(recentSteerAngles, rawSteerAngle / maxSteerAngle);

	getRawDataValue(rawValue, header, data, "Speed");

	float speed = *((float*)rawValue) * 3.6;
	float acceleration = speed - lastSpeed;

	lastSpeed = speed;

	pushValue(recentGLongs, acceleration);

	getRawDataValue(rawValue, header, data, "LatAccel");

	float lateralAcceleration = smoothValue(recentLatAccels, *((float*)rawValue));

	getRawDataValue(rawValue, header, data, "Lap");

	int completedLaps = *((int*)rawValue);

	getRawDataValue(rawValue, header, data, "YawRate");

	float angularVelocity = smoothValue(recentRealAngVels, *((float*)rawValue));

	float steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	float steerAngleRadians = -steeredAngleDegs / 57.2958;
	float wheelBaseMeter = (float)wheelbase / 100;
	float radius = wheelBaseMeter / steerAngleRadians;
	float perimeter = radius * PI * 2;
	float perimeterSpeed = lastSpeed / 3.6;

	if (fabs(steerAngle) > 0.1 && lastSpeed > 60) {
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

		CornerDynamics cd = CornerDynamics(lastSpeed, 0, completedLaps, phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			float idealAngularVelocity;
			float slip;
	
			if (true) {
				idealAngularVelocity = smoothValue(recentIdealAngVels, perimeterSpeed / perimeter * 2 * PI);
				slip = fabs(idealAngularVelocity - angularVelocity);

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

				cd.usos = slip * 57.2958 * 1;
			}
			else {
				idealAngularVelocity = smoothValue(recentIdealAngVels, lateralAcceleration / max(0.01f, lastSpeed / 3.6));
				slip = fabs(idealAngularVelocity) / max(0.01f, fabs(angularVelocity));

				if (slip < 1)
					slip = -(fabs(idealAngularVelocity) - fabs(angularVelocity));
				else
					slip = fabs(angularVelocity) - fabs(idealAngularVelocity);

				cd.usos = slip * 57.2958 * 1;
			}

			if ((soundsDirectory != "") && GetTickCount() > (lastSound + 300))
				if (triggerUSOSBeep(soundsDirectory, audioDevice, cd.usos))
					lastSound = GetTickCount();

			if (false) {
				std::ofstream output;

				output.open(dataFile + ".trace", std::ios::out | std::ios::app);

				output << rawSteerAngle << "  " << maxSteerAngle << "  " << steerAngle << "  " << steeredAngleDegs << "  " << steerAngleRadians << "  " <<
						  lastSpeed << "  " << idealAngularVelocity << "  " << angularVelocity << "  " << slip << "  " <<
						  cd.usos << std::endl;

				output.close();
				
				Sleep(200);
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

void writeTelemetry(const irsdk_header* header, const char* data, bool calibrate) {
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
		
		int slowOSMin[] = { 0, 0, 0 };
		int fastOSMin[] = { 0, 0, 0 };
		int slowUSMax[] = { 0, 0, 0 };
		int fastUSMax[] = { 0, 0, 0 };

		std::vector<CornerDynamics>::iterator cornerIter;
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
			output << "[Understeer.Slow]" << std::endl;

			output << "Entry=" << slowUSMax[0] << std::endl;
			output << "Apex=" << slowUSMax[1] << std::endl;
			output << "Exit=" << slowUSMax[2] << std::endl;
			
			output << "[Understeer.Fast]" << std::endl;

			output << "Entry=" << fastUSMax[0] << std::endl;
			output << "Apex=" << fastUSMax[1] << std::endl;
			output << "Exit=" << fastUSMax[2] << std::endl;
			
			output << "[Oversteer.Slow]" << std::endl;

			output << "Entry=" << slowOSMin[0] << std::endl;
			output << "Apex=" << slowOSMin[1] << std::endl;
			output << "Exit=" << slowOSMin[2] << std::endl;
			
			output << "[Oversteer.Fast]" << std::endl;

			output << "Entry=" << fastOSMin[0] << std::endl;
			output << "Apex=" << fastOSMin[1] << std::endl;
			output << "Exit=" << fastOSMin[2] << std::endl;
		}
		else {
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
int points = 0;

bool circuit = true;
bool mapStarted = false;
int mapLap = -1;

inline float vectorLength(float x, float y) {
	return sqrt((x * x) + (y * y));
}

float vectorAngle(float x, float y) {
	float scalar = (x * 0) + (y * 1);
	float length = vectorLength(x, y);

	float angle = (length > 0) ? acos(scalar / length) : 0;

	if (x < 0)
		angle = - angle;

	return angle;
}

bool writeCoordinates(const irsdk_header* header, const char* data, int playerCarIdx) {
	char buffer[60];
	char* rawValue;

	getRawDataValue(rawValue, header, data, "Lap");

	int carLaps = *((int*)rawValue);

	if (!mapStarted)
		if (mapLap == -1) {
			mapLap = carLaps;

			return true;
		}
		else if (carLaps == mapLap)
			return true;

	if (lastLap == 0)
		lastLap = carLaps;
	else if (!recording) {
		if (carLaps != lastLap) {
			lastLap = carLaps;
			
			printf("0.0,0.0,0.0,0.0,0.0\n");

			char* trackPositions;

			if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct"))
				lastRunning = ((float*)trackPositions)[playerCarIdx];

			lastTickCount = GetTickCount();

			recording = true;
		}
	}
	else if (carLaps != lastLap)
		return false;
	else {
		if (GetTickCount() - lastTickCount < 20)
			return true;

		char* trackPositions;
		float running = 0.0;

		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct"))
			running = ((float*)trackPositions)[playerCarIdx];

		if (running < lastRunning)
			return false;
		
		float distance = (running - lastRunning) * 6000;
		
		lastRunning = running;

		getDataValue(buffer, header, data, "Yaw");

		float yaw = atof(buffer);

		/*
		getDataValue(buffer, header, data, "YawNorth");

		float yawNorth = atof(buffer);

		getDataValue(buffer, header, data, "VelocityX");

		float velocityX = atof(buffer);

		getDataValue(buffer, header, data, "VelocityY");

		float velocityY = atof(buffer);

		getDataValue(buffer, header, data, "VelocityZ");

		float velocityZ = atof(buffer);

		float distance = sqrt(velocityX * velocityX + velocityY * velocityY + velocityZ * velocityZ);
		*/
		
		// float dx = distance * sin(yaw);
		// float dy = distance * cos(yaw);

		float dx = distance * sin(yaw);
		float dy = distance * cos(yaw);

		if (dx != 0 || dy != 0) {
			mapStarted = true;

			lastX += dx;
			lastY += dy;

			printf("%f,%f,%f,%f,%f\n", running, lastX, lastY, yaw, distance);

			if (circuit && (++points > 100) && fabs(lastX - initialX) < 10.0 && fabs(lastY - initialY) < 10.0)
				return false;
		}
		else if (mapStarted && !circuit)
			return false;

		lastTickCount = GetTickCount();
	}

	return true;
}

float xCoordinates[60];
float yCoordinates[60];
float trackDistances[60];
int numCoordinates = 0;
time_t lastUpdate = 0;
char* triggerType = "Automation";

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

				if (strcmp(triggerType, "Automation") == 0)
					sendAutomationMessage(buffer);
				else
					sendTriggerMessage(buffer);

				lastUpdate = time(NULL);
			}
		}
	}
}

std::string telemetryDirectory = "";
std::ofstream telemetryFile;
int telemetryLap = -1;
double lastTelemetryRunning = -1;

void collectCarTelemetry(const irsdk_header* header, const char* data, const int playerCarIndex, float trackLength) {
	char buffer[60] = "";
	char* rawValue;

	getRawDataValue(rawValue, header, data, "Lap");

	int carLaps = *((int*)rawValue);

	try {
		if ((carLaps + 1) != telemetryLap) {
			try {
				telemetryFile.close();

				sprintf_s(buffer, "%d", telemetryLap);

				remove((telemetryDirectory + "\\Lap " + buffer + ".telemetry").c_str());

				rename((telemetryDirectory + "\\Lap " + buffer + ".tmp").c_str(),
					   (telemetryDirectory + "\\Lap " + buffer + ".telemetry").c_str());
			}
			catch (...) {
			}

			telemetryLap = (carLaps + 1);

			sprintf_s(buffer, "%d", telemetryLap);

			telemetryFile.open(telemetryDirectory + "\\Lap " + buffer + ".tmp", std::ios::out | std::ios::trunc);
			
			lastTelemetryRunning = -1;
		}

		char* trackPositions;
		char* pitLaneStates;
		float playerRunning = 0.0;
		float speed = 0.0;
		float throttle = 0.0;
		float brake = 0.0;
		float steerAngle = 0.0;
		int gear = 0;
		int rpms = 0;
		float longG = 0.0;
		float latG = 0.0;

		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct"))
			playerRunning = ((float*)trackPositions)[playerCarIndex];

		if (playerRunning > lastTelemetryRunning) {
			if (getRawDataValue(rawValue, header, data, "Speed"))
				speed = *((float*)rawValue) * 3.6;

			if (getRawDataValue(rawValue, header, data, "Throttle"))
				throttle = *(float*)rawValue;

			if (getRawDataValue(rawValue, header, data, "Brake"))
				brake = *(float*)rawValue;

			if (getRawDataValue(rawValue, header, data, "SteeringWheelAngleMax")) {
				float maxSteerAngle = *((float*)rawValue);

				if (getRawDataValue(rawValue, header, data, "SteeringWheelAngle"))
					steerAngle = *((float*)rawValue) / maxSteerAngle;
			}

			if (getRawDataValue(rawValue, header, data, "Gear"))
				gear = *(int*)rawValue;

			if (getRawDataValue(rawValue, header, data, "RPM"))
				rpms = (int)*(float*)rawValue;

			if (getRawDataValue(rawValue, header, data, "LongAccel"))
				longG = (*(float*)rawValue) / 9.807;

			if (getRawDataValue(rawValue, header, data, "LatAccel"))
				latG = (*(float*)rawValue) / 9.807;
			
			telemetryFile << (playerRunning * trackLength) << ";"
						  << throttle << ";"
						  << brake << ";"
						  << steerAngle << ";"
						  << gear << ";"
						  << rpms << ";"
						  << speed << ";"
						  << "n/a" << ";"
						  << "n/a" << ";"
						  << longG << ";" << - latG;

			float coordinateX;
			float coordinateY;

			if (getCarCoordinates(header, data, playerCarIndex, coordinateX, coordinateY))
				telemetryFile << ";" << coordinateX << ";" << coordinateY << std::endl;
			else
				telemetryFile << std::endl;

			if (fileExists(telemetryDirectory + "\\Telemetry.cmd"))
				try {
					std::ofstream file;

					file.open(telemetryDirectory + "\\Telemetry.section", std::ios::out | std::ios::ate | std::ios::app);

					file << (playerRunning * trackLength) << ";"
						 << throttle << ";"
						 << brake << ";"
						 << steerAngle << ";"
						 << gear << ";"
						 << rpms << ";"
						 << speed << ";"
						 << "n/a" << ";"
						 << "n/a" << ";"
						 << longG << ";" << -latG;

					if (getCarCoordinates(header, data, playerCarIndex, coordinateX, coordinateY))
						file << ";" << coordinateX << ";" << coordinateY << std::endl;
					else
						file << std::endl;

					file.close();
				}
				catch (...) {}

			lastTelemetryRunning = playerRunning;
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

bool started = false;

inline const bool active(const irsdk_header* header, const char* data) {
	if (started)
		return true;
	else {
		const char* sessionInfo = irsdk_getSessionInfoStr();
		char playerCarIdx[10] = "";
		char sessionID[10] = "";
		char result[64];
		bool race = false;
		int laps = 0;

		getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");

		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		getDataValue(result, header, data, "SessionFlags");

		int flags = atoi(result);

		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionType:", sessionID))
			if (strstr(result, "Race"))
				race = true;

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LapsComplete:", sessionID, playerCarIdx))
			laps = atoi(result);

		if (race && !(flags & irsdk_startGo) && (laps == 0))
			return false;
	}

	started = true;

	return true;
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
	bool calibrateTelemetry = false;
	bool analyzeTelemetry = false;
	bool carTelemetry = false;

	char* soundsDirectory = "";
	char* audioDevice = "";

	if (argc > 1) {
		calibrateTelemetry = (strcmp(argv[1], "-Calibrate") == 0);
		analyzeTelemetry = calibrateTelemetry || (strcmp(argv[1], "-Analyze") == 0);
		mapTrack = (strcmp(argv[1], "-Map") == 0);
		positionTrigger = (strcmp(argv[1], "-Automation") == 0);
		carTelemetry = (strcmp(argv[1], "-Telemetry") == 0);

		if (!positionTrigger) {
			positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

			if (positionTrigger)
				triggerType = "Trigger";
		}

		if (mapTrack) {
			if (argc > 2)
				circuit = (strcmp(argv[2], "Circuit") == 0);

			// SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS);
		}

		if (analyzeTelemetry) {
			dataFile = argv[2];

			if (calibrateTelemetry) {
				lowspeedThreshold = atoi(argv[3]);
				steerRatio = atoi(argv[4]);
				wheelbase = atoi(argv[5]);
				trackWidth = atoi(argv[6]);
			}
			else {
				understeerLightThreshold = atoi(argv[3]);
				understeerMediumThreshold = atoi(argv[4]);
				understeerHeavyThreshold = atoi(argv[5]);
				oversteerLightThreshold = atoi(argv[6]);
				oversteerMediumThreshold = atoi(argv[7]);
				oversteerHeavyThreshold = atoi(argv[8]);
				lowspeedThreshold = atoi(argv[9]);
				steerRatio = atoi(argv[10]);
				wheelbase = atoi(argv[11]);
				trackWidth = atoi(argv[12]);

				if (argc > 14) {
					soundsDirectory = argv[14];

					if (argc > 15)
						soundsDirectory = argv[15];
				}
			}
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
		else if (carTelemetry) {
			char* trackLength = argv[2];

			telemetryDirectory = argv[3];

			if (argc > 3) {
				loadTrackCoordinates(argv[4]);

				hasTrackCoordinates = true;
			}
		}
		else {
			for (int i = 0; i < 512; ++i)
				lastRunnings[i] = 0;

			if (argc > 1)
				char* trackLength = argv[1];
			
			if (argc > 2)
				aheadAccidentDistance = atoi(argv[2]);

			if (argc > 3)
				behindAccidentDistance = atoi(argv[3]);

			if (argc > 4)
				slowCarDistance = atoi(argv[4]);

			if (argc > 5)
				semFileName = std::string(argv[5]);

			if (argc > 6)
				thresholdSpeed = atoi(argv[6]);

			if (argc > 7) {
				traceFileName = std::string(argv[7]);

				if (traceFileName == "-")
					traceFileName = "";
			}

			if (argc > 8)
				loadTrackCoordinates(argv[8]);
		}
	}

	float trackLength = 0.0;
	bool done = false;
	long counter = 0;
	int playerCarIndex = -1;

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

					if (playerCarIndex == -1) {
						char playerCarIdx[10] = "";

						getYamlValue(playerCarIdx, irsdk_getSessionInfoStr(), "DriverInfo:DriverCarIdx:");

						playerCarIndex = atoi(playerCarIdx);
					}

					if (analyzeTelemetry) {
						if (collectTelemetry(pHeader, g_data, soundsDirectory, audioDevice, calibrateTelemetry)) {
							if (remainder(counter, 20) == 0)
								writeTelemetry(pHeader, g_data, calibrateTelemetry);
						}
						else
							break;
					}
					else if (mapTrack) {
						if (!writeCoordinates(pHeader, g_data, playerCarIndex)) {
							done = true;

							break;
						}
					}
					else if (positionTrigger)
						checkCoordinates(pHeader, g_data, trackLength);
					else if (active(pHeader, g_data)) {
						if (!greenFlagReported && (counter > 8000))
							greenFlagReported = true;

						if (!running) {
							countdown -= 1;

							getDataValue(result, pHeader, g_data, "SessionFlags");

							int flags = atoi(result);

							running = (((flags& irsdk_startGo) != 0) || ((flags & irsdk_startSet) != 0) || (countdown <= 0));
						}

						if (running) {
							getDataValue(result, pHeader, g_data, "IsOnTrack");
							if (!atoi(result))
								running = false;

							if (running) {
								getDataValue(result, pHeader, g_data, "IsOnTrackCar");
								if (!atoi(result))
									running = false;
							}

							if (running) {
								getDataValue(result, pHeader, g_data, "IsInGarage");
								if (atoi(result))
									running = false;
							}

							if (running) {
								getDataValue(result, pHeader, g_data, "IsReplayPlaying");

								if (atoi(result))
									running = false;

								if (getYamlValue(result, irsdk_getSessionInfoStr(), "WeekendInfo:SimMode:"))
									if (strcmp(result, "full") != 0)
										running = false;
							}
						}

						if (running) {
							char* rawValue;

							if (carTelemetry)
								collectCarTelemetry(pHeader, g_data, playerCarIndex, trackLength);
							else {
								bool onTrack = true;

								getDataValue(result, pHeader, g_data, "IsInGarage");
								if (atoi(result))
									onTrack = false;

								getDataValue(result, pHeader, g_data, "IsReplayPlaying");
								if (atoi(result))
									onTrack = false;

								getRawDataValue(rawValue, pHeader, g_data, "IsOnTrack");
								if (!*(bool*)rawValue)
									onTrack = false;

								getRawDataValue(rawValue, pHeader, g_data, "IsOnTrackCar");
								if (!*(bool*)rawValue)
									onTrack = false;

								bool inPit = false;

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
									updateTopSpeed(pHeader, g_data);

									cycle += 1;

									if (cycle > nextSpeedUpdate)
									{
										char* rawValue;

										getRawDataValue(rawValue, pHeader, g_data, "Speed");

										float speed = *((float*)rawValue) * 3.6;

										nextSpeedUpdate = cycle + 50;

										if ((speed >= thresholdSpeed) && !enabled)
										{
											enabled = true;

											sendSpotterMessage("enableSpotter");
										}
										else if ((speed < thresholdSpeed) && enabled)
										{
											enabled = false;

											sendSpotterMessage("disableSpotter");
										}
									}

									if (greenFlag(pHeader, g_data))
										wait = false;
									else if (enabled)
										if (checkAccident(pHeader, g_data, playerCarIndex, trackLength))
											wait = false;
										else if (checkFlagState(pHeader, g_data) || checkPositions(pHeader, g_data, playerCarIndex, trackLength))
											wait = false;
										else
											wait = !checkPitWindow(pHeader, g_data);

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
						else
							wait = true;
					}
					else
						wait = true;
				}
				else
					Sleep(1000);
			}

			if (g_data)
				delete g_data;
		}

		if (mapTrack)
			Sleep(5);
		else if (carTelemetry || analyzeTelemetry || positionTrigger)
			Sleep(10);
		else if (wait)
			Sleep(50);
	}

	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

