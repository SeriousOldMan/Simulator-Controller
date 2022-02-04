;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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
	
	iSimulators := []
	iSimulatorConfigurations := {}
	iCurrentSimulator := false
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	Simulators[] {
		Get {
			return this.iSimulators
		}
	}
	
	__New(editor, configuration := false) {
		this.iEditor := editor
		
		base.__New(configuration)
		
		RaceEngineerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		x0 := x + 8
		x1 := x + 132
		x2 := x + 172
		x3 := x + 176
		
		w1 := width - (x1 - x + 8)
		w3 := width - (x3 - x + 16) + 10
		
		Gui %window%:Add, Text, x%x0% y%y% w105 h23 +0x200 HWNDwidget1 Hidden, % translate("Simulator")
		
		if (this.Simulators.Length() = 0)
			this.iSimulators := this.getSimulators()
		
 		choices := this.iSimulators
		chosen := (choices.Length() > 0) ? 1 : 0
		
		Gui %window%:Add, DropDownList, x%x1% y%y% w%w1% Choose%chosen% gchooseRaceEngineerSimulator vreSimulatorDropDown HWNDwidget2 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x%x% yp+40 w%width% h70 HWNDwidget3 Hidden, % translate("Settings (for all Race Assistants)")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x0% yp+17 w120 h23 +0x200 HWNDwidget4 Hidden, % translate("@ Session Begin")
		choices := map(["Use values from previous Session", "Load from Setup Database"], "translate")
		Gui %window%:Add, DropDownList, x%x1% yp w%w1% AltSubmit vreLoadSettingsDropDown HWNDwidget5 Hidden, % values2String("|", choices*)
		
		choices := map(["Ask", "Always save", "No action"], "translate")
		Gui %window%:Add, Text, x%x0% yp+24 w120 h23 +0x200 HWNDwidget6 Hidden, % translate("@ Session End")
		Gui %window%:Add, DropDownList, x%x1% yp w140 AltSubmit vreSaveSettingsDropDown HWNDwidget7 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x%x% yp+35 w%width% h70 HWNDwidget8 Hidden, % translate("Tyre Pressures")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x0% yp+17 w120 h23 +0x200 HWNDwidget9 Hidden, % translate("@ Session Begin")
		choices := map(["Use Values from Settings", "Load from Setup Database", "Import from Simulator"], "translate")
		chosen := 1
		Gui %window%:Add, DropDownList, x%x1% yp w%w1% AltSubmit Choose%chosen% vreLoadTyrePressuresDropDown HWNDwidget10 Hidden, % values2String("|", choices*)
		
		choices := map(["Ask", "Always save", "No action"], "translate")
		Gui %window%:Add, Text, x%x0% yp+24 w120 h23 +0x200 HWNDwidget11 Hidden, % translate("@ Session End")
		Gui %window%:Add, DropDownList, x%x1% yp w140 AltSubmit vreSaveTyrePressuresDropDown HWNDwidget12 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x%x% yp+35 w%width% h156 HWNDwidget13 Hidden, % translate("Data Analysis")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x0% yp+17 w80 h23 +0x200 HWNDwidget14 Hidden, % translate("Learn for")
		Gui %window%:Add, Edit, x%x1% yp w40 h21 Number vreLearningLapsEdit HWNDwidget15 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget16 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp w%w3% h23 +0x200 HWNDwidget17 Hidden, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x%x0% yp+26 w105 h20 Section HWNDwidget18 Hidden, % translate("Statistical Window")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h21 Number vreLapsConsideredEdit HWNDwidget19 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget20 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp+2 w%w3% h20 HWNDwidget21 Hidden, % translate("Laps")
		
		Gui %window%:Add, Text, x%x0% ys+24 w105 h20 Section HWNDwidget22 Hidden, % translate("Damping Factor")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h21 vreDampingFactorEdit HWNDwidget23 Hidden
		Gui %window%:Add, Text, x%x3% yp+2 w%w3% h20 HWNDwidget24 Hidden, % translate("p. Lap")

		Gui %window%:Add, Text, x%x0% ys+30 w160 h23 +0x200 Section HWNDwidget25 Hidden, % translate("Adjust Lap Time")
		Gui %window%:Add, CheckBox, x%x1% yp w%w1% h23 VreAdjustLapTimeCheck HWNDwidget26 Hidden, % translate("for Start, Pitstop or imcomplete Laps (use from Settings)")
		
		Gui %window%:Add, Text, x%x0% ys+30 w120 h23 +0x200 Section HWNDwidget27 Hidden, % translate("Damage Analysis for")
		Gui %window%:Add, Edit, x%x1% yp w40 h21 Number VreDamageAnalysisLapsEdit HWNDwidget28 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget29 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp-2 w%w3% h23 +0x200 HWNDwidget30 Hidden, % translate("Laps after Incident")
		
		Loop 30
			editor.registerWidget(this, widget%A_Index%)
		
		this.loadSimulatorConfiguration()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		if (this.Simulators.Length() = 0)
			this.iSimulators := this.getSimulators()
			
		for ignore, simulator in this.Simulators {
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
			setConfigurationValue(configuration, "Race Assistant Startup", simulator . "." . "LoadSettings", simulatorConfiguration["LoadSettings"])
			setConfigurationValue(configuration, "Race Assistant Shutdown", simulator . "." . "SaveSettings", simulatorConfiguration["SaveSettings"])
		
			setConfigurationValue(configuration, "Race Engineer Startup", simulator . "." . "LoadTyrePressures", simulatorConfiguration["LoadTyrePressures"])
			setConfigurationValue(configuration, "Race Engineer Shutdown", simulator . "." . "SaveTyrePressures", simulatorConfiguration["SaveTyrePressures"])
			
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping", "AdjustLapTime", "DamageAnalysisLaps"]
				setConfigurationValue(configuration, "Race Engineer Analysis", simulator . "." . key, simulatorConfiguration[key])
		}
	}
	
	loadConfigurator(configuration, simulators) {
		this.loadFromConfiguration(configuration)
		
		this.setSimulators(simulators)
	}
	
	loadSimulatorConfiguration(simulator := false) {
		window := this.Editor.Window
		
		Gui %window%:Default
		
		if simulator {
			reSimulatorDropDown := simulator
			
			GuiControl Choose, reSimulatorDropDown, % inList(this.iSimulators, simulator)
		}	
		else
			GuiControlGet reSimulatorDropDown
		
		this.iCurrentSimulator := reSimulatorDropDown
		
		if this.iSimulatorConfigurations.HasKey(reSimulatorDropDown) {
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
	}
	
	saveSimulatorConfiguration() {
		window := this.Editor.Window
		
		Gui %window%:Default
		
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
			
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]
			
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
	
	setSimulators(simulators) {
		window := this.Editor.Window
		
		Gui %window%:Default
		
		this.iSimulators := simulators
		
		GuiControl, , reSimulatorDropDown, % "|" . values2String("|", simulators*)
		
		if (simulators.Length() > 0) {
			this.loadFromConfiguration(this.Configuration)
			
			this.loadSimulatorConfiguration(simulators[1])
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