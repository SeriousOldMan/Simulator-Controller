;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Plugin                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\SettingsDatabase.ahk"
#Include "SimulatorProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPitstopMode := "Pitstop"
global kAssistantMode := "Assistant"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAssistantAnswerActions := ["Accept", "Reject"]
global kAssistantRaceActions := ["FuelRatioOptimize", "PitstopPlan", "DriverSwapPlan", "PitstopPrepare", "PitstopRecommend", "StrategyRecommend", "FCYRecommend", "StrategyCancel"]


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

		if (this.Controller.State = "Foreground")
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
					theAction.Function.setLabel(this.actionLabel(theAction))
				}
				else if inList([kSessionPractice, kSessionRace], session) {
					if (theAction.Action = "FuelRatioOptimize") {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
					}
					else {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setLabel(this.actionLabel(theAction))
					}
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
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
					theAction.Function.setLabel(this.actionLabel(theAction))
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
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
	static sActiveSimulation := false

	iCommandMode := "Event"
	iCommandDelay := kUndefined

	iProvider := false

	iSimulator := false
	iSession := kSessionFinished

	iCar := false
	iTrack := false

	iTrackAutomation := kUndefined

	static ActiveSimulator {
		Get {
			return SimulatorPlugin.sActiveSimulator
		}
	}

	ActiveSimulator {
		Get {
			return SimulatorPlugin.ActiveSimulator
		}
	}

	static ActiveSimulation {
		Get {
			return SimulatorPlugin.sActiveSimulation
		}
	}

	ActiveSimulation {
		Get {
			return SimulatorPlugin.ActiveSimulation
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

				settings := SettingsDatabase().loadSettings(simulator, car, track, "*", "*")

				default := getMultiMapValue(settings, "Simulator." . simulator, "Pitstop.KeyDelay", 30)

				this.iCommandDelay := getMultiMapValue(settings, "Simulator." . simulator, "Command.KeyDelay", default)
			}

			return this.iCommandDelay
		}

		Set {
			return (this.iCommandDelay := value)
		}
	}

	Provider {
		Get {
			if !this.iProvider
				try {
					this.iProvider := this.createSimulatorProvider()
				}
				catch {
					return SimulatorProvider.GenericSimulatorProvider("Unknown", "Unknown", "Unknown")
				}

			return this.iProvider
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
			if (value != this.iCar) {
				this.iProvider := false

				this.resetTrackAutomation()
			}

			this.iCommandDelay := kUndefined

			return (this.iCar := value)
		}
	}

	Track {
		Get {
			return this.iTrack
		}

		Set {
			if (value != this.iTrack) {
				this.iProvider := false

				this.resetTrackAutomation()
			}

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

		super.__New(controller, name, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")

			for ignore, theAction in string2Values(",", this.getArgumentValue("pitstopCommands", "")) {
				arguments := string2Values(A_Space, substituteString(theAction, "  ", A_Space))

				theAction := arguments[1]

				if (inList(kAssistantAnswerActions, theAction) || inList(kAssistantRaceActions, theAction) || (theAction = "InformationRequest"))
					this.createRaceAssistantAction(controller, arguments*)
				else
					this.createPitstopAction(controller, arguments*)
			}

			if register
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

	createSimulatorProvider() {
		return SimulatorProvider.createSimulatorProvider(this.Simulator[true], this.Car, this.Track)
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		return this.Provider.supportsPitstop(&refuelService, &tyreService, &brakeService, &repairService)
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		return this.Provider.supportsTyreManagement(&mixedCompounds, &tyreSets)
	}

	supportsSetupImport() {
		return this.Provider.supportsSetupImport()
	}

	supportsTrackMap() {
		return this.Provider.supportsTrackMap()
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap()

		selectActions := []
	}

	writePluginState(configuration) {
		local simulator := this.runningSimulator()
		local car, track

		if this.Active {
			setMultiMapValue(configuration, this.Plugin, "State", simulator ? "Active" : "Passive")

			if simulator {
				if (this.Car && this.Track) {
					setMultiMapValue(configuration, "Simulation", "State", "Active")

					setMultiMapValue(configuration, "Simulation", "Session", this.Session[true])

					car := SessionDatabase.getCarName(simulator, this.Car)
					track := SessionDatabase.getTrackName(simulator, this.Track)

					setMultiMapValue(configuration, "Simulation", "Simulator", simulator)
					setMultiMapValue(configuration, "Simulation", "Car", car)
					setMultiMapValue(configuration, "Simulation", "Track", track)

					setMultiMapValue(configuration, this.Plugin, "Information"
								   , values2String("; ", translate("Simulator: ") . simulator
								   , translate("Car: ") . car
								   , translate("Track: ") . track))

					if (this.StartupSettings && getMultiMapValue(this.StartupSettings, "Profiles", "Profile", false))
						setMultiMapValue(configuration, "Simulation", "Profile", getMultiMapValue(this.StartupSettings, "Profiles", "Profile"))
					else
						setMultiMapValue(configuration, "Simulation", "Profile", translate("Standard"))
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

		if !WinExist(window) {
			if isDebug()
				showMessage(this.Simulator[true] . " not found...")

			return false
		}
		else if !WinActive(window) {
			WinActivate(window)

			return WinActive(window)
		}
		else
			return true
	}

	sendCommand(command, delay?) {
		try {
			switch this.CommandMode, false {
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

		if !isSet(delay)
			delay := this.CommandDelay

		if delay
			Sleep(delay)
	}

	runningSimulator(active := false) {
		if active
			return (this.Simulator.isRunning() ? this.Simulator.Application : false)
		else
			return (this.Simulator.isRunning() ? this.Simulator.Application
											   : ((SimulatorPlugin.ActiveSimulation = this.Simulator.Application) ? SimulatorPlugin.ActiveSimulation : false))
	}

	simulatorStartup(simulator) {
		super.simulatorStartup(simulator)

		if ((simulator = this.Simulator.Application) && (SimulatorPlugin.ActiveSimulator != this)) {
			if SimulatorPlugin.ActiveSimulator
				SimulatorPlugin.ActiveSimulator.simulatorShutdown(SimulatorPlugin.ActiveSimulation)

			this.updateSession(kSessionFinished, true)

			SimulatorPlugin.sActiveSimulator := this
			SimulatorPlugin.sActiveSimulation := simulator
		}
	}

	simulatorShutdown(simulator) {
		super.simulatorShutdown(simulator)

		if ((simulator = this.Simulator.Application) && (SimulatorPlugin.ActiveSimulator == this)) {
			this.updateSession(kSessionFinished, true)

			SimulatorPlugin.sActiveSimulator := false
			SimulatorPlugin.sActiveSimulation := false

			callSimulator(this.Code, "Close")
		}
	}

	updateFunctions() {
		if (this.Controller.State = "Foreground")
			this.updateActions(kSessionUnknown)
	}

	updateActions(session) {
		local mode := this.findMode(kPitstopMode)

		if (mode && inList(this.Controller.ActiveModes, mode))
			mode.updateActions(session)

		mode := this.findMode(kAssistantMode)

		if (mode && inList(this.Controller.ActiveModes, mode))
			mode.updateActions(session)
	}

	updateSession(session, force := false) {
		local mode

		if (force || ((session != this.Session) && (session != kSessionPaused))) {
			this.iSession := session
			this.iProvider := false

			if (session == kSessionFinished) {
				this.Car := false
				this.Track := false

				this.Controller.setModes(this.Simulator.Application)
			}
			else if inList(kSessions, session)
				this.Controller.setModes(this.Simulator.Application, kSessionNames[session])
			else
				this.Controller.setModes(this.Simulator.Application, "Other")
		}

		this.updateActions(session)
	}

	updatePitstopOption(option, action, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption(option))
			this.changePitstopOption(option, action, steps)
	}

	notifyPitstopChanged(option) {
		local newValues, ignore, postfix

		if this.RaceEngineer {
			switch option, false {
				case "TyreCompound":
					option := "Tyre Compound"
				case "TyreCompoundFront":
					option := "Tyre Compound Front"
				case "TyreCompoundRear":
					option := "Tyre Compound Rear"
				case "TyreCompoundFrontLeft":
					option := "Tyre Compound Front Left"
				case "TyreCompoundFrontRight":
					option := "Tyre Compound Front Right"
				case "TyreCompoundRearLeft":
					option := "Tyre Compound Rear Left"
				case "TyreCompoundRearRight":
					option := "Tyre Compound Rear Right"
			}

			switch option, false {
				case "Refuel", "Tyre Compound", "Tyre Set"
				   , "Tyre Compound Front", "Tyre Compound Rear"
				   , "Tyre Compound Front Left", "Tyre Compound Front Right"
				   , "Tyre Compound Rear Left", "Tyre Compound Rear Right"
				   , "Repair Suspension", "Repair Bodywork", "Repair Engine", "Driver":
					newValues := this.getPitstopOptionValues(option)

					if newValues {
						if isDebug()
							logMessage(kLogDebug, "Changing `"" . option . "`" to: " . values2String(", ", newValues*))

						this.RaceEngineer.pitstopOptionChanged(option, true, newValues*)
					}
				case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
					newValues := this.getPitstopOptionValues("Tyre Pressures")

					if newValues {
						if isDebug()
							logMessage(kLogDebug, "Changing `"" . option . "`" to: " . values2String(", ", newValues*))

						this.RaceEngineer.pitstopOptionChanged("Tyre Pressures", true, newValues*)
					}
			}
		}
	}

	getPitstopAllOptionValues() {
		local options := CaseInsenseMap()
		local tyreSet, refuelService, tyreService, brakeService, repairService

		if this.supportsPitstop(&refuelService, &tyreService, &brakeService, &repairService) {
			if refuelService
				options["Refuel"] := this.getPitstopOptionValues("Refuel")

			if tyreService {
				options["Tyre Pressures"] := this.getPitstopOptionValues("Tyre Pressures")

				if (tyreService = "Axle") {
					options["Tyre Compound Front"] := this.getPitstopOptionValues("Tyre Compound Front")
					options["Tyre Compound Rear"] := this.getPitstopOptionValues("Tyre Compound Rear")
				}
				else if (tyreService = "Wheel") {
					options["Tyre Compound Front Left"] := this.getPitstopOptionValues("Tyre Compound Front Left")
					options["Tyre Compound Front Right"] := this.getPitstopOptionValues("Tyre Compound Front Right")
					options["Tyre Compound Rear Left"] := this.getPitstopOptionValues("Tyre Compound Rear Left")
					options["Tyre Compound Rear Right"] := this.getPitstopOptionValues("Tyre Compound Rear Right")
				}
				else
					options["Tyre Compound"] := this.getPitstopOptionValues("Tyre Compound")

				if (this.supportsTyreManagement( , &tyreSet) && tyreSet)
					options["Tyre Set"] := this.getPitstopOptionValues("Tyre Set")
			}

			if brakeService
				options["Change Brakes"] := this.getPitstopOptionValues("Change Brakes")

			if repairService {
				if inList(repairService, "Suspension")
					options["Repair Suspension"] := this.getPitstopOptionValues("Repair Suspension")

				if inList(repairService, "Bodywork")
					options["Repair Bodywork"] := this.getPitstopOptionValues("Repair Bodywork")

				if inList(repairService, "Engine")
					options["Repair Engine"] := this.getPitstopOptionValues("Repair Engine")
			}
		}

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

	correctStandingsData(standingsData, needCorrection := false) {
		return this.Provider.correctStandingsData(standingsData, needCorrection)
	}

	readTelemetryData() {
		return this.Provider.readTelemetryData()
	}

	readStandingsData(telemetryData, correct := false) {
		return this.Provider.readStandingsData(telemetryData, correct)
	}

	acquireTelemetryData() {
		return this.Provider.readTelemetryData()
	}

	acquireStandingsData(telemetryData, finished := false) {
		return this.Provider.acquireStandingsData(telemetryData, finished)
	}

	acquireSessionData(&telemetryData, &standingsData, finished := false) {
		return this.Provider.acquireSessionData(&telemetryData, &standingsData, finished)
	}

	readSessionData(options := "", protocol?) {
		return this.Provider.readSessionData(options, protocol?)
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

		switch this.Action, false {
			case "InformationRequest":
				plugin.requestInformation(this.Arguments*)
			case "PitstopRecommend":
				plugin.recommendPitstop()
			case "StrategyRecommend":
				plugin.recommendStrategy()
			case "FCYRecommend":
				plugin.recommendFullCourseYellow()
			case "StrategyCancel":
				plugin.cancelStrategy()
			case "FuelRatioOptimize":
				plugin.optimizeFuelRatio()
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

	iSettings := false

	iRaceEngineer := false
	iRaceStrategist := false
	iRaceSpotter := false

	iCurrentTyreCompounds := false
	iRequestedTyreCompounds := false

	iHasStandingsData := false

	Settings {
		Get {
			return this.iSettings
		}

		Set {
			return (this.iSettings := value)
		}
	}

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

	CurrentTyreCompounds {
		Get {
			return this.iCurrentTyreCompounds
		}

		Set {
			if (value && !isObject(value))
				value := [value, value, value, value]

			return (this.iCurrentTyreCompounds := value)
		}
	}

	RequestedTyreCompounds {
		Get {
			return this.iRequestedTyreCompounds
		}

		Set {
			if (value && !isObject(value))
				value := [value, value, value, value]

			return (this.iRequestedTyreCompounds := value)
		}
	}

	__New(controller, name, simulator, configuration := false, register := true) {
		local ignore, theAction

		super.__New(controller, name, simulator, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iActionMode := kAssistantMode

			for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
				this.createRaceAssistantAction(controller, string2Values(A_Space, substituteString(theAction, "  ", A_Space))*)

			if register
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

	writePluginState(configuration) {
		super.writePluginState(configuration)

		if (this.Active && this.runningSimulator()) {
			if (this.Car && this.Track && !this.iHasStandingsData) {
				setMultiMapValue(configuration, this.Plugin, "State", "Warning")
				setMultiMapValue(configuration, this.Plugin, "Information", getMultiMapValue(configuration, this.Plugin, "Information") . translate("; ") . translate("State:") . A_Space . translate("No participant information available..."))

				setMultiMapValue(configuration, "Simulation", "State", "Warning")
				setMultiMapValue(configuration, "Simulation", "Information", translate("No participant information available..."))
			}
		}
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

			this.iHasStandingsData := false
		}
	}

	simulatorShutdown(simulator) {
		super.simulatorShutdown(simulator)

		if (simulator = this.Simulator.Application) {
			RaceAssistantPlugin.stopSimulation(this)

			this.iRaceEngineer := false
			this.iRaceStrategist := false
			this.iRaceSpotter := false

			this.iHasStandingsData := false
		}
	}

	supportsRaceAssistant(assistantPlugin) {
		local hasProvider := false
		
		try
			hasProvider := FileExist(SimulatorProvider.getProtocol(this.Code, "Provider").File)
			
		if !hasProvider
			try
				hasProvider := FileExist(SimulatorProvider.getProtocol(this.Code, "Connector").File)
		
		if (isSet(kRaceSpotterPlugin) && (assistantPlugin = kRaceSpotterPlugin))
			try
				hasProvider := (hasProvider && FileExist(SimulatorProvider.getProtocol(this.Code, "Spotter").File))
				
		return hasProvider
	}

	updateSession(session, force := false) {
		super.updateSession(session, force)

		if (session = kSessionFinished) {
			this.CurrentTyreCompounds := false
			this.RequestedTyreCompounds := false
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

	driverActive(data, driverForname, driverSurname) {
		return (this.sessionActive(data)
			 && (getMultiMapValue(data, "Stint Data", "DriverForname") = driverForname)
			 && (getMultiMapValue(data, "Stint Data", "DriverSurname") = driverSurname))
	}

	prepareSimulation() {
		this.Provider.prepareProvider()
	}

	hasPrepared(settings, data, count) {
		return (count > 1)
	}

	prepareSettings(settings, data) {
		return settings
	}

	prepareSession(settings, data) {
		local simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		local car := getMultiMapValue(data, "Session Data", "Car", "Unknown")
		local track := getMultiMapValue(data, "Session Data", "Track", "Unknown")
		local tyreCompound := getMultiMapValue(settings, "Session Setup", "Tyre.Compound", "Dry")
		local tyreCompoundColor := getMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")
		local mixedCompounds

		static lastSimulator := false
		static lastCar := false
		static lastTrack := false

		registerSimulator(simulator, car, track) {
			local settings

			SessionDatabase.registerCar(simulator, car, SessionDatabase.getCarName(simulator, car))

			SessionDatabase.registerTrack(simulator, car, track
										, SessionDatabase.getTrackName(simulator, track, false)
										, SessionDatabase.getTrackName(simulator, track, true))

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Simulator", "Simulator", SessionDatabase.getSimulatorName(simulator))
			setMultiMapValue(settings, "Simulator", "Car", car)
			setMultiMapValue(settings, "Simulator", "Track", track)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
		}

		this.Settings := settings

		this.Car := car
		this.Track := track

		if ((simulator != lastSimulator) || (car != lastCar) || (track != lastTrack)) {
			lastSimulator := simulator
			lastCar := car
			lastTrack := track

			Task.startTask(registerSimulator.Bind(simulator, car, track), 1000, kLowPriority)
		}

		if this.supportsTyreManagement(&mixedCompounds) {
			if (mixedCompounds = "Axle")
				this.CurrentTyreCompounds := [compound(getMultiMapValue(data, "Car Data", "TyreCompoundFront", tyreCompound)
													 , getMultiMapValue(data, "Car Data", "TyreCompoundColorFront", tyreCompoundColor))
											, compound(getMultiMapValue(data, "Car Data", "TyreCompoundRear", tyreCompound)
													 , getMultiMapValue(data, "Car Data", "TyreCompoundColorRear", tyreCompoundColor))]
			else if (mixedCompounds = "Wheel") {
				this.CurrentTyreCompounds := [compound(getMultiMapValue(data, "Car Data", "TyreCompoundFrontLeft", tyreCompound)
													 , getMultiMapValue(data, "Car Data", "TyreCompoundColorFrontLeft", tyreCompoundColor))
											, compound(getMultiMapValue(data, "Car Data", "TyreCompoundFrontRight", tyreCompound)
													 , getMultiMapValue(data, "Car Data", "TyreCompoundColorFrontRight", tyreCompoundColor))
											, compound(getMultiMapValue(data, "Car Data", "TyreCompoundRearLeft", tyreCompound)
													 , getMultiMapValue(data, "Car Data", "TyreCompoundColorRearLeft", tyreCompoundColor))
											, compound(getMultiMapValue(data, "Car Data", "TyreCompoundRearRight", tyreCompound)
													 , getMultiMapValue(data, "Car Data", "TyreCompoundColorRearRight", tyreCompoundColor))]
			}
			else if getMultiMapValue(data, "Car Data", "TyreCompound", false)
				this.CurrentTyreCompounds := compound(getMultiMapValue(data, "Car Data", "TyreCompound")
													, getMultiMapValue(data, "Car Data", "TyreCompoundColor"))
			else
				this.CurrentTyreCompounds := compound(tyreCompound, tyreCompoundColor)
		}
		else
			this.CurrentTyreCompounds := compound(tyreCompound, tyreCompoundColor)

		this.updateTyreCompound(data)
	}

	startSession(settings, data) {
		this.prepareSession(settings, data)

		this.iHasStandingsData := (getMultiMapValue(data, "Position Data", "Car.Count", 0) > 0)
	}

	finishSession() {
		this.updateSession(kSessionFinished)

		this.Car := false
		this.Track := false
	}

	pauseSession() {
	}

	resumeSession() {
	}

	addLap(lap, data) {
	}

	updateLap(lap, data) {
	}

	recommendPitstop() {
		if this.RaceStrategist
			this.RaceStrategist.recommendPitstop()
	}

	recommendStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.recommendStrategy()
	}

	recommendFullCourseYellow() {
		if this.RaceStrategist
			this.RaceStrategist.recommendFullCourseYellow()
	}

	cancelStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.cancelStrategy()
	}

	optimizeFuelRatio() {
		if this.RaceEngineer
			this.RaceEngineer.optimizeFuelRatio("Engineer")
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
		if this.RequestedTyreCompounds {
			this.CurrentTyreCompounds := this.RequestedTyreCompounds
			this.RequestedTyreCompounds := false
		}
	}

	tyreCompoundIndex(tyreCompound, tyreCompoundColor := false) {
		local compounds, index, candidate

		if tyreCompound {
			compounds := SessionDatabase().getTyreCompounds(this.Simulator[true], this.Car, this.Track)
			index := inList(compounds, compound(tyreCompound, tyreCompoundColor))

			if index
				return index
			else
				for index, candidate in compounds
					if (InStr(candidate, tyreCompound) == 1)
						return index

			return false
		}
		else
			return false
	}

	tyreCompoundCode(tyreCompound, tyreCompoundColor := false) {
		local index

		if tyreCompound {
			index := this.tyreCompoundIndex(tyreCompound, tyreCompoundColor)

			return (index ? SessionDatabase().getTyreCompounds(this.Simulator[true], this.Car, this.Track, true)[index] : false)
		}
		else
			return false
	}

	resetTrackAutomation() {
		this.iTrackAutomation := kUndefined
	}

	triggerAction(actionNr, positionX, positionY) {
		local action, ignore, theHotkey, index, argument, arguments

		if this.TrackAutomation {
			action := this.TrackAutomation.Actions[actionNr]

			switch action.Type, false {
				case "Hotkey":
					if this.activateWindow()
						for ignore, theHotkey in string2Values("|", action.Action) {
							this.sendCommand(theHotKey)

							Sleep(25)
						}
				case "Command":
					execute(action.Action)
				case "Action":
					for ignore, action in (InStr(action.Action, "|") ? StrSplit(action.Action, "|") : StrSplit(action.Action, ";")) {
						action := StrSplit(action, "(", " `t", 2)

						arguments := string2Values(",", SubStr(action[2], 1, StrLen(action[2]) - 1))
						action := Trim(action[1], " `t`n")

						for index, argument in arguments {
							argument := Trim(argument, " `t`n")

							if (argument = kTrue)
								arguments[index] := true
							else if (argument = kFalse)
								arguments[index] := false
							else if ((InStr(argument, "`"") = 1) && (StrLen(argument) > 1) && (SubStr(argument, StrLen(argument)) = "`""))
								arguments[index] := SubStr(argument, 2, StrLen(argument) - 2)
						}

						try {
							%action%(arguments*)
						}
						catch Any as exception {
							logError(exception, true)
						}
					}
				case "Speech":
					speak(action.Action)
				case "Audio":
					play(action.Action)
			}
		}
	}

	startPitstopSetup(pitstopNumber) {
	}

	finishPitstopSetup(pitstopNumber) {
		if this.RaceEngineer
			this.RaceEngineer.pitstopSetupFinished()
	}

	setPitstopRefuelAmount(pitstopNumber, liters, fillUp) {
	}

	setPitstopTyreCompound(pitstopNumber, tyreCompound, tyreCompoundColor := false, set := false) {
		local compounds := []
		local tyreService

		this.RequestedTyreCompounds := false

		if (this.supportsPitstop( , &tyreService) && tyreService) {
			if InStr(tyreCompound, ",") {
				tyreCompound := string2Values(",", tyreCompound)
				tyreCompoundColor := string2Values(",", tyreCompoundColor)
			}
			else if (tyreService = "Wheel") {
				tyreCompound := [tyreCompound, tyreCompound, tyreCompound, tyreCompound]
				tyreCompoundColor := [tyreCompoundColor, tyreCompoundColor, tyreCompoundColor, tyreCompoundColor]
			}
			else if (tyreService = "Axle") {
				tyreCompound := [tyreCompound, tyreCompound]
				tyreCompoundColor := [tyreCompoundColor, tyreCompoundColor]
			}
			else {
				tyreCompound := [tyreCompound]
				tyreCompoundColor := [tyreCompoundColor]
			}

			loop tyreCompound.Length
				compounds.Push(tyreCompound[A_Index] ? compound(tyreCompound[A_Index], tyreCompoundColor[A_Index]) : false)
		}

		this.RequestedTyreCompounds := compounds
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	setPitstopBrakeChange(pitstopNumber, change, frontBrakePads := false, rearBrakePads := false) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
	}

	requestPitstopDriver(pitstopNumber, driver) {
	}

	updateTyreCompound(data) {
		local mixedCompounds, tyreCompounds, index, axle, tyre

		if !getMultiMapValue(data, "Car Data", "TyreCompound", false) {
			if this.CurrentTyreCompounds {
				tyreCompounds := this.CurrentTyreCompounds

				if this.supportsTyreManagement(&mixedCompounds) {
					if ((mixedCompounds = "Axle") && (tyreCompounds.Length = 2)) {
						for index, axle in ["Front", "Rear"] {
							tyreCompound := "Dry"
							tyreCompoundColor := "Black"

							splitCompound(tyreCompounds[index], &tyreCompound, &tyreCompoundColor)

							setMultiMapValue(data, "Car Data", "TyreCompound" . axle, tyreCompound)
							setMultiMapValue(data, "Car Data", "TyreCompoundColor" . axle, tyreCompoundColor)

							if (index = 1) {
								setMultiMapValue(data, "Car Data", "TyreCompound", tyreCompound)
								setMultiMapValue(data, "Car Data", "TyreCompoundColor", tyreCompoundColor)
							}
						}

						return
					}
					else if ((mixedCompounds = "Wheel") && (tyreCompounds.Length = 4)) {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							tyreCompound := "Dry"
							tyreCompoundColor := "Black"

							splitCompound(tyreCompounds[index], &tyreCompound, &tyreCompoundColor)

							setMultiMapValue(data, "Car Data", "TyreCompound" . tyre, tyreCompound)
							setMultiMapValue(data, "Car Data", "TyreCompoundColor" . tyre, tyreCompoundColor)

							if (index = 1) {
								setMultiMapValue(data, "Car Data", "TyreCompound", tyreCompound)
								setMultiMapValue(data, "Car Data", "TyreCompoundColor", tyreCompoundColor)
							}
						}

						return
					}
					else if (tyreCompounds.Length = 1) {
						tyreCompound := "Dry"
						tyreCompoundColor := "Black"

						splitCompound(this.CurrentTyreCompounds[1], &tyreCompound, &tyreCompoundColor)

						setMultiMapValue(data, "Car Data", "TyreCompound", tyreCompound)
						setMultiMapValue(data, "Car Data", "TyreCompoundColor", tyreCompoundColor)

						return
					}
				}
				else if (tyreCompounds.Length = 1) {
					tyreCompound := "Dry"
					tyreCompoundColor := "Black"

					splitCompound(this.CurrentTyreCompounds[1], &tyreCompound, &tyreCompoundColor)

					setMultiMapValue(data, "Car Data", "TyreCompound", tyreCompound)
					setMultiMapValue(data, "Car Data", "TyreCompoundColor", tyreCompoundColor)

					return
				}
			}

			setMultiMapValue(data, "Car Data", "TyreCompound", "Dry")
			setMultiMapValue(data, "Car Data", "TyreCompoundColor", "Black")
		}
	}

	updateTelemetryData(data) {
		this.updateTyreCompound(data)

		if (this.Session != kSessionFinished) {
			this.Car := getMultiMapValue(data, "Session Data", "Car")
			this.Track := getMultiMapValue(data, "Session Data", "Track")
		}
	}

	updateStandingsData(data) {
		this.iHasStandingsData := (getMultiMapValue(data, "Position Data", "Car.Count", 0) > 0)
	}

	saveSessionState(&sessionSettings, &sessionState) {
		local mixedCompounds

		updateTyreCompound(compounds, type) {
			local index, axle, tyre, tyreCompound, tyreCompoundColor

			if compounds {
				if ((mixedCompounds = "Axle") && (compounds.Length = 2)) {
					for index, axle in ["Front", "Rear"] {
						tyreCompound := "Dry"
						tyreCompoundColor := "Black"

						splitCompound(compounds[index], &tyreCompound, &tyreCompoundColor)

						setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound." . axle, tyreCompound)
						setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound.Color." . axle, tyreCompoundColor)

						if (index = 1) {
							setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound", tyreCompound)
							setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound.Color", tyreCompoundColor)
						}
					}
				}
				else if ((mixedCompounds = "Wheel") && (compounds.Length = 4)) {
					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						tyreCompound := "Dry"
						tyreCompoundColor := "Black"

						splitCompound(compounds[index], &tyreCompound, &tyreCompoundColor)

						setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound." . tyre, tyreCompound)
						setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound.Color." . tyre, tyreCompoundColor)

						if (index = 1) {
							setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound", tyreCompound)
							setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound.Color", tyreCompoundColor)
						}
					}
				}
				else if (compounds.Length = 1) {
					tyreCompound := "Dry"
					tyreCompoundColor := "Black"

					splitCompound(compounds[1], &tyreCompound, &tyreCompoundColor)

					setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound", tyreCompound)
					setMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound.Color", tyreCompoundColor)
				}
			}
		}

		if !sessionSettings
			sessionSettings := newMultiMap()

		if this.supportsTyreManagement(&mixedCompounds) {
			updateTyreCompound(this.CurrentTyreCompounds, "Current")
			updateTyreCompound(this.RequestedTyreCompounds, "Requested")
		}
	}

	restoreSessionState(&sessionSettings, &sessionState) {
		local mixedCompounds

		updateTyreCompound(type) {
			local compounds := []
			local tyreCompound, index, axle, tyre

			if (mixedCompounds = "Axle") {
				for index, axle in ["Front", "Rear"] {
					tyreCompound := getMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound." . axle, false)

					if tyreCompound
						compounds.Push(compound(tyreCompound, getMultiMapValue(sessionSettings
																			 , "Simulator Settings", "Tyre." . type . ".Compound.Color." . axle)))
					else
						compounds.Push(false)
				}
			}
			else if (mixedCompounds = "Wheel") {
				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
					tyreCompound := getMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound." . tyre, false)

					if tyreCompound
						compounds.Push(compound(tyreCompound, getMultiMapValue(sessionSettings
																			 , "Simulator Settings", "Tyre." . type . ".Compound.Color." . tyre)))
					else
						compounds.Push(false)
				}
			}
			else {
				tyreCompound := getMultiMapValue(sessionSettings, "Simulator Settings", "Tyre." . type . ".Compound", false)

				if tyreCompound
					compounds.Push(compound(tyreCompound, getMultiMapValue(sessionSettings
																		 , "Simulator Settings", "Tyre." . type . ".Compound.Color")))
				else
					compounds.Push(false)
			}

			return compounds
		}

		if (sessionSettings && this.supportsTyreManagement(&mixedCompounds)) {
			this.CurrentTyreCompounds := updateTyreCompound("Current")
			this.RequestedTyreCompounds := updateTyreCompound("Requested")
		}
		else {
			this.CurrentTyreCompounds := false
			this.RequestedTyreCompounds := false
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

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

				return plugin.openPitstopMFD(descriptor)
			}
			else {
				plugin.resetPitstopMFD()

				return plugin.openPitstopMFD()
			}
		}
		finally {
			protectionOff()
		}
	}
	else
		return false
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