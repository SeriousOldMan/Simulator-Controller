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

void sendAnalyzerMessage(const char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.ahk");

	if (winHandle != 0) {
		char buffer[128];

		strcpy_s(buffer, 128, "Analyzer:");
		strcpy_s(buffer + strlen("Analyzer:"), 128 - strlen("Analyzer:"), message);

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

inline float vectorLength(float x, float y) {
	return sqrt((x * x) + (y * y));
}

std::string player = "";
std::string audioDevice = "";
float volume = 0;
STARTUPINFOA si = { sizeof(si) };

void playSound(std::string wavFile) {
	PROCESS_INFORMATION pi;

	if (CreateProcessA(
		NULL,               // Application name
		(char*)("\"" + player + "\" \"" + wavFile + "\" -T waveaudio " +
								((audioDevice != "") ? ("\"" + audioDevice + "\" ") : "") +
								"vol " + std::to_string(volume)).c_str(),         // Command line
		NULL,               // Process handle not inheritable
		NULL,               // Thread handle not inheritable
		FALSE,              // Set handle inheritance to FALSE
		0,                  // No creation flags
		NULL,               // Use parent's environment block
		NULL,               // Use parent's starting directory 
		&si,                // Pointer to STARTUPINFO structure
		&pi)                // Pointer to PROCESS_INFORMATION structure
		)
	{
		// Wait until process exits
		WaitForSingleObject(pi.hProcess, INFINITE);

		// Close process and thread handles
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
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
		phase(phase) {
	}
};

const int MAXVALUES = 6;
#define PI 3.14159265

std::vector<float> recentSteerAngles;
std::vector<float> recentGLongs;
std::vector<float> recentIdealAngVels;
std::vector<float> recentRealAngVels;

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
		if (audioDevice != "") {
			if (player != "")
				playSound(wavFile);
			else
				sendAnalyzerMessage(("acousticFeedback:" + wavFile).c_str());
		}
		else
			PlaySoundA(wavFile.c_str(), NULL, SND_FILENAME | SND_ASYNC);

		return true;
	}
	else
		return false;
}

bool collectTelemetry(const SharedMemory* sharedData, std::string soundsDirectory, std::string audioDevice, bool calibrate) {
	if (sharedData->mGameState == GAME_INGAME_PAUSED && sharedData->mPitMode != PIT_MODE_NONE)
		return true;

	float steerAngle = smoothValue(recentSteerAngles, sharedData->mSteering);

	float acceleration = sharedData->mSpeed * 3.6 - lastSpeed;

	lastSpeed = sharedData->mSpeed * 3.6;

	pushValue(recentGLongs, acceleration);

	double angularVelocity = smoothValue(recentRealAngVels, sharedData->mAngularVelocity[VEC_Y]);
	double steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	double steerAngleRadians = -steeredAngleDegs / 57.2958;
	double wheelBaseMeter = (float)wheelbase / 100;
	double radius = wheelBaseMeter / steerAngleRadians;
	double perimeter = radius * PI * 2;
	double perimeterSpeed = lastSpeed / 3.6;
	double idealAngularVelocity = smoothValue(recentIdealAngVels, perimeterSpeed / perimeter * 2 * PI);

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

		CornerDynamics cd = CornerDynamics(sharedData->mSpeed * 3.6, 0,
			sharedData->mParticipantInfo[sharedData->mViewedParticipantIndex].mLapsCompleted,
			phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			double slip = fabs(idealAngularVelocity - angularVelocity);

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

			cd.usos = slip * 57.2989 * 1;

			if ((soundsDirectory != "") && GetTickCount() > (lastSound + 300))
				if (triggerUSOSBeep(soundsDirectory, audioDevice, cd.usos))
					lastSound = GetTickCount();

			if (false) {
				std::ofstream output;

				output.open(dataFile + ".trace", std::ios::out | std::ios::app);

				output << steerAngle << "  " << steeredAngleDegs << "  " << steerAngleRadians << "  " <<
					lastSpeed << "  " << idealAngularVelocity << "  " << angularVelocity << "  " << slip << "  " <<
					cd.usos << std::endl;

				output.close();

				Sleep(200);
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

void writeTelemetry(const SharedMemory* sharedData, bool calibrate) {
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

		int slowOSMin[] = { 0, 0, 0 };
		int fastOSMin[] = { 0, 0, 0 };
		int slowUSMax[] = { 0, 0, 0 };
		int fastUSMax[] = { 0, 0, 0 };

		std::vector <CornerDynamics>::iterator cornerIter;
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

float xCoordinates[256];
float yCoordinates[256];
int numCoordinates = 0;
time_t nextUpdate = 0;
char* triggerType = "Trigger";

std::string hintFile = "";

std::string hintSounds[256];
float hintDistances[256];
time_t lastHintsUpdate = 0;
int lastLap = 0;
int lastHint = -1;

void checkCoordinates(const SharedMemory* sharedData) {
	int carID = sharedData->mViewedParticipantIndex;

	if (time(NULL) > nextUpdate) {
		float velocityX = sharedData->mWorldVelocity[VEC_X];
		float velocityY = sharedData->mWorldVelocity[VEC_Z];
		float velocityZ = sharedData->mWorldVelocity[VEC_Y];

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			float coordinateX = sharedData->mParticipantInfo[carID].mWorldPosition[VEC_X];
			float coordinateY = - sharedData->mParticipantInfo[carID].mWorldPosition[VEC_Z];
			
			if (strcmp(triggerType, "Trigger") == 0) {
				for (int i = 0; i < numCoordinates; i += 1) {
					if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
						char buffer[512] = "";						
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

						nextUpdate = time(NULL) + 2;

						break;
					}
				}
			}
			else {
				if (lastLap != sharedData->mParticipantInfo[carID].mLapsCompleted) {
					lastLap = sharedData->mParticipantInfo[carID].mLapsCompleted;

					lastHint = -1;
				}

				for (int i = lastHint + 1; i < numCoordinates; i += 1) {
					if (vectorLength(xCoordinates[i] - coordinateX, yCoordinates[i] - coordinateY) < hintDistances[i]) {
						lastHint = i;

						if (audioDevice != "")
						{
							if (player != "")
								playSound(hintSounds[i]);
							else {
								char buffer[512] = "";

								strcat_s(buffer, "acousticFeedback:");
								strcat_s(buffer, hintSounds[i].c_str());

								sendTriggerMessage(buffer);
							}

							nextUpdate = time(NULL) + 1;
						}
						else
							PlaySoundA(hintSounds[i].c_str(), NULL, SND_SYNC);

						break;
					}
				}
			}
		}
	}
}

#ifdef WIN32
#define stat _stat
#endif

void loadTrackHints()
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
				auto parts = splitString(line, " ", 4);

				xCoordinates[numCoordinates] = (float)atof(parts[0].c_str());
				yCoordinates[numCoordinates] = (float)atof(parts[1].c_str());
				hintDistances[numCoordinates] = (float)atof(parts[2].c_str());
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
	bool handlingCalibrator = false;
	bool handlingAnalyzer = false;
	bool positionTrigger = false;
	bool trackHints = false;
	const char* soundsDirectory = "";

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

		trackHints = (strcmp(argv[1], "-TrackHints") == 0);

		if (trackHints) {
			triggerType = "TrackHints";

			hintFile = argv[2];

			if (argc > 3)
				audioDevice = argv[3];

			if (argc > 4)
				volume = atof(argv[4]);

			if (argc > 5)
				player = argv[5];
		}

		handlingCalibrator = (strcmp(argv[1], "-Calibrate") == 0);
		handlingAnalyzer = handlingCalibrator || (strcmp(argv[1], "-Analyze") == 0);
#
		if (handlingAnalyzer) {
			dataFile = argv[2];

			if (handlingCalibrator) {
				lowspeedThreshold = atoi(argv[3]);
				steerLock = atoi(argv[4]);
				steerRatio = atoi(argv[5]);
				wheelbase = atoi(argv[6]);
				trackWidth = atoi(argv[7]);
			}
			else {
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

				if (argc > 14) {
					soundsDirectory = argv[14];

					if (argc > 15)
						audioDevice = argv[15];
				}
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

		long counter = 0;

		while (true)
		{
			counter += 0;

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

			if (handlingAnalyzer) {
				if (collectTelemetry(localCopy, soundsDirectory, audioDevice, handlingCalibrator)) {
					if (remainder(counter, 20) == 0)
						writeTelemetry(localCopy, handlingCalibrator);

					Sleep(10);
				}
				else
					break;
			}
			else if (positionTrigger) {
				checkCoordinates(sharedData);

				Sleep(10);
			}
			else if (positionTrigger) {
				loadTrackHints();

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
