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

long getRemainingTime(const char* sessionInfo, int sessionLaps, long sessionTime, int lap, long lastTime);

long getRemainingLaps(const char* sessionInfo, int sessionLaps, long sessionTime, int lap, long lastTime) {
	char result[100];

	if (lap < 1)
		return 0;

	if (sessionLaps > 0)
		return (long)(sessionLaps - lap);
	else if (lastTime > 0)
		return (long)(getRemainingTime(sessionInfo, sessionLaps, sessionTime, lap, lastTime) / lastTime);
	else
		return 0;
}

long getRemainingTime(const char* sessionInfo, int sessionLaps, long sessionTime, int lap, long lastTime) {
	if (lap < 1)
		return max(0, sessionTime);

	if (sessionLaps == -1)
		return (sessionTime - (lastTime * lap));
	else
		return (getRemainingLaps(sessionInfo, sessionLaps, sessionTime, lap, lastTime) * lastTime);
}

void printDataValue(const irsdk_header* header, const char* data, const irsdk_varHeader* rec) {
	if (header && data) {
		int count = rec->count;

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
				printf(", ");
		}
	}
}

void printDataValue(const irsdk_header* header, const char* data, const char* variable) {
	if (header && data) {
		for (int i = 0; i < header->numVars; i++) {
			const irsdk_varHeader* rec = irsdk_getVarHeaderEntry(i);

			if (strcmp(rec->name, variable) == 0) {
				printDataValue(header, data, rec);

				break;
			}
		}
	}
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

float getTyreTemperature(const irsdk_header* header, const char* sessionInfo, const char* data, char* sessionPath,
						 char* dataVariableO, char* dataVariableM, char* dataVariableI) {
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

float getTyrePressure(const irsdk_header* header, const char* sessionInfo, const char* data, char* sessionPath, char* dataVariable) {
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

void pitstopSetValues(const irsdk_header* header, const char* data, char* arguments) {
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

void changePitstopTyrePressure(const irsdk_header* header, int command, char* serviceFlag, float pressureDelta) {
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

void changePitstopTyrePressure(const irsdk_header* header, char* tyre, float pressureDelta) {
	if (strcmp(tyre, "FL") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_LF, "PitSvLFP", pressureDelta);
	else if (strcmp(tyre, "FR") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_RF, "PitSvRFP", pressureDelta);
	else if (strcmp(tyre, "RL") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_LR, "PitSvLRP", pressureDelta);
	else if (strcmp(tyre, "RR") == 0)
		changePitstopTyrePressure(header, irsdk_PitCommand_RR, "PitSvRRP", pressureDelta);
}

void pitstopChangeValues(const irsdk_header* header, const char* data, char* arguments) {
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

void writeStandings(const irsdk_header *header, const char* data)
{
	if (header && data)
	{
		const char* sessionInfo = irsdk_getSessionInfoStr();
		char playerCarIdx[10] = "";
		char sessionID[10] = "";

		getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");

		itoa(getCurrentSessionID(sessionInfo), sessionID, 10);

		char result[100];

		printf("[Position Data]\n");
		
		printf("Driver.Car=%s\n", playerCarIdx);
		
		for (int i = 1; ; i++) {
			char posIdx[10];
			char carIdx[10];
			
			itoa(i, posIdx, 10);
			
			if (getYamlValue(carIdx, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:Position:{%s}Position:", sessionID, posIdx)) {
				printf("Car.%s.Position=%s\n", carIdx, posIdx);

				getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LapsComplete:", sessionID, carIdx);

				printf("Car.%s.Lap=%s\n", carIdx, result);

				getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}LastTime:", sessionID, carIdx);
				
				printf("Car.%s.Time=%ld\n", carIdx, (long)(normalize(atof(result)) * 1000));

				getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}ResultsPositions:CarIdx:{%s}Time:", sessionID, carIdx);

				printf("Car.%s.Time.Running=%ld\n", carIdx, (long)(normalize(atof(result)) * 1000));

				getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarScreenName:", carIdx);
				
				printf("Car.%s.Car=%s\n", carIdx, result);

				char forName[100];
				char surName[100];
				char nickName[3];

				readDriverInfo(sessionInfo, carIdx, forName, surName, nickName);

				printf("Car.%s.Driver.Forname=%s\n", carIdx, forName);
				printf("Car.%s.Driver.Surname=%s\n", carIdx, surName);
				printf("Car.%s.Driver.Nickname=%s\n", carIdx, nickName);
			}
			else {
				printf("Car.Count=%s\n", posIdx);
				
				break;
			}
		}
	}
}

void writeData(const irsdk_header *header, const char* data, bool setupOnly)
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

		if (setupOnly) {
			printf("[Setup Data]\n");

			printf("TyreCompound=Dry\n");
			printf("TyreCompoundColor=Black\n");
			printf("TyreSet=1\n");

			printf("TyrePressure = %f, %f, %f, %f\n",
				GetPsi(getDataFloat(header, data, "LFcoldPressure")),
				GetPsi(getDataFloat(header, data, "RFcoldPressure")),
				GetPsi(getDataFloat(header, data, "LRcoldPressure")),
				GetPsi(getDataFloat(header, data, "RRcoldPressure")));
		}
		else {
			printf("[Session Data]\n");

			printf("Active=true\n");
			printf("Paused=false\n"); // Not yet implemented

			if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionType:", sessionID)) {
				if (strstr(result, "Practice"))
					printf("Session=Practice\n");
				else if (strstr(result, "Qualify"))
					printf("Session=Qualification\n");
				else if (strstr(result, "Race"))
					printf("Session=Race\n");
				else
					printf("Session=Other\n");
			}
			else
				printf("Session=Other\n");

			printf("FuelAmount=%f\n", maxFuel);

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackName:"))
				printf("Track=%s\n", result);
			else
				printf("Track=Unknown\n");

			if (getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarScreenName:", playerCarIdx))
				printf("Car=%s\n", result);
			else
				printf("Car=Unknown\n");

			printf("SessionFormat=%s\n", (sessionLaps == -1) ? "Time" : "Lap");

			long timeRemaining = -1;
			
			if (getDataValue(result, header, data, "SessionTimeRemain")) {
				float time = atof(result);

				if (time != -1)
					timeRemaining = ((long)time * 1000);
			}

			if (timeRemaining == -1)
				timeRemaining = getRemainingTime(sessionInfo, sessionLaps, sessionTime, laps, lastTime);

			printf("SessionTimeRemaining=%ld\n", timeRemaining);

			long lapsRemaining = -1;
			
			timeRemaining = -1;

			if (getDataValue(result, header, data, "SessionLapsRemain"))
				lapsRemaining = atoi(result);

			if ((lapsRemaining == -1) || (lapsRemaining == 32767)) {
				long estTime = lastTime;

				if ((estTime == 0) && getYamlValue(result, sessionInfo, "DriverInfo:DriverCarEstLapTime:"))
					estTime = (long)(atof(result) * 1000);

				lapsRemaining = getRemainingLaps(sessionInfo, sessionLaps, sessionTime, laps, estTime);
			}

			printf("SessionLapsRemaining=%ld\n", lapsRemaining);

			printf("[Car Data]\n");

			printf("BodyworkDamage=0,0,0,0,0\n");
			printf("SuspensionDamage=0,0,0,0\n");

			printf("FuelRemaining=%f\n", getDataFloat(header, data, "FuelLevel"));

			printf("TyreCompound=Dry\n");
			printf("TyreCompoundColor=Black\n");

			printf("TyrePressure = %f, %f, %f, %f\n",
				GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:LeftFront:LastHotPressure:", "LFpressure")),
				GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:RightFront:LastHotPressure:", "RFpressure")),
				GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:LeftRear:LastHotPressure:", "LRpressure")),
				GetPsi(getTyrePressure(header, sessionInfo, data, "CarSetup:Suspension:RightRear:LastHotPressure:", "RRpressure")));

			printf("TyreTemperature = %f, %f, %f, %f\n",
				getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:LeftFront:LastTempsOMI:", "LFtempCL", "LFtempCM", "LFtempCR"),
				getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:RightFront:LastTempsOMI:", "RFtempCL", "RFtempCM", "RFtempCR"),
				getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:LeftRear:LastTempsOMI:", "LRtempCL", "LRtempCM", "LRtempCR"),
				getTyreTemperature(header, sessionInfo, data, "CarSetup:Suspension:RightRear:LastTempsOMI:", "RRtempCL", "RRtempCM", "RRtempCR"));

			printf("[Stint Data]\n");
			
			char forName[100];
			char surName[100];
			char nickName[3];
				
			readDriverInfo(sessionInfo, playerCarIdx, forName, surName, nickName);

			printf("DriverForname=%s\n", forName);
			printf("DriverSurname=%s\n", surName);
			printf("DriverNickname=%s\n", nickName);

			printf("Laps=%s\n", itoa(laps, result, 10));

			printf("LapLastTime=%ld\n", lastTime);
			printf("LapBestTime=%ld\n", bestTime);

			if (getDataValue(result, header, data, "SessionTimeRemain")) {
				float time = atof(result);

				if (time != -1)
					timeRemaining = ((long)time * 1000);
			}

			if (timeRemaining == -1)
				timeRemaining = getRemainingTime(sessionInfo, sessionLaps, sessionTime, laps, lastTime);

			printf("StintTimeRemaining=%ld\n", timeRemaining);
			printf("DriverTimeRemaining=%ld\n", timeRemaining);

			if (getDataValue(result, header, data, "CarIdxTrackSurface"))
				printf("InPit=%s\n", (atoi(result) == irsdk_InPitStall) ? "true" : "false");
			else
				printf("InPit=false\n");

			printf("[Track Data]\n");

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackSurfaceTemp:")) {
				char temperature[10];

				substring((char*)result, temperature, 0, strcspn(result, " "));

				printf("Temperature=%s\n", temperature);
			}
			else
				printf("Temperature=24\n");

			char gripLevel[32] = "Green";

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

			printf("Grip=%s\n", gripLevel);

			printf("[Weather Data]\n");

			if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackAirTemp:")) {
				char temperature[10];

				substring((char*)result, temperature, 0, strcspn(result, " "));

				printf("Temperature=%s\n", temperature);
			}
			else
				printf("Temperature=24\n");

			printf("Weather=Dry\n");
			printf("Weather10Min=Dry\n");
			printf("Weather30Min=Dry\n");

			printf("[Test Data]\n");
			
			id = atoi(sessionID);

			while (id >= 0) {
				char session[32];

				if (getYamlValue(result, sessionInfo, "SessionInfo:Sessions:SessionNum:{%s}SessionTrackRubberState:", itoa(id, session, 10)))
					printf("Session %d Track Grip=%s\n", id, result);

				id -= 1;
			}

			printf("Pit TP FL=%f\n", GetPsi(getDataFloat(header, data, "PitSvLFP")));
			printf("Pit TP FR=%f\n", GetPsi(getDataFloat(header, data, "PitSvRFP")));
			printf("Pit TP RL=%f\n", GetPsi(getDataFloat(header, data, "PitSvLRP")));
			printf("Pit TP RR=%f\n", GetPsi(getDataFloat(header, data, "PitSvRRP")));
		}

		if (false) {
			printf("\n[Debug Session Info]\n");
			printf("%s", sessionInfo);
			printf("\n");
			printf("[Debug Variables]\n");
			dumpDataToDisplay(header, data);
			printf("\n");
		}
	}
}

int main(int argc, char* argv[])
{
	// bump priority up so we get time from the sim
	SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);

	// ask for 1ms timer so sleeps are more precise
	timeBeginPeriod(1);

	g_data = NULL;
	int tries = 3;

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

				if ((argc > 2) && (strcmp(argv[1], "-Pitstop") == 0)) {
					if (strcmp(argv[2], "Set") == 0)
						pitstopSetValues(pHeader, g_data, argv[3]);
					else if (strcmp(argv[2], "Change") == 0)
						pitstopChangeValues(pHeader, g_data, argv[3]);
				}
				else if ((argc > 0) && (strcmp(argv[1], "-Standings") == 0)) {
					writeStandings(pHeader, g_data);
				}
				else
					writeData(pHeader, g_data, ((argc == 2) && (strcmp(argv[1], "-Setup") == 0)));

				break;
			}
		}
	}

	if ((tries == 0) || (g_data == NULL)) {
		printf("[Session Data]\n");
		printf("Active=false\n");
	}
	
	irsdk_shutdown();
	timeEndPeriod(1);

	return 0;
}

