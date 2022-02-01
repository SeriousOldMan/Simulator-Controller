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
	iSessionDataActive := false
	
	iSpotterPID := false
	
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
	
	__New(configuration, remoteHandler, name := false, language := "__Undefined__"
		, service := false, speaker := false, vocalics := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Spotter", remoteHandler, name, language, service, speaker, vocalics, listener, voiceServer)
	}
	
	createVoiceAssistant(name, options) {
		return new this.SpotterVoiceAssistant(this, name, options)
	}
	
	updateConfigurationValues(values) {
		base.updateConfigurationValues(values)
	}
	
	updateSessionValues(values) {
		base.updateSessionValues(values)
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
	
	alert(phrase, variables := false) {
		if (variables && !IsObject(variables)) {
			values := {}
			
			for ignore, value in string2Values(",", variables) {
				value := string2Values(":", value)
			
				values[value[1]] := value[2]
			}
			
			variables := values
		}
		
		this.getSpeaker(true).speakPhrase(phrase, variables)
	}
	
	startupSpotter() {
		code := this.SessionDatabase.getSimulatorCode(this.Simulator)
		
		exePath := (code . " SHM Spotter.exe")
		
		if FileExist(kBinariesDirectory . exePath) {
			this.shutdownSpotter()
			
			exePath := (kBinariesDirectory . exePath)
			
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
		
		Process Exist %exePath%
			
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
		
		raceEngineer := (ErrorLevel > 0)
		
		if raceEngineer
			saveSettings := kNever
		else {
			Process Exist, Race Strategist.exe
		
			raceStrategist := (ErrorLevel > 0)
		
			if raceStrategist
				saveSettings := kNever
			else
				saveSettings := getConfigurationValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings")
		}
		
		this.updateConfigurationValues({LearningLaps: getConfigurationValue(configuration, "Race Strategist Analysis", simulatorName . ".LearningLaps", 1)
									  , SaveSettings: saveSettings})
		
		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
							    , BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})
		
		this.startupSpotter()
		
		if this.Speaker
			this.getSpeaker().speakPhrase(raceEngineer ? "" : "Greeting")
		
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