;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Plugin                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished = 0
global kSessionPaused = -1
global kSessionOther = 1
global kSessionPractice = 2
global kSessionQualification = 3
global kSessionRace = 4

global kPitstopMode = "Pitstop"
global kAssistantMode = "Assistant"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionStates = [kSessionOther, kSessionPractice, kSessionQualification, kSessionRace]
global kSessionStateNames = ["Other", "Practice", "Qualification", "Race"]

global kAssistantRaceActions = ["PitstopRecommend", "PitstopPlan", "PitstopPrepare", "StrategyCancel", "Accept", "Reject"]


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vRunningSimulator = false
global vRunningSimulation = false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;
	
class AssistantMode extends ControllerMode {
	Mode[] {
		Get {
			return kAssistantMode
		}
	}

	activate() {
		base.activate()
		
		this.updateActions(this.Plugin.SessionState)
	}
	
	updateActions(sessionState) {
		this.updateRaceAssistantActions(sessionState)
	}			
		
	updateRaceAssistantActions(sessionState) {
		if (!this.Plugin.RaceEngineer || !this.Plugin.RaceEngineer.RaceEngineer)
			sessionState := kSessionFinished
		
		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceAssistantAction)
				if inList(kAssistantRaceActions, theAction.Action) {
					if (sessionState == kSessionRace) {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setLabel(theAction.Label)
					}
					else {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setLabel(theAction.Label, "Gray")
					}
				}
				else if (theAction.Action = "InformationRequest") {
					if inList([kSessionPractice, kSessionRace], sessionState) {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setLabel(theAction.Label)
					}
					else {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setLabel(theAction.Label, "Gray")
					}
				}
	}
}

class PitstopMode extends AssistantMode {
	Mode[] {
		Get {
			return kPitstopMode
		}
	}
	
	updateActions(sessionState) {
		this.updatePitstopActions(sessionState)
	
		base.updateActions(sessionState)
	}			
	
	updatePitstopActions(sessionState) {	
		for ignore, theAction in this.Actions
			if isInstance(theAction, PitstopAction)
				if ((sessionState != kSessionFinished) && (sessionState != kSessionPaused)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label, "Gray")
				}
	}	
}

class PitstopAction extends ControllerAction {
	iPlugin := false
	iOption := false
	iSteps := 1
	
	Plugin[] {
		Get {
			return this.iPlugin
		}
	}
	
	Option[] {
		Get {
			return this.iOption
		}
	}
	
	Steps[] {
		Get {
			return this.iSteps
		}
	}
	
	__New(plugin, function, label, icon, option, steps := 1, moreArguments*) {
		this.iPlugin := plugin
		this.iOption := option
		this.iSteps := steps
		
		if (moreArguments.Length() > 0)
			Throw "Unsupported arguments (" . values2String(", ", moreArguments*) . ") detected in PitstopAction.__New"
		
		base.__New(function, label, icon)
	}
	
	fireAction(function, trigger) {
		local plugin := this.Plugin
		
		return (plugin.requirePitstopMFD() && plugin.selectPitstopOption(this.Option))
	}
}

class PitstopChangeAction extends PitstopAction {
	iDirection := false
	
	Direction[] {
		Get {
			return this.iDirection
		}
	}
	
	__New(plugin, function, label, icon, option, direction, moreArguments*) {
		this.iDirection := direction
		
		base.__New(plugin, function, label, icon, option, moreArguments*)
	}
	
	fireAction(function, trigger) {
		if base.fireAction(function, trigger) {
			this.Plugin.changePitstopOption(this.Option, this.Direction, this.Steps)
			
			this.Plugin.notifyPitstopChanged(this.Option)
		}
	}
}

class PitstopSelectAction extends PitstopChangeAction {
	__New(plugin, function, label, icon, option, moreArguments*) {
		base.__New(plugin, function, label, icon, option, "Increase", moreArguments*)
	}
}

class PitstopToggleAction extends PitstopAction {
	fireAction(function, trigger) {
		if base.fireAction(function, trigger) {
			if ((trigger == "On") || (trigger = kIncrease) || (trigger == "Push") || (trigger == "Call"))
				this.Plugin.changePitstopOption(this.Option, "Increase", this.Steps)
			else
				this.Plugin.changePitstopOption(this.Option, "Decrease", this.Steps)
			
			this.Plugin.notifyPitstopChanged(this.Option)
		}
	}
}

class SimulatorPlugin extends ControllerPlugin {
	iSimulator := false
	iSessionState := kSessionFinished
	
	Code[] {
		Get {
			return this.Plugin
		}
	}
	
	Simulator[] {
		Get {
			return this.iSimulator
		}
	}
	
	SessionState[asText := false] {
		Get {
			if asText {
				sessionState := this.iSessionState
				
				if (sessionState >= kSessionOther)
					return kSessionStateNames[sessionState]
				else
					return ((sessionState == kSessionFinished) ? "Finished" : "Paused")
			}
			else
				return this.iSessionState
		}
	}
	
	SessionStates[asText := false] {
		Get {
			return (asText ? kSessionStateNames : kSessionStates)
		}
	}
	
	__New(controller, name, simulator, configuration := false, register := true) {
		this.iSimulator := new Application(simulator, SimulatorController.Instance.Configuration)
		
		base.__New(controller, name, configuration, register)
		
		if (!this.Active && !isDebug())
			return
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("pitstopCommands", "")) {
			arguments := string2Values(A_Space, theAction)
		
			theAction := arguments[1]
			
			if (inList(kAssistantRaceActions, theAction) || (theAction = "InformationRequest"))
				this.createRaceAssistantAction(controller, arguments*)
			else
				this.createPitstopAction(controller, arguments*)
		}
	
		controller.registerPlugin(this)
	}
	
	createPitstopAction(controller, action, increaseFunction, moreArguments*) {
		local function
		
		this.getPitstopActions(actions, selectActions)
		
		if actions.HasKey(action) {
			decreaseFunction := false
			
			if (moreArguments.Length() > 0) {
				decreaseFunction := moreArguments[1]
				
				if (controller.findFunction(decreaseFunction) != false)
					moreArguments.RemoveAt(1)
				else
					decreaseFunction := false
			}
			
			function := controller.findFunction(increaseFunction)
			
			mode := this.findMode(kPitstopMode)
			
			if (mode == false)
				mode := new PitstopMode(this)
			
			if !decreaseFunction {
				if (function != false) {
					label := this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), kUndefined)
					
					if (label == kUndefined) {
						label := this.getLabel(ConfigurationItem.descriptor(action, "Dial"), action)
						icon := this.getIcon(ConfigurationItem.descriptor(action, "Dial"))
					}
					else
						icon := this.getIcon(ConfigurationItem.descriptor(action, "Toggle"))
					
					if (inList(selectActions, action))
						mode.registerAction(new PitstopSelectAction(this, function, label, icon, actions[action], moreArguments*))
					else
						mode.registerAction(new PitstopToggleAction(this, function, label, icon, actions[action], moreArguments*))
				}
				else
					this.logFunctionNotFound(increaseFunction)
			}
			else {
				if (function != false) {
					descriptor := ConfigurationItem.descriptor(action, "Increase")
					
					mode.registerAction(new PitstopChangeAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), actions[action], "Increase", moreArguments*))
				}
				else
					this.logFunctionNotFound(increaseFunction)
					
				function := controller.findFunction(decreaseFunction)
				
				if (function != false) {
					descriptor := ConfigurationItem.descriptor(action, "Decrease")
					
					mode.registerAction(new PitstopChangeAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), actions[action], "Decrease", moreArguments*))
				}
				else
					this.logFunctionNotFound(decreaseFunction)
			}
		}
		else
			logMessage(kLogWarn, translate("Action ") . action . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}
	
	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {}
		selectActions := []
	}
	
	runningSimulator() {
		return (this.Simulator.isRunning() ? this.Simulator.Application : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if ((simulator = this.Simulator.Application) && (vRunningSimulator != this)) {
			if vRunningSimulator
				vRunningSimulator.simulatorShutdown(vRunningSimulation)
			
			this.updateSessionState(kSessionFinished)
			
			vRunningSimulator := this
			vRunningSimulation := simulator
		}
	}
	
	simulatorShutdown(simulator) {
		base.simulatorShutdown(simulator)
		
		if ((simulator = this.Simulator.Application) && (vRunningSimulator == this)) {
			this.updateSessionState(kSessionFinished)
		
			vRunningSimulator := false
			vRunningSimulation := false
		}
	}
	
	updateSessionState(sessionState) {
		if ((sessionState != this.SessionState) && (sessionState != kSessionPaused)) { 
			this.iSessionState := sessionState
			
			if (sessionState == kSessionFinished)
				this.Controller.setModes()
			else
				this.Controller.setModes(this.Simulator.Application, ["Other", "Practice", "Qualification", "Race"][sessionState])
		}
		
		mode := this.findMode(kPitstopMode)
		
		if (mode && inList(this.Controller.ActiveModes, mode))
			mode.updateActions(sessionState)
		
		mode := this.findMode(kAssistantMode)
		
		if (mode && inList(this.Controller.ActiveModes, mode))
			mode.updateActions(sessionState)
	}
	
	updatePitstopOption(option, action, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption(option))
			this.changePitstopOption(option, action, steps)
	}
	
	notifyPitstopChanged(option) {
		if this.RaceEngineer
			switch option {
				case "Refuel", "Tyre Compound", "Tyre Set", "Repair Suspension", "Repair Bodywork":
					newValues := this.getPitstopOptionValues(option)
					
					if newValues
						this.RaceEngineer.pitstopOptionChanged(option, newValues*)
				case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
					newValues := this.getPitstopOptionValues("Tyre Pressures")
					
					if newValues
						this.RaceEngineer.pitstopOptionChanged("Tyre Pressures", newValues*)
			}
	}
	
	getPitstopOptionValues(option) {
		return false
	}
	
	selectPitstopOption(option) {
		Throw "Virtual method SimulatorPlugin.selectPitstopOption must be implemented in a subclass..."
	}
	
	changePitstopOption(option, action, steps := 1) {
		Throw "Virtual method SimulatorPlugin.changePitstopOption must be implemented in a subclass..."
	}
	
	openPitstopMFD(descriptor := false) {
		Throw "Virtual method SimulatorPlugin.openPitstopMFD must be implemented in a subclass..."
	}
	
	closePitstopMFD() {
		Throw "Virtual method SimulatorPlugin.closePitstopMFD must be implemented in a subclass..."
	}
	
	requirePitstopMFD() {
		return false
	}
}

class RaceAssistantAction extends ControllerAction {
	iPlugin := false
	iAction := false
	iArguments := false
		
	Plugin[] {
		Get {
			return this.iPlugin
		}
	}
	
	Action[] {
		Get {
			return this.iAction
		}
	}
	
	Arguments[] {
		Get {
			return this.iArguments
		}
	}
	
	__New(pluginOrMode, function, label, icon, action, arguments*) {
		this.iPlugin := (isInstance(pluginOrMode, ControllerMode) ? pluginOrMode.Plugin : pluginOrMode)
		this.iAction := action
		this.iArguments := arguments
		
		base.__New(function, label, icon)
	}
	
	fireAction(function, trigger) {
		local plugin := this.Plugin
		
		switch this.Action {
			case "InformationRequest":
				plugin.requestInformation(this.Arguments*)
			case "PitstopRecommend":
				plugin.recommendPitstop()
			case "StrategyCancel":
				plugin.cancelStrategy()
			case "PitstopPlan":
				plugin.planPitstop()
			case "PitstopPrepare":
				plugin.preparePitstop()
			case "Accept":
				plugin.accept()
			case "Reject":
				plugin.reject()
			default:
				Throw "Invalid action """ . this.Action . """ detected in RaceAssistantAction.fireAction...."
		}
	}
}

class RaceAssistantSimulatorPlugin extends SimulatorPlugin {
	iActionMode := kPitstopMode
	
	iRaceEngineer := false
	iRaceStrategist := false
	iRaceSpotter := false
	
	RaceEngineer[] {
		Get {
			return this.iRaceEngineer
		}
	}
	
	RaceStrategist[] {
		Get {
			return this.iRaceStrategist
		}
	}
	
	RaceSpotter[] {
		Get {
			return this.iRaceSpotter
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
	
		if (!this.Active && !isDebug())
			return
		
		this.iActionMode := kAssistantMode
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
			this.createRaceAssistantAction(controller, string2Values(A_Space, theAction)*)
	
		controller.registerPlugin(this)
	}
	
	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function
		
		if (action = "InformationRequest") {
			arguments.InsertAt(1, actionFunction)
			
			actionFunction := arguments.Pop()
		}
		
		function := controller.findFunction(actionFunction)
		
		mode := this.findMode(this.iActionMode)
		
		if (mode == false)
			mode := ((this.iActionMode = "Pitstop") ? new PitstopMode(this) : new AssistantMode(this))
		
		if (function != false) {
			if (action = "InformationRequest") {
				action := values2String("", arguments*)
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				mode.registerAction(new RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), "InformationRequest", arguments*))
			}
			else if inList(kAssistantRaceActions, action) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				mode.registerAction(new RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (simulator = this.Simulator.Application) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive()) {
				raceEngineer.startSimulation(this)
				
				this.iRaceEngineer := raceEngineer
			}
			
			raceStrategist := SimulatorController.Instance.findPlugin(kRaceStrategistPlugin)
			
			if (raceStrategist && raceStrategist.isActive()) {
				raceStrategist.startSimulation(this)
				
				this.iRaceStrategist := raceStrategist
			}
			
			if this.supportsSpotter() {
				raceSpotter := SimulatorController.Instance.findPlugin(kRaceSpotterPlugin)
				
				if (raceSpotter && raceSpotter.isActive()) {
					raceSpotter.startSimulation(this)
					
					this.iRaceSpotter := raceSpotter
				}
			}
		}
	}
	
	simulatorShutdown(simulator) {
		base.simulatorShutdown(simulator)
		
		if (simulator = this.Simulator.Application) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive()) {
				raceEngineer.stopSimulation(this)
				
				this.iRaceEngineer := false
			}
			
			raceStrategist := SimulatorController.Instance.findPlugin(kRaceStrategistPlugin)
			
			if (raceStrategist && raceStrategist.isActive()) {
				raceStrategist.stopSimulation(this)
				
				this.iRaceStrategist := false
			}
			
			if this.supportsSpotter() {
				raceSpotter := SimulatorController.Instance.findPlugin(kRaceSpotterPlugin)
				
				if (raceSpotter && raceSpotter.isActive()) {
					raceSpotter.stopSimulation(this)
					
					this.iRaceSpotter := false
				}
			}
		}
	}
	
	supportsSpotter() {
		return FileExist(kBinariesDirectory . this.Code . " SHM Spotter.exe")
	}
	
	supportsPitstop() {
		return false
	}
	
	supportsSetupImport() {
		return false
	}
	
	requestInformation(arguments*) {
		if (this.RaceStrategist && this.RaceStrategist.requestInformation(arguments*))
			return
		else if (this.RaceEngineer && this.RaceStrategist.requestInformation(arguments*))
			this.RaceEngineer.requestInformation(arguments*)
		else if this.RaceSpotter
			this.RaceSpotter.requestInformation(arguments*)
	}
	
	accept() {
		if this.RaceEngineer
			this.RaceEngineer.accept()
		else if this.RaceStrategist
			this.RaceStrategist.accept()
	}
	
	reject() {
		if this.RaceEngineer
			this.RaceEngineer.reject()
		else if this.RaceStrategist
			this.RaceStrategist.reject()
	}
	
	recommendPitstop() {
		if this.RaceStrategist
			this.RaceStrategist.recommendPitstop()
	}
	
	cancelStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.cancelStrategy()
	}
	
	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}
	
	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}
	
	pitstopPlanned(pitstopNumber, plannedLap := false) {
	}
	
	pitstopPrepared(pitstopNumber) {
	}
	
	pitstopFinished(pitstopNumber) {
	}
	
	startPitstopSetup(pitstopNumber) {
	}

	finishPitstopSetup(pitstopNumber) {
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
	}
	
	updatePositionsData(data) {
	}
	
	updateSessionData(data) {
	}
	
	restoreSessionState(sessionSettings, sessionState) {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getCurrentSimulatorPlugin(option := false) {
	if vRunningSimulator {
		if option {
			actions := false
			ignore := false
			
			vRunningSimulator.getPitstopActions(actions, ignore)
			
			for ignore, candidate in actions
				if (candidate = option)
					return vRunningSimulator
				
			return false
		}
		else
			return vRunningSimulator
	}
	else
		return false
}


;;;-------------------------------------------------------------------------;;;
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

openPitstopMFD(descriptor := false) {
	local plugin := getCurrentSimulatorPlugin()
	
	if plugin {
		protectionOn()
		
		try {
			if descriptor
				plugin.openPitstopMFD(descriptor)
			else
				plugin.openPitstopMFD()
		}
		finally {
			protectionOff()
		}
	}
}

closePitstopMFD() {
	local plugin := getCurrentSimulatorPlugin()
	
	if plugin {
		protectionOn()
		
		try {
			plugin.closePitstopMFD()
		}
		finally {
			protectionOff()
		}
	}
}

changePitstopStrategy(selection, steps := 1) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported strategy selection """) . selection . translate(""" detected in changePitstopStrategy - please check the configuration"))
	
	changePitstopOption("Strategy", selection, steps)
}

changePitstopFuelAmount(direction, litres := 5) {
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported fuel amount """) . direction . translate(""" detected in changePitstopFuelAmount - please check the configuration"))
	
	changePitstopOption("Refuel", direction, litres)
}

changePitstopTyreCompound(selection) {
	if !inList(["Next", "Previous", "Increase", "Decrease"], selection)
		logMessage(kLogWarn, translate("Unsupported tyre compound selection """) . selection . translate(""" detected in changePitstopTyreCompound - please check the configuration"))
	
	changePitstopOption("Tyre Compound", selection)
}

changePitstopTyreSet(selection, steps := 1) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported tyre set selection """) . selection . translate(""" detected in changePitstopTyreSet - please check the configuration"))
	
	changePitstopOption("Tyre Set", selection, steps)
}

changePitstopTyrePressure(tyre, direction, increments := 1) {
	if !inList(["All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"], tyre)
		logMessage(kLogWarn, translate("Unsupported tyre position """) . tyre . translate(""" detected in changePitstopTyrePressure - please check the configuration"))
		
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported pressure change """) . direction . translate(""" detected in changePitstopTyrePressure - please check the configuration"))
	
	changePitstopOption(tyre, direction, increments)
}

changePitstopBrakeType(brake, selection) {
	if !inList(["Front Brake", "Rear Brake"], brake)
		logMessage(kLogWarn, translate("Unsupported brake unit """) . brake . translate(""" detected in changePitstopBrakeType - please check the configuration"))
	
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported brake selection """) . selection . translate(""" detected in changePitstopBrakeType - please check the configuration"))
	
	changePitstopOption(brake, selection)
}

changePitstopDriver(selection) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported driver selection """) . selection . translate(""" detected in changePitstopDriver - please check the configuration"))
	
	changePitstopOption("Driver", selection)
}

changePitstopOption(option, selection := "Next", increments := 1) {
	local plugin
	
	if (selection = "Next")
		selection := "Increase"
	else if (selection = "Previous")
		selection := "Decrease"
	else if !inList(["Increase", "Decrease"], selection)
		logMessage(kLogWarn, translate("Unsupported option selection """) . selection . translate(""" detected in changePitstopOption - please check the configuration"))
	
	plugin := getCurrentSimulatorPlugin(option)
	
	if plugin {
		protectionOn()
	
		try {
			plugin.updatePitstopOption(option, selection, increments)
		}
		finally {
			protectionOff()
		}
	}
}