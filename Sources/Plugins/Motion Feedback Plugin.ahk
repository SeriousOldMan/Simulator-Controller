﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Motion Feedback Plugin          ;;;
;;;                                         (Powered by SimFeedback)        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    Creative Commons - BY-NC-SA                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kMotionIntensityIncrement := 5
global kMotionIntensityMin := 0
global kMotionIntensityMax := 50
global kMotionIntensityRange := 100

global kMotionSliderY := 231
global kMotionSliderMinX := 377
global kMotionSliderMaxX := 450
global kMotionSliderWidth := kMotionSliderMaxX - kMotionSliderMinX

global kEffectIntensityIncrement := 0.1
global kEffectIntensityMin := 0.2
global kEffectIntensityMax := 1.8
global kEffectIntensityRange := 2.0

global kEffectMuteToggleX := 276
global kEffectMuteToggleY := [330, 425, 520, 615, 710, 805, 900]

global kEffectsSliderMinX := 730
global kEffectsSliderMaxX := 950
global kEffectsSliderWidth := kEffectsSliderMaxX - kEffectsSliderMinX
global kEffectsSliderY := [305, 400, 495, 590, 685, 780, 875]

global kSimFeedbackConnector := false


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kMotionFeedbackPlugin := "Motion Feedback"
global kMotionMode := "Motion"


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

	iUpdateMotionStateTask := false

	class MotionMode extends ControllerMode {
		iSelectedEffect := false
		iIntensityActions := []

		iUpdateLabelsTask := false

		Mode {
			Get {
				return kMotionMode
			}
		}

		SelectedEffect {
			Get {
				if ((this.iSelectedEffect != false) && (this.iSelectedEffect != kUndefined))
					return this.iSelectedEffect
				else
					return false
			}
		}

		PendingEffect {
			Get {
				return (this.iSelectedEffect == kUndefined)
			}
		}

		registerIntensityActions(actions*) {
			this.iIntensityActions := actions
		}

		updateEffectLabels() {
			local action, state, index, effect

			static isInfo := false

			if (inList(this.Controller.ActiveModes, this)) {
				state := (isInfo ? ((this.iSelectedEffect == kUndefined) ? "Highlight" : "Info") : "Normal")

				for index, effect in this.Plugin.kEffects
					if inList(this.Controller.ActiveModes, this) {
						action := this.findAction(this.Plugin.getLabel(ConfigurationItem.descriptor(effect, "Toggle"), effect))

						if action
							action.updateLabel(state)
					}

				if inList(this.Controller.ActiveModes, this) {
					action := this.findAction(this.Plugin.getLabel(ConfigurationItem.descriptor("MotionIntensity", "Dial"), "Motion Intensity"))

					if action
						action.updateLabel(isInfo ? "Info" : "Normal")
				}

				isInfo := !isInfo
			}
		}

		selectEffect(effect) {
			local ignore, action

			this.iSelectedEffect := effect

			for ignore, action in this.iIntensityActions
				action.setEffect(effect)
		}

		chooseEffect() {
			local ignore, action

			this.iSelectedEffect := kUndefined

			for ignore, action in this.iIntensityActions
				action.setEffect(false)
		}

		deselectEffect() {
			this.selectEffect(false)
		}

		isActive() {
			return (super.isActive() && this.Plugin.Application.isRunning())
		}

		activate() {
			super.activate()

			this.deselectEffect()

			this.updateActionStates()

			if !this.iUpdateLabelsTask {
				this.iUpdateLabelsTask := PeriodicTask(ObjBindMethod(this, "updateEffectLabels"), 1500, kLowPriority)

				this.iUpdateLabelsTask.start()
			}
		}

		deactivate() {
			super.deactivate()

			if this.iUpdateLabelsTask {
				this.iUpdateLabelsTask.stop()

				this.iUpdateLabelsTask := false
			}

			this.deselectEffect()
		}

		updateActionStates() {
			local ignore, effect

			for ignore, effect in this.Plugin.kEffects
				this.findAction(this.Plugin.getLabel(ConfigurationItem.descriptor(effect, "Toggle"), effect)).updateLabel("Normal")
		}
	}

	class MotionToggleAction extends ControllerAction {
		Plugin {
			Get {
				return this.Controller.findPlugin(kMotionFeedbackPlugin)
			}
		}

		Active {
			Get {
				return this.Plugin.MotionActive
			}
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (this.Active && ((trigger = "On") || (trigger = "Off") || (trigger == "Push")))
				plugin.stopMotion(plugin.actionLabel(this))
			else if (!this.Active && ((trigger = "On") || (trigger == "Push")))
				plugin.startMotion(plugin.actionLabel(this))
		}
	}

	class MotionModeAction extends ControllerAction {
		iMotionMode := false

		Mode {
			Get {
				return this.iMotionMode
			}
		}

		Plugin {
			Get {
				return this.Mode.Plugin
			}
		}

		__New(function, motionMode, label, icon) {
			this.iMotionMode := motionMode

			super.__New(function, label, icon)
		}
	}

	class MotionIntensityAction extends MotionFeedbackPlugin.MotionModeAction {
		__New(function, motionMode, label, icon) {
			super.__New(function, motionMode, label, icon)
		}

		fireAction(function, trigger) {
			local currentIntensity

			if ((trigger = "On") || (trigger = kIncrease))
				this.Mode.Plugin.increaseMotionIntensity()
			else if ((trigger = "Off") || (trigger = kDecrease))
				this.Mode.Plugin.decreaseMotionIntensity()

			currentIntensity := this.Mode.Plugin.getMotionIntensity()

			trayMessage(translate("Motion"), translate("Intensity: ") . currentIntensity)

			function.setLabel(currentIntensity . translate("%"), "Black", true)

			Sleep(500)

			function.setLabel(translate("Motion Intensity"))
		}

		updateLabel(mode) {
			if (mode == "Info")
				this.Function.setLabel(this.Mode.Plugin.getMotionIntensity() . translate("%"), "Gray", true)
			else
				this.Function.setLabel(translate("Motion Intensity"))
		}
	}

	class EffectToggleAction extends MotionFeedbackPlugin.MotionModeAction {
		iEffect := false

		Effect {
			Get {
				return this.iEffect
			}
		}

		Active {
			Get {
				return this.Plugin.getEffectState(this.Effect)
			}
		}

		__New(function, motionMode, effect) {
			local descriptor := ConfigurationItem.descriptor(effect, "Toggle")

			this.iEffect := effect

			super.__New(function, motionMode, motionMode.Plugin.getLabel(descriptor, effect), motionMode.Plugin.getIcon(descriptor))
		}

		fireAction(function, trigger) {
			if this.Mode.PendingEffect {
				this.Mode.selectEffect(this.Effect)

				trayMessage(translate("Motion"), translate("Intensity Adjustment: ") . translate(this.Effect))
			}
			else {
				if (!this.Active && ((trigger = "On") || (trigger == "Push")))
					this.Plugin.unmuteEffect(this.Effect)
				else if (this.Active && ((trigger = "On") || (trigger = "Off") || (trigger == "Push")))
					this.Plugin.muteEffect(this.Effect)

				trayMessage(translate("Motion"), translate("Effect: ") . translate(this.Effect) . ", " . translate("State: ") . (this.Active ? translate("On") : translate("Off")))

				this.updateLabel("Normal")
			}
		}

		updateLabel(mode) {
			if (mode == "Highlight")
				this.Function.setLabel(this.Label, "Blue")
			else if (mode == "Info")
				this.Function.setLabel(Format("{:.1f}", this.Mode.Plugin.getEffectIntensity(this.iEffect)), "Gray", true)
			else if this.Active
				this.Function.setLabel(this.Label, "Green")
			else
				this.Function.setLabel(this.Label, "Gray")
		}
	}

	class EffectIntensityAction extends MotionFeedbackPlugin.MotionModeAction {
		iCurrentEffect := false
		iDirection := false

		__New(function, motionMode, label, icon, direction := false) {
			this.iDirection := direction

			super.__New(function, motionMode, label, icon)
		}

		fireAction(function, trigger) {
			local effect, currentIntensity

			if (this.iCurrentEffect != false) {
				effect := this.iCurrentEffect

				if this.iDirection {
					if (this.iDirection = kIncrease)
						this.Mode.Plugin.increaseEffectIntensity(effect)
					else
						this.Mode.Plugin.decreaseEffectIntensity(effect)
				}
				else {
					if ((trigger = "On") || (trigger = kIncrease))
						this.Mode.Plugin.increaseEffectIntensity(effect)
					else if ((trigger = "Off") || (trigger = kDecrease))
						this.Mode.Plugin.decreaseEffectIntensity(effect)
				}

				currentIntensity := Format("{:.1f}", this.Mode.Plugin.getEffectIntensity(effect))

				trayMessage(translate("Motion"), translate("Effect: ") . translate(effect) . ", " . translate("Intensity: ") . currentIntensity)

				function.setLabel(currentIntensity, "Black", true)

				Sleep(500)

				function.setLabel(effect)
			}
		}

		setEffect(effect) {
			this.iCurrentEffect := effect

			this.Function.setLabel(effect ? effect : "")
		}
	}

	class EffectSelectorAction extends ControllerAction {
		fireAction(function, trigger) {
			local mode := this.Controller.findMode(kMotionFeedbackPlugin, kMotionMode)

			if (mode.PendingEffect || (mode.SelectedEffect != false))
				mode.deselectEffect()
			else
				mode.chooseEffect()
		}
	}

	Application {
		Get {
			return this.iMotionApplication
		}
	}

	MotionActive {
		Get {
			return this.iIsMotionActive
		}
	}

	MotionIntensity {
		Get {
			return this.iCurrentMotionIntensity
		}
	}

	__New(controller, name, configuration := false, register := true) {
		global kSimFeedbackConnector

		local function, motionArguments, motionEffectsArguments, motionEffectIntensityArguments, initialIntensity
		local effectFunctions, ignore, index, effect, descriptor, motionMode, increaseAction, decreaseAction, intensityDialAction
		local motionEnabled

		super.__New(controller, name, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iMotionApplication := Application(this.getArgumentValue("controlApplication", kMotionFeedbackPlugin), configuration)

			kSimFeedback := this.iMotionApplication.ExePath

			if (!kSimFeedback || !FileExist(kSimFeedback)) {
				logMessage(kLogCritical, translate("Plugin Motion Feedback deactivated, because the configured application path (") . kSimFeedback . translate(") cannot be found - please check the configuration"))

				if !isDebug()
					return false
			}

			kSimFeedbackConnector := this.getArgumentValue("connector", false)

			if !FileExist(kSimFeedbackConnector) {
				logMessage(kLogCritical, translate("Configured application path for SimFeedback connector (") . kSimFeedbackConnector . translate(") not found - please check the configuration"))

				kSimFeedbackConnector := false
			}

			motionArguments := string2Values(A_Space, substituteString(this.getArgumentValue("motion", ""), "  ", A_Space))
			motionEffectsArguments := string2Values(",", this.getArgumentValue("motionEffects", ""))
			motionEffectIntensityArguments := string2Values(A_Space, substituteString(this.getArgumentValue("motionEffectIntensity", ""), "  ", A_Space))

			if (motionArguments.Length == 4) {
				initialIntensity := motionArguments[4]

				this.kInitialMotionIntensity := initialIntensity
				this.iCurrentMotionIntensity := initialIntensity
			}

			effectFunctions := []

			for ignore, effect in motionEffectsArguments {
				effect := this.parseValues(A_Space, effect)

				this.kEffects.Push(StrReplace(effect[1], "_", A_Space))
				this.kInitialEffectStates.Push(effect[2] = "On" ? true : false)
				this.kInitialEffectIntensities.Push(effect[3] + 0)

				effectFunctions.Push(effect[4])
			}

			this.iCurrentMotionIntensity := this.kInitialMotionIntensity
			this.iCurrentEffectStates := this.kInitialEffectStates.Clone()
			this.iCurrentEffectIntensities := this.kInitialEffectIntensities.Clone()

			if (motionArguments.Length > 1) {
				descriptor := motionArguments[2]
				function := this.Controller.findFunction(descriptor)

				if (function != false) {
					descriptor := ConfigurationItem.descriptor("Motion", "Toggle")

					this.registerAction(MotionFeedbackPlugin.MotionToggleAction(function, this.getLabel(descriptor, "Motion"), this.getIcon(descriptor)))
				}
				else
					this.logFunctionNotFound(descriptor)
			}

			motionMode := MotionFeedbackPlugin.MotionMode(this)

			this.iMotionMode := motionMode

			if (motionArguments.Length > 2) {
				descriptor := motionArguments[3]
				function := this.Controller.findFunction(descriptor)

				if (function != false) {
					descriptor := ConfigurationItem.descriptor("MotionIntensity", "Dial")

					motionMode.registerAction(MotionFeedbackPlugin.MotionIntensityAction(function, motionMode, this.getLabel(descriptor, "Motion Intensity"), this.getIcon(descriptor)))
				}
				else
					this.logFunctionNotFound(descriptor)
			}

			for index, effect in this.kEffects
				this.createEffectToggleAction(controller, motionMode, effectFunctions[index], effect)

			if (motionEffectIntensityArguments.Length > 0) {
				descriptor := motionEffectIntensityArguments[1]
				function := this.Controller.findFunction(descriptor)

				if (function != false)
					motionMode.registerAction(MotionFeedbackPlugin.EffectSelectorAction(function, "Effect Intensity", this.getIcon(ConfigurationItem.descriptor("EffectIntensity", "Activate"))))
				else
					this.logFunctionNotFound(descriptor)

				if (motionEffectIntensityArguments.Length > 2) {
					descriptor := motionEffectIntensityArguments[2]
					function := this.Controller.findFunction(descriptor)

					decreaseAction := false
					increaseAction := false

					if (function != false) {
						descriptor := ConfigurationItem.descriptor("EffectIntensity", "Decrease")

						decreaseAction := MotionFeedbackPlugin.EffectIntensityAction(function, motionMode, this.getLabel(descriptor), this.getIcon(descriptor), kDecrease)

						motionMode.registerAction(decreaseAction)
					}
					else
						this.logFunctionNotFound(descriptor)

					descriptor := motionEffectIntensityArguments[3]
					function := this.Controller.findFunction(descriptor)

					if (function != false) {
						descriptor := ConfigurationItem.descriptor("EffectIntensity", "Increase")

						increaseAction := MotionFeedbackPlugin.EffectIntensityAction(function, motionMode, this.getLabel(descriptor), this.getIcon(descriptor), kIncrease)

						motionMode.registerAction(increaseAction)
					}
					else
						this.logFunctionNotFound(descriptor)

					if (increaseAction && decreaseAction)
						motionMode.registerIntensityActions(decreaseAction, increaseAction)
				}
				else {
					descriptor := motionEffectIntensityArguments[2]
					function := this.Controller.findFunction(descriptor)

					if (function != false) {
						descriptor := ConfigurationItem.descriptor("EffectIntensity", "Dial")

						intensityDialAction := MotionFeedbackPlugin.EffectIntensityAction(function, motionMode, this.getLabel(descriptor), this.getIcon(descriptor))

						motionMode.registerAction(intensityDialAction)
						motionMode.registerIntensityActions(intensityDialAction)
					}
					else
						this.logFunctionNotFound(descriptor)
				}
			}

			if register
				controller.registerPlugin(this)

			if (motionArguments.Length > 0) {
				if ((motionArguments[1] == true) || (motionArguments[1] = kTrue))
					motionArguments[1] := "On"

				if ((motionArguments[1] == false) || (motionArguments[1] = kFalse))
					motionArguments[1] := "Off"

				motionEnabled := (motionArguments[1] = "On")
			}
			else
				motionEnabled := false

			if (this.StartupSettings && (getMultiMapValue(this.StartupSettings, "Functions", "Motion", kUndefined) != kUndefined))
				motionEnabled := getMultiMapValue(this.StartupSettings, "Functions", "Motion")

			if motionEnabled
				this.startMotion(false, true)
			else if this.Application.isRunning()
				this.stopMotion(false, true)
			else
				this.stopMotion(false, true, false)

			if register
				controller.registerPlugin(this)
		}
	}

	writePluginState(configuration) {
		if this.Active {
			setMultiMapValue(configuration, this.Plugin, "State", "Active")

			setMultiMapValue(configuration, this.Plugin, "Information", translate("Motion: ") . translate(this.MotionActive ? "On" : "Off"))
		}
		else
			super.writePluginState(configuration)
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

			this.iCurrentEffectStates[effect] := this.kInitialEffectStates[effect]
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
		local isActive, posX, posY

		if kSimFeedbackConnector
			this.iIsMotionActive := this.callSimFeedback("IsRunning")
		else {
			isActive := false

			try {
				ControlGetPos(&posX, &posY, , , "Stop", this.Application.WindowTitle)

				if ((posX && (posX != "")) && (posY && (posY != "")))
					isActive := true
			}
			catch Any as exception {
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
		local ignore, effect

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
			mode.registerAction(MotionFeedbackPlugin.EffectToggleAction(function, mode, effect))
		else
			this.logFunctionNotFound(functionDescriptor)
	}

	activate() {
		local action, isRunning

		super.activate()

		isRunning := this.Application.isRunning()

		this.updateActions()

		if !this.iUpdateMotionStateTask {
			this.iUpdateMotionStateTask := PeriodicTask(ObjBindMethod(this, "updateMotionState"), 30000, kLowPriority)

			this.iUpdateMotionStateTask.start()
		}
	}

	deactivate() {
		if this.iUpdateMotionStateTask {
			this.iUpdateMotionStateTask.stop()

			this.iUpdateMotionStateTask := false
		}

		super.deactivate()
	}
	
	updateFunctions() {
		this.updateActions()
	}

	updateActions() {
		local action := this.findAction(this.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion"))
		local isRunning := this.Application.isRunning()

		if action {
			action.Function.setLabel(this.actionLabel(action), isRunning ? (action.Active ? "Green" : "Black") : "Silver")
			action.Function.setIcon(this.actionIcon(action), isRunning ? (action.Active ? "Activated" : "Deactivated") : "Disabled")
		}
	}

	actionLabel(action) {
		local label := super.actionLabel(action)

		return (isInstance(action, MotionFeedbackPlugin.EffectToggleAction) ? label : translate(label))
	}

	callSimFeedback(arguments*) {
		local index, argument, result, message

		if this.requireSimFeedback()
			try {
				for index, argument in arguments
					if InStr(argument, A_Space)
						arguments[index] := "`"" . argument . "`""

				arguments := values2String(A_Space, arguments*)

				result := RunWait("`"" . kSimFeedbackConnector . "`" " . arguments, , "Hide")

				logMessage(kLogInfo, translate("Invoking SimFeedback connector with arguments: ") . arguments . " => " . result)

				return result
			}
			catch Any as exception {
				logError(exception, true)

				message := (isObject(exception) ? exception.Message : exception)

				logMessage(kLogCritical, "Error while connecting to SimFeedback (" . kSimFeedbackConnector . "): " . message . " - please check the configuration")

				if !kSilentMode
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
		local yCoordinate

		if this.Application.isRunning() {
			if kSimFeedbackConnector {
				this.callSimFeedback("EffectToggle", effect)

				this.loadEffectStateFromSimFeedback(effect)
			}
			else {
				effect := inList(this.kEffects, effect)

				yCoordinate := kEffectMuteToggleY[effect]

				ControlClick("X" . kEffectMuteToggleX . " Y" . yCoordinate, this.Application.WindowTitle)

				Sleep(100)

				this.iCurrentEffectStates[effect] := !this.iCurrentEffectStates[effect]
			}
		}
	}

	setEffectIntensity(effect, targetIntensity) {
		local currentIntensity, sliderY

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

					MouseClickDrag("Left", kEffectsSliderMinX + Round(kEffectsSliderWidth * (currentIntensity / kEffectIntensityRange)), sliderY
										 , kEffectsSliderMinX + Round(kEffectsSliderWidth * (targetIntensity / kEffectIntensityRange)), sliderY)

					Sleep(100)

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
					MouseClickDrag("Left", kMotionSliderMinX + Round(kMotionSliderWidth * (this.iCurrentMotionIntensity / kMotionIntensityRange)), kMotionSliderY
										 , kMotionSliderMinX + Round(kMotionSliderWidth * (targetIntensity / kMotionIntensityRange)), kMotionSliderY)

					Sleep(100)

					this.iCurrentMotionIntensity := targetIntensity
				}
		}
	}

	requireSimFeedback(startup := true) {
		local isRunning := this.Application.isRunning()
		local windowTitle

		static needsInitialize := true

		if (!isRunning && startup) {
			startSimFeedback(kSimFeedbackConnector == false)

			isRunning := true
		}
		else if !kSimFeedbackConnector {
			windowTitle := this.Application.WindowTitle

			WinWait(windowTitle, , 20)
			WinActivate(windowTitle)
			WinMaximize(windowTitle)
		}

		if (isRunning && needsInitialize) {
			needsInitialize := false

			this.loadFromSimFeedback()
		}

		if !isRunning
			loop 20
				Sleep(500)
			until this.Application.isRunning()

		return this.Application.isRunning()
	}

	increaseMotionIntensity() {
		local wasHidden

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
		local wasHidden

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
		local wasHidden

		if kSimFeedbackConnector
			this.toggleEffect(effect)
		else {
			wasHidden := this.showMotionWindow()

			if !this.getEffectState(effect) {
				this.toggleEffect(effect)

				Sleep(100)
			}

			if wasHidden
				this.hideMotionWindow()
		}
	}

	muteEffect(effect) {
		local wasHidden

		if kSimFeedbackConnector
			this.toggleEffect(effect)
		else {
			wasHidden := this.showMotionWindow()

			if this.getEffectState(effect) {
				this.toggleEffect(effect)

				Sleep(100)
			}

			if wasHidden
				this.hideMotionWindow()
		}
	}

	increaseEffectIntensity(effect) {
		local wasHidden

		if kSimFeedbackConnector
			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] + kEffectIntensityIncrement)
		else {
			wasHidden := this.showMotionWindow()

			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] + kEffectIntensityIncrement)

			Sleep(100)

			if wasHidden
				this.hideMotionWindow()
		}
	}

	decreaseEffectIntensity(effect) {
		local wasHidden

		if kSimFeedbackConnector
			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] - kEffectIntensityIncrement)
		else {
			wasHidden := this.showMotionWindow()

			this.setEffectIntensity(effect, this.iCurrentEffectIntensities[inList(this.kEffects, effect)] - kEffectIntensityIncrement)

			Sleep(100)

			if wasHidden
				this.hideMotionWindow()
		}
	}

	resetEffectStates() {
		local index, effect

		for index, effect in this.kEffects {
			if (this.iCurrentEffectStates[index] != this.kInitialEffectStates[index]) {
				this.toggleEffect(effect)

				Sleep(50)
			}
		}
	}

	resetEffectIntensities() {
		local index, effect, initialIntensity

		for index, effect in this.kEffects {
			initialIntensity := this.kInitialEffectIntensities[index]

			if (this.iCurrentEffectIntensities[index] != initialIntensity) {
				this.setEffectIntensity(effect, initialIntensity)

				Sleep(50)
			}
		}
	}

	resetMotionIntensity() {
		this.setMotionIntensity(this.kInitialMotionIntensity)
	}

	showMotionWindow() {
		local window := this.Application.WindowTitle
		local wasHidden := (WinActive(window) == 0)

		if this.requireSimFeedback() {
			window := this.Application.WindowTitle

			if !WinActive(window)
				WinActivate(window)

			Sleep(100)
		}
		else
			Exit()

		return wasHidden
	}

	hideMotionWindow() {
		if this.Application.isRunning()
			WinMinimize(this.Application.WindowTitle)
	}

	resetToInitialState() {
		this.resetMotionIntensity()
		this.resetEffectStates()
		this.resetEffectIntensities()
	}

	toggleMotion() {
		if this.MotionActive
			this.stopMotion()
		else
			this.startMotion()
	}

	updateTrayLabel(label, enabled) {
		static hasTrayMenu := false

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu {
			A_TrayMenu.Insert("1&")
			A_TrayMenu.Insert("1&", label, (*) => this.toggleMotion())

			hasTrayMenu := true
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
	}

	startMotion(label := false, force := false) {
		local actionLabel, action, wasHidden

		if (!this.MotionActive || force) {
			actionLabel := this.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion")
			action := this.findAction(actionLabel)

			if !label
				label := actionLabel

			if kSimFeedbackConnector {
				this.callSimFeedback("StartMotion")

				Sleep(5000)

				this.loadMotionStateFromSimFeedback()
			}
			else {
				wasHidden := this.showMotionWindow()

				if !this.MotionActive {
					ControlClick("Start", this.Application.WindowTitle)

					Sleep(100)

					this.iIsMotionActive := true
				}

				if wasHidden
					this.hideMotionWindow()
			}

			this.updatePluginState()

			trayMessage(label, translate(this.MotionActive ? "State: On" : "State: Off"))

			this.updateTrayLabel(label, this.MotionActive)

			this.updateActions()
		}
	}

	stopMotion(label := false, force := false, stop := true) {
		local actionLabel, wasHidden, motionMode

		if (this.MotionActive || force) {
			actionLabel := this.getLabel(ConfigurationItem.descriptor("Motion", "Toggle"), "Motion")

			if !label
				label := actionLabel

			if stop {
				motionMode := this.findMode(kMotionMode)

				if motionMode
					motionMode.deselectEffect()

				if kSimFeedbackConnector {
					if this.MotionActive {
						this.resetToInitialState()

						this.callSimFeedback("StopMotion")

						Sleep(5000)

						this.loadMotionStateFromSimFeedback()
					}
				}
				else {
					wasHidden := this.showMotionWindow()

					if this.MotionActive {
						this.resetToInitialState()

						ControlClick("Stop", this.Application.WindowTitle)

						Sleep(100)

						this.iIsMotionActive := false
					}

					if wasHidden
						this.hideMotionWindow()
				}

				this.updatePluginState()
			}

			trayMessage(label, translate(this.MotionActive ? "State: On" : "State: Off"))

			this.updateTrayLabel(label, this.MotionActive)

			this.updateActions()
		}
	}

	updatePluginState() {
		local mode := this.findMode(kMotionMode)

		if (inList(this.Controller.ActiveModes, mode))
			if this.Application.isRunning()
				mode.updateActionStates()
			else {
				this.Controller.rotateMode(1, mode.FunctionController)

				if inList(this.Controller.ActiveModes, mode)
					mode.deactivate()
			}

		this.deactivate()
		this.activate()
	}

	updateMotionState() {
		local first := false

		static isRunning := kUndefined

		if (isRunning == kUndefined) {
			isRunning := this.Application.isRunning()

			first := true
		}

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
			else if first
				this.updatePluginState()
		}
		finally {
			protectionOff()
		}

		Task.CurrentTask.Sleep := (isRunning ? 60000 : 30000)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startSimFeedback(stayOpen := false) {
	local simFeedback := Application("Motion Feedback", SimulatorController.Instance.Configuration)
	local pid, windowTitle

	if simFeedback.isRunning()
		pid := simFeedback.CurrentPID
	else
		pid := simFeedback.startup(false)

	if pid {
		windowTitle := simFeedback.WindowTitle

		WinWait(windowTitle, , 20)

		if !kSimFeedbackConnector
			WinMaximize(windowTitle)
		else
			WinActivate(windowTitle)

		if !stayOpen
			WinMinimize(windowTitle)
	}

	return pid
}

initializeMotionFeedbackPlugin() {
	local controller := SimulatorController.Instance

	MotionFeedbackPlugin(controller, kMotionFeedbackPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startMotion() {
	local plugin := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin)

	protectionOn()

	try {
		if (plugin && SimulatorController.Instance.isActive(plugin))
			plugin.startMotion()
	}
	finally {
		protectionOff()
	}
}

stopMotion() {
	local plugin := SimulatorController.Instance.findPlugin(kMotionFeedbackPlugin)

	protectionOn()

	try {
		if (plugin && SimulatorController.Instance.isActive(plugin))
			plugin.stopMotion()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeMotionFeedbackPlugin()
