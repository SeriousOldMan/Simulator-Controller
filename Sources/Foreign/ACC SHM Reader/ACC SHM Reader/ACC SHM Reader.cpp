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

void printData(string name, float value)
{
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

inline const string printWeather(ACC_RAIN_INTENSITY weather) {
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

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();

 	if ((argc == 1) || strchr(argv[1], 'C'))
	{
		wcout << "[Car Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		_bstr_t tc(gf->tyreCompound);
		std::string tyreCompound(tc);

		printData("BodyworkDamage", pf->carDamage);
		printData("SuspensionDamage", pf->suspensionDamage);
		printData("FuelRemaining", pf->fuel);
		wcout << "TyreCompound=" << ((tyreCompound.compare("dry_compound") == 0) ? "Dry" : "Wet") << endl;
		printData("TyreTemperature", pf->tyreCoreTemperature);
		printData("TyrePressure", pf->wheelsPressure);
	}

	if ((argc == 1) || strchr(argv[1], 'S'))
	{
		wcout << "[Stint Data]" << endl;

		SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData("Active", ((gf->status == AC_LIVE) || (gf->status == AC_PAUSE)) ? "true" : "false");
		printData("Paused", (gf->status == AC_PAUSE) ? "true" : "false");
		printData("Session", (gf->session == AC_RACE) ? "RACE" : ((gf->session == AC_QUALIFY) ? "QUALIFY" : "OTHER"));
		wcout << "DriverForname=" << sf->playerName << endl;
		wcout << "DriverSurname=" << sf->playerSurname << endl;
		wcout << "DriverNickname=" << sf->playerNick << endl;
		printData("Laps", gf->completedLaps);
		printData("LapLastTime", gf->iLastTime);
		printData("LapBestTime", gf->iBestTime);
		printData("RaceTimeRemaining", gf->sessionTimeLeft);
		printData("StintTimeRemaining", gf->DriverStintTimeLeft);
		printData("DriverTimeRemaining", gf->DriverStintTotalTimeLeft);
		printData("InPit", gf->isInPit ? "true" : "false");

	}

	if ((argc == 1) || strchr(argv[1], '´T'))
	{
		wcout << "[Track Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData("Temperature", pf->roadTemp);

		_bstr_t ts(gf->trackStatus);
		const char* trackStatus = ts;

		printData("Grip", trackStatus);
	}

	if ((argc == 1) || strchr(argv[1], '´P'))
	{
		wcout << "[Pitstop Data]" << endl;

		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData("TyreSet", gf->mfdTyreSet + 1);
		printData("FuelAmount", gf->mfdFuelToAdd);
		printData("TyrePressureFL", gf->mfdTyrePressureFL);
		printData("TyrePressureFR", gf->mfdTyrePressureFR);
		printData("TyrePressureRL", gf->mfdTyrePressureRL);
		printData("TyrePressureRR", gf->mfdTyrePressureRR);
	}
	
	if ((argc == 1) || strchr(argv[1], '´W'))
	{
		wcout << "[Weather Data]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
		SPageFileGraphic* gf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

		printData("Temperature", pf->airTemp);
		printData("Weather", printWeather(gf->rainIntensity));
		printData("Weather10min", printWeather(gf->rainIntensityIn10min));
		printData("Weather30min", printWeather(gf->rainIntensityIn30min));
	}

	if ((argc == 1) || strchr(argv[1], 'R'))
	{
		wcout << "[Race Data]" << endl;

		SPageFileStatic* sf = (SPageFileStatic*)m_static.mapFileBuffer;

		wcout << "Car=" << sf->carModel << endl;
		wcout << "Track=" << sf->track << endl;
		printData("FuelAmount", sf->maxFuel);

	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


