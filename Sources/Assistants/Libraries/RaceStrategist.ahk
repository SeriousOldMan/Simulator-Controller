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


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategist extends RaceAssistant {
	iEnoughData := false
	
	iOverallTime := 0
	iLastFuelAmount := 0
	iInitialFuelAmount := 0
	iAvgFuelConsumption := 0
	
	EnoughData[] {
		Get {
			return this.iEnoughData
		}
	}
	
	OverallTime[] {
		Get {
			return this.iOverallTime
		}
	}
	
	InitialFuelAmount[] {
		Get {
			return this.iInitialFuelAmount
		}
	}
	
	LastFuelAmount[] {
		Get {
			return this.iLastFuelAmount
		}
	}
	
	AvgFuelConsumption[] {
		Get {
			return this.iAvgFuelConsumption
		}
	}
	
	__New(configuration, strategistSettings, name := false, language := "__Undefined__", speaker := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Strategist", strategistSettings, name, language, speaker, listener, voiceServer)
	}
	
	updateSessionValues(values) {
		base.updateSessionValues(values)
	}
	
	updateDynamicValues(values) {
		base.updateDynamicValues(values)
		
		if values.HasKey("OverallTime")
			this.iOverallTime := values["OverallTime"]
		
		if values.HasKey("LastFuelAmount")
			this.iLastFuelAmount := values["LastFuelAmount"]
		
		if values.HasKey("InitialFuelAmount")
			this.iInitialFuelAmount := values["InitialFuelAmount"]
		
		if values.HasKey("AvgFuelConsumption")
			this.iAvgFuelConsumption := values["AvgFuelConsumption"]
		
		if values.HasKey("EnoughData")
			this.iEnoughData := values["EnoughData"]
	}
	
	handleVoiceCommand(grammar, words) {
		switch grammar {
			case "LapsRemaining":
				this.lapInfoRecognized(words)
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
				this.lapTimesInfoRecognized(words)
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
	
	accept() {
		this.phraseRecognized("Yes", ["Yes"])
	}
	
	reject() {
		this.phraseRecognized("No", ["No"])
	}
	
	lapInfoRecognized(words) {
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
		
		speaker.speakPhrase("TrackGapToFront", {delta: Format("{:.1f}", Abs(Round(knowledgeBase.getValue("Position.Track.Front.Delta", 0) / 1000, 1)))})
		
		lap := knowledgeBase.getValue("Lap")
		driverLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
		otherLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Front.Car") . ".Laps"))
		
		if (driverLap < otherLap)
		  speaker.speakPhrase("NotTheSameLap")
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
		
		speaker.speakPhrase("TrackGapToBehind", {delta: Format("{:.1f}", Abs(Round(knowledgeBase.getValue("Position.Track.Behind.Delta", 0) / 1000, 1)))})
		
		lap := knowledgeBase.getValue("Lap")
		driverLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
		otherLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Behind.Car") . ".Laps"))
		
		if (driverLap > (otherLap + 1))
		  speaker.speakPhrase("NotTheSameLap")
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
	
	lapTimesInfoRecognized(words) {
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
	
	recommendPitstop(lap := false) {
		local knowledgeBase := this.KnowledgeBase
		
		speaker := this.getSpeaker()
		
		if false && !this.hasEnoughData()
			return
				
		knowledgeBase.setFact("Pitstop.Strategy.Plan", lap ? lap : true)
		
		knowledgeBase.produce()
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		plannedLap := knowledgebase.getValue("Pitstop.Strategy.Lap", false)
		
		if !plannedLap
			speaker.speakPhrase("NoPlannedPitstop")
		else {
			speaker.speakPhrase("PitstopLap", {lap: plannedLap})
		
			Process Exist, Race Engineer.exe
			
			if (ErrorLevel && this.Listener) {
				speaker.speakPhrase("InformEngineer", false, true)
				
				this.setContinuation(ObjBindMethod(this, "planPitstop", plannedLap))
			}
		}
	}
	
	planPitstop(plannedLap) {
		sendMessage()
		
		Loop 10
			Sleep 500
		
		Process Exist, Race Engineer.exe
		
		if ErrorLevel
			raiseEvent(kFileMessage, "Engineer", "planPitstop:" . plannedLap, ErrorLevel)
	}
	
	createSession(data) {
		local facts
		
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
		
		this.updateSessionValues({Simulator: simulatorName, Session: session
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
				, "Session.Settings.Lap.History.Considered": getConfigurationValue(this.Configuration, "Race Strategist Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
				, "Session.Settings.Lap.History.Damping": getConfigurationValue(this.Configuration, "Race Strategist Analysis", simulatorName . ".HistoryLapsDamping", 0.2)
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
			
			simulatorName := this.Simulator
		
			facts := {"Session.Settings.Lap.Formation": getConfigurationValue(settings, "Session Settings", "Lap.Formation", true)
					, "Session.Settings.Lap.PostRace": getConfigurationValue(settings, "Session Settings", "Lap.PostRace", true)
					, "Session.Settings.Fuel.AvgConsumption": getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", 0)
					, "Session.Settings.Pitstop.Delta": getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta", getConfigurationValue(settings, "Session Settings", "Pitstop.Delta", 30))
					, "Session.Settings.Lap.AvgTime": getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", 0)
					, "Session.Settings.Fuel.SafetyMargin": getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin", 5)
					, "Session.Settings.Lap.History.Considered": getConfigurationValue(this.Configuration, "Race Strategist Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
					, "Session.Settings.Lap.History.Damping": getConfigurationValue(this.Configuration, "Race Strategist Analysis", simulatorName . ".HistoryLapsDamping", 0.2)
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
		if !IsObject(data)
			data := readConfiguration(data)
		
		simulatorName := this.Simulator
		
		this.updateConfigurationValues({})
		
		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(this.createSession(data))
							   , OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		
		if this.Speaker
			this.getSpeaker().speak("")
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
	}
	
	finishSession() {
		this.updateDynamicValues({KnowledgeBase: false, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		
		this.updateSessionValues({Simulator: "", Session: kSessionFinished})
	}
	
	addLap(lapNumber, data) {
		local knowledgeBase
		
		static baseLap := false
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		if !this.KnowledgeBase
			this.startSession(data)
		
		knowledgeBase := this.KnowledgeBase
		
		if (lapNumber == 1)
			knowledgeBase.addFact("Lap", 1)
		else
			knowledgeBase.setValue("Lap", lapNumber)
			
		if !this.InitialFuelAmount
			baseLap := lapNumber
		
		for key, value in getConfigurationSectionValues(data, "Position Data", Object())
			knowledgeBase.setFact(key, value)
		
		this.updateDynamicValues({EnoughData: (lapNumber > (baseLap + (this.LearningLaps - 1)))})
		
		knowledgeBase.setFact("Session.Time.Remaining", getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0))
		knowledgeBase.setFact("Session.Lap.Remaining", getConfigurationValue(data, "Session Data", "SessionLapsRemaining", 0))
		
		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JD")
		
		this.updateSessionValues({Driver: driverForname})
			
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Forname", driverForname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Surname", driverSurname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Nickname", driverNickname)
		
		knowledgeBase.setFact("Driver.Forname", driverForname)
		knowledgeBase.setFact("Driver.Surname", driverSurname)
		knowledgeBase.setFact("Driver.Nickname", driverNickname)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Compound", getConfigurationValue(data, "Car Data", "TyreCompound", "Dry"))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Compound.Color", getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black"))
		
		timeRemaining := getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0)
		
		knowledgeBase.setFact("Driver.Time.Remaining", getConfigurationValue(data, "Stint Data", "DriverTimeRemaining", timeRemaining))
		knowledgeBase.setFact("Driver.Time.Stint.Remaining", getConfigurationValue(data, "Stint Data", "StintTimeRemaining", timeRemaining))
		
		airTemperature := Round(getConfigurationValue(data, "Weather Data", "Temperature", 0))
		trackTemperature := Round(getConfigurationValue(data, "Track Data", "Temperature", 0))
		
		if (airTemperature = 0)
			airTemperature := Round(getConfigurationValue(data, "Car Data", "AirTemperature", 0))
		
		if (trackTemperature = 0)
			trackTemperature := Round(getConfigurationValue(data, "Car Data", "RoadTemperature", 0))
		
		weatherNow := getConfigurationValue(data, "Weather Data", "Weather", "Dry")
		weather10Min := getConfigurationValue(data, "Weather Data", "Weather10Min", "Dry")
		weather30Min := getConfigurationValue(data, "Weather Data", "Weather30Min", "Dry")
		
		knowledgeBase.setFact("Weather.Temperature.Air", airTemperature)
		knowledgeBase.setFact("Weather.Temperature.Track", trackTemperature)
		knowledgeBase.setFact("Weather.Weather.Now", weatherNow)
		knowledgeBase.setFact("Weather.Weather.10Min", weather10Min)
		knowledgeBase.setFact("Weather.Weather.30Min", weather30Min)
		
		lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
		
		if ((lapNumber <= 2) && knowledgeBase.getValue("Session.Settings.Lap.Time.Adjust", false)) {
			settingsLapTime := (getConfigurationValue(this.Settings, "Session Settings", "Lap.AvgTime", lapTime / 1000) * 1000)
			
			if ((lapTime / settingsLapTime) > 2)
				lapTime := settingsLapTime
		}
		
		if (this.iLapTime = 0)
			this.iLapTime := lapTime
		else
			this.iLapTime := Min(this.iLapTime, lapTime)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time", lapTime)
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.Start", this.OverallTime)
		
		overallTime := (this.OverallTime + lapTime)
		
		this.updateDynamicValues({OverallTime: overallTime})
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.End", overallTime)
		
		fuelRemaining := getConfigurationValue(data, "Car Data", "FuelRemaining", 0)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Remaining", Round(fuelRemaining, 2))
		
		if (lapNumber == 1) {
			this.updateDynamicValues({LastFuelAmount: fuelRemaining, InitialFuelAmount: fuelRemaining, AvgFuelConsumption: 0})
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", 0)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", 0)
		}
		else if (!this.InitialFuelAmount || (fuelRemaining > this.LastFuelAmount)) {
			; This is the case after a pitstop
			this.updateDynamicValues({LastFuelAmount: fuelRemaining, InitialFuelAmount: fuelRemaining, AvgFuelConsumption: 0})
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Fuel.AvgConsumption", 0))
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Fuel.Consumption", 0))
		}
		else {
			avgFuelConsumption := Round((this.InitialFuelAmount - fuelRemaining) / (lapNumber - baseLap), 2)
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", avgFuelConsumption)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", Round(this.LastFuelAmount - fuelRemaining, 2))
			
			this.updateDynamicValues({LastFuelAmount: fuelRemaining, AvgFuelConsumption: avgFuelConsumption})
		}
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Weather", weatherNow)
		knowledgeBase.addFact("Lap." . lapNumber . ".Grip", getConfigurationValue(data, "Track Data", "Grip", "Green"))
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Air", airTemperature)
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Track", trackTemperature)
		
		result := knowledgeBase.produce()
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		return result
	}
	
	updateLap(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local fact
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		for key, value in getConfigurationSectionValues(data, "Position Data", Object())
			knowledgeBase.setFact(key, value)
	
		knowledgeBase.addFact("Sector", true)
		
		result := knowledgeBase.produce()
			
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		return result
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
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

comparePositions(c1, c2) {
	return !(c1[2] > c2[2])
}

compareSequences(c1, c2) {
	c1 := (c1 - Floor(c1))
	c2 := (c2 - Floor(c2))
	
	return !(c1 > c2)
}

updatePositions(context, futureLap) {
	local knowledgeBase := context.KnowledgeBase
	
	cars := []
	count := 0
	
	Loop {
		laps := knowledgeBase.getValue("Standings.Extrapolated." . futureLap . ".Car." . A_Index . ".Laps", kUndefined)
		
		if (laps == kUndefined)
			break
		else
			cars.Push(Array(A_Index, laps))
		
		count += 1
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