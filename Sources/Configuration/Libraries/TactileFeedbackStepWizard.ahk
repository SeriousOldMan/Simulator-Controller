;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tactile Feedback Step Wizard    ;;;
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
;;; TactileFeedbackStepWizard                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TactileFeedbackStepWizard extends ActionsStepWizard {
	iPedalEffectsList := false
	iChassisEffectsList := false
	
	iCachedActions := {}
	
	Pages[] {
		Get {
			wizard := this.SetupWizard

			if (wizard.isModuleSelected("Button Box") && wizard.isModuleSelected("Tactile Feedback"))
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
	
		arguments := ""
		
		if wizard.isModuleSelected("Tactile Feedback") {
			parameters := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Parameters", ""))
			
			for ignore, action in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Toggles", "")) {
				function := wizard.getModuleActionFunction("Tactile Feedback", false, action)

				if !IsObject(function)
					function := ((function != "") ? Array(function) : [])
				
				if (function.Length() > 0) {
					if (arguments != "")
						arguments .= "; "
					
					arguments .= (parameters[A_Index] . " On " . values2String(A_Space, function*))
				}
			}

			for ignore, mode in this.Definition {
				actions := ""
			
				for ignore, action in this.getActions(mode) {
					function := wizard.getModuleActionFunction("Tactile Feedback", mode, action)

					if !IsObject(function)
						function := ((function != "") ? Array(function) : [])
					
					if (function.Length() > 0) {
						if (actions != "")
							actions .= ", "
						
						actions .= (action . A_Space . values2String(A_Space, function*))
					}
				}
				
				if (actions != "") {
					if (arguments != "")
						arguments .= "; "
					
					arguments .= (((mode = "Pedal Vibration") ? "pedalEffects: " : "chassisEffects: ") . actions)
				}
			}
					
			new Plugin("Tactile Feedback", false, true, "", arguments).saveToConfiguration(configuration)
		}
		else
			new Plugin("Tactile Feedback", false, false, "", "").saveToConfiguration(configuration)
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static tactileFeedbackInfoText
		
		window := this.Window
		
		Gui %window%:Default
		
		tactileFeedbackIconHandle := false
		tactileFeedbackLabelHandle := false
		tactileFeedbackListViewHandle := false
		tactileFeedbackInfoTextHandle := false
		
		pedalEffectsLabelHandle := false
		pedalEffectsButtonHandle := false
		pedalEffectsListHandle := false
		chassisEffectsLabelHandle := false
		chassisEffectsButtonHandle := false
		chassisEffectsListHandle := false
		
		labelsEditorButtonHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDtactileFeedbackIconHandle Hidden, %kResourcesDirectory%Setup\Images\Vibration 1.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDtactileFeedbackLabelHandle Hidden, % translate("Tactile Feedback Configuration")
		
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
		
		Gui %window%:Add, Text, x%x% yp+10 w105 h23 +0x200 HWNDpedalEffectsLabelHandle Hidden, % translate("Pedal Effects")
		
		Gui %window%:Add, Button, x%buttonX% yp w23 h23 HWNDpedalEffectsButtonHandle gchangePedalEffects Hidden
		setButtonIcon(pedalEffectsButtonHandle, kResourcesDirectory . "Setup\Images\Pencil.ico", 1, "L2 T2 R2 B2 H16 W16")
		Gui %window%:Add, ListBox, x%secondX% yp w%secondWidth% h60 ReadOnly Disabled HWNDpedalEffectsListHandle Hidden
		
		Gui %window%:Add, Text, x%x% yp+65 w105 h23 +0x200 HWNDchassisEffectsLabelHandle Hidden, % translate("Chassis Effects")
		
		Gui %window%:Add, Button, x%buttonX% yp w23 h23 HWNDchassisEffectsButtonHandle gchangeChassisEffects Hidden
		setButtonIcon(chassisEffectsButtonHandle, kResourcesDirectory . "Setup\Images\Pencil.ico", 1, "L2 T2 R2 B2 H16 W16")
		Gui %window%:Add, ListBox, x%secondX% yp w%secondWidth% h60 ReadOnly Disabled HWNDchassisEffectsListHandle Hidden
		
		Gui %window%:Add, Button, x%x% yp+70 w%colWidth% h23 HWNDlabelsEditorButtonHandle gopenLabelsEditor Hidden, % translate("Edit Labels...")
		
		Gui %window%:Font, s8 Bold, Arial
			
		Gui %window%:Add, Text, x%listX% ys w%listWidth% h23 +0x200 HWNDcolumnLabel2Handle Hidden Section, % translate("Actions")
		Gui %window%:Add, Text, yp+20 x%listX% w%listWidth% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, s8 Norm, Arial
		
		Gui Add, ListView, x%listX% yp+10 w%listWidth% h270 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDtactileFeedbackListViewHandle gupdateTactileFeedbackActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Gui %window%:Add, ActiveX, x%x% yp+275 w%width% h135 HWNDtactileFeedbackInfoTextHandle VtactileFeedbackInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		tactileFeedbackInfoText.Navigate("about:blank")
		tactileFeedbackInfoText.Document.Write(html)
		
		this.setActionsListView(tactileFeedbackListViewHandle)
		
		this.iPedalEffectsList := pedalEffectsListHandle
		this.iChassisEffectsList := chassisEffectsListHandle
		
		this.registerWidgets(1, tactileFeedbackIconHandle, tactileFeedbackLabelHandle, tactileFeedbackListViewHandle, tactileFeedbackInfoTextHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle, pedalEffectsLabelHandle, pedalEffectsButtonHandle, pedalEffectsListHandle, chassisEffectsLabelHandle, chassisEffectsButtonHandle, chassisEffectsListHandle, labelsEditorButtonHandle)
	}
	
	reset() {
		base.reset()
	
		this.iPedalEffectsList := {}
		this.iChassisEffectsList := {}
		this.iCachedActions := {}
	}
	
	/*
	showPage(page) {
		base.showPage(page)
		
		list := this.iPedalEffectsList
		
		GuiControl Disable, %list%
		
		list := this.iChassisEffectsList
		
		GuiControl Disable, %list%
	}
	*/
	
	hidePage(page) {
		wizard := this.SetupWizard
		
		if !wizard.isSoftwareInstalled("SimHub") {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup ")
			MsgBox 262436, %title%, % translate("SimHub cannot be found. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		return base.hidePage(page)
	}
	
	getModule() {
		return "Tactile Feedback"
	}
	
	getModes() {
		return Array(false, this.Definition*)
	}
	
	getActions(mode := false) {
		if this.iCachedActions.HasKey(mode)
			return this.iCachedActions[mode]
		else {
			wizard := this.SetupWizard
			
			actions := wizard.moduleAvailableActions("Tactile Feedback", mode)
			
			if (actions.Length() == 0) {
				if mode
					actions := concatenate(string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback." . mode . ".Effects", ""))
										 , string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback." . mode . ".Intensity", "")))
				else
					actions := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Toggles", ""))
				
				wizard.setModuleAvailableActions("Tactile Feedback", mode, actions)
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
						wizard.addControllerStaticFunction("Tactile Feedback", function, label)
		}
	}
	
	clearActionFunction(mode, action, function) {
		base.clearActionFunction(mode, action, function)
		
		if inList(this.getActions(false), action)
			this.SetupWizard.removeControllerStaticFunction("Tactile Feedback", function)
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
			
			list := this.iPedalEffectsList
			
			GuiControl, , %list%, % "|" . values2String("|", this.getActions("Pedal Vibration")*)
			
			list := this.iChassisEffectsList
			
			GuiControl, , %list%, % "|" . values2String("|", this.getActions("Chassis Vibration")*)
		}
		
		this.clearActions()
		
		Gui ListView, % this.ActionsListView
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		LV_Delete()
		
		lastMode := -1
		count := 1
		
		for ignore, mode in this.getModes() {
			for ignore, action in this.getActions(mode) {
				if wizard.moduleActionAvailable("Tactile Feedback", mode, action) {
					first := (mode != lastMode)
					lastMode := mode
				
					if load {
						function := wizard.getModuleActionFunction("Tactile Feedback", mode, action)
						
						if (function && (function != ""))
							this.setActionFunction(mode, action, (IsObject(function) ? function : Array(function)))
					}
					
					label := getConfigurationValue(pluginLabels, "Tactile Feedback", action . (mode ? ".Dial" : ".Toggle"), kUndefined)
					
					if (label == kUndefined) {
						label := getConfigurationValue(pluginLabels, "Tactile Feednack", action . ".Activate", kUndefined)
						
						if (label == kUndefined) {
							label := ""
							
							this.setAction(count, mode, action, [false, (mode ? "Dial" : "Toggle"), "Increase", "Decrease"], label)
						
							isBinary := true
						}
						else {
							this.setAction(count, mode, action, [false, "Activate"], label)
							
							isBinary := false
						}
					}
					else {
						if mode
							this.setAction(count, mode, action, [false, "Dial", "Increase", "Decrease"], label)
						else
							this.setAction(count, mode, action, [false, "Activate"], label)
						
						isBinary := true
					}
					
					function := this.getActionFunction(mode, action)
					
					if function {
						if (function.Length() == 1)
							function := (!isBinary ? function[1] : ((mode ? translate("+/-: ") : translate("On/Off: ")) . function[1]))
						else {
							onLabel := getConfigurationValue(pluginLabels, "Tactile Feedback", action . ".Increase", false)
							offLabel := getConfigurationValue(pluginLabels, "Tactile Feedback", action . ".Decrease", false)
							
							if (onLabel && (function[1] != ""))
								this.setActionLabel(count, function[1], onLabel)
							
							if (offLabel && (function[2] != ""))
								this.setActionLabel(count, function[2], offLabel)
							
							function := ((mode ? translate("+: ") : translate("On: ")) . function[1] . (mode ? translate(" | -: ") : translate(" | Off: ")) . function[2])
						}
					}
					else
						function := ""
					
					LV_Add("", (first ? translate(mode ? mode : "Independent") : ""), action, label, function)
					
					count += 1
				}
			}
		}
		
		this.loadButtonBoxLabels()
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
	}
	
	saveActions() {
		local function
		local action
		
		wizard := this.SetupWizard
		
		for ignore, mode in this.getModes() {
			modeFunctions := {}
		
			for ignore, action in this.getActions(mode)
				if wizard.moduleActionAvailable("Tactile Feedback", mode, action) {
					function := this.getActionFunction(mode, action)
					
					if (function && (function != ""))
						modeFunctions[action] := function
				}
			
			wizard.setModuleActionFunctions("Tactile Feedback", mode, modeFunctions)
		}
	}
	
	changeEffects(mode) {
		actions := this.getActions(mode)
		
		title := translate("Setup ")
		prompt := translate("Please input effect names (seperated by comma):")
		locale := ((getLanguage() = "en") ? "" : "Locale")
		
		actions := values2String(", ", actions*)
		
		InputBox actions, %title%, %prompt%, , 300, 150, , , %locale%, , %actions%
		
		if !ErrorLevel {
			this.saveActions()
			
			this.SetupWizard.setModuleAvailableActions("Tactile Feedback", mode, string2Values(",", actions))
			
			this.loadActions(true)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

changePedalEffects() {
	SetupWizard.Instance.StepWizards["Tactile Feedback"].changeEffects("Pedal Vibration")
}

changeChassisEffects() {
	SetupWizard.Instance.StepWizards["Tactile Feedback"].changeEffects("Chassis Vibration")
}

updateTactileFeedbackActionFunction() {
	updateActionFunction(SetupWizard.Instance.StepWizards["Tactile Feedback"])
}

initializeTactileFeedbackStepWizard() {
	SetupWizard.Instance.registerStepWizard(new TactileFeedbackStepWizard(SetupWizard.Instance, "Tactile Feedback", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTactileFeedbackStepWizard()