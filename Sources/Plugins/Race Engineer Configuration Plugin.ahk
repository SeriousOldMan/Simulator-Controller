;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceEngineerConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RaceEngineerConfigurator extends ConfigurationItem {
	__New(configuration) {
		base.__New(configuration)
		
		RaceEngineerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y80 w105 h23 +0x200, % translate("Simulator")
		
 		choices := this.getSimulators()
		chosen := (choices.Length() > 0) ? 1 : 0
		
		Gui %window%:Add, DropDownList, x156 y80 w307 Choose%chosen%, % values2String("|", choices*) ; gchooseSimulator vsimulatorDropDown
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y110 w458 h70, % translate("Session Startup")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y127 w160 h23 +0x200, % translate("Settings")
		choices := ["Use values from previous Session", "Load from Setup Database"]
		chosen := 1
		Gui %window%:Add, DropDownList, x156 y127 w307 Choose%chosen%, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x24 y151 w160 h23 +0x200, % translate("Tyre Pressures")
		choices := ["Use Values from Settings", "Load from Setup Database", "Import from Simulator"]
		chosen := 1
		Gui %window%:Add, DropDownList, x156 y151 w307 Choose%chosen%, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y186 w458 h70, % translate("Session Shutdown")
		
		Gui %window%:Font, Norm, Arial
		
		choices := ["Ask", "Always", "Never"]
		chosen := 1
		Gui %window%:Add, Text, x24 y203 w160 h23 +0x200, % translate("Save Settings")
		Gui %window%:Add, DropDownList, x156 y203 w140 Choose%chosen%, % values2String("|", choices*)
		
		choices := ["Ask", "Always", "Never"]
		chosen := 1
		Gui %window%:Add, Text, x24 y227 w160 h23 +0x200, % translate("Save Tyre Pressures")
		Gui %window%:Add, DropDownList, x156 y227 w140 Choose%chosen%, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y262 w458 h156, % translate("Data Analysis")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y279 w160 h23 +0x200, % translate("Learn for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number ; VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x196 yp w17 h21, 1
		Gui %window%:Add, Text, x200 yp w160 h23 +0x200, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x24 yp+26 w105 h20 Section, % translate("Statistical Window")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 Number ; VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x196 yp w17 h21, 1
		Gui %window%:Add, Text, x200 yp+2 w70 h20, % translate("Laps")
		
		Gui %window%:Add, Text, x24 ys+24 w105 h20 Section, % translate("Damping Factor")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 ; VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, Text, x200 yp+2 w70 h20, % translate("p. Lap")

		Gui %window%:Add, Text, x24 ys+30 w160 h23 +0x200 Section, % translate("Adjust Lap Time")
		Gui %window%:Add, CheckBox, x156 yp w300 h23, % translate("for Start, Pitstop or imcomplete Laps (use from Settings)") ; Checked%startWithWindowsCheck% VstartWithWindowsCheck
		
		Gui %window%:Add, Text, x24 ys+30 w160 h23 +0x200 Section, % translate("Damage Analysis for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number ; VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x196 yp w17 h21, 1
		Gui %window%:Add, Text, x200 yp-2 w160 h23 +0x200, % translate("Laps after Incident")
		
/*

		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Pitstop Warning")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VpitstopWarningEdit, %pitstopWarningEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %pitstopWarningEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("Laps")

		Gui RES:Add, Text, x16 yp+30 w105 h23 +0x200, % translate("Repair Suspension")
		
		choices := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairSuspensionDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairSuspensionDropDown)
	
		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairSuspensionDropDown% VrepairSuspensionDropDown gupdateRepairSuspensionState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairSuspensionGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairSuspensionThresholdEdit, %repairSuspensionThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairSuspensionThresholdLabel, % translate("Sec. p. Lap")

		updateRepairSuspensionState()
		
		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Repair Bodywork")
		
		choices := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairBodyworkDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairBodyworkDropDown)
		
		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairBodyworkDropDown% VrepairBodyworkDropDown gupdateRepairBodyworkState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairBodyworkGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairBodyworkThresholdEdit, %repairBodyworkThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairBodyworkThresholdLabel, % translate("Sec. p. Lap")

		updateRepairBodyworkState()
		
		
		Gui %window%:Add, CheckBox, x24 y200 w242 h23 Checked%startWithWindowsCheck% VstartWithWindowsCheck, % translate("Start with Windows")
		Gui %window%:Add, CheckBox, x24 y224 w242 h23 Checked%silentModeCheck% VsilentModeCheck, % translate("Silent mode (no splash screen, no sound)")
		
		Gui %window%:Add, Button, x363 y224 w100 h23 GopenThemesEditor, % translate("Themes Editor...")
		*/
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
	}

	getSimulators() {
		simulators := []
		
		for simulator, ignore in getConfigurationSectionValues(getControllerConfiguration(), "Simulators", Object())
			simulators.Push(simulator)
				
		return simulators
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerConfigurator() {
	editor := ConfigurationEditor.Instance
	
	editor.registerConfigurator(translate("Race Engineer"), new RaceEngineerConfigurator(editor.Configuration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerConfigurator()