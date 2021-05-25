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

global simulatorDropDown

global loadSettingsDropDown
global loadTyrePressuresDropDown
global saveSettingsDropDown
global saveTyrePressuresDropDown

global learningLapsEdit
global lapsConsideredEdit
global dampingFactorEdit

global adjustLapTimesCheck
global damageAnalysisLapsEdit

class RaceEngineerConfigurator extends ConfigurationItem {
	iSimulatorConfigurations := {}
	iCurrentSimulator := false
	
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
		
		Gui %window%:Add, DropDownList, x156 y80 w307 Choose%chosen% gchooseSimulator vsimulatorDropDown, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y120 w458 h70, % translate("Session Begin")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y137 w160 h23 +0x200, % translate("Settings")
		choices := map(["Use values from previous Session", "Load from Setup Database"], "translate")
		Gui %window%:Add, DropDownList, x156 y137 w307 AltSubmit vloadSettingsDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x24 y161 w160 h23 +0x200, % translate("Tyre Pressures")
		choices := map(["Use Values from Settings", "Load from Setup Database", "Import from Simulator"], "translate")
		chosen := 1
		Gui %window%:Add, DropDownList, x156 y161 w307 AltSubmit vloadTyrePressuresDropDown, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y196 w458 h70, % translate("Session End")
		
		Gui %window%:Font, Norm, Arial
		
		choices := map(["Ask", "Always", "Never"], "translate")
		Gui %window%:Add, Text, x24 y213 w160 h23 +0x200, % translate("Save Settings")
		Gui %window%:Add, DropDownList, x156 y213 w140 AltSubmit vsaveSettingsDropDown, % values2String("|", choices*)
		
		choices := map(["Ask", "Always", "Never"], "translate")
		Gui %window%:Add, Text, x24 y237 w160 h23 +0x200, % translate("Save Tyre Pressures")
		Gui %window%:Add, DropDownList, x156 y237 w140 AltSubmit vsaveTyrePressuresDropDown, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y272 w458 h156, % translate("Data Analysis")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y289 w160 h23 +0x200, % translate("Learn for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number vlearningLapsEdit
		Gui %window%:Add, UpDown, x196 yp w17 h21, 1
		Gui %window%:Add, Text, x200 yp w260 h23 +0x200, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x24 yp+26 w105 h20 Section, % translate("Statistical Window")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 Number vlapsConsideredEdit
		Gui %window%:Add, UpDown, x196 yp w17 h21, 1
		Gui %window%:Add, Text, x200 yp+2 w170 h20, % translate("Laps")
		
		Gui %window%:Add, Text, x24 ys+24 w105 h20 Section, % translate("Damping Factor")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 vdampingFactorEdit
		Gui %window%:Add, Text, x200 yp+2 w170 h20, % translate("p. Lap")

		Gui %window%:Add, Text, x24 ys+30 w160 h23 +0x200 Section, % translate("Adjust Lap Time")
		Gui %window%:Add, CheckBox, x156 yp w300 h23 VadjustLapTimesCheck, % translate("for Start, Pitstop or imcomplete Laps (use from Settings)")
		
		Gui %window%:Add, Text, x24 ys+30 w160 h23 +0x200 Section, % translate("Damage Analysis for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number VdamageAnalysisLapsEdit
		Gui %window%:Add, UpDown, x196 yp w17 h21, 1
		Gui %window%:Add, Text, x200 yp-2 w260 h23 +0x200, % translate("Laps after Incident")
		
		this.loadSimulatorConfiguration()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		for ignore, simulator in this.getSimulators() {
			simulatorConfiguration := {}
		
			simulatorConfiguration["LoadSettings"] := getConfigurationValue(configuration, "Race Engineer Startup", simulator . ".LoadSettings", "Default")
			simulatorConfiguration["LoadTyrePressures"] := getConfigurationValue(configuration, "Race Engineer Startup", simulator . ".LoadTyrePressures", "Default")
		
			simulatorConfiguration["SaveSettings"] := getConfigurationValue(configuration, "Race Engineer Shutdown", simulator . ".SaveSettings", "Never")
			simulatorConfiguration["SaveTyrePressures"] := getConfigurationValue(configuration, "Race Engineer Shutdown", simulator . ".SaveTyrePressures", "Ask")
		
			simulatorConfiguration["LearningLaps"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".HistoryLapsDamping", 0.2)
			simulatorConfiguration["AdjustLapTimes"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".AdjustLapTimes", true)
			simulatorConfiguration["DamageAnalysisLaps"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".DamageAnalysisLaps", 1)
								
			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		this.saveSimulatorConfiguration()
		
		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			for ignore, key in ["LoadSettings", "LoadTyrePressures"]
				setConfigurationValue(configuration, "Race Engineer Startup", simulator . "." . key, simulatorConfiguration[key])
			
			for ignore, key in ["SaveSettings", "SaveTyrePressures"]
				setConfigurationValue(configuration, "Race Engineer Shutdown", simulator . "." . key, simulatorConfiguration[key])
			
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping", "AdjustLapTimes", "DamageAnalysisLaps"]
				setConfigurationValue(configuration, "Race Engineer Analysis", simulator . "." . key, simulatorConfiguration[key])
		}
	}
	
	loadSimulatorConfiguration() {
		GuiControlGet simulatorDropDown
		
		this.iCurrentSimulator := simulatorDropDown
		
		configuration := this.iSimulatorConfigurations[simulatorDropDown]
		
		GuiControl Choose, loadSettingsDropDown, % inList(["Default", "SetupDatabase"], configuration["LoadSettings"])
		GuiControl Choose, loadTyrePressuresDropDown, % inList(["Default", "SetupDatabase", "Import"], configuration["LoadTyrePressures"])
		
		GuiControl Choose, saveSettingsDropDown, % inList(["Ask", "Always", "Never"], configuration["SaveSettings"])
		GuiControl Choose, saveTyrePressuresDropDown, % inList(["Ask", "Always", "Never"], configuration["SaveTyrePressures"])
		
		GuiControl Text, learningLapsEdit, % configuration["LearningLaps"]
		GuiControl Text, lapsConsideredEdit, % configuration["ConsideredHistoryLaps"]
		GuiControl Text, dampingFactorEdit, % configuration["HistoryLapsDamping"]
		
		GuiControl, , adjustLapTimesCheck, % configuration["AdjustLapTimes"]
		
		GuiControl Text, damageAnalysisLapsEdit, % configuration["DamageAnalysisLaps"]
	}
	
	saveSimulatorConfiguration() {
		if this.iCurrentSimulator {
			GuiControlGet loadSettingsDropDown
			GuiControlGet loadTyrePressuresDropDown
			GuiControlGet saveSettingsDropDown
			GuiControlGet saveTyrePressuresDropDown
			
			GuiControlGet learningLapsEdit
			GuiControlGet lapsConsideredEdit
			GuiControlGet dampingFactorEdit
			
			GuiControlGet adjustLapTimesCheck
			GuiControlGet damageAnalysisLapsEdit
			
			configuration := this.iSimulatorConfigurations[simulatorDropDown]
			
			configuration["LoadSettings"] := ["Default", "SetupDatabase"][loadSettingsDropDown]
			configuration["LoadTyrePressures"] := ["Default", "SetupDatabase", "Import"][loadTyrePressuresDropDown]
			
			configuration["SaveSettings"] := ["Ask", "Always", "Never"][loadSettingsDropDown]
			configuration["SaveTyrePressures"] := ["Ask", "Always", "Never"][loadTyrePressuresDropDown]
			
			configuration["LearningLaps"] := learningLapsEdit
			configuration["ConsideredHistoryLaps"] := lapsConsideredEdit
			configuration["HistoryLapsDamping"] := dampingFactorEdit
			
			configuration["AdjustLapTimes"] := adjustLapTimesCheck
			
			configuration["DamageAnalysisLaps"] := damageAnalysisLapsEdit
		}
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

chooseSimulator() {
	configurator := RaceEngineerConfigurator.Instance
	
	configurator.saveSimulatorConfiguration()
	configurator.loadSimulatorConfiguration()
}

initializeRaceEngineerConfigurator() {
	editor := ConfigurationEditor.Instance
	
	editor.registerConfigurator(translate("Race Engineer"), new RaceEngineerConfigurator(editor.Configuration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerConfigurator()