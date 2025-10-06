;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Audio Functions                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "MultiMap.ahk"
#Include "Extensions\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global gAudioConfiguration := false
global gAudioConfigurationModTime := false
global gAudioConfigurationModeSimulator := false
global gAudioConfigurationModeSession := false


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getAudioSetting(name, type, property := "AudioDevice", default := false) {
	global gAudioConfiguration, gAudioConfigurationModeSimulator, gAudioConfigurationModeSession, gAudioConfigurationModTime

	local value := kUndefined
	local key

	static settings := CaseInsenseMap()
	static lastModTime := false

	if (lastModTime != gAudioConfigurationModTime)
		settings := CaseInsenseMap()

	if requireAudioConfiguration() {
		key := ((gAudioConfigurationModeSimulator ? (type . "." . gAudioConfigurationModeSimulator
														  . "." . gAudioConfigurationModeSession)
												  : type) . name . "." . property)

		if settings.Has(key)
			return settings[key]
		else {
			if gAudioConfigurationModeSimulator {
				value := getMultiMapValue(gAudioConfiguration, type . "." . gAudioConfigurationModeSimulator
																	. "." . gAudioConfigurationModeSession
															 , name . "." . property, kUndefined)

				if (value == kUndefined)
					value := getMultiMapValue(gAudioConfiguration, type . "." . gAudioConfigurationModeSimulator . ".*"
																 , name . "." . property, kUndefined)

				if (value == kUndefined)
					value := getMultiMapValue(gAudioConfiguration, type . ".*." . gAudioConfigurationModeSession
																 , name . "." . property, kUndefined)

				if (value == kUndefined)
					value := getMultiMapValue(gAudioConfiguration, type . "*.*", name . "." . property, kUndefined)
			}

			if (value == kUndefined)
				value := getMultiMapValue(gAudioConfiguration, type, name . "." . property, default)

			settings[key] := value

			return value
		}
	}
	else
		return default
}

setAudioMode(simulator, session := false) {
	global gAudioConfiguration

	if requireAudioConfiguration() {
		if simulator {
			setMultiMapValue(gAudioConfiguration, "General", "Simulator", simulator)
			setMultiMapValue(gAudioConfiguration, "General", "Session", session ? session : "Default")
		}
		else {
			setMultiMapValue(gAudioConfiguration, "General", "Simulator", false)
			setMultiMapValue(gAudioConfiguration, "General", "Session", false)
		}

		writeMultiMap(kUserConfigDirectory . "Audio Settings.ini", gAudioConfiguration)
	}
}

requireSoundPlayer(player) {
	local path

	if (kSox && FileExist(kSox)) {
		path := (kProgramsDirectory . player)

		if FileExist(path)
			return path
		else
			loop
				try {
					DirCreate(normalizeDirectoryPath(kProgramsDirectory))

					FileCopy(kSox, path, true)

					return path
				}
				catch Any as exception {
					logError(exception)

					Sleep(100)
				}
	}

	return false
}

playSound(player, wavFile, options := false) {
	local workingDirectory, pid

	if (player = "System")
		player := false
	else
		player := requireSoundPlayer(player)

	if player {
		SplitPath(kSox, , &workingDirectory)

		if !options
			options := ""

		try {
			Run("`"" . player . "`" `"" . wavFile . "`" -t waveaudio " . options, workingDirectory, "HIDE", &pid)
		}
		catch Any as exception {
			logError(exception)

			pid := false
		}

		return pid
	}
	else {
		if (options = "Wait")
			SoundPlay(wavFile, "Wait")
		else
			SoundPlay(wavFile)

		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

requireAudioConfiguration() {
	global gAudioConfiguration, gAudioConfigurationModTime, gAudioConfigurationModeSimulator, gAudioConfigurationModeSession

	local fileName := (kUserConfigDirectory . "Audio Settings.ini")

	if (!gAudioConfiguration && FileExist(fileName)) {
		gAudioConfiguration := readMultiMap(fileName)
		gAudioConfigurationModTime := FileGetTime(fileName, "M")
		gAudioConfigurationModeSimulator := getMultiMapValue(gAudioConfiguration, "General", "Simulator", false)
		gAudioConfigurationModeSession := getMultiMapValue(gAudioConfiguration, "General", "Session", false)
	}

	return gAudioConfiguration
}

initializeAudioConfiguration() {
	PeriodicTask(() {
		global gAudioConfiguration, gAudioConfigurationModTime

		if (gAudioConfigurationModTime && (FileGetTime(kUserConfigDirectory . "Audio Settings.ini", "M") > gAudioConfigurationModTime)) {
			gAudioConfiguration := false
			gAudioConfigurationModTime := false
		}
	}, 2000, kLowPriority).start()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeAudioConfiguration()