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

global simulatorDropDown

class PedalCalibrationStepWizard extends ActionsStepWizard {
	iModeActions := []
	
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

		for ignore, pedal in getConfigurationValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Pedals")
			for ignore, action in getConfigurationValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Actions") {
				action := (pedal . "." . action)
				function := wizard.getModuleActionFunction("Pedal Calibration", "Pedal Calibration", action)
				
				if (function && (function != "")) {
					calibrations.Push("""" . action . """ " . function)
			}
		
		if (calibrations.Length() > 0)
			arguments .= ("pedalCalibrations: " . values2String(", ", calibrations*))
				
		new Plugin("Pedal Calibration", false, true, "", arguments).saveToConfiguration(configuration)
	}
	
	createGui(wizard, x, y, width, height) {
	}
	
	reset() {
		base.reset()
		
		this.iModeActions := false
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
	}
	
	saveActions() {
		wizard := this.SetupWizard
		
		wizard.setModuleActionFunctions("Pedal Calibration", "Pedal Calibration", this.iModeActions)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateSimulatorActionFunction() {
	updateActionFunction(SetupWizard.Instance.StepWizards["Pedal Calibration"])
}

initializePedalCalibrationStepWizard() {
	SetupWizard.Instance.registerStepWizard(new PedalCalibrationStepWizard(SetupWizard.Instance, "Pedal Calibration", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalCalibrationStepWizard()