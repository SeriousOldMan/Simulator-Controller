;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - System Plugin (required)        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSystemPlugin = "System"
global kLaunchMode = "Launch"


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
		
		LaunchpadFunction[] {
			Get {
				return this.iLaunchpadFunction
			}
		}
		
		LaunchpadAction[] {
			Get {
				return this.iLaunchpadAction
			}
		}
		
		updateRunningState() {
			isRunning := this.isRunning()
			stateChange := false
			
			if (isRunning != this.iIsRunning) {
				this.iIsRunning := isRunning
				
				stateChange := true
				
				trayMessage(translate(kSystemPlugin), (isRunning ? translate("Start: ") : translate("Stop: ")) . this.Application)
			}
			
			transition := false
			
			if !stateChange {
				transition := this.LaunchpadAction.Transition
						
				if (transition && ((A_TickCount - transition) > 10000)) {
					transition := false
					stateChange := true
					
					this.LaunchpadAction.endTransition()
				}
			}
			else
				this.LaunchpadAction.endTransition()
			
			if (true || (stateChange && (this.LaunchpadFunction != false))) {
				controller := SimulatorController.Instance
					
				if (inList(controller.ActiveModes, controller.findMode(kSystemPlugin, kLaunchMode))) {
					if transition
						this.LaunchpadFunction.setText(this.LaunchpadAction.Label, "Gray")
					else
						this.LaunchpadFunction.setText(this.LaunchpadAction.Label, isRunning ? "Green" : "Black")
				}
			}	
		}
		
		connectAction(function, action) {
			this.iLaunchpadFunction := function
			this.iLaunchpadAction := action
		}
	}
	
	class LaunchMode extends ControllerMode {
		Mode[] {
			Get {
				return kLaunchMode
			}
		}
	}
	
	class ModeSelectorAction extends ControllerAction {	
		Label[] {
			Get {
				controller := this.Controller
				
				mode := controller.ActiveMode[controller.findButtonBox(this.Function)]
				
				if mode
					return mode.Mode
				else
					return translate("Mode Selector")
			}
		}
	
		fireAction(function, trigger) {
			controller := this.Controller
			
			controller.rotateMode(((trigger == "Off") || (trigger == "Decrease")) ? -1 : 1, Array(controller.findButtonBox(function)))

			this.Function.setText(controller.findPlugin(kSystemPlugin).actionLabel(this))
		}
	}

	class LaunchAction extends ControllerAction {
		iApplication := false
		iTransition := false
	
		Application[] {
			Get {
				return this.iApplication
			}
		}
	
		Transition[] {
			Get {
				return this.iTransition
			}
		}
	
		__New(function, label, name) {
			this.iApplication := new Application(name, function.Controller.Configuration)
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			if !this.Transition {
				if (inList(function.Controller.ActiveModes, function.Controller.findMode(kSystemPlugin, kLaunchMode))) {
					this.beginTransition()
				
					function.setText(this.Label, "Gray")
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
	
	ChildProcess[] {
		Get {
			return this.iChildProcess
		}
	}
	
	ModeSelectors[] {
		Get {
			return this.iModeSelectors
		}
	}
	
	RunnableApplications[] {
		Get {
			return this.iRunnableApplications
		}
	}
	
	MouseClicked[] {
		Get {
			return this.iMouseClicked
		}
	}
	
	__New(controller, name, configuration := false) {
		local function
		local action
		
		this.iLaunchMode := new this.LaunchMode(this)
		
		if inList(A_Args, "-Startup")
			this.iChildProcess := true
		
		base.__New(controller, name, configuration)
		
		for ignore, descriptor in string2Values(A_Space, this.getArgumentValue("modeSelector", ""))
			if (descriptor != false) {
				function := controller.findFunction(descriptor)
				
				if (function != false) {
					action := new this.ModeSelectorAction(function)
					
					this.iModeSelectors.Push(action)
					
					this.registerAction(action)
				}
				else
					this.logFunctionNotFound(descriptor)
			}
		
		descriptor := this.getArgumentValue("logo", false)
		
		if (descriptor != false) {
			function := controller.findFunction(descriptor)
		
			if (function != false)
				this.iLaunchMode.registerAction(new this.LogoToggleAction(function, ""))
			else
				this.logFunctionNotFound(descriptor)
		}
		
		descriptor := this.getArgumentValue("shutdown", false)
		
		if (descriptor != false) {
			function := controller.findFunction(descriptor)
		
			if (function != false)
				this.iLaunchMode.registerAction(new this.SystemShutdownAction(function, "Shutdown"))
			else
				this.logFunctionNotFound(descriptor)
		}
		
		this.registerMode(this.iLaunchMode)
		controller.registerPlugin(this)
		
		this.initializeBackgroundTasks()
	}
	
	loadFromConfiguration(configuration) {
		local action
		local function
		
		base.loadFromConfiguration(configuration)
		
		for descriptor, name in getConfigurationSectionValues(configuration, "Applications", Object())
			this.RunnableApplications.Push(new this.RunnableApplication(name, configuration))
	
		for descriptor, appDescriptor in getConfigurationSectionValues(configuration, "Launchpad", Object()) {
			function := this.Controller.findFunction(descriptor)
			
			if (function != false) {
				appDescriptor := string2Values("|", appDescriptor)
			
				runnable := this.findRunnableApplication(appDescriptor[2])
				
				if (runnable != false) {
					action := new this.LaunchAction(function, appDescriptor[1], appDescriptor[2])
					
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
	
	simulatorStartup(simulator) {
		if this.ChildProcess {
			; Looks like we have recurring deadlock situations with bidirectional pipes in case of process exit situations...
			;
			; raiseEvent(kPipeMessage, "Startup", "exitStartup")
			;
			; Using a sempahore file instead...
			
			fileName := (kTempDirectory . "Startup.semaphore")
						
			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}
		}
	
		base.simulatorStartup(simulator)
	}
	
	findRunnableApplication(name) {
		for ignore, candidate in this.RunnableApplications
			if (name == candidate.Application)
				return candidate
				
		return false
	}
	
	mouseClick(clicked := true) {
		iMouseClicked := clicked
	}
	
	playStartupSong(songFile) {
		if (!kSilentMode && !this.iStartupSongIsPlaying) {
			try {
				songFile := getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)
				
				if FileExist(songFile) {
					SoundPlay %songFile%
			
					this.iStartupSongIsPlaying := true
				}
			}
			catch exception {
				; Ignore
			}
		}
	}
	
	stopStartupSong(callback := false) {
		if this.iStartupSongIsPlaying
			masterVolume := fadeOut()
			
		try {
			SoundPlay NonExistent.avi
		}
		catch ignore {
			; Ignore
		}
		
		if this.iStartupSongIsPlaying {
			if callback
				%callback%()
				
			fadeIn(masterVolume)
		}

		this.iStartupSongIsPlaying := false
	}

	initializeBackgroundTasks() {
		SetTimer updateApplicationStates, 5000
		SetTimer updateModeSelector, -500
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

fadeOut() {
	SoundGet masterVolume, MASTER

	currentVolume := masterVolume

	Loop {
		currentVolume -= 5

		if (currentVolume <= 0)
			break
		else {
			SoundSet %currentVolume%, MASTER

			Sleep 100
		}
	}
	
	return masterVolume
}

fadeIn(masterVolume) {
	currentVolume := 0

	Loop {
		currentVolume += 5

		if (currentVolume >= masterVolume)
			break
		else {
			SoundSet %currentVolume%, MASTER

			Sleep 100
		}
	}

	SoundSet %masterVolume%, MASTER
}

mouseClicked(clicked := true) {
	SimulatorController.Instance.findPlugin(kSystemPlugin).mouseClick(clicked)
}

restoreSimulatorVolume() {
	if kNirCmd
		try {
			simulator := SimulatorController.Instance.ActiveSimulator
			
			if (simulator != false) {
				pid := (new Application(simulator, SimulatorController.Instance.Configuration)).CurrentPID
				
				Run "%kNirCmd%" setappvolume /%pid% 1.0
			}
		}
		catch exception {
			showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
}

muteSimulator() {
	simulator := SimulatorController.Instance.ActiveSimulator
	
	if (simulator != false) {
		SetTimer muteSimulator, Off
		
		Sleep 5000
		
		if kNirCmd
			try {
				pid := (new Application(simulator, SimulatorController.Instance.Configuration)).CurrentPID
				
				Run "%kNirCmd%" setappvolume /%pid% 0.0
			}
			catch exception {
				showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
	
		SetTimer unmuteSimulator, 500
		
		mouseClicked(false)
		
		HotKey Escape, mouseClicked
		HotKey ~LButton, mouseClicked
	}
}

unmuteSimulator() {
	local plugin := SimulatorController.Instance.findPlugin(kSystemPlugin)
	
	if (plugin.MouseClicked || GetKeyState("LButton") || GetKeyState("Escape")) {
		HotKey ~LButton, Off
		HotKey Escape, Off
		
		SetTimer unmuteSimulator, Off

		plugin.stopStartupSong("restoreSimulatorVolume")
	}
}

updateApplicationStates() {
	static plugin := false
	static controller := false
	static mode:= false
	
	if !plugin {
		controller := SimulatorController.Instance
		plugin := controller.findPlugin(kSystemPlugin)
		mode := plugin.findMode(kLaunchMode)
	}
		
	protectionOn()

	try {
		for ignore, runnable in plugin.RunnableApplications
			if inList(controller.ActiveModes, mode)
				runnable.updateRunningState()
	}
	finally {
		protectionOff()
	}
}

updateModeSelector() {
	local function
	
	static modeSelectorMode := false
	static controller := false
	
	nextUpdate := -500
	
	if !controller
		controller := SimulatorController.Instance
	
	protectionOn()
	
	try {
		for ignore, selector in controller.findPlugin(kSystemPlugin).ModeSelectors {
			function := selector.Function
			
			if modeSelectorMode {
				currentMode := controller.ActiveMode[controller.findButtonBox(function)]
				
				if currentMode
					currentMode := currentMode.Mode
				else
					currentMode := translate("Mode Selector")
			}
			else
				currentMode := translate("Mode Selector")
			
			if modeSelectorMode
				function.setText(translate(currentMode))
			else
				function.setText(currentMode, "Gray")
		}
		
		nextUpdate := (modeSelectorMode ? -2000 : -1000)

		modeSelectorMode := !modeSelectorMode
	}
	finally {
		protectionOff()
		
		SetTimer updateModeSelector, %nextUpdate%
	}
}

initializeSystemPlugin() {
	local controller
	
	controller := SimulatorController.Instance
	
	new SystemPlugin(controller, kSystemPlugin, controller.Configuration)
	
	registerEventHandler("Startup", "functionEventHandler")
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupApplication(application, silent := true) {
	runnable := SimulatorController.Instance.findPlugin(kSystemPlugin).findRunnableApplication(application)
	
	if (runnable != false)
		if runnable.isRunning()
			return true
		else
			return (runnable.startup(!silent) != 0)
	else
		return false
}

startupComponent(component) {
	startupApplication(component, false)
}

startupSimulator(simulator, silent := false) {
	startupApplication(simulator, silent)
}

shutdownSimulator(simulator) {
	runnable := SimulatorController.Instance.findPlugin(kSystemPlugin).findRunnableApplication(simulator)
	
	if (runnable != false)
		runnable.shutdown()
	
	return false
}

playStartupSong(songFile) {
	SimulatorController.Instance.findPlugin(kSystemPlugin).playStartupSong(songFile)
	
	SetTimer muteSimulator, 1000
}

stopStartupSong() {
	SimulatorController.Instance.findPlugin(kSystemPlugin).stopStartupSong()
		
	SetTimer muteSimulator, Off
}
	
startupExited() {
	SimulatorController.Instance.findPlugin(kSystemPlugin).iChildProcess := false
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

execute(command) {
	command := substituteVariables(command)
	
	try {
		Run %command%
	}
	catch exception {
		logMessage(kLogWarn, substituteVariables(translate("Cannot execute command (%command%) - please check the configuration"), {command: command}))
	}
}

startSimulation(name := false) {
	local controller := SimulatorController.Instance
	
	if !(controller.ActiveSimulator != false) {
		if !name {
			simulators := string2Values("|", getConfigurationValue(controller.Configuration, "Configuration", "Simulators", ""))
	
			if (simulators.Length() > 0)
				name := simulators[1]
		}
		
		withProtection("startupSimulator", name)
	}
}

stopSimulation() {
	local simulator := SimulatorController.Instance.ActiveSimulator
	
	if (simulator != false) {
		withProtection("shutdownSimulator", simulator)
	}
}

shutdownSystem() {
	SoundPlay *32
	
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	title := translate("Shutdown")
	MsgBox 262436, %title%, % translate("Shutdown Simulator?")
	OnMessage(0x44, "")

	IfMsgBox Yes
		Shutdown 1
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSystemPlugin()