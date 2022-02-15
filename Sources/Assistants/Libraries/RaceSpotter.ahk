;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Spotter                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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

class RaceSpotter extends RaceAssistant {
	iSpotterPID := false
	
	iSessionDataActive := false
	iSpotterSpeaking := false
	
	iGridPosition := false

	iAnnouncementSettings := false
	
	iLastPerformanceUpdateLap := false
	iPositionInfo := {}
	
	iRaceStartSummarized := true
	iFinalLapsAnnounced := false
	
	class SpotterVoiceAssistant extends RaceAssistant.RaceVoiceAssistant {		
		iFastSpeechSynthesizer := false
			
		getSpeaker(fast := false) {
			if fast {
				if !this.iFastSpeechSynthesizer {
					this.iFastSpeechSynthesizer := new this.LocalSpeaker(this, this.Service, this.Speaker, this.Language
																	   , this.buildFragments(this.Language), this.buildPhrases(this.Language))
				
					this.iFastSpeechSynthesizer.setVolume(this.SpeakerVolume)
					this.iFastSpeechSynthesizer.setPitch(this.SpeakerPitch)
					this.iFastSpeechSynthesizer.setRate(this.SpeakerSpeed)
				}
			
				return this.iFastSpeechSynthesizer
			}
			else
				return base.getSpeaker()
		}
	}
	
	class RaceSpotterRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			base.__New("Race Spotter", remotePID)
		}
	}
	
	SessionDataActive[] {
		Get {
			return this.iSessionDataActive
		}
	}
	
	SpotterSpeaking[] {
		Get {
			return this.iSpotterSpeaking
		}
	}
	
	AnnouncementSettings[key := false] {
		Get {
			return (key ? this.iAnnouncementSettings[key] : this.iAnnouncementSettings)
		}
	}
	
	GridPosition[] {
		Get {
			return this.iGridPosition
		}
	}
	
	PositionInfo {
		Get {
			return this.iPositionInfo
		}
	}
	
	__New(configuration, remoteHandler, name := false, language := "__Undefined__"
		, service := false, speaker := false, vocalics := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Spotter", remoteHandler, name, language, service, speaker, vocalics, listener, voiceServer)
		
		OnExit(ObjBindMethod(this, "shutdownSpotter"))
	}
	
	createVoiceAssistant(name, options) {
		return new this.SpotterVoiceAssistant(this, name, options)
	}
	
	updateConfigurationValues(values) {
		base.updateConfigurationValues(values)
		
		if values.HasKey("AnnouncementSettings")
			this.iAnnouncementSettings := values["AnnouncementSettings"]
	}
	
	updateSessionValues(values) {
		base.updateSessionValues(values)
		
		if (this.Session == kSessionFinished) {
			this.iLastPerformanceUpdateLap := false
			this.iPositionInfo := {}
			
			this.iRaceStartSummarized := false
			this.iFinalLapsAnnounced := false
		}
	}
	
	updateDynamicValues(values) {
		base.updateDynamicValues(values)
	}
	
	handleVoiceCommand(grammar, words) {
		switch grammar {
			default:
				base.handleVoiceCommand(grammar, words)
		}
	}
	
	getSpeaker(fast := false) {
		return this.VoiceAssistant.getSpeaker(fast)
	}
	
	updatePositionInfo(lastLap) {
		local knowledgeBase = this.KnowledgeBase
		
		positionInfo := this.PositionInfo
		
		driver := knowledgeBase.getValue("Driver.Car")
		driverLapTime := Round(knowledgeBase.getValue("Car." . driver . ".Time") / 1000, 1)
		position := Round(knowledgeBase.getValue("Position", 0))
		
		frontStandingsDelta := Round(Abs(knowledgeBase.getValue("Position.Standings.Front.Delta", 0)) / 1000, 1)
		
		if ((frontStandingsDelta = 0) || (position = 1))
			positionInfo.Delete("Front")
		else {
			car := knowledgeBase.getValue("Position.Standings.Front.Car")
			
			if (positionInfo.HasKey("Front") && (positionInfo["Front"].Car != car))
				positionInfo.Delete("Front")
			
			frontLapTime := Round(knowledgeBase.getValue("Car." . car . ".Time") / 1000, 1)
			
			difference := (positionInfo.HasKey("Front") ? (positionInfo["Front"].Delta - frontStandingsDelta) : false)
			
			positionInfo["Front"] := {Car: car, Delta: frontStandingsDelta, DeltaDifference: difference, LapTimeDifference: frontLapTime - driverLapTime}
		}
		
		behindStandingsDelta := Round(Abs(knowledgeBase.getValue("Position.Standings.Behind.Delta", 0)) / 1000, 1)
		
		if ((behindStandingsDelta = 0) || (position = Round(knowledgeBase.getValue("Car.Count", 0))))
			positionInfo.Delete("Behind")
		else {
			car := knowledgeBase.getValue("Position.Standings.Behind.Car")
			
			if (positionInfo.HasKey("Behind") && (positionInfo["Behind"].Car != car))
				positionInfo.Delete("Behind")
			
			behindLapTime := Round(knowledgeBase.getValue("Car." . car . ".Time") / 1000, 1)
			
			difference := (positionInfo.HasKey("Behind") ? (positionInfo["Behind"].Delta - behindStandingsDelta) : false)
			
			positionInfo["Behind"] := {Car: car, Delta: behindStandingsDelta, DeltaDifference: difference, LapTimeDifference: behindLapTime - driverLapTime}
		}
	}

	summarizeRaceStart(lastLap) {
		local knowledgeBase = this.KnowledgeBase
		
		if (this.Session == kSessionRace) {
			speaker := this.getSpeaker(true)
			driver := knowledgeBase.getValue("Driver.Car", false)
			
			if (driver && this.GridPosition) {
				currentPosition := knowledgeBase.getValue("Car." . driver . ".Position")
			
				if (currentPosition = this.GridPosition)
					speaker.speakPhrase("GoodStart")
				else if (currentPosition < this.GridPosition) {
					speaker.speakPhrase("GreatStart")
					
					speaker.speakPhrase("PositionsGained", {positions: Abs(currentPosition - this.GridPosition)})
				}
				else if (currentPosition > this.GridPosition) {
					speaker.speakPhrase("BadStart")
					
					speaker.speakPhrase("PositionsLost", {positions: Abs(currentPosition - this.GridPosition)})
					
					speaker.speakPhrase("Fight")
				}
			}
		}
	}
	
	updatePerformance(lastLap) {
		local knowledgeBase := this.KnowledgeBase
		
		speaker := this.getSpeaker(true)
		positionInfo := this.PositionInfo
		
		cheered := false
		
		if (positionInfo.HasKey("Front") && (positionInfo["Front"].DeltaDifference > 0)) {
			delta := positionInfo["Front"].Delta
			lapTimeDifference := Round(positionInfo["Behind"].LapTimeDifference, 1)
			
			speaker.speakPhrase("GainedFront", {delta: Round(delta), gained: Round(positionInfo["Front"].DeltaDifference, 1), lapTime: lapTimeDifference})
			
			if (knowledgeBase.getValue("Session.Lap.Remaining") > (delta / lapTimeDifference))
				speaker.speakPhrase("CanDoIt")
			else
				speaker.speakPhrase("CantDoIt")
			
			cheered := true
		}
		
		if (positionInfo.HasKey("Behind") && (positionInfo["Behind"].DeltaDifference > 0)) {
			speaker.speakPhrase("LostBehind", {delta: Round(positionInfo["Behind"].Delta), lost: Round(positionInfo["Behind"].DeltaDifference, 1)
											 , lapTime: Round(positionInfo["Behind"].LapTimeDifference, 1)})
			
			if !cheered
				speaker.speakPhrase("Focus")
		}
	}
	
	announceFinalLaps(lastLap) {
		local knowledgeBase = this.KnowledgeBase
		
		speaker := this.getSpeaker(true)
		position := Round(knowledgeBase.getValue("Position", 0))
		
		speaker.speakPhrase("LastLaps")
		
		if (position <= 3) {
			if (position == 1)
				speaker.speakPhrase("Leader")
			else 
				speaker.speakPhrase("Position", {position: position})
			
			speaker.speakPhrase("BringItHome")
		}
		else
			speaker.speakPhrase("Focus")
	}
	
	updateDriver() {
		local knowledgeBase = this.KnowledgeBase
		
		if (this.Speaker) {
			if !this.SpotterSpeaking {
				this.iSpotterSpeaking := true
				
				try {
					lastLap := knowledgeBase.getValue("Lap", 0)
						
					if (this.AnnouncementSettings["FinalLaps"] && !this.iFinalLapsAnnounced && (knowledgeBase.getValue("Session.Lap.Remaining") <= 3)) {
						this.iFinalLapsAnnounced := true
						
						this.announceFinalLaps(lastLap)
					}
					else if (this.AnnouncementSettings["StartSummary"] && !this.iRaceStartSummarized && (lastLap > 2)) {
						this.iRaceStartSummarized := true

						if this.AnnouncementSettings["StartSummary"]
							this.summarizeRaceStart(lastLap)
					}
					else if (lastLap > 2) {
						performanceUpdates := this.AnnouncementSettings["PerformanceUpdates"]
						
						if (performanceUpdates && (lastLap >= (this.iLastPerformanceUpdateLap + performanceUpdates))) {
							this.updatePerformance(lastLap)
						
							this.iLastPerformanceUpdateLap := lastLap
						}
					}
				}
				finally {
					this.iSpotterSpeaking := false
				}
			}
			else {
				callback := ObjBindMethod(this, "updateDriver")
			
				SetTimer %callback%, -1000
			}
		}
	}
	
	proximityAlert(type, variables := false) {
		if ((type != "Behind") || this.AnnouncementSettings["RearProximity"]) {
			if (variables && !IsObject(variables)) {
				values := {}
				
				for ignore, value in string2Values(",", variables) {
					value := string2Values(":", value)
				
					values[value[1]] := value[2]
				}
				
				variables := values
			}
			
			if (this.Speaker && !this.SpotterSpeaking) {
				this.iSpotterSpeaking := true
				
				try {
					this.getSpeaker(true).speakPhrase(type, variables)
				}
				finally {
					this.iSpotterSpeaking := false
				}
			}
		}
	}
	
	yellowFlag(type, arguments*) {
		if (this.AnnouncementSettings["YellowFlags"] && this.Speaker && !this.SpotterSpeaking) {
			this.iSpotterSpeaking := true
			
			try {
				switch type {
					case "Full":
						this.getSpeaker(true).speakPhrase("YellowFull")
					case "Sector":
						if (arguments.Length() > 1)
							this.getSpeaker(true).speakPhrase("YellowDistance", {sector: arguments[1], distance: arguments[2]})
						else
							this.getSpeaker(true).speakPhrase("YellowSector", {sector: arguments[1]})
					case "Clear":
						this.getSpeaker(true).speakPhrase("YellowClear")
					case "Ahead":
						this.getSpeaker(true).speakPhrase("YellowAhead")
				}
			}
			finally {
				this.iSpotterSpeaking := false
			}
		}
	}
	
	blueFlag() {
		if (this.AnnouncementSettings["BlueFlags"] && this.Speaker && !this.SpotterSpeaking) {
			this.iSpotterSpeaking := true
			
			try {
				delta := this.KnowledgeBase.getValue("Position.Standings.Behind.Delta", false)
				
				if (delta && (delta < 2000))
					this.getSpeaker().speakPhrase("BlueForPosition")
				else
					this.getSpeaker().speakPhrase("Blue")
			}
			finally {
				this.iSpotterSpeaking := false
			}
		}
	}
	
	pitWindow(state) {
		if (this.AnnouncementSettings["PitWindow"] && this.Speaker && !this.SpotterSpeaking) {
			this.iSpotterSpeaking := true
			
			try {
				if (state = "Open")
					this.getSpeaker().speakPhrase("PitWindowOpen")
				else if (state = "Closed")
					this.getSpeaker().speakPhrase("PitWindowClosed")
			}
			finally {
				this.iSpotterSpeaking := false
			}
		}
	}
	
	startupSpotter() {
		code := this.SessionDatabase.getSimulatorCode(this.Simulator)
		
		exePath := (kBinariesDirectory . code . " SHM Spotter.exe")
		
		if FileExist(exePath) {
			this.shutdownSpotter()
			
			Run %exePath%, %kBinariesDirectory%, Hide UseErrorLevel, spotterPID
			
			if ((ErrorLevel != "Error") && spotterPID)
				this.iSpotterPID := spotterPID
		}
	}
	
	shutdownSpotter() {
		if this.iSpotterPID {
			spotterPID := this.iSpotterPID
			
			Process Close, %spotterPID%
		}
		
		processName := (this.SessionDatabase.getSimulatorCode(this.Simulator) . " SHM Spotter.exe")
		
		Process Exist, %processName%
			
		if ErrorLevel
			Process Close, %ErrorLevel%
	}
				
	createSession(settings, data) {
		local facts := base.createSession(settings, data)
		
		simulatorName := this.SessionDatabase.getSimulatorName(facts["Session.Simulator"])
		configuration := this.Configuration
		settings := this.Settings
		
		facts["Session.Settings.Lap.Learning.Laps"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)
		facts["Session.Settings.Lap.History.Considered"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
		facts["Session.Settings.Lap.History.Damping"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".HistoryLapsDamping", 0.2)
		
		return facts
	}
	
	updateSession(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts
		
		if knowledgeBase {
			if !IsObject(settings)
				settings := readConfiguration(settings)
			
			facts := {}
			
			for key, value in facts
				knowledgeBase.setFact(key, value)
			
			base.updateSession(settings)
		}
	}
	
	prepareSession(settings, data) {
		base.prepareSession(settings, data)
		
		simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SessionDatabase.getSimulatorName(simulator)
		
		if !this.AnnouncementSettings {
			configuration := this.Configuration
			
			announcementSettings := {}
			
			for ignore, key in ["SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
							  , "StartSummary", "FinalLaps", "PitWindow"] 
				announcementSettings[key] := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . "." . key, true)
				
			announcementSettings["PerformanceUpdates"] := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . ".PerformanceUpdates", 2)
			
			this.updateConfigurationValues({AnnouncementSettings: announcementSettings})
			
		}
		
		this.iRaceStartSummarized := false
		
		driver := getConfigurationValue(data, "Position Data", "Driver.Car", false)
		
		if driver
			this.iGridPosition := getConfigurationValue(data, "Position Data", "Car." . driver . ".Position")
		
		if this.Speaker
			this.getSpeaker().speakPhrase("Greeting")
		
		callback := ObjBindMethod(this, "startupSpotter")
		
		SetTimer %callback%, -10000
	}
	
	startSession(settings, data) {
		local facts
		
		if !IsObject(settings)
			settings := readConfiguration(settings)
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		facts := this.createSession(settings, data)
		
		simulatorName := this.Simulator
		configuration := this.Configuration
		
		Process Exist, Race Engineer.exe
		
		if (ErrorLevel > 0)
			saveSettings := kNever
		else {
			Process Exist, Race Strategist.exe
		
			if (ErrorLevel > 0)
				saveSettings := kNever
			else
				saveSettings := getConfigurationValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings")
		}
		
		this.updateConfigurationValues({LearningLaps: getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)
									  , SaveSettings: saveSettings})
		
		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
							    , BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})
		
		this.iFinalLapsAnnounced := false
		this.iLastPerformanceUpdateLap := false
		
		this.startupSpotter()
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
	}
	
	finishSession(shutdown := true) {
		local knowledgeBase := this.KnowledgeBase
		
		if knowledgeBase {
			if (shutdown && (knowledgeBase.getValue("Lap", 0) > this.LearningLaps)) {
				this.shutdownSession("Before")
				
				if this.Listener {
					asked := true
					
					if ((this.SaveSettings == kAsk) && (this.Session == kSessionRace))
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
			
			this.shutdownSpotter()
			
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
		else {
			callback := ObjBindMethod(this, "forceFinishSession")
					
			SetTimer %callback%, -5000
		}
	}
	
	prepareData(lapNumber, data) {
		local knowledgeBase
		
		data := base.prepareData(lapNumber, data)
		
		knowledgeBase := this.KnowledgeBase
		
		for key, value in getConfigurationSectionValues(data, "Position Data", Object())
			knowledgeBase.setFact(key, value)
		
		return data
	}
	
	addLap(lapNumber, data) {
		result := base.addLap(lapNumber, data)
		
		if result {
			this.updatePositionInfo(lapNumber)
			
			callback := ObjBindMethod(this, "updateDriver")
			
			SetTimer %callback%, -60000
		}
	
		return result
	}
	
	updateLap(lapNumber, data) {
		; this.KnowledgeBase.addFact("Sector", true)
		
		return base.updateLap(lapNumber, data)
	}
	
	shutdownSession(phase) {
		this.iSessionDataActive := true
		
		try {
			if ((this.Session == kSessionRace) && (this.SaveSettings = ((phase = "Before") ? kAlways : kAsk)))
				this.saveSessionSettings()
		}
		finally {
			this.iSessionDataActive := false
		}
		
		if (phase = "After") {
			this.updateDynamicValues({KnowledgeBase: false})
			
			this.finishSession()
		}
	}
}