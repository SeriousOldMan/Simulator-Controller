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
	
	iSimulatorMFDKeys := {}
	iButtonBoxWidgets := []
	
	iCachedActions := {}
	iCachedSimulator := false
	
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
		
		for ignore, simulator in this.Definition {
			code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
			
			if wizard.isApplicationSelected(simulator) {
				arguments := ""
				
				for ignore, descriptor in this.iSimulatorMFDKeys[simulator] {
					key := descriptor[3]
					value := wizard.getSimulatorValue(simulator, key, descriptor[4])
					
					if (arguments != "")
						arguments .= "; "
					
					arguments .= (key . ": " . value)
				}
				
				for ignore, mode in ["Pitstop", "Assistant"] {
					actions := ""
				
					for ignore, action in this.getActions(mode, simulator)
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
			else
				new Plugin(code, false, false, simulator, "").saveToConfiguration(configuration)
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static actionsInfoText
		
		wizard := this.SetupWizard
		window := this.Window
		
		Gui %window%:Default
		
		actionsIconHandle := false
		actionsIconLabelHandle := false
		actionsListViewHandle := false
		actionsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 35
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDactionsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Gaming Wheel.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDactionsLabelHandle Hidden, % translate("Simulator Configuration")
		
		Gui %window%:Font, s8 Norm, Arial

		simulatorLabelHandle := false
		simulatorDropDownHandle := false
		
		columnLabel1Handle := false
		columnLine1Handle := false
		columnLabel2Handle := false
		columnLine2Handle := false
	
		secondX := x + 80
		secondWidth := 160
		
		col1Width := (secondX - x) + secondWidth
		
		Gui %window%:Add, Text, x%x% yp+30 w105 h23 +0x200 HWNDsimulatorLabelHandle Hidden, % translate("Simulator")
		Gui %window%:Add, DropDownList, x%secondX% yp w%secondWidth% Choose%chosen% HWNDsimulatorDropDownHandle gchooseSimulator vsimulatorDropDown Hidden
		
		Gui %window%:Font, Bold, Arial
		
		Gui %window%:Add, Text, x%x% yp+30 w%col1Width% h23 +0x200 HWNDcolumnLabel1Handle Hidden Section, % translate("Pitstop MFD")
		Gui %window%:Add, Text, yp+20 x%x% w%col1Width% 0x10 HWNDcolumnLine1Handle Hidden

		Gui %window%:Font, Norm, Arial
		
		labelHandle := false
		editHandle := false
		
		secondX := x + 150
		
		for ignore, simulator in this.Definition {
			code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
			keys := getConfigurationValue(wizard.Definition, "Setup.Simulators", "Simulators.MFDKeys." . code, false)
			
			if keys {
				this.iSimulatorMFDKeys[simulator] := []
				keyY := labelY + 90
				
				for ignore, key in string2Values("|", keys) {
					key := string2Values(":", key)
					default := key[2]
					key := key[1]
					
					label := getConfigurationValue(wizard.Definition, "Setup.Simulators", "Simulators.MFDKeys." . key . "." . getLanguage(), key)
				
					Gui %window%:Add, Text, x%x% y%keyY% w148 h23 +0x200 HWNDlabelHandle Hidden, % label
					Gui %window%:Add, Edit, x%secondX% yp w60 h23 +0x200 HWNDeditHandle Hidden, % default
		
					this.iSimulatorMFDKeys[simulator].Push(Array(labelHandle, editHandle, key, default))
					this.registerWidgets(1, labelHandle, editHandle)
					
					keyY += 24
				}
			}
		}
		
		listX := x + 250
		listWidth := width - 250
		
		Gui %window%:Font, Bold, Arial
		
		Gui %window%:Add, Text, x%listX% ys w%listWidth% h23 +0x200 HWNDcolumnLabel2Handle Hidden, % translate("Actions")
		Gui %window%:Add, Text, yp+20 x%listX% w%listWidth% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, Norm, Arial
		
		Gui Add, ListView, x%listX% yp+10 w%listWidth% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDactionsListViewHandle gupdateSimulatorActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Simulators", "Simulators.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"
		
		Sleep 200
		
		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h76 HWNDactionsInfoTextHandle VactionsInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		actionsInfoText.Navigate("about:blank")
		actionsInfoText.Document.Write(html)
		
		this.iButtonBoxWidgets := [columnLabel2Handle, columnLine2Handle]
		
		this.setActionsListView(actionsListViewHandle)
		
		this.registerWidgets(1, actionsIconHandle, actionsLabelHandle, actionsListViewHandle, actionsInfoTextHandle, simulatorLabelHandle, simulatorDropDownHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle)
	}
	
	reset() {
		base.reset()
		
		this.iSimulatorMFDKeys := {}
		this.iButtonBoxWidgets := []
		this.iCachedActions := {}
		this.iCachedSimulator := false
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
		
		this.loadSimulatorMFDKeys(this.iCurrentSimulator)
		
		GuiControl, , simulatorDropDown, % "|" . values2String("|", this.iSimulators*)
		GuiControl Choose, simulatorDropDown, % chosen
	}
	
	hidePage(page) {
		if base.hidePage(page) {
			this.saveSimulatorMFDKeys(this.iCurrentSimulator)
				
			return true
		}
		else
			return false
	}
	
	getModes() {
		return ["Pitstop", "Assistant"]
	}
	
	getActions(mode, simulator := false) {
		if !simulator
			simulator := this.iCurrentSimulator

		if (simulator != this.iCachedSimulator) {
			this.iCachedActions := {}
		
			this.iCachedSimulator := simulator
		}
		
		if this.iCachedActions.HasKey(mode)
			return this.iCachedActions[mode]
		else {
			wizard := this.SetupWizard
			
			code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
			actions := string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Actions.Assistant" : ("Simulators.Settings.Pitstop." . code)))
			
			this.iCachedActions[mode] := actions
			
			return actions
		}
	}
	
	chooseSimulator() {
		this.saveActions()
		
		this.saveSimulatorMFDKeys(this.iCurrentSimulator)
		
		GuiControlGet simulatorDropDown
		
		this.iCurrentSimulator := simulatorDropDown
		
		this.loadSimulatorMFDKeys(simulatorDropDown)
		
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
		local count
		
		window := this.Window
		wizard := this.SetupWizard
		
		if load {
			this.iCachedActions := {}
			
			this.clearActionFunctions()
		}
		
		this.clearActions()
		
		Gui %window%:Default
		
		Gui ListView, % this.ActionsListView
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
		
		LV_Delete()
		
		lastMode := false
		count := 1
		
		for ignore, mode in ["Pitstop", "Assistant"]
			for ignore, action in this.getActions(mode, simulator) {
				if wizard.simulatorActionAvailable(simulator, mode, action) {
					first := (mode != lastMode)
					lastMode := mode
				
					if load {
						function := wizard.getSimulatorActionFunction(simulator, mode, action)
						
						if (function != "")
							this.setActionFunction(mode, action, (IsObject(function) ? function : Array(function)))
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
						label := getConfigurationValue(pluginLabels, code, subAction . ".Dial", kUndefined)
						
						if (label != kUndefined) {
							this.setAction(count, mode, action, [isInformationRequest, "Dial", "Increase", "Decrease"], label)
						
							isBinary := true
							isDial := true
						}
						else {
							label := getConfigurationValue(pluginLabels, code, subAction . ".Activate", "")
			
							this.setAction(count, mode, action, [isInformationRequest, "Activate"], label)
							
							isBinary := false
							isDial := false
						}
					}
					else {
						this.setAction(count, mode, action, [isInformationRequest, "Toggle", "Increase", "Decrease"], label)
						
						isBinary := true
						isDial := false
					}
					
					function := this.getActionFunction(mode, action)
					
					if function {
						if (function.Length() == 1)
							function := (!isBinary ? function[1] : ((isDial ? translate("+/-: ") : translate("On/Off: ")) . function[1]))
						else {
							onLabel := getConfigurationValue(pluginLabels, code, subAction . ".Increase", false)
							offLabel := getConfigurationValue(pluginLabels, code, subAction . ".Decrease", false)
							
							if (onLabel && (function[1] != ""))
								this.setActionLabel(count, function[1], onLabel)
							
							if (offLabel && (function[2] != ""))
								this.setActionLabel(count, function[2], offLabel)
							
							function := ((isDial ? translate("+: ") : translate("On: ")) . function[1] . (isDial ? translate(" | -: ") : translate(" | Off: ")) . function[2])
						}
					}
					else
						function := ""
					
					LV_Add("", (first ? translate(mode) : ""), subAction, label, function)
					
					count += 1
				}
			}
		
		this.loadButtonBoxLabels()
		
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
		
			for ignore, action in this.getActions(mode, simulator)
				if wizard.simulatorActionAvailable(simulator, mode, action) {
					function := this.getActionFunction(mode, action)
					
					if (function && (function != ""))
						modeFunctions[action] := function
				}
			
			wizard.setSimulatorActionFunctions(simulator, mode, modeFunctions)
		}
	}
	
	loadSimulatorMFDKeys(simulator) {
		wizard := this.SetupWizard
		
		for ignore, descriptors in this.iSimulatorMFDKeys
			for ignore, descriptor in descriptors {
				GuiControl Hide, % descriptor[1]
				GuiControl Hide, % descriptor[2]
			}
		
		for ignore, descriptor in this.iSimulatorMFDKeys[simulator] {
			value := wizard.getSimulatorValue(simulator, descriptor[3], descriptor[4])
			
			widget := descriptor[2]
			
			GuiControl, , %widget%, %value%
			
			GuiControl Show, % descriptor[1]
			GuiControl Show, % descriptor[2]
			GuiControl Enable, % descriptor[1]
			GuiControl Enable, % descriptor[2]
		}
	}
	
	saveSimulatorMFDKeys(simulator) {
		wizard := this.SetupWizard
		
		for ignore, descriptor in this.iSimulatorMFDKeys[simulator] {
			GuiControlGet value, , % descriptor[2]
			
			wizard.setSimulatorValue(simulator, descriptor[3], value, false)
		}
	}
	
	loadButtonBoxLabels() {
		local function
		local action
		
		base.loadButtonBoxLabels()
		
		wizard := this.SetupWizard
		simulator := this.iCurrentSimulator
		
		for ignore, preview in this.ButtonBoxPreviews {
			targetMode := preview.Mode
		
			for ignore, mode in this.getModes()
				if ((targetMode == true) || (mode = targetMode))
					for ignore, action in this.getActions(mode, simulator)
						if wizard.simulatorActionAvailable(simulator, mode, action) {
							function := this.getActionFunction(mode, action)
								
							if (function && (function != "")) {
								if !IsObject(function)
									function := Array(function)
									
								for ignore, partFunction in function
									if (partFunction && (partFunction != ""))
										if preview.findFunction(partFunction, row, column)
											preview.setLabel(row, column, this.getActionLabel(this.getActionRow(mode, action), partFunction))
							}
						}
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