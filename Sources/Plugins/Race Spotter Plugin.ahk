;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter Plugin             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\RaceAssistantPlugin.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceSpotterPlugin = "Race Spotter"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceSpotterPlugin extends RaceAssistantPlugin  {
	class RemoteRaceSpotter extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			base.__New(plugin, "Race Spotter", remotePID)
		}
	}

	RaceSpotter[] {
		Get {
			return this.RaceAssistant
		}
	}

	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)

		if (!this.Active && !isDebug())
			return

		if (this.RaceAssistantName)
			SetTimer collectRaceSpotterSessionData, 10000
		else
			SetTimer updateRaceSpotterSessionState, 5000
	}

	createRaceAssistant(pid) {
		return new this.RemoteRaceSpotter(this, pid)
	}

	requestInformation(arguments*) {
		if (this.RaceSpotter && inList(["Time", "Position", "LapTimes", "GapToAhead", "GapToFront", "GapToBehind"
									  , "GapToAheadStandings", "GapToFrontStandings", "GapToBehindStandings", "GapToAheadTrack"
									  , "GapToBehindTrack", "GapToLeader"], arguments[1])) {
			this.RaceSpotter.requestInformation(arguments*)

			return true
		}
		else
			return false
	}

	acquireSessionData(ByRef telemetryData, ByRef positionsData) {
		data := base.acquireSessionData(telemetryData, positionsData)

		this.updatePositionsData(data)

		if positionsData
			setConfigurationSectionValues(positionsData, "Position Data", getConfigurationSectionValues(data, "Position Data", Object()))

		return data
	}

	addLap(lapNumber, dataFile, telemetryData, positionsData) {
		static sessionDB := false

		base.addLap(lapNumber, dataFile, telemetryData, positionsData)

		if (this.RaceAssistant && (this.Simulator && this.Simulator.supportsTrackMap())) {
			if !sessionDB
				sessionDB := new SessionDatabase()

			simulator := getConfigurationValue(telemetryData, "Session Data", "Simulator", false)
			simulatorName := settingsDB.getSimulatorName(simulator)

			if (lapNumber > getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)) {
				track := getConfigurationValue(telemetryData, "Session Data", "Track", false)

				if !sessionDB.hasTrackMap(simulator, track) {
					code := settingsDB.getSimulatorCode(simulator)
					dataFile := (kTempDirectory . simulator . " Data\" . track . ".data")

					exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

					if FileExist(exePath) {
						try {
							Run %ComSpec% /c ""%exePath%" -Map > "%dataFile%"", %kBinariesDirectory%, Hide UseErrorLevel, mapperPID
						}
						catch exception {
							logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
																	   , {simulator: code, protocol: "SHM"})
												   . exePath . translate(") - please rebuild the applications in the binaries folder (")
												   . kBinariesDirectory . translate(")"))

							showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
														  , {exePath: exePath, simulator: code, protocol: "SHM"})
									  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
						}

						if ((ErrorLevel != "Error") && mapperPID) {
							callback := ObjBindMethod(this, "createTrackMap", simulatorName, track, dataFile, mapperPID)

							SetTimer %callback%, -120000
						}
					}
				}
			}
		}
	}

	createTrackMap(simulator, track, dataFile, mapperPID) {
		Process Exist, %mapperPID%

		if ErrorLevel {
			callback := ObjBindMethod(this, "createTrackMap", simulator, track, dataFile, mapperPID)

			SetTimer %callback%, -10000
		}
		else {
			try {
				Run %kBinariesDirectory%Track Mapper.exe -Simulator ""%simulator%"" -Track ""track"" -Data ""%datafile%""
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start Track Mapper - please rebuild the applications..."))

				showMessage(translate("Cannot start Track Mapper - please rebuild the applications...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateRaceSpotterSessionState() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceSpotterPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

collectRaceSpotterSessionData() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceSpotterPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

initializeRaceSpotterPlugin() {
	local controller := SimulatorController.Instance

	new RaceSpotterPlugin(controller, kRaceSpotterPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterPlugin()