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

global sideProximityDropDown
global rearProximityDropDown
global yellowFlagsDropDown
global blueFlagsDropDown
global sessionInformationDropDown
global deltaInformationDropDown
global deltaInformationMethodDropDown
global tacticalAdvicesDropDown
global pitWindowDropDown

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
		local window := editor.Window
		local x0, x1, x2, x3, x4, x5, x6, w1, w2, w3, w4, choices, chosen

		Gui %window%:Font, Norm, Arial

		x0 := x + 8
		x1 := x + 132
		x2 := x + 172
		x3 := x + 176

		w1 := width - (x1 - x + 8)
		w3 := width - (x3 - x + 16) + 10

		w2 := w1 - 24
		x4 := x1 + w2 + 1

		w4 := w1 - 24
		x6 := x1 + w4 + 1

		Gui %window%:Add, Text, x%x0% y%y% w120 h23 +0x200 HWNDwidget1 Hidden, % translate("Simulator")

		if (this.Simulators.Length() = 0)
			this.iSimulators := this.getSimulators()

 		choices := this.iSimulators
		chosen := (choices.Length() > 0) ? 1 : 0

		Gui %window%:Add, DropDownList, x%x1% yp w%w4% Choose%chosen% gchooseRaceSpotterSimulator vrspSimulatorDropDown HWNDwidget2 Hidden, % values2String("|", choices*)

		Gui %window%:Add, Button, x%x6% yp w23 h23 Center +0x200 greplicateRSPSettings HWNDwidget31 Hidden
		setButtonIcon(widget31, kIconsDirectory . "Renew.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x%x% yp+40 w%width% h96 HWNDwidget3 Hidden, % translate("Data Analysis")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x0% yp+17 w80 h23 +0x200 HWNDwidget4 Hidden, % translate("Learn for")
		Gui %window%:Add, Edit, x%x1% yp w40 h21 Number vrspLearningLapsEdit HWNDwidget5 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget6 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp w%w3% h23 +0x200 HWNDwidget7 Hidden, % translate("Laps after Start or Pitstop")

		Gui %window%:Add, Text, x%x0% yp+26 w120 h20 Section HWNDwidget8 Hidden, % translate("Statistical Window")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h21 Number vrspLapsConsideredEdit HWNDwidget9 Hidden
		Gui %window%:Add, UpDown, x%x2% yp w17 h21 HWNDwidget10 Hidden, 1
		Gui %window%:Add, Text, x%x3% yp+2 w80 h20 HWNDwidget11 Hidden, % translate("Laps")

		Gui %window%:Add, Text, x%x0% ys+24 w120 h20 Section HWNDwidget12 Hidden, % translate("Damping Factor")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h21 vrspDampingFactorEdit gvalidateRSPDampingFactor HWNDwidget13 Hidden
		Gui %window%:Add, Text, x%x3% yp+2 w80 h20 HWNDwidget14 Hidden, % translate("p. Lap")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x%x% yp+35 w%width% h155 HWNDwidget15 Hidden, % translate("Announcements")

		Gui %window%:Font, Norm, Arial

		x3 := x + 186
		w3 := width - (x3 - x + 16) + 10
		x5 := x1 + 72

		Gui %window%:Add, Text, x%x0% yp+20 w120 h20 Section HWNDwidget16 Hidden, % translate("Side / Rear Proximity")
		Gui %window%:Add, DropDownList, x%x1% yp-4 w70 AltSubmit Choose1 vsideProximityDropDown HWNDwidget17 Hidden, % values2String("|", translate("Off"), translate("On"))
		Gui %window%:Add, DropDownList, x%x5% yp w70 AltSubmit Choose1 vrearProximityDropDown HWNDwidget18 Hidden, % values2String("|", translate("Off"), translate("On"))

		Gui %window%:Add, Text, x%x0% yp+26 w120 h20 Section HWNDwidget19 Hidden, % translate("Yellow / Blue Flags")
		Gui %window%:Add, DropDownList, x%x1% yp-4 w70 AltSubmit Choose1 vyellowFlagsDropDown HWNDwidget20 Hidden, % values2String("|", translate("Off"), translate("On"))
		Gui %window%:Add, DropDownList, x%x5% yp w70 AltSubmit Choose1 vblueFlagsDropDown HWNDwidget21 Hidden, % values2String("|", translate("Off"), translate("On"))

		Gui %window%:Add, Text, x%x0% yp+26 w120 h20 Section HWNDwidget22 Hidden, % translate("Pit Window")
		Gui %window%:Add, DropDownList, x%x1% yp-4 w70 AltSubmit Choose1 vpitWindowDropDown HWNDwidget23 Hidden, % values2String("|", translate("Off"), translate("On"))

		Gui %window%:Add, Text, x%x0% yp+26 w120 h20 Section HWNDwidget24 Hidden, % translate("General Information")
		Gui %window%:Add, DropDownList, x%x1% yp-4 w70 AltSubmit Choose1 vsessionInformationDropDown HWNDwidget25 Hidden, % values2String("|", translate("Off"), translate("On"))

		Gui %window%:Add, Text, x%x0% yp+26 w120 h20 Section HWNDwidget26 Hidden, % translate("Opponent Infos every")
		Gui %window%:Add, DropDownList, x%x1% yp-4 w70 AltSubmit Choose3 vdeltaInformationDropDown HWNDwidget27 Hidden, % values2String("|", translate("Off"), translate("Sector"), translate("Lap"), translate("2 Laps"), translate("3 Laps"), translate("4 Laps"))
		Gui %window%:Add, DropDownList, x%x5% yp w70 AltSubmit Choose1 vdeltaInformationMethodDropDown HWNDwidget30 Hidden, % values2String("|", translate("Static"), translate("Dynamic"), translate("Both"))

		Gui %window%:Add, Text, x%x0% yp+26 w120 h20 Section HWNDwidget28 Hidden, % translate("Tactical Advices")
		Gui %window%:Add, DropDownList, x%x1% yp-4 w70 AltSubmit Choose1 vtacticalAdvicesDropDown HWNDwidget29 Hidden, % values2String("|", translate("Off"), translate("On"))

		Gui %window%:Font, Norm, Arial

		loop 31
			editor.registerWidget(this, widget%A_Index%)

		this.loadSimulatorConfiguration()
	}

	loadFromConfiguration(configuration) {
		local ignore, simulator, simulatorConfiguration, key, default

		base.loadFromConfiguration(configuration)

		if (this.Simulators.Length() = 0)
			this.iSimulators := this.getSimulators()

		for ignore, simulator in this.Simulators {
			simulatorConfiguration := {}

			simulatorConfiguration["LearningLaps"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulator . ".HistoryLapsDamping", 0.2)

			for ignore, key in ["SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
							  , "SessionInformation", "TacticalAdvices", "PitWindow"]
				simulatorConfiguration[key] := getConfigurationValue(configuration, "Race Spotter Announcements", simulator . "." . key, true)

			default := getConfigurationValue(configuration, "Race Spotter Announcements", simulator . ".PerformanceUpdates", 2)
			default := getConfigurationValue(configuration, "Race Spotter Announcements", simulator . ".DistanceInformation", default)

			simulatorConfiguration["DeltaInformation"] := getConfigurationValue(configuration, "Race Spotter Announcements"
																			  , simulator . ".DeltaInformation", default)
			simulatorConfiguration["DeltaInformationMethod"] := getConfigurationValue(configuration, "Race Spotter Announcements"
																					, simulator . ".DeltaInformationMethod", "Both")

			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local simulator, simulatorConfiguration, ignore, key

		base.saveToConfiguration(configuration)

		this.saveSimulatorConfiguration()

		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping"]
				setConfigurationValue(configuration, "Race Spotter Analysis", simulator . "." . key, simulatorConfiguration[key])

			for ignore, key in ["SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
							  , "SessionInformation", "DeltaInformation", "DeltaInformationMethod", "TacticalAdvices", "PitWindow"]
				setConfigurationValue(configuration, "Race Spotter Announcements", simulator . "." . key, simulatorConfiguration[key])
		}
	}

	loadConfigurator(configuration, simulators) {
		this.loadFromConfiguration(configuration)

		this.setSimulators(simulators)
	}

	loadSimulatorConfiguration(simulator := false) {
		local window := this.Editor.Window
		local configuration

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

			rspDampingFactorEdit := configuration["HistoryLapsDamping"]
			GuiControl Text, rspDampingFactorEdit, %rspDampingFactorEdit%

			GuiControl Choose, sideProximityDropDown, % (configuration["SideProximity"] + 1)
			GuiControl Choose, rearProximityDropDown, % (configuration["RearProximity"] + 1)
			GuiControl Choose, yellowFlagsDropDown, % (configuration["YellowFlags"] + 1)
			GuiControl Choose, blueFlagsDropDown, % (configuration["BlueFlags"] + 1)
			GuiControl Choose, sessionInformationDropDown, % (configuration["SessionInformation"] + 1)

			if (!configuration["DeltaInformation"])
				GuiControl Choose, deltaInformationDropDown, 1
			else if (configuration["DeltaInformation"] = "S")
				GuiControl Choose, deltaInformationDropDown, 2
			else
				GuiControl Choose, deltaInformationDropDown, % (configuration["DeltaInformation"] + 2)

			GuiControl Choose, deltaInformationMethodDropDown, % inList(["Static", "Dynamic", "Both"], configuration["DeltaInformationMethod"])

			GuiControl Choose, tacticalAdvicesDropDown, % (configuration["TacticalAdvices"] + 1)
			GuiControl Choose, pitWindowDropDown, % (configuration["PitWindow"] + 1)
		}
	}

	saveSimulatorConfiguration() {
		local window := this.Editor.Window
		local configuration

		Gui %window%:Default

		if this.iCurrentSimulator {
			GuiControlGet rspLearningLapsEdit
			GuiControlGet rspLapsConsideredEdit
			GuiControlGet rspDampingFactorEdit

			GuiControlGet sideProximityDropDown
			GuiControlGet rearProximityDropDown
			GuiControlGet yellowFlagsDropDown
			GuiControlGet blueFlagsDropDown
			GuiControlGet sessionInformationDropDown
			GuiControlGet deltaInformationDropDown
			GuiControlGet deltaInformationMethodDropDown
			GuiControlGet tacticalAdvicesDropDown
			GuiControlGet pitWindowDropDown

			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			configuration["LearningLaps"] := rspLearningLapsEdit
			configuration["ConsideredHistoryLaps"] := rspLapsConsideredEdit
			configuration["HistoryLapsDamping"] := rspDampingFactorEdit

			configuration["SideProximity"] := (sideProximityDropDown - 1)
			configuration["RearProximity"] := (rearProximityDropDown - 1)
			configuration["YellowFlags"] := (yellowFlagsDropDown - 1)
			configuration["BlueFlags"] := (blueFlagsDropDown - 1)
			configuration["SessionInformation"] := (sessionInformationDropDown - 1)

			if (deltaInformationDropDown == 1)
				configuration["DeltaInformation"] := false
			else if (deltaInformationDropDown == 2)
				configuration["DeltaInformation"] := "S"
			else
				configuration["DeltaInformation"] := (deltaInformationDropDown - 2)

			configuration["DeltaInformationMethod"] := ["Static", "Dynamic", "Both"][deltaInformationMethodDropDown]

			configuration["TacticalAdvices"] := (tacticalAdvicesDropDown - 1)
			configuration["PitWindow"] := (pitWindowDropDown - 1)
		}
	}

	setSimulators(simulators) {
		local window := this.Editor.Window

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

	replicateSettings() {
		local configuration, simulator, simulatorConfiguration

		this.saveSimulatorConfiguration()

		configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

		for simulator, simulatorConfiguration in this.iSimulatorConfigurations
			if (simulator != this.iCurrentSimulator)
				for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping"
								  , "SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
								  , "SessionInformation", "DeltaInformation", "DeltaInformationMethod", "TacticalAdvices", "PitWindow"]
					simulatorConfiguration[key] := configuration[key]
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

replicateRSPSettings() {
	RaceSpotterConfigurator.Instance.replicateSettings()
}

validateRSPDampingFactor() {
	local oldValue := rspDampingFactorEdit

	GuiControlGet rspDampingFactorEdit

	if rspDampingFactorEdit is not Number
	{
		rspDampingFactorEdit := oldValue

		GuiControl, , rspDampingFactorEdit, %rspDampingFactorEdit%
	}
}

chooseRaceSpotterSimulator() {
	local configurator := RaceSpotterConfigurator.Instance

	configurator.saveSimulatorConfiguration()
	configurator.loadSimulatorConfiguration()
}

initializeRaceSpotterConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Race Spotter"), new RaceSpotterConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterConfigurator()