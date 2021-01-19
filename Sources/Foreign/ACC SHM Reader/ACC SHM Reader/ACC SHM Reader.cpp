// ConsoleApplication1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <tchar.h>
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

int main(int argc, char* argv[])
{
	initPhysics();
	initGraphics();
	initStatic();

 	if ((argc == 1) || strchr(argv[1], 'C'))
	{
		wcout << "[Car State]" << endl;

		SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

		printData("BodyWorkDamage", pf->carDamage);
		printData("SuspensionDamage", pf->suspensionDamage);
		printData("FuelRemaining", pf->fuel);
		printData("TyreTemperature", pf->tyreCoreTemperature);
		printData("TyrePressure", pf->wheelsPressure);
		printData("TyreWear", pf->tyreWear);
	}

	if ((argc == 1) || strchr(argv[1], 'S'))
	{
		wcout << "[Stint State]" << endl;

		SPageFileGraphic* pf = (SPageFileGraphic*)m_graphics.mapFileBuffer;
		
		printData("Active", (pf->status == AC_LIVE) ? "true" : "false");
		printData("Laps", pf->completedLaps);
        printData("LapLastTime", pf->iLastTime);
		printData("LapBestTime", pf->iBestTime);
		printData("TimeLeft", pf->sessionTimeLeft);
		printData("InPit", pf->isInPit ? "true" : "false");
		wcout << "TyreCompound=" << pf->tyreCompound << endl;
	}

	if ((argc == 1) || strchr(argv[1], 'I'))
	{
		wcout << "[Car Data]" << endl;

		SPageFileStatic* pf = (SPageFileStatic*)m_static.mapFileBuffer;

		wcout << "DriverName=" << pf->playerSurname << endl;
		printData("FuelAmount", pf->maxFuel);

	}

	dismiss(m_graphics);
	dismiss(m_physics);
	dismiss(m_static);

	return 0;
}


