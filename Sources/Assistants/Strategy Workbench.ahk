;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Workbench Tool         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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

#Include Libraries\SettingsDatabase.ahk
#Include Libraries\TelemetryDatabase.ahk
#Include Libraries\Strategy.ahk
#Include Libraries\StrategyViewer.ahk


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
global stratViewer
		
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
global pitstopWindowEdit = "25 - 35"
global pitstopWindowLabel
global tyreChangeRequirementsDropDown
global tyreChangeRequirementsLabel
global refuelRequirementsDropDown
global refuelRequirementsLabel

global tyreSetDropDown
global tyreSetCountEdit
global tyreSetAddButton
global tyreSetDeleteButton

global pitstopDeltaEdit = 60
global pitstopTyreServiceEdit = 30
global pitstopFuelServiceEdit = 1.2
global pitstopServiceDropDown
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
global simtyreCompoundVariationWeight = 0
global simInitialFuelWeight = 0

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
	
	iAvailableCompounds := kQualifiedTyreCompounds
	
	iSelectedCompound := "Dry"
	iSelectedCompoundColor := "Black"
	
	iSelectedDataType := "Electronics"
	iSelectedChartType := "Scatter"

	iSelectedValidator := false
	
	iSelectedSessionType := "Duration"
	
	iTelemetryChartHTML := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
	iStrategyChartHTML := this.iTelemetryChartHTML
	
	iTyreSetListView := false
	
	iSelectedScenario := false
	iSelectedStrategy := false
	
	iAirTemperature := 23
	iTrackTemperature := 27
	
	iPitstopListView := false
	
	iStrategyViewer := false
	
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
	
	AvailableCompounds[index := false] {
		Get {
			return (index ? this.iAvailableCompounds[index] : this.iAvailableCompounds)
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
		local compound
		
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
		
		Gui %window%:Add, Text, x16 yp+32 w364 0x10
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, Text, x16 yp+10 w364 h23 Center +0x200, % translate("Chart")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, DropDownList, x12 yp+28 w76 AltSubmit Choose1 vdataTypeDropDown gchooseDataType +0x200, % values2String("|", map(["Electronics", "Tyres", "-----------------", "Cleanup Data"], "translate")*)
		
		Gui %window%:Add, ListView, x12 yp+24 w170 h123 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdataListView gchooseData, % values2String("|", map(["Compound", "Map", "#"], "translate")*)
		
		this.iDataListView := dataListView
		
		compound := this.SelectedCompound[true]
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}
		
		Gui %window%:Add, Text, x195 yp w70 h23 +0x200, % translate("Compound")
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
		
		Gui %window%:Add, ActiveX, x400 yp+24 w800 h302 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x8 yp+310 w1200 0x10

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

		Gui %window%:Add, GroupBox, -Theme x619 ys+39 w577 h9, % translate("Strategy")
		
		Gui %window%:Add, ActiveX, x619 yp+21 w577 h193 Border vstratViewer, shell.explorer
		
		stratViewer.Navigate("about:blank")
		
		this.iStrategyViewer := new StrategyViewer(window, stratViewer)
		
		this.showStrategyInfo(false)
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x8 y676 w1200 0x10
		
		Gui %window%:Add, Button, x574 y684 w80 h23 GcloseWorkbench, % translate("Close")

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
		Gui %window%:Add, Text, x%x12% yp+3 w110 h20 VpitstopWindowLabel, % translate("Minute (From - To)")

		Gui %window%:Add, Text, x%x5% yp+22 w75 h23 +0x200 VrefuelRequirementsLabel, % translate("Refuel")
		Gui %window%:Add, DropDownList, x%x7% yp w80 AltSubmit Choose2 VrefuelRequirementsDropDown, % values2String("|", map(["Optional", "Required", "Disallowed"], "translate")*)

		Gui %window%:Add, Text, x%x5% yp+26 w75 h23 +0x200 VtyreChangeRequirementsLabel, % translate("Tyre Change")
		Gui %window%:Add, DropDownList, x%x7% yp w80 AltSubmit Choose2 VtyreChangeRequirementsDropDown, % values2String("|", map(["Optional", "Required", "Disallowed"], "translate")*)
		
		Gui %window%:Add, Text, x%x5% yp+26 w75 h23 +0x200, % translate("Tyre Sets")
		
		w12 := (x11 + 50 - x7)
		
		Gui %window%:Add, ListView, x%x7% yp w%w12% h65 -Multi -Hdr -LV0x10 AltSubmit NoSort NoSortHdr HWNDtyreSetListView gchooseTyreSet, % values2String("|", map(["Compound", "#"], "translate")*)
	
		this.iTyreSetListView := tyreSetListView
		
		x13 := (x7 + w12 + 5)
		
		Gui %window%:Add, DropDownList, x%x13% yp w116 AltSubmit Choose0 vtyreSetDropDown gupdateTyreSet, % values2String("|", map(kQualifiedTyreCompounds, "translate")*)
		
		Gui %window%:Add, Edit, x%x13% yp+24 w40 h20 Limit2 Number vtyreSetCountEdit gupdateTyreSet
		Gui %window%:Add, UpDown, x%x13% yp w18 h20 0x80
		
		x13 := (x7 + w12 + 5 + 116 - 48)
	
		Gui %window%:Add, Button, x%x13% yp+18 w23 h23 Center +0x200 HWNDaddButtonHandle vtyreSetAddButton gaddTyreSet
		setButtonIcon(addButtonHandle, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		
		x13 += 25
		
		Gui %window%:Add, Button, x%x13% yp w23 h23 Center +0x200 HWNDdeleteButtonHandle vtyreSetDeleteButton gdeleteTyreSet
		setButtonIcon(deleteButtonHandle, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		
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
		Gui %window%:Add, Edit, x%x1% yp-1 w50 h20 VpitstopFuelServiceEdit, %pitstopFuelServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Refuel of 10 litres)")
		
		Gui %window%:Add, Text, x%x% yp+24 w160 h23, % translate("Service")
		Gui %window%:Add, DropDownList, x%x1% yp-3 w100 AltSubmit Choose1 vpitstopServiceDropDown, % values2String("|", map(["Simultaneous", "Sequential"], "translate")*)

		Gui %window%:Add, Text, x%x% yp+27 w85 h20 +0x200, % translate("Fuel Capacity")
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
		x3 := x2 + 28
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
		Gui %window%:Add, Edit, x%x1% yp-1 w45 h20 Number VsimMaxTyreLapsEdit, %simMaxTyreLapsEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simMaxTyreLapsEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w45 h20, % translate("Laps")
				
		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Fuel Amount")
		Gui %window%:Add, Edit, x%x1% yp-1 w45 h20 Number VsimInitialFuelAmountEdit, %simInitialFuelAmountEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simInitialFuelAmountEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w45 h20, % translate("Liter")
		
		Gui %window%:Add, Text, x%x% yp+21 w70 h20 +0x200, % translate("Map")
		Gui %window%:Add, Edit, x%x1% yp-1 w45 h20 VsimMapEdit, %simMapEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20, %simMapEdit%
		
		Gui %window%:Add, Text, x%x% yp+23 w85 h23 +0x200, % translate("Avg. Lap Time")
		Gui %window%:Add, Edit, x%x1% yp w45 h20 Limit3 Number VsimAvgLapTimeEdit, %simAvgLapTimeEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w30 h20, % translate("Sec.")

		Gui %window%:Add, Text, x%x% yp+21 w85 h20 +0x200, % translate("Consumption")
		Gui %window%:Add, Edit, x%x1% yp-2 w45 h20 VsimFuelConsumptionEdit, %simFuelConsumptionEdit%
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
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimConsumptionWeight, %simConsumptionWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Initial Fuel")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimInitialFuelWeight, %simInitialFuelWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Tyre Usage")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimTyreUsageWeight, %simTyreUsageWeight%
		
		Gui %window%:Add, Text, x%x% yp+24 w100 h20 +0x200, % translate("Tyre Compound")
		Gui %window%:Add, Slider, x%x1% yp w60 0x10 Range0-100 ToolTip VsimtyreCompoundVariationWeight, %simtyreCompoundVariationWeight%
		
		Gui %window%:Add, Text, x214 yp+32 w40 h23 +0x200, % translate("Use")
		
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
		
		this.updateState()
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
					<div id="chart_id" style="width: 798px; height: 285px"></div>
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
	
	updateState() {
		window := this.Window
		
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
			
		oldTChoice := ["Optional", "Required", "Disallowed"][tyreChangeRequirementsDropDown]
		oldFChoice := ["Optional", "Required", "Disallowed"][refuelRequirementsDropDown]
		
		if (pitstopRequirementsDropDown = 1) {
			GuiControl, , tyreChangeRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Disallowed"], "translate")*)
			GuiControl, , refuelRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Disallowed"], "translate")*)
			
			oldTChoice := inList(["Optional", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Disallowed"], oldFChoice)
			
			GuiControl Choose, tyreChangeRequirementsDropDown, % oldTChoice ? oldTChoice : 1
			GuiControl Choose, refuelRequirementsDropDown, % oldFChoice ? oldFChoice : 1
		}
		else {
			GuiControl, , tyreChangeRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Required", "Disallowed"], "translate")*)
			GuiControl, , refuelRequirementsDropDown, % "|" . values2String("|", map(["Optional", "Required", "Disallowed"], "translate")*)
			
			oldTChoice := inList(["Optional", "Required", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Required", "Disallowed"], oldFChoice)
			
			GuiControl Choose, tyreChangeRequirementsDropDown, % oldTChoice ? oldTChoice : 1
			GuiControl Choose, refuelRequirementsDropDown, % oldFChoice ? oldFChoice : 1
		}
	}
	
	updateSettingsMenu() {
		window := this.Window
		
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
			
			if ((value = "n/a") || (isNull(value)))
				value := kNull

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
		return new SessionDatabase().getSimulators()
	}
	
	getCars(simulator) {
		return new SessionDatabase().getCars(simulator)
	}
	
	getTracks(simulator, car) {
		return new SessionDatabase().getTracks(simulator, car)
	}
	
	loadSimulator(simulator, force := false) {
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedSimulator := simulator
			
			sessionDB := new SessionDatabase()
			
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
			
			this.loadDataType(this.SelectedDataType, true)
		}
	}
	
	setTemperatures(airTemperature, trackTemperature) {
		this.iAirTemperature := airTemperature
		this.iTrackTemperature := trackTemperature
	}
	
	loadDataType(dataType, force := false) {
		local compound
		
		if (force || (this.SelectedDataType != dataType)) {
			this.showTelemetryChart(false)
			
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedDataType := dataType
			
			telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
			
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
				
				LV_Add("", translateQualifiedCompound(compound, compoundColor), value, category.Count)
				
				compound := qualifiedCompound(compound, compoundColor)
				
				if !inList(availableCompounds, compound)
					availableCompounds.Push(compound)
			}
			
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			
			this.iAvailableCompounds := availableCompounds

			GuiControl, , compoundDropDown, % "|" . values2String("|", map(availableCompounds, "translate")*)
			
			if (availableCompounds.Length() == 0) {
				GuiControl, , dataXDropDown, |
				GuiControl, , dataY1DropDown, |
				GuiControl, , dataY2DropDown, |
				GuiControl, , dataY3DropDown, |
			}
			else {
				schema := filterSchema(new TelemetryDatabase().getSchema(dataType, true))
					
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
	
	loadCompound(compound, force := false) {
		if (force || (this.SelectedCompound[true] != compound)) {
			window := this.Window
				
			Gui %window%:Default
		
			if compound {
				GuiControl Choose, compoundDropDown, % inList(this.AvailableCompounds, compound)
				
				compoundString := compound
				
				splitQualifiedCompound(compound, compound, compoundColor)
				
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
		}
	}
	
	loadChart(chartType) {
		local compound
		
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
	
	chooseSettingsMenu(line) {
		local compound
		local strategy
		
		window := this.Window
						
		Gui %window%:Default
		
		switch line {
			case 3: ; "Load from Strategy"
				simulator := this.SelectedSimulator
				car := this.SelectedCar
				track := this.SelectedTrack
				
				if (simulator && car && track) {
					strategy := this.SelectedStrategy
					
					if strategy {
						GuiControl, , pitstopDeltaEdit, % strategy.PitstopDelta
						GuiControl, , pitstopTyreServiceEdit, % strategy.PitstopTyreService
						GuiControl, , pitstopFuelServiceEdit, % strategy.PitstopFuelService
						GuiControl Choose, pitstopServiceDropDown, % (strategy.PitstopServiceOrder = "Simultaneous") ? 1 : 2
						GuiControl, , safetyFuelEdit, % strategy.SafetyFuel
						GuiControl, , fuelCapacityEdit, % strategy.FuelCapacity
						
						this.iSelectedValidator := strategy.Validator
						
						pitstopRule := strategy.PitstopRule
						
						if !pitstopRule
							GuiControl Choose, pitstopRequirementsDropDown, 1
						else if IsObject(pitstopRule) {
							GuiControl Choose, pitstopRequirementsDropDown, 3
						
							pitstopWindowEdit := values2String("-", pitstopRule*)
						}
						else {
							GuiControl Choose, pitstopRequirementsDropDown, 3
						
							pitstopWindowEdit := pitstopRule
						}
						
						choosePitstopRequirements()
		
						if pitstopRule {
							GuiControl Choose, refuelRequirementsDropDown, % inList(["Optional", "Required", "Disallowed"], strategy.RefuelRule)
							GuiControl Choose, tyreChangeRequirementsDropDown, % inList(["Optional", "Required", "Disallowed"], strategy.TyreChangeRule)
						}
						else {
							GuiControl Choose, refuelRequirementsDropDown, % inList(["Optional", "Disallowed"], strategy.RefuelRule)
							GuiControl Choose, tyreChangeRequirementsDropDown, % inList(["Optional", "Disallowed"], strategy.TyreChangeRule)
						}
						
						Gui ListView, % this.TyreSetListView
						
						LV_Delete()
						
						for ignore, descriptor in strategy.TyreSets
							LV_Add("", translateQualifiedCompound(descriptor[1], descriptor[2]), descriptor[3])
						
						LV_ModifyCol()
					
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
						
						GuiControl Choose, simCompoundDropDown, % inList(kQualifiedTyreCompounds, qualifiedCompound(compound, compoundColor))
						
						GuiControl, , simAvgLapTimeEdit, % Round(strategy.AvgLapTime, 1)
						GuiControl, , simFuelConsumptionEdit, % Round(strategy.FuelConsumption, 2)
						GuiControl, , simMaxTyreLapsEdit, % Round(strategy.MaxTyreLaps)
						
						GuiControl, , simInitialFuelAmountEdit, % Round(strategy.RemainingFuel)
						GuiControl, , simMapEdit, % strategy.Map

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
				simulator := this.SelectedSimulator
				car := this.SelectedCar
				track := this.SelectedTrack
				
				if (simulator && car && track) {
					if GetKeyState("Ctrl", "P") {
						telemetryDB := new TelemetryDatabase(simulator, car, track)
						simulatorCode := telemetryDB.getSimulatorCode(simulator)
						
						dirName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings
						
						FileCreateDir %dirName%
						
						title := translate("Load Race Settings...")
								
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
							GuiControl, , pitstopFuelServiceEdit, % getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", 1.5)
							GuiControl Choose, pitstopServiceDropDown, % (getConfigurationValue(settings, "Strategy Settings", "Service.Order", "Simulataneous") = "Simulataneous") ? 1 : 2
							GuiControl, , safetyFuelEdit, % getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin", 3)
							
							compound := getConfigurationValue(settings, "Session Setup", "Tyre.Compound", "Dry")
							compoundColor := getConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")
							
							GuiControl Choose, simCompoundDropDown, % inList(kQualifiedTyreCompounds, qualifiedCompound(compound, compoundColor))
							
							GuiControl, , simAvgLapTimeEdit, % Round(getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", 120), 1)
							GuiControl, , simFuelConsumptionEdit, % Round(getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", 3.0), 2)
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
				simulator := this.SelectedSimulator
				car := this.SelectedCar
				track := this.SelectedTrack
				
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
						
						if (getConfigurationValue(settings, "Strategy Settings", "Service.Refuel", kUndefined) != kUndefined)
							GuiControl, , pitstopFuelServiceEdit, % getConfigurationValue(settings, "Strategy Settings", "Service.Refuel")
						
						if (getConfigurationValue(settings, "Strategy Settings", "Service.Order", kUndefined) != kUndefined)
							GuiControl Choose, pitstopServiceDropDown, % (getConfigurationValue(settings, "Strategy Settings", "Service.Order") = "Simulataneous") ? 1 : 2
						
						if (getConfigurationValue(settings, "Strategy Settings", "Fuel.SafetyMargin", kUndefined) != kUndefined)
							GuiControl, , safetyFuelEdit, % getConfigurationValue(settings, "Session Settings", "Fuel.SafetyMargin")
						
						if ((getConfigurationValue(settings, "Session Settings", "Tyre.Compound", kUndefined) != kUndefined)
						 && (getConfigurationValue(settings, "Session Settings", "Tyre.Compound.Color", kUndefined) != kUndefined)) {
							compound := getConfigurationValue(settings, "Session Setup", "Tyre.Compound")
							compoundColor := getConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color")
						
							GuiControl Choose, simCompoundDropDown, % inList(kQualifiedTyreCompounds, qualifiedCompound(compound, compoundColor))
						}
						
						if (getConfigurationValue(settings, "Session Settings", "Lap.AvgTime", kUndefined) != kUndefined)
							GuiControl, , simAvgLapTimeEdit, % Round(getConfigurationValue(settings, "Session Settings", "Lap.AvgTime"), 1)
						
						if (getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", kUndefined) != kUndefined)
							GuiControl, , simFuelConsumptionEdit, % Round(getConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption"), 2)
					}
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("You must first select a car and a track.")
					OnMessage(0x44, "")
				}
			case 6: ; "Update from Telemetry..."
				if (this.SelectedSimulator && this.SelectedCar && this.SelectedTrack) {
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
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("You must first select a car and a track.")
					OnMessage(0x44, "")
				}
			case 7: ; "Import from Simulation..."
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
						
						if ((compound != kUndefined) && (compoundColor != kUndefined))
							GuiControl Choose, simCompoundDropDown, % inList(kQualifiedTyreCompounds, qualifiedCompound(compound, compoundColor))
						
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
	
	chooseSimulationMenu(line) {
		local strategy
		
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
		local strategy
		
		simulator := this.SelectedSimulator
		car := this.SelectedCar
		track := this.SelectedTrack
		
		if (simulator && car && track) {
			telemetryDB := new TelemetryDatabase(simulator, car, track)
			simulatorCode := telemetryDB.getSimulatorCode(simulator)
			
			dirName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Strategies
			
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
				
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
				FileSelectFile file, 1, %dirName%, %title%, Strategy (*.strategy)
				OnMessage(0x44, "")
			
				if (file != "") {
					configuration := readConfiguration(file)
					
					if (configuration.Count() > 0)
						this.selectStrategy(this.createStrategy(configuration))
				}
			case 5: ; "Save Strategy..."
				if this.SelectedStrategy {
					title := translate("Save Race Strategy...")
					
					fileName := (((dirName != "") ? (dirName . "\") : "") . this.SelectedStrategy.Name . ".strategy")
					
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
			case 7: ; "Compare Strategies..."
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
			case 9: ; "Export Strategy..."
				if this.SelectedStrategy {
					configuration := newConfiguration()
					
					this.SelectedStrategy.saveToConfiguration(configuration)
					
					writeConfiguration(kUserConfigDirectory . "Race.strategy", configuration)
				}
			case 10: ; "Clear Strategy..."
				try {
					FileDelete %kUserConfigDirectory%Race.strategy
				}
				catch exception {
					; ignore
				}
		}
	}
	
	selectStrategy(strategy) {
		local compound
		
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
		
		compound := qualifiedCompound(strategy.TyreCompound, strategy.TyreCompoundColor)
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

		tableCSS := getTableCSS()
		
		html := ("<html>" . before . chart . after . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } </style>" . html . "<br><hr style=""width: 50`%""><br>" . chartArea . "</body></html>")
		
		this.showComparisonChart(html)
	}
	
	createStrategy(nameOrConfiguration := false) {
		name := nameOrConfiguration
		
		if !IsObject(nameOrConfiguration)
			nameOrConfiguration := false
		
		theStrategy := new Strategy(this, nameOrConfiguration)
		
		if (name && !IsObject(name))
			theStrategy.setName(name)
		
		return theStrategy
	}
	
	getStrategySettings(ByRef simulator, ByRef car, ByRef track, ByRef weather, ByRef airTemperature, ByRef trackTemperature
					  , ByRef sessionType, ByRef sessionLength
					  , ByRef maxTyreLaps, ByRef tyreCompound, ByRef tyreCompoundColor, ByRef tyrePressures) {
		local compound
		
		window := this.Window
			
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
		
		splitQualifiedCompound(kQualifiedTyreCompounds[simCompoundDropDown], compound, compoundColor)
		
		tyreCompound := compound
		tyreCompoundColor := compoundColor
		
		maxTyreLaps := simMaxTyreLapsEdit
		
		if (tyreCompound = "Dry")
			tyrePressures := [27.7, 27.7, 27.7, 27.7]
		else
			tyrePressures := [30.0, 30.0, 30.0, 30.0]
		
		telemetryDB := new TelemetryDatabase(this.Simulator, this.Car, this.Track)
		lowestLapTime := false
		
		for ignore, row in telemetryDB.getLapTimePressures(weather, tyreCompound, tyreCompoundColor) {
			lapTime := row["Lap.Time"]
		
			if (!lowestLapTime || (lapTime < lowestLapTime)) {
				lowestLapTime := lapTime
				
				tyrePressures := [Round(row["Tyre.Pressure.Front.Left"], 1), Round(row["Tyre.Pressure.Front.Right"], 1)
								, Round(row["Tyre.Pressure.Rear.Left"], 1), Round(row["Tyre.Pressure.Rear.Right"], 1)]
			}
		}
	}
	
	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		window := this.Window
			
		Gui %window%:Default
	
		GuiControlGet simInputDropDown
		GuiControlGet simAvgLapTimeEdit
		
		a := false
		b := false
			
		if (simInputDropDown > 1) {
			telemetryDB := new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
			
			lapTimes := telemetryDB.getMapLapTimes(this.SelectedWeather, tyreCompound, tyreCompoundColor)
			tyreLapTimes := telemetryDB.getTyreLapTimes(this.SelectedWeather, tyreCompound, tyreCompoundColor)
				
			if (tyreLapTimes.Length() > 1) {
				xValues := []
				yValues := []
				
				for ignore, entry in tyreLapTimes {
					xValues.Push(entry["Tyre.Laps"])
					yValues.Push(entry["Lap.Time"])
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
		
		Loop %numLaps% {
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
			
		return avgLapTime ? avgLapTime : (default ? default : simAvgLapTimeEdit)
	}
	
	getPitstopRules(ByRef validator, ByRef pitstopRule, ByRef refuelRule, ByRef tyreChangeRule, ByRef tyreSets) {
		local compound
		
		result := true
		
		window := this.Window
						
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
			refuelRule := ["Optional", "Required", "Disallowed"][refuelRequirementsDropDown]
			tyreChangeRule := ["Optional", "Required", "Disallowed"][tyreChangeRequirementsDropDown]
		}
		else {
			refuelRule := ["Optional", "Disallowed"][refuelRequirementsDropDown]
			tyreChangeRule := ["Optional", "Disallowed"][tyreChangeRequirementsDropDown]
		}
		
		Gui ListView, % this.TyreSetListView
		
		translatedCompounds := map(kQualifiedTyreCompounds, "translate")
		tyreSets := []
		
		Loop % LV_GetCount()
		{
			LV_GetText(compound, A_Index, 1)
			LV_GetText(count, A_Index, 2)
		
			splitQualifiedCompound(kQualifiedTyreCompounds[inList(translatedCompounds, compound)], compound, compoundColor)
		
			tyreSets.Push(Array(compound, compoundColor, count))
		}
			
		return result
	}
	
	getSessionSettings(ByRef stintLength, ByRef formationLap, ByRef postRaceLap, ByRef fuelCapacity, ByRef safetyFuel
					 , ByRef pitstopDelta, ByRef pitstopFuelService, ByRef pitstopTyreService, ByRef pitstopServiceOrder) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet stintLengthEdit
		GuiControlGet formationLapCheck
		GuiControlGet postRaceLapCheck
		GuiControlGet fuelCapacityEdit
		GuiControlGet safetyFuelEdit
	
		GuiControlGet pitstopDeltaEdit
		GuiControlGet pitstopTyreServiceEdit
		GuiControlGet pitstopFuelServiceEdit
		GuiControlGet pitstopServiceDropDown
		
		stintLength := stintLengthEdit
		formationLap := formationLapCheck
		postRaceLap := postRaceLapCheck
		fuelCapacity := fuelCapacityEdit
		safetyFuel := safetyFuelEdit
		pitstopDelta := pitstopDeltaEdit
		pitstopFuelService := pitstopFuelServiceEdit
		pitstopTyreService := pitstopTyreServiceEdit
		pitstopServiceOrder := ((pitstopServiceDropDown == 1) ? "Simultaneous" : "Sequential")
	}
	
	getStartConditions(ByRef initialLap, ByRef initialStintTime, ByRef initialTyreLaps, ByRef initialFuelAmount
					 , ByRef initialMap, ByRef initialFuelConsumption, ByRef initialAvgLapTime) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet simMaxTyreLapsEdit
		GuiControlGet simInitialFuelAmountEdit
		GuiControlGet simMapEdit
		GuiControlGet simFuelConsumptionEdit
		GuiControlGet simAvgLapTimeEdit
		
		initialLap := 0
		initialStintTime := 0
		initialTyreLaps := 0
		initialFuelAmount := simInitialFuelAmountEdit
		initialMap := simMapEdit
		initialFuelConsumption := simFuelConsumptionEdit
		initialAvgLapTime := simAvgLapTimeEdit
	}
	
	getSimulationSettings(ByRef useStartConditions, ByRef useTelemetryData, ByRef consumptionWeight, ByRef initialFuelWeight, ByRef tyreUsageWeight, ByRef tyreCompoundVariationWeight) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet simInputDropDown
		
		GuiControlGet simConsumptionWeight
		GuiControlGet simInitialFuelWeight
		GuiControlGet simTyreUsageWeight
		GuiControlGet simtyreCompoundVariationWeight
		
		useStartConditions := ((simInputDropDown == 1) || (simInputDropDown == 3))
		useTelemetryData := (simInputDropDown > 1)
		
		consumptionWeight := simConsumptionWeight
		initialFuelWeight := simInitialFuelWeight
		tyreUsageWeight := simTyreUsageWeight
		tyreCompoundVariationWeight := simtyreCompoundVariationWeight
	}

	runSimulation() {
		new VariationSimulation(this, this.SelectedSessionType
							  , new TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)).runSimulation(true)
	}
	
	chooseScenario(strategy) {
		window := this.Window
		
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

validatePitstopRule(full := false) {
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
	
	workbench.loadCar(workbench.getCars(workbench.SelectedSimulator)[carDropDown])
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
	
	workbench.loadCompound(workbench.AvailableCompounds[compoundDropDown])
}

chooseDataType() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
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
				new TelemetryDatabase(workbench.SelectedSimulator, workbench.SelectedCar
									, workbench.SelectedTrack).cleanupData(workbench.SelectedWeather
																		 , workbench.SelectedCompound, workbench.SelectedCompoundColor)
		
				GuiControlGet compoundDropDown
				
				workbench.loadCompound(kQualifiedTyreCompounds[compoundDropDown], true)
			}
		}
		
		GuiControl Choose, dataTypeDropDown, % inList(["Electronics", "Tyres"], workbench.SelectedDataType)
	}
	else
		workbench.loadDataType(["Electronics", "Tyres"][dataTypeDropDown], true)
}

chooseData() {
	workbench := StrategyWorkbench.Instance
	window := workbench.Window
	
	Gui %window%:Default
	
	Gui ListView, % workbench.DataListView
	
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
	StrategyWorkbench.Instance.updateState()
}

chooseTyreSet() {
	local compound
	
	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		workbench := StrategyWorkbench.Instance
	
		window := workbench.Window
		
		Gui %window%:Default
		
		Gui ListView, % workbench.TyreSetListView

		LV_GetText(compound, A_EventInfo, 1)
		LV_GetText(count, A_EventInfo, 2)
		
		GuiControl Choose, tyreSetDropDown, % inList(map(kQualifiedTyreCompounds, "translate"), compound)
		GuiControl, , tyreSetCountEdit, %count%
	
		workbench.updateState()
	}
}

updateTyreSet() {
	workbench := StrategyWorkbench.Instance
	
	window := workbench.Window
	
	Gui %window%:Default
	
	Gui ListView, % workbench.TyreSetListView
	
	row := LV_GetNext(0)
	
	if (row > 0) {
		GuiControlGet tyreSetDropDown
		GuiControlGet tyreSetCountEdit
		
		LV_Modify(row, "", map(kQualifiedTyreCompounds, "translate")[tyreSetDropDown], tyreSetCountEdit)
						
		LV_ModifyCol()
	}
}

addTyreSet() {
	workbench := StrategyWorkbench.Instance
	
	window := workbench.Window
	
	Gui %window%:Default
	
	Gui ListView, % workbench.TyreSetListView
	
	index := inList(kQualifiedTyreCompounds, "Dry")
	
	if !index
		index := 1
	
	LV_Add("", map(kQualifiedTyreCompounds, "translate")[index], 99)
	
	LV_Modify(LV_GetCount(), "Select Vis")
	
	LV_ModifyCol()
	
	GuiControl Choose, tyreSetDropDown, %index%
	GuiControl, , tyreSetCountEdit, 99
	
	workbench.updateState()
}

deleteTyreSet() {
	workbench := StrategyWorkbench.Instance
	
	window := workbench.Window
	
	Gui %window%:Default
	
	Gui ListView, % workbench.TyreSetListView
	
	LV_Delete(LV_GetNext(0))
	
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
	workbench := StrategyWorkbench.Instance
	
	selectStrategy := GetKeyState("Ctrl")
				
	workbench.runSimulation()
				
	if selectStrategy
		workbench.chooseSimulationMenu(5)
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
	local compound
	
	icon := kIconsDirectory . "Dashboard.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Strategy Workbench
	
	simulator := "Assetto Corsa Competizione"
	car := false
	track := false
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
		workbench := new StrategyWorkbench(simulator, car, track, weather, airTemperature, trackTemperature
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