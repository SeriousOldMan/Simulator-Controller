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
;;; MotionFeedbackStepWizard                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class MotionFeedbackStepWizard extends ActionsStepWizard {
	iMotionEffectsList := false
	
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
	
		if wizard.isModuleSelected("Tactile Feedback") {
			connector := wizard.softwarePath("StreamDeck Extension")
			
			arguments := ((connector && (connector != "")) ? ("connector: " . connector) : "")
			
			parameters := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Parameters", ""))
			
			for ignore, action in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Toggles", "")) {
				function := wizard.getModuleActionFunction("Motion Feedback", false, action)

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
					function := wizard.getModuleActionFunction("Motion Feedback", mode, action)

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
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDmotionFeedbackIconHandle Hidden, %kResourcesDirectory%Setup\Images\Motion.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDmotionFeedbackLabelHandle Hidden, % translate("Motion Feedback")
		
		Gui %window%:Font, s8 Norm, Arial
			
		columnLabel1Handle := false
		columnLine1Handle := false
		columnLabel2Handle := false
		columnLine2Handle := false
		
		listX := x + 300
		listWidth := width - 300
			
		colWidth := width - listWidth - x
		
		Gui %window%:Font, Bold, Arial
			
		Gui %window%:Add, Text, x%x% yp+30 w%colWidth% h23 +0x200 HWNDcolumnLabel1Handle Hidden Section, % translate("Setup")
		Gui %window%:Add, Text, yp+20 x%x% w%colWidth% 0x10 HWNDcolumnLine1Handle Hidden
		
		secondX := x + 155
		buttonX := secondX - 24
		secondWidth := colWidth - 155
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+10 w105 h23 +0x200 HWNDmotionEffectsLabelHandle Hidden, % translate("Motion Effects")
		
		Gui %window%:Font, s8 Bold, Arial
		
		Gui %window%:Add, Button, x%buttonX% yp w23 h23 HWNDmotionEffectsButtonHandle gchangeMotionEffects Hidden, % translate("...")
		Gui %window%:Add, ListBox, x%secondX% yp w%secondWidth% h60 Disabled HWNDmotionEffectsListHandle Hidden
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Button, x%x% yp+70 w%colWidth% h23 HWNDlabelsEditorButtonHandle gopenLabelsEditor Hidden, % translate("Edit Plugin Labels...")
		
		Gui %window%:Add, Text, x%listX% ys w%listWidth% h23 +0x200 HWNDcolumnLabel2Handle Hidden Section, % translate("Actions")
		Gui %window%:Add, Text, yp+20 x%listX% w%listWidth% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, Norm, Arial
		
		Gui Add, ListView, x%listX% yp+10 w%listWidth% h270 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDmotionFeedbackListViewHandle gupdateMotionFeedbackActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "State", "Value", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Gui %window%:Add, ActiveX, x%x% yp+275 w%width% h80 HWNDmotionFeedbackInfoTextHandle VmotionFeedbackInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		motionFeedbackInfoText.Navigate("about:blank")
		motionFeedbackInfoText.Document.Write(html)
		
		this.setActionsListView(motionFeedbackListViewHandle)
		
		this.iMotionEffectsList := motionEffectsListHandle
		
		this.registerWidgets(1, motionFeedbackIconHandle, motionFeedbackLabelHandle, motionFeedbackListViewHandle, motionFeedbackInfoTextHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle, motionEffectsLabelHandle, motionEffectsButtonHandle, motionEffectsListHandle, labelsEditorButtonHandle)
	}
	
	reset() {
		base.reset()
	
		this.iMotionEffectsList := {}
		this.iCachedActions := {}
	}
	
	showPage(page) {
		base.showPage(page)
		
		list := this.iMotionEffectsList
		
		GuiControl Disable, %list%
	}
	
	hidePage(page) {
		wizard := this.SetupWizard
		
		if (!wizard.isSoftwareInstalled("SimFeedback") || !wizard.isSoftwareInstalled("StreamDeck Extension")) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup")
			MsgBox 262436, %title%, % translate("SimFeedback cannot be found or the StreamDeck Extension was not installed. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		return base.hidePage(page)
	}
	
	getActions(mode := false) {
		if this.iCachedActions.HasKey(mode)
			return this.iCachedActions[mode]
		else {
			wizard := this.SetupWizard
			
			actions := wizard.moduleAvailableActions("Motion Feedback", mode)
			
			if (actions.Length() == 0) {
				if mode
					actions := concatenate(string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback." . mode . ".Effects", ""))
										 , string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback." . mode . ".Intensity", "")))
				else
					actions := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Toggles", ""))
				
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
			
			if functions {
				row := false
				column := false
			
				for ignore, function in functions {
					wizard.addControllerStaticFunction("Motion Feedback", function, label)
				
					for ignore, preview in this.ButtonBoxPreviews
						if preview.findFunction(function, row, column)
							preview.setLabel(row, column, label)
				}
			}
		}
	}
	
	clearActionFunction(mode, action, function) {
		base.clearActionFunction(mode, action, function)
		
		if inList(this.getActions(false), action)
			this.SetupWizard.removeControllerStaticFunction("Motion Feedback", function)
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
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		LV_Delete()
		
		lastMode := -1
		count := 1
		
		for ignore, mode in concatenate([false], this.Definition) {
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
					
					label := getConfigurationValue(pluginLabels, "Motion Feedback", action . (mode ? ".Dial" : ".Toggle"), kUndefined)
					
					if (label == kUndefined) {
						label := getConfigurationValue(pluginLabels, code, action . ".Activate", "")
		
						this.setAction(count, mode, action, [false, "Activate"], label)
						
						isBinary := false
					}
					else {
						this.setAction(count, mode, action, [false, (mode ? "Dial" : "Toggle"), "Increase", "Decrease"], label)
						
						isBinary := (mode != false)
					}
					
					function := this.getActionFunction(mode, action)
					
					if function {
						for ignore, partFunction in function {
							row := false
							column := false
							
							for ignore, preview in this.ButtonBoxPreviews {
								if preview.findFunction(partFunction, row, column) {
									preview.setLabel(row, column, label)
									
									break
								}
							}
						}
					
						if (function.Length() == 1)
							function := (!isBinary ? function[1] : ("+/-: " . function[1]))
						else
							function := ("+: " . function[1] . " | -: " . function[2])
					}
					else
						function := ""
					
					arguments := this.getActionArgument(count)
					
					if (arguments && (arguments != "")) {
						state := string2Values("|", arguments)
						value := state[2]
						state := state[1]
					}
					else {
						state := true
						value := ""
					}
					
					LV_Add("", (first ? translate(mode ? mode : "Independent") : ""), action, label, state ? "On" : "Off", value, function)
					
					count += 1
				}
			}
		}
			
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
		
		for ignore, mode in concatenate([false], this.Definition) {
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
		
		title := translate("Setup")
		prompt := translate("Please input effect names (seperated by comma):")
		locale := ((getLanguage() = "en") ? "" : "Locale")
		
		actions := values2String(", ", actions*)
		
		InputBox actions, %title%, %prompt%, , 300, 150, , , %locale%, , %actions%
		
		if !ErrorLevel {
			this.saveActions()
			
			this.SetupWizard.setModuleAvailableActions("Motion Feedback", mode, string2Values(",", actions))
			
			this.loadActions(true)
		}
	}
	
	createActionsMenu(title, row) {
		contextMenu := base.createActionsMenu(title, row)
		
		Menu %contextMenu%, Add
		
		menuItem := translate("Toggle State")
		handler := ObjBindMethod(this, "toggleState", row)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		menuItem := translate("Set Value...")
		handler := ObjBindMethod(this, "inputValue", row)
		
		Menu %contextMenu%, Add, %menuItem%, %handler%
		
		return contextMenu
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
		
		this.loadActions()
	}
	
	inputValue(row) {
		local action := this.getAction(row)
		
		mode := this.getActionMode(row)
		
		title := translate("Setup")
		prompt := translate("Please input initial effect value (use dot as decimal point):")
		locale := ((getLanguage() = "en") ? "" : "Locale")
		
		arguments := this.getActionArgument(row)
		
		if (arguments && (arguments != "")) {
			arguments := string2Values("|", arguments)
			
			value := arguments[2]
		}
		else {
			arguments := Array(true, "")
		
			value := ""
		}
		
		InputBox value, %title%, %prompt%, , 200, 150, , , %locale%, , %value%
		
		if !ErrorLevel {
			if value is number
				if ((value >= 0) && (value <= 100))
					valid := true
			
			if !valid {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("You must enter a valid value between 0 and 100...")
				OnMessage(0x44, "")
				
				return
			}
			
			arguments[2] := value
			
			this.setActionArgument(row, values2String("|", arguments*))
			
			this.loadActions()
		}
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