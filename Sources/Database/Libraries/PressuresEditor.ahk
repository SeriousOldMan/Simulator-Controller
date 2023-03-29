;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pressures Editor                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "TyresDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PressuresEditor                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PressuresEditor {
	iWindow := false

	iSessionDatabase := false
	iClosed := false

	iPressuresDatabase := false

	iPressuresViewer := false
	iPressuresListView := false

	iCompounds := []
	iTemperatures := []

	iSelectedWeather := false
	iSelectedCompound := false
	iSelectedTemperatures := [false, false]

	iModifications := []

	Window {
		Get {
			return this.iWindow
		}
	}

	Field[name] {
		Get {
			return this.iWindow[name]
		}
	}

	SessionDatabase {
		Get {
			return this.iSessionDatabase
		}
	}

	PressuresDatabase {
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

	SelectedWeather {
		Get {
			return this.iSelectedWeather
		}
	}

	SelectedCompound {
		Get {
			return this.iSelectedCompound
		}
	}

	SelectedTemperatures[key := false] {
		Get {
			return (key ? this.iSelectedTemperatures[key] : this.iSelectedTemperatures)
		}
	}

	PressuresViewer {
		Get {
			return this.iPressuresViewer
		}
	}

	PressuresListView {
		Get {
			return this.iPressuresListView
		}
	}

	__New(sessionDatabase, compound, compoundColor, airTemperature, trackTemperature) {
		this.iSessionDatabase := sessionDatabase
		this.iPressuresDatabase := TyresDatabase().getTyresDatabase(sessionDatabase.SelectedSimulator
																  , sessionDatabase.SelectedCar
																  , sessionDatabase.SelectedTrack)

		PressuresEditor.Instance := this

		this.createGui(compound, compoundColor, Round(airTemperature), Round(trackTemperature))
	}

	createGui(tyreCompound, tyreCompoundColor, airTemperature, trackTemperature) {
		local sessionDatabase := this.SessionDatabase
		local compounds := []
		local weather, ignore, row, theCompound, pressuresEditorGui

		pressuresEditorGui := Window()

		this.iWindow := pressuresEditorGui

		pressuresEditorGui.SetFont("s10 Bold", "Arial")

		pressuresEditorGui.Add("Text", "w388 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(pressuresEditorGui, "Session Database.Pressures Editor"))

		pressuresEditorGui.SetFont("s9 Norm", "Arial")
		pressuresEditorGui.SetFont("Italic Underline", "Arial")

		pressuresEditorGui.Add("Text", "x158 YP+20 w88 cBlue Center", translate("Tyre Pressures")).OnEvent("Click", openDocumentation.Bind(pressuresEditorGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#browsing-and-editing-tyre-pressures"))

		pressuresEditorGui.SetFont("s8 Norm", "Arial")

		pressuresEditorGui.Add("Text", "x8 yp+30 w410 0x10")

		pressuresEditorGui.SetFont("Norm", "Arial")

		pressuresEditorGui.Add("Text", "x16 yp+10 w80 h23 +0x200", translate("Simulator"))
		pressuresEditorGui.Add("Text", "x100 yp+4 w160 h23", sessionDatabase.SelectedSimulator)

		pressuresEditorGui.Add("Text", "x16 yp+20 w80 h23 +0x200", translate("Car"))
		pressuresEditorGui.Add("Text", "x100 yp+4 w160 h23", sessionDatabase.getCarName(sessionDatabase.SelectedSimulator, sessionDatabase.SelectedCar))

		pressuresEditorGui.Add("Text", "x16 yp+20 w80 h23 +0x200", translate("Track"))
		pressuresEditorGui.Add("Text", "x100 yp+4 w160 h23", sessionDatabase.getTrackName(sessionDatabase.SelectedSimulator, sessionDatabase.SelectedTrack))

		weather := sessionDatabase.SelectedWeather

		this.iSelectedWeather := weather

		pressuresEditorGui.Add("Text", "x16 yp+20 w80 h23 +0x200", translate("Weather"))
		pressuresEditorGui.Add("Text", "x100 yp+4 w160 h23", translate(weather))

		for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
													  , {Select: ["Compound", "Compound.Color"], By: ["Compound", "Compound.Color"]
													   , Where: {Weather: weather, Type: "Cold", Driver: this.SessionDatabase.SessionDatabase.ID}}) {
			theCompound := compound(row["Compound"], row["Compound.Color"])

			if !inList(compounds, theCompound)
				compounds.Push(theCompound)
		}

		bubbleSort(&compounds)

		this.iCompounds := compounds

		pressuresEditorGui.Add("Text", "x16 yp+20 w85 h23 +0x200", translate("Compound"))

		pressuresEditorGui.Add("DropDownList", "x96 yp w100 vcompoundDropDown", compounds).OnEvent("Change", chooseCompound)
		pressuresEditorGui.Add("DropDownList", "x205 yp w60 AltSubmit vtemperaturesDropDown").OnEvent("Change", chooseTemperatures)

		pressuresEditorGui.Add("Text", "x270 yp w140 h23 +0x200", substituteVariables(translate("Temperature (%unit%)"), {unit: getUnit("Temperature", true)}))

		this.iPressuresViewer := pressuresEditorGui.Add("ActiveX", "x16 yp+30 w394 h160 Border vpressuresViewer", "shell.explorer").Value
		this.PressuresViewer.Navigate("about:blank")
		this.PressuresViewer.Document.Write("<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>")

		this.iPressuresListView := pressuresEditorGui.Add("ListView", "x16 yp+170 w394 h160 BackgroundD8D8D8 -Multi -LV0x10 AltSubmit", collect(["Tyre", "Pressure", "#"], translate))
		this.iPressuresListView.OnEvent("Click", choosePressure)

		pressuresEditorGui.Add("Button", "x338 yp+162 w23 h23 vupPressureButton").OnEvent("Click", upPressure)
		pressuresEditorGui.Add("Button", "xp+24 yp w23 h23 vdownPressureButton").OnEvent("Click", downPressure)
		pressuresEditorGui.Add("Button", "xp+24 yp w23 h23 vclearPressureButton").OnEvent("Click", clearPressure.Bind("Normal"))

		setButtonIcon(pressuresEditorGui["upPressureButton"], kIconsDirectory . "Up Arrow.ico", 1, "W12 H12 L6 T6 R6 B6")
		setButtonIcon(pressuresEditorGui["downPressureButton"], kIconsDirectory . "Down Arrow.ico", 1, "W12 H12 L4 T4 R4 B4")
		setButtonIcon(pressuresEditorGui["clearPressureButton"], kIconsDirectory . "Minus.ico", 1, "W12 H12 L4 T4 R4 B4")

		pressuresEditorGui.SetFont("s8 Norm", "Arial")

		pressuresEditorGui.Add("Text", "x8 yp+30 w410 0x10")

		pressuresEditorGui.Add("Button", "x126 yp+10 w80 h23 Default", translate("Save")).OnEvent("Click", savePressuresEditor)
		pressuresEditorGui.Add("Button", "x214 yp w80 h23", translate("&Cancel")).OnEvent("Click", cancelPressuresEditor)

		if (compounds.Length > 0) {
			this.loadCompound(compound(tyreCompound, tyreCompoundColor), true)
			this.loadTemperatures(airTemperature, trackTemperature, true)
		}
	}

	flushPressures() {
		local sessionDatabase := this.SessionDatabase
		local connectors := sessionDatabase.SessionDatabase.Connectors
		local database := this.PressuresDatabase
		local ignore, update, entry, row, connector, properties

		database.reload("Tyres.Pressures.Distribution", false)

		database.lock("Tyres.Pressures.Distribution")

		try {
			for ignore, update in this.iModifications
				switch update[1], false {
					case "Update":
						entry := database.query("Tyres.Pressures.Distribution", {Where: update[2]})

						if (entry.Length > 0) {
							entry := entry[1]

							entry["Count"] := update[3]
							entry["Synchronized"] := kNull

							database.changed("Tyres.Pressures.Distribution")
						}
					case "Add":
						database.add(update[2])
					case "Remove":
						for ignore, connector in connectors
							try {
								for ignore, row in database.query("Tyres.Pressures.Distribution", {Where: update[2]})
									if (row["Identifier"] != kNull)
										connector.DeleteData("TyresPressuresDistribution", row["Identifier"])
							}
							catch Any as exception {
								logError(exception, true)
							}

						database.remove("Tyres.Pressures.Distribution", update[2], always.Bind(true))
				}
		}
		finally {
			database.unlock("Tyres.Pressures.Distribution")
		}
	}

	editPressures() {
		local x, y

		this.Window.Opt("+Owner" . this.SessionDatabase.Window.Hwnd)

		if getWindowPosition("Session Database.Pressures Editor", &x, &y)
			this.Window.Show("x" . x . " y" . y)
		else
			this.Window.Show()

		loop
			Sleep(200)
		until this.iClosed

		try {
			if (this.iClosed == kOk) {
				this.flushPressures()

				return true
			}
			else
				return false
		}
		finally {
			this.Window.Destroy()

			this.iWindow := false
		}
	}

	closeEditor(save) {
		this.iClosed := (save ? kOk : kCancel)
	}

	updateState() {
		local index, count

		index := this.PressuresListView.GetNext(0)

		if index {
			count := this.PressuresListView.GetText(index, 3)

			this.Field["upPressureButton"].Enabled := true

			if (count > 1)
				this.Field["downPressureButton"].Enabled := true
			else
				this.Field["downPressureButton"].Enabled := false

			this.Field["clearPressureButton"].Enabled := true
		}
		else {
			this.Field["upPressureButton"].Enabled := false
			this.Field["downPressureButton"].Enabled := false
			this.Field["clearPressureButton"].Enabled := false
		}
	}

	loadCompound(compound, force := false) {
		local temperatures := []
		local temperature, ignore, row, compoundColor

		if (force || (compound != this.SelectedCompound)) {
			this.iSelectedCompound := compound

			this.Field["compoundDropDown"].Choose(inList(this.Compounds, compound))

			splitCompound(compound, &compound, &compoundColor)

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

			bubbleSort(&temperatures)

			loop temperatures.Length {
				temperature := string2Values(translate(" / "), temperatures[A_Index])

				this.Temperatures.Push(Array(temperature[1] + 0, temperature[2] + 0))

				temperatures[A_Index] := (Round(convertUnit("Temperature", temperature[1])) . translate(" / ") . Round(convertUnit("Temperature", temperature[2])))
			}

			this.Field["temperaturesDropDown"].Delete()
			this.Field["temperaturesDropDown"].Add(temperatures)

			if (temperatures.Length > 0)
				this.loadTemperatures(this.Temperatures[1][1], this.Temperatures[1][2], true)
			else
				this.loadPressures(false, false)
		}
	}

	loadTemperatures(airTemperature, trackTemperature, force := false) {
		local chosen := 0
		local compound, compoundColor, index, candidate

		if (force || (airTemperature != this.SelectedTemperatures[1]) || (airTemperature != this.SelectedTemperatures[2])) {
			for index, candidate in this.Temperatures
				if ((candidate[1] = airTemperature) && (candidate[2] = trackTemperature)) {
					chosen := index

					break
				}

			if (airTemperature && trackTemperature) {
				if ((chosen = 0) && (this.Temperatures.Length > 0)) {
					airTemperature := this.Temperatures[1][1]
					trackTemperature := this.Temperatures[1][2]

					chosen := 1
				}

				this.iSelectedTemperatures := [airTemperature, trackTemperature]

				splitCompound(this.SelectedCompound, &compound, &compoundColor)

				this.loadPressures(compound, compoundColor, airTemperature, trackTemperature)
			}
			else {
				this.iSelectedTemperatures := [false, false]

				this.loadPressures(false, false)
			}

			this.Field["temperaturesDropDown"].Choose(chosen)
		}
	}

	loadPressures(compound, compoundColor, airTemperature := false, trackTemperature := false) {
		local tyres := CaseInsenseMap("FL", translate("Front Left"), "FR", translate("Front Right")
									, "RL", translate("Rear Left"), "RR", translate("Rear Right"))
		local pressures := []
		local ignore, row, lastTyre

		this.PressuresListView.Delete()

		if (compound && compoundColor) {
			for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
														  , {Select: ["Count", "Tyre", "Pressure"]
														   , Where: Map("Weather", this.SelectedWeather, "Type", "Cold", "Driver", this.SessionDatabase.SessionDatabase.ID
																      , "Compound", compound, "Compound.Color", compoundColor
																	  , "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature)})
				pressures.Push(Array(tyres[row["Tyre"]], displayValue("Float", convertUnit("Pressure", row["Pressure"])), row["Count"]))

			bubbleSort(&pressures, (a, b) => strGreater(a[1], b[1]))

			lastTyre := false

			for ignore, row in pressures
				if (pressures[A_Index][1] = lastTyre)
					pressures[A_Index][1] := ""
				else
					lastTyre := pressures[A_Index][1]

			loop pressures.Length
				this.PressuresListView.Add("", pressures[A_Index][1], pressures[A_Index][2], pressures[A_Index][3])

			this.PressuresListView.ModifyCol()

			loop 3
				this.PressuresListView.ModifyCol(A_Index, "AutoHdr")
		}

		this.updateState()
		this.updateStatistics()
	}

	savePressures() {
		local pressuresDB := this.PressuresDatabase
		local pressures := CaseInsenseMap()
		local tyres := CaseInsenseMap()
		local airTemperature := this.SelectedTemperatures[1]
		local trackTemperature := this.SelectedTemperatures[2]
		local tyre, pressure, count, lastTyre, oldPressure
		local compound, compoundColor, ignore, entry, prototype

		splitCompound(this.SelectedCompound, &compound, &compoundColor)

		tyres[translate("Front Left")] := "FL"
		tyres[translate("Front Right")] := "FR"
		tyres[translate("Rear Left")] := "RL"
		tyres[translate("Rear Right")] := "RR"

		loop this.PressuresListView.GetCount() {
			tyre := this.PressuresListView.GetText(A_Index, 1)
			pressure := this.PressuresListView.GetText(A_Index, 2)
			count := this.PressuresListView.GetText(A_Index, 3)

			if (tyre != "")
				lastTyre := tyres[tyre]

			pressure := Round(convertUnit("Pressure", internalValue("Float", pressure), false), 1)

			pressures[lastTyre . "." . pressure] := true

			prototype := CaseInsenseMap("Weather", this.SelectedWeather, "Driver", this.SessionDatabase.SessionDatabase.ID
									  , "Compound", compound, "Compound.Color", compoundColor, "Tyre", lastTyre, "Type", "Cold"
									  , "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
									  , "Pressure", pressure)

			oldPressure := pressuresDB.query("Tyres.Pressures.Distribution", {Where: prototype})

			if (oldPressure.Length > 0) {
				if (oldPressure[1]["Count"] != count) {
					oldPressure[1]["Count"] := count

					this.iModifications.Push(Array("Update", prototype, count))
				}
			}
			else {
				prototype := prototype.Clone()
				prototype["Count"] := count

				pressuresDB.add("Tyres.Pressures.Distribution", prototype)

				this.iModifications.Push(Array("Add", prototype))
			}
		}

		for ignore, entry in pressuresDB.query("Tyres.Pressures.Distribution"
											 , {Select: ["Tyre", "Pressure"]
											  , Where: Map("Weather", this.SelectedWeather, "Type", "Cold", "Driver", this.SessionDatabase.SessionDatabase.ID
														 , "Compound", compound, "Compound.Color", compoundColor
														 , "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature)})
			if !pressures.Has(entry["Tyre"] . "." . entry["Pressure"]) {
				where := Map("Weather", this.SelectedWeather, "Type", "Cold", "Driver", this.SessionDatabase.SessionDatabase.ID
						   , "Compound", compound, "Compound.Color", compoundColor
						   , "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
						   , "Tyre", entry["Tyre"], "Pressure", entry["Pressure"])

				pressuresDB.remove("Tyres.Pressures.Distribution", where, always.Bind(true))

				this.iModifications.Push(Array("Remove", where))
			}
	}

	showStatisticsChart(drawChartFunction) {
		local before, after, html

		this.PressuresViewer.Document.Open()

		if (drawChartFunction && (drawChartFunction != "")) {
			before := "
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
			)"

			after := "
			(
					</script>
				</head>
				<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: %width%px; height: %height%px"></div>
				</body>
			</html>
			)"

			html := (before . drawChartFunction . substituteVariables(after, {width: this.PressuresViewer.Width, height: this.PressuresViewer.Height - 1}))

			this.PressuresViewer.Document.Write(html)
		}
		else {
			html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

			this.PressuresViewer.Document.Write(html)
		}

		this.PressuresViewer.Document.close()
	}

	updateStatistics() {
		local drawChartFunction := "function drawChart() {`nvar array = [`n"
		local tyreData := CaseInsenseMap()
		local tyreDatas := []
		local lastTyre := false
		local ignore, index, tyre, pressure, count, maxCount, text

		for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"]
			tyreData[translate(tyre)] := Array()

		loop this.PressuresListView.GetCount() {
			tyre := this.PressuresListView.GetText(A_Index, 1)
			pressure := this.PressuresListView.GetText(A_Index, 2)
			count := this.PressuresListView.GetText(A_Index, 3)

			if (tyre != "")
				lastTyre := tyre

			loop count
				tyreData[lastTyre].Push(internalValue("Float", pressure))
		}

		maxCount := 0

		for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"] {
			tyre := translate(tyre)

			maxCount := Max(maxCount, tyreData[tyre].Length)
		}

		for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"] {
			tyre := translate(tyre)

			loop maxCount
				if (tyreData[tyre].Length < maxCount)
					tyreData[tyre].Push(average(tyreData[tyre]))
				else
					break

			if (average(tyreData[tyre]) > 0)
				tyreDatas.Push("['" . tyre . "', " . values2String(", ", tyreData[tyre]*) . "]")
		}

		drawChartFunction .= (values2String("`n, ", tyreDatas*) . "];")

		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		drawChartFunction .= "`ndata.addColumn('string', '" . translate("Tyre") . "');"

		loop maxCount
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("Pressure") . A_Space . A_Index . "');"

		text := "
		(
		data.addColumn({id:'max', type:'number', role:'interval'});
		data.addColumn({id:'min', type:'number', role:'interval'});
		data.addColumn({id:'firstQuartile', type:'number', role:'interval'});
		data.addColumn({id:'median', type:'number', role:'interval'});
		data.addColumn({id:'mean', type:'number', role:'interval'});
		data.addColumn({id:'thirdQuartile', type:'number', role:'interval'});
		)"

		drawChartFunction .= ("`n" . text)

		drawChartFunction .= ("`n" . "data.addRows(getBoxPlotValues(array, " . (maxCount + 1) . "));")

		drawChartFunction .= ("`n" . getBoxAndWhiskerJSFunctions())

		text := "
		(
		var options = {
			backgroundColor: 'D8D8D8', chartArea: { left: '10%', top: '5%', right: '5%', bottom: '20%' },
			legend: { position: 'none' },
		)"

		drawChartFunction .= text

		text := "
		(
			hAxis: { title: '%tyres%', gridlines: {count: 0} },
			vAxis: { title: '%pressures%', gridlines: {count: 0} },
			lineWidth: 0,
			series: [ { 'color': 'D8D8D8' } ],
			intervals: { barWidth: 1, boxWidth: 1, lineWidth: 2, style: 'boxes' },
			interval: { max: { style: 'bars', fillOpacity: 1, color: '#777' },
						min: { style: 'bars', fillOpacity: 1, color: '#777' },
						mean: { style: 'points', color: 'grey', pointsize: 5 } }
		};
		)"

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

	script := "
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

			if (arr.length % 2 === 0) {
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
		if (length % 2 === 0) {
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
				value = value + array[i]

			return value / array.length;
		}
	}
	)"

	return script
}

chooseCompound(dropDown, *) {
	PressuresEditor.Instance.loadCompound(dropDown.Text)
}

chooseTemperatures(dropDown, *) {
	local editor := PressuresEditor.Instance
	local index := dropDown.Value

	editor.loadTemperatures(editor.Temperatures[index][1], editor.Temperatures[index][2])
}

choosePressure(*) {
	PressuresEditor.Instance.updateState()
}

upPressure(*) {
	local editor := PressuresEditor.Instance
	local index, count

	index := editor.PressuresListView.GetNext(0)

	if index {
		count := editor.PressuresListView.GetText(index, 3)

		editor.PressuresListView.Modify(index, "Col3", count + 1)
	}

	editor.savePressures()
	editor.updateState()
	editor.updateStatistics()
}

downPressure(*) {
	local editor := PressuresEditor.Instance
	local index, count

	index := editor.PressuresListView.GetNext(0)

	if index {
		count := editor.PressuresListView.GetText(index, 3)

		editor.PressuresListView.Modify(index, "Col3", count - 1)
	}

	editor.savePressures()
	editor.updateState()
	editor.updateStatistics()
}

clearPressure(*) {
	local editor := PressuresEditor.Instance
	local index, tyre, nextTyre

	index := editor.PressuresListView.GetNext(0)

	if index {
		tyre := editor.PressuresListView.GetText(index)

		if ((tyre != "") && (index < editor.PressuresListView.GetCount())) {
			nextTyre := editor.PressuresListView.GetText(index + 1, 1)

			if (nextTyre = "")
				editor.PressuresListView.Modify(index + 1, "", tyre)
		}

		editor.PressuresListView.Delete(index)
	}

	editor.savePressures()
	editor.updateState()
	editor.updateStatistics()
}

savePressuresEditor(*) {
	protectionOn()

	try {
		PressuresEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelPressuresEditor(*) {
	protectionOn()

	try {
		PressuresEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}