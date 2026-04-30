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

DWORD lastParentPID = 0;

SharedMemoryObjectOut* require(DWORD parentPID) {
	bool retVal = true;

	static SharedMemoryObjectOut copiedMem;

	try {
		SharedMemoryLock smLock = SharedMemoryLock::MakeSharedMemoryLock();

		// Try to open a handle to the parent process with SYNCHRONIZE right.
		// SYNCHRONIZE is enough to wait on the process handle for exit.

		if (parentPID != lastParentPID) {
			dismiss();

			hParent = OpenProcess(SYNCHRONIZE | PROCESS_QUERY_LIMITED_INFORMATION, FALSE, parentPID);
			hEvent = OpenEventA(SYNCHRONIZE, FALSE, "LMU_Data_Event");
			hMapFile = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, L"LMU_Data");

			lastParentPID = parentPID;
		}

		if (hParent && hEvent && hMapFile) {
			if (SharedMemoryLayout* pBuf = (SharedMemoryLayout*)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedMemoryLayout))) {
				HANDLE objectHandlesArray[2] = { hParent, hEvent };
				for (DWORD waitObject = WaitForMultipleObjects(2, objectHandlesArray, FALSE, 500); waitObject != WAIT_OBJECT_0; waitObject = WaitForMultipleObjects(2, objectHandlesArray, FALSE, 500)) {
					if (waitObject == WAIT_OBJECT_0 + 1) {
						smLock.Lock();
						CopySharedMemoryObj(copiedMem, pBuf->data);
						smLock.Unlock();
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

void printNAData(ostringstream* output, string name, long value)
{
	if (value == -1)
		(*output) << name.c_str() << "=" << "n/a" << endl;
	else {
		(*output) << name.c_str() << "=" << fixed << value << endl;

		(*output).setf(0, ios::floatfield);
	}
}

void printData(ostringstream* output, string name, float value)
{
	if (round(value) == value) {
		int old_precision = (*output).precision();

		(*output).precision(0);

		(*output) << name.c_str() << "=" << fixed << value << endl;

		(*output).setf(0, ios::floatfield);

		(*output).precision(old_precision);
	}
	else
		(*output) << name.c_str() << "=" << value << endl;
}

void printData(ostringstream* output, string name, string value)
{
	(*output) << name.c_str() << "=" << value.c_str() << endl;
}

template <typename T, unsigned S>
inline void printData(ostringstream* output, const string name, const T(&v)[S])
{
	(*output) << name.c_str() << "=";

	for (int i = 0; i < S; i++)
	{
		(*output) << v[i];

		if (i < S - 1)
			(*output) << ", ";
	}

	(*output) << endl;
}

template <typename T, unsigned S, unsigned S2>
inline void printData2(ostringstream* output, const string name, const T(&v)[S][S2])
{
	(*output) << name.c_str() << "=";

	for (int i = 0; i < S; i++)
	{
		(*output) << i << ": ";

		for (int j = 0; j < S2; j++) {
			(*output) << v[i][j];

			if (j < S2 - 1)
				(*output) << ", ";
		}

		if (i < (S - 1))
			(*output) << "; ";

	}

	(*output) << endl;
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

extern "C" __declspec(dllexport) int __stdcall open() {
	return 0;
}

extern "C" __declspec(dllexport) int __stdcall close() {
	dismiss();
	
	return 0;
}

DWORD lmuPID = 0;

extern "C" __declspec(dllexport) int __stdcall call(char* request, char* result, int size)
{
	SharedMemoryObjectOut* data = require(atoi(getArgument(request, "LMU").c_str()));

	ostringstream output;
	
	if (data == NULL) {
		output << "[Session Data]" << endl << "Active=false" << endl;
		output << "[Position Data]" << endl << "Active=false" << endl;
			
		strcpy_s(result, size, output.str().c_str());
			
		return -1;
	}

	bool setup = getArgument(request, "Setup") != "";
	bool standings = getArgument(request, "Standings") != "";

	uint8_t playerIdx = data->telemetry.playerVehicleIdx;
	VehicleScoringInfoV01 playerScoring = data->scoring.vehScoringInfo[playerIdx];
	TelemInfoV01 playerTelemetry = data->telemetry.telemInfo[playerIdx];

	if (!setup && !standings)
	{
		output << "[Session Data]" << endl;

		printData(&output, "Active", (data->scoring.scoringInfo.mGamePhase != 0) ? "true" : "false");

		if (!data->telemetry.playerHasVehicle)
			output << "Paused=true" << endl;
		else if (getString(playerTelemetry.mTrackName) == "")
			output << "Paused=true" << endl;
		else
			output << "Paused=" << ((data->scoring.scoringInfo.mGamePhase <= 2 || data->scoring.scoringInfo.mGamePhase == 9) ? "true" : "false") << endl;

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

		printData(&output, "Session", session);
		
		printData(&output, "ID", playerTelemetry.mID + 1);
		printData(&output, "Car", getString(playerTelemetry.mVehicleModel));
		printData(&output, "CarClass", getString(playerScoring.mVehicleClass));
		printData(&output, "Track", getString(data->scoring.scoringInfo.mTrackName));
		printData(&output, "SessionFormat", (data->scoring.scoringInfo.mEndET <= 0.0) ? "Laps" : "Time");
		printData(&output, "FuelAmount", round(playerTelemetry.mFuelCapacity));

		long time = GetRemainingTime(&data->scoring, &playerScoring);

		printData(&output, "SessionTimeRemaining", time);
		printData(&output, "SessionLapsRemaining", GetRemainingLaps(&data->scoring, &playerScoring));
		
		output << "[Car Data]" << endl;

		printNAData(&output, "MAP", playerTelemetry.mMotorMap + 1);
		printNAData(&output, "TC", playerTelemetry.mTC);
		printNAData(&output, "TCSlip", playerTelemetry.mTCSlip);
		printNAData(&output, "TCCut", playerTelemetry.mTCCut);
		printNAData(&output, "ABS", playerTelemetry.mABS);
		printNAData(&output, "BB", (1 - round(playerTelemetry.mRearBrakeBias * 10000) / 10000) * 100);

		printNAData(&output, "FuelRemaining", playerTelemetry.mFuel);

		printData(&output, "TyreTemperature", to_string(GetCelcius(playerTelemetry.mWheel[0].mTireCarcassTemperature)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[1].mTireCarcassTemperature)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[2].mTireCarcassTemperature)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[3].mTireCarcassTemperature)));
		printData(&output, "TyrePressure", to_string(GetPsi(playerTelemetry.mWheel[0].mPressure)) + "," +
			to_string(GetPsi(playerTelemetry.mWheel[1].mPressure)) + "," +
			to_string(GetPsi(playerTelemetry.mWheel[2].mPressure)) + "," +
			to_string(GetPsi(playerTelemetry.mWheel[3].mPressure)));
		printData(&output, "TyreWear", to_string(playerTelemetry.mWheel[0].mWear) + "," +
			to_string(playerTelemetry.mWheel[1].mWear) + "," +
			to_string(playerTelemetry.mWheel[2].mWear) + "," +
			to_string(playerTelemetry.mWheel[3].mWear));
		printData(&output, "BrakeTemperature", to_string(GetCelcius(playerTelemetry.mWheel[0].mBrakeTemp)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[1].mBrakeTemp)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[2].mBrakeTemp)) + "," +
			to_string(GetCelcius(playerTelemetry.mWheel[3].mBrakeTemp)));

		int compound = playerTelemetry.mWheel[0].mCompoundIndex;

		printData(&output, "TyreCompoundRaw", compound);
		printData(&output, "TyreCompoundRawFrontLeft", compound);
		printData(&output, "TyreCompoundRawFrontRight", playerTelemetry.mWheel[1].mCompoundIndex);
		printData(&output, "TyreCompoundRawRearLeft", playerTelemetry.mWheel[2].mCompoundIndex);
		printData(&output, "TyreCompoundRawRearRight", playerTelemetry.mWheel[3].mCompoundIndex);
		printData(&output, "TyreTypeRawFrontLeft", playerTelemetry.mWheel[0].mCompoundType);
		printData(&output, "TyreTypeRawFrontRight", playerTelemetry.mWheel[1].mCompoundType);
		printData(&output, "TyreTypeRawRearLeft", playerTelemetry.mWheel[2].mCompoundType);
		printData(&output, "TyreTypeRawRearRight", playerTelemetry.mWheel[3].mCompoundType);

		int damage = 0;

		for (int i = 0; i < 8; i++)	
			damage += playerTelemetry.mDentSeverity[i];

		output << "BodyworkDamage=0, 0, 0, 0, " << damage / 16 << endl;
		output << "SuspensionDamage=0, 0, 0, 0" << endl;
		printData(&output, "EngineDamage", playerTelemetry.mOverheating ? 1 : 0);

		if (playerTelemetry.mEngineWaterTemp > 0)
			printData(&output, "WaterTemperature", playerTelemetry.mEngineWaterTemp);

		if (playerTelemetry.mEngineOilTemp > 0)
			printData(&output, "OilTemperature", playerTelemetry.mEngineOilTemp);
	
		output << "[Stint Data]" << endl;

		printData(&output, "DriverForname", GetForname(data->scoring.scoringInfo.mPlayerName));
		printData(&output, "DriverSurname", GetSurname(data->scoring.scoringInfo.mPlayerName));
		printData(&output, "DriverNickname", GetNickname(data->scoring.scoringInfo.mPlayerName));

		printData(&output, "Position", playerScoring.mPlace);

		printData(&output, "LapValid", playerTelemetry.mLapInvalidated ? "false" : "true");

		printData(&output, "LapLastTime", round(Normalize((playerScoring.mLastLapTime > 0) ? playerScoring.mLastLapTime
																						   : playerScoring.mBestLapTime) * 1000));
		printData(&output, "LapBestTime", round(Normalize(playerScoring.mBestLapTime) * 1000));

		if (playerScoring.mNumPenalties > 0)
			output << "Penalty=true" << endl;

		printData(&output, "Sector", (playerScoring.mSector == 0) ? 3 : playerScoring.mSector);

		printData(&output, "Running", playerScoring.mLapDist / data->scoring.scoringInfo.mLapDist);

		printData(&output, "Laps", playerScoring.mTotalLaps);

		printData(&output, "StintTimeRemaining", time);
		printData(&output, "DriverTimeRemaining", time);

		printData(&output, "InPitLane", (playerScoring.mInPits) != 0 ? "true" : "false");

		if (playerScoring.mInPits != 0) {
			double speed = VehicleSpeed(&playerScoring);

			if (speed < 5 || playerScoring.mPitState == 3)
				output << "InPit=true" << endl;
			else
				output << "InPit=false" << endl;
		}
	
		output << "[Track Data]" << endl;

		printData(&output, "Length", data->scoring.scoringInfo.mLapDist);

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

		printData(&output, "Grip", grip);
		printData(&output, "Temperature", data->scoring.scoringInfo.mTrackTemp);

		int index = 0;

		for (int i = 0; i < data->scoring.scoringInfo.mNumVehicles; ++i) {
			VehicleScoringInfoV01* vehicle = &data->scoring.scoringInfo.mVehicle[i];

			index += 1;

			printData(&output, "Car." + to_string(index) + ".Position", to_string(vehicle->mPos.x) + "," + to_string(-vehicle->mPos.z));
		}
	
		output << "[Weather Data]" << endl;

		printData(&output, "Temperature", data->scoring.scoringInfo.mAmbientTemp);

		string theWeather = GetWeather(data->scoring.scoringInfo.mDarkCloud, data->scoring.scoringInfo.mRaining);

		printData(&output, "Weather", theWeather);
		printData(&output, "Weather10Min", theWeather);
		printData(&output, "Weather30Min", theWeather);
	}

	if (standings) {
		output << "[Position Data]" << endl;

		int index = 0;

		for (int i = 1; i <= data->scoring.scoringInfo.mNumVehicles; ++i)
		{
			VehicleScoringInfoV01* vehicle = &data->scoring.scoringInfo.mVehicle[i - 1];
			double speed = VehicleSpeed(vehicle);

			index = i;

			TelemInfoV01* telemetry = GetVehicleTelemetry(vehicle->mID, &data->scoring, &data->telemetry);

			printData(&output, "Car." + to_string(index) + ".ID", vehicle->mID + 1);
			printData(&output, "Car." + to_string(index) + ".Position", vehicle->mPlace);

			printData(&output, "Car." + to_string(index) + ".Laps", vehicle->mTotalLaps);
			printData(&output, "Car." + to_string(index) + ".Lap.Running", vehicle->mLapDist / data->scoring.scoringInfo.mLapDist);
			printData(&output, "Car." + to_string(index) + ".Lap.Running.Valid", telemetry->mLapInvalidated ? "false" : "true");
			printData(&output, "Car." + to_string(index) + ".Lap.Running.Time", (long)((telemetry->mElapsedTime - telemetry->mLapStartET) * 1000));

			int lapTime = (int)round(Normalize(vehicle->mLastLapTime) * 1000);

			if (lapTime == 0)
				lapTime = (int)round(Normalize(vehicle->mBestLapTime) * 1000);

			int sector1Time = (int)round(Normalize(vehicle->mLastSector1) * 1000);
			int sector2Time = (int)round(Normalize(vehicle->mLastSector2) * 1000) - sector1Time;
			int sector3Time = lapTime - sector1Time - sector2Time;

			printData(&output, "Car." + to_string(index) + ".Time", lapTime);
			printData(&output, "Car." + to_string(index) + ".Time.Sectors", to_string(sector1Time) + "," + to_string(sector2Time) + "," + to_string(sector3Time));

			string carClass = getString(vehicle->mVehicleClass);
			string carName = getString(vehicle->mVehicleName);

			printData(&output, "Car." + to_string(index) + ".Nr", GetCarNr(vehicle->mID, carClass, carName));
			printData(&output, "Car." + to_string(index) + ".Class", carClass);
			printData(&output, "Car." + to_string(index) + ".Car", telemetry->mVehicleModel);

			printData(&output, "Car." + to_string(index) + ".Driver.Forname", GetForname(vehicle->mDriverName));
			printData(&output, "Car." + to_string(index) + ".Driver.Surname", GetSurname(vehicle->mDriverName));
			printData(&output, "Car." + to_string(index) + ".Driver.Nickname", GetNickname(vehicle->mDriverName));

			printData(&output, "Car." + to_string(index) + ".InPitLane", (vehicle->mInPits) != 0 ? "true" : "false");

			if (vehicle->mInPits != 0) {
				double speed = VehicleSpeed(vehicle);

				if (speed < 5 || vehicle->mPitState == 3)
					printData(&output, "Car." + to_string(index) + ".InPit", "true");
				else
					printData(&output, "Car." + to_string(index) + ".InPit", "false");
			}
			else
				printData(&output, "Car." + to_string(index) + ".InPit", "false");

			if (vehicle->mIsPlayer == 1)
				printData(&output, "Driver.Car", index);
		}

		printData(&output, "Car.Count", index);
	}
	
	if (setup)
	{
		output << "[Setup Data]" << endl;

		printData(&output, "FuelRemaining", playerTelemetry.mFuel);
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