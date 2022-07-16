// Used for memory-mapped functionality
#include <windows.h>
#include <math.h>
#include "sharedmemory.h"

// Used for this example
#include <stdio.h>
#include <conio.h>

// Name of the pCars memory mapped file
#define MAP_OBJECT_NAME "$pcars2$"

inline double normalize(double value) {
	return (value < 0) ? 0.0 : value;
}

void substring(char s[], char sub[], int p, int l) {
	int c = 0;

	while (c < l) {
		sub[c] = s[p + c];

		c++;
	}
	sub[c] = '\0';
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
	HWND winHandle = FindWindowExA(0, 0, 0, "Race Spotter.exe");

	if (winHandle == 0)
		FindWindowExA(0, 0, 0, "Race Spotter.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

void sendAutomationMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Simulator Controller.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Simulator Controller.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Race Spotter:");
		strcpy_s(buffer + strlen("Race Spotter:"), 128 - strlen("Race Spotter:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

#define PI 3.14159265

const float nearByXYDistance = 10.0;
const float nearByZDistance = 6.0;
const float longitudinalDistance = 4;
const float lateralDistance = 6;
const float verticalDistance = 2;

const int CLEAR = 0;
const int LEFT = 1;
const int RIGHT = 2;
const int THREE = 3;

const int situationRepeat = 50;

const char* noAlert = "NoAlert";

int lastSituation = CLEAR;
int situationCount = 0;

bool carBehind = false;
bool carBehindLeft = false;
bool carBehindRight = false;
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

inline float vectorLength(float x, float y) {
	return sqrt((x * x) + (y * y));
}

float vectorAngle(float x, float y) {
	float scalar = (x * 0) + (y * 1);
	float length = vectorLength(x, y);

	float angle = (length > 0) ? acos(scalar / length) * 180 / PI : 0;

	if (x < 0)
		angle = 360 - angle;

	return angle;
}

bool nearBy(float car1X, float car1Y, float car1Z,
	float car2X, float car2Y, float car2Z) {
	return (fabs(car1X - car2X) < nearByXYDistance) &&
		(fabs(car1Y - car2Y) < nearByXYDistance) &&
		(fabs(car1Z - car2Z) < nearByZDistance);
}

void rotateBy(float* x, float* y, float angle) {
	float sinus = sin(angle * PI / 180);
	float cosinus = cos(angle * PI / 180);

	float newX = (*x * cosinus) - (*y * sinus);
	float newY = (*x * sinus) + (*y * cosinus);

	*x = newX;
	*y = newY;
}

int checkCarPosition(float carX, float carY, float carZ, float angle, bool faster,
					 float otherX, float otherY, float otherZ) {
	if (nearBy(carX, carY, carZ, otherX, otherY, otherZ)) {
		float transX = (otherX - carX);
		float transY = (otherY - carY);

		rotateBy(&transX, &transY, angle);

		if ((fabs(transY) < longitudinalDistance) && (fabs(transX) < lateralDistance) && (fabs(otherZ - carZ) < verticalDistance))
			return (transX > 0) ? RIGHT : LEFT;
		else {
			if (transY < 0) {
				carBehind = true;

				if ((faster && fabs(transY) < longitudinalDistance * 1.5) ||
					(fabs(transY) < longitudinalDistance * 2 && fabs(transX) > lateralDistance / 2))
					if (transX > 0)
						carBehindRight = true;
					else
						carBehindLeft = true;
			}

			return CLEAR;
		}
	}
	else
		return CLEAR;
}

float lastCoordinates[STORED_PARTICIPANTS_MAX][3];
bool hasLastCoordinates = false;

bool checkPositions(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		float angle = vectorAngle(velocityX, velocityY);

		int carID = sharedData->mViewedParticipantIndex;

		float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
		float coordinateY = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];
		float coordinateZ = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Y];
		float speed = 0.0;

		if (hasLastCoordinates)
			speed = vectorLength(lastCoordinates[carID][VEC_X] - coordinateX, lastCoordinates[carID][VEC_Z] - coordinateY);

		int newSituation = CLEAR;

		carBehind = false;
		carBehindLeft = false;
		carBehindRight = false;

		for (int id = 0; id < sharedData->mNumParticipants; id++) {
			if (id != carID) {
				bool faster = false;

				if (hasLastCoordinates)
					faster = vectorLength(lastCoordinates[id][VEC_X] - sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
										  lastCoordinates[id][VEC_Z] - sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z]) > speed * 1.01;

				newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
					sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
					sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z],
					sharedData->mParticipantInfo[id].mWorldPosition[VEC_Y]);

				if ((newSituation == THREE) && carBehind)
					break;
			}
		}

		for (int id = 0; id < sharedData->mNumParticipants; id++) {
			ParticipantInfo participantInfo = sharedData->mParticipantInfo[id];

			lastCoordinates[id][VEC_X] = participantInfo.mWorldPosition[VEC_X];
			lastCoordinates[id][VEC_Y] = participantInfo.mWorldPosition[VEC_Y];
			lastCoordinates[id][VEC_Z] = participantInfo.mWorldPosition[VEC_Z];
		}

		hasLastCoordinates = true;

		if (newSituation != CLEAR) {
			carBehind = false;
			carBehindLeft = false;
			carBehindRight = false;
			carBehindReported = false;
		}

		const char* alert = computeAlert(newSituation);

		if (alert != noAlert) {
			if (strcmp(alert, "Hold") == 0)
				carBehindReported = false;

			char buffer[128];

			strcpy_s(buffer, 128, "proximityAlert:");
			strcpy_s(buffer + strlen("proximityAlert:"), 128 - strlen("proximityAlert:"), alert);

			sendSpotterMessage(buffer);

			return true;
		}
		else if (carBehind) {
			if (!carBehindReported) {
				carBehindReported = true;

				sendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
												   (carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

				return true;
			}
		}
		else
			carBehindReported = false;
	}
	else {
		lastSituation = CLEAR;
		carBehind = false;
		carBehindLeft = false;
		carBehindRight = false;
		carBehindReported = false;
	}

	return false;
}

bool checkFlagState(const SharedMemory* sharedData) {
	if ((waitYellowFlagState & YELLOW) != 0) {
		if (yellowCount++ > 50) {
			if (!(sharedData->mHighestFlagColour == FLAG_COLOUR_YELLOW || sharedData->mHighestFlagColour == FLAG_COLOUR_DOUBLE_YELLOW))
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

	if (sharedData->mHighestFlagColour == FLAG_COLOUR_BLUE) {
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

	if (sharedData->mHighestFlagColour == FLAG_COLOUR_YELLOW || sharedData->mHighestFlagColour == FLAG_COLOUR_DOUBLE_YELLOW) {
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

void checkPitWindow(const SharedMemory* sharedData) {
	if (sharedData->mEnforcedPitStopLap > 0)
		if ((sharedData->mEnforcedPitStopLap == sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted + 1) &&
			!pitWindowOpenReported) {
			pitWindowOpenReported = true;
			pitWindowClosedReported = false;

			sendSpotterMessage("pitWindow:Open");
		}
		else if ((sharedData->mEnforcedPitStopLap < sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted) &&
			!pitWindowClosedReported) {
			pitWindowClosedReported = true;
			pitWindowOpenReported = false;

			sendSpotterMessage("pitWindow:Closed");
		}
}

float initialX = 0.0;
float initialY = 0.0;
int coordCount = 0;

bool writeCoordinates(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		int carID = sharedData->mViewedParticipantIndex;

		float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
		float coordinateY = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

		printf("%f,%f\n", coordinateX, coordinateY);

		if (initialX == 0.0) {
			initialX = coordinateX;
			initialY = coordinateY;
		}
		else if (coordCount++ > 1000 && fabs(coordinateX - initialX) < 10.0 && fabs(coordinateY - initialY) < 10.0)
			return false;
	}

	return true;
}

float xCoordinates[60];
float yCoordinates[60];
int numCoordinates = 0;

void checkCoordinates(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		int carID = sharedData->mViewedParticipantIndex;

		float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
		float coordinateY = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

		for (int i = 0; i < numCoordinates; i += 2) {
			if (fabs(xCoordinates[i] - coordinateX) < 10 && fabs(yCoordinates[i] - coordinateY) < 10) {
				char buffer[60] = "";
				char numBuffer[60];

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
	bool mapTrack = false;
	bool positionTrigger = false;

	if (argc > 1) {
		mapTrack = (strcmp(argv[1], "-Map") == 0);

		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		for (int i = 2; i < (argc - 1); i = i + 2) {
			xCoordinates[numCoordinates] = (float)atof(argv[i]);
			yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

			numCoordinates += 1;
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

		bool running = false;
		int countdown = 400;

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
			
			if (mapTrack) {
				if (!writeCoordinates(sharedData))
					break;
			}
			else if (positionTrigger)
				checkCoordinates(sharedData);
			else {
				if (!running)
					running = ((localCopy->mHighestFlagColour == FLAG_COLOUR_GREEN) || (countdown-- <= 0));

				if (running) {
					if (localCopy->mGameState != GAME_INGAME_PAUSED && localCopy->mPitMode == PIT_MODE_NONE) {
						if (!checkFlagState(localCopy) && !checkPositions(localCopy))
							checkPitWindow(localCopy);
					}
					else {
						lastSituation = CLEAR;
						carBehind = false;
						carBehindLeft = false;
						carBehindRight = false;
						carBehindReported = false;

						lastFlagState = 0;
					}
				}
			}

			Sleep(50);
		}
	}

	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}
