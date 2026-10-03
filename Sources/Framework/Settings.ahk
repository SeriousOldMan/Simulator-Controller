;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Application Settings            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Collections.ahk"
#Include "MultiMap.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Extensions\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Global Variables Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gSettings := newMultiMap()
global gChangedSettings := newMultiMap()
global gRemovedSettings := newMultiMap()
global gSettingsUpdate := false


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getSetting(topic := StrSplit(A_ScriptName, ".")[1], setting, default := false) {
	local value

	static unsetSetting := {}

	if !getMultiMapValue(gRemovedSettings, topic, setting, false) {
		requireSettings()

		value := getMultiMapValue(gChangedSettings, topic, setting, unsetSetting)

		if (value != unsetSetting)
			return value

		value := getMultiMapValue(gSettings, topic, setting, unsetSetting)

		if (value != unsetSetting)
			return value
	}

	return default
}

setSetting(topic := StrSplit(A_ScriptName, ".")[1], setting, value, flush := false) {
	setMultiMapValue(gChangedSettings, topic, setting, value)
	removeMultiMapValue(gRemovedSettings, topic, setting)

	if flush
		flushSettings()
}

removeSetting(topic := StrSplit(A_ScriptName, ".")[1], setting, flush := false) {
	setMultiMapValue(gRemovedSettings, topic, setting, true)

	if flush
		flushSettings()
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

lockSettings() {
	local file

	loop
		try {
			return FileOpen(kUserConfigDirectory . "Application Settings.ini", "rw-rw", "UTF-16")
		}
		catch Any as exception {
			logError(exception)

			Sleep(100)
		}
}

unlockSettings(file) {
	file.Close()
}

requireSettings(file := false) {
	global gSettings, gSettingsUpdate

	local fileTime

	if FileExist(kUserConfigDirectory . "Application Settings.ini") {
		if !file {
			file := lockSettings()

			try {
				requireSettings(file)
			}
			finally {
				unlockSettings(file)
			}
		}
		else {
			fileTime := FileGetTime(kUserConfigDirectory . "Application Settings.ini", "M")

			if (fileTime != gSettingsUpdate) {
				gSettings := parseMultiMap(file.Read())

				gSettingsUpdate := fileTime
			}
		}
	}
	else
		gSettings := newMultiMap()
}

flushSettings() {
	global gChangedSettings, gRemovedSettings

	local file, topic, settings, ignore, setting

	if (gChangedSettings.Count > 0) {
		file := lockSettings()

		try {
			requireSettings(file)

			addMultiMapValues(gSettings, gChangedSettings)

			for topic, settings in gRemovedSettings
				for setting, ignore in settings
					removeMultiMapValue(gSettings, topic, setting)

			file.Write(printMultiMap(gSettings))

			gChangedSettings := newMultiMap()
			gRemovedSettings := newMultiMap()
		}
		finally {
			unlockSettings(file)
		}
	}

	return false
}

initializeSettings() {
	PeriodicTask(flushSettings, 10000, kLowPriority).start()

	OnExit((*) => flushSettings())
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSettings()