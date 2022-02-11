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

	iSessionUpdateLaps := false
	
	iLastPositionReportLap := false
	iRaceStartReported := false
	iLastLapsReported := false
	
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
	
	SessionUpdateLaps[] {
		Get {
			return this.iSessionUpdateLaps
		}
	}
	
	GridPosition[] {
		Get {
			return this.iGridPosition
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
	}
	
	updateSessionValues(values) {
		base.updateSessionValues(values)
		
		if (this.Session == kSessionFinished) {
			this.iLastPositionReportLap := false
			
			this.iRaceStartReported := false
			this.iLastLapsReported := false
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
	
	raceStartSummary(currentLap) {
		local knowledgeBase = this.KnowledgeBase
		
		if (this.Session == kSessionRace) {
			speaker := this.getSpeaker(true)
			driver := knowledgeBase.getValue("Driver.Car", false)
			
			if (driver && this.GridPosition) {
				currentPosition := knowledgeBase.getValue("Car." . driver . ".Position")
			
				if (currentPosition < this.GridPosition) {
					speaker.speak("GreatStart")
					
					speaker.speak("PositionsGained", {positions: Abs(currentPosition - this.GridPosition)})
				}
				else if (currentPosition > this.GridPosition) {
					speaker.speak("BadStart")
					
					speaker.speak("PositionsLost", {positions: Abs(currentPosition - this.GridPosition)})
					
					speaker.speak("Fight")
				}
			}
		}
	}
	
	standingsUpdate(currentLap) {
	}
	
	lastLapsAnnouncement(currentLap) {
		local knowledgeBase = this.KnowledgeBase
		
		speaker := this.getSpeaker(true)
		position := Round(knowledgeBase.getValue("Position", 0))
		
		speaker.speak("LastLaps")
		
		if (position <= 3) {
			if (position == 1)
				speaker.speak("Leader")
			else 
				speaker.speak("Position", {position: position})
			
			speaker.speak("BringItHome")
		}
		else
			speaker.speak("Focus")
	}
	
	driverUpdate() {
		local knowledgeBase = this.KnowledgeBase
		
		if (this.Speaker)
			if !this.SpotterSpeaking {
				this.iSpotterSpeaking := true
				
				try {
					currentLap := knowledgeBase.getValue("Lap", 0)
						
					if (!this.iLastLapsReported && knowledgeBase.getValue("Session.Lap.Remaining") == 2) {
						this.iLastLapsReported := true
						
						this.lastLapsAnnouncement(currentLap)
					}
					else {
						updateLaps := this.SessionUpdateLaps
						
						if (updateLaps && (currentLap > (this.iLastPositionReportLap + updateLaps))) {
							if !this.iRaceStartReported {
								this.iRaceStartReported := true
								
								this.raceStartSummary(currentLap)
							}
							else
								this.standingsUpdate(currentLap)
							
							this.iLastPositionReportLap := currentLap
						}
					}
				}
				finally {
					this.iSpotterSpeaking := false
				}
			}
			else {
				callback := ObjBindMethod(this, "driverUpdate")
			
				SetTimer %callback%, -1000
			}
		}
	}
	
	proximityAlert(type, variables := false) {
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
	
	yellowFlag(type, arguments*) {
		if (this.Speaker && !this.SpotterSpeaking)
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
		if (this.Speaker && !this.SpotterSpeaking) {
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
		if (this.Speaker && !this.SpotterSpeaking)
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
		
		this.iSessionUpdateLaps := getConfigurationValue(this.Configuration, "Race Spotter Updates", simulatorName . ".UpdateLaps", 2)
		
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
			if ((lapNumber = 1) || (key != "Driver.Car"))
				knowledgeBase.setFact(key, value)
		
		return data
	}
	
	addLap(lapNumber, data) {
		result := base.addLap(lapNumber, data)
		
		if result {
			callback := ObjBindMethod(this, "driverUpdate")
			
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