;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pedal Calibtazion Step Wizard   ;;;
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
;;; PedalCalibrationStepWizard                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PedalCalibrationStepWizard extends ActionsStepWizard {
	Pages[] {
		Get {
			wizard := this.SetupWizard

			if (wizard.isModuleSelected("Button Box") && wizard.isModuleSelected("Pedal Calibration"))
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
		calibrations := []

		for ignore, pedal in this.Definition
			for ignore, curve in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Curves")) {
				action := (pedal . "." . curve)
				function := wizard.getModuleActionFunction("Pedal Calibration", "Pedal Calibration", action)
				
				if (function && (function != ""))
					calibrations.Push("""" . action . """ " . (IsObject(function) ? function[1] : function))
			}
		
		if (calibrations.Length() > 0)
			arguments .= ("pedalCalibrations: " . values2String(", ", calibrations*))
				
		new Plugin("Pedal Calibration", false, true, "", arguments).saveToConfiguration(configuration)
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static pedalCalibrationInfoText
		
		window := this.Window
		
		Gui %window%:Default
		
		pedalCalibrationIconHandle := false
		pedalCalibrationLabelHandle := false
		pedalCalibrationListViewHandle := false
		pedalCalibrationInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDpedalCalibrationIconHandle Hidden, %kResourcesDirectory%Setup\Images\Pedal.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDpedalCalibrationLabelHandle Hidden, % translate("Pedal Calibration")
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui Add, ListView, x%x% yp+30 w%width% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDpedalCalibrationListViewHandle gupdatePedalCalibrationActionFunction Hidden, % values2String("|", map(["Mode", "Action", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h80 HWNDpedalCalibrationInfoTextHandle VpedalCalibrationInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		pedalCalibrationInfoText.Navigate("about:blank")
		pedalCalibrationInfoText.Document.Write(html)
		
		this.setActionsListView(pedalCalibrationListViewHandle)
		
		this.registerWidgets(1, pedalCalibrationIconHandle, pedalCalibrationLabelHandle, pedalCalibrationListViewHandle, pedalCalibrationInfoTextHandle)
	}
	
	hidePage(page) {
		wizard := this.SetupWizard
		
		if !wizard.isSoftwareInstalled("SmartControl") {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup")
			MsgBox 262436, %title%, % translate("Heusinkveld SmartControl cannot be found. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		return base.hidePage(page)
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
		
		LV_Delete()
		
		count := 1
		
		for ignore, pedal in this.Definition
			for ignore, curve in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Curves")) {
				action := (pedal . "." . curve)
				
				if wizard.moduleActionAvailable("Pedal Calibration", "Pedal Calibration", action) {
					if load {
						function := wizard.getModuleActionFunction("Pedal Calibration", "Pedal Calibration", action)
						
						if (function && (function != ""))
							this.setActionFunction("Pedal Calibration", action, (IsObject(function) ? function : Array(function)))
					}
					
					subAction := ConfigurationItem.splitDescriptor(action)
					
					label := (translate(subAction[1]) . " " . subAction[2])
					
					this.setAction(count, "Pedal Calibration", action, [false, "Activate"], label)
					
					function := this.getActionFunction("Pedal Calibration", action)
					
					if (function && (function != "")) {
						function := (IsObject(function) ? function[1] : function)
						
						row := false
						column := false
						
						for ignore, preview in this.ButtonBoxPreviews {
							if preview.findFunction(function, row, column) {
								preview.setLabel(row, column, label)
								
								break
							}
						}
					}
					else
						function := ""
					
					LV_Add("", ((count = 1) ? translate("Pedal Calibration") : ""), action, label, function)
					
					count += 1
				}
			}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
	}
	
	saveActions() {
		local function
		local action
		
		wizard := this.SetupWizard
		
		modeFunctions := {}
		
		for ignore, pedal in this.Definition
			for ignore, curve in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Curves")) {
				action := (pedal . "." . curve)
				
				if wizard.moduleActionAvailable("Pedal Calibration", "Pedal Calibration", action) {
					function := this.getActionFunction("Pedal Calibration", action)
					
					if (function && (function != ""))
						modeFunctions[action] := function
				}
			}
					
		wizard.setModuleActionFunctions("Pedal Calibration", "Pedal Calibration", modeFunctions)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updatePedalCalibrationActionFunction() {
	updateActionFunction(SetupWizard.Instance.StepWizards["Pedal Calibration"])
}

initializePedalCalibrationStepWizard() {
	SetupWizard.Instance.registerStepWizard(new PedalCalibrationStepWizard(SetupWizard.Instance, "Pedal Calibration", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalCalibrationStepWizard()