#include "stdafx.h"
#include <stdio.h>
#include <fstream>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include <comdef.h>
#include <iostream>
#include "SharedFileOut.h"
#include <codecvt>
#include <vector>
#include <string>
#include <thread>
#include <unordered_map>

#pragma comment( lib, "winmm.lib" )

#pragma optimize("",off)
using namespace std;

template <typename T, unsigned S>
inline unsigned arraysize(const T(&v)[S])
{
	return S;
}

struct SMElement
{
	HANDLE hMapFile;
	unsigned char* mapFileBuffer;
};

SMElement m_graphics;
SMElement m_physics;
SMElement m_static;

void initPhysics()
{
	TCHAR szName[] = TEXT("Local\\acpmf_physics");
	m_physics.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFilePhysics), szName);
	if (!m_physics.hMapFile)
	{
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACCS", MB_OK);
	}
	m_physics.mapFileBuffer = (unsigned char*)MapViewOfFile(m_physics.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFilePhysics));
	if (!m_physics.mapFileBuffer)
	{
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACCS", MB_OK);
	}
}

void initGraphics()
{
	TCHAR szName[] = TEXT("Local\\acpmf_graphics");
	m_graphics.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFileGraphic), szName);
	if (!m_graphics.hMapFile)
	{
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACCS", MB_OK);
	}
	m_graphics.mapFileBuffer = (unsigned char*)MapViewOfFile(m_graphics.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFileGraphic));
	if (!m_graphics.mapFileBuffer)
	{
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACCS", MB_OK);
	}
}

void initStatic()
{
	TCHAR szName[] = TEXT("Local\\acpmf_static");
	m_static.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFileStatic), szName);
	if (!m_static.hMapFile)
	{
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACCS", MB_OK);
	}
	m_static.mapFileBuffer = (unsigned char*)MapViewOfFile(m_static.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFileStatic));
	if (!m_static.mapFileBuffer)
	{
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACCS", MB_OK);
	}
}

void dismiss(SMElement element)
{
	UnmapViewOfFile(element.mapFileBuffer);
	CloseHandle(element.hMapFile);
}

int sendStringMessage(HWND hWnd, int wParam, string msg) {
	int result = 0;

	if (hWnd) {
		COPYDATASTRUCT cds;
		cds.dwData = (256 * 'D' + 'C');
		cds.cbData = sizeof(char) * (msg.length() + 1);
		cds.lpData = (char *)msg.c_str();

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendTriggerMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Driving Coach:" + message);
}

void sendAnalyzerMessage(string message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.ahk");

	if (winHandle != 0)
		sendStringMessage(winHandle, 0, "Analyzer:" + message);
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

string player = "";
string audioDevice = "";
float volume = 1;
STARTUPINFOA si = { sizeof(si) };

void playSound(string wavFile, bool wait = true) {
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
		if (wait)
			// Wait until process exits
			WaitForSingleObject(pi.hProcess, INFINITE);

		// Close process and thread handles
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	}
}

template <typename T> int sgn(T val) {
	return (T(0) < val) - (val < T(0));
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
	vector <float>::iterator iter;
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

string dataFile = "";
int understeerLightThreshold = 12;
int understeerMediumThreshold = 20;
int understeerHeavyThreshold = 35;
int oversteerLightThreshold = 2;
int oversteerMediumThreshold = -6;
int oversteerHeavyThreshold = -10;
int lowspeedThreshold = 100;
int steerLock = 480;
int steerRatio = 12;
int wheelbase = 267;
int trackWidth = 150;

int lastCompletedLaps = 0;
float lastSpeed = 0.0;
long lastSound = 0;

bool triggerUSOSBeep(string soundsDirectory, string audioDevice, float usos) {
	string wavFile = "";

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
				playSound(wavFile, false);
			else
				sendAnalyzerMessage("acousticFeedback:" + wavFile);
		}
		else
			PlaySoundA(wavFile.c_str(), NULL, SND_FILENAME | SND_ASYNC);

		return true;
	}
	else
		return false;
}

bool collectTelemetry(string soundsDirectory, string audioDevice, bool calibrate) {
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	if ((gf->status != AC_LIVE) || gf->isInPit || gf->isInPitLane)
		return true;

	float steerAngle = smoothValue(recentSteerAngles, pf->steerAngle);
	float acceleration = pf->speedKmh - lastSpeed;

	lastSpeed = pf->speedKmh;

	pushValue(recentGLongs, acceleration);

	float angularVelocity = smoothValue(recentRealAngVels, pf->localAngularVel[1]);
	float steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	double steerAngleRadians = -steeredAngleDegs / 57.2958;
	double wheelBaseMeter = (float)wheelbase / 100;
	double radius = wheelBaseMeter / steerAngleRadians;
	double perimeter = radius * PI * 2;
	double perimeterSpeed = lastSpeed / 3.6;
	float idealAngularVelocity = smoothValue(recentIdealAngVels, perimeterSpeed / perimeter * 2 * PI);

	if (fabs(steerAngle) > 0.1 && pf->speedKmh > 60) {
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

		CornerDynamics cd = CornerDynamics(pf->speedKmh, 0, gf->completedLaps, phase);

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			double slip = fabs(angularVelocity - idealAngularVelocity);

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

		int completedLaps = gf->completedLaps;

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

void writeTelemetry(bool calibrate) {
	ofstream output;

	try {
		output.open(dataFile + ".tmp", ios::out | ios::trunc);

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

		vector <CornerDynamics>::iterator cornerIter;
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
			output << "[Understeer.Slow]" << endl;

			output << "Entry=" << slowUSMax[0] << endl;
			output << "Apex=" << slowUSMax[1] << endl;
			output << "Exit=" << slowUSMax[2] << endl;

			output << "[Understeer.Fast]" << endl;

			output << "Entry=" << fastUSMax[0] << endl;
			output << "Apex=" << fastUSMax[1] << endl;
			output << "Exit=" << fastUSMax[2] << endl;

			output << "[Oversteer.Slow]" << endl;

			output << "Entry=" << slowOSMin[0] << endl;
			output << "Apex=" << slowOSMin[1] << endl;
			output << "Exit=" << slowOSMin[2] << endl;

			output << "[Oversteer.Fast]" << endl;

			output << "Entry=" << fastOSMin[0] << endl;
			output << "Apex=" << fastOSMin[1] << endl;
			output << "Exit=" << fastOSMin[2] << endl;
		}
		else {
			output << "[Understeer.Slow.Light]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowLightUSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowLightUSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowLightUSNum[2] / slowTotalNum) << endl;
			}

			output << "[Understeer.Slow.Medium]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowMediumUSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowMediumUSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowMediumUSNum[2] / slowTotalNum) << endl;
			}

			output << "[Understeer.Slow.Heavy]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum) << endl;
			}

			output << "[Understeer.Fast.Light]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastLightUSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastLightUSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastLightUSNum[2] / fastTotalNum) << endl;
			}

			output << "[Understeer.Fast.Medium]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastMediumUSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastMediumUSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastMediumUSNum[2] / fastTotalNum) << endl;
			}

			output << "[Understeer.Fast.Heavy]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum) << endl;
			}

			output << "[Oversteer.Slow.Light]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowLightOSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowLightOSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowLightOSNum[2] / slowTotalNum) << endl;
			}

			output << "[Oversteer.Slow.Medium]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowMediumOSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowMediumOSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowMediumOSNum[2] / slowTotalNum) << endl;
			}

			output << "[Oversteer.Slow.Heavy]" << endl;

			if (slowTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum) << endl;
			}

			output << "[Oversteer.Fast.Light]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastLightOSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastLightOSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastLightOSNum[2] / fastTotalNum) << endl;
			}

			output << "[Oversteer.Fast.Medium]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastMediumOSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastMediumOSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastMediumOSNum[2] / fastTotalNum) << endl;
			}

			output << "[Oversteer.Fast.Heavy]" << endl;

			if (fastTotalNum > 0) {
				output << "Entry=" << (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum) << endl;
				output << "Apex=" << (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum) << endl;
				output << "Exit=" << (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum) << endl;
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

const int Start = 0;
const int Intro = 1;
const int Ready = 2;
const int Set = 3;
const int Brake = 4;
const int Release = 5;

float xCoordinates[256];
float yCoordinates[256];
int numCoordinates = 0;
time_t nextUpdate = 0;
const char* triggerType = "Trigger";

string hintFile = "";

int hintGroups[256];
int hintPhases[256];
float hintDistances[256];
string hintSounds[256];
time_t lastHintsUpdate = 0;
int lastLap = 0;
int lastHint = -1;
int lastGroup = 0;
int lastPhase = Start;

void checkCoordinates() {
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	if (time(NULL) > nextUpdate) {
		float velocityX = pf->velocity[0];
		float velocityY = pf->velocity[2];
		float velocityZ = pf->velocity[1];

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int carID = gf->playerCarID;

			for (int i = 0; i < gf->activeCars; i++)
				if (gf->carID[i] == carID) {
					carID = i;

					break;
				}

			float coordinateX = gf->carCoordinates[carID][0];
			float coordinateY = gf->carCoordinates[carID][2];
			
			if (strcmp(triggerType, "Trigger") == 0) {
				for (int i = 0; i < numCoordinates; i++) {
					if (abs(xCoordinates[i] - coordinateX) < 20 && abs(yCoordinates[i] - coordinateY) < 20) {
						char buffer[60] = "";
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
				if (lastLap != gf->completedLaps) {
					lastLap = gf->completedLaps;

					lastHint = -1;
					lastGroup = 0;
					lastPhase = Start;
				}

				int bestHint = -1;
				float bestDistance = 99999;

				for (int i = lastHint + 1; i < numCoordinates; i += 1)
				{
					float curDistance = (float)vectorLength(xCoordinates[i] - coordinateX, yCoordinates[i] - coordinateY);

					if ((curDistance < hintDistances[i]) && (curDistance < bestDistance))
					{
						bestHint = i;
						bestDistance = curDistance;
					}
				}

				if (bestHint > lastHint) {
					int phase = hintPhases[bestHint];
					int group = hintGroups[bestHint];

					if ((lastHint > -1) || (phase == Intro)) {
						if ((lastGroup != group) && (phase != Intro))
							return;
						else if ((phase <= lastPhase) && (phase != Intro))
							return;

						lastHint = bestHint;
						lastGroup = group;
						lastPhase = phase;

						if (audioDevice != "")
						{
							if (player != "")
								playSound(hintSounds[bestHint], false);
							else
								sendTriggerMessage("acousticFeedback:" + hintSounds[bestHint]);

							nextUpdate = time(NULL) + 1;
						}
						else {
							char* sound = (char*)hintSounds[bestHint].c_str();

							PlaySoundA(NULL, NULL, SND_FILENAME | SND_ASYNC);
							PlaySoundA(sound, NULL, SND_FILENAME | SND_ASYNC);
						}

						if (lastPhase >= Brake)
							lastPhase = Start;
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
			string line;

			while (std::getline(infile, line)) {
				auto parts = splitString(line, " ", 6);

				hintGroups[numCoordinates] = atoi(parts[0].c_str());
				if (parts[1] == "Intro" || parts[1] == "intro")
					hintPhases[numCoordinates] = Intro;
				else if (parts[1] == "Ready" || parts[1] == "ready")
					hintPhases[numCoordinates] = Ready;
				else if (parts[1] == "Set" || parts[1] == "set")
					hintPhases[numCoordinates] = Set;
				else if (parts[1] == "Brake" || parts[1] == "brake")
					hintPhases[numCoordinates] = Brake;
				else if (parts[1] == "Release" || parts[1] == "release")
					hintPhases[numCoordinates] = Release;
				xCoordinates[numCoordinates] = (float)atof(parts[2].c_str());
				yCoordinates[numCoordinates] = (float)atof(parts[3].c_str());
				hintDistances[numCoordinates] = (float)atof(parts[4].c_str());
				hintSounds[numCoordinates] = parts[5];

				if (++numCoordinates > 255)
					break;
			}

			lastHint = -1;
			lastGroup = 0;
			lastPhase = Start;
		}
	}
}

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();
	
	bool positionTrigger = false;
	bool trackHints = false;
	bool handlingCalibrator = false;
	bool handlingAnalyzer = false;
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
				audioDevice = atof(argv[4]);

			if (argc > 5)
				player = argv[5];
		}

		handlingCalibrator = (strcmp(argv[1], "-Calibrate") == 0);
		handlingAnalyzer =  handlingCalibrator || (strcmp(argv[1], "-Analyze") == 0);

		if (handlingAnalyzer) {
			dataFile = argv[2];

			if (handlingAnalyzer) {
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

	SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

	long counter = 0;

	while (true) {
		counter += 1;

		if (handlingAnalyzer) {
			if (collectTelemetry(soundsDirectory, audioDevice, handlingCalibrator)) {
				if (remainder(counter, 20) == 0)
					writeTelemetry(handlingCalibrator);

				Sleep(10);
			}
			else
				break;
		}
		else if (positionTrigger) {
			checkCoordinates();

			Sleep(10);
		}
		else if (positionTrigger) {
			loadTrackHints();

			checkCoordinates();

			Sleep(10);
		}
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}