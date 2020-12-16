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
		iEffectsAreHighlighted := false
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

		blinkEffectLabels() {
			if ((this.iSelectedEffect == false) && !this.iEffectsAreHighlighted)
				return
			
			if (this.Controller.ActiveMode == this)
				for index, effect in this.Plugin.kEffects
					this.Plugin.EffectToggleAction.findAction(effect).updateLabel(!this.iEffectsAreHighlighted)
			
			this.iEffectsAreHighlighted := !this.iEffectsAreHighlighted
		}

		unblinkEffectLabels() {
			if this.iEffectsAreHighlighted
				this.blinkEffectLabels()
		}
		
		selectEffect(effect) {
			this.iSelectedEffect := effect
				
			SetTimer blinkEffectLabels, Off
			
			this.unblinkEffectLabels()
			
			this.iIntensityDialAction.setEffect(effect)
		}
		
		chooseEffect() {
			this.iSelectedEffect := kUndefined
			
			SetTimer blinkEffectLabels, 1000
			
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
			
			for index, effect in this.Plugin.kEffects
				this.Plugin.EffectToggleAction.findAction(effect).updateLabel(false)
		}
		
		deactivate() {
			this.deselectEffect()
			
			base.deactivate()
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
			if (this.Active && ((trigger = "Off") || (trigger == "Push"))) {
				this.Plugin.findMode(kMotionMode).deselectEffect()
				
				this.Plugin.stopMotion()
			}
			else if (!this.Active && ((trigger = "On") || (trigger == "Push")))
				this.Plugin.startMotion()
				
			if this.Active {				
				trayMessage(this.Label, "State: On")
			
				function.setText(this.Label, "Green")
			}
			else {
				trayMessage(this.Label, "State: Off")
			
				function.setText(this.Label, "Gray")
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
		__New(function, motionMode) {
			base.__New(function, motionMode, "Motion Intensity")
		}
		
		fireAction(function, trigger) {
			if ((trigger = "On") || (trigger == "Increase"))
				this.Mode.Plugin.increaseMotionIntensity()
			else if ((trigger = "Off") || (trigger == "Decrease"))
				this.Mode.Plugin.decreaseMotionIntensity()
			
			currentIntensity := this.Mode.Plugin.getMotionIntensity()
			
			trayMessage("Motion", "Intensity: " . currentIntensity)
				
			function.setText(currentIntensity . "%")
			
			Sleep 500
			
			function.setText("Motion Intensity")
		}
	}

	class EffectToggleAction extends MotionFeedbackPlugin.MotionModeAction {
		static sLabelsDatabase := false
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
			this.iMotionMode := motionMode
			
			if !this.sLabelsDatabase
				this.sLabelsDatabase := readConfiguration(kConfigDirectory . "Controller Plugin Labels.ini")
			
			label := getConfigurationValue(this.sLabelsDatabase, "Motion Feedback", effect, false)
			
			if (!label || (label == ""))
				label := effect
				
			base.__New(function, motionMode, label)
		}
		
		fireAction(function, trigger) {
			if this.Mode.PendingEffect {
				this.Mode.selectEffect(this.Effect)
				
				trayMessage("Motion", "Intensity Adjustment: " . this.Effect)
			}
			else {
				if (!this.Active && ((trigger = "On") || (trigger == "Push")))
					this.Plugin.unmuteEffect(this.Effect)
				else if (this.Active && ((trigger = "Off") || (trigger == "Push")))
					this.Plugin.muteEffect(this.Effect)
					
				trayMessage("Motion", "Effect: " . this.Effect . ", State: " . (this.Active ? "On" : "Off"))
			
				this.updateLabel(false)
			}
		}
		
		updateLabel(highlighted) {
			if highlighted
				this.Function.setText(this.Label, "Blue")
			else if this.Active
				this.Function.setText(this.Label, "Green")
			else
				this.Function.setText(this.Label, "Gray")
		}
		
		findAction(effect) {
			label := getConfigurationValue(this.sLabelsDatabase, "Motion Feedback", effect, false)
			
			if (!label || (label == ""))
				label := effect
				
			return this.Mode.findAction(label)
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
				
				trayMessage("Motion", "Effect: " . effect . ", Intensity: " . currentIntensity)
				
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
			mode := this.Controller.findMode(kMotionMode)
			
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
		
		this.iMotionApplication := new Application(kMotionFeedbackPlugin, configuration)
		
		base.__New(controller, name, configuration)
		
		kSimFeedbackConnector := this.getArgumentValue("connector", false)
		
		if !FileExist(kSimFeedbackConnector) {
			logMessage(kLogCritical, "Configured application path for SimFeedback connector (" . kSimFeedbackConnector . ") not found - please check the setup...")
			
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
			this.registerAction(new this.MotionToggleAction(function, "Motion"))
		else
			logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
		
		motionMode := new this.MotionMode(this)
		
		this.iMotionMode := motionMode
		
		descriptor := motionArguments[3]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false)
			motionMode.registerAction(new this.MotionIntensityAction(function, motionMode))
		else
			logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
		
		for index, effect in this.kEffects
			this.createEffectToggleAction(controller, motionMode, effectFunctions[index], effect)
		
		descriptor := motionEffectIntensityArguments[1]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false)
			motionMode.registerAction(new this.EffectSelectorAction(function, "Effect Intensity"))
		else
			logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
		
		descriptor := motionEffectIntensityArguments[2]
		function := this.Controller.findFunction(descriptor)
		
		if (function != false) {
			intensityDialAction := new this.EffectIntensityAction(function, motionMode)

			motionMode.registerAction(intensityDialAction)
			motionMode.registerIntensityDialAction(intensityDialAction)
		}
		else
			logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
		
		controller.registerPlugin(this)
		
		if ((motionArguments[1] = "On") && !this.MotionActive && !this.Application.isRunning())
			this.startMotion(true)
		else if ((motionArguments[1] = "Off") && this.Application.isRunning())
			this.stopMotion(true)
		
		SetTimer updateMotionState, 50
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
			
			ControlGet isChecked, Checked, , %muteToggle%, % this.iMotionApplication.WindowTitle
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
				ControlGetPos, posX, posY, , , Stop, % this.iMotionApplication.WindowTitle
				
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
		wasHidden := this.showMotionWindow()
		
		this.loadMotionStateFromSimFeedback()
		this.loadMotionIntensityFromSimFeedback()
		
		for ignore, effect in this.kEffects {
			this.loadEffectStateFromSimFeedback(effect)
			this.loadEffectIntensityFromSimFeedback(effect)
		}
			
		if wasHidden
			this.hideMotionWindow()
			
		mode := this.findMode(kMotionMode)
	
		if (this.Controller.ActiveMode == mode) {
			mode.deactivate()
			mode.activate()
		}
	
		this.deactivate()
		this.activate()
	}
		
	createEffectToggleAction(controller, mode, functionDescriptor, effect) {
		local function := this.Controller.findFunction(functionDescriptor)
		
		if (function != false)
			mode.registerAction(new this.EffectToggleAction(function, mode, effect))
		else
			logMessage(kLogWarn, "Controller function " . functionDescriptor . " not found in plugin " . this.Plugin . " - please check the setup")
	}
	
	activate() {
		base.activate()
	
		isRunning := this.Application.isRunning()
		
		action := this.findAction("Motion")
		
		action.Function.setText(action.Label, isRunning ? (action.Active ? "Green" : "Black") : "Olive")
	}
	
	callSimFeedback(arguments*) {
		this.requireSimFeedback()
		
		try {
			for index, argument in arguments
				if InStr(argument, A_Space)
					arguments[index] := """" . argument . """"
			
			arguments := values2String(A_Space, arguments*)
			
			RunWait "%kSimFeedbackConnector%" %arguments%, , Hide
			
			result := ErrorLevel
			
			logMessage(kLogInfo, "Invoking command SimFeedback connector with arguments: " . arguments . " => " . result)
		
			return result
		}
		catch exception {
			logMessage(kLogCritical, "Error while connecting to SimFeedback (" . kSimFeedbackConnector . "): " . exception.Message . " - please check the setup")
			
			SplashTextOn 800, 60, Modular Simulator Controller System, Cannot connect to SimFeedback (%kSimFeedbackConnector%) `n`nPlease run the setup tool...
					
			Sleep 5000
						
			SplashTextOff
				
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
		if this.iMotionApplication.isRunning() {
			if kSimFeedbackConnector {
				this.callSimFeedback("EffectToggle", effect)
				
				this.loadEffectStateFromSimFeedback(effect)
			}
			else {
				effect := inList(this.kEffects, effect)
			
				yCoordinate := kEffectMuteToggleY[effect]
				
				ControlClick X%kEffectMuteToggleX% Y%yCoordinate%, % this.iMotionApplication.WindowTitle
				Sleep 100

				this.iCurrentEffectStates[effect] := !this.iCurrentEffectStates[effect]
			}
		}
	}

	setEffectIntensity(effect, targetIntensity) {
		if (this.iMotionApplication.isRunning() && (targetIntensity >= kEffectIntensityMin) && (targetIntensity <= kEffectIntensityMax)) {
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
		if this.iMotionApplication.isRunning() {
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
	
	requireSimFeedback() {
		static needsInitialize := true
		
		if !this.iMotionApplication.isRunning()
			startSimFeedback()
		else if !kSimFeedbackConnector {
			windowTitle := this.iMotionApplication.WindowTitle
			
			WinWait %windowTitle%, , 20
			WinActivate %windowTitle%
			WinMaximize %windowTitle%
		}
		
		if needsInitialize {
			needsInitialize := false
			
			this.loadFromSimFeedback()
		}
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
		window := this.iMotionApplication.WindowTitle
		
		wasHidden := (WinActive(window) == 0)
		
		this.requireSimFeedback()
	
		if this.iMotionApplication.isRunning() {
			window := this.iMotionApplication.WindowTitle
		
			IfWinNotActive %window%, , WinActivate, %window%
			WinWaitActive %window%, , 2
			Sleep 100
		}
		
		return wasHidden
	}
	
	hideMotionWindow() {
		if this.iMotionApplication.isRunning()
			WinMinimize % this.iMotionApplication.WindowTitle
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
					ControlClick Start, % this.iMotionApplication.WindowTitle
					Sleep 100
			
					this.iIsMotionActive := true
				}
			
				if wasHidden
					this.hideMotionWindow()
			}
			
			mode := this.findMode(kMotionMode)
		
			if (this.Controller.ActiveMode == mode) {
				mode.deactivate()
				mode.activate()
			}
		
			this.deactivate()
			this.activate()
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
			
					ControlClick Stop, % this.iMotionApplication.WindowTitle
					Sleep 100
			
					this.iIsMotionActive := false
				}
					
				if wasHidden
					this.hideMotionWindow()
			}
			
			mode := this.findMode(kMotionMode)
		
			if (this.Controller.ActiveMode == mode) {
				mode.deactivate()
				mode.activate()
			}
		
			this.deactivate()
			this.activate()
		}
	}
	
	updateMotionState() {
		static isRunning := "__Undefined__"
		
		if (isRunning == kUndefined)
			isRunning := this.Application.isRunning()
		
		if (isRunning != this.Application.isRunning()) {
			protectionOn()
			
			try {
				isRunning := !isRunning
				
				if isRunning
					this.requireSimFeedback()
				else {
					if (this.Controller.ActiveMode == this.findMode(kMotionMode))
						this.Controller.rotateMode()
						
					this.deactivate()
					this.activate()
				}
				
				setTimer updateMotionState, % isRunning ? 5000 : 1000
			}
			finally {
				protectionOff()
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateMotionState() {
	SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin).updateMotionState()
}

blinkEffectLabels() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findMode(kMotionMode).blinkEffectLabels()
	}
	finally {
		protectionOff()
	}
}

startSimFeedback() {
	simFeedback := new Application("Motion Feedback", SimulatorController.Instance.Configuration)
	
	windowTitle := simFeedback.WindowTitle
		
	simFeedback.startup(false)
	
	WinWait %windowTitle%, , 20
	
	if !kSimFeedbackConnector
		WinMaximize %windowTitle%
	else
		WinActivate %windowTitle%
	
	WinMinimize %windowTitle%
}

initializeMotionFeedbackPlugin() {
	controller := SimulatorController.Instance
	
	kSimFeedback := getConfigurationValue(controller.Configuration, kMotionFeedbackPlugin, "Exe Path", false)
	
	if (!kSimFeedback || !FileExist(kSimFeedback)) {
		logMessage(kLogCritical, "Plugin Motion Feedback deactivated, because the configured application path (" . kSimFeedback . ") cannot be found - please check the setup...")
		
		if !isDebug()
			return
	}

	new MotionFeedbackPlugin(controller, kMotionFeedbackPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startMotion() {
	protectionOn()
	
	try {
		action := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin).findAction("Motion")
	
		action.fireAction(action.Function, "On")
	}
	finally {
		protectionOff()
	}
}

stopMotion() {
	protectionOn()
	
	try {
		action := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin).findAction("Motion")
	
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
