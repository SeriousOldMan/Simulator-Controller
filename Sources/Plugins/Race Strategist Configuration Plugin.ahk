;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist Configuration   ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceStrategistConfigurator                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global rsSimulatorDropDown

global rsLearningLapsEdit
global rsLapsConsideredEdit
global rsDampingFactorEdit

class RaceStrategistConfigurator extends ConfigurationItem {
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
		
		RaceStrategistConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y80 w105 h23 +0x200 HWNDwidget1 Hidden, % translate("Simulator")
		
 		choices := this.getSimulators()
		chosen := (choices.Length() > 0) ? 1 : 0
		
		Gui %window%:Add, DropDownList, x156 y80 w307 Choose%chosen% gchooseRaceStrategistSimulator vrsSimulatorDropDown HWNDwidget2 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y120 w458 h96 HWNDwidget3 Hidden, % translate("Data Analysis")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y137 w160 h23 +0x200 HWNDwidget4 Hidden, % translate("Learn for")
		Gui %window%:Add, Edit, x156 yp w40 h21 Number vrsLearningLapsEdit HWNDwidget5 Hidden
		Gui %window%:Add, UpDown, x196 yp w17 h21 HWNDwidget6 Hidden, 1
		Gui %window%:Add, Text, x200 yp w260 h23 +0x200 HWNDwidget7 Hidden, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x24 yp+26 w105 h20 Section HWNDwidget8 Hidden, % translate("Statistical Window")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 Number vrsLapsConsideredEdit HWNDwidget9 Hidden
		Gui %window%:Add, UpDown, x196 yp w17 h21 HWNDwidget10 Hidden, 1
		Gui %window%:Add, Text, x200 yp+2 w170 h20 HWNDwidget11 Hidden, % translate("Laps")
		
		Gui %window%:Add, Text, x24 ys+24 w105 h20 Section HWNDwidget12 Hidden, % translate("Damping Factor")
		Gui %window%:Add, Edit, x156 yp-2 w40 h21 vrsDampingFactorEdit HWNDwidget13 Hidden
		Gui %window%:Add, Text, x200 yp+2 w170 h20 HWNDwidget14 Hidden, % translate("p. Lap")
		
		Loop 14
			editor.registerWidget(this, widget%A_Index%)
		
		this.loadSimulatorConfiguration()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		for ignore, simulator in this.getSimulators() {
			simulatorConfiguration := {}
		
			simulatorConfiguration["LearningLaps"] := getConfigurationValue(configuration, "Race Strategist Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getConfigurationValue(configuration, "Race Strategist Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getConfigurationValue(configuration, "Race Strategist Analysis", simulator . ".HistoryLapsDamping", 0.2)
								
			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		this.saveSimulatorConfiguration()
		
		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping"]
				setConfigurationValue(configuration, "Race Strategist Analysis", simulator . "." . key, simulatorConfiguration[key])
		}
	}
	
	loadSimulatorConfiguration() {
		GuiControlGet rsSimulatorDropDown
		
		this.iCurrentSimulator := rsSimulatorDropDown
		
		configuration := this.iSimulatorConfigurations[rsSimulatorDropDown]
		
		GuiControl Text, rsLearningLapsEdit, % configuration["LearningLaps"]
		GuiControl Text, rsLapsConsideredEdit, % configuration["ConsideredHistoryLaps"]
		GuiControl Text, rsDampingFactorEdit, % configuration["HistoryLapsDamping"]
	}
	
	saveSimulatorConfiguration() {
		if this.iCurrentSimulator {
			GuiControlGet rsLearningLapsEdit
			GuiControlGet rsLapsConsideredEdit
			GuiControlGet rsDampingFactorEdit
			
			configuration := this.iSimulatorConfigurations[rsSimulatorDropDown]
			
			configuration["LearningLaps"] := rsLearningLapsEdit
			configuration["ConsideredHistoryLaps"] := rsLapsConsideredEdit
			configuration["HistoryLapsDamping"] := rsDampingFactorEdit
		}
	}

	getSimulators() {
		return this.Editor.getSimulators()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

chooseRaceStrategistSimulator() {
	configurator := RaceStrategistConfigurator.Instance
	
	configurator.saveSimulatorConfiguration()
	configurator.loadSimulatorConfiguration()
}

initializeRaceStrategistConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
	
		editor.registerConfigurator(translate("Race Strategist"), new RaceStrategistConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistConfigurator()