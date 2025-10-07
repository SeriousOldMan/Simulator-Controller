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

global gAudioConfigurationMode := false
global gAudioConfigurationModeModTime := false


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getAudioSetting(name, type := "Output", property := "AudioDevice", default := false) {
	global gAudioConfiguration, gAudioConfigurationModTime, gAudioConfigurationMode

	local simulator, session, key, value

	static settings := false
	static lastModTime := false

	if requireAudioConfiguration() {
		if (!settings || (lastModTime != gAudioConfigurationModTime))
			settings := CaseInsenseMap()

		simulator := (gAudioConfigurationMode ? gAudioConfigurationMode[1] : false)
		session := (gAudioConfigurationMode ? gAudioConfigurationMode[2] : false)
		key := ((simulator ? (type . "." . simulator . "." . session) : type) . name . "." . property)

		if settings.Has(key)
			return settings[key]
		else {
			if simulator {
				value := getMultiMapValue(gAudioConfiguration, type . "." . simulator . "." . session
															 , name . "." . property, kUndefined)

				if (value == kUndefined)
					value := getMultiMapValue(gAudioConfiguration, type . "." . simulator . ".*"
																 , name . "." . property, kUndefined)

				if (value == kUndefined)
					value := getMultiMapValue(gAudioConfiguration, type . ".*." . session
																 , name . "." . property, kUndefined)

				if (value == kUndefined)
					value := getMultiMapValue(gAudioConfiguration, type . "*.*", name . "." . property, kUndefined)
			}
			else
				value := kUndefined

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
	global gAudioConfigurationMode

	local curSimulator := (gAudioConfigurationMode ? gAudioConfigurationMode[1] : false)
	local curSession := (gAudioConfigurationMode ? gAudioConfigurationMode[2] : false)

	if simulator {
		if (session = "Qualification")
			session := "Qualifying"
		else if !session
			session := "Default"
	}
	else
		session := false

	if ((curSimulator != simulator) || (curSession != session)) {
		deleteFile(kUserConfigDirectory . "Audio.mode")

		FileAppend(simulator . "->" . session, kUserConfigDirectory . "Audio.mode")

		gAudioConfigurationMode := [simulator, session]
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
	global gAudioConfiguration, gAudioConfigurationModTime, gAudioConfigurationMode, gAudioConfigurationModeModTime

	local fileName

	try {
		fileName := (kUserConfigDirectory . "Audio Settings.ini")

		if (!gAudioConfiguration && FileExist(fileName)) {
			gAudioConfigurationModTime := FileGetTime(fileName, "M")
			gAudioConfiguration := readMultiMap(fileName)
		}
	}
	catch Any as exception {
		logError(exception)

		gAudioConfiguration := false
	}

	try {
		fileName := (kUserConfigDirectory . "Audio.mode")

		if (!gAudioConfigurationMode && FileExist(fileName)) {
			gAudioConfigurationModeModTime := FileGetTime(fileName, "M")
			gAudioConfigurationMode := string2Values("->", FileRead(fileName))
		}
	}
	catch Any as exception {
		logError(exception)

		gAudioConfigurationMode := false
	}

	return gAudioConfiguration
}

initializeAudioConfiguration() {
	PeriodicTask(() {
		global gAudioConfiguration, gAudioConfigurationModTime, gAudioConfigurationMode, gAudioConfigurationModeModTime

		try {
			if (gAudioConfigurationModTime && (FileGetTime(kUserConfigDirectory . "Audio Settings.ini", "M") > gAudioConfigurationModTime)) {
				gAudioConfiguration := false
				gAudioConfigurationModTime := false
			}
		}
		catch Any as exception {
			logError(exception)
		}

		try {
			if (gAudioConfigurationModeModTime && (FileGetTime(kUserConfigDirectory . "Audio.mode", "M") > gAudioConfigurationModeModTime)) {
				gAudioConfigurationMode := false
				gAudioConfigurationModeModTime := false
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}, 2000, kLowPriority).start()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeAudioConfiguration()