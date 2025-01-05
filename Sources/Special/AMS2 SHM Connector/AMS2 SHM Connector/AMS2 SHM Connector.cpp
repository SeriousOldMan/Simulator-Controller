// Used for memory-mapped functionality
#include <windows.h>
#include "sharedmemory.h"

// Used for this example
#include <stdio.h>
#include <conio.h>
#include <tgmath.h>
#include <iostream>
#include <sstream>

// Name of the pCars memory mapped file
#define MAP_OBJECT_NAME "$pcars2$"

inline double normalize(double value) {
	return (value < 0) ? 0.0 : value;
}

inline double normalizeDamage(double value) {
	if (value < 0)
		return 0.0;
	else
		return (value * 100);
}

inline double normalizeKelvin(double value) {
	if (value < 0)
		return 0.0;
	else
		return (value - 273.15);
}

long getRemainingTime(SharedMemory* shm);

long getRemainingLaps(SharedMemory* shm) {
	if (shm->mSessionState == SESSION_PRACTICE && shm->mEventTimeRemaining == -1)
		return 360;

	if (shm->mSessionState != SESSION_PRACTICE && shm->mLapsInEvent > 0) {
		return (long)shm->mLapsInEvent - shm->mParticipantInfo[shm->mViewedParticipantIndex].mLapsCompleted;
	}
	else {
		long time = (shm->mSessionState != SESSION_PRACTICE) ? (long)(shm->mLastLapTime * 1000) : (long)(shm->mBestLapTime * 1000);

		if (time > 0)
			return (long)(getRemainingTime(shm) / time);
		else
			return 0;
	}
}

long getRemainingTime(SharedMemory* shm) {
	if (shm->mSessionState == SESSION_PRACTICE && shm->mEventTimeRemaining == -1)
		return 3600000 * 12;

	if (shm->mSessionState != SESSION_PRACTICE && shm->mLapsInEvent > 0) {
		long time = getRemainingLaps(shm) * (long)(shm->mLastLapTime * 1000);

		if (time > 0)
			return time;
		else
			return 0;
	}
	else
		return normalize(shm->mEventTimeRemaining) * 1000;
}

const char * getWeather(SharedMemory * shm) {
	float rainLevel = shm->mRainDensity;

	if (rainLevel <= 0.1)
		return "Dry";
	else if (rainLevel <= 0.2)
		return "Drizzle";
	else if (rainLevel <= 0.4)
		return "LightRain";
	else if (rainLevel <= 0.6)
		return "MediumRain";
	else if (rainLevel <= 0.8)
		return "HeavyRain";
	else
		return "Thunderstorm";
}

void substring(char s[], char sub[], int p, int l) {
	int c = 0;

	while (c < l) {
		sub[c] = s[p + c];

		c++;
	}
	sub[c] = '\0';
}

void print(std::ostringstream* output, std::string value) {
	(*output) << value;
}

void print(std::ostringstream* output, double value) {
	(*output) << value;
}

void print(std::ostringstream* output, int value) {
	(*output) << value;
}

void print(std::ostringstream* output, long value) {
	(*output) << value;
}

void print(std::ostringstream* output, std::string value1, std::string value2) {
	(*output) << value1 << value2;
}

void print(std::ostringstream* output, std::string value1, double value2) {
	(*output) << value1 << value2;
}

void print(std::ostringstream* output, std::string value1, int value2) {
	(*output) << value1 << value2;
}

void print(std::ostringstream* output, std::string value1, long value2) {
	(*output) << value1 << value2;
}

void printLine(std::ostringstream* output) {
	(*output) << std::endl;
}

void printLine(std::ostringstream* output, std::string value) {
	(*output) << value << std::endl;
}

void printLine(std::ostringstream* output, std::string value1, std::string value2) {
	(*output) << value1 << value2 << std::endl;
}

void printLine(std::ostringstream* output, std::string value1, double value2) {
	(*output) << value1 << value2 << std::endl;
}

void printLine(std::ostringstream* output, std::string value1, int value2) {
	(*output) << value1 << value2 << std::endl;
}

void printLine(std::ostringstream* output, std::string value1, long value2) {
	(*output) << value1 << value2 << std::endl;
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

HANDLE fileHandle = NULL;
const SharedMemory* sharedData = NULL;
SharedMemory* localCopy = NULL;

extern "C" __declspec(dllexport) int __stdcall open() {
	fileHandle = OpenFileMappingA(PAGE_READONLY, FALSE, MAP_OBJECT_NAME);

	return (fileHandle ? 0 : -1);
}

extern "C" __declspec(dllexport) int __stdcall close() {
	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}

extern "C" __declspec(dllexport) int __stdcall call(char* request, char* result, int size) {
	std::ostringstream output;

	if (fileHandle != NULL) {
		sharedData = (SharedMemory*)MapViewOfFile(fileHandle, PAGE_READONLY, 0, 0, sizeof(SharedMemory));
		localCopy = new SharedMemory;
	
		if (sharedData == NULL) {
			CloseHandle(fileHandle);

			fileHandle = NULL;
		}
		else {
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

				break;
			}
		}
	}

	bool writeStandings = (getArgument(request, "Standings") != "");
	bool writeTelemetry = !writeStandings;

	if (writeTelemetry) {
		printLine(&output, "[Session Data]");

		if (fileHandle == NULL) {
			printLine(&output, "Active=false");

			strcpy_s(result, size, output.str().c_str());

			return -1;
		}

		printLine(&output, "Active=true");
		printLine(&output, "Paused=", ((localCopy->mGameState == GAME_INGAME_PLAYING) || (localCopy->mGameState == GAME_INGAME_INMENU_TIME_TICKING)) ? "false" : "true");

		/* if (localCopy->mSessionState != SESSION_PRACTICE && localCopy->mLapsInEvent > 0 &&
			(localCopy->mLapsInEvent - localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mLapsCompleted) <= 0)
			printLine(&output, "Session=Finished");
		else */
		if ((localCopy->mSessionState == SESSION_FORMATION_LAP) || (localCopy->mSessionState == SESSION_RACE))
			printLine(&output, "Session=Race");
		else if (localCopy->mSessionState == SESSION_QUALIFY)
			printLine(&output, "Session=Qualification");
		else if ((localCopy->mSessionState == SESSION_PRACTICE) || (localCopy->mSessionState == SESSION_TEST))
			printLine(&output, "Session=Practice");
		else if (localCopy->mSessionState == SESSION_TIME_ATTACK)
			printLine(&output, "Session=Time Trial");
		else
			printLine(&output, "Session=Other");

		printLine(&output, "Car=", localCopy->mCarName);
		print(&output, "Track=", localCopy->mTrackLocation); print(&output, "-");  printLine(&output, localCopy->mTrackVariation);
		printLine(&output, "FuelAmount=", (int)localCopy->mFuelCapacity);

		printLine(&output, "SessionFormat=", (localCopy->mLapsInEvent == 0) ? "Time" : "Laps");

		printLine(&output, "SessionTimeRemaining=", getRemainingTime(localCopy));
		printLine(&output, "SessionLapsRemaining=", getRemainingLaps(localCopy));
		
		printLine(&output, "[Car Data]");

		printLine(&output, "MAP=n/a");
		printLine(&output, "TC=n/a");
		printLine(&output, "ABS=n/a");

		print(&output, "BodyworkDamage=", 0.0); print(&output, ",", 0.0); print(&output, ",", 0.0); print(&output, ",", 0.0); printLine(&output, ",", normalizeDamage(localCopy->mAeroDamage));

		print(&output, "SuspensionDamage=", normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_LEFT]));
		print(&output, ",", normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_RIGHT]));
		print(&output, ",", normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_LEFT]));
		printLine(&output, ",", normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_RIGHT]));

		double engineDamage = normalizeDamage(localCopy->mEngineDamage);

		printLine(&output, "EngineDamage=", (engineDamage > 20) ? round(engineDamage / 10) * 10 : 0);
		printLine(&output, "FuelRemaining=", localCopy->mFuelLevel* localCopy->mFuelCapacity);

		print(&output, "TyreTemperature=", localCopy->mTyreTemp[TYRE_FRONT_LEFT]);
		print(&output, ",", localCopy->mTyreTemp[TYRE_FRONT_RIGHT]);
		print(&output, ",", localCopy->mTyreTemp[TYRE_REAR_LEFT]);
		printLine(&output, ",", localCopy->mTyreTemp[TYRE_REAR_RIGHT]);

		if (localCopy->mVersion < SHARED_MEMORY_VERSION) {
			print(&output, "TyreInnerTemperature=", localCopy->mTyreTreadTemp[TYRE_FRONT_LEFT] - 272.15);
			print(&output, ",", localCopy->mTyreTreadTemp[TYRE_FRONT_RIGHT] - 272.15);
			print(&output, ",", localCopy->mTyreTreadTemp[TYRE_REAR_LEFT] - 272.15);
			printLine(&output, ",", localCopy->mTyreTreadTemp[TYRE_REAR_RIGHT] - 272.15);

			print(&output, "TyreMiddleTemperature=", localCopy->mTyreTreadTemp[TYRE_FRONT_LEFT] - 272.15);
			print(&output, ",", localCopy->mTyreTreadTemp[TYRE_FRONT_RIGHT] - 272.15);
			print(&output, ",", localCopy->mTyreTreadTemp[TYRE_REAR_LEFT] - 272.15);
			printLine(&output, ",", localCopy->mTyreTreadTemp[TYRE_REAR_RIGHT] - 272.15);

			print(&output, "TyreOuterTemperature=", localCopy->mTyreTreadTemp[TYRE_FRONT_LEFT] - 272.15);
			print(&output, ",", localCopy->mTyreTreadTemp[TYRE_FRONT_RIGHT] - 272.15);
			print(&output, ",", localCopy->mTyreTreadTemp[TYRE_REAR_LEFT] - 272.15);
			printLine(&output, ",", localCopy->mTyreTreadTemp[TYRE_REAR_RIGHT] - 272.15);
		}
		else {
			printLine(&output, "TyreCompoundRaw=", localCopy->mTyreCompound[TYRE_FRONT_LEFT]);
			printLine(&output, "TyreCompoundRawFL=", localCopy->mTyreCompound[TYRE_FRONT_LEFT]);
			printLine(&output, "TyreCompoundRawFR=", localCopy->mTyreCompound[TYRE_FRONT_RIGHT]);
			printLine(&output, "TyreCompoundRawRL=", localCopy->mTyreCompound[TYRE_REAR_LEFT]);
			printLine(&output, "TyreCompoundRawRR=", localCopy->mTyreCompound[TYRE_REAR_RIGHT]);

			print(&output, "TyreInnerTemperature=", localCopy->mTyreTempRight[TYRE_FRONT_LEFT]);
			print(&output, ",", localCopy->mTyreTempLeft[TYRE_FRONT_RIGHT]);
			print(&output, ",", localCopy->mTyreTempRight[TYRE_REAR_LEFT]);
			printLine(&output, ",", localCopy->mTyreTempLeft[TYRE_REAR_RIGHT]);

			print(&output, "TyreMiddleTemperature=", localCopy->mTyreTempCenter[TYRE_FRONT_LEFT]);
			print(&output, ",", localCopy->mTyreTempCenter[TYRE_FRONT_RIGHT]);
			print(&output, ",", localCopy->mTyreTempCenter[TYRE_REAR_LEFT]);
			printLine(&output, ",", localCopy->mTyreTempCenter[TYRE_REAR_RIGHT]);

			print(&output, "TyreOuterTemperature=", localCopy->mTyreTempLeft[TYRE_FRONT_LEFT]);
			print(&output, ",", localCopy->mTyreTempRight[TYRE_FRONT_RIGHT]);
			print(&output, ",", localCopy->mTyreTempLeft[TYRE_REAR_LEFT]);
			printLine(&output, ",", localCopy->mTyreTempRight[TYRE_REAR_RIGHT]);
		}

		print(&output, "TyrePressure=", localCopy->mAirPressure[TYRE_FRONT_LEFT] / 100 * 14.5);
		print(&output, ",", localCopy->mAirPressure[TYRE_FRONT_RIGHT] / 100 * 14.5);
		print(&output, ",", localCopy->mAirPressure[TYRE_REAR_LEFT] / 100 * 14.5);
		printLine(&output, ",", localCopy->mAirPressure[TYRE_REAR_RIGHT] / 100 * 14.5);

		print(&output, "TyreWear=", (int)round(localCopy->mTyreWear[TYRE_FRONT_LEFT] * 100));
		print(&output, ",", (int)round(localCopy->mTyreWear[TYRE_FRONT_RIGHT] * 100));
		print(&output, ",", (int)round(localCopy->mTyreWear[TYRE_REAR_LEFT] * 100));
		printLine(&output, ",", (int)round(localCopy->mTyreWear[TYRE_REAR_RIGHT] * 100));

		print(&output, "BrakeTemperature=", localCopy->mBrakeTempCelsius[TYRE_FRONT_LEFT]);
		print(&output, ",", localCopy->mBrakeTempCelsius[TYRE_FRONT_RIGHT]);
		print(&output, ",", localCopy->mBrakeTempCelsius[TYRE_REAR_LEFT]);
		printLine(&output, ",", localCopy->mBrakeTempCelsius[TYRE_REAR_RIGHT]);

		print(&output, "BrakeWear=", (int)round(localCopy->mBrakeDamage[TYRE_FRONT_LEFT] * 100));
		print(&output, ",", (int)round(localCopy->mBrakeDamage[TYRE_FRONT_RIGHT] * 100));
		print(&output, ",", (int)round(localCopy->mBrakeDamage[TYRE_REAR_LEFT] * 100));
		printLine(&output, ",", (int)round(localCopy->mBrakeDamage[TYRE_REAR_RIGHT] * 100));

		printLine(&output, "[Stint Data]");

		char name[100];

		strcpy_s(name, 100, localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mName);

		if (strchr(name, ' ')) {
			char forName[100];
			char surName[100];
			char nickName[3];

			size_t length = strcspn(name, " ");

			substring(name, forName, 0, length);
			substring(name, surName, length + 1, strlen(name) - length - 1);
			nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

			printLine(&output, "DriverForname=", forName);
			printLine(&output, "DriverSurname=", surName);
			printLine(&output, "DriverNickname=", nickName);
		}
		else {
			printLine(&output, "DriverForname=", name);
			printLine(&output, "DriverSurname=", "");
			printLine(&output, "DriverNickname=", "");
		}

		printLine(&output, "Position=", (long)localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mRacePosition);

		printLine(&output, "LapValid=", localCopy->mLapInvalidated ? "false" : "true");

		printLine(&output, "LapLastTime=", (long)(normalize(localCopy->mLastLapTime) * 1000));

		if (normalize(localCopy->mBestLapTime) != 0)
			printLine(&output, "LapBestTime=", (long)(normalize(localCopy->mBestLapTime) * 1000));
		else
			printLine(&output, "LapBestTime=", (long)(normalize(localCopy->mLastLapTime) * 1000));

		printLine(&output, "Sector=", (long)normalize(localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mCurrentSector + 1));
		printLine(&output, "Laps=", (long)normalize(localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mLapsCompleted));

		long timeRemaining = getRemainingTime(localCopy);

		printLine(&output, "StintTimeRemaining=", timeRemaining);
		printLine(&output, "DriverTimeRemaining=", timeRemaining);
		
		printLine(&output, "InPit=", (localCopy->mPitMode == PIT_MODE_IN_PIT) ? "true" : "false");

		printLine(&output, "[Track Data]");
		printLine(&output, "Length=", localCopy->mTrackLength);
		printLine(&output, "Temperature=", localCopy->mTrackTemperature);
		printLine(&output, "Grip=Optimum");

		for (int id = 0; id < sharedData->mNumParticipants; id++) {
			print(&output, "Car.", id + 1);
			print(&output, ".Position=", sharedData->mParticipantInfo[id].mWorldPosition[VEC_X]);
			printLine(&output, ",", -sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z]);
		}

		const char* weather = getWeather(localCopy);

		printLine(&output, "[Weather Data]");
		printLine(&output, "Temperature=", localCopy->mAmbientTemperature);
		printLine(&output, "Weather=", weather);
		printLine(&output, "Weather10Min=", weather);
		printLine(&output, "Weather30Min=", weather);
	}

	if (writeStandings) {
		printLine(&output, "[Position Data]");

		if (fileHandle == NULL) {
			printLine(&output, "Active=false");

			strcpy_s(result, size, output.str().c_str());

			return 1;
		}

		if (fileHandle == NULL) {
			printLine(&output, "Active=false");
			printLine(&output, "Car.Count=0");
			printLine(&output, "Driver.Car=0");
		}
		else {
			int count = localCopy->mNumParticipants;
			
			printLine(&output, "Driver.Car=", localCopy->mViewedParticipantIndex + 1);

			for (int i = 1; i <= localCopy->mNumParticipants; ++i) {
				ParticipantInfo vehicle = localCopy->mParticipantInfo[i - 1];

				if (strcmp(localCopy->mCarClassNames[i - 1], "SafetyCar") == 0 && localCopy->mNumParticipants == i) {
					count -= 1;
					
					break;
				}
				
				print(&output, "Car.", i); printLine(&output, ".Nr=", i);
				print(&output, "Car.", i); printLine(&output, ".Class=", localCopy->mCarClassNames[i - 1]);
				print(&output, "Car.", i); printLine(&output, ".Position=", (long)vehicle.mRacePosition);
				print(&output, "Car.", i); printLine(&output, ".Laps=", (long)vehicle.mLapsCompleted);
				print(&output, "Car.", i); printLine(&output, ".Lap.Running=", vehicle.mCurrentLapDistance / localCopy->mTrackLength);
				print(&output, "Car.", i); printLine(&output, ".Lap.Running.Valid=", localCopy->mLapsInvalidated[i - 1] ? "false" : "true");
				print(&output, "Car.", i); printLine(&output, ".Time=", (long)(localCopy->mLastLapTimes[i - 1] * 1000));
				print(&output, "Car.", i); print(&output, ".Time.Sectors=");
				print(&output, (long)(localCopy->mCurrentSector1Times[i - 1] * 1000)); print(&output, ",");
				print(&output, (long)(localCopy->mCurrentSector2Times[i - 1] * 1000)); print(&output, ",");
				print(&output, (long)(localCopy->mCurrentSector3Times[i - 1] * 1000)); printLine(&output);

				print(&output, "Car.", i); printLine(&output, ".Car=", localCopy->mCarNames[i - 1]);

				char* name = (char*)vehicle.mName;

				if (strchr((char*)name, ' ')) {
					char forName[100];
					char surName[100];
					char nickName[3];

					size_t length = strcspn(name, " ");

					substring(name, forName, 0, length);
					substring(name, surName, length + 1, strlen(name) - length - 1);
					nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

					print(&output, "Car.", i); printLine(&output, ".Driver.Forname=", forName);
					print(&output, "Car.", i); printLine(&output, ".Driver.Surname=", surName);
					print(&output, "Car.", i); printLine(&output, ".Driver.Nickname=", nickName);
				}
				else {
					print(&output, "Car.", i); printLine(&output, ".Driver.Forname=", name);
					print(&output, "Car.", i); printLine(&output, ".Driver.Surname=", "");
					print(&output, "Car.", i); printLine(&output, ".Driver.Nickname=", "");
				}

				print(&output, "Car.", i); printLine(&output, ".InPitLane=", localCopy->mPitModes[i - 1] > PIT_MODE_NONE ? "true" : "false");
				print(&output, "Car.", i); printLine(&output, ".InPit=", localCopy->mPitModes[i - 1] > PIT_MODE_IN_PIT ? "true" : "false");
			}
			
			printLine(&output, "Car.Count=", count);
		}
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