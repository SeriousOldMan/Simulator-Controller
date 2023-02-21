;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pressures Editor                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Framework.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PressuresEditor                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global pressuresViewer
global temperaturesDropDown
global compoundDropDown

global upPressureButton
global downPressureButton
global clearPressureButton

class PressuresEditor {
	iSessionDatabase := false
	iClosed := false

	iPressuresDatabase := false

	iPressuresListView := false

	iCompounds := []
	iTemperatures := []

	iSelectedWeather := false
	iSelectedCompound := false
	iSelectedTemperatures := [false, false]

	SessionDatabase[] {
		Get {
			return this.iSessionDatabase
		}
	}

	PressuresDatabase[] {
		Get {
			return this.iPressuresDatabase
		}
	}

	Compounds[key := false] {
		Get {
			return (key ? this.iCompounds[key] : this.iCompounds)
		}
	}

	Temperatures[key := false] {
		Get {
			return (key ? this.iTemperatures[key] : this.iTemperatures)
		}
	}

	SelectedWeather[] {
		Get {
			return this.iSelectedWeather
		}
	}

	SelectedCompound[] {
		Get {
			return this.iSelectedCompound
		}
	}

	SelectedTemperatures[key := false] {
		Get {
			return (key ? this.iSelectedTemperatures[key] : this.iSelectedTemperatures)
		}
	}

	PressuresListView[] {
		Get {
			return this.iPressuresListView
		}
	}

	__New(sessionDatabase, compound, compoundColor, airTemperature, trackTemperature) {
		this.iSessionDatabase := sessionDatabase
		this.iPressuresDatabase := new TyresDatabase().getTyresDatabase(sessionDatabase.SelectedSimulator
																	  , sessionDatabase.SelectedCar
																	  , sessionDatabase.SelectedTrack)

		PressuresEditor.Instance := this

		this.createGui(compound, compoundColor, Round(airTemperature), Round(trackTemperature))
	}

	createGui(tyreCompound, tyreCompoundColor, airTemperature, trackTemperature) {
		local sessionDatabase := this.SessionDatabase
		local compounds := []
		local weather, ignore, row, compound

		Gui PE:Default

		Gui PE:-Border ; -Caption
		Gui PE:Color, D0D0D0, D8D8D8

		Gui PE:Font, s10 Bold, Arial

		Gui PE:Add, Text, w388 Center gmovePressuresEditor, % translate("Modular Simulator Controller System")

		Gui PE:Font, s9 Norm, Arial
		Gui PE:Font, Italic Underline, Arial

		Gui PE:Add, Text, x158 YP+20 w88 cBlue Center gopenPressuresDocumentation, % translate("Tyre Pressures")

		Gui PE:Font, s8 Norm, Arial

		Gui PE:Add, Text, x8 yp+30 w410 0x10

		Gui PE:Font, Norm, Arial

		Gui PE:Add, Text, x16 yp+10 w80 h23 +0x200, % translate("Simulator")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % sessionDatabase.SelectedSimulator

		Gui PE:Add, Text, x16 yp+20 w80 h23 +0x200, % translate("Car")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % sessionDatabase.getCarName(sessionDatabase.SelectedSimulator, sessionDatabase.SelectedCar)

		Gui PE:Add, Text, x16 yp+20 w80 h23 +0x200, % translate("Track")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % sessionDatabase.getTrackName(sessionDatabase.SelectedSimulator, sessionDatabase.SelectedTrack)

		weather := sessionDatabase.SelectedWeather

		this.iSelectedWeather := weather

		Gui PE:Add, Text, x16 yp+20 w80 h23 +0x200, % translate("Weather")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % translate(weather)

		for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
													  , {Select: ["Compound", "Compound.Color"], By: ["Compound", "Compound.Color"]
													   , Where: {Weather: weather, Type: "Cold", Driver: this.SessionDatabase.SessionDatabase.ID}}) {
			compound := compound(row.Compound, row["Compound.Color"])

			if !inList(compounds, compound)
				compounds.Push(compound)
		}

		bubbleSort(compounds)

		this.iCompounds := compounds

		Gui PE:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Compound")

		Gui PE:Add, DropDownList, x96 yp w100 vcompoundDropDown gchooseCompound, % values2String("|", compounds*)

		Gui PE:Add, DropDownList, x205 yp w60 AltSubmit vtemperaturesDropDown gchooseTemperatures

		Gui PE:Add, Text, x270 yp w140 h23 +0x200, % substituteVariables(translate("Temperature (%unit%)"), {unit: getUnit("Temperature", true)})

		Gui PE:Add, ActiveX, x16 yp+30 w394 h160 Border vpressuresViewer, shell.explorer

		pressuresViewer.Navigate("about:blank")
		pressuresViewer.Document.Write("<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>")

		Gui PE:Add, ListView, x16 yp+170 w394 h160 -Multi -LV0x10 AltSubmit HwndpressuresListViewHandle gchoosePressure, % values2String("|", map(["Tyre", "Pressure", "#"], "translate")*) ; NoSort NoSortHdr

		this.iPressuresListView := pressuresListViewHandle

		Gui PE:Add, Button, x338 yp+162 w23 h23 HWNDupPressureButtonHandle vupPressureButton gupPressure
		Gui PE:Add, Button, xp+24 yp w23 h23 HWNDdownPressureButtonHandle vdownPressureButton gdownPressure
		Gui PE:Add, Button, xp+24 yp w23 h23 HWNDclearPressureButtonHandle vclearPressureButton gclearPressure

		setButtonIcon(upPressureButtonHandle, kIconsDirectory . "Up Arrow.ico", 1, "W12 H12 L6 T6 R6 B6")
		setButtonIcon(downPressureButtonHandle, kIconsDirectory . "Down Arrow.ico", 1, "W12 H12 L4 T4 R4 B4")
		setButtonIcon(clearPressureButtonHandle, kIconsDirectory . "Minus.ico", 1, "W12 H12 L4 T4 R4 B4")

		Gui PE:Font, s8 Norm, Arial

		Gui PE:Add, Text, x8 yp+30 w410 0x10

		Gui PE:Add, Button, x126 yp+10 w80 h23 Default GsavePressuresEditor, % translate("Save")
		Gui PE:Add, Button, x214 yp w80 h23 GcancelPressuresEditor, % translate("&Cancel")

		if (compounds.Length() > 0) {
			this.loadCompound(compound(tyreCompound, tyreCompoundColor), true)
			this.loadTemperatures(airTemperature, trackTemperature, true)
		}
	}

	editPressures() {
		local x, y

		if getWindowPosition("Session Database.Pressures Editor", x, y)
			Gui PE:Show, x%x% y%y%
		else
			Gui PE:Show

		loop
			Sleep 200
		until this.iClosed

		try {
			if (this.iClosed == kOk) {
				return true
			}
			else
				return false
		}
		finally {
			Gui PE:Destroy
		}
	}

	closeEditor(save) {
		this.iClosed := (save ? kOk : kCancel)
	}

	updateState() {
		local index, count

		Gui PE:Default

		Gui ListView, % this.PressuresListView

		index := LV_GetNext(0)

		if index {
			LV_GetText(count, index, 3)

			GuiControl Enable, upPressureButton

			if (count > 1)
				GuiControl Enable, downPressureButton
			else
				GuiControl Disable, downPressureButton

			GuiControl Enable, clearPressureButton
		}
		else {
			GuiControl Disable, upPressureButton
			GuiControl Disable, downPressureButton
			GuiControl Disable, clearPressureButton
		}
	}

	loadCompound(compound, force := false) {
		local temperatures := []
		local temperature, ignore, row, compoundColor

		if (force || (compound != this.SelectedCompound)) {
			Gui PE:Default

			this.iSelectedCompound := compound

			GuiControl Choose, compoundDropDown, % inList(this.Compounds, compound)

			splitCompound(compound, compound, compoundColor)

			for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
														  , {Select: ["Temperature.Air", "Temperature.Track"]
														   , By: ["Temperature.Air", "Temperature.Track"]
														   , Where: {Weather: this.SelectedWeather, Type: "Cold", Driver: this.SessionDatabase.SessionDatabase.ID
																   , Compound: compound, CompoundColor: compoundColor}})
				if (row["Temperature.Air"] && row["Temperature.Track"]) {
					temperature := (row["Temperature.Air"] . translate(" / ") . row["Temperature.Track"])

					if !inList(temperatures, temperature)
						temperatures.Push(temperature)
				}

			this.iTemperatures := []

			bubbleSort(temperatures)

			loop % temperatures.Length()
			{
				temperature := string2Values(translate(" / "), temperatures[A_Index])

				this.Temperatures.Push(Array(temperature[1] + 0, temperature[2] + 0))

				temperatures[A_Index] := (Round(convertUnit("Temperature", temperature[1])) . translate(" / ") . Round(convertUnit("Temperature", temperature[2])))
			}

			GuiControl, , temperaturesDropDown, % ("|" . values2String("|", temperatures*))

			if (temperatures.Length() > 0)
				this.loadTemperatures(this.Temperatures[1][1], this.Temperatures[1][2], true)
			else
				this.loadPressures(false, false)
		}
	}

	loadTemperatures(airTemperature, trackTemperature, force := false) {
		local chosen := 0
		local compound, compoundColor, index, candidate

		if (force || (airTemperature != this.SelectedTemperatures[1]) || (airTemperature != this.SelectedTemperatures[2])) {
			this.iSelectedTemperatures := [airTemperature, trackTemperature]

			for index, candidate in this.Temperatures
				if ((candidate[1] = airTemperature) && (candidate[2] = trackTemperature)) {
					chosen := index

					break
				}

			if (airTemperature && trackTemperature) {
				if ((chosen = 0) && (this.Temperatures.Length() > 0)) {
					airTemperature := this.Temperatures[1][1]
					trackTemperature := this.Temperatures[1][2]

					chosen := 1
				}

				splitCompound(this.SelectedCompound, compound, compoundColor)

				this.loadPressures(compound, compoundColor, airTemperature, trackTemperature)
			}
			else
				this.loadPressures(false, false)

			GuiControl Choose, temperaturesDropDown, %chosen%
		}
	}

	loadPressures(compound, compoundColor, airTemperature := false, trackTemperature := false) {
		local tyres := {FL: translate("Front Left"), FR: translate("Front Right")
					  , RL: translate("Rear Left"), RR: translate("Rear Right")}
		local pressures := []
		local ignore, row, lastTyre

		Gui PE:Default

		Gui ListView, % this.PressuresListView

		LV_Delete()

		if (compound && compoundColor) {
			for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
														  , {Select: ["Count", "Tyre", "Pressure"]
														   , Where: {Weather: this.SelectedWeather, Type: "Cold", Driver: this.SessionDatabase.SessionDatabase.ID
																   , Compound: compound, "Compound.Color": compoundColor
																   , "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature}})
				pressures.Push(Array(tyres[row.Tyre], displayValue("Float", convertUnit("Pressure", row.Pressure)), row.Count))

			bubbleSort(pressures, "comparePressures")

			lastTyre := false

			for ignore, row in pressures
				if (pressures[A_Index][1] = lastTyre)
					pressures[A_Index][1] := ""
				else
					lastTyre := pressures[A_Index][1]

			loop % pressures.Length()
				LV_Add("", pressures[A_Index, 1], pressures[A_Index, 2], pressures[A_Index, 3])

			LV_ModifyCol()

			loop 3
				LV_ModifyCol(A_Index, "AutoHdr")
		}

		this.updateState()
		this.updateStatistics()
	}

	showStatisticsChart(drawChartFunction) {
		local before, after, width, height, html

		Gui PE:Default

		pressuresViewer.Document.open()

		if (drawChartFunction && (drawChartFunction != "")) {
			before =
			(
			<html>
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.cellStyle { text-align: right; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'bar', 'table']}).then(drawChart);
			)

			width := pressuresViewer.Width
			height := (pressuresViewer.Height - 1)

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

			pressuresViewer.Document.write(html)
		}
		else {
			html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

			pressuresViewer.Document.write(html)
		}

		pressuresViewer.Document.close()
	}

	updateStatistics() {
		local drawChartFunction := "function drawChart() {`nvar array = [`n"
		local tyreData := {}
		local tyreDatas := []
		local lastTyre := false
		local ignore, index, tyre, pressure, count, maxCount, text

		Gui PE:Default

		Gui ListView, % this.PressuresListView

		for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"]
			tyreData[translate(tyre)] := Array()

		loop % LV_GetCount()
		{
			LV_GetText(tyre, A_Index, 1)
			LV_GetText(pressure, A_Index, 2)
			LV_GetText(count, A_Index, 3)

			if (tyre != "")
				lastTyre := tyre

			loop %count%
				tyreData[lastTyre].Push(internalValue("Float", pressure))
		}

		maxCount := 0

		for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"] {
			tyre := translate(tyre)

			maxCount := Max(maxCount, tyreData[tyre].Length())
		}

		for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"] {
			tyre := translate(tyre)

			loop %maxCount%
				if (tyreData[tyre].Length() < maxCount)
					tyreData[tyre].Push(average(tyreData[tyre]))
				else
					break

			if (average(tyreData[tyre]) > 0)
				tyreDatas.Push("['" . tyre . "', " . values2String(", ", tyreData[tyre]*) . "]")
		}

		drawChartFunction .= (values2String("`n, ", tyreDatas*) . "];")

		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		drawChartFunction .= "`ndata.addColumn('string', '" . translate("Tyre") . "');"

		loop %maxCount%
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("Pressure") . A_Space . A_Index . "');"

		text =
		(
		data.addColumn({id:'max', type:'number', role:'interval'});
		data.addColumn({id:'min', type:'number', role:'interval'});
		data.addColumn({id:'firstQuartile', type:'number', role:'interval'});
		data.addColumn({id:'median', type:'number', role:'interval'});
		data.addColumn({id:'mean', type:'number', role:'interval'});
		data.addColumn({id:'thirdQuartile', type:'number', role:'interval'});
		)

		drawChartFunction .= ("`n" . text)

		drawChartFunction .= ("`n" . "data.addRows(getBoxPlotValues(array, " . (maxCount + 1) . "));")

		drawChartFunction .= ("`n" . getBoxAndWhiskerJSFunctions())

		text =
		(
		var options = {
			backgroundColor: 'D8D8D8', chartArea: { left: '10`%', top: '5`%', right: '5`%', bottom: '20`%' },
			legend: { position: 'none' },
		)

		drawChartFunction .= text

		text =
		(
			hAxis: { title: '`%tyres`%', gridlines: {count: 0} },
			vAxis: { title: '`%pressures`%', gridlines: {count: 0} },
			lineWidth: 0,
			series: [ { 'color': 'D8D8D8' } ],
			intervals: { barWidth: 1, boxWidth: 1, lineWidth: 2, style: 'boxes' },
			interval: { max: { style: 'bars', fillOpacity: 1, color: '#777' },
						min: { style: 'bars', fillOpacity: 1, color: '#777' },
						mean: { style: 'points', color: 'grey', pointsize: 5 } }
		};
		)

		drawChartFunction .= ("`n" . substituteVariables(text, {tyres: translate("Tyres"), pressures: translate("Pressure")}))

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")

		this.showStatisticsChart(drawChartFunction)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getBoxAndWhiskerJSFunctions() {
	local script

	script =
	(
	/**
	* Takes an array of input data and returns an
	* array of the input data with the box plot
	* interval data appended to each row.
	*/
	function getBoxPlotValues(array, base) {
		for (var i = 0; i < array.length; i++) {
			var arr = array[i].slice(1).sort(function (a, b) {
												return a - b;
											 });

			var max = arr[arr.length - 1];
			var min = arr[0];
			var median = getMedian(arr);
			var average = getAverage(arr);

			if (arr.length `% 2 === 0) {
				var midUpper = arr.length / 2;
				var midLower = midUpper - 1;

				array[i][base + 2] = getMedian(arr.slice(0, midUpper));
				array[i][base + 5] = getMedian(arr.slice(midLower));
			}
			else {
				var index = Math.floor(arr.length / 2);

				array[i][base + 2] = getMedian(arr.slice(0, index + 1));
				array[i][base + 5] = getMedian(arr.slice(index));
			}

			array[i][base] = max;
			array[i][base + 1] = min
			array[i][base + 3] = median;
			array[i][base + 4] = average;
		}

		return array;
	}

	/*
	* Takes an array and returns
	* the median value.
	*/
	function getMedian(array) {
		var length = array.length;

		/* If the array is an even length the
		* median is the average of the two
		* middle-most values. Otherwise the
		* median is the middle-most value.
		*/
		if (length `% 2 === 0) {
			var midUpper = length / 2;
			var midLower = midUpper - 1;

			return (array[midUpper] + array[midLower]) / 2;
		}
		else {
			return array[Math.floor(length / 2)];
		}
	}

	/*
	* Takes an array and returns
	* the average value.
	*/
	function getAverage(array) {
		var value = 0;

		if (array.length == 0)
			return 0;
		else {
			for (var i = 0; i < array.length; i++)
				value = value + array[i];

			return value / array.length;
		}
	}
	)

	return script
}

comparePressures(a, b) {
	return (a[1] > b[1])
}

chooseCompound() {
	local editor := PressuresEditor.Instance

	Gui PE:Default

	GuiControlGet compoundDropDown

	editor.loadCompound(compoundDropDown)
}

chooseTemperatures() {
	local editor := PressuresEditor.Instance

	Gui PE:Default

	GuiControlGet temperaturesDropDown

	editor.loadTemperatures(editor.Temperatures[temperaturesDropDown][1], editor.Temperatures[temperaturesDropDown][2])
}

choosePressure() {
	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0))
		PressuresEditor.Instance.updateState()
}

upPressure() {
	local editor := PressuresEditor.Instance
	local index, count

	Gui PE:Default

	Gui ListView, % editor.PressuresListView

	index := LV_GetNext(0)

	if index {
		LV_GetText(count, index, 3)

		LV_Modify(index, "Col3", count + 1)
	}

	editor.updateState()
	editor.updateStatistics()
}

downPressure() {
	local editor := PressuresEditor.Instance
	local index, count

	Gui PE:Default

	Gui ListView, % editor.PressuresListView

	index := LV_GetNext(0)

	if index {
		LV_GetText(count, index, 3)

		LV_Modify(index, "Col3", count - 1)
	}

	editor.updateState()
	editor.updateStatistics()
}

clearPressure() {
	local editor := PressuresEditor.Instance
	local index, tyre, nextTyre

	Gui PE:Default

	Gui ListView, % editor.PressuresListView

	index := LV_GetNext(0)

	if index {
		LV_GetText(tyre, index)

		if ((tyre != "") && (index < LV_GetCount())) {
			LV_GetText(nextTyre, index + 1)

			if (nextTyre = "")
				LV_Modify(index + 1, "", tyre)
		}

		LV_Delete(index)
	}

	editor.updateState()
	editor.updateStatistics()
}

savePressuresEditor() {
	protectionOn()

	try {
		PressuresEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelPressuresEditor() {
	protectionOn()

	try {
		PressuresEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}

movePressuresEditor() {
	moveByMouse("PE", "Session Database.Pressures Editor")
}

openPressuresDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database
}