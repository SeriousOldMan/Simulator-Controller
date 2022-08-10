;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Controller            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Gear.ico
;@Ahk2Exe-ExeName Simulator Controller.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk
#Include ..\Libraries\SpeechRecognizer.ahk
#Include ..\Plugins\Libraries\SimulatorPlugin.ahk


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

	Controller[] {
		Get {
			return this.iController
		}
	}

	Descriptor[] {
		Get {
			return this.base.__Class
		}
	}

	Type[] {
		Get {
			return this.Descriptor
		}
	}

	Num1WayToggles[] {
		Get {
			return this.iNum1WayToggles
		}
	}

	Num2WayToggles[] {
		Get {
			return this.iNum2WayToggles
		}
	}

	NumButtons[] {
		Get {
			return this.iNumButtons
		}
	}

	NumDials[] {
		Get {
			return this.iNumDials
		}
	}

	__New(controller, configuration := false) {
		this.iController := controller

		base.__New(configuration)

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
	static iGuiFunctionController := {}

	iWindow := false
	iWindowWidth := 0
	iWindowHeight := 0

	iControlHandles := {}

	iIsVisible := false
	iIsPositioned := false

	Visible[] {
		Get {
			return this.iIsVisible
		}
	}

	VisibleDuration[] {
		Get {
			local controller := this.Controller
			local inSimulation, type

			if (controller != false) {
				inSimulation := (controller.ActiveSimulator != false)

				type := this.Type

				return getConfigurationValue(this.Controller.Settings, type
										   , type . (inSimulation ? " Simulation Duration" : " Duration")
										   , inSimulation ? false : false)
			}
			else
				return false
		}
	}

	__New(controller, configuration := false) {
		base.__New(controller, configuration)

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

		this.iGuiFunctionController[window] := this

		logMessage(kLogInfo, translate("Controller layout initialized:") . " #" . num1WayToggles . A_Space . translate("1-Way Toggles") . ", #" . num2WayToggles . A_Space . translate("2-Way Toggles") . ", #" . numButtons . A_Space . translate("Buttons") . ", #" . numDials . A_Space . translate("Dials"))
	}

	findFunctionController(window) {
		if this.iGuiFunctionController.HasKey(window)
			return this.iGuiFunctionController[window]
		else
			return false
	}

	hasFunction(function) {
		return (this.getControlHandle(function.Descriptor) != false)
	}

	connectAction(plugin, function, action) {
		this.setControlLabel(function, plugin.actionLabel(action))
	}

	disconnectAction(plugin, function, action) {
		this.setControlLabel(function, "")
	}

	registerControlHandle(descriptor, handle) {
		this.iControlHandles[descriptor] := handle
	}

	getControlHandle(descriptor) {
		if this.iControlHandles.HasKey(descriptor)
			return this.iControlHandles[descriptor]
		else
			return false
	}

	setControlLabel(function, text, color := "Black", overlay := false) {
		local window := this.iWindow
		local handle

		if (window != false) {
			handle := this.getControlHandle(function.Descriptor)

			if (handle != false) {
				Gui %window%:Font, s8 c%color%, Arial
				GuiControl Text, %handle%, % text
				GuiControl Font, %handle%
				Gui %window%:Font

				this.show()
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

		index := controller.Length()

		loop {
			fnController := controller[index]

			distance += fnController.iWindowHeight

			if (fnController == this)
				return distance
		} until (--index = 0)

		throw "Internal error detected in GuiFunctionController.distanceFromBottom..."
	}

	show(makeVisible := true) {
		local duration, window, width, height, type, position, x, y, count
		local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

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
					hideTask := new PeriodicTask("hideFunctionController", duration, kLowPriority)

					Task.startTask(hideTask)
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
						Gui %window%:Show, NoActivate
					else {
						type := this.Type

						position := getConfigurationValue(this.Controller.Settings, type, type . " Position", "Bottom Right")

						SysGet mainScreen, MonitorWorkArea

						switch position {
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
							case "Secondary Screen":
								SysGet count, MonitorCount

								if (count > 1) {
									SysGet, secondScreen, MonitorWorkArea, 2

									x := Round(secondScreenLeft + ((secondScreenRight - secondScreenLeft - width) / 2))
									y := Round(secondScreenTop + ((secondScreenBottom - secondScreenTop- height) / 2))
								}
								else
									Goto defaultCase
							case "Last Position":
	defaultCase:
								x := getConfigurationValue(this.Controller.Settings, type, this.Descriptor . ".Position.X", mainScreenRight - width)
								y := getConfigurationValue(this.Controller.Settings, type, this.Descriptor . ".Position.Y", mainScreenBottom - height)
							default:
								throw "Unhandled position for " . type " (" . position . ") encountered in GuiFunctionController.show..."
						}

						Gui %window%:Show, x%x% y%y% w%width% h%height% NoActivate

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
		local window

		protectionOn()

		try {
			if this.Visible {
				window := this.iWindow

				Gui %window%:Hide

				this.iIsVisible := false
			}
		}
		finally {
			protectionOff()
		}
	}

	moveByMouse(window, button := "LButton") {
		local curCoordMode := A_CoordModeMouse
		local anchorX, anchorY, winX, winY, newX, newY, x, y, w, h, settings

		CoordMode Mouse, Screen

		try {
			MouseGetPos anchorX, anchorY
			WinGetPos winX, winY, w, h, A

			newX := winX
			newY := winY

			while GetKeyState(button, "P") {
				MouseGetPos x, y

				newX := winX + (x - anchorX)
				newY := winY + (y - anchorY)

				Gui %window%:Show, X%newX% Y%newY%
			}

			settings := this.Controller.Settings

			setConfigurationValue(settings, this.Type, this.Descriptor . ".Position.X", newX)
			setConfigurationValue(settings, this.Type, this.Descriptor . ".Position.Y", newY)

			writeConfiguration(kSimulatorSettingsFile, settings)

			this.Controller.reloadSettings(settings)
		}
		finally {
			CoordMode Mouse, %curCoordMode%
		}
	}
}

class SimulatorController extends ConfigurationItem {
	iID := false

	iStarted := false

	iSettings := false

	iPlugins := []
	iFunctions := {}
	iFunctionController := []

	iModes := []
	iActiveModes := []

	iFunctionActions := {}

	iVoiceServer := false
	iVoiceCommands := {}

	iLastEvent := A_TickCount

	iShowLogo := false
	iLogoIsVisible := false

	ID[] {
		Get {
			return this.iID
		}
	}

	Settings[] {
		Get {
			return this.iSettings
		}
	}

	Started[] {
		Get {
			return this.iStarted
		}
	}

	VoiceServer[] {
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

	Functions[] {
		Get {
			return this.iFunctions
		}
	}

	Plugins[] {
		Get {
			return this.iPlugins
		}
	}

	Modes[] {
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
				return ((activeModes.Length() > 0) ? activeModes[1] : false)
		}
	}

	ActiveModes[] {
		Get {
			return this.iActiveModes
		}
	}

	ActiveSimulator[] {
		Get {
			return this.runningSimulator()
		}
	}

	LastEvent[] {
		Get {
			return this.iLastEvent
		}
	}

	__New(configuration, settings, voiceServer := false) {
		FileRead identifier, % kUserConfigDirectory . "ID"

		this.iID := identifier

		SimulatorController.Controller := this

		this.iSettings := settings
		this.iVoiceServer := voiceServer

		SimulatorController.Instance := this

		base.__New(configuration)

		if !inList(A_Args, "-NoStartup")
			this.initializeBackgroundTasks()
	}

	loadFromConfiguration(configuration) {
		local descriptor, arguments, functions

		base.loadFromConfiguration(configuration)

		for descriptor, arguments in getConfigurationSectionValues(configuration, "Controller Functions", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			descriptor := ConfigurationItem.descriptor(descriptor[1], descriptor[2])

			functions := this.Functions

			if !functions.HasKey(descriptor)
				functions[descriptor] := this.createControllerFunction(descriptor, configuration)
		}
	}

	reloadSettings(settings) {
		this.iSettings := settings
	}

	createControllerFunction(descriptor, configuration) {
		descriptor := ConfigurationItem.splitDescriptor(descriptor)

		switch descriptor[1] {
			case k2WayToggleType:
				return new Controller2WayToggleFunction(this, descriptor[2], configuration)
			case k1WayToggleType:
				return new Controller1WayToggleFunction(this, descriptor[2], configuration)
			case kButtonType:
				return new ControllerButtonFunction(this, descriptor[2], configuration)
			case kDialType:
				return new ControllerDialFunction(this, descriptor[2], configuration)
			case kCustomType:
				return new ControllerCustomFunction(this, descriptor[2], configuration)
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

		if !IsObject(plugin)
			plugin := this.findPlugin(plugin)

		for ignore, mode in this.Modes
			if ((mode.Mode = name) && (mode.Plugin == plugin))
				return mode

		return false
	}

	findFunction(descriptor) {
		local functions := this.Functions

		return (functions.HasKey(descriptor) ? functions[descriptor] : false)
	}

	getActions(function, trigger) {
		return (this.iFunctionActions.HasKey(function) ? this.iFunctionActions[function] : [])
	}

	getLogo() {
		local rnd

		Random rnd, 0, 1

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
		local function, ignore, mode, action, fnController

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

	runningSimulator() {
		local ignore, thePlugin, simulator

		static lastSimulator := false
		static lastCheck := 0

		if (A_TickCount + (lastCheck + 10000)) {
			lastSimulator := false

			for ignore, thePlugin in this.Plugins
				if this.isActive(thePlugin) {
					simulator := thePlugin.runningSimulator()

					if (simulator != false) {
						lastSimulator := simulator

						break
					}
				}

			lastCheck := A_TickCount
		}

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
		local theme, songFile, posX, posY, name, started

		if !application.isRunning()
			if (application.startup(false))
				if (!kSilentMode && splashImage) {
					protectionOff()

					try {
						showSplash(splashImage)

						theme := getConfigurationValue(this.Settings, "Startup", "Splash Theme", false)
						songFile := (theme ? getConfigurationValue(this.Configuration, "Splash Themes", theme . ".Song", false) : false)

						if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)))
							sendMessage(kLocalMessage, "Startup", "playStartupSong:" . songFile)

						posX := Round((A_ScreenWidth - 300) / 2)
						posY := A_ScreenHeight - 150

						name := application.Application

						showProgress({x: posX, y: posY, message: name, title: translate("Starting Simulator")})

						started := false

						loop {
							if (A_Index >= 100)
								break

							showProgress({progress: A_Index})

							if (!started && application.isRunning())
								started := true

							Sleep % started ? 10 : 100
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
		local descriptor, pid

		static registered := false

		if this.iVoiceCommands.HasKey(command)
			return this.iVoiceCommands[command]
		else {
			descriptor := Array(command, false)

			this.iVoiceCommands[command] := descriptor

			if this.VoiceServer {
				Process Exist

				pid := ErrorLevel

				if !registered {
					activationCommand := getConfigurationValue(this.Configuration, "Voice Control", "ActivationCommand", false)

					sendMessage(kFileMessage, "Voice", "registerVoiceClient:" . values2String(";", "Controller", pid
																								 , activationCommand, "activationCommand", false
																								 , false, false, false, true, true)
							  , this.VoiceServer)

					registered := true
				}

				sendMessage(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", "Controller", false, command, "voiceCommand"), this.VoiceServer)
			}

			return descriptor
		}
	}

	activationCommand(words*) {
		static first := true

		if first
			first := false
		else
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav
	}

	voiceCommand(grammar, command, words*) {
		local handler := this.iVoiceCommands[command][2]

		if handler
			%handler%()
	}

	enableVoiceCommand(command, handler) {
		this.getVoiceCommandDescriptor(command)[2] := handler
	}

	disableVoiceCommand(command) {
		this.getVoiceCommandDescriptor(command)[2] := false
	}

	connectAction(plugin, function, action) {
		local ignore, fnController

		logMessage(kLogInfo, translate("Connecting ") . function.Descriptor . translate(" to action ") . translate(getLabelForLogMessage(action)))

		function.connectAction(plugin, action)

		action.connectFunction(plugin, function)

		if !this.iFunctionActions.HasKey(function)
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
		local modeSwitched, controllers, deactivatedModes, ignore, mode

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

		if controller
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
		else
			position := inList(modes, this.ActiveModes[1])

		if !position
			position := 1

		targetMode := false
		index := position + delta

		loop {
			if (index > modes.Length())
				index := 1
			else if (index < 1)
				index := modes.Length()

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
			} else if controller {
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
		} until targetMode

		this.setMode(targetMode)
	}

	setModes(simulator := false, session := false) {
		local modes := false
		local ignore, theMode

		if !simulator
			modes := getConfigurationValue(this.Settings, "Modes", "Default", "")
		else {
			modes := getConfigurationValue(this.Settings, "Modes", ConfigurationItem.descriptor(simulator, session), "")

			if (StrLen(Trim(modes)) = 0)
				modes := getConfigurationValue(this.Settings, "Modes", ConfigurationItem.descriptor(simulator, "Default"), "")
		}

		if (StrLen(Trim(modes)) != 0)
			for ignore, theMode in string2Values(",", modes) {
				theMode := ConfigurationItem.splitDescriptor(theMode)

				theMode := this.findMode(theMode[1], theMode[2])

				if theMode
					this.setMode(theMode)
			}
	}

	showLogo(show := "__Undefined__") {
		local info, logo, image, x, y, title1, title2
		local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

		if (show != kUndefined)
			this.iShowLogo := show
		else if (this.iShowLogo && !this.iLogoIsVisible) {
			static videoPlayer

			info := kVersion . " - 2022, Oliver Juwig`nCreative Commons - BY-NC-SA"
			logo := this.getLogo()
			image := "1:" . logo

			SysGet mainScreen, MonitorWorkArea

			x := mainScreenRight - 229
			y := mainScreenBottom - 259

			title1 := translate("Modular Simulator")
			title2 := translate("Controller System")

			SplashImage %image%, B FS8 CWD0D0D0 w229 x%x% y%y% ZH180 ZW209, %info%, %title1%`n%title2%

			WinSet Transparent, 255, , % translate("Creative Commons - BY-NC-SA")

			Gui Logo:-Border -Caption
			Gui Logo:Add, ActiveX, x0 y0 w209 h180 VvideoPlayer, shell explorer

			videoPlayer.Navigate("about:blank")

			html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . logo . "' width=209 height=180 border=0 padding=0></body></html>"

			videoPlayer.document.write(html)

			x += 10
			y += 40

			Gui Logo:Margin, 0, 0
			Gui Logo:+AlwaysOnTop
			Gui Logo:Show, AutoSize x%x% y%y%

			this.iLogoIsVisible := true
		}
	}

	hideLogo() {
		if this.iLogoIsVisible {
			Gui Logo:Destroy
			SplashImage 1:Off

			this.iLogoIsVisible := false
		}
	}

	initializeBackgroundTasks() {
		Task.startTask(new PeriodicTask("updateSimulatorState", 10000, kLowPriority))
		Task.startTask(new PeriodicTask("externalCommandManager", 100, kLowPriority))

		this.iShowLogo := (this.iShowLogo && !kSilentMode)
	}

	writeControllerConfiguration() {
		local controller, configuration, ignore, thePlugin, modes, states, name, theMode, simulators, simulator, fnController

		configuration := newConfiguration()

		for ignore, thePlugin in this.Plugins {
			if (this.isActive(thePlugin)) {
				modes := []

				if isInstance(thePlugin, SimulatorPlugin) {
					states := []

					for ignore, name in thePlugin.Sessions[true]
						states.Push(name)

					setConfigurationValue(configuration, "Simulators", thePlugin.Simulator.Application
										, thePlugin.Plugin . "|" . values2String(",", states*))
				}

				for ignore, theMode in thePlugin.Modes
					modes.Push(theMode.Mode)

				simulators := []

				for ignore, simulator in thePlugin.Simulators
					simulators.Push(simulator)

				setConfigurationValue(configuration, "Plugins", thePlugin.Plugin
									, values2String("|", (this.isActive(thePlugin) ? kTrue : kFalse)
													   , values2String(",", simulators*), values2String(",", modes*)))
			}
		}

		for ignore, fnController in this.FunctionController
			setConfigurationValue(configuration, fnController.Type, fnController.Descriptor
								, values2String(",", fnController.Num1WayToggles, fnController.Num2WayToggles
												   , fnController.NumButtons, fnController.NumDials))

		writeConfiguration(kUserConfigDirectory . "Simulator Controller.config", configuration)
	}
}

class ControllerFunction {
	iController := false
	iFunction := false

	iEnabledActions := {}

	Controller[] {
		Get {
			return this.iController
		}
	}

	Function[] {
		Get {
			return this.iFunction
		}
	}

	Type[] {
		Get {
			return this.Function.Type
		}
	}

	Number[] {
		Get {
			return this.Function.Number
		}
	}

	Descriptor[] {
		Get {
			return this.Function.Descriptor
		}
	}

	Enabled[action := false] {
		Get {
			if action
				return this.iEnabledActions.HasKey(action)
			else
				return (this.iEnabledActions.Count() > 0)
		}
	}

	Hotkeys[trigger := false] {
		Get {
			return this.Function.Hotkeys[trigger]
		}
	}

	Trigger[] {
		Get {
			return this.Function.Trigger
		}
	}

	Actions[trigger := false] {
		Get {
			return this.Function.Actions[trigger]
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

		if (trigger == kAllTrigger)
			for ignore, trigger in this.Trigger
				setHotkeyEnabled(this, trigger, true)
		else
			setHotkeyEnabled(this, trigger, true)
	}

	disable(trigger := "__All Trigger__", action := false) {
		local ignore, fnController

		this.iEnabledActions.Delete(action)

		for ignore, fnController in this.Controller.FunctionController
			fnController.disable(this, action)

		if !this.Enabled
			if (trigger == kAllTrigger)
				for ignore, trigger in this.Trigger
					setHotkeyEnabled(this, trigger, false)
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
				if (SubStr(theHotkey, 1, 1) = "?") {
					command := SubStr(theHotkey, 2)

					controller.enableVoiceCommand(command, handler)

					logMessage(kLogInfo, translate("Binding voice command ") . command . translate(" for trigger ") . trigger . translate(" to ") . (action ? (action.base.__Class . ".fireAction") : this.Function.Actions[trigger, true]))
				}
				else
					try {
						Hotkey %theHotkey%, %handler%
						Hotkey %theHotkey%, On

						logMessage(kLogInfo, translate("Binding hotkey ") . theHotkey . translate(" for trigger ") . trigger . translate(" to ") . (action ? (action.base.__Class . ".fireAction") : this.Function.Actions[trigger, true]))
					}
					catch exception {
						logMessage(kLogCritical, translate("Error while registering hotkey ") . theHotkey . translate(" - please check the configuration"))

						showMessage(substituteVariables(translate("Cannot register hotkey %hotkey% - please check the configuration..."), {hotKey: theHotKey})
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

					}
			}
		}
	}

	disconnectAction(plugin, action) {
		local controller := this.Controller
		local ignore, trigger

		this.iEnabledActions.Delete(action)

		for ignore, trigger in this.Function.Trigger {
			for ignore, theHotkey in this.Hotkeys[trigger] {
				if (SubStr(theHotkey, 1, 1) = "?")
					controller.disableVoiceCommand(SubStr(theHotkey, 2))
				else
					Hotkey %theHotkey%, Off
			}
		}
	}
}

class Controller1WayToggleFunction extends ControllerFunction {
	class Inner1WayToggleFunction extends 1WayToggleFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			base.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, base.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		base.__New(controller, new this.Inner1WayToggleFunction(this, number, configuration))
	}
}

class Controller2WayToggleFunction extends ControllerFunction {
	class Inner2WayToggleFunction extends 2WayToggleFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			base.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, base.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		base.__New(controller, new this.Inner2WayToggleFunction(this, number, configuration))
	}
}

class ControllerButtonFunction extends ControllerFunction {
	class InnerButtonFunction extends ButtonFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			base.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, base.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		base.__New(controller, new this.InnerButtonFunction(this, number, configuration))
	}
}

class ControllerDialFunction extends ControllerFunction {
	class InnerDialFunction extends DialFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			base.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, base.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		base.__New(controller, new this.InnerDialFunction(this, number, configuration))
	}
}

class ControllerCustomFunction extends ControllerFunction {
	class InnerCustomFunction extends CustomFunction {
		iOuterFunction := false

		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction

			base.__New(functionNumber, configuration)
		}

		actionCallable(trigger, action) {
			return functionActionCallable(this.iOuterFunction, trigger, base.actionCallable(trigger, action))
		}
	}

	__New(controller, number, configuration := false) {
		base.__New(controller, new this.InnerCustomFunction(this, number, configuration))

		this.connectAction(false, false)
	}
}

class ControllerPlugin extends Plugin {
	static sLabelsDatabase := false
	static sIconsDatabase := false

	iController := false
	iModes := []
	iActions := []

	Controller[] {
		Get {
			return this.iController
		}
	}

	Modes[] {
		Get {
			return this.iModes
		}
	}

	Actions[] {
		Get {
			return this.iActions
		}
	}

	__New(controller, name, configuration := false, register := true) {
		this.iController := controller

		base.__New(name, configuration)

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

		if !this.sLabelsDatabase
			ControllerPlugin.sLabelsDatabase := getControllerActionLabels()

		label := getConfigurationValue(this.sLabelsDatabase, this.Plugin, descriptor, false)

		if (!label || (label == ""))
			label := default

		return label
	}

	getIcon(descriptor, default := false) {
		local icon

		if !this.sIconsDatabase
			ControllerPlugin.sIconsDatabase := getControllerActionIcons()

		icon := getConfigurationValue(this.sIconsDatabase, this.Plugin, descriptor, false)

		if (!icon || (icon == ""))
			icon := default

		return icon
	}

	logFunctionNotFound(functionDescriptor) {
		logMessage(kLogWarn, translate("Controller function ") . functionDescriptor . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}
}

class ControllerMode {
	iPlugin := false
	iActions := []

	iFunctionController := []

	Mode[] {
		Get {
			throw "Virtual property ControllerMode.Mode must be implemented in a subclass..."
		}
	}

	Plugin[] {
		Get {
			return this.iPlugin
		}
	}

	Controller[] {
		Get {
			return this.Plugin.Controller
		}
	}

	Actions[] {
		Get {
			return this.iActions
		}
	}

	FunctionController[] {
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

			if (simulators.Length() == 0)
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

	Function[] {
		Get {
			return this.iFunction
		}
	}

	Controller[] {
		Get {
			return this.Function.Controller
		}
	}

	Label[] {
		Get {
			return this.iLabel
		}
	}

	Icon[] {
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
				controller.enableVoiceCommand(SubStr(theHotkey, 2))
			else
				controller.disableVoiceCommand(SubStr(theHotkey, 2))
		}
		else
			Hotkey %theHotkey%, %state%
}

functionActionCallable(function, trigger, action) {
	return (action ? action : Func("fireControllerActions").Bind(function, trigger))
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

				while (pending.Length() > 0) {
					callable := pending.RemoveAt(1)

					%callable%()
				}
			}
			finally {
				pending := false
			}
		}
		else
			Task.startTask(Func("fireControllerActions").Bind(function, trigger, true), 0, kLowPriority)
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

	return StrReplace(label, "`n", A_Space)
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

	duration := getConfigurationValue(settings, "Tray Tip"
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
		}
		catch exception {
			return
		}

		while !file.AtEOF {
			command := Trim(file.ReadLine(), " `t`n`r")

			if (StrLen(command) == 0)
				break

			commands.Push(command)
		}

		file.Close()

		try {
			FileDelete %fileName%
		}
		catch exception {
			; ignore
		}

		for ignore, command in commands {
			command := string2Values(A_Space, command)

			descriptor := ConfigurationItem.splitDescriptor(command[1])

			switch descriptor[1] {
				case k1WayToggleType, k2WayToggleType:
					switchToggle(descriptor[1], descriptor[2], (command.Length() > 1) ? command[2] : "On")
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

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Controller

	Menu Tray, NoStandard
	Menu Tray, Add, Exit, Exit

	installSupportMenu()

	SetKeyDelay 5, 25

	settings := readConfiguration(kSimulatorSettingsFile)

	if inList(A_Args, "-NoStartup")
		disableTrayMessages()
	else
		updateTrayMessageState(settings)

	argIndex := inList(A_Args, "-Voice")
	voice := false

	if argIndex
		voice := A_Args[argIndex + 1]
	else {
		Process Exist, Voice Server.exe

		voice := ErrorLevel
	}

	configuration := kSimulatorConfiguration

	argIndex := inList(A_Args, "-Configuration")

	if argIndex
		configuration := readConfiguration(A_Args[argIndex + 1])

	protectionOn()

	try {
		new SimulatorController(configuration, settings, voice)
	}
	finally {
		protectionOff()
	}

	registerMessageHandler("Controller", "functionMessageHandler")
	registerMessageHandler("Voice", "methodMessageHandler", SimulatorController.Instance)

	return

Exit:
	ExitApp 0
}

startupSimulatorController() {
	local controller := SimulatorController.Instance

	controller.writeControllerConfiguration()

	controller.computeControllerModes()

	controller.updateLastEvent()

	if ((A_Args.Length() > 0) && (A_Args[1] = "-NoStartup"))
		ExitApp 0

	controller.startup()
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

pushButton(buttonNumber) {
	local descriptor := ConfigurationItem.descriptor(kButtonType, buttonNumber)
	local function := SimulatorController.Instance.findFunction(descriptor)

	if ((function != false) && (SimulatorController.Instance.getActions(function, "Push").Length() > 0))
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

	if ((function != false) && (SimulatorController.Instance.getActions(function, direction).Length() > 0))
		fireControllerActions(function, direction)
	else
		logMessage(kLogWarn, translate("Controller function ") . descriptor . translate(" not found in custom controller action rotateDial - please check the configuration"))
}

switchToggle(toggleType, toggleNumber, mode := "activate") {
	local descriptor := ConfigurationItem.descriptor(toggleType, toggleNumber)
	local function := SimulatorController.Instance.findFunction(descriptor)

	if (function != false) {
		if (((mode = "activate") || (mode = "on")) && (SimulatorController.Instance.getActions(function, "On").Length() > 0))
			fireControllerActions(function, "On")
		else if (((mode = "deactivate") || (mode = "off")) && (SimulatorController.Instance.getActions(function, "Off").Length() > 0))
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

writeControllerConfiguration() {
	SimulatorController.Instance.writeControllerConfiguration()
}


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 1                     ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorController()


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Controller Plugins.ahk
#Include %A_MyDocuments%\Simulator Controller\Plugins\Controller Plugins.ahk


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorController()