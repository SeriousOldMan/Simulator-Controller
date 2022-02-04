#pragma once

#include <Windows.h>

#define CLOCKS_PER_MS (CLOCKS_PER_SEC / 1000)
#define RPS_TO_RPM (60 / (2 * M_PI))
#define MPS_TO_KPH 3.6f

BOOL is_process_running(const TCHAR* name);
BOOL is_r3e_running();