#include "stdafx.h"
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include <comdef.h>
#include <iostream>
#include <sstream>
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

static SMElement m_graphics;
static SMElement m_physics;
static SMElement m_static;

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

inline string getString(wchar_t* str) {
	wstring s(str);

	return string(s.begin(), s.end());
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

extern "C" __declspec(dllexport) int __stdcall initialize() {
	initPhysics();
	initGraphics();
	initStatic();

	return 0;
}

extern "C" __declspec(dllexport) int __stdcall dispose() {
	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}

extern "C" __declspec(dllexport) int __stdcall collect(char* request, char* result, int size)
{
	ostringstream output;
	
	if (strlen(request) == 0)
	{
		output << "[Car Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		_bstr_t tc(gf->tyreCompound);
		std::string tyreCompound(tc);

		printNAData(&output, "MAP", gf->EngineMap + 1);
		printNAData(&output, "TC", gf->TC);
		printNAData(&output, "ABS", gf->ABS);

		printData(&output, "Ignition", pf->ignitionOn ? "true" : "false");
		printData(&output, "HeadLights", (gf->lightsStage == 0) ? "Off" : (gf->lightsStage == 1) ? "Low" : "High");
		printData(&output, "RainLights", gf->rainLights ? "true" : "false");
		printData(&output, "PitLimiter", (pf->pitLimiterOn == 0) ? "false" : "true");

		printData(&output, "BodyworkDamage", pf->carDamage);
		printData(&output, "SuspensionDamage", pf->suspensionDamage);
		printData(&output, "EngineDamage", 0);
		printData(&output, "FuelRemaining", pf->fuel);
		output << "TyreCompound=" << ((tyreCompound.compare("dry_compound") == 0) ? "Dry" : "Wet") << endl;
		output << "TyreCompoundColor=Black" << endl;
		printData(&output, "TyreSet", gf->currentTyreSet);
		printData(&output, "TyreTemperature", pf->tyreCoreTemperature);
		printData(&output, "TyrePressure", pf->wheelsPressure);
		printData(&output, "BrakeTemperature", pf->brakeTemp);
		printData(&output, "BrakePadLifeRaw", pf->padLife);
		printData(&output, "BrakeDiscLifeRaw", pf->discLife);
		printData(&output, "FrontBrakePadCompoundRaw", pf->frontBrakeCompound + 1);
		printData(&output, "RearBrakePadCompoundRaw", pf->rearBrakeCompound + 1);
	
		output << "[Stint Data]" << endl;

		SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
		
		output << "DriverForname=" << getString(sf->playerName) << endl;
		output << "DriverSurname=" << getString(sf->playerSurname) << endl;
		output << "DriverNickname=" << getString(sf->playerNick) << endl;
		printData(&output, "Sector", gf->currentSectorIndex + 1);
		printData(&output, "Laps", gf->completedLaps);

		printData(&output, "LapValid", gf->isValidLap ? "true" : "false");
		printData(&output, "LapLastTime", gf->iLastTime);
		printData(&output, "LapBestTime", gf->iBestTime);

		output << "Position=" << gf->position << endl;

		string penalty = getPenalty(gf->penalty);

		if (penalty.length() != 0)
			printData(&output, "Penalty", penalty);

		printData(&output, "GapAhead", gf->gapAhead);
		printData(&output, "GapBehind", gf->gapBehind);

		long timeLeft = (long)gf->sessionTimeLeft;

		if (timeLeft < 0)
			if (gf->session == AC_PRACTICE)
				timeLeft = 24 * 3600 * 1000;
			else
				timeLeft = 0.0;

		printData(&output, "StintTimeRemaining", gf->DriverStintTimeLeft < 0 ? timeLeft : gf->DriverStintTimeLeft);
		printData(&output, "DriverTimeRemaining", gf->DriverStintTotalTimeLeft < 0 ? timeLeft : gf->DriverStintTotalTimeLeft);

		printData(&output, "InPitLane", gf->isInPit ? "true" : "false");
		printData(&output, "InPit", gf->isInPit ? "true" : "false");
	
		output << "[Track Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData(&output, "Temperature", pf->roadTemp);
		printData(&output, "Grip", getGrip(gf->trackGripStatus));

		for (int id = 0; id < gf->activeCars; id++) {
			output << "Car." << id + 1 << ".ID=" << gf->carID[id] << endl;
			output << "Car." << id + 1 << ".Position=" << gf->carCoordinates[id][0] << "," << gf->carCoordinates[id][2] << endl;
		}
	
		output << "[Weather Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData(&output, "Temperature", pf->airTemp);
		printData(&output, "Weather", getWeather(gf->rainIntensity));
		printData(&output, "Weather10min", getWeather(gf->rainIntensityIn10min));
		printData(&output, "Weather30min", getWeather(gf->rainIntensityIn30min));
	
		output << "[Session Data]" << endl;

		SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData(&output, "Active", ((gf->status == AC_LIVE) || (gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false");
		printData(&output, "Paused", ((gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false");
		printData(&output, "Session", getSession(gf->session));
		output << "ID=" << gf->playerCarID << endl;
		output << "Car=" << getString(sf->carModel) << endl;
		output << "Track=" << getString(sf->track) << endl;
		output << "SessionFormat=Time" << endl;
		printData(&output, "FuelAmount", sf->maxFuel);

		long timeLeft = gf->sessionTimeLeft;

		if (timeLeft < 0)
			if (gf->session == AC_PRACTICE)
				timeLeft = 24 * 3600 * 1000;
			else
				timeLeft = 0.0;

		printData(&output, "SessionTimeRemaining", timeLeft);

		if (gf->session == AC_PRACTICE)
			printData(&output, "SessionLapsRemaining", 1000);
		else
			printData(&output, "SessionLapsRemaining", (gf->iLastTime > 0) ? timeLeft / gf->iLastTime : 99);
	}
	
	if (strcmp(request, "Setup") == 0 || strcmp(request, "-Setup") == 0)
	{
		output << "[Setup Data]" << endl;

		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

		_bstr_t tc(gf->tyreCompound);
		std::string tyreCompound(tc);

		if ((gf->trackGripStatus >= ACC_DAMP) || (gf->rainIntensityIn10min >= ACC_LIGHT_RAIN))
			output << "TyreCompound=Wet" << endl;
		else
			output << "TyreCompound=" << ((tyreCompound.compare("dry_compound") == 0) ? "Dry" : "Wet") << endl;

		output << "TyreCompoundColor=Black" << endl;

		printData(&output, "TyreSet", gf->mfdTyreSet + 1);
		printData(&output, "TyreSetCurrent", gf->currentTyreSet + 1);
		printData(&output, "TyreSetStrategy", gf->strategyTyreSet + 1);
		printData(&output, "FuelAmount", gf->mfdFuelToAdd);
		printData(&output, "TyrePressureFL", gf->mfdTyrePressureFL);
		printData(&output, "TyrePressureFR", gf->mfdTyrePressureFR);
		printData(&output, "TyrePressureRL", gf->mfdTyrePressureRL);
		printData(&output, "TyrePressureRR", gf->mfdTyrePressureRR);
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