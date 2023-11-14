;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - System Plugin (required)        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSystemPlugin := "System"
global kLaunchMode := "Launch"
global kCustomMode := "Custom"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SystemPlugin extends ControllerPlugin {
	iChildProcess := false
	iLaunchMode := false
	iMouseClicked := false
	iStartupSongIsPlaying := false
	iRunnableApplications := []
	iModeSelectors := []

	class RunnableApplication extends Application {
		iIsRunning := false
		iLaunchpadFunction := false
		iLaunchpadAction := false

		LaunchpadFunction {
			Get {
				return this.iLaunchpadFunction
			}
		}

		LaunchpadAction {
			Get {
				return this.iLaunchpadAction
			}
		}

		updateRunningState() {
			local isRunning := this.isRunning()
			local stateChange := false
			local transition := false
			local controller

			if (isRunning != this.iIsRunning) {
				this.iIsRunning := isRunning

				stateChange := true

				trayMessage(translate(kSystemPlugin), (isRunning ? translate("Start: ") : translate("Stop: ")) . this.Application)

				if isDebug()
					logMessage(kLogDebug, (isRunning ? "Startup of " : "Shutdown of ") . this.Application . " detected...")
			}

			if !stateChange {
				transition := (this.LaunchpadAction ? this.LaunchpadAction.Transition : false)

				if (transition && ((A_TickCount - transition) > 10000)) {
					transition := false
					stateChange := true

					this.LaunchpadAction.endTransition()
				}
			}
			else if this.LaunchpadAction
				this.LaunchpadAction.endTransition()

			if (this.LaunchpadFunction != false) {
				controller := SimulatorController.Instance

				if (inList(controller.ActiveModes, controller.findMode(kSystemPlugin, kLaunchMode))) {
					if transition
						this.LaunchpadFunction.setLabel(this.LaunchpadAction.Label, "Gray")
					else
						this.LaunchpadFunction.setLabel(this.LaunchpadAction.Label, isRunning ? "Green" : "Black")
				}
			}
		}

		connectAction(function, action) {
			this.iLaunchpadFunction := function
			this.iLaunchpadAction := action
		}
	}

	class LaunchMode extends ControllerMode {
		Mode {
			Get {
				return kLaunchMode
			}
		}
	}

	class CustomMode extends ControllerMode {
		iMode := false

		Mode {
			Get {
				return this.iMode
			}
		}

		__New(plugin, mode := kCustomMode) {
			this.iMode := mode

			super.__New(plugin)
		}
	}

	class ModeSelectorAction extends ControllerAction {
		Label {
			Get {
				local controller := this.Controller
				local mode := controller.ActiveMode[controller.findFunctionController(this.Function)]

				if mode
					return mode.Mode
				else
					return StrReplace(StrReplace(translate("Mode Selector"), A_Space, "`n"), "`r", "")
			}
		}

		fireAction(function, trigger) {
			local controller := this.Controller

			controller.rotateMode(((trigger == "Off") || (trigger = kDecrease)) ? -1 : 1, Array(controller.findFunctionController(function)))

			this.Function.setLabel(controller.findPlugin(kSystemPlugin).actionLabel(this))
		}
	}

	class LaunchAction extends ControllerAction {
		iApplication := false
		iTransition := false

		Application {
			Get {
				return this.iApplication
			}
		}

		Transition {
			Get {
				return this.iTransition
			}
		}

		__New(function, label, icon, name) {
			this.iApplication := Application(name, function.Controller.Configuration)

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			if !this.Transition {
				if (inList(function.Controller.ActiveModes, function.Controller.findMode(kSystemPlugin, kLaunchMode))) {
					this.beginTransition()

					function.setLabel(this.Label, "Gray")
				}

				if !this.Application.isRunning()
					this.Application.startup()
				else
					this.Application.shutdown()
			}
		}

		beginTransition() {
			this.iTransition := A_TickCount
		}

		endTransition() {
			this.iTransition := false
		}
	}

	class CustomAction extends ControllerAction {
		iCustomFunction := false

		CustomFunction {
			Get {
				return this.iCustomFunction
			}
		}

		__New(function, label, icon, customFunction) {
			this.iCustomFunction := customFunction

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			function.Controller.fireActions(this.CustomFunction, "Call")
		}
	}

	class LogoToggleAction extends ControllerAction {
		iLogoIsVisible := false

		fireAction(function, trigger) {
			this.Controller.showLogo(this.iLogoIsVisible := !this.iLogoIsVisible)
		}
	}

	class SystemShutdownAction extends ControllerAction {
		fireAction(function, trigger) {
			shutdownSystem()
		}
	}

	ChildProcess {
		Get {
			return this.iChildProcess
		}
	}

	ModeSelectors {
		Get {
			return this.iModeSelectors
		}
	}

	RunnableApplications {
		Get {
			return this.iRunnableApplications
		}
	}

	MouseClicked {
		Get {
			return this.iMouseClicked
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local function, action, ignore, descriptor, arguments, commands, mode, modeCommands

		if inList(A_Args, "-Startup")
			this.iChildProcess := true

		super.__New(controller, name, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			for ignore, descriptor in string2Values(A_Space, this.getArgumentValue("modeSelector", ""))
				if (descriptor != false) {
					function := controller.findFunction(descriptor)

					if (function != false) {
						action := SystemPlugin.ModeSelectorAction(function, "", this.getIcon("ModeSelector.Activate"))

						this.iModeSelectors.Push(action)

						this.registerAction(action)
					}
					else
						this.logFunctionNotFound(descriptor)
				}

			for ignore, arguments in string2Values(",", this.getArgumentValue("launchApplications", ""))
				this.createLaunchAction(controller, this.parseValues(A_Space, arguments)*)

			for ignore, commands in string2Values("|", this.getArgumentValue("customCommands", ""))
				if InStr(commands, "->") {
					commands := string2Values("->", commands)

					mode := SystemPlugin.CustomMode(this, commands[1])

					for ignore, arguments in string2Values(",", commands[2])
						this.createCustomAction(controller, mode, this.parseValues(A_Space, arguments)*)

					this.registerMode(mode)
				}
				else
					for ignore, arguments in string2Values(",", commands)
						this.createCustomAction(controller, this, this.parseValues(A_Space, arguments)*)

			descriptor := this.getArgumentValue("logo", false)

			if (descriptor != false) {
				function := controller.findFunction(descriptor)

				if (function != false) {
					if !this.iLaunchMode
						this.iLaunchMode := SystemPlugin.LaunchMode(this)

					this.iLaunchMode.registerAction(SystemPlugin.LogoToggleAction(function, ""))
				}
				else
					this.logFunctionNotFound(descriptor)
			}

			descriptor := this.getArgumentValue("shutdown", false)

			if (descriptor != false) {
				function := controller.findFunction(descriptor)

				if (function != false) {
					if !this.iLaunchMode
						this.iLaunchMode := SystemPlugin.LaunchMode(this)

					this.iLaunchMode.registerAction(SystemPlugin.SystemShutdownAction(function, "Shutdown"))
				}
				else
					this.logFunctionNotFound(descriptor)
			}

			if this.iLaunchMode
				this.registerMode(this.iLaunchMode)

			if register
				controller.registerPlugin(this)

			this.initializeBackgroundTasks()
		}
	}

	loadFromConfiguration(configuration) {
		local action, function, descriptor, name, appDescriptor, runnable

		super.loadFromConfiguration(configuration)

		for descriptor, name in getMultiMapValues(configuration, "Applications")
			this.RunnableApplications.Push(SystemPlugin.RunnableApplication(name, configuration))

		for descriptor, appDescriptor in getMultiMapValues(configuration, "Launchpad") {
			function := this.Controller.findFunction(descriptor)

			if (function != false) {
				appDescriptor := string2Values("|", appDescriptor)

				runnable := this.findRunnableApplication(appDescriptor[2])

				if (runnable != false) {
					action := SystemPlugin.LaunchAction(function, appDescriptor[1], this.getIcon("Launch.Activate"), appDescriptor[2])

					if !this.iLaunchMode
						this.iLaunchMode := SystemPlugin.LaunchMode(this)

					this.iLaunchMode.registerAction(action)

					runnable.connectAction(function, action)
				}
				else
					logMessage(kLogWarn, translate("Application ") . appDescriptor[2] . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}

	createLaunchAction(controller, label, application, function) {
		local runnable, action

		function := this.Controller.findFunction(function)

		if (function != false) {
			runnable := this.findRunnableApplication(application)

			if (runnable != false) {
				action := SystemPlugin.LaunchAction(function, label, this.getIcon("Launch.Activate"), application)

				if !this.iLaunchMode
					this.iLaunchMode := SystemPlugin.LaunchMode(this)

				this.iLaunchMode.registerAction(action)

				runnable.connectAction(function, action)
			}
		}
		else
			logMessage(kLogWarn, translate("Application ") . application . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	createCustomAction(controller, owner, label, descriptor, customDescriptor) {
		local function, customFunction, action

		function := this.Controller.findFunction(descriptor)
		customFunction := this.Controller.findFunction(customDescriptor)

		if !function
			this.logFunctionNotFound(descriptor)
		else if (!customFunction || !isInstance(customFunction, ControllerCustomFunction))
			this.logFunctionNotFound(customDescriptor)
		else
			owner.registerAction(SystemPlugin.CustomAction(function, label, this.getIcon("Custom.Activate"), customFunction))
	}

	writePluginState(configuration) {
		if this.Active
			setMultiMapValue(configuration, this.Plugin, "State", "Active")
		else
			super.writePluginState(configuration)
	}

	simulatorStartup(simulator) {
		local fileName

		if this.ChildProcess {
			; Looks like we have recurring deadlock situations with bidirectional pipes in case of process exit situations...
			;
			; messageSend(kPipeMessage, "Startup", "exitStartup")
			;
			; Using a sempahore file instead...

			fileName := (kTempDirectory . "Startup.semaphore")

			deleteFile(fileName)
		}

		super.simulatorStartup(simulator)
	}

	findRunnableApplication(name) {
		local ignore, candidate

		for ignore, candidate in this.RunnableApplications
			if (name == candidate.Application)
				return candidate

		return false
	}

	mouseClick(clicked := true) {
		this.iMouseClicked := clicked
	}

	playStartupSong(songFile) {
		if (!kSilentMode && !this.iStartupSongIsPlaying) {
			try {
				songFile := getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)

				if FileExist(songFile) {
					SoundPlay(songFile)

					this.iStartupSongIsPlaying := true
				}
			}
			catch Any as exception {
				logError(exception)
			}
		}
	}

	stopStartupSong(callback := false) {
		local masterVolume

		if this.iStartupSongIsPlaying
			masterVolume := fadeOut()

		try
			SoundPlay("NonExistent.avi")

		if this.iStartupSongIsPlaying {
			if callback
				callback.Call()

			fadeIn(masterVolume)
		}

		this.iStartupSongIsPlaying := false
	}

	initializeBackgroundTasks() {
		PeriodicTask(updateApplicationStates, 5000, kLowPriority).start()
		PeriodicTask(updateModeSelector, 500, kLowPriority).start()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

fadeOut() {
	local masterVolume, currentVolume

	masterVolume := SoundGetVolume()

	currentVolume := masterVolume

	loop {
		currentVolume -= 5

		if (currentVolume <= 0)
			break
		else {
			SoundSetVolume(currentVolume)

			Sleep(100)
		}
	}

	return masterVolume
}

fadeIn(masterVolume) {
	local currentVolume := 0

	loop {
		currentVolume += 5

		if (currentVolume >= masterVolume)
			break
		else {
			SoundSetVolume(currentVolume)

			Sleep(100)
		}
	}

	SoundSetVolume(masterVolume)
}

mouseClicked(clicked := true) {
	SimulatorController.Instance.findPlugin(kSystemPlugin).mouseClick(clicked)
}

restoreSimulatorVolume() {
	local pid, simulator

	if kNirCmd
		try {
			simulator := SimulatorController.Instance.ActiveSimulator

			if (simulator != false) {
				pid := (Application(simulator, SimulatorController.Instance.Configuration)).CurrentPID

				Run("`"" . kNirCmd . "`" setappvolume /" . pid . " 1.0")
			}
		}
		catch Any as exception {
			logError(exception, true)

			showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
}

muteSimulator() {
	local simulator := SimulatorController.Instance.ActiveSimulator
	local pid

	if (simulator != false) {
		SetTimer(muteSimulator, 0)

		Sleep(5000)

		if kNirCmd
			try {
				pid := (Application(simulator, SimulatorController.Instance.Configuration)).CurrentPID

				Run("`"" . kNirCmd . "`" setappvolume /" . pid . " 0.0")
			}
			catch Any as exception {
				logError(exception, true)

				showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}

		SetTimer(unmuteSimulator, 500)

		mouseClicked(false)

		Hotkey("Escape", mouseClicked)
		Hotkey("~LButton", mouseClicked)
	}
}

unmuteSimulator() {
	local plugin := SimulatorController.Instance.findPlugin(kSystemPlugin)

	if (plugin.MouseClicked || GetKeyState("LButton") || GetKeyState("Escape")) {
		Hotkey("~LButton", "Off")
		Hotkey("Escape", "Off")

		SetTimer(unmuteSimulator, 0)

		plugin.stopStartupSong(restoreSimulatorVolume)
	}
}

updateApplicationStates() {
	local ignore, runnable

	static plugin := false
	static controller := false
	static mode := false

	if !plugin {
		controller := SimulatorController.Instance
		plugin := controller.findPlugin(kSystemPlugin)
		mode := plugin.findMode(kLaunchMode)
	}

	if inList(controller.ActiveModes, mode) {
		protectionOn()

		try {
			for ignore, runnable in plugin.RunnableApplications
				runnable.updateRunningState()
		}
		finally {
			protectionOff()
		}
	}
}

updateModeSelector() {
	local function, ignore, selector, currentMode, nextUpdate

	static modeSelectorMode := false
	static controller := false
	static plugin := false

	if !controller {
		controller := SimulatorController.Instance
		plugin := controller.findPlugin(kSystemPlugin)
	}

	protectionOn()

	try {
		for ignore, selector in plugin.ModeSelectors {
			function := selector.Function

			if modeSelectorMode {
				currentMode := controller.ActiveMode[controller.findFunctionController(function)]

				if currentMode
					currentMode := currentMode.Mode
				else
					currentMode := StrReplace(StrReplace(translate("Mode Selector"), A_Space, "`n"), "`r", "")
			}
			else
				currentMode := StrReplace(StrReplace(translate("Mode Selector"), A_Space, "`n"), "`r", "")

			if modeSelectorMode
				function.setLabel(translate(currentMode))
			else
				function.setLabel(currentMode, "Gray")
		}

		nextUpdate := (modeSelectorMode ? 2000 : 1000)

		modeSelectorMode := !modeSelectorMode
	}
	finally {
		protectionOff()
	}

	Task.CurrentTask.Sleep := nextUpdate
}

initializeSystemPlugin() {
	local controller := SimulatorController.Instance

	SystemPlugin(controller, kSystemPlugin, controller.Configuration)

	registerMessageHandler("Startup", functionMessageHandler)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startApplication(application, silent := true) {
	local runnable := SimulatorController.Instance.findPlugin(kSystemPlugin).findRunnableApplication(application)

	if (runnable != false)
		if runnable.isRunning()
			return true
		else
			return (runnable.startup(!silent) != 0)
	else
		return false
}

startupComponent(component) {
	startApplication(component, false)
}

startupSimulator(simulator, silent := false) {
	startApplication(simulator, silent)
}

shutdownSimulator(simulator) {
	local runnable := SimulatorController.Instance.findPlugin(kSystemPlugin).findRunnableApplication(simulator)

	if (runnable != false)
		runnable.shutdown()

	return false
}

playStartupSong(songFile) {
	SimulatorController.Instance.findPlugin(kSystemPlugin).playStartupSong(songFile)

	SetTimer(muteSimulator, 1000)
}

stopStartupSong() {
	SimulatorController.Instance.findPlugin(kSystemPlugin).stopStartupSong()

	SetTimer(muteSimulator, 0)
}

startupExited() {
	SimulatorController.Instance.findPlugin(kSystemPlugin).iChildProcess := false
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

execute(command) {
	local thePlugin := false

	SimulatorController.Instance.runningSimulator(&thePlugin)

	if thePlugin
		thePlugin.activateWindow()

	try {
		Run(substituteVariables(command))
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogWarn, substituteVariables(translate("Cannot execute command (%command%) - please check the configuration"), {command: command}))
	}
}

trigger(hotkeys, method := "Event") {
	local thePlugin := false
	local ignore, theHotkey

	SimulatorController.Instance.runningSimulator(&thePlugin)

	if thePlugin
		thePlugin.activateWindow()

	for ignore, theHotkey in string2Values("|", hotkeys)
		try {
			switch method, false {
				case "Event":
					SendEvent(theHotkey)
				case "Input":
					SendInput(theHotkey)
				case "Play":
					SendPlay(theHotkey)
				case "Raw":
					Send("{Raw}" . theHotkey)
				default:
					Send(theHotkey)
			}
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogWarn, substituteVariables(translate("Cannot send command (%hotkey%) - please check the configuration"), {command: theHotkey}))
		}
}

mouse(button, x, y, count := 1, window := false) {
	local curCoordMode := A_CoordModeMouse

	CoordMode("Mouse", window ? "Window" : "Screen")

	try {
		if (window && WinExist(window))
			WinActivate(window)

		MouseClick(button, x, y, count)
	}
	catch Any as exception {
		logError(exception, true)
	}
	finally {
		CoordMode("Mouse", curCoordMode)
	}
}

invoke(target, method, arguments*) {
	local command

	try {
		if ((target = "Controller") || (target = "Simulator Controller"))
			ObjBindMethod(SimulatorController.Instance, method).Call(arguments*)
		else if InStr(target, ".") {
			target := ConfigurationItem.splitDescriptor(target)

			ObjBindMethod(SimulatorController.Instance.findMode(target[1], target[2]), method).Call(arguments*)
		}
		else
			ObjBindMethod(SimulatorController.Instance.findPlugin(target), method).Call(arguments*)
	}
	catch Any as exception {
		logError(exception, true)

		command := ("invoke(" . values2String(", ", target, method, arguments*) . ")")

		logMessage(kLogWarn, substituteVariables(translate("Cannot execute command (%command%) - please check the configuration"), {command: command}))
	}
}

startSimulation(name := false) {
	local controller := SimulatorController.Instance
	local simulators

	if !(controller.ActiveSimulator != false) {
		if !name {
			simulators := string2Values("|", getMultiMapValue(controller.Configuration, "Configuration", "Simulators", ""))

			if (simulators.Length > 0)
				name := simulators[1]
		}

		withProtection(startupSimulator, name)
	}
}

stopSimulation() {
	local simulator := SimulatorController.Instance.ActiveSimulator

	if (simulator != false)
		withProtection(shutdownSimulator, simulator)
}

shutdownSystem() {
	local msgResult

	OnMessage(0x44, translateYesNoButtons)
	msgResult := MsgBox(translate("Shutdown Simulator?"), translate("Shutdown"), 262436)
	OnMessage(0x44, translateYesNoButtons, 0)

	if (msgResult = "Yes")
		Shutdown(1)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSystemPlugin()