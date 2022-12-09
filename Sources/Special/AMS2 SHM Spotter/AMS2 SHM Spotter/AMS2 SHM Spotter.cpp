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
float longitudinalFrontDistance = 4;
float longitudinalRearDistance = 5;
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
int carBehindCount = 0;

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

		if ((fabs(transY) < ((transY > 0) ? longitudinalFrontDistance : longitudinalRearDistance)) && (fabs(transX) < lateralDistance) && (fabs(otherZ - carZ) < verticalDistance))
			return (transX > 0) ? RIGHT : LEFT;
		else {
			if (transY < 0) {
				carBehind = true;

				if ((faster && fabs(transY) < longitudinalFrontDistance * 1.5) ||
					(fabs(transY) < longitudinalFrontDistance * 2 && fabs(transX) > lateralDistance / 2))
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
			if ((id != carID) && (sharedData->mPitModes[id] == PIT_MODE_NONE)) {
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

		if (carBehindCount++ > 200)
			carBehindCount = 0;

		const char* alert = computeAlert(newSituation);

		if (alert != noAlert) {
			longitudinalRearDistance = 4;

			char buffer[128];

			strcpy_s(buffer, 128, "proximityAlert:");
			strcpy_s(buffer + strlen("proximityAlert:"), 128 - strlen("proximityAlert:"), alert);

			sendSpotterMessage(buffer);

			return true;
		}
		else {
			longitudinalRearDistance = 5;
			
			if (carBehind) {
				if (!carBehindReported) {
					if (carBehindLeft || carBehindRight || (carBehindCount < 20)) {
						carBehindReported = true;

						sendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
							(carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

						return true;
					}
				}
			}
			else
				carBehindReported = false;
		}
	}
	else {
		longitudinalRearDistance = 5;
		
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
		if (yellowCount > 50) {
			if (!(sharedData->mHighestFlagColour == FLAG_COLOUR_YELLOW || sharedData->mHighestFlagColour == FLAG_COLOUR_DOUBLE_YELLOW))
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

	if (sharedData->mHighestFlagColour == FLAG_COLOUR_BLUE) {
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

bool checkPitWindow(const SharedMemory* sharedData) {
	if (sharedData->mEnforcedPitStopLap > 0)
		if ((sharedData->mEnforcedPitStopLap == sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted + 1) &&
			!pitWindowOpenReported) {
			pitWindowOpenReported = true;
			pitWindowClosedReported = false;

			sendSpotterMessage("pitWindow:Open");

			return true;
		}
		else if ((sharedData->mEnforcedPitStopLap < sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted) &&
			!pitWindowClosedReported) {
			pitWindowClosedReported = true;
			pitWindowOpenReported = false;

			sendSpotterMessage("pitWindow:Closed");

			return true;
		}

	return false;
}

bool greenFlagReported = false;

bool greenFlag(SharedMemory* shm) {
	if (!greenFlagReported && (shm->mHighestFlagColour == FLAG_COLOUR_GREEN)) {
		greenFlagReported = true;
		
		sendSpotterMessage("greenFlag");
		
		Sleep(2000);
		
		return true;
	}
	else
		return false;
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

bool collectTelemetry(const SharedMemory* sharedData) {
	if (sharedData->mGameState == GAME_INGAME_PAUSED && sharedData->mPitMode != PIT_MODE_NONE)
		return true;

	recentSteerAngles.push_back(sharedData->mSteering);
	if ((int)recentSteerAngles.size() > numRecentSteerAngles) {
		recentSteerAngles.erase(recentSteerAngles.begin());
	}

	float acceleration = sharedData->mSpeed * 3.6 - lastSpeed;

	lastSpeed = sharedData->mSpeed * 3.6;

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

	if (fabs(sharedData->mSteering) > 0.1 && lastSpeed > 60) {
		double angularVelocity = sharedData->mAngularVelocity[VEC_Z];

		CornerDynamics cd = CornerDynamics(sharedData->mSpeed * 3.6, 0,
			sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted,
			phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			double steeredAngleDegs = sharedData->mSteering * steerLock / 2.0f / steerRatio;
			double steerAngleRadians = -steeredAngleDegs / 57.2958;
			double wheelBaseMeter = (float)wheelbase / 10;
			double radius = wheelBaseMeter / steerAngleRadians;

			double perimeter = radius * PI * 2;
			double perimeterSpeed = lastSpeed / 3.6;
			double idealAngularVelocity = perimeterSpeed / perimeter * 2 * PI;

			double slip = fabs(idealAngularVelocity) - fabs(angularVelocity);

			if (false)
				if (sharedData->mSteering > 0) {
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

				output << sharedData->mSteering << "  " << steeredAngleDegs << "  " << steerAngleRadians << "  " <<
					      lastSpeed << "  " << idealAngularVelocity << "  " << angularVelocity << "  " << slip << "  " <<
						  cd.usos << std::endl;

				output.close();
			}
		}

		cornerDynamicsList.push_back(cd);

		int completedLaps = sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted;

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

void writeTelemetry(const SharedMemory* sharedData) {
	std::ofstream output;

	try {
		output.open(dataFile + ".tmp", std::ios::out | std::ios::trunc);

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

		std::vector <CornerDynamics>::iterator cornerIter;
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
int coordCount = 0;

bool writeCoordinates(const SharedMemory* sharedData) {
	float velocityX = sharedData->mWorldVelocity[VEC_X];
	float velocityY = sharedData->mWorldVelocity[VEC_Z];
	float velocityZ = sharedData->mWorldVelocity[VEC_Y];

	if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
		int carID = sharedData->mViewedParticipantIndex;

		float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
		float coordinateY = - sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

		printf("%f,%f\n", coordinateX, coordinateY);

		if (coordCount == 0) {
			initialX = coordinateX;
			initialY = coordinateY;
		}
		else if (coordCount > 100 && fabs(coordinateX - initialX) < 10.0 && fabs(coordinateY - initialY) < 10.0)
			return false;
		
		coordCount += 1;
	}

	return true;
}

float xCoordinates[60];
float yCoordinates[60];
int numCoordinates = 0;
time_t lastUpdate = 0;

void checkCoordinates(const SharedMemory* sharedData) {
	if (time(NULL) > (lastUpdate + 2)) {
		float velocityX = sharedData->mWorldVelocity[VEC_X];
		float velocityY = sharedData->mWorldVelocity[VEC_Z];
		float velocityZ = sharedData->mWorldVelocity[VEC_Y];

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int carID = sharedData->mViewedParticipantIndex;

			float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
			float coordinateY = - sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];

			for (int i = 0; i < numCoordinates; i += 1) {
				if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
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

					lastUpdate = time(NULL);

					break;
				}
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
			for (int i = 2; i < (argc - 1); i = i + 2) {
				xCoordinates[numCoordinates] = (float)atof(argv[i]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 1]);

				numCoordinates += 1;
			}
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
		long counter = 0;

		while (++counter)
		{
			bool wait = true;

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
			
			if (analyzeTelemetry) {
				if (collectTelemetry(localCopy)) {
					if (remainder(counter, 20) == 0)
						writeTelemetry(localCopy);
				}
				else
					break;
			}
			else if (mapTrack) {
				if (!writeCoordinates(sharedData))
					break;
			}
			else if (positionTrigger)
				checkCoordinates(sharedData);
			else {
				bool startGo = (localCopy->mHighestFlagColour == FLAG_COLOUR_GREEN);
				
				if (!running) {
					countdown -= 1;

					if (!greenFlagReported && (countdown <= 0))
						greenFlagReported = true;

					running = (startGo || (countdown <= 0));
				}

				if (running)
					if (localCopy->mGameState != GAME_INGAME_PAUSED && localCopy->mPitMode == PIT_MODE_NONE) {
						if (!startGo || !greenFlag(localCopy))
							if (!checkFlagState(localCopy) && !checkPositions(localCopy))
								wait = !checkPitWindow(localCopy);
							else
								wait = false;
					}
					else {
						longitudinalRearDistance = 5;
						
						lastSituation = CLEAR;
						carBehind = false;
						carBehindLeft = false;
						carBehindRight = false;
						carBehindReported = false;

						lastFlagState = 0;
					}
			}

			if (analyzeTelemetry)
				Sleep(10);
			else if (positionTrigger)
				Sleep(10);
			else if (wait)
				Sleep(50);
		}
	}

	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}
