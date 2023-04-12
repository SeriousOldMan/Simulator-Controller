;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Workbench                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Setup.ico
;@Ahk2Exe-ExeName Setup Workbench.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Math.ahk"
#Include "..\Libraries\RuleEngine.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "ok"
global kCancel := "cancel"

global kMaxCharacteristics := 8
global kCharacteristicHeight := 56


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugOff := 0
global kDebugKnowledgeBase := 1
global kDebugRules := 2


;;;-------------------------------------------------------------------------;;;
;;;                         Public Classes Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupWorkbench                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetupWorkbench extends ConfigurationItem {
	iWindow := false

	iDebug := kDebugOff

	iProgressCount := 0

	iCharacteristicsArea := false

	iDefinition := false
	iSimulatorDefinition := false
	iSimulatorSettings := false

	iSelectedSimulator := false
	iAvailableCars := []
	iSelectedCar := true
	iSelectedTrack := true
	iSelectedWeather := "Dry"

	iCharacteristics := []
	iSettings := []

	iSelectedCharacteristics := []
	iSelectedCharacteristicsWidgets := CaseInsenseMap()

	iSettingsViewer := false

	iSetup := false

	iKnowledgeBase := false

	class WorkbenchWindow extends Window {
		iWorkbench := false

		Workbench {
			Get {
				return this.iWorkbench
			}
		}

		__New(Workbench) {
			this.iWorkbench := workbench

			super.__New({Descriptor: "Setup Workbench", Resizeable: true, Closeable: true})
		}

		Close(*) {
			closeSetupWorkbench()
		}
	}

	class AdivisorResizer extends Window.Resizer {
		iRedraw := false

		__New(arguments*) {
			super.__New(arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViwer"), 500, kLowPriority)
		}

		Redraw() {
			this.iRedraw := (A_TickCount + 500)
		}

		RedrawHTMLViwer() {
			if (this.iRedraw && (A_TickCount > this.iRedraw)) {
				local ignore, button

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button, "P")
						return Task.CurrentTask

				this.iRedraw := false

				try this.Window.Workbench.updateRecommendations(true, false)
			}

			return Task.CurrentTask
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	ProgressCount {
		Get {
			return this.iProgressCount
		}

		Set {
			return (this.iProgressCount := value)
		}
	}

	Definition {
		Get {
			return this.iDefinition
		}
	}

	SimulatorDefinition {
		Get {
			return this.iSimulatorDefinition
		}
	}

	SimulatorSettings {
		Get {
			return this.iSimulatorSettings
		}
	}

	Characteristics {
		Get {
			return this.iCharacteristics
		}
	}

	Settings {
		Get {
			return this.iSettings
		}
	}

	CharacteristicsArea {
		Get {
			return this.iCharacteristicsArea
		}
	}

	SelectedCharacteristics[key?] {
		Get {
			return (isSet(key) ? this.iSelectedCharacteristics[key] : this.iSelectedCharacteristics)
		}
	}

	SelectedCharacteristicsWidgets[key?] {
		Get {
			return (isSet(key) ? this.iSelectedCharacteristicsWidgets[key] : this.iSelectedCharacteristicsWidgets)
		}

		Set {
			return (key ? (this.iSelectedCharacteristicsWidgets[key] := value) : (this.iSelectedCharacteristicsWidgets := value))
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	SelectedSimulator[label := true] {
		Get {
			if (label = "*")
				return ((this.iSelectedSimulator == true) ? "*" : this.iSelectedSimulator)
			else if this.SimulatorSettings
				return (label ? this.SimulatorSettings.Name : this.iSelectedSimulator)
			else
				return this.iSelectedSimulator
		}
	}

	AvailableCars[label := true] {
		Get {
			local cars, index, car

			if ((label == true) && inList(this.iAvailableCars, "*")) {
				cars := this.iAvailableCars.Clone()

				for index, car in cars
					if (car = "*")
						cars[index] := translate("All")

				return cars
			}
			else
				return this.iAvailableCars
		}
	}

	SelectedCar[label := true] {
		Get {
			if ((label = "*") && (this.iSelectedCar == true))
				return "*"
			else if (label && (this.iSelectedCar == true))
				return translate("All")
			else
				return this.iSelectedCar
		}
	}

	SelectedTrack[label := true] {
		Get {
			if ((label = "*") && (this.iSelectedTrack == true))
				return "*"
			else if (label && (this.iSelectedTrack == true))
				return translate("All")
			else
				return this.iSelectedTrack
		}
	}

	SelectedWeather {
		Get {
			return this.iSelectedWeather
		}
	}

	SettingsViewer {
		Get {
			return this.iSettingsViewer
		}
	}

	Setup {
		Get {
			return this.iSetup
		}

		Set {
			return (this.iSetup := value)
		}
	}

	KnowledgeBase {
		Get {
			return this.iKnowledgeBase
		}
	}

	__New(simulator := false, car := false, track := false, weather := false) {
		local found := false
		local definition, section, values, key, value, ignore, rootDirectory

		if simulator {
			this.iSelectedSimulator := simulator
			this.iSelectedCar := car
			this.iSelectedTrack := track
			this.iSelectedWeather := weather
		}

		definition := readMultiMap(kResourcesDirectory . "Garage\Setup Workbench.ini")

		for ignore, rootDirectory in [kTranslationsDirectory, kUserTranslationsDirectory]
			if FileExist(rootDirectory . "Setup Workbench." . getLanguage()) {
				found := true

				for section, values in readMultiMap(rootDirectory . "Setup Workbench." . getLanguage())
					for key, value in values
						setMultiMapValue(definition, section, key, value)
			}

		if !found
			for section, values in readMultiMap(kTranslationsDirectory . "Setup Workbench.en")
				for key, value in values
					setMultiMapValue(definition, section, key, value)

		this.iDefinition := definition

		super.__New(kSimulatorConfiguration)

		SetupWorkbench.Instance := this
	}

	createGui(configuration) {
		local workbench := this
		local simulators, simulator, weather, choices, chosen, index, name, workbenchGui, button

		chooseSimulator(*) {
			workbench.loadSimulator((workbenchGui["simulatorDropDown"].Text = translate("Generic")) ? true : workbenchGui["simulatorDropDown"].Text)
		}

		chooseCar(*) {
			workbench.loadCar((workbenchGui["carDropDown"].Text = translate("All")) ? true : workbenchGui["carDropDown"].Text)
		}

		chooseTrack(*) {
			local simulator, tracks, trackNames

			if (workbenchGui["trackDropDown"].Text = translate("All"))
				workbench.loadTrack(true)
			else {
				simulator := workbench.SelectedSimulator
				tracks := workbench.getTracks(simulator, workbench.SelectedCar)
				trackNames := collect(tracks, ObjBindMethod(workbench, "getTrackName", simulator))

				workbench.loadTrack(tracks[inList(trackNames, workbenchGui["trackDropDown"].Text)])
			}
		}

		chooseWeather(*) {
		}

		chooseCharacteristic(*) {
			workbench.chooseCharacteristic()
		}

		editSetup(*) {
			workbench.editSetup()
		}

		loadSetup(*) {
			local fileName

			workbenchGui.Opt("+OwnDialogs")

			OnMessage(0x44, translateLoadCancelButtons)
			fileName := FileSelect(1, "", translate("Load Problems..."), "Problems (*.setup)")
			OnMessage(0x44, translateLoadCancelButtons, 0)

			if (fileName != "")
				workbench.restoreState(fileName, false)
		}

		saveSetup(*) {
			local fileName

			workbenchGui.Opt("+OwnDialogs")

			OnMessage(0x44, translateSaveCancelButtons)
			fileName := FileSelect("S17", "", translate("Save Problems..."), "Problems (*.setup)")
			OnMessage(0x44, translateSaveCancelButtons, 0)

			if (fileName != "") {
				if !InStr(fileName, ".setup")
					fileName := (fileName . ".setup")

				workbench.saveState(fileName)
			}
		}

		workbenchGui := SetupWorkbench.WorkbenchWindow(this)

		this.iWindow := workbenchGui

		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Text", "w1184 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(workbenchGui, "Setup Workbench"))

		workbenchGui.SetFont("s9 Norm", "Arial")
		workbenchGui.SetFont("Italic Underline", "Arial")

		workbenchGui.Add("Text", "x508 YP+20 w184 cBlue Center H:Center", translate("Setup Workbench")).OnEvent("Click", openDocumentation.Bind(workbenchGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench"))

		workbenchGui.Add("Text", "x8 yp+30 w1200 W:Grow 0x10 Section")

		workbenchGui.SetFont("Norm")
		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x16 yp+12 w30 h30", kIconsDirectory . "Road.ico")
		workbenchGui.Add("Text", "x50 yp+5 w120 h26", translate("Selection"))

		workbenchGui.SetFont("s8 Norm", "Arial")

		workbenchGui.Add("Text", "x16 yp+32 w80 h23 +0x200", translate("Simulator"))

		simulators := this.getSimulators()
		simulator := 0

		if (simulators.Length > 0) {
			if this.SelectedSimulator
				simulator := inList(simulators, this.SelectedSimulator)

			if (simulator == 0)
				simulator := inList(simulators, true)
		}

		for index, name in simulators
			if (name == true)
				simulators[index] := translate("Generic")

		workbenchGui.Add("DropDownList", "x100 yp w196 Choose" . simulator . " vsimulatorDropDown", simulators).OnEvent("Change", chooseSimulator)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		workbenchGui.Add("Text", "x16 yp+24 w80 h23 +0x200", translate("Car"))
		workbenchGui.Add("DropDownList", "x100 yp w196 Choose1 vcarDropDown", [translate("All")]).OnEvent("Change", chooseCar)
		workbenchGui.Add("Text", "x16 yp+24 w80 h23 +0x200", translate("Track"))
		workbenchGui.Add("DropDownList", "x100 yp w196 Choose1 vtrackDropDown", [translate("All")]).OnEvent("Change", chooseTrack)

		workbenchGui.Add("Text", "x16 yp+24 w80 h23 +0x200", translate("Conditions"))

		weather := this.SelectedWeather
		choices := collect(kWeatherConditions, translate)
		chosen := inList(kWeatherConditions, weather)

		if (!chosen && (choices.Length > 0)) {
			weather := choices[1]
			chosen := 1
		}

		workbenchGui.Add("DropDownList", "x100 yp w196 AltSubmit Disabled Choose" . chosen . "  vweatherDropDown", choices).OnEvent("Change", chooseWeather)

		workbenchGui.Add("Button", "x305 ys+49 w94 h94 Disabled veditSetupButton").OnEvent("Click", editSetup)
		setButtonIcon(workbenchGui["editSetupButton"], kIconsDirectory . "Car Setup.ico", 1, "W64 H64")

		workbenchGui.Add("Text", "x8 yp+103 w400 0x10")

		workbenchGui.SetFont("Norm")
		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x16 yp+12 w30 h30", kIconsDirectory . "Report.ico")
		workbenchGui.Add("Text", "x50 yp+5 w180 h26", translate("Characteristics"))

		workbenchGui.SetFont("s8 Norm")
		workbenchGui.Add("GroupBox", "x16 yp+30 w382 h469 H:Grow -Theme")

		this.iCharacteristicsArea := {X: 16, Y: 262, Width: 382, W: 482, Height: 439, H: 439}

		workbenchGui.Add("Button", "x280 yp-24 w70 h23 vcharacteristicsButton", translate("Problem...")).OnEvent("Click", chooseCharacteristic)
		button := workbenchGui.Add("Button", "x352 yp w23 h23")
		button.OnEvent("Click", loadSetup)
		setButtonIcon(button, kIconsDirectory . "Load.ico", 1, "L2 T2 R2 B2")
		button := workbenchGui.Add("Button", "x376 yp w23 h23")
		button.OnEvent("Click", saveSetup)
		setButtonIcon(button, kIconsDirectory . "Save.ico", 1, "L4 T4 R4 B4")

		workbenchGui.SetFont("Norm")
		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x420 ys+12 w30 h30", kIconsDirectory . "Assistant.ico")
		workbenchGui.Add("Text", "x454 yp+5 w150 h26", translate("Recommendations"))

		workbenchGui.SetFont("s8 Norm", "Arial")

		this.iSettingsViewer := workbenchGui.Add("ActiveX", "x420 yp+30 w775 h621 W:Grow H:Grow Border vsettingsViewer", "shell.explorer").Value
		this.SettingsViewer.Navigate("about:blank")

		this.showSettingsChart(false)

		/*
		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x8 y730 w1200 Y:Move W:Grow 0x10")

		workbenchGui.Add("Button", "x16 y738 w77 h23 Y:Move", translate("&Load...")).OnEvent("Click", loadSetup)
		workbenchGui.Add("Button", "x98 y738 w77 h23 Y:Move", translate("&Save...")).OnEvent("Click", saveSetup)

		workbenchGui.Add("Button", "x574 y738 w80 h23 Y:Move H:Center", translate("Close")).OnEvent("Click", closeSetupWorkbench)
		*/

		workbenchGui.Add(SetupWorkbench.AdivisorResizer(workbenchGui))
	}

	show() {
		local window := this.Window
		local x, y, w, h

		if getWindowPosition("Setup Workbench", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Setup Workbench", &w, &h)
			window.Resize("Initialize", w, h)
	}

	saveState(fileName := false) {
		local state, ignore, characteristic, widgets, value1, value2

		if !fileName
			fileName := (kUserConfigDirectory . "Setup Workbench.setup")

		state := this.SimulatorDefinition.Clone()

		setMultiMapValue(state, "State", "Simulator", this.SelectedSimulator["*"])
		setMultiMapValue(state, "State", "Car", this.SelectedCar["*"])
		setMultiMapValue(state, "State", "Track", this.SelectedTrack["*"])
		setMultiMapValue(state, "State", "Weather", this.SelectedWeather)

		setMultiMapValue(state, "State", "Characteristics", values2String(",", this.Characteristics*))
		setMultiMapValue(state, "State", "Settings", values2String(",", this.Settings*))

		setMultiMapValue(state, "Characteristics", "Characteristics", values2String(",", this.SelectedCharacteristics*))

		for ignore, characteristic in this.SelectedCharacteristics {
			widgets := this.SelectedCharacteristicsWidgets[characteristic]

			value1 := widgets[1].Value
			value2 := widgets[2].Value

			setMultiMapValue(state, "Characteristics", characteristic . ".Weight", value1)
			setMultiMapValue(state, "Characteristics", characteristic . ".Value", value2)
		}

		setMultiMapValues(state, "KnowledgeBase", this.KnowledgeBase.Facts.Facts)

		writeMultiMap(fileName, state)
	}

	restoreState(fileName := false, reset := true) {
		local state, simulator, car, track, weather, characteristicLabels, characteristics
		local ignore, characteristic

		if !fileName
			fileName := (kUserConfigDirectory . "Setup Workbench.setup")

		if FileExist(fileName) {
			state := readMultiMap(fileName)

			simulator := getMultiMapValue(state, "State", "Simulator")
			car := getMultiMapValue(state, "State", "Car")
			track := getMultiMapValue(state, "State", "Track")
			weather := getMultiMapValue(state, "State", "Weather")

			if (simulator = "*")
				simulator := true

			if (car = "*")
				car := true

			if (track = "*")
				track := true

			if !GetKeyState("Ctrl", "P")
				this.clearCharacteristics()

			this.loadSimulator(simulator, reset)
			this.loadCar(car)
			this.loadTrack(track)
			this.loadWeather(weather)

			characteristicLabels := getMultiMapValues(this.Definition, "Setup.Characteristics.Labels")

			characteristics := string2Values(",", getMultiMapValue(state, "Characteristics", "Characteristics"))

			if (characteristics.Length > 0) {
				this.Window.Opt("+Disabled")

				try {
					this.ProgressCount := 0

					showProgress({color: "Green", width: 350, title: translate("Loading Problems"), message: translate("Preparing Characteristics...")})

					Sleep(200)

					for ignore, characteristic in characteristics {
						showProgress({progress: (this.ProgressCount += 10), message: translate("Load ") . characteristicLabels[characteristic] . translate("...")})

						if (this.SelectedCharacteristics.Length < kMaxCharacteristics)
							this.addCharacteristic(characteristic, getMultiMapValue(state, "Characteristics", characteristic . ".Weight")
																 , getMultiMapValue(state, "Characteristics", characteristic . ".Value")
																 , false)
					}

					this.updateRecommendations()

					this.updateState()

					showProgress({progress: 100, message: translate("Finished...")})

					Sleep(500)

					hideProgress()
				}
				finally {
					this.Window.Opt("-Disabled")
				}
			}
		}
		else
			this.loadSimulator(true, true)

		return false
	}

	showSettingsChart(content) {
		local isChart, before, after, width, height, info, html, index, message, iWidth, iHeight, document

		if !content
			content := [translate("Please describe your car handling problems.")]

		isChart := !isObject(content)

		if this.SettingsViewer {
			this.SettingsViewer.Document.open()

			if (content && (content != "")) {
				if isChart {
					before := "
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
								google.charts.load('current', {'packages':['corechart', 'table', 'bar']}).then(drawChart);
					)"

					width := this.SettingsViewer.Width
					height := (this.SettingsViewer.Height - 110 - 1)

					info := getMultiMapValue(this.Definition, "Setup.Info", "ChangeWarning", "")

					iWidth := width - 10
					iHeight := 90

					after := "
					(
							</script>
						</head>
						<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
							<div id="chart_id" style="width: %width%px; height: %height%px"></div>
							<div style="width: %iWidth%px; height: %iHeight%px">
								<p style="font-family: Arial; font-size: 16px; margin: 5px">
									<br>
									<br>
									%info%
								</p>
							</div>
						</body>
					</html>
					)"

					after := substituteVariables(after, {width: width, height: height, iWidth: iWidth, iHeight: iHeight, info: info})

					this.SettingsViewer.Document.write(before . content . after)
				}
				else {
					width := this.SettingsViewer.Width
					height := (this.SettingsViewer.Height - 1)

					html := ""

					for index, message in content {
						if (index > 1)
							html .= "<br><br>"

						html .= message
					}

					document := "
					(
					<html>
						<meta charset='utf-8'>
						<head>
						</head>
						<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
							<div style="width: %width%px; height: %height%px; text-align: center">
								<p style="font-family: Arial; font-size: 16px; height: %height%px; margin: auto">
									<br>
									<br>
									<br>
									<br>
									%html%
								</p>
							</div>
						</body>
					</html>
					)"

					this.SettingsViewer.Document.write(substituteVariables(document, {width: width, height: height, html: html}))
				}
			}
			else {
				html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

				this.SettingsViewer.Document.write(html)
			}

			this.SettingsViewer.Document.close()
		}
	}

	showSettingsDeltas(settings) {
		local drawChartFunction, names, values, ignore, setting, theMax, index, value

		this.showSettingsChart(false)

		if settings {
			if (settings.Length > 0) {
				drawChartFunction := "function drawChart() {"
				drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["

				if false {
					names := []
					values := []
				}
				else {
					names := [translate("Settings")]
					values := [0.0]
				}

				for ignore, setting in settings {
					names.Push(setting[1])
					values.Push(setting[2])
				}

				theMax := Max(Abs(maximum(values)), Abs(minimum(values)))

				for index, value in values
					values[index] := (value / theMax)

				if false {
					drawChartFunction .= "`n['" . translate("Setting") . "', '" . translate("Value") . "',  { role: 'annotation' }]"

					loop names.Length
						drawChartFunction .= ",`n['" . names[A_Index] . "', " . values[A_Index] . ", '" . names[A_Index] . "']"

					drawChartFunction .= "`n]);"

					drawChartFunction := drawChartFunction . "`nvar options = { legend: 'none', vAxis: { textPosition: 'none', baseline: 'none' }, bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '5%', top: '5%', right: '5%', bottom: '5%' } };"
				}
				else {
					drawChartFunction .= "`n['" . values2String("', '", names*) . "'],"

					drawChartFunction .= "`n[" . values2String(",", values*) . "]"

					drawChartFunction .= "`n]);"

					drawChartFunction := drawChartFunction . "`nvar options = { bar: { groupWidth: " . (settings.Length * 16) . " }, vAxis: { textPosition: 'none', baseline: 'none' }, hAxis: {maxValue: 1, minValue: -1}, bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '5%', top: '5%', right: '40%', bottom: '5%' } };"
				}

				drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction := [translate("I can't help you with that."), translate("You are on your own this time.")]

			this.showSettingsChart(drawChartFunction)
		}
	}

	setDebug(option, enabled, *) {
		local label := false

		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)

		switch option {
			case kDebugKnowledgeBase:
				label := translate("Debug Knowledgebase")

				if enabled
					this.dumpKnowledgeBase(this.KnowledgeBase)
			case kDebugRules:
				label := translate("Debug Rule System")

				if enabled
					this.dumpRules(this.KnowledgeBase)
		}

		if label
			if enabled
				SupportMenu.Check(label)
			else
				SupportMenu.Uncheck(label)
	}

	toggleDebug(option, *) {
		this.setDebug(option, !this.Debug[option])
	}

	getSimulators() {
		local simulators := []
		local hasGeneric := false
		local simulator

		loop Files, kResourcesDirectory "Garage\Definitions\*.ini", "F" {
			SplitPath(A_LoopFileName, , , , &simulator)

			if (simulator = "Generic")
				hasGeneric := true
			else if !inList(simulators, simulator)
				simulators.Push(simulator)
		}

		loop Files, kUserHomeDirectory "Garage\Definitions\*.ini", "F" {
			SplitPath(A_LoopFileName, , , , &simulator)

			if (simulator = "Generic")
				hasGeneric := true
			else if !inList(simulators, simulator)
				simulators.Push(simulator)
		}

		if hasGeneric
			simulators.InsertAt(1, true)

		return simulators
	}

	getCars(simulator) {
		local cars := []
		local ignore, car, descriptor

		if ((simulator != true) && (simulator != "*")) {
			loop Files, kResourcesDirectory . "Garage\Definitions\Cars\" . simulator . ".*.ini", "F" {
				SplitPath(A_LoopFileName, , , , &descriptor)

				car := StrReplace(StrReplace(descriptor, simulator . ".", ""), ".ini", "")

				if ((car != "Generic") && !inList(cars, car))
					cars.Push(car)
			}

			loop Files, kUserHomeDirectory . "Garage\Definitions\Cars\*.ini", "F" {
				SplitPath(A_LoopFileName, , , , &descriptor)

				car := StrReplace(StrReplace(descriptor, simulator . ".", ""), ".ini", "")

				if ((car != "Generic") && !inList(cars, car))
					cars.Push(car)
			}

			if (this.SimulatorDefinition && (getMultiMapValue(this.SimulatorDefinition, "Simulator", "Cars", false) = "*")) {
				for ignore, car in SessionDatabase().getCars(simulator) {
					car := SessionDatabase.getCarName(simulator, car)

					if !inList(cars, car)
						cars.Push(car)
				}
			}
		}

		cars.InsertAt(1, "*")

		return cars
	}

	getTracks(simulator, car) {
		local tracks := []

		if (car && (car != true))
			tracks := SessionDatabase().getTracks(simulator, car)

		tracks.InsertAt(1, "*")

		return tracks
	}

	getTrackName(simulator, track) {
		if ((track = "*") || (track == true))
			return translate("All")
		else
			return SessionDatabase.getTrackName(simulator, track)
	}

	dumpKnowledgeBase(knowledgeBase) {
		knowledgeBase.dumpFacts()
	}

	dumpRules(knowledgeBase) {
		knowledgeBase.dumpRules()
	}

	updateState() {
		if (this.SelectedCharacteristics.Length < kMaxCharacteristics)
			this.Control["characteristicsButton"].Enabled := true
		else
			this.Control["characteristicsButton"].Enabled := false

		if (this.SimulatorDefinition && getMultiMapValue(this.SimulatorDefinition, "Setup", "Editor", false))
			this.Control["editSetupButton"].Enabled := true
		else
			this.Control["editSetupButton"].Enabled := false

	}

	compileRules(fileName, &productions, &reductions) {
		if (fileName && (fileName != "") && FileExist(fileName))
			RuleCompiler().compileRules(FileRead(fileName), &productions, &reductions)
	}

	loadRules(&productions, &reductions) {
		local simulator, car

		productions := false
		reductions := false

		RuleCompiler().compileRules(FileRead(kResourcesDirectory . "Garage\Rules\Setup Workbench.rules"), &productions, &reductions)

		simulator := this.SelectedSimulator
		car := this.SelectedCar[false]

		this.compileRules(getFileName("Garage\Rules\" . simulator . ".rules", kResourcesDirectory, kUserHomeDirectory), &productions, &reductions)
		this.compileRules(getFileName("Garage\Rules\Cars\" . simulator . ".Generic.rules", kResourcesDirectory, kUserHomeDirectory), &productions, &reductions)

		if (car != true)
			this.compileRules(getFileName("Garage\Rules\Cars\" . simulator . "." . car . ".rules", kResourcesDirectory, kUserHomeDirectory), &productions, &reductions)
	}

	loadCharacteristics(definition, simulator := false, car := false, track := false, fast := false) {
		local knowledgeBase := this.KnowledgeBase
		local characteristicLabels := getMultiMapValues(this.Definition, "Setup.Characteristics.Labels")
		local compiler, group, ignore, groupOption, option, characteristic

		this.iCharacteristics := []

		if !simulator
			knowledgeBase.addFact("Characteristics.Count", 0)

		compiler := RuleCompiler()

		for group, definition in getMultiMapValues(definition, "Setup.Characteristics")
			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)

					for ignore, option in string2Values(",", groupOption[2]) {
						characteristic := factPath(group, groupOption[1], option)

						if !simulator {
							showProgress({progress: ++this.ProgressCount, message: translate("Initializing Characteristic ")
																				 . characteristicLabels[characteristic]
																				 . translate("...")})

							knowledgeBase.prove(compiler.compileGoal("addCharacteristic(" . characteristic . ")")).dispose()

							this.Characteristics.Push(characteristic)

							if (!fast && !isDebug())
								Sleep(25)
						}
						else if knowledgeBase.prove(compiler.compileGoal("characteristicActive("
																	   . StrReplace(values2String(",", simulator, car, track, characteristic), A_Space, "\ ")
																	   . ")")) {
							showProgress({progress: ++this.ProgressCount})

							this.Characteristics.Push(characteristic)
						}
					}
				}
				else {
					characteristic := factPath(group, groupOption)

					if !simulator {
						showProgress({progress: ++this.ProgressCount, message: translate("Initializing Characteristic ")
																			 . characteristicLabels[characteristic] . translate("...")})

						knowledgeBase.prove(compiler.compileGoal("addCharacteristic(" . characteristic . ")")).dispose()

						this.Characteristics.Push(characteristic)

						if (!fast && !isDebug())
							Sleep(25)
					}
					else if knowledgeBase.prove(compiler.compileGoal("characteristicActive("
																   . StrReplace(values2String(",", simulator, car, track, characteristic), A_Space, "\ ")
																   . ")")) {
						showProgress({progress: ++this.ProgressCount})

						this.Characteristics.Push(characteristic)
					}
				}
			}
	}

	loadSettings(definition, simulator := false, car := false, fast := false) {
		local knowledgeBase := this.KnowledgeBase
		local settingsLabels := getMultiMapValues(this.Definition, "Setup.Settings.Labels")
		local compiler, group, ignore, groupOption, option, setting

		this.iSettings := []

		if !simulator
			knowledgeBase.setFact("Settings.Count", 0)

		compiler := RuleCompiler()

		for group, definition in getMultiMapValues(definition, "Setup.Settings")
			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)

					for ignore, option in string2Values(",", groupOption[2]) {
						setting := factPath(group, groupOption[1], option)

						if !simulator {
							showProgress({progress: ++this.ProgressCount, message: translate("Initializing Setting ")																				 . settingsLabels[setting]																				 . translate("...")})

							knowledgeBase.prove(compiler.compileGoal("addSetting(" . setting . ")")).dispose()

							this.Settings.Push(setting)

							if (!fast && !isDebug())
								Sleep(25)
						}
						else if knowledgeBase.prove(compiler.compileGoal("settingAvailable("
																	   . StrReplace(values2String(",", simulator, car, setting), A_Space, "\ ")
																	   . ")")) {
							showProgress({progress: ++this.ProgressCount})

							this.Settings.Push(setting)
						}
					}
				}
				else {
					setting := factPath(group, groupOption)

					if !simulator {
						showProgress({progress: ++this.ProgressCount, message: translate("Initializing Setting ")
																			 . settingsLabels[setting]
																			 . translate("...")})

						knowledgeBase.prove(compiler.compileGoal("addSetting(" . setting . ")")).dispose()

						this.Settings.Push(setting)

						if (!fast && !isDebug())
							Sleep(25)
					}
					else if knowledgeBase.prove(compiler.compileGoal("settingAvailable("
																   . StrReplace(values2String(",", simulator, car, setting), A_Space, "\ ")
																   . ")")) {
						showProgress({progress: ++this.ProgressCount})

						this.Settings.Push(setting)
					}
				}
			}
	}

	createKnowledgeBase(productions, reductions, facts := false) {
		local engine := RuleEngine(productions, reductions, facts)

		return KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}

	initializeSimulator(name) {
		local definition := readMultiMap(kResourcesDirectory . "Garage\Definitions\" . name . ".ini")
		local simulator := getMultiMapValue(definition, "Simulator", "Simulator")
		local cars, tracks

		this.iSimulatorDefinition := definition

		cars := this.getCars(simulator)
		tracks := this.getTracks(simulator, true)

		this.iSimulatorSettings := {Name: name, Simulator: simulator, Cars: cars, Tracks: tracks}

		this.iSelectedSimulator := ((simulator = "*") ? true : simulator)
		this.iAvailableCars := cars
		this.iSelectedCar := ((cars[1] = "*") ? true : cars[1])
		this.iSelectedTrack := ((tracks[1] = "*") ? true : tracks[1])
	}

	initializeWorkbench(phase1 := "Initializing Setup Workbench", phase2 := "Starting Setup Workbench", phase3 := "Loading Car", fast := false) {
		local knowledgeBase, simulator, x, y, productions, reductions

		simulator := this.SelectedSimulator

		this.ProgressCount := 0

		showProgress({color: "Blue", width: 350, title: translate(phase1), message: translate("Clearing Problems...")})

		Sleep(200)

		this.clearCharacteristics()

		showProgress({progress: this.ProgressCount++, message: translate("Preparing Knowledgebase...")})

		Sleep(200)

		productions := false
		reductions := false

		this.loadRules(&productions, &reductions)

		knowledgeBase := this.createKnowledgeBase(productions, reductions)

		this.iKnowledgeBase := knowledgeBase

		if this.Debug[kDebugRules]
			this.dumpRules(this.KnowledgeBase)

		this.loadCharacteristics(this.Definition, false, false, false, fast)
		this.loadSettings(this.Definition, false, false, fast)

		showProgress({progress: this.ProgressCount++, color: "Green", title: translate(phase2), message: translate("Starting AI Kernel...")})

		knowledgeBase.addFact("Initialize", true)

		knowledgeBase.produce()

		Sleep(200)

		showProgress({progress: this.ProgressCount++, color: "Green", title: translate(phase3), message: translate("Loading Car Settings...")})

		this.loadCharacteristics(this.Definition, this.SelectedSimulator["*"], this.SelectedCar["*"], this.SelectedTrack["*"], fast)

		Sleep(200)

		this.loadSettings(this.Definition, this.SelectedSimulator["*"], this.SelectedCar["*"], fast)

		Sleep(200)

		knowledgeBase.setFact("Workbench.Simulator", this.SelectedSimulator["*"])
		knowledgeBase.setFact("Workbench.Car", this.SelectedCar["*"])
		knowledgeBase.setFact("Workbench.Track", this.SelectedTrack["*"])

		knowledgeBase.addFact("Calculate", true)

		knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		showProgress({progress: this.ProgressCount++, message: translate("Initializing Car Setup...")})

		Sleep(200)

		this.updateRecommendations(false, false)

		this.showSettingsChart(false)

		showProgress({message: translate("Finished...")})

		Sleep(500)

		this.iSetup := false

		hideProgress()

		this.updateState()
	}

	loadSimulator(simulator, force := false) {
		local simulators, settings

		if (force || (simulator != this.SelectedSimulator)) {
			this.Window.Opt("+Disabled")

			try {
				this.iSelectedSimulator := simulator

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				if (simulator == true)
					removeMultiMapValue(settings, "Setup Workbench", "Simulator")
				else
					setMultiMapValue(settings, "Setup Workbench", "Simulator", simulator)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

				this.initializeSimulator((simulator == true) ? "Generic" : simulator)

				simulators := this.getSimulators()

				if (simulators.Length > 0)
					this.Control["simulatorDropDown"].Choose(inList(this.getSimulators(), simulator))

				this.loadCars(this.AvailableCars[true])

				this.initializeWorkbench()
			}
			finally {
				this.Window.Opt("-Disabled")
			}
		}
	}

	loadCars(cars) {
		local tracks, trackNames

		this.Control["carDropDown"].Delete()
		this.Control["carDropDown"].Add(cars)

		this.Control["carDropDown"].Choose(1)

		this.iSelectedCar := ((cars[1] = translate("All")) ? true : cars[1])

		tracks := this.getTracks(this.SelectedSimulator, this.SelectedCar).Clone()
		trackNames := collect(tracks, ObjBindMethod(this, "getTrackName", this.SelectedSimulator))

		this.Control["trackDropDown"].Delete()
		this.Control["trackDropDown"].Add(trackNames)
		this.Control["trackDropDown"].Choose(1)
	}

	loadCar(car, force := false) {
		local tracks, trackNames, settings

		if (force || (car != this.SelectedCar[false])) {
			this.Window.Opt("+Disabled")

			try {
				this.iSelectedCar := car

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				if (car == true)
					removeMultiMapValue(settings, "Setup Workbench", "Car")
				else
					setMultiMapValue(settings, "Setup Workbench", "Car", car)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

				this.Control["carDropDown"].Choose(inList(this.AvailableCars, this.SelectedCar))

				tracks := this.getTracks(this.SelectedSimulator, car).Clone()
				trackNames := collect(tracks, ObjBindMethod(this, "getTrackName", this.SelectedSimulator))

				this.Control["trackDropDown"].Delete()
				this.Control["trackDropDown"].Add(trackNames)
				this.Control["trackDropDown"].Choose(1)

				this.initializeWorkbench("Loading Car", "Loading Car", "Loading Car", true)
			}
			finally {
				this.Window.Opt("-Disabled")
			}
		}
	}

	loadTrack(track, force := false) {
		local settings

		if (force || (track != this.SelectedTrack[false])) {
			this.Window.Opt("+Disabled")

			try {
				this.iSelectedTrack := track

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				if (track == true)
					removeMultiMapValue(settings, "Setup Workbench", "Track")
				else
					setMultiMapValue(settings, "Setup Workbench", "Track", track)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

				if (track != true) {
					track := inList(this.getTracks(this.SelectedSimulator, this.SelectedCar), track)

					if !track
						track := 1
				}

				this.Control["trackDropDown"].Choose(track)
			}
			finally {
				this.Window.Opt("-Disabled")
			}
		}
	}

	loadWeather(weather, force := false) {
	}

	startTelemetryAnalyzer(*) {
		local analyzerClass := getMultiMapValue(this.SimulatorDefinition, "Simulator", "Analyzer", false)

		if analyzerClass
			%analyzerClass%(this, this.SelectedSimulator).createCharacteristics()
	}

	clearCharacteristics() {
		while (this.SelectedCharacteristics.Length > 0)
			this.deleteCharacteristic(this.SelectedCharacteristics[this.SelectedCharacteristics.Length], false)

		this.showSettingsChart(false)
	}

	addCharacteristic(characteristic, weight := 50, value := 33, draw := true, *) {
		local workbench := this
		local window := this.Window
		local numCharacteristics := this.SelectedCharacteristics.Length
		local x, y, characteristicLabels, callback
		local label1, label2, slider1, slider2, deleteButton

		updateSlider(characteristic, slider1, slider2, *) {
			workbench.updateCharacteristic(characteristic, slider1.Value, slider2.Value)
		}

		if (!inList(this.SelectedCharacteristics, characteristic) && (numCharacteristics <= kMaxCharacteristics)) {
			x := (this.CharacteristicsArea.X + 8)
			y := (this.CharacteristicsArea.Y + 8 + (numCharacteristics * kCharacteristicHeight))

			characteristicLabels := getMultiMapValues(this.Definition, "Setup.Characteristics.Labels")

			this.SelectedCharacteristics.Push(characteristic)

			window.SetFont("s10 Italic", "Arial")

			deleteButton := window.Add("Button", "x" . X . " y" . Y . " w20 h20")
			deleteButton.OnEvent("Click", ObjBindMethod(this, "deleteCharacteristic", characteristic, true))
			setButtonIcon(deleteButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

			x := x + 25

			label1 := window.Add("Text", "x" . X . " y" . Y . " w300 h26", characteristicLabels[characteristic])

			x := x - 25

			window.SetFont("s8 Norm", "Arial")

			x := x + 8
			y := y + 26

			label2 := window.Add("Text", "x" . X . " y" . Y . " w115", translate("Importance / Severity"))

			x := x + 120

			slider1 := window.Add("Slider", "Center Thick15 x" . x . " yp-2 w118 0x10 Range0-100 ToolTip", 0)

			x := x + 123

			slider2 := window.Add("Slider", "Center Thick15 x" . x . " yp w118 0x10 Range0-100 ToolTip", 0)

			callback := updateSlider.Bind(characteristic, slider1, slider2)

			slider1.OnEvent("Change", callback)
			slider2.OnEvent("Change", callback)

			slider1.Value := weight
			slider2.Value := value

			this.SelectedCharacteristicsWidgets[characteristic] := [slider1, slider2, label1, label2, deleteButton]

			if draw {
				this.updateRecommendations()

				this.updateState()
			}
		}
	}

	deleteCharacteristic(characteristic, draw := true, *) {
		local numCharacteristics := this.SelectedCharacteristics.Length
		local index := inList(this.SelectedCharacteristics, characteristic)
		local ignore, widget, row, y, widgets, pos, poxX, posY

		if index {
			for ignore, widget in this.SelectedCharacteristicsWidgets[characteristic]
				widget.Visible := false

			loop (numCharacteristics - index) {
				row := (A_Index + index)

				for ignore, widget in this.SelectedCharacteristicsWidgets[this.SelectedCharacteristics[row]] {
					widget.GetPos(&posX, &posY, &posW, &posH)

					y := (posY - kCharacteristicHeight)

					widget.Move(posX, Y)
					widget.Redraw()
				}
			}

			widgets := this.SelectedCharacteristicsWidgets[characteristic]

			this.KnowledgeBase.clearFact(characteristic . ".Weight")
			this.KnowledgeBase.clearFact(characteristic . ".Value")

			this.SelectedCharacteristics.RemoveAt(index)

			if this.SelectedCharacteristicsWidgets.Has(characteristic)
				this.SelectedCharacteristicsWidgets.Delete(characteristic)

			this.updateRecommendations(draw)
		}
	}

	chooseCharacteristic() {
		local dynamicMenus := CaseInsenseMap()
		local characteristicLabels, menuIndex, groups, translatedGroups, ignore, group, definition, option
		local groupMenu, groupEmpty, groupOption, optionMenu, optionEmpty, label, characteristic
		local characteristicsMenu, groupMenu

		characteristicsMenu := Menu()

		characteristicLabels := getMultiMapValues(this.Definition, "Setup.Characteristics.Labels")

		menuIndex := 1

		groups := getMultiMapValues(this.Definition, "Setup.Characteristics")
		translatedGroups := CaseInsenseMap()

		for group, definition in groups
			translatedGroups[characteristicLabels[group]] := group

		for ignore, group in translatedGroups {
			definition := groups[group]

			groupMenu := ("SubMenu" . menuIndex++)
			groupEmpty := true

			dynamicMenus[groupMenu] := Menu()

			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)
					optionMenu := ("SubMenu" . menuIndex++)
					optionEmpty := true

					dynamicMenus[optionMenu] := Menu()

					for ignore, option in string2Values(",", groupOption[2]) {
						characteristic := factPath(group, groupOption[1], option)

						if (inList(this.Characteristics, characteristic) && !inList(this.SelectedCharacteristics, characteristic)) {
							dynamicMenus[optionMenu].Add(characteristicLabels[option]
													   , ObjBindMethod(this, "addCharacteristic", characteristic, 50, 33, true))

							optionEmpty := false
						}
					}

					if !optionEmpty {
						dynamicMenus[groupMenu].Add(characteristicLabels[groupOption[1]], dynamicMenus[optionMenu])

						groupEmpty := false
					}
				}
				else {
					characteristic := factPath(group, groupOption)

					if (inList(this.Characteristics, characteristic) && !inList(this.SelectedCharacteristics, characteristic)) {
						dynamicMenus[groupMenu].Add(characteristicLabels[groupOption]
												  , ObjBindMethod(this, "addCharacteristic", characteristic, 50, 33, true))

						groupEmpty := false
					}
				}
			}

			if !groupEmpty
				characteristicsMenu.Add(characteristicLabels[group], dynamicMenus[groupMenu])
		}

		characteristicsMenu.Add()

		label := translate("Analyzer...")

		characteristicsMenu.Add(label, ObjBindMethod(this, "startTelemetryAnalyzer"))

		if (!this.SimulatorDefinition || !getMultiMapValue(this.SimulatorDefinition, "Simulator", "Analyzer", false)
									  || !inList(getKeys(getMultiMapValues(getControllerState(), "Simulators")), this.SelectedSimulator))
			characteristicsMenu.Disable(label)

		characteristicsMenu.Show()
	}

	updateCharacteristic(characteristic, value1, value2) {
		this.updateRecommendations()
	}

	updateRecommendations(draw := true, update := true) {
		local knowledgeBase := this.KnowledgeBase
		local noProblem, ignore, characteristic, widgets, value1, value2, settingsLabels, settings
		local setting, delta

		this.Window.Opt("+Disabled")

		try {
			noProblem := true

			if knowledgeBase {
				for ignore, characteristic in this.SelectedCharacteristics {
					noProblem := false

					widgets := this.SelectedCharacteristicsWidgets[characteristic]

					value1 := widgets[1].Value
					value2 := widgets[2].Value

					knowledgeBase.setFact(characteristic . ".Weight", value1, true)
					knowledgeBase.setFact(characteristic . ".Value", value2, true)
				}

				knowledgeBase.addFact("Calculate", true)

				this.KnowledgeBase.produce()

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)
			}

			if draw {
				if knowledgeBase {
					settingsLabels := getMultiMapValues(this.Definition, "Setup.Settings.Labels")

					settings := []

					for ignore, setting in this.Settings {
						delta := knowledgeBase.getValue(setting . ".Delta", translate("n/a"))

						if (isNumber(delta) && (delta != 0))
							settings.Push(Array(settingsLabels[setting], Round(delta, 2)))
					}
				}

				if noProblem
					this.showSettingsChart(false)
				else
					this.showSettingsDeltas(settings)
			}

			if update
				this.updateState()
		}
		finally {
			this.Window.Opt("-Disabled")
		}
	}

	editSetup() {
		local editorClass := getMultiMapValue(this.SimulatorDefinition, "Setup", "Editor", false)

		if editorClass
			%editorClass%(this).editSetup(this.Setup)
	}
}


;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TelemetryAnalyzer                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TelemetryAnalyzer {
	iWorkbench := false
	iSimulator := false

	Workbench {
		Get {
			return this.iWorkbench
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	__New(workbench, simulator) {
		this.iWorkbench := workbench
		this.iSimulator := simulator
	}

	createCharacteristics() {
		throw "Virtual method TelemetryAnalyzer.createCharacteristics must be implemented in a subclass..."
	}
}


;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Setup                                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Setup {
	iEditor := false
	iOriginalSetup := ""
	iModifiedSetup := ""

	iEnabledSettings := CaseInsenseMap()

	Editor {
		Get {
			return this.iEditor
		}

		Set {
			return (this.iEditor := value)
		}
	}

	Name {
		Get {
			throw "Virtual property Setup.Name must be implemented in a subclass..."
		}
	}

	Enabled[setting] {
		Get {
			return this.iEnabledSettings.Has(setting)
		}
	}

	Setup[original := false] {
		Get {
			return ((original || !this.iModifiedSetup) ? this.iOriginalSetup : this.iModifiedSetup)
		}

		Set {
			return (original ? (this.iOriginalSetup := value) : (this.iModifiedSetup := value))
		}
	}

	__New(editor) {
		this.iEditor := editor
	}

	getInitializationArguments() {
		return []
	}

	reset() {
		this.iModifiedSetup := false
	}

	getValue(setting, original := false, default := false) {
		throw "Virtual method Setup.getValue must be implemented in a subclass..."
	}

	setValue(setting, value) {
		throw "Virtual method Setup.setValue must be implemented in a subclass..."
	}

	enable(setting) {
		this.iEnabledSettings[setting] := true
	}

	disable(setting) {
		if setting {
			if this.iEnabledSettings.Has(setting)
				this.iEnabledSettings.Delete(setting)
		}
		else
			this.iEnabledSettings := CaseInsenseMap()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FileSetup                                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FileSetup extends Setup {
	iOriginalFileName := false
	iModifiedFileName := false

	Name {
		Get {
			local fileName := this.FileName[true]

			SplitPath(fileName, , , , &fileName)

			return fileName
		}
	}

	FileName[original := false] {
		Get {
			return (original ? this.iOriginalFileName : (this.iModifiedFileName ? this.iModifiedFileName : this.iOriginalFileName))
		}

		Set {
			return (original ? (this.iOriginalFileName := value) : (this.iModifiedFileName := value))
		}
	}

	__New(editor, originalFileName := false, modifiedFileName := false) {
		local setup

		super.__New(editor)

		this.iOriginalFileName := originalFileName
		this.iModifiedFileName := modifiedFileName

		if (originalFileName && FileExist(originalFileName)) {
			setup := FileRead(originalFileName)

			this.iOriginalSetup := setup
		}

		if (modifiedFileName && FileExist(modifiedFileName)) {
			setup := FileRead(modifiedFileName)

			this.iModifiedSetup := setup
		}
	}

	getInitializationArguments() {
		return [this.FileName[true], this.FileName[false]]
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SettingHandler                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SettingHandler {
	validValue(displayValue) {
		throw "Virtual method SettingHandler.validValue must be implemented in a subclass..."
	}

	formatValue(value) {
		return value
	}

	convertToDisplayValue(value) {
		throw "Virtual method SettingHandler.convertToDisplayValue must be implemented in a subclass..."
	}

	convertToRawValue(value) {
		throw "Virtual method SettingHandler.convertToRawValue must be implemented in a subclass..."
	}

	increaseValue(displayValue) {
		throw "Virtual method SettingHandler.increaseValue must be implemented in a subclass..."
	}

	decreaseValue(displayValue) {
		throw "Virtual method SettingHandler.decreaseValue must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; NumberHandler                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NumberHandler extends SettingHandler {
	MinValue {
		Get {
			return -2147483648
		}
	}

	MaxValue {
		Get {
			return 2147483647
		}
	}

	validValue(displayValue) {
		return ((displayValue >= this.MinValue) && (displayValue <= this.MaxValue))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DiscreteValuesHandler                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DiscreteValuesHandler extends NumberHandler {
	iZero := false
	iIncrement := false
	iMinValue := kUndefined
	iMaxValue := kUndefined

	Zero {
		Get {
			return this.iZero
		}
	}

	Increment {
		Get {
			return this.iIncrement
		}
	}

	MinValue {
		Get {
			return ((this.iMinValue != kUndefined) ? this.iMinValue : super.MinValue)
		}
	}

	MaxValue {
		Get {
			return ((this.iMaxValue != kUndefined) ? this.iMaxValue : super.MaxValue)
		}
	}

	__New(zero := 0, increment := 1, minValue := "__Undefined__", maxValue := "__Undefined__") {
		this.iZero := zero
		this.iIncrement := increment
		this.iMinValue := minValue
		this.iMaxValue := maxValue
	}

	convertToDisplayValue(rawValue) {
		return this.formatValue(this.Zero + (rawValue * this.Increment))
	}

	convertToRawValue(displayValue) {
		return Round((displayValue - this.Zero) / this.Increment)
	}

	increaseValue(displayValue) {
		local value := (displayValue + this.Increment)

		if this.validValue(value)
			return value
		else
			return displayValue
	}

	decreaseValue(displayValue) {
		local value := (displayValue - this.Increment)

		if this.validValue(value)
			return value
		else
			return displayValue
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RawHandler                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RawHandler extends DiscreteValuesHandler {
	__New(increment := 1, minValue := "__Undefined__", maxValue := "__Undefined__") {
		super.__New(0, increment, minValue, maxValue)
	}

	convertToDisplayValue(rawValue) {
		return rawValue
	}

	convertToRawValue(displayValue) {
		return displayValue
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; IntegerHandler                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class IntegerHandler extends DiscreteValuesHandler {
	validValue(displayValue) {
		local rawValue := this.convertToRawValue(displayValue)

		return (super.validValue(displayValue) && (Round(rawValue) = rawValue))
	}

	formatValue(value) {
		return Round(value)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DecimalHandler                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DecimalHandler extends DiscreteValuesHandler {
	iPrecision := false

	Precision {
		Get {
			return this.iPrecision
		}
	}

	__New(zero := 0.0, increment := 1.0, precision := 0, minValue := "__Undefined__", maxValue := "__Undefined__") {
		this.iPrecision := precision

		super.__New(zero, increment, minValue, maxValue)
	}

	validValue(displayValue) {
		local rawValue := this.convertToRawValue(displayValue)

		return (super.validValue(displayValue) && (Round(rawValue) = rawValue))
	}

	formatValue(value) {
		return Round(value, this.Precision)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FloatHandler                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FloatHandler extends DecimalHandler {
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ClicksHandler                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClicksHandler extends IntegerHandler {
	__New(minValue := 0, maxValue := "__Undefined__") {
		super.__New(minValue, 1, minValue, maxValue)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupEditor                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetupEditor extends ConfigurationItem {
	iWindow := false

	iWorkbench := false
	iSetup := false

	iComparator := false

	iSettings := CaseInsenseMap()
	iSettingsListView := false

	iClosed := false

	class EditorWindow extends Window {
		iEditor := false

		Editor {
			Get {
				return this.iEditor
			}
		}

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Setup Workbench.Setup Editor", Resizeable: true, Closeable: true}, "Setup Editor")
		}

		Close(*) {
			this.Editor.close()
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	Workbench {
		Get {
			return this.iWorkbench
		}
	}

	Comparator {
		Get {
			return this.iComparator
		}
	}

	SetupClass {
		Get {
			throw "Virtual property FileSetupComparator.SetupClass must be implemented in a subclass..."
		}
	}

	Setup {
		Get {
			return this.iSetup
		}

		Set {
			return (this.iSetup := value)
		}
	}

	Setings[key?] {
		Get {
			return (isSet(key) ? this.iSettings[key] : this.iSettings)
		}

		Set {
			return (isSet(key) ? (this.iSettings[key] := value) : (this.iSettings := value))
		}
	}

	SettingsListView {
		Get {
			return this.iSettingsListView
		}
	}

	__New(workbench, configuration := false) {
		local simulator, car, section, values, key, value, fileName

		this.iWorkbench := workbench

		if !configuration {
			simulator := workbench.SelectedSimulator
			car := workbench.SelectedCar[false]

			configuration := readMultiMap(kResourcesDirectory . "Garage\Definitions\" . simulator . ".ini")

			for section, values in readMultiMap(kResourcesDirectory . "Garage\Definitions\Cars\" . simulator . ".Generic.ini")
				for key, value in values
					setMultiMapValue(configuration, section, key, value)

			if (car != true) {
				fileName := ("Garage\Definitions\Cars\" . simulator . "." . car . ".ini")

				for section, values in readMultiMap(getFileName(fileName, kResourcesDirectory, kUserHomeDirectory))
					for key, value in values
						setMultiMapValue(configuration, section, key, value)
			}
		}

		super.__New(configuration)
	}

	createGui(configuration) {
		local editor := this
		local settingsListView, editorGui

		closeEditor(*) {
			editor.close()
		}

		chooseSetupFile(*) {
			editor.chooseSetup()
		}

		resetSetup(*) {
			editor.resetSetup()
		}

		selectSetting(*) {
			editor.updateState()
		}

		increaseSetting(*) {
			editor.increaseSetting()
		}

		decreaseSetting(*) {
			editor.decreaseSetting()
		}

		compareSetup(*) {
			editor.compareSetup()
		}

		applyRecommendations(*) {
			editor.applyRecommendations(editorGui["applyStrengthSlider"].Value)
		}

		saveModifiedSetup(*) {
			editor.saveSetup()
		}

		editorGui := SetupEditor.EditorWindow(this)

		this.iWindow := editorGui

		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Text", "w784 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Setup Workbench.Setup Editor"))

		editorGui.SetFont("s9 Norm", "Arial")
		editorGui.SetFont("Italic Underline", "Arial")

		editorGui.Add("Text", "x308 YP+20 w184 cBlue Center H:Center", translate("Setup Editor")).OnEvent("Click", openDocumentation.Bind(editorGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#managing-car-setups"))

		editorGui.SetFont("s8 Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w800 0x10 W:Grow Section")

		editorGui.Add("Button", "x16 ys+10 w60", translate("Setup:")).OnEvent("Click", chooseSetupFile)
		editorGui.Add("Text", "x85 ys+14 w193 vsetupNameViewer")
		editorGui.Add("Button", "x280 ys+10 w80 X:Move(0.5) vresetSetupButton", translate("&Reset")).OnEvent("Click", resetSetup)

		this.iSettingsListView := editorGui.Add("ListView", "x16 ys+40 w344 h320 H:Grow W:Grow(0.5) BackgroundD8D8D8 -Multi -LV0x10 Checked AltSubmit NoSort NoSortHdr", collect(["Category", "Setting", "Value", "Unit"], translate))
		this.iSettingsListView.OnEvent("Click", selectSetting)

		editorGui.Add("Button", "x16 yp+324 w80 Disabled Y:Move vdecreaseSettingButton", translate("Decrease")).OnEvent("Click", decreaseSetting)
		editorGui.Add("Button", "x280 yp w80 Y:Move X:Move(0.5) Disabled vincreaseSettingButton", translate("Increase")).OnEvent("Click", increaseSetting)

		editorGui.Add("Button", "x280 yp+29 w80 Y:Move X:Move(0.5)", translate("Compare...")).OnEvent("Click", compareSetup)

		editorGui.Add("Button", "x16 ys+420 w80 Y:Move", translate("&Apply")).OnEvent("Click", applyRecommendations)
		editorGui.Add("Slider", "x100 ys+422 w60 0x10 Y:Move Range20-100 ToolTip vapplyStrengthSlider", 100)
		editorGui.Add("Text", "x162 ys+425 Y:Move", translate("%"))

		editorGui.Add("Button", "x280 ys+420 w80 Y:Move X:Move(0.5)", translate("&Save...")).OnEvent("Click", saveModifiedSetup)

		editorGui.Add("Edit", "x374 ys+10 w423 h433 T8 X:Move(0.5) W:Grow(0.5) H:Grow ReadOnly -Wrap HScroll vsetupViewer")

		/*
		editorGui.Add("Text", "x8 y506 w800 0x10 Y:Move W:Grow")

		editorGui.Add("Button", "x374 y514 w80 h23 Y:Move H:Center", translate("Close")).OnEvent("Click", closeEditor)
		*/
	}

	show() {
		local window := this.Window
		local x, y, w, h

		if getWindowPosition("Setup Workbench.Setup Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Setup Workbench.Setup Editor", &w, &h)
			window.Resize("Initialize", w, h)

		this.loadSetup()
	}

	close() {
		this.destroy()

		if this.Setup {
			this.Workbench.Setup := this.Setup

			this.Setup.Editor := false
		}

		this.iClosed := true
	}

	destroy() {
		if this.Window
			this.Window.Destroy()
	}

	editSetup(setup := false) {
		this.Setup := (setup ? setup.Clone() : Setup())
		this.Setup.Editor := this

		this.createGui(this.Configuration)

		this.show()
	}

	updateState() {
		local setup := this.Setup
		local enabled := []
		local changed := false
		local row, label, sIndex, sEnabled, ignore, setting

		if this.SettingsListView.GetNext(0) {
			this.Control["increaseSettingButton"].Enabled := true
			this.Control["decreaseSettingButton"].Enabled := true
		}
		else {
			this.Control["increaseSettingButton"].Enabled := false
			this.Control["decreaseSettingButton"].Enabled := false
		}

		if setup {
			row := this.SettingsListView.GetNext(0, "C")

			while row {
				label := this.SettingsListView.GetText(row, 2)

				enabled.Push(this.Settings[label])

				row := this.SettingsListView.GetNext(row, "C")
			}

			for ignore, setting in this.Workbench.Settings {
				sIndex := inList(enabled, setting)
				sEnabled := setup.Enabled[setting]

				if (sIndex && !sEnabled) {
					setup.enable(setting)

					changed := true
				}
				else if (!sIndex && sEnabled) {
					setup.disable(setting)

					changed := true
				}
			}

			if changed
				this.Control["setupViewer"].Value := this.Setup.Setup
		}
	}

	createSettingHandler(setting) {
		local handler := getMultiMapValue(this.Configuration, "Setup.Settings.Handler", setting, false)
		local handlerClass

		if (handler && (handler != "")) {
			handler := string2Values("(", SubStr(handler, 1, StrLen(handler) - 1))

			handlerClass := handler[1]

			return %handlerClass%(string2Values(",", handler[2])*)
		}
		else
			throw "Unknown handler encountered in SetupEditor.createSettingHandler..."
	}

	chooseSetup() {
		throw "Virtual method SetupEditor.chooseSetup must be implemented in a subclass..."
	}

	loadSetup(&setup := false) {
		local categories, categoriesLabels, settingsLabels, settingsUnits
		local ignore, setting, handler, modifiedValue, originalValue, value, category, candidate, settings
		local cSetting, label, lastCategory

		if !setup
			setup := this.Setup
		else
			this.Setup := setup

		this.Control["setupNameViewer"].Text := (setup ? setup.Name : "")
		this.Control["setupViewer"].Value := (setup ? setup.Setup : "")

		categories := getMultiMapValues(this.Workbench.Definition, "Setup.Categories")

		categoriesLabels := getMultiMapValues(this.Workbench.Definition, "Setup.Categories.Labels")

		settingsLabels := getMultiMapValues(this.Workbench.Definition, "Setup.Settings.Labels")

		settingsUnits := getMultiMapValues(this.Configuration, "Setup.Settings.Units." . getLanguage())

		if (settingsUnits.Count = 0)
			settingsUnits := getMultiMapValues(this.Configuration, "Setup.Settings.Units.EN")

		this.SettingsListView.Delete()

		this.Settings := CaseInsenseMap()

		setup.disable(false)

		for ignore, setting in this.Workbench.Settings {
			handler := this.createSettingHandler(setting)

			if handler {
				originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
				modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

				if (originalValue = modifiedValue)
					value := displayValue("Float", handler.formatValue(originalValue))
				else if (modifiedValue > originalValue) {
					value := (displayValue("Float", modifiedValue) . A_Space . translate("(") . "+"
							. displayValue("Float", handler.formatValue(Abs(originalValue - modifiedValue))) . translate(")"))

					setup.enable(setting)
				}
				else {
					value := (displayValue("Float", modifiedValue) . A_Space . translate("(") . "-"
							. displayValue("Float", handler.formatValue(Abs(originalValue - modifiedValue))) . translate(")"))

					setup.enable(setting)
				}

				category := ""

				for candidate, settings in categories {
					for ignore, cSetting in string2Values(";", settings)
						if (InStr(setting, cSetting) == 1) {
							category := candidate

							break
						}

					if (category != "")
						break
				}

				label := settingsLabels[setting]

				this.SettingsListView.Add((originalValue = modifiedValue) ? "" : "Check", categoriesLabels[category], label, value, settingsUnits[setting])

				this.Settings[setting] := label
				this.Settings[label] := setting
			}
		}

		this.SettingsListView.ModifyCol()

		this.SettingsListView.ModifyCol(1, "AutoHdr Sort 80")
		this.SettingsListView.ModifyCol(2, "AutoHdr")
		this.SettingsListView.ModifyCol(3, "AutoHdr")
		this.SettingsListView.ModifyCol(4, "AutoHdr")

		lastCategory := ""

		loop this.SettingsListView.GetCount() {
			category := this.SettingsListView.GetText(A_Index)

			if (category = lastCategory)
				this.SettingsListView.Modify(A_Index, "", "")

			lastCategory := category
		}

		this.updateState()
	}

	saveSetup() {
		throw "Virtual method SetupEditor.saveSetup must be implemented in a subclass..."
	}

	increaseSetting(setting := false) {
		local handler, label, row, candidate

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				candidate := this.SettingsListView.GetText(A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := this.SettingsListView.GetNext(0)

		if row {
			label := this.SettingsListView.GetText(row, 2)

			setting := this.Settings[label]
			handler := this.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.increaseValue(handler.convertToDisplayValue(this.Setup.getValue(setting)))))

			this.Control["setupViewer"].Value := (this.Setup ? this.Setup.Setup : "")
		}

		this.updateState()
	}

	decreaseSetting(setting := false) {
		local label, row, candidate, handler

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				candidate := this.SettingsListView.GetText(A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := this.SettingsListView.GetNext(0)

		if row {
			label := this.SettingsListView.GetText(row, 2)

			setting := this.Settings[label]
			handler := this.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.decreaseValue(handler.convertToDisplayValue(this.Setup.getValue(setting)))))

			this.Control["setupViewer"].Value := (this.Setup ? this.Setup.Setup : "")
		}

		this.updateState()
	}

	applyRecommendations(percentage) {
		local knowledgeBase := this.Workbench.KnowledgeBase
		local settings := CaseInsenseMap()
		local theMin := 1
		local ignore, setting, delta, increment

		this.resetSetup()

		for ignore, setting in this.Workbench.Settings {
			delta := knowledgeBase.getValue(setting . ".Delta", kUndefined)

			if (delta != kUndefined)
				if (delta != 0) {
					theMin := Min(Abs(delta), theMin)

					settings[setting] := delta
				}
		}

		for setting, delta in settings {
			increment := Round((delta / theMin) * (percentage / 100))

			if (increment != 0) {
				if getMultiMapValue(this.Configuration, "Setup.Settings", setting . ".Reverse", false)
					increment *= -1

				if (increment < 0) {
					loop Abs(increment)
						this.decreaseSetting(setting)
				}
				else
					loop Abs(increment)
						this.increaseSetting(setting)
			}
		}
	}

	resetSetup() {
		local setup := this.Setup

		this.Setup.reset()

		this.loadSetup(&setup)
	}

	updateSetting(setting, newValue) {
		local setup := this.Setup
		local label := this.Settings[setting]
		local row := false
		local candidate, handler, originalValue, modifiedValue, value

		setup.setValue(setting, newValue)

		loop {
			candidate := this.SettingsListView.GetText(A_Index, 2)

			if (label = candidate) {
				row := A_Index

				break
			}
		}

		handler := this.createSettingHandler(setting)
		originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
		modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

		if (originalValue = modifiedValue) {
			value := displayValue("Float", handler.formatValue(originalValue))

			setup.disable(setting)
		}
		else if (modifiedValue > originalValue) {
			value := (displayValue("Float", modifiedValue) . A_Space . translate("(") . "+"
					. displayValue("Float", handler.formatValue(Abs(originalValue - modifiedValue))) . translate(")"))

			setup.enable(setting)
		}
		else {
			value := (displayValue("Float", modifiedValue) . A_Space . translate("(") . "-"
					. displayValue("Float", handler.formatValue(Abs(originalValue - modifiedValue))) . translate(")"))

			setup.enable(setting)
		}

		this.SettingsListView.Modify(row, "Vis Col3", value)
		this.SettingsListView.Modify(row, (originalValue = modifiedValue) ? "-Check" : "Check")
		this.SettingsListView.ModifyCol(3, "AutoHdr")
	}

	compareSetup() {
		local comparatorClass := getMultiMapValue(this.Configuration, "Setup", "Comparator", false)
		local comparator, newSetup

		if comparatorClass {
			comparator := %comparatorClass%(this)

			this.iComparator := comparator

			this.Window.Opt("+Disabled")

			try {
				newSetup := comparator.compareSetup()

				if newSetup
					this.loadSetup(&newSetup)
			}
			finally {
				this.iComparator := false

				this.Window.Opt("-Disabled")
			}
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupComparator                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetupComparator extends ConfigurationItem {
	iWindow := false

	iEditor := false

	iSetupA := false
	iSetupB := false
	iSetupAB := false

	iSettingsListView := false

	iSettings := CaseInsenseMap()

	iClosed := false

	class ComparatorWindow extends Window {
		iComparator := false

		Comparator {
			Get {
				return this.iComparator
			}
		}

		__New(comparator) {
			this.iComparator := comparator

			super.__New({Descriptor: "Setup Workbench.Setup Comparator", Resizeable: true, Closeable: true, Options: "-MaximizeBox"}, "")
		}

		Close(*) {
			this.Comparator.close()
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	Workbench {
		Get {
			return this.Editor.Workbench
		}
	}

	Editor {
		Get {
			return this.iEditor
		}
	}

	SetupClass {
		Get {
			return this.Editor.SetupClass
		}
	}

	SetupA {
		Get {
			return this.iSetupA
		}

		Set {
			return (this.iSetupA := value)
		}
	}

	SetupB {
		Get {
			return this.iSetupB
		}

		Set {
			return (this.iSetupB := value)
		}
	}

	SetupAB {
		Get {
			return this.iSetupAB
		}

		Set {
			return (this.iSetupAB := value)
		}
	}

	Setings[key?] {
		Get {
			return (isSet(key) ? this.iSettings[key] : this.iSettings)
		}

		Set {
			return (isSet(key) ? (this.iSettings[key] := value) : (this.iSettings := value))
		}
	}

	SettingsListView {
		Get {
			return this.iSettingsListView
		}
	}

	__New(editor, configuration := false) {
		local workbench, simulator, car, section, values, key, value, fileName

		this.iEditor := editor
		this.iSetupA := editor.Setup

		if !configuration {
			workbench := this.Workbench

			simulator := workbench.SelectedSimulator
			car := workbench.SelectedCar[false]

			configuration := readMultiMap(kResourcesDirectory . "Garage\Definitions\" . simulator . ".ini")

			for section, values in readMultiMap(kResourcesDirectory . "Garage\Definitions\Cars\" . simulator . ".Generic.ini")
				for key, value in values
					setMultiMapValue(configuration, section, key, value)

			if (car != true) {
				fileName := ("Garage\Definitions\Cars\" . simulator . "." . car . ".ini")

				for section, values in readMultiMap(getFileName(fileName, kResourcesDirectory, kUserHomeDirectory))
					for key, value in values
						setMultiMapValue(configuration, section, key, value)
			}
		}

		super.__New(configuration)
	}

	createGui(configuration) {
		local comparator := this
		local settingsListView, comparatorGui

		applyComparator(*) {
			comparator.close(true)
		}

		closeComparator(*) {
			comparator.close()
		}

		chooseSetupAFile(*) {
			comparator.chooseSetup("A")
		}

		chooseSetupBFile(*) {
			comparator.chooseSetup("B")
		}

		selectABSetting(*) {
			comparator.updateState()
		}

		increaseABSetting(*) {
			comparator.increaseSetting()
		}

		decreaseABSetting(*) {
			comparator.decreaseSetting()
		}

		mixSetups(*) {
			local ignore1 := false
			local ignore2 := false

			comparator.loadSetups(&ignore1, &ignore2, comparatorGui["applyMixSlider"].Value)
		}

		comparatorGui := SetupComparator.ComparatorWindow(this)

		this.iWindow := comparatorGui

		comparatorGui.SetFont("s10 Bold", "Arial")

		comparatorGui.Add("Text", "w784 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(comparatorGui, "Setup Workbench.Setup Comparator"))

		comparatorGui.SetFont("s9 Norm", "Arial")
		comparatorGui.SetFont("Italic Underline", "Arial")

		comparatorGui.Add("Text", "x308 YP+20 w184 cBlue Center H:Center", translate("Setup Comparator")).OnEvent("Click", openDocumentation.Bind(comparatorGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#comparing-car-setups"))

		comparatorGui.SetFont("s8 Norm", "Arial")

		comparatorGui.Add("Text", "x8 yp+30 w800 0x10 W:Grow Section")

		comparatorGui.Add("Button", "x16 ys+10 w60", translate("Setup A:")).OnEvent("Click", chooseSetupAFile)
		comparatorGui.Add("Text", "x85 ys+14 w193 vsetupNameAViewer")
		comparatorGui.Add("Button", "x16 ys+34 w60", translate("Setup B:")).OnEvent("Click", chooseSetupBFile)
		comparatorGui.Add("Text", "x85 ys+38 w193 vsetupNameBViewer")

		this.iSettingsListView := comparatorGui.Add("ListView", "x16 ys+64 w784 h350 W:Grow H:Grow BackgroundD8D8D8 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Category", "Setting", "Value (A)", "Value (B)", "Value (A/B)", "Unit"], translate))
		this.iSettingsListView.OnEvent("Click", selectABSetting)

		comparatorGui.Add("Button", "x16 yp+354 w80 Disabled Y:Move vdecreaseABSettingButton", translate("Decrease")).OnEvent("Click", decreaseABSetting)
		comparatorGui.Add("Button", "x720 yp w80 Disabled X:Move Y:Move vincreaseABSettingButton", translate("Increase")).OnEvent("Click", increaseABSetting)

		comparatorGui.Add("Slider", "x316 yp w200 0x10 Range-100-100 Y:Move X:Move(0.5) ToolTip vapplyMixSlider", 0).OnEvent("Change", mixSetups)
		comparatorGui.Add("Text", "x251 yp+3 w50 Y:Move X:Move(0.5) ", translate("Setup A"))
		comparatorGui.Add("Text", "x529 yp w50 X:Move(0.5) Y:Move", translate("Setup B"))

		comparatorGui.Add("Text", "x8 y506 w800 0x10 Y:Move W:Grow")

		comparatorGui.Add("Button", "x322 y514 w80 h23 Y:Move X:Move(0.5)", translate("&Apply")).OnEvent("Click", applyComparator)
		comparatorGui.Add("Button", "x426 y514 w80 h23 Default Y:Move X:Move(0.5)", translate("Close")).OnEvent("Click", closeComparator)
	}

	show() {
		local window := this.Window
		local x, y, w, h

		if getWindowPosition("Setup Workbench.Setup Comparator", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Setup Workbench.Setup Comparator", &w, &h)
			window.Resize("Initialize", w, h)

		this.loadSetups()
	}

	close(apply := false) {
		this.iClosed := (apply ? "Apply" : "Close")
	}

	destroy() {
		if this.Window
			this.Window.Destroy()
	}

	loadSetups(&setupA := false, &setupB := false, mix := 0) {
		local setupClass, setupAB, categories, categoriesLabels, settingsLabels, settingsUnits
		local ignore, setting, handler, valueA, valueB, category, candidate, settings, cSetting
		local targetAB, valueAB, lastValueAB, delta, label, lastCategory

		if !setupA
			setupA := this.SetupA
		else
			this.SetupA := setupA

		if !setupB
			setupB := this.SetupB
		else
			this.SetupB := setupB

		this.Control["setupNameAViewer"].Text := (setupA ? setupA.Name : "")
		this.Control["setupNameBViewer"].Text := (setupB ? setupB.Name : "")

		setupClass := this.SetupClass

		setupAB := %setupClass%(this.Editor, setupA.getInitializationArguments()*)

		setupAB.Setup[false] := setupA.Setup[false]

		this.SetupAB := setupAB

		categories := getMultiMapValues(this.Workbench.Definition, "Setup.Categories")

		categoriesLabels := getMultiMapValues(this.Workbench.Definition, "Setup.Categories.Labels")

		settingsLabels := getMultiMapValues(this.Workbench.Definition, "Setup.Settings.Labels")

		settingsUnits := getMultiMapValues(this.Configuration, "Setup.Settings.Units." . getLanguage())

		if (settingsUnits.Count = 0)
			settingsUnits := getMultiMapValues(this.Configuration, "Setup.Settings.Units.EN")

		this.SettingsListView.Delete()

		this.Settings := CaseInsenseMap()

		for ignore, setting in this.Workbench.Settings {
			handler := this.Editor.createSettingHandler(setting)

			if handler {
				valueA := handler.convertToDisplayValue(setupA.getValue(setting, false))
				valueB := handler.convertToDisplayValue(setupB.getValue(setting, true))

				category := ""

				for candidate, settings in categories {
					for ignore, cSetting in string2Values(";", settings)
						if (InStr(setting, cSetting) == 1) {
							category := candidate

							break
						}

					if (category != "")
						break
				}

				targetAB := ((valueA * (((mix * -1) + 100) / 200)) + (valueB * (mix + 100) / 200))
				valueAB := ((valueA < valueB) ? valueA : valueB)
				lastValueAB := kUndefined

				loop {
					if (valueAB >= targetAB) {
						if (lastValueAB != kUndefined) {
							delta := (valueAB - lastValueAB)

							if ((lastValueAB + (delta / 2)) > targetAB)
								valueAB := lastValueAB
						}

						break
					}
					else {
						lastValueAB := valueAB

						valueAB := handler.increaseValue(valueAB)

						if (valueAB = lastValueAB)
							break
					}
				}

				setupAB.setValue(setting, handler.convertToRawValue(valueAB))

				valueAB := handler.formatValue(valueAB)

				if (valueB > valueA)
					valueB := (displayValue("Float", valueB) . A_Space . translate("(") . "+"
							 . displayValue("Float", handler.formatValue(Abs(valueA - valueB))) . translate(")"))
				else if (valueB < valueA)
					valueB := (displayValue("Float", valueB) . A_Space . translate("(") . "-"
							 . displayValue("Float", handler.formatValue(Abs(valueA - valueB))) . translate(")"))
				else
					valueB := displayValue("Float", valueB)

				if (valueAB > valueA)
					valueAB := (displayValue("Float", valueAB) . A_Space . translate("(") . "+"
							  . displayValue("Float", handler.formatValue(Abs(valueA - valueAB))) . translate(")"))
				else if (valueAB < valueA)
					valueAB := (displayValue("Float", valueAB) . A_Space . translate("(") . "-"
							  . displayValue("Float", handler.formatValue(Abs(valueA - valueAB))) . translate(")"))
				else
					valueAB := displayValue("Float", valueAB)

				label := settingsLabels[setting]

				this.SettingsListView.Add("", categoriesLabels[category], settingsLabels[setting], displayValue("Float", valueA), valueB, valueAB, settingsUnits[setting])

				this.Settings[setting] := label
				this.Settings[label] := setting
			}
		}

		this.SettingsListView.ModifyCol()

		this.SettingsListView.ModifyCol(1, "AutoHdr Sort")
		this.SettingsListView.ModifyCol(2, "AutoHdr")
		this.SettingsListView.ModifyCol(3, "AutoHdr")
		this.SettingsListView.ModifyCol(4, "AutoHdr")
		this.SettingsListView.ModifyCol(5, "AutoHdr")

		lastCategory := ""

		loop this.SettingsListView.GetCount() {
			category := this.SettingsListView.GetText(A_Index)

			if (category = lastCategory)
				this.SettingsListView.Modify(A_Index, "", "")

			lastCategory := category
		}

		this.updateState()
	}

	compareSetup(setup := false) {
		this.SetupB := (setup ? setup : Setup())

		this.createGui(this.Configuration)

		this.show()

		try {
			while !this.iClosed
				Sleep(200)
		}
		finally {
			this.destroy()
		}

		return ((this.iClosed = "Apply") ? this.SetupAB : false)
	}

	updateSetting(setting, newValue) {
		local setup := this.SetupAB
		local label, row, candidate, handler, originalValue, modifiedValue, value

		setup.setValue(setting, newValue)

		label := this.Settings[setting]
		row := false

		loop {
			candidate := this.SettingsListView.GetText(A_Index, 2)

			if (label = candidate) {
				row := A_Index

				break
			}
		}

		handler := this.Editor.createSettingHandler(setting)
		originalValue := handler.convertToDisplayValue(this.SetupA.getValue(setting, false))
		modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

		if (originalValue = modifiedValue)
			value := displayValue("Float", handler.formatValue(originalValue))
		else if (modifiedValue > originalValue)
			value := (displayValue("Float", modifiedValue) . A_Space . translate("(") . "+"
					. displayValue("Float", handler.formatValue(Abs(originalValue - modifiedValue))) . translate(")"))
		else
			value := (displayValue("Float", modifiedValue) . A_Space . translate("(") . "-"
					. displayValue("Float", handler.formatValue(Abs(originalValue - modifiedValue))) . translate(")"))

		this.SettingsListView.Modify(row, "Vis Col5", value)
		this.SettingsListView.ModifyCol(5, "AutoHdr")
	}

	increaseSetting(setting := false) {
		local row, candidate, label, handler

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				candidate := this.SettingsListView.GetText(A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := this.SettingsListView.GetNext(0)

		if row {
			label := this.SettingsListView.GetText(row, 2)

			setting := this.Settings[label]
			handler := this.Editor.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.increaseValue(handler.convertToDisplayValue(this.SetupAB.getValue(setting)))))
		}

		this.updateState()
	}

	decreaseSetting(setting := false) {
		local label, row, candidate, handler

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				candidate := this.SettingsListView.GetText(A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := this.SettingsListView.GetNext(0)

		if row {
			label := this.SettingsListView.GetText(row, 2)

			setting := this.Settings[label]
			handler := this.Editor.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.decreaseValue(handler.convertToDisplayValue(this.SetupAB.getValue(setting)))))
		}

		this.updateState()
	}

	updateState() {
		if this.SettingsListView.GetNext(0) {
			this.Control["increaseABSettingButton"].Enabled := true
			this.Control["decreaseABSettingButton"].Enabled := true
		}
		else {
			this.Control["increaseABSettingButton"].Enabled := false
			this.Control["decreaseABSettingButton"].Enabled := false
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FileSetupEditor                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FileSetupEditor extends SetupEditor {
	editSetup(theSetup := false) {
		if !theSetup
			theSetup := this.chooseSetup(false)

		if theSetup
			return super.editSetup(theSetup)
		else {
			this.destroy()

			return false
		}
	}

	chooseSetup(load := true) {
		throw "Virtual method FileSetupEditor.chooseSetup must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FileSetupComparator                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FileSetupComparator extends SetupComparator {
	chooseSetup(type, load := true) {
		throw "Virtual method FileSetupComparator.chooseSetup must be implemented in a subclass..."
	}

	compareSetup(theSetup := false) {
		if !theSetup
			theSetup := this.chooseSetup("B", false)

		if theSetup
			return super.compareSetup(theSetup)
		else {
			this.destroy()

			return false
		}
	}

	loadSetups(&setupA := false, &setupB := false, mix := 0) {
		super.loadSetups(&setupA, &setupB, mix)

		if this.SetupAB
			this.SetupAB.FileName[false] := setupA.FileName[false]
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

closeSetupWorkbench(*) {
	if GetKeyState("Ctrl", "P")
		SetupWorkbench.Instance.saveState()

	ExitApp(0)
}

factPath(path*) {
	local result := ""

	loop path.Length
		result .= ((StrLen(result) > 0) ? ("." . path[A_Index]) : path[A_Index])

	return result
}

runSetupWorkbench() {
	local icon := kIconsDirectory . "Setup.ico"
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getMultiMapValue(settings, "Setup Workbench", "Simulator", false)
	local car := getMultiMapValue(settings, "Setup Workbench", "Car", false)
	local track := getMultiMapValue(settings, "Setup Workbench", "Track", false)
	local weather := false
	local index := 1
	local workbench, label

	TraySetIcon(icon, "1")
	A_IconTip := "Setup Workbench"

	while (index < A_Args.Length) {
		switch A_Args[index], false {
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
			default:
				index += 1
		}
	}

	fixIE(11)

	if car
		car := SessionDatabase.getCarName(simulator, car)

	workbench := SetupWorkbench(simulator, car, track, weather)

	SupportMenu.Insert("1&")

	label := translate("Debug Rule System")

	SupportMenu.Insert("1&", label, ObjBindMethod(workbench, "toggleDebug", kDebugRules))

	if workbench.Debug[kDebugRules]
		SupportMenu.Check(label)

	label := translate("Debug Knowledgebase")

	SupportMenu.Insert("1&", label, ObjBindMethod(workbench, "toggleDebug", kDebugKnowledgeBase))

	if workbench.Debug[kDebugKnowledgebase]
		SupportMenu.Check(label)

	workbench.createGui(workbench.Configuration)

	workbench.show()

	if !GetKeyState("Ctrl", "P")
		if simulator {
			workbench.loadSimulator(simulator, true)

			if inList(workbench.AvailableCars, car)
				workbench.loadCar(car)

			if track
				workbench.loadTrack(track)

			if weather
				workbench.loadWeather(weather)
		}
		else
			workbench.loadSimulator(true, true)
	else
		Task.startTask(ObjBindMethod(workbench, "restoreState"), 100)

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                          Editor Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\GenericTelemetryAnalyzer.ahk"
#Include "Libraries\IRCTelemetryAnalyzer.ahk"
#Include "Libraries\R3ETelemetryAnalyzer.ahk"
#Include "Libraries\ACCSetupEditor.ahk"
#Include "Libraries\ACSetupEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

runSetupWorkbench()