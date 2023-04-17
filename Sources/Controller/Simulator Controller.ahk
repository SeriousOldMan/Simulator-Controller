;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Controller            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Gear.ico
;@Ahk2Exe-ExeName Simulator Controller.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\SpeechRecognizer.ahk"
#Include "..\Plugins\Libraries\SimulatorPlugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLogoBright := kResourcesDirectory . "Logo Bright.gif"
global kLogoDark := kResourcesDirectory . "Logo Dark.gif"

global kAllTrigger := "__All Trigger__"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class FunctionController extends ConfigurationItem {
	iController := false

	iNum1WayToggles := 0
	iNum2WayToggles := 0
	iNumButtons := 0
	iNumDials := 0

	Controller {
		Get {
			return this.iController
		}
	}

	Descriptor {
		Get {
			return this.base.__Class
		}
	}

	Type {
		Get {
			return this.Descriptor
		}
	}

	Num1WayToggles {
		Get {
			return this.iNum1WayToggles
		}
	}

	Num2WayToggles {
		Get {
			return this.iNum2WayToggles
		}
	}

	NumButtons {
		Get {
			return this.iNumButtons
		}
	}

	NumDials {
		Get {
			return this.iNumDials
		}
	}

	__New(controller, configuration := false) {
		this.iController := controller

		super.__New(configuration)

		controller.registerFunctionController(this)
	}

	setControls(num1WayToggles, num2WayToggles, numButtons, numDials) {
		this.iNum1WayToggles := num1WayToggles
		this.iNum2WayToggles := num2WayToggles
		this.iNumButtons := numButtons
		this.iNumDials := numDials
	}

	hasFunction(function) {
		throw "Virtual method FunctionController.hasFunction must be implemented in a subclass..."
	}

	setControlLabel(function, text, color := "Black", overlay := false) {
	}

	setControlIcon(function, icon) {
	}

	connectAction(plugin, function, action) {
	}

	disconnectAction(plugin, function, action) {
	}

	enable(function, action := false) {
	}

	disable(function, action := false) {
	}
}

class GuiFunctionController extends FunctionController {
	static sGuiFunctionController := Map()

	iWindow := false
	iWindowWidth := 0
	iWindowHeight := 0

	iControlLabels := CaseInsenseMap()

	iIsVisible := false
	iIsPositioned := false

	Visible {
		Get {
			return this.iIsVisible
		}
	}

	VisibleDuration {
		Get {
			local controller := this.Controller
			local type

			if (controller != false) {
				type := this.Type

				return getMultiMapValue(this.Controller.Settings, type
									  , type . (controller.ActiveSimulator ? " Simulation Duration" : " Duration")
									  , false)
			}
			else
				return false
		}
	}

	__New(controller, configuration := false) {
		super.__New(controller, configuration)

		this.createGui()
	}

	createGui() {
		throw "Virtual method GuiFunctionController.createGui must be implemented in a subclass..."
	}

	associateGui(window, width, height, num1WayToggles, num2WayToggles, numButtons, numDials) {
		this.iWindow := window
		this.iWindowWidth := width
		this.iWindowHeight := height

		this.setControls(num1WayToggles, num2WayToggles, numButtons, numDials)

		GuiFunctionController.sGuiFunctionController[window] := this

		logMessage(kLogInfo, translate("Controller layout initialized:") . " #" . num1WayToggles . A_Space . translate("1-Way Toggles") . ", #" . num2WayToggles . A_Space . translate("2-Way Toggles") . ", #" . numButtons . A_Space . translate("Buttons") . ", #" . numDials . A_Space . translate("Dials"))
	}

	static findFunctionController(window) {
		if GuiFunctionController.sGuiFunctionController.Has(window)
			return GuiFunctionController.sGuiFunctionController[window]
		else
			return false
	}

	findFunctionController(window) {
		return GuiFunctionController.findFunctionController(window)
	}

	hasFunction(function) {
		return (this.getControlLabel(function.Descriptor) != false)
	}

	connectAction(plugin, function, action) {
		this.setControlLabel(function, plugin.actionLabel(action))
	}

	disconnectAction(plugin, function, action) {
		this.setControlLabel(function, "")
	}

	registerControlLabel(descriptor, label) {
		this.iControlLabels[descriptor] := label
	}

	getControlLabel(descriptor) {
		if this.iControlLabels.Has(descriptor)
			return this.iControlLabels[descriptor]
		else
			return false
	}

	setControlLabel(function, text, color := "Black", overlay := false) {
		local window := this.iWindow
		local label, font

		if (window != false) {
			label := this.getControlLabel(function.Descriptor)

			if (label != false) {
				font := ("s8 c" . color)

				if !label.HasOwnProp("Font")
					label.Font := false

				if ((label.Font != font) || (label.Text != text)) {
					label.SetFont("s8 c" . color, "Arial")
					label.Text := text
					label.Font := font

					this.show()
				}
			}
		}
	}

	updateVisibility() {
		this.Controller.updateLastEvent()

		this.show(false)
	}

	distanceFromTop() {
		local distance := 0
		local ignore, fnController

		for ignore, fnController in this.Controller.FunctionController[GuiFunctionController]
			if (fnController == this)
				return distance
			else
				distance += fnController.iWindowHeight

		throw "Internal error detected in GuiFunctionController.distanceFromTop..."
	}

	distanceFromBottom() {
		local distance := 0
		local controller := []
		local ignore, fnController, index

		for ignore, fnController in this.Controller.FunctionController[GuiFunctionController]
			controller.Push(fnController)

		index := controller.Length

		loop {
			fnController := controller[index]

			distance += fnController.iWindowHeight

			if (fnController == this)
				return distance
		}
		until (--index = 0)

		throw "Internal error detected in GuiFunctionController.distanceFromBottom..."
	}

	show(makeVisible := true) {
		local duration, window, width, height, type, position, x, y, count
		local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom
		local secondScreen, secondScreenLeft, secondScreenRight, secondScreenTop, secondScreenBottom

		static hideTask := false

		if !this.Controller.Started
			return

		duration := this.VisibleDuration

		if (duration >= 9999)
			duration := 24 * 3600 * 1000 ; Show always - one day should be enough :-)

		if (duration > 0) {
			if ((A_TickCount - this.Controller.LastEvent) > duration)
				return
			else {
				if !hideTask {
					hideTask := PeriodicTask(hideFunctionController, duration, kLowPriority)

					hideTask.start()
				}

				hideTask.Sleep := duration
			}

			protectionOn()

			try {
				if makeVisible {
					this.Controller.hideLogo()

					window := this.iWindow
					width := this.iWindowWidth
					height := this.iWindowHeight

					if this.iIsPositioned
						window.Show("NoActivate")
					else {
						type := this.Type

						position := getMultiMapValue(this.Controller.Settings, type, type . " Position", "Bottom Right")

						MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

						count := MonitorGetCount()

						if (InStr(position, "Screen") && (count = 1))
							position := "Last Position"

						switch position, false {
							case "Top Left":
								x := mainScreenLeft
								y := mainScreenTop + this.distanceFromTop()
							case "Top Right":
								x := mainScreenRight - width
								y := mainScreenTop + this.distanceFromTop()
							case "Bottom Left":
								x := mainScreenLeft
								y := mainScreenBottom - this.distanceFromBottom()
							case "Bottom Right":
								x := mainScreenRight - width
								y := mainScreenBottom - this.distanceFromBottom()
							case "Secondary Screen", "2nd Screen":
								MonitorGetWorkArea(2, &secondScreenLeft, &secondScreenTop, &secondScreenRight, &secondScreenBottom)

								x := Round(secondScreenLeft + ((secondScreenRight - secondScreenLeft - width) / 2))
								y := Round(secondScreenTop + ((secondScreenBottom - secondScreenTop - height) / 2))
							case "Last Position":
								x := getMultiMapValue(this.Controller.Settings, type, this.Descriptor . ".Position.X", mainScreenRight - width)
								y := getMultiMapValue(this.Controller.Settings, type, this.Descriptor . ".Position.Y", mainScreenBottom - height)
							default:
								throw "Unhandled position for " . type " (" . position . ") encountered in GuiFunctionController.show..."
						}

						window.Show("x" . x . " y" . y . " w" . width . " h" . height . " NoActivate")

						this.iIsPositioned := true
					}

					this.iIsVisible := true
				}
			}
			finally {
				protectionOff()
			}
		}
		else
			this.hide()
	}

	hide() {
		protectionOn()

		try {
			if this.Visible {
				this.iWindow.Hide()

				this.iIsVisible := false
			}
		}
		finally {
			protectionOff()
		}
	}

	moveByMouse(window, *) {
		local curCoordMode := A_CoordModeMouse
		local anchorX, anchorY, winX, winY, newX, newY, x, y, w, h, settings

		CoordMode("Mouse", "Screen")

		try {
			MouseGetPos(&anchorX, &anchorY)
			WinGetPos(&winX, &winY, &w, &h, "A")

			newX := winX
			newY := winY

			while GetKeyState("LButton", "P") {
				MouseGetPos(&x, &y)

				newX := winX + (x - anchorX)
				newY := winY + (y - anchorY)

				window.Show("X" . newX . " Y" . newY)
			}

			settings := readMultiMap(kSimulatorSettingsFile)

			setMultiMapValue(settings, this.Type, this.Descriptor . ".Position.X", newX)
			setMultiMapValue(settings, this.Type, this.Descriptor . ".Position.Y", newY)

			writeMultiMap(kSimulatorSettingsFile, settings)

			this.Controller.reloadSettings(settings)
		}
		finally {
			CoordMode("Mouse", curCoordMode)
		}
	}
}

class SimulatorController extends ConfigurationItem {
	iID := false

	iStarted := false

	iSettings := false

	iPlugins := []
	iFunctions := CaseInsenseMap()
	iFunctionController := []

	iModes := []
	iActiveModes := []

	iFunctionActions := CaseInsenseMap()

	iVoiceServer := false
	iVoiceCommands := CaseInsenseMap()

	iLastEvent := A_TickCount

	iShowLogo := false
	iLogoGui := false
	iLogoIsVisible := false

	ID {
		Get {
			return this.iID
		}
	}

	Settings {
		Get {
			return this.iSettings
		}
	}

	Started {
		Get {
			return this.iStarted
		}
	}

	VoiceServer {
		Get {
			return this.iVoiceServer
		}
	}

	FunctionController[class := false] {
		Get {
			local controller, ignore, fnController

			if class {
				controller := []

				for ignore, fnController in this.iFunctionController
					if isInstance(fnController, class)
						controller.Push(fnController)

				return controller
			}
			else
				return this.iFunctionController
		}
	}

	Functions {
		Get {
			return this.iFunctions
		}
	}

	Plugins {
		Get {
			return this.iPlugins
		}
	}

	Modes {
		Get {
			return this.iModes
		}
	}

	ActiveMode[controller := false] {
		Get {
			local activeModes := this.ActiveModes
			local ignore, mode

			if controller {
				for ignore, mode in activeModes
					if inList(mode.FunctionController, controller)
						return mode

				return false
			}
			else
				return ((activeModes.Length > 0) ? activeModes[1] : false)
		}
	}

	ActiveModes {
		Get {
			return this.iActiveModes
		}
	}

	ActiveSimulator {
		Get {
			return this.runningSimulator()
		}
	}

	LastEvent {
		Get {
			return this.iLastEvent
		}
	}

	__New(configuration, settings, voiceServer := false) {
		identifier := FileRead(kUserConfigDirectory . "ID")

		this.iID := identifier

		SimulatorController.Controller := this

		this.iSettings := settings
		this.iVoiceServer := voiceServer

		SimulatorController.Instance := this

		super.__New(configuration)

		if !inList(A_Args, "-NoStartup")
			this.initializeBackgroundTasks()
	}

	loadFromConfiguration(configuration) {
		local descriptor, arguments, functions

		super.loadFromConfiguration(configuration)

		for descriptor, arguments in getMultiMapValues(configuration, "Controller Functions") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			descriptor := ConfigurationItem.descriptor(descriptor[1], descriptor[2])

			functions := this.Functions

			if !functions.Has(descriptor)
				functions[descriptor] := this.createControllerFunction(descriptor, configuration)
		}
	}

	reloadSettings(settings) {
		this.iSettings := settings
	}

	createControllerFunction(descriptor, configuration) {
		descriptor := ConfigurationItem.splitDescriptor(descriptor)

		switch descriptor[1], false {
			case k2WayToggleType:
				return ControllerTwoWayToggleFunction(this, descriptor[2], configuration)
			case k1WayToggleType:
				return ControllerOneWayToggleFunction(this, descriptor[2], configuration)
			case kButtonType:
				return ControllerButtonFunction(this, descriptor[2], configuration)
			case kDialType:
				return ControllerDialFunction(this, descriptor[2], configuration)
			case kCustomType:
				return ControllerCustomFunction(this, descriptor[2], configuration)
			default:
				throw "Unknown controller function type (" . descriptor[1] . ") detected in SimulatorController.createControllerFunction..."
		}
	}

	findPlugin(name) {
		local ignore, plugin

		for ignore, plugin in this.Plugins
			if (plugin.Plugin = name)
				return plugin

		return false
	}

	findMode(plugin, name) {
		local ignore, mode

		if !isObject(plugin)
			plugin := this.findPlugin(plugin)

		for ignore, mode in this.Modes
			if ((mode.Mode = name) && (mode.Plugin == plugin))
				return mode

		return false
	}

	findFunction(descriptor) {
		local functions := this.Functions

		return (functions.Has(descriptor) ? functions[descriptor] : false)
	}

	getActions(function, trigger) {
		return (this.iFunctionActions.Has(function) ? this.iFunctionActions[function] : [])
	}

	getLogo() {
		local rnd

		rnd := Random(0, 1)

		return ((Round(rnd) == 1) ? kLogoDark : kLogoBright)
	}

	registerFunctionController(controller) {
		if !inList(this.FunctionController, controller)
			this.FunctionController.Push(controller)
	}

	unregisterFunctionController(controller) {
		local index := inList(this.FunctionController, controller)

		if index {
			controller.hide()

			this.FunctionController.RemoveAt(index)
		}
	}

	findFunctionController(function) {
		local ignore, fnController

		for ignore, fnController in this.FunctionController
			if fnController.hasFunction(function)
				return fnController

		return false
	}

	registerPlugin(plugin) {
		if !inList(this.Plugins, plugin) {
			logMessage(kLogInfo, translate("Plugin ") . translate(getPluginForLogMessage(plugin)) . (this.isActive(plugin) ? translate(" (Active)") : translate(" (Inactive)")) . translate(" registered"))

			this.Plugins.Push(plugin)
		}

		if this.isActive(plugin)
			plugin.activate()
	}

	registerMode(plugin, mode) {
		if !inList(this.Modes, mode) {
			logMessage(kLogInfo, translate("Mode ") . translate(getModeForLogMessage(mode)) . translate(" registered") . (plugin ? (translate(" for plugin ") . translate(getPluginForLogMessage(plugin))) : ""))

			this.Modes.Push(mode)
		}
	}

	startup() {
		local ignore, fnController

		this.iStarted := true

		this.setModes()

		for ignore, fnController in this.FunctionController[GuiFunctionController]
			if fnController.VisibleDuration >= 9999
				fnController.show()
	}

	computeControllerModes() {
		local function, ignore, mode, action, fnController, controllers

		for ignore, mode in this.Modes {
			controllers := []

			for ignore, action in mode.Actions {
				fnController := this.findFunctionController(action.Function)

				if (fnController && !inList(controllers, fnController)) {
					controllers.Push(fnController)

					mode.registerFunctionController(fnController)
				}
			}
		}
	}

	isActive(modeOrPlugin) {
		return isDebug() ? true : modeOrPlugin.isActive()
	}

	registerActiveMode(mode) {
		if !inList(this.iActiveModes, mode)
			this.iActiveModes.Push(mode)
	}

	unregisterActiveMode(mode) {
		local position := inList(this.iActiveModes, mode)

		while position {
			this.iActiveModes.RemoveAt(position)

			position := inList(this.iActiveModes, mode)
		}
	}

	runningSimulator(&plugin := false) {
		local ignore, thePlugin, simulator

		static lastSimulator := false
		static lastPlugin := false
		static lastCheck := 0

		if (A_TickCount > (lastCheck + 10000)) {
			lastSimulator := false
			lastPlugin := false

			for ignore, thePlugin in this.Plugins
				if this.isActive(thePlugin) {
					simulator := thePlugin.runningSimulator()

					if (simulator != false) {
						lastSimulator := simulator
						lastPlugin := thePlugin

						break
					}
				}

			lastCheck := A_TickCount
		}

		plugin := lastPlugin

		return lastSimulator
	}

	simulatorStartup(simulator) {
		local ignore, thePlugin, fnController

		for ignore, thePlugin in this.Plugins
			if this.isActive(thePlugin)
				thePlugin.simulatorStartup(simulator)

		for ignore, fnController in this.FunctionController[GuiFunctionController] {
			fnController.hide()
			fnController.show()
		}
	}

	simulatorShutdown(simulator) {
		local ignore, thePlugin, fnController

		for ignore, thePlugin in this.Plugins
			if this.isActive(thePlugin)
				thePlugin.simulatorShutdown(simulator)

		for ignore, fnController in this.FunctionController[GuiFunctionController] {
			fnController.hide()
			fnController.show()
		}
	}

	startSimulator(application, splashImage := false) {
		local theme, songFile, name, started

		if !application.isRunning()
			if (application.startup(false))
				if (!kSilentMode && splashImage) {
					protectionOff()

					try {
						showSplash(splashImage)

						theme := getMultiMapValue(this.Settings, "Startup", "Splash Theme", false)
						songFile := (theme ? getMultiMapValue(this.Configuration, "Splash Themes", theme . ".Song", false) : false)

						if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)))
							messageSend(kLocalMessage, "Startup", "playStartupSong:" . songFile)

						name := application.Application

						showProgress({message: name, title: translate("Starting Simulator")})

						started := false

						loop {
							if (A_Index >= 100)
								break

							showProgress({progress: A_Index})

							if (!started && application.isRunning())
								started := true

							Sleep(started ? 10 : 100)
						}

						hideProgress()
					}
					finally {
						protectionOn()

						hideSplash()
					}
				}

		return application.CurrentPID
	}

	getVoiceCommandDescriptor(command) {
		local descriptor, pid, activationCommand

		static registered := false
		static registeredCommands := false

		if !registeredCommands
			registeredCommands := CaseInsenseMap()

		if this.iVoiceCommands.Has(command)
			return this.iVoiceCommands[command]
		else {
			descriptor := Array(command, [])

			this.iVoiceCommands[command] := descriptor

			if this.VoiceServer {
				pid := ProcessExist()

				if !registered {
					activationCommand := getMultiMapValue(this.Configuration, "Voice Control", "ActivationCommand", false)

					messageSend(kFileMessage, "Voice", "registerVoiceClient:" . values2String(";", "Controller", "Controller", pid
																								 , activationCommand, "activationCommand", false
																								 , false, false, false, true, true)
							  , this.VoiceServer)

					registered := true
				}

				if !registeredCommands.Has(command) {
					messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", "Controller", false, command, "voiceCommand"), this.VoiceServer)

					registeredCommands[command] := true
				}
			}

			return descriptor
		}
	}

	activationCommand(words*) {
		static first := true

		if first
			first := false
		else
			SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")
	}

	voiceCommand(grammar, command, words*) {
		local ignore, handler

		for ignore, handler in this.iVoiceCommands[command][2]
			handler.Call()
	}

	enableVoiceCommand(command, handler) {
		local handlers := this.getVoiceCommandDescriptor(command)[2]

		if !inList(handlers, handler)
			handlers.Push(handler)
	}

	disableVoiceCommand(command, handler) {
		local handlers := this.getVoiceCommandDescriptor(command)[2]
		local index := inList(handlers, handler)

		if index
			handlers.RemoveAt(index)
	}

	connectAction(plugin, function, action) {
		local ignore, fnController

		logMessage(kLogInfo, translate("Connecting ") . function.Descriptor . translate(" to action ") . translate(getLabelForLogMessage(action)))

		function.connectAction(plugin, action)

		action.connectFunction(plugin, function)

		if !this.iFunctionActions.Has(function)
			this.iFunctionActions[function] := Array()

		this.iFunctionActions[function].Push(action)

		for ignore, fnController in this.FunctionController
			if fnController.hasFunction(function)
				fnController.connectAction(plugin, function, action)
	}

	disconnectAction(plugin, function, action) {
		local index, ignore, fnController

		logMessage(kLogInfo, translate("Disconnecting ") . function.Descriptor . translate(" from action ") . translate(getLabelForLogMessage(action)))

		function.disconnectAction(plugin, action)

		action.disconnectFunction(plugin, function)

		index := inList(this.iFunctionActions[function], action)

		while index {
			this.iFunctionActions[function].RemoveAt(index)

			index := inList(this.iFunctionActions[function], action)
		}

		for ignore, fnController in this.FunctionController
			if fnController.hasFunction(function)
				fnController.disconnectAction(plugin, function, action)
	}

	updateLastEvent() {
		this.iLastEvent := A_TickCount
	}

	fireActions(function, trigger) {
		local ignore, action

		for ignore, action in this.getActions(function, trigger)
			if function.Enabled[action]
				if (action != false) {
					this.updateLastEvent()

					logMessage(kLogInfo, translate("Firing action ") . getLabelForLogMessage(action) . translate(" for ") . function.Descriptor)

					action.fireAction(function, trigger)
				}
				else
					throw "Cannot find action for " . function.Descriptor . ".trigger " . " in SimulatorController.fireAction..."
	}

	setMode(newMode) {
		local modeSwitched, controllers, deactivatedModes, ignore, mode, controller

		if !this.isActive(newMode)
			return

		modeSwitched := !inList(this.ActiveModes, newMode)

		if modeSwitched {
			controllers := (newMode ? newMode.FunctionController : [])

			deactivatedModes := []

			for ignore, mode in this.ActiveModes
				for ignore, controller in mode.FunctionController
					if (inList(controllers, controller) && !inList(deactivatedModes, mode))
						deactivatedModes.Push(mode)

			for ignore, mode in deactivatedModes
				mode.deactivate()

			if (newMode != false)
				newMode.activate()

			if modeSwitched
				trayMessage(translate("Controller"), translate("Mode: ") . translate(newMode.Mode))
		}
	}

	rotateMode(delta := 1, controller := false) {
		local startMode := false
		local modes := this.Modes
		local position := false
		local ignore, mode, fnController, modeController, position, targetMode, index, found

		if controller {
			for ignore, mode in this.ActiveModes {
				for ignore, fnController in controller {
					for ignore, modeController in mode.FunctionController
						if (fnController == modeController) {
							position := inList(modes, mode)

							if position
								break
						}

					if position
						break
				}

				if position
					break
			}
		}
		else
			position := inList(modes, this.ActiveModes[1])

		if !position
			position := 1

		targetMode := false
		index := position + delta

		loop {
			if (index > modes.Length)
				index := 1
			else if (index < 1)
				index := modes.Length

			targetMode := modes[index]

			if startMode {
				if (startMode == targetMode)
					return
			}
			else
				startMode := targetMode

			if !this.isActive(targetMode) {
				index += delta
				targetMode := false
			}
			else if controller {
				found := false

				for ignore, modeController in targetMode.FunctionController
					if inList(controller, modeController) {
						found := true

						break
					}

				if !found {
					index += delta
					targetMode := false
				}
			}
		}
		until targetMode

		this.setMode(targetMode)
	}

	setModes(simulator := false, session := false) {
		local modes := false
		local ignore, theMode

		if !simulator
			modes := getMultiMapValue(this.Settings, "Modes", "Default", "")
		else {
			modes := getMultiMapValue(this.Settings, "Modes", ConfigurationItem.descriptor(simulator, session), "")

			if (StrLen(Trim(modes)) = 0)
				modes := getMultiMapValue(this.Settings, "Modes", ConfigurationItem.descriptor(simulator, "Default"), "")
		}

		if (StrLen(Trim(modes)) != 0)
			for ignore, theMode in string2Values(",", modes) {
				theMode := ConfigurationItem.splitDescriptor(theMode)

				theMode := this.findMode(theMode[1], theMode[2])

				if theMode
					this.setMode(theMode)
			}
	}

	showLogo(show := kUndefined) {
		local info, x, y, html, videoPlayer
		local mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom
		local logoGui

		if (show != kUndefined)
			this.iShowLogo := show
		else if (this.iShowLogo && !this.iLogoIsVisible) {
			info := kVersion . " - 2023, Oliver Juwig`nCreative Commons - BY-NC-SA"

			MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

			x := mainScreenRight - 229
			y := mainScreenBottom - 259

			logoGui := Window()

			logoGui.SetFont("Bold")
			logoGui.AddText("w200 Center", translate("Modular Simulator") . "`n" . translate("Controller System"))

			videoPlayer := logoGui.Add("ActiveX", "x10 y40 w209 h180", "shell explorer").Value

			logoGui.SetFont("Norm")
			logoGui.AddText("w200 Center", info)

			videoPlayer.navigate("about:blank")

			html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . this.getLogo() . "' width=209 height=180 border=0 padding=0></body></html>"

			videoPlayer.document.write(html)

			logoGui.Show("X" . x . " Y" . y . " W239 H259")

			WinSetTransparent(255, , translate("Creative Commons - BY-NC-SA"))

			this.iLogoGui := logoGui
			this.iLogoIsVisible := true
		}
	}

	hideLogo() {
		if this.iLogoIsVisible {
			this.iLogoGui.Destroy()
			this.iLogoGui := false

			this.iLogoIsVisible := false
		}
	}

	initializeBackgroundTasks() {
		PeriodicTask(updateSimulatorState, 10000, kLowPriority).start()
		PeriodicTask(externalCommandManager, 100, kLowPriority).start()

		this.iShowLogo := (this.iShowLogo && !kSilentMode)
	}

	writeControllerState(periodic := true) {
		local plugins := CaseInsenseMap()
		local controller, configuration, ignore, thePlugin, modes, states, name, theMode, simulators, simulator, fnController

		configuration := newMultiMap()

		try {
			for ignore, thePlugin in this.Plugins {
				plugins[thePlugin.Plugin] := true

				if (this.isActive(thePlugin)) {
					modes := []

					if isInstance(thePlugin, SimulatorPlugin) {
						states := []

						for ignore, name in thePlugin.Sessions[true]
							states.Push(name)

						setMultiMapValue(configuration, "Simulators", thePlugin.Simulator.Application
									   , thePlugin.Plugin . "|" . values2String(",", states*))
					}

					for ignore, theMode in thePlugin.Modes
						modes.Push(theMode.Mode)

					simulators := []

					for ignore, simulator in thePlugin.Simulators
						simulators.Push(simulator)

					setMultiMapValue(configuration, "Plugins", thePlugin.Plugin
								   , values2String("|", (this.isActive(thePlugin) ? kTrue : kFalse)
								   , values2String(",", simulators*), values2String(",", modes*)))
				}

				thePlugin.writePluginState(configuration)
			}

			setMultiMapValue(configuration, "Modules", "Plugins", values2String("|", getKeys(plugins)*))

			for ignore, fnController in this.FunctionController
				setMultiMapValue(configuration, fnController.Type, fnController.Descriptor
							   , values2String(",", fnController.Num1WayToggles, fnController.Num2WayToggles
							   , fnController.NumButtons, fnController.NumDials))
		}
		catch Any as exception {
			logError(exception)
		}

		writeMultiMap(kTempDirectory . "Simulator Controller.state", configuration)

		if periodic
			Task.CurrentTask.Sleep := (ProcessExist("System Monitor.exe") ? 2000 : 60000)
	}
}

class ControllerFunction {
	iController := false
	iFunction := false

	iEnabledActions := CaseInsenseMap()
	iCachedActions := CaseInsenseMap()

	Controller {
		Get {
			return this.iController
		}
	}

	Function {
		Get {
			return this.iFunction
		}
	}

	Type {
		Get {
			return this.Function.Type
		}
	}

	Number {
		Get {
			return this.Function.Number
		}
	}

	Descriptor {
		Get {
			return this.Function.Descriptor
		}
	}

	Enabled[action := false] {
		Get {
			if action
				return this.iEnabledActions.Has(action)
			else
				return (this.iEnabledActions.Count > 0)
		}
	}

	Hotkeys[trigger := false] {
		Get {
			return this.Function.Hotkeys[trigger]
		}
	}

	Trigger {
		Get {
			return this.Function.Trigger
		}
	}

	Actions[trigger := false] {
		Get {
			if this.iCachedActions.Has(trigger)
				return this.iCachedActions[trigger]
			else
				return (this.iCachedActions[trigger] := this.Function.Actions[trigger])
		}
	}

	__New(controller, function) {
		this.iController := controller
		this.iFunction := function
	}

	setLabel(text, color := "Black", overlay := false) {
		local controller, ignore, fnController

		for ignore, fnController in this.Controller.FunctionController
			if fnController.hasFunction(this)
				fnController.setControlLabel(this, text, color, overlay)
	}

	setIcon(icon) {
		local controller, ignore, fnController

		for ignore, fnController in this.Controller.FunctionController
			if fnController.hasFunction(this)
				fnController.setControlIcon(this, icon)
	}

	enable(trigger := "__All Trigger__", action := false) {
		local ignore, fnController

		this.iEnabledActions[action] := true

		for ignore, fnController in this.Controller.FunctionController
			fnController.enable(this, action)

		if (trigger == kAllTrigger) {
			for ignore, trigger in this.Trigger
				setHotkeyEnabled(this, trigger, true)
		}
		else
			setHotkeyEnabled(this, trigger, true)
	}

	disable(trigger := "__All Trigger__", action := false) {
		local ignore, fnController

		if this.iEnabledActions.Has(action)
			this.iEnabledActions.Delete(action)

		for ignore, fnController in this.Controller.FunctionController
			fnController.disable(this, action)

		if !this.Enabled
			if (trigger == kAllTrigger) {
				for ignore, trigger in this.Trigger
					setHotkeyEnabled(this, trigger, false)
			}
			else
				setHotkeyEnabled(this, trigger, false)
	}

	connectAction(plugin, action) {
		local controller := this.Controller
		local ignore, trigger, handler, ignore, theHotkey, command

		this.iEnabledActions[action] := true

		for ignore, trigger in this.Trigger {
			handler := this.Actions[trigger]

			for ignore, theHotkey in this.Hotkeys[trigger] {
				try {
					if (SubStr(theHotkey, 1, 1) = "?") {
						if !handler
							throw "Action " . this.Actions[trigger, true] . " cannot be found..."

						command := SubStr(theHotkey, 2)

						controller.enableVoiceCommand(command, handler)

						logMessage(kLogInfo, translate("Binding voice command ") . command . translate(" for trigger ") . trigger . translate(" to ") . (action ? (action.base.__Class . ".fireAction") : this.Function.Actions[trigger, true]))
					}
					else {
						if theHotkey = ""
							MsgBox ("Oops")
						Hotkey(theHotkey, handler, "On")

						logMessage(kLogInfo, translate("Binding hotkey ") . theHotkey . translate(" for trigger ") . trigger . translate(" to ") . (action ? (action.base.__Class . ".fireAction")
																																						   : this.Function.Actions[trigger, true]))
					}
				}
				catch Any as exception {
					logMessage(kLogCritical, translate("Error while registering hotkey ") . theHotkey . translate(" - please check the configuration"))

					showMessage(substituteVariables(translate("Cannot register hotkey %hotkey% - please check the configuration..."), {hotKey: theHotKey})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}

	disconnectAction(plugin, action) {
		local controller := this.Controller
		local ignore, trigger, theHotkey, handler

		if this.iEnabledActions.Has(action)
			this.iEnabledActions.Delete(action)

		for ignore, trigger in this.Trigger {
			handler := this.Actions[trigger]

			for ignore, theHotkey in this.Hotkeys[trigger] {
				if (SubStr(theHotkey, 1, 1) = "?")
					controller.disableVoiceCommand(SubStr(theHotkey, 2), handler)
				else
					try {
						Hotkey(theHotkey, "Off")
					}
					catch Any as exception {
						logError(exception, false, false)
					}
			}
		}
	}
}

class ControllerOneWayToggleFunction extends ControllerFunction {
	class InnerOneWayToggleFunction extends OneWayToggleFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			super.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, super.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		super.__New(controller, ControllerOneWayToggleFunction.InnerOneWayToggleFunction(this, number, configuration))
	}
}

class ControllerTwoWayToggleFunction extends ControllerFunction {
	class InnerTwoWayToggleFunction extends TwoWayToggleFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			super.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, super.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		super.__New(controller, ControllerTwoWayToggleFunction.InnerTwoWayToggleFunction(this, number, configuration))
	}
}

class ControllerButtonFunction extends ControllerFunction {
	class InnerButtonFunction extends ButtonFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			super.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, super.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		super.__New(controller, ControllerButtonFunction.InnerButtonFunction(this, number, configuration))
	}
}

class ControllerDialFunction extends ControllerFunction {
	class InnerDialFunction extends DialFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			super.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, super.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		super.__New(controller, ControllerDialFunction.InnerDialFunction(this, number, configuration))
	}
}

class ControllerCustomFunction extends ControllerFunction {
	class InnerCustomFunction extends CustomFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			super.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			local callable := super.actionCallable(trigger, action)

			return (callable ? functionActionCallable(this.iOuterFunction, trigger, callable) : false)
		}
	}

	__New(controller, number, configuration := false) {
		super.__New(controller, ControllerCustomFunction.InnerCustomFunction(this, number, configuration))

		this.connectAction(false, false)
	}
}

class ControllerPlugin extends Plugin {
	static sLabelsDatabase := false
	static sIconsDatabase := false

	iController := false
	iModes := []
	iActions := []

	Controller {
		Get {
			return this.iController
		}
	}

	Modes {
		Get {
			return this.iModes
		}
	}

	Actions {
		Get {
			return this.iActions
		}
	}

	__New(controller, name, configuration := false, register := true) {
		this.iController := controller

		super.__New(name, configuration)

		if (this.Active || isDebug())
			if register
				controller.registerPlugin(this)
	}

	findMode(name) {
		local ignore, mode

		for ignore, mode in this.Modes
			if (mode.Mode = name)
				return mode

		return false
	}

	findAction(label) {
		local ignore, candidate

		for ignore, candidate in this.Actions
			if (candidate.Label = label)
				return candidate

		return false
	}

	registerMode(mode) {
		if !inList(this.Modes, mode)
			this.Modes.Push(mode)

		if (this.Controller != false)
			this.Controller.registerMode(this, mode)
	}

	registerAction(action) {
		if !inList(this.Actions, action)
			this.Actions.Push(action)
	}

	actionLabel(action) {
		return action.Label
	}

	actionIcon(action) {
		return action.Icon
	}

	isActive() {
		return this.Active
	}

	activate() {
		local controller := this.Controller
		local ignore, theAction

		logMessage(kLogInfo, translate("Activating plugin ") . translate(this.Plugin))

		for ignore, theAction in this.Actions {
			controller.connectAction(this, theAction.Function, theAction)

			theAction.Function.enable(kAllTrigger, theAction)
		}
	}

	deactivate() {
		local controller := this.Controller
		local ignore, theAction

		logMessage(kLogInfo, translate("Deactivating plugin ") . translate(this.Plugin))

		for ignore, theAction in this.Actions
			controller.disconnectAction(this, theAction.Function, theAction)
	}

	runningSimulator() {
		return false
	}

	simulatorStartup(simulator) {
	}

	simulatorShutdown(simulator) {
	}

	getLabel(descriptor, default := false) {
		local label

		if !ControllerPlugin.sLabelsDatabase
			ControllerPlugin.sLabelsDatabase := getControllerActionLabels()

		label := getMultiMapValue(ControllerPlugin.sLabelsDatabase, this.Plugin, descriptor, false)

		if (!label || (label == ""))
			label := default

		return label
	}

	getIcon(descriptor, default := false) {
		local icon

		if !ControllerPlugin.sIconsDatabase
			ControllerPlugin.sIconsDatabase := getControllerActionIcons()

		icon := getMultiMapValue(ControllerPlugin.sIconsDatabase, this.Plugin, descriptor, false)

		if (!icon || (icon == ""))
			icon := default

		return icon
	}

	logFunctionNotFound(functionDescriptor) {
		logMessage(kLogWarn, translate("Controller function ") . functionDescriptor . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	writePluginState(configuration) {
		setMultiMapValue(configuration, this.Plugin, "State", this.Active ? "Passive" : "Disabled")
	}
}

class ControllerMode {
	iPlugin := false
	iActions := []

	iFunctionController := []

	Mode {
		Get {
			throw "Virtual property ControllerMode.Mode must be implemented in a subclass..."
		}
	}

	Plugin {
		Get {
			return this.iPlugin
		}
	}

	Controller {
		Get {
			return this.Plugin.Controller
		}
	}

	Actions {
		Get {
			return this.iActions
		}
	}

	FunctionController {
		Get {
			return this.iFunctionController
		}
	}

	__New(plugin) {
		this.iPlugin := plugin

		plugin.registerMode(this)
	}

	registerAction(action) {
		if !inList(this.Actions, action)
			this.Actions.Push(action)
	}

	registerFunctionController(controller) {
		if !inList(this.FunctionController, controller)
			this.FunctionController.Push(controller)
	}

	findAction(label) {
		local ignore, candidate

		for ignore, candidate in this.Actions
			if (candidate.Label = label)
				return candidate

		return false
	}

	actionLabel(action) {
		return this.Plugin.actionLabel(action)
	}

	actionIcon(action) {
		return this.Plugin.actionIcon(action)
	}

	isActive() {
		local simulators, simulator

		if this.Plugin.isActive() {
			simulators := this.Plugin.Simulators

			if (simulators.Length == 0)
				return true
			else {
				simulator := this.Controller.ActiveSimulator

				return (simulator ? inList(simulators, simulator) : false)
			}
		}
		else
			return false
	}

	activate() {
		local plugin := this.Plugin
		local controller := this.Controller
		local ignore, theAction

		logMessage(kLogInfo, translate("Activating mode ") . translate(getModeForLogMessage(this)))

		for ignore, theAction in this.Actions {
			controller.connectAction(plugin, theAction.Function, theAction)

			theAction.Function.enable(kAllTrigger, theAction)
		}

		controller.registerActiveMode(this)
	}

	deactivate() {
		local plugin := this.Plugin
		local controller := this.Controller
		local ignore, theAction

		controller.unregisterActiveMode(this)

		logMessage(kLogInfo, translate("Deactivating mode ") . translate(getModeForLogMessage(this)))

		for ignore, theAction in this.Actions {
			theAction.Function.disable(kAllTrigger, theAction)

			controller.disconnectAction(plugin, theAction.Function, theAction)
		}
	}
}

class ControllerAction {
	iFunction := false
	iLabel := ""
	iIcon := false

	Function {
		Get {
			return this.iFunction
		}
	}

	Controller {
		Get {
			return this.Function.Controller
		}
	}

	Label {
		Get {
			return this.iLabel
		}
	}

	Icon {
		Get {
			return this.iIcon
		}
	}

	__New(function, label := "", icon := false) {
		this.iFunction := function
		this.iLabel := label
		this.iIcon := icon
	}

	fireAction(function, trigger) {
		throw "Virtual method ControllerAction.fireAction must be implemented in a subclass..."
	}

	connectFunction(plugin, function) {
	}

	disconnectFunction(pluginOrMode, function) {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

hideFunctionController() {
	local ignore, fnController

	for ignore, fnController in SimulatorController.Instance.FunctionController[GuiFunctionController]
		fnController.hide()
}

setHotkeyEnabled(function, trigger, enabled) {
	local controller := SimulatorController.Instance
	local state := enabled ? "On" : "Off"
	local ignore, theHotKey

	for ignore, theHotkey in function.Hotkeys[trigger]
		if (SubStr(theHotkey, 1, 1) = "?") {
			if enabled
				controller.enableVoiceCommand(SubStr(theHotkey, 2), function.Actions[trigger])
			else
				controller.disableVoiceCommand(SubStr(theHotkey, 2), function.Actions[trigger])
		}
		else
			try {
				Hotkey(theHotkey, state)
			}
			catch Any as exception {
				logMessage(kLogCritical, translate("Error while registering hotkey ") . theHotkey . translate(" - please check the configuration"))

				showMessage(substituteVariables(translate("Cannot register hotkey %hotkey% - please check the configuration..."), {hotKey: theHotKey})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			}
}

functionActionCallable(function, trigger, action) {
	local handler := (action ? action : fireControllerActions.Bind(function, trigger))

	actionCallable(*) {
		handler.Call()
	}

	return (handler ? actionCallable : false)
}

fireControllerActions(function, trigger, fromTask := false) {
	local callable

	static pending := false

	protectionOn(true, true)

	try {
		if pending
			pending.Push(ObjBindMethod(function.Controller, "fireActions", function, trigger))
		else if fromTask {
			pending := []

			try {
				function.Controller.fireActions(function, trigger)

				while (pending.Length > 0) {
					callable := pending.RemoveAt(1)

					callable.Call()
				}
			}
			finally {
				pending := false
			}
		}
		else
			Task.startTask(fireControllerActions.Bind(function, trigger, true), 0, kLowPriority)
	}
	finally {
		protectionOff(true, true)
	}

	return false
}

getLabelForLogMessage(action) {
	local label := action.Label

	if (label == "")
		label := action.base.__Class

	return StrReplace(StrReplace(label, "`n", A_Space), "`r", "")
}

getPluginForLogMessage(plugin) {
	plugin := plugin.Plugin

	if (plugin == "")
		plugin := plugin.base.__Class

	return plugin
}

getModeForLogMessage(mode) {
	mode := mode.Mode

	if (mode == "")
		mode := mode.base.__Class

	return mode
}

updateSimulatorState() {
	local controller := SimulatorController.Instance
	local currentSimulator, changed, ignore, fnController, show

	static isSimulatorRunning := false
	static lastSimulator := false

	protectionOn()

	try {
		updateTrayMessageState()

		currentSimulator := controller.ActiveSimulator
		changed := (isSimulatorRunning != (currentSimulator != false))

		if currentSimulator {
			isSimulatorRunning := true

			if (lastSimulator != currentSimulator) {
				if lastSimulator
					controller.simulatorShutdown(lastSimulator)

				lastSimulator := currentSimulator

				controller.simulatorStartup(currentSimulator)
			}
		}
		else if lastSimulator {
			isSimulatorRunning := false

			controller.simulatorShutdown(lastSimulator)

			lastSimulator := false
		}

		if changed
			for ignore, fnController in controller.FunctionController[GuiFunctionController]
				fnController.updateVisibility()

		if isSimulatorRunning {
			Task.CurrentTask.Sleep := 5000

			controller.hideLogo()
		}
		else {
			Task.CurrentTask.Sleep := 1000

			show := true

			for ignore, fnController in controller.FunctionController[GuiFunctionController]
				show := (show && !fnController.Visible)

			if show
				controller.showLogo()
		}
	}
	finally {
		protectionOff()
	}
}

updateTrayMessageState(settings := false) {
	local inSimulation := false
	local duration

	if !settings {
		settings := SimulatorController.Instance.Settings
		inSimulation := SimulatorController.Instance.ActiveSimulator
	}

	duration := getMultiMapValue(settings, "Tray Tip"
							   , inSimulation ? "Tray Tip Simulation Duration" : "Tray Tip Duration"
							   , inSimulation ? 1500 : 1500)

	if (duration > 0)
		enableTrayMessages(duration)
	else
		disableTrayMessages()
}

externalCommandManager() {
	local fileName := kTempDirectory . "Controller.cmd"
	local file, line, commands, command, ignore, descriptor

	if FileExist(fileName) {
		commands := []
		file := false

		try {
			file := FileOpen(fileName, "rw-rwd")

			if !file
				return
		}
		catch Any as exception {
			return
		}

		while !file.AtEOF {
			command := Trim(file.ReadLine(), " `t`n`r")

			if (StrLen(command) == 0)
				break

			commands.Push(command)
		}

		file.Close()

		deleteFile(fileName)

		for ignore, command in commands {
			command := string2Values(A_Space, command)

			descriptor := ConfigurationItem.splitDescriptor(command[1])

			switch descriptor[1], false {
				case k1WayToggleType, k2WayToggleType:
					switchToggle(descriptor[1], descriptor[2], (command.Length > 1) ? command[2] : "On")
				case kButtonType:
					pushButton(descriptor[2])
				case kDialType:
					rotateDial(descriptor[2], command[2])
				default:
					throw "Unknown controller function type (" . descriptor[1] . ") detected in externalCommand..."
			}
		}
	}
}

initializeSimulatorController() {
	local icon := kIconsDirectory . "Gear.ico"
	local settings, argIndex, voice, configuration

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Controller"

	SetKeyDelay(10, 30)

	settings := readMultiMap(kSimulatorSettingsFile)

	if inList(A_Args, "-NoStartup")
		disableTrayMessages()
	else
		updateTrayMessageState(settings)

	argIndex := inList(A_Args, "-Voice")
	voice := false

	if argIndex
		voice := A_Args[argIndex + 1]
	else
		voice := ProcessExist("Voice Server.exe")

	configuration := kSimulatorConfiguration

	argIndex := inList(A_Args, "-Configuration")

	if argIndex
		configuration := readMultiMap(A_Args[argIndex + 1])

	protectionOn()

	try {
		SimulatorController(configuration, settings, voice)
	}
	finally {
		protectionOff()
	}

	registerMessageHandler("Controller", functionMessageHandler)
	registerMessageHandler("Voice", methodMessageHandler, SimulatorController.Instance)

	return
}

startupSimulatorController() {
	local controller := SimulatorController.Instance
	local noStartup := ((A_Args.Length > 0) && (A_Args[1] = "-NoStartup"))

	if noStartup
		controller.writeControllerState(false)
	else
		PeriodicTask(ObjBindMethod(controller, "writeControllerState"), 0, kLowPriority).start()

	controller.computeControllerModes()

	controller.updateLastEvent()

	if noStartup
		ExitApp(0)

	controller.startup()
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

pushButton(buttonNumber) {
	local descriptor := ConfigurationItem.descriptor(kButtonType, buttonNumber)
	local function := SimulatorController.Instance.findFunction(descriptor)

	if ((function != false) && (SimulatorController.Instance.getActions(function, "Push").Length > 0))
		fireControllerActions(function, "Push")
	else
		logMessage(kLogWarn, translate("Controller function ") . descriptor . translate(" not found in custom controller action pushButton - please check the configuration"))
}

rotateDial(dialNumber, direction) {
	local function, descriptor

	if ((direction = kIncrease) || (direction = "plus") || (direction = "+"))
		direction := "Increase"
	else if ((direction = kDecrease) || (direction = "minus") || (direction = "-"))
		direction := "Decrease"
	else {
		logMessage(kLogWarn, translate("Unsupported argument (") . direction . translate(") detected in rotateDial - please check the configuration"))

		throw "Unsupported argument (" . direction . ") detected in rotateDial..."
	}

	descriptor := ConfigurationItem.descriptor(kDialType, dialNumber)
	function := SimulatorController.Instance.findFunction(descriptor)

	if ((function != false) && (SimulatorController.Instance.getActions(function, direction).Length > 0))
		fireControllerActions(function, direction)
	else
		logMessage(kLogWarn, translate("Controller function ") . descriptor . translate(" not found in custom controller action rotateDial - please check the configuration"))
}

switchToggle(toggleType, toggleNumber, mode := "activate") {
	local descriptor := ConfigurationItem.descriptor(toggleType, toggleNumber)
	local function := SimulatorController.Instance.findFunction(descriptor)

	if (function != false) {
		if (((mode = "activate") || (mode = "on")) && (SimulatorController.Instance.getActions(function, "On").Length > 0))
			fireControllerActions(function, "On")
		else if (((mode = "deactivate") || (mode = "off")) && (SimulatorController.Instance.getActions(function, "Off").Length > 0))
			fireControllerActions(function, "Off")
		else {
			logMessage(kLogWarn, translate("Unsupported argument (") . mode . translate(") detected in switchToggle - please check the configuration"))

			throw "Unsupported argument (" . mode . ") detected in switchToggle..."
		}
	}
	else
		logMessage(kLogWarn, translate("Controller function ") . descriptor . translate(" not found in custom controller action switchToggle - please check the configuration"))
}

setMode(actionOrPlugin, mode := false) {
	local controller := SimulatorController.Instance
	local theMode

	protectionOn()

	try {
		if (actionOrPlugin = kIncrease)
			SimulatorController.Instance.rotateMode(1)
		else if (actionOrPlugin = kDecrease)
			SimulatorController.Instance.rotateMode(-1)
		else {
			theMode := controller.findMode(actionOrPlugin, mode)

			if ((theMode != false) && controller.isActive(theMode))
				controller.setMode(theMode)
			else
				trayMessage(translate("Controller"), translate("Mode: ") . translate(actionOrPlugin) . " - " . translate(mode) . translate(" is not available"), 10000)
		}
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

writeControllerState() {
	SimulatorController.Instance.writeControllerState(false)
}


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 1                     ;;;
;;;-------------------------------------------------------------------------;;;

MessageManager.pause()

initializeSimulatorController()


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Plugins\Controller Plugins.ahk"
#Include "%A_MyDocuments%\Simulator Controller\Plugins\Controller Plugins.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorController()

MessageManager.resume()