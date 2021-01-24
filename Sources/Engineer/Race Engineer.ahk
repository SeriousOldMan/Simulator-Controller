;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence.ico
;@Ahk2Exe-ExeName Race Engineer.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Libraries\RaceEngineer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RemotePitstopHandler {
	iRemotePID := false
	
	RemotePID[] {
		Get {
			return this.iRemotePID
		}
	}
	
	__New(remotePID) {
		this.iRemotePID := remotePID
	}
		
	callRemote(function, arguments*) {
		raiseEvent("ahk_pid " . this.RemotePID, "Pitstop", function . ":" . values2String(";", arguments*))
	}
	
	pitstopPlanned() {
		this.callRemote("pitstopPlanned")
	}
	
	pitstopPrepared() {
		this.callRemote("pitstopPrepared")
	}
	
	pitstopFinished() {
		this.callRemote("pitstopFinished")
	}
	
	startPitstopSetup() {
		this.callRemote("startPitstopSetup")
	}

	finishPitstopSetup() {
		this.callRemote("finishPitstopSetup")
	}

	setPitstopRefuelAmount(litres) {
		this.callRemote("setPitstopRefuelAmount", litres)
	}
	
	setPitstopTyreSet(compound, set := false) {
		this.callRemote("setPitstopTyreSet", compound, set)
	}

	setPitstopTyrePressures(pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement) {
		this.callRemote("setPitstopTyrePressures", pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement)
	}

	requestPitstopRepairs(repairSuspension, repairBodywork) {
		this.callRemote("requestPitstopRepairs", repairSuspension, repairBodywork)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startRaceEngineer() {
	icon := kIconsDirectory . "Artificial Intelligence.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	remotePID := 0
	remoteHandle := false
	engineerName := "Jona"
	engineerSpeaker := false
	engineerListener:= false
	raceSettingsFile := getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory)
	
	index := 1
	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				engineerName := A_Args[index + 1]
				index += 2
			case "-Speaker":
				engineerSpeaker := A_Args[index + 1]
				index += 2
			case "-Listener":
				engineerListener := A_Args[index + 1]
				index += 2
			case "-Settings":
				raceSettingsFile := A_Args[index + 1]
				index += 2
		}
	}
	
	registerEventHandler("Race", "handleEvents")
	
	RaceEngineer.Instance := new RaceEngineer(false, readConfiguration(raceSettingsFile), remotePID ? new RemotePitstopHandler(remotePID) : false, engineerName, engineerSpeaker, engineerListener)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRace(dataFileName) {
	RaceEngineer.Instance.startRace(readConfiguration(dataFileName))
}

finishRace() {
	RaceEngineer.Instance.finishRace()
}

addLap(lapNumber, dataFileName) {
	RaceEngineer.Instance.addLap(readConfiguration(dataFileName))
}

planPitstop() {
	RaceEngineer.Instance.planPitstop()
}

preparePitstop(lap := false) {
	RaceEngineer.Instance.planPitstop()
}

performPitstop() {
	RaceEngineer.Instance.performPitstop()
}

handleEvents(event, data) {
	local function
	
	if InStr(data, ":") {
		data := StrSplit(data, ":")
		
		function := data[1]
		arguments := string2Values(";", data[2])
			
		withProtection(function, arguments*)
	}
	else	
		withProtection(data)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRaceEngineer()