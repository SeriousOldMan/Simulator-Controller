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
#include <comdef.h>
#include <iostream>
#include <sstream>

#include "irsdk_defines.h"
#include "yaml_parser.h"
#include <fstream>

// for timeBeginPeriod
#pragma comment(lib, "Winmm")

// 32 ms timeout
#define TIMEOUT 32

char *g_data = NULL;
int g_nData = 0;

inline void print(std::ostringstream* output, std::string value) {
	(*output) << value;
}

inline void print(std::ostringstream* output, char* value) {
	(*output) << std::string(value);
}

inline void printLine(std::ostringstream* output, std::string value) {
	(*output) << value << std::endl;
}

inline void printLine(std::ostringstream* output, char* value) {
	(*output) << std::string(value) << std::endl;
}

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

bool getYamlValue(char* result, const char* sessionInfo, const char* path) {
	int length = -1;
	const char* string;

	if (parseYaml(sessionInfo, path, &string, &length)) {
		extractString(result, string, length);

		return true;
	}
	else
		return false;
}

bool getYamlValue(char* result, const char* sessionInfo, const char* path, const char* value) {
	char buffer[256];
	int pos = 0;

	sprintf(buffer, path, value);

	return getYamlValue(result, sessionInfo, buffer);
}

bool getYamlValue(char* result, const char* sessionInfo, const char* path, const char* value1, const char* value2) {
	char buffer[256];
	int pos = 0;

	sprintf(buffer, path, value1, value2);

	return getYamlValue(result, sessionInfo, buffer);
}

int getCurrentSessionID(const char* sessionInfo) {
	char id[10] = "";
	char result[100] = "";
	int sID = 0;

	while (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsOfficial:", itoa(sID, id, 10))) {
		if (strcmp(result, "0") == 0)
			return sID;

		sID += 1;
	}

	return -1;
}

long getRemainingTime(const char* sessionInfo, bool practice, int sessionLaps, long sessionTime, int lap, long lastTime, long bestTime);

long getRemainingLaps(const char* sessionInfo, bool practice, int sessionLaps, long sessionTime, int lap, long lastTime, long bestTime) {
	char result[100];

	if (lap < 1)
		return 0;

	if (!practice && sessionLaps > 0)
		return (long)(sessionLaps - lap);
	else if (lastTime > 0)
		return (long)(getRemainingTime(sessionInfo, practice, sessionLaps, sessionTime, lap, lastTime, bestTime) / lastTime);
	else
		return 0;
}

long getRemainingTime(const char* sessionInfo, bool practice, int sessionLaps, long sessionTime, int lap, long lastTime, long bestTime) {
	if (lap < 1)
		return max(0, sessionTime);

	if (practice || sessionLaps == -1) {
		long time = (sessionTime - (bestTime * lap));

		if (time > 0)
			return time;
		else
			return 0;
	}
	else
		return (getRemainingLaps(sessionInfo, practice, sessionLaps, sessionTime, lap, lastTime, bestTime) * lastTime);
}

const char* getWeather(float percentage) {
	if (percentage == 0.0)
		return "Dry";
	else if (percentage <= 0.15)
		return "Drizzle";
	else if (percentage <= 0.3)
		return "LightRain";
	else if (percentage <= 0.5)
		return "MediumRain";
	else if (percentage <= 0.8)
		return "HeavyRain";
	else
		return "Thunderstorm";
}

void printDataValue(std::ostringstream * output, const irsdk_header* header, const char* data, const irsdk_varHeader* rec) {
	if (header && data) {
		int count = rec->count;

		for (int j = 0; j < count; j++)
		{
			switch (rec->type)
			{
			case irsdk_char:
				print(output, (char*)(data + rec->offset)); break;
			case irsdk_bool:
				print(output, ((bool*)(data + rec->offset))[j] ? "true" : "false"); break;
			case irsdk_int:
				print(output, std::to_string(((int*)(data + rec->offset))[j])); break;
			case irsdk_bitField:
				print(output, std::to_string(((int*)(data + rec->offset))[j])); break;
			case irsdk_float:
				print(output, std::to_string(((float*)(data + rec->offset))[j])); break;
			case irsdk_double:
				print(output, std::to_string(((double*)(data + rec->offset))[j])); break;
			}

			if (j + 1 < count)
				print(output, ", ");
		}
	}
}

void printDataValue(std::ostringstream* output, const irsdk_header* header, const char* data, const char* variable) {
	if (header && data) {
		for (int i = 0; i < header->numVars; i++) {
			const irsdk_varHeader* rec = irsdk_getVarHeaderEntry(i);

			if (strcmp(rec->name, variable) == 0) {
				printDataValue(output, header, data, rec);

				break;
			}
		}
	}
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

int getDataInt(const irsdk_header* header, const char* data, const char* variable) {
	char result[32];

	if (getDataValue(result, header, data, variable))
		return atoi(result);
	else
		return 0;
}

void printDataNAFloat(std::ostringstream* output, const irsdk_header* header, const char* data, const char* variable) {
	char result[32];

	if (getDataValue(result, header, data, variable))
		print(output, result);
	else
		print(output, "n/a");
}

void setPitstopRefuelAmount(float fuelAmount) {
	if (fuelAmount == 0)
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_ClearFuel, 0);
	else
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_Fuel, (int)fuelAmount);
}

void requestPitstopRepairs(bool repair) {
	if (repair)
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_FR, 0);
	else
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_ClearFR, 0);
}

void requestPitstopTyreChange(bool change) {
	if (change) {
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_LF, 0);
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_RF, 0);
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_LR, 0);
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_RR, 0);
	}
	else
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_ClearTires, 0);
}

float getTyreTemperature(const irsdk_header* header, const char* sessionInfo, const char* data, const char* sessionPath,
						 const char* dataVariableO, const char* dataVariableM, const char* dataVariableI) {
	char result[32];

	if (getDataValue(result, header, data, dataVariableO))
		return (atof(result) + getDataFloat(header, data, dataVariableM) + getDataFloat(header, data, dataVariableI)) / 3;
	else if (getYamlValue(result, sessionInfo, sessionPath)) {
		char* values = result;
		float temps[3];

		for (int i = 0; i < 2; i++) {
			char buffer[32];
			size_t length = strcspn(values, ",");

			substring(values, buffer, 0, length);

			temps[i] = atof(buffer);

			values += (length + 1);
		}

		temps[2] = atof(values);

		return (temps[0] + temps[1] + temps[2]) / 3;
	}
	else
		return 0;
}

int getTyreWear(const irsdk_header* header, const char* sessionInfo, const char* data,
				const char* dataVariableO, const char* dataVariableM, const char* dataVariableI) {
	char result[32];

	if (getDataValue(result, header, data, dataVariableO))
		return 100 - (int)(((atof(result) +
							 getDataFloat(header, data, dataVariableM) +
							 getDataFloat(header, data, dataVariableI)) / 3) * 100);
	else
		return 0;
}

float getTyrePressure(const irsdk_header* header, const char* sessionInfo, const char* data, const char* sessionPath, const char* dataVariable) {
	char result[32];

	if (getDataValue(result, header, data, dataVariable))
		return atof(result);
	else if (getYamlValue(result, sessionInfo, sessionPath)) {
		char temp[32];

		substring((char*)result, temp, 0, strcspn(result, " "));

		return atof(temp);
	}
	else
		return 0;
}

void setTyrePressure(int command, float pressure) {
	irsdk_broadcastMsg(irsdk_BroadcastPitCommand, command, (int)GetKpa(pressure));
}

void setPitstopTyrePressures(float pressures[4]) {
	setTyrePressure(irsdk_PitCommand_LF, pressures[0]);
	setTyrePressure(irsdk_PitCommand_RF, pressures[1]);
	setTyrePressure(irsdk_PitCommand_LR, pressures[2]);
	setTyrePressure(irsdk_PitCommand_RR, pressures[3]);
}

void pitstopSetValues(const irsdk_header* header, const char* data, const char* arguments) {
	char service[64];
	char valuesBuffer[64];
	char* values = valuesBuffer;
	size_t length = strcspn(arguments, ":");

	substring((char*)arguments, service, 0, length);
	substring((char*)arguments, values, length + 1, strlen(arguments) - length - 1);

	if (strcmp(service, "Refuel") == 0)
		setPitstopRefuelAmount(atof(values));
	else if (strcmp(service, "Repair") == 0)
		requestPitstopRepairs((strcmp(values, "true") == 0));
	else if (strcmp(service, "Tyre Change") == 0)
		requestPitstopTyreChange((strcmp(values, "true") == 0));
	else if (strcmp(service, "Tyre Pressure") == 0) {
		float pressures[4];

		for (int i = 0; i < 3; i++) {
			char buffer[32];
			size_t length = strcspn(values, ";");

			substring(values, buffer, 0, length);

			pressures[i] = atof(buffer);

			values += (length + 1);
		}

		pressures[3] = atof(values);

		setPitstopTyrePressures(pressures);
	}
}

void changePitstopRefuelAmount(const irsdk_header* header, const char* data, float fuelDelta) {
	if (fuelDelta != 0)
		irsdk_broadcastMsg(irsdk_BroadcastPitCommand, irsdk_PitCommand_Fuel, (int)(getDataFloat(header, data, "PitSvFuel") + fuelDelta));
}

void changePitstopTyrePressure(const irsdk_header* header, int command, const char* serviceFlag, float pressureDelta) {
	int tries = 10;
	float currentPressure = getDataFloat(header, g_data, serviceFlag);
	float targetPressure = GetPsi(currentPressure) + pressureDelta;

	while ((getDataFloat(header, g_data, serviceFlag) == currentPressure) && (tries-- > 0)) {
		initData(header, g_data, g_nData);
		irsdk_waitForDataReady(TIMEOUT, g_data);

		setTyrePressure(command, targetPressure);

		targetPressure += (pressureDelta >= 0) ? 0.1 : -0.1;
	}
}

void changePitstopTyrePressure(const irsdk_header* header, const char* tyre, float pressureDelta) {
	if (strcmp(tyre, "FL") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_LF, "PitSvLFP", pressureDelta);
	else if (strcmp(tyre, "FR") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_RF, "PitSvRFP", pressureDelta);
	else if (strcmp(tyre, "RL") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_LR, "PitSvLRP", pressureDelta);
	else if (strcmp(tyre, "RR") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_RR, "PitSvRRP", pressureDelta);
}

void pitstopChangeValues(const irsdk_header* header, const char* data, const char* arguments) {
	char service[64];
	char values[64];
	size_t length = strcspn(arguments, ":");

	substring((char*)arguments, service, 0, length);
	substring((char*)arguments, values, length + 1, strlen(arguments) - length - 1);

	if (strcmp(service, "Refuel") == 0)
		changePitstopRefuelAmount(header, data, atof(values));
	else if (strcmp(service, "Repair") == 0)
		requestPitstopRepairs((strcmp(values, "true") == 0));
	else if (strcmp(service, "Tyre Change") == 0)
		requestPitstopTyreChange((strcmp(values, "true") == 0));
	else if (strcmp(service, "All Around") == 0) {
		changePitstopTyrePressure(header, "FL", atof(values));
		changePitstopTyrePressure(header, "FR", atof(values));
		changePitstopTyrePressure(header, "RL", atof(values));
		changePitstopTyrePressure(header, "RR", atof(values));
	}
	else if (strcmp(service, "Front Left") == 0)
		changePitstopTyrePressure(header, "FL", atof(values));
	else if (strcmp(service, "Front Right") == 0)
		changePitstopTyrePressure(header, "FR", atof(values));
	else if (strcmp(service, "Rear Left") == 0)
		changePitstopTyrePressure(header, "RL", atof(values));
	else if (strcmp(service, "Rear Right") == 0)
		changePitstopTyrePressure(header, "RR", atof(values));
}

void dumpDataToDisplay(const irsdk_header* header, const char* data)
{
	if (header && data)
	{
		int newLineCount = 5;

		for (int i = 0; i < header->numVars; i++)
		{
			const irsdk_varHeader* rec = irsdk_getVarHeaderEntry(i);

			printf("%s[", rec->name);

			// only dump the first 4 entrys in an array to save space
			// for now ony carsTrkPct and carsTrkLoc output more than 4 entrys
			int count = 1;
			if (rec->type != irsdk_char)
				count = min(4, rec->count);

			for (int j = 0; j < count; j++)
			{
				switch (rec->type)
				{
				case irsdk_char:
					printf("%s", (char*)(data + rec->offset)); break;
				case irsdk_bool:
					printf("%d", ((bool*)(data + rec->offset))[j]); break;
				case irsdk_int:
					printf("%d", ((int*)(data + rec->offset))[j]); break;
				case irsdk_bitField:
					printf("0x%08x", ((int*)(data + rec->offset))[j]); break;
				case irsdk_float:
					printf("%0.2f", ((float*)(data + rec->offset))[j]); break;
				case irsdk_double:
					printf("%0.2f", ((double*)(data + rec->offset))[j]); break;
				}

				if (j + 1 < count)
					printf("; ");
			}
			if (rec->type != irsdk_char && count < rec->count)
				printf("; ...");

			printf("]");

			if ((i + 1) < header->numVars)
				printf(", ");

			if (newLineCount-- <= 0) {
				newLineCount = 5;

				printf("\n");
			}
		}
		printf("\n\n");
	}
}

void readDriverInfo(const char* sessionInfo, char* carIdx, char* forName, char* surName, char* nickName) {
	char result[100];

	if (getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}UserName:", carIdx)) {
		size_t length = strcspn(result, " ");

		substring((char*)result, forName, 0, length);
		substring((char*)result, surName, length + 1, strlen(result) - length - 1);
		nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';
	} else {
		strcpy(forName, "John");
		strcpy(surName, "Doe");
		strcpy(nickName, "JD");
	}
}

bool hasTrackCoordinates = false;
float rXCoordinates[1000];
float rYCoordinates[1000];

bool getCarCoordinates(const irsdk_header* header, const char* data, const int carIdx, float& coordinateX, float& coordinateY) {
	char* trackPositions;

	if (hasTrackCoordinates) {
		if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct")) {
			int index = max(0, min((int)round(((float*)trackPositions)[carIdx] * 1000), 999));

			coordinateX = rXCoordinates[index];
			coordinateY = rYCoordinates[index];

			return true;
		}
	}
	
	return false;
}

void writePositions(std::ostringstream* output, const irsdk_header *header, const char* data)
{
	if (header && data)
	{
		const char* sessionInfo = irsdk_getSessionInfoStr();
		char playerCarIdx[10] = "";
		char sessionID[10] = "";

		getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");

		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		char result[100];
		char posIdx[10];
		char carIdx[10];
		char carIdx1[10];

		printLine(output, "[Position Data]");
		
		itoa(atoi(playerCarIdx) + 1, carIdx1, 10);

		printLine(output, "Driver.Car=" + std::string(carIdx1));
		
		for (int i = 1; ; i++) {
			itoa(i, posIdx, 10);
			
			if (getYamlValue(carIdx, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:Position:{%s}CarIdx:", sessionID, posIdx)) {
				int carIndex = atoi(carIdx);
				char carIdx1[10];

				itoa(carIndex + 1, carIdx1, 10);

				getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarNumber:", carIdx1);

				printLine(output, "Car." + std::string(carIdx1) + ".Nr=" + std::string(result));
				printLine(output, "Car." + std::string(carIdx1) + ".Position=" + std::string(posIdx));

				getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LapsComplete:", sessionID, carIdx);

				printLine(output, "Car." + std::string(carIdx1) + ".Laps=" + std::string(result));

				getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LastTime:", sessionID, carIdx);

				printLine(output, "Car." + std::string(carIdx1) + ".Time=" + std::to_string((long)(normalize(atof(result)) * 1000)));

				getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}Incidents:", sessionID, carIdx);

				printLine(output, "Car." + std::string(carIdx1) + ".Incidents=" + std::string(result));

				char* trackPositions;
				
				if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct"))
					printLine(output, "Car." + std::string(carIdx1) + ".Lap.Running=" + std::to_string(((float*)trackPositions)[carIndex]));

				getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarScreenName:", carIdx);

				printLine(output, "Car." + std::string(carIdx1) + ".Car=" + std::string(result));

				getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarClassShortName:", carIdx);

				if (std::string(result).length() > 0)
					printLine(output, "Car." + std::string(carIdx1) + ".Class=" + std::string(result));

				char forName[100];
				char surName[100];
				char nickName[3];

				readDriverInfo(sessionInfo, carIdx, forName, surName, nickName);

				printLine(output, "Car." + std::string(carIdx1) + ".Driver.Forname=" + std::string(forName));
				printLine(output, "Car." + std::string(carIdx1) + ".Driver.Surname=" + std::string(surName));
				printLine(output, "Car." + std::string(carIdx1) + ".Driver.Nickname=" + std::string(nickName));

				char* pitLaneStates;

				if (getRawDataValue(pitLaneStates, header, data, "CarIdxOnPitRoad"))
					printLine(output, "Car." + std::string(carIdx1) + ".InPitLane=" + std::string(((bool*)pitLaneStates)[carIndex] ? "true" : "false"));
			}
			else {
				itoa(i - 1, posIdx, 10);

				printLine(output, "Car.Count=" + std::string(posIdx));
				
				break;
			}
		}
	}
}

void writeData(std::ostringstream * output, const irsdk_header *header, const char* data, bool setupOnly)
{
	if (header && data)
	{
		const char* sessionInfo = irsdk_getSessionInfoStr();
		char playerCarIdx[10] = "";
		char sessionID[10] = "";

		getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");

		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		char result[100];

		int sessionLaps = -1;
		long sessionTime = -1;
		int laps = 0;
		float maxFuel = 0;

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LapsComplete:", sessionID, playerCarIdx))
			laps = atoi(result);

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionLaps:", sessionID))
			if (strcmp(result, "unlimited") != 0)
				sessionLaps = atoi(result);
			else if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionTime:", sessionID)) {
				char buffer[64];
				float time;

				substring((char*)result, buffer, 0, strcspn(result, " "));

				time = atof(buffer);

				sessionTime = ((long)time * 1000);
			}
			else {
				sessionTime = 0;
			}

		if (getYamlValue(result, sessionInfo, "DriverInfo:DriverCarFuelMaxLtr:"))
			maxFuel = atof(result);

		long lastTime = 0;
		long bestTime = 0;

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LastTime:", sessionID, playerCarIdx))
			lastTime = (long)(normalize(atof(result)) * 1000);

		if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}FastestTime:", sessionID, playerCarIdx))
			bestTime = (long)(normalize(atof(result)) * 1000);

		if (bestTime == 0)
			bestTime = lastTime;

		printLine(output, "[Setup Data]");

		int compound = getDataInt(header, data, "PitSvTireCompound");

		printLine(output, "TyreCompoundRaw=" + std::to_string((compound == -1) ? 1 : compound + 1));

		printLine(output, "FuelAmount=" + std::to_string(getDataFloat(header, data, "PitSvFuel")));

		float pressureFL = GetPsi(getDataFloat(header, data, "PitSvLFP"));
		float pressureFR = GetPsi(getDataFloat(header, data, "PitSvRFP"));
		float pressureRL = GetPsi(getDataFloat(header, data, "PitSvLRP"));
		float pressureRR = GetPsi(getDataFloat(header, data, "PitSvRRP"));

		printLine(output, "TyrePressureFL=" + std::to_string(pressureFL));
		printLine(output, "TyrePressureFR=" + std::to_string(pressureFR));
		printLine(output, "TyrePressureRL=" + std::to_string(pressureRL));
		printLine(output, "TyrePressureRR=" + std::to_string(pressureRR));

		printLine(output, "TyrePressure=" + std::to_string(pressureFL) + "," + std::to_string(pressureFR) + ","
										  + std::to_string(pressureRL) + "," + std::to_string(pressureRR));
		
		if (!setupOnly) {
			printLine(output, "[Session Data]");

			bool running = false;
			const char* paused = "false";

			getDataValue(result, header, data, "IsOnTrack");
			if (atoi(result))
				running = true;

			getDataValue(result, header, data, "IsOnTrackCar");
			if (atoi(result))
				running = true;

			getDataValue(result, header, data, "IsInGarage");
			if (atoi(result))
				running = false;

			if (running) {
				getDataValue(result, header, data, "IsReplayPlaying");

				if (atoi(result))
					paused = "true";
			}
			else
				paused = "true";

			printLine(output, "Active=true");
			printLine(output, "Paused=" + std::string(paused));

			char buffer[64];

			getDataValue(buffer, header, data, "SessionFlags");

			int flags = atoi(buffer);

			bool practice = false;

			if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionType:", sessionID))
				if (strstr(result, "Practice"))
					practice = true;

			if (!practice && sessionLaps > 0 && (long)(sessionLaps - laps) <= 0)
				printLine(output, "Session=Finished");
			else if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionType:", sessionID)) {
				if (practice)
					printLine(output, "Session=Practice");
				else if (strstr(result, "Qualify"))
					printLine(output, "Session=Qualification");
				else if (strstr(result, "Race"))
					printLine(output, "Session=Race");
				else
					printLine(output, "Session=Other");
			}
			else
				printLine(output, "Session=Other");

			printLine(output, "FuelAmount=" + std::to_string(maxFuel));

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackName:"))
				printLine(output, "Track=" + std::string(result));
			else
				printLine(output, "Track=Unknown");

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackDisplayName:"))
				printLine(output, "TrackLongName=" + std::string(result));
			else
				printLine(output, "TrackLongName=Unknown");

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackDisplayShortName:"))
				printLine(output, "TrackShortName=" + std::string(result));
			else
				printLine(output, "TrackShortName=Unknown");

			if (getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarScreenName:", playerCarIdx))
				printLine(output, "Car=" + std::string(result));
			else
				printLine(output, "Car=Unknown");

			if (sessionLaps == -1)
				printLine(output, "SessionFormat=Time");
			else
				printLine(output, "SessionFormat=Laps");

			long timeRemaining = -1;

			if (getDataValue(result, header, data, "SessionTimeRemain")) {
				float time = atof(result);

				if (time != -1)
					timeRemaining = ((long)time * 1000);
			}

			if (timeRemaining == -1)
				timeRemaining = getRemainingTime(sessionInfo, practice, sessionLaps, sessionTime, laps, lastTime, bestTime);

			printLine(output, "SessionTimeRemaining=" + std::to_string(timeRemaining));

			long lapsRemaining = -1;

			timeRemaining = -1;

			if (getDataValue(result, header, data, "SessionLapsRemain"))
				lapsRemaining = atoi(result);

			if ((lapsRemaining == -1) || (lapsRemaining == 32767)) {
				long estTime = lastTime;

				if ((estTime == 0) && getYamlValue(result, sessionInfo, "DriverInfo:DriverCarEstLapTime:"))
					estTime = (long)(atof(result) * 1000);

				lapsRemaining = getRemainingLaps(sessionInfo, practice, sessionLaps, sessionTime, laps, estTime, bestTime);
			}
			
			printLine(output, "SessionLapsRemaining=" + std::to_string(lapsRemaining));

			printLine(output, "[Car Data]");

			print(output, "MAP="); printDataNAFloat(output, header, data, "dcEnginePower"); printLine(output, "");
			print(output, "TC="); printDataNAFloat(output, header, data, "dcTractionControl"); printLine(output, "");
			print(output, "ABS="); printDataNAFloat(output, header, data, "dcABS"); printLine(output, "");

			printLine(output, "BodyworkDamage=0,0,0,0,0");
			printLine(output, "SuspensionDamage=0,0,0,0");
			printLine(output, "EngineDamage=0");

			printLine(output, "FuelRemaining=" + std::to_string(getDataFloat(header, data, "FuelLevel")));

			int compound = getDataInt(header, data, "PlayerTireCompound");

			printLine(output, "TyreCompoundRaw=" + std::to_string((compound == -1) ? 1 : compound + 1));

			printLine(output, "TyrePressure=" +
				std::to_string(GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:LeftFront:LastHotPressure:", "LFpressure"))) + "," +
				std::to_string(GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:RightFront:LastHotPressure:", "RFpressure"))) + "," +
				std::to_string(GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:LeftRear:LastHotPressure:", "LRpressure"))) + "," +
				std::to_string(GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:RightRear:LastHotPressure:", "RRpressure"))));

			printLine(output, "TyreTemperature=" +
				std::to_string(getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:LeftFront:LastTempsOMI:", "LFtempCL", "LFtempCM", "LFtempCR")) + "," +
				std::to_string(getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:RightFront:LastTempsOMI:", "RFtempCL", "RFtempCM", "RFtempCR")) + "," +
				std::to_string(getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:LeftRear:LastTempsOMI:", "LRtempCL", "LRtempCM", "LRtempCR")) + "," +
				std::to_string(getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:RightRear:LastTempsOMI:", "RRtempCL", "RRtempCM", "RRtempCR")));

			printLine(output, "TyreWear=" +
				std::to_string(getTyreWear(header, sessionInfo, data, "LFwearL", "LFwearM", "LFwearR")) + "," +
				std::to_string(getTyreWear(header, sessionInfo, data, "RFwearL", "RFwearM", "RFwearR")) + "," +
				std::to_string(getTyreWear(header, sessionInfo, data, "LRwearL", "LRwearM", "LRwearR")) + "," +
				std::to_string(getTyreWear(header, sessionInfo, data, "RRwearL", "RRwearM", "RRwearR")));

			printLine(output, "[Stint Data]");

			char forName[100];
			char surName[100];
			char nickName[3];

			readDriverInfo(sessionInfo, playerCarIdx, forName, surName, nickName);

			printLine(output, "DriverForname=" + std::string(forName));
			printLine(output, "DriverSurname=" + std::string(surName));
			printLine(output, "DriverNickname=" + std::string(nickName));

			char* trackPositions;

			if (getRawDataValue(trackPositions, header, data, "CarIdxLapDistPct")) 
				printLine(output, "Sector=" + std::to_string((int)min(3, 1 + floor(3 * ((float*)trackPositions)[atoi(playerCarIdx)]))));

			if (getDataValue(result, header, data, "PlayerCarPosition"))
				printLine(output, "Position=" + std::string(result));

			printLine(output, "Laps=" + std::string(itoa(laps, result, 10)));

			bool valid = true;
			
			// if (getDataValue(result, header, data, "LapDeltaToBestLap_OK"))
			//	valid = (atoi(result) > 0);

			if (valid)
				printLine(output, "LapValid=true");
			else
				printLine(output, "LapValid=false");

			printLine(output, "LapLastTime=" + std::to_string(lastTime));
			printLine(output, "LapBestTime=" + std::to_string(bestTime));

			if (getDataValue(result, header, data, "SessionTimeRemain")) {
				float time = atof(result);

				if (time != -1)
					timeRemaining = ((long)time * 1000);
			}

			if (timeRemaining == -1)
				timeRemaining = getRemainingTime(sessionInfo, practice, sessionLaps, sessionTime, laps, lastTime, bestTime);

			printLine(output, "StintTimeRemaining=" + std::to_string(timeRemaining));
			printLine(output, "DriverTimeRemaining=" + std::to_string(timeRemaining));

			if (getDataValue(result, header, data, "CarIdxTrackSurface")) {
				if (atoi(result) == irsdk_InPitStall)
					printLine(output, "InPit=true");
				else
					printLine(output, "InPit=false");
			}
			else
				printLine(output, "InPit=false");

			printLine(output, "[Track Data]");

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackLength:"))
				printLine(output, "Length=" + std::to_string(atof(result) * 1000));

			if (getDataValue(result, header, data, "TrackTemp"))
				printLine(output, "Temperature=" + std::string(result));
			else if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackSurfaceTemp:")) {
				char temperature[10];

				substring((char*)result, temperature, 0, strcspn(result, " "));

				printLine(output, "Temperature" + std::string(temperature));
			}
			else
				printLine(output, "Temperature=24");

			int wetness = irsdk_TrackWetness_Dry;

			if (getDataValue(result, header, data, "TrackWetness"))
				wetness = atoi(result);

			char gripLevel[32] = "Green";

			if (wetness <= irsdk_TrackWetness_MostlyDry) {
				int id = atoi(sessionID);

				while (id >= 0) {
					char session[32];

					if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionTrackRubberState:", itoa(id, session, 10)))
						if (strstr(result, "moderate") || strstr(result, "moderately"))
							strcpy(gripLevel, "Fast");
						else if (strstr(result, "high"))
							strcpy(gripLevel, "Optimum");
						else if (!strstr(result, "carry over"))
							break;

					id -= 1;
				}
			}
			else if (wetness <= irsdk_TrackWetness_VeryLightlyWet)
				strcpy(gripLevel, "Greasy");
			else if (wetness <= irsdk_TrackWetness_LightlyWet)
				strcpy(gripLevel, "Damp");
			else if (wetness <= irsdk_TrackWetness_VeryWet)
				strcpy(gripLevel, "Wet");
			else if (wetness <= irsdk_TrackWetness_ExtremelyWet)
				strcpy(gripLevel, "Flooded");

			printLine(output, "Grip=" + std::string(gripLevel));

			for (int i = 1; ; i++) {
				char posIdx[10];
				char carIdx[10];

				itoa(i, posIdx, 10);

				if (getYamlValue(carIdx, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:Position:{%s}CarIdx:", sessionID, posIdx)) {
					int carIndex = atoi(carIdx);
					float coordinateX;
					float coordinateY;

					if (getCarCoordinates(header, data, carIndex, coordinateX, coordinateY)) {
						char carIdx1[10];

						itoa(carIndex + 1, carIdx1, 10);

						printLine(output, "Car." + std::string(carIdx1) + ".Position=" + std::to_string(coordinateX) + "," + std::to_string(coordinateY));
					}
				}
				else
					break;
			}

			printLine(output, "[Weather Data]");

			if (getDataValue(result, header, data, "AirTemp"))
				printLine(output, "Temperature=" + std::string(result));
			else if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackAirTemp:")) {
				char temperature[10];

				substring((char*)result, temperature, 0, strcspn(result, " "));

				printLine(output, "Temperature=" + std::string(temperature));
			}
			else
				printLine(output, "Temperature=24");

			const char* weather = getWeather(getDataFloat(header, data, "Precipitation"));
			
			printLine(output, "Weather=" + std::string(weather));
			printLine(output, "Weather10Min=" + std::string(weather));
			printLine(output, "Weather30Min=" + std::string(weather));

			printLine(output, "[Test Data]");
			
			int id = atoi(sessionID);

			printLine(output, "Driver.Car=" + std::string(playerCarIdx));

			while (id >= 0) {
				char session[32];

				if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionTrackRubberState:", itoa(id, session, 10)))
					printLine(output, "Session " + std::to_string(id) + " Track Grip=" + std::string(result));

				id -= 1;
			}

			printLine(output, "Pit TP FL=" + std::to_string(GetPsi(getDataFloat(header, data, "PitSvLFP"))));
			printLine(output, "Pit TP FR=" + std::to_string(GetPsi(getDataFloat(header, data, "PitSvRFP"))));
			printLine(output, "Pit TP RL=" + std::to_string(GetPsi(getDataFloat(header, data, "PitSvLRP"))));
			printLine(output, "Pit TP RR=" + std::to_string(GetPsi(getDataFloat(header, data, "PitSvRRP"))));
		}
	}
}

void loadTrackCoordinates(const char* fileName) {
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

std::string getArgument(std::string request, std::string key) {
	if (request.rfind(key + "=") == 0)
		return request.substr(key.length() + 1, request.length() - (key.length() + 1)).c_str();
	else
		return "";
}

std::string getArgument(char* request, std::string key) {
	return getArgument(std::string(request), key);
}

extern "C" __declspec(dllexport) int __stdcall open() {
	// bump priority up so we get time from the sim
	SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);

	// ask for 1ms timer so sleeps are more precise
	timeBeginPeriod(1);

	return 0;
}

extern "C" __declspec(dllexport) int __stdcall close() {
	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

extern "C" __declspec(dllexport) int __stdcall call(char* request, char* result, int size)
{
	std::string argument = getArgument(request, "Track");

	if (argument != "") {
		loadTrackCoordinates(argument.c_str());

		hasTrackCoordinates = true;
	}

	std::ostringstream output;
	g_data = NULL;
	int tries = 3;

	output << "[Debug]" << std::endl;
	output << "Request=" << request << std::endl;
	output << "Standings=" << getArgument(request, "Standings") << std::endl;
	output << "Setup=" << getArgument(request, "Setup") << std::endl;
	output << "Track=" << getArgument(request, "Track") << std::endl;

	while (tries-- > 0) {
		// wait for new data and copy it into the g_data buffer, if g_data is not null
		if (irsdk_waitForDataReady(TIMEOUT, g_data)) {
			const irsdk_header* pHeader = irsdk_getHeader();

			if (pHeader)
			{
				if (!g_data || g_nData != pHeader->bufLen)
				{
					// realocate our g_data buffer to fit, and lookup some data offsets
					initData(pHeader, g_data, g_nData);

					continue;
				}

				argument = getArgument(request, "Pitstop");

				if (argument != "") {
					argument = getArgument(argument, "Set");

					if (argument != "")
						pitstopSetValues(pHeader, g_data, argument.c_str());
					else {
						argument = getArgument(getArgument(request, "Pitstop"), "Change");

						if (argument != "")
							pitstopChangeValues(pHeader, g_data, argument.c_str());
					}
				}
				else {
					output << "[Debug]" << std::endl;
					
					if (getArgument(request, "Setup") != "") {
						output << "Action=Setup" << std::endl;
						writeData(&output, pHeader, g_data, true);
					}
					else {
						if (getArgument(request, "Standings") != "") {
							output << "Action=Standings" << std::endl;
							writePositions(&output, pHeader, g_data);
						}
						else {
							output << "Action=Telemetry" << std::endl;
							writeData(&output, pHeader, g_data, false);
						}
					}
				}

				break;
			}
		}
	}

	if ((tries == 0) || (g_data == NULL)) {
		output << "[Session Data]" << std::endl;
		output << "Active=false" << std::endl;
	}

	strcpy_s(result, size, output.str().c_str());

	return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}