// Used for memory-mapped functionality
#include <windows.h>
#include "sharedmemory.h"

// Used for this example
#include <stdio.h>
#include <conio.h>
#include <tgmath.h>

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

bool replace(std::string& str, const std::string& from, const std::string& to) {
	size_t start_pos = str.find(from);
	if (start_pos == std::string::npos)
		return false;
	str.replace(start_pos, from.length(), to);
	return true;
}

std::string normalizeName(const char* name) {
	std::string result = name;

	replace(result, "/", "");
	replace(result, ":", "");
	replace(result, "*", "");
	replace(result, "?", "");
	replace(result, "<", "");
	replace(result, ">", "");
	replace(result, "|", "");

	return result;
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

char * getWeather(SharedMemory * shm) {
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

std::string getArgument(std::string request, std::string key) {
	if (request.rfind(key + "=") == 0)
		return request.substr(key.length() + 1, request.length() - (key.length() + 1)).c_str();
	else
		return "";
}

std::string getArgument(char* request, std::string key) {
	return getArgument(std::string(request), key);
}

int main(int argc, char* argv[]) {
	// Open the memory-mapped file
	HANDLE fileHandle = OpenFileMappingA(PAGE_READONLY, FALSE, MAP_OBJECT_NAME);

	const SharedMemory* sharedData = NULL;
	SharedMemory* localCopy = NULL;

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

	bool writeStandings = ((argc > 1) && (getArgument(argv[1], "Standings") != ""));
	bool writeTelemetry = !writeStandings;

	if (writeTelemetry) {
		printf("[Session Data]\n");

		if (fileHandle == NULL) {
			printf("Active=false\n");

			return 1;
		}

		printf("Active=true\n");
		printf("Paused=%s\n", ((localCopy->mGameState == GAME_INGAME_PLAYING) || (localCopy->mGameState == GAME_INGAME_INMENU_TIME_TICKING)) ? "false" : "true");

		/*
		if (localCopy->mSessionState != SESSION_PRACTICE && localCopy->mLapsInEvent > 0 &&
			(localCopy->mLapsInEvent - localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mLapsCompleted) <= 0)
			printf("Session=Finished\n");
		else if (localCopy->mHighestFlagColour == FLAG_COLOUR_CHEQUERED)
			printf("Session=Finished\n");
		else */
		if ((localCopy->mSessionState == SESSION_FORMATION_LAP) || (localCopy->mSessionState == SESSION_RACE))
			printf("Session=Race\n");
		else if (localCopy->mSessionState == SESSION_QUALIFY)
			printf("Session=Qualification\n");
		else if ((localCopy->mSessionState == SESSION_PRACTICE) || (localCopy->mSessionState == SESSION_TEST))
			printf("Session=Practice\n");
		else if (localCopy->mSessionState == SESSION_TIME_ATTACK)
			printf("Session=Time Trial\n");
		else
			printf("Session=Other\n");

		printf("Car=%s\n", normalizeName(localCopy->mCarName));
		printf("Track=%s-%s\n", normalizeName(localCopy->mTrackLocation), normalizeName(localCopy->mTrackVariation));
		printf("FuelAmount=%d\n", (int)localCopy->mFuelCapacity);

		printf("SessionFormat=%s\n", (localCopy->mLapsInEvent == 0) ? "Time" : "Laps");
		printf("AdditionalLaps=%d\n", localCopy->mSessionAdditionalLaps);

		/*
		if (localCopy->mSessionState == SESSION_PRACTICE) {
			printf("SessionTimeRemaining=3600000\n");
			printf("SessionLapsRemaining=30\n");
		}
		else {
		*/
		printf("SessionTimeRemaining=%ld\n", getRemainingTime(localCopy));
		printf("SessionLapsRemaining=%ld\n", getRemainingLaps(localCopy));
		/*
		}
		*/

		printf("[Car Data]\n");

		printf("MAP=n/a\n");
		printf("TC=n/a\n");
		printf("ABS=n/a\n");

		printf("BodyworkDamage=%f, %f, %f, %f, %f\n", 0.0, 0.0, 0.0, 0.0, normalizeDamage(localCopy->mAeroDamage));
		printf("SuspensionDamage=%f, %f, %f, %f\n", normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_LEFT]),
			normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_RIGHT]),
			normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_LEFT]),
			normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_RIGHT]));

		double engineDamage = normalizeDamage(localCopy->mEngineDamage);

		printf("EngineDamage=%f\n", (engineDamage > 20) ? round(engineDamage / 10) * 10 : 0);
		printf("FuelRemaining=%f\n", localCopy->mFuelLevel * localCopy->mFuelCapacity);

		printf("TyreTemperature=%f,%f,%f,%f\n", localCopy->mTyreTemp[TYRE_FRONT_LEFT],
			localCopy->mTyreTemp[TYRE_FRONT_RIGHT],
			localCopy->mTyreTemp[TYRE_REAR_LEFT],
			localCopy->mTyreTemp[TYRE_REAR_RIGHT]);

		if (localCopy->mVersion < SHARED_MEMORY_VERSION) {
			printf("TyreInnerTemperature=%f,%f,%f,%f\n", localCopy->mTyreTreadTemp[TYRE_FRONT_LEFT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_FRONT_RIGHT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_REAR_LEFT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_REAR_RIGHT] - 272.15);

			printf("TyreMiddleTemperature=%f,%f,%f,%f\n", localCopy->mTyreTreadTemp[TYRE_FRONT_LEFT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_FRONT_RIGHT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_REAR_LEFT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_REAR_RIGHT] - 272.15);

			printf("TyreOuterTemperature=%f,%f,%f,%f\n", localCopy->mTyreTreadTemp[TYRE_FRONT_LEFT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_FRONT_RIGHT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_REAR_LEFT] - 272.15,
				localCopy->mTyreTreadTemp[TYRE_REAR_RIGHT] - 272.15);
		}
		else {
			printf("TyreCompoundRaw=%s\n", localCopy->mTyreCompound[TYRE_FRONT_LEFT]);
			printf("TyreCompoundRawFL=%s\n", localCopy->mTyreCompound[TYRE_FRONT_LEFT]);
			printf("TyreCompoundRawFR=%s\n", localCopy->mTyreCompound[TYRE_FRONT_RIGHT]);
			printf("TyreCompoundRawRL=%s\n", localCopy->mTyreCompound[TYRE_REAR_LEFT]);
			printf("TyreCompoundRawRR=%s\n", localCopy->mTyreCompound[TYRE_REAR_RIGHT]);

			printf("TyreInnerTemperature=%f,%f,%f,%f\n", localCopy->mTyreTempRight[TYRE_FRONT_LEFT],
				localCopy->mTyreTempLeft[TYRE_FRONT_RIGHT],
				localCopy->mTyreTempRight[TYRE_REAR_LEFT],
				localCopy->mTyreTempLeft[TYRE_REAR_RIGHT]);

			printf("TyreMiddleTemperature=%f,%f,%f,%f\n", localCopy->mTyreTempCenter[TYRE_FRONT_LEFT],
				localCopy->mTyreTempCenter[TYRE_FRONT_RIGHT],
				localCopy->mTyreTempCenter[TYRE_REAR_LEFT],
				localCopy->mTyreTempCenter[TYRE_REAR_RIGHT]);

			printf("TyreOuterTemperature=%f,%f,%f,%f\n", localCopy->mTyreTempLeft[TYRE_FRONT_LEFT],
				localCopy->mTyreTempRight[TYRE_FRONT_RIGHT],
				localCopy->mTyreTempLeft[TYRE_REAR_LEFT],
				localCopy->mTyreTempRight[TYRE_REAR_RIGHT]);
		}

		printf("TyrePressure=%f,%f,%f,%f\n", localCopy->mAirPressure[TYRE_FRONT_LEFT] / 100 * 14.5,
			localCopy->mAirPressure[TYRE_FRONT_RIGHT] / 100 * 14.5,
			localCopy->mAirPressure[TYRE_REAR_LEFT] / 100 * 14.5,
			localCopy->mAirPressure[TYRE_REAR_RIGHT] / 100 * 14.5);

		printf("TyreWear=%d,%d,%d,%d\n", (int)round(localCopy->mTyreWear[TYRE_FRONT_LEFT] * 100),
			(int)round(localCopy->mTyreWear[TYRE_FRONT_RIGHT] * 100),
			(int)round(localCopy->mTyreWear[TYRE_REAR_LEFT] * 100),
			(int)round(localCopy->mTyreWear[TYRE_REAR_RIGHT] * 100));

		printf("BrakeTemperature=%f,%f,%f,%f\n", localCopy->mBrakeTempCelsius[TYRE_FRONT_LEFT],
			localCopy->mBrakeTempCelsius[TYRE_FRONT_RIGHT],
			localCopy->mBrakeTempCelsius[TYRE_REAR_LEFT],
			localCopy->mBrakeTempCelsius[TYRE_REAR_RIGHT]);

		printf("BrakeWear=%d,%d,%d,%d\n", (int)round(localCopy->mBrakeDamage[TYRE_FRONT_LEFT] * 100),
			(int)round(localCopy->mBrakeDamage[TYRE_FRONT_RIGHT] * 100),
			(int)round(localCopy->mBrakeDamage[TYRE_REAR_LEFT] * 100),
			(int)round(localCopy->mBrakeDamage[TYRE_REAR_RIGHT] * 100));

		if ((int)round(localCopy->mWaterTempCelsius))
			printf("WaterTemperature=%d\n", (int)round(localCopy->mWaterTempCelsius));

		if ((int)round(localCopy->mOilTempCelsius))
			printf("OilTemperature=%d\n", (int)round(localCopy->mOilTempCelsius));

		printf("[Stint Data]\n");

		char name[100];

		strcpy(name, localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mName);

		if (strchr(name, ' ')) {
			char forName[100];
			char surName[100];
			char nickName[3];

			size_t length = strcspn(name, " ");

			substring((char*)name, forName, 0, length);
			substring((char*)name, surName, length + 1, strlen((char*)name) - length - 1);
			nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

			printf("DriverForname=%s\n", forName);
			printf("DriverSurname=%s\n", surName);
			printf("DriverNickname=%s\n", nickName);
		}
		else {
			printf("DriverForname=%s\n", name);
			printf("DriverSurname=%s\n", "");
			printf("DriverNickname=%s\n", "");
		}

		printf("Position=%ld\n", (long)localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mRacePosition);

		printf("LapValid=%s\n", localCopy->mLapInvalidated ? "false" : "true");

		printf("LapLastTime=%ld\n", (long)(normalize(localCopy->mLastLapTime) * 1000));

		if (normalize(localCopy->mBestLapTime) != 0)
			printf("LapBestTime=%ld\n", (long)(normalize(localCopy->mBestLapTime) * 1000));
		else
			printf("LapBestTime=%ld\n", (long)(normalize(localCopy->mLastLapTime) * 1000));

		printf("Sector=%ld\n", (long)normalize(localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mCurrentSector + 1));
		printf("Laps=%ld\n", (long)normalize(localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mLapsCompleted));

		long timeRemaining = getRemainingTime(localCopy);

		/*
		if (localCopy->mSessionState == SESSION_PRACTICE) {
			printf("StintTimeRemaining=3600000\n");
			printf("DriverTimeRemaining=3600000\n");
		}
		else {
		*/
			printf("StintTimeRemaining=%ld\n", timeRemaining);
			printf("DriverTimeRemaining=%ld\n", timeRemaining);
		/*
		}
		*/
		printf("InPit=%s\n", (localCopy->mPitMode == PIT_MODE_IN_PIT) ? "true" : "false");
		printf("InPitLane=%s\n", (localCopy->mPitMode > PIT_MODE_NONE) ? "true" : "false");

		printf("[Track Data]\n");
		printf("Length=%f\n", localCopy->mTrackLength);
		printf("Temperature=%f\n", localCopy->mTrackTemperature);
		printf("Grip=Optimum\n");

		for (int id = 0; id < sharedData->mNumParticipants; id++)
			printf("Car.%d.Position=%f,%f\n", id + 1,
											  sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
											  - sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z]);

		char* weather = getWeather(localCopy);

		printf("[Weather Data]\n");
		printf("Temperature=%f\n", localCopy->mAmbientTemperature);
		printf("Weather=%s\n", weather);
		printf("Weather10Min=%s\n", weather);
		printf("Weather30Min=%s\n", weather);
	}

	if (writeStandings) {
		printf("[Position Data]\n");

		if (fileHandle == NULL) {
			printf("Active=false\n");

			return 1;
		}

		if (fileHandle == NULL) {
			printf("Active=false\n");
			printf("Car.Count=0\n");
			printf("Driver.Car=0\n");
		}
		else {
			int count = localCopy->mNumParticipants;
			
			printf("Driver.Car=%d\n", localCopy->mViewedParticipantIndex + 1);

			for (int i = 1; i <= localCopy->mNumParticipants; ++i) {
				ParticipantInfo vehicle = localCopy->mParticipantInfo[i - 1];

				if (strcmp(localCopy->mCarClassNames[i - 1], "SafetyCar") == 0 && localCopy->mNumParticipants == i) {
					count -= 1;
					
					break;
				}

				printf("Car.%d.Nr=%d\n", i, i);
				printf("Car.%d.Class=%s\n", i, localCopy->mCarClassNames[i - 1]);
				printf("Car.%d.Position=%d\n", i, vehicle.mRacePosition);
				printf("Car.%d.Laps=%d\n", i, vehicle.mLapsCompleted);
				printf("Car.%d.Lap.Running=%f\n", i, vehicle.mCurrentLapDistance / localCopy->mTrackLength);
				printf("Car.%d.Lap.Running.Valid=%s\n", i, localCopy->mLapsInvalidated[i - 1] ? "false" : "true");
				printf("Car.%d.Time=%ld\n", i, (long)(localCopy->mLastLapTimes[i - 1] * 1000));
				printf("Car.%d.Time.Sectors=%ld,%ld,%ld\n", i, (long)(localCopy->mCurrentSector1Times[i - 1] * 1000),
					(long)(localCopy->mCurrentSector2Times[i - 1] * 1000),
					(long)(localCopy->mCurrentSector3Times[i - 1] * 1000));

				printf("Car.%d.Car=%s\n", i, normalizeName(localCopy->mCarNames[i - 1]));

				char* name = (char*)vehicle.mName;

				if (strchr((char*)name, ' ')) {
					char forName[100];
					char surName[100];
					char nickName[3];

					size_t length = strcspn(name, " ");

					substring(name, forName, 0, length);
					substring(name, surName, length + 1, strlen(name) - length - 1);
					nickName[0] = forName[0], nickName[1] = surName[0], nickName[2] = '\0';

					printf("Car.%d.Driver.Forname=%s\n", i, forName);
					printf("Car.%d.Driver.Surname=%s\n", i, surName);
					printf("Car.%d.Driver.Nickname=%s\n", i, nickName);
				}
				else {
					printf("Car.%d.Driver.Forname=%s\n", i, name);
					printf("Car.%d.Driver.Surname=%s\n", i, "");
					printf("Car.%d.Driver.Nickname=%s\n", i, "");
				}

				printf("Car.%d.InPitLane=%s\n", i, localCopy->mPitModes[i - 1] > PIT_MODE_NONE ? "true" : "false");
				printf("Car.%d.InPit=%s\n", i, localCopy->mPitModes[i - 1] > PIT_MODE_IN_PIT ? "true" : "false");
			}
			
			printf("Car.Count=%d\n", count);
		}
	}

	//------------------------------------------------------------------------------

	// Cleanup
	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}
