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

inline string getString(wchar_t* str) {
	wstring s(str);

	return string(s.begin(), s.end());
}

inline string getString(char* str) {
	string s(str);

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

inline const string getSession(int sessionType, string phaseName) {
	if (sessionType == AC_RACE)
		return "Race";
	else
		return "Other";
}

long getRemainingTime(long timeLeft);

long getRemainingLaps(long timeLeft)
{
	SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
	SPageFileStaticEvo* sf = (SPageFileStaticEvo*)m_static.mapFileBuffer;

	if (getSession(sf->session, gf->session_state.phase_name) != "Practice")
	{
		if (!sf->is_timed_race)
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

	if (getSession(sf->session, gf->session_state.phase_name) == "Practice" || sf->is_timed_race)
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

bool connected = false;

extern "C" __declspec(dllexport) int __stdcall open() {
	initPhysics();
	initGraphics();
	initStatic();

	connected = true;
	
	return 0;
}

extern "C" __declspec(dllexport) int __stdcall close() {
	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	connected = false;
	
	return 0;
}

extern "C" __declspec(dllexport) int __stdcall call(char* request, char* result, int size)
{
	SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
	SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
	SPageFileStaticEvo* sf = (SPageFileStaticEvo*)m_static.mapFileBuffer;
	ostringstream output;

	if (!connected) {
		open();

		if (!connected) {
			output << "";

			strcpy_s(result, size, output.str().c_str());

			return -1;
		}
	}

	if (strlen(request) == 0)
	{
		output << "[Car Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphicEvo* gf = (SPageFileGraphicEvo*)m_graphics.mapFileBuffer;
		SPageFileStaticEvo* sf = (SPageFileStaticEvo*)m_static.mapFileBuffer;

		printNAData(&output, "MAP", gf->electronics.engine_map_level + 1);
		printNAData(&output, "TC", gf->electronics.tc_level);
		printNAData(&output, "ABS", gf->electronics.abs_level);
		printNAData(&output, "BBRaw", pf->brakeBias);

		/*
		printData(&output, "Ignition", pf->ignitionOn ? "true" : "false");
		printData(&output, "HeadLights", (gf->lightsStage == 0) ? "Off" : (gf->lightsStage == 1) ? "Low" : "High");
		printData(&output, "RainLights", gf->rainLights ? "true" : "false");
		output << "PitLimiter=" << ((pf->pitLimiterOn == 0) ? "false" : "true") << endl;
		*/

		printData(&output, "BodyworkDamage", pf->carDamage);
		printData(&output, "SuspensionDamage", pf->suspensionDamage);
		printData(&output, "EngineDamage", 0);
		printData(&output, "FuelRemaining", pf->fuel);

		output << "TyreCompoundRawFront=" << gf->tyre_lf.tyre_compound_front << endl;
		output << "TyreCompoundRawRear=" << gf->tyre_lf.tyre_compound_rear << endl;

		printData(&output, "TyreTemperature", pf->tyreCoreTemperature);

		/*
		printData(&output, "TyreInnerTemperature", pf->tyreTempI);
		printData(&output, "TyreMiddleTemperature", pf->tyreTempM);
		printData(&output, "TyreOuterTemperature", pf->tyreTempO);
		*/

		printData(&output, "TyreWear", pf->tyreWear);
		printData(&output, "TyreTemperature", pf->tyreCoreTemperature);
		printData(&output, "TyrePressure", pf->wheelsPressure);
		printData(&output, "BrakeTemperature", pf->brakeTemp);
		printData(&output, "BrakePadLifeRaw", pf->padLife);
		printData(&output, "BrakeDiscLifeRaw", pf->discLife);
		printData(&output, "FrontBrakePadCompoundRaw", pf->frontBrakeCompound + 1);
		printData(&output, "RearBrakePadCompoundRaw", pf->rearBrakeCompound + 1);

		if (pf->waterTemp)
			printData(&output, "WaterTemperature", pf->waterTemp);

		if (gf->oil_temperature_c)
			printData(&output, "OilTemperature", gf->oil_temperature_c);

		output << "[Stint Data]" << endl;

		output << "DriverForname=" << gf->driver_name << endl;
		output << "DriverSurname=" << gf->driver_surname << endl;
		output << "DriverNickname=" << endl;
		// printData(&output, "Sector", gf->currentSectorIndex + 1);
		printData(&output, "Running", gf->npos);
		printData(&output, "Laps", gf->total_lap_count);

		output << "LapValid=" << (gf->is_valid_lap ? "true" : "false") << endl;
		printData(&output, "LapLastTime", gf->last_laptime_ms);
		printData(&output, "LapBestTime", gf->best_laptime_ms);

		output << "Position=" << gf->current_pos << endl;

		/*
		string penalty = getPenalty(gf->penalty);

		if (penalty.length() != 0)
			printData(&output, "Penalty", penalty);
		*/

		printData(&output, "GapAhead", gf->gap_ahead);
		printData(&output, "GapBehind", gf->gap_behind);

		/*
		if (gf->session == AC_PRACTICE) {
			printData(&output, "StintTimeRemaining", 3600000);
			printData(&output, "DriverTimeRemaining", 3600000);
		}
		else {
			double timeLeft = gf->sessionTimeLeft;

			if (timeLeft < 0) {
				timeLeft = 3600.0 * 1000;
			}

			printData(&output, "StintTimeRemaining", gf->DriverStintTimeLeft < 0 ? timeLeft : gf->DriverStintTimeLeft);
			printData(&output, "DriverTimeRemaining", gf->DriverStintTotalTimeLeft < 0 ? timeLeft : gf->DriverStintTotalTimeLeft);
		}
		*/

		long timeLeft = (long)gf->session_state.time_left_ms;

		if (timeLeft < 0)
			if (getSession(sf->session, gf->session_state.phase_name) == "Practice")
				timeLeft = 24 * 3600 * 1000;
			else
				timeLeft = 0.0;

		printData(&output, "StintTimeRemaining", getRemainingTime(timeLeft));
		printData(&output, "DriverTimeRemaining", getRemainingTime(timeLeft));

		output << "InPitLane=" << ((gf->is_in_pit_lane || gf->is_in_pit_box) ? "true" : "false") << endl;
		output << "InPit=" << (gf->is_in_pit_box ? "true" : "false") << endl;

		output << "[Track Data]" << endl;
		printData(&output, "Length", sf->track_length_m);
		printData(&output, "Temperature", pf->roadTemp);

		output << "Grip=" << getGrip(sf->starting_grip).c_str() << endl;

		for (int id = 0; id < gf->active_cars; id++) {
			// output << "Car." << id + 1 << ".ID=" << gf->carID[id] << endl;
			output << "Car." << id + 1 << ".Position=" << gf->car_coordinates[id][0] << "," << gf->car_coordinates[id][2] << endl;
		}

		output << "[Weather Data]" << endl;

		printData(&output, "Temperature", pf->airTemp);
		output << "Weather=Dry" << endl;
		output << "Weather10Min=Dry" << endl;
		output << "Weather30Min=Dry" << endl;

		output << "[Session Data]" << endl;

		output << "Active=" << (((gf->status == AC_LIVE) || (gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false") << endl;
		output << "Paused=" << (((gf->status == AC_PAUSE) || (gf->status == AC_REPLAY)) ? "true" : "false") << endl;
		output << "Session=" << getSession(sf->session, gf->session_state.phase_name).c_str() << endl;
		output << "ID=" << gf->player_car_id_a << endl;
		output << "Car=" << normalizeName(getString(gf->car_model)).c_str() << endl;
		output << "Track=" << normalizeName(getString(sf->track)).c_str() << endl;
		output << "Layout=" << normalizeName(getString(sf->track_configuration)).c_str() << endl;
		output << "SessionFormat=" << ((getSession(sf->session, gf->session_state.phase_name) == "Practice" || sf->is_timed_race) ? "Time" : "Laps") << endl;
		printData(&output, "FuelAmount", gf->max_fuel);

		printData(&output, "SessionTimeRemaining", getRemainingTime(timeLeft));

		if (getSession(sf->session, gf->session_state.phase_name) == "Practice")
			printData(&output, "SessionLapsRemaining", 1000);
		else
			printData(&output, "SessionLapsRemaining", (gf->last_laptime_ms > 0) ? timeLeft / gf->last_laptime_ms : 99);
	}

	strcpy_s(result, size, output.str().c_str());
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