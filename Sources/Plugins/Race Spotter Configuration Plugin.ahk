;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter Configuration      ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceSpotterConfigurator                                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global rspSimulatorDropDown

global rspLearningLapsEdit
global rspLapsConsideredEdit
global rspDampingFactorEdit

class RaceSpotterConfigurator extends ConfigurationItem {
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
		
		RaceSpotterConfigurator.Instance := this
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
		
		w2 := w1 - 24
		x4 := x1 + w2 + 1
		
		Gui %window%:Add, Text, x%x0% y%y% w105 h23 +0x200 HWNDwidget1 Hidden, % translate("Simulator")
		
		if (this.Simulators.Length() = 0)
			this.iSimulators := this.getSimulators()
		
 		choices := this.iSimulators
		chosen := (choices.Length() > 0) ? 1 : 0
		
		Gui %window%:Add, DropDownList, x%x1% yp w%w1% Choose%chosen% gchooseRaceSpotterSimulator vrspSimulatorDropDown HWNDwidget2 Hidden, % values2String("|", choices*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x%x% yp+40 w%width% h96 HWNDwidget3 Hidden, % translate("Data Analysis")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x0% yp+17 w80 h23 +0x200 HWNDwidget4 Hidden, % translate("Learn for")
		Gui %window%:Add, Edit, x%x1% yp w40 h21 Number vrspLearningLapsEdit HWNDwidget5 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget6 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp w%w3% h23 +0x200 HWNDwidget7 Hidden, % translate("Laps after Start or Pitstop")
		
		Gui %window%:Add, Text, x%x0% yp+26 w105 h20 Section HWNDwidget8 Hidden, % translate("Statistical Window")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h21 Number vrspLapsConsideredEdit HWNDwidget9 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget10 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp+2 w80 h20 HWNDwidget11 Hidden, % translate("Laps")
		
		Gui %window%:Add, Text, x%x0% ys+24 w105 h20 Section HWNDwidget12 Hidden, % translate("Damping Factor")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h21 vrspDampingFactorEdit HWNDwidget13 Hidden
		Gui %window%:Add, Text, x%x3% yp+2 w80 h20 HWNDwidget14 Hidden, % translate("p. Lap")
		
		Loop 14
			editor.registerWidget(this, widget%A_Index%)
		
		this.loadSimulatorConfiguration()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		if (this.Simulators.Length() = 0)
			this.iSimulators := this.getSimulators()
		
		for ignore, simulator in this.Simulators {
			simulatorConfiguration := {}
		
			simulatorConfiguration["LearningLaps"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulator . ".HistoryLapsDamping", 0.2)
			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		this.saveSimulatorConfiguration()
		
		for simulator, simulatorConfiguration in this.iSimulatorConfigurations
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping"]
				setConfigurationValue(configuration, "Race Spotter Analysis", simulator . "." . key, simulatorConfiguration[key])
	}
	
	loadConfigurator(configuration, simulators) {
		this.loadFromConfiguration(configuration)
		
		this.setSimulators(simulators)
	}
	
	loadSimulatorConfiguration(simulator := false) {
		window := this.Editor.Window
		
		Gui %window%:Default
		
		if simulator {
			rspSimulatorDropDown := simulator
			
			GuiControl Choose, rspSimulatorDropDown, % inList(this.iSimulators, simulator)
		}	
		else
			GuiControlGet rspSimulatorDropDown
			
		this.iCurrentSimulator := rspSimulatorDropDown
		
		if this.iSimulatorConfigurations.HasKey(rspSimulatorDropDown) {
			configuration := this.iSimulatorConfigurations[rspSimulatorDropDown]
			
			GuiControl Text, rspLearningLapsEdit, % configuration["LearningLaps"]
			GuiControl Text, rspLapsConsideredEdit, % configuration["ConsideredHistoryLaps"]
			GuiControl Text, rspDampingFactorEdit, % configuration["HistoryLapsDamping"]
		}
	}
	
	saveSimulatorConfiguration() {
		window := this.Editor.Window
		
		Gui %window%:Default
		
		if this.iCurrentSimulator {
			GuiControlGet rspLearningLapsEdit
			GuiControlGet rspLapsConsideredEdit
			GuiControlGet rspDampingFactorEdit
			
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]
			
			configuration["LearningLaps"] := rspLearningLapsEdit
			configuration["ConsideredHistoryLaps"] := rspLapsConsideredEdit
			configuration["HistoryLapsDamping"] := rspDampingFactorEdit
		}
	}
	
	setSimulators(simulators) {
		window := this.Editor.Window
		
		Gui %window%:Default
		
		this.iSimulators := simulators
		
		GuiControl, , rspSimulatorDropDown, % "|" . values2String("|", simulators*)
		
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

chooseRaceSpotterSimulator() {
	configurator := RaceSpotterConfigurator.Instance
	
	configurator.saveSimulatorConfiguration()
	configurator.loadSimulatorConfiguration()
}

initializeRaceSpotterConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
	
		editor.registerConfigurator(translate("Race Spotter"), new RaceSpotterConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterConfigurator()