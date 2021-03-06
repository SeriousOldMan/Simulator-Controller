;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Motion Feedback Plugin          ;;;
;;;                                         (Powered by SimFeedback)        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    Creative Commons - BY-NC-SA                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kMotionIntensityIncrement = 5
global kMotionIntensityMin = 0
global kMotionIntensityMax = 50
global kMotionIntensityRange = 100

global kMotionSliderY = 231
global kMotionSliderMinX = 377
global kMotionSliderMaxX = 450
global kMotionSliderWidth = kMotionSliderMaxX - kMotionSliderMinX

global kEffectIntensityIncrement = 0.1
global kEffectIntensityMin = 0.2
global kEffectIntensityMax = 1.8
global kEffectIntensityRange = 2.0

global kEffectMuteToggleX = 276
global kEffectMuteToggleY = [330, 425, 520, 615, 710, 805, 900]

global kEffectsSliderMinX = 730
global kEffectsSliderMaxX = 950
global kEffectsSliderWidth = kEffectsSliderMaxX - kEffectsSliderMinX
global kEffectsSliderY = [305, 400, 495, 590, 685, 780, 875]

global kSimFeedbackConnector := false


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kMotionFeedbackPlugin = "Motion Feedback"
global kMotionMode = "Motion"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;
	
class MotionFeedbackPlugin extends ControllerPlugin {
	kInitialMotionIntensity := 30
	
	kEffects := []
	kInitialEffectStates := []
	kInitialEffectIntensities := []
	
	iCurrentMotionIntensity := false
	iCurrentEffectStates := false
	iCurrentEffectIntensities := false
	
	iMotionApplication := false
	iIsMotionActive := false
	
	class MotionMode extends ControllerMode {
		iSelectedEffect := false
		iIntensityDialAction := false
		
		Mode[] {
			Get {
				return kMotionMode
			}
		}
		
		SelectedEffect[] {
			Get {
				if ((this.iSelectedEffect != false) && (this.iSelectedEffect != kUndefined))
					return this.iSelectedEffect
				else
					return false
			}
		}
		
		PendingEffect[] {
			Get {
				return (this.iSelectedEffect == kUndefined)
			}
		}
		
		registerIntensityDialAction(intensityDialAction) {
			this.iIntensityDialAction := intensityDialAction
		}
		
		updateEffectLabels() {
			static isInfo := false
			
			if (inList(this.Controller.ActiveModes, this)) {
				state := (isInfo ? ((this.iSelectedEffect == kUndefined) ? "Highlight" : "Info") : "Normal")
				
				for index, effect in this.Plugin.kEffects
					if inList(this.Controller.ActiveModes, this)
						this.findAction(this.Plugin.getLabel(ConfigurationItem.descriptor(effect, "Toggle"), effect)).updateLabel(state)
			
				if inList(this.Controller.ActiveModes, this)
					this.findAction(this.Plugin.getLabel(ConfigurationItem.descriptor("Motion Intensity", "Dial"), "Motion Intensity")).updateLabel(isInfo ? "Info" : "Normal")
			
				isInfo := !isInfo
			}
		}
		
		selectEffect(effect) {
			this.iSelectedEffect := effect

			this.iIntensityDialAction.setEffect(effect)
		}
		
		chooseEffect() {
			this.iSelectedEffect := kUndefined
			
			this.iIntensityDialAction.setEffect(false)
		}
		
		deselectEffect() {
			this.selectEffect(false)
		}
		
		isActive() {
			return (base.isActive() && this.Plugin.Application.isRunning())
		}
		
		activate() {
			base.activate()
			
			this.deselectEffect()
			
			this.updateActionStates()
			
			SetTimer updateEffectLabels, 1500
		}
		
		deactivate() {
			base.deactivate()
			
			SetTimer updateEffectLabels, Off
			
			this.deselectEffect()
		}
		
		updateActionStates() {
			for index, effect in this.Plugin.kEffects
				this.findAction(this.Plugin.getLabel(ConfigurationItem.descriptor(effect, "Toggle"), effect)).updateLabel("Normal")
		}
	}

	class MotionToggleAction extends ControllerAction {
		Plugin[] {
			Get {
				return this.Controller.findPlugin(kMotionFeedbackPlugin)
			}
		}
		
		Active[] {
			Get {
				return this.Plugin.MotionActive
			}
		}
		
		fireAction(function, trigger) {
			local plugin := this.Plugin
			
			if (this.Active && ((trigger = "Off") || (trigger == "Push"))) {
				plugin.findMode(kMotionMode).deselectEffect()
				
				plugin.stopMotion()
			}
			else if (!this.Active && ((trigger = "On") || (trigger == "Push")))
				plugin.startMotion()
				
			if this.Active {				
				trayMessage(plugin.actionLabel(this), translate("State: On"))
			
				function.setText(plugin.actionLabel(this), "Green")
			}
			else {
				trayMessage(plugin.actionLabel(this), translate("State: Off"))
			
				function.setText(plugin.actionLabel(this), "Gray")
			}
		}
	}

	class MotionModeAction extends ControllerAction {
		iMotionMode := false
		
		Mode[] {
			Get {
				return this.iMotionMode
			}
		}
		
		Plugin[] {
			Get {
				return this.Mode.Plugin
			}
		}
		
		__New(function, motionMode, label) {
			this.iMotionMode := motionMode
			
			base.__New(function, label)
		}
	}
			
	class MotionIntensityAction extends MotionFeedbackPlugin.MotionModeAction {
		__New(function, motionMode, label) {
			base.__New(function, motionMode, label)
		}
		
		fireAction(function, trigger) {
			if ((trigger = "On") || (trigger == "Increase"))
				this.Mode.Plugin.increaseMotionIntensity()
			else if ((trigger = "Off") || (trigger == "Decrease"))
				this.Mode.Plugin.decreaseMotionIntensity()
			
			currentIntensity := this.Mode.Plugin.getMotionIntensity()
			
			trayMessage(translate("Motion"), translate("Intensity: ") . currentIntensity)
				
			function.setText(currentIntensity . translate("%"))
			
			Sleep 500
			
			function.setText(translate("Motion Intensity"))
		}
		
		updateLabel(mode) {
			if (mode == "Info")
				this.Function.setText(this.Mode.Plugin.getMotionIntensity() . translate("%"), "Gray")
			else
				this.Function.setText(translate("Motion Intensity"))
		}
	}

	class EffectToggleAction extends MotionFeedbackPlugin.MotionModeAction {
		iEffect := false
		
		Effect[] {
			Get {
				return this.iEffect
			}
		}
		
		Active[] {
			Get {
				return this.Plugin.getEffectState(this.Effect)
			}
		}
		
		__New(function, motionMode, effect) {
			this.iEffect := effect
			
			base.__New(function, motionMode, motionMode.Plugin.getLabel(ConfigurationItem.descriptor(effect, "Toggle"), effect))
		}
		
		fireAction(function, trigger) {
			if this.Mode.PendingEffect {
				this.Mode.selectEffect(this.Effect)
				
				trayMessage(translate("Motion"), translate("Intensity Adjustment: ") . translate(this.Effect))
			}
			else {
				if (!this.Active && ((trigger = "On") || (trigger == "Push")))
					this.Plugin.unmuteEffect(this.Effect)
				else if (this.Active && ((trigger = "Off") || (trigger == "Push")))
					this.Plugin.muteEffect(this.Effect)
					
				trayMessage(translate("Motion"), translate("Effect: ") . translate(this.Effect) . ", " . translate("State: ") . (this.Active ? translate("On") : translate("Off")))
			
				this.updateLabel("Normal")
			}
		}
		
		updateLabel(mode) {
			if (mode == "Highlight")
				this.Function.setText(this.Label, "Blue")
			else if (mode == "Info")
				this.Function.setText(Format("{:.1f}", this.Mode.Plugin.getEffectIntensity(this.iEffect)), "Gray")
			else if this.Active
				this.Function.setText(this.Label, "Green")
			else
				this.Function.setText(this.Label, "Gray")
		}
	}
			
	class EffectIntensityAction extends MotionFeedbackPlugin.MotionModeAction {
		iCurrentEffect := false
		
		__New(function, motionMode) {
			base.__New(function, motionMode, "")
		}
		
		fireAction(function, trigger) {
			if (this.iCurrentEffect != false) {
				effect := this.iCurrentEffect
				
				if ((trigger = "On") || (trigger == "Increase"))
					this.Mode.Plugin.increaseEffectIntensity(effect)
				else if ((trigger = "Off") || (trigger == "Decrease"))
					this.Mode.Plugin.decreaseEffectIntensity(effect)
			
				currentIntensity := Format("{:.1f}", this.Mode.Plugin.getEffectIntensity(effect))
				
				trayMessage(translate("Motion"), translate("Effect: ") . translate(effect) . ", " . translate("Intensity: ") . currentIntensity)
				
				function.setText(currentIntensity)
				
				Sleep 500
				
				function.setText(effect)
			}
		}
		
		setEffect(effect) {
			this.iCurrentEffect := effect
			
			this.Function.setText(effect ? effect : "")
		}
	}
	
	class EffectSelectorAction extends ControllerAction {
		fireAction(function, trigger) {
			mode := this.Controller.findMode(kMotionFeedbackPlugin, kMotionMode)
			
			if (mode.PendingEffect || (mode.SelectedEffect != false))
				mode.deselectEffect()
			else
				mode.chooseEffect()
		}
	}
	
	Application[] {
		Get {
			return this.iMotionApplication
		}
	}

	MotionActive[] {
		Get {
			return this.iIsMotionActive
		}
	}

	MotionIntensity[] {
		Get {
			return this.iCurrentMotionIntensity
		}
	}
	
	__New(controller, name, configuration := false) {
		local function
		
		base.__New(controller, name, configuration, false)
		
		this.iMotionApplication := new Application(this.getArgumentValue("controlApplication", kMotionFeedbackPlugin), configuration)
		
		kSimFeedback := this.iMotionApplication.ExePath
	
		if (!kSimFeedback || !FileExist(kSimFeedback)) {
			logMessage(kLogCritical, translate("Plugin Motion Feedback deactivated, because the configured application path (") . kSimFeedback . translate(") cannot be found - please check the configuration"))
			
			if !isDebug()
				return
		}
		
		kSimFeedbackConnector := this.getArgumentValue("connector", false)
		
		if !FileExist(kSimFeedbackConnector) {
			logMessage(kLogCritical, translate("Configured application path for SimFeedback connector (") . kSimFeedbackConnector . translate(") not found - please check the configuration"))
			
			kSimFeedbackConnector := false
		}
		
		motionArguments := string2Values(A_Space, this.getArgumentValue("motion", ""))
		motionEffectsArguments := string2Values(",", this.getArgumentValue("motionEffects", ""))
		motionEffectIntensityArguments := string2Values(A_Space, this.getArgumentValue("motionEffectIntensity", ""))
		
		initialIntensity := motionArguments[4]
				
		this.kInitialMotionIntensity := initialIntensity
		this.iCurrentMotionIntensity := initialIntensity
		
		effectFunctions := []
		
		for index, effect in motionEffectsArguments {
			effect := string2Values(A_Space, effect)
			
			this.kEffects.Push(StrReplace(effect[1], "_", A_Space))
			this.kInitialEffectStates.Push(effect[2] = "On" ? true : false)
			this.kInitialEffectIntensities.Push(effect[3] + 0)
			
			effectFunctions.Push(effect[4])
		}
			
		this.iCurrentMotionIntensity := this.kInitialMotionIntensity
		this.iCurrentEffectStates := this.kInitialEffectStates.Clone()
		this.iCurrentEffectIntensities := this.kInitialEffectIntensities.Clone()
		
		descriptor := motionArguments[2]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false)
			this.registerAction(new this.MotionToggleAction(function, this.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion")))
		else
			this.logFunctionNotFound(descriptor)
		
		motionMode := new this.MotionMode(this)
		
		this.iMotionMode := motionMode
		
		descriptor := motionArguments[3]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false)
			motionMode.registerAction(new this.MotionIntensityAction(function, motionMode
																   , this.getLabel(ConfigurationItem.descriptor("Motion Intensity", "Dial"), "Motion Intensity")))
		else
			this.logFunctionNotFound(descriptor)
		
		for index, effect in this.kEffects
			this.createEffectToggleAction(controller, motionMode, effectFunctions[index], effect)
		
		descriptor := motionEffectIntensityArguments[1]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false)
			motionMode.registerAction(new this.EffectSelectorAction(function, "Effect Intensity"))
		else
			this.logFunctionNotFound(descriptor)
		
		descriptor := motionEffectIntensityArguments[2]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false) {
			intensityDialAction := new this.EffectIntensityAction(function, motionMode)

			motionMode.registerAction(intensityDialAction)
			motionMode.registerIntensityDialAction(intensityDialAction)
		}
		else
			this.logFunctionNotFound(descriptor)
		
		controller.registerPlugin(this)
		
		if (this.isActive()) {
			if ((motionArguments[1] = "On") && !this.MotionActive && !this.Application.isRunning())
				this.startMotion(true)
			else if ((motionArguments[1] = "Off") && this.Application.isRunning())
				this.stopMotion(true)
		}
	}
	
	loadEffectStateFromSimFeedback(effect) {
		if kSimFeedbackConnector
			this.iCurrentEffectStates[inList(this.kEffects, effect)] := this.callSimFeedback("EffectIsEnabled", effect)
		else {
			effect := inList(this.kEffects, effect)
		
			/*
			yCoordinate := kEffectMuteToggleY[effect]
				
			MouseMove kEffectMuteToggleX, yCoordinate, 0
			MouseGetPos posX, posY, window, muteToggle
			
			ControlGet isChecked, Checked, , %muteToggle%, % this.Application.WindowTitle
			*/
			isChecked := this.kInitialEffectStates[effect]
			
			this.iCurrentEffectStates[effect] := isChecked
		}
	}
	
	loadEffectIntensityFromSimFeedback(effect) {
		if kSimFeedbackConnector
			this.iCurrentEffectIntensities[inList(this.kEffects, effect)] := Round(this.callSimFeedback("EffectIntensityGet", effect) / 10, 1)
		else {
			effect := inList(this.kEffects, effect)
		
			this.iCurrentEffectIntensities[effect] := this.kInitialEffectIntensities[effect]
		}
	}	
	
	loadMotionStateFromSimFeedback() {
		if kSimFeedbackConnector
			this.iIsMotionActive := this.callSimFeedback("IsRunning")
		else {
			isActive := false
		
			try {
				ControlGetPos, posX, posY, , , Stop, % this.Application.WindowTitle
				
				if ((posX && (posX != "")) && (posY && (posY != "")))
					isActive := true
			}
			catch exception {
			}
			
			this.iIsMotionActive := isActive
		}
	}
	
	loadMotionIntensityFromSimFeedback() {
		if kSimFeedbackConnector
			this.iCurrentMotionIntensity := this.callSimFeedback("GetOverallIntensity")
		else
			this.iCurrentMotionIntensity := this.kInitialMotionIntensity
	}
	
	loadFromSimFeedback() {
		this.loadMotionStateFromSimFeedback()
		this.loadMotionIntensityFromSimFeedback()
		
		for ignore, effect in this.kEffects {
			this.loadEffectStateFromSimFeedback(effect)
			this.loadEffectIntensityFromSimFeedback(effect)
		}
		
		this.updatePluginState()
	}
		
	createEffectToggleAction(controller, mode, functionDescriptor, effect) {
		local function := this.Controller.findFunction(functionDescriptor)
		
		if (function != false)
			mode.registerAction(new this.EffectToggleAction(function, mode, effect))
		else
			this.logFunctionNotFound(descriptor)
	}
	
	activate() {
		local action
		
		base.activate()
	
		isRunning := this.Application.isRunning()
		
		action := this.findAction(this.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion"))
		
		action.Function.setText(this.actionLabel(action), isRunning ? (action.Active ? "Green" : "Black") : "Olive")
			
		SetTimer updateMotionState, -100
	}
	
	deactivate() {
		SetTimer updateMotionState, Off
		
		base.deactivate()
	}
	
	actionLabel(action) {
		if isInstance(action, MotionFeedbackPlugin.EffectToggleAction)
			return action.Label
		else
			return translate(base.actionLabel(action))
	}
	
	callSimFeedback(arguments*) {
		if this.requireSimFeedback()
			try {
				for index, argument in arguments
					if InStr(argument, A_Space)
						arguments[index] := """" . argument . """"
				
				arguments := values2String(A_Space, arguments*)
				
				RunWait "%kSimFeedbackConnector%" %arguments%, , Hide
				
				result := ErrorLevel
				
				logMessage(kLogInfo, "Invoking SimFeedback connector with arguments: " . arguments . " => " . result)
			
				return result
			}
			catch exception {
				logMessage(kLogCritical, "Error while connecting to SimFeedback (" . kSimFeedbackConnector . "): " . exception.Message . " - please check the configuration")
			
				showMessage(substituteVariables(translate("Cannot connect to SimFeedback (%kSimFeedbackConnector%) - please check the configuration..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
					
				return 0
			}
	}
	
	getMotionIntensity() {
		return this.iCurrentMotionIntensity
	}
	
	getEffectState(effect) {
		return this.iCurrentEffectStates[inList(this.kEffects, effect)]
	}
	
	getEffectIntensity(effect) {
		return this.iCurrentEffectIntensities[inList(this.kEffects, effect)]
	}
	
	toggleEffect(effect) {
		if this.Application.isRunning() {
			if kSimFeedbackConnector {
				this.callSimFeedback("EffectToggle", effect)
				
				this.loadEffectStateFromSimFeedback(effect)
			}
			else {
				effect := inList(this.kEffects, effect)
			
				yCoordinate := kEffectMuteToggleY[effect]
				
				ControlClick X%kEffectMuteToggleX% Y%yCoordinate%, % this.Application.WindowTitle
				Sleep 100

				this.iCurrentEffectStates[effect] := !this.iCurrentEffectStates[effect]
			}
		}
	}

	setEffectIntensity(effect, targetIntensity) {
		if (this.Application.isRunning() && (targetIntensity >= kEffectIntensityMin) && (targetIntensity <= kEffectIntensityMax)) {
			if kSimFeedbackConnector {
				this.callSimFeedback("EffectIntensitySet", effect, Round(targetIntensity * 10))
				
				this.loadEffectIntensityFromSimFeedback(effect)
			}
			else {
				effect := inList(this.kEffects, effect)
				currentIntensity := this.iCurrentEffectIntensities[effect]
			
				if (targetIntensity != currentIntensity) {
					sliderY := kEffectsSliderY[effect]
					
					MouseClickDrag Left, kEffectsSliderMinX + Round(kEffectsSliderWidth * (currentIntensity / kEffectIntensityRange))
									   , sliderY
									   , kEffectsSliderMinX + Round(kEffectsSliderWidth * (targetIntensity / kEffectIntensityRange))
									   , sliderY
					Sleep 100
					
					this.iCurrentEffectIntensities[effect] := targetIntensity
				}
			}
		}
	}
	
	setMotionIntensity(targetIntensity) {
		if this.Application.isRunning() {
			if kSimFeedbackConnector {
				this.callSimFeedback("SetOverallIntensity", targetIntensity)
				
				this.loadMotionIntensityFromSimFeedback()
			}
			else
				if (targetIntensity != this.iCurrentMotionIntensity) {
					MouseClickDrag Left, kMotionSliderMinX + Round(kMotionSliderWidth * (this.iCurrentMotionIntensity / kMotionIntensityRange))
									   , kMotionSliderY
									   , kMotionSliderMinX + Round(kMotionSliderWidth * (targetIntensity / kMotionIntensityRange))
									   , kMotionSliderY
					Sleep 100
				
					this.iCurrentMotionIntensity := targetIntensity
				}
		}
	}
	
	requireSimFeedback(startup := true) {
		static needsInitialize := true
		
		isRunning := this.Application.isRunning()
		
		if (!isRunning && startup) {
			startSimFeedback(kSimFeedbackConnector == false)
			
			isRunning := true
		}
		else if !kSimFeedbackConnector {
			windowTitle := this.Application.WindowTitle
			
			WinWait %windowTitle%, , 20
			WinActivate %windowTitle%
			WinMaximize %windowTitle%
		}
		
		if (isRunning && needsInitialize) {
			needsInitialize := false
			
			this.loadFromSimFeedback()
		}
		
		if !isRunning
			Loop 20 {
				Sleep 500
			} until this.Application.isRunning()
		
		return this.Application.isRunning()
	}
	
	increaseMotionIntensity() {
		if ((this.iCurrentMotionIntensity + kMotionIntensityIncrement) < kMotionIntensityMax)
			if kSimFeedbackConnector
				this.setMotionIntensity(this.iCurrentMotionIntensity + kMotionIntensityIncrement)
			else {
				wasHidden := this.showMotionWindow()
			
				this.setMotionIntensity(this.iCurrentMotionIntensity + kMotionIntensityIncrement)
				
				if wasHidden
					this.hideMotionWindow()
			}
	}
	
	decreaseMotionIntensity() {
		if ((this.iCurrentMotionIntensity - kMotionIntensityIncrement) > kMotionIntensityMin)
			if kSimFeedbackConnector
				this.setMotionIntensity(this.iCurrentMotionIntensity - kMotionIntensityIncrement)
			else {
				wasHidden := this.showMotionWindow()
					
				this.setMotionIntensity(this.iCurrentMotionIntensity - kMotionIntensityIncrement)
				
				if wasHidden
					this.hideMotionWindow()
			}
	}
	
	unmuteEffect(effect) {
		if kSimFeedbackConnector
			this.toggleEffect(effect)
		else {
			wasHidden := this.showMotionWindow()
		
			if !this.getEffectState(effect) {
				this.toggleEffect(effect)
				Sleep 100
			}
			
			if wasHidden
				this.hideMotionWindow()
		}
	}
	
	muteEffect(effect) {
		if kSimFeedbackConnector
			this.toggleEffect(effect)
		else {
			wasHidden := this.showMotionWindow()
			
			if this.getEffectState(effect) {
				this.toggleEffect(effect)
				Sleep 100
			}
			
			if wasHidden
				this.hideMotionWindow()
		}
	}
	
	increaseEffectIntensity(effect) {
		if kSimFeedbackConnector
			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] + kEffectIntensityIncrement)
		else {
			wasHidden := this.showMotionWindow()
		
			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] + kEffectIntensityIncrement)
			Sleep 100
			
			if wasHidden
				this.hideMotionWindow()
		}
	}
	
	decreaseEffectIntensity(effect) {
		if kSimFeedbackConnector
			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] - kEffectIntensityIncrement)
		else {
			wasHidden := this.showMotionWindow()
		
			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] - kEffectIntensityIncrement)
			Sleep 100
			
			if wasHidden
				this.hideMotionWindow()
		}
	}

	resetEffectStates() {
		for index, effect in this.kEffects {
			if (this.iCurrentEffectStates[index] != this.kInitialEffectStates[index]) {
				this.toggleEffect(effect)
				Sleep 50
			}
		}
	}

	resetEffectIntensities() {
		for index, effect in this.kEffects {
			initialIntensity := this.kInitialEffectIntensities[index]
			
			if (this.iCurrentEffectIntensities[index] != initialIntensity) {
				this.setEffectIntensity(effect, initialIntensity, false)
				Sleep 50
			}
		}
	}
	
	resetMotionIntensity() {
		this.setMotionIntensity(this.kInitialMotionIntensity, false)
	}
	
	showMotionWindow() {
		window := this.Application.WindowTitle
		
		wasHidden := (WinActive(window) == 0)
		
		if this.requireSimFeedback() {
			window := this.Application.WindowTitle
		
			if !WinActive(window)
				WinActivate %window%
			
			Sleep 100
		}
		else
			Exit
		
		return wasHidden
	}
	
	hideMotionWindow() {
		if this.Application.isRunning()
			WinMinimize % this.Application.WindowTitle
	}
	
	resetToInitialState() {
		this.resetMotionIntensity()
		this.resetEffectStates()
		this.resetEffectIntensities()
	}
	
	startMotion(force := false) {
		if (force || !this.MotionActive) {
			if kSimFeedbackConnector {
				this.callSimFeedback("StartMotion")
				
				Sleep 5000
				
				this.loadMotionStateFromSimFeedback()
			}
			else {
				wasHidden := this.showMotionWindow()

				if !this.MotionActive {
					ControlClick Start, % this.Application.WindowTitle
					Sleep 100
			
					this.iIsMotionActive := true
				}
			
				if wasHidden
					this.hideMotionWindow()
			}
		
			this.updatePluginState()
		}
	}
	
	stopMotion(force := false) {
		if (force || this.MotionActive) {
			if kSimFeedbackConnector {
				if this.MotionActive {
					this.resetToInitialState()
					
					this.callSimFeedback("StopMotion")
				
					Sleep 5000
					
					this.loadMotionStateFromSimFeedback()
				}
			}
			else {
				wasHidden := this.showMotionWindow()

				if this.MotionActive {
					this.resetToInitialState()
			
					ControlClick Stop, % this.Application.WindowTitle
					Sleep 100
			
					this.iIsMotionActive := false
				}
					
				if wasHidden
					this.hideMotionWindow()
			}
		
			this.updatePluginState()
		}
	}
	
	updatePluginState() {
		mode := this.findMode(kMotionMode)
	
		if (inList(this.Controller.ActiveModes, mode))
			if this.Application.isRunning()
				mode.updateActionStates()
			else {
				this.Controller.rotateMode(1, mode.ButtonBoxes)
				
				if inList(this.Controller.ActiveModes, mode)
					mode.deactivate()
			}
	
		this.deactivate()
		this.activate()
	}
	
	updateMotionState() {
		static isRunning := "__Undefined__"
		
		if (isRunning == kUndefined)
			isRunning := this.Application.isRunning()
		
		protectionOn()
			
		try {
			if (isRunning != this.Application.isRunning()) {
				isRunning := !isRunning
				
				if isRunning
					this.requireSimFeedback()
				else
					this.updatePluginState()
			}
			else if (isRunning && kSimFeedbackConnector)
				this.loadFromSimFeedback()
		}
		finally {
			protectionOff()
		}

		SetTimer updateMotionState, % isRunning ? 10000 : 5000
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateMotionState() {
	static plugin := false
	
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin)
		
	plugin.updateMotionState()
}

updateEffectLabels() {
	static mode := false
	
	if !mode
		mode := SimulatorController.Instance.findMode(kMotionFeedbackPlugin, kMotionMode)
		
	protectionOn()
	
	try {
		mode.updateEffectLabels()
	}
	finally {
		protectionOff()
	}
}

startSimFeedback(stayOpen := false) {
	simFeedback := new Application("Motion Feedback", SimulatorController.Instance.Configuration)
	
	if simFeedback.isRunning()
		pid := simFeedback.CurrentPID
	else
		pid := simFeedback.startup(false)
	
	if pid {
		windowTitle := simFeedback.WindowTitle
		
		WinWait %windowTitle%, , 20
		
		if !kSimFeedbackConnector
			WinMaximize %windowTitle%
		else
			WinActivate %windowTitle%
		
		if !stayOpen
			WinMinimize %windowTitle%
	}
	
	return pid
}

initializeMotionFeedbackPlugin() {
	controller := SimulatorController.Instance

	new MotionFeedbackPlugin(controller, kMotionFeedbackPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startMotion() {
	local plugin := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin)
	local action
	
	protectionOn()
	
	try {
		action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion"))
	
		action.fireAction(action.Function, "On")
	}
	finally {
		protectionOff()
	}
}

stopMotion() {
	local plugin := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin)
	local action
	
	protectionOn()
	
	try {
		action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion"))
	
		action.fireAction(action.Function, "Off")
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeMotionFeedbackPlugin()
