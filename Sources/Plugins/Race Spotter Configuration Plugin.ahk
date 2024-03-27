;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter Configuration      ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceSpotterConfigurator                                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RaceSpotterConfigurator extends ConfiguratorPanel {
	iSimulators := []
	iSimulatorConfigurations := CaseInsenseMap()
	iCurrentSimulator := false

	Simulators {
		Get {
			return this.iSimulators
		}
	}

	__New(editor, configuration := false) {
		this.Editor := editor

		super.__New(configuration)

		RaceSpotterConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local x0, x1, x2, x3, x4, x5, x6, w1, w2, w3, w4, choices, chosen

		replicateRSPSettings(*) {
			this.replicateSettings()
		}

		validateRSPDampingFactor(*) {
			local field := this.Control["rspDampingFactorEdit"]

			if !isNumber(internalValue("Float", field.Text)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		chooseRaceSpotterSimulator(*) {
			this.saveSimulatorConfiguration()
			this.loadSimulatorConfiguration()
		}

		window.SetFont("Norm", "Arial")

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

		widget1 := window.Add("Text", "x" . x0 . " y" . y . " w120 h23 +0x200 Hidden", translate("Simulator"))

		if (this.Simulators.Length = 0)
			this.iSimulators := this.getSimulators()

 		choices := this.iSimulators
		chosen := (choices.Length > 0) ? 1 : 0

		widget2 := window.Add("DropDownList", "x" . x1 . " yp w" . w4 . " Choose" . chosen . " W:Grow vrspSimulatorDropDown Hidden", choices)
		widget2.OnEvent("Change", chooseRaceSpotterSimulator)

		widget3 := window.Add("Button", "x" . x6 . " yp w23 h23 X:Move Center +0x200  Hidden")
		widget3.OnEvent("Click", replicateRSPSettings)
		setButtonIcon(widget3, kIconsDirectory . "Renew.ico", 1, "L4 T4 R4 B4")

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget4 := window.Add("GroupBox", "x" . x . " yp+40 w" . width . " h96 W:Grow Hidden", translate("Data Analysis"))

		window.SetFont("Norm", "Arial")

		widget5 := window.Add("Text", "x" . x0 . " yp+17 w80 h23 +0x200 Hidden", translate("Learn for"))
		widget6 := window.Add("Edit", "x" . x1 . " yp w40 h21 Number Limit1 vrspLearningLapsEdit Hidden")
		widget7 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", 2)
		widget8 := window.Add("Text", "x" . x3 . " yp w" . w3 . " h23 +0x200 Hidden", translate("Laps after Start or Pitstop"))

		widget9 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Statistical Window"))
		widget10 := window.Add("Edit", "x" . x1 . " yp-2 w40 h21 Number Limit1 vrspLapsConsideredEdit Hidden", 5)
		widget11 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", 5)
		widget12 := window.Add("Text", "x" . x3 . " yp+2 w80 h20 Hidden", translate("Laps"))

		widget13 := window.Add("Text", "x" . x0 . " ys+24 w120 h20 Section Hidden", translate("Damping Factor"))
		widget14 := window.Add("Edit", "x" . x1 . " yp-2 w40 h21 vrspDampingFactorEdit Hidden", displayValue("Float", 0.2, 1))
		widget14.OnEvent("Change", validateRSPDampingFactor)
		widget15 := window.Add("Text", "x" . x3 . " yp+2 w80 h20 Hidden", translate("p. Lap"))

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget16 := window.Add("GroupBox", "x" . x . " yp+35 w" . width . " h278 W:Grow Hidden", translate("Announcements"))

		window.SetFont("Norm", "Arial")

		x3 := x + 186
		w3 := width - (x3 - x + 16) + 10
		x5 := x1 + 72

		widget17 := window.Add("Text", "x" . x0 . " yp+20 w120 h20 Section Hidden", translate("Side / Rear Proximity"))
		widget18 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vsideProximityDropDown Hidden", [translate("Off"), translate("On")])
		widget19 := window.Add("DropDownList", "x" . x5 . " yp w70 X:Move(0.1) W:Grow(0.1) Choose1 vrearProximityDropDown Hidden", [translate("Off"), translate("On")])

		widget20 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Yellow / Blue Flags"))
		widget21 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vyellowFlagsDropDown Hidden", [translate("Off"), translate("On")])
		widget22 := window.Add("DropDownList", "x" . x5 . " yp w70 X:Move(0.1) W:Grow(0.1) Choose1 vblueFlagsDropDown Hidden", [translate("Off"), translate("On")])

		widget36 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Accidents Ahead"))
		widget37 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vaccidentsAheadDropDown Hidden", [translate("Off"), translate("On")])

		widget38 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Accidents Behind"))
		widget39 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vaccidentsBehindDropDown Hidden", [translate("Off"), translate("On")])

		widget40 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Slow Cars"))
		widget41 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vslowCarsDropDown Hidden", [translate("Off"), translate("On")])

		widget23 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Pit Window"))
		widget24 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vpitWindowDropDown Hidden", [translate("Off"), translate("On")])

		widget25 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Cut Warnings"))
		widget26 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vcutWarningsDropDown Hidden", [translate("Off"), translate("On")])

		widget27 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("General Information"))
		widget28 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vsessionInformationDropDown Hidden", [translate("Off"), translate("On")])

		widget29 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Penalty Information"))
		widget30 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vpenaltyInformationDropDown Hidden", [translate("Off"), translate("On")])

		widget31 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Opponent Infos every"))
		widget32 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose3 vdeltaInformationDropDown Hidden", [translate("Off"), translate("Sector"), translate("Lap"), translate("2 Laps"), translate("3 Laps"), translate("4 Laps")])
		widget33 := window.Add("DropDownList", "x" . x5 . " yp w70 X:Move(0.1) W:Grow(0.1) Choose1 vdeltaInformationMethodDropDown Hidden", [translate("Static"), translate("Dynamic"), translate("Both")])

		widget34 := window.Add("Text", "x" . x0 . " yp+26 w120 h20 Section Hidden", translate("Tactical Advices"))
		widget35 := window.Add("DropDownList", "x" . x1 . " yp-4 w70 W:Grow(0.1) Choose1 vtacticalAdvicesDropDown Hidden", [translate("Off"), translate("On")])

		window.SetFont("Norm", "Arial")

		loop 41
			editor.registerWidget(this, widget%A_Index%)

		this.loadSimulatorConfiguration()
	}

	loadFromConfiguration(configuration) {
		local ignore, simulator, simulatorConfiguration, key, default

		super.loadFromConfiguration(configuration)

		if (this.Simulators.Length = 0)
			this.iSimulators := this.getSimulators()

		for ignore, simulator in this.Simulators {
			simulatorConfiguration := CaseInsenseMap()

			simulatorConfiguration["LearningLaps"] := getMultiMapValue(configuration, "Race Spotter Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getMultiMapValue(configuration, "Race Spotter Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getMultiMapValue(configuration, "Race Spotter Analysis", simulator . ".HistoryLapsDamping", 0.2)

			for ignore, key in ["SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
							  , "SessionInformation", "TacticalAdvices", "PitWindow", "CutWarnings", "PenaltyInformation"
							  , "SlowCars", "AccidentsAhead", "AccidentsBehind"]
				simulatorConfiguration[key] := getMultiMapValue(configuration, "Race Spotter Announcements", simulator . "." . key, inList(["SlowCars", "AccidentsAhead", "AccidentsBehind"], key) ? false : true)

			default := getMultiMapValue(configuration, "Race Spotter Announcements", simulator . ".PerformanceUpdates", 2)
			default := getMultiMapValue(configuration, "Race Spotter Announcements", simulator . ".DistanceInformation", default)

			simulatorConfiguration["DeltaInformation"] := getMultiMapValue(configuration, "Race Spotter Announcements"
																		 , simulator . ".DeltaInformation", default)
			simulatorConfiguration["DeltaInformationMethod"] := getMultiMapValue(configuration, "Race Spotter Announcements"
																			   , simulator . ".DeltaInformationMethod", "Both")

			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local simulator, simulatorConfiguration, ignore, key

		super.saveToConfiguration(configuration)

		this.saveSimulatorConfiguration()

		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping"]
				setMultiMapValue(configuration, "Race Spotter Analysis", simulator . "." . key, simulatorConfiguration[key])

			for ignore, key in ["SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
							  , "SessionInformation", "DeltaInformation", "DeltaInformationMethod", "TacticalAdvices", "PitWindow"
							  , "CutWarnings", "PenaltyInformation"
							  , "SlowCars", "AccidentsAhead", "AccidentsBehind"]
				setMultiMapValue(configuration, "Race Spotter Announcements", simulator . "." . key, simulatorConfiguration[key])
		}
	}

	loadConfigurator(configuration, simulators) {
		this.loadFromConfiguration(configuration)

		this.setSimulators(simulators)
	}

	show() {
		super.show()

		this.loadConfigurator(this.Configuration, this.getSimulators())
	}

	loadSimulatorConfiguration(simulator := false) {
		local configuration

		if simulator
			this.Control["rspSimulatorDropDown"].Choose(inList(this.iSimulators, simulator))

		this.iCurrentSimulator := this.Control["rspSimulatorDropDown"].Text

		if this.iSimulatorConfigurations.Has(this.iCurrentSimulator) {
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			this.Control["rspLearningLapsEdit"].Text := configuration["LearningLaps"]
			this.Control["rspLapsConsideredEdit"].Text := configuration["ConsideredHistoryLaps"]

			this.Control["rspDampingFactorEdit"].Text := displayValue("Float", configuration["HistoryLapsDamping"], 1)
			this.Control["rspDampingFactorEdit"].ValidText := this.Control["rspDampingFactorEdit"].Text

			this.Control["sideProximityDropDown"].Choose(configuration["SideProximity"] + 1)
			this.Control["rearProximityDropDown"].Choose(configuration["RearProximity"] + 1)
			this.Control["yellowFlagsDropDown"].Choose(configuration["YellowFlags"] + 1)
			this.Control["blueFlagsDropDown"].Choose(configuration["BlueFlags"] + 1)
			this.Control["sessionInformationDropDown"].Choose(configuration["SessionInformation"] + 1)
			this.Control["cutWarningsDropDown"].Choose(configuration["CutWarnings"] + 1)
			this.Control["penaltyInformationDropDown"].Choose(configuration["PenaltyInformation"] + 1)
			this.Control["slowCarsDropDown"].Choose(configuration["SlowCars"] + 1)
			this.Control["accidentsAheadDropDown"].Choose(configuration["AccidentsAhead"] + 1)
			this.Control["accidentsBehindDropDown"].Choose(configuration["AccidentsBehind"] + 1)

			if !configuration["DeltaInformation"]
				this.Control["deltaInformationDropDown"].Choose(1)
			else if (configuration["DeltaInformation"] = "S")
				this.Control["deltaInformationDropDown"].Choose(2)
			else
				this.Control["deltaInformationDropDown"].Choose(configuration["DeltaInformation"] + 2)

			this.Control["deltaInformationMethodDropDown"].Choose(inList(["Static", "Dynamic", "Both"], configuration["DeltaInformationMethod"]))

			this.Control["tacticalAdvicesDropDown"].Choose(configuration["TacticalAdvices"] + 1)
			this.Control["pitWindowDropDown"].Choose(configuration["PitWindow"] + 1)
		}
	}

	saveSimulatorConfiguration() {
		local configuration

		if this.iCurrentSimulator {
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			configuration["LearningLaps"] := this.Control["rspLearningLapsEdit"].Text
			configuration["ConsideredHistoryLaps"] := this.Control["rspLapsConsideredEdit"].Text
			configuration["HistoryLapsDamping"] := internalValue("Float", this.Control["rspDampingFactorEdit"].Text)

			configuration["SideProximity"] := (this.Control["sideProximityDropDown"].Value - 1)
			configuration["RearProximity"] := (this.Control["rearProximityDropDown"].Value - 1)
			configuration["YellowFlags"] := (this.Control["yellowFlagsDropDown"].Value - 1)
			configuration["BlueFlags"] := (this.Control["blueFlagsDropDown"].Value - 1)
			configuration["SessionInformation"] := (this.Control["sessionInformationDropDown"].Value - 1)
			configuration["CutWarnings"] := (this.Control["cutWarningsDropDown"].Value - 1)
			configuration["PenaltyInformation"] := (this.Control["penaltyInformationDropDown"].Value - 1)
			configuration["SlowCars"] := (this.Control["slowCarsDropDown"].Value - 1)
			configuration["AccidentsAhead"] := (this.Control["accidentsAheadDropDown"].Value - 1)
			configuration["AccidentsBehind"] := (this.Control["accidentsBehindDropDown"].Value - 1)

			if (this.Control["deltaInformationDropDown"].Value == 1)
				configuration["DeltaInformation"] := false
			else if (this.Control["deltaInformationDropDown"].Value == 2)
				configuration["DeltaInformation"] := "S"
			else
				configuration["DeltaInformation"] := (this.Control["deltaInformationDropDown"].Value - 2)

			configuration["DeltaInformationMethod"] := ["Static", "Dynamic", "Both"][this.Control["deltaInformationMethodDropDown"].Value]

			configuration["TacticalAdvices"] := (this.Control["tacticalAdvicesDropDown"].Value - 1)
			configuration["PitWindow"] := (this.Control["pitWindowDropDown"].Value - 1)
		}
	}

	setSimulators(simulators) {
		this.iSimulators := simulators

		this.Control["rspSimulatorDropDown"].Delete()
		this.Control["rspSimulatorDropDown"].Add(simulators)

		if (simulators.Length > 0) {
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
								  , "SessionInformation", "DeltaInformation", "DeltaInformationMethod", "TacticalAdvices", "PitWindow"
								  , "CutWarnings", "PenaltyInformation"
								  , "SlowCars", "AccidentsAhead", "AccidentsBehind"]
					simulatorConfiguration[key] := configuration[key]
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Race Spotter"), RaceSpotterConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterConfigurator()