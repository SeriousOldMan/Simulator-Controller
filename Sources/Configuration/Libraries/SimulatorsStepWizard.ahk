;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulators Step Wizard          ;;;
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
;;; SimulatorsStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorDropDown

class SimulatorsStepWizard extends ActionsStepWizard {
	iSimulators := []
	iCurrentSimulator := false
	
	iButtonBoxWidgets := []
	
	Pages[] {
		Get {
			wizard := this.SetupWizard

			if (wizard.isModuleSelected("Button Box") || wizard.isModuleSelected("Race Engineer"))
				for ignore, simulator in this.Definition
					if wizard.isApplicationSelected(simulator)
						return 1
				
			return 0
		}
	}
	
	saveToConfiguration(configuration) {
		local function
		local action
		
		base.saveToConfiguration(configuration)
		
		wizard := this.SetupWizard
		
		for ignore, simulator in this.Definition
			if wizard.isApplicationSelected(simulator) {
				code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
				arguments := ""
				
				for ignore, mode in ["Pitstop", "Assistant"] {
					actions := ""
				
					for ignore, action in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Actions.Assistant" : ("Simulators.Settings.Pitstop." . code)))
						if wizard.simulatorActionAvailable(simulator, mode, action) {
							function := wizard.getSimulatorActionFunction(simulator, mode, action)

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
						
						arguments .= (((mode = "Pitstop") ? "pitstopCommands: " : "assistantCommands: ") . actions)
					}
				}
				
				new Plugin(code, false, true, simulator, arguments).saveToConfiguration(configuration)
			}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static actionsInfoText
		
		window := this.Window
		
		Gui %window%:Default
		
		actionsIconHandle := false
		actionsIconLabelHandle := false
		actionsListViewHandle := false
		actionsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDactionsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Controller.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDactionsLabelHandle Hidden, % translate("Simulator Configuration")
		
		Gui %window%:Font, s8 Norm, Arial

		simulatorLabelHandle := false
		simulatorDropDownHandle := false
		
		colummLabel1Handle := false
		colummLine1Handle := false
		colummLabel2Handle := false
		colummLine2Handle := false
	
		secondX := x + 80
		secondWidth := 160
		
		col1Width := (secondX - x) + secondWidth
		
		Gui %window%:Add, Text, x%x% yp+30 w105 h23 +0x200 HWNDsimulatorLabelHandle Hidden, % translate("Simulator")
		Gui %window%:Add, DropDownList, x%secondX% yp w%secondWidth% Choose%chosen% HWNDsimulatorDropDownHandle gchooseSimulator vsimulatorDropDown Hidden
		
		Gui %window%:Font, Bold, Arial
		
		Gui %window%:Add, Text, x%x% yp+30 w%col1Width% h23 +0x200 HWNDcolumnLabel1Handle Hidden Section, % translate("Pitstop MFD")
		Gui %window%:Add, Text, yp+20 x%x% w%col1Width% 0x10 HWNDcolumnLine1Handle Hidden

		Gui %window%:Font, Norm, Arial
		
		colummLabel1Handle := false
		colummLine1Handle := false
		colummLabel2Handle := false
		colummLine2Handle := false
		
		listX := x + 250
		listWidth := width - 250
		
		Gui %window%:Font, Bold, Arial
		
		Gui %window%:Add, Text, x%listX% ys w%listWidth% h23 +0x200 HWNDcolumnLabel2Handle Hidden, % translate("Actions")
		Gui %window%:Add, Text, yp+20 x%listX% w%listWidth% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, Norm, Arials
		
		Gui Add, ListView, x%listX% yp+10 w%listWidth% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDactionsListViewHandle gupdateSimulatorActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Simulators", "Simulators.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"
		
		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h80 HWNDactionsInfoTextHandle VactionsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		actionsInfoText.Navigate("about:blank")
		actionsInfoText.Document.Write(html)
		
		this.iButtonBoxWidgets := [columnLabel2Handle, columnLine2Handle]
		
		this.setActionsListView(actionsListViewHandle)
		
		this.registerWidgets(1, actionsIconHandle, actionsLabelHandle, actionsListViewHandle, actionsInfoTextHandle, simulatorLabelHandle, simulatorDropDownHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle)
	}
	
	reset() {
		base.reset()
		
		this.iButtonBoxWidgets := []
	}
	
	updateState() {
		base.updateState()
		
		wizard := this.SetupWizard
		simulators := []
		
		for ignore, simulator in this.Definition
			if wizard.isApplicationSelected(simulator)
				simulators.Push(simulator)
			
		this.iSimulators := simulators
	}
	
	showPage(page) {
		chosen := (this.iSimulators.Length() > 0) ? 1 : 0
		
		this.iCurrentSimulator := ((chosen > 0) ? this.iSimulators[chosen] : false)
		
		base.showPage(page)
		
		if !this.SetupWizard.isModuleSelected("Button Box")
			for ignore, widget in this.iButtonBoxWidgets
				GuiControl Hide, %widget%
		
		GuiControl, , simulatorDropDown, % "|" . values2String("|", this.iSimulators*)
		GuiControl Choose, simulatorDropDown, % chosen
	}
	
	chooseSimulator() {
		this.saveActions()
		
		GuiControlGet simulatorDropDown
		
		this.iCurrentSimulator := simulatorDropDown
		
		this.resetButtonBoxes()
		this.loadActions(simulatorDropDown, true)
	}
	
	loadActions(load := false) {
		if (this.iCurrentSimulator && this.SetupWizard.isModuleSelected("Button Box"))
			this.loadSimulatorActions(this.iCurrentSimulator, load)
	}
	
	saveActions() {
		if (this.iCurrentSimulator && this.SetupWizard.isModuleSelected("Button Box"))
			this.saveSimulatorActions(this.iCurrentSimulator)
	}
	
	loadSimulatorActions(simulator, load := false) {
		local function
		local action
		
		window := this.Window
		wizard := this.SetupWizard
		
		if load
			this.clearActionFunctions()
		
		this.clearActions()
		
		Gui %window%:Default
		
		Gui ListView, % this.ActionsListView
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
		
		LV_Delete()
		
		lastMode := false
		count := 1
		
		for ignore, mode in ["Pitstop", "Assistant"]
			for ignore, action in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Actions.Assistant" : ("Simulators.Settings.Pitstop." . code))) {
				if wizard.simulatorActionAvailable(simulator, mode, action) {
					first := (mode != lastMode)
					lastMode := mode
				
					if load {
						function := wizard.getSimulatorActionFunction(simulator, mode, action)
						
						if (function != "")
							this.setActionFunction(action, (IsObject(function) ? function : Array(function)))
					}
					
					subAction := ConfigurationItem.splitDescriptor(action)
				
					if (subAction[1] = "InformationRequest") {
						subAction := subAction[2]
						
						isInformationRequest := true
					}
					else {
						subAction := subAction[1]
						
						isInformationRequest := false
					}
					
					label := getConfigurationValue(pluginLabels, code, subAction . ".Toggle", kUndefined)
					
					if (label == kUndefined) {
						label := getConfigurationValue(pluginLabels, code, subAction . ".Activate", "")
		
						this.setAction(count, action, [isInformationRequest, "Activate"], label)
						
						isBinary := false
					}
					else {
						this.setAction(count, action, [isInformationRequest, "Toggle", "Increase", "Decrease"], label)
						
						isBinary := true
					}
					
					function := this.getActionFunction(action)
					
					if function {
						for ignore, partFunction in function {
							row := false
							column := false
							
							for ignore, preview in this.iButtonBoxPreviews {
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
					
					LV_Add("", (first ? mode : ""), subAction, label, function)
					
					count += 1
				}
			}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
	}
	
	saveSimulatorActions(simulator) {
		local function
		local action
		
		wizard := this.SetupWizard
		code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
		
		for ignore, mode in ["Pitstop", "Assistant"] {
			modeFunctions := {}
		
			for ignore, action in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Actions.Assistant" : ("Simulators.Settings.Pitstop." . code)))				
				if wizard.simulatorActionAvailable(simulator, mode, action) {
					function := this.getActionFunction(action)
					
					if function
						modeFunctions[action] := function
				}
			
			wizard.setSimulatorActionFunctions(simulator, mode, modeFunctions)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateSimulatorActionFunction() {
	updateActionFunction(SetupWizard.Instance.StepWizards["Simulators"])
}

chooseSimulator() {
	SetupWizard.Instance.StepWizards["Simulators"].chooseSimulator()
}

initializeSimulatorsStepWizard() {
	SetupWizard.Instance.registerStepWizard(new SimulatorsStepWizard(SetupWizard.Instance, "Simulators", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorsStepWizard()