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


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceStrategistPlugin = "Race Strategist"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategistPlugin extends RaceAssistantPlugin  {
	class RemoteRaceStrategist extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(remotePID) {
			base.__New("Strategist", remotePID)
		}
		
		recommendPitstop(arguments*) {
			this.callRemote("callRecommendPitstop", arguments*)
		}
	}

	class RaceStrategistAction extends RaceAssistantPlugin.RaceAssistantAction {
		fireAction(function, trigger) {
			if (this.Plugin.RaceAssistant && (this.Action = "PitstopRecommend"))
				this.Plugin.recommendPitstop()
			else
				base.fireAction(function, trigger)
		}
	}
	
	RaceStrategist[] {
		Get {
			return this.RaceAssistant
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)
		
		if (this.RaceAssistantName)
			SetTimer collectRaceStrategistSessionData, 10000
		else
			SetTimer updateRaceStrategistSessionState, 5000
	}
	
	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function
		
		if inList(["PitstopRecommend"], action) {
			function := controller.findFunction(actionFunction)
			
			if (function != false)
				this.registerAction(new this.RaceStrategistAction(this, function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), action))
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return base.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}
	
	createRaceAssistant(pid) {
		return new this.RemoteRaceStrategist(pid)
	}
	
	requestInformation(arguments*) {
		if (this.RaceStrategist && inList(["LapsRemaining", "Weather", "Position", "LapTimes", "GapToFront", "GapToBehind", "GapToFrontStandings", "GapToBehindStandings", "GapToFrontTrack", "GapToBehindTrack", "GapToLeader"], arguments[1])) {
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
	
	sessionActive(sessionState) {
		return ((sessionState == kSessionPractice) || (sessionState == kSessionRace))
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