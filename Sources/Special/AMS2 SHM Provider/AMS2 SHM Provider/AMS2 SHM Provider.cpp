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

long getRemainingTime(SharedMemory* shm);

long getRemainingLaps(SharedMemory* shm) {
	if (shm->mLapsInEvent > 0) {
		return (long)shm->mLapsInEvent - shm->mParticipantInfo[shm->mViewedParticipantIndex].mLapsCompleted;
	}
	else {
		long time = (long)(shm->mLastLapTime * 1000);

		if (time > 0)
			return (long)(getRemainingTime(shm) / time);
		else
			return 0;
	}
}

long getRemainingTime(SharedMemory* shm) {
	if (shm->mLapsInEvent > 0) {
		return getRemainingLaps(shm) * (long)(shm->mLastLapTime * 1000);
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

	if ((argc > 1) && (strcmp(argv[1], "-Standings") == 0)) {
		printf("[Position Data]\n");

		if (fileHandle == NULL) {
			printf("Active=false\n");

			return 1;
		}

		if (fileHandle == NULL) {
			printf("Car.Count=0\n");
			printf("Driver.Car=0\n");
		}
		else {
			printf("Car.Count=%d\n", localCopy->mNumParticipants);
			printf("Driver.Car=%d\n", localCopy->mViewedParticipantIndex + 1);

			for (int i = 1; i <= localCopy->mNumParticipants; ++i) {
				ParticipantInfo vehicle = localCopy->mParticipantInfo[i - 1];

				printf("Car.%d.Nr=%d\n", i, i);
				printf("Car.%d.Position=%d\n", i, vehicle.mRacePosition);
				printf("Car.%d.Lap=%d\n", i, vehicle.mLapsCompleted);
				printf("Car.%d.Lap.Running=%f\n", i, vehicle.mCurrentLapDistance / localCopy->mTrackLength);
				printf("Car.%d.Lap.Valid=%s\n", i, localCopy->mLapsInvalidated[i - 1] ? "false" : "true");
				printf("Car.%d.Time=%ld\n", i, (long)(localCopy->mLastLapTimes[i - 1] * 1000));
				printf("Car.%d.Time.Sectors=%ld,%ld,%ld\n", i, (long)(localCopy->mCurrentSector1Times[i - 1] * 1000),
															   (long)(localCopy->mCurrentSector2Times[i - 1] * 1000),
															   (long)(localCopy->mCurrentSector3Times[i - 1] * 1000));
															   	
				printf("Car.%d.Car=%s\n", i, localCopy->mCarNames[i - 1]);

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
			}
		}
	}
	else {
		printf("[Session Data]\n");

		if (fileHandle == NULL) {
			printf("Active=false\n");

			return 1;
		}

		printf("Active=true\n");
		printf("Paused=%s\n", (localCopy->mGameState == GAME_INGAME_PAUSED) ? "true" : "false");

		if ((localCopy->mSessionState == SESSION_FORMATION_LAP) || (localCopy->mSessionState == SESSION_RACE))
			printf("Session=Race\n");
		else if (localCopy->mSessionState == SESSION_QUALIFY)
			printf("Session=Qualification\n");
		else if (localCopy->mSessionState == SESSION_PRACTICE)
			printf("Session=Practice\n");
		else
			printf("Session=Other\n");

		printf("Car=%s\n", localCopy->mCarName);
		printf("Track=%s-%s\n", localCopy->mTrackLocation, localCopy->mTrackVariation);
		printf("FuelAmount=%d\n", (int)localCopy->mFuelCapacity);

		printf("SessionFormat=%s\n", (localCopy->mLapsInEvent == 0) ? "Time" : "Lap");
		printf("SessionTimeRemaining=%ld\n", getRemainingTime(localCopy));
		printf("SessionLapsRemaining=%ld\n", getRemainingLaps(localCopy));

		printf("[Car Data]\n");

		printf("MAP=n/a\n");
		printf("TC=n/a\n");
		printf("ABS=n/a\n");

		printf("BodyworkDamage=%f, %f, %f, %f, %f\n", 0.0, 0.0, 0.0, 0.0, normalizeDamage(localCopy->mAeroDamage));
		printf("SuspensionDamage=%f, %f, %f, %f\n", normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_LEFT]),
			normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_RIGHT]),
			normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_LEFT]),
			normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_RIGHT]));
		printf("FuelRemaining=%f\n", localCopy->mFuelLevel * localCopy->mFuelCapacity);

		printf("TyreTemperature=%f,%f,%f,%f\n", localCopy->mTyreTemp[TYRE_FRONT_LEFT],
			localCopy->mTyreTemp[TYRE_FRONT_RIGHT],
			localCopy->mTyreTemp[TYRE_REAR_LEFT],
			localCopy->mTyreTemp[TYRE_REAR_RIGHT]);

		printf("TyrePressure=%f,%f,%f,%f\n", localCopy->mAirPressure[TYRE_FRONT_LEFT] / 10,
			localCopy->mAirPressure[TYRE_FRONT_RIGHT] / 10,
			localCopy->mAirPressure[TYRE_REAR_LEFT] / 10,
			localCopy->mAirPressure[TYRE_REAR_RIGHT] / 10);

		printf("TyreWear=%d,%d,%d,%d\n", (int)round(localCopy->mTyreWear[TYRE_FRONT_LEFT] * 100),
			(int)round(localCopy->mTyreWear[TYRE_FRONT_RIGHT] * 100),
			(int)round(localCopy->mTyreWear[TYRE_REAR_LEFT] * 100),
			(int)round(localCopy->mTyreWear[TYRE_REAR_RIGHT] * 100));

		printf("[Stint Data]\n");

		char* name = localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mName;

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

		printf("LapValid=%s\n", localCopy->mLapInvalidated ? "false" : "true");

		printf("LapLastTime=%ld\n", (long)(normalize(localCopy->mLastLapTime) * 1000));

		if (normalize(localCopy->mBestLapTime) != 0)
			printf("LapBestTime=%ld\n", (long)(normalize(localCopy->mBestLapTime) * 1000));
		else
			printf("LapBestTime=%ld\n", (long)(normalize(localCopy->mLastLapTime) * 1000));

		printf("Sector=%ld\n", (long)normalize(localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mCurrentSector + 1));
		printf("Laps=%ld\n", (long)normalize(localCopy->mParticipantInfo[localCopy->mViewedParticipantIndex].mLapsCompleted));

		long timeRemaining = getRemainingTime(localCopy);

		printf("StintTimeRemaining=%ld\n", timeRemaining);
		printf("DriverTimeRemaining=%ld\n", timeRemaining);
		printf("InPit=%s\n", (localCopy->mPitMode == PIT_MODE_IN_PIT) ? "true" : "false");

		printf("[Track Data]\n");
		printf("Temperature=%f\n", localCopy->mTrackTemperature);
		printf("Grip=Optimum\n");

		for (int id = 0; id < sharedData->mNumParticipants; id++)
			printf("Car.%d.Position=%f,%f\n", id + 1,
											  sharedData->mParticipantInfo[id].mWorldPosition[VEC_X],
											  sharedData->mParticipantInfo[id].mWorldPosition[VEC_Z]);

		char* weather = getWeather(localCopy);

		printf("[Weather Data]\n");
		printf("Temperature=%f\n", localCopy->mAmbientTemperature);
		printf("Weather=%s\n", weather);
		printf("Weather10Min=%s\n", weather);
		printf("Weather30Min=%s\n", weather);
	}

	//------------------------------------------------------------------------------

	// Cleanup
	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}
