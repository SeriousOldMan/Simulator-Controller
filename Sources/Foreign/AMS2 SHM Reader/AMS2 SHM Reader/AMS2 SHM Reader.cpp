// Used for memory-mapped functionality
#include <windows.h>
#include "sharedmemory.h"

// Used for this example
#include <stdio.h>
#include <conio.h>

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

inline float normalizeKelvin(double value) {
	if (value < 0)
		return 0.0;
	else
		return (value - 273.15);
}

long getRemainingTime(SharedMemory* shm) {
	return normalize(shm->mEventTimeRemaining);
}

long getRemainingLaps(SharedMemory* shm) {
	long time = (long)(shm->mLastLapTime * 1000);

	if (time > 0)
		return (long)(getRemainingTime(shm) / time);
	else
		return 0;
}


int main()
{
	printf("[Session Data]\n");

	// Open the memory-mapped file
	HANDLE fileHandle = OpenFileMappingA(PAGE_READONLY, FALSE, MAP_OBJECT_NAME);
	if (fileHandle == NULL)
	{
		printf("Active=false\n");
		return 1;
	}

	// Get the data structure
	const SharedMemory* sharedData = (SharedMemory*)MapViewOfFile(fileHandle, PAGE_READONLY, 0, 0, sizeof(SharedMemory));
	SharedMemory* localCopy = new SharedMemory;
	if (sharedData == NULL)
	{
		printf("Active=false\n");

		CloseHandle(fileHandle);
		return 1;
	}

	// Ensure we're sync'd to the correct data version
	if (sharedData->mVersion != SHARED_MEMORY_VERSION)
	{
		printf("Active=false\n");

		return 1;
	}


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

		break;
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

	printf("SessionFormat=Time\n");
	printf("SessionTimeRemaining=%ld\n", getRemainingTime(localCopy));
	printf("SessionLapsRemaining=%ld\n", getRemainingLaps(localCopy));

	printf("[Car Data]\n");

	printf("BodyworkDamage=%f, %f, %f, %f, %f\n", 0.0, 0.0, 0.0, 0.0, normalizeDamage(localCopy->mAeroDamage));
	printf("SuspensionDamage=%f, %f, %f, %f\n", normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_LEFT]),
												normalizeDamage(localCopy->mSuspensionDamage[TYRE_FRONT_RIGHT]),
												normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_LEFT]),
												normalizeDamage(localCopy->mSuspensionDamage[TYRE_REAR_RIGHT]));

	printf("TyreCompound=Dry\n");
	printf("TyreCompoundColor=Black\n");

	printf("TyreTemperature=%f, %f, %f, %f\n", localCopy->mTyreTemp[TYRE_FRONT_LEFT],
											   localCopy->mTyreTemp[TYRE_FRONT_RIGHT],
											   localCopy->mTyreTemp[TYRE_REAR_LEFT],
											   localCopy->mTyreTemp[TYRE_REAR_RIGHT]);

	printf("TyrePressure = %f, %f, %f, %f\n", localCopy->mAirPressure[TYRE_FRONT_LEFT],
											  localCopy->mAirPressure[TYRE_FRONT_RIGHT],
											  localCopy->mAirPressure[TYRE_REAR_LEFT],
											  localCopy->mAirPressure[TYRE_REAR_RIGHT]);

	//------------------------------------------------------------------------------

	// Cleanup
	UnmapViewOfFile(sharedData);
	CloseHandle(fileHandle);
	delete localCopy;

	return 0;
}




/*
int main()
{
	// Open the memory-mapped file
	HANDLE fileHandle = OpenFileMappingA( PAGE_READONLY, FALSE, MAP_OBJECT_NAME );
	if (fileHandle == NULL)
	{
		printf( "Could not open file mapping object (%d).\n", GetLastError() );
		return 1;
	}

	// Get the data structure
	const SharedMemory* sharedData = (SharedMemory*)MapViewOfFile( fileHandle, PAGE_READONLY, 0, 0, sizeof(SharedMemory) );
	SharedMemory* localCopy = new SharedMemory;
	if (sharedData == NULL)
	{
		printf( "Could not map view of file (%d).\n", GetLastError() );

		CloseHandle( fileHandle );
		return 1;
	}

	// Ensure we're sync'd to the correct data version
	if ( sharedData->mVersion != SHARED_MEMORY_VERSION )
	{
		printf( "Data version mismatch\n");
		return 1;
	}


	//------------------------------------------------------------------------------
	// TEST DISPLAY CODE
	//------------------------------------------------------------------------------
	unsigned int updateIndex(0);
	unsigned int indexChange(0);
	printf( "ESC TO EXIT\n\n" );
	while (true)
	{
		if ( sharedData->mSequenceNumber % 2 )
		{
			// Odd sequence number indicates, that write into the shared memory is just happening
			continue;
		}

		indexChange = sharedData->mSequenceNumber - updateIndex;
		updateIndex = sharedData->mSequenceNumber;

		//Copy the whole structure before processing it, otherwise the risk of the game writing into it during processing is too high.
		memcpy(localCopy,sharedData,sizeof(SharedMemory));


		if (localCopy->mSequenceNumber != updateIndex )
		{
			// More writes had happened during the read. Should be rare, but can happen.
			continue;
		}

		printf( "Sequence number increase %d, current index %d, previous index %d\n", indexChange, localCopy->mSequenceNumber, updateIndex );

		const bool isValidParticipantIndex = localCopy->mViewedParticipantIndex != -1 && localCopy->mViewedParticipantIndex < localCopy->mNumParticipants && localCopy->mViewedParticipantIndex < STORED_PARTICIPANTS_MAX;
		if ( isValidParticipantIndex )
		{
			const ParticipantInfo& viewedParticipantInfo = localCopy->mParticipantInfo[sharedData->mViewedParticipantIndex];
			printf( "mParticipantName: (%s)\n", viewedParticipantInfo.mName );
			printf( "lap Distance = %f \n", viewedParticipantInfo.mCurrentLapDistance );
		}

		printf( "mGameState: (%d)\n", localCopy->mGameState );
		printf( "mSessionState: (%d)\n", localCopy->mSessionState );
		printf( "mOdometerKM: (%0.2f)\n", localCopy->mOdometerKM );

		system("cls");

		if ( _kbhit() && _getch() == 27 ) // check for escape
		{
			break;
		}
	}
	//------------------------------------------------------------------------------

	// Cleanup
	UnmapViewOfFile( sharedData );
	CloseHandle( fileHandle );
	delete localCopy;

	return 0;
}
*/