;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Debug Functions                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vDebug := false
global vLogLevel := kLogWarn


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global SupportMenu := Menu()
global LogMenu := Menu()


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Constants.ahk"
#Include "..\Framework\Variables.ahk"
#Include "..\Framework\Files.ahk"
#Include "..\Framework\Strings.ahk"
#Include "..\Framework\Localization.ahk"
#Include "..\Framework\TrayMenu.ahk"
#Include "..\Framework\Message.ahk"
#Include "..\Libraries\Messages.ahk"


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


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

reportNonObjectUsage(reference, p1 := "", p2 := "", p3 := "", p4 := "") {
	if isDebug() {
		showMessage(StrSplit(A_ScriptName, ".")[1] . ": The literal value " . reference . " was used as an object: " . p1 . "; " . p2 . "; " . p3 . "; " . p4
				  , false, kUndefined, 5000)

		if isDevelopment()
			ListLines()
	}

	return false
}

initializeDebugging() {
	; "".base.__Get := "".base.__Set := "".base.__Call := reportNonObjectUsage

	; OnError(logUnhandledError)
}

logUnhandledError(error, *) {
	logError(error, true)

	return -1
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

isDebug() {
	global vDebug

	return vDebug
}

isDevelopment() {
	global kBuildConfiguration

	return (kBuildConfiguration = "Development")
}

getLogLevel() {
	global vLogLevel

	return vLogLevel
}

logMessage(logLevel, message) {
	global vLogLevel

	local script := StrSplit(A_ScriptName, ".")[1]
	local time := A_Now
	local level, fileName, directory, tries, logTime, logLine, pid

	static sending := false

	if (logLevel >= vLogLevel) {
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

		logTime := FormatTime(time, "dd.MM.yy hh:mm:ss tt")

		fileName := kLogsDirectory . script . " Logs.txt"
		logLine := "[" level . " - " . logTime . "]: " . message . "`n"

		SplitPath(fileName, , &directory)
		DirCreate(directory)

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

		if (!sending && (script != "System Monitor")) {
			pid := ProcessExist("System Monitor.exe")

			if pid {
				sending := true

				try {
					messageSend(kFileMessage, "Monitoring", "logMessage:" . values2String(";", script, time, logLevel, message), pid)
				}
				finally {
					sending := false
				}
			}
		}
	}
}

logError(exception, unhandled := false, report := true) {
	local message

	if IsObject(exception) {
		message := exception.Message

		if !isNumber(message)
			logMessage(unhandled ? kLogCritical : kLogDebug
					 , translate(unhandled ? "Unhandled exception encountered in " : "Handled exception encountered in ")
					 . exception.File . translate(" at line ") . exception.Line . translate(": ") . message)
	}
	else if !isNumber(exception)
		logMessage(unhandled ? kLogCritical : kLogDebug
				 , translate(unhandled ? "Unhandled exception encountered: " : "Handled exception encountered: ") . exception)

	if (report && !unhandled && isDevelopment() && isDebug())
		if IsObject(exception)
			MsgBox(translate("Handled exception encountered in ") . exception.File . translate(" at line ") . exception.Line . translate(": ") . exception.Message)
		else
			MsgBox(translate("Handled exception encountered: ") . exception)

	return ((isDevelopment() || isDebug()) ? false : true)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

toggleDebug(*) {
	setDebug(!isDebug())
}

setDebug(debug, *) {
	global vDebug
	local title, state

	if hasTrayMenu()
		if debug
			SupportMenu.Check(translate("Debug"))
		else
			SupportMenu.Uncheck(translate("Debug"))

	if (vDebug || debug) {
		title := translate("Modular Simulator Controller System")
		state := (debug ? translate("Enabled") : translate("Disabled"))

		TrayTip(title, "Debug: " . state)
	}

	vDebug := debug
}

setLogLevel(level, *) {
	global vLogLevel

	local ignore, title, state

	if hasTrayMenu()
		for ignore, label in ["Off", "Info", "Warn", "Critical"]
			LogMenu.Uncheck(translate(label))

	switch level {
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

	if (vLogLevel != level) {
		vLogLevel := level

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