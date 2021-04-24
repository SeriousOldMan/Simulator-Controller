/*
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

// Simple demo that reads iracing telemetry data and writes it to a file

//------

// Uncomment to log data to display
//#define LOG_TO_DISPLAY

// Uncomment to log to ascii CSV format instead of binary IBT format
//#define LOG_TO_CSV

// Uncomment to log only when driver in car
//#define LOG_IN_CAR_ONLY

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
time_t g_ttime;
FILE *g_file = NULL;

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

int recordCount;
long int recordCountOffset;

// place holders for data that needs to be updated in our IBT file
irsdk_header g_diskHeader;
irsdk_diskSubHeader g_diskSubHeader;
int g_diskSubHeaderOffset = 0;
int g_diskLastLap = -1;


// open a file for writing, without overwriting any existing files
FILE *openUniqueFile(const char *name, const char *ext, time_t t_time, bool asBinary)
{
	FILE *file = NULL;
	char tstr[MAX_PATH] = "";
	int i = 0;

	// find an unused filename
	do
	{
		if(file)
			fclose(file);

		_snprintf(tstr, MAX_PATH, "%s", name);
		tstr[MAX_PATH-1] = '\0';

		tm tm_time;
		localtime_s(&tm_time, &t_time);
		strftime(tstr+strlen(tstr), MAX_PATH-strlen(tstr), " %Y-%m-%d %H-%M-%S", &tm_time);
		tstr[MAX_PATH-1] = '\0';

		if(i > 0)
		{
			_snprintf(tstr+strlen(tstr), MAX_PATH-strlen(tstr), " %02d", i, ext);
			tstr[MAX_PATH-1] = '\0';
		}

		_snprintf(tstr+strlen(tstr), MAX_PATH-strlen(tstr), ".%s", ext);
		tstr[MAX_PATH-1] = '\0';

		file = fopen(tstr, "r");
	}
	while(file && ++i < 100);

	// failed to find an unused file
	if(file)
	{
		fclose(file);
		return NULL;
	}

	if(asBinary)
		return fopen(tstr, "wb");
	else
		return fopen(tstr, "w");
}

void writeSessionItem(FILE *file, const char *path, const char *desc)
{
	const char *valstr;
	int valstrlen; 

	fprintf(file, desc);
	if(parseYaml(irsdk_getSessionInfoStr(), path, &valstr, &valstrlen))
		fwrite(valstr, 1, valstrlen, file);
	fprintf(file, "\n");
}

static const int reserveCount = 32;
// reserve a little space in the file for a number to be written
long int fileReserveSpace(FILE *file)
{
	long int pos = ftell(file);

	int count = reserveCount;
	while(count--)
		fputc(' ', file);
	fputs("\n", file);

	return pos;
}

// fill in a number in our reserved space, without overwriting the newline
void fileWriteReservedInt(FILE *file, long int pos, int value)
{
	long int curpos = ftell(file);

	fseek(file, pos, SEEK_SET);
	fprintf(file, "%d", value);

	fseek(file, curpos, SEEK_SET);
}

void fileWriteReservedFloat(FILE *file, long int pos, double value)
{
	long int curpos = ftell(file);

	fseek(file, pos, SEEK_SET);
	fprintf(file, "%f", value);

	fseek(file, curpos, SEEK_SET);
}

// log header to ibt binary format
void logHeaderToIBT(const irsdk_header *header, FILE *file, time_t t_time)
{
	if(header && file)
	{
		int offset = 0;

		// main header
		memcpy(&g_diskHeader, header, sizeof(g_diskHeader));
		offset += sizeof(g_diskHeader);

		// sub header is written out at end of session
		memset(&g_diskSubHeader, 0, sizeof(g_diskSubHeader));
		g_diskSubHeader.sessionStartDate = t_time;
		g_diskSubHeaderOffset = offset;
		offset += sizeof(g_diskSubHeader);

		// pointer to var definitions
		g_diskHeader.varHeaderOffset = offset;
		offset += g_diskHeader.numVars * sizeof(irsdk_varHeader);

		// pointer to session info string
		g_diskHeader.sessionInfoOffset = offset;
		offset += g_diskHeader.sessionInfoLen;

		// pointer to start of buffered data
		g_diskHeader.numBuf = 1;
		g_diskHeader.varBuf[0].bufOffset = offset;

		fwrite(&g_diskHeader, 1, sizeof(g_diskHeader), file);
		fwrite(&g_diskSubHeader, 1, sizeof(g_diskSubHeader), file);
		fwrite(irsdk_getVarHeaderPtr(), 1, g_diskHeader.numVars * sizeof(irsdk_varHeader), file);
		fwrite(irsdk_getSessionInfoStr(), 1, g_diskHeader.sessionInfoLen, file);

		if(ftell(file) != g_diskHeader.varBuf[0].bufOffset)
			printf("ERROR: file pointer mismach: %d != %d\n", ftell(file), g_diskHeader.varBuf[0].bufOffset);
	}
}

void logDataToIBT(const irsdk_header *header, const char *data, FILE *file)
{
	// write data to disk, and update irsdk_diskSubHeader in memory
	if(header && data && file)
	{
		fwrite(data, 1, g_diskHeader.bufLen, file);
		g_diskSubHeader.sessionRecordCount++;

		if(g_sessionTimeOffset >= 0)
		{
			double time = *((double *)(data+g_sessionTimeOffset));
			if(g_diskSubHeader.sessionRecordCount == 1)
			{
				g_diskSubHeader.sessionStartTime = time;
				g_diskSubHeader.sessionEndTime = time;
			}

			if(g_diskSubHeader.sessionEndTime < time)
				g_diskSubHeader.sessionEndTime = time;
		}

		if(g_lapIndexOffset >= 0)
		{
			int lap = *((int *)(data+g_lapIndexOffset));

			if(g_diskSubHeader.sessionRecordCount == 1)
				g_diskLastLap = lap-1;

			if(g_diskLastLap < lap)
			{
				g_diskSubHeader.sessionLapCount++;
				g_diskLastLap = lap;
			}
		}
	}
}

void logCloseIBT(FILE *file)
{
	if(file)
	{
		fseek(file, g_diskSubHeaderOffset, SEEK_SET);
		fwrite(&g_diskSubHeader, 1, sizeof(g_diskSubHeader), file);
	}
}

// dump data in CSV format
void logHeaderToCSV(const irsdk_header *header, FILE *file, time_t t_time)
{
	if(header && file)
	{
		// remove trailing ... from string
		const char *sessionStr = irsdk_getSessionInfoStr();
		int len = strlen(sessionStr);
		const char *pStr = strstr(sessionStr, "...");
		if(pStr)
			len = pStr - sessionStr;

		// and write the whole thing out
		fwrite(sessionStr, 1, len,  file);

		// reserve space for entrys that will be filled in later
		fprintf(file, "SessionLogInfo:\n");

		// get file open time as a string
		char tstr[512];
		tm tm_time;
		localtime_s(&tm_time, &t_time);
		strftime(tstr, 512, " %Y-%m-%d %H:%M:%S", &tm_time);
		tstr[512-1] = '\0';
		fprintf(file, " SessionStartDate: %s\n", tstr);

		fprintf(file, " SessionStartTime: ");
		startTimeOffset = fileReserveSpace(file);
		startTime = -1.0;

		fprintf(file, " SessionEndTime: ");
		endTimeOffset = fileReserveSpace(file);
		endTime = -1.0;

		fprintf(file, " SessionLapCount: ");
		lapCountOffset = fileReserveSpace(file);
		lapCount = 0;
		lastLap = -1;

		fprintf(file, " SessionRecordCount: ");
		recordCountOffset = fileReserveSpace(file);
		recordCount = 0;

		fprintf(file, "...\n");

		// dump the var names
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			int count = (rec->type == irsdk_char) ? 1 : rec->count;

			for(int j=0; j<count; j++)
			{
				if((i+j) > 0)
					fputs(", ", file);

				if(count>1)
					fprintf(file, "%s_%02d", rec->name, j);
				else
					fputs(rec->name, file);
			}
		}
		fprintf(file, "\n");

		// dump the var descriptions
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			int count = (rec->type == irsdk_char) ? 1 : rec->count;

			for(int j=0; j<count; j++)
			{
				if((i+j) > 0)
					fputs(", ", file);

				fputs(rec->desc, file);
			}
		}
		fprintf(file, "\n");

		// dump the var units
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			int count = (rec->type == irsdk_char) ? 1 : rec->count;

			for(int j=0; j<count; j++)
			{
				if((i+j) > 0)
					fputs(", ", file);

				fputs(rec->unit, file);
			}
		}
		fprintf(file, "\n");

		// dump the var data type
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			int count = (rec->type == irsdk_char) ? 1 : rec->count;

			for(int j=0; j<count; j++)
			{
				if((i+j) > 0)
					fputs(", ", file);

				switch(rec->type)
				{
				case irsdk_char: fputs("string", file); break;
				case irsdk_bool: fputs("boolean", file); break;
				case irsdk_int: fputs("integer", file); break;
				case irsdk_bitField: fputs("bitfield", file); break;
				case irsdk_float: fputs("float", file); break;
				case irsdk_double: fputs("double", file); break;
				default: fputs("unknown", file); break;
				}
			}
		}
		fprintf(file, "\n");
	}
}

void logStateToFile(time_t t_time)
{
	if(irsdk_getSessionInfoStr())
	{
		FILE *file = openUniqueFile("irsdk_session", "txt", t_time, false);
		if(file)
		{
			// dump session information to disk
			fputs(irsdk_getSessionInfoStr(), file);
			fclose(file);
		}
	}
}

void logDataToCSV(const irsdk_header *header, const char *data, FILE *file)
{
	if(header && data && file)
	{
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			int count = (rec->type == irsdk_char) ? 1 : rec->count;

			for(int j=0; j<count; j++)
			{
				if((i+j) > 0)
					fputs(", ", file);

				// write each entry out
				switch(rec->type)
				{
				case irsdk_char:
					fprintf(file, "%s", (char *)(data+rec->offset) ); break;
				case irsdk_bool:
					fprintf(file, "%d", ((bool *)(data+rec->offset))[j]); break;
				case irsdk_int:
					fprintf(file, "%d", ((int *)(data+rec->offset))[j]); break;
				case irsdk_bitField:
					fprintf(file, "%d", ((int *)(data+rec->offset))[j]); break;
				case irsdk_float:
					fprintf(file, "%g", ((float *)(data+rec->offset))[j]); break;
				case irsdk_double:
					fprintf(file, "%g", ((double *)(data+rec->offset))[j]); break;
				}
			}
		}
		fprintf(file, "\n");

		// update our session counters
		if(g_sessionTimeOffset >= 0)
		{
			double time = *((double *)(data+g_sessionTimeOffset));
			if(startTime < 0.0)
			{
				startTime = time;
				endTime = time;
				fileWriteReservedFloat(file, startTimeOffset, startTime); // move these to close?
				fileWriteReservedFloat(file, endTimeOffset, endTime);
			}
			if(endTime < time)
			{
				endTime = time;
				fileWriteReservedFloat(file, endTimeOffset, endTime);
			}
		}
		if(g_lapIndexOffset >= 0)
		{
			int lap = *((int *)(data+g_lapIndexOffset));
			if(lastLap < lap)
			{
				lapCount++;
				lastLap = lap;
				fileWriteReservedInt(file, lapCountOffset, lapCount);
			}
		}

		recordCount++;
		fileWriteReservedInt(file, recordCountOffset, recordCount);
	}
}

// dump data to display, for debugging
void logHeaderToDisplay(const irsdk_header *header)
{
	if(header)
	{
		printf("\n\nSession Info String:\n\n");

		// puts is safer in case the string contains '%' characters
		puts(irsdk_getSessionInfoStr());

		printf("\n\nVariable Headers:\n\n");
		for(int i=0; i<header->numVars; i++)
		{
			const irsdk_varHeader *rec = irsdk_getVarHeaderEntry(i);
			printf("%s, %s, %s\n", rec->name, rec->desc, rec->unit);
		}
		printf("\n\n");
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

	// get the playerCarIdx
	//const char *valstr;
	//int valstrlen; 
	//const char g_playerCarIdxPath[] = "DriverInfo:DriverCarIdx:";
	//playerCarIdx = -1;
	//if(parseYaml(irsdk_getSessionInfoStr(), g_playerCarIdxPath, &valstr, &valstrlen))
	//	playerCarIdx = atoi(valstr);
}

bool canLogToFile(const irsdk_header *header, const char *data)
{
	(void)header;
	(void)data;
	return 
#ifdef LOG_IN_CAR_ONLY
		// only log if driver in car...
		(g_playerInCarOffset < 0 || *((bool *)(data+g_playerInCarOffset)));
#else 
		true;
#endif
}

bool open_file(FILE* &file, time_t &t_time)
{
	// get current time
	t_time = time(NULL);
#ifdef LOG_TO_CSV
	file = openUniqueFile("irsdk_session", "csv", t_time, false);
#else
	file = openUniqueFile("irsdk_session", "ibt", t_time, true);
#endif

	if(file)
	{
		printf("Session begin.\n\n");
		return true;
	}
	return false;
}

void close_file(FILE* &file, time_t t_time)
{
	// if disconnected close file
	if(file)
	{

#ifndef LOG_TO_CSV
		logCloseIBT(file);
#endif
		// write last state string recieved out to disk
		logStateToFile(t_time);

		fclose(file);
		file= NULL;

		printf("Session ended.\n\n");
	}
}

void end_session(bool shutdown)
{
	close_file(g_file, g_ttime);

	if(g_data)
		delete[] g_data;
	g_data = NULL;

	if(shutdown)
	{
		irsdk_shutdown();
		timeEndPeriod(1);
	}
}

// exited with ctrl-c
void ex_program(int sig) 
{
	(void)sig;

	printf("recieved ctrl-c, exiting\n\n");

	end_session(true);

	signal(SIGINT, SIG_DFL);
	exit(0);
}

int main()
{
	printf("irsdk_writetest 1.0\n");
	printf(" demo program to save iRacing telemetry data to a .csv file\n\n");

	// trap ctrl-c
	signal(SIGINT, ex_program);
	printf("press enter to exit:\n\n");

	// bump priority up so we get time from the sim
	SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);

	// ask for 1ms timer so sleeps are more precise
	timeBeginPeriod(1);
	g_data = NULL;
	g_nData = 0;
	
	while(!_kbhit())
	{
		// wait for new data and copy it into the g_data buffer, if g_data is not null
		if(irsdk_waitForDataReady(TIMEOUT, g_data))
		{
			const irsdk_header *pHeader = irsdk_getHeader();
			if(pHeader)
			{

				// if header changes size, assume a new connection
				if(!g_data || g_nData != pHeader->bufLen)
				{
					// realocate our g_data buffer to fit, and lookup some data offsets
					initData(pHeader, g_data, g_nData);

#ifdef LOG_TO_DISPLAY
					logHeaderToDisplay(pHeader);
#endif
				}
				else if(g_data)
				{
					if(canLogToFile(pHeader, g_data))
					{
						// open file if first time
						if(!g_file && open_file(g_file, g_ttime))
						{
#ifdef LOG_TO_CSV
								logHeaderToCSV(pHeader, g_file, g_ttime);
#else
								logHeaderToIBT(pHeader, g_file, g_ttime);
#endif
						}

						// and log data to file
						if(g_file)
						{
#ifdef LOG_TO_CSV
							logDataToCSV(pHeader, g_data, g_file);
#else
							logDataToIBT(pHeader, g_data, g_file);
#endif
						}
					}
					else
						close_file(g_file, g_ttime);

#ifdef LOG_TO_DISPLAY
					static int ct = 0;
					if(ct++ % 100 == 0)
					{
						logDataToDisplay(pHeader, g_data);
					}
#endif
				}
			}
		}
		// session ended
		else if(!irsdk_isConnected())
			end_session(false);
	}

	// exited with a keyboard hit
	printf("Shutting down.\n\n");

	end_session(true);

	return 0;
}

