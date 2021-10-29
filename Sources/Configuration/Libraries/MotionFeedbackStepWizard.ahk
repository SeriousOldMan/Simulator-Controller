;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Motion Feedback Step Wizard   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ButtonBoxStepWizard.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; MotionFeedbackStepWizard                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global motionIntensityField
global effectSelectorField
global effectIntensityField

class MotionFeedbackStepWizard extends ActionsStepWizard {
	iMotionEffectsList := false
	
	iMotionIntensityDial := false
	iEffectSelectorField := false
	iEffectIntensityDial := false
	
	iDisabledWidgets := []
	
	iCachedActions := {}
	
	Pages[] {
		Get {
			wizard := this.SetupWizard

			if (wizard.isModuleSelected("Button Box") && wizard.isModuleSelected("Motion Feedback"))
				return 1
			else
				return 0
		}
	}
	
	saveToConfiguration(configuration) {
		local function
		local action
		
		base.saveToConfiguration(configuration)
		
		wizard := this.SetupWizard
	
		if wizard.isModuleSelected("Motion Feedback") {
			connector := wizard.softwarePath("StreamDeck Extension")
			
			arguments := ((connector && (connector != "")) ? ("connector: " . connector) : "")
			
			parameters := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Parameters", ""))
			
			function := wizard.getModuleActionFunction("Motion Feedback", false, "Motion")
			actionArguments := wizard.getModuleActionArgument("Motion Feedback", false, "Motion")
			motionIntensity := wizard.getModuleValue("Motion Feedback", "Motion Intensity")
			
			if (actionArguments && (actionArguments != ""))
				actionArguments := string2Values("|", actionArguments)
			else
				actionArguments := Array("On", 50)

			if !IsObject(function)
				function := ((function != "") ? Array(function) : [])
			
			if (function.Length() > 0) {
				if (arguments != "")
					arguments .= "; "
			
				if (motionIntensity != "")
					motionIntensity .= A_Space
				
				arguments .= ("motion: " . actionArguments[1] . A_Space . values2String(A_Space, function*) . A_Space . motionIntensity . actionArguments[2])
			}
			
			effectSelector := wizard.getModuleValue("Motion Feedback", "Effect Selector")
			effectIntensity := wizard.getModuleValue("Motion Feedback", "Effect Intensity")
			
			if ((effectSelector != "") && (effectIntensity != "")) {
				if (arguments != "")
					arguments .= "; "
				
				arguments .= ("motionEffectIntensity: " . effectSelector . A_Space . effectIntensity)
			}

			for ignore, mode in this.Definition {
				actions := ""
			
				for ignore, action in this.getActions(mode) {
					function := wizard.getModuleActionFunction("Motion Feedback", mode, action)
					actionArguments := wizard.getModuleActionArgument("Motion Feedback", mode, action)
					
					if (actionArguments && (actionArguments != ""))
						actionArguments := string2Values("|", actionArguments)
					else
						actionArguments := Array("On", 1.0)

					if !IsObject(function)
						function := ((function != "") ? Array(function) : [])
					
					if (function.Length() > 0) {
						if (actions != "")
							actions .= ", "
						
						actions .= ("""" . action . """ " . actionArguments[1] . A_Space . actionArguments[2] . A_Space . values2String(A_Space, function*))
					}
				}
				
				if (actions != "") {
					if (arguments != "")
						arguments .= "; "
					
					arguments .= ("motionEffects: " . actions)
				}
			}
					
			new Plugin("Motion Feedback", false, true, "", arguments).saveToConfiguration(configuration)
		}
		else
			new Plugin("Motion Feedback", false, false, "", "").saveToConfiguration(configuration)
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static motionFeedbackInfoText
		
		window := this.Window
		
		Gui %window%:Default
		
		motionFeedbackIconHandle := false
		motionFeedbackLabelHandle := false
		motionFeedbackListViewHandle := false
		motionFeedbackInfoTextHandle := false
		
		motionEffectsLabelHandle := false
		motionEffectsButtonHandle := false
		motionEffectsListHandle := false
		
		labelsEditorButtonHandle := false
		
		motionIntensityLabelHandle := false
		motionIntensityFieldHandle := false
		effectSelectorLabelHandle := false
		effectSelectorFieldHandle := false
		effectIntensityLabelHandle := false
		effectIntensityFieldHandle := false
		
		labelWidth := width - 30
		labelX := x + 35
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDmotionFeedbackIconHandle Hidden, %kResourcesDirectory%Setup\Images\Motion 1.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDmotionFeedbackLabelHandle Hidden, % translate("Motion Feedback Configuration")
		
		Gui %window%:Font, s8 Norm, Arial
			
		columnLabel1Handle := false
		columnLine1Handle := false
		columnLabel2Handle := false
		columnLine2Handle := false
		
		listX := x + 300
		listWidth := width - 300
			
		colWidth := width - listWidth - x
		
		Gui %window%:Font, Bold, Arial
			
		Gui %window%:Add, Text, x%x% yp+30 w%colWidth% h23 +0x200 HWNDcolumnLabel1Handle Hidden Section, % translate("Setup ")
		Gui %window%:Add, Text, yp+20 x%x% w%colWidth% 0x10 HWNDcolumnLine1Handle Hidden
		
		secondX := x + 155
		buttonX := secondX - 26
		secondWidth := colWidth - 155
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+10 w105 h23 +0x200 HWNDmotionEffectsLabelHandle Hidden, % translate("Motion Effects")
		
		Gui %window%:Add, Button, x%buttonX% yp w23 h23 HWNDmotionEffectsButtonHandle gchangeMotionEffects Hidden
		setButtonIcon(motionEffectsButtonHandle, kResourcesDirectory . "Setup\Images\Pencil.ico", 1, "L2 T2 R2 B2 H16 W16")
		Gui %window%:Add, ListBox, x%secondX% yp w%secondWidth% h60 Disabled ReadOnly HWNDmotionEffectsListHandle Hidden
		
		Gui %window%:Add, Text, x%x% yp+70 w105 h23 +0x200 HWNDmotionIntensityLabelHandle Hidden, % translate("Motion Intensity")
		
		Gui %window%:Font, s8 Bold, Arial
		
		Gui %window%:Add, Edit, x%secondX% yp w%secondWidth% h23 +0x200 HWNDmotionIntensityFieldHandle vmotionIntensityField Hidden
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+24 w105 h23 +0x200 HWNDeffectSelectorLabelHandle Hidden, % translate("Effect Selector")
		
		Gui %window%:Font, s8 Bold, Arial
		
		Gui %window%:Add, Edit, x%secondX% yp w%secondWidth% h23 +0x200 HWNDeffectSelectorFieldHandle veffectSelectorField Hidden
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+24 w105 h23 +0x200 HWNDeffectIntensityLabelHandle Hidden, % translate("Effect Intensity")
		
		Gui %window%:Font, s8 Bold, Arial
		
		Gui %window%:Add, Edit, x%secondX% yp w%secondWidth% h23 +0x200 HWNDeffectIntensityFieldHandle veffectIntensityField Hidden
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Button, x%x% yp+30 w%colWidth% h23 HWNDlabelsEditorButtonHandle gopenLabelsEditor Hidden, % translate("Edit Labels...")
		
		Gui %window%:Font, s8 Bold, Arial
			
		Gui %window%:Add, Text, x%listX% ys w%listWidth% h23 +0x200 HWNDcolumnLabel2Handle Hidden Section, % translate("Actions")
		Gui %window%:Add, Text, yp+20 x%listX% w%listWidth% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, s8 Norm, Arial
		
		Gui Add, ListView, x%listX% yp+10 w%listWidth% h270 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDmotionFeedbackListViewHandle gupdateMotionFeedbackActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "State", "Intensity", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Sleep 200
		
		Gui %window%:Add, ActiveX, x%x% yp+275 w%width% h135 HWNDmotionFeedbackInfoTextHandle VmotionFeedbackInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		motionFeedbackInfoText.Navigate("about:blank")
		motionFeedbackInfoText.Document.Write(html)
		
		this.setActionsListView(motionFeedbackListViewHandle)
		
		this.iMotionEffectsList := motionEffectsListHandle
		this.iMotionIntensityDial := motionIntensityFieldHandle
		this.iEffectSelectorField := effectSelectorFieldHandle
		this.iEffectIntensityDial := effectIntensityFieldHandle
		
		; this.iDisabledWidgets := [motionEffectsListHandle, motionIntensityFieldHandle, effectSelectorFieldHandle, effectIntensityFieldHandle]
		this.iDisabledWidgets := [motionIntensityFieldHandle, effectSelectorFieldHandle, effectIntensityFieldHandle]
		
		this.registerWidgets(1, motionFeedbackIconHandle, motionFeedbackLabelHandle, motionFeedbackListViewHandle, motionFeedbackInfoTextHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle, motionEffectsLabelHandle, motionEffectsButtonHandle, motionEffectsListHandle, labelsEditorButtonHandle, motionIntensityLabelHandle, motionIntensityFieldHandle, effectSelectorLabelHandle, effectSelectorFieldHandle, effectIntensityLabelHandle, effectIntensityFieldHandle)
	}
	
	reset() {
		base.reset()
	
		motionIntensityField := false
		effectSelectorField := false
		effectIntensityField := false
		
		this.iMotionEffectsList := false
		this.iMotionIntensityDial := false
		this.iEffectSelectorField := false
		this.iEffectIntensityDial := false
		this.iDisabledWidgets := []
		this.iCachedActions := {}
	}
	
	showPage(page) {
		base.showPage(page)
		
		wizard := this.SetupWizard
		
		for ignore, widget in this.iDisabledWidgets
			GuiControl Disable, %widget%
		
		motionIntensityField := wizard.getModuleValue("Motion Feedback", "Motion Intensity")
		effectSelectorField := wizard.getModuleValue("Motion Feedback", "Effect Selector")
		effectIntensityField := wizard.getModuleValue("Motion Feedback", "Effect Intensity")
		
		GuiControl Text, motionIntensityField, %motionIntensityField%
		GuiControl Text, effectSelectorField, %effectSelectorField%
		GuiControl Text, effectIntensityField, %effectIntensityField%
		
		row := false
		column := false
		
		if (motionIntensityField != "")
			for ignore, preview in this.ButtonBoxPreviews
				if preview.findFunction(motionIntensityField, row, column) {
					preview.setLabel(row, column, translate("Motion Intensity"))
					
					break
				}
		
		if (effectSelectorField != "")
			for ignore, preview in this.ButtonBoxPreviews
				if preview.findFunction(effectSelectorField, row, column) {
					preview.setLabel(row, column, translate("Effect Selector"))
					
					break
				}
		
		if (effectIntensityField != "")
			for ignore, preview in this.ButtonBoxPreviews
				if preview.findFunction(effectIntensityField, row, column) {
					preview.setLabel(row, column, translate("Effect Intensity"))
					
					break
				}
	}
	
	hidePage(page) {
		local function
		local action
		
		wizard := this.SetupWizard
		
		if (!wizard.isSoftwareInstalled("SimFeedback") || !wizard.isSoftwareInstalled("StreamDeck Extension")) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Modular Simulator Controller System")
			MsgBox 262436, %title%, % translate("SimFeedback cannot be found or the StreamDeck Extension was not installed. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		function := this.getActionFunction(false, "Motion")
		
		if !function {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Modular Simulator Controller System")
			MsgBox 262436, %title%, % translate("The function for the ""Motion"" action has not been set. You will not be able to activate or deactivate motion. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		/*
		valid := true
		
		for ignore, mode in this.getModes() {
			for ignore, action in this.getActions(mode) {
				function := this.getActionFunction(mode, action)
			
				if (function && (function != "")) {
					arguments := this.getActionArgument(mode, action)
					
					if ((!arguments || (arguments = "")) || (string2Values("|", arguments)[2] = ""))
						valid := false
				}
				
				if !valid
					break
			}
			
			if !valid
				break
		}
		
		if !valid {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Modular Simulator Controller System")
			MsgBox 262436, %title%, % translate("Not all configured effects have defined initial intensities. Do you really want to proceed? (Default is 50%)")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		*/
		
		GuiControlGet effectSelectorField
		GuiControlGet effectIntensityField
		
		if (((effectSelectorField != "") && (effectIntensityField = "")) || ((effectSelectorField = "") && (effectIntensityField != ""))) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Modular Simulator Controller System")
			MsgBox 262436, %title%, % translate("You must specify both ""Effect Selector"" and ""Effect Intensity"" functions, if you want to control effect intensities. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		if base.hidePage(page) {
			wizard := this.SetupWizard
			
			GuiControlGet motionIntensityField
			GuiControlGet effectSelectorField
			GuiControlGet effectIntensityField
			
			if (motionIntensityField != "")
				wizard.setModuleValue("Motion Feedback", "Motion Intensity", motionIntensityField, false)
			else
				wizard.clearModuleValue("Motion Feedback", "Motion Intensity", false)
			
			if (effectSelectorField != "")
				wizard.setModuleValue("Motion Feedback", "Effect Selector", effectSelectorField, false)
			else
				wizard.clearModuleValue("Motion Feedback", "Effect Selector", false)
			
			if (effectIntensityField != "")
				wizard.setModuleValue("Motion Feedback", "Effect Intensity", effectIntensityField, false)
			else
				wizard.clearModuleValue("Motion Feedback", "Effect Intensity", false)
			
			return true
		}
		else
			return false
	}
	
	getModule() {
		return "Motion Feedback"
	}
	
	getModes() {
		return Array(false, this.Definition*)
	}
	
	getActions(mode := false) {
		if this.iCachedActions.HasKey(mode)
			return this.iCachedActions[mode]
		else {
			wizard := this.SetupWizard
			
			actions := wizard.moduleAvailableActions("Motion Feedback", mode)
			
			if (actions.Length() == 0) {
				if mode
					actions := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback." . mode . ".Effects", ""))
				else
					actions := ["Motion"]
				
				wizard.setModuleAvailableActions("Motion Feedback", mode, actions)
			}
			
			this.iCachedActions[mode] := actions
			
			return actions
		}
	}
	
	setAction(row, mode, action, actionDescriptor, label, argument := false) {
		local function
		
		wizard := this.SetupWizard
		
		base.setAction(row, mode, action, actionDescriptor, label, argument)
			
		if inList(this.getActions(false), action) {
			functions := this.getActionFunction(this.getActionMode(row), action)
			
			if functions
				for ignore, function in functions
					if (function && (function != ""))
						wizard.addModuleStaticFunction("Motion Feedback", function, label)
		}
	}
	
	clearActionFunction(mode, action, function) {
		base.clearActionFunction(mode, action, function)
		
		if inList(this.getActions(false), action)
			this.SetupWizard.removeModuleStaticFunction("Motion Feedback", function)
	}
	
	loadButtonBoxLabels() {
		local function
		local action
		
		base.loadButtonBoxLabels()
		
		wizard := this.SetupWizard
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet motionIntensityField
		GuiControlGet effectSelectorField
		GuiControlGet effectIntensityField
		
		row := false
		column := false
		
		if (motionIntensityField != "")
			for ignore, preview in this.ButtonBoxPreviews {
				mode := preview.Mode
			
				if (((mode == true) || (mode = "Motion")) && preview.findFunction(motionIntensityField, row, column)) {
					preview.setLabel(row, column, translate("Motion Intensity"))
					
					break
				}
			}
		
		if (effectSelectorField != "")
			for ignore, preview in this.ButtonBoxPreviews {
				mode := preview.Mode
			
				if (((mode == true) || (mode = "Motion")) && preview.findFunction(effectSelectorField, row, column)) {
					preview.setLabel(row, column, translate("Effect Selector"))
					
					break
				}
			}
		
		if (effectIntensityField != "")
			for ignore, preview in this.ButtonBoxPreviews {
				mode := preview.Mode
			
				if (((mode == true) || (mode = "Motion")) && preview.findFunction(effectIntensityField, row, column)) {
					preview.setLabel(row, column, translate("Effect Intensity"))
				
					break
				}
			}
	}
	
	loadActions(load := false) {
		local function
		local action
		local count
		
		window := this.Window
		wizard := this.SetupWizard
		
		Gui %window%:Default
		
		if load {
			this.iCachedActions := {}
			
			this.clearActionFunctions()
			this.clearActionArguments()
			
			list := this.iMotionEffectsList
			
			GuiControl, , %list%, % "|" . values2String("|", this.getActions("Motion")*)
		}
		
		this.clearActions()
		
		Gui ListView, % this.ActionsListView
		
		pluginLabels := readConfiguration(getFileName("Controller Action Labels." . getLanguage(), kUserTranslationsDirectory, kTranslationsDirectory))
		
		LV_Delete()
		
		lastMode := -1
		count := 1
		
		for ignore, mode in this.getModes() {
			for ignore, action in this.getActions(mode) {
				if wizard.moduleActionAvailable("Motion Feedback", mode, action) {
					first := (mode != lastMode)
					lastMode := mode
				
					if load {
						function := wizard.getModuleActionFunction("Motion Feedback", mode, action)
						
						if (function && (function != ""))
							this.setActionFunction(mode, action, (IsObject(function) ? function : Array(function)))
						
						arguments := wizard.getModuleActionArgument("Motion Feedback", mode, action)
						
						if (arguments && (arguments != ""))
							this.setActionArgument(count, arguments)
					}
					
					label := getConfigurationValue(pluginLabels, "Motion Feedback", action . ".Toggle", kUndefined)
					
					if (label == kUndefined)
						label := getConfigurationValue(pluginLabels, "Motion Feedback", action . ".Activate", "")
		
					this.setAction(count, mode, action, [false, "Activate"], label)
						
					isBinary := false
					
					function := this.getActionFunction(mode, action)
					
					if function
						function := (mode ? function[1] : (translate("On/Off: ") . function[1]))
					else
						function := ""
					
					arguments := this.getActionArgument(count)
					
					if (arguments && (arguments != "")) {
						state := string2Values("|", arguments)
						intensity := ((state[2] != "") ? state[2] : (mode ? "1.0" : "50"))
						state := state[1]
					}
					else {
						state := true
						intensity := (mode ? "1.0" : "50")
					}
					
					LV_Add("", (first ? translate(mode ? mode : "Independent") : ""), action, label, translate(state ? "On" : "Off"), intensity, function)
					
					count += 1
				}
			}
		}
		
		this.loadButtonBoxLabels()
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
		LV_ModifyCol(5, "AutoHdr")
		LV_ModifyCol(6, "AutoHdr")
	}
	
	saveActions() {
		local function
		local action
		
		wizard := this.SetupWizard
		
		for ignore, mode in this.getModes() {
			modeFunctions := {}
		
			for ignore, action in this.getActions(mode)
				if wizard.moduleActionAvailable("Motion Feedback", mode, action) {
					function := this.getActionFunction(mode, action)
					
					if (function && (function != ""))
						modeFunctions[action] := function
				}
			
			wizard.setModuleActionFunctions("Motion Feedback", mode, modeFunctions)
			
			modeArguments := {}
		
			for ignore, action in this.getActions(mode)
				if wizard.moduleActionAvailable("Motion Feedback", mode, action) {
					arguments := this.getActionArgument(mode, action)
					
					if (arguments && (arguments != ""))
						modeArguments[action] := arguments
				}
			
			wizard.setModuleActionArguments("Motion Feedback", mode, modeArguments)
		}
	}
	
	changeEffects(mode) {
		actions := this.getActions(mode)
		
		title := translate("Modular Simulator Controller System")
		prompt := translate("Please input effect names (seperated by comma):")
		locale := ((getLanguage() = "en") ? "" : "Locale")
		
		actions := values2String(", ", actions*)
		
		InputBox actions, %title%, %prompt%, , 450, 150, , , %locale%, , %actions%
		
		if !ErrorLevel {
			this.saveActions()
			
			this.SetupWizard.setModuleAvailableActions("Motion Feedback", mode, string2Values(",", actions))
			
			this.loadActions(true)
		}
	}
	
	setMotionIntensityDial(preview, function, control, row, column) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet motionIntensityField
		
		if (motionIntensityField != "") {
			cRow := false
			cColumn := false
			
			for ignore, bbPreview in this.ButtonBoxPreviews
				if bbPreview.findFunction(motionIntensityField, cRow, cColumn) {
					this.clearMotionIntensityDial(preview, motionIntensityField
												, ConfigurationItem.descriptor("Ignore", ConfigurationItem.splitDescriptor(motionIntensityField)[2])
												, cRow, cColumn, false)
					
					break
				}
		}
		
		motionIntensityField := function
		
		GuiControl, , motionIntensityField, %motionIntensityField%
		
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadButtonBoxLabels()
	}
			
	clearMotionIntensityDial(preview, function, control, row, column, sound := true) {
		window := this.Window
		
		Gui %window%:Default
		
		motionIntensityField := ""
		
		GuiControl, , motionIntensityField, %motionIntensityField%
		
		if sound
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadButtonBoxLabels()
	}
	
	setEffectSelector(preview, function, control, row, column) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet effectSelectorField
		
		if (effectSelectorField != "") {
			cRow := false
			cColumn := false
			
			for ignore, bbPreview in this.ButtonBoxPreviews
				if bbPreview.findFunction(effectSelectorField, cRow, cColumn) {
					this.clearEffectSelector(preview, effectSelectorField
										   , ConfigurationItem.descriptor("Ignore", ConfigurationItem.splitDescriptor(effectSelectorField)[2])
										   , cRow, cColumn, false)
					
					break
				}
		}
		
		effectSelectorField := function
		
		GuiControl, , effectSelectorField, %effectSelectorField%
		
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadButtonBoxLabels()
	}
			
	clearEffectSelector(preview, function, control, row, column, sound := true) {
		window := this.Window
		
		Gui %window%:Default
		
		effectSelectorField := ""
		
		GuiControl, , effectSelectorField, %effectSelectorField%
		
		if sound
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadButtonBoxLabels()
	}
	
	setEffectIntensityDial(preview, function, control, row, column) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet effectIntensityField
		
		if (effectIntensityField != "") {
			cRow := false
			cColumn := false
			
			for ignore, bbPreview in this.ButtonBoxPreviews
				if bbPreview.findFunction(effectIntensityField, cRow, cColumn) {
					this.clearEffectIntensityDial(preview, effectIntensityField
												, ConfigurationItem.descriptor("Ignore", ConfigurationItem.splitDescriptor(effectIntensityField)[2])
												, cRow, cColumn, false)
					
					break
				}
		}
		
		effectIntensityField := function
		
		GuiControl, , effectIntensityField, %effectIntensityField%
		
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadButtonBoxLabels()
	}
			
	clearEffectIntensityDial(preview, function, control, row, column, sound := true) {
		window := this.Window
		
		Gui %window%:Default
		
		effectIntensityField := ""
		
		GuiControl, , effectIntensityField, %effectIntensityField%
		
		if sound
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadButtonBoxLabels()
	}
	
	toggleState(row) {
		local action := this.getAction(row)
		
		mode := this.getActionMode(row)
		
		arguments := this.getActionArgument(row)
		
		if (arguments && (arguments != "")) {
			arguments := string2Values("|", arguments)
			arguments[1] := !arguments[1]
		}
		else
			arguments := Array(false, "")
					
		this.setActionArgument(row, values2String("|", arguments*))
		
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		this.loadActions()
	}
	
	inputIntensity(row) {
		local action := this.getAction(row)
		
		mode := this.getActionMode(row)
		
		title := translate("Modular Simulator Controller System")
		prompt := translate(mode ? "Please input initial effect intensity (use dot as decimal point):" : "Please input initial motion intensity:")
		locale := ((getLanguage() = "en") ? "" : "Locale")
		
		arguments := this.getActionArgument(row)
		
		if (arguments && (arguments != "")) {
			arguments := string2Values("|", arguments)
			
			value := arguments[2]
		}
		else {
			arguments := Array(true, "")
		
			value := (mode ? "1.0" : "50")
		}
		
		InputBox value, %title%, %prompt%, , 300, 150, , , %locale%, , %value%
		
		if !ErrorLevel {
			message := (mode ? "You must enter a valid number between 0.0 and 2.0..." : "You must enter a valid integer between 0 and 100...")
			
			valid := false
			
			if value is number
				if (!mode && (value >= 0) && (value <= 100)) {
					if value is integer
					{
						valid := true
						
						value := Round(value)
					}
				}
				else if (mode && (value >= 0.0) && (value <= 2.0)) {
					valid := true
						
					value := Round(value, 1)
				}
			
			if !valid {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate(message)
				OnMessage(0x44, "")
				
				return
			}
			
			arguments[2] := value
			
			this.setActionArgument(row, values2String("|", arguments*))
			
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav
			
			this.loadActions()
		}
	}
	
	createActionsMenu(title, row) {
		contextMenu := base.createActionsMenu(title, row)
		
		Menu %contextMenu%, Add
		
		menuItem := translate("Toggle Initial State")
		handler := ObjBindMethod(this, "toggleState", row)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		menuItem := translate("Set Initial Intensity...")
		handler := ObjBindMethod(this, "inputIntensity", row)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		return contextMenu
	}
	
	createControlMenu(title, preview, element, function, row, column) {
		contextMenu := base.createControlMenu(title, preview, element, function, row, column)
		
		functionType := ConfigurationItem.splitDescriptor(function)[1]
		
		GuiControlGet motionIntensityField
		GuiControlGet effectSelectorField
		GuiControlGet effectIntensityField
		
		Menu %contextMenu%, Add
		
		menuItem := translate("Set Motion Intensity Dial")
		handler := ObjBindMethod(this, "setMotionIntensityDial", preview, function, element[2], row, column)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		if ((functionType != k2WayToggleType) && (functionType != kDialType))
			Menu %contextMenu%, Disable, %menuItem%
		
		menuItem := translate("Clear Motion Intensity Dial")
		handler := ObjBindMethod(this, "clearMotionIntensityDial", preview, function, element[2], row, column)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		if ((motionIntensityField = "") || (motionIntensityField != function))
			Menu %contextMenu%, Disable, %menuItem%
		
		Menu %contextMenu%, Add
		
		menuItem := translate("Set Effect Selector")
		handler := ObjBindMethod(this, "setEffectSelector", preview, function, element[2], row, column)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		menuItem := translate("Clear Effect Selector")
		handler := ObjBindMethod(this, "clearEffectSelector", preview, function, element[2], row, column)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		if ((effectSelectorField = "") || (effectSelectorField != function))
			Menu %contextMenu%, Disable, %menuItem%
		
		Menu %contextMenu%, Add
		
		menuItem := translate("Set Effect Intensity Dial")
		handler := ObjBindMethod(this, "setEffectIntensityDial", preview, function, element[2], row, column)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		if ((functionType != k2WayToggleType) && (functionType != kDialType))
			Menu %contextMenu%, Disable, %menuItem%
		
		menuItem := translate("Clear Effect Intensity Dial")
		handler := ObjBindMethod(this, "clearEffectIntensityDial", preview, function, element[2], row, column)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		if ((effectIntensityField = "") || (effectIntensityField != function))
			Menu %contextMenu%, Disable, %menuItem%
		
		return contextMenu
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

changeMotionEffects() {
	SetupWizard.Instance.StepWizards["Motion Feedback"].changeEffects("Motion")
}

updateMotionFeedbackActionFunction() {
	updateActionFunction(SetupWizard.Instance.StepWizards["Motion Feedback"])
}

initializeMotionFeedbackStepWizard() {
	SetupWizard.Instance.registerStepWizard(new MotionFeedbackStepWizard(SetupWizard.Instance, "Motion Feedback", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeMotionFeedbackStepWizard()