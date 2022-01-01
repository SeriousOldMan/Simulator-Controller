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
	
	__New(configuration, remoteHandler, name := false, language := "__Undefined__", service := false, speaker := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Spotter", remoteHandler, name, language, service, speaker, listener, voiceServer)
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
				
	createSession(settings, data) {
		local facts := base.createSession(settings, data)
				
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
		
		Process Exist, Race Engineer.exe
		
		raceEngineer := (ErrorLevel > 0)
		
		if raceEngineer
			saveSettings := kNever
		else
			saveSettings := getConfigurationValue(this.Configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings")
		
		this.updateConfigurationValues({SaveSettings: saveSettings})
		
		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
							    , BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})
		
		if this.Speaker
			this.getSpeaker().speakPhrase(raceEngineer ? "" : "Greeting")
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
	}
	
	addLap(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local driverForname := ""
		local driverSurname := ""
		local driverNickname := ""
		
		static lastLap := 0
		
		if (lapNumber <= lastLap)
			lastLap := 0
		else if ((lastLap == 0) && (lapNumber > 1))
			lastLap := (lapNumber - 1)
		
		if (this.Speaker && (lapNumber > 1)) {
			driverForname := knowledgeBase.getValue("Driver.Forname", "John")
			driverSurname := knowledgeBase.getValue("Driver.Surname", "Doe")
			driverNickname := knowledgeBase.getValue("Driver.Nickname", "JDO")
		}
		
		result := base.addLap(lapNumber, data)
		
		if !result
			return false
		
		if (this.Speaker && (lastLap < (lapNumber - 2)) && (computeDriverName(driverForname, driverSurname, driverNickname) != this.DriverFullName)) {
			Process Exist, Race Engineer.exe
			
			exists := ErrorLevel
			
			this.getSpeaker().speakPhrase(exists ? "" : "WelcomeBack")
		}
		
		return result
	}
	
	finishSession(shutdown := true) {
		local knowledgeBase := this.KnowledgeBase
		
		if knowledgeBase {
			Process Exist, Race Engineer.exe
			
			if (!ErrorLevel && this.Speaker)
				this.getSpeaker().speakPhrase("Bye")
			
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
		
		return data
	}
	
	updateLap(lapNumber, data) {
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