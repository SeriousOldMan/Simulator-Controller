;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Plugin                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished := 0
global kSessionPaused := -1
global kSessionOther := 1
global kSessionPractice := 2
global kSessionQualification := 3
global kSessionRace := 4

global kPitstopMode := "Pitstop"
global kAssistantMode := "Assistant"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessions := [kSessionOther, kSessionPractice, kSessionQualification, kSessionRace]
global kSessionNames := ["Other", "Practice", "Qualification", "Race"]

global kAssistantAnswerActions := ["Accept", "Reject"]
global kAssistantRaceActions := ["PitstopPlan", "DriverSwapPlan", "PitstopPrepare", "PitstopRecommend", "StrategyRecommend", "StrategyCancel"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class AssistantMode extends ControllerMode {
	Mode {
		Get {
			return kAssistantMode
		}
	}

	activate() {
		super.activate()

		this.updateActions(this.Plugin.Session)
	}

	updateActions(session) {
		this.updateRaceAssistantActions(session)
	}

	updateRaceAssistantActions(session) {
		local ignore, theAction

		if (!this.Plugin.RaceEngineer || !this.Plugin.RaceEngineer.RaceEngineer)
			session := kSessionFinished

		for ignore, theAction in this.Actions
			if (isInstance(theAction, RaceAssistantAction) && inList(this.Controller.ActiveModes, this))
				if inList(kAssistantAnswerActions, theAction.Action) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else if inList([kSessionPractice, kSessionRace], session) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label, "Gray")
				}
	}
}

class PitstopMode extends AssistantMode {
	Mode {
		Get {
			return kPitstopMode
		}
	}

	updateActions(session) {
		this.updatePitstopActions(session)

		super.updateActions(session)
	}

	updatePitstopActions(session) {
		local ignore, theAction

		for ignore, theAction in this.Actions
			if (isInstance(theAction, PitstopAction) && inList(this.Controller.ActiveModes, this))
				if ((session != kSessionFinished) && (session != kSessionPaused)) {
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

	Plugin {
		Get {
			return this.iPlugin
		}
	}

	Option {
		Get {
			return this.iOption
		}
	}

	Steps {
		Get {
			return this.iSteps
		}
	}

	__New(plugin, function, label, icon, option, steps := 1, moreArguments*) {
		this.iPlugin := plugin
		this.iOption := option
		this.iSteps := steps

		if (moreArguments.Length > 0)
			throw "Unsupported arguments (" . values2String(", ", moreArguments*) . ") detected in PitstopAction.__New"

		super.__New(function, label, icon)
	}

	fireAction(function, trigger) {
		local plugin := this.Plugin

		return (plugin.requirePitstopMFD() && plugin.selectPitstopOption(this.Option))
	}
}

class PitstopChangeAction extends PitstopAction {
	iDirection := false

	Direction {
		Get {
			return this.iDirection
		}
	}

	__New(plugin, function, label, icon, option, direction, moreArguments*) {
		this.iDirection := direction

		super.__New(plugin, function, label, icon, option, moreArguments*)
	}

	fireAction(function, trigger) {
		if super.fireAction(function, trigger) {
			this.Plugin.changePitstopOption(this.Option, this.Direction, this.Steps)

			this.Plugin.notifyPitstopChanged(this.Option)
		}
	}
}

class PitstopSelectAction extends PitstopChangeAction {
	__New(plugin, function, label, icon, option, moreArguments*) {
		super.__New(plugin, function, label, icon, option, "Increase", moreArguments*)
	}
}

class PitstopToggleAction extends PitstopAction {
	fireAction(function, trigger) {
		if super.fireAction(function, trigger) {
			if ((trigger == "On") || (trigger = kIncrease) || (trigger == "Push") || (trigger == "Call"))
				this.Plugin.changePitstopOption(this.Option, "Increase", this.Steps)
			else
				this.Plugin.changePitstopOption(this.Option, "Decrease", this.Steps)

			this.Plugin.notifyPitstopChanged(this.Option)
		}
	}
}

class SimulatorPlugin extends ControllerPlugin {
	static sActiveSimulator := false
	static sActiveimulation := false

	iCommandMode := "Event"
	iCommandDelay := kUndefined

	iSimulator := false
	iSession := kSessionFinished

	iCar := false
	iTrack := false

	iTrackAutomation := kUndefined

	ActiveSimulator {
		Get {
			return SimulatorPlugin.sActiveSimulator
		}
	}

	ActiveSimulation {
		Get {
			return SimulatorPlugin.sActiveSimulation
		}
	}

	Code {
		Get {
			return this.Plugin
		}
	}

	CommandMode {
		Get {
			return this.iCommandMode
		}

		Set {
			return (this.iCommandMode := value)
		}
	}

	CommandDelay {
		Get {
			local simulator, car, track, settings, default

			if (this.iCommandDelay = kUndefined) {
				simulator := this.Simulator[true]
				car := (this.Car ? this.Car : "*")
				track := (this.Track ? this.Track : "*")

				settings := SettingsDatabase().loadSettings(simulator, car, track, "*")

				default := getMultiMapValue(settings, "Simulator." . simulator, "Pitstop.KeyDelay", 30)

				this.iCommandDelay := getMultiMapValue(settings, "Simulator." . simulator, "Command.KeyDelay", default)
			}

			return this.iCommandDelay
		}

		Set {
			return (this.iCommandDelay := value)
		}
	}

	Simulator[name := false] {
		Get {
			return (name ? this.iSimulator.Application : this.iSimulator)
		}
	}

	Car {
		Get {
			return this.iCar
		}

		Set {
			if (value != this.iCar)
				this.resetTrackAutomation()

			this.iCommandDelay := kUndefined

			return (this.iCar := value)
		}
	}

	Track {
		Get {
			return this.iTrack
		}

		Set {
			if (value != this.iTrack)
				this.resetTrackAutomation()

			this.iCommandDelay := kUndefined

			return (this.iTrack := value)
		}
	}

	TrackAutomation {
		Get {
			local simulator, car, track

			if (this.iTrackAutomation == kUndefined) {
				simulator := this.Simulator[true]
				car := this.Car
				track := this.Track

				this.iTrackAutomation := SessionDatabase().getTrackAutomation(simulator, car, track)
			}

			return this.iTrackAutomation
		}

		Set {
			return (this.iTrackAutomation := value)
		}
	}

	Session[asText := false] {
		Get {
			local session

			if asText {
				session := this.iSession

				if (session >= kSessionOther)
					return kSessionNames[session]
				else
					return ((session == kSessionFinished) ? "Finished" : "Paused")
			}
			else
				return this.iSession
		}
	}

	Sessions[asText := false] {
		Get {
			return (asText ? kSessionNames : kSessions)
		}
	}

	__New(controller, name, simulator, configuration := false, register := true) {
		local ignore, theAction, arguments

		this.iSimulator := Application(simulator, SimulatorController.Instance.Configuration)

		super.__New(controller, name, configuration, register)

		if (this.Active || isDebug()) {
			this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")

			for ignore, theAction in string2Values(",", this.getArgumentValue("pitstopCommands", "")) {
				arguments := string2Values(A_Space, theAction)

				theAction := arguments[1]

				if (inList(kAssistantAnswerActions, theAction) || inList(kAssistantRaceActions, theAction) || (theAction = "InformationRequest"))
					this.createRaceAssistantAction(controller, arguments*)
				else
					this.createPitstopAction(controller, arguments*)
			}

			controller.registerPlugin(this)
		}
	}

	createPitstopAction(controller, action, increaseFunction, moreArguments*) {
		local function, decreaseFunction, mode, label, icon, actions, selectActions, descriptor

		this.getPitstopActions(&actions, &selectActions)

		if actions.Has(action) {
			decreaseFunction := false

			if (moreArguments.Length > 0) {
				decreaseFunction := moreArguments[1]

				if (controller.findFunction(decreaseFunction) != false)
					moreArguments.RemoveAt(1)
				else
					decreaseFunction := false
			}

			function := controller.findFunction(increaseFunction)
			mode := this.findMode(kPitstopMode)

			if (mode == false)
				mode := PitstopMode(this)

			if !decreaseFunction {
				if (function != false) {
					label := this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), kUndefined)

					if (label == kUndefined) {
						label := this.getLabel(ConfigurationItem.descriptor(action, "Dial"), kUndefined)

						if (label == kUndefined) {
							label := this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action)
							icon := this.getIcon(ConfigurationItem.descriptor(action, "Activate"))
						}
						else
							icon := this.getIcon(ConfigurationItem.descriptor(action, "Dial"))
					}
					else
						icon := this.getIcon(ConfigurationItem.descriptor(action, "Toggle"))

					if (inList(selectActions, action))
						mode.registerAction(PitstopSelectAction(this, function, label, icon, actions[action], moreArguments*))
					else
						mode.registerAction(PitstopToggleAction(this, function, label, icon, actions[action], moreArguments*))
				}
				else
					this.logFunctionNotFound(increaseFunction)
			}
			else {
				if (function != false) {
					descriptor := ConfigurationItem.descriptor(action, "Increase")

					mode.registerAction(PitstopChangeAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), actions[action], "Increase", moreArguments*))
				}
				else
					this.logFunctionNotFound(increaseFunction)

				function := controller.findFunction(decreaseFunction)

				if (function != false) {
					descriptor := ConfigurationItem.descriptor(action, "Decrease")

					mode.registerAction(PitstopChangeAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), actions[action], "Decrease", moreArguments*))
				}
				else
					this.logFunctionNotFound(decreaseFunction)
			}
		}
		else
			logMessage(kLogWarn, translate("Action ") . action . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := Map()
		allActions.CaseSense := false

		selectActions := []
	}

	writePluginState(configuration) {
		local simulator := this.runningSimulator()
		local sessionDB, car, track

		if this.Active {
			setMultiMapValue(configuration, this.Plugin, "State", simulator ? "Active" : "Passive")

			if simulator {
				if (this.Car && this.Track) {
					setMultiMapValue(configuration, "Simulation", "State", "Active")

					setMultiMapValue(configuration, "Simulation", "Session", this.Session[true])

					sessionDB := SessionDatabase()

					car := sessionDB.getCarName(simulator, this.Car)
					track := sessionDB.getTrackName(simulator, this.Track)

					setMultiMapValue(configuration, "Simulation", "Simulator", simulator)
					setMultiMapValue(configuration, "Simulation", "Car", car)
					setMultiMapValue(configuration, "Simulation", "Track", track)

					setMultiMapValue(configuration, this.Plugin, "Information"
								   , values2String("; ", translate("Simulator: ") . simulator
								   , translate("Car: ") . car
								   , translate("Track: ") . track))
				}
				else
					setMultiMapValue(configuration, "Simulation", "State", "Passive")
			}
		}
		else
			super.writePluginState(configuration)
	}

	activateWindow() {
		local window := this.Simulator.WindowTitle

		if !WinExist(window)
			if isDebug()
				showMessage(this.Simulator[true] . " not found...")

		if !WinActive(window)
			WinActivate(window)
	}

	sendCommand(command) {
		local delay

		try {
			switch this.CommandMode {
				case "Event":
					SendEvent(command)
				case "Input":
					SendInput(command)
				case "Play":
					SendPlay(command)
				case "Raw":
					Send("{Raw}" . command)
				default:
					Send(command)
			}
		}
		catch Any as exception {
			logMessage(kLogWarn, substituteVariables(translate("Cannot send command (%command%) - please check the configuration"), {command: command}))
		}

		delay := this.CommandDelay

		if delay
			Sleep(delay)
	}

	runningSimulator() {
		return (this.Simulator.isRunning() ? this.Simulator.Application : false)
	}

	simulatorStartup(simulator) {
		super.simulatorStartup(simulator)

		if ((simulator = this.Simulator.Application) && (SimulatorPlugin.ActiveSimulator != this)) {
			if SimulatorPlugin.ActiveSimulator
				SimulatorPlugin.ActiveSimulator.simulatorShutdown(SimulatorPlugin.ActiveSimulation)

			this.updateSession(kSessionFinished)

			SimulatorPlugin.sActiveSimulator := this
			SimulatorPlugin.sActiveSimulation := simulator
		}
	}

	simulatorShutdown(simulator) {
		super.simulatorShutdown(simulator)

		if ((simulator = this.Simulator.Application) && (SimulatorPlugin.ActiveSimulator == this)) {
			this.updateSession(kSessionFinished)

			SimulatorPlugin.sActiveSimulator := false
			SimulatorPlugin.sActiveSimulation := false
		}
	}

	updateSession(session) {
		local mode

		if ((session != this.Session) && (session != kSessionPaused)) {
			this.iSession := session

			if (session == kSessionFinished) {
				this.Car := false
				this.Track := false

				this.Controller.setModes()
			}
			else
				this.Controller.setModes(this.Simulator.Application, ["Other", "Practice", "Qualification", "Race"][session])
		}

		mode := this.findMode(kPitstopMode)

		if (mode && inList(this.Controller.ActiveModes, mode))
			mode.updateActions(session)

		mode := this.findMode(kAssistantMode)

		if (mode && inList(this.Controller.ActiveModes, mode))
			mode.updateActions(session)
	}

	updatePitstopOption(option, action, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption(option))
			this.changePitstopOption(option, action, steps)
	}

	notifyPitstopChanged(option) {
		local newValues

		if this.RaceEngineer
			switch option {
				case "Refuel", "Tyre Compound", "Tyre Set", "Repair Suspension", "Repair Bodywork", "Repair Engine":
					newValues := this.getPitstopOptionValues(option)

					if newValues
						this.RaceEngineer.pitstopOptionChanged(option, newValues*)
				case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
					newValues := this.getPitstopOptionValues("Tyre Pressures")

					if newValues
						this.RaceEngineer.pitstopOptionChanged("Tyre Pressures", newValues*)
			}
	}

	getPitstopAllOptionValues() {
		local options := Map()

		options.CaseSense := false

		options["Refuel"] := this.getPitstopOptionValues("Refuel")
		options["Tyre Compound"] := this.getPitstopOptionValues("Tyre Compound")
		options["Tyre Set"] := this.getPitstopOptionValues("Tyre Set")
		options["Tyre Pressures"] := this.getPitstopOptionValues("Tyre Pressures")
		options["Repair Suspension"] := this.getPitstopOptionValues("Repair Suspension")
		options["Repair Bodywork"] := this.getPitstopOptionValues("Repair Bodywork")
		options["Repair Engine"] := this.getPitstopOptionValues("Repair Engine")

		return options
	}

	getPitstopOptionValues(option) {
		return false
	}

	selectPitstopOption(option) {
		throw "Virtual method SimulatorPlugin.selectPitstopOption must be implemented in a subclass..."
	}

	changePitstopOption(option, action, steps := 1) {
		throw "Virtual method SimulatorPlugin.changePitstopOption must be implemented in a subclass..."
	}

	openPitstopMFD(descriptor := false) {
		throw "Virtual method SimulatorPlugin.openPitstopMFD must be implemented in a subclass..."
	}

	resetPitstopMFD(descriptor := false) {
	}

	closePitstopMFD() {
		throw "Virtual method SimulatorPlugin.closePitstopMFD must be implemented in a subclass..."
	}

	requirePitstopMFD() {
		return false
	}
}

class RaceAssistantAction extends ControllerAction {
	iPlugin := false
	iAction := false
	iArguments := false

	Plugin {
		Get {
			return this.iPlugin
		}
	}

	Action {
		Get {
			return this.iAction
		}
	}

	Arguments {
		Get {
			return this.iArguments
		}
	}

	__New(pluginOrMode, function, label, icon, action, arguments*) {
		this.iPlugin := (isInstance(pluginOrMode, ControllerMode) ? pluginOrMode.Plugin : pluginOrMode)
		this.iAction := action
		this.iArguments := arguments

		super.__New(function, label, icon)
	}

	fireAction(function, trigger) {
		local plugin := this.Plugin

		switch this.Action {
			case "InformationRequest":
				plugin.requestInformation(this.Arguments*)
			case "PitstopRecommend":
				plugin.recommendPitstop()
			case "StrategyRecommend":
				plugin.recommendStrategy()
			case "StrategyCancel":
				plugin.cancelStrategy()
			case "PitstopPlan":
				plugin.planPitstop()
			case "DriverSwapPlan":
				plugin.planDriverSwap()
			case "PitstopPrepare":
				plugin.preparePitstop()
			case "Accept":
				plugin.accept()
			case "Reject":
				plugin.reject()
			default:
				throw "Invalid action `"" . this.Action . "`" detected in RaceAssistantAction.fireAction...."
		}
	}
}

class RaceAssistantSimulatorPlugin extends SimulatorPlugin {
	iActionMode := kPitstopMode

	iRaceEngineer := false
	iRaceStrategist := false
	iRaceSpotter := false

	iCurrentTyreCompound := false
	iRequestedTyreCompound := false

	RaceEngineer {
		Get {
			return this.iRaceEngineer
		}
	}

	RaceStrategist {
		Get {
			return this.iRaceStrategist
		}
	}

	RaceSpotter {
		Get {
			return this.iRaceSpotter
		}
	}

	CurrentTyreCompound {
		Get {
			return this.iCurrentTyreCompound
		}

		Set {
			return (this.iCurrentTyreCompound := value)
		}
	}

	RequestedTyreCompound {
		Get {
			return this.iRequestedTyreCompound
		}

		Set {
			return (this.iRequestedTyreCompound := value)
		}
	}

	__New(controller, name, simulator, configuration := false) {
		local ignore, theAction

		super.__New(controller, name, simulator, configuration)

		if (this.Active || isDebug()) {
			this.iActionMode := kAssistantMode

			for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
				this.createRaceAssistantAction(controller, string2Values(A_Space, theAction)*)

			controller.registerPlugin(this)
		}
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function, mode, descriptor

		if (action = "InformationRequest") {
			arguments.InsertAt(1, actionFunction)

			actionFunction := arguments.Pop()
		}

		function := controller.findFunction(actionFunction)
		mode := this.findMode(this.iActionMode)

		if (mode == false)
			mode := ((this.iActionMode = "Pitstop") ? PitstopMode(this) : AssistantMode(this))

		if (function != false) {
			if (action = "InformationRequest") {
				action := values2String("", arguments*)
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				mode.registerAction(RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), "InformationRequest", arguments*))
			}
			else if (inList(kAssistantRaceActions, action) || inList(kAssistantAnswerActions, action)) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				mode.registerAction(RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}

	simulatorStartup(simulator) {
		local ignore, assistant

		super.simulatorStartup(simulator)

		if (simulator = this.Simulator.Application) {
			RaceAssistantPlugin.startSimulation(this)

			for ignore, assistant in RaceAssistantPlugin.Assistants
				if isInstance(assistant, RaceEngineerPlugin)
					this.iRaceEngineer := assistant
				else if isInstance(assistant, RaceStrategistPlugin)
					this.iRaceStrategist := assistant
				else if isInstance(assistant, RaceSpotterPlugin)
					this.iRaceSpotter := assistant
		}
	}

	simulatorShutdown(simulator) {
		local raceEngineer, raceStrategist, raceSpotter

		super.simulatorShutdown(simulator)

		if (simulator = this.Simulator.Application) {
			RaceAssistantPlugin.stopSimulation(this)

			this.iRaceEngineer := false
			this.iRaceStrategist := false
			this.iRaceSpotter := false
		}
	}

	supportsRaceAssistant(assistantPlugin) {
		local hasProvider := (FileExist(kBinariesDirectory . this.Code . " SHM Provider.exe") != false)

		if (assistantPlugin = kRaceSpotterPlugin)
			return (hasProvider && FileExist(kBinariesDirectory . this.Code . " SHM Spotter.exe"))
		else
			return hasProvider
	}

	supportsPitstop() {
		return false
	}

	supportsSetupImport() {
		return false
	}

	supportsTrackMap() {
		return false
	}

	updateSession(session) {
		super.updateSession(session)

		if (session = kSessionFinished) {
			this.CurrentTyreCompound := false
			this.RequestedTyreCompound := false
		}
	}

	requestInformation(arguments*) {
		if (this.RaceStrategist && this.RaceStrategist.requestInformation(arguments*))
			return
		else if (this.RaceEngineer && this.RaceEngineer.requestInformation(arguments*))
			return
		else if this.RaceSpotter
			this.RaceSpotter.requestInformation(arguments*)
	}

	accept() {
		if this.RaceEngineer
			this.RaceEngineer.accept()

		if this.RaceStrategist
			this.RaceStrategist.accept()

		if this.RaceSpotter
			this.RaceSpotter.accept()
	}

	reject() {
		if this.RaceEngineer
			this.RaceEngineer.reject()

		if this.RaceStrategist
			this.RaceStrategist.reject()

		if this.RaceSpotter
			this.RaceSpotter.reject()
	}

	sessionActive(data) {
		return (getMultiMapValue(data, "Session Data", "Active", false) && !getMultiMapValue(data, "Session Data", "Paused", false))
	}

	driverActive(data, driverForName, driverSurName) {
		return (this.sessionActive(data)
			 && (getMultiMapValue(data, "Stint Data", "DriverForname") = driverForName)
			 && (getMultiMapValue(data, "Stint Data", "DriverSurname") = driverSurName))
	}

	prepareSession(settings, data) {
		local sessionDB := SessionDatabase()
		local simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		local car := getMultiMapValue(data, "Session Data", "Car", "Unknown")
		local track := getMultiMapValue(data, "Session Data", "Track", "Unknown")

		sessionDB.registerCar(simulator, car, sessionDB.getCarName(simulator, car))

		sessionDB.registerTrack(simulator, car, track
							  , sessionDB.getTrackName(simulator, track, false), sessionDB.getTrackName(simulator, track, true))
	}

	startSession(settings, data) {
		local compound := getMultiMapValue(settings, "Session Setup", "Tyre.Compound", "Dry")
		local compoundColor := getMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")

		this.Car := getMultiMapValue(data, "Session Data", "Car")
		this.Track := getMultiMapValue(data, "Session Data", "Track")

		this.CurrentTyreCompound := compound(compound, compoundColor)

		this.updateTyreCompound(data)

		this.prepareSession(settings, data)
	}

	finishSession() {
		this.updateSession(kSessionFinished)

		this.Car := false
		this.Track := false
	}

	recommendPitstop() {
		if this.RaceStrategist
			this.RaceStrategist.recommendPitstop()
	}

	recommendStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.recommendStrategy()
	}

	cancelStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.cancelStrategy()
	}

	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}

	planDriverSwap() {
		if this.RaceEngineer
			this.RaceEngineer.planDriverSwap()
	}

	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}

	performPitstop(lap, options) {
	}

	pitstopPlanned(pitstopNumber, plannedLap := false) {
	}

	pitstopPrepared(pitstopNumber) {
	}

	pitstopFinished(pitstopNumber) {
		if this.RequestedTyreCompound {
			this.CurrentTyreCompound := this.RequestedTyreCompound
			this.RequestedTyreCompound := false
		}
	}

	tyreCompoundIndex(compound, compoundColor := false) {
		local compounds, index, candidate

		if compound {
			compounds := SessionDatabase().getTyreCompounds(this.Simulator[true], this.Car, this.Track)
			index := inList(compounds, compound(compound, compoundColor))

			if index
				return index
			else
				for index, candidate in compounds
					if (InStr(candidate, compound) == 1)
						return index

			return false
		}
		else
			return false
	}

	tyreCompoundCode(compound, compoundColor := false) {
		local index

		if compound {
			index := this.tyreCompoundIndex(compound, compoundColor)

			return (index ? SessionDatabase().getTyreCompounds(this.Simulator[true], this.Car, this.Track, true)[index] : false)
		}
		else
			return false
	}

	resetTrackAutomation() {
		this.iTrackAutomation := kUndefined
	}

	triggerAction(actionNr, positionX, positionY) {
		local action, ignore, theHotkey

		if this.TrackAutomation {
			action := this.TrackAutomation.Actions[actionNr]

			if (action.Type = "Hotkey") {
				this.activateWindow()

				for ignore, theHotkey in string2Values("|", action.Action) {
					this.sendCommand(theHotKey)

					Sleep(25)
				}
			}
			else if (action.Type = "Command")
				execute(action.Action)
		}
	}

	startPitstopSetup(pitstopNumber) {
	}

	finishPitstopSetup(pitstopNumber) {
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		if compound
			this.RequestedTyreCompound := compound(compound, compoundColor)
		else
			this.RequestedTyreCompound := false
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
	}

	requestPitstopDriver(pitstopNumber, driver) {
	}

	updateTyreCompound(data) {
		local compound, compoundColor

		if (!getMultiMapValue(data, "Car Data", "TyreCompound", false)
		 && !getMultiMapValue(data, "Car Data", "TyreCompoundRaw", false))
			if this.CurrentTyreCompound {
				compound := "Dry"
				compoundColor := "Black"

				splitCompound(this.CurrentTyreCompound, &compound, &compoundColor)

				setMultiMapValue(data, "Car Data", "TyreCompound", compound)
				setMultiMapValue(data, "Car Data", "TyreCompoundColor", compoundColor)
			}
	}

	updateTelemetryData(data) {
		this.updateTyreCompound(data)

		if (this.Session != kSessionFinished) {
			this.Car := getMultiMapValue(data, "Session Data", "Car")
			this.Track := getMultiMapValue(data, "Session Data", "Track")
		}
	}

	updatePositionsData(data) {
	}

	saveSessionState(&sessionSettings, &sessionState) {
		local compound, compoundColor

		if !sessionSettings
			sessionSettings := newMultiMap()

		if this.CurrentTyreCompound {
			compound := "Dry"
			compoundColor := "Black"

			splitCompound(this.CurrentTyreCompound, &compound, &compoundColor)

			setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre.Current.Compound", compound)
			setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre.Current.Compound.Color", compoundColor)
		}

		if this.RequestedTyreCompound {
			compound := "Dry"
			compoundColor := "Black"

			splitCompound(this.RequestedTyreCompound, &compound, &compoundColor)

			setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre.Requested.Compound", compound)
			setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre.Requested.Compound.Color", compoundColor)
		}
	}

	restoreSessionState(&sessionSettings, &sessionState) {
		local compound

		this.CurrentTyreCompound := false
		this.RequestedTyreCompound := false

		if sessionSettings {
			compound := getMultiMapValue(sessionSettings, "Simulator Settings", "Tyre.Current.Compound", false)

			if compound
				this.CurrentTyreCompound := compound(compound, getMultiMapValue(sessionSettings
																			  , "Simulator Settings", "Tyre.Current.Compound.Color"))

			compound := getMultiMapValue(sessionSettings, "Simulator Settings", "Tyre.Requested.Compound", false)

			if compound
				this.RequestedTyreCompound := compound(compound, getMultiMapValue(sessionSettings
																				, "Simulator Settings", "Tyre.Requested.Compound.Color"))
		}
	}

	acquireTelemetryData() {
		local code, trackData, data

		static sessionDB := false

		if !sessionDB
			sessionDB := SessionDatabase()

		code := this.Code
		trackData := sessionDB.getTrackData(code, this.Track)

		return (trackData ? readSimulatorData(code, "-Track `"" . trackData . "`"") : readSimulatorData(code))
	}

	acquirePositionsData(telemetryData) {
		local cars := []
		local positionsData, count

		if telemetryData.Has("Position Data") {
			positionsData := newMultiMap()

			setMultiMapValues(positionsData, "Position Data", getMultiMapValues(telemetryData, "Position Data"))
		}
		else
			positionsData := readSimulatorData(this.Code, "-Standings")

		count := getMultiMapValue(positionsData, "Position Data", "Car.Count", 0)

		loop count
			cars.Push(Array(A_Index, getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Lap")
								   + getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Lap.Running")))

		bubbleSort(&cars, compareCarPositions)

		if isDebug()
			loop count {
				if (getMultiMapValue(positionsData, "Position Data", "Car." . cars[A_Index] . ".Position") != A_Index)
					logMessage(kLogDebug, "Corrected position for car " . cars[A_Index] . ": "
										. getMultiMapValue(positionsData, "Position Data", "Car." . cars[A_Index] . ".Position")
										. " -> " . A_Index)

				setMultiMapValue(positionsData, "Position Data", "Car." . cars[A_Index] . ".Position", A_Index)
			}
		else
			loop count
				setMultiMapValue(positionsData, "Position Data", "Car." . cars[A_Index] . ".Position", A_Index)

		return positionsData
	}

	acquireSessionData(&telemetryData, &positionsData) {
		local data := newMultiMap()
		local section, values

		setMultiMapValue(data, "System", "Time", A_TickCount)

		telemetryData := this.acquireTelemetryData()
		positionsData := this.acquirePositionsData(telemetryData)

		RaceAssistantPlugin.updateAssistantsTelemetryData(telemetryData)
		RaceAssistantPlugin.updateAssistantsPositionsData(positionsData)

		for section, values in telemetryData
			setMultiMapValues(data, section, values)

		for section, values in positionsData
			setMultiMapValues(data, section, values)

		return data
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readSimulatorData(simulator, options := "", protocol := "SHM") {
	local exePath := kBinariesDirectory . simulator . A_Space . protocol . " Provider.exe"
	local dataFile, data

	DirCreate(kTempDirectory . simulator . " Data")

	dataFile := temporaryFileName(simulator . " Data\" . protocol, "data")

	try {
		RunWait(A_ComSpec . " /c `"`"" . exePath . "`" " . options . " > `"" .dataFile . "`"`", , Hide")
	}
	catch Any as exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider (")
												   , {simulator: simulator, protocol: protocol})
							   . exePath . translate(") - please rebuild the applications in the binaries folder (")
							   . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
									  , {exePath: exePath, simulator: simulator, protocol: protocol})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}

	data := readMultiMap(dataFile)

	deleteFile(dataFile)

	setMultiMapValue(data, "Session Data", "Simulator", simulator)

	return data
}

;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

compareCarPositions(c1, c2) {
	return (c1[2] > c2[2])
}

getCurrentSimulatorPlugin(option := false) {
	local actions, ignore, candidate

	if SimulatorPlugin.ActiveSimulator {
		if option {
			actions := false
			ignore := false

			SimulatorPlugin.ActiveSimulator.getPitstopActions(&actions, &ignore)

			for ignore, candidate in actions
				if (candidate = option)
					return SimulatorPlugin.ActiveSimulator

			return false
		}
		else
			return SimulatorPlugin.ActiveSimulator
	}
	else
		return false
}


;;;-------------------------------------------------------------------------;;;
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

openPitstopMFD(descriptor := false) {
	local plugin := getCurrentSimulatorPlugin()

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		protectionOn()

		try {
			if descriptor {
				plugin.resetPitstopMFD(descriptor)

				plugin.openPitstopMFD(descriptor)
			}
			else {
				plugin.resetPitstopMFD()

				plugin.openPitstopMFD()
			}
		}
		finally {
			protectionOff()
		}
	}
}

closePitstopMFD() {
	local plugin := getCurrentSimulatorPlugin()

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
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
		logMessage(kLogWarn, translate("Unsupported strategy selection `"") . selection . translate("`" detected in changePitstopStrategy - please check the configuration"))

	changePitstopOption("Strategy", selection, steps)
}

changePitstopFuelAmount(direction, liters := 5) {
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported fuel amount `"") . direction . translate("`" detected in changePitstopFuelAmount - please check the configuration"))

	changePitstopOption("Refuel", direction, liters)
}

changePitstopTyreCompound(selection) {
	if !inList(["Next", "Previous", "Increase", "Decrease"], selection)
		logMessage(kLogWarn, translate("Unsupported tyre compound selection `"") . selection . translate("`" detected in changePitstopTyreCompound - please check the configuration"))

	changePitstopOption("Tyre Compound", selection)
}

changePitstopTyreSet(selection, steps := 1) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported tyre set selection `"") . selection . translate("`" detected in changePitstopTyreSet - please check the configuration"))

	changePitstopOption("Tyre Set", selection, steps)
}

changePitstopTyrePressure(tyre, direction, increments := 1) {
	if !inList(["All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"], tyre)
		logMessage(kLogWarn, translate("Unsupported tyre position `"") . tyre . translate("`" detected in changePitstopTyrePressure - please check the configuration"))

	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported pressure change `"") . direction . translate("`" detected in changePitstopTyrePressure - please check the configuration"))

	changePitstopOption(tyre, direction, increments)
}

changePitstopBrakePadType(brake, selection) {
	if !inList(["Front Brake", "Rear Brake"], brake)
		logMessage(kLogWarn, translate("Unsupported brake unit `"") . brake . translate("`" detected in changePitstopBrakePadType - please check the configuration"))

	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported brake selection `"") . selection . translate("`" detected in changePitstopBrakePadType - please check the configuration"))

	changePitstopOption(brake, selection)
}

changePitstopDriver(selection) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported driver selection `"") . selection . translate("`" detected in changePitstopDriver - please check the configuration"))

	changePitstopOption("Driver", selection)
}

changePitstopOption(option, selection := "Next", increments := 1) {
	local plugin

	if (selection = "Next")
		selection := "Increase"
	else if (selection = "Previous")
		selection := "Decrease"
	else if !inList(["Increase", "Decrease"], selection)
		logMessage(kLogWarn, translate("Unsupported option selection `"") . selection . translate("`" detected in changePitstopOption - please check the configuration"))

	plugin := getCurrentSimulatorPlugin(option)

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		protectionOn()

		try {
			plugin.updatePitstopOption(option, selection, increments)
		}
		finally {
			protectionOff()
		}
	}
}