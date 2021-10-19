;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Workbench Tool         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Dashboard.ico
;@Ahk2Exe-ExeName Strategy Workbench.exe

				
;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\TelemetryDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk = "Ok"
global kCancel = "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variables Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global vChartID = 0


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown
global airTemperatureEdit
global trackTemperatureEdit
global compoundDropDown
global dataTypeDropDown
global dataXDropDown
global dataY1DropDown
global dataY2DropDown
global dataY3DropDown

global chartSourceDropDown
global chartTypeDropDown

global chartViewer
global strategyViewer
		
global sessionTypeDropDown
global sessionLengthEdit = 60
global sessionLengthLabel
global stintLengthEdit = 70
global formationLapCheck = true
global postRaceLapCheck = true

global settingsMenuDropDown
global simulationMenuDropDown
global strategyMenuDropDown

global pitstopRequirementsDropDown
global pitstopWindowEdit = "25-35"
global pitstopWindowLabel
global tyreChangeRequirementsDropDown
global tyreChangeRequirementsLabel
global refuelRequirementsDropDown
global refuelRequirementsLabel

global pitstopDeltaEdit = 60
global pitstopTyreServiceEdit = 30
global pitstopRefuelServiceEdit = 1.2
global fuelCapacityEdit = 125
global safetyFuelEdit = 5

global simCompoundDropDown
global simMaxTyreLapsEdit = 40
global simInitialFuelAmountEdit = 90
global simMapEdit = 1
global simAvgLapTimeEdit = 120
global simFuelConsumptionEdit = 3.8

global simConsumptionWeight = 0
global simTyreUsageWeight = 0
global simCarWeightWeight = 0

global simInputDropDown

global simNumPitstopResult = ""
global simNumTyreChangeResult = ""
global simConsumedFuelResult = ""
global simPitlaneSecondsResult = ""
global simSessionResultResult = ""
global simSessionResultLabel

global strategyStartMapEdit = 1
global strategyStartTCEdit = 1
global strategyStartABSEdit = 2

global strategyCompoundDropDown
global strategyPressureFLEdit = 27.7
global strategyPressureFREdit = 27.7
global strategyPressureRLEdit = 27.7
global strategyPressureRREdit = 27.7

class StrategyWorkbench extends ConfigurationItem {
	iDataListView := false
	
	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	iSelectedWeather := "Dry"
	iSelectedCompound := "Dry"
	iSelectedCompoundColor := "Black"
	
	iSelectedDataType := "Electronics"
	iSelectedChartType := "Scatter"
	
	iSelectedSessionType := "Duration"
	
	iTelemetryChartHTML := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
	iStrategyChartHTML := this.iTelemetryChartHTML
	
	iSelectedScenario := false
	iSelectedStrategy := false
	
	iAirTemperature := 23
	iTrackTemperature := 27
	
	iPitstopListView := false
	
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
	
	SelectedCompound[colored := false] {
		Get {
			if colored
				return qualifiedCompound(this.iSelectedCompound, this.iSelectedCompoundColor)
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
	
	SelectedSessionType[] {
		Get {
			return this.iSelectedSessionType
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
	
	PitstopListView[] {
		Get {
			return this.iPitstopListView
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
	
	__New(simulator := false, car := false, track := false, duration := false, weather := false, airTemperature := false, trackTemperature := false
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
		local stepWizard
		
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1184 Center gmoveWorkbench, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w1184 cBlue Center gopenWorkbenchDocumentation, % translate("Strategy Workbench")
		
		Gui %window%:Add, Text, x8 yp+30 w1200 0x10
			
		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial
			
		Gui %window%:Add, Picture, x16 yp+12 w30 h30 Section, %kIconsDirectory%Sensor.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Telemetry")
			
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x16 yp+32 w70 h23 +0x200, % translate("Simulator")
		
		simulators := this.getSimulators()
		simulator := 0
		
		if (simulators.Length() > 0) {
			if this.iSelectedSimulator
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
		Gui %window%:Add, DropDownList, x90 yp w290 vcarDropDown gchooseCar
		
		Gui %window%:Add, Text, x16 yp24 w70 h23 +0x200, % translate("Track")
		Gui %window%:Add, DropDownList, x90 yp w290 vtrackDropDown gchooseTrack
		
		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Conditions")
		
		weather := this.SelectedWeather
		choices := map(kWeatherOptions, "translate")
		chosen := inList(kWeatherOptions, weather)
		
		if (!chosen && (choices.Length() > 0)) {
			weather := choices[1]
			chosen := 1
		}
		
		Gui %window%:Add, DropDownList, x90 yp w120 AltSubmit Choose%chosen% gchooseWeather vweatherDropDown, % values2String("|", choices*)
		
		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature
		
		Gui %window%:Add, Edit, x215 yp w40 vairTemperatureEdit gupdateTemperatures
		Gui %window%:Add, UpDown, x242 yp-2 w18 h20, % airTemperature
		
		Gui %window%:Add, Edit, x262 yp w40 vtrackTemperatureEdit gupdateTemperatures
		Gui %window%:Add, UpDown, x289 yp w18 h20, % trackTemperature
		Gui %window%:Add, Text, x304 yp w90 h23 +0x200, % translate("Air / Track")
		
		this.setTemperatures(airTemperature, trackTemperature)
		
		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Compound")
		
		compound := this.SelectedCompound[true]
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}
		
		Gui %window%:Add, DropDownList, x90 yp w120 AltSubmit Choose%chosen% gchooseCompound vcompoundDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x16 yp+32 w364 0x10
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, Text, x16 yp+10 w364 h23 Center +0x200, % translate("Chart")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, DropDownList, x12 yp+32 w76 AltSubmit Choose1 vdataTypeDropDown gchooseDataType +0x200, % values2String("|", map(["Electronics", "Tyres"], "translate")*)
		
		Gui %window%:Add, ListView, x90 yp-2 w100 h97 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdataListView gchooseData, % values2String("|", map(["Map", "Count"], "translate")*)
		
		this.iDataListView := dataListView
		
		Gui %window%:Add, Text, x200 yp+2 w70 h23 +0x200, % translate("X-Axis")
		
		schema := filterSchema(new TelemetryDatabase().getSchema("Electronics", true))
		
		chosen := inList(schema, "Map")
		Gui %window%:Add, DropDownList, x250 yp w130 AltSubmit Choose%chosen% vdataXDropDown gchooseAxis, % values2String("|", map(schema, "translate")*)
		
		Gui %window%:Add, Text, x200 yp+24 w70 h23 +0x200, % translate("Series")
		
		chosen := inList(schema, "Fuel.Consumption")
		Gui %window%:Add, DropDownList, x250 yp w130 AltSubmit Choose%chosen% vdataY1DropDown gchooseAxis, % values2String("|", map(schema, "translate")*)
		Gui %window%:Add, DropDownList, x250 yp+24 w130 AltSubmit Choose1 vdataY2DropDown gchooseAxis, % translate("None") . "|" . values2String("|", map(schema, "translate")*)
		Gui %window%:Add, DropDownList, x250 yp+24 w130 AltSubmit Choose1 vdataY3DropDown gchooseAxis, % translate("None") . "|" . values2String("|", map(schema, "translate")*)
		
		Gui %window%:Add, Text, x400 ys w40 h23 +0x200, % translate("Chart")
		Gui %window%:Add, DropDownList, x444 yp w80 AltSubmit Choose1 +0x200 vchartSourceDropDown gchooseChartSource, % values2String("|", map(["Telemetry", "Comparison"], "translate")*)
		Gui %window%:Add, DropDownList, x529 yp w80 AltSubmit Choose1 vchartTypeDropDown gchooseChartType, % values2String("|", map(["Scatter", "Bar", "Bubble", "Line"], "translate")*)
		
		Gui %window%:Add, ActiveX, x400 yp+24 w800 h278 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x8 yp+286 w1200 0x10

		Gui %window%:Font, s10 Bold, Arial
			
		Gui %window%:Add, Picture, x16 yp+10 w30 h30 Section, %kIconsDirectory%Strategy.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Strategy")
		
		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, DropDownList, x220 yp-2 w180 AltSubmit Choose1 +0x200 VsettingsMenuDropDown gsettingsMenu, % values2String("|", map(["Settings", "---------------------------------------------", "Initialize from Setup Database...", "Initialize from Telemetry...", "Initialize from Simulation..."], "translate")*)
		
		Gui %window%:Add, DropDownList, x405 yp w180 AltSubmit Choose1 +0x200 VsimulationMenuDropDown gsimulationMenu, % values2String("|", map(["Simulation", "---------------------------------------------", "Set Target Stint Length...", "Set Target Fuel Consumption...", "Set Target Tyre Usage...", "---------------------------------------------", "Run Simulation", "---------------------------------------------", "Use as Strategy..."], "translate")*)
		
		Gui %window%:Add, DropDownList, x590 yp w180 AltSubmit Choose1 +0x200 VstrategyMenuDropDown gstrategyMenu, % values2String("|", map(["Strategy", "---------------------------------------------", "Load Strategy...", "Save Strategy...", "---------------------------------------------", "Compare Strategies...", "---------------------------------------------", "Set as Race Strategy", "Clear Race Strategy"], "translate")*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x619 ys+39 w577 h9, % translate("Strategy")
		
		Gui %window%:Add, ActiveX, x619 yp+21 w577 h193 Border vstrategyViewer, shell.explorer
		
		strategyViewer.Navigate("about:blank")
		
		this.showStrategyInfo(false)
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x8 y650 w1200 0x10
		
		Gui %window%:Add, Button, x574 y656 w80 h23 GcloseWorkbench, % translate("Close")

		Gui %window%:Add, Tab, x16 ys+39 w593 h216 -Wrap Section, % values2String("|", map(["Rules && Settings", "Pitstop && Service", "Simulation", "Strategy"], "translate")*)
		
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
		
		Gui %window%:Add, Text, x%x% yp+21 w85 h23 +0x200, % translate("Max. Stint")
		Gui %window%:Add, Edit, x%x1% yp w50 h20 Limit4 Number VstintLengthEdit, %stintLengthEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-9999 0x80, %stintLengthEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w60 h20, % translate("Minutes")

		Gui %window%:Add, Text, x%x% yp+21 w85 h23 +0x200, % translate("Formation")
		Gui %window%:Add, CheckBox, x%x1% yp-1 w17 h23 Checked%formationLapCheck% VformationLapCheck, %formationLapCheck%
		Gui %window%:Add, Text, x%x4% yp+5 w50 h20, % translate("Lap")
				
		Gui %window%:Add, Text, x%x% yp+19 w85 h23 +0x200, % translate("Post Race")
		Gui %window%:Add, CheckBox, x%x1% yp-1 w17 h23 Checked%postRaceLapCheck% VpostRaceLapCheck, %postRaceLapCheck%
		Gui %window%:Add, Text, x%x4% yp+5 w50 h20, % translate("Lap")
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x243 ys+34 w354 h171, % translate("Pitstop")
		
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x5% yp+23 w90 h20, % translate("Pitstop")
		Gui %window%:Add, DropDownList, x%x7% yp-4 w80 AltSubmit Choose3 VpitstopRequirementsDropDown gchoosePitstopRequirements, % values2String("|", map(["Optional", "Required", "Window"], "translate")*)
		Gui %window%:Add, Edit, x%x11% yp+1 w50 h20 VpitstopWindowEdit, %pitstopWindowEdit%
		Gui %window%:Add, Text, x%x12% yp+3 w110 h20 VpitstopWindowLabel, % translate("Minute (From - To)")

		Gui %window%:Add, Text, x%x5% yp+22 w85 h23 +0x200 VrefuelRequirementsLabel, % translate("Refuel")
		Gui %window%:Add, DropDownList, x%x7% yp w80 AltSubmit Choose2 VrefuelRequirementsDropDown, % values2String("|", map(["Optional", "Required"], "translate")*)

		Gui %window%:Add, Text, x%x5% yp+26 w85 h23 +0x200 VtyreChangeRequirementsLabel, % translate("Tyre Change")
		Gui %window%:Add, DropDownList, x%x7% yp w80 AltSubmit Choose2 VtyreChangeRequirementsDropDown, % values2String("|", map(["Optional", "Required"], "translate")*)
		
		Gui %window%:Tab, 2
		
		x := 32
		x0 := x - 4
		x1 := x + 94
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w350 h171, % translate("Pitstop")
				
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w105 h20 +0x200, % translate("Pitlane Delta")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Limit2 Number VpitstopDeltaEdit, %pitstopDeltaEdit%
		Gui %window%:Add, UpDown, x%x2% yp w18 h20 0x80, %pitstopDeltaEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Drive through - Drive by)")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Tyre Service")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Limit2 Number VpitstopTyreServiceEdit, %pitstopTyreServiceEdit%
		Gui %window%:Add, UpDown, x%x2% yp w18 h20 0x80, %pitstopTyreServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Change four tyres)")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Refuel Service")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 VpitstopRefuelServiceEdit, %pitstopRefuelServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Refuel of 10 litres)")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Fuel Capacity")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 Number VfuelCapacityEdit, %fuelCapacityEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Liter")
		
		Gui %window%:Add, Text, x%x% yp+19 w85 h23 +0x200, % translate("Safety Fuel")
		Gui %window%:Add, Edit, x%x1% yp+1 w50 h20 Number VsafetyFuelEdit, %safetyFuelEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %safetyFuelEdit%
		Gui %window%:Add, Text, x%x3% yp+2 w90 h20, % translate("Liter")
		
		Gui %window%:Tab, 3
		
		x := 32
		x0 := x - 4
		x1 := x + 74
		x2 := x1 + 22
		x3 := x2 + 26
		x4 := x1 + 16
		x5 := x3 + 44
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w179 h171, % translate("Initial Conditions")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+21 w85 h23 +0x200, % translate("Compound")
		
		compound := this.SelectedCompound[true]
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x%x1% yp w84 AltSubmit Choose%chosen% VsimCompoundDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("Tyre Usage")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 Number VsimMaxTyreLapsEdit, %simMaxTyreLapsEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simMaxTyreLapsEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w47 h20, % translate("Laps")
				
		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Tank Filling")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 Number VsimInitialFuelAmountEdit, %simInitialFuelAmountEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simInitialFuelAmountEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w47 h20, % translate("Liter")
		
		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Map")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 VsimMapEdit, %simMapEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simMapEdit%
		
		Gui %window%:Add, Text, x%x% yp+23 w85 h23 +0x200, % translate("Avg. Lap Time")
		Gui %window%:Add, Edit, x%x1% yp w40 h20 Limit3 Number VsimAvgLapTimeEdit, %simAvgLapTimeEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Sec.")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Consumption")
		Gui %window%:Add, Edit, x%x1% yp-2 w40 h20 VsimFuelConsumptionEdit, %simFuelConsumptionEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Ltr.")
		
		x := 222
		x0 := x - 4
		x1 := x + 104
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		x5 := x + 50
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x214 ys+34 w174 h99, % translate("Optimizer")
		
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w100 h20 +0x200, % translate("Fuel Consumption")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-10 ToolTip VsimConsumptionWeight, %simConsumptionWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Tyre Usage")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimTyreUsageWeight, %simTyreUsageWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Car Weight")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimCarWeightWeight, %simCarWeightWeight%
		
		Gui %window%:Add, Text, x214 yp+48 w40 h23 +0x200, % translate("Use")
		
		choices := map(["Initial Conditions", "Telemetry Data", "Initial Cond. + Telemetry"], "translate")

		Gui %window%:Add, DropDownList, x250 yp w138 AltSubmit Choose3 VsimInputDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, Button, x214 yp+34 w174 h20 grunSimulation, % translate("Simulate!")
		
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
		
		Gui %window%:Tab, 4
		
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
		
		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w179 h171, % translate("Electronics")
		
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Map")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 VstrategyStartMapEdit, %strategyStartMapEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %strategyStartMapEdit%
		
		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("TC")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 VstrategyStartTCEdit, %strategyStartTCEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %strategyStartTCEdit%
		
		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("ABS")
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 VstrategyStartABSEdit, %strategyStartABSEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %strategyStartABSEdit%
		
		x := 222
		x0 := x + 50
		x1 := x + 70
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x214 ys+34 w174 h171, % translate("Tyres")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+21 w65 h23 +0x200, % translate("Compound")
		
		compound := this.SelectedCompound[true]
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x%x1% yp w85 AltSubmit Choose%chosen% VstrategyCompoundDropDown, % values2String("|", choices*)

		Gui %window%:Add, Text, x%x% yp+26 w85 h20 +0x200, % translate("Pressure")
		Gui %window%:Add, Text, x%x0% yp w85 h20 +0x200, % translate("FL")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureFLEdit, %strategyPressureFLEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x%x0% yp+21 w85 h20 +0x200, % translate("FR")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureFREdit, %strategyPressureFREdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x%x0% yp+21 w85 h20 +0x200, % translate("RL")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureRLEdit, %strategyPressureRLEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x%x0% yp+21 w85 h20 +0x200, % translate("RR")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyPressureRREdit, %strategyPressureRREdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("PSI")
		
		x := 407
		x0 := x - 4
		x1 := x + 84
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x399 ys+34 w197 h171, % translate("Pitstops")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, ListView, x%x% yp+21 w180 h139 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDpitstopListView, % values2String("|", map(["Lap", "Fuel", "Tyres", "Map"], "translate")*)
		
		this.iPitstopListView := pitstopListView
		
		Gui %window%:Font, Norm, Arial
		
		car := this.SelectedCar
		track := this.SelectedTrack
		
		this.loadSimulator(simulator, true)
		
		if car
			this.loadCar(car)
		
		if track
			this.loadTrack(track)
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
	}
	
	showTelemetryChart(drawChartFunction) {
		window := this.Window
		
		Gui %window%:Default
		
		chartViewer.Document.Open()
		
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
					<div id="chart_id" style="width: 798px; height: 248px"></div>
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
		window := this.Window
		
		Gui %window%:Default
		
		chartViewer.Document.Open()
		chartViewer.Document.Write(html)
		chartViewer.Document.Close()
		
		this.iStrategyChartHTML := html
		
		GuiControl Choose, chartSourceDropDown, 2
		GuiControl Hide, chartTypeDropDown
	}
	
	createStrategyInfo(strategy) {
		html := "<table>"
		html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . this.SelectedSimulator . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . this.SelectedCar . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . this.SelectedTrack . "</td></tr>")
		
		if (strategy.SessionType = "Duration") {
			html .= ("<tr><td><b>" . translate("Duration:") . "</b></td><td>" . strategy.SessionLength . A_Space . translate("Minutes") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></td><td>" . strategy.getSessionLaps() . A_Space . translate("Laps") . "</td></tr>")
		}
		else {
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></td><td>" . strategy.SessionLength . A_Space . translate("Laps") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Duration:") . "</b></td><td>" . Round(strategy.getSessionDuration() / 60) . A_Space . translate("Minutes") . "</td></tr>")
		}
		
		html .= ("<tr><td><b>" . translate("Weather:") . "</b></td><td>" . translate(strategy.Weather) . translate(" (") . strategy.AirTemperature . translate(" / ") . strategy.TrackTemperature . translate(")") . "</td></tr>")
		html .= "</table>"
		
		return html
	}
	
	createSetupInfo(strategy) {
		html := "<table>"
		html .= ("<tr><td><b>" . translate("Fuel:") . "</b></td><td>" . strategy.RemainingFuel . A_Space . translate("Liter") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Compound:") . "</b></td><td>" . translate(strategy.TyreCompound[true]) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Pressures (hot):") . "</b></td><td>" . strategy.TyrePressures[true] . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Map:") . "</b></td><td>" . strategy.Map . "</td></tr>")
		html .= ("<tr><td><b>" . translate("TC:") . "</b></td><td>" . strategy.TC . "</td></tr>")
		html .= ("<tr><td><b>" . translate("ABS:") . "</b></td><td>" . strategy.ABS . "</td></tr>")
		html .= "</table>"
			
		return html
	}
	
	createStintsInfo(strategy, ByRef timeSeries, ByRef lapSeries, ByRef fuelSeries, ByRef tyreSeries) {
		timeSeries := [0]
		lapSeries := [0]
		fuelSeries := [strategy.RemainingFuel]
		tyreSeries := [strategy.RemainingTyreLaps]
		
		html := ""
		
		if !strategy.LastPitstop {
			html .= "<table id=""stints"">"
			html .= ("<tr><td><i>" . translate("Stint:") . "</i></td><td id=""data"">1</td></tr>")
			html .= ("<tr><td><i>" . translate("Map:") . "</i></td><td id=""data"">" . strategy.Map . "</td></tr>")
			html .= ("<tr><td><i>" . translate("Laps:") . "</i></td><td id=""data"">" . strategy.RemainingLaps . "</td></tr>")
			html .= ("<tr><td><i>" . translate("Lap Time:") . "</i></td><td id=""data"">" . strategy.AvgLapTime . "</td></tr>")
			html .= ("<tr><td><i>" . translate("Fuel Consumption:") . "</i></td><td id=""data"">" . strategy.FuelConsumption . "</td></tr>")
			html .= "</table>"
			
			timeSeries.Push(strategy.getSessionDuration() / 60)
			lapSeries.Push(strategy.getSessionLaps())
			fuelSeries.Push(strategy.RemainingFuel - (strategy.FuelConsumption * strategy.RemainingLaps))
			tyreSeries.Push(strategy.RemainingTyreLaps - strategy.RemainingLaps)
		}
		else {
			stints := []
			maps := []
			laps := []
			lapTimes := []
			fuelConsumptions := []
			pitstopLaps := []
			refuels := []
			tyreChanges := []
			
			lastMap := strategy.Map
			lastLap := 0
			lastLapTime := strategy.AvgLapTime
			lastFuelConsumption := strategy.FuelConsumption
			lastRefuel := ""
			lastPitstopLap := ""
			lastTyreChange := ""
			lastTyreLaps := strategy.RemainingTyreLaps
		
			for ignore, pitstop in strategy.Pitstops {
				stints.Push("<td id=""data"">" . A_Index . "</td>")
				maps.Push("<td id=""data"">" . lastMap . "</td>")
				laps.Push("<td id=""data"">" . (pitstop.Lap - lastLap) . "</td>")
				lapTimes.Push("<td id=""data"">" . Round(lastLapTime, 1) . "</td>")
				fuelConsumptions.Push("<td id=""data"">" . Round(lastFuelConsumption, 2) . "</td>")
				pitstopLaps.Push("<td id=""data"">" . lastPitstopLap . "</td>")
				refuels.Push("<td id=""data"">" . (lastRefuel ? Ceil(lastRefuel) : "") . "</td>")
				tyreChanges.Push("<td id=""data"">" . lastTyreChange . "</td>")
				
				timeSeries.Push(pitstop.Time / 60)
				lapSeries.Push(pitstop.Lap)
				fuelSeries.Push(pitstop.RemainingFuel - pitstop.RefuelAmount)
				tyreSeries.Push(lastTyreLaps - (pitstop.Lap - lastLap))
				
				lastMap := pitstop.Map
				lastLap := pitstop.Lap
				lastFuelConsumption := pitstop.FuelConsumption
				lastLapTime := pitstop.AvgLapTime
				lastRefuel := pitstop.RefuelAmount
				lastPitstopLap := pitstop.Lap
				lastTyreChange := (pitstop.TyreChange ? translate("Yes") : translate("No"))
				lastTyreLaps := pitstop.RemainingTyreLaps
				
				timeSeries.Push((pitstop.Time + pitStop.Duration) / 60)
				lapSeries.Push(pitstop.Lap)
				fuelSeries.Push(pitstop.RemainingFuel)
				tyreSeries.Push(lastTyreLaps)
			}
			
			stints.Push("<td id=""data"">" . (strategy.Pitstops.Length() + 1) . "</td>")
			maps.Push("<td id=""data"">" . lastMap . "</td>")
			laps.Push("<td id=""data"">" . strategy.LastPitstop.StintLaps . "</td>")
			lapTimes.Push("<td id=""data"">" . Round(lastLapTime, 1) . "</td>")
			fuelConsumptions.Push("<td id=""data"">" . Round(lastFuelConsumption, 2) . "</td>")
			pitstopLaps.Push("<td id=""data"">" . lastPitstopLap . "</td>")
			refuels.Push("<td id=""data"">" . Ceil(lastRefuel) . "</td>")
			tyreChanges.Push("<td id=""data"">" . lastTyreChange . "</td>")
			
			timeSeries.Push((strategy.LastPitstop.Time + (strategy.LastPitstop.StintLaps * lastLapTime)) / 60)
			lapSeries.Push(lastLap + strategy.LastPitstop.StintLaps)
			fuelSeries.Push(strategy.LastPitstop.RemainingFuel - (strategy.LastPitstop.StintLaps * strategy.LastPitstop.FuelConsumption))
			tyreSeries.Push(lastTyreLaps - strategy.LastPitstop.StintLaps)
			
			html .= "<table id=""stints"">"
			html .= ("<tr><td><i>" . translate("Stint:") . "</i></td>" . values2String("", stints*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Map:") . "</i></td>" . values2String("", maps*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Laps:") . "</i></td>" . values2String("", laps*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Lap Time:") . "</i></td>" . values2String("", lapTimes*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Fuel Consumption:") . "</i></td>" . values2String("", fuelConsumptions*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Pitstop Lap:") . "</i></td>" . values2String("", pitstopLaps*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Refuel Amount:") . "</i></td>" . values2String("", refuels*) . "</tr>")
			html .= ("<tr><td><i>" . translate("Tyre Change:") . "</i></td>" . values2String("", tyreChanges*) . "</tr>")
			html .= "</table>"
		}
		
		return html
	}
	
	createConsumablesChart(strategy, width, height, timeSeries, lapSeries, fuelSeries, tyreSeries, ByRef drawChartFunction, ByRef chartID) {
		vChartID += 1
		
		chartID := vChartID
		
		durationSession := (this.SelectedSessionType = "Duration")
				
		drawChartFunction := ("function drawChart" . vChartID . "() {`nvar data = new google.visualization.DataTable();")
		
		if durationSession
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap") . "');")
		else
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Minutes") . "');")
		
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Fuel Level") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Tyre Life") . "');")

		drawChartFunction .= "`ndata.addRows(["
		
		for ignore, time in timeSeries {
			if (A_Index > 1)
				drawChartFunction .= ", "
			
			xAxis := (durationSession ? lapSeries[A_Index] : time)
			
			drawChartFunction .= ("[" . xAxis . ", " . fuelSeries[A_Index] . ", " . tyreSeries[A_Index] . "]")
		}
		
		drawChartFunction .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Lap") . "' }, vAxis: { viewWindow: { min: 0 } }, backgroundColor: 'D8D8D8' };`n")
				
		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . vChartID . "')); chart.draw(data, options); }")
		
		return ("<div id=""chart_" . vChartID . """ style=""width: " . width . "px; height: " . height . "px"">")
	}
	
	showStrategyInfo(strategy) {
		html := ""
		
		if strategy {
			html := ("<div id=""header""><b>" . translate("Strategy: ") . strategy.Name . "</b></div>")
			
			html .= ("<br><br><div id=""header""><i>" . translate("Session") . "</i></div>")
			
			html .= ("<br><br>" . this.createStrategyInfo(strategy))
			
			html .= ("<br><br><div id=""header""><i>" . translate("Setup") . "</i></div>")
			
			html .= ("<br><br>" . this.createSetupInfo(strategy))
			
			html .= ("<br><br><div id=""header""><i>" . translate("Stints") . "</i></div>")
		
			timeSeries := []
			lapSeries := []
			fuelSeries := []
			tyreSeries := []
			
			html .= ("<br><br>" . this.createStintsInfo(strategy, timeSeries, lapSeries, fuelSeries, tyreSeries))
		
			html .= ("<br><br><div id=""header""><i>" . translate("Consumables") . "</i></div>")
			
			drawChartFunction := false
			chartID := false
			
			chartArea := this.createConsumablesChart(strategy, 555, 248, timeSeries, lapSeries, fuelSeries, tyreSeries, drawChartFunction, chartID)
			
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
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart%chartID%);
			)

			after =
			(
					</script>
				</head>
			)
		}
		else {
			before := ""
			after := ""
			drawChartFunction := ""
			chartArea := ""
		}
			
		html := ("<html>" . before . drawChartFunction . after . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #stints td { border-right: solid 1px #A0A0A0; } </style><style> #header { font-size: 12px; } </style><style> #data { border-collapse: separate; border-spacing: 10px; text-align: center; } </style><div>" . html . "</div><br>" . chartArea . "</body></html>")

		strategyViewer.Document.Open()
		strategyViewer.Document.Write(html)
		strategyViewer.Document.Close()
	}
	
	showDataPlot(data, xAxis, yAxises) {
		this.iSelectedChart := "LapTimes"
		
		double := (yAxises.Length() > 1)
		
		drawChartFunction := ""
		
		drawChartFunction .= "function drawChart() {"
		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		
		if (this.SelectedChartType = "Bubble")
			drawChartFunction .= ("`ndata.addColumn('string', 'ID');")
		
		drawChartFunction .= ("`ndata.addColumn('number', '" . xAxis . "');")
		
		for ignore, yAxis in yAxises {
			drawChartFunction .= ("`ndata.addColumn('number', '" . yAxis . "');")
		}
		
		drawChartFunction .= "`ndata.addRows(["
		
		for ignore, values in data {
			if (A_Index > 1)
				drawChartFunction .= ",`n"
			
			value := values[xAxis]
			
			if ((value = "n/a") || (value == kNull))
				value := "null"

			if (this.SelectedChartType = "Bubble")
				drawChartFunction .= ("['', " . value)
			else
				drawChartFunction .= ("[" . value)
		
			for ignore, yAxis in yAxises {
				value := values[yAxis]
			
				if ((value = "n/a") || (value == kNull))
					value := "null"
				
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
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { viewWindowMode: 'pretty' }, vAxis: { viewWindowMode: 'pretty' } };")
				
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
		return new TelemetryDatabase().getSimulators()
	}
	
	getCars(simulator) {
		return new TelemetryDatabase().getCars(simulator)
	}
	
	getTracks(simulator, car) {
		return new TelemetryDatabase().getTracks(simulator, car)
	}
	
	loadSimulator(simulator, force := false) {
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedSimulator := simulator
			
			cars := this.getCars(simulator)
			
			GuiControl Choose, simulatorDropDown, % inList(this.getSimulators(), simulator)
			GuiControl, , carDropDown, % "|" . values2String("|", cars*)
			
			this.loadCar((cars.Length() > 0) ? cars[1] : false, true)
		}
	}
				
	loadCar(car, force := false) {
		if (force || (car != this.SelectedCar)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedCar := car
			
			tracks := this.getTracks(this.SelectedSimulator, car)
			
			GuiControl Choose, carDropDown, % inList(this.getCars(this.SelectedSimulator), car)
			GuiControl, , trackDropDown, % "|" . values2String("|", tracks*)
			
			this.loadTrack((tracks.Length() > 0) ? tracks[1] : false, true)
		}
	}
	
	loadTrack(track, force := false) {
		if (force || (track != this.SelectedTrack)) {
			window := this.Window
		
			Gui %window%:Default
			
			simulator := this.SelectedSimulator
			car := this.SelectedCar
			
			this.iSelectedTrack := track
				
			GuiControl Choose, trackDropDown, % inList(this.getTracks(simulator, car), track)
			
			this.loadWeather(this.SelectedWeather, true)
		}
	}
	
	loadWeather(weather, force := false) {
		if (force || (this.SelectedWeather != weather)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedWeather := weather
			
			GuiControl Choose, weatherDropDown, % inList(kWeatherOptions, weather)
			
			this.loadCompound(this.SelectedCompound[true], true)
		}
	}
	
	setTemperatures(airTemperature, trackTemperature) {
		this.iAirTemperature := airTemperature
		this.iTrackTemperature := trackTemperature
	}
	
	loadCompound(compound, force := false) {
		if (force || (this.SelectedCompound[true] != compound)) {
			this.showWorkbenchChart(false)
			
			compoundString := compound
			
			compound := string2Values(A_Space, compound)
		
			if (compound.Length() == 1)
				compoundColor := "Black"
			else
				compoundColor := SubStr(compound[2], 2, StrLen(compound[2]) - 2)
			
			compound := compound[1]
			
			this.iSelectedCompound := compound
			this.iSelectedCompoundColor := compoundColor
			
			telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
			weather := this.SelectedWeather
			
			window := this.Window
		
			Gui %window%:Default
			Gui ListView, % this.DataListView
			
			LV_Delete()
			
			while LV_DeleteCol(1)
				ignore := 1
			
			if (this.SelectedDataType = "Electronics") {
				for ignore, column in map(["Map", "Count"], "translate")
					LV_InsertCol(A_Index, "", column)
			
				categories := telemetryDB.getMapsCount(weather, compound, compoundColor)
				field := "Map"
				
				records := telemetryDB.getElectronicEntries(weather, compound, compoundColor)
			}
			else if (this.SelectedDataType = "Tyres") {
				for ignore, column in map(["Pressure", "Count"], "translate")
					LV_InsertCol(A_Index, "", column)
			
				categories := telemetryDB.getPressuresCount(weather, compound, compoundColor)
				field := "Tyre.Pressure"
				
				records := telemetryDB.getTyreEntries(weather, compound, compoundColor)
			}
			else
				records := []
			
			for ignore, category in categories {
				value := category[field]
				
				if (value = "n/a")
					value := translate(value)
				
				LV_Add("", value, category.Count)
			}

			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			
			this.loadChart(this.SelectedChartType)
		}
	}
	
	loadChart(chartType) {
		window := this.Window
		
		Gui %window%:Default
		
		this.iSelectedChartType := chartType
		
		GuiControl Choose, chartTypeDropDown, % inList(["Scatter", "Bar", "Bubble", "Line"], chartType)

		telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
		weather := this.SelectedWeather
		compound := this.SelectedCompound
		compoundColor := this.SelectedCompoundColor
		
		if (this.SelectedDataType = "Electronics")
			records := telemetryDB.getElectronicEntries(weather, compound, compoundColor)
		else if (this.SelectedDataType = "Tyres")
			records := telemetryDB.getTyreEntries(weather, compound, compoundColor)
		else
			records := []
		
		GuiControlGet dataXDropDown
		GuiControlGet dataY1DropDown
		GuiControlGet dataY2DropDown
		GuiControlGet dataY3DropDown
		
		schema := filterSchema(new TelemetryDatabase().getSchema(this.SelectedDataType, true))
		
		xAxis := schema[dataXDropDown]
		yAxises := Array(schema[dataY1DropDown])
		
		if (dataY2DropDown > 1)
			yAxises.Push(schema[dataY2DropDown - 1])
		
		if (dataY3DropDown > 1)
			yAxises.Push(schema[dataY3DropDown - 1])
		
		this.showDataPlot(records, xAxis, yAxises)
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
	
	calcSessionLaps(avgLapTime, formationLap := true, postRaceLap := true) {
		window := this.Window
		
		Gui %window%:Default
	
		GuiControlGet sessionLengthEdit
		GuiControlGet formationLapCheck
		GuiControlGet postRaceLapCheck
		
		if (this.SelectedSessionType = "Duration")
			return Ceil(((sessionLengthEdit * 60) / avgLapTime) + ((formationLap && formationLapCheck) ? 1 : 0) + ((postRaceLap && postRaceLapCheck) ? 1 : 0))
		else
			return (sessionLengthEdit + ((formationLap && formationLapCheck) ? 1 : 0) + ((postRaceLap && postRaceLapCheck) ? 1 : 0))
	}
	
	calcSessionTime(avgLapTime, formationLap := true, postRaceLap := true) {
		window := this.Window
		
		Gui %window%:Default
	
		GuiControlGet sessionLengthEdit
		GuiControlGet formationLapCheck
		GuiControlGet postRaceLapCheck
		
		if (this.SelectedSessionType = "Duration")
			return ((sessionLengthEdit * 60) + (((formationLap && formationLapCheck) ? 1 : 0) * avgLapTime) + (((postRaceLap && postRaceLapCheck) ? 1 : 0) * avgLapTime))
		else
			return ((sessionLengthEdit + ((formationLap && formationLapCheck) ? 1 : 0) + ((postRaceLap && postRaceLapCheck) ? 1 : 0)) * avgLapTime)
	}
	
	getMaxFuelLaps(fuelConsumption) {
		window := this.Window
		
		Gui %window%:Default
	
		GuiControlGet safetyFuelEdit
		GuiControlGet fuelCapacityEdit
		
		return Floor((fuelCapacityEdit - safetyFuelEdit) / fuelConsumption)
	}
	
	calcRefuelAmount(targetFuel, currentFuel) {
		window := this.Window
		
		Gui %window%:Default
	
		GuiControlGet safetyFuelEdit
		GuiControlGet fuelCapacityEdit
		
		return (Min(fuelCapacityEdit, targetFuel + safetyFuelEdit) - currentFuel)
	}

	calcPitstopDuration(refuelAmount, changeTyres) {
		window := this.Window
		
		Gui %window%:Default
	
		GuiControlGet pitstopDeltaEdit
		GuiControlGet pitstopTyreServiceEdit
		GuiControlGet pitstopRefuelServiceEdit
		
		return (pitstopDeltaEdit + (changeTyres ? pitstopTyreServiceEdit : 0) + ((refuelAmount / 10) * pitstopRefuelServiceEdit))
	}
	
	getSimulationWeights(ByRef consumption, ByRef tyreUsage, ByRef carWeight) {
		window := this.Window
		
		Gui %window%:Default
	
		GuiControlGet simConsumptionWeight
		GuiControlGet simTyreUsageWeight
		GuiControlGet simCarWeightWeight
		
		consumption := simConsumptionWeight
		tyreUsage := simTyreUsageWeight
		carWeight := simCarWeightWeight
	}
	
	getPitstopRules(ByRef pitstopRequired, ByRef refuelRequired, ByRef tyreChangeRequired) {
		result := true
		
		window := this.Window
						
		Gui %window%:Default
		
		GuiControlGet pitstopRequirementsDropDown
		GuiControlGet pitstopWindowEdit
		GuiControlGet tyreChangeRequirementsDropDown
		GuiControlGet refuelRequirementsDropDown
		
		switch pitstopRequirementsDropDown {
			case 1:
				pitstopRequired := false
			case 2:
				pitstopRequired := true
			case 3:
				window := string2Values("-", pitstopWindowEdit)
				
				if (window.Length() = 2)
					pitstopRequired := window
				else {
					pitstopRequired := true
				
					result := false
				}
		}
		
		refuelRequired := (refuelRequirementsDropDown = 2)
		tyreChangeRequired := (tyreChangeRequirementsDropDown = 2)
			
		return result
	}
	
	chooseSettingsMenu(line) {
		if (!this.SelectedSimulator || !this.SelectedCar || !this.SelectedTrack)
			return
		
		window := this.Window
						
		Gui %window%:Default
		
		switch line {
			case 3: ; "Load from Setup Database..."
				simulator := this.SelectedSimulator
				car := this.SelectedCar
				track := this.SelectedTrack
				
				telemetryDB := new TelemetryDatabase(simulator, car, track)
				simulatorCode := telemetryDB.getSimulatorCode(simulator)
				
				dirName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings
				
				FileCreateDir %dirName%
				
				title := translate("Load Race Settings...")
						
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
				FileSelectFile file, 1, %dirName%, %title%, Settings (*.settings)
				OnMessage(0x44, "")
			
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
						GuiControl, , pitstopRefuelServiceEdit, % getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", 1.5)
						
						compound := getConfigurationValue(settings, "Session Setup", "Tyre.Compound", "Dry")
						compoundColor := getConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")
						
						GuiControl Choose, simCompoundDropDown, % inList(kQualifiedTyreCompounds, qualifiedCompound(compound, compoundColor))
						
						GuiControl, , simAvgLapTimeEdit, % Round(getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", 120), 1)
						GuiControl, , simFuelConsumptionEdit, % Round(getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", 3.0), 2)
					}
				}
			case 4: ; "Update from Telemetry..."
				telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
				
				fastestLapTime := false
				
				for ignore, row in telemetryDB.getMapData(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor) {
					lapTime := row["Lap.Time"]
				
					if (!fastestLapTime || (lapTime < fastestLapTime)) {
						fastestLapTime := lapTime
						
						GuiControl, , simMapEdit, % row["Map"]
						GuiControl, , simAvgLapTimeEdit, % Round(lapTime, 1)
						GuiControl, , simFuelConsumptionEdit, % Round(row["Fuel.Consumption"], 2)
					}
				}
			case 5: ; "Import from Simulation..."
				simulator := this.SelectedSimulator
				
				if simulator {
					switch simulator {
						case "Assetto Corsa Competizione":
							prefix := "ACC"
						case "RaceRoom Racing Experience":
							prefix := "R3E"
						case "rFactor 2":
							prefix := "RF2"
						default:
							OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
							title := translate("Warning")
							MsgBox 262192, %title%, % translate("This is not supported for the selected simulator...")
							OnMessage(0x44, "")
							
							return
					}
					
					data := readSimulatorData(prefix)
					
					if false && ((getConfigurationValue(data, "Session Data", "Car") != this.SelectedCar)
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
						
						if ((compound != kUndefined) && (compoundColor != kUndefined))
							GuiControl Choose, simCompoundDropDown, % inList(kQualifiedTyreCompounds, qualifiedCompound(compound, compoundColor))
						
						map := getConfigurationValue(data, "Car Data", "Map", kUndefined)
						
						if (map != kUndefined)
							GuiControl, , simMapEdit, % Round(map)
					}
				}
			case 6: ; "Load Defaults..."
			case 8: ; "Save Defaults"
		}
	}
	
	chooseSimulationMenu(line) {
		local strategy
		
		switch line {
			case 3: ; "Set Target Stint Length..."
			case 4: ; "Set Target Fuel Consumption..."
			case 5: ; "Set Target Tyre Usage..."
			case 7: ; "Run Simulation"
				this.runSimulation()
			case 9: ; "Use as Strategy..."
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
		local strategy
		
		simulator := this.SelectedSimulator
		car := this.SelectedCar
		track := this.SelectedTrack
		
		if (simulator && car && track) {
			telemetryDB := new TelemetryDatabase(simulator, car, track)
			simulatorCode := telemetryDB.getSimulatorCode(simulator)
			
			dirName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Strategies
			
			FileCreateDir %dirName%
			
			switch line {
				case 3: ; "Load Strategy..."
					title := translate("Load Race Strategy...")
					
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
					FileSelectFile file, 1, %dirName%, %title%, Strategy (*.strategy)
					OnMessage(0x44, "")
				
					if (file != "") {
						configuration := readConfiguration(file)
						
						if (configuration.Count() > 0)
							this.selectStrategy(this.createStrategy(configuration))
					}
				case 4: ; "Save Strategy..."
					if this.SelectedStrategy {
						title := translate("Save Race Strategy...")
						
						fileName := (dirName . "\" . this.SelectedStrategy.Name . ".strategy")
						
						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
						FileSelectFile file, S17, %fileName%, %title%, Strategy (*.strategy)
						OnMessage(0x44, "")
					
						if (file != "") {
							if !InStr(file, ".")
								file := (file . ".strategy")
				
							SplitPath file, , , , name
							
							this.SelectedStrategy.setName(name)
								
							configuration := newConfiguration()
							
							this.SelectedStrategy.saveToConfiguration(configuration)
							
							writeConfiguration(file, configuration)
						}
					}
				case 6: ; "Compare Strategies..."
					title := translate("Choose two or more Race Strategies for comparison...")
				
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Compare", "Cancel"]))
					FileSelectFile files, M1, %dirName%, %title%, Strategy (*.strategy)
					OnMessage(0x44, "")
				
					strategies := []
					
					if (files != "") {
						directory := ""
						
						Loop Parse, files, `n
						{
							if (A_Index = 1)
								directory := A_LoopField
							else
								strategies.Push(this.createStrategy(readConfiguration(directory . "\" . A_LoopField)))
						}
						
						if (strategies.Count() > 1)
							this.compareStrategies(strategies*)
					}
				case 8: ; "Export Strategy..."
					if this.SelectedStrategy {
						configuration := newConfiguration()
						
						this.SelectedStrategy.saveToConfiguration(configuration)
						
						writeConfiguration(kUserConfigDirectory . "Race.strategy", configuration)
					}
				case 9: ; "Export Strategy..."
					try {
						FileDelete %kUserConfigDirectory%Race.strategy
					}
					catch exception {
						; ignore
					}
			}
		}
	}
	
	selectStrategy(strategy) {
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.PitstopListView
		
		LV_Delete()
		
		avgLapTimes := []
		avgFuelConsumption := []
		
		for ignore, pitstop in strategy.Pitstops {
			LV_Add("", pitstop.Lap, Ceil(pitstop.RefuelAmount), pitstop.TyreChange ? translate("x") : "-", pitstop.Map)
		
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
		
		compound := strategy.TyreCompound[true]
		GuiControl Choose, strategyCompoundDropDown, % inList(kQualifiedTyreCompounds, compound)
		
		GuiControl, , strategyPressureFLEdit, % strategy.TyrePressureFL
		GuiControl, , strategyPressureFREdit, % strategy.TyrePressureFR
		GuiControl, , strategyPressureRLEdit, % strategy.TyrePressureRL
		GuiControl, , strategyPressureRREdit, % strategy.TyrePressureRR
		
		this.showStrategyInfo(strategy)
		
		this.iSelectedStrategy := strategy
	}
	
	compareStrategies(strategies*) {
		local strategy
		
		vChartID += 1
		
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
					google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart%vChartID%);
		)

		after =
		(
				</script>
			</head>
		)
		
		chart := ("function drawChart" . vChartID . "() {`nvar data = new google.visualization.DataTable();")
			
		chart .= ("`ndata.addColumn('number', '" . translate("Minute") . "');")
		
		for ignore, strategy in strategies
			chart .= ("`ndata.addColumn('number', '" . strategy.Name . "');")
		
		chart .= "`ndata.addRows(["
		
		laps := []
		
		for ignore, strategy in strategies
			laps.Push(strategy.getLaps(120))
		
		Loop {
			if (A_Index > 1)
				chart .= ", "
			
			chart .= ("[" . (A_Index * 2))

			exhausted := true
			index := A_Index
			
			Loop % strategies.Length()
			{
				sLaps := laps[A_Index]
			
				hasData := (sLaps.Length() >= index)
			
				chart .= (", " . (hasData ? sLaps[index] : "null"))
				
				if hasData
					exhausted := false
			}
			
			chart .= "]"
			
			if exhausted
				break
		}
		
		html := ""
		
		for ignore, strategy in strategies {
			timesSeries := []
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
		
		chart .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Minute") . "' }, vAxis: { title: '" . translate("Lap") . "', viewWindow: { min: 0 } }, backgroundColor: 'D8D8D8' };`n")
				
		chart .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id" . vChartID . "')); chart.draw(data, options); }")
		
		chartArea := ("<div id=""header""><i><b>" . translate("Performance") . "</b></i></div><br><div id=""chart_id" . vChartID . """ style=""width: 778px; height: 348px"">")

		html := ("<html>" . before . chart . after . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #stints td { border-right: solid 1px #A0A0A0; } </style><style> #header { font-size: 12px; } </style><style> #data { border-collapse: separate; border-spacing: 10px; text-align: center; } </style>" . html . "<br><hr style=""width: 50`%""><br>" . chartArea . "</body></html>")
		
		this.showComparisonChart(html)
	}
	
	createStrategy(configuration := false) {
		return new Strategy(this, configuration)
	}
	
	acquireTelemetryData(ByRef progress, ByRef electronicsData, ByRef tyreData) {
		message := translate("Reading Electronics Data...")
		
		showProgress({progress: progress, message: message})
		
		telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
		
		electronicsData := telemetryDB.getMapData(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		
		Sleep 200
		
		message := translate("Reading Tyre Data...")
		
		showProgress({progress: progress, message: message})
		
		Sleep 200
		
		progress += 5
	}
	
	createScenarios(ByRef progress, electronicsData, tyreData) {
		local strategy
		
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet simMaxTyreLapsEdit
		GuiControlGet simInitialFuelAmountEdit
		GuiControlGet stintLengthEdit
		GuiControlGet simMapEdit
		GuiControlGet simFuelConsumptionEdit
		GuiControlGet simAvgLapTimeEdit
		
		GuiControlGet simInputDropDown
		
		fuelConsumption := simFuelConsumptionEdit
		maxTyreLaps := simMaxTyreLapsEdit
		
		consumption := 0
		tyreUsage := 0
		carWeight := 0
		
		this.getSimulationWeights(consumption, tyreUsage, carWeight)
		
		consumptionStep := (consumption / 4)
		tyreUsageStep := (tyreUsage / 4)
		
		scenarios := {}
		variation := 1
		
		Loop { ; consumption
			Loop { ; tyreUsage
				Loop { ; carWeight
					if ((simInputDropDown = 1) || (simInputDropDown = 3)) {
						if simMapEdit is number
						{			
							message := (translate("Creating Initial Scenario with Map ") . simMapEdit . translate("..."))
								
							showProgress({progress: progress, message: message})
							
							stintLaps := Floor((stintLengthEdit * 60) / simAvgLapTimeEdit)
								
							strategy := this.createStrategy()
							
							strategy.createStints(simInitialFuelAmountEdit, stintLaps, maxTyreLaps + (maxTyreLaps / 100 * tyreUsage), simMapEdit
												, simFuelConsumptionEdit - (simFuelConsumptionEdit / 100 * consumption), simAvgLapTimeEdit)
								
							scenarios[translate("Initial Conditions - Map ") . simMapEdit . translate(":") . variation++] := strategy
								
							Sleep 100
								
							progress += 1
						}
					}
					
					if (simInputDropDown > 1)
						for ignore, mapData in electronicsData {
							map := mapData["Map"]
							fuelConsumption := mapData["Fuel.Consumption"]
							avgLapTime := mapData["Lap.Time"]

							if map is number
							{
								message := (translate("Creating Telemetry Scenario with Map ") . map . translate("..."))
								
								showProgress({progress: progress, message: message})
							
								stintLaps := Floor((stintLengthEdit * 60) / avgLapTime)
								
								strategy := this.createStrategy()
							
								strategy.createStints(simInitialFuelAmountEdit, stintLaps, maxTyreLaps + (maxTyreLaps / 100 * tyreUsage), map
													, fuelConsumption - (fuelConsumption / 100 * consumption), avgLapTime)
								
								scenarios[translate("Telemetry - Map ") . map . translate(":") . variation++] := strategy
								
								Sleep 100
								
								progress += 1
							}
						}
						
					break
				}
				
				if (tyreUsage = 0)
					break
				else
					tyreUsage := Max(0, tyreUsage - tyreUsageStep)
			}
			
			if (consumption = 0)
				break
			else
				consumption := Max(0, consumption - consumptionStep)
		}
		
		progress := Floor(progress + 10)
		
		return scenarios
	}
	
	optimizeScenarios(ByRef progress, scenarios) {
		local strategy
		
		if (this.SelectedSessionType = "Duration")
			for name, strategy in scenarios {
				message := (translate("Optimzing stint length for Scenario ") . name . translate("..."))
			
				showProgress({progress: progress, message: message})
				
				avgLapTime := strategy.AvgLapTime[true]

				targetTime := this.calcSessionTime(avgLapTime, false)
				sessionTime := strategy.getSessionDuration()
				
				superfluousLaps := -1
				
				while (sessionTime > targetTime) {
					superfluousLaps += 1
					sessionTime -= avgLapTime
				}
				
				pitstopRequired := false
				refuelRequired := false
				tyreChangeRequired := false
				
				this.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)
				
				if ((strategy.Pitstops.Length() != 1) || !pitstopRequired)
					strategy.adjustLastPitstop(superfluousLaps)
				
				strategy.adjustLastPitstopRefuelAmount()
				
				Sleep 500
				
				progress += 1
			}
		
		progress := Floor(progress + 10)
		
		return scenarios
	}
	
	evaluateScenarios(ByRef progress, scenarios) {
		local strategy
		
		candidate := false
		
		for name, strategy in scenarios {
			message := (translate("Evaluating Scenario ") . name . translate("..."))
			
			showProgress({progress: progress, message: message})
			
			if !candidate
				candidate := strategy
			else {
				if (this.SelectedSessionType = "Duration") {
					sLaps := strategy.getSessionLaps()
					cLaps := candidate.getSessionLaps()
					sTime := strategy.getSessionDuration()
					cTime := candidate.getSessionDuration()
					
					if (sLaps > cLaps)
						candidate := strategy
					else if ((sLaps = cLaps) && (sTime < cTime))
						candidate := strategy
					else if ((sLaps = cLaps) && (sTime = cTime) && (candidate.FuelConsumption[true] < strategy.FuelConsumption[true] ))
						candidate := strategy
				}
				else if (strategy.getSessionDuration() < candidate.getSessionDuration())
					candidate := strategy
			}
			
			progress += 1
		
			Sleep 500
		}
		
		progress := Floor(progress + 10)
		
		return candidate
	}

	chooseScenario(ByRef progress, strategy) {
		window := this.Window
		
		Gui %window%:Default
		
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

	runSimulation() {
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
			
		window := this.Window
		
		progressWindow := showProgress({x: x, y: y, color: "Blue", title: translate("Acquiring Telemetry Data")})
		
		Gui %progressWindow%:+Owner%window%
		Gui %window%:+Disabled
		
		Sleep 200
		
		progress := 0
		
		electronicsData := false
		tyreData := false
		
		this.acquireTelemetryData(progress, electronicsData, tyreData)
		
		message := translate("Creating Scenarios...")
		
		showProgress({progress: progress, color: "Green", title: translate("Running Simulation")})
		
		Sleep 200
		
		scenarios := this.createScenarios(progress, electronicsData, tyreData)
		
		message := translate("Optimizing Scenarios...")
		
		showProgress({progress: progress, message: message})
		
		Sleep 200
		
		scenarios := this.optimizeScenarios(progress, scenarios)
		
		message := translate("Evaluating Scenarios...")
		
		showProgress({progress: progress, message: message})
		
		Sleep 200
		
		scenario := this.evaluateScenarios(progress, scenarios)
		
		if scenario {
			message := translate("Choose Scenario...")
			
			showProgress({progress: progress, message: message})
			
			Sleep 200
			
			this.chooseScenario(progress, scenario)
		}
		else
			this.chooseScenario(progress, false)
		
		message := translate("Finished...")
		
		showProgress({progress: 100, message: message})
		
		Sleep 1000
		
		hideProgress()
		
		Gui %window%:-Disabled
	}
}

class Strategy extends ConfigurationItem {
	iStrategyWorkbench := false
	
	iName := translate("Unnamed")
	
	iWeather := "Dry"
	iAirTemperature := 23
	iTrackTemperature := 27
	
	iSimulator := false
	iCar := false
	iTrack := false
	
	iSessionType := "Duration"
	iSessionLength := 0
	
	iMap := "n/a"
	iTC := "n/a"
	iABS := "n/a"
	
	iFuelAmount := 0
		
	iTyreCompound := "Dry"
	iTyreCompoundColor := "Black"
	iTyrePressureLF := "2.7"
	iTyrePressureLR := "2.7"
	iTyrePressureRF := "2.7"
	iTyrePressureRR := "2.7"
	
	iStintLaps := 0
	iMaxTyreLaps := 0
	
	iAvgLapTime := 0
	iFuelConsumption := 0
	iTyreLaps := 0
	
	iPitstops := []
	
	class Pitstop extends ConfigurationItem {
		iStrategy := false
		iID := false
		iLap := 0
		
		iTime := 0
		iDuration := 0
		iRefuelAmount := 0
		iTyreChange := false
		
		iStintLaps := 0
		iMap := 1
		iFuelConsumption := 0
		iAvgLapTime := 0
		
		iRemainingTime := 0
		iRemainingLaps := 0
		iRemainingTyreLaps := 0
		iRemainingFuel := 0
		
		Strategy[]  {
			Get {
				return this.iStrategy
			}
		}
		
		ID[]  {
			Get {
				return this.iID
			}
		}
		
		Lap[]  {
			Get {
				return this.iLap
			}
		}
		
		Time[]  {
			Get {
				return this.iTime
			}
		}
		
		Duration[] {
			Get {
				return this.iDuration
			}
		}
		
		TyreChange[] {
			Get {
				return this.iTyreChange
			}
		}
		
		RefuelAmount[] {
			Get {
				return this.iRefuelAmount
			}
		}
		
		StintLaps[] {
			Get {
				return this.iStintLaps
			}
		}
		
		Map[] {
			Get {
				return this.iMap
			}
		}
		
		FuelConsumption[] {
			Get {
				return this.iFuelConsumption
			}
		}
		
		AvgLapTime[] {
			Get {
				return this.iAvgLapTime
			}
		}
		
		RemainingLaps[] {
			Get {
				return this.iRemainingLaps
			}
		}
		
		RemainingTime[] {
			Get {
				return this.iRemainingTime
			}
		}
		
		RemainingTyreLaps[] {
			Get {
				return this.iRemainingTyreLaps
			}
		}
		
		RemainingFuel[] {
			Get {
				return this.iRemainingFuel
			}
		}
		
		__New(strategy, id, lap, configuration := false, adjustments := false) {
			this.iStrategy := strategy
			this.iID := id
			this.iLap := lap

			base.__New(configuration)
			
			if !configuration {
				pitstopRequired := false
				refuelRequired := false
				tyreChangeRequired := false
				
				strategy.StrategyWorkbench.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)
			
				remainingFuel := strategy.RemainingFuel[true]
				remainingLaps := strategy.RemainingLaps[true]
				fuelConsumption := strategy.FuelConsumption[true]
				lastStintLaps := Floor(Min(strategy.StintLaps[true], remainingFuel / fuelConsumption, strategy.LastPitstop ? (lap - strategy.LastPitstop.Lap) : lap))
				
				if (adjustments && adjustments.HasKey(id) && adjustments[id].HasKey("RemainingLaps"))
					remainingLaps := (adjustments[id].RemainingLaps + lastStintLaps)
				
				if (adjustments && adjustments.HasKey(id) && adjustments[id].HasKey("StintLaps"))
					stintLaps := adjustments[id].StintLaps
				else
					stintLaps := Floor(Min(remainingLaps - lastStintLaps, strategy.StintLaps, strategy.getMaxFuelLaps(fuelConsumption)))
				
				this.iStintLaps := stintLaps
				this.iMap := strategy.Map[true]
				this.iFuelConsumption := fuelConsumption
				this.iAvgLapTime := strategy.AvgLapTime[true]
				
				refuelAmount := strategy.calcRefuelAmount(stintLaps * fuelConsumption, remainingFuel, remainingLaps, lastStintLaps)
				tyreChange := kUndefined
				
				if (adjustments && adjustments.HasKey(id)) {
					if adjustments[id].HasKey("RefuelAmount")
						refuelAmount := adjustments[id].RefuelAmount
					
					if adjustments[id].HasKey("TyreChange")
						tyreChange := adjustments[id].TyreChange
				}
						
				if ((id == 1) && refuelRequired && (refuelAmount <= 0))
					refuelAmount := 1
				else if (refuelAmount <= 0)
					refuelAmount := 0
				
				this.iRemainingLaps := (remainingLaps - lastStintLaps)
				this.iRemainingFuel := (remainingFuel - (lastStintLaps * fuelConsumption) + refuelAmount)
				
				remainingTyreLaps := (strategy.RemainingTyreLaps[true] - lastStintLaps)
			
				if (tyreChange != kUndefined) {
					this.iTyreChange := tyreChange
					
					if tyreChange
						this.iRemainingTyreLaps := strategy.RemainingTyreLaps
					else
						this.iRemainingTyreLaps := remainingTyreLaps
				}
				else if ((remainingTyreLaps - stintLaps) >= 0) {
					if ((id == 1) && tyreChangeRequired && (remainingTyreLaps >= this.iRemainingLaps)) {
						this.iTyreChange := true
						this.iRemainingTyreLaps := strategy.RemainingTyreLaps
					}
					else
						this.iRemainingTyreLaps := remainingTyreLaps
				}
				else {
					this.iTyreChange := true
					this.iRemainingTyreLaps := strategy.RemainingTyreLaps
				}
				
				this.iRefuelAmount := refuelAmount
				this.iDuration := strategy.calcPitstopDuration(refuelAmount, this.TyreChange)
				
				lastPitstop := strategy.LastPitstop
								
				if lastPitstop {
					delta := (lastPitstop.Duration + (lastPitstop.StintLaps * lastPitstop.AvgLapTime))
				
					this.iTime := (lastPitstop.Time + delta)
					this.iRemainingTime := (lastPitstop.RemainingTime - delta)
				}
				else {
					this.iTime := (lastStintLaps * strategy.AvgLapTime[true])
					this.iRemainingTime := (strategy.RemainingTime - this.iTime)
				}
			}
		}
		
		loadFromConfiguration(configuration) {
			base.loadFromConfiguration(configuration)
			
			lap := this.Lap
			
			this.iTime := getConfigurationValue(configuration, "Pitstop", "Time." . lap, 0)
			this.iDuration := getConfigurationValue(configuration, "Pitstop", "Duration." . lap, 0)
			this.iRefuelAmount := getConfigurationValue(configuration, "Pitstop", "RefuelAmount." . lap, 0)
			this.iTyreChange := getConfigurationValue(configuration, "Pitstop", "TyreChange." . lap, false)
		
			this.iStintLaps := getConfigurationValue(configuration, "Pitstop", "StintLaps." . lap, 0)

			this.iMap := getConfigurationValue(configuration, "Pitstop", "Map." . lap, 0)
			this.iAvgLapTime := getConfigurationValue(configuration, "Pitstop", "AvgLapTime." . lap, 0)
			this.iFuelConsumption := getConfigurationValue(configuration, "Pitstop", "FuelConsumption." . lap, 0)

			this.iRemainingLaps := getConfigurationValue(configuration, "Pitstop", "RemainingLaps." . lap, 0)
			this.iRemainingTime := getConfigurationValue(configuration, "Pitstop", "RemainingTime." . lap, 0)
			this.iRemainingTyreLaps := getConfigurationValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, 0)
			this.iRemainingFuel := getConfigurationValue(configuration, "Pitstop", "RemainingFuel." . lap, 0.0)
		}
		
		saveToConfiguration(configuration) {
			base.saveToConfiguration(configuration)
			
			lap := this.Lap
			
			setConfigurationValue(configuration, "Pitstop", "Time." . lap, this.Time)
			setConfigurationValue(configuration, "Pitstop", "Duration." . lap, this.Duration)
			setConfigurationValue(configuration, "Pitstop", "RefuelAmount." . lap, Ceil(this.RefuelAmount))
			setConfigurationValue(configuration, "Pitstop", "TyreChange." . lap, this.TyreChange)
			
			setConfigurationValue(configuration, "Pitstop", "StintLaps." . lap, this.StintLaps)
			
			setConfigurationValue(configuration, "Pitstop", "Map." . lap, this.Map)
			setConfigurationValue(configuration, "Pitstop", "AvgLapTime." . lap, this.AvgLapTime)
			setConfigurationValue(configuration, "Pitstop", "FuelConsumption." . lap, this.FuelConsumption)
			
			setConfigurationValue(configuration, "Pitstop", "RemainingLaps." . lap, this.RemainingLaps)
			setConfigurationValue(configuration, "Pitstop", "RemainingTime." . lap, this.RemainingTime)
			setConfigurationValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, this.RemainingTyreLaps)
			setConfigurationValue(configuration, "Pitstop", "RemainingFuel." . lap, this.RemainingFuel)
		}
	}
	
	StrategyWorkbench[] {
		Get {
			return this.iStrategyWorkbench
		}
	}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	Simulator[] {
		Get {
			return this.iSimulator
		}
	}
	
	Car[] {
		Get {
			return this.iCar
		}
	}
	
	Track[] {
		Get {
			return this.iTrack
		}
	}
	
	Weather[] {
		Get {
			return this.iWeather
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
	
	SessionType[] {
		Get {
			return this.iSessionType
		}
	}
	
	SessionLength[] {
		Get {
			return this.iSessionLength
		}
	}

	Map[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.Map
			else
				return this.iMap
		}
	}
		
	TC[] {
		Get {
			return this.iTC
		}
	}
	
	ABS[] {
		Get {
			return this.iABS
		}
	}
	
	TyreCompound[colored := false] {
		Get {
			if colored
				return qualifiedCompound(this.iTyreCompound, this.iTyreCompoundColor)
			else
				return this.iTyreCompound
		}
	}
	
	TyreCompoundColor[] {
		Get {
			return this.iTyreCompoundColor
		}
	}
	
	TyrePressures[asText := false] {
		Get {
			pressures := [this.TyrePressureFL, this.TyrePressureFR, this.TyrePressureRL, this.TyrePressureRR]
			
			return (asText ? values2String(", ", pressures*) : pressures)
		}
	}
	
	TyrePressureFL[] {
		Get {
			return this.iTyrePressureFL
		}
	}
	
	TyrePressureFR[] {
		Get {
			return this.iTyrePressureFR
		}
	}
	
	TyrePressureRL[] {
		Get {
			return this.iTyrePressureRL
		}
	}
	
	TyrePressureRR[] {
		Get {
			return this.iTyrePressureRR
		}
	}

	StintLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.StintLaps
			else
				return this.iStintLaps
		}
	}
	
	MaxTyreLaps[] {
		Get {
			return this.iMaxTyreLaps
		}
	}

	RemainingLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingLaps
			else
				return this.calcSessionLaps()
		}
	}

	RemainingTime[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingTime
			else
				return this.calcSessionTime()
		}
	}

	RemainingFuel[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingFuel
			else
				return this.iFuelAmount
		}
	}

	RemainingTyreLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingTyreLaps
			else
				return this.iTyreLaps
		}
	}

	AvgLapTime[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.AvgLapTime
			else
				return this.iAvgLapTime
		}
	}
	
	FuelConsumption[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.FuelConsumption
			else
				return this.iFuelConsumption
		}
	}
	
	Pitstops[index := false] {
		Get {
			return (index ? this.iPitstops[index] : this.iPitstops)
		}
	}
	
	LastPitstop[] {
		Get {
			length := this.Pitstops.Length()
			
			return ((length = 0) ? false : this.iPitstops[length])
		}
	}
	
	__New(strategyWorkbench, configuration := false) {
		this.iStrategyWorkbench := strategyWorkbench
		
		base.__New(configuration)
		
		if !configuration {
			window := strategyWorkbench.Window
			
			Gui %window%:Default
			
			GuiControlGet sessionLengthEdit
			GuiControlGet simMaxTyreLapsEdit
			GuiControlGet simCompoundDropDown
			
			this.iSimulator := strategyWorkbench.SelectedSimulator
			this.iCar := strategyWorkbench.SelectedCar
			this.iTrack := strategyWorkbench.SelectedTrack
			
			this.iWeather := strategyWorkbench.SelectedWeather
			this.iAirTemperature := strategyWorkbench.AirTemperature
			this.iTrackTemperature := strategyWorkbench.TrackTemperature
			
			this.iSessionType := strategyWorkbench.SelectedSessionType
			this.iSessionLength := sessionLengthEdit
			
			compound := false
			compoundColor := false
			
			splitQualifiedCompound(kQualifiedTyreCompounds[simCompoundDropDown], compound, compoundColor)
			
			this.iTyreCompound := compound
			this.iTyreCompoundColor := compoundColor
			
			this.iMaxTyreLaps := simMaxTyreLapsEdit
			
			if (this.iTyreCompound = "Dry") {
				this.iTyrePressureFL := 27.7
				this.iTyrePressureFR := 27.7
				this.iTyrePressureRL := 27.7
				this.iTyrePressureRR := 27.7
			}
			else {
				this.iTyrePressureFL := 30.0
				this.iTyrePressureFR := 30.0
				this.iTyrePressureRL := 30.0
				this.iTyrePressureRR := 30.0
			}
			
			telemetryDB := new TelemetryDatabase(this.Simulator, this.Car, this.Track)
			lowestLapTime := false
			
			for ignore, row in telemetryDB.getLapTimePressures(this.Weather, this.TyreCompound, this.TyreCompoundColor) {
				lapTime := row["Lap.Time"]
			
				if (!lowestLapTime || (lapTime < lowestLapTime)) {
					lowestLapTime := lapTime
					
					this.iTyrePressureFL := Round(row["Tyre.Pressure.Front.Left"], 1)
					this.iTyrePressureFR := Round(row["Tyre.Pressure.Front.Right"], 1)
					this.iTyrePressureRL := Round(row["Tyre.Pressure.Rear.Left"], 1)
					this.iTyrePressureRR := Round(row["Tyre.Pressure.Rear.Right"], 1)
				}
			}
		}
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iName := getConfigurationValue(configuration, "General", "Name", translate("Unnamed"))
		
		this.iSimulator := getConfigurationValue(configuration, "Session", "Simulator", "Unknown")
		this.iCar := getConfigurationValue(configuration, "Session", "Car", "Unknown")
		this.iTrack := getConfigurationValue(configuration, "Session", "Track", "Unknown")
	
		this.iWeather := getConfigurationValue(configuration, "Weather", "Weather", "Dry")
		this.iAirTemperature := getConfigurationValue(configuration, "Weather", "AirTemperature", 23)
		this.iTrackTemperature := getConfigurationValue(configuration, "Weather", "TrackTemperature", 27)
		
		this.iSessionType := getConfigurationValue(configuration, "Session", "SessionType", "Duration")
		this.iSessionLength := getConfigurationValue(configuration, "Session", "SessionLength", 0)
		
		this.iMap := getConfigurationValue(configuration, "Setup", "Map", "n/a")
		this.iTC := getConfigurationValue(configuration, "Setup", "TC", "n/a")
		this.iABS := getConfigurationValue(configuration, "Setup", "ABS", "n/a")
		
		this.iFuelAmount := getConfigurationValue(configuration, "Setup", "FuelAmount", 0.0)
		
		this.iTyreCompound := getConfigurationValue(configuration, "Setup", "TyreCompound", "Dry")
		this.iTyreCompoundColor := getConfigurationValue(configuration, "Setup", "TyreCompoundColor", "Black")
		
		defaultPressure := ((this.iTyreCompound = "Dry") ? 27.7 : 30.0)
		
		this.iTyrePressureFL := getConfigurationValue(configuration, "Setup", "TyrePressureFL", defaultPressure)
		this.iTyrePressureFR := getConfigurationValue(configuration, "Setup", "TyrePressureFR", defaultPressure)
		this.iTyrePressureRL := getConfigurationValue(configuration, "Setup", "TyrePressureRL", defaultPressure)
		this.iTyrePressureRR := getConfigurationValue(configuration, "Setup", "TyrePressureRR", defaultPressure)
		
		this.iStintLaps := getConfigurationValue(configuration, "Strategy", "StintLaps", 0)
		this.iMaxTyreLaps := getConfigurationValue(configuration, "Strategy", "MaxTyreLaps", 0)
		
		this.iAvgLapTime := getConfigurationValue(configuration, "Strategy", "AvgLapTime", 0)
		this.iFuelConsumption := getConfigurationValue(configuration, "Strategy", "FuelConsumption", 0)
		this.iTyreLaps:= getConfigurationValue(configuration, "Strategy", "TyreLaps", 0)
		
		for ignore, lap in string2Values(",", getConfigurationValue(configuration, "Strategy", "Pitstops", ""))
			this.Pitstops.Push(new this.Pitstop(this, A_Index, lap, configuration))
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "General", "Name", this.Name)
		
		setConfigurationValue(configuration, "Weather", "Weather", this.Weather)
		setConfigurationValue(configuration, "Weather", "AirTemperature", this.AirTemperature)
		setConfigurationValue(configuration, "Weather", "TrackTemperature", this.TrackTemperature)
		
		setConfigurationValue(configuration, "Session", "Simulator", this.Simulator)
		setConfigurationValue(configuration, "Session", "Car", this.Car)
		setConfigurationValue(configuration, "Session", "Track", this.Track)
		
		setConfigurationValue(configuration, "Session", "SessionType", this.SessionType)
		setConfigurationValue(configuration, "Session", "SessionLength", this.SessionLength)
		
		setConfigurationValue(configuration, "Setup", "Map", this.Map)
		setConfigurationValue(configuration, "Setup", "TC", this.TC)
		setConfigurationValue(configuration, "Setup", "ABS", this.ABS)
		
		setConfigurationValue(configuration, "Setup", "FuelAmount", this.RemainingFuel)
		
		setConfigurationValue(configuration, "Setup", "TyreCompound", this.TyreCompound)
		setConfigurationValue(configuration, "Setup", "TyreCompoundColor", this.TyreCompoundColor)
		
		setConfigurationValue(configuration, "Setup", "TyrePressureFL", this.TyrePressureFL)
		setConfigurationValue(configuration, "Setup", "TyrePressureFR", this.TyrePressureFR)
		setConfigurationValue(configuration, "Setup", "TyrePressureRL", this.TyrePressureRL)
		setConfigurationValue(configuration, "Setup", "TyrePressureRR", this.TyrePressureRR)
		
		setConfigurationValue(configuration, "Strategy", "StintLaps", this.StintLaps)
		setConfigurationValue(configuration, "Strategy", "MaxTyreLaps", this.MaxTyreLaps)
		
		setConfigurationValue(configuration, "Strategy", "AvgLapTime", this.AvgLapTime)
		setConfigurationValue(configuration, "Strategy", "FuelConsumption", this.FUelConsumption)
		setConfigurationValue(configuration, "Strategy", "TyreLaps", this.RemainingTyreLaps)
		
		pitstops := []
		
		for ignore, pitstop in this.Pitstops {
			pitstops.Push(pitstop.Lap)
		
			pitstop.saveToConfiguration(configuration)
		}
		
		setConfigurationValue(configuration, "Strategy", "Pitstops", values2String(", ", pitstops*))
	}
	
	setName(name) {
		this.iName := name
	}
	
	getLaps(seconds) {
		laps := []
		
		index := false
		curTime := 0
		maxTime := 0
		avgLapTime := this.AvgLapTime
		
		if !this.LastPitstop
			numLaps := this.getSessionLaps()
		else
			numLaps := this.Pitstops[1].Lap
		
		maxTime := (numLaps * (avgLapTime / 60))
			
		Loop {
			Loop
				if (curTime > maxTime)
					break
				else {
					curTime += (seconds / 60)
				
					laps.Push(Floor((curTime / maxTime) * numLaps))
				}
			
			if !index {
				if !this.LastPitstop
					return laps
				
				index := 1
			}
			else
				index += 1
			
			if (index > this.Pitstops.Length())
				return laps
			else {
				pitstop := this.Pitstops[index]
			
				avgLapTime := pitstop.AvgLapTime
				numLaps += pitstop.StintLaps
				maxTime := ((pitstop.Time / 60) + (pitstop.Duration / 60) + (pitstop.StintLaps * (avgLapTime / 60)))
			}
		}
	}
	
	calcSessionLaps() {
		return this.StrategyWorkbench.calcSessionLaps(this.AvgLapTime)
	}
	
	calcSessionTime() {
		return this.StrategyWorkbench.calcSessionTime(this.AvgLapTime)
	}
	
	getMaxFuelLaps(fuelConsumption) {
		return this.StrategyWorkbench.getMaxFuelLaps(fuelConsumption)
	}
	
	calcRefuelAmount(targetFuel, startFuel, remainingLaps, stintLaps) {
		remainingFuel := Max(0, startFuel - (stintLaps * this.FuelConsumption[true]))
		
		return this.StrategyWorkbench.calcRefuelAmount(targetFuel, remainingFuel)
	}

	calcPitstopDuration(refuelAmount, changeTyres) {
		return this.StrategyWorkbench.calcPitstopDuration(refuelAmount, changeTyres)
	}
	
	calcNextPitstopLap(pitstopNr, currentLap, remainingLaps, remainingTyreLaps, remainingFuel) {
		fuelConsumption := this.FuelConsumption[true]
		targetLap := (currentLap + Floor(Min(this.StintLaps, remainingTyreLaps, remainingFuel / fuelConsumption, this.getMaxFuelLaps(fuelConsumption))))
		
		if (pitstopNr = 1) {
			pitstopRequired := false
			refuelRequired := false
			tyreChangeRequired := false
			
			this.StrategyWorkbench.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)
			
			if (((targetLap >= remainingLaps) && pitstopRequired) || IsObject(pitstopRequired)) {
				if (pitstopRequired == true)
					targetLap := remainingLaps - 2
				else
					targetLap := Min(targetLap, Floor((pitstopRequired[1] + ((pitstopRequired[2] - pitstopRequired[1]) / 2)) * 60 / this.AvgLapTime))
			}
		}
		
		return targetLap
	}
	
	createStints(startFuel, stintLaps, tyreLaps, map, fuelConsumption, avgLapTime, adjustments := false) {
		this.iFuelAmount := startFuel
		this.iStintLaps := stintLaps
		this.iTyreLaps := tyreLaps
		
		this.iMap := map
		this.iFuelConsumption := fuelConsumption
		this.iAvgLapTime := avgLapTime
		
		this.iPitstops := []
		
		currentLap := 0
		
		sessionLaps := this.RemainingLaps
		
		Loop {
			remainingFuel := this.RemainingFuel[true]
		
			if (this.SessionType = "Duration") {
				if (this.RemainingTime[true] <= 0)
					break
			}
			else {
				if (currentLap >= this.RemainingLaps)
					break
			}
			
			pitstopLap := this.calcNextPitstopLap(A_Index, currentLap, this.RemainingLaps[true], this.RemainingTyreLaps[true], remainingFuel)
			
			pitstop := new this.Pitstop(this, A_Index, pitstopLap, false, adjustments)
			
			if (this.SessionType = "Duration") {
				if (pitStop.RemainingTime <= 0)
					break
			}
			else {
				if (pitstop.Lap >= this.RemainingLaps)
					break
			}
			
			currentLap := pitstopLap
		
			if ((pitstop.StintLaps > 0) && ((pitstop.RefuelAmount > 0) || (pitstop.TyreChange)))
				this.Pitstops.Push(pitstop)
			else
				break
		}
	}
	
	adjustLastPitstop(superfluousLaps) {
		while (superfluousLaps > 0) {
			pitstop := this.LastPitstop
		
			if pitstop {
				stintLaps := pitstop.StintLaps
				
				if (stintLaps <= superfluousLaps) {
					superfluousLaps -= stintLaps
				
					this.Pitstops.Pop()
					
					continue
				}
				else {
					pitstop.iStintLaps -= superfluousLaps
				
					delta := Min((superfluousLaps * pitstop.FuelConsumption), pitstop.iRefuelAmount)
					
					pitstop.iRefuelAmount -= delta
					pitstop.iRemainingFuel -= delta
					
					this.iDuration := pitstop.Strategy.calcPitstopDuration(this.RefuelAmount, this.TyreChange)
				}
			}
			
			break
		}
	}
	
	adjustLastPitstopRefuelAmount() {
		pitstops := this.Pitstops
		numPitstops := pitstops.Length()
		
		if (pitstops.Length() > 1) {
			refuelAmount := Ceil((pitstops[numPitstops - 1].RefuelAmount + pitstops[numPitstops].RefuelAmount) / 2)
			remainingLaps := Ceil(pitstops[numPitstops - 1].StintLaps + pitstops[numPitstops].StintLaps)
			stintLaps := Ceil(remainingLaps / 2)
			
			adjustments := {}
			adjustments[numPitstops - 1] := {RefuelAmount: refuelAmount, RemainingLaps: remainingLaps, StintLaps: stintLaps}
			adjustments[numPitstops] := {StintLaps: stintLaps}
			
			this.createStints(this.RemainingFuel, this.StintLaps, this.RemainingTyreLaps, this.Map, this.FuelConsumption, this.AvgLapTime, adjustments)
		}
	}
	
	getPitstopTime() {
		time := 0
		
		for ignore, pitstop in this.Pitstops
			time += pitstop.Duration
		
		return time
	}
	
	getSessionLaps() {
		pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Lap + pitstop.StintLaps)
		else
			return this.RemainingLaps
	}
	
	getSessionDuration() {
		pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Time + pitstop.Duration + (pitstop.StintLaps * pitstop.AvgLapTime))
		else
			return this.RemainingTime
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

qualifiedCompound(compound, compoundColor) {
	if (compound= "Dry") {
		if (compoundColor = "Black")
			return "Dry"
		else
			return ("Dry (" . compoundColor . ")")
	}
	else
		return "Wet"
}

splitQualifiedCompound(qualifiedCompound, ByRef compound, ByRef compoundColor) {
	compoundColor := "Black"
	
	index := inList(kQualifiedTyreCompounds, qualifiedCompound)
	
	if (index == 1)
		compound := "Wet"
	else {
		compound := "Dry"
	
		if (index > 2)
			compoundColor := ["Red", "White", "Blue"][index - 2]
	}
}

readSimulatorData(simulator) {
	dataFile := kTempDirectory . simulator . " Data\Setup.data"
	exePath := kBinariesDirectory . simulator . " SHM Provider.exe"
	
	FileCreateDir %kTempDirectory%%simulator% Data
	
	try {
		RunWait %ComSpec% /c ""%exePath%" -Setup > "%dataFile%"", , Hide
		
		data := readConfiguration(dataFile)
		
		setupData := getConfigurationSectionValues(data, "Setup Data")
		
		RunWait %ComSpec% /c ""%exePath%" > "%dataFile%"", , Hide
		
		data := readConfiguration(dataFile)
		
		setConfigurationSectionValues(data, "Setup Data", setupData)
		
		return data
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"}) . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration..."), {simulator: simulator, protocol: "SHM", exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

filterSchema(schema) {
	newSchema := []
	
	for ignore, column in schema
		if !inList(["Weather", "Tyre.Compound", "Tyre.Compound.Color"], column)
			newSchema.Push(column)
		
	return newSchema
}

closeWorkbench() {
	ExitApp 0
}

moveWorkbench() {
	moveByMouse(StrategyWorkbench.Instance.Window)
}

openWorkbenchDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development
}

chooseSimulator() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet simulatorDropDown
	
	workbench.loadSimulator(simulatorDropDown)
}

chooseCar() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet carDropDown
	
	workbench.loadCar(carDropDown)
}

chooseTrack() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet trackDropDown
	
	workbench.loadTrack(trackDropDown)
}

chooseWeather() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet weatherDropDown
	
	workbench.loadWeather(kWeatherOptions[weatherDropDown])
}

updateTemperatures() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit
	
	workbench.setTemperatures(airTemperatureEdit, trackTemperatureEdit)
}

chooseCompound() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet compoundDropDown
	
	workbench.loadCompound(kQualifiedTyreCompounds[compoundDropDown])
}

chooseDataType() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	GuiControlGet compoundDropDown
	GuiControlGet dataTypeDropDown
	
	dataType := ["Electronics", "Tyres"][dataTypeDropDown]
	schema := filterSchema(new TelemetryDatabase().getSchema(dataType, true))
	
	workbench.iSelectedDataType := dataType
	
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
	
	workbench.loadChart(workbench.SelectedChartType)
	
	GuiControlGet compoundDropDown
	
	workbench.loadCompound(kQualifiedTyreCompounds[compoundDropDown], true)
}

chooseData() {
	LV_Modify(A_EventInfo, "-Select")
}

chooseAxis() {
	StrategyWorkbench.Instance.loadChart(StrategyWorkbench.Instance.SelectedChartType)
}

chooseChartSource() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
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
	window := StrategyWorkbench.Instance.Window
	
	Gui %window%:Default
	
	GuiControlGet chartTypeDropDown
	
	StrategyWorkbench.Instance.loadChart(["Scatter", "Bar", "Bubble", "Line"][chartTypeDropDown])
}

chooseSessionType() {
	GuiControlGet sessionTypeDropDown
	
	StrategyWorkbench.Instance.selectSessionType(["Duration", "Laps"][sessionTypeDropDown])
}

choosePitstopRequirements() {
	GuiControlGet pitstopRequirementsDropDown
	
	if (pitstopRequirementsDropDown = 3) {
		GuiControl Show, pitstopWindowEdit
		GuiControl Show, pitstopWindowLabel
	}
	else {
		GuiControl Hide, pitstopWindowEdit
		GuiControl Hide, pitstopWindowLabel
	}
	
	if (pitstopRequirementsDropDown = 1) {
		GuiControl Choose, tyreChangeRequirementsDropDown, 1
		GuiControl Choose, refuelRequirementsDropDown, 1
		
		GuiControl Hide, tyreChangeRequirementsLabel
		GuiControl Hide, tyreChangeRequirementsDropDown
		GuiControl Hide, refuelRequirementsLabel
		GuiControl Hide, refuelRequirementsDropDown
	}
	else {
		GuiControl Show, tyreChangeRequirementsLabel
		GuiControl Show, tyreChangeRequirementsDropDown
		GuiControl Show, refuelRequirementsLabel
		GuiControl Show, refuelRequirementsDropDown
	}
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
	StrategyWorkbench.Instance.runSimulation()
}

setButtonIcon(buttonHandle, file, index := 1, options := "") {
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin	
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
}

fixIE(version := 0, exeName := "") {
	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := {7: 7000, 8: 8888, 9: 9999, 10: 10001, 11: 11001}
	
	if versions.HasKey(version)
		version := versions[version]
	
	if !exeName {
		if A_IsCompiled
			exeName := A_ScriptName
		else
			SplitPath A_AhkPath, exeName
	}
	
	RegRead previousValue, HKCU, %key%, %exeName%

	if (version = "")
		RegDelete, HKCU, %key%, %exeName%
	else
		RegWrite, REG_DWORD, HKCU, %key%, %exeName%, %version%
	
	return previousValue
}

runStrategyWorkbench() {
	icon := kIconsDirectory . "Dashboard.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Strategy Workbench
	
	simulator := "Assetto Corsa Competizione"
	car := false
	track := false
	duration := false
	weather := "Dry"
	airTemperature := 23
	trackTemperature:= 27
	compound := "Dry"
	compoundColor := "Black"
	
	index := 1
	
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
			case "-Duration":
				duration := A_Args[index + 1]
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
	
	if ((airTemperature <= 0) || (trackTemperature <= 0)) {
		airTemperature := false
		trackTemperature := false
	}
	
	current := fixIE(11)
	
	try {
		workbench := new StrategyWorkbench(simulator, car, track, duration, weather, airTemperature, trackTemperature
										 , compound, compoundColor, map, tc, abs)
		
		workbench.createGui(workbench.Configuration)
		workbench.show()
	}
	finally {
		fixIE(current)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

runStrategyWorkbench()