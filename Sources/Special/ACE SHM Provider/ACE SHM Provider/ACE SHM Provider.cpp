#include "stdafx.h"
#include <windows.h>
#include <tchar.h>
#include <iostream>
#include "SharedFileOut.h"
using namespace std;
template <typename T, unsigned S> inline unsigned arraysize(const T(&v)[S]) {
	return S;
}
struct SMElement {
	HANDLE hMapFile;
	unsigned char* mapFileBuffer;
};
SMElement m_graphics;
SMElement m_physics;
SMElement m_static;
static void initPhysics() {
	TCHAR szName[] = TEXT("Local\\acevo_pmf_physics");
	m_physics.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFilePhysics), szName);
	if (!m_physics.hMapFile) {
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACS", MB_OK);
	}
	m_physics.mapFileBuffer = (unsigned char*)MapViewOfFile(m_physics.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFilePhysics));
	if (!m_physics.mapFileBuffer) {
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACS", MB_OK);
	}
}
static void initGraphics() {
	TCHAR szName[] = TEXT("Local\\acevo_pmf_graphics");
	m_graphics.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFileGraphicEvo), szName);
	if (!m_graphics.hMapFile) {
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACS", MB_OK);
	}
	m_graphics.mapFileBuffer = (unsigned char*)MapViewOfFile(m_graphics.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFileGraphicEvo));
	if (!m_graphics.mapFileBuffer) {
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACS", MB_OK);
	}
}
static void initStatic() {
	TCHAR szName[] = TEXT("Local\\acevo_pmf_static");
	m_static.hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(SPageFileStaticEvo), szName);
	if (!m_static.hMapFile) {
		MessageBoxA(GetActiveWindow(), "CreateFileMapping failed", "ACS", MB_OK);
	}
	m_static.mapFileBuffer = (unsigned char*)MapViewOfFile(m_static.hMapFile, FILE_MAP_READ, 0, 0, sizeof(SPageFileStaticEvo));
	if (!m_static.mapFileBuffer) {
		MessageBoxA(GetActiveWindow(), "MapViewOfFile failed", "ACS", MB_OK);
	}
}
static void dismiss(SMElement element) {
	UnmapViewOfFile(element.mapFileBuffer);
	CloseHandle(element.hMapFile);
}
// Consolidated printData overloads to avoid conflicts
inline void printData(const wstring& name, float value) {
	wcout << name.c_str() << "=" << value << endl;
}
inline void printData(const wstring& name, bool value) {
	wcout << name.c_str() << "=" << (value ? 1 : 0) << endl;
}
inline void printData(const wstring& name, uint8_t value) {
	wcout << name.c_str() << " : " << (int)value << endl;
}
inline void printData(const wstring& name, int8_t value) {
	wcout << name.c_str() << "=" << (int)value << endl;
}
inline void printData(const wstring& name, uint32_t value) {
	wcout << name.c_str() << "=" << value << endl;
}
inline void printData(const wstring& name, uint64_t value) {
	wcout << name.c_str() << "=" << value << endl;
}
inline void printData(const wstring& name, int32_t value) {
	wcout << name.c_str() << "=" << value << endl;
}
inline void printData(const wstring& name, string value) {
	wcout << name.c_str() << "=" << value.c_str() << endl;
}
template <typename T, unsigned S> inline void printData(const wstring& name, const T(&v)[S]) {
	wcout << name.c_str() << "=";
	for (int i = 0; i < S; i++) {
		wcout << v[i];
		if (i < S - 1) {
			wcout << " , ";
		}
	}
	wcout << endl;
}
template <typename T, unsigned S1, unsigned S2> inline void printData(const wstring& name, const T(&v)[S1][S2]) {
	wcout << name.c_str() << "=" << endl;
	for (int i = 0; i < S1; i++) {
		wcout << "  [" << i << "] : ";
		for (int j = 0; j < S2; j++) {
			wcout << v[i][j];
			if (j < S2 - 1) {
				wcout << " , ";
			}
		}
		wcout << endl;
	}
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

inline const string getSession(int sessionType, string phaseName) {
	if (phaseName == "Qualify")
		return "Qualification";
	else
		return phaseName;
}

long getRemainingTime(long timeLeft);

long getRemainingLaps(long timeLeft)
{
	SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
	SPageFileStaticEvo* sf = (SPageFileStaticEvo*)m_static.mapFileBuffer;

	if (getSession(sf->session, gf->session_state.phase_name) != "Practice")
	{
		if (sf->is_timed_race == 0)
			return (gf->session_state.total_lap - gf->total_lap_count);
		else
		{
			if (gf->last_laptime_ms > 0)
				return ((getRemainingTime(timeLeft) / gf->last_laptime_ms) + 1);
			else
				return 0;
		}
	}
	else
	{
		if (gf->best_laptime_ms > 0)
			return ((getRemainingTime(timeLeft) / gf->best_laptime_ms) + 1);
		else
			return 0;
	}
}

long getRemainingTime(long timeLeft)
{
	SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
	SPageFileStaticEvo* sf = (SPageFileStaticEvo*)m_static.mapFileBuffer;

	if (getSession(sf->session, gf->session_state.phase_name) == "Practice" || sf->is_timed_race != 0)
	{
		long time = (timeLeft - (gf->best_laptime_ms * gf->total_lap_count));

		if (time > 0)
			return time;
		else
			return 0;
	}
	else
		return (getRemainingLaps(timeLeft) * gf->last_laptime_ms);
}

inline string getString(wchar_t* str) {
	wstring s(str);

	return string(s.begin(), s.end());
}

inline string getString(char* str) {
	string s(str);

	return string(s.begin(), s.end());
}

const string getGrip(ACEVO_STARTING_GRIP gripStatus) {
	switch (gripStatus) {
	case ACEVO_GREEN:
		return "Green";
	case ACEVO_FAST:
		return "Fast";
	case ACEVO_OPTIMUM:
		return "Optimum";
	default:
		return "Unknown";
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
		SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
		SPageFileStaticEvo* sf = (SPageFileStaticEvo*)m_static.mapFileBuffer;

		printNAData("MAP", gf->electronics.engine_map_level + 1);
		printNAData("TC", gf->electronics.tc_level);
		printNAData("ABS", gf->electronics.abs_level);
		printNAData("BBRaw", pf->brakeBias);

		/*
		printData("Ignition", pf->ignitionOn ? "true" : "false");
		printData("HeadLights", (gf->lightsStage == 0) ? "Off" : (gf->lightsStage == 1) ? "Low" : "High");
		printData("RainLights", gf->rainLights ? "true" : "false");
		wcout << "PitLimiter=" << ((pf->pitLimiterOn == 0) ? "false" : "true") << endl;
		*/

		printData(L"BodyworkDamage", pf->carDamage);
		printData(L"SuspensionDamage", pf->suspensionDamage);
		printData(L"EngineDamage", 0);
		printData(L"FuelRemaining", pf->fuel);

		wcout << "TyreCompoundRawFront=" << gf->tyre_lf.tyre_compound_front << endl;
		wcout << "TyreCompoundRawRear=" << gf->tyre_lf.tyre_compound_rear << endl;

		
		
		printData(L"TyreTemperature", pf->tyreCoreTemperature);
		printData(L"TyreInnerTemperature", pf->tyreTempI);
		printData(L"TyreMiddleTemperature", pf->tyreTempM);
		printData(L"TyreOuterTemperature", pf->tyreTempO);
		printData(L"TyreTemperature", pf->tyreCoreTemperature);
		printData(L"TyrePressure", pf->wheelsPressure);
		printData(L"BrakeTemperature", pf->brakeTemp);
		printData(L"BrakePadLifeRaw", pf->padLife);
		printData(L"BrakeDiscLifeRaw", pf->discLife);
		printData(L"FrontBrakePadCompoundRaw", pf->frontBrakeCompound + 1);
		printData(L"RearBrakePadCompoundRaw", pf->rearBrakeCompound + 1);

		if (pf->waterTemp)
			printData(L"WaterTemperature", pf->waterTemp);

		if (gf->oil_temperature_c)
			printData(L"OilTemperature", gf->oil_temperature_c);

		wcout << "[Stint Data]" << endl;
		
		wcout << "DriverForname=" << gf->driver_name << endl;
		wcout << "DriverSurname=" << gf->driver_surname << endl;
		try {
			wcout << "DriverNickname=" << gf->driver_name[0] + gf->driver_surname[0] << endl;
		}
		catch (const exception& e) {
			wcout << "DriverNickname=" << endl;
		}
		// printData(L"Sector", gf->currentSectorIndex + 1);
		printData(L"Laps", gf->total_lap_count);
		
		printData(L"LapValid", gf->is_valid_lap ? "true" : "false");
		printData(L"LapLastTime", gf->last_laptime_ms);
		printData(L"LapBestTime", gf->best_laptime_ms);

		wcout << "Position=" << gf->current_pos << endl;
		
		/*
		string penalty = getPenalty(gf->penalty);

		if (penalty.length() != 0)
			printData("Penalty", penalty);
		*/

		printData(L"GapAhead", gf->gap_ahead);
		printData(L"GapBehind", gf->gap_behind);

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

		long timeLeft = (long)gf->session_state.time_left_ms;

		if (timeLeft < 0)
			if (getSession(sf->session, gf->session_state.phase_name) == "Practice")
				timeLeft = 24 * 3600 * 1000;
			else
				timeLeft = 0.0;

		printData(L"StintTimeRemaining", getRemainingTime(timeLeft));
		printData(L"DriverTimeRemaining", getRemainingTime(timeLeft));

		printData(L"InPitLane", (gf->is_in_pit_lane || gf->is_in_pit_box) ? "true" : "false");
		printData(L"InPit", gf->is_in_pit_box ? "true" : "false");

		wcout << "[Track Data]" << endl;

		printData(L"Temperature", pf->roadTemp);

		wcout << "Grip" << getGrip(sf->starting_grip).c_str() << endl;

		/*
		for (int id = 0; id < gf->activeCars; id++) {
			wcout << "Car." << id + 1 << ".ID=" << gf->carID[id] << endl;
			wcout << "Car." << id + 1 << ".Position=" << gf->carCoordinates[id][0] << "," << gf->carCoordinates[id][2] << endl;
		}
		*/

		wcout << "[Weather Data]" << endl;

		printData(L"Temperature", pf->airTemp);
		printData(L"Weather", "Dry");
		printData(L"Weather10min", "Dry");
		printData(L"Weather30min", "Dry");

		wcout << "[Session Data]" << endl;

		printData(L"Active", ((gf->status == AC_LIVE) || (gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false");
		printData(L"Paused", ((gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false");
		printData(L"Session", getSession(sf->session, gf->session_state.phase_name));
		wcout << "ID=" << gf->player_car_id_a << endl;
		wcout << "Car=" << normalizeName(getString(gf->car_model)).c_str() << endl;
		wcout << "Track=" << normalizeName(getString(sf->track)).c_str() << endl;
		wcout << "Layout=" << normalizeName(getString(sf->track_configuration)).c_str() << endl;
		wcout << "SessionFormat=" << ((getSession(sf->session, gf->session_state.phase_name) == "Practice" || sf->is_timed_race != 0) ? "Time" : "Laps") << endl;
		printData(L"FuelAmount", gf->max_fuel);

		printData(L"SessionTimeRemaining", getRemainingTime(timeLeft));

		if (getSession(sf->session, gf->session_state.phase_name) == "Practice")
			printData(L"SessionLapsRemaining", 1000);
		else
			printData(L"SessionLapsRemaining", (gf->last_laptime_ms > 0) ? timeLeft / gf->last_laptime_ms : 99);
	}

	if (strlen(request) == 0 || getArgument(request, "Setup") != "")
	{
		SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

		wcout << "[Setup Data]" << endl;

		printData(L"FuelAmount", gf->pit_info.fuel);
	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


