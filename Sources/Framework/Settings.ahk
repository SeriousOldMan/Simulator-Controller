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
global gPendingChangedSettings := newMultiMap()
global gRemovedSettings := newMultiMap()
global gPendingRemovedSettings := newMultiMap()
global gSettingsUpdate := false
global gSettingsFlushing := false


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getSetting(topic, setting, default := false) {
	local value

	static unsetSetting := {}

	if getMultiMapValue(gRemovedSettings, topic, setting, false)
		return default

	if (gSettingsFlushing && getMultiMapValue(gPendingRemovedSettings, topic, setting, false))
		return default

	requireSettings()

	if gSettingsFlushing {
		value := getMultiMapValue(gPendingChangedSettings, topic, setting, unsetSetting)

		if (value != unsetSetting)
			return value
	}

	value := getMultiMapValue(gChangedSettings, topic, setting, unsetSetting)

	if (value != unsetSetting)
		return value

	value := getMultiMapValue(gSettings, topic, setting, unsetSetting)

	if (value != unsetSetting)
		return value

	return default
}

setSetting(topic, setting, value, flush := false) {
	if gSettingsFlushing {
		setMultiMapValue(gPendingChangedSettings, topic, setting, value)
		removeMultiMapValue(gPendingRemovedSettings, topic, setting)
	}
	else {
		setMultiMapValue(gChangedSettings, topic, setting, value)
		removeMultiMapValue(gRemovedSettings, topic, setting)
	}

	if flush
		flushSettings()
}

removeSetting(topic := StrSplit(A_ScriptName, ".")[1], setting, flush := false) {
	if gSettingsFlushing {
		setMultiMapValue(gPendingRemovedSettings, topic, setting, true)
		removeMultiMapValue(gPendingChangedSettings, topic, setting)
	}
	else {
		setMultiMapValue(gRemovedSettings, topic, setting, true)
		removeMultiMapValue(gChangedSettings, topic, setting)
	}

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
			file := FileOpen(kUserConfigDirectory . "Application Settings.ini", "rw-rw", "UTF-16")

			file.Pos := 0

			return file
		}
		catch Any as exception {
			logError(exception)

			if gSettingsFlushing
				return false
			else
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

			if file
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
	global gChangedSettings, gPendingChangedSettings, gRemovedSettings, gPendingRemovedSettings
	global gSettingsFlushing

	local oldFlushingSettings, file, topic, settings, ignore, setting

	if ((gChangedSettings.Count > 0) && !(oldFlushingSettings := gSettingsFlushing)) {
		file := lockSettings()

		if file
			try {
				gSettingsFlushing := true

				requireSettings(file)

				addMultiMapValues(gSettings, gChangedSettings)

				for topic, settings in gRemovedSettings
					for setting, ignore in settings
						removeMultiMapValue(gSettings, topic, setting)

				file.Length := 0
				file.Write(printMultiMap(gSettings))

				gChangedSettings := gPendingChangedSettings
				gRemovedSettings := gPendingRemovedSettings
				gPendingChangedSettings := newMultiMap()
				gPendingRemovedSettings := newMultiMap()
			}
			finally {
				unlockSettings(file)

				gSettingsFlushing := oldFlushingSettings
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