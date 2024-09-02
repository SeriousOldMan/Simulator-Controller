;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Sound Functions                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

requireSoundPlayer(player) {
	local path

	if (kSox && FileExist(kSox)) {
		path := (kUserHomeDirectory . "Programs\" . player)

		if FileExist(path)
			return path
		else
			loop
				try {
					DirCreate(kUserHomeDirectory . "Programs")

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