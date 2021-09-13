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

#Include ..\Assistants\Libraries\StatisticsDatabase.ahk


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

global chartViewer

class StrategyWorkbench extends ConfigurationItem {
	iStatisticsDatabase := false
	
	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	iSelectedWeather := "Dry"
	iSelectedCompound := "Dry"
	iSelectedCompoundColor := "Black"
	
	iAvailableDataSets := []
	iSelectedDataType := "Electronics"
	iSelectedDataSet := false
	
	iAirTemperature := 23
	iTrackTemperature := 27
	
	iDataListView := false
	
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
	
	StatisticsDatabase[] {
		Get {
			return this.iStatisticsDatabase
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
	
	SelectedCompound[] {
		Get {
			if (this.iSelectedCompound = "Dry") {
				if (this.iSelectedCompoundColor = "Black")
					return "Dry"
				else
					return ("Dry (" . this.iSelectedCompoundColor . ")")
			}
			else
				return "Wet"
		}
	}
	
	AvailableDataSets[index := false] {
		Get {
			return (index ? this.iAvailableDataSets[index] : this.iAvailableDataSets)
		}
	}
	
	SelectedDataType[] {
		Get {
			return this.iSelectedDataType
		}
	}
	
	SelectedDataSet[] {
		Get {
			return this.iSelectedDataSet
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
	
	Compound[] {
		Get {
			return this.iCompound
		}
	}
	
	CompoundColor[] {
		Get {
			return this.iCompoundColor
		}
	}
	
	Map[] {
		Get {
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

		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x16 yp+10 w70 h23 +0x200 Section, % translate("Simulator")
		
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
		
		Gui %window%:Add, DropDownList, x90 yp w180 AltSubmit Choose%chosen% gchooseWeather vweatherDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Compound")
		
		compound := this.SelectedCompound
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}
		
		Gui %window%:Add, DropDownList, x90 yp w180 AltSubmit Choose%chosen% gchooseCompound vcompoundDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, DropDownList, x12 yp+32 w76 AltSubmit Choose1 vdataTypeDropDown gchooseDataType +0x200, % values2String("|", map(["Electronics", "Tyres"], "translate")*)
		
		Gui %window%:Add, ListView, x90 yp-2 w290 h152 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdataListView gchooseData, % values2String("|", map(["MAP", "TC", "ABS"], "translate")*)
		
		this.iDataListView := dataListView
		
		Gui %window%:Add, Text, x16 yp+165 w364 0x10
		
		Gui %window%:Add, Text, x16 yp+15 w90 h20, % translate("Race Duration")
		Gui %window%:Add, Edit, x90 yp-2 w50 h20 Limit4 Number ; VraceDurationEdit, %raceDurationEdit%
		Gui %window%:Add, UpDown, x122 yp-2 w18 h20 Range1-9999 0x80 ; , %raceDurationEdit%
		Gui %window%:Add, Text, x148 yp+4 w70 h20, % translate("Minutes")

		Gui %window%:Add, Text, x246 yp-4 w85 h23 +0x200, % translate("Formation")
		Gui %window%:Add, CheckBox, x320 yp-1 w17 h23 ; Checked%formationLapCheck% VformationLapCheck, %formationLapCheck%
		Gui %window%:Add, Text, x338 yp+4 w50 h20, % translate("Lap")
				
		Gui %window%:Add, Text, x16 yp+21 w85 h23 +0x200, % translate("Safety Fuel")
		Gui %window%:Add, Edit, x90 yp w50 h20 ; VsafetyFuelEdit, %safetyFuelEdit%
		Gui %window%:Add, UpDown, x122 yp-2 w18 h20 ; , %safetyFuelEdit%
		Gui %window%:Add, Text, x148 yp+2 w90 h20, % translate("Ltr.")
				
		Gui %window%:Add, Text, x246 yp-4 w85 h23 +0x200, % translate("Post Race")
		Gui %window%:Add, CheckBox, x320 yp-1 w17 h23 ; Checked%postRaceLapCheck% VpostRaceLapCheck, %postRaceLapCheck%
		Gui %window%:Add, Text, x338 yp+4 w50 h20, % translate("Lap")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, x16 yp+30 w362 h96, % translate("Pitstop")
				
		Gui %window%:Font, Norm, Arial
		
		x := 16
		x1 := x + 110
		x2 := x + 142
		x3 := x + 168
		
		Gui %window%:Add, Text, x%x% yp+24 w105 h20 +0x200, % translate("Pitstop Delta")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 Limit2 Number ; VpitstopDeltaEdit, %pitstopDeltaEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 0x80 ; , %pitstopDeltaEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Drive through - Drive by)")

		Gui %window%:Add, Text, x%x% yp+22 w85 h20 +0x200, % translate("Tyre Service")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 Limit2 Number ; VpitstopTyreServiceEdit, %pitstopTyreServiceEdit%
		Gui %window%:Add, UpDown, x%x2% yp-2 w18 h20 0x80 ; , %pitstopTyreServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Change four tyres)")

		Gui %window%:Add, Text, x%x% yp+22 w85 h20 +0x200, % translate("Refuel Service")
		Gui %window%:Add, Edit, x%x1% yp-2 w50 h20 ; VpitstopRefuelServiceEdit, %pitstopRefuelServiceEdit%
		Gui %window%:Add, Text, x%x3% yp+4 w180 h20, % translate("Seconds (Refuel of 10 litres)")
		
		Gui %window%:Add, ActiveX, x400 ys w800 h295 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		car := this.SelectedCar
		track := this.SelectedTrack
		
		this.loadSimulator(simulator, true)
		
		if car
			this.loadCar(car)
		
		if track
			this.loadTrack(track)
		
		Gui %window%:Add, Text, x8 y574 w1200 0x10
		
		Gui %window%:Add, Button, x574 y580 w80 h23 GcloseWorkbench, % translate("Close")
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
				<body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: 798px; height: 285px"></div>
				</body>
			</html>
			)

			chartViewer.Document.write(before . drawChartFunction . after)
		}
		else {
			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
		
			chartViewer.Document.write(html)
		}
		
		chartViewer.Document.close()
	}
	
	getSimulators() {
		return new StatisticsDatabase().getSimulators()
	}
	
	getCars(simulator) {
		return new StatisticsDatabase().getCars(simulator)
	}
	
	getTracks(simulator, car) {
		return new StatisticsDatabase().getTracks(simulator, car)
	}
	
	showLapTimeChart(data, yAxis) {
		this.iSelectedChart := "LapTimes"
		
		double := (yAxis.Length() > 1)
		
		drawChartFunction := ""
		
		drawChartFunction .= "function drawChart() {"
		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		drawChartFunction .= ("`ndata.addColumn('number', 'LapTime');")
		
		for ignore, axis in yAxis
			drawChartFunction .= ("`ndata.addColumn('number', '" . axis . "');")
		
		drawChartFunction .= "`ndata.addRows(["
		
		for ignore, values in data {
			if (A_Index > 1)
				drawChartFunction .= ",`n"
			
			drawChartFunction .= ("[" . Round(values["LapTime"] / 1000, 1))
		
			for ignore, axis in yAxis {
				value := values[axis]
			
				if (value = "n/a")
					value := 0
				
				drawChartFunction .= (", " . value)
			}
			
			drawChartFunction .= "]"
		}
		
		drawChartFunction .= "`n]);"
		
		series := "series: {"
		vAxis := "vAxis: { gridlines: { color: 'E0E0E0' }, "
		for ignore, axis in yAxis {
			if (A_Index > 1) {
				series .= ", "
				vAxis .= ", "
			}
			
			index := A_Index - 1
			
			series .= (index . ": {targetAxisIndex: " . index . "}")
			vAxis .= (index . ": {title: '" . translate(axis) . "'}")
		}
		
		series .= "}"
		vAxis .= "}"
		
		drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, backgroundColor: 'D0D0D0', hAxis: { title: '" . translate("Lap Times") . "', gridlines: { color: 'E0E0E0' } }, " . series . ", " . vAxis . "};")
			
		drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		
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
			
			this.loadCompound(this.SelectedCompound, true)
		}
	}
	
	loadCompound(compound, force := false) {
		if (force || (this.SelectedCompound != compound)) {
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
			
			LV_Delete()
			
			while LV_DeleteCol(1)
				ignore := 1
				
			
			if (this.SelectedDataType = "Electronics") {
				for ignore, column in map(["MAP", "TC", "ABS"], "translate")
					LV_InsertCol(A_Index, "", column)
			
				dataSets := new StatisticsDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack).queryElectronics(this.SelectedWeather, compound, compoundColor)
			
				this.iAvailableDataSets := dataSets
				
				for ignore, dataEntry in dataSets {
					dataEntry := dataEntry[1]
				
					map := dataEntry.Map
					
					if (map = "n/a")
						map := translate(map)
				
					tc := dataEntry.TC
					
					if (tc = "n/a")
						tc := translate(tc)
				
					abs := dataEntry.ABS
					
					if (abs = "n/a")
						abs := translate(abs)
					
					LV_Add("", map, tc, abs)
				}

				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(3, "AutoHdr")
			
				this.loadData((dataSets.Length() > 0) ? 1 : false, true)
			}
			else if (this.SelectedDataType = "Tyres") {
				for ignore, column in map(["Pressure", "Temperature"], "translate")
					LV_InsertCol(A_Index, "", column)
			
				dataSets := new StatisticsDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack).queryTyres(this.SelectedWeather, compound, compoundColor)
			
				this.iAvailableDataSets := dataSets
				
				for ignore, dataEntry in dataSets
					LV_Add("", Round(dataEntry["Pressure"], 1), Round(dataEntry["Temperature"], 1))
				
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				
				this.showLapTimeChart(dataSets, ["Pressure", "Temperature"])
			}
		}
	}
	
	loadData(dataSet, force := false) {
		if dataSet
			if dataSet is Number
				dataSet := this.AvailableDataSets[dataSet]
		
		if (force || (this.SelectedDataSet != dataSet)) {
			if dataSet {
				Gui ListView, % this.DataListView
					
				LV_Modify(inList(this.AvailableDataSets, dataSet), "Select Vis")
				
				this.iSelectedDataSet := dataSet
				
				if (this.SelectedDataType = "Electronics")
					this.showLapTimeChart(dataSet, ["FuelRemaining", "FuelConsumption"])
				else
					this.showChart(false)
			}
			else {
				this.showChart(false)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

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
	
	GuiControlGet simulatorDropDown
	
	workbench.loadSimulator(simulatorDropDown)
}

chooseCar() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet carDropDown
	
	workbench.loadCar(carDropDown)
}

chooseTrack() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet trackDropDown
	
	workbench.loadTrack(trackDropDown)
}

chooseWeather() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet weatherDropDown
	
	workbench.loadWeather(kWeatherOptions[weatherDropDown])
}

chooseCompound() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet compoundDropDown
	
	workbench.loadCompound(kQualifiedTyreCompounds[compoundDropDown])
}

chooseDataType() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet compoundDropDown
	GuiControlGet dataTypeDropDown
	
	workbench.iSelectedDataType := ["Electronics", "Tyres"][dataTypeDropDown]
	
	workbench.loadCompound(kQualifiedTyreCompounds[compoundDropDown], true)
}

chooseData() {
	workbench := StrategyWorkbench.Instance
	
	if (workbench.SelectedDataType = "Electronics") {
		if (A_GuiEvent = "Normal")
			workbench.loadData(A_EventInfo)
	}
	else
		LV_Modify(A_EventInfo, "-Select")
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