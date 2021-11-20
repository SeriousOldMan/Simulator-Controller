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
			base.__New("Race Strategist", remotePID)
		}
		
		recommendPitstop(arguments*) {
			this.callRemote("callRecommendPitstop", arguments*)
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