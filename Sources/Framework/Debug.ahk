;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Debug Functions                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vDebug := false
global vLogLevel := kLogWarn


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Files.ahk
#Include ..\Framework\Localization.ahk
#Include ..\Framework\TrayMenu.ahk
#Include ..\Framework\Message.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

reportNonObjectUsage(reference, p1 = "", p2 = "", p3 = "", p4 = "") {
	if isDebug() {
		showMessage(StrSplit(A_ScriptName, ".")[1] . ": The literal value " . reference . " was used as an object: " . p1 . "; " . p2 . "; " . p3 . "; " . p4
				  , false, kUndefined, 5000)

		ListLines
	}

	return false
}

initializeDebugging() {
	"".base.__Get := "".base.__Set := "".base.__Call := Func("reportNonObjectUsage")

	OnError(Func("logError").Bind(true))
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

isDebug() {
	return vDebug
}

isDevelopment() {
	return (vBuildConfiguration = "Development")
}

getLogLevel() {
	return vLogLevel
}

logMessage(logLevel, message) {
	local script := StrSplit(A_ScriptName, ".")[1]
	local time := A_Now
	local level, fileName, directory, tries, logTime, logLine

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

		FormatTime, logTime, %time%, dd.MM.yy hh:mm:ss tt

		fileName := kLogsDirectory . script . " Logs.txt"
		logLine := "[" level . " - " . logTime . "]: " . message . "`n"

		SplitPath fileName, , directory
		FileCreateDir %directory%

		tries := 5

		while (tries > 0)
			try {
				FileAppend %logLine%, %fileName%, UTF-16

				break
			}
			catch exception {
				Sleep 1

				tries -= 1
			}

		if (!sending && (script != "System Monitor")) {
			Process Exist, System Monitor.exe

			if ErrorLevel {
				sending := true

				try {
					sendMessage(kFileMessage, "Monitoring", "logMessage:" . values2String(";", script, time, logLevel, message), ErrorLevel)
				}
				finally {
					sending := false
				}
			}
		}
	}
}

logError(exception, unhandled := false) {
	local message

	if IsObject(exception) {
		message := exception.Message

		if message is not Number
			logMessage(unhandled ? kLogCritical : kLogDebug
					 , translate(unhandled ? "Unhandled exception encountered in " : "Handled exception encountered in ")
					 . exception.File . translate(" at line ") . exception.Line . translate(": ") . message)
	}
	else if exception is not Number
		logMessage(unhandled ? kLogCritical : kLogDebug
				 , translate(unhandled ? "Unhandled exception encountered: " : "Handled exception encountered: ") . exception)

	return ((isDevelopment() || isDebug()) ? false : true)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

toggleDebug() {
	setDebug(!isDebug())
}

setDebug(debug) {
	local label := translate("Debug")
	local title, state

	if hasTrayMenu()
		if debug
			Menu SupportMenu, Check, %label%
		else
			Menu SupportMenu, Uncheck, %label%

	vDebug := debug

	title := translate("Modular Simulator Controller System")
	state := (debug ? translate("Enabled") : translate("Disabled"))

	TrayTip %title%, Debug: %state%
}

setLogLevel(level) {
	local ignore, label, title, state

	if hasTrayMenu()
		for ignore, label in ["Off", "Info", "Warn", "Critical"] {
			label := translate(label)

			Menu LogMenu, Uncheck, %label%
		}

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
	}

	vLogLevel := Min(kLogOff, Max(level, kLogDebug))

	state := translate("Unknown")

	switch vLogLevel {
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

	if hasTrayMenu()
		Menu LogMenu, Check, %state%

	title := translate("Modular Simulator Controller System")

	TrayTip %title%, % translate("Log Level: ") . state
}

increaseLogLevel() {
	setLogLevel(getLogLevel() - 1)
}

decreaseLogLevel() {
	setLogLevel(getLogLevel() + 1)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeDebugging()