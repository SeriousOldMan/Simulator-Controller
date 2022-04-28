;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Advisor                   ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Setup.ico
;@Ahk2Exe-ExeName Setup Advisor.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk = "ok"
global kCancel = "cancel"

global kMaxCharacteristics = 8
global kCharacteristicHeight = 56


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vProgressCount = 0
global vCharacteristicFinished = true


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugOff = 0
global kDebugKnowledgeBase = 1
global kDebugRules = 2


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
		this.iDebug := (isDebug() ? (kDebugKnowledgeBase + kDebugRules) : kDebugOff)
		
		if simulator {
			this.iSelectedSimulator := simulator
			this.iSelectedCar := car
			this.iSelectedTrack := track
			this.iSelectedWeather := weather
		}
		
		this.iDefinition := readConfiguration(kResourcesDirectory . "Advisor\Setup Advisor.ini")
		
		base.__New(kSimulatorConfiguration)
		
		SetupAdvisor.Instance := this
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1184 Center gmoveAdvisor, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w1184 cBlue Center gopenAdvisorDocumentation, % translate("Setup Advisor")
		
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
		Gui %window%:Add, DropDownList, x100 yp w196 Disabled Choose1 vtrackDropDown gchooseTrack, % translate("All")
		
		Gui %window%:Add, Text, x16 yp+24 w80 h23 +0x200, % translate("Conditions")
		
		weather := this.SelectedWeather
		choices := map(kWeatherOptions, "translate")
		chosen := inList(kWeatherOptions, weather)
		
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

			characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels." . getLanguage(), Object())
		
			if (characteristicLabels.Count() == 0)
				characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels.EN", Object())
		
			characteristics := string2Values(",", getConfigurationValue(state, "Characteristics", "Characteristics"))
			
			if (characteristics.Length() > 0) {
				window := this.Window
			
				Gui %window%:Default
				Gui %window%:+Disabled
				
				try {
					x := Round((A_ScreenWidth - 300) / 2)
					y := A_ScreenHeight - 150
					
					vProgressCount := 0
					
					showProgress({x: x, y: y, color: "Green", title: translate("Loading Problems"), message: translate("Preparing Characteristics...")})
			
					Sleep 200
					
					for ignore, characteristic in characteristics {
						showProgress({progress: (vProgressCount += 10), message: translate("Load ") . characteristicLabels[characteristic] . translate("...")})
					
						this.addCharacteristic(characteristic, getConfigurationValue(state, "Characteristics", characteristic . ".Weight")
															 , getConfigurationValue(state, "Characteristics", characteristic . ".Value"))
					
						while !vCharacteristicFinished
							Sleep 50
					}
					
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
			advisor.loadSimulator(true, true)
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
	}
	
	showSettingsChart(content) {
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
					
					info := getConfigurationValue(this.Definition, "Setup.Info." . getLanguage(), "ChangeWarning", false)
					
					if !info
						info := getConfigurationValue(this.Definition, "Setup.Info.EN", "ChangeWarning", false)
					
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
					
					Loop % names.Length()
						drawChartFunction .= ",`n['" . names[A_Index] . "', " . values[A_Index] . ", '" . names[A_Index] . "']"
					
					drawChartFunction .= "`n]);"
					
					drawChartFunction := drawChartFunction . "`nvar options = { legend: 'none', vAxis: { textPosition: 'none', baseline: 'none' }, bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '5%', top: '5%', right: '5%', bottom: '5%' } };"
				}
				else {
					drawChartFunction .= "`n['" . values2String("', '", names*) . "'],"
					
					drawChartFunction .= "`n[" . values2String(",", values*) . "]"
					
					drawChartFunction .= "`n]);"
					
					drawChartFunction := drawChartFunction . "`nvar options = { bar: { groupWidth: " . (settings.Length() * 16) . " }, vAxis: { textPosition: 'none', baseline: 'none' }, bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '5%', top: '5%', right: '40%', bottom: '5%' } };"
				}
				
				drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction := [translate("I can't help you with that."), translate("You are on your own this time.")]
			
			this.showSettingsChart(drawChartFunction)
		}
	}
	
	setDebug(option, enabled) {
		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)
	}
	
	getSimulators() {
		simulators := []
		
		hasGeneric := false
		
		Loop Files, %kResourcesDirectory%Advisor\Definitions\*.ini, F
		{
			SplitPath A_LoopFileName, , , , simulator
		
			if (simulator = "Generic")
				hasGeneric := true
			else if !inList(simulators, simulator)
				simulators.Push(simulator)
		}
		
		Loop Files, %kUserHomeDirectory%Advisor\Definitions\*.ini, F
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
		cars := []
		
		if ((simulator != true) && (simulator != "*")) {
			Loop Files, %kResourcesDirectory%Advisor\Definitions\Cars\%simulator%.*.ini, F
			{
				SplitPath A_LoopFileName, , , , descriptor
			
				car := StrReplace(StrReplace(descriptor, simulator . ".", ""), ".ini", "")
			
				if ((car != "Generic") && !inList(cars, car))
					cars.Push(car)
			}
			
			Loop Files, %kUserHomeDirectory%Advisor\Definitions\Cars\*.ini, F
			{
				SplitPath A_LoopFileName, , , , descriptor
			
				car := StrReplace(StrReplace(descriptor, simulator . ".", ""), ".ini", "")
			
				if ((car != "Generic") && !inList(cars, car))
					cars.Push(car)
			}
		}
		
		cars.InsertAt(1, "*")
		
		return cars
	}
	
	getTracks(simulator) {
		tracks := []
		
		tracks.InsertAt(1, "*")
		
		return tracks
	}
	
	dumpKnowledge(knowledgeBase) {
		try {
			FileDelete %kTempDirectory%Setup Advisor.knowledge
		}
		catch exception {
			; ignore
		}

		for key, value in knowledgeBase.Facts.Facts {
			text := (key . " = " . value . "`n")
		
			FileAppend %text%, %kTempDirectory%Setup Advisor.knowledge
		}
	}
	
	dumpRules(knowledgeBase) {
		local rules
		local rule
		
		try {
			FileDelete %kTempDirectory%Setup Advisor.rules
		}
		catch exception {
			; ignore
		}

		production := knowledgeBase.Rules.Productions[false]
		
		Loop {
			if !production
				break
			
			text := (production.Rule.toString() . "`n")
		
			FileAppend %text%, %kTempDirectory%Setup Advisor.rules
			
			production := production.Next[false]
		}

		for ignore, rules in knowledgeBase.Rules.Reductions
			for ignore, rule in rules {
				text := (rule.toString() . "`n")
			
				FileAppend %text%, %kTempDirectory%Setup Advisor.rules
			}
	}
	
	updateState() {
		window := this.Window
		
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
			
			compiler.compileRules(rules, productions, reductions)
		}
	}
	
	loadRules(ByRef productions, ByRef reductions) {
		local rules
		
		FileRead rules, % kResourcesDirectory . "Advisor\Rules\Setup Advisor.rules"
		
		productions := false
		reductions := false

		compiler := new RuleCompiler()
		
		compiler.compileRules(rules, productions, reductions)
		
		simulator := this.SelectedSimulator
		car := this.SelectedCar
		
		this.compileRules(getFileName("Advisor\Rules\" . simulator . ".rules", kResourcesDirectory, kUserHomeDirectory), productions, reductions)
		this.compileRules(getFileName("Advisor\Rules\Cars\" . simulator . ".Generic.rules", kResourcesDirectory, kUserHomeDirectory), productions, reductions)
		
		if (car != true)
			this.compileRules(getFileName("Advisor\Rules\Cars\" . simulator . "." . car . ".rules", kResourcesDirectory, kUserHomeDirectory), productions, reductions)
	}
	
	loadCharacteristics(definition, simulator := false, car := false, track := false, fast := false) {
		local knowledgeBase := this.KnowledgeBase
		
		this.iCharacteristics := []
		
		if !simulator
			knowledgeBase.addFact("Characteristics.Count", 0)
		
		compiler := new RuleCompiler()
		
		for group, definition in getConfigurationSectionValues(definition, "Setup.Characteristics", Object())
			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)
					
					for ignore, option in string2Values(",", groupOption[2]) {
						characteristic := factPath(group, groupOption[1], option)
					
						if !simulator {
							showProgress({progress: ++vProgressCount, message: translate("Initializing Characteristic ") . characteristic . translate("...")})
							
							knowledgeBase.prove(compiler.compileGoal("addCharacteristic(" . characteristic . ")")).dispose()
						
							this.Characteristics.Push(characteristic)
							
							if (!fast && !isDebug())
								Sleep 50
						}
						else if knowledgeBase.prove(compiler.compileGoal("characteristicActive("
																	   . StrReplace(values2String(",", simulator, car, track, characteristic), A_Space, "\ ")
																	   . ")")) {
							showProgress({progress: ++vProgressCount})
						
							this.Characteristics.Push(characteristic)
						}
					}
				}
				else {
					characteristic := factPath(group, groupOption)
				
					if !simulator {
						showProgress({progress: ++vProgressCount, message: translate("Initializing Characteristic ") . characteristic . translate("...")})
							
						knowledgeBase.prove(compiler.compileGoal("addCharacteristic(" . characteristic . ")")).dispose()
						
						this.Characteristics.Push(characteristic)
							
						if (!fast && !isDebug())
							Sleep 50
					}
					else if knowledgeBase.prove(compiler.compileGoal("characteristicActive("
																   . StrReplace(values2String(",", simulator, car, track, characteristic), A_Space, "\ ")
																   . ")")) {
						showProgress({progress: ++vProgressCount})
					
						this.Characteristics.Push(characteristic)
					}
				}
			}
	}
	
	loadSettings(definition, simulator := false, car := false, fast := false) {
		local knowledgeBase := this.KnowledgeBase
		
		this.iSettings := []
		
		if !simulator
			knowledgeBase.addFact("Settings.Count", 0)
		
		compiler := new RuleCompiler()
		
		for group, definition in getConfigurationSectionValues(definition, "Setup.Settings", Object())
			for ignore, groupOption in string2Values(";", definition) {
				if InStr(groupOption, ":") {
					groupOption := string2Values(":", groupOption)
					
					for ignore, option in string2Values(",", groupOption[2]) {
						setting := factPath(group, groupOption[1], option)
					
						if !simulator {
							showProgress({progress: ++vProgressCount, message: translate("Initializing Setting ") . setting . translate("...")})
							
							knowledgeBase.prove(compiler.compileGoal("addSetting(" . setting . ")")).dispose()
						
							this.Settings.Push(setting)
							
							if (!fast && !isDebug())
								Sleep 50
						}
						else if knowledgeBase.prove(compiler.compileGoal("settingAvailable("
																	   . StrReplace(values2String(",", simulator, car, setting), A_Space, "\ ")
																	   . ")")) {
							showProgress({progress: ++vProgressCount})
						
							this.Settings.Push(setting)
						}
					}
				}
				else {
					setting := factPath(group, groupOption)
				
					if !simulator {
						showProgress({progress: ++vProgressCount, message: translate("Initializing Setting ") . setting . translate("...")})
						
						knowledgeBase.prove(compiler.compileGoal("addSetting(" . setting . ")")).dispose()
						
						this.Settings.Push(setting)
							
						if (!fast && !isDebug())
							Sleep 50
					}
					else if knowledgeBase.prove(compiler.compileGoal("settingAvailable("
																   . StrReplace(values2String(",", simulator, car, setting), A_Space, "\ ")
																   . ")")) {
						showProgress({progress: ++vProgressCount})
					
						this.Settings.Push(setting)
					}
				}
			}
	}
	
	createKnowledgeBase(facts, productions, reductions) {
		engine := new RuleEngine(productions, reductions, facts)
		
		return new KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}
	
	initializeSimulator(name) {
		definition := readConfiguration(kResourcesDirectory . "Advisor\Definitions\" . name . ".ini")
		
		this.iSimulatorDefinition := definition
		
		simulator := getConfigurationValue(definition, "Simulator", "Simulator")
		; cars := string2Values(",", getConfigurationValue(definition, "Simulator", "Cars"))
		; tracks := string2Values(",", getConfigurationValue(definition, "Simulator", "Tracks"))
		
		cars := this.getCars(simulator)
		tracks := this.getTracks(simulator)
		
		this.iSimulatorSettings := {Name: name, Simulator: simulator, Cars: cars, Tracks: tracks}
		
		this.iSelectedSimulator := ((simulator = "*") ? true : simulator)
		this.iAvailableCars := cars
		this.iSelectedCar := ((cars[1] = "*") ? true : cars[1])
		this.iSelectedTrack := ((tracks[1] = "*") ? true : tracks[1])
	}
	
	initializeAdvisor(phase1 := "Initializing Setup Advisor", phase2 := "Starting Setup Advisor", phase3 := "Loading Car", fast := false) {
		local knowledgeBase
		
		simulator := this.SelectedSimulator
		
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
		
		vProgressCount := 0
		
		showProgress({x: x, y: y, color: "Blue", title: translate(phase1), message: translate("Clearing Problems...")})
		
		Sleep 200
		
		this.clearCharacteristics()
		
		showProgress({progress: vProgressCount++, message: translate("Preparing Knowledgebase...")})

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
		
		showProgress({progress: vProgressCount++, color: "Green", title: translate(phase2), message: translate("Starting AI Kernel...")})
		
		knowledgeBase.addFact("Initialize", true)
			
		knowledgeBase.produce()

		Sleep 200
		
		showProgress({progress: vProgressCount++, color: "Green", title: translate(phase3), message: translate("Loading Car Settings...")})
		
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
			this.dumpKnowledge(knowledgeBase)
		
		showProgress({progress: vProgressCount++, message: translate("Initializing Car Setup...")})
		
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
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			Gui %window%:+Disabled
			
			try {
				this.iSelectedSimulator := simulator
		
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
		GuiControl, , carDropDown, % "|" . values2String("|", cars*)
		
		GuiControl Choose, carDropDown, 1
		
		this.iSelectedCar := ((cars[1] = translate("All")) ? true : cars[1])
	}
	
	loadCar(car, force := false) {
		if (force || (car != this.SelectedCar[false])) {
			window := this.Window
		
			Gui %window%:Default
			Gui %window%:+Disabled
			
			try {
				this.iSelectedCar := car
				
				GuiControl Choose, carDropDown, % inList(this.AvailableCars, this.SelectedCar)
			
				this.initializeAdvisor("Loading Car", "Loading Car", "Loading Car", true)
			}
			finally {
				Gui %window%:-Disabled
			}
		}
	}
	
	loadTrack(track, force := false) {
	}
	
	loadWeather(weather, force := false) {
	}
	
	clearCharacteristics() {
		while (this.SelectedCharacteristics.Length() > 0)
			this.deleteCharacteristic(this.SelectedCharacteristics[this.SelectedCharacteristics.Length()], false)
		
		this.showSettingsChart(false)
	}
	
	addCharacteristic(characteristic, weight := 50, value := 33) {
		numCharacteristics := this.SelectedCharacteristics.Length()
		
		if (!inList(this.SelectedCharacteristics, characteristic) && (numCharacteristics <= kMaxCharacteristics)) {
			vCharacteristicFinished := false
			
			try {
				window := this.Window
			
				Gui %window%:Default
				Gui %window%:Color, D0D0D0, D8D8D8
				
				x := (this.CharacteristicsArea.X + 8)
				y := (this.CharacteristicsArea.Y + 8 + (numCharacteristics * kCharacteristicHeight))
				
				characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels." . getLanguage(), Object())
			
				if (characteristicLabels.Count() == 0)
					characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels.EN", Object())
				
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
				
				Gui %window%:Add, Slider, x%x% yp-2 w118 0x10 Range0-100 ToolTip HWNDslider1, 0
				
				x := x + 123
				
				Gui %window%:Add, Slider, x%x% yp w118 0x10 Range0-100 ToolTip HWNDslider2, 0
				
				callback := Func("updateSlider").Bind(characteristic, slider1, slider2)
				
				GuiControl +g, %slider1%, %callback%
				GuiControl +g, %slider2%, %callback%
				
				this.SelectedCharacteristicsWidgets[characteristic] := [slider1, slider2, label1, label2, deleteButton]
		
				initializeSlider(slider1, weight, slider2, value)
		
				this.updateRecommendations()
				
				this.updateState()
			}
			finally {
				vCharacteristicFinished := true
			}
		}
	}
	
	deleteCharacteristic(characteristic, draw := true) {
		numCharacteristics := this.SelectedCharacteristics.Length()
		index := inList(this.SelectedCharacteristics, characteristic)
		
		if index {
			for ignore, widget in this.SelectedCharacteristicsWidgets[characteristic]
				GuiControl Hide, %widget%
			
			Loop % (numCharacteristics - index)
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
		window := this.Window
		
		Gui %window%:Default
		
		try {
			Menu CharacteristicsMenu, DeleteAll
		}
		catch exception {
			; ignore
		}
		
		characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels." . getLanguage(), Object())
		
		if (characteristicLabels.Count() == 0)
			characteristicLabels := getConfigurationSectionValues(this.Definition, "Setup.Characteristics.Labels.EN", Object())
		
		menuIndex := 1
		
		groups := getConfigurationSectionValues(this.Definition, "Setup.Characteristics", Object())
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
				; ignore
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
						; ignore
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

		Menu CharacteristicsMenu, Show
	}
	
	updateCharacteristic(characteristic, value1, value2) {
		this.updateRecommendations()
	}
	
	updateRecommendations(draw := true, update := true) {
		local knowledgeBase := this.KnowledgeBase
		
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
				this.dumpKnowledge(this.KnowledgeBase)
			
			if draw {
				settingsLabels := getConfigurationSectionValues(this.Definition, "Setup.Settings.Labels." . getLanguage(), Object())
				
				if (settingsLabels.Count() == 0)
					settingsLabels := getConfigurationSectionValues(this.Definition, "Setup.Settings.Labels.EN", Object())
				
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
		editorClass := getConfigurationValue(this.SimulatorDefinition, "Setup", "Editor", false)
			
		if editorClass {
			editor := new %editorClass%(this)
			
			this.iEditor := editor

			aWindow := this.Window
			eWindow := editor.Window
			
			Gui %eWIndow%:+Owner%aWindow%
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
;;; Setup                                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Setup {
	iEditor := false
	
	iOriginalFileName := false
	iModifiedFileName := false
	
	iOriginalSetup := ""
	iModifiedSetup := ""
	
	Editor[] {
		Get {
			return this.iEditor
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
	
	Setup[original := false] {
		Get {
			return ((original || !this.iModifiedSetup) ? this.iOriginalSetup : this.iModifiedSetup)
		}
		
		Set {
			return (original ? (this.iOriginalSetup := value) : (this.iModifiedSetup := value))
		}
	}
	
	__New(editor, originalFileName := false) {
		local setup
		
		this.iEditor := editor
		this.iOriginalFileName := originalFileName
		
		if (originalFileName && FileExist(originalFileName)) {
			FileRead setup, %originalFileName%
			
			this.iOriginalSetup := setup
		}
	}
	
	reset() {
		this.iModifiedSetup := false
	}
	
	getValue(setting, original := false, default := false) {
		Throw "Virtual method Setup.getValue must be implemented in a subclass..."
	}
	
	setValue(setting, value) {
		Throw "Virtual method Setup.setValue must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SettingHandler                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SettingHandler {
	validValue(displayValue) {
		Throw "Virtual method SettingHandler.validValue must be implemented in a subclass..."
	}
	
	formatValue(value) {
		return value
	}
	
	convertToDisplayValue(value) {
		Throw "Virtual method SettingHandler.convertToDisplayValue must be implemented in a subclass..."
	}
	
	convertToRawValue(value) {
		Throw "Virtual method SettingHandler.convertToRawValue must be implemented in a subclass..."
	}
	
	increaseValue(displayValue) {
		Throw "Virtual method SettingHandler.increaseValue must be implemented in a subclass..."
	}
	
	decreaseValue(displayValue) {
		Throw "Virtual method SettingHandler.decreaseValue must be implemented in a subclass..."
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
		value := (displayValue + this.Increment)
		
		if this.validValue(value)
			return value
		else
			return displayValue
	}
	
	decreaseValue(displayValue) {
		value := (displayValue - this.Increment)
		
		if this.validValue(value)
			return value
		else
			return displayValue
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; IntegerValueHandler                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class IntegerHandler extends DiscreteValuesHandler {
	validValue(displayValue) {
		rawValue := this.convertToRawValue(displayValue)
		
		return (base.validValue(displayValue) && (Round(rawValue) = rawValue))
	}
	
	formatValue(value) {
		return Round(value)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FloatValueHandler                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FloatHandler extends DiscreteValuesHandler {
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
		rawValue := this.convertToRawValue(displayValue)
		
		return (base.validValue(displayValue) && (Round(rawValue) = rawValue))
	}
	
	formatValue(value) {
		return Round(value, this.Precision)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ClicksHandler                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClicksHandler extends IntegerHandler {
	__New(minValue := 0, maxValue := "__Undefined__") {
		base.__New(0, 1, minValue, maxValue)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupEditor                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global setupViewer
global fileNameViewer

global decreaseSettingButton
global increaseSettingButton

global resetSetupButton

global applyStrengthSlider = 100

class SetupEditor extends ConfigurationItem {
	iAdvisor := false
	iSetup := false
	
	iSettings := []
	iSettingsListView := false
	
	iClosed := false
	
	Advisor[] {
		Get {
			return this.iAdvisor
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
		this.iAdvisor := advisor
		
		if !configuration {
			simulator := advisor.SelectedSimulator
			car := advisor.SelectedCar
			
			configuration := readConfiguration(kResourcesDirectory . "Advisor\Definitions\" . simulator . ".ini")
			
			for section, values in readConfiguration(kResourcesDirectory . "Advisor\Definitions\Cars\" . simulator . ".Generic.ini")
				for key, value in values
					setConfigurationValue(configuration, section, key, value)
			
			if (car != true) {
				fileName := ("Advisor\Definitions\Cars\" . simulator . "." . car . ".ini")
				
				for section, values in readConfiguration(getFileName(fileName, kResourcesDirectory, kUserHomeDirectory . "Advisor\"))
					for key, value in values
						setConfigurationValue(configuration, section, key, value)
			}
		}
		
		base.__New(configuration)
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w784 Center gmoveEditor, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w784 cBlue Center gopenEditorDocumentation, % translate("Setup Editor")
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x8 yp+30 w800 0x10 Section
		
		Gui %window%:Add, Button, x16 ys+10 w60 gchooseSetupFile, % translate("Setup:")
		Gui %window%:Add, Text, x85 ys+14 w193 vfileNameViewer
		Gui %window%:Add, Button, x280 ys+10 w80 gresetSetup vresetSetupButton, % translate("&Reset")
		
		Gui %window%:Add, ListView, x16 ys+40 w344 h320 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDsettingsListView gselectSetting, % values2String("|", map(["Setting", "Value", "Unit"], "translate")*)
		
		this.iSettingsListView := settingsListView
		
		Gui %window%:Add, Button, x16 yp+324 w80 Disabled gdecreaseSetting vdecreaseSettingButton, % translate("Decrease")
		Gui %window%:Add, Button, x280 yp w80 Disabled gincreaseSetting vincreaseSettingButton, % translate("Increase")
				
		Gui %window%:Add, Button, x16 ys+420 w80 gapplyRecommendations, % translate("&Apply")
		Gui %window%:Add, Slider, x100 ys+422 w60 0x10 Range20-100 ToolTip vapplyStrengthSlider, %applyStrengthSlider%
		Gui %window%:Add, Text, x162 ys+425, % translate("%")
		
		Gui %window%:Add, Button, x280 ys+420 w80 gsaveModifiedSetup, % translate("&Save...")
		
		Gui %window%:Add, Edit, x374 ys+10 w423 h433 T8 ReadOnly -Wrap HScroll vsetupViewer
		
		Gui %window%:Add, Text, x8 y506 w800 0x10
		
		Gui %window%:Add, Button, x374 y514 w80 h23 GcloseEditor, % translate("Close")
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
		
		this.loadSetup()
	}
	
	close() {
		this.iClosed := true
	}
	
	destroy() {
		window := this.Window
			
		Gui %window%:Destroy
	}
	
	editSetup(setup := false) {
		this.iSetup := (setup ? setup : new Setup())
		
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
		window := this.Window
		
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
	}
	
	createSettingHandler(setting) {
		handler := getConfigurationValue(this.Configuration, "Setup.Settings.Handler", setting, false)
		
		if (handler && (handler != "")) {
			handler := string2Values("(", SubStr(handler, 1, StrLen(handler) - 1))
			
			handlerClass := handler[1]
			
			return new %handlerClass%(string2Values(",", handler[2])*)
		}
		else
			Throw "Unknown handler encoutered in SetupEditor.createSettingHandler..."
	}
	
	chooseSetup() {
		Throw "Virtual method SetupEditor.chooseSetup must be implemented in a subclass..."
	}
	
	loadSetup(ByRef setup := false) {
		if !setup
			setup := this.Setup
		
		window := this.Window
		
		Gui %window%:Default
		
		Gui ListView, % this.SettingsListView
		
		LV_Delete()
		
		this.Settings := []
		
		fileName := ""
		
		if setup {
			fileName := setup.FileName[true]
			
			SplitPath fileName, , , , fileName
		}
		
		GuiControl Text, fileNameViewer, %fileName%
		GuiControl Text, setupViewer, % (setup ? setup.Setup : "")
		
		this.updateState()
	}
	
	saveSetup() {
		Throw "Virtual method SetupEditor.saveSetup must be implemented in a subclass..."
	}
	
	increaseSetting(setting := false) {
		window := this.Window
		
		Gui %window%:Default
		
		Gui ListView, % this.SettingsListView
		
		if setting
			row := inList(this.Settings, setting)
		else
			row := LV_GetNext(0)
		
		if row {
			setting := this.Settings[row]
			handler := this.createSettingHandler(setting)
			
			this.updateSetting(setting, handler.convertToRawValue(handler.increaseValue(handler.convertToDisplayValue(this.Setup.getValue(setting)))))
			
			GuiControl Text, setupViewer, % (this.Setup ? this.Setup.Setup : "")
		}
		
		this.updateState()
	}
	
	decreaseSetting(setting := false) {
		window := this.Window
		
		Gui %window%:Default
		
		Gui ListView, % this.SettingsListView
		
		if setting
			row := inList(this.Settings, setting)
		else
			row := LV_GetNext(0)
		
		if row {
			setting := this.Settings[row]
			handler := this.createSettingHandler(setting)
			
			this.updateSetting(setting, handler.convertToRawValue(handler.decreaseValue(handler.convertToDisplayValue(this.Setup.getValue(setting)))))
			
			GuiControl Text, setupViewer, % (this.Setup ? this.Setup.Setup : "")
		}
		
		this.updateState()
	}
	
	applyRecommendations(percentage) {
		local knowledgeBase := this.Advisor.KnowledgeBase
		
		this.resetSetup()
		
		settings := {}
		
		min := 1
		
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
					Loop % Abs(increment)
						this.decreaseSetting(setting)
				else
					Loop % Abs(increment)
						this.increaseSetting(setting)
			}
		}
	}
	
	resetSetup() {
		this.Setup.reset()
		
		this.loadSetup(this.Setup)
	}
	
	updateSetting(setting, newValue) {
		Throw "Virtual method SetupEditor.updateSetting must be implemented in a subclass..."
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

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
	
initializeSlider(slider1, value1, slider2, value2) {
	window := SetupAdvisor.Instance.Window
	
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
	GuiControlGet value1, , %slider1%
	GuiControlGet value2, , %slider2%
	
	SetupAdvisor.Instance.updateCharacteristic(characteristic, value1, value2)
}

factPath(path*) {
	result := ""
	
	Loop % path.Length()
		result .= ((StrLen(result) > 0) ? ("." . path[A_Index]) : path[A_Index])
	
	return result
}

loadSetup() {
	title := translate("Load Setup...")
	
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
	FileSelectFile fileName, 1, , %title%, Setup (*.setup)
	OnMessage(0x44, "")

	if (fileName != "")
		SetupAdvisor.Instance.restoreState(fileName)
}

saveSetup() {
	title := translate("Save Setup...")
	
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
	FileSelectFile fileName, S17, , %title%, Setup (*.setup)
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

closeAdvisor() {
	if GetKeyState("Ctrl", "P")
		SetupAdvisor.Instance.saveState()
	
	ExitApp 0
}

moveAdvisor() {
	moveByMouse(SetupAdvisor.Instance.Window)
}

openAdvisorDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor
}

closeEditor() {
	SetupAdvisor.Instance.Editor.close()
}

moveEditor() {
	moveByMouse(SetupAdvisor.Instance.Editor.Window)
}

openEditorDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#managing-car-setups
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
	advisor := SetupAdvisor.Instance
	window := advisor.Window
	
	Gui %window%:Default
	
	GuiControlGet simulatorDropDown
	
	advisor.loadSimulator((simulatorDropDown = translate("Generic")) ? true : simulatorDropDown)
}

chooseCar() {
	advisor := SetupAdvisor.Instance
	window := advisor.Window
	
	Gui %window%:Default
	
	GuiControlGet carDropDown
	
	advisor.loadCar((carDropDown = translate("All")) ? true : carDropDown)
}

chooseTrack() {
	/*
	advisor := SetupAdvisor.Instance
	window := advisor.Window
	
	Gui %window%:Default
	
	GuiControlGet trackDropDown
	
	advisor.loadTrack(trackDropDown = translate("All")) ? true : trackDropDown)
	*/
}

chooseWeather() {
	/*
	advisor := SetupAdvisor.Instance
	window := advisor.Window
	
	Gui %window%:Default
	
	GuiControlGet weatherDropDown
	
	advisor.loadWeather(kWeatherOptions[weatherDropDown])
	*/
}

chooseCharacteristic() {
	SetupAdvisor.Instance.chooseCharacteristic()
}

runSetupAdvisor() {
	icon := kIconsDirectory . "Setup.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Setup Advisor
	
	current := fixIE()
	
	try {
		advisor := new SetupAdvisor()
		
		advisor.createGui(advisor.Configuration)
		
		advisor.show()
		
		if !GetKeyState("Ctrl", "P")
			advisor.loadSimulator(true, true)
		else {
			callback := ObjBindMethod(advisor, "restoreState")
		
			SetTimer %callback%, -50
		}
	}
	finally {
		; fixIE(current)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Editor Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ACCSetupEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

runSetupAdvisor()