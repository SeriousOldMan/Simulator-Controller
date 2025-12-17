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

getAudioSettings(name, type := "Output", default := false) {
	global gAudioConfigurationModTime, gAudioConfigurationMode

	local simulator, session, key, audioDevice, volume

	static settings := false
	static lastModTime := false

	getValue(property, default) {
		global gAudioConfiguration

		local value

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

		return value
	}

	if requireAudioConfiguration() {
		if (!settings || (lastModTime != gAudioConfigurationModTime))
			settings := CaseInsenseMap()

		simulator := (gAudioConfigurationMode ? gAudioConfigurationMode[1] : false)
		session := (gAudioConfigurationMode ? gAudioConfigurationMode[2] : false)
		key := ((simulator ? (type . "." . simulator . "." . session) : type) . name)

		if settings.Has(key)
			return settings[key]
		else {
			if (type = "Output") {
				audioDevice := getValue("AudioDevice", kUndefined)
				volume := getValue("Volume", 1.0)

				if ((audioDevice != kUndefined) || (volume != 1.0))
					return (settings[key] := {AudioDevice: ((audioDevice != kUndefined) ? audioDevice : false)
											, Volume: volume})
			}
			else {
				audioDevice := getValue("AudioDevice", kUndefined)

				if (audioDevice != kUndefined)
					return (settings[key] := {AudioDevice: audioDevice})
			}
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
		
		if !InStr(player, ".exe")
			player .= ".exe"

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

playSound(player, wavFile, settings := false, options := false) {
	local workingDirectory, pid, audioDevice, volume

	if (player = "System")
		player := false
	else
		player := requireSoundPlayer(player)

	if settings {
		audioDevice := settings.AudioDevice
		volume := settings.Volume
	}
	else {
		audioDevice := false
		volume := 1.0
	}

	if (audioDevice = kNull)
		return false

	if player {
		SplitPath(kSox, , &workingDirectory)

		try {
			if isDebug()
				logMessage(kLogDebug, "Playing sound `"" . wavFile . "`" with player " . player . "...")

			Run("`"" . player . "`" `"" . wavFile . "`" -t waveaudio" . (audioDevice ? (A_Space . "`"" . audioDevice . "`"") : "")
																	  . (options ? (A_Space . options) : "")
																	  . ((volume != 1.0) ? (A_Space . "vol " . volume) : "")
			  , workingDirectory, "HIDE", &pid)
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
			
			if (gAudioConfigurationMode.Length != 2) {
				gAudioConfigurationMode := false
				
				deleteFile(fileName)
			}
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