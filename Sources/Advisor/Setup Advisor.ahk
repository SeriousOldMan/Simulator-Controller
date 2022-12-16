;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Advisor                   ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Setup.ico
;@Ahk2Exe-ExeName Setup Advisor.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Math.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


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

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown

global editSetupButton

global settingsViewer

global characteristicsButton

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupAdvisor                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetupAdvisor extends ConfigurationItem {
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
	iSelectedCharacteristicsWidgets := {}

	iEditor := false
	iSetup := false

	iKnowledgeBase := false

	Window[] {
		Get {
			return "Advisor"
		}
	}

	ProgressCount[] {
		Get {
			return this.iProgressCount
		}

		Set {
			return (this.iProgressCount := value)
		}
	}

	SettingsViewer[] {
		Get {
			return settingsViewer
		}
	}

	Definition[] {
		Get {
			return this.iDefinition
		}
	}

	SimulatorDefinition[] {
		Get {
			return this.iSimulatorDefinition
		}
	}

	SimulatorSettings[] {
		Get {
			return this.iSimulatorSettings
		}
	}

	Characteristics[] {
		Get {
			return this.iCharacteristics
		}
	}

	Settings[] {
		Get {
			return this.iSettings
		}
	}

	CharacteristicsArea[] {
		Get {
			return this.iCharacteristicsArea
		}
	}

	SelectedCharacteristics[key := false] {
		Get {
			return (key ? this.iSelectedCharacteristics[key] : this.iSelectedCharacteristics)
		}
	}

	SelectedCharacteristicsWidgets[key := false] {
		Get {
			return (key ? this.iCharacteristicsWidgets[key] : this.iCharacteristicsWidgets)
		}

		Set {
			return (key ? (this.iCharacteristicsWidgets[key] := value) : (this.iCharacteristicsWidgets := value))
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

	SelectedWeather[] {
		Get {
			return this.iSelectedWeather
		}
	}

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	Setup[] {
		Get {
			return this.iSetup
		}
	}

	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}

	__New(simulator := false, car := false, track := false, weather := false) {
		local found := false
		local definition, section, values, key, value, ignore, rootDirectory

		this.iDebug := (isDebug() ? (kDebugKnowledgeBase + kDebugRules) : kDebugOff)

		if simulator {
			this.iSelectedSimulator := simulator
			this.iSelectedCar := car
			this.iSelectedTrack := track
			this.iSelectedWeather := weather
		}

		definition := readConfiguration(kResourcesDirectory . "Advisor\Setup Advisor.ini")

		for ignore, rootDirectory in [kTranslationsDirectory, kUserTranslationsDirectory]
			if FileExist(rootDirectory . "Setup Advisor." . getLanguage()) {
				found := true

				for section, values in readConfiguration(rootDirectory . "Setup Advisor." . getLanguage())
					for key, value in values
						setConfigurationValue(definition, section, key, value)
			}

		if !found
			for section, values in readConfiguration(kTranslationsDirectory . "Setup Advisor.en")
				for key, value in values
					setConfigurationValue(definition, section, key, value)

		this.iDefinition := definition

		base.__New(kSimulatorConfiguration)

		SetupAdvisor.Instance := this
	}

	createGui(configuration) {
		local window := this.Window
		local simulators, simulator, weather, choices, chosen, index, name

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1184 Center gmoveAdvisor, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x508 YP+20 w184 cBlue Center gopenAdvisorDocumentation, % translate("Setup Advisor")

		Gui %window%:Add, Text, x8 yp+30 w1200 0x10 Section

		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x16 yp+12 w30 h30, %kIconsDirectory%Road.ico
		Gui %window%:Add, Text, x50 yp+5 w120 h26, % translate("Selection")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, Text, x16 yp+32 w80 h23 +0x200, % translate("Simulator")

		simulators := this.getSimulators()
		simulator := 0

		if (simulators.Length() > 0) {
			if this.SelectedSimulator
				simulator := inList(simulators, this.SelectedSimulator)

			if (simulator == 0)
				simulator := inList(simulators, true)
		}

		for index, name in simulators
			if (name == true)
				simulators[index] := translate("Generic")

		Gui %window%:Add, DropDownList, x100 yp w196 Choose%simulator% vsimulatorDropDown gchooseSimulator, % values2String("|", simulators*)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		Gui %window%:Add, Text, x16 yp+24 w80 h23 +0x200, % translate("Car")
		Gui %window%:Add, DropDownList, x100 yp w196 Choose1 vcarDropDown gchooseCar, % translate("All")
		Gui %window%:Add, Text, x16 yp+24 w80 h23 +0x200, % translate("Track")
		Gui %window%:Add, DropDownList, x100 yp w196 Choose1 vtrackDropDown gchooseTrack, % translate("All")

		Gui %window%:Add, Text, x16 yp+24 w80 h23 +0x200, % translate("Conditions")

		weather := this.SelectedWeather
		choices := map(kWeatherConditions, "translate")
		chosen := inList(kWeatherConditions, weather)

		if (!chosen && (choices.Length() > 0)) {
			weather := choices[1]
			chosen := 1
		}

		Gui %window%:Add, DropDownList, x100 yp w196 AltSubmit Disabled Choose%chosen% gchooseWeather vweatherDropDown, % values2String("|", choices*)

		Gui %window%:Add, Button, x305 ys+49 w94 h94 Disabled HWNDsetupButton veditSetupButton geditSetup
		setButtonIcon(setupButton, kIconsDirectory . "Car Setup.ico", 1, "W64 H64")

		Gui %window%:Add, Text, x8 yp+103 w400 0x10

		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x16 yp+12 w30 h30, %kIconsDirectory%Report.ico
		Gui %window%:Add, Text, x50 yp+5 w180 h26, % translate("Characteristics")

		Gui %window%:Font, s8 Norm
		Gui %window%:Add, GroupBox, x16 yp+30 w382 h469 -Theme

		this.iCharacteristicsArea := {X: 16, Y: 262, Width: 382, W: 482, Height: 439, H: 439}

		Gui %window%:Add, Button, x328 yp-24 w70 h23 vcharacteristicsButton gchooseCharacteristic, % translate("Problem...")

		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x420 ys+12 w30 h30, %kIconsDirectory%Assistant.ico
		Gui %window%:Add, Text, x454 yp+5 w150 h26, % translate("Recommendations")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, ActiveX, x420 yp+30 w775 h621 Border vsettingsViewer, shell.explorer

		settingsViewer.Navigate("about:blank")

		this.showSettingsChart(false)

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x8 y730 w1200 0x10

		Gui %window%:Add, Button, x16 y738 w77 h23 gloadSetup, % translate("&Load...")
		Gui %window%:Add, Button, x98 y738 w77 h23 gsaveSetup, % translate("&Save...")

		Gui %window%:Add, Button, x574 y738 w80 h23 GcloseAdvisor, % translate("Close")
	}

	saveState(fileName := false) {
		local state, window, ignore, characteristic, widgets, value1, value2

		if !fileName
			fileName := (kUserConfigDirectory . "Advisor.setup")

		state := this.SimulatorDefinition.Clone()

		setConfigurationValue(state, "State", "Simulator", this.SelectedSimulator["*"])
		setConfigurationValue(state, "State", "Car", this.SelectedCar["*"])
		setConfigurationValue(state, "State", "Track", this.SelectedTrack["*"])
		setConfigurationValue(state, "State", "Weather", this.SelectedWeather)

		setConfigurationValue(state, "State", "Characteristics", values2String(",", this.Characteristics*))
		setConfigurationValue(state, "State", "Settings", values2String(",", this.Settings*))

		setConfigurationValue(state, "Characteristics", "Characteristics", values2String(",", this.SelectedCharacteristics*))

		window := this.Window

		Gui %window%:Default

		for ignore, characteristic in this.SelectedCharacteristics {
			widgets := this.SelectedCharacteristicsWidgets[characteristic]

			GuiControlGet value1, , % widgets[1]
			GuiControlGet value2, , % widgets[2]

			setConfigurationValue(state, "Characteristics", characteristic . ".Weight", value1)
			setConfigurationValue(state, "Characteristics", characteristic . ".Value", value2)
		}

		setConfigurationSectionValues(state, "KnowledgeBase", this.KnowledgeBase.Facts.Facts)

		writeConfiguration(fileName, state)
	}

	restoreState(fileName := false) {
		local state, simulator, car, track, weather, characteristicLabels, characteristics, window
		local ignore, characteristic

		if !fileName
			fileName := (kUserConfigDirectory . "Advisor.setup")

		if FileExist(fileName) {
			state := readConfiguration(fileName)

			simulator := getConfigurationValue(state, "State", "Simulator")
			car := getConfigurationValue(state, "State", "Car")
			track := getConfigurationValue(state, "State", "Track")
			weather := getConfigurationValue(state, "State", "Weather")

			if (simulator = "*")
				simulator := true

			if (car = "*")
				car := true

			if (track = "*")
				track := true

			this.loadSimulator(simulator, true)
			this.loadCar(car)
			this.loadTrack(track)
			this.loadWeather(weather)

			characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels")

			characteristics := string2Values(",", getConfigurationValue(state, "Characteristics", "Characteristics"))

			if (characteristics.Length() > 0) {
				window := this.Window

				Gui %window%:Default
				Gui %window%:+Disabled

				try {
					this.ProgressCount := 0

					showProgress({color: "Green", width: 350, title: translate("Loading Problems"), message: translate("Preparing Characteristics...")})

					Sleep 200

					for ignore, characteristic in characteristics {
						showProgress({progress: (this.ProgressCount += 10), message: translate("Load ") . characteristicLabels[characteristic] . translate("...")})

						this.addCharacteristic(characteristic, getConfigurationValue(state, "Characteristics", characteristic . ".Weight")
															 , getConfigurationValue(state, "Characteristics", characteristic . ".Value")
															 , false)
					}

					this.updateRecommendations()

					this.updateState()

					showProgress({progress: 100, message: translate("Finished...")})

					Sleep 500

					hideProgress()
				}
				finally {
					Gui %window%:-Disabled
				}
			}
		}
		else
			this.loadSimulator(true, true)

		return false
	}

	show() {
		local window := this.Window
		local x, y

		if getWindowPosition("Setup Advisor", x, y)
			Gui %window%:Show, x%x% y%y%
		else
			Gui %window%:Show
	}

	showSettingsChart(content) {
		local isChart, window, before, after, width, height, info, html, index, message, iWidth, iHeight

		if !content
			content := [translate("Please describe your car handling problems.")]

		isChart := !IsObject(content)

		if this.SettingsViewer {
			window := this.Window

			Gui %window%:Default

			this.SettingsViewer.Document.open()

			if (content && (content != "")) {
				if isChart {
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
								google.charts.load('current', {'packages':['corechart', 'table', 'bar']}).then(drawChart);
					)

					width := this.SettingsViewer.Width
					height := (this.SettingsViewer.Height - 110 - 1)

					info := getConfigurationValue(this.Definition, "Setup.Info", "ChangeWarning", "")

					iWidth := width - 10
					iHeight := 90

					after =
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
					)

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


					html =
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
					)

					this.SettingsViewer.Document.write(html)
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
		local drawChartFunction, names, values, ignore, setting, max, index, value

		this.showSettingsChart(false)

		if settings {
			if (settings.Length() > 0) {
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

				max := Max(Abs(maximum(values)), Abs(minimum(values)))

				for index, value in values
					values[index] := (value / max)

				if false {
					drawChartFunction .= "`n['" . translate("Setting") . "', '" . translate("Value") . "',  { role: 'annotation' }]"

					loop % names.Length()
						drawChartFunction .= ",`n['" . names[A_Index] . "', " . values[A_Index] . ", '" . names[A_Index] . "']"

					drawChartFunction .= "`n]);"

					drawChartFunction := drawChartFunction . "`nvar options = { legend: 'none', vAxis: { textPosition: 'none', baseline: 'none' }, bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '5%', top: '5%', right: '5%', bottom: '5%' } };"
				}
				else {
					drawChartFunction .= "`n['" . values2String("', '", names*) . "'],"

					drawChartFunction .= "`n[" . values2String(",", values*) . "]"

					drawChartFunction .= "`n]);"

					drawChartFunction := drawChartFunction . "`nvar options = { bar: { groupWidth: " . (settings.Length() * 16) . " }, vAxis: { textPosition: 'none', baseline: 'none' }, hAxis: {maxValue: 1, minValue: -1}, bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '5%', top: '5%', right: '40%', bottom: '5%' } };"
				}

				drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction := [translate("I can't help you with that."), translate("You are on your own this time.")]

			this.showSettingsChart(drawChartFunction)
		}
	}

	setDebug(option, enabled) {
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
				Menu SupportMenu, Check, %label%
			else
				Menu SupportMenu, Uncheck, %label%
	}

	toggleDebug(option) {
		this.setDebug(option, !this.Debug[option])
	}

	getSimulators() {
		local simulators := []
		local hasGeneric := false
		local simulator

		loop Files, %kResourcesDirectory%Advisor\Definitions\*.ini, F
		{
			SplitPath A_LoopFileName, , , , simulator

			if (simulator = "Generic")
				hasGeneric := true
			else if !inList(simulators, simulator)
				simulators.Push(simulator)
		}

		loop Files, %kUserHomeDirectory%Advisor\Definitions\*.ini, F
		{
			SplitPath A_LoopFileName, , , , simulator

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
		local sessionDB, ignore, car, descriptor

		if ((simulator != true) && (simulator != "*")) {
			loop Files, %kResourcesDirectory%Advisor\Definitions\Cars\%simulator%.*.ini, F
			{
				SplitPath A_LoopFileName, , , , descriptor

				car := StrReplace(StrReplace(descriptor, simulator . ".", ""), ".ini", "")

				if ((car != "Generic") && !inList(cars, car))
					cars.Push(car)
			}

			loop Files, %kUserHomeDirectory%Advisor\Definitions\Cars\*.ini, F
			{
				SplitPath A_LoopFileName, , , , descriptor

				car := StrReplace(StrReplace(descriptor, simulator . ".", ""), ".ini", "")

				if ((car != "Generic") && !inList(cars, car))
					cars.Push(car)
			}

			if (this.SimulatorDefinition && (getConfigurationValue(this.SimulatorDefinition, "Simulator", "Cars", false) = "*")) {
				sessionDB := new SessionDatabase()

				for ignore, car in sessionDB.getCars(simulator) {
					car := sessionDB.getCarName(simulator, car)

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
			tracks := new SessionDatabase().getTracks(simulator, car)

		tracks.InsertAt(1, "*")

		return tracks
	}

	getTrackName(simulator, track) {
		if ((track = "*") || (track == true))
			return translate("All")
		else
			return new SessionDatabase().getTrackName(simulator, track)
	}

	dumpKnowledgeBase(knowledgeBase) {
		knowledgeBase.dumpFacts()
	}

	dumpRules(knowledgeBase) {
		knowledgeBase.dumpRules()
	}

	updateState() {
		local window := this.Window

		Gui %window%:Default

		if (this.SelectedCharacteristics.Length() < kMaxCharacteristics)
			GuiControl Enable, characteristicsButton
		else
			GuiControl Disable, characteristicsButton

		if (this.SimulatorDefinition && getConfigurationValue(this.SimulatorDefinition, "Setup", "Editor", false))
			GuiControl Enable, editSetupButton
		else
			GuiControl Disable, editSetupButton

	}

	compileRules(fileName, ByRef productions, ByRef reductions) {
		local rules

		if (fileName && (fileName != "") && FileExist(fileName)) {
			FileRead rules, %fileName%

			new RuleCompiler().compileRules(rules, productions, reductions)
		}
	}

	loadRules(ByRef productions, ByRef reductions) {
		local rules, compiler, simulator, car

		FileRead rules, % kResourcesDirectory . "Advisor\Rules\Setup Advisor.rules"

		productions := false
		reductions := false

		compiler := new RuleCompiler()

		compiler.compileRules(rules, productions, reductions)

		simulator := this.SelectedSimulator
		car := this.SelectedCar[false]

		this.compileRules(getFileName("Advisor\Rules\" . simulator . ".rules", kResourcesDirectory, kUserHomeDirectory), productions, reductions)
		this.compileRules(getFileName("Advisor\Rules\Cars\" . simulator . ".Generic.rules", kResourcesDirectory, kUserHomeDirectory), productions, reductions)

		if (car != true)
			this.compileRules(getFileName("Advisor\Rules\Cars\" . simulator . "." . car . ".rules", kResourcesDirectory, kUserHomeDirectory), productions, reductions)
	}

	loadCharacteristics(definition, simulator := false, car := false, track := false, fast := false) {
		local knowledgeBase := this.KnowledgeBase
		local characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels")
		local compiler, group, ignore, groupOption, option, characteristic

		this.iCharacteristics := []

		if !simulator
			knowledgeBase.addFact("Characteristics.Count", 0)

		compiler := new RuleCompiler()

		for group, definition in getConfigurationSectionValues(definition, "Setup.Characteristics")
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
								Sleep 25
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
							Sleep 25
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
		local settingsLabels := getConfigurationSectionValues(this.Definition, "Setup.Settings.Labels")
		local compiler, group, ignore, groupOption, option, setting

		this.iSettings := []

		if !simulator
			knowledgeBase.addFact("Settings.Count", 0)

		compiler := new RuleCompiler()

		for group, definition in getConfigurationSectionValues(definition, "Setup.Settings")
			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)

					for ignore, option in string2Values(",", groupOption[2]) {
						setting := factPath(group, groupOption[1], option)

						if !simulator {
							showProgress({progress: ++this.ProgressCount, message: translate("Initializing Setting ")
																				 . settingsLabels[setting]
																				 . translate("...")})

							knowledgeBase.prove(compiler.compileGoal("addSetting(" . setting . ")")).dispose()

							this.Settings.Push(setting)

							if (!fast && !isDebug())
								Sleep 25
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
							Sleep 25
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

	createKnowledgeBase(facts, productions, reductions) {
		local engine := new RuleEngine(productions, reductions, facts)

		return new KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}

	initializeSimulator(name) {
		local definition := readConfiguration(kResourcesDirectory . "Advisor\Definitions\" . name . ".ini")
		local simulator := getConfigurationValue(definition, "Simulator", "Simulator")
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

	initializeAdvisor(phase1 := "Initializing Setup Advisor", phase2 := "Starting Setup Advisor", phase3 := "Loading Car", fast := false) {
		local knowledgeBase, simulator, x, y, productions, reductions

		simulator := this.SelectedSimulator

		this.ProgressCount := 0

		showProgress({color: "Blue", width: 350, title: translate(phase1), message: translate("Clearing Problems...")})

		Sleep 200

		this.clearCharacteristics()

		showProgress({progress: this.ProgressCount++, message: translate("Preparing Knowledgebase...")})

		Sleep 200

		productions := false
		reductions := false

		this.loadRules(productions, reductions)

		knowledgeBase := this.createKnowledgeBase({}, productions, reductions)

		this.iKnowledgeBase := knowledgeBase

		if this.Debug[kDebugRules]
			this.dumpRules(this.KnowledgeBase)

		this.loadCharacteristics(this.Definition, false, false, false, fast)
		this.loadSettings(this.Definition, false, false, fast)

		showProgress({progress: this.ProgressCount++, color: "Green", title: translate(phase2), message: translate("Starting AI Kernel...")})

		knowledgeBase.addFact("Initialize", true)

		knowledgeBase.produce()

		Sleep 200

		showProgress({progress: this.ProgressCount++, color: "Green", title: translate(phase3), message: translate("Loading Car Settings...")})

		this.loadCharacteristics(this.Definition, this.SelectedSimulator["*"], this.SelectedCar["*"], this.SelectedTrack["*"], fast)

		Sleep 200

		this.loadSettings(this.Definition, this.SelectedSimulator["*"], this.SelectedCar["*"], fast)

		Sleep 200

		knowledgeBase.setFact("Advisor.Simulator", this.SelectedSimulator["*"])
		knowledgeBase.setFact("Advisor.Car", this.SelectedCar["*"])
		knowledgeBase.setFact("Advisor.Track", this.SelectedTrack["*"])

		knowledgeBase.addFact("Calculate", true)

		knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		showProgress({progress: this.ProgressCount++, message: translate("Initializing Car Setup...")})

		Sleep 200

		this.updateRecommendations(false, false)

		this.showSettingsChart(false)

		showProgress({message: translate("Finished...")})

		Sleep 500

		this.iSetup := false

		hideProgress()

		this.updateState()
	}

	loadSimulator(simulator, force := false) {
		local window, simulators, settings

		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window

			Gui %window%:Default
			Gui %window%:+Disabled

			try {
				this.iSelectedSimulator := simulator

				settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

				if (simulator == true)
					removeConfigurationValue(settings, "Setup Advisor", "Simulator")
				else
					setConfigurationValue(settings, "Setup Advisor", "Simulator", simulator)

				writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

				this.initializeSimulator((simulator == true) ? "Generic" : simulator)

				simulators := this.getSimulators()

				if (simulators.Length() > 0)
					GuiControl Choose, simulatorDropDown, % inList(this.getSimulators(), simulator)

				this.loadCars(this.AvailableCars[true], false)

				this.initializeAdvisor()
			}
			finally {
				Gui %window%:-Disabled
			}
		}
	}

	loadCars(cars) {
		local tracks, trackNames

		GuiControl, , carDropDown, % "|" . values2String("|", cars*)

		GuiControl Choose, carDropDown, 1

		this.iSelectedCar := ((cars[1] = translate("All")) ? true : cars[1])

		tracks := this.getTracks(this.SelectedSimulator, this.SelectedCar).Clone()
		trackNames := map(tracks, ObjBindMethod(this, "getTrackName", this.SelectedSimulator))

		GuiControl, , trackDropDown, % "|" . values2String("|", trackNames*)
		GuiControl Choose, trackDropDown, 1
	}

	loadCar(car, force := false) {
		local window, tracks, trackNames, settings

		if (force || (car != this.SelectedCar[false])) {
			window := this.Window

			Gui %window%:Default
			Gui %window%:+Disabled

			try {
				this.iSelectedCar := car

				settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

				if (car == true)
					removeConfigurationValue(settings, "Setup Advisor", "Car")
				else
					setConfigurationValue(settings, "Setup Advisor", "Car", car)

				writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

				GuiControl Choose, carDropDown, % inList(this.AvailableCars, this.SelectedCar)

				tracks := this.getTracks(this.SelectedSimulator, car).Clone()
				trackNames := map(tracks, ObjBindMethod(this, "getTrackName", this.SelectedSimulator))

				GuiControl, , trackDropDown, % "|" . values2String("|", trackNames*)
				GuiControl Choose, trackDropDown, 1

				this.initializeAdvisor("Loading Car", "Loading Car", "Loading Car", true)
			}
			finally {
				Gui %window%:-Disabled
			}
		}
	}

	loadTrack(track, force := false) {
		local window, settings

		if (force || (track != this.SelectedTrack[false])) {
			window := this.Window

			Gui %window%:Default
			Gui %window%:+Disabled

			try {
				this.iSelectedTrack := track

				settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

				if (track == true)
					removeConfigurationValue(settings, "Setup Advisor", "Track")
				else
					setConfigurationValue(settings, "Setup Advisor", "Track", track)

				writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

				if (track == true)
					GuiControl Choose, trackDropDown, 1
				else
					GuiControl Choose, trackDropDown, % inList(this.getTracks(this.SelectedSimulator, this.SelectedCar), track)
			}
			finally {
				Gui %window%:-Disabled
			}
		}
	}

	loadWeather(weather, force := false) {
	}

	startTelemetryAnalyzer() {
		local analyzerClass := getConfigurationValue(this.SimulatorDefinition, "Simulator", "Analyzer", false)

		if analyzerClass
			new %analyzerClass%(this, this.SelectedSimulator).createCharacteristics()
	}

	clearCharacteristics() {
		while (this.SelectedCharacteristics.Length() > 0)
			this.deleteCharacteristic(this.SelectedCharacteristics[this.SelectedCharacteristics.Length()], false)

		this.showSettingsChart(false)
	}

	addCharacteristic(characteristic, weight := 50, value := 33, draw := true) {
		local numCharacteristics := this.SelectedCharacteristics.Length()
		local window, x, y, characteristicLabels, callback
		local label1, label2, slider1, slider2

		if (!inList(this.SelectedCharacteristics, characteristic) && (numCharacteristics <= kMaxCharacteristics)) {
			window := this.Window

			Gui %window%:Default
			Gui %window%:Color, D0D0D0, D8D8D8

			x := (this.CharacteristicsArea.X + 8)
			y := (this.CharacteristicsArea.Y + 8 + (numCharacteristics * kCharacteristicHeight))

			characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels")

			this.SelectedCharacteristics.Push(characteristic)

			Gui %window%:Font, s10 Italic, Arial

			Gui %window%:Add, Button, x%X% y%Y% w20 h20 HWNDdeleteButton
			setButtonIcon(deleteButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

			callback := ObjBindMethod(this, "deleteCharacteristic", characteristic)

			GuiControl +g, %deleteButton%, %callback%

			x := x + 25

			Gui %window%:Add, Text, x%X% y%Y% w300 h26 HWNDlabel1, % characteristicLabels[characteristic]

			x := x - 25

			Gui %window%:Font, s8 Norm, Arial

			x := x + 8
			y := y + 26

			Gui %window%:Add, Text, x%X% y%Y% w115 HWNDlabel2, % translate("Importance / Severity")

			x := x + 120

			Gui %window%:Add, Slider, Center Thick15 x%x% yp-2 w118 0x10 Range0-100 ToolTip HWNDslider1, 0

			x := x + 123

			Gui %window%:Add, Slider, Center Thick15 x%x% yp w118 0x10 Range0-100 ToolTip HWNDslider2, 0

			callback := Func("updateSlider").Bind(characteristic, slider1, slider2)

			GuiControl +g, %slider1%, %callback%
			GuiControl +g, %slider2%, %callback%

			this.SelectedCharacteristicsWidgets[characteristic] := [slider1, slider2, label1, label2, deleteButton]

			initializeSlider(slider1, weight, slider2, value)

			if draw {
				this.updateRecommendations()

				this.updateState()
			}
		}
	}

	deleteCharacteristic(characteristic, draw := true) {
		local numCharacteristics := this.SelectedCharacteristics.Length()
		local index := inList(this.SelectedCharacteristics, characteristic)
		local ignore, widget, row, y, widgets, pos, poxX, posY

		if index {
			for ignore, widget in this.SelectedCharacteristicsWidgets[characteristic]
				GuiControl Hide, %widget%

			loop % (numCharacteristics - index)
			{
				row := (A_Index + index)

				for ignore, widget in this.SelectedCharacteristicsWidgets[this.SelectedCharacteristics[row]] {
					GuiControlGet pos, Pos, %widget%

					y := (posY - kCharacteristicHeight)

					GuiControl MoveDraw, %widget%, y%Y%
				}
			}

			widgets := this.SelectedCharacteristicsWidgets[characteristic]

			this.KnowledgeBase.clearFact(characteristic . ".Weight")
			this.KnowledgeBase.clearFact(characteristic . ".Value")

			this.SelectedCharacteristics.RemoveAt(index)
			this.SelectedCharacteristicsWidgets.Delete(characteristic)

			this.updateRecommendations(draw)
		}
	}

	chooseCharacteristic() {
		local window := this.Window
		local characteristicLabels, menuIndex, groups, translatedGroups, ignore, group, definition, option
		local groupMenu, groupEmpty, groupOption, optionMenu, optionEmpty, handler, label, characteristic

		Gui %window%:Default

		try {
			Menu CharacteristicsMenu, DeleteAll
		}
		catch exception {
			logError(exception)
		}

		characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels")

		menuIndex := 1

		groups := getConfigurationSectionValues(this.Definition, "Setup.Characteristics")
		translatedGroups := {}

		for group, definition in groups
			translatedGroups[characteristicLabels[group]] := group

		for ignore, group in translatedGroups {
			definition := groups[group]

			groupMenu := ("SubMenu" . menuIndex++)
			groupEmpty := true

			try {
				Menu %groupMenu%, DeleteAll
			}
			catch exception {
				logError(exception)
			}

			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)
					optionMenu := ("SubMenu" . menuIndex++)
					optionEmpty := true

					try {
						Menu %optionMenu%, DeleteAll
					}
					catch exception {
						logError(exception)
					}

					for ignore, option in string2Values(",", groupOption[2]) {
						characteristic := factPath(group, groupOption[1], option)

						if (inList(this.Characteristics, characteristic) && !inList(this.SelectedCharacteristics, characteristic)) {
							handler := ObjBindMethod(this, "addCharacteristic", characteristic, 50, 33)

							label := characteristicLabels[option]

							Menu, %optionMenu%, Add, %label%, %handler%

							optionEmpty := false
						}
					}

					if !optionEmpty {
						label := characteristicLabels[groupOption[1]]

						Menu %groupMenu%, Add, %label%, :%optionMenu%

						groupEmpty := false
					}
				}
				else {
					characteristic := factPath(group, groupOption)

					if (inList(this.Characteristics, characteristic) && !inList(this.SelectedCharacteristics, characteristic)) {
						handler := ObjBindMethod(this, "addCharacteristic", characteristic, 50, 33)
						label := characteristicLabels[groupOption]

						Menu %groupMenu%, Add, %label%, %handler%

						groupEmpty := false
					}
				}
			}

			if !groupEmpty {
				label := characteristicLabels[group]

				Menu CharacteristicsMenu, Add, %label%, :%groupMenu%
			}
		}

		Menu CharacteristicsMenu, Add

		label := translate("Analyzer...")
		handler := ObjBindMethod(this, "startTelemetryAnalyzer")

		Menu CharacteristicsMenu, Add, %label%, %handler%

		if (!this.SimulatorDefinition || !getConfigurationValue(this.SimulatorDefinition, "Simulator", "Analyzer", false))
			Menu CharacteristicsMenu, Disable, %label%

		Menu CharacteristicsMenu, Show
	}

	updateCharacteristic(characteristic, value1, value2) {
		this.updateRecommendations()
	}

	updateRecommendations(draw := true, update := true) {
		local knowledgeBase := this.KnowledgeBase
		local window, noProblem, ignore, characteristic, widgets, value1, value2, settingsLabels, settings
		local setting, delta

		window := this.Window

		Gui %window%:Default
		Gui %window%:+Disabled

		try {
			noProblem := true

			for ignore, characteristic in this.SelectedCharacteristics {
				noProblem := false

				widgets := this.SelectedCharacteristicsWidgets[characteristic]

				GuiControlGet value1, , % widgets[1]
				GuiControlGet value2, , % widgets[2]

				knowledgeBase.setFact(characteristic . ".Weight", value1, true)
				knowledgeBase.setFact(characteristic . ".Value", value2, true)
			}

			knowledgeBase.addFact("Calculate", true)

			this.KnowledgeBase.produce()

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(this.KnowledgeBase)

			if draw {
				settingsLabels := getConfigurationSectionValues(this.Definition, "Setup.Settings.Labels")

				settings := []

				for ignore, setting in this.Settings {
					delta := knowledgeBase.getValue(setting . ".Delta", translate("n/a"))

					if delta is Number
						if (delta != 0)
							settings.Push(Array(settingsLabels[setting], Round(delta, 2)))
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
			Gui %window%:-Disabled
		}
	}

	editSetup() {
		local editorClass := getConfigurationValue(this.SimulatorDefinition, "Setup", "Editor", false)
		local editor, aWindow, eWindow

		if editorClass {
			editor := new %editorClass%(this)

			this.iEditor := editor

			aWindow := this.Window
			eWindow := editor.Window

			Gui %eWindow%:+Owner%aWindow%
			Gui %aWindow%:+Disabled

			try {
				editor.createGui(editor.Configuration)

				this.iSetup := editor.editSetup(this.Setup)
			}
			finally {
				this.iEditor := false

				Gui %aWindow%:-Disabled
			}
		}
	}
}


;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TelemetryAnalyzer                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TelemetryAnalyzer {
	iAdvisor := false
	iSimulator := false

	Advisor[] {
		Get {
			return this.iAdvisor
		}
	}

	Simulator[] {
		Get {
			return this.iSimulator
		}
	}

	__New(advisor, simulator) {
		this.iAdvisor := advisor
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

	iEnabledSettings := {}

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	Name[] {
		Get {
			throw "Virtual property Setup.Name must be implemented in a subclass..."
		}
	}

	Enabled[setting] {
		Get {
			return this.iEnabledSettings.HasKey(setting)
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
		if setting
			this.iEnabledSettings.Delete(setting)
		else
			this.iEnabledSettings := {}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FileSetup                                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FileSetup extends Setup {
	iOriginalFileName := false
	iModifiedFileName := false

	Name[] {
		Get {
			local fileName := this.FileName[true]

			SplitPath fileName, , , , fileName

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

		base.__New(editor)

		this.iOriginalFileName := originalFileName
		this.iModifiedFileName := modifiedFileName

		if (originalFileName && FileExist(originalFileName)) {
			FileRead setup, %originalFileName%

			this.iOriginalSetup := setup
		}

		if (modifiedFileName && FileExist(modifiedFileName)) {
			FileRead setup, %modifiedFileName%

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

class NumberHandler {
	MinValue[] {
		Get {
			return -2147483648
		}
	}

	MaxValue[] {
		Get {
			return 2147483647
		}
	}

	validValue(displayValue) {
		return ((displayValue >= this.MinValue) && (displayValue <= this.MaxValue))
	}

	formatValue(value) {
		return value
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

	Zero[] {
		Get {
			return this.iZero
		}
	}

	Increment[] {
		Get {
			return this.iIncrement
		}
	}

	MinValue[] {
		Get {
			return ((this.iMinValue != kUndefined) ? this.iMinValue : base.MinValue)
		}
	}

	MaxValue[] {
		Get {
			return ((this.iMaxValue != kUndefined) ? this.iMaxValue : base.MaxValue)
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
		base.__New(0, increment, minValue, maxValue)
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

		return (base.validValue(displayValue) && (Round(rawValue) = rawValue))
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

	Precision[] {
		Get {
			return this.iPrecision
		}
	}

	__New(zero := 0.0, increment := 1.0, precision := 0, minValue := "__Undefined__", maxValue := "__Undefined__") {
		this.iPrecision := precision

		base.__New(zero, increment, minValue, maxValue)
	}

	validValue(displayValue) {
		local rawValue := this.convertToRawValue(displayValue)

		return (base.validValue(displayValue) && (Round(rawValue) = rawValue))
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
		base.__New(minValue, 1, minValue, maxValue)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupEditor                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global setupViewer
global setupNameViewer

global decreaseSettingButton
global increaseSettingButton

global resetSetupButton

global applyStrengthSlider := 100

class SetupEditor extends ConfigurationItem {
	iAdvisor := false
	iSetup := false

	iComparator := false

	iSettings := {}
	iSettingsListView := false

	iClosed := false

	Advisor[] {
		Get {
			return this.iAdvisor
		}
	}

	Comparator[] {
		Get {
			return this.iComparator
		}
	}

	SetupClass[] {
		Get {
			throw "Virtual property FileSetupComparator.SetupClass must be implemented in a subclass..."
		}
	}

	Setup[] {
		Get {
			return this.iSetup
		}

		Set {
			return (this.iSetup := value)
		}
	}

	Setings[key := false] {
		Get {
			return (key ? this.iSettings[key] : this.iSettings)
		}

		Set {
			return (key ? (this.iSettings[key] := value) : (this.iSettings := value))
		}
	}

	SettingsListView[] {
		Get {
			return this.iSettingsListView
		}
	}

	Window[] {
		Get {
			return "Editor"
		}
	}

	__New(advisor, configuration := false) {
		local simulator, car, section, values, key, value, fileName

		this.iAdvisor := advisor

		if !configuration {
			simulator := advisor.SelectedSimulator
			car := advisor.SelectedCar[false]

			configuration := readConfiguration(kResourcesDirectory . "Advisor\Definitions\" . simulator . ".ini")

			for section, values in readConfiguration(kResourcesDirectory . "Advisor\Definitions\Cars\" . simulator . ".Generic.ini")
				for key, value in values
					setConfigurationValue(configuration, section, key, value)

			if (car != true) {
				fileName := ("Advisor\Definitions\Cars\" . simulator . "." . car . ".ini")

				for section, values in readConfiguration(getFileName(fileName, kResourcesDirectory, kUserHomeDirectory))
					for key, value in values
						setConfigurationValue(configuration, section, key, value)
			}
		}

		base.__New(configuration)
	}

	createGui(configuration) {
		local window := this.Window
		local settingsListView

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w784 Center gmoveEditor, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x308 YP+20 w184 cBlue Center gopenEditorDocumentation, % translate("Setup Editor")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, Text, x8 yp+30 w800 0x10 Section

		Gui %window%:Add, Button, x16 ys+10 w60 gchooseSetupFile, % translate("Setup:")
		Gui %window%:Add, Text, x85 ys+14 w193 vsetupNameViewer
		Gui %window%:Add, Button, x280 ys+10 w80 gresetSetup vresetSetupButton, % translate("&Reset")

		Gui %window%:Add, ListView, x16 ys+40 w344 h320 -Multi -LV0x10 Checked AltSubmit NoSort NoSortHdr HWNDsettingsListView gselectSetting, % values2String("|", map(["Category", "Setting", "Value", "Unit"], "translate")*)

		this.iSettingsListView := settingsListView

		Gui %window%:Add, Button, x16 yp+324 w80 Disabled gdecreaseSetting vdecreaseSettingButton, % translate("Decrease")
		Gui %window%:Add, Button, x280 yp w80 Disabled gincreaseSetting vincreaseSettingButton, % translate("Increase")

		Gui %window%:Add, Button, x280 yp+29 w80 gcompareSetup, % translate("Compare...")

		Gui %window%:Add, Button, x16 ys+420 w80 gapplyRecommendations, % translate("&Apply")
		Gui %window%:Add, Slider, x100 ys+422 w60 0x10 Range20-100 ToolTip vapplyStrengthSlider, %applyStrengthSlider%
		Gui %window%:Add, Text, x162 ys+425, % translate("%")

		Gui %window%:Add, Button, x280 ys+420 w80 gsaveModifiedSetup, % translate("&Save...")

		Gui %window%:Add, Edit, x374 ys+10 w423 h433 T8 ReadOnly -Wrap HScroll vsetupViewer

		Gui %window%:Add, Text, x8 y506 w800 0x10

		Gui %window%:Add, Button, x374 y514 w80 h23 GcloseEditor, % translate("Close")
	}

	show() {
		local window := this.Window
		local x, y

		if getWindowPosition("Setup Advisor.Setup Editor", x, y)
			Gui %window%:Show, x%x% y%y%
		else
			Gui %window%:Show

		this.loadSetup()
	}

	close() {
		this.iClosed := true
	}

	destroy() {
		local window := this.Window

		Gui %window%:Destroy
	}

	editSetup(setup := false) {
		this.Setup := (setup ? setup : new Setup())

		this.show()

		try {
			while !this.iClosed
				Sleep 200
		}
		finally {
			this.destroy()
		}

		return this.Setup
	}

	updateState() {
		local window := this.Window
		local setup := this.Setup
		local enabled := []
		local changed := false
		local row, label, sIndex, sEnabled, ignore, setting

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		if LV_GetNext(0) {
			GuiControl Enable, increaseSettingButton
			GuiControl Enable, decreaseSettingButton
		}
		else {
			GuiControl Disable, increaseSettingButton
			GuiControl Disable, decreaseSettingButton
		}

		if setup {
			row := LV_GetNext(0, "C")

			while row {
				LV_GetText(label, row, 2)

				enabled.Push(this.Settings[label])

				row := LV_GetNext(row, "C")
			}

			for ignore, setting in this.Advisor.Settings {
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
				GuiControl Text, setupViewer, % this.Setup.Setup
		}
	}

	createSettingHandler(setting) {
		local handler := getConfigurationValue(this.Configuration, "Setup.Settings.Handler", setting, false)
		local handlerClass

		if (handler && (handler != "")) {
			handler := string2Values("(", SubStr(handler, 1, StrLen(handler) - 1))

			handlerClass := handler[1]

			return new %handlerClass%(string2Values(",", handler[2])*)
		}
		else
			throw "Unknown handler encountered in SetupEditor.createSettingHandler..."
	}

	chooseSetup() {
		throw "Virtual method SetupEditor.chooseSetup must be implemented in a subclass..."
	}

	loadSetup(ByRef setup := false) {
		local window, categories, categoriesLabels, settingsLabels, settingsUnits
		local ignore, setting, handler, modifiedValue, originalValue, value, category, candidate, settings
		local cSetting, label, lastCategory

		if !setup
			setup := this.Setup
		else
			this.Setup := setup

		window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		LV_Delete()

		this.Settings := {}

		GuiControl Text, setupNameViewer, % (setup ? setup.Name : "")
		GuiControl Text, setupViewer, % (setup ? setup.Setup : "")

		categories := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories")

		categoriesLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories.Labels")

		settingsLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Settings.Labels")

		settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units." . getLanguage(), {})

		if (settingsUnits.Count() = 0)
			settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units.EN")

		window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		LV_Delete()

		this.Settings := {}

		setup.disable(false)

		for ignore, setting in this.Advisor.Settings {
			handler := this.createSettingHandler(setting)

			if handler {
				originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
				modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

				if (originalValue = modifiedValue)
					value := originalValue
				else if (modifiedValue > originalValue) {
					value := (modifiedValue . A_Space . translate("(") . "+" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

					setup.enable(setting)
				}
				else {
					value := (modifiedValue . A_Space . translate("(") . "-" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

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

				LV_Add((originalValue = modifiedValue) ? "" : "Check", categoriesLabels[category], label, value, settingsUnits[setting])

				this.Settings[setting] := label
				this.Settings[label] := setting
			}
		}

		LV_ModifyCol()

		LV_ModifyCol(1, "AutoHdr Sort 80")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")

		lastCategory := ""

		loop % LV_getCount()
		{
			LV_GetText(category, A_Index)

			if (category = lastCategory)
				LV_Modify(A_Index, "", "")

			lastCategory := category
		}

		this.updateState()
	}

	saveSetup() {
		throw "Virtual method SetupEditor.saveSetup must be implemented in a subclass..."
	}

	increaseSetting(setting := false) {
		local window := this.Window
		local handler, label, row, candidate

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				LV_GetText(candidate, A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := LV_GetNext(0)

		if row {
			LV_GetText(label, row, 2)

			setting := this.Settings[label]
			handler := this.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.increaseValue(handler.convertToDisplayValue(this.Setup.getValue(setting)))))

			GuiControl Text, setupViewer, % (this.Setup ? this.Setup.Setup : "")
		}

		this.updateState()
	}

	decreaseSetting(setting := false) {
		local window := this.Window
		local label, row, candidate, handler

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				LV_GetText(candidate, A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := LV_GetNext(0)

		if row {
			LV_GetText(label, row, 2)

			setting := this.Settings[label]
			handler := this.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.decreaseValue(handler.convertToDisplayValue(this.Setup.getValue(setting)))))

			GuiControl Text, setupViewer, % (this.Setup ? this.Setup.Setup : "")
		}

		this.updateState()
	}

	applyRecommendations(percentage) {
		local knowledgeBase := this.Advisor.KnowledgeBase
		local settings := {}
		local min := 1
		local ignore, setting, delta, increment

		this.resetSetup()

		for ignore, setting in this.Advisor.Settings {
			delta := knowledgeBase.getValue(setting . ".Delta", kUndefined)

			if (delta != kUndefined)
				if (delta != 0) {
					min := Min(Abs(delta), min)

					settings[setting] := delta
				}
		}

		for setting, delta in settings {
			increment := Round((delta / min) * (percentage / 100))

			if (increment != 0) {
				if getConfigurationValue(this.Configuration, "Setup.Settings", setting . ".Reverse", false)
					increment *= -1

				if (increment < 0)
					loop % Abs(increment)
						this.decreaseSetting(setting)
				else
					loop % Abs(increment)
						this.increaseSetting(setting)
			}
		}
	}

	resetSetup() {
		this.Setup.reset()

		this.loadSetup(this.Setup)
	}

	updateSetting(setting, newValue) {
		local setup := this.Setup
		local label := this.Settings[setting]
		local row := false
		local candidate, window, handler, originalValue, modifiedValue, value

		setup.setValue(setting, newValue)

		loop {
			LV_GetText(candidate, A_Index, 2)

			if (label = candidate) {
				row := A_Index

				break
			}
		}

		window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		handler := this.createSettingHandler(setting)
		originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
		modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

		if (originalValue = modifiedValue) {
			value := originalValue

			setup.disable(setting)
		}
		else if (modifiedValue > originalValue) {
			value := (modifiedValue . A_Space . translate("(") . "+" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

			setup.enable(setting)
		}
		else {
			value := (modifiedValue . A_Space . translate("(") . "-" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

			setup.enable(setting)
		}

		LV_Modify(row, "Vis Col3", value)
		LV_Modify(row, (originalValue = modifiedValue) ? "-Check" : "Check")
		LV_ModifyCol(3, "AutoHdr")
	}

	compareSetup() {
		local comparatorClass := getConfigurationValue(this.Configuration, "Setup", "Comparator", false)
		local comparator, aWindow, cWindow, newSetup

		if comparatorClass {
			comparator := new %comparatorClass%(this)

			this.iComparator := comparator

			aWindow := this.Window
			cWindow := comparator.Window

			Gui %cWindow%:+Owner%aWindow%
			Gui %aWindow%:+Disabled

			try {
				comparator.createGui(comparator.Configuration)

				newSetup := comparator.compareSetup()

				if newSetup
					this.loadSetup(newSetup)
			}
			finally {
				this.iComparator := false

				Gui %aWindow%:-Disabled
			}
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupComparator                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global decreaseABSettingButton
global increaseABSettingButton

global setupNameAViewer
global setupNameBViewer

global applyMixSlider := 0

class SetupComparator extends ConfigurationItem {
	iEditor := false

	iSetupA := false
	iSetupB := false
	iSetupAB := false

	iSettingsListView := false

	iSettings := {}

	iClosed := false

	Advisor[] {
		Get {
			return this.Editor.Advisor
		}
	}

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	SetupClass[] {
		Get {
			return this.Editor.SetupClass
		}
	}

	SetupA[] {
		Get {
			return this.iSetupA
		}

		Set {
			return (this.iSetupA := value)
		}
	}

	SetupB[] {
		Get {
			return this.iSetupB
		}

		Set {
			return (this.iSetupB := value)
		}
	}

	SetupAB[] {
		Get {
			return this.iSetupAB
		}

		Set {
			return (this.iSetupAB := value)
		}
	}

	Setings[key := false] {
		Get {
			return (key ? this.iSettings[key] : this.iSettings)
		}

		Set {
			return (key ? (this.iSettings[key] := value) : (this.iSettings := value))
		}
	}

	SettingsListView[] {
		Get {
			return this.iSettingsListView
		}
	}

	Window[] {
		Get {
			return "Comparator"
		}
	}

	__New(editor, configuration := false) {
		local advisor, simulator, car, section, values, key, value, fileName

		this.iEditor := editor
		this.iSetupA := editor.Setup

		if !configuration {
			advisor := this.Advisor

			simulator := advisor.SelectedSimulator
			car := advisor.SelectedCar[false]

			configuration := readConfiguration(kResourcesDirectory . "Advisor\Definitions\" . simulator . ".ini")

			for section, values in readConfiguration(kResourcesDirectory . "Advisor\Definitions\Cars\" . simulator . ".Generic.ini")
				for key, value in values
					setConfigurationValue(configuration, section, key, value)

			if (car != true) {
				fileName := ("Advisor\Definitions\Cars\" . simulator . "." . car . ".ini")

				for section, values in readConfiguration(getFileName(fileName, kResourcesDirectory, kUserHomeDirectory))
					for key, value in values
						setConfigurationValue(configuration, section, key, value)
			}
		}

		base.__New(configuration)
	}

	createGui(configuration) {
		local window := this.Window
		local settingsListView

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w784 Center gmoveComparator, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x308 YP+20 w184 cBlue Center gopenComparatorDocumentation, % translate("Setup Comparator")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, Text, x8 yp+30 w800 0x10 Section

		Gui %window%:Add, Button, x16 ys+10 w60 gchooseSetupAFile, % translate("Setup A:")
		Gui %window%:Add, Text, x85 ys+14 w193 vsetupNameAViewer
		Gui %window%:Add, Button, x16 ys+34 w60 gchooseSetupBFile, % translate("Setup B:")
		Gui %window%:Add, Text, x85 ys+38 w193 vsetupNameBViewer

		Gui %window%:Add, ListView, x16 ys+64 w784 h350 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDsettingsListView gselectABSetting, % values2String("|", map(["Category", "Setting", "Value (A)", "Value (B)", "Value (A/B)", "Unit"], "translate")*)

		Gui %window%:Add, Button, x16 yp+354 w80 Disabled vdecreaseABSettingButton gdecreaseABSetting, % translate("Decrease")
		Gui %window%:Add, Button, x720 yp w80 Disabled vincreaseABSettingButton gincreaseABSetting, % translate("Increase")

		Gui %window%:Add, Slider, x316 yp w200 0x10 Range-100-100 ToolTip vapplyMixSlider gmixSetups, 0
		Gui %window%:Add, Text, x251 yp+3 w50, % translate("Setup A")
		Gui %window%:Add, Text, x529 yp w50, % translate("Setup B")

		this.iSettingsListView := settingsListView

		Gui %window%:Add, Text, x8 y506 w800 0x10

		Gui %window%:Add, Button, x322 y514 w80 h23 GapplyComparator, % translate("&Apply")
		Gui %window%:Add, Button, x426 y514 w80 h23 Default GcloseComparator, % translate("Close")
	}

	show() {
		local window := this.Window
		local x, y

		if getWindowPosition("Setup Advisor.Setup Comparator", x, y)
			Gui %window%:Show, x%x% y%y%
		else
			Gui %window%:Show

		this.loadSetups()
	}

	close(apply := false) {
		this.iClosed := (apply ? "Apply" : "Close")
	}

	destroy() {
		local window := this.Window

		Gui %window%:Destroy
	}

	loadSetups(ByRef setupA := false, ByRef setupB := false, mix := 0) {
		local window, setupClass, setupAB, categories, categoriesLabels, settingsLabels, settingsUnits
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

		window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		LV_Delete()

		this.Settings := {}

		GuiControl Text, setupNameAViewer, % (setupA ? setupA.Name : "")
		GuiControl Text, setupNameBViewer, % (setupB ? setupB.Name : "")

		setupClass := this.SetupClass

		setupAB := new %setupClass%(this.Editor, setupA.getInitializationArguments()*)

		setupAB.Setup[false] := setupA.Setup[false]

		this.SetupAB := setupAB

		categories := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories")

		categoriesLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories.Labels")

		settingsLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Settings.Labels")

		settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units", {})

		if (settingsUnits.Count() = 0)
			settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units.EN")

		LV_Delete()

		this.Settings := {}

		for ignore, setting in this.Advisor.Settings {
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
					valueB := (valueB . A_Space . translate("(") . "+" . handler.formatValue(Abs(valueA - valueB)) . translate(")"))
				else if (valueB < valueA)
					valueB := (valueB . A_Space . translate("(") . "-" . handler.formatValue(Abs(valueA - valueB)) . translate(")"))

				if (valueAB > valueA)
					valueAB := (valueAB . A_Space . translate("(") . "+" . handler.formatValue(Abs(valueA - valueAB)) . translate(")"))
				else if (valueAB < valueA)
					valueAB := (valueAB . A_Space . translate("(") . "-" . handler.formatValue(Abs(valueA - valueAB)) . translate(")"))

				label := settingsLabels[setting]

				LV_Add("", categoriesLabels[category], settingsLabels[setting], valueA, valueB, valueAB, settingsUnits[setting])

				this.Settings[setting] := label
				this.Settings[label] := setting
			}
		}

		LV_ModifyCol()

		LV_ModifyCol(1, "AutoHdr Sort")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
		LV_ModifyCol(5, "AutoHdr")

		lastCategory := ""

		loop % LV_getCount()
		{
			LV_GetText(category, A_Index)

			if (category = lastCategory)
				LV_Modify(A_Index, "", "")

			lastCategory := category
		}

		this.updateState()
	}

	compareSetup(setup := false) {
		this.SetupB := (setup ? setup : new Setup())

		this.show()

		try {
			while !this.iClosed
				Sleep 200
		}
		finally {
			this.destroy()
		}

		return ((this.iClosed = "Apply") ? this.SetupAB : false)
	}

	updateSetting(setting, newValue) {
		local setup := this.SetupAB
		local label, row, candidate, window, handler, originalValue, modifiedValue, value

		setup.setValue(setting, newValue)

		label := this.Settings[setting]
		row := false

		loop {
			LV_GetText(candidate, A_Index, 2)

			if (label = candidate) {
				row := A_Index

				break
			}
		}

		window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		handler := this.Editor.createSettingHandler(setting)
		originalValue := handler.convertToDisplayValue(this.SetupA.getValue(setting, false))
		modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

		if (originalValue = modifiedValue)
			value := originalValue
		else if (modifiedValue > originalValue)
			value := (modifiedValue . A_Space . translate("(") . "+" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))
		else
			value := (modifiedValue . A_Space . translate("(") . "-" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

		LV_Modify(row, "Vis Col5", value)
		LV_ModifyCol(5, "AutoHdr")
	}

	increaseSetting(setting := false) {
		local window := this.Window
		local row, candidate, label, handler

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				LV_GetText(candidate, A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := LV_GetNext(0)

		if row {
			LV_GetText(label, row, 2)

			setting := this.Settings[label]
			handler := this.Editor.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.increaseValue(handler.convertToDisplayValue(this.SetupAB.getValue(setting)))))
		}

		this.updateState()
	}

	decreaseSetting(setting := false) {
		local window := this.Window
		local label, row, candidate, handler

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		if setting {
			label := this.Settings[setting]
			row := false

			loop {
				LV_GetText(candidate, A_Index, 2)

				if (label = candidate) {
					row := A_Index

					break
				}
			}
		}
		else
			row := LV_GetNext(0)

		if row {
			LV_GetText(label, row, 2)

			setting := this.Settings[label]
			handler := this.Editor.createSettingHandler(setting)

			this.updateSetting(setting, handler.convertToRawValue(handler.decreaseValue(handler.convertToDisplayValue(this.SetupAB.getValue(setting)))))
		}

		this.updateState()
	}

	updateState() {
		local window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		if LV_GetNext(0) {
			GuiControl Enable, increaseABSettingButton
			GuiControl Enable, decreaseABSettingButton
		}
		else {
			GuiControl Disable, increaseABSettingButton
			GuiControl Disable, decreaseABSettingButton
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
			return base.editSetup(theSetup)
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
			return base.compareSetup(theSetup)
		else {
			this.destroy()

			return false
		}
	}

	loadSetups(ByRef setupA := false, ByRef setupB := false, mix := 0) {
		base.loadSetups(setupA, setupB, mix)

		if this.SetupAB
			this.SetupAB.FileName[false] := setupA.FileName[false]
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

initializeSlider(slider1, value1, slider2, value2) {
	local window := SetupAdvisor.Instance.Window
	local y, pos, posX, posY

	Gui %window%:Default
	Gui %window%:Color, D0D0D0, D8D8D8

	ControlClick, , ahk_id %slider1%, , , , x0 y0
	ControlClick, , ahk_id %slider2%, , , , x0 y0

	Sleep 10

	GuiControlGet pos, Pos, %slider1%
	y := (posY - 1)
	GuiControl MoveDraw, %slider1%, y%Y%
	GuiControl MoveDraw, %slider1%, y%posY%

	GuiControlGet pos, Pos, %slider2%
	y := (posY - 1)
	GuiControl MoveDraw, %slider2%, y%Y%
	GuiControl MoveDraw, %slider2%, y%posY%

	GuiControl, , %slider1%, %value1%
	GuiControl, , %slider2%, %value2%
}

updateSlider(characteristic, slider1, slider2) {
	local value1, value2

	GuiControlGet value1, , %slider1%
	GuiControlGet value2, , %slider2%

	SetupAdvisor.Instance.updateCharacteristic(characteristic, value1, value2)
}

factPath(path*) {
	local result := ""

	loop % path.Length()
		result .= ((StrLen(result) > 0) ? ("." . path[A_Index]) : path[A_Index])

	return result
}

loadSetup() {
	local title := translate("Load Problems...")
	local fileName

	Gui +OwnDialogs

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
	FileSelectFile fileName, 1, , %title%, Problems (*.setup)
	OnMessage(0x44, "")

	if (fileName != "")
		SetupAdvisor.Instance.restoreState(fileName)
}

saveSetup() {
	local title := translate("Save Problems...")
	local fileName

	Gui +OwnDialogs

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
	FileSelectFile fileName, S17, , %title%, Problems (*.setup)
	OnMessage(0x44, "")

	if (fileName != "") {
		if !InStr(fileName, ".setup")
			fileName := (fileName . ".setup")

		SetupAdvisor.Instance.saveState(fileName)
	}
}

editSetup() {
	SetupAdvisor.Instance.editSetup()
}

compareSetup() {
	SetupAdvisor.Instance.Editor.compareSetup()
}

closeAdvisor() {
	if GetKeyState("Ctrl", "P")
		SetupAdvisor.Instance.saveState()

	ExitApp 0
}

moveAdvisor() {
	moveByMouse(SetupAdvisor.Instance.Window, "Setup Advisor")
}

openAdvisorDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor
}

closeEditor() {
	SetupAdvisor.Instance.Editor.close()
}

moveEditor() {
	moveByMouse(SetupAdvisor.Instance.Editor.Window, "Setup Advisor.Setup Editor")
}

openEditorDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#managing-car-setups
}

applyComparator() {
	SetupAdvisor.Instance.Editor.Comparator.close(true)
}

closeComparator() {
	SetupAdvisor.Instance.Editor.Comparator.close()
}

moveComparator() {
	moveByMouse(SetupAdvisor.Instance.Editor.Comparator.Window, "Setup Advisor.Setup Comparator")
}

openComparatorDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#comparing-car-setups
}

chooseSetupAFile() {
	SetupAdvisor.Instance.Editor.Comparator.chooseSetup("A")
}

chooseSetupBFile() {
	SetupAdvisor.Instance.Editor.Comparator.chooseSetup("B")
}

selectABSetting() {
	SetupAdvisor.Instance.Editor.Comparator.updateState()
}

increaseABSetting() {
	SetupAdvisor.Instance.Editor.Comparator.increaseSetting()
}

decreaseABSetting() {
	SetupAdvisor.Instance.Editor.Comparator.decreaseSetting()
}

mixSetups() {
	GuiControlGet applyMixSlider

	SetupAdvisor.Instance.Editor.Comparator.loadSetups(false, false, applyMixSlider)
}

chooseSetupFile() {
	SetupAdvisor.Instance.Editor.chooseSetup()
}

selectSetting() {
	SetupAdvisor.Instance.Editor.updateState()
}

increaseSetting() {
	SetupAdvisor.Instance.Editor.increaseSetting()
}

decreaseSetting() {
	SetupAdvisor.Instance.Editor.decreaseSetting()
}

applyRecommendations() {
	GuiControlGet applyStrengthSlider

	SetupAdvisor.Instance.Editor.applyRecommendations(applyStrengthSlider)
}

resetSetup() {
	SetupAdvisor.Instance.Editor.resetSetup()
}

saveModifiedSetup() {
	SetupAdvisor.Instance.Editor.saveSetup()
}

chooseSimulator() {
	local advisor := SetupAdvisor.Instance
	local window := advisor.Window

	Gui %window%:Default

	GuiControlGet simulatorDropDown

	advisor.loadSimulator((simulatorDropDown = translate("Generic")) ? true : simulatorDropDown)
}

chooseCar() {
	local advisor := SetupAdvisor.Instance
	local window := advisor.Window

	Gui %window%:Default

	GuiControlGet carDropDown

	advisor.loadCar((carDropDown = translate("All")) ? true : carDropDown)
}

chooseTrack() {
	local advisor := SetupAdvisor.Instance
	local window := advisor.Window
	local simulator, tracks, trackNames

	Gui %window%:Default

	GuiControlGet trackDropDown

	if (trackDropDown = translate("All"))
		advisor.loadTrack(true)
	else {
		simulator := advisor.SelectedSimulator
		tracks := advisor.getTracks(simulator, advisor.SelectedCar)
		trackNames := map(tracks, ObjBindMethod(advisor, "getTrackName", simulator))

		advisor.loadTrack(tracks[inList(trackNames, trackDropDown)])
	}
}

chooseWeather() {
	/*
	advisor := SetupAdvisor.Instance
	window := advisor.Window

	Gui %window%:Default

	GuiControlGet weatherDropDown

	advisor.loadWeather(kWeatherConditions[weatherDropDown])
	*/
}

chooseCharacteristic() {
	SetupAdvisor.Instance.chooseCharacteristic()
}

runSetupAdvisor() {
	local icon := kIconsDirectory . "Setup.ico"
	local settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getConfigurationValue(settings, "Setup Advisor", "Simulator", false)
	local car := getConfigurationValue(settings, "Setup Advisor", "Car", false)
	local track := getConfigurationValue(settings, "Setup Advisor", "Track", false)
	local weather := false
	local index := 1
	local advisor, label, callback

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Setup Advisor

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
			default:
				index += 1
		}
	}

	fixIE(11)

	if car
		car := new SessionDatabase().getCarName(simulator, car)

	advisor := new SetupAdvisor(simulator, car, track, weather)

	Menu SupportMenu, Insert, 1&

	label := translate("Debug Rule System")
	callback := ObjBindMethod(advisor, "toggleDebug", kDebugRules)

	Menu SupportMenu, Insert, 1&, %label%, %callback%

	if advisor.Debug[kDebugRules]
		Menu SupportMenu, Check, %label%

	label := translate("Debug Knowledgebase")
	callback := ObjBindMethod(advisor, "toggleDebug", kDebugKnowledgeBase)

	Menu SupportMenu, Insert, 1&, %label%, %callback%

	if advisor.Debug[kDebugKnowledgebase]
		Menu SupportMenu, Check, %label%

	advisor.createGui(advisor.Configuration)

	advisor.show()

	if !GetKeyState("Ctrl", "P")
		if simulator {
			advisor.loadSimulator(simulator, true)

			if inList(advisor.AvailableCars, car)
				advisor.loadCar(car)

			if track
				advisor.loadTrack(track)

			if weather
				advisor.loadWeather(weather)
		}
		else
			advisor.loadSimulator(true, true)
	else
		Task.startTask(ObjBindMethod(advisor, "restoreState"), 100)

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                          Editor Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\GenericTelemetryAnalyzer.ahk
#Include Libraries\IRCTelemetryAnalyzer.ahk
#Include Libraries\R3ETelemetryAnalyzer.ahk
#Include Libraries\ACCSetupEditor.ahk
#Include Libraries\ACSetupEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

runSetupAdvisor()