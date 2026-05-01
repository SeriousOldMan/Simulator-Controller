#include "stdafx.h"
#include <stdio.h>
#include <string.h>
#include <vector>
#include <windows.h>
#include <tchar.h>
#include <comdef.h>
#include <iostream>
#include <sstream>
#include <algorithm>
#include "SharedMemoryInterface.hpp"

#pragma optimize("",off)
using namespace std;

HANDLE hParent = NULL;
HANDLE hEvent = NULL;
HANDLE hMapFile = NULL;

void dismiss() {
	if (hMapFile) {
		CloseHandle(hMapFile);
		hMapFile = NULL;
	}
	if (hEvent) {
		CloseHandle(hEvent);
		hEvent = NULL;
	}
	if (hParent) {
		CloseHandle(hParent);
		hParent = NULL;
	}
}

SharedMemoryObjectOut* require(DWORD parentPid) {
	bool retVal = true;

	static SharedMemoryObjectOut copiedMem;

	try {
		std::optional<SharedMemoryLock> smLock = SharedMemoryLock::MakeSharedMemoryLock();

		// Try to open a handle to the parent process with SYNCHRONIZE right.
		// SYNCHRONIZE is enough to wait on the process handle for exit.
		dismiss();

		hParent = OpenProcess(SYNCHRONIZE | PROCESS_QUERY_LIMITED_INFORMATION, FALSE, parentPid);
		hEvent = OpenEventA(SYNCHRONIZE, FALSE, "LMU_Data_Event");
		hMapFile = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, L"LMU_Data");

		if (hParent && hEvent && hMapFile) {
			if (SharedMemoryLayout* pBuf = (SharedMemoryLayout*)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedMemoryLayout))) {
				HANDLE objectHandlesArray[2] = { hParent, hEvent };
				for (DWORD waitObject = WaitForMultipleObjects(2, objectHandlesArray, FALSE, 500); waitObject != WAIT_OBJECT_0; waitObject = WaitForMultipleObjects(2, objectHandlesArray, FALSE, 500)) {
					if (waitObject == WAIT_OBJECT_0 + 1) {
						smLock->Lock();
						CopySharedMemoryObj(copiedMem, pBuf->data);
						smLock->Unlock();
					}
					else
						break;
				}
				UnmapViewOfFile(pBuf);
			}
			else
				retVal = false;
		}
		else
			retVal = false;
	}
	catch (...) {
		retVal = false;
	}

	return retVal ? &copiedMem : NULL;
}

inline string getString(char* str) {
	string s(str);

	return string(s.begin(), s.end());
}

std::vector<std::string> splitString(const std::string& str, const std::string& delimiter, int parts = 9999) {
	std::vector<std::string> tokens;
	size_t start = 0;
	size_t end = 0;

	while ((end = str.find(delimiter, start)) != std::string::npos) {
		tokens.push_back(str.substr(start, end - start));
		start = end + delimiter.length();

		if (--parts <= 1)
			break;
	}

	tokens.push_back(str.substr(start)); // Letzter Teil hinzufügen

	return tokens;
}

inline void trimString(std::string& s) {
	// Remove leading spaces
	s.erase(s.begin(), find_if_not(s.begin(), s.end(),
		[](unsigned char ch) { return isspace(ch); }));
	// Remove trailing spaces
	s.erase(find_if_not(s.rbegin(), s.rend(),
		[](unsigned char ch) { return isspace(ch); }).base(), s.end());
}

void printNAData(string name, long value)
{
	if (value == -1)
		wcout << name.c_str() << "=" << "n/a" << endl;
	else {
		wcout << name.c_str() << "=" << fixed << value << endl;

		wcout.setf(0, ios::floatfield);
	}
}

void printData(string name, float value)
{
	if (round(value) == value) {
		int old_precision = wcout.precision();
		
		wcout.precision(0);

		wcout << name.c_str() << "=" << fixed << value << endl;

		wcout.setf(0, ios::floatfield);

		wcout.precision(old_precision);
	}
	else
		wcout << name.c_str() << "=" << value << endl;
}

void printData(string name, string value)
{
	wcout << name.c_str() << "=" << value.c_str() << endl;
}

template <typename T, unsigned S>
inline void printData(const string name, const T(&v)[S])
{
	wcout << name.c_str() << "=";
    
    for (int i = 0; i < S; i++)
    {
        wcout << v[i];

        if (i < S - 1)
			wcout << ", ";
    }

	wcout << endl;
}

template <typename T, unsigned S, unsigned S2>
inline void printData2(const string name, const T(&v)[S][S2])
{
    wcout << name.c_str() << "=";

    for (int i = 0; i < S; i++)
    {
        wcout << i << ": ";
    
		for (int j = 0; j < S2; j++) {
            wcout << v[i][j];
        
			if (j < S2 - 1)
                wcout << ", ";
        }

		if (i < (S - 1))
			wcout << "; ";
       
    }

	wcout << endl;
}

bool replace(std::string& str, const std::string& from, const std::string& to) {
	size_t start_pos = str.find(from);
	if (start_pos == std::string::npos)
		return false;
	str.replace(start_pos, from.length(), to);
	return true;
}

std::string normalizeName(string result) {
	replace(result, "/", "");
	replace(result, ":", "");
	replace(result, "*", "");
	replace(result, "?", "");
	replace(result, "<", "");
	replace(result, ">", "");
	replace(result, "|", "");

	return result;
}

inline long Normalize(long value) {
	return (value < 0) ? 0 : value;
}

inline double Normalize(double value) {
	return (value < 0) ? 0 : value;
}

inline long Max(long value1, long value2) {
	return (value1 > value2) ? value1 : value2;
}

inline long Min(long value1, long value2) {
	return (value1 < value2) ? value1 : value2;
}

static TelemInfoV01 noTelemetry = TelemInfoV01();

TelemInfoV01* GetVehicleTelemetry(int id, SharedMemoryScoringData* scoring, SharedMemoryTelemetryData* telemetry)
{
	for (int i = 0; i < scoring->scoringInfo.mNumVehicles; ++i)
	{
		if (scoring->scoringInfo.mVehicle[i].mID == id)
			return &telemetry->telemInfo[i];
	}

	return &noTelemetry;
}

double VehicleSpeed(VehicleScoringInfoV01* playerScoring)
{
	TelemVect3 localVel = playerScoring->mLocalVel;

	return sqrt(localVel.x * localVel.x + localVel.y * localVel.y + localVel.z * localVel.z) * 3.6;
}

long GetRemainingTime(SharedMemoryScoringData* scoring, VehicleScoringInfoV01* playerScoring);

long GetRemainingLaps(SharedMemoryScoringData* scoring, VehicleScoringInfoV01* playerScoring) {
	if (playerScoring->mTotalLaps < 1)
		return 0;

	if (scoring->scoringInfo.mEndET <= 0.0) {
		return scoring->scoringInfo.mMaxLaps - playerScoring->mTotalLaps;
	}
	else {
		if (playerScoring->mLastLapTime > 0)
			return (long)round(GetRemainingTime(scoring, playerScoring) / (Normalize(playerScoring->mLastLapTime) * 1000)) + 1;
		else if (playerScoring->mEstimatedLapTime > 0)
			return (long)round(GetRemainingTime(scoring, playerScoring) / (Normalize(playerScoring->mEstimatedLapTime) * 1000)) + 1;
		else
			return 1;
	}
}

long GetRemainingTime(SharedMemoryScoringData* scoring, VehicleScoringInfoV01* playerScoring) {
	if (playerScoring->mTotalLaps < 1)
		return 0;

	if (scoring->scoringInfo.mEndET > 0.0)
	{
		/*
		long time = (long)((scoring.mScoringInfo.mEndET - (Normalize(playerScoring.mLastLapTime) * playerScoring.mTotalLaps)) * 1000);

		if (time > 0)
			return time;
		else
			return 0;
		*/

		return (long)Max(0, scoring->scoringInfo.mEndET - scoring->scoringInfo.mCurrentET) * 1000;
	}
	else
	{
		if (playerScoring->mLastLapTime > 0)
			return (long)(GetRemainingLaps(scoring, playerScoring) * playerScoring->mLastLapTime * 1000);
		else if (playerScoring->mEstimatedLapTime > 0)
			return (long)(GetRemainingLaps(scoring, playerScoring) * playerScoring->mEstimatedLapTime * 1000);
		else
			return (long)(GetRemainingLaps(scoring, playerScoring) * playerScoring->mBestLapTime * 1000);
	}
}

inline double GetCelcius(double kelvin) {
	return kelvin - 273.15;
}

inline double GetPsi(double kPa) {
	return kPa / 6.895;
}

inline double GetKpa(double psi) {
	return psi * 6.895;
}

string GetForname(char* name) {
	string forName = getString(name);

	if (forName.find(" ") != string::npos)
		return splitString(forName, " ")[0];
	else
		return forName;
}

string GetSurname(char* name) {
	string forName = getString(name);

	if (forName.find(" ") != string::npos)
		return splitString(forName, " ")[1];
	else
		return "";
}

string GetNickname(char* name) {
	string forName = getString(name);

	if (forName.find(" ") != string::npos) {
		vector<string> names = splitString(forName, " ");

		return names[0].substr(0, Min(1, names[0].length())) + names[1].substr(0, Min(1, names[1].length()));
	}
	else
		return "";
}

string GetCarNr(int id, string carClass, string carName)
{
	trimString(carName);

	try {
		if (carName.length() > 0)
		{
			if (carName[0] == '#')
			{
				vector<string> parts = splitString(carName, " ", 2);

				string nr = splitString(parts[0], "#")[1];

				trimString(nr);

				return nr;
			}
			else if (carName.find("#")) {
				string nr = splitString(carName, "#")[1];

				trimString(nr);

				nr = splitString(nr, " ")[0];

				trimString(nr);

				return nr;
			}
			else
				return to_string(id + 1);
		}
		else
			return to_string(id + 1);
	}
	catch (...)
	{
		return to_string(id + 1);
	}
}

string GetWeather(double cloudLevel, double rainLevel) {
	if (rainLevel == 0.0)
		return "Dry";
	else if (rainLevel <= 0.1)
		return (cloudLevel < 0.5) ? "Drizzle" : "LightRain";
	else if (rainLevel <= 0.3)
		return (cloudLevel > 0.5) ? "MediumRain" : "LightRain";
	else if (rainLevel <= 0.8)
		return (cloudLevel > 0.8) ? "HeavyRain" : "MediumRain";
	else
		return (cloudLevel > 0.8) ? "ThunderStorm" : "HeavyRain";
}

std::string getArgument(std::string request, std::string key) {
	vector<string> options = splitString(request, ",");

	int index = 0;

	while (index < options.size())
	{
		string option = options[index];

		if (option.rfind(key + "=") == 0)
			return option.substr(key.length() + 1, option.length() - (key.length() + 1)).c_str();

		index++;
	}

	return "";
}

std::string getArgument(char* request, std::string key) {
	return getArgument(std::string(request), key);
}

int main(int argc, char* argv[])
{
	const char* request = (argc == 1) ? "" : argv[1];

	SharedMemoryObjectOut* data = require(atoi(getArgument(request, "LMU").c_str()));

	if (data == NULL) {
		wcout << "[Session Data]" << endl << "Active=false" << endl;
		wcout << "[Position Data]" << endl << "Active=false" << endl;

		return -1;
	}

	bool setup = getArgument(request, "Setup") != "";
	bool standings = getArgument(request, "Standings") != "";

	uint8_t playerIdx = data->telemetry.playerVehicleIdx;
	VehicleScoringInfoV01 playerScoring = data->scoring.vehScoringInfo[playerIdx];
	TelemInfoV01 playerTelemetry = data->telemetry.telemInfo[playerIdx];

	if (!setup && !standings)
	{
		wcout << "[Session Data]" << endl;

		printData("Active", (data->scoring.scoringInfo.mGamePhase != 0) ? "true" : "false");

		if (!data->telemetry.playerHasVehicle)
			wcout << "Paused=true" << endl;
		else if (getString(playerTelemetry.mTrackName) == "")
			wcout << "Paused=true" << endl;
		else
			wcout << "Paused=" << ((data->scoring.scoringInfo.mGamePhase <= 2 || data->scoring.scoringInfo.mGamePhase == 9) ? "true" : "false") << endl;

		string session;
		int sessionType = data->scoring.scoringInfo.mSession;

		/*
		if (data->scoring.scoringInfo.mEndET <= 0.0 && (data->scoring.scoringInfo.mMaxLaps - playerScoring.mTotalLaps) <= 0)
			session = "Finished";
		else */
		if (sessionType >= 10 && sessionType <= 13)
			session = "Race";
		else if (sessionType >= 0 && sessionType <= 4)
			session = "Practice";
		else if (sessionType >= 5 && sessionType <= 8)
			session = "Qualification";
		else
			session = "Other";

		printData("Session", session);

		printData("ID", playerTelemetry.mID + 1);
		printData("Car", getString(playerTelemetry.mVehicleModel));
		printData("CarClass", getString(playerScoring.mVehicleClass));
		printData("Track", getString(data->scoring.scoringInfo.mTrackName));
		printData("SessionFormat", (data->scoring.scoringInfo.mEndET <= 0.0) ? "Laps" : "Time");
		printData("FuelAmount", round(playerTelemetry.mFuelCapacity));

		long time = GetRemainingTime(&data->scoring, &playerScoring);

		printData("SessionTimeRemaining", time);
		printData("SessionLapsRemaining", GetRemainingLaps(&data->scoring, &playerScoring));

		wcout << "[Car Data]" << endl;

		printNAData("MAP", playerTelemetry.mMotorMap + 1);
		printNAData("TC", playerTelemetry.mTC);
		printNAData("TCSlip", playerTelemetry.mTCSlip);
		printNAData("TCCut", playerTelemetry.mTCCut);
		printNAData("ABS", playerTelemetry.mABS);
		printNAData("BB", (1 - round(playerTelemetry.mRearBrakeBias * 10000) / 10000) * 100);

		printNAData("FuelRemaining", playerTelemetry.mFuel);

		printData("TyreTemperature", to_string(GetCelcius(playerTelemetry.mWheel[0].mTireCarcassTemperature)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[1].mTireCarcassTemperature)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[2].mTireCarcassTemperature)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[3].mTireCarcassTemperature)));
		printData("TyrePressure", to_string(GetPsi(playerTelemetry.mWheel[0].mPressure)) + "," +
			to_string(GetPsi(playerTelemetry.mWheel[1].mPressure)) + "," +
			to_string(GetPsi(playerTelemetry.mWheel[2].mPressure)) + "," +
			to_string(GetPsi(playerTelemetry.mWheel[3].mPressure)));
		printData("TyreWear", to_string(playerTelemetry.mWheel[0].mWear) + "," +
			to_string(playerTelemetry.mWheel[1].mWear) + "," +
			to_string(playerTelemetry.mWheel[2].mWear) + "," +
			to_string(playerTelemetry.mWheel[3].mWear));
		printData("BrakeTemperature", to_string(GetCelcius(playerTelemetry.mWheel[0].mBrakeTemp)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[1].mBrakeTemp)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[2].mBrakeTemp)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[3].mBrakeTemp)));

		int compound = playerTelemetry.mWheel[0].mCompoundIndex;

		printData("TyreCompoundRaw", compound);
		printData("TyreCompoundRawFrontLeft", compound);
		printData("TyreCompoundRawFrontRight", playerTelemetry.mWheel[1].mCompoundIndex);
		printData("TyreCompoundRawRearLeft", playerTelemetry.mWheel[2].mCompoundIndex);
		printData("TyreCompoundRawRearRight", playerTelemetry.mWheel[3].mCompoundIndex);
		printData("TyreTypeRawFrontLeft", playerTelemetry.mWheel[0].mCompoundType);
		printData("TyreTypeRawFrontRight", playerTelemetry.mWheel[1].mCompoundType);
		printData("TyreTypeRawRearLeft", playerTelemetry.mWheel[2].mCompoundType);
		printData("TyreTypeRawRearRight", playerTelemetry.mWheel[3].mCompoundType);

		int damage = 0;

		for (int i = 0; i < 8; i++)
			damage += playerTelemetry.mDentSeverity[i];

		wcout << "BodyworkDamage=0, 0, 0, 0, " << damage / 16 << endl;
		wcout << "SuspensionDamage=0, 0, 0, 0" << endl;
		printData("EngineDamage", playerTelemetry.mOverheating ? 1 : 0);

		if (playerTelemetry.mEngineWaterTemp > 0)
			printData("WaterTemperature", playerTelemetry.mEngineWaterTemp);

		if (playerTelemetry.mEngineOilTemp > 0)
			printData("OilTemperature", playerTelemetry.mEngineOilTemp);

		wcout << "[Stint Data]" << endl;

		printData("DriverForname", GetForname(data->scoring.scoringInfo.mPlayerName));
		printData("DriverSurname", GetSurname(data->scoring.scoringInfo.mPlayerName));
		printData("DriverNickname", GetNickname(data->scoring.scoringInfo.mPlayerName));

		printData("Position", playerScoring.mPlace);

		printData("LapValid", playerTelemetry.mLapInvalidated ? "false" : "true");

		printData("LapLastTime", round(Normalize((playerScoring.mLastLapTime > 0) ? playerScoring.mLastLapTime
			: playerScoring.mBestLapTime) * 1000));
		printData("LapBestTime", round(Normalize(playerScoring.mBestLapTime) * 1000));

		if (playerScoring.mNumPenalties > 0)
			wcout << "Penalty=true" << endl;

		printData("Sector", (playerScoring.mSector == 0) ? 3 : playerScoring.mSector);

		printData("Running", playerScoring.mLapDist / data->scoring.scoringInfo.mLapDist);

		printData("Laps", playerScoring.mTotalLaps);

		printData("StintTimeRemaining", time);
		printData("DriverTimeRemaining", time);

		printData("InPitLane", (playerScoring.mInPits) != 0 ? "true" : "false");

		if (playerScoring.mInPits != 0) {
			double speed = VehicleSpeed(&playerScoring);

			if (speed < 5 || playerScoring.mPitState == 3)
				wcout << "InPit=true" << endl;
			else
				wcout << "InPit=false" << endl;
		}

		wcout << "[Track Data]" << endl;

		printData("Length", data->scoring.scoringInfo.mLapDist);

		string grip = "Optimum";
		float pathWetness = data->scoring.scoringInfo.mAvgPathWetness;

		if (pathWetness >= 0.7)
			grip = "Flooded";
		else if (pathWetness >= 0.15)
			grip = "Wet";
		else if (pathWetness >= 0.075)
			grip = "Damp";
		else if (pathWetness > 0.02)
			grip = "Greasy";
		else if (pathWetness > 0.0)
			grip = "Green";
		else
			grip = "Fast";

		printData("Grip", grip);
		printData("Temperature", data->scoring.scoringInfo.mTrackTemp);

		int index = 0;

		for (int i = 0; i < data->scoring.scoringInfo.mNumVehicles; ++i) {
			VehicleScoringInfoV01* vehicle = &data->scoring.scoringInfo.mVehicle[i];

			index += 1;

			printData("Car." + to_string(index) + ".Position", to_string(vehicle->mPos.x) + "," + to_string(-vehicle->mPos.z));
		}

		wcout << "[Weather Data]" << endl;

		printData("Temperature", data->scoring.scoringInfo.mAmbientTemp);

		string theWeather = GetWeather(data->scoring.scoringInfo.mDarkCloud, data->scoring.scoringInfo.mRaining);

		printData("Weather", theWeather);
		printData("Weather10Min", theWeather);
		printData("Weather30Min", theWeather);
	}

	if (standings) {
		wcout << "[Position Data]" << endl;

		int index = 0;

		for (int i = 1; i <= data->scoring.scoringInfo.mNumVehicles; ++i)
		{
			VehicleScoringInfoV01* vehicle = &data->scoring.scoringInfo.mVehicle[i - 1];
			double speed = VehicleSpeed(vehicle);

			index = i;

			TelemInfoV01* telemetry = GetVehicleTelemetry(vehicle->mID, &data->scoring, &data->telemetry);

			printData("Car." + to_string(index) + ".ID", vehicle->mID + 1);
			printData("Car." + to_string(index) + ".Position", vehicle->mPlace);

			printData("Car." + to_string(index) + ".Laps", vehicle->mTotalLaps);
			printData("Car." + to_string(index) + ".Lap.Running", vehicle->mLapDist / data->scoring.scoringInfo.mLapDist);
			printData("Car." + to_string(index) + ".Lap.Running.Valid", telemetry->mLapInvalidated ? "false" : "true");
			printData("Car." + to_string(index) + ".Lap.Running.Time", (long)((telemetry->mElapsedTime - telemetry->mLapStartET) * 1000));

			int lapTime = (int)round(Normalize(vehicle->mLastLapTime) * 1000);

			if (lapTime == 0)
				lapTime = (int)round(Normalize(vehicle->mBestLapTime) * 1000);

			int sector1Time = (int)round(Normalize(vehicle->mLastSector1) * 1000);
			int sector2Time = (int)round(Normalize(vehicle->mLastSector2) * 1000) - sector1Time;
			int sector3Time = lapTime - sector1Time - sector2Time;

			printData("Car." + to_string(index) + ".Time", lapTime);
			printData("Car." + to_string(index) + ".Time.Sectors", to_string(sector1Time) + "," + to_string(sector2Time) + "," + to_string(sector3Time));

			string carClass = getString(vehicle->mVehicleClass);
			string carName = getString(vehicle->mVehicleName);

			printData("Car." + to_string(index) + ".Nr", GetCarNr(vehicle->mID, carClass, carName));
			printData("Car." + to_string(index) + ".Class", carClass);
			printData("Car." + to_string(index) + ".Car", telemetry->mVehicleModel);

			printData("Car." + to_string(index) + ".Driver.Forname", GetForname(vehicle->mDriverName));
			printData("Car." + to_string(index) + ".Driver.Surname", GetSurname(vehicle->mDriverName));
			printData("Car." + to_string(index) + ".Driver.Nickname", GetNickname(vehicle->mDriverName));

			printData("Car." + to_string(index) + ".InPitLane", (vehicle->mInPits) != 0 ? "true" : "false");

			if (vehicle->mInPits != 0) {
				double speed = VehicleSpeed(vehicle);

				if (speed < 5 || vehicle->mPitState == 3)
					printData("Car." + to_string(index) + ".InPit", "true");
				else
					printData("Car." + to_string(index) + ".InPit", "false");
			}
			else
				printData("Car." + to_string(index) + ".InPit", "false");

			if (vehicle->mIsPlayer == 1)
				printData("Driver.Car", index);
		}

		printData("Car.Count", index);
	}

	if (setup)
	{
		wcout << "[Setup Data]" << endl;

		printData("FuelRemaining", playerTelemetry.mFuel);
	}

	dismiss();

	return 0;
}