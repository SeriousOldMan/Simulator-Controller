﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Debug Functions                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gDebug := false
global gLogLevel := kLogWarn
global gDiagnosticsCritical := true


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global SupportMenu := Menu()
global LogMenu := Menu()


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Files.ahk"
#Include "Strings.ahk"
#Include "Localization.ahk"
#Include "TrayMenu.ahk"
#Include "Message.ahk"
#Include "MultiMap.ahk"
#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Framework\Extensions\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

/* Must be defined in Constants.ahk due to circular loading problems...
global kLogDebug := 1
global kLogInfo := 2
global kLogWarn := 3
global kLogCritical := 4
global kLogOff := 5

global kLogLevels := {Off: kLogOff, Debug: kLogDebug, Info: kLogInfo, Warn: kLogWarn, Critical: kLogCritical}
global kLogLevelNames := ["Debug", "Info", "Warn", "Critical", "Off"]
*/

global kLogStartup := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
									 , "Debug", "LogStartup", false)


;;;-------------------------------------------------------------------------;;;
;;;                    Private Variables Declaration Section                ;;;
;;;-------------------------------------------------------------------------;;;

global gHighMemoryUsage := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

reportHighMemoryUsage(threshold) {
	global gHighMemoryUsage

	local used := getMemoryUsage(ProcessExist())

	if (used > threshold) {
		gHighMemoryUsage := true

		try {
			throw Error(translate("High memory warning: ") . Round((used / (1024 * 1024)), 1) . translate(" MB"))
		}
		catch Any as exception {
			logMessage(kLogCritical, exception.Message)

			if exception.HasProp("Stack")
				logMessage(kLogCritical, "Stack:`n`n" . exception.Stack, false)
		}
	}
}

reportNonObjectUsage(reference, p1 := "", p2 := "", p3 := "", p4 := "") {
	if isDebug() {
		showMessage(StrSplit(A_ScriptName, ".")[1] . ": The literal value " . String(reference) . " was used as an object: "
												   . String(p1) . "; " . String(p2) . "; " . String(p3) . "; " . String(p4)
				  , false, kUndefined, 5000)

		if isDevelopment()
			ListLines()
	}

	return false
}

initializeDebugging() {
	global gDebug, gLogLevel, gDiagnosticsCritical

	local settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
	local criticalMemory := ((getMultiMapValue(settings, "Process", "Memory.Max", 1024) / 100)
						   * getMultiMapValue(settings, "Process", "Memory.Critical", 80) * 1024 * 1024)

	gDebug := getMultiMapValue(settings, "Debug", "Debug", (kBuildConfiguration = "Development") && !A_IsCompiled)
	gLogLevel := kLogLevels[getMultiMapValue(settings, "Debug", "LogLevel", ((kBuildConfiguration = "Development") && !A_IsCompiled) ? "Debug" : "Warn")]
	gDiagnosticsCritical := getMultiMapValue(settings, "Diagnostics", "Critical", true)

	if kLogStartup {
		logMessage(kLogOff, "-----------------------------------------------------------------")
		logMessage(kLogOff, translate("      Starting ") . StrSplit(A_ScriptName, ".")[1] . " [" . ProcessExist() . "]")
		logMessage(kLogOff, "-----------------------------------------------------------------")
	}

	String.__Call := reportNonObjectUsage
	String.__Get := reportNonObjectUsage
	String.__Set := reportNonObjectUsage
	Number.__Get := reportNonObjectUsage
	Number.__Call := reportNonObjectUsage
	Number.__Set := reportNonObjectUsage

	OnError(logUnhandledError)

	PeriodicTask(reportHighMemoryUsage.Bind(criticalMemory), 1000, kInterruptPriority).start()

	if kLogStartup
		logMessage(kLogOff, "Debugger initialized...")
}

logUnhandledError(error, *) {
	return logError(error, true)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

isDebug() {
	global gDebug

	return gDebug
}

isLogLevel(logLevel) {
	return (logLevel >= gLogLevel)
}

isDevelopment() {
	global kBuildConfiguration

	return (kBuildConfiguration = "Development")
}

isCritical() {
	global gHighMemoryUsage

	return gHighMemoryUsage
}

getLogLevel() {
	global gLogLevel

	return gLogLevel
}

logMessage(logLevel, message, monitor := true, error := false, header := true) {
	global gLogLevel

	local script := StrSplit(A_ScriptName, ".")[1]
	local time := A_Now
	local level, fileName, directory, tries, logTime, logLine, pid

	static sending := false

	if isLogLevel(logLevel) {
		level := ""

		switch logLevel {
			case kLogDebug:
				level := "Debug   "
			case kLogInfo:
				level := "Info    "
			case kLogWarn:
				level := "Warn    "
			case kLogCritical:
				level := "Critical"
			case kLogOff:
				level := "Off     "
			default:
				throw "Unknown log level (" . logLevel . ") encountered in logMessage..."
		}

		logTime := FormatTime(time, "dd.MM.yy HH:mm:ss")

		fileName := kLogsDirectory . script . ".log"
		logLine := "[" level . " - " . logTime . "]: " . message . "`n"

		DirCreate(kLogsDirectory)

		tries := 5

		while (tries > 0)
			try {
				FileAppend(logLine, fileName, "UTF-16")

				break
			}
			catch Any as exception {
				Sleep(1)

				tries -= 1
			}

		if (monitor && !sending && (script != "System Monitor")) {
			pid := ProcessExist("System Monitor.exe")

			if pid {
				sending := true

				message := StrReplace(StrReplace(StrReplace(StrReplace(message, "`n", A_Space), "`r", A_Space), "`t", A_Space), ";", A_Space)

				try {
					messageSend(kFileMessage, "Monitoring", "logMessage:" . values2String(";", script, time, logLevel, StrReplace(message, ";", ","))
											, pid)
				}
				finally {
					sending := false
				}
			}
		}

		if (gDiagnosticsCritical && (error || (logLevel = kLogCritical))) {
			DirCreate(kUserHomeDirectory . "Diagnostics")

			tries := 5

			while (tries > 0)
				try {
					if header
						logLine := ("---------------------------------------------------------------------`n"
								  . "      Error in " . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ")`n"
								  . "---------------------------------------------------------------------`n"
								  . logLine)

					FileAppend(logLine, kUserHomeDirectory . "Diagnostics\Critical.log", "UTF-16")

					break
				}
				catch Any as exception {
					Sleep(1)

					tries -= 1
				}
		}
	}
}

logError(exception, unexpected := false, report := true) {
	local debug := (isDevelopment() && isDebug())
	local critical := (unexpected || isDevelopment())
	local handle, message, settings

	static verbose := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Debug", "Verbose", debug && !A_IsCompiled)

	if isObject(exception) {
		message := exception.Message

		logMessage(critical ? kLogCritical : kLogDebug
				 , translate(unexpected ? "Unexpected exception encountered in " : "Handled exception encountered in ")
				 . exception.File . translate(" at line ") . exception.Line . translate(": ") . message
				 , true, unexpected)


		if exception.HasProp("Stack")
			logMessage(critical ? kLogCritical : kLogDebug, "`n`nStack:`n`n" . exception.Stack
					 , false, unexpected, false)
	}
	else
		logMessage(critical ? kLogCritical : kLogDebug
				 , translate(unexpected ? "Unexpected exception encountered: " : "Handled exception encountered: ") . exception
				 , true, unexpected)

	if (verbose && (unexpected || report))
		if isObject(exception)
			withBlockedWindows(MsgBox, translate(unexpected ? "Unexpected exception encountered in " : "Handled exception encountered in ")
									 . exception.File . translate(" at line ") . exception.Line . translate(": ") . exception.Message
									 . (exception.HasProp("Stack") ? ("`n`nStack:`n`n" . exception.Stack) : ""))
		else
			withBlockedWindows(MsgBox, translate(unexpected ? "Unexpected exception encountered: " : "Handled exception encountered: ") . exception)

	if debug
		return (A_IsCompiled ? -1 : false)
	else
		return -1
}

getMemoryUsage(pid) {
	local size := (8 + A_PtrSize * 9)
	local PMC_EX := Buffer(size, 0)
	local hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", pid)
	local success := false

	if hProcess {
		NumPut("uint", size, PMC_EX)

		try
			if DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", PMC_EX, "uint", size)
				success := true

		if !success
			try
				if DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", PMC_EX, "uint", size)
					success := true

		DllCall("CloseHandle", "ptr", hProcess)

		return (success ? NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") : false)
	}

	return false
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

toggleDebug(*) {
	setDebug(!isDebug())
}

setDebug(debug, *) {
	global gDebug
	local title, state

	if hasTrayMenu()
		if debug
			SupportMenu.Check(translate("Debug"))
		else
			SupportMenu.Uncheck(translate("Debug"))

	if (gDebug || debug) {
		title := translate("Modular Simulator Controller System")
		state := (debug ? translate("Enabled") : translate("Disabled"))

		TrayTip(title, "Debug: " . state)
	}

	gDebug := debug
}

setLogLevel(level, *) {
	global gLogLevel

	local ignore, title, state

	if hasTrayMenu()
		for ignore, label in ["Debug", "Off", "Info", "Warn", "Critical"]
			LogMenu.Uncheck(translate(label))

	switch level, false {
		case "Debug":
			level := kLogDebug
		case "Info":
			level := kLogInfo
		case "Warn":
			level := kLogWarn
		case "Critical":
			level := kLogCritical
		case "Off":
			level := kLogOff
		default:
			if !isInteger(level)
				level := kLogWarn
	}

	level := Min(kLogOff, Max(level, kLogDebug))

	state := translate("Unknown")

	switch level {
		case kLogDebug:
			state := translate("Debug")
		case kLogInfo:
			state := translate("Info")
		case kLogWarn:
			state := translate("Warn")
		case kLogCritical:
			state := translate("Critical")
		case kLogOff:
			state := translate("Off")
	}

	if (gLogLevel != level) {
		gLogLevel := level

		title := translate("Modular Simulator Controller System")

		TrayTip(title, translate("Log Level: ") . state)
	}

	if hasTrayMenu()
		LogMenu.Check(state)
}

increaseLogLevel(*) {
	setLogLevel(getLogLevel() - 1)
}

decreaseLogLevel(*) {
	setLogLevel(getLogLevel() + 1)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeDebugging()