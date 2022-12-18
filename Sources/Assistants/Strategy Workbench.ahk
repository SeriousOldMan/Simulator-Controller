;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Workbench Tool         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Includes\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Dashboard.ico
;@Ahk2Exe-ExeName Strategy Workbench.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\SettingsDatabase.ahk
#Include Libraries\TelemetryDatabase.ahk
#Include Libraries\Strategy.ahk
#Include Libraries\StrategyViewer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown
global airTemperatureEdit
global trackTemperatureEdit
global driverDropDown
global compoundDropDown
global dataTypeDropDown
global dataXDropDown
global dataY1DropDown
global dataY2DropDown
global dataY3DropDown

global chartSourceDropDown
global chartTypeDropDown

global chartViewer
global stratViewer

global sessionTypeDropDown
global sessionLengthEdit := 60
global sessionLengthLabel
global stintLengthEdit := 70
global formationLapCheck := true
global postRaceLapCheck := true

global settingsMenuDropDown
global simulationMenuDropDown
global strategyMenuDropDown

global pitstopRequirementsDropDown
global pitstopWindowEdit := "25 - 35"
global pitstopWindowLabel
global tyreChangeRequirementsDropDown
global tyreChangeRequirementsLabel
global refuelRequirementsDropDown
global refuelRequirementsLabel

global tyreSetDropDown
global tyreSetCountEdit
global tyreSetAddButton
global tyreSetDeleteButton

global pitstopDeltaEdit := 60
global pitstopTyreServiceEdit := 30
global pitstopFuelServiceRuleDropDown := "Dynamic"
global pitstopFuelServiceEdit := 1.2
global pitstopFuelServiceLabel
global pitstopServiceDropDown
global fuelCapacityEdit := 125
global safetyFuelEdit := 5

global simDriverDropDown
global addDriverButton
global deleteDriverButton

global simWeatherTimeEdit
global simWeatherDropDown
global simWeatherAirTemperatureEdit
global simWeatherTrackTemperatureEdit
global addSimWeatherButton
global deleteSimWeatherButton

global simCompoundDropDown
global simMaxTyreLapsEdit := 40
global simInitialFuelAmountEdit := 90
global simMapEdit := 1
global simAvgLapTimeEdit := 120
global simFuelConsumptionEdit := 3.8

global simConsumptionVariation := 0
global simTyreUsageVariation := 0
global simtyreCompoundVariation := 0
global simInitialFuelVariation := 0

global simInputDropDown

global simNumPitstopResult := ""
global simNumTyreChangeResult := ""
global simConsumedFuelResult := ""
global simPitlaneSecondsResult := ""
global simSessionResultResult := ""
global simSessionResultLabel

global strategyStartMapEdit := 1
global strategyStartTCEdit := 1
global strategyStartABSEdit := 2

global strategyCompoundDropDown
global strategyPressureFLEdit := 27.7
global strategyPressureFREdit := 27.7
global strategyPressureRLEdit := 27.7
global strategyPressureRREdit := 27.7

class StrategyWorkbench extends ConfigurationItem {
	iDataListView := false

	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	iSelectedWeather := "Dry"

	iTyreCompounds := [normalizeCompound("Dry")]

	iAvailableCompounds := [normalizeCompound("Dry")]

	iSelectedCompound := "Dry"
	iSelectedCompoundColor := "Black"

	iSelectedDataType := "Electronics"
	iSelectedChartType := "Scatter"

	iAvailableDrivers := []
	iSelectedDrivers := false
	iStintDrivers := []

	iSelectedValidator := false

	iSelectedSessionType := "Duration"

	iTelemetryChartHTML := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
	iStrategyChartHTML := this.iTelemetryChartHTML

	iTyreSetListView := false

	iSelectedScenario := false
	iSelectedStrategy := false

	iAirTemperature := 23
	iTrackTemperature := 27

	iDriversListView := false
	iWeatherListView := false
	iPitstopListView := false

	iStrategyViewer := false

	iTelemetryDatabase := false

	Window[] {
		Get {
			return "Workbench"
		}
	}

	DataListView[] {
		Get {
			return this.iDataListView
		}
	}

	SelectedSimulator[] {
		Get {
			return this.iSelectedSimulator
		}
	}

	SelectedCar[] {
		Get {
			return this.iSelectedCar
		}
	}

	SelectedTrack[] {
		Get {
			return this.iSelectedTrack
		}
	}

	SelectedWeather[] {
		Get {
			return this.iSelectedWeather
		}
	}

	AirTemperature[] {
		Get {
			return this.iAirTemperature
		}
	}

	TrackTemperature[] {
		Get {
			return this.iTrackTemperature
		}
	}

	TyreCompounds[key := false] {
		Get {
			return (key ? this.iTyreCompounds[key] : this.iTyreCompounds)
		}
	}

	AvailableDrivers[index := false] {
		Get {
			return (index ? this.iAvailableDrivers[index] : this.iAvailableDrivers)
		}
	}

	AvailableCompounds[index := false] {
		Get {
			return (index ? this.iAvailableCompounds[index] : this.iAvailableCompounds)
		}
	}

	SelectedCompound[colored := false] {
		Get {
			if colored
				return compound(this.iSelectedCompound, this.iSelectedCompoundColor)
			else
				return this.iSelectedCompound
		}
	}

	SelectedCompoundColor[] {
		Get {
			return this.iSelectedCompoundColor
		}
	}

	SelectedDataType[] {
		Get {
			return this.iSelectedDataType
		}
	}

	SelectedChartType[] {
		Get {
			return this.iSelectedChartType
		}
	}

	SelectedDrivers[index := false] {
		Get {
			return (index ? this.iSelectedDrivers[index] : this.iSelectedDrivers)
		}
	}

	StintDrivers[index := false] {
		Get {
			return (index ? this.iStintDrivers[index] : this.iStintDrivers)
		}

		Set {
			return (index ? (this.iStintDrivers[index] := value) : (this.iStintDrivers := value))
		}
	}

	SelectedValidator[] {
		Get {
			return this.iSelectedValidator
		}
	}

	SelectedSessionType[] {
		Get {
			return this.iSelectedSessionType
		}
	}

	TyreSetListView[] {
		Get {
			return this.iTyreSetListView
		}
	}

	SelectedScenario[] {
		Get {
			return this.iSelectedScenario
		}
	}

	SelectedStrategy[] {
		Get {
			return this.iSelectedStrategy
		}
	}

	DriversListView[] {
		Get {
			return this.iDriversListView
		}
	}

	WeatherListView[] {
		Get {
			return this.iWeatherListView
		}
	}

	PitstopListView[] {
		Get {
			return this.iPitstopListView
		}
	}

	StrategyViewer[] {
		Get {
			return this.iStrategyViewer
		}
	}

	TelemetryDatabase[] {
		Get {
			return this.iTelemetryDatabase
		}
	}

	__New(simulator := false, car := false, track := false, weather := false, airTemperature := false, trackTemperature := false
		, compound := false, compoundColor := false) {
		this.iSelectedSimulator := simulator
		this.iSelectedCar := car
		this.iSelectedTrack := track
		this.iSelectedWeather := weather
		this.iSelectedCompound := compound
		this.iSelectedCompoundColor := compoundColor

		this.iAirTemperature := airTemperature
		this.iTrackTemperature := trackTemperature

		base.__New(kSimulatorConfiguration)

		StrategyWorkbench.Instance := this
	}

	createGui(configuration) {
		local window := this.Window
		local compound, simulators, simulator, car, track, weather, choices, chosen, schema
		local x, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, w12, w3
		local airTemperature, trackTemperature

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1334 Center gmoveWorkbench, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x608 YP+20 w134 cBlue Center gopenWorkbenchDocumentation, % translate("Strategy Workbench")

		Gui %window%:Add, Text, x8 yp+30 w1350 0x10

		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x16 yp+12 w30 h30 Section, %kIconsDirectory%Sensor.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Telemetry")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, Text, x16 yp+32 w70 h23 +0x200, % translate("Simulator")

		simulators := this.getSimulators()
		simulator := 0

		if (simulators.Length() > 0) {
			if this.SelectedSimulator
				simulator := inList(simulators, this.SelectedSimulator)

			if (simulator == 0)
				simulator := 1
		}

		Gui %window%:Add, DropDownList, x90 yp w290 Choose%simulator% vsimulatorDropDown gchooseSimulator, % values2String("|", simulators*)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Car")
		Gui %window%:Add, DropDownList, AltSubmit x90 yp w290 vcarDropDown gchooseCar

		Gui %window%:Add, Text, x16 yp24 w70 h23 +0x200, % translate("Track")
		Gui %window%:Add, DropDownList, x90 yp w290 vtrackDropDown gchooseTrack

		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Conditions")

		weather := this.SelectedWeather
		choices := map(kWeatherConditions, "translate")
		chosen := inList(kWeatherConditions, weather)

		if (!chosen && (choices.Length() > 0)) {
			weather := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x90 yp w120 AltSubmit Choose%chosen% gchooseWeather vweatherDropDown, % values2String("|", choices*)

		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature

		Gui %window%:Add, Edit, x215 yp w40 Number Limit2 vairTemperatureEdit gupdateTemperatures
		Gui %window%:Add, UpDown, x242 yp-2 w18 h20 Range0-99, % airTemperature

		Gui %window%:Add, Edit, x262 yp w40 Number Limit2 vtrackTemperatureEdit gupdateTemperatures
		Gui %window%:Add, UpDown, x289 yp w18 h20 Range0-99, % trackTemperature
		Gui %window%:Add, Text, x304 yp w90 h23 +0x200, % translate("Air / Track")

		this.setTemperatures(airTemperature, trackTemperature)

		Gui %window%:Add, Text, x16 yp+32 w364 0x10

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, Text, x16 yp+10 w364 h23 Center +0x200, % translate("Chart")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, DropDownList, x12 yp+28 w76 AltSubmit Choose1 vdataTypeDropDown gchooseDataType +0x200, % values2String("|", map(["Electronics", "Tyres", "-----------------", "Cleanup Data"], "translate")*)

		Gui %window%:Add, ListView, x12 yp+24 w170 h123 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdataListView gchooseData, % values2String("|", map(["Compound", "Map", "#"], "translate")*)

		this.iDataListView := dataListView

		Gui %window%:Add, Text, x195 yp w70 h23 +0x200, % translate("Driver")
		Gui %window%:Add, DropDownList, x250 yp w130 AltSubmit gchooseDriver vdriverDropDown

		compound := this.SelectedCompound[true]
		choices := map([normalizeCompound("Dry")], "translate")
		chosen := inList([normalizeCompound("Dry")], compound)

		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}

		Gui %window%:Add, Text, x195 yp+24 w70 h23 +0x200, % translate("Compound")
		Gui %window%:Add, DropDownList, x250 yp w130 AltSubmit Choose%chosen% gchooseCompound vcompoundDropDown, % values2String("|", choices*)

		Gui %window%:Add, Text, x195 yp+28 w70 h23 +0x200, % translate("X-Axis")

		schema := filterSchema(new TelemetryDatabase().getSchema("Electronics", true))

		chosen := inList(schema, "Map")
		Gui %window%:Add, DropDownList, x250 yp w130 AltSubmit Choose%chosen% vdataXDropDown gchooseAxis, % values2String("|", map(schema, "translate")*)

		Gui %window%:Add, Text, x195 yp+24 w70 h23 +0x200, % translate("Series")

		chosen := inList(schema, "Fuel.Consumption")
		Gui %window%:Add, DropDownList, x250 yp w130 AltSubmit Choose%chosen% vdataY1DropDown gchooseAxis, % values2String("|", map(schema, "translate")*)
		Gui %window%:Add, DropDownList, x250 yp+24 w130 AltSubmit Choose1 vdataY2DropDown gchooseAxis, % translate("None") . "|" . values2String("|", map(schema, "translate")*)
		Gui %window%:Add, DropDownList, x250 yp+24 w130 AltSubmit Choose1 vdataY3DropDown gchooseAxis, % translate("None") . "|" . values2String("|", map(schema, "translate")*)

		Gui %window%:Add, Text, x400 ys w40 h23 +0x200, % translate("Chart")
		Gui %window%:Add, DropDownList, x444 yp w80 AltSubmit Choose1 +0x200 vchartSourceDropDown gchooseChartSource, % values2String("|", map(["Telemetry", "Comparison"], "translate")*)
		Gui %window%:Add, DropDownList, x529 yp w80 AltSubmit Choose1 vchartTypeDropDown gchooseChartType, % values2String("|", map(["Scatter", "Bar", "Bubble", "Line"], "translate")*)

		Gui %window%:Add, ActiveX, x400 yp+24 w950 h442 Border vchartViewer, shell.explorer

		chartViewer.Navigate("about:blank")

		Gui %window%:Add, Text, x8 yp+450 w1350 0x10

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x16 yp+10 w30 h30 Section, %kIconsDirectory%Strategy.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Strategy")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, DropDownList, x250 yp-2 w180 AltSubmit Choose1 +0x200 VsettingsMenuDropDown gsettingsMenu

		this.updateSettingsMenu()

		Gui %window%:Add, DropDownList, x435 yp w180 AltSubmit Choose1 +0x200 VsimulationMenuDropDown gsimulationMenu, % values2String("|", map(["Simulation", "---------------------------------------------", "Run Simulation", "---------------------------------------------", "Use as Strategy..."], "translate")*)

		Gui %window%:Add, DropDownList, x620 yp w180 AltSubmit Choose1 +0x200 VstrategyMenuDropDown gstrategyMenu, % values2String("|", map(["Strategy", "---------------------------------------------", "Load current Race Strategy", "Load Strategy...", "Save Strategy...", "---------------------------------------------", "Compare Strategies...", "---------------------------------------------", "Set as Race Strategy", "Clear Race Strategy"], "translate")*)

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x619 ys+39 w727 h9, % translate("Strategy")

		Gui %window%:Add, ActiveX, x619 yp+21 w727 h193 Border vstratViewer, shell.explorer

		stratViewer.Navigate("about:blank")

		this.iStrategyViewer := new StrategyViewer(window, stratViewer)

		this.showStrategyInfo(false)

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x8 y816 w1350 0x10

		Gui %window%:Add, Button, x649 y824 w80 h23 GcloseWorkbench, % translate("Close")

		Gui %window%:Add, Tab, x16 ys+39 w593 h216 -Wrap Section, % values2String("|", map(["Rules && Settings", "Pitstop && Service", "Drivers", "Weather", "Simulation", "Strategy"], "translate")*)

		Gui %window%:Tab, 1

		x := 32
		x0 := x - 4
		x1 := x + 74
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		x5 := 243 + 8
		x6 := x5 - 4
		x7 := x5 + 79
		x8 := x7 + 32
		x9 := x8 + 26
		x10 := x7 + 16

		x11 := x7 + 87
		x12 := x11 + 56

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w209 h171, % translate("Race")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, DropDownList, x%x0% yp+21 w70 AltSubmit Choose1 gchooseSessionType VsessionTypeDropDown, % values2String("|", map(["Duration", "Laps"], "translate")*)
		Gui %window%:Add, Edit, x%x1% yp w50 h20 Limit4 Number VsessionLengthEdit, %sessionLengthEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-9999 0x80, %sessionLengthEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w60 h20 VsessionLengthLabel, % translate("Minutes")

		Gui %window%:Add, Text, x%x% yp+21 w75 h23 +0x200, % translate("Max. Stint")
		Gui %window%:Add, Edit, x%x1% yp w50 h20 Limit4 Number VstintLengthEdit, %stintLengthEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-9999 0x80, %stintLengthEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w60 h20, % translate("Minutes")

		Gui %window%:Add, Text, x%x% yp+21 w75 h23 +0x200, % translate("Formation")
		Gui %window%:Add, CheckBox, x%x1% yp-1 w17 h23 Checked%formationLapCheck% VformationLapCheck, %formationLapCheck%
		Gui %window%:Add, Text, x%x4% yp+5 w50 h20, % translate("Lap")

		Gui %window%:Add, Text, x%x% yp+19 w75 h23 +0x200, % translate("Post Race")
		Gui %window%:Add, CheckBox, x%x1% yp-1 w17 h23 Checked%postRaceLapCheck% VpostRaceLapCheck, %postRaceLapCheck%
		Gui %window%:Add, Text, x%x4% yp+5 w50 h20, % translate("Lap")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x243 ys+34 w354 h171, % translate("Pitstop")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x5% yp+23 w75 h20, % translate("Pitstop")
		Gui %window%:Add, DropDownList, x%x7% yp-4 w80 AltSubmit Choose3 VpitstopRequirementsDropDown gchoosePitstopRequirements, % values2String("|", map(["Optional", "Required", "Window"], "translate")*)
		Gui %window%:Add, Edit, x%x11% yp+1 w50 h20 VpitstopWindowEdit gvalidatePitstopRule, %pitstopWindowEdit%
		Gui %window%:Add, Text, x%x12% yp+3 w120 h20 VpitstopWindowLabel, % translate("Minute (From - To)")

		Gui %window%:Add, Text, x%x5% yp+22 w75 h23 +0x200 VrefuelRequirementsLabel, % translate("Refuel")
		Gui %window%:Add, DropDownList, x%x7% yp w80 AltSubmit Choose2 VrefuelRequirementsDropDown, % values2String("|", map(["Optional", "Required", "Always", "Disallowed"], "translate")*)

		Gui %window%:Add, Text, x%x5% yp+26 w75 h23 +0x200 VtyreChangeRequirementsLabel, % translate("Tyre Change")
		Gui %window%:Add, DropDownList, x%x7% yp w80 AltSubmit Choose2 VtyreChangeRequirementsDropDown, % values2String("|", map(["Optional", "Required", "Always", "Disallowed"], "translate")*)

		Gui %window%:Add, Text, x%x5% yp+26 w75 h23 +0x200, % translate("Tyre Sets")

		w12 := (x11 + 50 - x7)

		Gui %window%:Add, ListView, x%x7% yp w%w12% h65 -Multi -Hdr -LV0x10 AltSubmit NoSort NoSortHdr HWNDtyreSetListView gchooseTyreSet, % values2String("|", map(["Compound", "#"], "translate")*)

		this.iTyreSetListView := tyreSetListView

		x13 := (x7 + w12 + 5)

		Gui %window%:Add, DropDownList, x%x13% yp w116 AltSubmit Choose0 vtyreSetDropDown gupdateTyreSet, % values2String("|", map([normalizeCompound("Dry")], "translate")*)

		Gui %window%:Add, Edit, x%x13% yp+24 w40 h20 Limit2 Number vtyreSetCountEdit gupdateTyreSet
		Gui %window%:Add, UpDown, x%x13% yp w18 h20 0x80 Range0-99

		x13 := (x7 + w12 + 5 + 116 - 48)

		Gui %window%:Add, Button, x%x13% yp+18 w23 h23 Center +0x200 HWNDaddButtonHandle vtyreSetAddButton gaddTyreSet
		setButtonIcon(addButtonHandle, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")

		x13 += 25

		Gui %window%:Add, Button, x%x13% yp w23 h23 Center +0x200 HWNDdeleteButtonHandle vtyreSetDeleteButton gdeleteTyreSet
		setButtonIcon(deleteButtonHandle, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Tab, 2

		x := 32
		x0 := x - 4
		x1 := x + 114
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w410 h171, % translate("Pitstop")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w105 h20 +0x200, % translate("Pitlane Delta")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Limit2 Number VpitstopDeltaEdit, %pitstopDeltaEdit%
		Gui %window%:Add, UpDown, x%x2% yp w18 h20 0x80 Range0-99, %pitstopDeltaEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w220 h20, % translate("Seconds (Drive through - Drive by)")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Tyre Service")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Limit2 Number VpitstopTyreServiceEdit, %pitstopTyreServiceEdit%
		Gui %window%:Add, UpDown, x%x2% yp w18 h20 0x80 Range0-99, %pitstopTyreServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w220 h20, % translate("Seconds (Change four tyres)")

		Gui %window%:Add, DropDownList, x%x0% yp+20 w110 AltSubmit Choose2 VpitstopFuelServiceRuleDropdown gchooseRefuelService, % values2String("|", map(["Refuel Fixed", "Refuel Dynamic"], "translate")*)

		Gui %window%:Add, Edit, x%x1% yp w50 h20 VpitstopFuelServiceEdit gvalidatePitstopFuelService, %pitstopFuelServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w220 h20 VpitstopFuelServiceLabel, % translate("Seconds (Refuel of 10 litres)")

		Gui %window%:Add, Text, x%x% yp+24 w160 h23, % translate("Service")
		Gui %window%:Add, DropDownList, x%x1% yp-3 w100 AltSubmit Choose1 vpitstopServiceDropDown, % values2String("|", map(["Simultaneous", "Sequential"], "translate")*)

		Gui %window%:Add, Text, x%x% yp+27 w85 h20 +0x200, % translate("Fuel Capacity")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Number Limit3 VfuelCapacityEdit, %fuelCapacityEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w220 h20, % translate("Liter")

		Gui %window%:Add, Text, x%x% yp+19 w85 h23 +0x200, % translate("Safety Fuel")
		Gui %window%:Add, Edit, x%x1% yp+1 w50 h20 Number Limit2 VsafetyFuelEdit, %safetyFuelEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range0-99, %safetyFuelEdit%
		Gui %window%:Add, Text, x%x3% yp+2 w130 h20, % translate("Liter")

		Gui %window%:Tab, 3

		x := 32
		x2 := x + 220
		x3 := x2 + 100
		w3 := 140
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		Gui %window%:Add, ListView, x24 ys+34 w216 h171 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdriversListView gchooseSimDriver, % values2String("|", map(["Stint", "Driver"], "translate")*)

		this.iDriversListView := driversListView

		Gui %window%:Add, Text, x%x2% ys+34 w90 h23 +0x200, % translate("Driver")
		Gui %window%:Add, DropDownList, x%x3% yp w%w3% AltSubmit vsimDriverDropDown gupdateSimDriver

		Gui %window%:Add, Button, x%x4% yp+30 w23 h23 Center +0x200 HWNDplusButton vaddDriverButton gaddSimDriver
		setButtonIcon(plusButton, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x5% yp w23 h23 Center +0x200 HWNDminusButton vdeleteDriverButton gdeleteSimDriver
		setButtonIcon(minusButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Tab, 4

		x := 32
		x2 := x + 220
		x3 := x2 + 70
		w3 := 100
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		x6 := x3 + w3 + 5
		x7 := x6 + 47
		x8 := x7 + 52

		Gui %window%:Add, ListView, x24 ys+34 w216 h171 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDweatherListView gchooseSimWeather, % values2String("|", map(["Time", "Weather", "T Air", "T Track"], "translate")*)

		this.iWeatherListView := weatherListView

		Gui %window%:Add, Text, x%x2% ys+34 w70 h23 +0x200, % translate("Time")
		Gui %window%:Add, DateTime, x%x3% yp w50 h23 vsimWeatherTimeEdit gupdateSimWeather 1, HH:mm

		Gui %window%:Add, Text, x%x2% yp+24 w70 h23 +0x200, % translate("Weather")
		Gui %window%:Add, DropDownList, x%x3% yp w%w3% AltSubmit vsimWeatherDropDown gupdateSimWeather, % values2String("|", map(kWeatherConditions, "translate")*)

		Gui %window%:Add, Edit, x%x6% yp w40 Number Limit2 vsimWeatherAirTemperatureEdit gupdateSimWeather
		Gui %window%:Add, UpDown, x%x6% yp-2 w18 h20 Range0-99, % airTemperature

		Gui %window%:Add, Edit, x%x7% yp w40 Number Limit2 vsimWeatherTrackTemperatureEdit gupdateSimWeather
		Gui %window%:Add, UpDown, x%x7% yp w18 h20 Range0-99, % trackTemperature
		Gui %window%:Add, Text, x%x8% yp w70 h23 +0x200, % translate("Air / Track")

		Gui %window%:Add, Button, x%x8% yp+30 w23 h23 Center +0x200 HWNDplusButton vaddSimWeatherButton gaddSimWeather
		setButtonIcon(plusButton, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, xp+25 yp w23 h23 Center +0x200 HWNDminusButton vdeleteSimWeatherButton gdeleteSimWeather
		setButtonIcon(minusButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Tab, 5

		x := 32
		x0 := x - 4
		x1 := x + 74
		x2 := x1 + 22
		x3 := x2 + 28
		x4 := x1 + 16
		x5 := x3 + 44

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w179 h171, % translate("Initial Conditions")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w85 h23 +0x200, % translate("Compound")

		compound := this.SelectedCompound[true]
		choices := map([normalizeCompound("Dry")], "translate")
		chosen := inList([normalizeCompound("Dry")], compound)

		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x%x1% yp w84 AltSubmit Choose%chosen% VsimCompoundDropDown, % values2String("|", choices*)

		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("Tyre Usage")
		Gui %window%:Add, Edit, x%x1% yp-1 w45 h20 Number Limit3 VsimMaxTyreLapsEdit gvalidateSimMaxTyreLaps, %simMaxTyreLapsEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-999, %simMaxTyreLapsEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w45 h20, % translate("Laps")

		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Initial Fuel")
		Gui %window%:Add, Edit, x%x1% yp-1 w45 h20 Number Limit3 VsimInitialFuelAmountEdit gvalidateSimInitialFuelAmount, %simInitialFuelAmountEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-999, %simInitialFuelAmountEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w45 h20, % translate("Liter")

		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Map")
		Gui %window%:Add, Edit, x%x1% yp-1 w45 h20 Number Limit2 VsimMapEdit, %simMapEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range0-99 , %simMapEdit%

		Gui %window%:Add, Text, x%x% yp+23 w85 h23 +0x200, % translate("Avg. Lap Time")
		Gui %window%:Add, Edit, x%x1% yp w45 h20 VsimAvgLapTimeEdit gvalidateSimAvgLapTime, %simAvgLapTimeEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Sec.")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Consumption")
		Gui %window%:Add, Edit, x%x1% yp-2 w45 h20 VsimFuelConsumptionEdit gvalidateSimFuelConsumption, %simFuelConsumptionEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Ltr.")

		x := 222
		x0 := x - 4
		x1 := x + 104
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		x5 := x + 50

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x214 ys+34 w174 h120, % translate("Optimizer")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w100 h20 +0x200, % translate("Consumption")
		Gui %window%:Add, Slider, Center Thick15 x%x1% yp+2 w60 0x10 Range0-10 ToolTip VsimConsumptionVariation, %simConsumptionVariation%

		Gui %window%:Add, Text, x%x% yp+22 w100 h20 +0x200, % translate("Initial Fuel")
		Gui %window%:Add, Slider, Center Thick15 x%x1% yp+2 w60 0x10 Range0-100 ToolTip VsimInitialFuelVariation, %simInitialFuelVariation%

		Gui %window%:Add, Text, x%x% yp+22 w100 h20 +0x200, % translate("Tyre Usage")
		Gui %window%:Add, Slider, Center Thick15 x%x1% yp+2 w60 0x10 Range0-100 ToolTip VsimTyreUsageVariation, %simTyreUsageVariation%

		Gui %window%:Add, Text, x%x% yp+22 w100 h20 +0x200, % translate("Tyre Compound")
		Gui %window%:Add, Slider, Center Thick15 x%x1% yp+2 w60 0x10 Range0-100 ToolTip VsimtyreCompoundVariation, %simtyreCompoundVariation%

		Gui %window%:Add, Text, x214 yp+30 w40 h23 +0x200, % translate("Use")

		choices := map(["Initial Conditions", "Telemetry Data", "Initial Cond. + Telemetry"], "translate")

		Gui %window%:Add, DropDownList, x250 yp w138 AltSubmit Choose3 VsimInputDropDown, % values2String("|", choices*)

		Gui %window%:Add, Button, x214 yp+26 w174 h20 grunSimulation, % translate("Simulate!")

		x := 407
		x0 := x - 4
		x1 := x + 89
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x399 ys+34 w197 h171, % translate("Summary")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w90 h20 +0x200, % translate("# Pitstops")
		Gui %window%:Add, Edit, x%x1% yp+1 w40 h20 Disabled VsimNumPitstopResult, %simNumPitstopResult%

		Gui %window%:Add, Text, x%x% yp+23 w90 h20 +0x200, % translate("# Tyre Changes")
		Gui %window%:Add, Edit, x%x1% yp+1 w40 h20 Disabled VsimNumTyreChangeResult, %simNumTyreChangeResult%

		Gui %window%:Add, Text, x%x% yp+23 w90 h20 +0x200, % translate("Consumed Fuel")
		Gui %window%:Add, Edit, x%x1% yp+1 w40 h20 Disabled VsimConsumedFuelResult, %simConsumedFuelResult%
		Gui %window%:Add, Text, x%x3% yp+2 w50 h20, % translate("Liter")

		Gui %window%:Add, Text, x%x% yp+21 w90 h20 +0x200, % translate("@ Pitlane")
		Gui %window%:Add, Edit, x%x1% yp+1 w40 h20 Disabled VsimPitlaneSecondsResult, %simPitlaneSecondsResult%
		Gui %window%:Add, Text, x%x3% yp+2 w50 h20, % translate("Seconds")

		Gui %window%:Add, Text, x%x% yp+21 w90 h20 +0x200, % translate("@ Finish")
		Gui %window%:Add, Edit, x%x1% yp+1 w40 h20 Disabled VsimSessionResultResult, %simSessionResultResult%
		Gui %window%:Add, Text, x%x3% yp+2 w50 h20 VsimSessionResultLabel, % translate("Laps")

		Gui %window%:Tab, 6

		x := 32
		x0 := x - 4
		x1 := x + 74
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		x5 := 243 + 8
		x6 := x5 - 4
		x7 := x5 + 74
		x8 := x7 + 32
		x9 := x8 + 26
		x10 := x7 + 16

		x11 := x7 + 82
		x12 := x11 + 56

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w143 h171, % translate("Electronics")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Map")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Number Limit2 VstrategyStartMapEdit Disabled, %strategyStartMapEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range0-99 Disabled, %strategyStartMapEdit%

		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("TC")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Number Limit2 VstrategyStartTCEdit Disabled, %strategyStartTCEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range0-99 Disabled, %strategyStartTCEdit%

		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("ABS")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Number Limit2 VstrategyStartABSEdit Disabled, %strategyStartABSEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range0-99 Disabled, %strategyStartABSEdit%

		x := 186
		x0 := x + 50
		x1 := x + 70
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x178 ys+34 w174 h171, % translate("Tyres")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w65 h23 +0x200, % translate("Compound")

		compound := this.SelectedCompound[true]
		choices := map([normalizeCompound("Dry")], "translate")
		chosen := inList([normalizeCompound("Dry")], compound)

		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x%x1% yp w85 AltSubmit Choose%chosen% VstrategyCompoundDropDown Disabled, % values2String("|", choices*)

		Gui %window%:Add, Text, x%x% yp+26 w85 h20 +0x200, % translate("Pressure")
		Gui %window%:Add, Text, x%x0% yp w85 h20 +0x200, % translate("FL")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureFLEdit Disabled, %strategyPressureFLEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x%x0% yp+21 w85 h20 +0x200, % translate("FR")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureFREdit Disabled, %strategyPressureFREdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x%x0% yp+21 w85 h20 +0x200, % translate("RL")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureRLEdit Disabled, %strategyPressureRLEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x%x0% yp+21 w85 h20 +0x200, % translate("RR")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureRREdit Disabled, %strategyPressureRREdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		x := 371
		x0 := x - 4
		x1 := x + 84
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x363 ys+34 w233 h171, % translate("Pitstops")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, ListView, x%x% yp+21 w216 h139 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDpitstopListView gnoSelect, % values2String("|", map(["Lap", "Driver", "Fuel", "Tyres", "Map"], "translate")*)

		this.iPitstopListView := pitstopListView

		Gui %window%:Font, Norm, Arial

		car := this.SelectedCar
		track := this.SelectedTrack

		this.loadSimulator(simulator, true)

		if car
			this.loadCar(car)

		if track
			this.loadTrack(track)

		this.updateState()
	}

	show() {
		local window := this.Window
		local x, y

		if getWindowPosition("Strategy Workbench", x, y)
			Gui %window%:Show, x%x% y%y%
		else
			Gui %window%:Show
	}

	showTelemetryChart(drawChartFunction) {
		local window := this.Window
		local width, height, before, after, html

		Gui %window%:Default

		chartViewer.Document.Open()

		width := (chartViewer.Width - 5)
		height := (chartViewer.Height - 5)

		if (drawChartFunction && (drawChartFunction != "")) {
			before =
			(
			<html>
			    <meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)

			after =
			(
					</script>
				</head>
				<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: %width%px; height: %height%px"></div>
				</body>
			</html>
			)

			html := (before . drawChartFunction . after)

			chartViewer.Document.Write(html)
		}
		else {
			html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

			chartViewer.Document.Write(html)
		}

		this.iTelemetryChartHTML := html

		chartViewer.Document.Close()

		GuiControl Choose, chartSourceDropDown, 1
		GuiControl Show, chartTypeDropDown
	}

	showComparisonChart(html) {
		local window := this.Window

		Gui %window%:Default

		chartViewer.Document.Open()
		chartViewer.Document.Write(html)
		chartViewer.Document.Close()

		this.iStrategyChartHTML := html

		GuiControl Choose, chartSourceDropDown, 2
		GuiControl Hide, chartTypeDropDown
	}

	updateState() {
		local window := this.Window
		local oldTChoice, oldFChoice

		Gui %window%:Default

		Gui ListView, % this.TyreSetListView

		if (LV_GetNext(0) > 0) {
			GuiControl Enable, tyreSetDropDown
			GuiControl Enable, tyreSetCountEdit
			GuiControl Enable, tyreSetDeleteButton
		}
		else {
			GuiControl Disable, tyreSetDropDown
			GuiControl Disable, tyreSetCountEdit
			GuiControl Disable, tyreSetDeleteButton

			GuiControl Choose, tyreSetDropDown, 0
			GuiControl, , tyreSetCountEdit, % ""
		}

		GuiControlGet pitstopRequirementsDropDown
		GuiControlGet pitstopWindowEdit

		if (pitstopRequirementsDropDown = 3) {
			GuiControl Show, pitstopWindowEdit
			GuiControl Show, pitstopWindowLabel

			GuiControl, , pitstopWindowLabel, % translate("Minute (From - To)")

			if !InStr(pitstopWindowEdit, "-")
				GuiControl, , pitstopWindowEdit, 25 - 35
		}
		else if (pitstopRequirementsDropDown = 2) {
			GuiControl Show, pitstopWindowEdit
			GuiControl Show, pitstopWindowLabel

			GuiControl, , pitstopWindowLabel, % ""

			if InStr(pitstopWindowEdit, "-")
				GuiControl, , pitstopWindowEdit, 1
		}
		else {
			GuiControl Hide, pitstopWindowEdit
			GuiControl Hide, pitstopWindowLabel
		}

		GuiControlGet tyreChangeRequirementsDropDown
		GuiControlGet refuelRequirementsDropDown

		oldTChoice := ["Optional", "Required", "Always", "Disallowed"][tyreChangeRequirementsDropDown]
		oldFChoice := ["Optional", "Required", "Always", "Disallowed"][refuelRequirementsDropDown]

		if (pitstopRequirementsDropDown = 1) {
			GuiControl, , tyreChangeRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Always", "Disallowed"], "translate")*)
			GuiControl, , refuelRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Always", "Disallowed"], "translate")*)

			oldTChoice := inList(["Optional", "Always", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Always", "Disallowed"], oldFChoice)

			GuiControl Choose, tyreChangeRequirementsDropDown, % oldTChoice ? oldTChoice : 1
			GuiControl Choose, refuelRequirementsDropDown, % oldFChoice ? oldFChoice : 1
		}
		else {
			GuiControl, , tyreChangeRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Required", "Always", "Disallowed"], "translate")*)
			GuiControl, , refuelRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Required", "Always", "Disallowed"], "translate")*)

			oldTChoice := inList(["Optional", "Required", "Always", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Required", "Always", "Disallowed"], oldFChoice)

			GuiControl Choose, tyreChangeRequirementsDropDown, % oldTChoice ? oldTChoice : 1
			GuiControl Choose, refuelRequirementsDropDown, % oldFChoice ? oldFChoice : 1
		}

		Gui ListView, % this.DriversListView

		if (this.AvailableDrivers.Length() > 0)
			GuiControl Enable, addDriverButton
		else
			GuiControl Disable, addDriverButton

		if (LV_GetNext(0) && (this.AvailableDrivers.Length() > 0)) {
			if (this.AvailableDrivers.Length() > 1)
				GuiControl Enable, deleteDriverButton
			else
				GuiControl Disable, deleteDriverButton

			GuiControl Enable, simDriverDropDown
		}
		else {
			GuiControl Disable, deleteDriverButton
			GuiControl Disable, simDriverDropDown

			GuiControl Choose, simDriverDropDown, 0
		}

		Gui ListView, % this.WeatherListView

		GuiControl Enable, addSimWeatherButton

		if LV_GetNext(0) {
			GuiControl Enable, deleteSimWeatherButton
			GuiControl Enable, simWeatherTimeEdit
			GuiControl Enable, simWeatherTrackTemperatureEdit
			GuiControl Enable, simWeatherAirTemperatureEdit
			GuiControl Enable, simWeatherDropDown
		}
		else {
			GuiControl Disable, deleteSimWeatherButton
			GuiControl Disable, simWeatherTimeEdit
			GuiControl Disable, simWeatherTrackTemperatureEdit
			GuiControl Disable, simWeatherAirTemperatureEdit
			GuiControl Disable, simWeatherDropDown

			GuiControl Choose, simWeatherDropDown, 0
			GuiControl, , simWeatherTimeEdit, 20200101000000
			GuiControl, , simWeatherTrackTemperatureEdit, % ""
			GuiControl, , simWeatherAirTemperatureEdit, % ""
		}
	}

	updateSettingsMenu() {
		local window := this.Window
		local settingsMenu, fileNames, validators, ignore, fileName, validator

		Gui %window%:Default

		settingsMenu := map(["Settings", "---------------------------------------------", "Initialize from Strategy", "Initialize from Settings...", "Initialize from Database", "Initialize from Telemetry", "Initialize from Simulation"], "translate")

		fileNames := getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\")

		if (fileNames.Length() > 0) {
			settingsMenu.Push(translate("---------------------------------------------"))
			settingsMenu.Push(translate("Rules:"))

			validators := []

			for ignore, fileName in fileNames {
				SplitPath fileName, , , , validator

				if !inList(validators, validator) {
					validators.Push(validator)

					if (validator = this.SelectedValidator)
						settingsMenu.Push("(x) " . validator)
					else
						settingsMenu.Push("      " . validator)
				}
			}
		}

		GuiControl, , settingsMenuDropDown, % "|" . values2String("|", settingsMenu*)

		GuiControl Choose, settingsMenuDropDown, 1
	}

	createStrategyInfo(strategy) {
		return this.StrategyViewer.createStrategyInfo(strategy)
	}

	createSetupInfo(strategy) {
		return this.StrategyViewer.createSetupInfo(strategy)
	}

	createStintsInfo(strategy, ByRef timeSeries, ByRef lapSeries, ByRef fuelSeries, ByRef tyreSeries) {
		return this.StrategyViewer.createStintsInfo(strategy, timeSeries, lapSeries, fuelSeries, tyreSeries)
	}

	showStrategyInfo(strategy) {
		this.StrategyViewer.showStrategyInfo(strategy)
	}

	showDataPlot(data, xAxis, yAxises) {
		local drawChartFunction := "function drawChart() {"
		local double := (yAxises.Length() > 1)
		local ignore, yAxis, minValue, maxValue, value, series, vAxis, index, values

		this.iSelectedChart := "LapTimes"

		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"

		if (this.SelectedChartType = "Bubble")
			drawChartFunction .= ("`ndata.addColumn('string', 'ID');")

		drawChartFunction .= ("`ndata.addColumn('number', '" . xAxis . "');")

		for ignore, yAxis in yAxises
			drawChartFunction .= ("`ndata.addColumn('number', '" . yAxis . "');")

		drawChartFunction .= "`ndata.addRows(["

		minValue := kUndefined
		maxValue := kUndefined

		for ignore, values in data {
			if (A_Index > 1)
				drawChartFunction .= ",`n"

			value := values[xAxis]

			if ((value = "n/a") || (isNull(value)))
				value := kNull
			else if (this.SelectedChartType = "Bar") {
				if (minValue = kUndefined)
					minValue := value
				else
					minValue := Min(value, minValue)

				if (maxValue = kUndefined)
					maxValue := value
				else
					maxValue := Max(value, maxValue)
			}

			if (this.SelectedChartType = "Bubble")
				drawChartFunction .= ("['', " . value)
			else
				drawChartFunction .= ("[" . value)

			for ignore, yAxis in yAxises {
				value := values[yAxis]

				if ((value = "n/a") || (isNull(value)))
					value := kNull

				drawChartFunction .= (", " . value)
			}

			drawChartFunction .= "]"
		}

		drawChartFunction .= "`n]);"

		series := "series: {"
		vAxis := "vAxis: { gridlines: { color: 'E0E0E0' }, "

		for ignore, yAxis in yAxises {
			if (A_Index > 1) {
				series .= ", "
				vAxis .= ", "
			}

			if (A_Index > 2)
				break

			index := A_Index - 1

			series .= (index . ": {targetAxisIndex: " . index . "}")
			vAxis .= (index . ": {title: '" . translate(yAxis) . "'}")
		}

		series .= "}"
		vAxis .= "}"

		if (this.SelectedChartType = "Scatter") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { title: '" . translate(xAxis) . "', gridlines: { color: 'E0E0E0' } }, " . series . ", " . vAxis . "};")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bar") {
			if (minValue = kUndefined)
				minValue := 0

			if (maxValue = kUndefined)
				maxValue := 0

			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: {minValue: " . minValue . ", maxValue: " . maxValue . "} };")
			; , hAxis: { viewWindowMode: 'pretty' }, vAxis: { viewWindowMode: 'pretty' }
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bubble") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { title: '" . translate(xAxis) . "', viewWindowMode: 'pretty' }, vAxis: { title: '" . translate(yAxises[1]) . "', viewWindowMode: 'pretty' }, colorAxis: { legend: {position: 'none'}, colors: ['blue', 'red'] }, sizeAxis: { maxSize: 15 } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BubbleChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Line") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8' };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}

		this.showTelemetryChart(drawChartFunction)
	}

	getSimulators() {
		return new SessionDatabase().getSimulators()
	}

	getCars(simulator) {
		return new SessionDatabase().getCars(simulator)
	}

	getTracks(simulator, car) {
		return new SessionDatabase().getTracks(simulator, car)
	}

	loadSimulator(simulator, force := false) {
		local window, sessionDB, drivers, ignore, id, index, car, carNames, cars, settings

		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window

			Gui %window%:Default

			this.iSelectedSimulator := simulator

			settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

			setConfigurationValue(settings, "Strategy Workbench", "Simulator", simulator)

			writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

			sessionDB := new SessionDatabase()

			this.iAvailableDrivers := sessionDB.getAllDrivers(simulator)

			drivers := []

			for ignore, id in this.AvailableDrivers
				drivers.Push(sessionDB.getDriverName(simulator, id))

			GuiControl, , simDriverDropDown, % "|" . values2String("|", drivers*)
			GuiControl Choose, simDriverDropDown, 0

			GuiControl, , driverDropDown, |
			GuiControl Choose, driverDropDown, 0

			this.iSelectedDrivers := false

			Gui ListView, % this.DriversListView

			LV_Delete()

			LV_Add("", "1+", sessionDB.getDriverName(simulator, sessionDB.ID))

			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")

			this.iStintDrivers := [sessionDB.ID]

			cars := this.getCars(simulator)
			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := sessionDB.getCarName(simulator, car)

			GuiControl Choose, simulatorDropDown, % inList(this.getSimulators(), simulator)
			GuiControl, , carDropDown, % "|" . values2String("|", carNames*)

			this.loadCar((cars.Length() > 0) ? cars[1] : false, true)
		}
	}

	loadCar(car, force := false) {
		local window, tracks, settings

		if (force || (car != this.SelectedCar)) {
			window := this.Window

			Gui %window%:Default

			this.iSelectedCar := car

			settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

			setConfigurationValue(settings, "Strategy Workbench", "Car", car)

			writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

			tracks := this.getTracks(this.SelectedSimulator, car)

			GuiControl Choose, carDropDown, % inList(this.getCars(this.SelectedSimulator), car)
			GuiControl, , trackDropDown, % "|" . values2String("|", map(tracks, ObjBindMethod(new SessionDatabase(), "getTrackName", this.SelectedSimulator))*)

			this.loadTrack((tracks.Length() > 0) ? tracks[1] : false, true)
		}
	}

	loadTrack(track, force := false) {
		local window, simulator, car, settings

		if (force || (track != this.SelectedTrack)) {
			window := this.Window

			Gui %window%:Default

			simulator := this.SelectedSimulator
			car := this.SelectedCar

			this.iSelectedTrack := track

			settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

			setConfigurationValue(settings, "Strategy Workbench", "Track", track)

			writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

			GuiControl Choose, trackDropDown, % inList(this.getTracks(simulator, car), track)

			this.loadTyreCompounds(simulator, car, track)

			this.loadWeather(this.SelectedWeather, true)
		}
	}

	loadWeather(weather, force := false) {
		local window

		if (force || (this.SelectedWeather != weather)) {
			window := this.Window

			Gui %window%:Default

			this.iSelectedWeather := weather

			GuiControl Choose, weatherDropDown, % inList(kWeatherConditions, weather)

			this.loadDataType(this.SelectedDataType, true)
		}
	}

	setTemperatures(airTemperature, trackTemperature) {
		this.iAirTemperature := airTemperature
		this.iTrackTemperature := trackTemperature
	}

	loadDataType(dataType, force := false, reload := false) {
		local window, compound, compoundColor, telemetryDB, ignore, column, categories, field, category, value
		local sessionDB, driverNames, index, names, schema, availableCompounds

		if (force || (this.SelectedDataType != dataType)) {
			this.showTelemetryChart(false)

			window := this.Window

			Gui %window%:Default

			this.iSelectedDataType := dataType
			this.iSelectedDrivers := false

			telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar
											   , this.SelectedTrack, this.SelectedDrivers)

			Gui ListView, % this.DataListView

			LV_Delete()

			while LV_DeleteCol(1)
				ignore := 1

			if (this.SelectedDataType = "Electronics") {
				for ignore, column in map(["Compound", "Map", "#"], "translate")
					LV_InsertCol(A_Index, "", column)

				categories := telemetryDB.getMapsCount(this.SelectedWeather)
				field := "Map"
			}
			else if (this.SelectedDataType = "Tyres") {
				for ignore, column in map(["Compound", "Pressure", "#"], "translate")
					LV_InsertCol(A_Index, "", column)

				categories := telemetryDB.getPressuresCount(this.SelectedWeather)
				field := "Tyre.Pressure"
			}

			availableCompounds := []

			for ignore, category in categories {
				value := category[field]

				if (value = "n/a")
					value := translate(value)

				compound := category["Tyre.Compound"]
				compoundColor := category["Tyre.Compound.Color"]

				LV_Add("", translate(compound(compound, compoundColor)), value, category.Count)

				compound := compound(compound, compoundColor)

				if !inList(availableCompounds, compound)
					availableCompounds.Push(compound)
			}

			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")

			this.iAvailableCompounds := availableCompounds

			GuiControl, , compoundDropDown, % "|" . values2String("|", map(availableCompounds, "translate")*)

			if (availableCompounds.Length() == 0) {
				GuiControl, , driverDropDown, |
				GuiControl, , dataXDropDown, |
				GuiControl, , dataY1DropDown, |
				GuiControl, , dataY2DropDown, |
				GuiControl, , dataY3DropDown, |
			}
			else if !reload {
				sessionDB := new SessionDatabase()

				driverNames := sessionDB.getAllDrivers(this.SelectedSimulator, true)

				for index, names in driverNames
					driverNames[index] := values2String(", ", names*)

				GuiControl, , driverDropDown, % "|" . values2String("|", translate("All"), driverNames*)

				if this.SelectedDrivers {
					index := inList(this.AvailableDrivers, this.SelectedDrivers[1])

					if index
						GuiControl Choose, driverDropDown, % (index + 1)
					else {
						GuiControl Choose, driverDropDown, 1

						this.iSelectedDrivers := false
					}
				}
				else
					GuiControl Choose, driverDropDown, 1

				this.iSelectedDrivers := false

				schema := filterSchema(telemetryDB.getSchema(dataType, true))

				GuiControl, , dataXDropDown, % "|" . values2String("|", map(schema, "translate")*)
				GuiControl, , dataY1DropDown, % "|" . values2String("|", map(schema, "translate")*)
				GuiControl, , dataY2DropDown, % "|" . translate("None") . "|" . values2String("|", map(schema, "translate")*)
				GuiControl, , dataY3DropDown, % "|" . translate("None") . "|" . values2String("|", map(schema, "translate")*)

				if (dataType = "Electronics") {
					GuiControl Choose, dataXDropDown, % inList(schema, "Map")
					GuiControl Choose, dataY1DropDown, % inList(schema, "Fuel.Consumption")

					GuiControl Choose, dataY2DropDown, 1
				}
				else if (dataType = "Tyres") {
					GuiControl Choose, dataXDropDown, % inList(schema, "Tyre.Laps")
					GuiControl Choose, dataY1DropDown, % inList(schema, "Tyre.Pressure")
					GuiControl Choose, dataY2DropDown, % inList(schema, "Tyre.Temperature") + 1
				}

				GuiControl Choose, dataY3DropDown, 1
			}

			this.loadCompound((availableCompounds.Length() > 0) ? availableCompounds[1] : false, true)
		}
	}

	loadDriver(driver, force := false) {
		local window

		if (force || (((driver == true) || (driver == false)) && (this.SelectedDrivers != false))
				  || !inList(this.SelectedDrivers, driver)) {
			window := this.Window

			Gui %window%:Default

			if driver {
				GuiControl Choose, driverDropDown, % ((driver = true) ? 1 : (inList(this.AvailableDrivers, driver) + 1))

				this.iSelectedDrivers := ((driver == true) ? false : [driver])
			}
			else {
				GuiControl Choose, driverDropDown, 0

				this.iSelectedDrivers := false
			}

			if this.SelectedCompound
				this.loadChart(this.SelectedChartType)

			this.updateState()
		}
	}

	loadTyreCompounds(simulator, car, track) {
		local window := this.Window
		local compounds := new SessionDatabase().getTyreCompounds(simulator, car, track)
		local translatedCompounds, choices, index, ignore, compound

		Gui %window%:Default

		this.iTyreCompounds := compounds

		translatedCompounds := map(compounds, "translate")
		choices := ("|" . values2String("|", translatedCompounds*))

		GuiControl, , tyreSetDropDown, %choices%
		GuiControl, , simCompoundDropDown, %choices%
		GuiControl, , strategyCompoundDropDown, %choices%

		index := inList(compounds, this.SelectedCompound[true])

		if ((index == 0) && (compounds.Length() > 0))
			index := 1

		GuiControl Choose, tyreSetDropDown, %index%
		GuiControl Choose, simCompoundDropDown, %index%
		GuiControl Choose, strategyCompoundDropDown, %index%

		Gui ListView, % this.TyreSetListView

		LV_Delete()

		for ignore, compound in compounds
			LV_Add("", translate(compound), 99)

		LV_ModifyCol()
	}

	loadCompound(compound, force := false) {
		local window
		local compoundColor

		if compound
			compound := normalizeCompound(compound)

		if (force || (this.SelectedCompound[true] != compound)) {
			window := this.Window

			Gui %window%:Default

			if compound {
				GuiControl Choose, compoundDropDown, % inList(this.AvailableCompounds, compound)

				compoundColor := false

				splitCompound(compound, compound, compoundColor)

				this.iSelectedCompound := compound
				this.iSelectedCompoundColor := compoundColor

				this.loadChart(this.SelectedChartType)
			}
			else {
				GuiControl Choose, compoundDropDown, 0

				this.showTelemetryChart(false)

				this.iSelectedCompound := false
				this.iSelectedCompoundColor := false
			}

			this.updateState()
		}
	}

	loadChart(chartType) {
		local window := this.Window
		local telemetryDB, records, schema, xAxis, yAxises

		local compound

		Gui %window%:Default

		this.iSelectedChartType := chartType

		GuiControl Choose, chartTypeDropDown, % inList(["Scatter", "Bar", "Bubble", "Line"], chartType)

		telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar
										   , this.SelectedTrack, this.SelectedDrivers)

		if (this.SelectedDataType = "Electronics")
			records := telemetryDB.getElectronicEntries(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		else if (this.SelectedDataType = "Tyres")
			records := telemetryDB.getTyreEntries(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		else
			records := []

		GuiControlGet dataXDropDown
		GuiControlGet dataY1DropDown
		GuiControlGet dataY2DropDown
		GuiControlGet dataY3DropDown

		schema := filterSchema(telemetryDB.getSchema(this.SelectedDataType, true))

		xAxis := schema[dataXDropDown]
		yAxises := Array(schema[dataY1DropDown])

		if (dataY2DropDown > 1)
			yAxises.Push(schema[dataY2DropDown - 1])

		if (dataY3DropDown > 1)
			yAxises.Push(schema[dataY3DropDown - 1])

		this.showDataPlot(records, xAxis, yAxises)

		this.updateState()
	}

	selectSessionType(sessionType) {
		this.iSelectedSessionType := sessionType

		if (sessionType = "Duration") {
			GuiControl, , sessionLengthLabel, % translate("Minutes")
			GuiControl, , simSessionResultLabel, % translate("Laps")
		}
		else {
			GuiControl, , sessionLengthLabel, % translate("Laps")
			GuiControl, , simSessionResultLabel, % translate("Seconds")
		}
	}

	chooseSettingsMenu(line) {
		local window := this.Window
		local simulator := this.SelectedSimulator
		local car := this.SelectedCar
		local track := this.SelectedTrack
		local compound, strategy, pitstopRule
		local ignore, descriptor, sessionDB, directory, numPitstops, name, pitstop, compound, compoundColor
		local title, simulator, car, track, simulatorCode, dirName, file, settings, settingsDB
		local telemetryDB, fastestLapTime, row, lapTime, prefix, data, fuelCapacity, initialFuelAmount, map
		local validators, index, fileName, validator, index, forecast, time, hour, minute

		protectionOn(true, true)

		try {
			Gui %window%:Default

			switch line {
				case 3: ; "Load from Strategy"
					if (simulator && car && track) {
						strategy := this.SelectedStrategy

						if strategy {
							GuiControl, , pitstopDeltaEdit, % strategy.PitstopDelta
							GuiControl, , pitstopTyreServiceEdit, % strategy.PitstopTyreService

							pitstopFuelServiceEdit := strategy.PitstopFuelService

							if IsObject(pitstopFuelServiceEdit) {
								pitstopFuelServiceRuleDropDown := (1 + (pitstopFuelServiceEdit[1] != "Fixed"))
								GuiControl Choose, pitstopFuelServiceRuleDropDown, % pitstopFuelServiceRuleDropDown

								GuiControl, , pitstopFuelServiceLabel, % translate(["Seconds", "Seconds (Refuel of 10 litres)"][pitstopFuelServiceRuleDropDown])

								pitstopFuelServiceEdit := pitstopFuelServiceEdit[2]
							}
							else {
								GuiControl Choose, pitstopFuelServiceRuleDropDown, % 2
								GuiControl, , pitstopFuelServiceLabel, % translate("Seconds (Refuel of 10 litres)")
							}

							GuiControl, , pitstopFuelServiceEdit, %pitstopFuelServiceEdit%
							GuiControl Choose, pitstopServiceDropDown, % (strategy.PitstopServiceOrder = "Simultaneous") ? 1 : 2
							GuiControl, , safetyFuelEdit, % strategy.SafetyFuel
							GuiControl, , fuelCapacityEdit, % strategy.FuelCapacity

							this.iSelectedValidator := strategy.Validator

							pitstopRule := strategy.PitstopRule

							if !pitstopRule {
								GuiControl Choose, pitstopRequirementsDropDown, 1

								pitstopWindowEdit := ""
							}
							else if IsObject(pitstopRule) {
								GuiControl Choose, pitstopRequirementsDropDown, 3

								pitstopWindowEdit := values2String("-", pitstopRule*)
							}
							else {
								GuiControl Choose, pitstopRequirementsDropDown, 2

								pitstopWindowEdit := pitstopRule
							}

							GuiControl, , pitstopWindowEdit, %pitstopWindowEdit%
							choosePitstopRequirements()

							if pitstopRule {
								GuiControl Choose, refuelRequirementsDropDown, % inList(["Optional", "Required", "Always", "Disallowed"], strategy.RefuelRule)
								GuiControl Choose, tyreChangeRequirementsDropDown, % inList(["Optional", "Required", "Always", "Disallowed"], strategy.TyreChangeRule)
							}
							else {
								GuiControl Choose, refuelRequirementsDropDown, % inList(["Optional", "Always", "Disallowed"], strategy.RefuelRule)
								GuiControl Choose, tyreChangeRequirementsDropDown, % inList(["Optional", "Always", "Disallowed"], strategy.TyreChangeRule)
							}

							Gui ListView, % this.TyreSetListView

							LV_Delete()

							for ignore, descriptor in strategy.TyreSets
								LV_Add("", translate(compound(descriptor[1], descriptor[2])), descriptor[3])

							LV_ModifyCol()

							sessionDB := new SessionDatabase()

							this.iStintDrivers := []

							numPitstops := strategy.Pitstops.Length()

							name := sessionDB.getDriverName(simulator, strategy.Driver)

							Gui ListView, % this.DriversListView

							LV_Delete()

							LV_Add("", (numPitstops = 0) ? "1+" : 1, name)

							this.StintDrivers.Push((name = "John Doe (JD)") ? false : strategy.Driver)

							for ignore, pitstop in strategy.Pitstops {
								name := sessionDB.getDriverName(simulator, pitstop.Driver)

								LV_Add("", (numPitstops = A_Index) ? ((A_Index + 1) . "+") : (A_Index + 1), name)

								this.StintDrivers.Push((name = "John Doe (JD)") ? false : pitstop.Driver)
							}

							LV_ModifyCol()

							Gui ListView, % this.WeatherListView

							LV_Delete()

							for ignore, forecast in strategy.WeatherForecast {
								time := "20200101000000"
								hour := Floor(forecast[1] / 60)
								minute := (forecast[1] - (hour * 60))

								EnvAdd time, %hour%, Hours
								EnvAdd time, %minute%, Minutes

								FormatTime time, %time%, HH:mm

								LV_Add("", time, translate(forecast[2]), forecast[3], forecast[4])
							}

							LV_ModifyCol()

							Loop 4
								LV_ModifyCol(A_Index, "AutoHdr")

							if (strategy.SessionType = "Duration") {
								GuiControl, , sessionTypeDropDown, 1
								GuiControl, , sessionLengthlabel, % translate("Minutes")
							}
							else {
								GuiControl, , sessionTypeDropDown, 2
								GuiControl, , sessionLengthlabel, % translate("Laps")
							}

							GuiControl, , sessionLengthEdit, % Round(strategy.SessionLength)

							GuiControl, , stintLengthEdit, % strategy.StintLength
							GuiControl, , formationLapCheck, % strategy.FormationLap
							GuiControl, , postRaceLapCheck, % strategy.PostRaceLap

							compound := strategy.TyreCompound
							compoundColor := strategy.TyreCompoundColor

							GuiControl Choose, simCompoundDropDown, % inList(this.TyreCompounds, compound(compound, compoundColor))

							simAvgLapTimeEdit := Round(strategy.AvgLapTime, 1)
							GuiControl, , simAvgLapTimeEdit, %simAvgLapTimeEdit%

							simFuelConsumptionEdit := Round(strategy.FuelConsumption, 2)
							GuiControl, , simFuelConsumptionEdit, %simFuelConsumptionEdit%

							GuiControl, , simMaxTyreLapsEdit, % Round(strategy.MaxTyreLaps)

							GuiControl, , simInitialFuelAmountEdit, % Round(strategy.RemainingFuel)
							GuiControl, , simMapEdit, % strategy.Map

							GuiControl, , simConsumptionVariation, % strategy.ConsumptionVariation
							GuiControl, , simTyreUsageVariation, % strategy.TyreUsageVariation
							GuiControl, , simtyreCompoundVariation, % strategy.TyreCompoundVariation
							GuiControl, , simInitialFuelVariation, % strategy.InitialFuelVariation

							if (strategy.UseInitialConditions && strategy.UseTelemetryData)
								simInputDropDown := 3
							else if strategy.UseTelemetryData
								simInputDropDown := 2
							else
								simInputDropDown := 1

							GuiControl Choose, simInputDropDown, %simInputDropDown%

							this.updateState()
							this.updateSettingsMenu()
						}
						else {
							title := translate("Information")

							OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
							MsgBox 262192, %title%, % translate("There is no current Strategy.")
							OnMessage(0x44, "")
						}
					}
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You must first select a car and a track.")
						OnMessage(0x44, "")
					}
				case 4: ; "Load from Settings..."
					if (simulator && car && track) {
						if GetKeyState("Ctrl", "P") {
							sessionDB := new SessionDatabase()

							directory := sessionDB.DatabasePath
							simulatorCode := sessionDB.getSimulatorCode(simulator)

							dirName = %directory%User\%simulatorCode%\%car%\%track%\Race Settings

							FileCreateDir %dirName%

							title := translate("Load Race Settings...")

							Gui +OwnDialogs

							OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
							FileSelectFile file, 1, %dirName%, %title%, Settings (*.settings)
							OnMessage(0x44, "")
						}
						else
							file := getFileName("Race.settings", kUserConfigDirectory)

						if (file != "") {
							settings := readConfiguration(file)

							if (settings.Count() > 0) {
								GuiControl, , sessionTypeDropDown, 1
								GuiControl, , sessionLengthEdit, % Round(getConfigurationValue(settings, "Session Settings", "Duration", 3600) / 60)
								GuiControl, , sessionLengthlabel, % translate("Minutes")
								GuiControl, , formationLapCheck, % getConfigurationValue(settings, "Session Settings", "Lap.Formation", false)
								GuiControl, , postRaceLapCheck, % getConfigurationValue(settings, "Session Settings", "Lap.PostRace", false)

								GuiControl, , pitstopDeltaEdit, % getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta", 60)
								GuiControl, , pitstopTyreServiceEdit, % getConfigurationValue(settings, "Strategy Settings", "Service.Tyres", 30)

								pitstopFuelServiceEdit := string2Values(":", getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", 1.5))

								if (pitstopFuelServiceEdit.Length() = 1) {
									pitstopFuelServiceEdit := pitstopFuelServiceEdit[1]

									GuiControl Choose, pitstopFuelServiceRuleDropDown, % 2
									GuiControl, , pitstopFuelServiceLabel, % translate("Seconds (Refuel of 10 litres)")
								}
								else {
									pitstopFuelServiceRuleDropDown := (1 + (pitstopFuelServiceEdit[1] != "Fixed"))

									GuiControl Choose, pitstopFuelServiceRuleDropDown, % pitstopFuelServiceRuleDropDown
									GuiControl, , pitstopFuelServiceLabel, % translate(["Seconds", "Seconds (Refuel of 10 litres)"][pitstopFuelServiceRuleDropDown])

									pitstopFuelServiceEdit := pitstopFuelServiceEdit[2]
								}

								GuiControl, , pitstopFuelServiceEdit, %pitstopFuelServiceEdit%
								GuiControl Choose, pitstopServiceDropDown, % (getConfigurationValue(settings, "Strategy Settings", "Service.Order", "Simultaneous") = "Simultaneous") ? 1 : 2
								GuiControl, , safetyFuelEdit, % getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin", 3)

								compound := getConfigurationValue(settings, "Session Setup", "Tyre.Compound", "Dry")
								compoundColor := getConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")

								GuiControl Choose, simCompoundDropDown, % inList(this.TyreCompounds, compound(compound, compoundColor))

								simAvgLapTimeEdit := Round(getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", 120), 1)
								GuiControl, , simAvgLapTimeEdit, %simAvgLapTimeEdit%

								simFuelConsumptionEdit := Round(getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", 3.0), 2)
								GuiControl, , simFuelConsumptionEdit, %simFuelConsumptionEdit%
							}
						}
					}
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You must first select a car and a track.")
						OnMessage(0x44, "")
					}
				case 5:
					if (simulator && car && track) {
						settingsDB := new SettingsDatabase()

						settings := new SettingsDatabase().loadSettings(simulator, car, track, this.SelectedWeather)

						if (settings.Count() > 0) {
							if (getConfigurationValue(settings, "Session Settings", "Duration", kUndefined) != kUndefined) {
								GuiControl, , sessionTypeDropDown, 1
								GuiControl, , sessionLengthEdit, % Round(getConfigurationValue(settings, "Session Settings", "Duration") / 60)
								GuiControl, , sessionLengthlabel, % translate("Minutes")
							}

							if (getConfigurationValue(settings, "Session Settings", "Lap.Formation", kUndefined) != kUndefined)
								GuiControl, , formationLapCheck, % getConfigurationValue(settings, "Session Settings", "Lap.Formation")

							if (getConfigurationValue(settings, "Session Settings", "Lap.PostRace", kUndefined) != kUndefined)
								GuiControl, , postRaceLapCheck, % getConfigurationValue(settings, "Session Settings", "Lap.PostRace")

							if (getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta", kUndefined) != kUndefined)
								GuiControl, , pitstopDeltaEdit, % getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta")

							if (getConfigurationValue(settings, "Strategy Settings", "Service.Tyres", kUndefined) != kUndefined)
								GuiControl, , pitstopTyreServiceEdit, % getConfigurationValue(settings, "Strategy Settings", "Service.Tyres")

							if (getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", kUndefined) != kUndefined) {
								pitstopFuelServiceEdit := getConfigurationValue(settings, "Strategy Settings", "Service.Refuel")

								if (getConfigurationValue(settings, "Strategy Settings", "Service.Refuel.Rule", false) = "Fixed") {
									GuiControl Choose, pitstopFuelServiceRuleDropDown, % 1
									GuiControl, , pitstopFuelServiceLabel, % translate("Seconds")
								}
								else {
									GuiControl Choose, pitstopFuelServiceRuleDropDown, % 2
									GuiControl, , pitstopFuelServiceLabel, % translate("Seconds (Refuel of 10 litres)")
								}

								GuiControl, , pitstopFuelServiceEdit, %pitstopFuelServiceEdit%
							}

							if (getConfigurationValue(settings, "Strategy Settings", "Service.Order", kUndefined) != kUndefined)
								GuiControl Choose, pitstopServiceDropDown, % (getConfigurationValue(settings, "Strategy Settings", "Service.Order") = "Simultaneous") ? 1 : 2

							if (getConfigurationValue(settings, "Strategy Settings", "Fuel.SafetyMargin", kUndefined) != kUndefined)
								GuiControl, , safetyFuelEdit, % getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin")

							if (getConfigurationValue(settings, "Session Settings", "Fuel.Amount", kUndefined) != kUndefined)
								GuiControl, , fuelCapacityEdit, % getConfigurationValue(settings, "Session Settings", "Fuel.Amount")

							if ((getConfigurationValue(settings, "Session Settings", "Tyre.Compound", kUndefined) != kUndefined)
							 && (getConfigurationValue(settings, "Session Settings", "Tyre.Compound.Color", kUndefined) != kUndefined)) {
								compound := getConfigurationValue(settings, "Session Setup", "Tyre.Compound")
								compoundColor := getConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color")

								GuiControl Choose, simCompoundDropDown, % inList(this.TyreCompounds, compound(compound, compoundColor))
							}

							if (getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", kUndefined) != kUndefined) {
								simAvgLapTimeEdit := Round(getConfigurationValue(settings, "Session Settings", "Lap.AvgTime"), 1)

								GuiControl, , simAvgLapTimeEdit, %simAvgLapTimeEdit%
							}

							if (getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", kUndefined) != kUndefined) {
								simFuelConsumptionEdit := Round(getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption"), 2)

								GuiControl, , simFuelConsumptionEdit, %simFuelConsumptionEdit%
							}
						}
					}
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You must first select a car and a track.")
						OnMessage(0x44, "")
					}
				case 6: ; "Update from Telemetry..."
					if (simulator && car && track) {
						telemetryDB := new TelemetryDatabase(simulator, car, track, this.SelectedDrivers)

						fastestLapTime := false

						for ignore, row in telemetryDB.getMapData(this.SelectedWeather
																, this.SelectedCompound
																, this.SelectedCompoundColor) {
							lapTime := row["Lap.Time"]

							if (!fastestLapTime || (lapTime < fastestLapTime)) {
								fastestLapTime := lapTime

								GuiControl, , simMapEdit, % row["Map"]

								simAvgLapTimeEdit := Round(lapTime, 1)
								GuiControl, , simAvgLapTimeEdit, %simAvgLapTimeEdit%

								simFuelConsumptionEdit := Round(row["Fuel.Consumption"], 2)
								GuiControl, , simFuelConsumptionEdit, %simFuelConsumptionEdit%
							}
						}
					}
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You must first select a car and a track.")
						OnMessage(0x44, "")
					}
				case 7: ; "Import from Simulation..."
					if simulator {
						prefix := new SessionDatabase().getSimulatorCode(simulator)

						if !prefix {
							OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
							title := translate("Warning")
							MsgBox 262192, %title%, % translate("This is not supported for the selected simulator...")
							OnMessage(0x44, "")

							return
						}

						data := readSimulatorData(prefix)

						if ((getConfigurationValue(data, "Session Data", "Car") != this.SelectedCar)
						 || (getConfigurationValue(data, "Session Data", "Track") != this.SelectedTrack))
							return
						else {
							fuelCapacity := getConfigurationValue(data, "Session Data", "FuelAmount", kUndefined)
							initialFuelAmount := getConfigurationValue(data, "Car Data", "FuelRemaining", kUndefined)

							if (fuelCapacity != kUndefined)
								GuiControl, , fuelCapacityEdit, % Round(fuelCapacity)

							if (initialFuelAmount != kUndefined)
								GuiControl, , simInitialFuelAmountEdit, % Round(initialFuelAmount)

							compound := getConfigurationValue(data, "Car Data", "TyreCompound", kUndefined)
							compoundColor := getConfigurationValue(data, "Car Data", "TyreCompoundColor", kUndefined)

							if (compound = kUndefined) {
								compound := getConfigurationValue(data, "Car Data", "TyreCompoundRaw", kUndefined)

								if (compound != kUndefined) {
									compound := new SessionDatabase().getTyreCompoundName(simulator, car, track, compound, false)

									if compound
										splitCompound(compound, compound, compoundColor)
									else
										compound := kUndefined
								}
							}

							if ((compound != kUndefined) && (compoundColor != kUndefined))
								GuiControl Choose, simCompoundDropDown, % inList(this.TyreCompounds, compound(compound, compoundColor))

							map := getConfigurationValue(data, "Car Data", "Map", kUndefined)

							if (map != kUndefined)
								GuiControl, , simMapEdit, % Round(map)
						}
					}
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You must first select a simulation.")
						OnMessage(0x44, "")
					}
				default:
					if (line > 9) {
						validators := []

						if GetKeyState("Ctrl", "P") {
							index := 0

							for ignore, fileName in getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\") {
								SplitPath fileName, , , , validator

								if !inList(validators, validator) {
									if ((++index = (line - 9)) && !InStr(fileName, kResourcesDirectory)) {
										Run notepad %fileName%

										break
									}
								}
								else
									validators.Push(validator)
							}
						}
						else {
							for ignore, fileName in getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\") {
								SplitPath fileName, , , , validator

								if !inList(validators, validator)
									validators.Push(validator)
							}

							validator := validators[line - 9]

							if (this.iSelectedValidator = validator)
								this.iSelectedValidator := false
							else
								this.iSelectedValidator := validator

							this.updateSettingsMenu()
						}
					}
			}
		}
		finally {
			protectionOff(true, true)
		}
	}

	chooseSimulationMenu(line) {
		local strategy, selectStrategy, title

		switch line {
			case 3: ; "Run Simulation"
				selectStrategy := GetKeyState("Ctrl")

				this.runSimulation()

				if selectStrategy
					this.chooseSimulationMenu(5)
			case 5: ; "Use as Strategy..."
				strategy := this.SelectedScenario

				if strategy
					this.selectStrategy(strategy)
				else {
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					title := translate("Warning")
					MsgBox 262192, %title%, % translate("There is no current scenario. Please run a simulation first...")
					OnMessage(0x44, "")
				}
		}
	}

	chooseStrategyMenu(line) {
		local simulator := this.SelectedSimulator
		local car := this.SelectedCar
		local track := this.SelectedTrack
		local sessionDB := new SessionDatabase()
		local strategy, strategies, simulatorCode, dirName, fileName, configuration, title
		local info, name, files, directory

		if (simulator && car && track) {
			directory := sessionDB.DatabasePath
			simulatorCode := sessionDB.getSimulatorCode(simulator)

			dirName = %directory%User\%simulatorCode%\%car%\%track%\Race Strategies

			FileCreateDir %dirName%
		}
		else
			dirName := ""

		switch line {
			case 3:
				fileName := kUserConfigDirectory . "Race.strategy"

				if FileExist(fileName) {
					configuration := readConfiguration(fileName)

					if (configuration.Count() > 0)
						this.selectStrategy(this.createStrategy(configuration))
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no active Race Strategy.")
					OnMessage(0x44, "")
				}
			case 4: ; "Load Strategy..."
				title := translate("Load Race Strategy...")

				Gui +OwnDialogs

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
				FileSelectFile fileName, 1, %dirName%, %title%, Strategy (*.strategy)
				OnMessage(0x44, "")

				if (fileName != "") {
					configuration := readConfiguration(fileName)

					if (configuration.Count() > 0)
						this.selectStrategy(this.createStrategy(configuration))
				}
			case 5: ; "Save Strategy..."
				if this.SelectedStrategy {
					title := translate("Save Race Strategy...")

					fileName := (((dirName != "") ? (dirName . "\") : "") . this.SelectedStrategy.Name . ".strategy")

					Gui +OwnDialogs

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
					FileSelectFile fileName, S17, %fileName%, %title%, Strategy (*.strategy)
					OnMessage(0x44, "")

					if (fileName != "") {
						if !InStr(fileName, ".strategy")
							fileName := (fileName . ".strategy")

						SplitPath fileName, , , , name

						this.SelectedStrategy.setName(name)

						configuration := newConfiguration()

						this.SelectedStrategy.saveToConfiguration(configuration)

						writeConfiguration(fileName, configuration)

						if ((StrLen(dirName) > 0) && (InStr(fileName, dirName) = 1)) {
							info := sessionDB.readStrategyInfo(simulator, car, track, name . ".strategy")

							setConfigurationValue(info, "Strategy", "Synchronized", false)

							sessionDB.writeStrategyInfo(simulator, car, track, name . ".strategy", info)
						}
					}
				}
			case 7: ; "Compare Strategies..."
				title := translate("Choose two or more Race Strategies for comparison...")

				Gui +OwnDialogs

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Compare", "Cancel"]))
				FileSelectFile files, M1, %dirName%, %title%, Strategy (*.strategy)
				OnMessage(0x44, "")

				strategies := []

				if (files != "") {
					directory := ""

					loop Parse, files, `n
					{
						if (A_Index = 1)
							directory := A_LoopField
						else
							strategies.Push(this.createStrategy(readConfiguration(directory . "\" . A_LoopField)))
					}

					if (strategies.Count() > 1)
						this.compareStrategies(strategies*)
				}
			case 9: ; "Export Strategy..."
				if this.SelectedStrategy {
					configuration := newConfiguration()

					this.SelectedStrategy.saveToConfiguration(configuration)

					writeConfiguration(kUserConfigDirectory . "Race.strategy", configuration)
				}
			case 10: ; "Clear Strategy..."
				deleteFile(kUserConfigDirectory . "Race.strategy")
		}
	}

	selectStrategy(strategy) {
		local window := this.Window
		local compound, avgLapTimes, avgFuelConsumption, ignore, pitstop, compound

		Gui %window%:Default
		Gui ListView, % this.PitstopListView

		LV_Delete()

		avgLapTimes := []
		avgFuelConsumption := []

		for ignore, pitstop in strategy.Pitstops {
			LV_Add("", pitstop.Lap, pitstop.DriverName, Ceil(pitstop.RefuelAmount), pitstop.TyreChange ? translate("x") : "-", pitstop.Map)

			avgLapTimes.Push(pitstop.AvgLapTime)
			avgFuelConsumption.Push(pitstop.FuelConsumption)
		}

		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "Center AutoHdr")
		LV_ModifyCol(4, "AutoHdr")

		GuiControl Text, strategyStartMapEdit, % strategy.Map
		GuiControl Text, strategyStartTCEdit, % strategy.TC
		GuiControl Text, strategyStartABSEdit, % strategy.ABS

		compound := compound(strategy.TyreCompound, strategy.TyreCompoundColor)
		GuiControl Choose, strategyCompoundDropDown, % inList(this.TyreCompounds, compound)

		GuiControl, , strategyPressureFLEdit, % strategy.TyrePressureFL
		GuiControl, , strategyPressureFREdit, % strategy.TyrePressureFR
		GuiControl, , strategyPressureRLEdit, % strategy.TyrePressureRL
		GuiControl, , strategyPressureRREdit, % strategy.TyrePressureRR

		this.showStrategyInfo(strategy)

		this.iSelectedStrategy := strategy
	}

	compareStrategies(strategies*) {
		local strategy, before, after, chart, ignore, laps, exhausted, index, hasData
		local sLaps, html, timeSeries, lapSeries, fuelSeries, tyreSeries, width, chartArea, tableCSS

		before =
		(
			<meta charset='utf-8'>
			<head>
				<style>
					.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
					.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
					.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
				</style>
				<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
				<script type="text/javascript">
					google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
		)

		after =
		(
				</script>
			</head>
		)

		chart := ("function drawChart() {`nvar data = new google.visualization.DataTable();")

		chart .= ("`ndata.addColumn('number', '" . translate("Minute") . "');")

		for ignore, strategy in strategies
			chart .= ("`ndata.addColumn('number', '" . strategy.Name . "');")

		chart .= "`ndata.addRows(["

		laps := []

		for ignore, strategy in strategies
			laps.Push(strategy.getLaps(120))

		loop {
			if (A_Index > 1)
				chart .= ", "

			chart .= ("[" . (A_Index * 2))

			exhausted := true
			index := A_Index

			loop % strategies.Length()
			{
				sLaps := laps[A_Index]

				hasData := (sLaps.Length() >= index)

				chart .= (", " . (hasData ? sLaps[index] : kNull))

				if hasData
					exhausted := false
			}

			chart .= "]"

			if exhausted
				break
		}

		html := ""

		for ignore, strategy in strategies {
			timeSeries := []
			lapSeries := []
			fuelSeries := []
			tyreSeries := []

			if (A_Index > 1)
				html .= "<br><br>"

			html .= ("<div id=""header""><i><b>" .  translate("Strategy: ") . strategy.Name . "</b></i></div>")

			html .= ("<br>" . this.createStrategyInfo(strategy))

			html .= ("<br>" . this.createSetupInfo(strategy))

			html .= ("<br>" . this.createStintsInfo(strategy, timeSeries, lapSeries, fuelSeries, tyreSeries))
		}

		width := (chartViewer.Width - 5)

		chart .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Minute") . "' }, vAxis: { title: '" . translate("Lap") . "', viewWindow: { min: 0 } }, backgroundColor: 'D8D8D8' };`n")

		chart .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")

		chartArea := ("<div id=""header""><i><b>" . translate("Performance") . "</b></i></div><br><div id=""chart_id"" style=""width: " . width . "px; height: 348px"">")

		tableCSS := getTableCSS()

		html := ("<html>" . before . chart . after . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } </style>" . html . "<br><hr style=""width: 50`%""><br>" . chartArea . "</body></html>")

		this.showComparisonChart(html)
	}

	createStrategy(nameOrConfiguration, driver := false) {
		local name := nameOrConfiguration
		local theStrategy, name

		if !IsObject(nameOrConfiguration)
			nameOrConfiguration := false

		theStrategy := new Strategy(this, nameOrConfiguration, driver)

		if (name && !IsObject(name))
			theStrategy.setName(name)

		return theStrategy
	}

	getStrategySettings(ByRef simulator, ByRef car, ByRef track, ByRef weather, ByRef airTemperature, ByRef trackTemperature
					  , ByRef sessionType, ByRef sessionLength
					  , ByRef maxTyreLaps, ByRef tyreCompound, ByRef tyreCompoundColor, ByRef tyrePressures) {
		local window := this.Window
		local compound, compoundColor, telemetryDB, lowestLapTime, ignore, row, lapTime, settings

		Gui %window%:Default

		GuiControlGet sessionLengthEdit
		GuiControlGet simMaxTyreLapsEdit
		GuiControlGet simCompoundDropDown

		simulator := this.SelectedSimulator
		car := this.SelectedCar
		track := this.SelectedTrack

		weather := this.SelectedWeather
		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature

		sessionType := this.SelectedSessionType
		sessionLength := sessionLengthEdit

		compound := false
		compoundColor := false

		splitCompound(this.TyreCompounds[simCompoundDropDown], compound, compoundColor)

		tyreCompound := compound
		tyreCompoundColor := compoundColor

		maxTyreLaps := simMaxTyreLapsEdit

		tyrePressures := false

		telemetryDB := this.TelemetryDatabase
		lowestLapTime := false

		for ignore, row in telemetryDB.getLapTimePressures(weather, tyreCompound, tyreCompoundColor) {
			lapTime := row["Lap.Time"]

			if (!lowestLapTime || (lapTime < lowestLapTime)) {
				lowestLapTime := lapTime

				tyrePressures := [Round(row["Tyre.Pressure.Front.Left"], 1), Round(row["Tyre.Pressure.Front.Right"], 1)
								, Round(row["Tyre.Pressure.Rear.Left"], 1), Round(row["Tyre.Pressure.Rear.Right"], 1)]
			}
		}

		if !tyrePressures {
			settings := new SettingsDatabase().loadSettings(simulator, car, track, weather)

			if (tyreCompound = "Dry")
				tyrePressures := [getConfigurationValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
								, getConfigurationValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
								, getConfigurationValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
								, getConfigurationValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)]
			else if (tyreCompound = "Intermediate") {
				if (getConfigurationValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.FL", kUndefined) != kUndefined)
					tyrePressures := [getConfigurationValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.FL", 29.0)
									, getConfigurationValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.FR", 29.0)
									, getConfigurationValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.RL", 29.0)
									, getConfigurationValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.RR", 29.0)]
				else
					tyrePressures := [getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
									, getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
									, getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
									, getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)]
			}
			else
				tyrePressures := [getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
								, getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
								, getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
								, getConfigurationValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)]
		}
	}

	getPitstopRules(ByRef validator, ByRef pitstopRule, ByRef refuelRule, ByRef tyreChangeRule, ByRef tyreSets) {
		local window := this.Window
		local result := true
		local compound, compoundColor, translatedCompounds, count

		Gui %window%:Default

		validatePitstopRule("Full")

		GuiControlGet pitstopRequirementsDropDown
		GuiControlGet pitstopWindowEdit
		GuiControlGet tyreChangeRequirementsDropDown
		GuiControlGet refuelRequirementsDropDown

		validator := this.SelectedValidator

		switch pitstopRequirementsDropDown {
			case 1:
				pitstopRule := false
			case 2:
				if pitstopWindowEdit is Integer
					pitstopRule := Max(pitstopWindowEdit, 1)
				else {
					pitstopRule := 1

					result := false
				}

				; GuiControl, , pitstopWindowEdit, %pitstopRule%
			case 3:
				window := string2Values("-", pitstopWindowEdit)

				if (window.Length() = 2)
					pitstopRule := [Round(window[1]), Round(window[2])]
				else {
					pitstopRule := [25, 35]

					result := false
				}

				; GuiControl, , pitstopWindowEdit, % values2String("-", pitstopRule*)
		}

		if (pitstopRequirementsDropDown > 1) {
			refuelRule := ["Optional", "Required", "Always", "Disallowed"][refuelRequirementsDropDown]
			tyreChangeRule := ["Optional", "Required", "Always", "Disallowed"][tyreChangeRequirementsDropDown]
		}
		else {
			refuelRule := ["Optional", "Always", "Disallowed"][refuelRequirementsDropDown]
			tyreChangeRule := ["Optional", "Always", "Disallowed"][tyreChangeRequirementsDropDown]
		}

		Gui ListView, % this.TyreSetListView

		translatedCompounds := map(this.TyreCompounds, "translate")
		tyreSets := []

		loop % LV_GetCount()
		{
			LV_GetText(compound, A_Index, 1)
			LV_GetText(count, A_Index, 2)

			splitCompound(this.TyreCompounds[inList(translatedCompounds, compound)], compound, compoundColor)

			tyreSets.Push(Array(compound, compoundColor, count))
		}

		return result
	}

	getSessionSettings(ByRef stintLength, ByRef formationLap, ByRef postRaceLap, ByRef fuelCapacity, ByRef safetyFuel
					 , ByRef pitstopDelta, ByRef pitstopFuelService, ByRef pitstopTyreService, ByRef pitstopServiceOrder) {
		local window := this.Window

		Gui %window%:Default

		GuiControlGet stintLengthEdit
		GuiControlGet formationLapCheck
		GuiControlGet postRaceLapCheck
		GuiControlGet fuelCapacityEdit
		GuiControlGet safetyFuelEdit

		GuiControlGet pitstopDeltaEdit
		GuiControlGet pitstopTyreServiceEdit
		GuiControlGet pitstopFuelServiceRuleDropDown
		GuiControlGet pitstopFuelServiceEdit
		GuiControlGet pitstopServiceDropDown

		stintLength := stintLengthEdit
		formationLap := formationLapCheck
		postRaceLap := postRaceLapCheck
		fuelCapacity := fuelCapacityEdit
		safetyFuel := safetyFuelEdit
		pitstopDelta := pitstopDeltaEdit
		pitstopFuelService := [["Fixed", "Dynamic"][pitstopFuelServiceRuleDropDown], pitstopFuelServiceEdit]
		pitstopTyreService := pitstopTyreServiceEdit
		pitstopServiceOrder := ((pitstopServiceDropDown == 1) ? "Simultaneous" : "Sequential")
	}

	getSessionWeather(minute, ByRef weather, ByRef airTemperature, ByRef trackTemperature) {
		local window := this.Window
		local rows, ignore, time, tWeather, tAirTemperature, tTrackTemperature, candidate, weathers
		local hour, cHour, cMinute

		weather := this.SelectedWeather
		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature

		Gui %window%:Default

		Gui ListView, % this.WeatherListView

		rows := LV_GetCount()

		if (rows > 0) {
			weathers := []

			loop % rows
			{
				LV_GetText(time, A_Index, 1)
				LV_GetText(tWeather, A_Index, 2)
				LV_GetText(tAirTemperature, A_Index, 3)
				LV_GetText(tTrackTemperature, A_Index, 4)

				weathers.Push(Array(time, kWeatherConditions[inList(map(kWeatherConditions, "translate"), tWeather)]
								  , tAirTemperature, tTrackTemperature))
			}

			bubbleSort(weathers, "compareTime")

			hour := Floor(minute / 60)
			minute := minute - (hour * 60)

			for ignore, candidate in weathers {
				time := string2Values(":", candidate[1])
				cHour := (0 + time[1])
				cMinute := (0 + time[2])

				if ((cHour < hour) || ((cHour = hour) && (cMinute <= minute))) {
					weather := candidate[2]
					airTemperature := candidate[3]
					trackTemperature := candidate[4]
				}
			}
		}
	}

	getStartConditions(ByRef initialStint, ByRef initialLap, ByRef initialStintTime, ByRef initialSessionTime
					 , ByRef initialTyreLaps, ByRef initialFuelAmount
					 , ByRef initialMap, ByRef initialFuelConsumption, ByRef initialAvgLapTime) {
		local window := this.Window

		Gui %window%:Default

		GuiControlGet simMaxTyreLapsEdit
		GuiControlGet simInitialFuelAmountEdit
		GuiControlGet simMapEdit
		GuiControlGet simFuelConsumptionEdit
		GuiControlGet simAvgLapTimeEdit

		initialStint := 1
		initialLap := 0
		initialStintTime := 0
		initialSessionTime := 0
		initialTyreLaps := 0
		initialFuelAmount := simInitialFuelAmountEdit
		initialMap := simMapEdit
		initialFuelConsumption := simFuelConsumptionEdit
		initialAvgLapTime := simAvgLapTimeEdit
	}

	getSimulationSettings(ByRef useInitialConditions, ByRef useTelemetryData
						, ByRef consumptionVariation, ByRef initialFuelVariation, ByRef tyreUsageVariation, ByRef tyreCompoundVariation) {
		local window := this.Window

		Gui %window%:Default

		GuiControlGet simInputDropDown

		GuiControlGet simConsumptionVariation
		GuiControlGet simInitialFuelVariation
		GuiControlGet simTyreUsageVariation
		GuiControlGet simtyreCompoundVariation

		useInitialConditions := ((simInputDropDown == 1) || (simInputDropDown == 3))
		useTelemetryData := (simInputDropDown > 1)

		consumptionVariation := simConsumptionVariation
		initialFuelVariation := simInitialFuelVariation
		tyreUsageVariation := simTyreUsageVariation
		tyreCompoundVariation := simtyreCompoundVariation
	}

	getStintDriver(stintNumber, ByRef driverID, ByRef driverName) {
		local numDrivers := this.StintDrivers.Length()

		if (numDrivers == 0) {
			driverID := false
			driverName := "John Doe (JD)"
		}
		else if (numDrivers >= stintNumber) {
			driverID := this.StintDrivers[stintNumber]
			driverName := new SessionDatabase().getDriverName(this.SelectedSimulator, driverID)
		}
		else {
			driverID := this.StintDrivers[numDrivers]
			driverName := new SessionDatabase().getDriverName(this.SelectedSimulator, driverID)
		}

		return true
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		local window := this.Window
		local min := false
		local max := false
		local a, b, telemetryDB, lapTimes, tyreLapTimes, xValues, yValues, ignore, entry
		local baseLapTime, count, avgLapTime, lapTime, candidate

		Gui %window%:Default

		GuiControlGet simInputDropDown
		GuiControlGet simAvgLapTimeEdit

		a := false
		b := false

		if (simInputDropDown > 1) {
			telemetryDB := this.TelemetryDatabase

			lapTimes := telemetryDB.getMapLapTimes(weather, tyreCompound, tyreCompoundColor)
			tyreLapTimes := telemetryDB.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor)

			if (tyreLapTimes.Length() > 1) {
				xValues := []
				yValues := []

				for ignore, entry in tyreLapTimes {
					lapTime := entry["Lap.Time"]

					xValues.Push(entry["Tyre.Laps"])
					yValues.Push(lapTime)

					min := (min ? Min(min, lapTime) : lapTime)
					max := (max ? Min(max, lapTime) : lapTime)
				}

				linRegression(xValues, yValues, a, b)
			}
		}
		else
			lapTimes := []

		baseLapTime := ((a && b) ? (a + (b * tyreLaps)) : false)

		count := 0
		avgLapTime := 0
		lapTime := false

		loop %numLaps% {
			candidate := lookupLapTime(lapTimes, map, remainingFuel - (fuelConsumption * (A_Index - 1)))

			if (!lapTime || !baseLapTime)
				lapTime := candidate
			else if (candidate < lapTime)
				lapTime := candidate

			if lapTime {
				if baseLapTime
					avgLapTime += (lapTime + ((a + (b * (tyreLaps + A_Index))) - baseLapTime))
				else
					avgLapTime += lapTime

				count += 1
			}
		}

		if (avgLapTime > 0)
			avgLapTime := (avgLapTime / count)

		if (min && max)
			avgLapTime := Max(min, Min(max, avgLapTime))

		return avgLapTime ? avgLapTime : (default ? default : simAvgLapTimeEdit)
	}

	runSimulation() {
		local telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)

		this.iTelemetryDatabase := telemetryDB

		try {
			new VariationSimulation(this, this.SelectedSessionType, telemetryDB).runSimulation(true)
		}
		finally {
			this.iTelemetryDatabase := false
		}
	}

	chooseScenario(strategy) {
		local window := this.Window
		local numPitstops, numTyreChanges, consumedFuel, avgLapTimes, ignore, pitstop

		Gui %window%:Default

		if this.SelectedStrategy
			this.SelectedStrategy.dispose()

		if strategy {
			numPitstops := 0
			numTyreChanges := 0
			consumedFuel := strategy.RemainingFuel
			avgLapTimes := [strategy.AvgLapTime]

			for ignore, pitstop in strategy.Pitstops {
				numPitstops += 1

				if pitstop.TyreChange
					numTyreChanges += 1

				consumedFuel += pitstop.RefuelAmount

				avgLapTimes.Push(pitstop.AvgLapTime)
			}

			GuiControl Text, simNumPitstopResult, %numPitstops%
			GuiControl Text, simNumTyreChangeResult, %numTyreChanges%
			GuiControl Text, simConsumedFuelResult, % Ceil(consumedFuel)
			GuiControl Text, simPitlaneSecondsResult, % Ceil(strategy.getPitstopTime())

			if (this.SelectedSessionType = "Duration")
				GuiControl Text, simSessionResultResult, % strategy.getSessionLaps()
			else
				GuiControl Text, simSessionResultResult, % Ceil(strategy.getSessionDuration())
		}
		else {
			GuiControl Text, simNumPitstopResult, % ""
			GuiControl Text, simNumTyreChangeResult, % ""
			GuiControl Text, simConsumedFuelResult, % ""
			GuiControl Text, simPitlaneSecondsResult, % ""
			GuiControl Text, simSessionResultResult, % ""
		}

		this.iSelectedScenario := strategy
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

compareTime(w1, w2) {
	return (w1[1] > w2[1])
}

readSimulatorData(simulator) {
	local dataFile := kTempDirectory . simulator . " Data\Setup.data"
	local exePath := kBinariesDirectory . simulator . " SHM Provider.exe"
	local data, setupData

	FileCreateDir %kTempDirectory%%simulator% Data

	try {
		RunWait %ComSpec% /c ""%exePath%" -Setup > "%dataFile%"", , Hide

		data := readConfiguration(dataFile)

		setupData := getConfigurationSectionValues(data, "Setup Data")

		RunWait %ComSpec% /c ""%exePath%" > "%dataFile%"", , Hide

		data := readConfiguration(dataFile)

		deleteFile(dataFile)

		setConfigurationSectionValues(data, "Setup Data", setupData)

		return data
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"}) . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration..."), {simulator: simulator, protocol: "SHM", exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

chooseRefuelService() {
	GuiControlGet pitstopFuelServiceRuleDropdown

	GuiControl, , pitstopFuelServiceLabel, % translate(["Seconds", "Seconds (Refuel of 10 litres)"][pitstopFuelServiceRuleDropdown])
}

noSelect() {
	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

validatePitstopRule(full := false) {
	local reset, count, pitOpen, pitClose

	GuiControlGet pitstopWindowEdit

	if (StrLen(Trim(pitstopWindowEdit)) > 0) {
		GuiControlGet pitstopRequirementsDropDown

		if (pitstopRequirementsDropDown == 2) {
			if pitstopWindowEdit is Integer
			{
				if (pitstopWindowEdit < 1)
					GuiControl, , pitstopWindowEdit, 1
			}
			else
				GuiControl, , pitstopWindowEdit, 1
		}
		else if (pitstopRequirementsDropDown == 3) {
			reset := false

			StrReplace(pitstopWindowEdit, "-", "-", count)

			if (count > 1) {
				pitstopWindowEdit := StrReplace(pitstopWindowEdit, "-", "", , count - 1)

				reset := true
			}

			if (reset || InStr(pitstopWindowEdit, "-")) {
				pitstopWindowEdit := string2Values("-", pitstopWindowEdit)
				pitOpen := pitstopWindowEdit[1]
				pitClose := pitstopWindowEdit[2]

				if (StrLen(Trim(pitOpen)) > 0)
					if pitOpen is Integer
					{
						if (pitOpen < 0) {
							pitOpen := 0

							reset := true
						}
					}
					else {
						pitOpen := 0

						reset := true
					}
				else if (full = "Full") {
					pitOpen := 0

					reset := true
				}

				if (StrLen(Trim(pitClose)) > 0)
					if pitClose is Integer
					{
						if ((full = "Full") && (pitClose <= pitOpen)) {
							pitClose := pitOpen + 10

							reset := true
						}
					}
					else {
						pitClose := (pitOpen + 10)

						reset := true
					}
				else if (full = "Full") {
					pitClose := (pitOpen + 10)

					reset := true
				}

				if reset
					GuiControl, , pitstopWindowEdit, % Round(pitOpen) . " - " . Round(pitClose)
			}
		}
	}
}

validateNumber(field) {
	local oldValue := %field%

	GuiControlGet %field%

	if %field% is not Number
	{
		%field%:= oldValue

		GuiControl, , %field%, %oldValue%
	}
}

validatePositiveInteger(field, minValue) {
	local oldValue := %field%

	GuiControlGet %field%

	if %field% is not Number
	{
		%field%:= oldValue

		GuiControl, , %field%, %oldValue%
	}
	else if (%field% <= minValue) {
		%field%:= oldValue

		GuiControl, , %field%, %oldValue%
	}
}

validateSimMaxTyreLaps() {
	validatePositiveInteger("simMaxTyreLapsEdit", 10)
}

validateSimInitialFuelAmount() {
	validatePositiveInteger("simInitialFuelAmountEdit", 10)
}

validateSimAvgLapTime() {
	validateNumber("simAvgLapTimeEdit")
}

validateSimFuelConsumption() {
	validateNumber("simFuelConsumptionEdit")
}

validatePitstopFuelService() {
	validateNumber("pitstopFuelServiceEdit")
}

chooseSimDriver() {
	local workbench, window, sessionDB, ignore, id, driver

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		workbench := StrategyWorkbench.Instance
		window := workbench.Window

		Gui %window%:Default

		Gui ListView, % workbench.DriversListView

		LV_GetText(driver, A_EventInfo, 2)

		sessionDB := new SessionDatabase()

		for ignore, id in workbench.AvailableDrivers
			if (sessionDB.getDriverName(workbench.SelectedSimulator, id) = driver) {
				GuiControl Choose, simDriverDropDown, %A_Index%

				break
			}

		workbench.updateState()
	}
}

updateSimDriver() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local row, driver

	Gui %window%:Default

	Gui ListView, % workbench.DriversListView

	row := LV_GetNext(0)

	if (row > 0) {
		GuiControlGet simDriverDropDown

		if ((simDriverDropDown == 0) || (simDriverDropDown > workbench.AvailableDrivers.Length()))
			driver := false
		else
			driver := workbench.AvailableDrivers[simDriverDropDown]

		LV_Modify(row, "Col2", new SessionDatabase().getDriverName(workbench.SelectedSimulator, driver))

		if ((simDriverDropDown > 0) && driver)
			if (workbench.StintDrivers.Length() >= row)
				workbench.StintDrivers[row] := driver
			else
				workbench.StintDrivers.Push(driver)
	}
}

addSimDriver() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local row, title, numRows, sessionDB, driver

	Gui %window%:Default

	Gui ListView, % workbench.DriversListView

	row := LV_GetNext(0)

	if row {
		title := translate("Insert")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Before", "After", "Cancel"]))
		MsgBox 262179, %title%, % translate("Do you want to add the new entry before or after the currently selected entry?")
		OnMessage(0x44, "")

		IfMsgBox Cancel
			return

		IfMsgBox No
			row += 1

		LV_Insert(row, "Select", "", "")
		LV_Modify(row, "Vis")
	}
	else {
		LV_Modify(LV_Add("Select", "", ""), "Vis")

		row := LV_GetCount()
	}

	numRows := LV_GetCount()

	loop %numRows%
		LV_Modify(A_Index, "Col1", ((A_Index == numRows) ? (A_Index . "+") : A_Index))

	sessionDB := new SessionDatabase()
	driver := workbench.AvailableDrivers[1]

	if (row > workbench.StintDrivers.Length())
		workbench.StintDrivers.Push(driver)
	else
		workbench.StintDrivers.InsertAt(row, driver)

	LV_Modify(row, "Col2", sessionDB.getDriverName(workbench.SelectedSimulator, driver))

	GuiControl Choose, simDriverDropDown, % inList(workbench.AvailableDrivers, driver)

	workbench.updateState()
}

deleteSimDriver() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local row, title, numRows

	Gui %window%:Default

	Gui ListView, % workbench.DriversListView

	row := LV_GetNext(0)

	if row {
		title := translate("Delete")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		MsgBox 262436, %title%, % translate("Do you really want to delete the selected driver?")
		OnMessage(0x44, "")

		IfMsgBox Yes
		{
			LV_Delete(row)

			workbench.StintDrivers.RemoveAt(row)

			numRows := LV_GetCount()

			loop %numRows%
				LV_Modify(A_Index, "Col1", ((A_Index == numRows) ? (A_Index . "+") : A_Index))

			workbench.updateState()
		}
	}
}

chooseSimWeather() {
	local workbench, window, sessionDB, time, weather, currentTime, airTemperature, trackTemperature

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		workbench := StrategyWorkbench.Instance
		window := workbench.Window

		Gui %window%:Default

		Gui ListView, % workbench.WeatherListView

		LV_GetText(time, A_EventInfo, 1)
		LV_GetText(weather, A_EventInfo, 2)
		LV_GetText(airTemperature, A_EventInfo, 3)
		LV_GetText(trackTemperature, A_EventInfo, 4)

		time := string2Values(":", time)

		currentTime := "20200101000000"

		EnvAdd currentTime, time[1], Hours
		EnvAdd currentTime, time[2], Minutes

		GuiControl, , simWeatherTimeEdit, %currentTime%
		GuiControl, , simWeatherAirTemperatureEdit, %airTemperature%
		GuiControl, , simWeatherTrackTemperatureEdit, %trackTemperature%
		GuiControl Choose, simWeatherDropDown, % inList(map(kWeatherConditions, "translate"), weather)

		workbench.updateState()
	}
}

updateSimWeather() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local row, time

	Gui %window%:Default

	Gui ListView, % workbench.WeatherListView

	row := LV_GetNext(0)

	if (row > 0) {
		GuiControlGet simWeatherTimeEdit
		GuiControlGet simWeatherAirTemperatureEdit
		GuiControlGet simWeatherTrackTemperatureEdit
		GuiControlGet simWeatherDropDown

		FormatTime time, %simWeatherTimeEdit%, HH:mm

		LV_Modify(row, "", time, translate(kWeatherConditions[simWeatherDropDown])
						 , simWeatherAirTemperatureEdit, simWeatherTrackTemperatureEdit)

		LV_ModifyCol()

		Loop 4
			LV_ModifyCol(A_Index, "AutoHdr")
	}
}

addSimWeather() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local after := false
	local row, title, lastWeather, lastAirTemperature, lastTrackTemperature, lastTime, currentTime

	Gui %window%:Default

	Gui ListView, % workbench.WeatherListView

	row := LV_GetNext(0)

	if row {
		LV_GetText(lastTime, row, 1)
		LV_GetText(lastWeather, row, 2)
		LV_GetText(lastAirTemperature, row, 3)
		LV_GetText(lastTrackTemperature, row, 4)

		lastWeather := kWeatherConditions[inList(map(kWeatherConditions, "translate"), lastWeather)]

		title := translate("Insert")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Before", "After", "Cancel"]))
		MsgBox 262179, %title%, % translate("Do you want to add the new entry before or after the currently selected entry?")
		OnMessage(0x44, "")

		IfMsgBox Cancel
			return

		IfMsgBox No
		{
			row += 1

			after := true
		}

		LV_Insert(row, "Select", "", "")
		LV_Modify(row, "Vis")
	}
	else {
		row := LV_GetCount()

		if row {
			LV_GetText(lastTime, row, 1)
			LV_GetText(lastWeather, row, 2)
			LV_GetText(lastAirTemperature, row, 3)
			LV_GetText(lastTrackTemperature, row, 4)

			lastWeather := kWeatherConditions[inList(map(kWeatherConditions, "translate"), lastWeather)]
		}
		else {
			lastWeather := workbench.SelectedWeather
			lastAirTemperature := workbench.AirTemperature
			lastTrackTemperature := workbench.TrackTemperature
			lastTime := "00:00"
		}

		LV_Modify(LV_Add("Select", "", ""), "Vis")

		row += 1
	}

	lastTime := string2Values(":", lastTime)

	currentTime := "20200101000000"

	EnvAdd currentTime, lastTime[1], Hours
	EnvAdd currentTime, lastTime[2], Minutes

	if after
		EnvAdd currentTime, 1, Hours
	else if (LV_GetCount() > 1)
		EnvAdd currentTime, -30, Minutes

	GuiControl, , simWeatherTimeEdit, %currentTime%
	GuiControl, , simWeatherAirTemperatureEdit, %lastAirTemperature%
	GuiControl, , simWeatherTrackTemperatureEdit, %lastTrackTemperature%
	GuiControl Choose, simWeatherDropDown, % inList(kWeatherConditions, lastWeather)

	FormatTime currentTime, %currentTime%, HH:mm

	LV_Modify(row, "", currentTime, translate(lastWeather), lastAirTemperature, lastTrackTemperature)

	Loop 4
		LV_ModifyCol(A_Index, "AutoHdr")

	workbench.updateState()
}

deleteSimWeather() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local row, title

	Gui %window%:Default

	Gui ListView, % workbench.WeatherListView

	row := LV_GetNext(0)

	if row {
		title := translate("Delete")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		MsgBox 262436, %title%, % translate("Do you really want to delete the selected change of weather?")
		OnMessage(0x44, "")

		IfMsgBox Yes
		{
			LV_Delete(row)

			workbench.updateState()
		}
	}
}

filterSchema(schema) {
	local newSchema := []
	local ignore, column

	for ignore, column in schema
		if !inList(["Driver", "Identifier", "Synchronized", "Weather", "Tyre.Compound", "Tyre.Compound.Color"], column)
			newSchema.Push(column)

	return newSchema
}

closeWorkbench() {
	ExitApp 0
}

moveWorkbench() {
	moveByMouse(StrategyWorkbench.Instance.Window, "Strategy Workbench")
}

openWorkbenchDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development
}

chooseSimulator() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet simulatorDropDown

	workbench.loadSimulator(simulatorDropDown)
}

chooseCar() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet carDropDown

	workbench.loadCar(workbench.getCars(workbench.SelectedSimulator)[carDropDown])
}

chooseTrack() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local simulator, tracks, trackNames

	Gui %window%:Default

	GuiControlGet trackDropDown

	simulator := workbench.SelectedSimulator
	tracks := workbench.getTracks(simulator, workbench.SelectedCar)
	trackNames := map(tracks, ObjBindMethod(new SessionDatabase(), "getTrackName", simulator))

	workbench.loadTrack(tracks[inList(trackNames, trackDropDown)])
}

chooseWeather() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet weatherDropDown

	workbench.loadWeather(kWeatherConditions[weatherDropDown])
}

updateTemperatures() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit

	workbench.setTemperatures(airTemperatureEdit, trackTemperatureEdit)
}

chooseDriver() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet driverDropDown

	workbench.loadDriver((driverDropDown = 1) ? true : workbench.AvailableDrivers[driverDropDown - 1])
}

chooseCompound() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet compoundDropDown

	workbench.loadCompound(workbench.AvailableCompounds[compoundDropDown])
}

chooseDataType() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local title

	Gui %window%:Default

	GuiControlGet dataTypeDropDown

	if (dataTypeDropDown > 2) {
		if ((dataTypeDropDown = 4) && (workbench.SelectedSimulator && workbench.SelectedCar && workbench.SelectedTrack)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Delete")
			MsgBox 262436, %title%, % translate("Entries with lap times or fuel consumption outside the standard deviation will be deleted. Do you want to proceed?")
			OnMessage(0x44, "")

			IfMsgBox Yes
			{
				new TelemetryDatabase(workbench.SelectedSimulator
									, workbench.SelectedCar
									, workbench.SelectedTrack
									, workbench.SelectedDrivers).cleanupData(workbench.SelectedWeather
																		   , workbench.SelectedCompound
																		   , workbench.SelectedCompoundColor
																		   , workbench.SelectedDrivers)

				workbench.loadDataType(workbench.SelectedDataType, true, true)

				GuiControlGet compoundDropDown

				workbench.loadCompound(workbench.AvailableCompounds[compoundDropDown], true)
			}
		}

		GuiControl Choose, dataTypeDropDown, % inList(["Electronics", "Tyres"], workbench.SelectedDataType)
	}
	else
		workbench.loadDataType(["Electronics", "Tyres"][dataTypeDropDown], true)
}

chooseData() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	Gui ListView, % workbench.DataListView

	LV_Modify(A_EventInfo, "-Select")
}

chooseAxis() {
	StrategyWorkbench.Instance.loadChart(StrategyWorkbench.Instance.SelectedChartType)
}

chooseChartSource() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window

	Gui %window%:Default

	GuiControlGet chartSourceDropDown

	if (chartSourceDropDown = 1)
		GuiControl Show, chartTypeDropDown
	else
		GuiControl Hide, chartTypeDropDown

	chartViewer.Document.Open()
	chartViewer.Document.Write((chartSourceDropDown = 1) ? workbench.iTelemetryChartHTML : workbench.iStrategyChartHTML)
	chartViewer.Document.Close()
}

chooseChartType() {
	local window := StrategyWorkbench.Instance.Window

	Gui %window%:Default

	GuiControlGet chartTypeDropDown

	StrategyWorkbench.Instance.loadChart(["Scatter", "Bar", "Bubble", "Line"][chartTypeDropDown])
}

chooseSessionType() {
	GuiControlGet sessionTypeDropDown

	StrategyWorkbench.Instance.selectSessionType(["Duration", "Laps"][sessionTypeDropDown])
}

choosePitstopRequirements() {
	StrategyWorkbench.Instance.updateState()
}

chooseTyreSet() {
	local compound, workbench, window, count

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		workbench := StrategyWorkbench.Instance

		window := workbench.Window

		Gui %window%:Default

		Gui ListView, % workbench.TyreSetListView

		LV_GetText(compound, A_EventInfo, 1)
		LV_GetText(count, A_EventInfo, 2)

		if compound
			compound := normalizeCompound(compound)

		GuiControl Choose, tyreSetDropDown, % inList(map(workbench.TyreCompounds, "translate"), compound)
		GuiControl, , tyreSetCountEdit, %count%

		workbench.updateState()
	}
}

updateTyreSet() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local row

	Gui %window%:Default

	Gui ListView, % workbench.TyreSetListView

	row := LV_GetNext(0)

	if (row > 0) {
		GuiControlGet tyreSetDropDown
		GuiControlGet tyreSetCountEdit

		LV_Modify(row, "", map(workbench.TyreCompounds, "translate")[tyreSetDropDown], tyreSetCountEdit)

		LV_ModifyCol()
	}
}

addTyreSet() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local index

	Gui %window%:Default

	Gui ListView, % workbench.TyreSetListView

	index := inList(workbench.TyreCompounds, normalizeCompound("Dry"))

	if !index
		index := 1

	LV_Add("", map(workbench.TyreCompounds, "translate")[index], 99)

	LV_Modify(LV_GetCount(), "Select Vis")

	LV_ModifyCol()

	GuiControl Choose, tyreSetDropDown, %index%
	GuiControl, , tyreSetCountEdit, 99

	workbench.updateState()
}

deleteTyreSet() {
	local workbench := StrategyWorkbench.Instance
	local window := workbench.Window
	local index

	Gui %window%:Default

	Gui ListView, % workbench.TyreSetListView

	index := LV_GetNext(0)

	if (index > 0)
		LV_Delete(index)

	workbench.updateState()
}

settingsMenu() {
	GuiControlGet settingsMenuDropDown

	GuiControl Choose, settingsMenuDropDown, 1

	StrategyWorkbench.Instance.chooseSettingsMenu(settingsMenuDropDown)
}

simulationMenu() {
	GuiControlGet simulationMenuDropDown

	GuiControl Choose, simulationMenuDropDown, 1

	StrategyWorkbench.Instance.chooseSimulationMenu(simulationMenuDropDown)
}

strategyMenu() {
	GuiControlGet strategyMenuDropDown

	GuiControl Choose, strategyMenuDropDown, 1

	StrategyWorkbench.Instance.chooseStrategyMenu(strategyMenuDropDown)
}

runSimulation() {
	local workbench := StrategyWorkbench.Instance
	local selectStrategy := GetKeyState("Ctrl")

	workbench.runSimulation()

	if selectStrategy
		workbench.chooseSimulationMenu(5)
}

runStrategyWorkbench() {
	local icon := kIconsDirectory . "Dashboard.ico"
	local settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getConfigurationValue(settings, "Strategy Workbench", "Simulator", false)
	local car := getConfigurationValue(settings, "Strategy Workbench", "Car", false)
	local track := getConfigurationValue(settings, "Strategy Workbench", "Track", false)
	local weather := "Dry"
	local airTemperature := 23
	local trackTemperature:= 27
	local compound := "Dry"
	local compoundColor := "Black"
	local index := 1
	local workbench

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Strategy Workbench

	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Simulator":
				simulator := A_Args[index + 1]
				index += 2
			case "-Car":
				car := A_Args[index + 1]
				index += 2
			case "-Track":
				track := A_Args[index + 1]
				index += 2
			case "-Weather":
				weather := A_Args[index + 1]
				index += 2
			case "-AirTemperature":
				airTemperature := A_Args[index + 1]
				index += 2
			case "-TrackTemperature":
				trackTemperature := A_Args[index + 1]
				index += 2
			case "-Compound":
				compound := A_Args[index + 1]
				index += 2
			case "-CompoundColor":
				compoundColor := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}

	if (airTemperature <= 0)
		airTemperature := 23

	if (trackTemperature <= 0)
		trackTemperature := 27

	fixIE(11)

	workbench := new StrategyWorkbench(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor)

	workbench.createGui(workbench.Configuration)
	workbench.show()

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

runStrategyWorkbench()