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
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown
global compoundDropDown
global dataTypeDropDown
global dataXDropDown
global dataY1DropDown
global dataY2DropDown
global dataY3DropDown
global chartTypeDropDown

global chartViewer
global strategyViewer
global simulationViewer
		
global sessionTypeDropDown
global raceDurationEdit = 60
global raceDurationLabel
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
global refuelRequirementsDropDown

global pitstopDeltaEdit = 30
global pitstopTyreServiceEdit = 30
global pitstopRefuelServiceEdit = 1.2
global fuelCapacityEdit = 125
global safetyFuelEdit = 5

global simCompoundEdit
global simMaxTyreLifeEdit = 40
global simInitialFuelAmountEdit = 90
global simMapEdit = 1
global simTCEdit = 1
global simABSEdit = 2

global simConsumptionWeight = 20
global simTyreUsageWeight = 60
global simCarWeightWeight = 80

global simNumPitstopResult = ""
global simNumTyreChangeResult = ""
global simConsumedFuelResult = ""
global simPitlaneSecondsResult = ""
global simSessionResultResult = ""
global simSessionResultLabel

global strategyStartMapEdit = 1
global strategyStartTCEdit = 1
global strategyStartABSEdit = 2
global strategyAvgLapTimeEdit = 120
global strategyFuelConsumptionEdit = 3.8

global strategyCompoundDropDown
global strategyPressureFLEdit = 27.7
global strategyPressureFREdit = 27.7
global strategyPressureRLEdit = 27.7
global strategyPressureRREdit = 27.7

class StrategyWorkbench extends ConfigurationItem {
	iDataListView := false
	
	iTelemetryDatabase := false
	
	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	iSelectedWeather := "Dry"
	iSelectedCompound := "Dry"
	iSelectedCompoundColor := "Black"
	
	iSelectedDataType := "Electronics"
	iSelectedChartType := "Scatter"
	
	iSelectedSessionType := "Duration"
	
	iAirTemperature := 23
	iTrackTemperature := 27
	
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
	
	TelemetryDatabase[] {
		Get {
			return this.iTelemetryDatabase
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
			if colored {
				if (this.iSelectedCompound = "Dry") {
					if (this.iSelectedCompoundColor = "Black")
						return "Dry"
					else
						return ("Dry (" . this.iSelectedCompoundColor . ")")
				}
				else
					return "Wet"
			}
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
		
		Gui %window%:Add, ListView, x90 yp-2 w120 h97 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdataListView gchooseData, % values2String("|", map(["Map", "Count"], "translate")*)
		
		this.iDataListView := dataListView
		
		Gui %window%:Add, Text, x220 yp+2 w70 h23 +0x200, % translate("X-Axis")
		
		schema := filterSchema(kTelemetrySchemas["Electronics"])
		
		chosen := inList(schema, "Map")
		Gui %window%:Add, DropDownList, x270 yp w110 AltSubmit Choose%chosen% vdataXDropDown gchooseAxis, % values2String("|", map(schema, "translate")*)
		
		Gui %window%:Add, Text, x220 yp+24 w70 h23 +0x200, % translate("Series")
		
		chosen := inList(schema, "Fuel.Consumption")
		Gui %window%:Add, DropDownList, x270 yp w110 AltSubmit Choose%chosen% vdataY1DropDown gchooseAxis, % values2String("|", map(schema, "translate")*)
		Gui %window%:Add, DropDownList, x270 yp+24 w110 AltSubmit Choose1 vdataY2DropDown gchooseAxis, % translate("None") . "|" . values2String("|", map(schema, "translate")*)
		Gui %window%:Add, DropDownList, x270 yp+24 w110 AltSubmit Choose1 vdataY3DropDown gchooseAxis, % translate("None") . "|" . values2String("|", map(schema, "translate")*)
		
		Gui %window%:Add, Text, x400 ys w40 h23 +0x200, % translate("Chart")
		Gui %window%:Add, DropDownList, x444 yp w80 AltSubmit Choose1 +0x200, % values2String("|", map(["Telemetry", "Strategy"], "translate")*)
		Gui %window%:Add, DropDownList, x529 yp w80 AltSubmit Choose1 vchartTypeDropDown gchooseChartType, % values2String("|", map(["Scatter", "Bar", "Bubble", "Line"], "translate")*)
		
		Gui %window%:Add, ActiveX, x400 yp+24 w800 h278 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x8 yp+286 w1200 0x10

		Gui %window%:Font, s10 Bold, Arial
			
		Gui %window%:Add, Picture, x16 yp+10 w30 h30 Section, %kIconsDirectory%Strategy.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Strategy")
		
		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, DropDownList, x220 yp-2 w180 AltSubmit Choose1 +0x200 VsettingsMenuDropDown gsettingsMenu, % values2String("|", map(["Settings", "---------------------------------------------", "Initialize from Setup Database...", "Initialize from Telemetry...", "Initialize from Simulation...", "Initialize from Defaults...", "---------------------------------------------", "Save Defaults"], "translate")*)
		
		Gui %window%:Add, DropDownList, x405 yp w180 AltSubmit Choose1 +0x200 VsimulationMenuDropDown gsimulationMenu, % values2String("|", map(["Simulation", "---------------------------------------------", "Set Target Fuel Consumption...", "Set Target Tyre Usage...", "---------------------------------------------", "Run Simulation", "---------------------------------------------", "Use as Strategy..."], "translate")*)
		
		Gui %window%:Add, DropDownList, x590 yp w180 AltSubmit Choose1 +0x200 VstrategyMenuDropDown gstrategyMenu, % values2String("|", map(["Strategy", "---------------------------------------------", "Load Strategy...", "Save Strategy...", "Compare Strategies...", "---------------------------------------------", "Export Strategy..."], "translate")*)
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x619 ys+39 w577 h9, % translate("Summary")
		
		Gui %window%:Add, ActiveX, x619 yp+21 w577 h169 Border vstrategyViewer, shell.explorer
		
		strategyViewer.Navigate("about:blank")
		
		this.showSummary("Space to rent...")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x8 y626 w1200 0x10
		
		Gui %window%:Add, Button, x574 y632 w80 h23 GcloseWorkbench, % translate("Close")

		Gui %window%:Add, Tab, x16 ys+39 w593 h192 -Wrap Section, % values2String("|", map(["Rules && Settings", "Pitstop && Service", "Simulation", "Strategy"], "translate")*)
		
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
		
		x11 := x7 + 82
		x12 := x11 + 56
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w209 h147, % translate("Race")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, DropDownList, x%x0% yp+21 w70 AltSubmit Choose1 gchooseSessionType VsessionTypeDropDown, % values2String("|", map(["Duration", "Laps"], "translate")*)
		Gui %window%:Add, Edit, x%x1% yp w50 h20 Limit4 Number VraceDurationEdit, %raceDurationEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-9999 0x80, %raceDurationEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w60 h20 VraceDurationLabel, % translate("Minutes")
		
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
		
		Gui %window%:Add, GroupBox, -Theme x243 ys+34 w354 h147, % translate("Pitstop")
		
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x5% yp+23 w90 h20, % translate("Pitstop")
		Gui %window%:Add, DropDownList, x%x7% yp-4 w75 AltSubmit Choose3 VpitstopRequirementsDropDown gchoosePitstopRequirements, % values2String("|", map(["Optional", "Required", "Window"], "translate")*)
		Gui %window%:Add, Edit, x%x11% yp+1 w50 h20 VpitstopWindowEdit, %pitstopWindowEdit%
		Gui %window%:Add, Text, x%x12% yp+3 w110 h20 VpitstopWindowLabel, % translate("Minute (From - To)")

		Gui %window%:Add, Text, x%x5% yp+22 w85 h23 +0x200, % translate("Tyre Change")
		Gui %window%:Add, DropDownList, x%x7% yp w75 AltSubmit Choose1 VtyreChangeRequirementsDropDown, % values2String("|", map(["Required", "Optional"], "translate")*)

		Gui %window%:Add, Text, x%x5% yp+26 w85 h23 +0x200, % translate("Refuel")
		Gui %window%:Add, DropDownList, x%x7% yp w75 AltSubmit Choose1 VrefuelRequirementsDropDown, % values2String("|", map(["Required", "Optional"], "translate")*)
		
		Gui %window%:Tab, 2
		
		x := 32
		x0 := x - 4
		x1 := x + 94
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w350 h147, % translate("Pitstop")
				
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
		; Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %fuelCapacityEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Liter")
		
		Gui %window%:Add, Text, x%x% yp+19 w85 h23 +0x200, % translate("Safety Fuel")
		Gui %window%:Add, Edit, x%x1% yp+1 w50 h20 VsafetyFuelEdit, %safetyFuelEdit%
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

		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w179 h147, % translate("Initial Conditions")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x%x% yp+21 w85 h23 +0x200, % translate("Compound")
		
		compound := this.SelectedCompound[true]
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x%x1% yp w84 AltSubmit Choose%chosen% VsimCompoundEdit, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("Max Tyre Life")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 VsimMaxTyreLifeEdit, %simMaxTyreLifeEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simMaxTyreLifeEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w47 h20, % translate("Laps")
				
		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Tank Filling")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 VsimInitialFuelAmountEdit, %simInitialFuelAmountEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simInitialFuelAmountEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w47 h20, % translate("Liter")
		
		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Map")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 VsimMapEdit, %simMapEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simMapEdit%
		
		Gui %window%:Add, Text, x%x% yp+25 w70 h20 +0x200, % translate("TC / ABS")
		Gui %window%:Add, Edit, x%x1% yp-1 w40 h20 VsimTCEdit, %simTCEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simTCEdit%
		
		Gui %window%:Add, Edit, x%x3% yp w40 h20 VsimABSEdit, %simABSEdit%
		Gui %window%:Add, UpDown, x%x5% yp-2 w18 h20, %simABSEdit%
		
		x := 222
		x0 := x - 4
		x1 := x + 104
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x214 ys+34 w174 h147, % translate("Optimizer")
		
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w100 h20 +0x200, % translate("Fuel Consumption")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimConsumptionWeight, %simConsumptionWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Tyre Usage")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimTyreUsageWeight, %simTyreUsageWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Car Weight")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimCarWeightWeight, %simCarWeightWeight%
		
		Gui %window%:Add, Button, x%x% yp+48 w160 h20 grunSimulation, % translate("Simulate!")
		
		x := 407
		x0 := x - 4
		x1 := x + 89
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x399 ys+34 w197 h147, % translate("Results")
		
		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+21 w90 h20 +0x200, % translate("# Pitstops")
		Gui %window%:Add, Text, x%x1% yp-1 w40 h20 Border VsimNumPitstopResult, %simNumPitstopResult%
		
		Gui %window%:Add, Text, x%x% yp+25 w90 h20 +0x200, % translate("# Tyre Changes")
		Gui %window%:Add, Text, x%x1% yp-1 w40 h20 Border VsimNumTyreChangeResult, %simNumTyreChangeResult%
				
		Gui %window%:Add, Text, x%x% yp+25 w90 h20 +0x200, % translate("Consumed Fuel")
		Gui %window%:Add, Text, x%x1% yp-1 w40 h20 Border VsimConsumedFuelResult, %simConsumedFuelResult%
		Gui %window%:Add, Text, x%x3% yp+4 w50 h20, % translate("Liter")
				
		Gui %window%:Add, Text, x%x% yp+21 w90 h20 +0x200, % translate("@ Pitlane")
		Gui %window%:Add, Text, x%x1% yp-1 w40 h20 Border VsimPitlaneSecondsResult, %simPitlaneSecondsResult%
		Gui %window%:Add, Text, x%x3% yp+4 w50 h20, % translate("Seconds")
				
		Gui %window%:Add, Text, x%x% yp+21 w90 h20 +0x200, % translate("@ Finish")
		Gui %window%:Add, Text, x%x1% yp-1 w40 h20 Border VsimSessionResultResult, %simSessionResultResult%
		Gui %window%:Add, Text, x%x3% yp+4 w50 h20 VsimSessionResultLabel, % translate("Laps")
		
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
		
		Gui %window%:Add, GroupBox, -Theme x24 ys+34 w179 h147, % translate("Electronics")
		
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
		
		Gui %window%:Add, Text, x%x% yp+23 w85 h23 +0x200, % translate("Avg. Laptime")
		Gui %window%:Add, Edit, x%x1% yp w50 h20 Limit3 Number VstrategyAvgLapTimeEdit, %strategyAvgLapTimeEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 Range1-999 0x80, %strategyAvgLapTimeEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Sec.")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Consumption")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 VstrategyFuelConsumptionEdit, %strategyFuelConsumptionEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Ltr.")
		
		x := 222
		x0 := x + 50
		x1 := x + 70
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x214 ys+34 w174 h147, % translate("Tyres")
		
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

		Gui %window%:Add, GroupBox, -Theme x399 ys+34 w197 h147, % translate("Pitstops")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, ListView, x%x% yp+21 w180 h115 -Multi -LV0x10 AltSubmit NoSort NoSortHdr, % values2String("|", map(["Lap", "Refuel", "Tyre Change", "Map"], "translate")*)
		
		this.iDataListView := dataListView
		
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
	
	showChart(drawChartFunction) {
		window := this.Window
		
		Gui %window%:Default
		
		chartViewer.Document.open()
		
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

			chartViewer.Document.write(before . drawChartFunction . after)
		}
		else {
			html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
		
			chartViewer.Document.write(html)
		}
		
		chartViewer.Document.close()
	}
	
	showSummary(summary) {
		window := this.Window
		
		Gui %window%:Default
		
		html := "<html><head><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><div>" . summary . "</div></body></html>"

		strategyViewer.Document.Open()
		strategyViewer.Document.Write(html)
		strategyViewer.Document.Close()
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
		
		this.showChart(drawChartFunction)
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
		
		schema := filterSchema(kTelemetrySchemas[this.SelectedDataType])
		
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
			GuiControl, , raceDurationLabel, % translate("Minutes")
			GuiControl, , simSessionResultLabel, % translate("Laps")
		}
		else {
			GuiControl, , raceDurationLabel, % translate("Laps")
			GuiControl, , simSessionResultLabel, % translate("Seconds")
		}
	}
	
	calcSessionLaps(avgLapTime) {
		GuiControlGet raceDurationEdit
		GuiControlGet formationLapCheck
		GuiControlGet postRaceLapCheck
		
		if (this.SelectedSessionType = "Duration")
			return Ceil(((raceDurationEdit * 60) / avgLapTime) + (formationLapCheck ? 1 : 0) + (postRaceLapCheck ? 1 : 0))
		else
			return (raceDurationEdit + (formationLapCheck ? 1 : 0) + (postRaceLapCheck ? 1 : 0))
	}
	
	calcRefuelAmount(targetFuel, currentFuel) {
		GuiControlGet safetyFuelEdit
		GuiControlGet fuelCapacityEdit
		
		return (Min(fuelCapacityEdit, targetFuel) - currentFuel)
	}

	calcPitstopDuration(refuelAmount, changeTyres) {
		GuiControlGet pitstopDeltaEdit
		GuiControlGet pitstopTyreServiceEdit
		GuiControlGet pitstopRefuelServiceEdit
		
		return (pitstopDeltaEdit + (changeTyres ? pitstopTyreServiceEdit : 0) + ((refuelAmount / 10) * pitstopRefuelServiceEdit))
	}
	
	chooseSettingsMenu(line) {
		switch line {
			case 3: ; "Load from Setup Database..."
			case 4: ; "Update from Telemetry..."
				if (this.SelectedSimulator && this.SelectedCar && this.SelectedTrack) {
					telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
					
					mapData := telemetryDB.getMapData(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
					tyreData := telemetryDB.getTyreData(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
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
							
							return false
					}
					
					data := readSimulatorData(prefix)
				}
			case 6: ; "Load Defaults..."
			case 8: ; "Save Defaults"
		}
	}
	
	chooseSimulationMenu(line) {
		switch line {
			case 3: ; "Set Target Fuel Consumption..."
			case 4: ; "Set Target Tyre Usage..."
			case 6: ; "Run Simulation"
				this.runSimulation()
			case 8: ; "Use as Strategy..."
		}
	}
	
	chooseStrategyMenu(line) {
		switch line {
			case 3: ; "Load Strategy..."
			case 4: ; "Save Strategy..."
			case 5: ; "Compare Strategies..."
			case 7: ; "Export Strategy..."
		}
	}
	
	acquireTelemetryData(ByRef progress) {
		message := translate("Reading electronics data...")
		
		showProgress({progress: progress, message: message})
		
		Sleep 1000
		
		message := translate("Reading tyre data...")
		
		showProgress({progress: progress, message: message})
		
		Sleep 1000
		
		progress += 5
	}
	
	createScenarios(ByRef progress) {
		scenarios := []
		
		for ignore, name in ["Fast Map", "Slow Map", "Max Tyre Usage", "Fresh Tyres"] {
			message := translate("Scenario " . A_Index . ": " . name)
			
			showProgress({progress: progress, message: message, title: translate("Preparing Scenarios")})
		
			scenarios.Push({Name: name})
			
			progress += 2
		
			Sleep 1000
		}
		
		progress := Floor(progress + 10)
		
		return scenarios
	}
	
	evaluateScenarios(scenarios, ByRef progress) {
		for ignore, scenario in scenarios {
			message := translate("Scenario " . A_Index . ": " . scenario.Name)
			
			showProgress({progress: progress, message: message, title: translate("Evaluating Scenarios")})
			
			progress += 2
		
			Sleep 1000
		}
		
		progress := Floor(progress + 10)
	}
	
	createStrategy() {
		return new Strategy(this)
	}

	runSimulation() {
		local strategy := this.createStrategy()
		
		telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
		
		GuiControlGet simMaxTyreLifeEdit
		GuiControlGet simInitialFuelAmountEdit
		GuiControlGet stintLengthEdit
		
		for ignore, mapData in telemetryDB.getMapData(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor) {
			map := mapData["Map"]
			fuelConsumption := mapData["Fuel.Consumption"]
			avgLapTime := mapData["Lap.Time"]
		
			stintLaps := Floor((stintLengthEdit * 60) / avgLapTime)
			
			strategy.createPitstops(simInitialFuelAmountEdit, stintLaps, simMaxTyreLifeEdit, map, fuelConsumption, avgLapTime)
		}
		
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
			
		showProgress({x: x, y: y, color: "Blue", title: translate("Acquiring Telemetry Information")})
		
		progress := 0
		
		this.acquireTelemetryData(progress)
		
		message := translate("Creating scenarios...")
		
		showProgress({progress: progress, message: message})
		
		scenarios := this.createScenarios(progress)
		
		message := translate("Evaluating scenarios...")
		
		showProgress({progress: progress, color: "Green", message: message, title: translate("Running Simulation")})
		
		scenario := this.evaluateScenarios(scenarios, progress)
		
		Sleep 1000
			
		message := translate("Stint length...")
		
		showProgress({progress: progress, message: message, title: translate("Perform final optimizations")})
		
		progress += 10
		
		Sleep 1000
			
		message := translate("Fuel consumption...")
		
		showProgress({progress: progress, message: message})
		
		Sleep 1000
			
		message := translate("Finished...")
		
		showProgress({progress: 100, message: message})
		
		Sleep 2000
		
		hideProgress()
	}
}

class Strategy {
	iStrategyWorkbench := false
	
	iStintLaps := 0
	iFuelAmount := 0
	iTyreLaps := 0
	
	iMap := 1
	iAvgLapTime := 0
	iFuelConsumption := 0
	
	iPitstops := []
	
	class Pitstop {
		iStrategy := false
		iLap := 0
		
		iRefuelAmount := 0
		iTyreChange := false
		iDuration := 0
		
		iStintLaps := 0
		iMap := 1
		iFuelConsumption := 0
		
		iRemainingLaps := 0
		iRemainingFuel := 0
		iRemainingTyreLaps := 0
		
		Strategy[]  {
			Get {
				return this.iStrategy
			}
		}
		
		Lap[]  {
			Get {
				return this.iLap
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
		
		Duration[] {
			Get {
				return this.iDuration
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
		
		RemainingLaps[] {
			Get {
				return this.iRemainingLaps
			}
		}
		
		RemainingFuel[] {
			Get {
				return this.iRemainingFuel
			}
		}
		
		RemainingTyreLaps[] {
			Get {
				return this.iRemainingTyreLaps
			}
		}
		
		__New(strategy, lap) {
			remainingFuel := strategy.RemainingFuel[true]
			remainingLaps := strategy.RemainingLaps[true]
			fuelConsumption := strategy.FuelConsumption[true]
			lastStintLaps := Floor(Min(strategy.StintLaps[true], remainingFuel / fuelConsumption))
			
			stintLaps := Floor(Min(remainingLaps, strategy.StintLaps))
			
			this.iStrategy := strategy
			this.iLap := lap
			
			this.iStintLaps := stintLaps
			this.iMap := strategy.Map[true]
			this.iFuelConsumption := strategy.FuelConsumption[true]
			
			refuelAmount := strategy.calcRefuelAmount(remainingFuel, remainingLaps, lastStintLaps)
			
			this.iRemainingLaps := (remainingLaps - lastStintLaps)
			this.iRemainingFuel := (remainingFuel - (lastStintLaps * fuelConsumption) + refuelAmount)
			
			remainingTyreLaps := (strategy.RemainingTyreLaps[true] - strategy.StintLaps[true])
			
			if ((remainingTyreLaps - stintLaps) >= 0)
				this.iRemainingTyreLaps := remainingTyreLaps
			else {
				this.iTyreChange := true
				this.iRemainingTyreLaps := strategy.RemainingTyreLaps
			}
			
			this.iRefuelAmount := refuelAmount
			this.iDuration := strategy.calcPitstopDuration(refuelAmount, this.TyreChange)
		}
	}
	
	StrategyWorkbench[] {
		Get {
			return this.iStrategyWorkbench
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

	RemainingLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingLaps
			else
				return this.calcSessionLaps()
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

	Map[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.Map
			else
				return this.iMap
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
	
	Pitstops[] {
		Get {
			return this.iPitstops
		}
	}
	
	LastPitstop[] {
		Get {
			length := this.Pitstops.Length()
			
			return ((length = 0) ? false : this.iPitstops[length])
		}
	}
	
	__New(strategyWorkbench) {
		this.iStrategyWorkbench := strategyWorkbench
	}
	
	calcSessionLaps() {
		return this.StrategyWorkbench.calcSessionLaps(this.AvgLapTime)
	}
	
	calcRefuelAmount(startFuel, remainingLaps, stintLaps) {
		targetFuel := ((remainingLaps - stintLaps) * this.FuelConsumption)
		remainingFuel := Max(0, startFuel - (stintLaps * this.FuelConsumption))
		
		return this.StrategyWorkbench.calcRefuelAmount(targetFuel, remainingFuel)
	}

	calcPitstopDuration(refuelAmount, changeTyres) {
		return this.StrategyWorkbench.calcPitstopDuration(refuelAmount, changeTyres)
	}
	
	calcNextPitstopLap(currentLap, remainingLaps, remainingTyreLaps, remainingFuel) {
		return (currentLap + Floor(Min(this.StintLaps, remainingFuel / this.FuelConsumption[true])))
	}
	
	createPitstops(startFuel, stintLaps, tyreLaps, map, fuelConsumption, avgLapTime) {
		this.iFuelAmount := startFuel
		this.iStintLaps := stintLaps
		this.iTyreLaps := tyreLaps
		
		this.iMap := map
		this.iFuelConsumption := fuelConsumption
		this.iAvgLapTime := avgLapTime
		
		this.iPitstops := []
		
		currentLap := 0
		pitstopNr := 1
		
		sessionLaps := this.RemainingLaps
		
		Loop {
			remainingFuel := this.RemainingFuel[true]
		
			if ((currentLap + (remainingFuel / this.FuelConsumption[true])) >= sessionLaps)
				break
			
			pitstopLap := this.calcNextPitstopLap(currentLap, this.RemainingLaps[true], this.RemainingTyreLaps[true], remainingFuel)
			
			pitstop := new this.Pitstop(this, pitstopLap)
			
			currentLap := pitstopLap
			pitstopNr += 1
			
			this.Pitstops.Push(pitstop)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

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
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-workbench
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
	schema := filterSchema(kTelemetrySchemas[dataType])
	
	workbench.iSelectedDataType := dataType
	
	GuiControl, , dataXDropDown, % "|" . values2String("|", map(schema, "translate")*)
	GuiControl, , dataY1DropDown, % "|" . values2String("|", map(schema, "translate")*)
	GuiControl, , dataY2DropDown, % "|" . translate("None") . "|" . values2String("|", map(schema, "translate")*)
	GuiControl, , dataY3DropDown, % "|" . translate("None") . "|" . values2String("|", map(schema, "translate")*)
	
	if (dataType = "Electronics") {
		GuiControl Choose, dataXDropDown, % inList(schema, "Map")
		GuiControl Choose, dataY1DropDown, % inList(schema, "Fuel.Consumption")
	}
	else if (dataType = "Tyres") {
		GuiControl Choose, dataXDropDown, % inList(schema, "Lap.Time")
		GuiControl Choose, dataY1DropDown, % inList(schema, "Fuel.Remaining")
	}
	
	GuiControl Choose, dataY2DropDown, 1
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
}

settingsMenu() {
	GuiControlGet settingsMenuDropDown
	
	StrategyWorkbench.Instance.chooseSettingsMenu(settingsMenuDropDown)
	
	GuiControl Choose, settingsMenuDropDown, 1
}

simulationMenu() {
	GuiControlGet simulationMenuDropDown
	
	StrategyWorkbench.Instance.chooseSimulationMenu(simulationMenuDropDown)
	
	GuiControl Choose, simulationMenuDropDown, 1
}

strategyMenu() {
	GuiControlGet strategyMenuDropDown
	
	StrategyWorkbench.Instance.chooseStrategyMenu(strategyMenuDropDown)
	
	GuiControl Choose, strategyMenuDropDown, 1
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
	
	RegRead PreviousValue, HKCU, %key%, %exeName%

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