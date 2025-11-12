// Used for memory-mapped functionality
#include <windows.h>
#include <math.h>
#include "sharedmemory.h"

// Used for this example
#include <stdio.h>
#include <conio.h>
#include <time.h>
#include <vector>
#include <string>
#include <fstream>
#include <iostream>

#pragma comment( lib, "winmm.lib" )

// Name of the pCars memory mapped file
#define MAP_OBJECT_NAME "$pcars2$"

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
	HWND winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Driving Coach:");
		strcpy_s(buffer + strlen("Driving Coach:"), 128 - strlen("Driving Coach:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
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
char* triggerType = "Trigger";

std::string audioDevice = "";
std::string hintFile = "";

std::string hintSounds[256];
time_t lastHintsUpdate = 0;

void checkCoordinates(const SharedMemory* sharedData) {
	if ((triggerType == "BrakeHints") ? true : time(NULL) > (lastUpdate + 2)) {
		float velocityX = sharedData->mWorldVelocity[VEC_X];
		float velocityY = sharedData->mWorldVelocity[VEC_Z];
		float velocityZ = sharedData->mWorldVelocity[VEC_Y];

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int carID = sharedData->mViewedParticipantIndex;

			float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
			float coordinateY = - sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

			for (int i = 0; i < numCoordinates; i += 1) {
				if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
					char buffer[512] = "";
					
					if (strcmp(triggerType, "Trigger") == 0) {
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
					else if (strcmp(triggerType, "BrakeHints") == 0) {
						strcat_s(buffer, "acousticFeedback:");
						strcat_s(buffer, hintSounds[i].c_str());

						sendTriggerMessage(buffer);
					}

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
			std::string line;

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

int main(int argc, char* argv[]) {
	// Open the memory-mapped file
	HANDLE fileHandle = OpenFileMappingA(PAGE_READONLY, FALSE, MAP_OBJECT_NAME);

	const SharedMemory* sharedData = NULL;
	SharedMemory* localCopy = NULL;
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
		
	if (fileHandle != NULL) {
		sharedData = (SharedMemory*)MapViewOfFile(fileHandle, PAGE_READONLY, 0, 0, sizeof(SharedMemory));
		localCopy = new SharedMemory;

		if (sharedData == NULL) {
			CloseHandle(fileHandle);

			fileHandle = NULL;
		}
	}

	if (sharedData != NULL) {
		//------------------------------------------------------------------------------
		// TEST DISPLAY CODE
		//------------------------------------------------------------------------------
		unsigned int updateIndex(0);
		unsigned int indexChange(0);

		while (true)
		{
			if (sharedData->mSequenceNumber % 2)
			{
				// Odd sequence number indicates, that write into the shared memory is just happening
				continue;
			}

			indexChange = sharedData->mSequenceNumber - updateIndex;
			updateIndex = sharedData->mSequenceNumber;

			//Copy the whole structure before processing it, otherwise the risk of the game writing into it during processing is too high.
			memcpy(localCopy, sharedData, sizeof(SharedMemory));

			if (localCopy->mSequenceNumber != updateIndex)
			{
				// More writes had happened during the read. Should be rare, but can happen.
				continue;
			}

			if (positionTrigger) {
				checkCoordinates(sharedData);

				Sleep(10);
			}
			else if (positionTrigger) {
				loadBrakeHints();

				checkCoordinates(sharedData);

				Sleep(10);
			}
		}
	}

	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}
