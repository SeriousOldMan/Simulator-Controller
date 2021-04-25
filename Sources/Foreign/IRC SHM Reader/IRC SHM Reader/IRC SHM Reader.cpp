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

// 16 ms timeout
#define TIMEOUT 16

char *g_data = NULL;
int g_nData = 0;

const char g_playerInCarString[] = "IsOnTrack";
int g_playerInCarOffset = -1;

const char g_sessionTimeString[] = "SessionTime";
int g_sessionTimeOffset = -1;

const char g_lapIndexString[] = "Lap";
int g_lapIndexOffset = -1;


// place holders for variables that need to be updated in the header of our CSV file
double startTime;
long int startTimeOffset;

double endTime;
long int endTimeOffset;

int lastLap;
int lapCount;
long int lapCountOffset;

inline double normalize(double value) {
	return (value < 0) ? 0.0 : value;
}

inline double normalizeDamage(double value) {
	if (value < 0)
		return 0.0;
	else
		return ((1.0 - value) * 100);
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

/*
long getRemainingTime();

long getRemainingLaps() {
	if (map_buffer->session_iteration < 1)
		return 0;

	if (map_buffer->session_length_format == R3E_SESSION_LENGTH_LAP_BASED) {
		return (long)(map_buffer->race_session_laps[map_buffer->session_iteration - 1] - normalize(map_buffer->completed_laps));
	}
	else {
		long time = (long)map_buffer->lap_time_previous_self;

		if (time > 0)
			return (long)(getRemainingTime() / time);
		else
			return 0;
	}
}

long getRemainingTime() {
	if (map_buffer->session_iteration < 1)
		return 0;

	if (map_buffer->session_length_format != R3E_SESSION_LENGTH_LAP_BASED) {
		return (long)((map_buffer->race_session_minutes[map_buffer->session_iteration - 1] * 60) -
			(normalize(map_buffer->lap_time_previous_self) * normalize(map_buffer->completed_laps)));
	}
	else {
		return (long)(getRemainingLaps() * map_buffer->lap_time_previous_self);
	}
}
*/

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

void logHeaderToDisplay(const irsdk_header *header)
{
	if(header)
	{
		const char* sessionInfo = irsdk_getSessionInfoStr();
		char playerCarIdx[10] = "";

		char result[100];

		printf("[Session Data]\n");

		getYamlValue(playerCarIdx, sessionInfo, "DriverInfo:DriverCarIdx:");

		if (getYamlValue(result, sessionInfo, "DriverInfo:DriverCarFuelMaxLtr:"))
			printf("FuelAmount=%s\n", result);
		else
			printf("FuelAmount=%s\n", "0");

		if (getYamlValue(result, sessionInfo, "WeekendInfo:TrackName:"))
			printf("Track=%s\n", result);
		else
			printf("Track=Unknown\n");

		if (getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}CarScreenName:", playerCarIdx))
			printf("Car=%s\n", result);
		else
			printf("Car=Unknown\n");

		if (getYamlValue(result, sessionInfo, "SessionInfo:SessionNum:{0}SessionLaps:")) { // Not yet implemented - {0}
			if (strcmp(result, "unlimited"))
				printf("SessionFormat=Time\n", 0);
			else
				printf("SessionFormat=Lap\n", 0);
		}
		else
			printf("SessionFormat=Time\n", 0);

		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			const char* name = rec->name;

			if (strcmp(name, "TrackName") == 0)
				printf("Track=%s\n", rec->desc);
		}

		printf("[Car Data]\n");



		printf("[Stint Data]\n");
		printf("Active=true\n");
		printf("Paused=false\n"); // Not yet implemented

		if (getYamlValue(result, sessionInfo, "SessionInfo:SessionNum:{0}SessionType:")) { // Not yet implemented - {0}
			if (strcmp(result, "RACE") == 0) // Not yet implemented
				printf("Session=Race\n");
			else
				printf("Session=Other\n");
		}
		else
			printf("Session=Other\n");
		
		if (getYamlValue(result, sessionInfo, "DriverInfo:Drivers:CarIdx:{%s}UserName:", playerCarIdx)) {
			char forName[100];
			char surName[100];
			char nickName[3];

			size_t length = strcspn(result, " ");

			substring((char*)result, forName, 0, length);
			substring((char*)result, surName, length + 1, strlen(result) - length - 1);
			nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

			printf("DriverForname=%s\n", forName);
			printf("DriverSurname=%s\n", surName);
			printf("DriverNickname=%s\n", nickName);
		}
		else {
			printf("DriverForname=John\n");
			printf("DriverSurname=Doe\n");
			printf("DriverNickname=JD\n");
		}

		if (getYamlValue(result, sessionInfo, "SessionInfo:ResultsPositions:CarIdx:{0}LastTime:", playerCarIdx)) {
			float time;

			sscanf(result, "%f", &time);

			printf("LapLastTime=%d\n", (long)(time * 1000));
		}
		else
			printf("LapLastTime=0\n");

		if (getYamlValue(result, sessionInfo, "SessionInfo:ResultsPositions:CarIdx:{0}FastestTime:", playerCarIdx)) {
			float time;

			sscanf(result, "%f", &time);

			printf("LapBestTime=%ld\n", (long)(time * 1000));
		}
		else
			printf("LapBestTime=0\n");

		printf("[Debug]\n");
		printf("%s", sessionInfo);
	}
}

void logDataToDisplay(const irsdk_header *header, const char *data)
{
	if(header && data)
	{
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);

			printf("%s[", rec->name);

			// only dump the first 4 entrys in an array to save space
			// for now ony carsTrkPct and carsTrkLoc output more than 4 entrys
			int count = 1;
			if(rec->type != irsdk_char)
				count = min(4, rec->count);

			for(int j=0; j<count; j++)
			{
				switch(rec->type)
				{
				case irsdk_char:
					printf("%s", (char *)(data+rec->offset) ); break;
				case irsdk_bool:
					printf("%d", ((bool *)(data+rec->offset))[j] ); break;
				case irsdk_int:
					printf("%d", ((int *)(data+rec->offset))[j] ); break;
				case irsdk_bitField:
					printf("0x%08x", ((int *)(data+rec->offset))[j] ); break;
				case irsdk_float:
					printf("%0.2f", ((float *)(data+rec->offset))[j] ); break;
				case irsdk_double:
					printf("%0.2f", ((double *)(data+rec->offset))[j] ); break;
				}

				if(j+1 < count)
					printf("; ");
			}
			if(rec->type != irsdk_char && count < rec->count)
				printf("; ...");

			printf("]");

			if((i+1) < header->numVars)
				printf(", ");
		}
		printf("\n\n");
	}
}

void initData(const irsdk_header *header, char* &data, int &nData)
{
	if(data) delete [] data;
	nData = header->bufLen;
	data = new char[nData];

	// grab the memory offset to the playerInCar flag
	g_playerInCarOffset = irsdk_varNameToOffset(g_playerInCarString);
	g_sessionTimeOffset = irsdk_varNameToOffset(g_sessionTimeString);
	g_lapIndexOffset = irsdk_varNameToOffset(g_lapIndexString);

	const char *valstr;
	int valstrlen; 
	const char g_playerCarIdxPath[] = "DriverInfo:DriverCarIdx:";
	int playerCarIdx = -1;
	
	if(parseYaml(irsdk_getSessionInfoStr(), g_playerCarIdxPath, &valstr, &valstrlen))
		playerCarIdx = atoi(valstr);


}

void end_session(bool shutdown)
{
	if(g_data)
		delete[] g_data;
	g_data = NULL;

	if(shutdown)
	{
		irsdk_shutdown();
		timeEndPeriod(1);
	}
}

int main()
{
	// bump priority up so we get time from the sim
	SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);

	// ask for 1ms timer so sleeps are more precise
	timeBeginPeriod(1);
	g_data = NULL;
	g_nData = 0;
	
	// wait for new data and copy it into the g_data buffer, if g_data is not null
	if(irsdk_waitForDataReady(TIMEOUT, g_data))
	{
		const irsdk_header *pHeader = irsdk_getHeader();
		if(pHeader)
		{
			initData(pHeader, g_data, g_nData);

			logHeaderToDisplay(pHeader);
			
			// logDataToDisplay(pHeader, g_data);
		}
		else {
			printf("[Stint Data]\n");
			printf("Active=false\n");
		}
	}
	else {
		printf("[Stint Data]\n");
		printf("Active=false\n");
	}
	
	end_session(true);

	return 0;
}

