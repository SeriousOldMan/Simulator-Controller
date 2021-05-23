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
		
		Gui %window%:Add, GroupBox, x16 y110 w458 h70, % translate("Startup")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y127 w160 h23 +0x200, % translate("Settings")
		choices := ["Use values from previous session", "Load from Setup Database"]
		chosen := 1
		Gui %window%:Add, DropDownList, x156 y127 w307 Choose%chosen%, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x24 y151 w160 h23 +0x200, % translate("Tyre Pressures")
		choices := ["Use Values from Settings", "Load from Setup Database", "Import from Simulator"]
		chosen := 1
		Gui %window%:Add, DropDownList, x156 y151 w307 Choose%chosen%, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y186 w458 h70, % translate("Shutdown")
		
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
		
		Gui %window%:Add, GroupBox, x16 y262 w458 h95, % translate("Calculation Strategies")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y279 w160 h23 +0x200, % translate("Learning")
		Gui %window%:Add, Edit, x156 y279 w40 h21 Number ; VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x196 y279 w17 h21, 1
		Gui %window%:Add, Text, x200 y279 w160 h23 +0x200, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x24 y303 w160 h23 +0x200, % translate("Extrapolate Lap time")
		Gui %window%:Add, CheckBox, x156 y303 w300 h23, % translate("for Start, Pitstop or imcomplete Laps (use from Settings)") ; Checked%startWithWindowsCheck% VstartWithWindowsCheck
		
		Gui %window%:Add, Text, x24 y327 w160 h23 +0x200, % translate("Damage Analysis")
		Gui %window%:Add, Edit, x156 y327 w40 h21 Number ; VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x196 y327 w17 h21, 1
		Gui %window%:Add, Text, x200 y327 w160 h23 +0x200, % translate("Laps after incident")
		
		/*
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