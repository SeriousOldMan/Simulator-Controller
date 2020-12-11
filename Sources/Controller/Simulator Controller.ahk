;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator  Controller           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
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
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAllTrigger = "__All Trigger__"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLogoBright = kResourcesDirectory . "Logo Bright.gif"
global kLogoDark = kResourcesDirectory . "Logo Dark.gif"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ButtonBox extends ConfigurationItem {
	iController := false
	
	iNum1WayToggles := 0
	iNum2WayToggles := 0
	iNumButtons := 0
	iNumDials := 0
	
	iWindow := false
	iWindowWidth := 0
	iWindowHeight := 0
	
	iIsVisble := false
	
	Controller[] {
		Get {
			return this.iController
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
	
	VisibleDuration[] {
		Get {
			controller := this.Controller
			
			if (controller != false) {
				inSimulation := (controller.ActiveSimulator != false)
	
				return getConfigurationValue(this.Controller.ControllerConfiguration, "Controller"
										   , inSimulation ? "Button Box Simulation Duration" : "Button Box Duration"
										   , inSimulation ? false : 10000)
			}
			else
				return false
		}
	}

	__New(controller, configuration := false) {
		this.iController := controller
		
		ButtonBox.Instance := this
		
		base.__New(configuration)
		
		this.createWindow(window, width, height)
		
		this.iWindow := window
		this.iWindowWidth := width
		this.iWindowHeight := height
		
		controller.registerButtonBox(this)
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iNum1WayToggles := getConfigurationValue(configuration, "Controller Layout", "1WayToggles", 0)
		this.iNum2WayToggles := getConfigurationValue(configuration, "Controller Layout", "2WayToggles", 0)
		this.iNumButtons := getConfigurationValue(configuration, "Controller Layout", "Buttons", 0)
		this.iNumDials := getConfigurationValue(configuration, "Controller Layout", "Dials", 0)
		
		logMessage(kLogInfo, "Controller layout initialized: # " . this.iNum1WayToggles . " 1-Way Toggles, # " . this.iNum2WayToggles . " 2-Way Toggles, # " . this.iNumButtons . " Buttons, # " . this.iNumDials . " Dials")
	}
	
	createWindow(ByRef window, ByRef windowWidth, ByRef windowHeight) {
		Throw "Virtual method ButtonBox.createWindow must be overriden in a subclass..."
	}
	
	getControlHandle(descriptor) {
		Throw "Virtual method ButtonBox.getControlHandle must be overriden in a subclass..."
	}
	
	setControlText(function, text, color := "Black") {
		window := this.iWindow
		
		if (window != false) {
			handle := this.getControlHandle(function.Descriptor)
    
			Gui %window%:Font, c%color%
			GuiControl Text, %handle%, % text
			GuiControl Font, %handle%
			Gui %window%:Font
			
			this.show()
		}
	}
	
	isVisible() {
		return this.iIsVisible
	}
	
	updateVisibility() {
		this.show(false)
	}
	
	show(makeVisible := true) {
		if ((A_TickCount - this.Controller.LastEvent) > 1000)
			return
	
		duration := this.VisibleDuration
	
		if (duration >= 9999)
			duration := 24 * 3600 * 1000 ; Show always - one day should be enough :-)
		
		if (duration > 0) {
			if this.iIsVisible
				SetTimer hideButtonBox, %duration%
			else {
				SetTimer hideButtonBox, Off
		
				protectionOn()

				try {
					if makeVisible {
						this.Controller.hideLogo()
				
						window := this.iWindow
						width := this.iWindowWidth
						height := this.iWindowHeight
					
						position := getConfigurationValue(this.Controller.ControllerConfiguration, "Controller", "Button Box Position", "Bottom Right")
						
						switch position {
							case "Top Left":
								x := 0
								y := 0
							case "Top Right":
								x := A_ScreenWidth - width
								y := 0
							case "Bottom Left":
								x := 0
								y := A_ScreenHeight - height
							case "Bottom Right":
								x := A_ScreenWidth - width
								y := A_ScreenHeight - height
							default:
								Throw "Unhandled position for Button Box (" . position . ") encountered in ButtonBox.show..."
						}
					
						Gui %window%:Show, x%x% y%y% w%width% h%height% NoActivate
    
						this.iIsVisible := true
					}
					
					SetTimer hideButtonBox, On
					SetTimer hideButtonBox, %duration%
				}
				finally {
					protectionOff()
				}
			}
		}
		else
			this.hide()
	}
	
	hide() {
		protectionOn()
	
		try {
			if this.iIsVisible {
				window := this.iWindow
			
				Gui %window%:Hide
			}
	
			this.iIsVisible := false
	
			SetTimer hideButtonBox, Off
		}
		finally {
			protectionOff()
		}
	}
}

class SimulatorController extends ConfigurationItem {
	iControllerConfiguration := false
	
	iPlugins := []
	iFunctions := {}
	iButtonBox := false
	
	iModes := []
	iActiveMode := false
	
	iFunctionActions := {}
	
	iLastEvent := A_TickCount
	
	iShowLogo := true
	iLogoIsVisible := false
	
	ControllerConfiguration[] {
		Get {
			return this.iControllerConfiguration
		}
	}
	
	ButtonBox[] {
		Get {
			return this.iButtonBox
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
	
	ActiveMode[] {
		Get {
			return this.iActiveMode
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
	
	__New(simulatorConfiguration, controllerConfiguration) {
		SimulatorController.Controller := this
		
		this.iControllerConfiguration := controllerConfiguration
		
		SimulatorController.Instance := this
		
		base.__New(simulatorConfiguration)
		
		this.initializeBackgroundTasks()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		for descriptor, arguments in getConfigurationSectionValues(configuration, "Controller Functions", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			descriptor := ConfigurationItem.descriptor(descriptor[1], descriptor[2])
			functions := this.Functions
			
			if !functions.HasKey(descriptor)
				functions[descriptor] := this.createControllerFunction(descriptor, configuration)
		}
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
				Throw "Unknown controller function (" . descriptor[1] . ") detected in SimulatorController.createControllerFunction..."
		}
	}
	
	findPlugin(name) {
		for ignore, mode in this.Plugins
			if (mode.Plugin = name)
				return mode
		
		return false
	}
	
	findMode(name) {
		for ignore, mode in this.Modes
			if (mode.Mode = name)
				return mode
		
		return false
	}
	
	findFunction(descriptor) {
		functions := this.Functions
		
		return (functions.HasKey(descriptor) ? functions[descriptor] : false)
	}
	
	findAction(function, trigger) {
		return (this.iFunctionActions.HasKey(function) ? this.iFunctionActions[function] : false)
	}
	
	getLogo() {
		Random randomLogo, 0, 1
	
		return ((Round(randomLogo) == 1) ? kLogoDark : kLogoBright)
	}
	
	registerButtonBox(buttonBox) {
		this.iButtonBox := buttonBox
	}
	
	registerPlugin(plugin) {
		if !inList(this.Plugins, plugin) {
			logMessage(kLogInfo, "Plugin " . getPluginForLogMessage(plugin) . (this.isActive(plugin) ? " (Active)" : " (Inactive)") . " registered")
			
			this.Plugins.Push(plugin)
		}
	
		if this.isActive(plugin)
			plugin.activate()
	}
	
	registerMode(plugin, mode) {
		if !inList(this.Modes, mode) {
			logMessage(kLogInfo, "Mode " . getModeForLogMessage(mode) . " registered" . (plugin ? (" for plugin " . getPluginForLogMessage(plugin)) : ""))
			
			this.Modes.Push(mode)
		}
	}
	
	isActive(modeOrPlugin) {
		return isDebug() ? true : modeOrPlugin.isActive()
	}
	
	runningSimulator() {
		local plugin
		
		for ignore, plugin in this.Plugins
			if this.isActive(plugin) {
				simulator := plugin.runningSimulator()
				
				if (simulator != false)
					return simulator
			}
		
		return false
	}

	simulatorStartup(simulator) {
		local plugin
		local buttonBox
	
		for ignore, plugin in this.Plugins
			if this.isActive(plugin)
				plugin.simulatorStartup(simulator)
		
		buttonBox := this.ButtonBox
		
		if ((buttonBox != false) && buttonBox.isVisible()) {
			buttonBox.hide()
			buttonBox.show()
		}
	}
	
	simulatorShutdown() {
		local plugin
		local buttonBox
		
		for ignore, plugin in this.Plugins
			if this.isActive(plugin) 
				plugin.simulatorShutdown()
		
		buttonBox := this.ButtonBox
		
		if ((buttonBox != false) && buttonBox.isVisible()) {
			buttonBox.hide()
			buttonBox.show()
		}
	}	
	
	connectAction(function, action) {
		logMessage(kLogInfo, "Connecting " . function.Descriptor . " to action " . getLabelForLogMessage(action))
		
		function.connectAction(action)
		
		this.iFunctionActions[function] := action
	}
	
	disconnectAction(function, action) {
		logMessage(kLogInfo, "Disconnecting " . function.Descriptor . " from action " . getLabelForLogMessage(action))
		
		function.disconnectAction(action)
		
		this.iFunctionActions.Delete(function)
	}
	
	fireAction(function, trigger) {
		action := this.findAction(function, trigger)
		
		if (action != false) {
			this.iLastEvent := A_TickCount
			
			logMessage(kLogInfo, "Firing action " . getLabelForLogMessage(action) . " for " . function.Descriptor)
			
			action.fireAction(function, trigger)
		}
		else
			Throw "Cannot find action for " . function.Descriptor . ".trigger " . " in SimulatorController.fireAction..."
	}	

	setMode(newMode) {
		if !this.isActive(newMode)
			return
			
		modeSwitched := (this.ActiveMode != newMode)
	
		if modeSwitched {
			if (this.ActiveMode != false)
				this.ActiveMode.deactivate()
		
			this.iActiveMode := newMode
			
			logMessage(kLogInfo, "Setting controller mode to " . getModeForLogMessage(newMode))
			
			if (newMode != false)
				newMode.activate()
		
			if modeSwitched
				trayMessage("Control", "Mode: " . newMode.Mode)
		}
	}
	
	rotateMode(delta := 1) {
		modes := this.Modes
		position := inList(modes, this.ActiveMode)
	
		targetMode := false
		index := position + delta
	
		Loop {
			if (index > modes.Length())
				index := 1
			else if (index < 1)
				index := modes.Length()
		
			targetMode := modes[index]
		
			if !this.isActive(targetMode) {
				index += delta
				targetMode := false
			}
		} until targetMode
		
		this.setMode(targetMode)
	}

	showLogo(show := "__Undefined__") {
		if (show != kUndefined)
			this.iShowLogo := show
		else if (this.iShowLogo && !this.iLogoIsVisible) {
			static videoPlayer
	
			info := kVersion . " - 2020 by Oliver Juwig`nCreative Commons - BY-NC-SA"
			logo := this.getLogo()
			image := "1:" . logo

			x := A_ScreenWidth - 229
			y := A_ScreenHeight - 259
		
			SplashImage %image%, B FS8 CWD0D0D0 w229 x%x% y%y% ZH180 ZW209, %info%, Modular Simulator`nController System
	
			WinSet Transparent, 192, , Creative Commons - BY-NC-SA
		
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
		SetTimer updateSimulatorState, 1000
		
		this.iShowLogo := !kSilentMode
	}
}

class SimulatorControllerFunction {
	iController := false
	iFunction := false
	
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
	
	setText(text, color := "Black") {
		btnBox := this.Controller.ButtonBox
		
		if (btnBox != false)
			btnBox.setControlText(this, text, color)
	}
	
	enable(trigger) {
		if (trigger == kAllTrigger)
			for ignore, trigger in this.Trigger
				setHotkeyEnabled(this, trigger, true)
		else
			setHotkeyEnabled(this, trigger, true)
	}
	
	disable(trigger) {
		if (trigger == kAllTrigger)
			for ignore, trigger in this.Function.Trigger
				setHotkeyEnabled(this, trigger, false)
		else
			setHotkeyEnabled(this, trigger, false)
	}
	
	connectAction(action) {
		for ignore, trigger in this.Function.Trigger {
			handler := this.Actions[trigger]
			theHotkey := ""
			
			for ignore, hotkey in this.Hotkeys[trigger] {
				try {
					theHotkey := hotkey
					
					Hotkey %hotkey%, %handler%
					Hotkey %hotkey%, On
				}
				catch exception {
					logMessage(kLogCritical, "Error while registering hotkey " . theHotkey . " - please check the setup")
		
					SplashTextOn 800, 60, Modular Simulator Controller System, Cannot register hotkey %theHotkey%`n`nPlease run the setup tool...
							
					Sleep 5000
								
					SplashTextOff
				}
			}
		}
	}
	
	disconnectAction(action) {
		for ignore, trigger in this.Function.Trigger {
			for ignore, hotkey in this.Hotkeys[trigger] {
				this.setText("")
				
				Hotkey %hotkey%, Off
			}
		}
	}
}

class Controller1WayToggleFunction extends SimulatorControllerFunction {
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

class Controller2WayToggleFunction extends SimulatorControllerFunction {
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

class ControllerButtonFunction extends SimulatorControllerFunction {
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

class ControllerDialFunction extends SimulatorControllerFunction {
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

class ControllerCustomFunction extends SimulatorControllerFunction {
	class InnerCustomFunction extends CustomFunction {
		iOuterFunction := false
			
		__New(outerFunction, functionNumber, configuration := false) {
			this.iOuterFunction := outerFunction
			
			base.__New(functionNumber, configuration)
		}
	}
	
	__New(controller, number, configuration := false) {
		base.__New(controller, new this.InnerCustomFunction(this, number, configuration))
			
		this.connectAction(false)
	}
}

class ControllerPlugin extends Plugin {
	iController := false
	iModes := []
	iActions := []
	
	Plugin[] {
		Get {
			Throw "Virtual property ControllerPlugin.Plugin must be overriden in a subclass..."
		}
	}
	
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
	
	__New(controller, name, configuration := false) {
		this.iController := controller
		
		base.__New(name, configuration)
		
		if (this.Controller != false)
			this.Controller.registerPlugin(this)
	}
	
	findMode(name) {
		for ignore, mode in this.Modes
			if (mode.Mode = name)
				return mode
		
		return false
	}
	
	findAction(label) {
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
	
	isActive() {
		return this.Active
	}
	
	activate() {
		controller := this.Controller
		
		logMessage(kLogInfo, "Activating plugin " . this.Plugin)
		
		for ignore, action in this.Actions {
			controller.connectAction(action.Function, action)
			
			action.Function.enable(kAllTrigger)
			action.Function.setText(action.Label)
		}
	}
	
	deactivate() {
		controller := this.Controller
		
		logMessage(kLogInfo, "Deactivating plugin " . this.Plugin)
		
		for ignore, action in this.Actions
			controller.disconnectAction(action.Function, action)
	}
	
	runningSimulator() {
		return false
	}
	
	simulatorStartup(simulator) {
	}
	
	simulatorShutdown() {
	}
}

class ControllerMode {
	iPlugin := false
	iActions := []
	
	Mode[] {
		Get {
			Throw "Virtual property ControllerMode.Mode must be overriden in a subclass..."
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
	
	__New(plugin) {
		this.iPlugin := plugin
		
		plugin.registerMode(this)
	}
	
	registerAction(action) {
		if !inList(this.Actions, action)
			this.Actions.Push(action)
	}
	
	findAction(label) {
		for ignore, candidate in this.Actions
			if (candidate.Label = label)
				return candidate
			
		return false
	}
	
	isActive() {
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
		controller := this.Controller
		
		logMessage(kLogInfo, "Activating mode " . getModeForLogMessage(this))
		
		for ignore, action in this.Actions {
			controller.connectAction(action.Function, action)
			
			action.Function.enable(kAllTrigger)
			action.Function.setText(action.Label)
		}
	}
	
	deactivate() {
		controller := this.Controller
		
		logMessage(kLogInfo, "Deactivating mode " . getModeForLogMessage(this))
		
		for ignore, action in this.Actions
			controller.disconnectAction(action.Function, action)
	}
}

class ControllerAction {
	iFunction := false
	iLabel := ""
	
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
	
	__New(function, label := "") {
		this.iFunction := function
		this.iLabel := label
	}
	
	fireAction(function, trigger) {
		Throw "Virtual method ControllerAction.fireAction must be overriden in a subclass..."
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showButtonBox() {
	btnBox := ButtonBox.Instance
	
	if (btnBox != false)
		btnBox.show()
}

hideButtonBox() {
	btnBox := ButtonBox.Instance
	
	if (btnBox != false)
		btnBox.hide()
}

setHotkeyEnabled(function, trigger, enabled) {
	state := enabled ? "On" : "Off"
	
	for ignore, hotkey in function.Hotkeys[trigger]
		Hotkey %hotkey%, %state%
}

functionActionCallable(function, trigger, action) {
	return (action ? action : Func("fireControllerAction").bind(function, trigger))
}

fireControllerAction(function, trigger) {
	protectionOn()
	
	try {
		function.Controller.fireAction(function, trigger)
	}
	finally {
		protectionOff()
	}
}

getLabelForLogMessage(action) {
	label := action.Label

	if (label == "")
		label := action.base.__Class
	
	return label
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
	static isSimulatorRunning := false
	controller := SimulatorController.Instance
	
	protectionOn()

	try {
		updateTrayMessageState()
	
		stateChange := false
	
		if (isSimulatorRunning != (controller.ActiveSimulator != false)) {
			isSimulatorRunning := !isSimulatorRunning
		
			if isSimulatorRunning {
				raiseEvent("ahk_exe Simulator Startup.exe", "Startup", "exitStartup")
				
				controller.simulatorStartup(controller.ActiveSimulator)
			}
			else
				controller.simulatorShutdown()
		}

		btnBox := controller.ButtonBox
		
		if (btnBox != false)
			btnBox.updateVisibility()
		
		if isSimulatorRunning {
			SetTimer updateSimulatorState, 5000
			
			controller.hideLogo()
		}
		else {
			SetTimer updateSimulatorState, 1000

			if ((btnBox != false) && !btnBox.isVisible())
				controller.showLogo()
		}
	}
	finally {
		protectionOff()
	}
}

updateTrayMessageState(configuration := false) {
	inSimulation := false
	
	if !configuration {
		configuration := SimulatorController.Instance.ControllerConfiguration
		inSimulation := SimulatorController.Instance.ActiveSimulator
	}
	
	duration := getConfigurationValue(configuration, "Controller"
									, inSimulation ? "Tray Tip Simulation Duration" : "Tray Tip Duration"
									, inSimulation ? 1500 : false)
							   
	if (duration > 0)
		enableTrayMessages(duration)
	else
		disableTrayMessages()
}

initializeSimulatorController() {
	controllerConfiguration := readConfiguration(kControllerConfigurationFile)
	
	updateTrayMessageState(controllerConfiguration)

	icon := kIconsDirectory . "Gear.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	protectionOn()
	
	try {
		new SimulatorController(kSimulatorConfiguration, controllerConfiguration)
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

pushButton(buttonNumber) {
	descriptor := ConfigurationItem.descriptor(kButtonType, buttonNumber)
	function := SimulatorController.Instance.findFunction(descriptor)
	
	if (function != false)
		fireControllerAction(function, "Push")
	else
		logMessage(kLogWarn, "Controller function " . descriptor . " not found in custom controller action pushButton - please check the setup")
}

rotateDial(dialNumber, direction) {
	if (direction = "increase")
		direction := "Increase"
	else if (direction = "decrease")
		direction := "Decrease"
	else {
		logMessage(kLogWarn, "Unsupported argument (" . direction . ") detected in rotateDial - please check the setup")
		
		Throw "Unsupported argument (" . direction . ") detected in rotateDial..."
	}
	
	descriptor := ConfigurationItem.descriptor(kDialType, dialNumber)
	function := SimulatorController.Instance.findFunction(descriptor)
	
	if (function != false)
		fireControllerAction(function, direction)
	else
		logMessage(kLogWarn, "Controller function " . descriptor . " not found in custom controller action rotateDial - please check the setup")
}

switchToggle(toggleType, toggleNumber, mode := "activate") {
	descriptor := ConfigurationItem.descriptor(toggleType, toggleNumber)
	function := SimulatorController.Instance.findFunction(descriptor^)
	
	if (function != false) {
		if ((mode = "activate") || (mode = "on"))
			fireControllerAction(function, "On")
		else if ((mode = "deactivate") || (mode = "off"))
			fireControllerAction(function, "Off")
		else {
			logMessage(kLogWarn, "Unsupported argument (" . mode . ") detected in switchToggle - please check the setup")
		
			Throw "Unsupported argument (" . mode . ") detected in switchToggle..."
		}
	}
	else
		logMessage(kLogWarn, "Controller function " . descriptor . " not found in custom controller action switchToggle - please check the setup")
}

setMode(action) {
	controller := SimulatorController.Instance

	protectionOn()
	
	try {
		if (action = kIncrease)
			SimulatorController.Instance.rotateMode(1)
		else if (action = kDecrease)
			SimulatorController.Instance.rotateMode(-1)
		else {
			mode := controller.findMode(action)
			
			if ((mode != false) && controller.isActive(mode))
				controller.setMode(mode)
			else
				trayMessage("Control", "Mode: " . action . " is not available", 10000)
		}
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorController()


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include Plugins\Plugins.ahk
