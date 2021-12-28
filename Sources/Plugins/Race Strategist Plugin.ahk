;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist Plugin          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\RaceAssistantPlugin.ahk
#Include ..\Assistants\Libraries\TelemetryDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceStrategistPlugin = "Race Strategist"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategistPlugin extends RaceAssistantPlugin  {
	static kLapDataSchemas := {Telemetry: ["Lap", "Simulator", "Car", "Track", "Weather", "Temperature.Air", "Temperature.Track"
										 , "Fuel.Consumption", "Fuel.Remaining", "LapTime", "Pitstop", "Map", "TC", "ABS"
										 , "Compound", "Compound.Color", "Pressures", "Temperatures"]}
										 
	class RemoteRaceStrategist extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(remotePID) {
			base.__New("Race Strategist", remotePID)
		}
		
		recommendPitstop(arguments*) {
			this.callRemote("callRecommendPitstop", arguments*)
		}
		
		updateStrategy(arguments*) {
			this.callRemote("updateStrategy", arguments*)
		}
		
		cancelStrategy(arguments*) {
			this.callRemote("cancelStrategy", arguments*)
		}
	}

	class RaceStrategistAction extends RaceAssistantPlugin.RaceAssistantAction {
		fireAction(function, trigger) {
			if (this.Plugin.RaceAssistant && (this.Action = "PitstopRecommend"))
				this.Plugin.recommendPitstop()
			else if (this.Plugin.RaceAssistant && (this.Action = "StrategyCancel"))
				this.Plugin.cancelStrategy()
			else
				base.fireAction(function, trigger)
		}
	}
	
	RaceStrategist[] {
		Get {
			return this.RaceAssistant
		}
	}
	
	LapDatabase[] {
		Get {
			if !this.iLapDatabase
				this.iLapDatabase := new Database(false, this.kLapDataSchemas)
			
			return this.iLapDatabase
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)

		if (!this.Active && !isDebug())
			return
		
		if (this.RaceAssistantName)
			SetTimer collectRaceStrategistSessionData, 10000
		else
			SetTimer updateRaceStrategistSessionState, 5000
	}
	
	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function
		
		if inList(["PitstopRecommend", "StrategyCancel"], action) {
			function := controller.findFunction(actionFunction)
			
			if (function != false) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				this.registerAction(new this.RaceStrategistAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return base.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}
	
	createRaceAssistant(pid) {
		return new this.RemoteRaceStrategist(pid)
	}
	
	startSession(settingsFile, dataFile, teamSession) {
		base.startSession(settingsFile, dataFile, teamSession)
		
		this.iLapDatabase := false
	}
	
	addLap(lapNumber, dataFile, telemetryData, positionsData) {
		base.addLap(lapNumber, dataFile, telemetryData, positionsData)
		
		if (this.TeamSession && this.RaceStrategist) {
			strategyUpdate := this.TeamServer.getSessionValue("Strategy Update", false)
			
			if (strategyUpdate && (strategyUpdate != "")) {
				this.TeamServer.setSessionValue("Strategy Update", "")
				
				strategyUpdate := this.TeamServer.getLapValue(strategyUpdate, "Strategy Update")
				
				if (strategyUpdate && (strategyUpdate != ""))
					if (strategyUpdate = "CANCEL")
						this.RaceStrategist.updateStrategy(false)
					else {
						try {
							FileDelete %kTempDirectory%Race Strategy.update
							
							FileAppend %strategyUpdate%, %kTempDirectory%Race Strategy.update
						}
						catch exception {
							; ignore
						}
					
						this.RaceStrategist.updateStrategy(kTempDirectory . "Race Strategy.update")
					}
			}
		}
	}
	
	requestInformation(arguments*) {
		if (this.RaceStrategist && inList(["LapsRemaining", "Weather", "Position", "LapTimes", "GapToFront", "GapToBehind", "GapToFrontStandings", "GapToBehindStandings", "GapToFrontTrack", "GapToBehindTrack", "GapToLeader", "StrategyOverview", "NextPitstop"], arguments[1])) {
			this.RaceStrategist.requestInformation(arguments*)
		
			return true
		}
		else
			return false
	}
	
	recommendPitstop(lapNumber := false) {
		if this.RaceStrategist
			this.RaceStrategist.recommendPitstop(lapNumber)
	}
	
	cancelStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.cancelStrategy()
	}
	
	sessionActive(sessionState) {
		return ((sessionState == kSessionPractice) || (sessionState == kSessionRace))
	}
	
	acquireSessionData(ByRef telemetryData, ByRef positionsData) {
		data := base.acquireSessionData(telemetryData, positionsData)
		
		this.updatePositionsData(data)
		
		if positionsData
			setConfigurationSectionValues(positionsData, "Position Data", getConfigurationSectionValues(data, "Position Data", Object()))
		
		return data
	}
	
	saveTelemetryData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
					, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
					, compound, compoundColor, pressures, temperatures) {
		teamServer := this.TeamServer
		
		if (teamServer && teamServer.SessionActive)
			teamServer.setLapValue(lapNumber, this.Plugin . " Telemetry"
								 , values2String(";", simulator, car, track, weather, airTemperature, trackTemperature
								 , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs,
								 , compound, compoundColor, pressures, temperatures))
		else
			this.LapDatabase.add("Telemetry", {Lap: lapNumber, Simulator: simulator, Car: car, Track: track
											 , Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											 , "Fuel.Consumption": fuelConsumption, "Fuel.Remaining": fuelRemaining, LapTime: lapTime
											 , Pitstop: pitstop, Map: map, TC: tc, ABS: abs
											 , "Compound": compound, "Compound.Color": compoundColor, Pressures: pressures, Temperatures: temperatures})
	}

	updateTelemetryDatabase() {
		telemetryDB := false
		teamServer := this.TeamServer
		session := this.TeamSession
		
		runningLap := 0
		
		if (teamServer && teamServer.Active && session)
			Loop % teamServer.getCurrentLap(session)
			{
				try {
					telemetryData := teamServer.getLapValue(A_Index, this.Plugin . " Telemetry", session)
					
					if (!telemetryData || (telemetryData == ""))
						continue
					
					telemetryData := string2Values(";", telemetryData)
					
					if !telemetryDB
						telemetryDB := new TelemetryDatabase(telemetryData[1], telemetryData[2], telemetryData[3])
					
					if telemetryData[10]
						runningLap := 0
					
					runningLap += 1
					
					pressures := string2Values(",", telemetryData[16])
					temperatures := string2Values(",", telemetryData[17])
					
					telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15]
												 , telemetryData[11], telemetryData[12], telemetryData[13], telemetryData[7], telemetryData[8], telemetryData[9])
												 
					telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15], runningLap
										   , pressures[1], pressures[2], pressures[4], pressures[4]
										   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
										   , telemetryData[7], telemetryData[8], telemetryData[9])
				}
				catch exception {
					break
				}
			}
		else
			for ignore, telemetryData in this.LapDatabase.Tables["Telemetry"] {
				if !telemetryDB
					telemetryDB := new TelemetryDatabase(telemetryData.Simulator, telemetryData.Car, telemetryData.Track)
				
				if telemetryData.Pitstop
					runningLap := 0
				
				runningLap += 1
				
				telemetryDB.addElectronicEntry(telemetryData.Weather, telemetryData["Temperature.Air"], telemetryData["Temperature.Track"]
											 , telemetryData.Compound, telemetryData["Compound.Color"]
											 , telemetryData.Map, telemetryData.TC, telemetryData.ABS
											 , telemetryData["Fuel.Consumption"], telemetryData["Fuel.Remaining"], telemetryData.LapTime)
				
				pressures := string2Values(",", telemetryData.Pressures)
				temperatures := string2Values(",", telemetryData.Temperatures)
				
				telemetryDB.addTyreEntry(telemetryData.Weather, telemetryData["Temperature.Air"], telemetryData["Temperature.Track"]
									   , telemetryData.Compound, telemetryData["Compound.Color"], runningLap
									   , pressures[1], pressures[2], pressures[4], pressures[4]
									   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
									   , telemetryData["Fuel.Consumption"], telemetryData["Fuel.Remaining"], telemetryData.LapTime)
			}
	}
	
	setLapValue(lapNumber, name, fileName) {
		teamServer := this.TeamServer
		
		if (teamServer && teamServer.SessionActive) {
			currentEncoding := A_FileEncoding
			
			try {
				FileEncoding UTF-16
				FileRead lapData, %fileName%
			}
			finally {
				FileEncoding %currentEncoding%
			}
			
			teamServer.setLapValue(lapNumber, name, lapData)
			
			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}
		}
	}
	
	saveStandingsData(lapNumber, fileName) {
		teamServer := this.TeamServer
		
		if (teamServer && teamServer.SessionActive)
			this.setLapValue(lapNumber, this.Plugin . " Race Standings", fileName)
	}
	
	saveRaceInfo(lapNumber, fileName) {
		teamServer := this.TeamServer
		
		if (teamServer && teamServer.SessionActive)
			this.setLapValue(lapNumber, this.Plugin . " Race Info", fileName)
		else {
			try {
				FileRemoveDir %kTempDirectory%Race Report, 1
			}
			catch exception {
				; ignore
			}
			
			FileCreateDir %kTempDirectory%Race Report
			
			FileMove %fileName%, %kTempDirectory%Race Report\Race.data
		}
	}
	
	saveRaceLap(lapNumber, fileName) {
		teamServer := this.TeamServer
		
		if (teamServer && teamServer.SessionActive)
			this.setLapValue(lapNumber, this.Plugin . " Race Lap", fileName)
		else 
			FileMove %fileName%, %kTempDirectory%Race Report\Lap.%lapNumber%
	}
	
	createRaceReport() {
		reportsDirectory := getConfigurationValue(this.Configuration, "Race Strategist Reports", "Database", false)
		
		if reportsDirectory {
			teamServer := this.TeamServer
			session := this.TeamSession
			
			runningLap := 0
			
			if (teamServer && teamServer.Active && session) {
				try {
					FileRemoveDir %kTempDirectory%Race Report, 1
				}
				catch exception {
					; ignore
				}
				
				FileCreateDir %kTempDirectory%Race Report
				
				try {
					raceInfo := teamServer.getLapValue(1, this.Plugin . " Race Info", session)
		
					if (!raceInfo || (raceInfo == ""))
						return
						
					FileAppend %raceInfo%, %kTempDirectory%Race Report\Race.data
					
					data := readConfiguration(kTempDirectory . "Race Report\Race.data")
				}
				catch exception {
					data := {}
				}
				
				count := 0
				pitstops := false
				
				Loop % teamServer.getCurrentLap(session)
				{
					try {
						lapData := teamServer.getLapValue(A_Index, this.Plugin . " Race Lap", session)
						
						if (lapData && (lapData != "")) {
							lapData := parseConfiguration(lapData)
							
							count += 1
							
							for key, value in getConfigurationSectionValues(lapData, "Lap")
								setConfigurationValue(data, "Laps", key, value)
							
							pitstops := getConfigurationValue(lapData, "Pitstop", "Laps", "")
							
							times := getConfigurationValue(lapData, "Times", A_Index)
							positions := getConfigurationValue(lapData, "Positions", A_Index)
							laps := getConfigurationValue(lapData, "Laps", A_Index)
							drivers := getConfigurationValue(lapData, "Drivers", A_Index)
							
							newLine := ((count > 1) ? "`n" : "")
							
							line := (newLine . times)
							
							FileAppend %line%, % kTempDirectory . "Race Report\Times.CSV"
							
							line := (newLine . positions)
							
							FileAppend %line%, % kTempDirectory . "Race Report\Positions.CSV"
							
							line := (newLine . laps)
							
							FileAppend %line%, % kTempDirectory . "Race Report\Laps.CSV"
							
							line := (newLine . drivers)
							directory := (kTempDirectory . "Race Report\Drivers.CSV")
							
							FileAppend %line%, %directory%, UTF-16
						}
					}
					catch exception {
						break
					}
				}
				
				removeConfigurationValue(data, "Laps", "Lap")
				setConfigurationValue(data, "Laps", "Count", count)
				
				setConfigurationValue(data, "Laps", "Pitstops", pitstops)
				
				writeConfiguration(kTempDirectory . "Race Report\Race.data", data)
				
				simulatorCode := new SetupDatabase().getSimulatorCode(getConfigurationValue(data, "Session", "Simulator"))
			
				directory := (reportsDirectory . "\" . simulatorCode . "\" . getConfigurationValue(data, "Session", "Time"))
			
				FileCopyDir %kTempDirectory%Race Report, %directory%, 1
			}
			else {
				data := readConfiguration(kTempDirectory . "Race Report\Race.data")
				
				count := 0
				pitstops := false
				
				Loop {
					fileName := (kTempDirectory . "Race Report\Lap." . A_Index)
				
					if !FileExist(fileName)
						break
					else {
						lapData := readConfiguration(fileName)
				
						count += 1
						
						try {
							FileDelete %fileName%
						}
						catch exception {
							; ignore
						}
						
						for key, value in getConfigurationSectionValues(lapData, "Lap")
							setConfigurationValue(data, "Laps", key, value)
							
						pitstops := getConfigurationValue(lapData, "Pitstop", "Laps", "")
						
						times := getConfigurationValue(lapData, "Times", A_Index)
						positions := getConfigurationValue(lapData, "Positions", A_Index)
						laps := getConfigurationValue(lapData, "Laps", A_Index)
						drivers := getConfigurationValue(lapData, "Drivers", A_Index)
						
						newLine := ((count > 1) ? "`n" : "")
						
						line := (newLine . times)
						
						FileAppend %line%, % kTempDirectory . "Race Report\Times.CSV"
						
						line := (newLine . positions)
						
						FileAppend %line%, % kTempDirectory . "Race Report\Positions.CSV"
						
						line := (newLine . laps)
						
						FileAppend %line%, % kTempDirectory . "Race Report\Laps.CSV"
						
						line := (newLine . drivers)
						fileName := (kTempDirectory . "Race Report\Drivers.CSV")
						
						FileAppend %line%, %fileName%, UTF-16
					}
				}
				
				removeConfigurationValue(data, "Laps", "Lap")
				setConfigurationValue(data, "Laps", "Count", count)
				
				setConfigurationValue(data, "Laps", "Pitstops", pitstops)
				
				writeConfiguration(kTempDirectory . "Race Report\Race.data", data)
				
				simulatorCode := new SetupDatabase().getSimulatorCode(getConfigurationValue(data, "Session", "Simulator"))
			
				directory := (reportsDirectory . "\" . simulatorCode . "\" . getConfigurationValue(data, "Session", "Time"))
			
				FileCopyDir %kTempDirectory%Race Report, %directory%, 1
			}
		}		
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

collectRaceStrategistSessionData() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceStrategistPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

updateRaceStrategistSessionState() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceStrategistPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

initializeRaceStrategistPlugin() {
	local controller := SimulatorController.Instance
	
	new RaceStrategistPlugin(controller, kRaceStrategistPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistPlugin()