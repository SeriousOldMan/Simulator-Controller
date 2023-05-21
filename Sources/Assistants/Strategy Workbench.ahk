;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Workbench Tool         ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Dashboard.ico
;@Ahk2Exe-ExeName Strategy Workbench.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\HTMLViewer.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"
#Include "..\Database\Libraries\TelemetryDatabase.ahk"
#Include "Libraries\Strategy.ahk"
#Include "Libraries\StrategyViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StrategyWorkbench extends ConfigurationItem {
	iWindow := false

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

	iTelemetryChartHTML := false
	iStrategyChartHTML := false

	iTyreSetListView := false

	iSelectedScenario := false
	iSelectedStrategy := false

	iAirTemperature := 23
	iTrackTemperature := 27

	iDriversListView := false
	iWeatherListView := false
	iPitstopListView := false

	iChartViewer := false
	iStrategyViewer := false

	iTelemetryDatabase := false

	class WorkbenchResizer extends Window.Resizer {
		iRedraw := false

		__New(arguments*) {
			super.__New(arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViwer"), 500, kLowPriority)
		}

		Redraw() {
			this.iRedraw := true
		}

		RedrawHTMLViwer() {
			if this.iRedraw {
				local workbench := StrategyWorkbench.Instance
				local ignore, button

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button, "P")
						return Task.CurrentTask

				this.iRedraw := false

				workbench.StrategyViewer.StrategyViewer.Resized()
				workbench.ChartViewer.Resized()

				workbench.showStrategyInfo(workbench.SelectedStrategy)

				if (workbench.Control["chartSourceDropDown"].Value = 1)
					workbench.loadChart(["Scatter", "Bar", "Bubble", "Line"][workbench.Control["chartTypeDropDown"].Value])
				else {
					workbench.ChartViewer.document.open()
					workbench.ChartViewer.document.write(workbench.iStrategyChartHTML)
					workbench.ChartViewer.document.close()
				}
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
			return this.iWindow[name]
		}
	}

	SelectedSimulator {
		Get {
			return this.iSelectedSimulator
		}
	}

	SelectedCar {
		Get {
			return this.iSelectedCar
		}
	}

	SelectedTrack {
		Get {
			return this.iSelectedTrack
		}
	}

	SelectedWeather {
		Get {
			return this.iSelectedWeather
		}
	}

	AirTemperature {
		Get {
			return this.iAirTemperature
		}
	}

	TrackTemperature {
		Get {
			return this.iTrackTemperature
		}
	}

	TyreCompounds[key?] {
		Get {
			return (isSet(key) ? this.iTyreCompounds[key] : this.iTyreCompounds)
		}
	}

	AvailableDrivers[index?] {
		Get {
			return (isSet(index) ? this.iAvailableDrivers[index] : this.iAvailableDrivers)
		}
	}

	AvailableCompounds[index?] {
		Get {
			return (isSet(index) ? this.iAvailableCompounds[index] : this.iAvailableCompounds)
		}
	}

	SelectedCompound[colored?] {
		Get {
			return (isSet(colored) ? compound(this.iSelectedCompound, this.iSelectedCompoundColor) : this.iSelectedCompound)
		}
	}

	SelectedCompoundColor {
		Get {
			return this.iSelectedCompoundColor
		}
	}

	SelectedDataType {
		Get {
			return this.iSelectedDataType
		}
	}

	SelectedChartType {
		Get {
			return this.iSelectedChartType
		}
	}

	SelectedDrivers[index?] {
		Get {
			return (isSet(index) ? this.iSelectedDrivers[index] : this.iSelectedDrivers)
		}
	}

	StintDrivers[index?] {
		Get {
			return (isSet(index) ? this.iStintDrivers[index] : this.iStintDrivers)
		}

		Set {
			return (isSet(index) ? (this.iStintDrivers[index] := value) : (this.iStintDrivers := value))
		}
	}

	SelectedValidator {
		Get {
			return this.iSelectedValidator
		}
	}

	SelectedSessionType {
		Get {
			return this.iSelectedSessionType
		}
	}

	SelectedScenario {
		Get {
			return this.iSelectedScenario
		}
	}

	SelectedStrategy {
		Get {
			return this.iSelectedStrategy
		}
	}

	DataListView {
		Get {
			return this.iDataListView
		}
	}

	TyreSetListView {
		Get {
			return this.iTyreSetListView
		}
	}

	DriversListView {
		Get {
			return this.iDriversListView
		}
	}

	WeatherListView {
		Get {
			return this.iWeatherListView
		}
	}

	PitstopListView {
		Get {
			return this.iPitstopListView
		}
	}

	ChartViewer {
		Get {
			return this.iChartViewer
		}
	}

	StrategyViewer {
		Get {
			return this.iStrategyViewer
		}
	}

	TelemetryDatabase {
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

		super.__New(kSimulatorConfiguration)

		StrategyWorkbench.Instance := this

		PeriodicTask(ObjBindMethod(this, "updateSettingsMenu"), 10000, kLowPriority).start()
	}

	createGui(configuration) {
		local workbench := this
		local compound, simulators, simulator, car, track, weather, choices, chosen, schema
		local x, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, w12, w3
		local airTemperature, trackTemperature
		local workbenchGui, workbenchTab

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		closeWorkbench(*) {
			ExitApp(0)
		}

		chooseSimulator(*) {
			workbench.loadSimulator(workbenchGui["simulatorDropDown"].Text)
		}

		chooseCar(*) {
			workbench.loadCar(workbench.getCars(workbench.SelectedSimulator)[workbenchGui["carDropDown"].Value])
		}

		chooseTrack(*) {
			local simulator := workbench.SelectedSimulator
			local tracks := workbench.getTracks(simulator, workbench.SelectedCar)
			local trackNames := collect(tracks, ObjBindMethod(SessionDatabase, "getTrackName", simulator))

			workbench.loadTrack(tracks[inList(trackNames, workbenchGui["trackDropDown"].Text)])
		}

		chooseWeather(*) {
			workbench.loadWeather(kWeatherConditions[workbenchGui["weatherDropDown"].Value])
		}

		updateTemperatures(*) {
			this.iAirTemperature := workbenchGui["airTemperatureEdit"].Text
			this.iTrackTemperature := workbenchGui["trackTemperatureEdit"].Text
		}

		chooseDataType(*) {
			local dataTypeDropDown := workbenchGui["dataTypeDropDown"].Value
			local msgResult

			if (dataTypeDropDown > 2) {
				if ((dataTypeDropDown = 4) && (workbench.SelectedSimulator && workbench.SelectedCar && workbench.SelectedTrack)) {
					OnMessage(0x44, translateYesNoButtons)
					msgResult := MsgBox(translate("Entries with lap times or fuel consumption outside the standard deviation will be deleted. Do you want to proceed?")
									  , translate("Delete"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes") {
						TelemetryDatabase(workbench.SelectedSimulator , workbench.SelectedCar, workbench.SelectedTrack
										, workbench.SelectedDrivers).cleanupData(workbench.SelectedWeather, workbench.SelectedCompound
																			   , workbench.SelectedCompoundColor, workbench.SelectedDrivers)

						workbench.loadDataType(workbench.SelectedDataType, true, true)

						workbench.loadCompound(workbench.AvailableCompounds[workbenchGui["compoundDropDown"].Value], true)
					}
				}

				workbenchGui["dataTypeDropDown"].Choose(inList(["Electronics", "Tyres"], workbench.SelectedDataType))
			}
			else
				workbench.loadDataType(["Electronics", "Tyres"][dataTypeDropDown], true)
		}

		chooseDriver(*) {
			workbench.loadDriver((workbenchGui["driverDropDown"].Value = 1) ? true : workbench.AvailableDrivers[workbenchGui["driverDropDown"].Value - 1])
		}

		chooseCompound(*) {
			workbench.loadCompound(workbench.AvailableCompounds[workbenchGui["compoundDropDown"].Value])
		}

		chooseAxis(*) {
			workbench.loadChart(workbench.SelectedChartType)
		}

		chooseChartSource(*) {
			local chartSourceDropDown := workbenchGui["chartSourceDropDown"].Value

			if (chartSourceDropDown = 1)
				workbenchGui["chartTypeDropDown"].Visible := true
			else
				workbenchGui["chartTypeDropDown"].Visible := false

			workbench.ChartViewer.document.open()
			workbench.ChartViewer.document.write((chartSourceDropDown = 1) ? workbench.iTelemetryChartHTML : workbench.iStrategyChartHTML)
			workbench.ChartViewer.document.close()
		}

		chooseChartType(*) {
			workbench.loadChart(["Scatter", "Bar", "Bubble", "Line"][workbenchGui["chartTypeDropDown"].Value])
		}

		settingsMenu(*) {
			workbench.chooseSettingsMenu(workbenchGui["settingsMenuDropDown"].Value)

			workbenchGui["settingsMenuDropDown"].Choose(1)
		}

		simulationMenu(*) {
			workbench.chooseSimulationMenu(workbenchGui["simulationMenuDropDown"].Value)

			workbenchGui["simulationMenuDropDown"].Choose(1)
		}

		strategyMenu(*) {
			workbench.chooseStrategyMenu(workbenchGui["strategyMenuDropDown"].Value)

			workbenchGui["strategyMenuDropDown"].Choose(1)
		}

		chooseSessionType(*) {
			workbench.selectSessionType(["Duration", "Laps"][workbenchGui["sessionTypeDropDown"].Value])
		}

		choosePitstopRule(*) {
			workbench.updateState()
		}

		updatePitstopRule(*) {
			workbench.validatePitstopRule()
		}

		chooseTyreSet(listView, line, *) {
			local compound := listView.GetText(line, 1)
			local count := listView.GetText(line, 2)

			if line {
				if compound
					compound := normalizeCompound(compound)

				workbenchGui["tyreSetDropDown"].Choose(inList(collect(workbench.TyreCompounds, translate), compound))
				workbenchGui["tyreSetCountEdit"].Text := count

				workbench.updateState()
			}
		}

		updateTyreSet(*) {
			local row

			row := workbench.TyreSetListView.GetNext(0)

			if (row > 0) {
				workbench.TyreSetListView.Modify(row, "", collect(workbench.TyreCompounds, translate)[workbenchGui["tyreSetDropDown"].Value]
														, workbenchGui["tyreSetCountEdit"].Text)

				workbench.TyreSetListView.ModifyCol()
			}
		}

		addTyreSet(*) {
			local index := inList(workbench.TyreCompounds, normalizeCompound("Dry"))

			if !index
				index := 1

			workbench.TyreSetListView.Add("", collect(workbench.TyreCompounds, translate)[index], 99)
			workbench.TyreSetListView.Modify(workbench.TyreSetListView.GetCount(), "Select Vis")

			workbench.TyreSetListView.ModifyCol()

			workbenchGui["tyreSetDropDown"].Choose(index)
			workbenchGui["tyreSetCountEdit"].Value := 99

			workbench.updateState()
		}

		deleteTyreSet(*) {
			local index := workbench.TyreSetListView.GetNext(0)

			if (index > 0)
				workbench.TyreSetListView.Delete(index)

			workbench.updateState()
		}

		chooseRefuelService(*) {
			workbenchGui["pitstopFuelServiceLabel"].Text := translate(["Seconds", "Seconds (Refuel of 10 liters)"][workbenchGui["pitstopFuelServiceRuleDropdown"].Value])
		}

		validateFloat(field, minValue := 0.0) {
			local value

			field := workbenchGui[field]
			value := internalValue("Float", field.Text)

			if (isNumber(value) && (value >= minValue))
				field.ValidText := field.Text
			else {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : minValue)

				loop 10
					SendInput("{Right}")
			}
		}

		validateInteger(field, minValue := 0) {
			field := workbenchGui[field]

			if (isInteger(field.Text) && (field.Text >= minValue))
				field.ValidText := field.Text
			else {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : minValue)

				loop 10
					SendInput("{Right}")
			}
		}

		validateSimMaxTyreLaps(*) {
			validateInteger("simMaxTyreLapsEdit", 10)
		}

		validateSimInitialFuelAmount(*) {
			validateInteger("simInitialFuelAmountEdit", 0)
		}

		validateSimAvgLapTime(*) {
			validateFloat("simAvgLapTimeEdit", 10.0)
		}

		validateSimFuelConsumption(*) {
			validateFloat("simFuelConsumptionEdit", 0.1)
		}

		validatePitstopFuelService(*) {
			validateFloat("pitstopFuelServiceEdit", 1.0)
		}

		validateFuelCapacity(*) {
			validateFloat("fuelCapacityEdit", 5.0)
		}

		chooseSimDriver(listView, line, *) {
			if (line > 0) {
				local driver := workbench.DriversListView.GetText(line, 2)
				local ignore, id

				for ignore, id in workbench.AvailableDrivers
					if (SessionDatabase.getDriverName(workbench.SelectedSimulator, id) = driver) {
						workbenchGui["simDriverDropDown"].Choose(A_Index)

						break
					}

				workbench.updateState()
			}
		}

		updateSimDriver(*) {
			local row := workbench.DriversListView.GetNext(0)
			local simDriverDropDown := workbenchGui["simDriverDropDown"].Value
			local driver

			if (row > 0) {


				if ((simDriverDropDown == 0) || (simDriverDropDown > workbench.AvailableDrivers.Length))
					driver := false
				else
					driver := workbench.AvailableDrivers[simDriverDropDown]

				workbench.DriversListView.Modify(row, "Col2", SessionDatabase.getDriverName(workbench.SelectedSimulator, driver))

				if ((simDriverDropDown > 0) && driver)
					if (workbench.StintDrivers.Length >= row)
						workbench.StintDrivers[row] := driver
					else
						workbench.StintDrivers.Push(driver)
			}
		}

		addSimDriver(*) {
			local row := workbench.DriversListView.GetNext(0)
			local msgResult, numRows, driver, translator

			if row {
				translator := translateMsgBoxButtons.Bind(["Before", "After", "Cancel"])

				OnMessage(0x44, translator)
				msgResult := MsgBox(translate("Do you want to add the new entry before or after the currently selected entry?"), translate("Insert"), 262179)
				OnMessage(0x44, translator, 0)

				if (msgResult = "Cancel")
					return

				if (msgResult = "No")
					row += 1

				workbench.DriversListView.Insert(row, "Select", "", "")
				workbench.DriversListView.Modify(row, "Vis")
			}
			else {
				workbench.DriversListView.Modify(workbench.DriversListView.Add("Select", "", ""), "Vis")

				row := workbench.DriversListView.GetCount()
			}

			numRows := workbench.DriversListView.GetCount()

			loop numRows
				workbench.DriversListView.Modify(A_Index, "Col1", ((A_Index == numRows) ? (A_Index . "+") : A_Index))

			driver := workbench.AvailableDrivers[1]

			if (row > workbench.StintDrivers.Length)
				workbench.StintDrivers.Push(driver)
			else
				workbench.StintDrivers.InsertAt(row, driver)

			workbench.DriversListView.Modify(row, "Col2", SessionDatabase.getDriverName(workbench.SelectedSimulator, driver))

			workbenchGui["simDriverDropDown"].Choose(inList(workbench.AvailableDrivers, driver))

			workbench.updateState()
		}

		deleteSimDriver(*) {
			local row, msgResult, numRows

			row := workbench.DriversListView.GetNext(0)

			if row {
				OnMessage(0x44, translateYesNoButtons)
				msgResult := MsgBox(translate("Do you really want to delete the selected driver?"), translate("Delete"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes") {
					workbench.DriversListView.Delete(row)

					workbench.StintDrivers.RemoveAt(row)

					numRows := workbench.DriversListView.GetCount()

					loop numRows
						workbench.DriversListView.Modify(A_Index, "Col1", ((A_Index == numRows) ? (A_Index . "+") : A_Index))

					workbench.updateState()
				}
			}
		}

		chooseSimWeather(listView, line, *) {
			if (line > 0) {
				local time := string2Values(":", workbench.WeatherListView.GetText(line, 1))
				local currentTime := "20200101000000"

				currentTime := DateAdd(currentTime, time[1], "Hours")
				currentTime := DateAdd(currentTime, time[2], "Minutes")

				workbenchGui["simWeatherTimeEdit"].Value := currentTime
				workbenchGui["simWeatherAirTemperatureEdit"].Text := workbench.WeatherListView.GetText(line, 3)
				workbenchGui["simWeatherTrackTemperatureEdit"].Text := workbench.WeatherListView.GetText(line, 4)
				workbenchGui["simWeatherDropDown"].Choose(inList(collect(kWeatherConditions, translate), workbench.WeatherListView.GetText(line, 2)))

				workbench.updateState()
			}
		}

		updateSimWeather(*) {
			local row, time

			row := workbench.WeatherListView.GetNext(0)

			if (row > 0) {
				workbench.WeatherListView.Modify(row, "", FormatTime(workbenchGui["simWeatherTimeEdit"].Value, "HH:mm")
														, translate(kWeatherConditions[workbenchGui["simWeatherDropDown"].Value])
														, workbenchGui["simWeatherAirTemperatureEdit"].Text
														, workbenchGui["simWeatherTrackTemperatureEdit"].Text)

				workbench.WeatherListView.ModifyCol()

				loop 4
					workbench.WeatherListView.ModifyCol(A_Index, "AutoHdr")
			}
		}

		addSimWeather(*) {
			local after := false
			local row, msgResult, translator, lastWeather, lastAirTemperature, lastTrackTemperature, lastTime, currentTime

			row := workbench.WeatherListView.GetNext(0)

			if row {
				lastTime := workbench.WeatherListView.GetText(row, 1)
				lastWeather := kWeatherConditions[inList(collect(kWeatherConditions, translate), workbench.WeatherListView.GetText(row, 2))]
				lastAirTemperature := workbench.WeatherListView.GetText(row, 3)
				lastTrackTemperature := workbench.WeatherListView.GetText(row, 4)

				translator := translateMsgBoxButtons.Bind(["Before", "After", "Cancel"])

				OnMessage(0x44, translator)
				msgResult := MsgBox(translate("Do you want to add the new entry before or after the currently selected entry?"), translate("Insert"), 262179)
				OnMessage(0x44, translator, 0)

				if (msgResult = "Cancel")
					return

				if (msgResult = "No") {
					row += 1

					after := true
				}

				workbench.WeatherListView.Insert(row, "Select", "", "")
				workbench.WeatherListView.Modify(row, "Vis")
			}
			else {
				row := workbench.WeatherListView.GetCount()

				if row {
					lastTime := workbench.WeatherListView.GetText(row, 1)
					lastWeather := kWeatherConditions[inList(collect(kWeatherConditions, translate), workbench.WeatherListView.GetText(row, 2))]
					lastAirTemperature := workbench.WeatherListView.GetText(row, 3)
					lastTrackTemperature := workbench.WeatherListView.GetText(row, 4)
				}
				else {
					lastWeather := workbench.SelectedWeather
					lastAirTemperature := workbench.AirTemperature
					lastTrackTemperature := workbench.TrackTemperature
					lastTime := "00:00"
				}

				workbench.WeatherListView.Modify(workbench.WeatherListView.Add("Select", "", ""), "Vis")

				row += 1
			}

			lastTime := string2Values(":", lastTime)

			currentTime := "20200101000000"

			currentTime := DateAdd(currentTime, lastTime[1], "Hours")
			currentTime := DateAdd(currentTime, lastTime[2], "Minutes")

			if after
				currentTime := DateAdd(currentTime, 1, "Hours")
			else if (workbench.WeatherListView.GetCount() > 1)
				currentTime := DateAdd(currentTime, -30, "Minutes")

			workbenchGui["simWeatherTimeEdit"].Value := currentTime
			workbenchGui["simWeatherAirTemperatureEdit"].Value := lastAirTemperature
			workbenchGui["simWeatherTrackTemperatureEdit"].Value := lastTrackTemperature
			workbenchGui["simWeatherDropDown"].Choose(inList(kWeatherConditions, lastWeather))

			currentTime := FormatTime(currentTime, "HH:mm")

			workbench.WeatherListView.Modify(row, "", currentTime, translate(lastWeather), lastAirTemperature, lastTrackTemperature)

			loop 4
				workbench.WeatherListView.ModifyCol(A_Index, "AutoHdr")

			workbench.updateState()
		}

		deleteSimWeather(*) {
			local row, msgResult

			row := workbench.WeatherListView.GetNext(0)

			if row {
				OnMessage(0x44, translateYesNoButtons)
				msgResult := MsgBox(translate("Do you really want to delete the selected change of weather?"), translate("Delete"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes") {
					workbench.WeatherListView.Delete(row)

					workbench.updateState()
				}
			}
		}

		runSimulation(*) {
			local selectStrategy := GetKeyState("Ctrl")

			workbench.runSimulation()

			if selectStrategy
				workbench.chooseSimulationMenu(5)
		}

		workbenchGui := Window({Descriptor: "Strategy Workbench", Resizeable: true, Closeable: true})

		this.iWindow := workbenchGui

		this.iTelemetryChartHTML := substituteVariables("<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>", {backColor: workbenchGui.AltBackColor})
		this.iStrategyChartHTML := this.iTelemetryChartHTML

		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Text", "w1334 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(workbenchGui, "Strategy Workbench"))

		workbenchGui.SetFont("s9 Norm", "Arial")

		workbenchGui.Add("Documentation", "x608 YP+20 w134 Center H:Center", translate("Strategy Workbench")
					   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development")

		workbenchGui.Add("Text", "x8 yp+30 w1350 0x10 W:Grow")

		workbenchGui.SetFont("Norm")
		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x16 yp+12 w30 h30 Section", kIconsDirectory . "Sensor.ico")
		workbenchGui.Add("Text", "x50 yp+5 w80 h26", translate("Telemetry"))

		workbenchGui.SetFont("s8 Norm", "Arial")

		workbenchGui.Add("Text", "x16 yp+32 w70 h23 +0x200", translate("Simulator"))

		simulators := this.getSimulators()
		simulator := 0

		if (simulators.Length > 0) {
			if this.SelectedSimulator
				simulator := inList(simulators, this.SelectedSimulator)

			if (simulator == 0)
				simulator := 1
		}

		workbenchGui.Add("DropDownList", "x90 yp w290 W:Grow(0.1) Choose" . simulator . " vsimulatorDropDown", simulators).OnEvent("Change", chooseSimulator)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		workbenchGui.Add("Text", "x16 yp+24 w70 h23 +0x200", translate("Car"))
		workbenchGui.Add("DropDownList", "x90 yp w290 W:Grow(0.1) vcarDropDown").OnEvent("Change", chooseCar)

		workbenchGui.Add("Text", "x16 yp24 w70 h23 +0x200", translate("Track"))
		workbenchGui.Add("DropDownList", "x90 yp w290 W:Grow(0.1) vtrackDropDown").OnEvent("Change", chooseTrack)

		workbenchGui.Add("Text", "x16 yp+24 w70 h23 +0x200", translate("Conditions"))

		weather := this.SelectedWeather
		choices := collect(kWeatherConditions, translate)
		chosen := inList(kWeatherConditions, weather)

		if (!chosen && (choices.Length > 0)) {
			weather := choices[1]
			chosen := 1
		}

		workbenchGui.Add("DropDownList", "x90 yp w120 W:Grow(0.1) Choose" . chosen . "  vweatherDropDown", choices).OnEvent("Change", chooseWeather)

		workbenchGui.Add("Edit", "x215 yp w40 X:Move(0.1) Number Limit2 vairTemperatureEdit", this.AirTemperature).OnEvent("Change", updateTemperatures)
		workbenchGui.Add("UpDown", "x242 yp-2 w18 h20 X:Move(0.1) Range0-99", this.AirTemperature)
		workbenchGui.Add("Edit", "x262 yp w40 X:Move(0.1) Number Limit2 vtrackTemperatureEdit", this.TrackTemperature).OnEvent("Change", updateTemperatures)
		workbenchGui.Add("UpDown", "x289 yp w18 h20 X:Move(0.1) Range0-99", this.TrackTemperature)
		workbenchGui.Add("Text", "x304 yp w90 h23 X:Move(0.1) +0x200", translate("Air / Track"))

		workbenchGui.Add("Text", "x16 yp+32 w364 0x10 W:Grow(0.1)")

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("Text", "x16 yp+10 w364 h23 W:Grow(0.1) Center +0x200", translate("Chart"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("DropDownList", "x12 yp+28 w76 Choose1 vdataTypeDropDown  +0x200", collect(["Electronics", "Tyres", "-----------------", "Cleanup Data"], translate)).OnEvent("Change", chooseDataType)

		this.iDataListView := workbenchGui.Add("ListView", "x12 yp+24 w170 h263 W:Grow(0.1) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "Map", "#"], translate))
		this.iDataListView.OnEvent("Click", noSelect)
		this.iDataListView.OnEvent("DoubleClick", noSelect)

		workbenchGui.Add("Text", "x195 yp w70 h23 X:Move(0.1) +0x200", translate("Driver"))
		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) vdriverDropDown").OnEvent("Change", chooseDriver)

		compound := this.SelectedCompound[true]
		choices := collect([normalizeCompound("Dry")], translate)
		chosen := inList([normalizeCompound("Dry")], compound)

		if (!chosen && (choices.Length > 0)) {
			compound := choices[1]
			chosen := 1
		}

		workbenchGui.Add("Text", "x195 yp+24 w70 h23 X:Move(0.1) +0x200", translate("Compound"))
		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) Choose" . chosen . "  vcompoundDropDown", choices).OnEvent("Change", chooseCompound)

		workbenchGui.Add("Text", "x195 yp+28 w70 h23 X:Move(0.1) +0x200", translate("X-Axis"))

		schema := filterSchema(TelemetryDatabase().getSchema("Electronics", true))

		chosen := inList(schema, "Map")

		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) Choose" . chosen . " vdataXDropDown", schema).OnEvent("Change", chooseAxis)

		workbenchGui.Add("Text", "x195 yp+24 w70 h23 X:Move(0.1) +0x200", translate("Series"))

		chosen := inList(schema, "Fuel.Consumption")

		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) Choose" . chosen . " vdataY1DropDown", schema).OnEvent("Change", chooseAxis)

		schema := concatenate([translate("None")], schema)

		workbenchGui.Add("DropDownList", "x250 yp+24 w130 X:Move(0.1) Choose1 vdataY2DropDown", schema).OnEvent("Change", chooseAxis)
		workbenchGui.Add("DropDownList", "x250 yp+24 w130 X:Move(0.1) Choose1 vdataY3DropDown", schema).OnEvent("Change", chooseAxis)

		workbenchGui.Add("Text", "x400 ys w40 h23 X:Move(0.1) +0x200", translate("Chart"))
		workbenchGui.Add("DropDownList", "x444 yp w80 X:Move(0.1) Choose1 +0x200 vchartSourceDropDown", collect(["Telemetry", "Comparison"], translate)).OnEvent("Change", chooseChartSource)
		workbenchGui.Add("DropDownList", "x529 yp w80 X:Move(0.1) Choose1 vchartTypeDropDown", collect(["Scatter", "Bar", "Bubble", "Line"], translate)).OnEvent("Change", chooseChartType)

		this.iChartViewer := workbenchGui.Add("HTMLViewer", "x400 yp+24 w950 h442 Border vchartViewer X:Move(0.1) W:Grow(0.9)")

		workbenchGui.Add("Text", "x8 yp+450 w1350 0x10 W:Grow")

		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x16 yp+10 w30 h30 Section", kIconsDirectory . "Strategy.ico")
		workbenchGui.Add("Text", "x50 yp+5 w80 h26", translate("Strategy"))

		workbenchGui.SetFont("s8 Norm", "Arial")

		workbenchGui.Add("DropDownList", "x250 yp-2 w180 Choose1 +0x200 VsettingsMenuDropDown").OnEvent("Change", settingsMenu)

		this.updateSettingsMenu()

		workbenchGui.Add("DropDownList", "x435 yp w180 Choose1 +0x200 VsimulationMenuDropDown", collect(["Simulation", "---------------------------------------------", "Run Simulation", "---------------------------------------------", "Use as Strategy..."], translate)).OnEvent("Change", simulationMenu)

		workbenchGui.Add("DropDownList", "x620 yp w180 Choose1 +0x200 VstrategyMenuDropDown", collect(["Strategy", "---------------------------------------------", "Load current Race Strategy", "Load Strategy...", "Save Strategy...", "---------------------------------------------", "Compare Strategies...", "---------------------------------------------", "Set as Race Strategy", "Clear Race Strategy"], translate)).OnEvent("Change", strategyMenu)

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("Text", "x619 ys+39 w80 h21", translate("Strategy"))
		workbenchGui.Add("Text", "x700 yp+7 w646 0x10 W:Grow")

		workbenchGui.Add("HTMLViewer", "x619 yp+14 w727 h193 Border vstratViewer H:Grow W:Grow")

		this.iStrategyViewer := StrategyViewer(workbenchGui, workbenchGui["stratViewer"])

		this.showStrategyInfo(false)

		workbenchGui.SetFont("Norm", "Arial")

		/*
		workbenchGui.Add("Text", "x8 y816 w1350 0x10 Y:Move W:Grow")

		workbenchGui.Add("Button", "x649 y824 w80 h23 Y:Move H:Center", translate("Close")).OnEvent("Click", closeWorkbench)
		*/

		workbenchTab := workbenchGui.Add("Tab3", "x16 ys+39 w593 h216 H:Grow -Wrap Section", collect(["Rules && Settings", "Pitstop && Service", "Drivers", "Weather", "Simulation", "Strategy"], translate))

		workbenchTab.UseTab(1)

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

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x24 ys+34 w209 h171", translate("Race"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("DropDownList", "x" . x0 . " yp+21 w70 Choose1  VsessionTypeDropDown", collect(["Duration", "Laps"], translate)).OnEvent("Change", chooseSessionType)
		workbenchGui.Add("Edit", "x" . x1 . " yp w50 h20 Limit4 Number VsessionLengthEdit", 60)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range1-9999 0x80", 60)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w60 h20 VsessionLengthLabel", translate("Minutes"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w75 h23 +0x200", translate("Max. Stint"))
		workbenchGui.Add("Edit", "x" . x1 . " yp w50 h20 Limit4 Number VstintLengthEdit", 70)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range1-9999 0x80", 70)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w60 h20", translate("Minutes"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w75 h23 +0x200", translate("Formation"))
		workbenchGui.Add("CheckBox", "x" . x1 . " yp-1 w17 h23 Checked VformationLapCheck")
		workbenchGui.Add("Text", "x" . x4 . " yp+5 w50 h20", translate("Lap"))

		workbenchGui.Add("Text", "x" . x . " yp+19 w75 h23 +0x200", translate("Post Race"))
		workbenchGui.Add("CheckBox", "x" . x1 . " yp-1 w17 h23 Checked VpostRaceLapCheck")
		workbenchGui.Add("Text", "x" . x4 . " yp+5 w50 h20", translate("Lap"))

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x243 ys+34 w354 h171", translate("Pitstop"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x5 . " yp+23 w75 h20", translate("Pitstop"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp-4 w80 Choose3 VpitstopRequirementsDropDown", collect(["Optional", "Required", "Window"], translate)).OnEvent("Change", choosePitstopRule)
		workbenchGui.Add("Edit", "x" . x11 . " yp+1 w50 h20 VpitstopWindowEdit", "25 - 35").OnEvent("Change", updatePitstopRule)
		workbenchGui.Add("Text", "x" . x12 . " yp+3 w120 h20 VpitstopWindowLabel", translate("Minute (From - To)"))

		workbenchGui.Add("Text", "x" . x5 . " yp+22 w75 h23 +0x200 VrefuelRequirementsLabel", translate("Refuel"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp w80 Choose2 VrefuelRequirementsDropDown", collect(["Optional", "Required", "Always", "Disallowed"], translate))

		workbenchGui.Add("Text", "x" . x5 . " yp+26 w75 h23 +0x200 VtyreChangeRequirementsLabel", translate("Tyre Change"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp w80 Choose2 VtyreChangeRequirementsDropDown", collect(["Optional", "Required", "Always", "Disallowed"], translate))

		workbenchGui.Add("Text", "x" . x5 . " yp+26 w75 h23 +0x200", translate("Tyre Sets"))

		w12 := (x11 + 50 - x7)

		this.iTyreSetListView := workbenchGui.Add("ListView", "x" . x7 . " yp w" . w12 . " h65 -Multi -Hdr -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "#"], translate))
		this.iTyreSetListView.OnEvent("Click", chooseTyreSet)

		x13 := (x7 + w12 + 5)

		workbenchGui.Add("DropDownList", "x" . x13 . " yp w116 Choose0 vtyreSetDropDown", [translate(normalizeCompound("Dry"))]).OnEvent("Change", updateTyreSet)
		workbenchGui.Add("Edit", "x" . x13 . " yp+24 w40 h20 Limit2 Number vtyreSetCountEdit").OnEvent("Change", updateTyreSet)
		workbenchGui.Add("UpDown", "x" . x13 . " yp w18 h20 0x80 Range0-99")

		x13 := (x7 + w12 + 5 + 116 - 48)

		workbenchGui.Add("Button", "x" . x13 . " yp+18 w23 h23 Center +0x200 vtyreSetAddButton").OnEvent("Click", addTyreSet)
		setButtonIcon(workbenchGui["tyreSetAddButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")

		x13 += 25

		workbenchGui.Add("Button", "x" . x13 . " yp w23 h23 Center +0x200 vtyreSetDeleteButton").OnEvent("Click", deleteTyreSet)
		setButtonIcon(workbenchGui["tyreSetDeleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		workbenchTab.UseTab(2)

		x := 32
		x0 := x - 4
		x1 := x + 114
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x24 ys+34 w410 h171", translate("Pitstop"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w105 h20 +0x200", translate("Pitlane Delta"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Limit2 Number VpitstopDeltaEdit", 60)
		workbenchGui.Add("UpDown", "x" . x2 . " yp w18 h20 0x80 Range0-99", 60)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20", translate("Seconds (Drive through - Drive by)"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w85 h20 +0x200", translate("Tyre Service"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Limit2 Number VpitstopTyreServiceEdit", 30)
		workbenchGui.Add("UpDown", "x" . x2 . " yp w18 h20 0x80 Range0-99", 30)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20", translate("Seconds (Change four tyres)"))

		workbenchGui.Add("DropDownList", "x" . x0 . " yp+20 w110 Choose2 VpitstopFuelServiceRuleDropdown", collect(["Refuel Fixed", "Refuel Dynamic"], translate)).OnEvent("Change", chooseRefuelService)

		workbenchGui.Add("Edit", "x" . x1 . " yp w50 h20 VpitstopFuelServiceEdit", displayValue("Float", 1.2)).OnEvent("Change", validatePitstopFuelService)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20 VpitstopFuelServiceLabel", translate("Seconds (Refuel of 10 liters)"))

		workbenchGui.Add("Text", "x" . x . " yp+24 w160 h23", translate("Service"))
		workbenchGui.Add("DropDownList", "x" . x1 . " yp-3 w100 Choose1 vpitstopServiceDropDown", collect(["Simultaneous", "Sequential"], translate))

		workbenchGui.Add("Text", "x" . x . " yp+27 w85 h20 +0x200", translate("Fuel Capacity"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 VfuelCapacityEdit", displayValue("Float", convertUnit("Volume", 125))).OnEvent("Change", validateFuelCapacity)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20", getUnit("Volume", true))

		workbenchGui.Add("Text", "x" . x . " yp+19 w85 h23 +0x200", translate("Safety Fuel"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w50 h20 Number Limit2 VsafetyFuelEdit", displayValue("Float", convertUnit("Volume", 5), 0))
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99", displayValue("Float", convertUnit("Volume", 5), 0))
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w130 h20", getUnit("Volume", true))

		workbenchTab.UseTab(3)

		x := 32
		x2 := x + 220
		x3 := x2 + 100
		w3 := 140
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		this.iDriversListView := workbenchGui.Add("ListView", "x24 ys+34 w216 h171 H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Stint", "Driver"], translate))
		this.iDriversListView.OnEvent("Click", chooseSimDriver)
		this.iDriversListView.OnEvent("DoubleClick", chooseSimDriver)

		workbenchGui.Add("Text", "x" . x2 . " ys+34 w90 h23 +0x200", translate("Driver"))
		workbenchGui.Add("DropDownList", "x" . x3 . " yp w" . w3 . " vsimDriverDropDown").OnEvent("Change", updateSimDriver)

		workbenchGui.Add("Button", "x" . x4 . " yp+30 w23 h23 Center +0x200 vaddDriverButton").OnEvent("Click", addSimDriver)
		setButtonIcon(workbenchGui["addDriverButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		workbenchGui.Add("Button", "x" . x5 . " yp w23 h23 Center +0x200 vdeleteDriverButton").OnEvent("Click", deleteSimDriver)
		setButtonIcon(workbenchGui["deleteDriverButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		workbenchTab.UseTab(4)

		x := 32
		x2 := x + 220
		x3 := x2 + 70
		w3 := 100
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		x6 := x3 + w3 + 5
		x7 := x6 + 47
		x8 := x7 + 52

		this.iWeatherListView := workbenchGui.Add("ListView", "x24 ys+34 w216 h171 H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Time", "Weather", "T Air", "T Track"], translate))
		this.iWeatherListView.OnEvent("Click", chooseSimWeather)
		this.iWeatherListView.OnEvent("DoubleClick", chooseSimWeather)

		workbenchGui.Add("Text", "x" . x2 . " ys+34 w70 h23 +0x200", translate("Time"))
		workbenchGui.Add("DateTime", "x" . x3 . " yp w50 h23 vsimWeatherTimeEdit  1", "HH:mm").OnEvent("Change", updateSimWeather)

		workbenchGui.Add("Text", "x" . x2 . " yp+24 w70 h23 +0x200", translate("Weather"))
		workbenchGui.Add("DropDownList", "x" . x3 . " yp w" . w3 . " vsimWeatherDropDown", collect(kWeatherConditions, translate)).OnEvent("Change", updateSimWeather)

		workbenchGui.Add("Edit", "x" . x6 . " yp w40 Number Limit2 vsimWeatherAirTemperatureEdit").OnEvent("Change", updateSimWeather)
		workbenchGui.Add("UpDown", "x" . x6 . " yp-2 w18 h20 Range0-99", this.AirTemperature)
		workbenchGui.Add("Edit", "x" . x7 . " yp w40 Number Limit2 vsimWeatherTrackTemperatureEdit").OnEvent("Change", updateSimWeather)
		workbenchGui.Add("UpDown", "x" . x7 . " yp w18 h20 Range0-99", this.TrackTemperature)
		workbenchGui.Add("Text", "x" . x8 . " yp w70 h23 +0x200", translate("Air / Track"))

		workbenchGui.Add("Button", "x" . x8 . " yp+30 w23 h23 Center +0x200 vaddSimWeatherButton").OnEvent("Click", addSimWeather)
		setButtonIcon(workbenchGui["addSimWeatherButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		workbenchGui.Add("Button", "xp+25 yp w23 h23 Center +0x200 vdeleteSimWeatherButton").OnEvent("Click", deleteSimWeather)
		setButtonIcon(workbenchGui["deleteSimWeatherButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		workbenchTab.UseTab(5)

		x := 32
		x0 := x - 4
		x1 := x + 74
		x2 := x1 + 22
		x3 := x2 + 28
		x4 := x1 + 16
		x5 := x3 + 44

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x24 ys+34 w179 h171", translate("Initial Conditions"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w85 h23 +0x200", translate("Compound"))

		compound := this.SelectedCompound[true]
		choices := [translate(normalizeCompound("Dry"))]
		chosen := (normalizeCompound("Dry") = compound)

		if (!chosen && (choices.Length > 0)) {
			compound := choices[1]
			chosen := 1
		}

		workbenchGui.Add("DropDownList", "x" . x1 . " yp w84 Choose" . chosen . " VsimCompoundDropDown", choices)

		workbenchGui.Add("Text", "x" . x . " yp+25 w70 h20 +0x200", translate("Tyre Usage"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w45 h20 Number Limit3 VsimMaxTyreLapsEdit", 40).OnEvent("Change", validateSimMaxTyreLaps)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range1-999", 40)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w45 h20", translate("Laps"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w70 h20 +0x200", translate("Initial Fuel"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w45 h20 Number Limit3 VsimInitialFuelAmountEdit", displayValue("Float", convertUnit("Volume", 90), 0)).OnEvent("Change", validateSimInitialFuelAmount)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-999", displayValue("Float", convertUnit("Volume", 90), 0))
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w45 r1", getUnit("Volume", true))

		workbenchGui.Add("Text", "x" . x . " yp+21 w70 h20 +0x200", translate("Map"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w45 h20 Number Limit2 VsimMapEdit", 1)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99", 1)

		workbenchGui.Add("Text", "x" . x . " yp+23 w85 h23 +0x200", translate("Avg. Lap Time"))
		workbenchGui.Add("Edit", "x" . x1 . " yp w45 h20 VsimAvgLapTimeEdit", displayValue("Float", 120.0)).OnEvent("Change", validateSimAvgLapTime)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w30 h20", translate("Sec."))

		workbenchGui.Add("Text", "x" . x . " yp+21 w85 h20 +0x200", translate("Consumption"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-2 w45 h20 VsimFuelConsumptionEdit", displayValue("Float", convertUnit("Volume", 3.8))).OnEvent("Change", validateSimFuelConsumption)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w45 r1", getUnit("Volume", true))

		x := 222
		x0 := x - 4
		x1 := x + 104
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16
		x5 := x + 50

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x214 ys+34 w174 h120", translate("Optimizer"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w100 h20 +0x200", translate("Consumption"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-10 ToolTip VsimConsumptionVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Initial Fuel"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimInitialFuelVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Tyre Usage"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimTyreUsageVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Tyre Compound"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimtyreCompoundVariation", 0)

		workbenchGui.Add("Text", "x214 yp+30 w40 h23 +0x200", translate("Use"))

		choices := collect(["Initial Conditions", "Telemetry Data", "Initial Cond. + Telemetry"], translate)

		workbenchGui.Add("DropDownList", "x250 yp w138 Choose2 VsimInputDropDown", choices).OnEvent("Change", (*) => this.updateState())

		workbenchGui.Add("Button", "x214 yp+26 w174 h20", translate("Simulate!")).OnEvent("Click", runSimulation)

		x := 407
		x0 := x - 4
		x1 := x + 89
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x399 ys+34 w197 h171", translate("Summary"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w90 h20 +0x200", translate("# Pitstops"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimNumPitstopResult")

		workbenchGui.Add("Text", "x" . x . " yp+23 w90 h20 +0x200", translate("# Tyre Changes"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimNumTyreChangeResult")

		workbenchGui.Add("Text", "x" . x . " yp+23 w90 h20 +0x200", translate("Consumed Fuel"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimConsumedFuelResult")
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w45 r1", getUnit("Volume", true))

		workbenchGui.Add("Text", "x" . x . " yp+21 w90 h20 +0x200", translate("@ Pitlane"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimPitlaneSecondsResult")
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w50 h20", translate("Seconds"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w90 h20 +0x200", translate("@ Finish"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimSessionResultResult")
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w50 h20 VsimSessionResultLabel", translate("Laps"))

		workbenchTab.UseTab(6)

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

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x24 ys+34 w143 h171", translate("Electronics"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w70 h20 +0x200", translate("Map"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Number Limit2 VstrategyStartMapEdit Disabled", 1)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99 Disabled", 1)

		workbenchGui.Add("Text", "x" . x . " yp+25 w70 h20 +0x200", translate("TC"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Number Limit2 VstrategyStartTCEdit Disabled", 1)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99 Disabled", 1)

		workbenchGui.Add("Text", "x" . x . " yp+25 w70 h20 +0x200", translate("ABS"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Number Limit2 VstrategyStartABSEdit Disabled", 2)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99 Disabled", 2)

		x := 186
		x0 := x + 50
		x1 := x + 70
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x178 ys+34 w174 h171", translate("Tyres"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w65 h23 +0x200", translate("Compound"))

		compound := this.SelectedCompound[true]
		choices := collect([normalizeCompound("Dry")], translate)
		chosen := inList([normalizeCompound("Dry")], compound)

		if (!chosen && (choices.Length > 0)) {
			compound := choices[1]
			chosen := 1
		}

		workbenchGui.Add("DropDownList", "x" . x1 . " yp w85 Choose" . chosen . " VstrategyCompoundDropDown Disabled", choices)

		workbenchGui.Add("Text", "x" . x . " yp+26 w85 h20 +0x200", translate("Pressure"))
		workbenchGui.Add("Text", "x" . x0 . " yp w85 h20 +0x200", translate("FL"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-2 w50 h20 VstrategyPressureFLEdit Disabled", displayValue("Float", convertUnit("Pressure", 26.5)))
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w30 h20", getUnit("Pressure"))

		workbenchGui.Add("Text", "x" . x0 . " yp+21 w85 h20 +0x200", translate("FR"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-2 w50 h20 VstrategyPressureFREdit Disabled", displayValue("Float", convertUnit("Pressure", 26.5)))
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w30 h20", getUnit("Pressure"))

		workbenchGui.Add("Text", "x" . x0 . " yp+21 w85 h20 +0x200", translate("RL"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-2 w50 h20 VstrategyPressureRLEdit Disabled", displayValue("Float", convertUnit("Pressure", 26.5)))
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w30 h20", getUnit("Pressure"))

		workbenchGui.Add("Text", "x" . x0 . " yp+21 w85 h20 +0x200", translate("RR"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-2 w50 h20 VstrategyPressureRREdit Disabled", displayValue("Float", convertUnit("Pressure", 26.5)))
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w30 h20", getUnit("Pressure"))

		x := 371
		x0 := x - 4
		x1 := x + 84
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x363 ys+34 w233 h171", translate("Pitstops"))

		workbenchGui.SetFont("Norm", "Arial")

		this.iPitstopListView := workbenchGui.Add("ListView", "x" . x . " yp+21 w216 h139 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Lap", "Driver", "Fuel", "Tyres", "Map"], translate))
		this.iPitstopListView.OnEvent("Click", noSelect)
		this.iPitstopListView.OnEvent("DoubleClick", noSelect)

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add(StrategyWorkbench.WorkbenchResizer(workbenchGui))

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
		local x, y, w, h

		if getWindowPosition("Strategy Workbench", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Strategy Workbench", &w, &h)
			window.Resize("Initialize", w, h)
	}

	showTelemetryChart(drawChartFunction) {
		local before, after, html

		this.ChartViewer.document.open()

		if (drawChartFunction && (drawChartFunction != "")) {
			before := "
			(
			<html>
			    <meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)"

			before := substituteVariables(before, {headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

			after := "
			(
					</script>
				</head>
				<body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: %width%px; height: %height%px"></div>
				</body>
			</html>
			)"

			html := (before . drawChartFunction . substituteVariables(after,  {width: (this.ChartViewer.getWidth() - 4), height: (this.ChartViewer.getHeight() - 4), backColor: this.Window.AltBackColor}))

			this.ChartViewer.document.write(html)
		}
		else {
			html := "<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

			this.ChartViewer.document.write(substituteVariables(html, {backColor: this.Window.AltBackColor}))
		}

		this.iTelemetryChartHTML := html

		this.ChartViewer.document.close()

		this.Control["chartSourceDropDown"].Choose(1)
		this.Control["chartTypeDropDown"].Visible := true
	}

	showComparisonChart(html) {
		this.ChartViewer.document.open()
		this.ChartViewer.document.write(html)
		this.ChartViewer.document.close()

		this.iStrategyChartHTML := html

		this.Control["chartSourceDropDown"].Choose(2)
		this.Control["chartTypeDropDown"].Visible := false
	}

	updateState() {
		local oldTChoice, oldFChoice

		if ((this.Control["simInputDropDown"].Value = 1) || (this.Control["simInputDropDown"].Value = 3)) {
			this.Control["simMapEdit"].Enabled := true
			this.Control["simAvgLapTimeEdit"].Enabled := true
			this.Control["simFuelConsumptionEdit"].Enabled := true
		}
		else {
			this.Control["simMapEdit"].Enabled := false
			this.Control["simAvgLapTimeEdit"].Enabled := false
			this.Control["simFuelConsumptionEdit"].Enabled := false
		}

		if (this.TyreSetListView.GetNext(0) > 0) {
			this.Control["tyreSetDropDown"].Enabled := true
			this.Control["tyreSetCountEdit"].Enabled := true
			this.Control["tyreSetDeleteButton"].Enabled := true
		}
		else {
			this.Control["tyreSetDropDown"].Enabled := false
			this.Control["tyreSetCountEdit"].Enabled := false
			this.Control["tyreSetDeleteButton"].Enabled := false

			this.Control["tyreSetDropDown"].Choose(0)
			this.Control["tyreSetCountEdit"].Text := ""
		}

		if (this.Control["pitstopRequirementsDropDown"].Value = 3) {
			this.Control["pitstopWindowEdit"].Visible := true
			this.Control["pitstopWindowLabel"].Visible := true

			this.Control["pitstopWindowLabel"].Text := translate("Minute (From - To)")

			if !InStr(this.Control["pitstopWindowEdit"].Text, "-")
				this.Control["pitstopWindowEdit"].Text := "25 - 35"
		}
		else if (this.Control["pitstopRequirementsDropDown"].Value = 2) {
			this.Control["pitstopWindowEdit"].Visible := true
			this.Control["pitstopWindowLabel"].Visible := true

			this.Control["pitstopWindowLabel"].Text := ""

			if InStr(this.Control["pitstopWindowEdit"].Text, "-")
				this.Control["pitstopWindowEdit"].Text := 1
		}
		else {
			this.Control["pitstopWindowEdit"].Visible := false
			this.Control["pitstopWindowLabel"].Visible := false
		}

		tyreChangeRequirementsDropDown := this.Control["tyreChangeRequirementsDropDown"].Text
		refuelRequirementsDropDown := this.Control["refuelRequirementsDropDown"].Text

		oldTChoice := ["Optional", "Required", "Always", "Disallowed"][this.Control["tyreChangeRequirementsDropDown"].Value]
		oldFChoice := ["Optional", "Required", "Always", "Disallowed"][this.Control["refuelRequirementsDropDown"].Value]

		if (this.Control["pitstopRequirementsDropDown"].Value = 1) {
			this.Control["tyreChangeRequirementsDropDown"].Delete()
			this.Control["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))
			this.Control["refuelRequirementsDropDown"].Delete()
			this.Control["refuelRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))

			oldTChoice := inList(["Optional", "Always", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Always", "Disallowed"], oldFChoice)
		}
		else {
			this.Control["tyreChangeRequirementsDropDown"].Delete()
			this.Control["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))
			this.Control["refuelRequirementsDropDown"].Delete()
			this.Control["refuelRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))

			oldTChoice := inList(["Optional", "Required", "Always", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Required", "Always", "Disallowed"], oldFChoice)
		}

		this.Control["tyreChangeRequirementsDropDown"].Choose(oldTChoice ? oldTChoice : 1)
		this.Control["refuelRequirementsDropDown"].Choose(oldFChoice ? oldFChoice : 1)

		if (this.AvailableDrivers.Length > 0)
			this.Control["addDriverButton"].Enabled := true
		else
			this.Control["addDriverButton"].Enabled := false

		if (this.DriversListView.GetNext(0) && (this.AvailableDrivers.Length > 0)) {
			if (this.AvailableDrivers.Length > 1)
				this.Control["deleteDriverButton"].Enabled := true
			else
				this.Control["deleteDriverButton"].Enabled := false

			this.Control["simDriverDropDown"].Enabled := true
		}
		else {
			this.Control["deleteDriverButton"].Enabled := false
			this.Control["simDriverDropDown"].Enabled := false

			this.Control["simDriverDropDown"].Choose(0)
		}

		this.Control["addSimWeatherButton"].Enabled := true

		if this.WeatherListView.GetNext(0) {
			this.Control["deleteSimWeatherButton"].Enabled := true
			this.Control["simWeatherTimeEdit"].Enabled := true
			this.Control["simWeatherTrackTemperatureEdit"].Enabled := true
			this.Control["simWeatherAirTemperatureEdit"].Enabled := true
			this.Control["simWeatherDropDown"].Enabled := true
		}
		else {
			this.Control["deleteSimWeatherButton"].Enabled := false
			this.Control["simWeatherTimeEdit"].Enabled := false
			this.Control["simWeatherTrackTemperatureEdit"].Enabled := false
			this.Control["simWeatherAirTemperatureEdit"].Enabled := false
			this.Control["simWeatherDropDown"].Enabled := false

			this.Control["simWeatherDropDown"].Choose(0)
			this.Control["simWeatherTimeEdit"].Value := 20200101000000
			this.Control["simWeatherTrackTemperatureEdit"].Text := ""
			this.Control["simWeatherAirTemperatureEdit"].Text := ""
		}
	}

	updateSettingsMenu() {
		local settingsMenu, fileNames, validators, ignore, fileName, validator

		settingsMenu := collect(["Settings", "---------------------------------------------", "Initialize from Strategy", "Initialize from Settings...", "Initialize from Database", "Initialize from Telemetry", "Initialize from Simulation"], translate)

		fileNames := getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\")

		if (fileNames.Length > 0) {
			settingsMenu.Push(translate("---------------------------------------------"))
			settingsMenu.Push(translate("Rules:"))

			validators := []

			for ignore, fileName in fileNames {
				SplitPath(fileName, , , , &validator)

				if !inList(validators, validator) {
					validators.Push(validator)

					if (validator = this.SelectedValidator)
						settingsMenu.Push("(x) " . validator)
					else
						settingsMenu.Push("      " . validator)
				}
			}
		}

		this.Control["settingsMenuDropDown"].Delete()
		this.Control["settingsMenuDropDown"].Add(settingsMenu)

		this.Control["settingsMenuDropDown"].Choose(1)
	}

	createStrategyInfo(strategy) {
		return this.StrategyViewer.createStrategyInfo(strategy)
	}

	createSetupInfo(strategy) {
		return this.StrategyViewer.createSetupInfo(strategy)
	}

	createStintsInfo(strategy, &timeSeries, &lapSeries, &fuelSeries, &tyreSeries) {
		return this.StrategyViewer.createStintsInfo(strategy, &timeSeries, &lapSeries, &fuelSeries, &tyreSeries)
	}

	showStrategyInfo(strategy) {
		this.StrategyViewer.showStrategyInfo(strategy)
	}

	showDataPlot(data, xAxis, yAxises) {
		local drawChartFunction := "function drawChart() {"
		local double := (yAxises.Length > 1)
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
				drawChartFunction .= ("['', " . convertValue(xAxis, value))
			else
				drawChartFunction .= ("[" . convertValue(xAxis, value))

			for ignore, yAxis in yAxises {
				value := values[yAxis]

				if ((value = "n/a") || (isNull(value)))
					value := kNull

				drawChartFunction .= (", " . convertValue(yAxis, value))
			}

			drawChartFunction .= "]"
		}

		drawChartFunction .= "`n]);"

		series := "series: {"
		vAxis := "vAxis: { gridlines: { color: '#" . this.Window.Theme.AlternateBackColor . "' }, "

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
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "', gridlines: { color: '" . this.Window.Theme.AlternateBackColor . "' } }, " . series . ", " . vAxis . "};")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bar") {
			if (minValue = kUndefined)
				minValue := 0

			if (maxValue = kUndefined)
				maxValue := 0

			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: {minValue: " . minValue . ", maxValue: " . maxValue . "} };")
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bubble") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "', viewWindowMode: 'pretty' }, vAxis: { title: '" . translate(yAxises[1]) . "', viewWindowMode: 'pretty' }, colorAxis: { legend: {position: 'none'}, colors: ['blue', 'red'] }, sizeAxis: { maxSize: 15 } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BubbleChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Line") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "' };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}

		this.showTelemetryChart(drawChartFunction)
	}

	getSimulators() {
		return SessionDatabase().getSimulators()
	}

	getCars(simulator) {
		return SessionDatabase().getCars(simulator)
	}

	getTracks(simulator, car) {
		return SessionDatabase().getTracks(simulator, car)
	}

	loadSimulator(simulator, force := false) {
		local drivers, ignore, id, index, car, carNames, cars, settings

		if (force || (simulator != this.SelectedSimulator)) {
			this.iSelectedSimulator := simulator

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Strategy Workbench", "Simulator", simulator)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			this.iAvailableDrivers := SessionDatabase.getAllDrivers(simulator)

			drivers := []

			for ignore, id in this.AvailableDrivers
				drivers.Push(SessionDatabase.getDriverName(simulator, id))

			this.Control["simDriverDropDown"].Delete()
			this.Control["simDriverDropDown"].Add(drivers)
			this.Control["simDriverDropDown"].Choose(0)

			this.Control["driverDropDown"].Delete()

			this.iSelectedDrivers := false

			this.DriversListView.Delete()
			this.DriversListView.Add("", "1+", SessionDatabase.getDriverName(simulator, SessionDatabase.ID))

			this.DriversListView.ModifyCol()
			this.DriversListView.ModifyCol(1, "AutoHdr")
			this.DriversListView.ModifyCol(2, "AutoHdr")

			this.iStintDrivers := [SessionDatabase.ID]

			cars := this.getCars(simulator)
			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := SessionDatabase.getCarName(simulator, car)

			this.Control["simulatorDropDown"].Choose(inList(this.getSimulators(), simulator))

			this.Control["carDropDown"].Delete()
			this.Control["carDropDown"].Add(carNames)

			this.loadCar((cars.Length > 0) ? cars[1] : false, true)
		}
	}

	loadCar(car, force := false) {
		local tracks, settings

		if (force || (car != this.SelectedCar)) {
			this.iSelectedCar := car

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Strategy Workbench", "Car", car)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			tracks := this.getTracks(this.SelectedSimulator, car)

			this.Control["carDropDown"].Choose(inList(this.getCars(this.SelectedSimulator), car))
			this.Control["trackDropDown"].Delete()
			this.Control["trackDropDown"].Add(collect(tracks, ObjBindMethod(SessionDatabase, "getTrackName", this.SelectedSimulator)))

			this.loadTrack((tracks.Length > 0) ? tracks[1] : false, true)
		}
	}

	loadTrack(track, force := false) {
		local simulator, car, settings

		if (force || (track != this.SelectedTrack)) {
			simulator := this.SelectedSimulator
			car := this.SelectedCar

			this.iSelectedTrack := track

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Strategy Workbench", "Track", track)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			this.Control["trackDropDown"].Choose(inList(this.getTracks(simulator, car), track))

			this.loadTyreCompounds(simulator, car, track)

			this.loadWeather(this.SelectedWeather, true)
		}
	}

	loadWeather(weather, force := false) {
		if (force || (this.SelectedWeather != weather)) {
			this.iSelectedWeather := weather

			this.Control["weatherDropDown"].Choose(inList(kWeatherConditions, weather))

			this.loadDataType(this.SelectedDataType, true)
		}
	}

	loadDataType(dataType, force := false, reload := false) {
		local tyreCompound, telemetryDB, ignore, column, categories, field, category, value
		local driverNames, index, names, schema, availableCompounds

		if (force || (this.SelectedDataType != dataType)) {
			this.showTelemetryChart(false)

			this.iSelectedDataType := dataType
			this.iSelectedDrivers := false

			telemetryDB := TelemetryDatabase(this.SelectedSimulator, this.SelectedCar
										   , this.SelectedTrack, this.SelectedDrivers)

			this.DataListView.Delete()

			while this.DataListView.GetCount("Col")
				this.DataListView.DeleteCol(1)

			if (this.SelectedDataType = "Electronics") {
				for ignore, column in collect(["Compound", "Map", "#"], translate)
					this.DataListView.InsertCol(A_Index, "", column)

				categories := telemetryDB.getMapsCount(this.SelectedWeather)
				field := "Map"
			}
			else if (this.SelectedDataType = "Tyres") {
				for ignore, column in collect(["Compound", "Pressure", "#"], translate)
					this.DataListView.InsertCol(A_Index, "", column)

				categories := telemetryDB.getPressuresCount(this.SelectedWeather)
				field := "Tyre.Pressure"
			}

			availableCompounds := []

			for ignore, category in categories {
				value := category[field]

				if (value = "n/a")
					value := translate(value)

				tyreCompound := compound(category["Tyre.Compound"], category["Tyre.Compound.Color"])

				this.DataListView.Add("", translate(tyreCompound), value, category["Count"])

				if !inList(availableCompounds, tyreCompound)
					availableCompounds.Push(tyreCompound)
			}

			this.DataListView.ModifyCol(1, "AutoHdr")
			this.DataListView.ModifyCol(2, "AutoHdr")
			this.DataListView.ModifyCol(3, "AutoHdr")

			this.iAvailableCompounds := availableCompounds

			this.Control["compoundDropDown"].Delete()
			this.Control["compoundDropDown"].Add(collect(availableCompounds, translate))

			this.Control["driverDropDown"].Delete()
			this.Control["dataXDropDown"].Delete()
			this.Control["dataY1DropDown"].Delete()
			this.Control["dataY2DropDown"].Delete()
			this.Control["dataY3DropDown"].Delete()

			if ((availableCompounds.Length > 0) && !reload) {
				driverNames := SessionDatabase.getAllDrivers(this.SelectedSimulator, true)

				for index, names in driverNames
					driverNames[index] := values2String(", ", names*)

				this.Control["driverDropDown"].Add(Array(translate("All"), driverNames*))
				this.Control["driverDropDown"].Choose(1)

				schema := filterSchema(telemetryDB.getSchema(dataType, true))

				this.Control["dataXDropDown"].Add(schema)
				this.Control["dataY1DropDown"].Add(schema)
				this.Control["dataY2DropDown"].Add(Array(translate("None"), schema*))
				this.Control["dataY3DropDown"].Add(Array(translate("None"), schema*))

				if (dataType = "Electronics") {
					this.Control["dataXDropDown"].Choose(inList(schema, "Map"))
					this.Control["dataY1DropDown"].Choose(inList(schema, "Fuel.Consumption"))

					this.Control["dataY2DropDown"].Choose(1)
				}
				else if (dataType = "Tyres") {
					this.Control["dataXDropDown"].Choose(inList(schema, "Tyre.Laps"))
					this.Control["dataY1DropDown"].Choose(inList(schema, "Tyre.Pressure"))
					this.Control["dataY2DropDown"].Choose(inList(schema, "Tyre.Temperature") + 1)
				}

				this.Control["dataY3DropDown"].Choose(1)
			}

			this.loadCompound((availableCompounds.Length > 0) ? availableCompounds[1] : false, true)
		}
	}

	loadDriver(driver, force := false) {
		if (force || (((driver == true) || (driver == false)) && this.SelectedDrivers)
				  || (driver && !this.SelectedDrivers)
				  || (driver && (this.SelectedDrivers && !inList(this.SelectedDrivers, driver)))) {
			if driver {
				this.Control["driverDropDown"].Choose(((driver = true) ? 1 : (inList(this.AvailableDrivers, driver) + 1)))

				this.iSelectedDrivers := ((driver == true) ? false : [driver])
			}
			else {
				this.Control["driverDropDown"].Choose(0)

				this.iSelectedDrivers := false
			}

			if this.SelectedCompound
				this.loadChart(this.SelectedChartType)

			this.updateState()
		}
	}

	loadTyreCompounds(simulator, car, track) {
		local compounds := SessionDatabase().getTyreCompounds(simulator, car, track)
		local translatedCompounds, choices, index, ignore, compound

		this.iTyreCompounds := compounds

		translatedCompounds := collect(compounds, translate)

		this.Control["tyreSetDropDown"].Delete()
		this.Control["tyreSetDropDown"].Add(translatedCompounds)
		this.Control["simCompoundDropDown"].Delete()
		this.Control["simCompoundDropDown"].Add(translatedCompounds)
		this.Control["strategyCompoundDropDown"].Delete()
		this.Control["strategyCompoundDropDown"].Add(translatedCompounds)

		index := inList(compounds, this.SelectedCompound[true])

		if ((index == 0) && (compounds.Length > 0))
			index := 1

		if (index > 0) {
			this.Control["tyreSetDropDown"].Choose(index)
			this.Control["simCompoundDropDown"].Choose(index)
			this.Control["strategyCompoundDropDown"].Choose(index)
		}

		this.TyreSetListView.Delete()

		for ignore, compound in compounds
			this.TyreSetListView.Add("", translate(compound), 99)

		this.TyreSetListView.ModifyCol()
	}

	loadCompound(compound, force := false) {
		local compoundColor

		if compound
			compound := normalizeCompound(compound)

		if (force || (this.SelectedCompound[true] != compound)) {
			if compound {
				this.Control["compoundDropDown"].Choose(inList(this.AvailableCompounds, compound))

				compoundColor := false

				splitCompound(compound, &compound, &compoundColor)

				this.iSelectedCompound := compound
				this.iSelectedCompoundColor := compoundColor

				this.loadChart(this.SelectedChartType)
			}
			else {
				this.Control["compoundDropDown"].Choose(0)

				this.showTelemetryChart(false)

				this.iSelectedCompound := false
				this.iSelectedCompoundColor := false
			}

			this.updateState()
		}
	}

	loadChart(chartType) {
		local telemetryDB, records, schema, xAxis, yAxises

		local compound

		this.iSelectedChartType := chartType

		this.Control["chartTypeDropDown"].Choose(inList(["Scatter", "Bar", "Bubble", "Line"], chartType))

		telemetryDB := TelemetryDatabase(this.SelectedSimulator, this.SelectedCar
									   , this.SelectedTrack, this.SelectedDrivers)

		if (this.SelectedDataType = "Electronics")
			records := telemetryDB.getElectronicEntries(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		else if (this.SelectedDataType = "Tyres")
			records := telemetryDB.getTyreEntries(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		else
			records := []

		schema := filterSchema(telemetryDB.getSchema(this.SelectedDataType, true))

		xAxis := schema[this.Control["dataXDropDown"].Value]
		yAxises := Array(schema[this.Control["dataY1DropDown"].Value])

		if (this.Control["dataY2DropDown"].Value > 1)
			yAxises.Push(schema[this.Control["dataY2DropDown"].Value - 1])

		if (this.Control["dataY3DropDown"].Value > 1)
			yAxises.Push(schema[this.Control["dataY3DropDown"].Value - 1])

		this.showDataPlot(records, xAxis, yAxises)

		this.updateState()
	}

	selectSessionType(sessionType) {
		this.iSelectedSessionType := sessionType

		if (sessionType = "Duration") {
			this.Control["sessionLengthLabel"].Text := translate("Minutes")
			this.Control["simSessionResultLabel"].Text := translate("Laps")
		}
		else {
			this.Control["sessionLengthLabel"].Text := translate("Laps")
			this.Control["simSessionResultLabel"].Text := translate("Seconds")
		}
	}

	chooseSettingsMenu(line) {
		local simulator := this.SelectedSimulator
		local car := this.SelectedCar
		local track := this.SelectedTrack
		local strategy, pitstopRule
		local ignore, descriptor, directory, numPitstops, name, pitstop, tyreCompound, tyreCompoundColor
		local simulator, car, track, simulatorCode, dirName, file, settings, settingsDB
		local telemetryDB, fastestLapTime, row, lapTime, prefix, data, fuelCapacity, initialFuelAmount, map
		local validators, index, fileName, validator, index, forecast, time, hour, minute, value

		protectionOn(true, true)

		try {
			switch line {
				case 3: ; "Load from Strategy"
					if (simulator && car && track) {
						strategy := this.SelectedStrategy

						if strategy {
							this.Control["pitstopDeltaEdit"].Text := strategy.PitstopDelta
							this.Control["pitstopTyreServiceEdit"].Value := strategy.PitstopTyreService

							value := strategy.PitstopFuelService

							if isObject(value) {
								this.Control["pitstopFuelServiceRuleDropDown"].Choose(1 + (value[1] != "Fixed"))

								this.Control["pitstopFuelServiceLabel"].Text := translate(["Seconds", "Seconds (Refuel of 10 liters)"][1 + (value[1] != "Fixed")])

								value := value[2]
							}
							else {
								this.Control["pitstopFuelServiceRuleDropDown"].Choose(2)
								this.Control["pitstopFuelServiceLabel"].Text := translate("Seconds (Refuel of 10 liters)")
							}

							this.Control["pitstopFuelServiceEdit"].Text := displayValue("Float", value)
							this.Control["pitstopServiceDropDown"].Choose((strategy.PitstopServiceOrder = "Simultaneous") ? 1 : 2)
							this.Control["safetyFuelEdit"].Text := displayValue("Float", convertUnit("Volume", strategy.SafetyFuel), 0)
							this.Control["fuelCapacityEdit"].Text := displayValue("Float", convertUnit("Volume", strategy.FuelCapacity))

							this.iSelectedValidator := strategy.Validator

							pitstopRule := strategy.PitstopRule

							if !pitstopRule {
								this.Control["pitstopRequirementsDropDown"].Choose(1)

								value := ""
							}
							else if isObject(pitstopRule) {
								this.Control["pitstopRequirementsDropDown"].Choose(3)

								value := values2String("-", pitstopRule*)
							}
							else {
								this.Control["pitstopRequirementsDropDown"].Choose(2)

								value := pitstopRule
							}

							this.Control["pitstopWindowEdit"].Text := value

							if pitstopRule {
								this.Control["refuelRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"], strategy.RefuelRule))
								this.Control["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"], strategy.TyreChangeRule))
							}
							else {
								this.Control["refuelRequirementsDropDown"].Choose(inList(["Optional", "Always", "Disallowed"], strategy.RefuelRule))
								this.Control["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Always", "Disallowed"], strategy.TyreChangeRule))
							}

							this.TyreSetListView.Delete()

							for ignore, descriptor in strategy.TyreSets
								this.TyreSetListView.Add("", translate(compound(descriptor[1], descriptor[2])), descriptor[3])

							this.TyreSetListView.ModifyCol()

							this.iStintDrivers := []

							numPitstops := strategy.Pitstops.Length

							name := SessionDatabase.getDriverName(simulator, strategy.Driver)

							this.DriversListView.Delete()

							this.DriversListView.Add("", (numPitstops = 0) ? "1+" : 1, name)

							this.StintDrivers.Push((name = "John Doe (JD)") ? false : strategy.Driver)

							for ignore, pitstop in strategy.Pitstops {
								name := SessionDatabase.getDriverName(simulator, pitstop.Driver)

								this.DriversListView.Add("", (numPitstops = A_Index) ? ((A_Index + 1) . "+") : (A_Index + 1), name)

								this.StintDrivers.Push((name = "John Doe (JD)") ? false : pitstop.Driver)
							}

							this.DriversListView.ModifyCol()

							loop 2
								this.DriversListView.ModifyCol(A_Index, "AutoHdr")

							this.WeatherListView.Delete()

							for ignore, forecast in strategy.WeatherForecast {
								time := "20200101000000"
								hour := Floor(forecast[1] / 60)
								minute := (forecast[1] - (hour * 60))

								time := DateAdd(time, hour, "Hours")
								time := DateAdd(time, minute, "Minutes")

								time := FormatTime(time, "HH:mm")

								this.WeatherListView.Add("", time, translate(forecast[2]), forecast[3], forecast[4])
							}

							this.WeatherListView.ModifyCol()

							loop 4
								this.WeatherListView.ModifyCol(A_Index, "AutoHdr")

							if (strategy.SessionType = "Duration") {
								this.Control["sessionTypeDropDown"].Value := 1
								this.Control["sessionLengthLabel"].Text := translate("Minutes")
							}
							else {
								this.Control["sessionTypeDropDown"].Value := 2
								this.Control["sessionLengthLabel"].Text := translate("Laps")
							}

							this.Control["sessionLengthEdit"].Text := Round(strategy.SessionLength)

							this.Control["stintLengthEdit"].Text := strategy.StintLength
							this.Control["formationLapCheck"].Value := strategy.FormationLap
							this.Control["postRaceLapCheck"].Value := strategy.PostRaceLap

							tyreCompound := strategy.TyreCompound
							tyreCompoundColor := strategy.TyreCompoundColor

							this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))

							this.Control["simAvgLapTimeEdit"].Text := displayValue("Float", strategy.AvgLapTime, 1)
							this.Control["simFuelConsumptionEdit"].Text := displayValue("Float", convertUnit("Volume", strategy.FuelConsumption))
							this.Control["simMaxTyreLapsEdit"].Text := Round(strategy.MaxTyreLaps)
							this.Control["simInitialFuelAmountEdit"].Text := displayValue("Float", convertUnit("Volume", strategy.StartFuel), 0)
							this.Control["simMapEdit"].Text := strategy.Map

							this.Control["simConsumptionVariation"].Value := strategy.ConsumptionVariation
							this.Control["simTyreUsageVariation"].Value := strategy.TyreUsageVariation
							this.Control["simtyreCompoundVariation"].Value := strategy.TyreCompoundVariation
							this.Control["simInitialFuelVariation"].Value := strategy.InitialFuelVariation

							if (strategy.UseInitialConditions && strategy.UseTelemetryData)
								value := 3
							else if strategy.UseTelemetryData
								value := 2
							else
								value := 1

							this.Control["simInputDropDown"].Choose(value)

							this.updateState()
							this.updateSettingsMenu()
						}
						else {
							OnMessage(0x44, translateOkButton)
							MsgBox(translate("There is no current Strategy."), translate("Information"), 262192)
							OnMessage(0x44, translateOkButton, 0)
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You must first select a car and a track."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				case 4: ; "Load from Settings..."
					if (simulator && car && track) {
						if GetKeyState("Ctrl", "P") {
							directory := SessionDatabase.DatabasePath
							simulatorCode := SessionDatabase.getSimulatorCode(simulator)

							dirName := directory . "User\" . simulatorCode . "\" . car . "\" . track . "\Race Settings"

							DirCreate(dirName)

							this.Window.Opt("+OwnDialogs")

							OnMessage(0x44, translateLoadCancelButtons)
							file := FileSelect(1, dirName, translate("Load Race Settings..."), "Settings (*.settings)")
							OnMessage(0x44, translateLoadCancelButtons, 0)
						}
						else
							file := getFileName("Race.settings", kUserConfigDirectory)

						if (file != "") {
							settings := readMultiMap(file)

							if (settings.Count > 0) {
								if (getMultiMapValue(settings, "Session Settings", "Duration", kUndefined) != kUndefined) {
									this.Control["sessionTypeDropDown"].Choose(1)
									this.Control["sessionLengthEdit"].Text := Round(getMultiMapValue(settings, "Session Settings", "Duration") / 60)
									this.Control["sessionLengthlabel"].Text := translate("Minutes")
								}

								this.Control["formationLapCheck"].Value := getMultiMapValue(settings, "Session Settings", "Lap.Formation", false)
								this.Control["postRaceLapCheck"].Value := getMultiMapValue(settings, "Session Settings", "Lap.PostRace", false)

								this.Control["pitstopDeltaEdit"].Text := getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta", 60)
								this.Control["pitstopTyreServiceEdit"].Text := getMultiMapValue(settings, "Strategy Settings", "Service.Tyres", 30)

								value := string2Values(":", getMultiMapValue(settings, "Strategy Settings", "Service.Refuel", 1.5))

								if (value.Length = 1) {
									value := value[1]

									this.Control["pitstopFuelServiceRuleDropDown"].Choose(2)
									this.Control["pitstopFuelServiceLabel"].Text := translate("Seconds (Refuel of 10 liters)")
								}
								else {
									this.Control["pitstopFuelServiceRuleDropDown"].Choose(1 + (value[1] != "Fixed"))
									this.Control["pitstopFuelServiceLabel"].Text := translate(["Seconds", "Seconds (Refuel of 10 liters)"][1 + (value[1] != "Fixed")])

									value := value[2]
								}

								this.Control["pitstopFuelServiceEdit"].Text := displayValue("Float", value)
								this.Control["pitstopServiceDropDown"].Choose((getMultiMapValue(settings, "Strategy Settings", "Service.Order", "Simultaneous") = "Simultaneous") ? 1 : 2)
								this.Control["safetyFuelEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.SafetyMargin", 3)), 0)

								tyreCompound := getMultiMapValue(settings, "Session Setup", "Tyre.Compound", "Dry")
								tyreCompoundColor := getMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")

								this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))

								this.Control["simAvgLapTimeEdit"].Text := displayValue("Float", getMultiMapValue(settings, "Session Settings", "Lap.AvgTime", 120), 1)
								this.Control["simFuelConsumptionEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.AvgConsumption", 3.0)))
							}
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You must first select a car and a track."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				case 5:
					if (simulator && car && track) {
						settingsDB := SettingsDatabase()

						settings := SettingsDatabase().loadSettings(simulator, car, track, this.SelectedWeather)

						if (settings.Count > 0) {
							if (getMultiMapValue(settings, "Session Settings", "Duration", kUndefined) != kUndefined) {
								this.Control["sessionTypeDropDown"].Choose(1)
								this.Control["sessionLengthEdit"].Text := Round(getMultiMapValue(settings, "Session Settings", "Duration") / 60)
								this.Control["sessionLengthlabel"].Text := translate("Minutes")
							}

							if (getMultiMapValue(settings, "Session Settings", "Lap.Formation", kUndefined) != kUndefined)
								this.Control["formationLapCheck"].Value := getMultiMapValue(settings, "Session Settings", "Lap.Formation")

							if (getMultiMapValue(settings, "Session Settings", "Lap.PostRace", kUndefined) != kUndefined)
								this.Control["postRaceLapCheck"].Value := getMultiMapValue(settings, "Session Settings", "Lap.PostRace")

							if (getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta", kUndefined) != kUndefined)
								this.Control["pitstopDeltaEdit"].Text := getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta")

							if (getMultiMapValue(settings, "Strategy Settings", "Service.Tyres", kUndefined) != kUndefined)
								this.Control["pitstopTyreServiceEdit"].Text := getMultiMapValue(settings, "Strategy Settings", "Service.Tyres")

							if (getMultiMapValue(settings, "Strategy Settings", "Service.Refuel", kUndefined) != kUndefined) {
								if (getMultiMapValue(settings, "Strategy Settings", "Service.Refuel.Rule", false) = "Fixed") {
									this.Control["pitstopFuelServiceRuleDropDown"].Choose(1)
									this.Control["pitstopFuelServiceLabel"].Text := translate("Seconds")
								}
								else {
									this.Control["pitstopFuelServiceRuleDropDown"].Choose(2)
									this.Control["pitstopFuelServiceLabel"].Text := translate("Seconds (Refuel of 10 liters)")
								}

								this.Control["pitstopFuelServiceEdit"].Text := displayValue("Float", getMultiMapValue(settings, "Strategy Settings", "Service.Refuel"))
							}

							if (getMultiMapValue(settings, "Strategy Settings", "Service.Order", kUndefined) != kUndefined)
								this.Control["pitstopServiceDropDown"].Choose((getMultiMapValue(settings, "Strategy Settings", "Service.Order") = "Simultaneous") ? 1 : 2)

							if (getMultiMapValue(settings, "Strategy Settings", "Fuel.SafetyMargin", kUndefined) != kUndefined)
								this.Control["safetyFuelEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.SafetyMargin")), 0)

							if (getMultiMapValue(settings, "Session Settings", "Fuel.Amount", kUndefined) != kUndefined)
								this.Control["fuelCapacityEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.Amount")))

							if ((getMultiMapValue(settings, "Session Settings", "Tyre.Compound", kUndefined) != kUndefined)
							 && (getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Color", kUndefined) != kUndefined)) {
								tyreCompound := getMultiMapValue(settings, "Session Setup", "Tyre.Compound")
								tyreCompoundColor := getMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color")

								this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))
							}

							if (getMultiMapValue(settings, "Session Settings", "Lap.AvgTime", kUndefined) != kUndefined)
								this.Control["simAvgLapTimeEdit"].Text := displayValue("Float", getMultiMapValue(settings, "Session Settings", "Lap.AvgTime"), 1)

							if (getMultiMapValue(settings, "Session Settings", "Fuel.AvgConsumption", kUndefined) != kUndefined)
								this.Control["simFuelConsumptionEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.AvgConsumption")))
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You must first select a car and a track."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				case 6: ; "Update from Telemetry..."
					if (simulator && car && track) {
						telemetryDB := TelemetryDatabase(simulator, car, track, this.SelectedDrivers)

						fastestLapTime := false

						for ignore, row in telemetryDB.getMapData(this.SelectedWeather
																, this.SelectedCompound
																, this.SelectedCompoundColor) {
							lapTime := row["Lap.Time"]

							if (!fastestLapTime || (lapTime < fastestLapTime)) {
								fastestLapTime := lapTime

								this.Control["simMapEdit"].Text := row["Map"]
								this.Control["simAvgLapTimeEdit"].Text := displayValue("Float", lapTime, 1)
								this.Control["simFuelConsumptionEdit"].Text := displayValue("Float", convertUnit("Volume", row["Fuel.Consumption"]))
							}
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You must first select a car and a track."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				case 7: ; "Import from Simulation..."
					if simulator {
						prefix := SessionDatabase.getSimulatorCode(simulator)

						if !prefix {
							OnMessage(0x44, translateOkButton)
							MsgBox(translate("This is not supported for the selected simulator..."), translate("Warning"), 262192)
							OnMessage(0x44, translateOkButton, 0)

							return
						}

						data := readSimulatorData(prefix)

						if ((getMultiMapValue(data, "Session Data", "Car") != this.SelectedCar)
						 || (getMultiMapValue(data, "Session Data", "Track") != this.SelectedTrack))
							return
						else {
							fuelCapacity := getMultiMapValue(data, "Session Data", "FuelAmount", kUndefined)
							initialFuelAmount := getMultiMapValue(data, "Car Data", "FuelRemaining", kUndefined)

							if (fuelCapacity != kUndefined)
								this.Control["fuelCapacityEdit"].Text := displayValue("Float", convertUnit("Volume", fuelCapacity))

							if (initialFuelAmount != kUndefined)
								this.Control["simInitialFuelAmountEdit"].Text := displayValue("Float", convertUnit("Volume", initialFuelAmount), 0)

							tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompound", kUndefined)
							tyreCompoundColor := getMultiMapValue(data, "Car Data", "TyreCompoundColor", kUndefined)

							if (tyreCompound = kUndefined) {
								tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompoundRaw", kUndefined)

								if (tyreCompound && (tyreCompound != kUndefined)) {
									tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

									if tyreCompound
										splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)
									else
										tyreCompound := kUndefined
								}
							}

							if ((tyreCompound != kUndefined) && (tyreCompoundColor != kUndefined))
								this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))

							map := getMultiMapValue(data, "Car Data", "Map", kUndefined)

							if (map != kUndefined)
								this.Control["simMapEdit"].Text := (isNumber(map) ? Round(map) : map)
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You must first select a simulation."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				default:
					if (line = 9)
						Run(kUserHomeDirectory . "Validators")
					else if (line > 9) {
						validators := []

						if GetKeyState("Ctrl", "P") {
							index := 0

							for ignore, fileName in getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\") {
								SplitPath(fileName, , , , &validator)

								if !inList(validators, validator) {
									if ((++index = (line - 9)) && !InStr(fileName, kResourcesDirectory)) {
										Run("notepad " fileName)

										break
									}
								}
								else
									validators.Push(validator)
							}
						}
						else {
							for ignore, fileName in getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\") {
								SplitPath(fileName, , , , &validator)

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
		local strategy, selectStrategy

		switch line {
			case 3: ; "Run Simulation"
				selectStrategy := GetKeyState("Ctrl", "P")

				this.runSimulation()

				if (selectStrategy && !GetKeyState("Escape", "P"))
					this.chooseSimulationMenu(5)
			case 5: ; "Use as Strategy..."
				strategy := this.SelectedScenario

				if strategy
					this.selectStrategy(strategy)
				else {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("There is no current scenario. Please run a simulation first..."), translate("Warning"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
		}
	}

	chooseStrategyMenu(line) {
		local simulator := this.SelectedSimulator
		local car := this.SelectedCar
		local track := this.SelectedTrack
		local sessionDB, strategy, strategies, simulatorCode, dirName, ignore, fileName, configuration
		local info, name, files, directory, translator

		if (simulator && car && track) {
			directory := SessionDatabase.DatabasePath
			simulatorCode := SessionDatabase.getSimulatorCode(simulator)

			dirName := directory . "User\" . simulatorCode . "\" . car . "\" . track . "\Race Strategies"

			DirCreate(dirName)
		}
		else
			dirName := ""

		switch line {
			case 3:
				fileName := kUserConfigDirectory . "Race.strategy"

				if FileExist(fileName) {
					configuration := readMultiMap(fileName)

					if (configuration.Count > 0)
						this.selectStrategy(this.createStrategy(configuration))
				}
				else {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("There is no active Race Strategy."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 4: ; "Load Strategy..."
				this.Window.Opt("+OwnDialogs")

				OnMessage(0x44, translateLoadCancelButtons)
				fileName := FileSelect(1, dirName, translate("Load Race Strategy..."), "Strategy (*.strategy)")
				OnMessage(0x44, translateLoadCancelButtons, 0)

				if (fileName != "") {
					configuration := readMultiMap(fileName)

					if (configuration.Count > 0)
						this.selectStrategy(this.createStrategy(configuration))
				}
			case 5: ; "Save Strategy..."
				if this.SelectedStrategy {
					fileName := (((dirName != "") ? (dirName . "\") : "") . this.SelectedStrategy.Name . ".strategy")
					fileName := StrReplace(fileName, "n/a", "n.a.")
					fileName := StrReplace(fileName, "/", "-")

					this.Window.Opt("+OwnDialogs")

					OnMessage(0x44, translateSaveCancelButtons)
					fileName := FileSelect("S17", fileName, translate("Save Race Strategy..."), "Strategy (*.strategy)")
					OnMessage(0x44, translateSaveCancelButtons, 0)

					if (fileName != "") {
						if !InStr(fileName, ".strategy")
							fileName := (fileName . ".strategy")

						SplitPath(fileName, , , , &name)

						this.SelectedStrategy.setName(name)

						configuration := newMultiMap()

						this.SelectedStrategy.saveToConfiguration(configuration)

						writeMultiMap(fileName, configuration)

						if ((StrLen(dirName) > 0) && (InStr(fileName, dirName) = 1)) {
							sessionDB := SessionDatabase()

							info := sessionDB.readStrategyInfo(simulator, car, track, name . ".strategy")

							setMultiMapValue(info, "Strategy", "Synchronized", false)

							sessionDB.writeStrategyInfo(simulator, car, track, name . ".strategy", info)
						}
					}
				}
			case 7: ; "Compare Strategies..."
				this.Window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Compare", "Cancel"])

				OnMessage(0x44, translator)
				files := FileSelect("M1", dirName, translate("Choose two or more Race Strategies for comparison..."), "Strategy (*.strategy)")
				OnMessage(0x44, translator, 0)

				if (files != "") {
					strategies := []

					for ignore, fileName in files
						strategies.Push(this.createStrategy(readMultiMap(fileName)))

					if (strategies.Length > 1)
						this.compareStrategies(strategies*)
				}
			case 9: ; "Export Strategy..."
				if this.SelectedStrategy {
					configuration := newMultiMap()

					this.SelectedStrategy.saveToConfiguration(configuration)

					writeMultiMap(kUserConfigDirectory . "Race.strategy", configuration)
				}
			case 10: ; "Clear Strategy..."
				deleteFile(kUserConfigDirectory . "Race.strategy")
		}
	}

	selectStrategy(strategy) {
		local tyreCompound, avgLapTimes, avgFuelConsumption, ignore, pitstop

		this.PitstopListView.Delete()

		avgLapTimes := []
		avgFuelConsumption := []

		for ignore, pitstop in strategy.Pitstops {
			this.PitstopListView.Add("", pitstop.Lap, pitstop.DriverName, Ceil(convertUnit("Volume", pitstop.RefuelAmount)), pitstop.TyreChange ? translate("x") : "-", pitstop.Map)

			avgLapTimes.Push(pitstop.AvgLapTime)
			avgFuelConsumption.Push(pitstop.FuelConsumption)
		}

		this.PitstopListView.ModifyCol(1, "AutoHdr")
		this.PitstopListView.ModifyCol(2, "AutoHdr")
		this.PitstopListView.ModifyCol(3, "Center AutoHdr")
		this.PitstopListView.ModifyCol(4, "AutoHdr")

		this.Control["strategyStartMapEdit"].Text := strategy.Map
		this.Control["strategyStartTCEdit"].Text := strategy.TC
		this.Control["strategyStartABSEdit"].Text := strategy.ABS

		this.Control["strategyCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(strategy.TyreCompound, strategy.TyreCompoundColor)))

		this.Control["strategyPressureFLEdit"].Text := displayValue("Float", convertUnit("Pressure", strategy.TyrePressureFL))
		this.Control["strategyPressureFREdit"].Text := displayValue("Float", convertUnit("Pressure", strategy.TyrePressureFR))
		this.Control["strategyPressureRLEdit"].Text := displayValue("Float", convertUnit("Pressure", strategy.TyrePressureRL))
		this.Control["strategyPressureRREdit"].Text := displayValue("Float", convertUnit("Pressure", strategy.TyrePressureRR))

		this.showStrategyInfo(strategy)

		this.iSelectedStrategy := strategy
	}

	compareStrategies(strategies*) {
		local strategy, before, after, chart, ignore, laps, exhausted, index, hasData
		local sLaps, html, timeSeries, lapSeries, fuelSeries, tyreSeries, width, chartArea, tableCSS

		before := "
		(
			<meta charset='utf-8'>
			<head>
				<style>
					.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
					.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
					.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
				</style>
				<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
				<script type="text/javascript">
					google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
		)"

		before := substituteVariables(before, {headerBackColor: this.Window.Theme.ListBackColor["Header"]
											 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
											 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

		after := "
		(
				</script>
			</head>
		)"

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

			loop strategies.Length {
				sLaps := laps[A_Index]

				hasData := (sLaps.Length >= index)

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

			html .= ("<div id=`"header`"><i><b>" .  translate("Strategy: ") . strategy.Name . "</b></i></div>")

			html .= ("<br>" . this.createStrategyInfo(strategy))

			html .= ("<br>" . this.createSetupInfo(strategy))

			html .= ("<br>" . this.createStintsInfo(strategy, &timeSeries, &lapSeries, &fuelSeries, &tyreSeries))
		}

		chart .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Minute") . "' }, vAxis: { title: '" . translate("Lap") . "', viewWindow: { min: 0 } }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		chart .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")

		chartArea := ("<div id=`"header`"><i><b>" . translate("Performance") . "</b></i></div><br><div id=`"chart_id`" style=`"width: " . (this.ChartViewer.getWidth() - 24) . "px; height: 348px`">")

		tableCSS := this.StrategyViewer.getTableCSS()

		html := ("<html>" . before . chart . after . "<body style='background-color: #" . this.Window.AltBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } </style>" . html . "<br><hr style=`"width: 50%`"><br>" . chartArea . "</body></html>")

		this.showComparisonChart(html)
	}

	createStrategy(nameOrConfiguration, driver := false) {
		local name := nameOrConfiguration
		local theStrategy, name

		if !isObject(nameOrConfiguration)
			nameOrConfiguration := false

		theStrategy := Strategy(this, nameOrConfiguration, driver)

		if (name && !isObject(name))
			theStrategy.setName(name)

		return theStrategy
	}

	getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
					  , &sessionType, &sessionLength
					  , &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures) {
		local telemetryDB, lowestLapTime, ignore, row, lapTime, settings

		simulator := this.SelectedSimulator
		car := this.SelectedCar
		track := this.SelectedTrack

		weather := this.SelectedWeather
		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature

		sessionType := this.SelectedSessionType
		sessionLength := this.Control["sessionLengthEdit"].Text

		splitCompound(this.TyreCompounds[this.Control["simCompoundDropDown"].Value], &tyreCompound, &tyreCompoundColor)

		maxTyreLaps := this.Control["simMaxTyreLapsEdit"].Text

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
			settings := SettingsDatabase().loadSettings(simulator, car, track, weather)

			if (tyreCompound = "Dry")
				tyrePressures := [getMultiMapValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.FL", 26.5)
								, getMultiMapValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.FR", 26.5)
								, getMultiMapValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.RL", 26.5)
								, getMultiMapValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target.RR", 26.5)]
			else if (tyreCompound = "Intermediate") {
				if (getMultiMapValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.FL", kUndefined) != kUndefined)
					tyrePressures := [getMultiMapValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.FL", 29.0)
									, getMultiMapValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.FR", 29.0)
									, getMultiMapValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.RL", 29.0)
									, getMultiMapValue(settings, "Session Settings", "Tyre.Intermediate.Pressure.Target.RR", 29.0)]
				else
					tyrePressures := [getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
									, getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
									, getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
									, getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)]
			}
			else
				tyrePressures := [getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
								, getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
								, getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
								, getMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)]
		}
	}

	getPitstopRules(&validator, &pitstopRule, &refuelRule, &tyreChangeRule, &tyreSets) {
		local result := true
		local tyreCompound, tyreCompoundColor, translatedCompounds, count, pitstopWindow

		this.validatePitstopRule("Full")

		validator := this.SelectedValidator

		switch this.Control["pitstopRequirementsDropDown"].Value {
			case 1:
				pitstopRule := false
			case 2:
				if isInteger(this.Control["pitstopWindowEdit"].Text)
					pitstopRule := Max(this.Control["pitstopWindowEdit"].Text, 1)
				else {
					pitstopRule := 1

					result := false
				}
			case 3:
				pitstopWindow := string2Values("-", this.Control["pitstopWindowEdit"].Text)

				if (pitstopWindow.Length = 2)
					pitstopRule := [Round(pitstopWindow[1]), Round(pitstopWindow[2])]
				else {
					pitstopRule := [25, 35]

					result := false
				}
		}

		if (this.Control["pitstopRequirementsDropDown"].Value > 1) {
			refuelRule := ["Optional", "Required", "Always", "Disallowed"][this.Control["refuelRequirementsDropDown"].Value]
			tyreChangeRule := ["Optional", "Required", "Always", "Disallowed"][this.Control["tyreChangeRequirementsDropDown"].Value]
		}
		else {
			refuelRule := ["Optional", "Always", "Disallowed"][this.Control["refuelRequirementsDropDown"].Value]
			tyreChangeRule := ["Optional", "Always", "Disallowed"][this.Control["tyreChangeRequirementsDropDown"].Value]
		}

		translatedCompounds := collect(this.TyreCompounds, translate)
		tyreSets := []

		loop this.TyreSetListView.GetCount() {
			tyreCompound := this.TyreSetListView.GetText(A_Index, 1)
			count := this.TyreSetListView.GetText(A_Index, 2)

			splitCompound(this.TyreCompounds[inList(translatedCompounds, tyreCompound)], &tyreCompound, &tyreCompoundColor)

			tyreSets.Push(Array(tyreCompound, tyreCompoundColor, count))
		}

		return result
	}

	getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
					 , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder) {
		stintLength := this.Control["stintLengthEdit"].Text
		formationLap := this.Control["formationLapCheck"].Value
		postRaceLap := this.Control["postRaceLapCheck"].Value
		fuelCapacity := Round(convertUnit("Volume", internalValue("Float", this.Control["fuelCapacityEdit"].Text), false), 1)
		safetyFuel := Round(convertUnit("Volume", internalValue("Float", this.Control["safetyFuelEdit"].Text), false))
		pitstopDelta := this.Control["pitstopDeltaEdit"].Text
		pitstopFuelService := [["Fixed", "Dynamic"][this.Control["pitstopFuelServiceRuleDropDown"].Value], internalValue("Float", this.Control["pitstopFuelServiceEdit"].Text)]
		pitstopTyreService := this.Control["pitstopTyreServiceEdit"].Text
		pitstopServiceOrder := ((this.Control["pitstopServiceDropDown"].Value == 1) ? "Simultaneous" : "Sequential")
	}

	getSessionWeather(minute, &weather, &airTemperature, &trackTemperature) {
		local rows, ignore, time, tWeather, tAirTemperature, tTrackTemperature, candidate, weathers
		local hour, cHour, cMinute

		weather := this.SelectedWeather
		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature

		rows := this.WeatherListView.GetCount()

		if (rows > 0) {
			weathers := []

			loop rows {
				time := this.WeatherListView.GetText(A_Index, 1)
				tWeather := this.WeatherListView.GetText(A_Index, 2)
				tAirTemperature := this.WeatherListView.GetText(A_Index, 3)
				tTrackTemperature := this.WeatherListView.GetText(A_Index, 4)

				weathers.Push(Array(time, kWeatherConditions[inList(collect(kWeatherConditions, translate), tWeather)]
							, tAirTemperature, tTrackTemperature))
			}

			bubbleSort(&weathers, (w1, w2)  => strGreater(w1[1], w2[1]))

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

	getStartConditions(&initialStint, &initialLap, &initialStintTime, &initialSessionTime
					 , &initialTyreLaps, &initialFuelAmount
					 , &initialMap, &initialFuelConsumption, &initialAvgLapTime) {
		initialStint := 1
		initialLap := 0
		initialStintTime := 0
		initialSessionTime := 0
		initialTyreLaps := 0
		initialFuelAmount := convertUnit("Volume", internalValue("Float", this.Control["simInitialFuelAmountEdit"].Text), false)
		initialMap := this.Control["simMapEdit"].Text
		initialFuelConsumption := convertUnit("Volume", internalValue("Float", this.Control["simFuelConsumptionEdit"].Text), false)
		initialAvgLapTime := internalValue("Float", this.Control["simAvgLapTimeEdit"].Text)
	}

	getSimulationSettings(&useInitialConditions, &useTelemetryData
						, &consumptionVariation, &initialFuelVariation, &tyreUsageVariation, &tyreCompoundVariation) {
		local simInputDropDown := this.Control["simInputDropDown"].Value

		consumptionVariation := this.Control["simConsumptionVariation"].Value
		initialFuelVariation := this.Control["simInitialFuelVariation"].Value
		tyreUsageVariation := this.Control["simTyreUsageVariation"].Value
		tyreCompoundVariation := this.Control["simtyreCompoundVariation"].Value

		useInitialConditions := ((simInputDropDown == 1) || (simInputDropDown == 3))
		useTelemetryData := (simInputDropDown > 1)
	}

	getStintDriver(stintNumber, &driverID, &driverName) {
		local numDrivers := this.StintDrivers.Length

		if (numDrivers == 0) {
			driverID := false
			driverName := "John Doe (JD)"
		}
		else if (numDrivers >= stintNumber) {
			driverID := this.StintDrivers[stintNumber]
			driverName := SessionDatabase().getDriverName(this.SelectedSimulator, driverID)
		}
		else {
			driverID := this.StintDrivers[numDrivers]
			driverName := SessionDatabase().getDriverName(this.SelectedSimulator, driverID)
		}

		return true
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		local theMin := false
		local theMax := false
		local a, b, telemetryDB, lapTimes, tyreLapTimes, xValues, yValues, ignore, entry
		local baseLapTime, count, avgLapTime, lapTime, candidate

		a := false
		b := false

		if (this.Control["simInputDropDown"].Value > 1) {
			telemetryDB := this.TelemetryDatabase

			lapTimes := telemetryDB.getMapLapTimes(weather, tyreCompound, tyreCompoundColor)
			tyreLapTimes := telemetryDB.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor)

			if (tyreLapTimes.Length > 1) {
				xValues := []
				yValues := []

				for ignore, entry in tyreLapTimes {
					lapTime := entry["Lap.Time"]

					xValues.Push(entry["Tyre.Laps"])
					yValues.Push(lapTime)

					theMin := (theMin ? Min(theMin, lapTime) : lapTime)
					theMax := (theMax ? Min(theMax, lapTime) : lapTime)
				}

				linRegression(xValues, yValues, &a, &b)
			}
		}
		else
			lapTimes := []

		baseLapTime := ((a && b) ? (a + (b * tyreLaps)) : false)

		count := 0
		avgLapTime := 0
		lapTime := false

		loop numLaps {
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

		if (theMin && theMax)
			avgLapTime := Max(theMin, Min(theMax, avgLapTime))

		return avgLapTime ? avgLapTime : (default ? default : internalValue("Float", this.Control["simAvgLapTimeEdit"].Text))
	}

	runSimulation() {
		local telemetryDB := TelemetryDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)

		this.iTelemetryDatabase := telemetryDB

		try {
			VariationSimulation(this, this.SelectedSessionType, telemetryDB).runSimulation(true)
		}
		finally {
			this.iTelemetryDatabase := false
		}
	}

	chooseScenario(strategy) {
		local numPitstops, numTyreChanges, consumedFuel, avgLapTimes, ignore, pitstop

		if this.SelectedStrategy
			this.SelectedStrategy.dispose()

		if strategy {
			numPitstops := 0
			numTyreChanges := 0
			consumedFuel := strategy.StartFuel
			avgLapTimes := [strategy.AvgLapTime]

			for ignore, pitstop in strategy.Pitstops {
				numPitstops += 1

				if pitstop.TyreChange
					numTyreChanges += 1

				consumedFuel += pitstop.RefuelAmount

				avgLapTimes.Push(pitstop.AvgLapTime)
			}

			this.Control["simNumPitstopResult"].Text := numPitstops
			this.Control["simNumTyreChangeResult"].Text := numTyreChanges
			this.Control["simConsumedFuelResult"].Text := displayValue("Float", convertUnit("Volume", consumedFuel), 1)
			this.Control["simPitlaneSecondsResult"].Text := Ceil(strategy.getPitstopTime())

			if (this.SelectedSessionType = "Duration")
				this.Control["simSessionResultResult"].Text := strategy.getSessionLaps()
			else
				this.Control["simSessionResultResult"].Text := Ceil(strategy.getSessionDuration())
		}
		else {
			this.Control["simNumPitstopResult"].Text := ""
			this.Control["simNumTyreChangeResult"].Text := ""
			this.Control["simConsumedFuelResult"].Text := ""
			this.Control["simPitlaneSecondsResult"].Text := ""
			this.Control["simSessionResultResult"].Text := ""
		}

		this.iSelectedScenario := strategy
	}

	validatePitstopRule(full := false) {
		local reset, count, pitOpen, pitClose
		local pitstopWindowEdit := this.Control["pitstopWindowEdit"].Text
		local pitstopRequirementsDropDown := this.Control["pitstopRequirementsDropDown"].Value

		if (StrLen(Trim(pitstopWindowEdit)) > 0) {
			if (pitstopRequirementsDropDown == 2) {
				if isInteger(pitstopWindowEdit) {
					if (pitstopWindowEdit < 1)
						this.Control["pitstopWindowEdit"].Text := 1
				}
				else
					this.Control["pitstopWindowEdit"].Value := 1
			}
			else if (pitstopRequirementsDropDown == 3) {
				reset := false

				StrReplace(pitstopWindowEdit, "-", "-", , &count)

				if (count > 1) {
					pitstopWindowEdit := StrReplace(pitstopWindowEdit, "-", "", , , count - 1)

					reset := true
				}

				if (reset || InStr(pitstopWindowEdit, "-")) {
					pitstopWindowEdit := string2Values("-", pitstopWindowEdit)
					pitOpen := pitstopWindowEdit[1]
					pitClose := pitstopWindowEdit[2]

					if (StrLen(Trim(pitOpen)) > 0)
						if isInteger(pitOpen) {
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
						if isInteger(pitClose) {
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
						this.Control["pitstopWindowEdit"].Text := Round(pitOpen) . " - " . Round(pitClose)
				}
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

readSimulatorData(simulator) {
	local dataFile := kTempDirectory . simulator . " Data\Setup.data"
	local exePath := kBinariesDirectory . simulator . " SHM Provider.exe"
	local data, setupData

	DirCreate(kTempDirectory . simulator . " Data")

	try {
		RunWait(A_ComSpec . " /c `"`"" . exePath . "`" -Setup > `"" . dataFile . "`"`"", , "Hide")

		data := readMultiMap(dataFile)

		setupData := getMultiMapValues(data, "Setup Data")

		RunWait(A_ComSpec . " /c `"`"" . exePath . "`" > `"" . dataFile "`"`"", , "Hide")

		data := readMultiMap(dataFile)

		deleteFile(dataFile)

		setMultiMapValues(data, "Setup Data", setupData)

		return data
	}
	catch Any as exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"}) . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration..."), {simulator: simulator, protocol: "SHM", exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
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

convertValue(name, value) {
	if (value = kNull)
		return value
	else if InStr(name, "Fuel")
		return convertUnit("Volume", value)
	else if InStr(name, "Temperature")
		return convertUnit("Temperature", value)
	else if InStr(name, "Pressure")
		return convertUnit("Pressure", value)
	else
		return value
}

runStrategyWorkbench() {
	local icon := kIconsDirectory . "Dashboard.ico"
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getMultiMapValue(settings, "Strategy Workbench", "Simulator", false)
	local car := getMultiMapValue(settings, "Strategy Workbench", "Car", false)
	local track := getMultiMapValue(settings, "Strategy Workbench", "Track", false)
	local weather := "Dry"
	local airTemperature := 23
	local trackTemperature := 27
	local compound := "Dry"
	local compoundColor := "Black"
	local index := 1
	local workbench

	TraySetIcon(icon, "1")
	A_IconTip := "Strategy Workbench"

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

	workbench := StrategyWorkbench(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor)

	workbench.createGui(workbench.Configuration)

	workbench.show()
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

runStrategyWorkbench()