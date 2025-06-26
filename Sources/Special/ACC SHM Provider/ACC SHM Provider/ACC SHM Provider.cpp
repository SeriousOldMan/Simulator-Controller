#include "stdafx.h"
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include <comdef.h>
#include <iostream>
#include "SharedFileOut.h"
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

string normalizeName(string result) {
	replace(result, "/", "");
	replace(result, ":", "");
	replace(result, "*", "");
	replace(result, "?", "");
	replace(result, "<", "");
	replace(result, ">", "");
	replace(result, "|", "");

	return result;
}

inline string getString(wchar_t* str) {
	wstring s(str);

	return string(s.begin(), s.end());
}

inline const string getGrip(ACC_TRACK_GRIP_STATUS gripStatus) {

	switch (gripStatus) {
	case ACC_GREEN:
		return "Green";
	case ACC_FAST:
		return "Fast";
	case ACC_OPTIMUM:
		return "Optimum";
	case ACC_DAMP:
		return "Damp";
	case ACC_GREASY:
		return "Greasy";
	case ACC_WET:
		return "Wet";
	case ACC_FLOODED:
		return "Flooded";
	}
}

inline const string getWeather(ACC_RAIN_INTENSITY weather) {
	switch (weather) {
	case ACC_NO_RAIN:
		return "Dry";
		break;
	case ACC_DRIZZLE:
		return "Drizzle";
		break;
	case ACC_LIGHT_RAIN:
		return "LightRain";
		break;
	case ACC_MEDIUM_RAIN:
		return "MediumRain";
		break;
	case ACC_HEAVY_RAIN:
		return "HeavyRain";
		break;
	case ACC_THUNDERSTORM:
		return "Thunderstorm";
		break;
	default:
		return "Unknown";
		break;
	}
}

inline const string getSession(AC_SESSION_TYPE session) {
	switch (session) {
	case AC_PRACTICE:
		return "Practice";
		break;
	case AC_QUALIFY:
		return "Qualification";
		break;
	case AC_RACE:
		return "Race";
		break;
	case AC_HOTLAP:
		return "Time Trial";
		break;
	case AC_TIME_ATTACK:
		return "Time Trial";
		break;
	default:
		return "Other";
		break;
	}
}

inline const string getPenalty(PenaltyShortcut penalty) {
	SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	switch (penalty) {
	case PenaltyShortcut::None:
		return "";
	case PenaltyShortcut::DriveThrough_Cutting:
	case PenaltyShortcut::DriveThrough_PitSpeeding:
	case PenaltyShortcut::DriveThrough_IgnoredDriverStint:
	case PenaltyShortcut::Disqualified_ExceededDriverStintLimit:
		return "DT";
	case PenaltyShortcut::StopAndGo_10_Cutting:
	case PenaltyShortcut::StopAndGo_10_PitSpeeding:
		return "SG10";
	case PenaltyShortcut::StopAndGo_20_Cutting:
	case PenaltyShortcut::StopAndGo_20_PitSpeeding:
		return "SG20";
	case PenaltyShortcut::StopAndGo_30_Cutting:
	case PenaltyShortcut::StopAndGo_30_PitSpeeding:
		return "SG30";
	case PenaltyShortcut::Disqualified_Cutting:
	case PenaltyShortcut::Disqualified_PitSpeeding:
	case PenaltyShortcut::Disqualified_IgnoredMandatoryPit:
	case PenaltyShortcut::Disqualified_Trolling:
	case PenaltyShortcut::Disqualified_PitEntry:
	case PenaltyShortcut::Disqualified_PitExit:
	case PenaltyShortcut::Disqualified_WrongWay:
		return "DSQ";
	default:
		if (gf->penaltyTime > 0)
			return "Time";
		else
			return "";
	}
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

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();

	char* request = (argc == 1) ? "" : argv[1];

 	if (strlen(request) == 0)
	{
		wcout << "[Car Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
		SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;

		_bstr_t tc(gf->tyreCompound);
		std::string tyreCompound(tc);

		printNAData("MAP", gf->EngineMap + 1);
		printNAData("TC", gf->TC);
		printNAData("ABS", gf->ABS);

		printData("Ignition", pf->ignitionOn ? "true" : "false");
		printData("HeadLights", (gf->lightsStage == 0) ? "Off" : (gf->lightsStage == 1) ? "Low" : "High");
		printData("RainLights", gf->rainLights ? "true" : "false");
		wcout << "PitLimiter=" << ((pf->pitLimiterOn == 0) ? "false" : "true") << endl;

		printData("BodyworkDamage", pf->carDamage);
		printData("SuspensionDamage", pf->suspensionDamage);
		printData("EngineDamage", 0);
		printData("FuelRemaining", pf->fuel);
		wcout << "TyreCompound=" << ((tyreCompound.compare("dry_compound") == 0) ? "Dry" : "Wet") << endl;
		wcout << "TyreCompoundColor=Black" << endl;
		printData("TyreSet", gf->currentTyreSet);
		printData("TyreTemperature", pf->tyreCoreTemperature);
		printData("TyreInnerTemperature", pf->tyreTempI);
		printData("TyreMiddleTemperature", pf->tyreTempM);
		printData("TyreOuterTemperature", pf->tyreTempO);
		printData("TyreTemperature", pf->tyreCoreTemperature);
		printData("TyreTemperature", pf->tyreCoreTemperature);
		printData("TyrePressure", pf->wheelsPressure);
		printData("BrakeTemperature", pf->brakeTemp);
		printData("BrakePadLifeRaw", pf->padLife);
		printData("BrakeDiscLifeRaw", pf->discLife);
		printData("FrontBrakePadCompoundRaw", pf->frontBrakeCompound + 1);
		printData("RearBrakePadCompoundRaw", pf->rearBrakeCompound + 1);

		if (pf->waterTemp)
			printData("WaterTemperature", pf->waterTemp);

		wcout << "[Stint Data]" << endl;
		
		wcout << "DriverForname=" << sf->playerName << endl;
		wcout << "DriverSurname=" << sf->playerSurname << endl;
		wcout << "DriverNickname=" << sf->playerNick << endl;
		printData("Sector", gf->currentSectorIndex + 1);
		printData("Laps", gf->completedLaps);
		
		printData("LapValid", gf->isValidLap ? "true" : "false");
		printData("LapLastTime", gf->iLastTime);
		printData("LapBestTime", gf->iBestTime);

		wcout << "Position=" << gf->position << endl;
		
		string penalty = getPenalty(gf->penalty);

		if (penalty.length() != 0)
			printData("Penalty", penalty);

		printData("GapAhead", gf->gapAhead);
		printData("GapBehind", gf->gapBehind);

		/*
		if (gf->session == AC_PRACTICE) {
			printData("StintTimeRemaining", 3600000);
			printData("DriverTimeRemaining", 3600000);
		}
		else {
			double timeLeft = gf->sessionTimeLeft;

			if (timeLeft < 0) {
				timeLeft = 3600.0 * 1000;
			}

			printData("StintTimeRemaining", gf->DriverStintTimeLeft < 0 ? timeLeft : gf->DriverStintTimeLeft);
			printData("DriverTimeRemaining", gf->DriverStintTotalTimeLeft < 0 ? timeLeft : gf->DriverStintTotalTimeLeft);
		}
		*/

		long timeLeft = (long)gf->sessionTimeLeft;

		if (timeLeft < 0)
			if (gf->session == AC_PRACTICE)
				timeLeft = 24 * 3600 * 1000;
			else
				timeLeft = 0.0;

		printData("StintTimeRemaining", gf->DriverStintTimeLeft < 0 ? timeLeft : gf->DriverStintTimeLeft);
		printData("DriverTimeRemaining", gf->DriverStintTotalTimeLeft < 0 ? timeLeft : gf->DriverStintTotalTimeLeft);

		printData("InPitLane", (gf->isInPit || gf->isInPitLane) ? "true" : "false");
		printData("InPit", gf->isInPit ? "true" : "false");

		wcout << "[Track Data]" << endl;

		printData("Temperature", pf->roadTemp);
		printData("Grip", getGrip(gf->trackGripStatus));

		for (int id = 0; id < gf->activeCars; id++) {
			wcout << "Car." << id + 1 << ".ID=" << gf->carID[id] << endl;
			wcout << "Car." << id + 1 << ".Position=" << gf->carCoordinates[id][0] << "," << gf->carCoordinates[id][2] << endl;
		}

		wcout << "[Weather Data]" << endl;

		printData("Temperature", pf->airTemp);
		printData("Weather", getWeather(gf->rainIntensity));
		printData("Weather10min", getWeather(gf->rainIntensityIn10min));
		printData("Weather30min", getWeather(gf->rainIntensityIn30min));

		wcout << "[Session Data]" << endl;

		printData("Active", ((gf->status == AC_LIVE) || (gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false");
		printData("Paused", ((gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false");
		printData("Session", getSession(gf->session));
		wcout << "ID=" << gf->playerCarID << endl;
		wcout << "Car=" << normalizeName(getString(sf->carModel)).c_str() << endl;
		wcout << "Track=" << normalizeName(getString(sf->track)).c_str() << endl;
		wcout << "SessionFormat=Time" << endl;
		printData("FuelAmount", sf->maxFuel);

		printData("SessionTimeRemaining", timeLeft);

		if (gf->session == AC_PRACTICE)
			printData("SessionLapsRemaining", 1000);
		else
			printData("SessionLapsRemaining", (gf->iLastTime > 0) ? timeLeft / gf->iLastTime : 99);
	}

	if (strlen(request) == 0 || getArgument(request, "Setup") != "")
	{
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

		if (strlen(request) != 0) {
			wcout << "[Car Data]" << endl;

			printData("TyreSet", gf->currentTyreSet);
		}

		wcout << "[Setup Data]" << endl;

		_bstr_t tc(gf->tyreCompound);
		std::string tyreCompound(tc);

		/*
		if ((gf->trackGripStatus >= ACC_DAMP) || (gf->rainIntensityIn10min >= ACC_LIGHT_RAIN))
			wcout << "TyreCompound=Wet" << endl;
		else
			wcout << "TyreCompound=" << ((tyreCompound.compare("dry_compound") == 0) ? "Dry" : "Wet") << endl;

		wcout << "TyreCompoundColor=Black" << endl;
		*/
		
		printData("TyreSet", gf->mfdTyreSet + 1);
		printData("TyreSetCurrent", gf->currentTyreSet);
		printData("TyreSetStrategy", gf->strategyTyreSet);
		printData("FuelAmount", gf->mfdFuelToAdd);
		printData("TyrePressureFL", gf->mfdTyrePressureFL);
		printData("TyrePressureFR", gf->mfdTyrePressureFR);
		printData("TyrePressureRL", gf->mfdTyrePressureRL);
		printData("TyrePressureRR", gf->mfdTyrePressureRR);
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


