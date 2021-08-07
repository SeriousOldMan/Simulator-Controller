;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tactile Feedback Step Wizard   ;;;
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
;;; TactileFeedbackStepWizard                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TactileFeedbackStepWizard extends ActionsStepWizard {
	iModeActions := {}
	
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
				
		new Plugin("Tactile Feedback", false, true, "", arguments).saveToConfiguration(configuration)
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
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDtactileFeedbackIconHandle Hidden, %kResourcesDirectory%Setup\Images\Pedal.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDtactileFeedbackLabelHandle Hidden, % translate("Tactile Feedback")
		
		Gui %window%:Font, s8 Norm, Arial
			
		columnLabel1Handle := false
		columnLine1Handle := false
		columnLabel2Handle := false
		columnLine2Handle := false
		
		listX := x + 250
		listWidth := width - 250
			
		colWidth := width - listWidth - x
		
		Gui %window%:Font, Bold, Arial
			
		Gui %window%:Add, Text, x%x% yp+30 w%colWidth% h23 +0x200 HWNDcolumnLabel1Handle Hidden Section, % translate("Setup")
		Gui %window%:Add, Text, yp+20 x%x% w%colWidth% 0x10 HWNDcolumnLine1Handle Hidden
		
		Gui %window%:Add, Text, x%listX% ys w%listWidth% h23 +0x200 HWNDcolumnLabel2Handle Hidden Section, % translate("Actions")
		Gui %window%:Add, Text, yp+20 x%listX% w%listWidth% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, Norm, Arial
		
		Gui Add, ListView, x%listX% yp+10 w%listWidth% h270 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDtactileFeedbackListViewHandle gupdateTactileFeedbackActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Gui %window%:Add, ActiveX, x%x% yp+275 w%width% h80 HWNDtactileFeedbackInfoTextHandle VtactileFeedbackInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		tactileFeedbackInfoText.Navigate("about:blank")
		tactileFeedbackInfoText.Document.Write(html)
		
		this.setActionsListView(tactileFeedbackListViewHandle)
		
		this.registerWidgets(1, tactileFeedbackIconHandle, tactileFeedbackLabelHandle, tactileFeedbackListViewHandle, tactileFeedbackInfoTextHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle)
	}
	
	reset() {
		base.reset()
		
		this.iModeActions := {}
	}
	
	showPage(page) {
		this.iModeActions := {}
		
		base.showPage(page)
	}
	
	hidePage(page) {
		wizard := this.SetupWizard
		
		if !wizard.isSoftwareInstalled("SimHub") {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup")
			MsgBox 262436, %title%, % translate("SimHub cannot be found. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		return base.hidePage(page)
	}
	
	getActions(mode := false) {
		if this.iModeActions.HasKey(mode)
			return this.iModeActions[mode]
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
			
			this.iModeActions[mode] := actions
			
			return actions
		}
	}
	
	setAction(row, action, actionDescriptor, label) {
		local function
		
		wizard := this.SetupWizard
		
		base.setAction(row, action, actionDescriptor, label)
			
		if inList(this.getActions(false), action) {
			functions := this.getActionFunction(action)
			
			if functions {
				row := false
				column := false
			
				for ignore, function in functions {
					wizard.addControllerStaticFunction("Tactile Feedback", function, label)
				
					for ignore, preview in this.ButtonBoxPreviews
						if preview.findFunction(function, row, column)
							preview.setLabel(row, column, label)
				}
			}
		}
	}
	
	clearActionFunction(action, function) {
		base.clearActionFunction(action, function)
		
		if inList(this.getActions(false), action)
			this.SetupWizard.removeControllerStaticFunction("Tactile Feedback", function)
	}
	
	loadActions(load := false) {
		local function
		local action
		local count
		
		window := this.Window
		wizard := this.SetupWizard
		
		if load
			this.clearActionFunctions()
		
		this.clearActions()
		
		Gui %window%:Default
		
		Gui ListView, % this.ActionsListView
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		LV_Delete()
		
		lastMode := -1
		count := 1
		
		for ignore, mode in concatenate([false], this.Definition) {
			for ignore, action in this.getActions(mode) {
				if wizard.moduleActionAvailable("Tactile Feedback", mode, action) {
					first := (mode != lastMode)
					lastMode := mode
				
					if load {
						function := wizard.getModuleActionFunction("Tactile Feedback", mode, action)
						
						if (function && (function != ""))
							this.setActionFunction(action, (IsObject(function) ? function : Array(function)))
					}
					
					label := getConfigurationValue(pluginLabels, "Tactile Feedback", action . (mode ? ".Dial" : ".Toggle"), kUndefined)
					
					if (label == kUndefined) {
						label := getConfigurationValue(pluginLabels, code, action . ".Activate", "")
		
						this.setAction(count, action, [false, "Activate"], label)
						
						isBinary := false
					}
					else {
						this.setAction(count, action, [false, (mode ? "Dial" : "Toggle"), "Increase", "Decrease"], label)
						
						isBinary := (mode != false)
					}
					
					function := this.getActionFunction(action)
					
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
					
					LV_Add("", (first ? translate(mode ? mode : "Mode Independent") : ""), action, label, function)
					
					count += 1
				}
			}
		}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
	}
	
	saveActions() {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

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