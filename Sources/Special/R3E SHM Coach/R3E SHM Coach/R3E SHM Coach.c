#include "r3e.h"
#include "utils.h"

#define _USE_MATH_DEFINES

#include <math.h>
#include <stdio.h>
#include <time.h>
#include <Windows.h>
#include <tchar.h>

#pragma comment(lib, "winmm")

#define ALIVE_SEC 600
#define INTERVAL_MS 100

HANDLE map_handle = INVALID_HANDLE_VALUE;
r3e_shared* map_buffer = NULL;

HANDLE map_open()
{
    return OpenFileMapping(
        FILE_MAP_READ,
        FALSE,
        TEXT(R3E_SHARED_MEMORY_NAME));
}

BOOL map_exists()
{
    HANDLE handle = map_open();

    if (handle != NULL)
        CloseHandle(handle);
        
    return handle != NULL;
}

int map_init()
{
    map_handle = map_open();

    if (map_handle == NULL)
    {
        return 1;
    }

    map_buffer = (r3e_shared*)MapViewOfFile(map_handle, FILE_MAP_READ, 0, 0, sizeof(r3e_shared));
    if (map_buffer == NULL)
    {
        return 1;
    }

    return 0;
}

void map_close()
{
    if (map_buffer) UnmapViewOfFile(map_buffer);
    if (map_handle) CloseHandle(map_handle);
}

int getPlayerID() {
	for (int i = 0; i < map_buffer->num_cars; i++) {
		if (map_buffer->all_drivers_data_1[i].place == map_buffer->position) {
			return map_buffer->all_drivers_data_1[i].driver_info.user_id;
		}
	}

	return -1;
}

int getPlayerIndex() {
	for (int i = 0; i < map_buffer->num_cars; i++) {
		if (map_buffer->all_drivers_data_1[i].place == map_buffer->position) {
			return i;
		}
	}

	return -1;
}

int sendStringMessage(HWND hWnd, int wParam, char* msg) {
	int result = 0;

	if (hWnd > 0) {
		COPYDATASTRUCT cds;
		cds.dwData = (256 * 'D' + 'C');
		cds.cbData = sizeof(char) * (strlen(msg) + 1);
		cds.lpData = msg;

		result = SendMessage(hWnd, WM_COPYDATA, wParam, (LPARAM)(LPVOID)&cds);
	}

	return result;
}

void sendTriggerMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Driving Coach.ahk");

	if (winHandle != 0) {
		char buffer[512];

		strcpy_s(buffer, 512, "Driving Coach:");
		strcpy_s(buffer + strlen("Driving Coach:"), 512 - strlen("Driving Coach:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

void sendAnalyzerMessage(char* message) {
	HWND winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.exe");

	if (winHandle == 0)
		winHandle = FindWindowEx(0, 0, 0, L"Setup Workbench.ahk");

	if (winHandle != 0) {
		char buffer[512];

		strcpy_s(buffer, 512, "Analyzer:");
		strcpy_s(buffer + strlen("Analyzer:"), 512 - strlen("Analyzer:"), message);

		sendStringMessage(winHandle, 0, buffer);
	}
}

BOOL fileExists(char* name) {
	FILE* file;

	if (!fopen_s(&file, name, "r")) {
		fclose(file);

		return TRUE;
	}
	else
		return FALSE;
}

void splitString(const char* s, const char* delimiter, int count, char** parts) {
	char* pos = strstr(s, delimiter);
	int numParts = 0;

	while (pos) {
		if (count != 0 && numParts >= (count - 1))
			break;

		int i = 0;

		for (char* c = (char *)s; i < 255 && c < pos; c++)
			parts[numParts][i++] = *c;

		parts[numParts][i] = '\0';

		s = (pos + strlen(delimiter));

		numParts += 1;
		pos = strstr(s, delimiter);
	}

	int i = 0;

	for (char* c = (char*)s; i < 255 && *c != '\0' && *c != '\n'; c++)
		parts[numParts][i++] = *c;

	parts[numParts][i] = '\0';
}

inline r3e_float64 vectorLength(r3e_float64 x, r3e_float64 y) {
	return sqrt((x * x) + (y * y));
}


char* player = "";
char* workingDirectory = "";
char* audioDevice = "";
float volume = 0;
STARTUPINFOA si = { sizeof(si) };

void playSound(char* wavFile, BOOL wait) {
	PROCESS_INFORMATION pi;

	char buffer[512];
	
	if (strcmp(audioDevice, "") == 0)
		sprintf_s(buffer, 256, "\"%s\" \"%s\" -t waveaudio vol %f", player, wavFile, volume);
	else
		sprintf_s(buffer, 256, "\"%s\" \"%s\" -t waveaudio \"%s\" vol %f", player, wavFile, audioDevice, volume);

	if (CreateProcessA(
		NULL,               // Application name
		buffer,				// Command line
		NULL,               // Process handle not inheritable
		NULL,               // Thread handle not inheritable
		FALSE,              // Set handle inheritance to FALSE
		0,                  // No creation flags
		NULL,               // Use parent's environment block
		workingDirectory,
		&si,                // Pointer to STARTUPINFO structure
		&pi)                // Pointer to PROCESS_INFORMATION structure
		)
	{
		if (wait)
			// Wait until process exits
			WaitForSingleObject(pi.hProcess, INFINITE);

		// Close process and thread handles
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	}
}

/* Configuration parameters */
int lightBottomOutThreshold = 5;
int mediumBottomOutThreshold = 10;
int heavyBottomOutThreshold = 15;
float releaseThreshold = 0.2f;
int bottomOutDuration = 30;
int bottomOutGap = 100;
int samplerMinSamples = 2;
int deflectionMovingAverage = 5;
int accelerationMovingAverage = 2;

/* Moving Average Structure */
typedef struct {
	double* window;
	int window_size;
	int head;
	int count;
	double sum;
} MovingAverage;

MovingAverage* MovingAverage_Create(int period)
{
	MovingAverage* ma;

	if (period <= 0) {
		fprintf(stderr, "Period must be greater than zero.\n");
		return NULL;
	}

	ma = (MovingAverage*)malloc(sizeof(MovingAverage));
	if (!ma) return NULL;

	ma->window = (double*)calloc(period, sizeof(double));
	if (!ma->window) {
		free(ma);
		return NULL;
	}

	ma->window_size = period;
	ma->head = 0;
	ma->count = 0;
	ma->sum = 0.0;

	return ma;
}

double MovingAverage_Add(MovingAverage* ma, double newValue)
{
	if (!ma) return 0.0;

	if (ma->count == ma->window_size)
		ma->sum -= ma->window[ma->head];

	ma->window[ma->head] = newValue;
	ma->sum += newValue;
	ma->head = (ma->head + 1) % ma->window_size;

	if (ma->count < ma->window_size)
		ma->count++;

	return ma->sum / ma->count;
}

void MovingAverage_Destroy(MovingAverage* ma)
{
	if (ma) {
		free(ma->window);
		free(ma);
	}
}

/* Suspension Deflections Structure */
typedef struct {
	int completedLaps;
	long timeMS;
	double frontLeft;
	double frontRight;
	double rearLeft;
	double rearRight;
} SuspensionDeflections;

SuspensionDeflections* SuspensionDeflections_Create(
	int completedLaps,
	double suspensionDeflectionFL,
	double suspensionDeflectionFR,
	double suspensionDeflectionRL,
	double suspensionDeflectionRR)
{
	SuspensionDeflections* deflections;
	FILETIME ft;
	ULARGE_INTEGER uli;

	deflections = (SuspensionDeflections*)malloc(sizeof(SuspensionDeflections));
	if (!deflections) return NULL;

	deflections->completedLaps = completedLaps;
	deflections->frontLeft = suspensionDeflectionFL * 1000.0;
	deflections->frontRight = suspensionDeflectionFR * 1000.0;
	deflections->rearLeft = suspensionDeflectionRL * 1000.0;
	deflections->rearRight = suspensionDeflectionRR * 1000.0;

	/* Get current time in milliseconds */
	GetSystemTimeAsFileTime(&ft);
	uli.LowPart = ft.dwLowDateTime;
	uli.HighPart = ft.dwHighDateTime;
	deflections->timeMS = (long)((uli.QuadPart / 10000) - 116444736000000000LL);

	return deflections;
}

void SuspensionDeflections_Destroy(SuspensionDeflections* deflections)
{
	free(deflections);
}

/* Suspension Bottom Outs Structure */
typedef struct {
	int completedLaps;
	char* axle;
	long startTimeMs;
	long endTimeMs;
	double peakAcceleration;
	double avgAcceleration;
	double impulse;
} SuspensionBottomOuts;

SuspensionBottomOuts* SuspensionBottomOuts_Create(
	int completedLaps,
	double acceleration,
	const char* axle)
{
	SuspensionBottomOuts* event;

	event = (SuspensionBottomOuts*)malloc(sizeof(SuspensionBottomOuts));
	if (!event) return NULL;

	event->completedLaps = completedLaps;
	event->axle = (char*)malloc(strlen(axle) + 1);
	if (!event->axle) {
		free(event);
		return NULL;
	}
	strcpy_s(event->axle, strlen(axle) + 1, axle);
	event->peakAcceleration = acceleration;
	event->startTimeMs = 0;
	event->endTimeMs = 0;
	event->avgAcceleration = 0.0;
	event->impulse = 0.0;

	return event;
}

long SuspensionBottomOuts_GetDurationMs(SuspensionBottomOuts* event)
{
	if (!event) return 0;
	return event->endTimeMs - event->startTimeMs;
}

const char* SuspensionBottomOuts_GetSeverity(SuspensionBottomOuts* event)
{
	double gForce;

	if (!event) return "Light";

	gForce = fabs(event->peakAcceleration);

	if (gForce > heavyBottomOutThreshold)
		return "Heavy";
	else if (gForce > mediumBottomOutThreshold)
		return "Medium";
	else
		return "Light";
}

void SuspensionBottomOuts_Destroy(SuspensionBottomOuts* event)
{
	if (event) {
		free(event->axle);
		free(event);
	}
}

/* Dynamic Arrays */
typedef struct {
	SuspensionDeflections** items;
	int size;
	int capacity;
} DeflectionArray;

DeflectionArray* DeflectionArray_Create()
{
	DeflectionArray* arr = (DeflectionArray*)malloc(sizeof(DeflectionArray));
	if (!arr) return NULL;
	arr->capacity = 100;
	arr->size = 0;
	arr->items = (SuspensionDeflections**)malloc(arr->capacity * sizeof(SuspensionDeflections*));
	if (!arr->items) {
		free(arr);
		return NULL;
	}
	return arr;
}

void DeflectionArray_Add(DeflectionArray* arr, SuspensionDeflections* item)
{
	if (!arr) return;

	if (arr->size >= arr->capacity) {
		arr->capacity *= 2;
		arr->items = (SuspensionDeflections**)realloc(arr->items, arr->capacity * sizeof(SuspensionDeflections*));
	}
	arr->items[arr->size++] = item;
}

void DeflectionArray_Destroy(DeflectionArray* arr)
{
	if (arr) {
		for (int i = 0; i < arr->size; i++)
			if (arr->items[i] != NULL)
				SuspensionDeflections_Destroy(arr->items[i]);
		free(arr->items);
		free(arr);
	}
}

typedef struct {
	SuspensionBottomOuts** items;
	int size;
	int capacity;
} BottomOutArray;

BottomOutArray* BottomOutArray_Create()
{
	BottomOutArray* arr = (BottomOutArray*)malloc(sizeof(BottomOutArray));
	if (!arr) return NULL;
	arr->capacity = 100;
	arr->size = 0;
	arr->items = (SuspensionBottomOuts**)malloc(arr->capacity * sizeof(SuspensionBottomOuts*));
	if (!arr->items) {
		free(arr);
		return NULL;
	}
	return arr;
}

void BottomOutArray_Add(BottomOutArray* arr, SuspensionBottomOuts* item)
{
	if (!arr) return;

	if (arr->size >= arr->capacity) {
		arr->capacity *= 2;
		arr->items = (SuspensionBottomOuts**)realloc(arr->items, arr->capacity * sizeof(SuspensionBottomOuts*));
	}
	arr->items[arr->size++] = item;
}

void BottomOutArray_Destroy(BottomOutArray* arr)
{
	if (arr) {
		int i;
		for (i = 0; i < arr->size; i++)
			SuspensionBottomOuts_Destroy(arr->items[i]);
		free(arr->items);
		free(arr);
	}
}

typedef struct {
	double* first;
	double* second;
	int size;
	int capacity;
} DoublePairArray;

DoublePairArray* DoublePairArray_Create()
{
	DoublePairArray* arr = (DoublePairArray*)malloc(sizeof(DoublePairArray));
	if (!arr) return NULL;
	arr->capacity = 100;
	arr->size = 0;
	arr->first = (double*)malloc(arr->capacity * sizeof(double));
	arr->second = (double*)malloc(arr->capacity * sizeof(double));
	if (!arr->first || !arr->second) {
		free(arr->first);
		free(arr->second);
		free(arr);
		return NULL;
	}
	return arr;
}

void DoublePairArray_Add(DoublePairArray* arr, double f, double s)
{
	if (!arr) return;

	if (arr->size >= arr->capacity) {
		arr->capacity *= 2;
		arr->first = (double*)realloc(arr->first, arr->capacity * sizeof(double));
		arr->second = (double*)realloc(arr->second, arr->capacity * sizeof(double));
	}
	arr->first[arr->size] = f;
	arr->second[arr->size] = s;
	arr->size++;
}

void DoublePairArray_Destroy(DoublePairArray* arr)
{
	if (arr) {
		free(arr->first);
		free(arr->second);
		free(arr);
	}
}

typedef struct {
	long* first;
	double* second;
	int size;
	int capacity;
} LongDoublePairArray;

LongDoublePairArray* LongDoublePairArray_Create()
{
	LongDoublePairArray* arr = (LongDoublePairArray*)malloc(sizeof(LongDoublePairArray));
	if (!arr) return NULL;
	arr->capacity = 100;
	arr->size = 0;
	arr->first = (long*)malloc(arr->capacity * sizeof(long));
	arr->second = (double*)malloc(arr->capacity * sizeof(double));
	if (!arr->first || !arr->second) {
		free(arr->first);
		free(arr->second);
		free(arr);
		return NULL;
	}
	return arr;
}

void LongDoublePairArray_Add(LongDoublePairArray* arr, long f, double s)
{
	if (!arr) return;

	if (arr->size >= arr->capacity) {
		arr->capacity *= 2;
		arr->first = (long*)realloc(arr->first, arr->capacity * sizeof(long));
		arr->second = (double*)realloc(arr->second, arr->capacity * sizeof(double));
	}
	arr->first[arr->size] = f;
	arr->second[arr->size] = s;
	arr->size++;
}

void LongDoublePairArray_Destroy(LongDoublePairArray* arr)
{
	if (arr) {
		free(arr->first);
		free(arr->second);
		free(arr);
	}
}

typedef struct {
	double* items;
	int size;
	int capacity;
} DoubleArray;

DoubleArray* DoubleArray_Create()
{
	DoubleArray* arr = (DoubleArray*)malloc(sizeof(DoubleArray));
	if (!arr) return NULL;
	arr->capacity = 100;
	arr->size = 0;
	arr->items = (double*)malloc(arr->capacity * sizeof(double));
	if (!arr->items) {
		free(arr);
		return NULL;
	}
	return arr;
}

void DoubleArray_Add(DoubleArray* arr, double item)
{
	if (!arr) return;

	if (arr->size >= arr->capacity) {
		arr->capacity *= 2;
		arr->items = (double*)realloc(arr->items, arr->capacity * sizeof(double));
	}
	arr->items[arr->size++] = item;
}

double DoubleArray_Sum(DoubleArray* arr)
{
	double sum = 0.0;
	int i;
	if (!arr) return 0.0;
	for (i = 0; i < arr->size; i++)
		sum += arr->items[i];
	return sum;
}

void DoubleArray_Destroy(DoubleArray* arr)
{
	if (arr) {
		free(arr->items);
		free(arr);
	}
}

typedef struct {
	int* items;
	int size;
	int capacity;
} IntArray;

IntArray* IntArray_Create()
{
	IntArray* arr = (IntArray*)malloc(sizeof(IntArray));
	if (!arr) return NULL;
	arr->capacity = 100;
	arr->size = 0;
	arr->items = (int*)malloc(arr->capacity * sizeof(int));
	if (!arr->items) {
		free(arr);
		return NULL;
	}
	return arr;
}

void IntArray_Add(IntArray* arr, int item)
{
	if (!arr) return;

	if (arr->size >= arr->capacity) {
		arr->capacity *= 2;
		arr->items = (int*)realloc(arr->items, arr->capacity * sizeof(int));
	}
	arr->items[arr->size++] = item;
}

void IntArray_Destroy(IntArray* arr)
{
	if (arr) {
		free(arr->items);
		free(arr);
	}
}

#define MAXVALUES 6
#define PI 3.14159265

float recentSteerAngles[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentSteerAnglesCount = 0;

float recentGLongs[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentGLongsCount = 0;

float recentRealAngVels[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentRealAngVelsCount = 0;

float recentIdealAngVels[MAXVALUES] = { 0, 0, 0, 0, 0, 0 };
int recentIdealAngVelsCount = 0;

void pushValue(float* values, int* count, float value) {
	if (*count == MAXVALUES) {
		for (int i = 1; i < *count; i++)
			values[i - 1] = values[i];

		(*count)--;
	}

	values[(*count)++] = value;
}

float averageValue(float* values, int count) {
	float sum = 0.0;
	for (int i = 0; i < count; i++)
		sum += values[i];

	return (count > 0) ? sum / count : 0.0f;
}

float smoothValue(float* values, int* count, float value) {
	if (FALSE) {
		pushValue(values, count, value);

		return averageValue(values, *count);
	}
	else
		return value;
}

#define NumCornerDynamics 4096
typedef struct {
	float speed;
	double usos;
	int completedLaps;
	int phase;
} corner_dynamics;
corner_dynamics cornerDynamicsRing[NumCornerDynamics];
int cornerDynamicsStart = 0;
int cornerDynamicsEnd = 0;

void appendCornerDynamics(corner_dynamics* cd) {
	cornerDynamicsRing[cornerDynamicsEnd] = *cd;

	if (cornerDynamicsStart <= cornerDynamicsEnd) {
		if (++cornerDynamicsEnd == NumCornerDynamics) {
			cornerDynamicsEnd = 0;
			cornerDynamicsStart++;
		}
	}
	else {
		if (++cornerDynamicsEnd == NumCornerDynamics)
			cornerDynamicsEnd = 0;

		if (++cornerDynamicsStart == NumCornerDynamics)
			cornerDynamicsStart = 0;
	}
}

corner_dynamics* nextCornerDynamics(int* index) {
	corner_dynamics* result;

	while (TRUE) {
		if (*index == cornerDynamicsEnd)
			return NULL;

		if (*index == NumCornerDynamics)
			*index = 0;
		else {
			result = &cornerDynamicsRing[(*index)++];

			if (result->speed != 0)
				return result;
		}
	}
}

corner_dynamics* firstCornerDynamics(int* index) {
	*index = cornerDynamicsStart;

	return nextCornerDynamics(index);
}

void clearCornerDynamics(int lastLap) {
	int index;

	for (corner_dynamics* corner = firstCornerDynamics(&index); corner != NULL; corner = nextCornerDynamics(&index))
		if (corner->completedLaps < lastLap - 1)
			corner->speed = 0;
}

char dataFile[512];
int understeerLightThreshold = 12;
int understeerMediumThreshold = 20;
int understeerHeavyThreshold = 35;
int oversteerLightThreshold = 2;
int oversteerMediumThreshold = -6;
int oversteerHeavyThreshold = -10;
int lowspeedThreshold = 100;
int wheelbase = 270;
int trackWidth = 150;

int lastCompletedLaps = 0;
r3e_float32 lastSpeed = 0.0f;
long lastSound = 0;

BOOL triggerUSOSBeep(char* soundsDirectory, double usos) {
	BOOL sound = TRUE;
	char wavFile[255];

	strcpy_s(wavFile, 255, soundsDirectory);
	strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "");

	if (usos < oversteerHeavyThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Oversteer Heavy.wav");
	else if (usos < oversteerMediumThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Oversteer Medium.wav");
	else if (usos < oversteerLightThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Oversteer Light.wav");
	else if (usos > understeerHeavyThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Understeer Heavy.wav");
	else if (usos > understeerMediumThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Understeer Medium.wav");
	else if (usos > understeerLightThreshold)
		strcpy_s(wavFile + strlen(soundsDirectory), 255 - strlen(soundsDirectory), "\\Understeer Light.wav");
	else
		sound = FALSE;

	if (sound) {
		if (strcmp(audioDevice, "") != 0) {
			if (strcmp(player, "") == 0) {
				char buffer[512];

				strcpy_s(buffer, 512, "acousticFeedback:");
				strcpy_s(buffer + strlen("acousticFeedback:"), 512 - strlen("acousticFeedback:"), wavFile);

				sendAnalyzerMessage(buffer);
			}
			else
				playSound(wavFile, FALSE);
		}
		else
			PlaySoundA(wavFile, NULL, SND_FILENAME | SND_ASYNC);

		return TRUE;
	}
	else
		return FALSE;
}

/* Global suspension deflections list */
DeflectionArray* suspensionDeflectionsList = NULL;

void clearSuspensionDeflections(int lastLap) {
	DeflectionArray* new = DeflectionArray_Create();

	for (int i = 0; i < suspensionDeflectionsList->size; i++)
		if (suspensionDeflectionsList->items[i]->completedLaps >= lastLap - 1) {
			DeflectionArray_Add(new, suspensionDeflectionsList->items[i]);
			suspensionDeflectionsList->items[i] = NULL;
		}

	DeflectionArray_Destroy(suspensionDeflectionsList);
	suspensionDeflectionsList = new;
}

/* Typedef for deflection getter function pointer */
typedef double (*DeflectionGetter)(const SuspensionDeflections*);

double GetFrontLeft(const SuspensionDeflections* d) { return d->frontLeft; }
double GetFrontRight(const SuspensionDeflections* d) { return d->frontRight; }
double GetRearLeft(const SuspensionDeflections* d) { return d->rearLeft; }
double GetRearRight(const SuspensionDeflections* d) { return d->rearRight; }

double CalculateAccelerationValue(
	long lastTime, double lastDeflection,
	long time, double deflection,
	long nextTime, double nextDeflection)
{
	long dt1 = (time - lastTime);
	long dt2 = (nextTime - time);
	double term1, term2;

	if (dt1 <= 0 || dt2 <= 0)
		return 0.0;

	term1 = (nextDeflection - deflection) / dt2;
	term2 = (deflection - lastDeflection) / dt1;

	return 2.0 * (term1 - term2) / ((dt1 + dt2) / 1000.0);
}

DoublePairArray* CalculateAccelerations(const LongDoublePairArray* deflections)
{
	DoublePairArray* accelerations;
	MovingAverage* accelerationMA;
	int size, i;
	double accel;

	accelerations = DoublePairArray_Create();
	if (!accelerations) return NULL;

	size = deflections->size;
	accelerationMA = MovingAverage_Create(accelerationMovingAverage);
	if (!accelerationMA) {
		DoublePairArray_Destroy(accelerations);
		return NULL;
	}

	if (size > 3) {
		for (i = 1; i < (size - 1); i++) {
			accel = CalculateAccelerationValue(
				deflections->first[i - 1], deflections->second[i - 1],
				deflections->first[i], deflections->second[i],
				deflections->first[i + 1], deflections->second[i + 1]);

			DoublePairArray_Add(accelerations,
				MovingAverage_Add(accelerationMA, accel),
				deflections->second[i]);
		}
	}

	if (accelerations->size > 0) {
		DoublePairArray_Add(accelerations,
			accelerations->first[accelerations->size - 1],
			accelerations->second[accelerations->size - 1]);

		memmove(accelerations->first + 1, accelerations->first,
			(accelerations->size - 1) * sizeof(double));
		memmove(accelerations->second + 1, accelerations->second,
			(accelerations->size - 1) * sizeof(double));
		accelerations->first[0] = accelerations->first[1];
		accelerations->second[0] = accelerations->second[1];
		accelerations->size++;
	}

	MovingAverage_Destroy(accelerationMA);
	return accelerations;
}

LongDoublePairArray* ExtractDeflections(DeflectionGetter getter)
{
	LongDoublePairArray* smoothedDeflections;
	MovingAverage* deflectionMA;
	int i;

	smoothedDeflections = LongDoublePairArray_Create();
	if (!smoothedDeflections) return NULL;

	deflectionMA = MovingAverage_Create(deflectionMovingAverage);
	if (!deflectionMA) {
		LongDoublePairArray_Destroy(smoothedDeflections);
		return NULL;
	}

	for (i = 0; i < suspensionDeflectionsList->size; i++) {
		double smoothed = MovingAverage_Add(deflectionMA, getter(suspensionDeflectionsList->items[i]));
		LongDoublePairArray_Add(smoothedDeflections,
			suspensionDeflectionsList->items[i]->timeMS,
			smoothed);
	}

	MovingAverage_Destroy(deflectionMA);
	return smoothedDeflections;
}

double CalculateImpulse(long duration, DoubleArray* accelerationValues)
{
	double impulse = 0.0;
	int i;

	if (!accelerationValues || accelerationValues->size == 0)
		return 0.0;

	for (i = 0; i < accelerationValues->size - 1; i++) {
		impulse += (accelerationValues->items[i] + accelerationValues->items[i + 1]) / 2.0 *
			(((double)duration) / 1000.0);
	}

	return impulse;
}

BottomOutArray* MergeCloseEvents(BottomOutArray* allEvents)
{
	BottomOutArray* merged;
	SuspensionBottomOuts* currentEvent;
	long gap;
	int i;

	merged = BottomOutArray_Create();
	if (!merged) return NULL;

	if (allEvents->size <= 1)
		return allEvents;

	currentEvent = SuspensionBottomOuts_Create(
		allEvents->items[0]->completedLaps,
		allEvents->items[0]->peakAcceleration,
		allEvents->items[0]->axle);

	currentEvent->startTimeMs = allEvents->items[0]->startTimeMs;
	currentEvent->endTimeMs = allEvents->items[0]->endTimeMs;
	currentEvent->avgAcceleration = allEvents->items[0]->avgAcceleration;
	currentEvent->impulse = allEvents->items[0]->impulse;

	for (i = 1; i < allEvents->size; i++) {
		gap = allEvents->items[i]->startTimeMs - currentEvent->endTimeMs;

		if (gap < bottomOutGap) {
			currentEvent->endTimeMs = allEvents->items[i]->endTimeMs;
			currentEvent->peakAcceleration = (currentEvent->peakAcceleration > allEvents->items[i]->peakAcceleration) ?
				currentEvent->peakAcceleration : allEvents->items[i]->peakAcceleration;
			currentEvent->impulse += allEvents->items[i]->impulse;
			currentEvent->avgAcceleration =
				(currentEvent->avgAcceleration + allEvents->items[i]->avgAcceleration) / 2.0;
		}
		else {
			BottomOutArray_Add(merged, currentEvent);

			currentEvent = SuspensionBottomOuts_Create(
				allEvents->items[i]->completedLaps,
				allEvents->items[i]->peakAcceleration,
				allEvents->items[i]->axle);
			currentEvent->startTimeMs = allEvents->items[i]->startTimeMs;
			currentEvent->endTimeMs = allEvents->items[i]->endTimeMs;
			currentEvent->avgAcceleration = allEvents->items[i]->avgAcceleration;
			currentEvent->impulse = allEvents->items[i]->impulse;
		}
	}

	BottomOutArray_Add(merged, currentEvent);
	BottomOutArray_Destroy(allEvents);

	return merged;
}

BottomOutArray* CreateBottomOuts(
	const char* axle,
	DoublePairArray* leftAccelerations,
	DoublePairArray* rightAccelerations)
{
	BottomOutArray* events;
	int* leftAboveThreshold;
	int* rightAboveThreshold;
	int inEvent;
	size_t eventStartIndex;
	double leftStartDeflection, rightStartDeflection;
	double peakAccelInEvent;
	DoubleArray* accelValuesInEvent;
	long startTime, endTime;
	SuspensionBottomOuts* bottomOutEvent;
	int eventDurationSamples;
	int i;
	double leftMagnitude, rightMagnitude;

	events = BottomOutArray_Create();
	if (!events) return NULL;

	if (leftAccelerations->size == 0)
		return events;

	leftAboveThreshold = (int*)calloc(leftAccelerations->size, sizeof(int));
	rightAboveThreshold = (int*)calloc(rightAccelerations->size, sizeof(int));

	if (!leftAboveThreshold || !rightAboveThreshold) {
		free(leftAboveThreshold);
		free(rightAboveThreshold);
		BottomOutArray_Destroy(events);
		return NULL;
	}

	for (i = 0; i < (int)leftAccelerations->size; i++) {
		leftMagnitude = leftAccelerations->first[i];
		rightMagnitude = rightAccelerations->first[i];

		if (leftMagnitude < 0 && rightMagnitude < 0) {
			leftMagnitude = fabs(leftMagnitude);
			rightMagnitude = fabs(rightMagnitude);

			leftAboveThreshold[i] = (leftMagnitude >= lightBottomOutThreshold);
			rightAboveThreshold[i] = (rightMagnitude >= lightBottomOutThreshold);
		}
	}

	inEvent = 0;
	eventStartIndex = 0;
	leftStartDeflection = 0;
	rightStartDeflection = 0;
	peakAccelInEvent = 0.0;
	accelValuesInEvent = DoubleArray_Create();

	for (i = 0; i < (int)leftAccelerations->size; i++) {
		int condition = leftAboveThreshold[i] || rightAboveThreshold[i] ||
			(inEvent && (fabs(leftAccelerations->second[i] - leftStartDeflection) < releaseThreshold ||
						 fabs(rightAccelerations->second[i] - rightStartDeflection) < releaseThreshold));

		if (condition) {
			if (!inEvent) {
				inEvent = 1;
				eventStartIndex = i;
				leftStartDeflection = leftAccelerations->second[i];
				rightStartDeflection = rightAccelerations->second[i];
				peakAccelInEvent = 0.0;
				DoubleArray_Destroy(accelValuesInEvent);
				accelValuesInEvent = DoubleArray_Create();
			}

			double combinedAccel = (leftAccelerations->first[i] > rightAccelerations->first[i]) ?
				leftAccelerations->first[i] : rightAccelerations->first[i];
			peakAccelInEvent = (peakAccelInEvent > combinedAccel) ? peakAccelInEvent : combinedAccel;
			DoubleArray_Add(accelValuesInEvent, combinedAccel);
		}
		else {
			if (inEvent) {
				if ((int)(i - eventStartIndex) >= samplerMinSamples) {
					startTime = suspensionDeflectionsList->items[eventStartIndex]->timeMS;
					endTime = suspensionDeflectionsList->items[i]->timeMS;

					bottomOutEvent = SuspensionBottomOuts_Create(
						suspensionDeflectionsList->items[eventStartIndex]->completedLaps,
						peakAccelInEvent,
						axle);

					bottomOutEvent->startTimeMs = startTime;
					bottomOutEvent->endTimeMs = endTime;
					bottomOutEvent->avgAcceleration =
						DoubleArray_Sum(accelValuesInEvent) / accelValuesInEvent->size;
					bottomOutEvent->impulse = CalculateImpulse(endTime - startTime, accelValuesInEvent);

					BottomOutArray_Add(events, bottomOutEvent);
				}

				inEvent = 0;
			}
		}
	}

	if (inEvent) {
		eventDurationSamples = (int)(leftAccelerations->size - eventStartIndex);
		if (eventDurationSamples >= samplerMinSamples) {
			startTime = suspensionDeflectionsList->items[eventStartIndex]->timeMS;
			endTime = suspensionDeflectionsList->items[suspensionDeflectionsList->size - 1]->timeMS;

			if (endTime - startTime > bottomOutDuration) {
				bottomOutEvent = SuspensionBottomOuts_Create(
					suspensionDeflectionsList->items[eventStartIndex]->completedLaps,
					peakAccelInEvent,
					axle);

				bottomOutEvent->startTimeMs = startTime;
				bottomOutEvent->endTimeMs = endTime;
				bottomOutEvent->avgAcceleration =
					DoubleArray_Sum(accelValuesInEvent) / accelValuesInEvent->size;
				bottomOutEvent->impulse = CalculateImpulse(endTime - startTime, accelValuesInEvent);

				BottomOutArray_Add(events, bottomOutEvent);
			}
		}
	}

	free(leftAboveThreshold);
	free(rightAboveThreshold);
	DoubleArray_Destroy(accelValuesInEvent);

	BottomOutArray* merged = MergeCloseEvents(events);
	return merged;
}

BottomOutArray* CreateSuspensionIssues()
{
	LongDoublePairArray* frontLeftDeflections;
	LongDoublePairArray* frontRightDeflections;
	LongDoublePairArray* rearLeftDeflections;
	LongDoublePairArray* rearRightDeflections;

	DoublePairArray* frontLeftAccels;
	DoublePairArray* frontRightAccels;
	DoublePairArray* rearLeftAccels;
	DoublePairArray* rearRightAccels;

	BottomOutArray* result;
	BottomOutArray* frontEvents;
	BottomOutArray* rearEvents;

	frontLeftDeflections = ExtractDeflections(GetFrontLeft);
	frontRightDeflections = ExtractDeflections(GetFrontRight);
	rearLeftDeflections = ExtractDeflections(GetRearLeft);
	rearRightDeflections = ExtractDeflections(GetRearRight);

	frontLeftAccels = CalculateAccelerations(frontLeftDeflections);
	frontRightAccels = CalculateAccelerations(frontRightDeflections);
	rearLeftAccels = CalculateAccelerations(rearLeftDeflections);
	rearRightAccels = CalculateAccelerations(rearRightDeflections);

	if (FALSE) {
		char fileName[512];
		FILE* output;

		strcpy_s(fileName, 512, dataFile);
		strcpy_s(fileName + strlen(dataFile), 512 - strlen(dataFile), ".trace");

		/* Debug output to file */
		if (!fopen_s(&output, fileName, "a")) {
			fprintf(output, "----- Deflections -----\n");
			for (int i = 0; i < suspensionDeflectionsList->size; i++) {
				fprintf(output, "%f,%f,%f,%f\n",
						suspensionDeflectionsList->items[i]->frontLeft,
						suspensionDeflectionsList->items[i]->frontRight,
						suspensionDeflectionsList->items[i]->rearLeft,
						suspensionDeflectionsList->items[i]->rearRight);
			}

			fprintf(output, "----- Accelerations -----\n");
			if (frontLeftAccels->size > 0) {
				for (int i = 0; i < frontLeftAccels->size; i++) {
					fprintf(output, "%f,%f,%f,%f\n",
							frontLeftAccels->first[i],
							frontRightAccels->first[i],
							rearLeftAccels->first[i],
							rearRightAccels->first[i]);
				}
			}

			fclose(output);
		}
	}

	Sleep(200);

	result = BottomOutArray_Create();

	frontEvents = CreateBottomOuts("Front", frontLeftAccels, frontRightAccels);
	rearEvents = CreateBottomOuts("Rear", rearLeftAccels, rearRightAccels);

	for (int i = 0; i < frontEvents->size; i++)
		BottomOutArray_Add(result, frontEvents->items[i]);
	for (int i = 0; i < rearEvents->size; i++)
		BottomOutArray_Add(result, rearEvents->items[i]);

	/* Clean up */
	LongDoublePairArray_Destroy(frontLeftDeflections);
	LongDoublePairArray_Destroy(frontRightDeflections);
	LongDoublePairArray_Destroy(rearLeftDeflections);
	LongDoublePairArray_Destroy(rearRightDeflections);

	DoublePairArray_Destroy(frontLeftAccels);
	DoublePairArray_Destroy(frontRightAccels);
	DoublePairArray_Destroy(rearLeftAccels);
	DoublePairArray_Destroy(rearRightAccels);

	/* Note: frontEvents and rearEvents items are now owned by result */
	free(frontEvents->items);
	free(frontEvents);
	free(rearEvents->items);
	free(rearEvents);

	return result;
}

void WriteBottomOuts(
	FILE* output,
	BottomOutArray* suspensionIssues,
	const char* severity)
{
	int count = 0;
	int front = 0;
	int rear = 0;
	int i;

	if (!output || !suspensionIssues) return;

	for (i = 0; i < suspensionIssues->size; i++) {
		if (strcmp(SuspensionBottomOuts_GetSeverity(suspensionIssues->items[i]), severity) == 0) {
			count++;

			if (strcmp(suspensionIssues->items[i]->axle, "Front") == 0)
				front++;
			else if (strcmp(suspensionIssues->items[i]->axle, "Rear") == 0)
				rear++;
		}
	}

	if (count > 0) {
		fprintf(output, "[Suspension.Bottom.Out.%s]\n", severity);

		if (front > 0)
			fprintf(output, "Front=%d\n", front);

		if (rear > 0)
			fprintf(output, "Rear=%d\n", rear);
	}
}

BOOL collectTelemetry(char* soundsDirectory, BOOL calibrate) {
	int playerIdx = getPlayerIndex();

	if (map_buffer->game_paused || (map_buffer->all_drivers_data_1[playerIdx].in_pitlane != 0))
		return TRUE;

	r3e_float32 steerAngle = smoothValue(recentSteerAngles, &recentSteerAnglesCount, map_buffer->steer_input_raw);
	r3e_int32 steerLock = map_buffer->steer_wheel_range_degrees;
	r3e_float32 steerRatio = ((float)steerLock / 2) / map_buffer->steer_lock_degrees;

	r3e_float32 acceleration = map_buffer->car_speed * 3.6f - lastSpeed;

	lastSpeed = map_buffer->car_speed * 3.6f;

	if (lastSpeed > 60)
		DeflectionArray_Add(suspensionDeflectionsList,
			SuspensionDeflections_Create(map_buffer->completed_laps,
										 map_buffer->player.suspension_deflection[R3E_TIRE_FRONT_LEFT] * 1000.0,
										 map_buffer->player.suspension_deflection[R3E_TIRE_FRONT_RIGHT] * 1000.0,
										 map_buffer->player.suspension_deflection[R3E_TIRE_REAR_LEFT] * 1000.0,
										 map_buffer->player.suspension_deflection[R3E_TIRE_REAR_RIGHT] * 1000.0));

	smoothValue(recentGLongs, &recentGLongsCount, acceleration);

	r3e_float64 angularVelocity = smoothValue(recentRealAngVels, &recentRealAngVelsCount,
											  (float)map_buffer->player.local_angular_velocity.y);
	r3e_float64 steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
	r3e_float64 steerAngleRadians = -steeredAngleDegs / 57.2958;
	r3e_float64 wheelBaseMeter = (float)wheelbase / 100;
	r3e_float64 radius = wheelBaseMeter / steerAngleRadians;
	r3e_float64 perimeter = radius * PI * 2;
	r3e_float64 perimeterSpeed = lastSpeed / 3.6;
	r3e_float64 idealAngularVelocity = smoothValue(recentIdealAngVels, &recentIdealAngVelsCount,
												   (float)(perimeterSpeed / perimeter * 2 * PI));

	if (fabs(steerAngle) > 0.2 && lastSpeed > 60) {
		// Get the average recent GLong
		float glongAverage = averageValue(recentGLongs, recentGLongsCount);

		int phase = 0;
		if (recentGLongsCount > 0)
			if (glongAverage < -0.2) {
				// Braking
				phase = -1;
			}
			else if (glongAverage > 0.1) {
				// Accelerating
				phase = 1;
			}

		corner_dynamics cd = { map_buffer->car_speed * 3.6f, 0, map_buffer->completed_laps, phase };

		if (fabs(angularVelocity * 57.2958) > 0.1) {
			r3e_float64 slip = fabs(idealAngularVelocity - angularVelocity);

			if (steerAngle > 0) {
				if (angularVelocity > 0)
				{
					if (calibrate)
						slip *= -1;
					else
						slip = (oversteerHeavyThreshold - 1) / 57.2989;
				}
				else if (angularVelocity < idealAngularVelocity)
					slip *= -1;
			}
			else {
				if (angularVelocity < 0)
				{
					if (calibrate)
						slip *= -1;
					else
						slip = (oversteerHeavyThreshold - 1) / 57.2989;
				}
				else if (angularVelocity > idealAngularVelocity)
					slip *= -1;
			}

			cd.usos = slip * 57.2989 * 1;

			if ((strlen(soundsDirectory) > 0) && (long)GetTickCount() > (lastSound + 300))
				if (triggerUSOSBeep(soundsDirectory, cd.usos))
					lastSound = GetTickCount();

			if (FALSE) {
				char fileName[512];
				FILE* output;

				strcpy_s(fileName, 512, dataFile);
				strcpy_s(fileName + strlen(dataFile), 512 - strlen(dataFile), ".trace");

				if (!fopen_s(&output, fileName, "a")) {
					fprintf(output, "%f  %f  %f  %f  %f  %f  %f  %f\n", steerAngle, steeredAngleDegs, steerAngleRadians, lastSpeed, idealAngularVelocity, angularVelocity, slip, cd.usos);

					fclose(output);

					Sleep(200);
				}
			}
		}

		appendCornerDynamics(&cd);

		if (lastCompletedLaps != map_buffer->completed_laps) {
			lastCompletedLaps = map_buffer->completed_laps;

			clearCornerDynamics(lastCompletedLaps);

			clearSuspensionDeflections(lastCompletedLaps);
		}
	}

	return TRUE;
}

void writeTelemetry(BOOL calibrate) {
	char fileName[512];
	FILE* output;

	strcpy_s(fileName, 512, dataFile);
	strcpy_s(fileName + strlen(dataFile), 512 - strlen(dataFile), ".tmp");

	if (!fopen_s(&output, fileName, "w")) {
		int slowLightUSNum[] = { 0, 0, 0 };
		int slowMediumUSNum[] = { 0, 0, 0 };
		int slowHeavyUSNum[] = { 0, 0, 0 };
		int slowLightOSNum[] = { 0, 0, 0 };
		int slowMediumOSNum[] = { 0, 0, 0 };
		int slowHeavyOSNum[] = { 0, 0, 0 };
		int slowTotalNum = 0;
		int fastLightUSNum[] = { 0, 0, 0 };
		int fastMediumUSNum[] = { 0, 0, 0 };
		int fastHeavyUSNum[] = { 0, 0, 0 };
		int fastLightOSNum[] = { 0, 0, 0 };
		int fastMediumOSNum[] = { 0, 0, 0 };
		int fastHeavyOSNum[] = { 0, 0, 0 };
		int fastTotalNum = 0;

		int slowOSMin[] = { 0, 0, 0 };
		int fastOSMin[] = { 0, 0, 0 };
		int slowUSMax[] = { 0, 0, 0 };
		int fastUSMax[] = { 0, 0, 0 };

		int index = 0;

		for (corner_dynamics* corner = firstCornerDynamics(&index); corner != NULL; corner = nextCornerDynamics(&index)) {
			int phase = corner->phase + 1;

			if (calibrate) {
				if (corner->speed < lowspeedThreshold) {
					slowOSMin[phase] = min(slowOSMin[phase], (int)corner->usos);
					slowUSMax[phase] = max(slowUSMax[phase], (int)corner->usos);
				}
				else {
					fastOSMin[phase] = min(fastOSMin[phase], (int)corner->usos);
					fastUSMax[phase] = max(fastUSMax[phase], (int)corner->usos);
				}
			}
			else {
				if (corner->speed < lowspeedThreshold) {
					slowTotalNum++;
					if (corner->usos < oversteerHeavyThreshold) {
						slowHeavyOSNum[phase]++;
					}
					else if (corner->usos < oversteerMediumThreshold) {
						slowMediumOSNum[phase]++;
					}
					else if (corner->usos < oversteerLightThreshold) {
						slowLightOSNum[phase]++;
					}
					else if (corner->usos > understeerHeavyThreshold) {
						slowHeavyUSNum[phase]++;
					}
					else if (corner->usos > understeerMediumThreshold) {
						slowMediumUSNum[phase]++;
					}
					else if (corner->usos > understeerLightThreshold) {
						slowLightUSNum[phase]++;
					}
				}
				else {
					fastTotalNum++;
					if (corner->usos < oversteerHeavyThreshold) {
						fastHeavyOSNum[phase]++;
					}
					else if (corner->usos < oversteerMediumThreshold) {
						fastMediumOSNum[phase]++;
					}
					else if (corner->usos < oversteerLightThreshold) {
						fastLightOSNum[phase]++;
					}
					else if (corner->usos > understeerHeavyThreshold) {
						fastHeavyUSNum[phase]++;
					}
					else if (corner->usos > understeerMediumThreshold) {
						fastMediumUSNum[phase]++;
					}
					else if (corner->usos > understeerLightThreshold) {
						fastLightUSNum[phase]++;
					}
				}
			}
		}

		if (calibrate) {
			fprintf(output, "[Understeer.Slow]");

			fprintf(output, "Entry=%d", slowUSMax[0]);
			fprintf(output, "Apex=%d", slowUSMax[1]);
			fprintf(output, "Exit=%d", slowUSMax[2]);

			fprintf(output, "[Understeer.Fast]");

			fprintf(output, "Entry=%d", fastUSMax[0]);
			fprintf(output, "Apex=%d", fastUSMax[1]);
			fprintf(output, "Exit=%d", fastUSMax[2]);

			fprintf(output, "[Oversteer.Slow]");

			fprintf(output, "Entry=%d", slowOSMin[0]);
			fprintf(output, "Apex=%d", slowOSMin[1]);
			fprintf(output, "Exit=%d", slowOSMin[2]);

			fprintf(output, "[Oversteer.Fast]");

			fprintf(output, "Entry=%d", fastOSMin[0]);
			fprintf(output, "Apex=%d", fastOSMin[1]);
			fprintf(output, "Exit=%d", fastOSMin[2]);
		}
		else {
			fprintf(output, "[Understeer.Slow.Light]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowLightUSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowLightUSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowLightUSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Understeer.Slow.Medium]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowMediumUSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowMediumUSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowMediumUSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Understeer.Slow.Heavy]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Understeer.Fast.Light]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastLightUSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastLightUSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastLightUSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Understeer.Fast.Medium]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastMediumUSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastMediumUSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastMediumUSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Understeer.Fast.Heavy]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Oversteer.Slow.Light]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowLightOSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowLightOSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowLightOSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Oversteer.Slow.Medium]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowMediumOSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowMediumOSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowMediumOSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Oversteer.Slow.Heavy]\n");

			if (slowTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum));
			}

			fprintf(output, "[Oversteer.Fast.Light]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastLightOSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastLightOSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastLightOSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Oversteer.Fast.Medium]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastMediumOSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastMediumOSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastMediumOSNum[2] / fastTotalNum));
			}

			fprintf(output, "[Oversteer.Fast.Heavy]\n");

			if (fastTotalNum > 0) {
				fprintf(output, "Entry=%d\n", (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum));
				fprintf(output, "Apex=%d\n", (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum));
				fprintf(output, "Exit=%d\n", (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum));
			}

			BottomOutArray* events = CreateSuspensionIssues();

			WriteBottomOuts(output, events, "Light");
			WriteBottomOuts(output, events, "Medium");
			WriteBottomOuts(output, events, "Heavy");
		}

		fclose(output);

		remove(dataFile);

		rename(fileName, dataFile);
	}
}

#define Start 0
#define Intro 1
#define Ready 2
#define Set 3
#define Brake 4
#define Release 5

int tIndices[256];
float xCoordinates[256];
float yCoordinates[256];
int numCoordinates = 0;
time_t nextUpdate = 0;
char* triggerType = "Trigger";

char* hintFile = "";

int hintGroups[256];
int hintPhases[256];
float hintDistances[256];
char hintSounds[256][256];
time_t lastHintsUpdate = 0;
int lastLap = 0;
int lastHint = -1;
int lastGroup = 0;
int lastPhase = Start;

void checkCoordinates(int playerID) {
	if (time(NULL) > nextUpdate) {
		r3e_float64 velocityX = map_buffer->player.velocity.x;
		r3e_float64 velocityY = map_buffer->player.velocity.z;
		r3e_float64 velocityZ = map_buffer->player.velocity.y;

		if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0)) {
			int index = 0;

			for (int id = 0; id < map_buffer->num_cars; id++)
				if (map_buffer->all_drivers_data_1[id].driver_info.user_id == playerID) {
					index = id;

					break;
				}

			r3e_float32 coordinateX = map_buffer->all_drivers_data_1[index].position.x;
			r3e_float32 coordinateY = - map_buffer->all_drivers_data_1[index].position.z;
			
			if (strcmp(triggerType, "Trigger") == 0) {
				for (int i = 0; i < numCoordinates; i += 1) {
					if (fabs(xCoordinates[i] - coordinateX) < 20 && fabs(yCoordinates[i] - coordinateY) < 20) {
						char buffer[512] = "";
						char numBuffer[60];

						strcat_s(buffer, 60, "positionTrigger:");
						_itoa_s(tIndices[i], numBuffer, 60, 10);
						strcat_s(buffer, 60, numBuffer);
						strcat_s(buffer, 60, ";");
						sprintf_s(numBuffer, 60, "%f", xCoordinates[i]);
						strcat_s(buffer, 60, numBuffer);
						strcat_s(buffer, 60, ";");
						sprintf_s(numBuffer, 60, "%f", yCoordinates[i]);
						strcat_s(buffer, 60, numBuffer);

						sendTriggerMessage(buffer);

						nextUpdate = time(NULL) + 2;

						break;
					}
				}
			}
			else {
				if (lastLap != map_buffer->completed_laps) {
					lastLap = map_buffer->completed_laps;

					lastHint = -1;
				}

				int bestHint = -1;
				float bestDistance = 99999;

				for (int i = lastHint + 1; i < numCoordinates; i += 1)
				{
					float curDistance = (float)vectorLength(xCoordinates[i] - coordinateX, yCoordinates[i] - coordinateY);

					if ((curDistance < hintDistances[i]) && (curDistance < bestDistance))
					{
						bestHint = i;
						bestDistance = curDistance;
					}
				}

				if (bestHint > lastHint) {
					int phase = hintPhases[bestHint];
					int group = hintGroups[bestHint];

					if ((lastPhase != Start) || (phase == Intro)) {
						if ((lastGroup != group) && (phase != Intro))
							return;
						else if ((phase <= lastPhase) && (phase != Intro))
							return;

						lastHint = bestHint;
						lastGroup = group;
						lastPhase = phase;

						if (strcmp(audioDevice, "") != 0)
						{
							if (strcmp(player, "") == 0) {
								char buffer[512] = "";
								
								strcat_s(buffer, 512, "acousticFeedback:");
								strcat_s(buffer, 512, hintSounds[bestHint]);

								sendTriggerMessage(buffer);
							}
							else
								playSound(hintSounds[bestHint], FALSE);

							nextUpdate = time(NULL) + 1;
						}
						else {
							PlaySoundA(NULL, NULL, SND_ASYNC);
							PlaySoundA(hintSounds[bestHint], NULL, SND_ASYNC);
						}
					}
				}
			}
		}
	}
}

#ifdef WIN32
#define stat _stat
#endif

void loadTrackHints()
{
	if ((strcmp(hintFile, "") != 0) && fileExists(hintFile))
	{
		struct stat result;
		time_t mod_time = 0;

		if (stat(hintFile, &result) == 0)
			mod_time = result.st_mtime;

		if (numCoordinates == 0 || (mod_time > lastHintsUpdate))
		{
			numCoordinates = 0;
			lastHintsUpdate = mod_time;

			char groupPart[256];
			char phasePart[256];
			char xPart[256];
			char yPart[256];
			char distancePart[256];
			char hintPart[256];

			char* parts[6] = { groupPart, phasePart, xPart, yPart, distancePart, hintPart };

			FILE* file = fopen(hintFile, "r");

			char line[512];

			if (file != NULL) {
				while (fgets(line, sizeof(line), file)) {
					splitString(line, " ", 6, parts);

					hintGroups[numCoordinates] = atoi(parts[0]);
					if (strcmp(parts[1], "Intro") == 0 || strcmp(parts[1], "intro") == 0)
						hintPhases[numCoordinates] = Intro;
					else if (strcmp(parts[1], "Ready") == 0 || strcmp(parts[1], "ready") == 0)
						hintPhases[numCoordinates] = Ready;
					else if (strcmp(parts[1], "Set") == 0 || strcmp(parts[1], "set") == 0)
						hintPhases[numCoordinates] = Set;
					else if (strcmp(parts[1], "Brake") == 0 || strcmp(parts[1], "brake") == 0)
						hintPhases[numCoordinates] = Brake;
					else if (strcmp(parts[1], "Release") == 0 || strcmp(parts[1], "release") == 0)
						hintPhases[numCoordinates] = Release;
					xCoordinates[numCoordinates] = (float)atof(parts[2]);
					yCoordinates[numCoordinates] = (float)atof(parts[3]);
					hintDistances[numCoordinates] = (float)atof(parts[4]);
					
					strcpy_s((char *)hintSounds[numCoordinates], 256, parts[5]);

					if (++numCoordinates > 255)
						break;
				}

				lastHint = -1;
				lastGroup = 0;
				lastPhase = Start;

				fclose(file);
			}
		}
	}
}

int main(int argc, char* argv[])
{
    BOOL mapped_r3e = FALSE;
	int playerID = 0;
	BOOL handlingCalibrator = FALSE;
	BOOL handlingAnalyzer = FALSE;
	BOOL positionTrigger = FALSE;
	BOOL trackHints = FALSE;
	char* soundsDirectory = "";

	if (argc > 1) {
		positionTrigger = (strcmp(argv[1], "-Trigger") == 0);

		if (positionTrigger) {
			triggerType = "Trigger";

			for (int i = 2; i < (argc - 1); i = i + 3) {
				tIndices[numCoordinates] = atoi(argv[i]);
				xCoordinates[numCoordinates] = (float)atof(argv[i + 1]);
				yCoordinates[numCoordinates] = (float)atof(argv[i + 2]);

				if (++numCoordinates > 255)
					break;
			}
		}

		trackHints = (strcmp(argv[1], "-TrackHints") == 0);

		if (trackHints) {
			triggerType = "TrackHints";

			hintFile = argv[2];

			if (argc > 3)
				audioDevice = argv[3];

			if (argc > 4)
				volume = (float)atof(argv[4]);

			if (argc > 5)
				player = argv[5];

			if (argc > 6)
				workingDirectory = argv[6];
		}

		handlingCalibrator = (strcmp(argv[1], "-Calibrate") == 0);
		handlingAnalyzer = handlingCalibrator || (strcmp(argv[1], "-Analyze") == 0);

		if (handlingAnalyzer) {
			suspensionDeflectionsList = DeflectionArray_Create();

			strcpy_s(dataFile, 512, argv[2]);

			if (handlingCalibrator) {
				lowspeedThreshold = atoi(argv[3]);
				wheelbase = atoi(argv[4]);
				trackWidth = atoi(argv[5]);
			}
			else {
				understeerLightThreshold = atoi(argv[3]);
				understeerMediumThreshold = atoi(argv[4]);
				understeerHeavyThreshold = atoi(argv[5]);
				oversteerLightThreshold = atoi(argv[6]);
				oversteerMediumThreshold = atoi(argv[7]);
				oversteerHeavyThreshold = atoi(argv[8]);
				lowspeedThreshold = atoi(argv[9]);
				wheelbase = atoi(argv[10]);
				trackWidth = atoi(argv[11]);

				lightBottomOutThreshold = atoi(argv[12]);
				mediumBottomOutThreshold = atoi(argv[13]);
				heavyBottomOutThreshold = atoi(argv[14]);
				releaseThreshold = (float)atof(argv[15]);
				bottomOutDuration = atoi(argv[16]);
				bottomOutGap = atoi(argv[17]);
				samplerMinSamples = atoi(argv[18]);
				deflectionMovingAverage = atoi(argv[19]);
				accelerationMovingAverage = atoi(argv[20]);

				if (argc > 21) {
					soundsDirectory = argv[21];

					if (argc > 22)
						audioDevice = argv[22];

					if (argc > 23)
						volume = (float)atof(argv[23]);

					if (argc > 24)
						player = argv[24];

					if (argc > 25)
						workingDirectory = argv[25];
				}
			}
		}
	}

	long counter = 0;

	while (TRUE) {
		counter += 1;

		if (!mapped_r3e && map_exists())
			if (!map_init())
				mapped_r3e = TRUE;

		if (mapped_r3e) {
			playerID = getPlayerID();

			if (playerID == -1)
				continue;

			if (handlingAnalyzer) {
				if (collectTelemetry(soundsDirectory, handlingCalibrator)) {
					if (remainder(counter, 200) == 0)
						writeTelemetry(handlingCalibrator);

					Sleep(10);
				}
				else
					break;
			}
			else if (positionTrigger) {
				checkCoordinates(playerID);

				Sleep(10);
			}
			else if (trackHints) {
				loadTrackHints();

				checkCoordinates(playerID);

				Sleep(10);
			}
		}
		else
			Sleep(1000);
    }

    map_close();

    return 0;
}