;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Strategist              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceAssistant.ahk
#Include ..\Assistants\Libraries\TelemetryDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategist extends RaceAssistant {
	iSessionTime := false
	
	iSaveTelemetry := kAlways
	iSaveRaceReport := false
	
	iSessionReportsDatabase := false
	iSessionDataActive := false
	
	SessionTime[] {
		Get {
			return this.iSessionTime
		}
	}
	
	SaveTelemetry[] {
		Get {
			return this.iSaveTelemetry
		}
	}
	
	SaveRaceReport[] {
		Get {
			return ((this.iSessionReportsDatabase != false) ? this.iSaveRaceReport : kNever)
		}
	}
	
	SessionReportsDatabase[] {
		Get {
			return this.iSessionReportsDatabase
		}
	}
	
	SessionDataActive[] {
		Get {
			return this.iSessionDataActive
		}
	}
	
	__New(configuration, strategistSettings, name := false, language := "__Undefined__", service := false, speaker := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Strategist", strategistSettings, name, language, service, speaker, listener, voiceServer)
	}
	
	updateConfigurationValues(values) {
		base.updateConfigurationValues(values)
		
		if values.HasKey("SessionReportsDatabase")
			this.iSessionReportsDatabase := values["SessionReportsDatabase"]
		
		if values.HasKey("SaveTelemetry")
			this.iSaveTyrePressures := values["SaveTelemetry"]
		
		if values.HasKey("SaveRaceReport")
			this.iSaveRaceReport := values["SaveRaceReport"]
	}
	
	updateSessionValues(values) {
		base.updateSessionValues(values)
		
		if values.HasKey("SessionTime")
			this.iSessionTime := values["SessionTime"]
	}
	
	hasEnoughData(inform := true) {
		if (this.Session == kSessionRace)
			return base.hasEnoughData(inform)
		else {
			if (inform && this.Speaker)
				this.getSpeaker().speakPhrase("CollectingData")
			
			return false
		}
	}
	
	handleVoiceCommand(grammar, words) {
		switch grammar {
			case "LapsRemaining":
				this.lapsRemainingRecognized(words)
			case "Weather":
				this.weatherRecognized(words)
			case "Position":
				this.positionRecognized(words)
			case "FuturePosition":
				this.futurePositionRecognized(words)
			case "GapToFront":
				this.gapToFrontRecognized(words)
			case "GapToBehind":
				this.gapToBehindRecognized(words)
			case "GapToLeader":
				this.gapToLeaderRecognized(words)
			case "LapTimes":
				this.lapTimesRecognized(words)
			case "PitstopRecommend":
				this.clearContinuation()
				
				this.getSpeaker().speakPhrase("Confirm")
			
				sendMessage()
				
				Loop 10
					Sleep 500
				
				this.recommendPitstopRecognized(words)
			case "PitstopSimulate":
				this.clearContinuation()
				
				this.getSpeaker().speakPhrase("Confirm")
			
				sendMessage()
				
				Loop 10
					Sleep 500
				
				this.simulatePitstopRecognized(words)
			default:
				base.handleVoiceCommand(grammar, words)
		}
	}
	
	lapsRemainingRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		laps := Round(knowledgeBase.getValue("Lap.Remaining.Fuel", 0))
		
		if (laps == 0)
			this.getSpeaker().speakPhrase("Later")
		else
			this.getSpeaker().speakPhrase("Laps", {laps: laps})
	}
	
	weatherRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		weather10Min := knowledgeBase.getValue("Weather.Weather.10Min", false)
		
		if !weather10Min
			this.getSpeaker().speakPhrase("Later")
		else if (weather10Min = "Dry")
			this.getSpeaker().speakPhrase("WeatherGood")
		else
			this.getSpeaker().speakPhrase("WeatherRain")
	}
	
	positionRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		speaker := this.getSpeaker()
		position := Round(knowledgeBase.getValue("Position", 0))
		
		if (position == 0)
			speaker.speakPhrase("Later")
		else if inList(words, speaker.Fragments["Laps"])
			this.futurePositionRecognized(words)
		else {
			speaker.speakPhrase("Position", {position: position})
			
			if (position <= 3)
				speaker.speakPhrase("Great")
		}
	}
	
	futurePositionRecognized(words) {
		local knowledgeBase = this.KnowledgeBase
		local action
		
		if !this.hasEnoughData()
			return
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		lapPosition := inList(words, fragments["Laps"])
				
		if lapPosition {
			lapDelta := words[lapPosition - 1]
			
			if lapDelta is number
			{
				currentLap := knowledgeBase.getValue("Lap")
				lap := currentLap + lapDelta
				
				if (lap <= currentLap)
					speaker.speakPhrase("NoFutureLap")
				else {
					car := knowledgeBase.getValue("Driver.Car")
					
					speaker.speakPhrase("Confirm")
				
					sendMessage()
					
					Loop 10
						Sleep 500
					
					knowledgeBase.setFact("Standings.Extrapolate", lap)
		
					knowledgeBase.produce()
					
					if this.Debug[kDebugKnowledgeBase]
						this.dumpKnowledge(this.KnowledgeBase)
					
					position := knowledgeBase.getValue("Standings.Extrapolated." . lap . ".Car." . car . ".Position", false)
					
					if position
						speaker.speakPhrase("FuturePosition", {position: position})
					else
						speaker.speakPhrase("NoFuturePosition")
				}
				
				return
			}
		}
			
		speaker.speakPhrase("Repeat")
	}
	
	gapToFrontRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToFrontRecognized(words)
		else
			this.standingsGapToFrontRecognized(words)
	}
	
	trackGapToFrontRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		speaker := this.getSpeaker()
		
		delta := knowledgeBase.getValue("Position.Track.Front.Delta", 0)
		
		if (delta != 0) {
			speaker.speakPhrase("TrackGapToFront", {delta: Format("{:.1f}", Abs(Round(delta / 1000, 1)))})
			
			lap := knowledgeBase.getValue("Lap")
			driverLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
			otherLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Front.Car") . ".Laps"))
			
			if (driverLap < otherLap)
			  speaker.speakPhrase("NotTheSameLap")
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}
	
	standingsGapToFrontRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if (Round(knowledgeBase.getValue("Position", 0)) = 1)
			this.getSpeaker().speakPhrase("NoGapToFront")
		else {
			delta := Abs(Round(knowledgeBase.getValue("Position.Standings.Front.Delta", 0) / 1000, 1))
			
			this.getSpeaker().speakPhrase("StandingsGapToFront", {delta: Format("{:.1f}", delta)})
		}
	}
	
	gapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToBehindRecognized(words)
		else
			this.standingsGapToBehindRecognized(words)
	}
	
	trackGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		speaker := this.getSpeaker()
		
		delta := knowledgeBase.getValue("Position.Track.Behind.Delta", 0)
		
		if (delta != 0) {
			speaker.speakPhrase("TrackGapToBehind", {delta: Format("{:.1f}", Abs(Round(delta / 1000, 1)))})
			
			lap := knowledgeBase.getValue("Lap")
			driverLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
			otherLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Behind.Car") . ".Laps"))
			
			if (driverLap > (otherLap + 1))
			  speaker.speakPhrase("NotTheSameLap")
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}
	
	standingsGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if (Round(knowledgeBase.getValue("Position", 0)) = Round(knowledgeBase.getValue("Car.Count", 0)))
			this.getSpeaker().speakPhrase("NoGapToBehind")
		else {
			delta := Abs(Round(knowledgeBase.getValue("Position.Standings.Behind.Delta", 0) / 1000, 1))
		
			this.getSpeaker().speakPhrase("StandingsGapToBehind", {delta: Format("{:.1f}", delta)})
		}
	}
	
	gapToLeaderRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		if (Round(knowledgeBase.getValue("Position", 0)) = 1)
			this.getSpeaker().speakPhrase("NoGapToFront")
		else {
			delta := Abs(Round(knowledgeBase.getValue("Position.Standings.Leader.Delta", 0) / 1000, 1))
		
			this.getSpeaker().speakPhrase("GapToLeader", {delta: Format("{:.1f}", delta)})
		}
	}
	
	reportLapTime(phrase, driverLapTime, car) {
		lapTime := this.KnowledgeBase.getValue("Car." . car . ".Time", false)
		
		if lapTime {
			lapTime := Round(lapTime / 1000, 1)
			
			speaker := this.getSpeaker()
			fragments := speaker.Fragments
			
			speaker.speakPhrase(phrase, {time: Format("{:.1f}", lapTime)})
			
			delta := (driverLapTime - lapTime)
		
			if (Abs(delta) > 0.5)
				this.getSpeaker().speakPhrase("LapTimeDelta", {delta: Format("{:.1f}", Abs(delta))
															 , difference: (delta > 0) ? fragments["Faster"] : fragments["Slower"]})
		}
	}
	
	lapTimesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		car := knowledgeBase.getValue("Driver.Car")
		lap := knowledgeBase.getValue("Lap")
		position := Round(knowledgeBase.getValue("Position"))
		cars := Round(knowledgeBase.getValue("Car.Count"))
		
		driverLapTime := Round(knowledgeBase.getValue("Car." . car . ".Time") / 1000, 1)
		
		if (lap == 0)
			this.getSpeaker().speakPhrase("Later")
		else {
			this.getSpeaker().speakPhrase("LapTime", {time: Format("{:.1f}", driverLapTime)})
		
			if (position > 2)
				this.reportLapTime("LapTimeFront", driverLapTime, knowledgeBase.getValue("Position.Standings.Front.Car", 0))
			
			if (position < cars)
				this.reportLapTime("LapTimeBehind", driverLapTime, knowledgeBase.getValue("Position.Standings.Behind.Car", 0))
			
			if (position > 1)
				this.reportLapTime("LapTimeLeader", driverLapTime, knowledgeBase.getValue("Position.Standings.Leader.Car", 0))
		}
	}
	
	recommendPitstopRecognized(words) {
		this.pitstopLapRecognized(words)
	}
	
	simulatePitstopRecognized(words) {
		this.pitstopLapRecognized(words, true)
	}
	
	pitstopLapRecognized(words, lap := false) {
		if lap {
			lapPosition := inList(words, this.getSpeaker().Fragments["Lap"])
			
			if lapPosition {
				lap := words[lapPosition + 1]
				
				if lap is not number
					lap := false
			}
			else
				lap := false
		}
		
		this.recommendPitstop(lap)
	}
	
	createSession(data) {
		local facts
		
		configuration := this.Configuration
		settings := this.Settings
		
		simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SetupDatabase.getSimulatorName(simulator)
		
		switch getConfigurationValue(data, "Session Data", "Session", "Practice") {
			case "Practice":
				session := kSessionPractice
			case "Qualification":
				session := kSessionQualification
			case "Race":
				session := kSessionRace
			default:
				session := kSessionOther
		}
		
		this.updateSessionValues({Simulator: simulatorName, Session: session, SessionTime: A_Now
								, Driver: getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverName)})
		
		lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
		
		sessionFormat := getConfigurationValue(data, "Session Data", "SessionFormat", "Time")
		sessionTimeRemaining := getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0)
		sessionLapsRemaining := getConfigurationValue(data, "Session Data", "SessionLapsRemaining", 0)
		
		dataDuration := Round((sessionTimeRemaining + lapTime) / 1000)
		
		if (sessionFormat = "Time")
			duration := dataDuration
		else {
			settingsDuration := getConfigurationValue(settings, "Session Settings", "Duration", dataDuration)
			
			if ((Abs(settingsDuration - dataDuration) / dataDuration) >  0.05)
				duration := dataDuration
			else
				duration := settingsDuration
		}
		
		facts := {"Session.Simulator": simulator
				, "Session.Car": getConfigurationValue(data, "Session Data", "Car", "")
				, "Session.Track": getConfigurationValue(data, "Session Data", "Track", "")
				, "Session.Duration": duration
				, "Session.Format": sessionFormat
				, "Session.Time.Remaining": sessionTimeRemaining
				, "Session.Lap.Remaining": sessionLapsRemaining
				, "Session.Settings.Lap.Formation": getConfigurationValue(settings, "Session Settings", "Lap.Formation", true)
				, "Session.Settings.Lap.PostRace": getConfigurationValue(settings, "Session Settings", "Lap.PostRace", true)
				, "Session.Settings.Fuel.Max": getConfigurationValue(data, "Session Data", "FuelAmount", 0)
				, "Session.Settings.Fuel.AvgConsumption": getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", 0)
				, "Session.Settings.Pitstop.Delta": getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta", getConfigurationValue(settings, "Session Settings", "Pitstop.Delta", 30))
				, "Session.Settings.Fuel.SafetyMargin": getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin", 5)
				, "Session.Settings.Lap.AvgTime": getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", 0)
				, "Session.Settings.Lap.Learning.Laps": getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".LearningLaps", 1)
				, "Session.Settings.Lap.History.Considered": getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
				, "Session.Settings.Lap.History.Damping": getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".HistoryLapsDamping", 0.2)
				, "Session.Settings.Standings.Extrapolation.Laps": getConfigurationValue(settings, "Strategy Settings", "Extrapolation.Laps", 2)
				, "Session.Settings.Standings.Extrapolation.Overtake.Delta": Round(getConfigurationValue(settings, "Strategy Settings", "Overtake.Delta", 1) * 1000)
				, "Session.Settings.Strategy.Traffic.Considered": getConfigurationValue(settings, "Strategy Settings", "Traffic.Considered", 5) / 100
				, "Session.Settings.Pitstop.Service.Refuel": getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", 1.5)
				, "Session.Settings.Pitstop.Service.Tyres": getConfigurationValue(settings, "Strategy Settings", "Service.Tyres", 30)
				, "Session.Settings.Pitstop.Strategy.Window.Considered": getConfigurationValue(settings, "Strategy Settings", "Strategy.Window.Considered", 2)}
				
		return facts
	}
	
	updateSession(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts
		
		if knowledgeBase {
			if !IsObject(settings)
				settings := readConfiguration(settings)
			
			this.updateConfigurationValues({Settings: settings})
			
			configuration := this.Configuration
			simulatorName := this.Simulator
		
			facts := {"Session.Settings.Lap.Formation": getConfigurationValue(settings, "Session Settings", "Lap.Formation", true)
					, "Session.Settings.Lap.PostRace": getConfigurationValue(settings, "Session Settings", "Lap.PostRace", true)
					, "Session.Settings.Fuel.AvgConsumption": getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", 0)
					, "Session.Settings.Pitstop.Delta": getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta", getConfigurationValue(settings, "Session Settings", "Pitstop.Delta", 30))
					, "Session.Settings.Lap.AvgTime": getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", 0)
					, "Session.Settings.Fuel.SafetyMargin": getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin", 5)
					, "Session.Settings.Lap.Learning.Laps": getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".LearningLaps", 1)
					, "Session.Settings.Lap.History.Considered": getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
					, "Session.Settings.Lap.History.Damping": getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".HistoryLapsDamping", 0.2)
					, "Session.Settings.Standings.Extrapolation.Laps": getConfigurationValue(settings, "Strategy Settings", "Extrapolation.Laps", 2)
					, "Session.Settings.Standings.Extrapolation.Overtake.Delta": Round(getConfigurationValue(settings, "Strategy Settings", "Overtake.Delta", 1) * 1000)
					, "Session.Settings.Strategy.Traffic.Considered": getConfigurationValue(settings, "Strategy Settings", "Traffic.Considered", 5) / 100
					, "Session.Settings.Pitstop.Service.Refuel": getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", 1.5)
					, "Session.Settings.Pitstop.Service.Tyres": getConfigurationValue(settings, "Strategy Settings", "Service.Tyres", 30)
					, "Session.Settings.Pitstop.Strategy.Window.Considered": getConfigurationValue(settings, "Strategy Settings", "Strategy.Window.Considered", 2)}
			
			for key, value in facts
				knowledgeBase.setValue(key, value)
			
			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledge(knowledgeBase)
		}
	}
	
	startSession(data) {
		local facts
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		facts := this.createSession(data)
		simulatorName := this.Simulator
		
		Process Exist, Race Engineer.exe
			
		if ErrorLevel
			saveSettings := kNever
		else
			saveSettings := getConfigurationValue(this.Configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings", getConfigurationValue(configuration, "Race Engineer Shutdown", simulatorName . ".SaveSettings", kNever))
		
		this.updateConfigurationValues({LearningLaps: getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".LearningLaps", 1)
									  , SessionReportsDatabase: getConfigurationValue(this.Configuration, "Race Strategist Reports", "Database", false)
									  , SaveTelemetry: getConfigurationValue(configuration, "Race Strategist Shutdown", simulatorName . ".SaveTelemetry", kAlways)
									  , SaveRaceReport: getConfigurationValue(this.Configuration, "Race Strategist Shutdown", simulatorName . ".SaveRaceReport", false)
									  , SaveSettings: saveSettings})
		
		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
							    , BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		
		if this.Speaker {
			Process Exist, Race Engineer.exe
			
			exists := ErrorLevel
			
			this.getSpeaker().speakPhrase(exists ? "" : "Greeting")
		}
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
	}
	
	finishSession() {
		local knowledgeBase := this.KnowledgeBase
		
		if knowledgeBase {
			Process Exist, Race Engineer.exe
			
			if (!ErrorLevel && this.Speaker)
				this.getSpeaker().speakPhrase("Bye")
			
			if (knowledgeBase.getValue("Lap", 0) > this.LearningLaps) {
				this.shutdownSession("Before")
				
				if this.Listener {
					asked := true
					
					if ((((this.SaveSettings == kAsk) && (this.Session == kSessionRace)) || (this.SaveTelemetry == kAsk))
					 && ((this.SaveRaceReport == kAsk) && (this.Session == kSessionRace)))
						this.getSpeaker().speakPhrase("ConfirmSaveSettingsAndRaceReport", false, true)
					else if ((this.SaveRaceReport == kAsk) && (this.Session == kSessionRace))
						this.getSpeaker().speakPhrase("ConfirmSaveRaceReport", false, true)
					else if (((this.SaveSettings == kAsk) && (this.Session == kSessionRace)) || (this.SaveTelemetry == kAsk))
						this.getSpeaker().speakPhrase("ConfirmSaveSettings", false, true)
					else
						asked := false
				}
				else
					asked := false
						
				if asked {
					this.setContinuation(ObjBindMethod(this, "shutdownSession", "After"))
					
					callback := ObjBindMethod(this, "forceFinishSession")
					
					SetTimer %callback%, -120000
					
					return
				}
			}
			
			this.updateDynamicValues({KnowledgeBase: false})
		}
		
		this.updateDynamicValues({OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, SessionTime: false})
	}
	
	forceFinishSession() {
		if !this.SessionDataActive {
			this.updateDynamicValues({KnowledgeBase: false})
			
			this.finishSession()
		}	
	}
	
	prepareData(lapNumber, data) {
		local knowledgeBase
		
		data := base.prepareData(lapNumber, data)
		
		knowledgeBase := this.KnowledgeBase
		
		for key, value in getConfigurationSectionValues(data, "Position Data", Object())
			if ((lapNumber = 1) || (key != "Driver.Car"))
				knowledgeBase.setFact(key, value)
		
		return data
	}
	
	updateLap(lapNumber, data) {
		this.KnowledgeBase.addFact("Sector", true)
		
		return base.updateLap(lapNumber, data)
	}
	
	requestInformation(category, arguments*) {
		switch category {
			case "LapsRemaining":
				this.lapsRemainingRecognized([])
			case "Weather":
				this.weatherRecognized([])
			case "LapTimes":
				this.lapTimesRecognized([])
			case "Position":
				this.positionRecognized([])
			case "GapToFrontStandings":
				this.gapToFrontRecognized([])
			case "GapToFrontTrack":
				this.gapToFrontRecognized(["Car"])
			case "GapToFront":
				this.gapToFrontRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToBehindStandings":
				this.gapToBehindRecognized([])
			case "GapToBehindTrack":
				this.gapToBehindRecognized(["Car"])
			case "GapToBehind":
				this.gapToBehindRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToLeader":
				this.gapToLeaderRecognized([])
		}
	}
	
	recommendPitstop(lap := false) {
		local knowledgeBase := this.KnowledgeBase
		
		speaker := this.getSpeaker()
		
		if !this.hasEnoughData()
			return
				
		knowledgeBase.setFact("Pitstop.Strategy.Plan", lap ? lap : true)
		
		knowledgeBase.produce()
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		plannedLap := knowledgebase.getValue("Pitstop.Strategy.Lap", kUndefined)
		
		if (plannedLap == kUndefined)
			speaker.speakPhrase("NoPlannedPitstop")
		else if !plannedLap
			speaker.speakPhrase("NoPitstopNeeded")
		else {
			speaker.speakPhrase("PitstopLap", {lap: plannedLap})
		
			Process Exist, Race Engineer.exe
			
			if (ErrorLevel && this.Listener) {
				speaker.speakPhrase("InformEngineer", false, true)
				
				this.setContinuation(ObjBindMethod(this, "planPitstop", plannedLap))
			}
		}
	}
	
	planPitstop(plannedLap := false) {
		sendMessage()
		
		Loop 10
			Sleep 500
		
		Process Exist, Race Engineer.exe
		
		if ErrorLevel
			if plannedLap
				raiseEvent(kFileMessage, "Engineer", "planPitstop:" . plannedLap, ErrorLevel)
			else
				raiseEvent(kFileMessage, "Engineer", "planPitstop", ErrorLevel)
	}
	
	performPitstop(lapNumber := false) {
		local knowledgeBase := this.KnowledgeBase
		
		knowledgeBase.addFact("Pitstop.Lap", lapNumber ? lapNumber : knowledgeBase.getValue("Lap"))
		
		result := knowledgeBase.produce()
		
		this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(knowledgeBase)
		
		return result
	}
	
	callRecommendPitstop() {
		this.clearContinuation()
				
		this.getSpeaker().speakPhrase("Confirm")
	
		sendMessage()
		
		Loop 10
			Sleep 500
		
		this.recommendPitstop()
	}
	
	weatherChangeNotification(change, minutes) {
		local knowledgeBase := this.KnowledgeBase
		
		if this.Speaker {
			speaker := this.getSpeaker()
			
			speaker.speakPhrase(change ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
		}
	}
	
	weatherTyreChangeRecommendation(minutes, recommendedCompound) {
		local knowledgeBase := this.KnowledgeBase
		
		if (knowledgeBase.getValue("Lap.Remaining") > 3)
			if this.Speaker {
				speaker := this.getSpeaker()
				fragments := speaker.Fragments
				
				speaker.speakPhrase((recommendedCompound = "Wet") ? "WeatherRainChange" : "WeatherDryChange"
								  , {minutes: minutes, compound: fragments[recommendedCompound]})
				
				Process Exist, Race Engineer.exe
					
				if (ErrorLevel && this.Listener) {
					speaker.speakPhrase("InformEngineer", false, true)
					
					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
			}
	}
	
	shutdownSession(phase) {
		this.iSessionDataActive := true
		
		try {
			if ((this.Session == kSessionRace) && (this.SaveSettings = ((phase = "Before") ? kAlways : kAsk)))
				this.saveSessionSettings()
			
			if ((this.Session == kSessionRace) && (this.SaveRaceReport = ((phase = "Before") ? kAlways : kAsk)))
				this.saveSessionReport()
			
			if ((this.SaveTelemetry = ((phase = "After") ? kAsk : kAlways)))
				this.saveTelemetryData()
		}
		finally {
			this.iSessionDataActive := false
		}
		
		if (phase = "After") {
			if this.Speaker
				this.getSpeaker().speakPhrase("RaceReportSaved")
			
			this.updateDynamicValues({KnowledgeBase: false})
			
			this.finishSession()
		}
	}
	
	saveSessionReport() {
		local knowledgeBase := this.KnowledgeBase
		
		directory := this.SessionReportsDatabase
		
		if directory {
			simulatorCode := this.SetupDatabase.getSimulatorCode(knowledgeBase.getValue("Session.Simulator"))
			
			directory := (directory . "\" . simulatorCode . "\" . this.SessionTime)
			
			FileCreateDir %directory%
			
			data := newConfiguration()
			
			setConfigurationValue(data, "Session", "Car", knowledgeBase.getValue("Session.Car"))
			setConfigurationValue(data, "Session", "Track", knowledgeBase.getValue("Session.Track"))
			setConfigurationValue(data, "Session", "Duration", (Round((knowledgeBase.getValue("Session.Duration") / 60) / 5) * 300))
			setConfigurationValue(data, "Session", "Format", knowledgeBase.getValue("Session.Format"))
			
			driver := knowledgeBase.getValue("Driver.Car")
			carCount := knowledgeBase.getValue("Car.Count")
			
			setConfigurationValue(data, "Cars", "Count", carCount)
			setConfigurationValue(data, "Cars", "Driver", driver)
			
			Loop %carCount% {
				setConfigurationValue(data, "Cars", "Car." . A_Index . ".Nr", knowledgeBase.getValue("Car." . A_Index . ".Nr", A_Index))
				setConfigurationValue(data, "Cars", "Car." . A_Index . ".Car", knowledgeBase.getValue("Car." . A_Index . ".Car"))
			}
			
			lapCount := knowledgeBase.getValue("Lap")
			pitstops := []
			
			Loop % knowledgeBase.getValue("Pitstop.Last", 0)
				pitstops.Push(knowledgeBase.getValue("Pitstop." . A_Index . ".Lap") + 1)
			
			setConfigurationValue(data, "Laps", "Count", lapCount)
			
			Loop %lapCount% {
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".Weather", knowledgeBase.getValue("Standings.Lap." . A_Index . ".Weather"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".LapTime", knowledgeBase.getValue("Lap." . A_Index . ".Time"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".Compound", knowledgeBase.getValue("Lap." . A_Index . ".Tyre.Compound", "Dry"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".CompoundColor", knowledgeBase.getValue("Lap." . A_Index . ".Tyre.Compound.Color", "Black"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".Map", knowledgeBase.getValue("Lap." . A_Index . ".Map", "n/a"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".TC", knowledgeBase.getValue("Lap." . A_Index . ".TC", "n/a"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".ABS", knowledgeBase.getValue("Lap." . A_Index . ".ABS", "n/a"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".Consumption", knowledgeBase.getValue("Lap." . A_Index . ".Fuel.Consumption", "n/a"))
				setConfigurationValue(data, "Laps", "Lap." . A_Index . ".Pitstop", inList(pitstops, A_Index))
			
				lapNr := A_Index
				
				times := []
				positions := []
				drivers := []
				laps := []
				
				Loop %carCount% {
					carPrefix := ("Standings.Lap." . lapNr . ".Car." . A_Index)
					
					times.Push(knowledgeBase.getValue(carPrefix . ".Time", -1))
					positions.Push(knowledgeBase.getValue(carPrefix . ".Position", 0))
					laps.Push(Floor(knowledgeBase.getValue(carPrefix . ".Laps", 0)))
					
					driverForname := knowledgeBase.getValue(carPrefix . ".Driver.Forname")
					driverSurname := knowledgeBase.getValue(carPrefix . ".Driver.Surname")
					driverNickname := knowledgeBase.getValue(carPrefix . ".Driver.Nickname")
					
					drivers.Push(computeDriverName(driverForname, driverSurname, driverNickname))
				}
				
				newLine := ((lapNr > 1) ? "`n" : "")
				
				line := (newLine . values2String(";", times*))
				
				FileAppend %line%, % directory . "\Times.CSV"
				
				line := (newLine . values2String(";", positions*))
				
				FileAppend %line%, % directory . "\Positions.CSV"
				
				line := (newLine . values2String(";", laps*))
				
				FileAppend %line%, % directory . "\Laps.CSV"
				
				line := (newLine . values2String(";", drivers*))
				
				FileAppend %line%, % directory . "\Drivers.CSV"
			}
				
			writeConfiguration(directory . "\Race.data", data)
		}
	}

	saveTelemetryData() {
		local compound
		local knowledgeBase := this.KnowledgeBase
		
		if knowledgeBase {
			simulator := knowledgeBase.getValue("Session.Simulator")
			car := knowledgeBase.getValue("Session.Car")
			track := knowledgeBase.getValue("Session.Track")
			
			pitstops := []
			
			Loop % knowledgeBase.getValue("Pitstop.Last", 0)
				pitstops.Push(knowledgeBase.getValue("Pitstop." . A_Index . ".Lap") + 1)

			telemetryDB := new TelemetryDatabase(simulator, car, track)
			
			runningLap := 0
			
			Loop % knowledgeBase.getValue("Lap")
			{
				if inList(pitstops, A_Index)
					runningLap := 0
				
				runningLap += 1
				prefix := "Lap." . A_Index
				
				weather := knowledgeBase.getValue(prefix . ".Weather")
				airTemperature := knowledgeBase.getValue(prefix . ".Temperature.Air")
				trackTemperature := knowledgeBase.getValue(prefix . ".Temperature.Track")
				compound := knowledgeBase.getValue(prefix . ".Tyre.Compound")
				compoundColor := knowledgeBase.getValue(prefix . ".Tyre.Compound.Color")
				fuelConsumption := Round(knowledgeBase.getValue(prefix . ".Fuel.Consumption"), 1)
				fuelRemaining := Round(knowledgeBase.getValue(prefix . ".Fuel.Remaining"), 1)
				lapTime := Round(knowledgeBase.getValue(prefix . ".Time") / 1000, 1)
				
				map := knowledgeBase.getValue(prefix . ".Map")
				tc := knowledgeBase.getValue(prefix . ".TC")
				abs := knowledgeBase.getValue(prefix . ".ABS")
				
				telemetryDB.addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor
											 , map, tc, abs, fuelRemaining, fuelConsumption, lapTime)
				
				flPressure := Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.FL"), 1)
				frPressure := Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.FR"), 1)
				rlPressure := Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.RL"), 1)
				rrPressure := Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.RR"), 1)
				
				flTemperature := Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.FL"), 1)
				frTemperature := Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.FR"), 1)
				rlTemperature := Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.RL"), 1)
				rrTemperature := Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.RR"), 1)
				
				telemetryDB.addTyreEntry(weather, airTemperature, trackTemperature, compound, compoundColor, runningLap
									   , flPressure, frPressure, rlPressure, rrPressure, flTemperature, frTemperature, rlTemperature, rrTemperature
										, fuelRemaining, fuelConsumption, lapTime)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getTime() {
	return A_Now
}

computeDriverName(forName, surName, nickName) {
	name := ""
	
	if (forName != "")
		name .= (forName . A_Space)
	
	if (surName != "")
		name .= (surName . A_Space)
	
	if (nickName != "")
		name .= ("(" . nickName . ")")
	
	return name
}

comparePositions(c1, c2) {
	return (c1[2] < c2[2])
}

compareSequences(c1, c2) {
	c1 := c1[2]
	c2 := c2[2]
	
	return ((c1 - Floor(c1)) < (c2 - Floor(c2)))
}

updatePositions(context, futureLap) {
	local knowledgeBase := context.KnowledgeBase
	
	cars := []
	count := 0
	
	Loop % knowledgeBase.getValue("Car.Count", 0)
	{
		laps := knowledgeBase.getValue("Standings.Extrapolated." . futureLap . ".Car." . A_Index . ".Laps", kUndefined)
		
		if (laps != kUndefined) {
			cars.Push(Array(A_Index, laps))
		
			count += 1
		}
	}
	
	bubbleSort(cars, "comparePositions")
	
	Loop {
		if (A_Index > count)
			break
		
		knowledgeBase.setFact("Standings.Extrapolated." . futureLap . ".Car." . cars[A_Index][1] . ".Position", A_Index)
	}
	
	bubbleSort(cars, "compareSequences")
	
	Loop {
		if (A_Index > count)
			break
		
		knowledgeBase.setFact("Standings.Extrapolated." . futureLap . ".Car." . cars[A_Index][1] . ".Sequence", A_Index)
	}
	
	return true
}

weatherChangeNotification(context, change, minutes) {
	context.KnowledgeBase.RaceAssistant.weatherChangeNotification(change, minutes)
	
	return true
}

weatherTyreChangeRecommendation(context, minutes, recommendedCompound) {
	context.KnowledgeBase.RaceAssistant.weatherTyreChangeRecommendation(minutes, recommendedCompound)
	
	return true
}