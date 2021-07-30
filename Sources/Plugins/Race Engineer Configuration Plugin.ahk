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

global reSimulatorDropDown

global reLoadSettingsDropDown
global reLoadTyrePressuresDropDown
global reSaveSettingsDropDown
global reSaveTyrePressuresDropDown

global reLearningLapsEdit
global reLapsConsideredEdit
global reDampingFactorEdit

global reAdjustLapTimeCheck
global reDamageAnalysisLapsEdit

class RaceEngineerConfigurator extends ConfigurationItem {
	iEditor := false
	
	iSimulatorConfigurations := {}
	iCurrentSimulator := false
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	__New(editor, configuration) {
		this.iEditor := editor
		
		base.__New(configuration)
		
		RaceEngineerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y80 w105 h23 +0x200 HWNDwidget1 Hidden, % translate("Simulator")
		
 		choices := this.getSimulators()
		chosen := (choices.Length() > 0) ? 1 : 0
		
		Gui %window%:Add, DropDownList, x156 y80 w307 Choose%chosen% gchooseRaceEngineerSimulator vreSimulatorDropDown HWNDwidget2 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y120 w458 h70 HWNDwidget3 Hidden, % translate("Settings (for all Race Assistants)")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y137 w160 h23 +0x200 HWNDwidget4 Hidden, % translate("@ Session Begin")
		choices := map(["Use values from previous Session", "Load from Setup Database"], "translate")
		Gui %window%:Add, DropDownList, x156 y137 w307 AltSubmit vreLoadSettingsDropDown HWNDwidget5 Hidden, % values2String("|", choices*)
		
		choices := map(["Ask", "Always save", "No action"], "translate")
		Gui %window%:Add, Text, x24 y161 w160 h23 +0x200 HWNDwidget6 Hidden, % translate("@ Session End")
		Gui %window%:Add, DropDownList, x156 y161 w140 AltSubmit vreSaveSettingsDropDown HWNDwidget7 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y196 w458 h70 HWNDwidget8 Hidden, % translate("Tyre Pressures")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y213 w160 h23 +0x200 HWNDwidget9 Hidden, % translate("@ Session Begin")
		choices := map(["Use Values from Settings", "Load from Setup Database", "Import from Simulator"], "translate")
		chosen := 1
		Gui %window%:Add, DropDownList, x156 y213 w307 AltSubmit Choose%chosen% vreLoadTyrePressuresDropDown HWNDwidget10 Hidden, % values2String("|", choices*)
		
		choices := map(["Ask", "Always save", "No action"], "translate")
		Gui %window%:Add, Text, x24 y237 w160 h23 +0x200 HWNDwidget11 Hidden, % translate("@ Session End")
		Gui %window%:Add, DropDownList, x156 y237 w140 AltSubmit vreSaveTyrePressuresDropDown HWNDwidget12 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y272 w458 h156 HWNDwidget13 Hidden, % translate("Data Analysis")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y289 w160 h23 +0x200 HWNDwidget14 Hidden, % translate("Learn for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number vreLearningLapsEdit HWNDwidget15 Hidden
		Gui %window%:Add, UpDown, x196 yp w17 h21 HWNDwidget16 Hidden, 1
		Gui %window%:Add, Text, x200 yp w260 h23 +0x200 HWNDwidget17 Hidden, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x24 yp+26 w105 h20 Section HWNDwidget18 Hidden, % translate("Statistical Window")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 Number vreLapsConsideredEdit HWNDwidget19 Hidden
		Gui %window%:Add, UpDown, x196 yp w17 h21 HWNDwidget20 Hidden, 1
		Gui %window%:Add, Text, x200 yp+2 w170 h20 HWNDwidget21 Hidden, % translate("Laps")
		
		Gui %window%:Add, Text, x24 ys+24 w105 h20 Section HWNDwidget22 Hidden, % translate("Damping Factor")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 vreDampingFactorEdit HWNDwidget23 Hidden
		Gui %window%:Add, Text, x200 yp+2 w170 h20 HWNDwidget24 Hidden, % translate("p. Lap")

		Gui %window%:Add, Text, x24 ys+30 w160 h23 +0x200 Section HWNDwidget25 Hidden, % translate("Adjust Lap Time")
		Gui %window%:Add, CheckBox, x156 yp w300 h23 VreAdjustLapTimeCheck HWNDwidget26 Hidden, % translate("for Start, Pitstop or imcomplete Laps (use from Settings)")
		
		Gui %window%:Add, Text, x24 ys+30 w160 h23 +0x200 Section HWNDwidget27 Hidden, % translate("Damage Analysis for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number VreDamageAnalysisLapsEdit HWNDwidget28 Hidden
		Gui %window%:Add, UpDown, x196 yp w17 h21 HWNDwidget29 Hidden, 1
		Gui %window%:Add, Text, x200 yp-2 w260 h23 +0x200 HWNDwidget30 Hidden, % translate("Laps after Incident")
		
		Loop 30
			editor.registerWidget(this, widget%A_Index%)
		
		this.loadSimulatorConfiguration()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		for ignore, simulator in this.getSimulators() {
			simulatorConfiguration := {}
		
			simulatorConfiguration["LoadSettings"] := getConfigurationValue(configuration, "Race Assistant Startup", simulator . ".LoadSettings", getConfigurationValue(configuration, "Race Engineer Startup", simulator . ".LoadSettings", "Default"))
			simulatorConfiguration["LoadTyrePressures"] := getConfigurationValue(configuration, "Race Engineer Startup", simulator . ".LoadTyrePressures", "Default")
		
			simulatorConfiguration["SaveSettings"] := getConfigurationValue(configuration, "Race Assistant Shutdown", simulator . ".SaveSettings", getConfigurationValue(configuration, "Race Engineer Shutdown", simulator . ".SaveSettings", "Never"))
			simulatorConfiguration["SaveTyrePressures"] := getConfigurationValue(configuration, "Race Engineer Shutdown", simulator . ".SaveTyrePressures", "Ask")
		
			simulatorConfiguration["LearningLaps"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".HistoryLapsDamping", 0.2)
			simulatorConfiguration["AdjustLapTime"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".AdjustLapTime", true)
			simulatorConfiguration["DamageAnalysisLaps"] := getConfigurationValue(configuration, "Race Engineer Analysis", simulator . ".DamageAnalysisLaps", 1)
								
			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		this.saveSimulatorConfiguration()
		
		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			for ignore, key in ["LoadSettings", "LoadTyrePressures"]
				setConfigurationValue(configuration, "Race Assistant Startup", simulator . "." . key, simulatorConfiguration[key])
			
			for ignore, key in ["SaveSettings", "SaveTyrePressures"]
				setConfigurationValue(configuration, "Race Assistant Shutdown", simulator . "." . key, simulatorConfiguration[key])
			
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping", "AdjustLapTime", "DamageAnalysisLaps"]
				setConfigurationValue(configuration, "Race Engineer Analysis", simulator . "." . key, simulatorConfiguration[key])
		}
	}
	
	loadSimulatorConfiguration() {
		GuiControlGet reSimulatorDropDown
		
		this.iCurrentSimulator := reSimulatorDropDown
		
		configuration := this.iSimulatorConfigurations[reSimulatorDropDown]
		
		GuiControl Choose, reLoadSettingsDropDown, % inList(["Default", "SetupDatabase"], configuration["LoadSettings"])
		GuiControl Choose, reLoadTyrePressuresDropDown, % inList(["Default", "SetupDatabase", "Import"], configuration["LoadTyrePressures"])
		
		GuiControl Choose, reSaveSettingsDropDown, % inList(["Ask", "Always", "Never"], configuration["SaveSettings"])
		GuiControl Choose, reSaveTyrePressuresDropDown, % inList(["Ask", "Always", "Never"], configuration["SaveTyrePressures"])
		
		GuiControl Text, reLearningLapsEdit, % configuration["LearningLaps"]
		GuiControl Text, reLapsConsideredEdit, % configuration["ConsideredHistoryLaps"]
		GuiControl Text, reDampingFactorEdit, % configuration["HistoryLapsDamping"]
		
		GuiControl, , reAdjustLapTimeCheck, % configuration["AdjustLapTime"]
		
		GuiControl Text, reDamageAnalysisLapsEdit, % configuration["DamageAnalysisLaps"]
	}
	
	saveSimulatorConfiguration() {
		if this.iCurrentSimulator {
			GuiControlGet reLoadSettingsDropDown
			GuiControlGet reLoadTyrePressuresDropDown
			GuiControlGet reSaveSettingsDropDown
			GuiControlGet reSaveTyrePressuresDropDown
			
			GuiControlGet reLearningLapsEdit
			GuiControlGet reLapsConsideredEdit
			GuiControlGet reDampingFactorEdit
			
			GuiControlGet reAdjustLapTimeCheck
			GuiControlGet reDamageAnalysisLapsEdit
			
			configuration := this.iSimulatorConfigurations[reSimulatorDropDown]
			
			configuration["LoadSettings"] := ["Default", "SetupDatabase"][reLoadSettingsDropDown]
			configuration["LoadTyrePressures"] := ["Default", "SetupDatabase", "Import"][reLoadTyrePressuresDropDown]
			
			configuration["SaveSettings"] := ["Ask", "Always", "Never"][reSaveSettingsDropDown]
			configuration["SaveTyrePressures"] := ["Ask", "Always", "Never"][reSaveTyrePressuresDropDown]
			
			configuration["LearningLaps"] := reLearningLapsEdit
			configuration["ConsideredHistoryLaps"] := reLapsConsideredEdit
			configuration["HistoryLapsDamping"] := reDampingFactorEdit
			
			configuration["AdjustLapTime"] := reAdjustLapTimeCheck
			
			configuration["DamageAnalysisLaps"] := reDamageAnalysisLapsEdit
		}
	}

	getSimulators() {
		return this.Editor.getSimulators()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

chooseRaceEngineerSimulator() {
	configurator := RaceEngineerConfigurator.Instance
	
	configurator.saveSimulatorConfiguration()
	configurator.loadSimulatorConfiguration()
}

initializeRaceEngineerConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		
		editor.registerConfigurator(translate("Race Engineer"), new RaceEngineerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerConfigurator()