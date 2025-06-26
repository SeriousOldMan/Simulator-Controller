﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Workbench Tool         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Workbench.ico
;@Ahk2Exe-ExeName Strategy Workbench.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\HTMLViewer.ahk"
#Include "..\Framework\Extensions\CodeEditor.ahk"
#Include "..\Framework\Extensions\ScriptEngine.ahk"
#Include "..\Framework\Extensions\RuleEngine.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\SessionDatabaseBrowser.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"
#Include "..\Database\Libraries\LapsDatabase.ahk"
#Include "..\Plugins\Libraries\SimulatorProvider.ahk"
#Include "Libraries\Strategy.ahk"
#Include "Libraries\StrategyViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"

global kFixedPitstopRefuel := true


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
	iSelectedAdditionalLaps := 0

	iTelemetryChartHTML := false
	iStrategyChartHTML := false
	iComparisonChartHTML := false

	iTyreSetListView := false

	iSelectedScenario := false
	iSelectedStrategy := false

	iAirTemperature := 23
	iTrackTemperature := 27

	iAutoInitialize := false
	iFixedPitstops := false

	iFixedPitstopsListView := false
	iDriversListView := false
	iWeatherListView := false
	iPitstopListView := false

	iChartViewer := false
	iStrategyViewer := false

	iSimulation := false
	iLapsDatabase := false

	class WorkbenchResizer extends Window.Resizer {
		iRedraw := false

		__New(arguments*) {
			super.__New(arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViewer"), 500, kHighPriority)
		}

		Redraw() {
			this.iRedraw := true
		}

		RedrawHTMLViewer() {
			if this.iRedraw {
				local workbench := StrategyWorkbench.Instance
				local ignore, button

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button)
						return Task.CurrentTask

				this.iRedraw := false

				workbench.StrategyViewer.StrategyViewer.Resized()
				workbench.ChartViewer.Resized()

				workbench.showStrategyInfo(workbench.SelectedStrategy, false)

				if (workbench.Control["chartSourceDropDown"].Value = 1)
					workbench.loadChart(["Scatter", "Bar", "Bubble", "Line"][workbench.Control["chartTypeDropDown"].Value])
				else {
					workbench.ChartViewer.document.open()
					workbench.ChartViewer.document.write((workbench.Control["chartSourceDropDown"].Value = 2) ? workbench.iStrategyChartHTML : workbench.iComparisonChartHTML)
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

	SelectedAdditionalLaps {
		Get {
			return this.iSelectedAdditionalLaps
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

	AutoInitialize {
		Get {
			return this.iAutoInitialize
		}
	}

	FixedPitstops {
		Get {
			return this.iFixedPitstops
		}
	}

	FixedPitstopsListView {
		Get {
			return this.iFixedPitstopsListView
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

	Simulation {
		Get {
			return this.iSimulation
		}
	}

	LapsDatabase {
		Get {
			return this.iLapsDatabase
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
		local compound, simulators, simulator, car, track, weather, choices, chosen, schema, settings
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
					msgResult := withBlockedWindows(MsgBox, translate("Entries with lap times or fuel consumption outside the standard deviation will be deleted. Do you want to proceed?")
									  , translate("Delete"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes")
						withTask(ProgressTask(translate("Cleaning ") . translate("Data")), () {
							this.Window.Block()

							try {
								LapsDatabase(workbench.SelectedSimulator, workbench.SelectedCar, workbench.SelectedTrack
										   , workbench.SelectedDrivers).cleanupData(workbench.SelectedWeather, workbench.SelectedCompound
																				  , workbench.SelectedCompoundColor, workbench.SelectedDrivers ? workbench.SelectedDrivers : true)

								workbench.loadDataType(workbench.SelectedDataType, true)

								workbench.loadCompound(workbench.AvailableCompounds[workbenchGui["compoundDropDown"].Value], true)
							}
							finally {
								this.Window.Unblock()
							}
						})
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
			workbench.loadChart(workbench.SelectedChartType, true)
		}

		chooseChartSource(*) {
			local chartSourceDropDown := workbenchGui["chartSourceDropDown"].Value

			if (chartSourceDropDown = 1)
				workbenchGui["chartTypeDropDown"].Visible := true
			else
				workbenchGui["chartTypeDropDown"].Visible := false

			workbench.ChartViewer.document.open()

			switch chartSourceDropDown {
				case 1:
					workbench.ChartViewer.document.write(workbench.iTelemetryChartHTML)
				case 2:
					workbench.ChartViewer.document.write(workbench.iStrategyChartHTML)
				case 3:
					workbench.ChartViewer.document.write(workbench.iComparisonChartHTML)
			}

			workbench.ChartViewer.document.close()
		}

		chooseChartType(*) {
			workbench.loadChart(["Scatter", "Bar", "Bubble", "Line"][workbenchGui["chartTypeDropDown"].Value], true)
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
			local sessionType := ["Time", "Time + 1", "Laps", "Laps + 1"][workbenchGui["sessionTypeDropDown"].Value]
			local additionalLaps := 0

			switch sessionType {
				case "Time":
					sessionType := "Duration"
				case "Time + 1":
					sessionType := "Duration"
					additionalLaps := 1
				case "Laps":
					sessionType := "Laps"
				case "Laps + 1":
					sessionType := "Laps"
					additionalLaps := 1
				default:
					throw "Unsupported session format detected in StrategyWorkbench.chooseSessionType..."
			}

			workbench.selectSessionType(sessionType, additionalLaps)
		}

		choosePitstopRule(*) {
			workbench.updateState()
		}

		updatePitstopRule(*) {
			workbench.validatePitstopRule()
		}

		choosePitstopWindow(*) {
			workbench.updateState()
		}

		updatePitstopWindow(*) {
			workbench.validatePitstopWindow()
		}

		selectTyreSet(listView, line, selected) {
			if selected
				chooseTyreSet(listView, line)
		}

		chooseTyreSet(listView, line, *) {
			local compound := listView.GetText(line, 1)
			local laps := listView.GetText(line, 2)
			local count := listView.GetText(line, 3)

			if line {
				if compound
					compound := normalizeCompound(compound)

				workbenchGui["tyreSetDropDown"].Choose(inList(collect(workbench.TyreCompounds, translate), compound))
				workbenchGui["tyreSetLapsEdit"].Text := laps
				workbenchGui["tyreSetCountEdit"].Text := count
			}

			workbench.updateState()
		}

		updateTyreSet(*) {
			local row := workbench.TyreSetListView.GetNext(0)
			local availableCompounds, compound, usedCompounds, index, candidate

			if (row > 0) {
				availableCompounds := collect(workbench.TyreCompounds, translate)
				compound := availableCompounds[workbenchGui["tyreSetDropDown"].Value]
				usedCompounds := []

				loop workbench.TyreSetListView.GetCount()
					if (A_Index != row)
						usedCompounds.Push(workbench.TyreSetListView.GetText(A_Index, 1))

				if inList(usedCompounds, compound)
					for index, candidate in availableCompounds
						if !inList(usedCompounds, candidate) {
							compound := candidate

							workbenchGui["tyreSetDropDown"].Choose(index)

							break
						}

				workbench.TyreSetListView.Modify(row, "", compound, workbenchGui["tyreSetLapsEdit"].Text
														, workbenchGui["tyreSetCountEdit"].Text)

				workbench.TyreSetListView.ModifyCol()
			}

			workbench.updateState()
		}

		addTyreSet(*) {
			local availableCompounds := collect(workbench.TyreCompounds, translate)
			local usedCompounds := []
			local index, ignore, candidate

			loop workbench.TyreSetListView.GetCount()
				usedCompounds.Push(workbench.TyreSetListView.GetText(A_Index, 1))

			for ignore, candidate in availableCompounds
				if !inList(usedCompounds, candidate) {
					index := A_Index

					break
				}

			workbench.TyreSetListView.Add("", collect(workbench.TyreCompounds, translate)[index], 50, 99)
			workbench.TyreSetListView.Modify(workbench.TyreSetListView.GetCount(), "Select Vis")

			workbench.TyreSetListView.ModifyCol()

			workbenchGui["tyreSetDropDown"].Choose(index)
			workbenchGui["tyreSetLapsEdit"].Value := 50
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

		selectSimFixedPitstop(listView, line, selected) {
			if selected
				chooseSimFixedPitstop(listView, line)
		}

		chooseSimFixedPitstop(listView, line, *) {
			if line {
				workbenchGui["simFixedPitstopEdit"].Text := workbench.FixedPitstopsListView.GetText(line)
				workbenchGui["simFixedPitstopLapEdit"].Text := workbench.FixedPitstopsListView.GetText(line, 2)

				if kFixedPitstopRefuel
					workbenchGui["simFixedPitstopRefuelEdit"].Text := workbench.FixedPitstopsListView.GetText(line, 3)

				if (workbench.FixedPitstopsListView.GetText(line, 3 + kFixedPitstopRefuel) = translate("-"))
					workbenchGui["simFixedPitstopCompoundDropDown"].Choose(1)
				else
					workbenchGui["simFixedPitstopCompoundDropDown"].Choose(inList(collect(this.TyreCompounds, translate), workbench.FixedPitstopsListView.GetText(line, 3 + kFixedPitstopRefuel)) + 1)
			}

			workbench.updateState()
		}

		updateSimFixedPitstop(*) {
			local row := workbench.FixedPitstopsListView.GetNext(0)

			if (row > 0)
				if kFixedPitstopRefuel
					workbench.FixedPitstopsListView.Modify(row, ""
														 , workbenchGui["simFixedPitstopEdit"].Text
														 , workbenchGui["simFixedPitstopLapEdit"].Text
														 , workbenchGui["simFixedPitstopRefuelEdit"].Text
														 , (workbenchGui["simFixedPitstopCompoundDropDown"].Value = 1) ? translate("-")
																													   : translate(this.TyreCompounds[workbenchGui["simFixedPitstopCompoundDropDown"].Value - 1]))
				else
					workbench.FixedPitstopsListView.Modify(row, ""
														 , workbenchGui["simFixedPitstopEdit"].Text
														 , workbenchGui["simFixedPitstopLapEdit"].Text
														 , (workbenchGui["simFixedPitstopCompoundDropDown"].Value = 1) ? translate("-")
																													   : translate(this.TyreCompounds[workbenchGui["simFixedPitstopCompoundDropDown"].Value - 1]))
		}

		addSimFixedPitstop(*) {
			if kFixedPitstopRefuel
				workbench.FixedPitstopsListView.Add("Vis Select", 1, 1, 0, translate("-"))
			else
				workbench.FixedPitstopsListView.Add("Vis Select", 1, 1, translate("-"))

			workbenchGui["simFixedPitstopEdit"].Text := 1
			workbenchGui["simFixedPitstopLapEdit"].Text := 1

			if kFixedPitstopRefuel
				workbenchGui["simFixedPitstopRefuelEdit"].Text := 0

			workbenchGui["simFixedPitstopCompoundDropDown"].Choose(1)

			workbench.updateState()
		}

		deleteSimFixedPitstop(*) {
			local row, msgResult, numRows

			row := workbench.FixedPitstopsListView.GetNext(0)

			if row {
				OnMessage(0x44, translateYesNoButtons)
				msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected fixed pitstop?"), translate("Delete"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes") {
					workbench.FixedPitstopsListView.Delete(row)

					workbench.updateState()
				}
			}
		}

		selectSimDriver(listView, line, selected) {
			if selected
				chooseSimDriver(listView, line)
		}

		chooseSimDriver(listView, line, *) {
			local driver := (line ? workbench.DriversListView.GetText(line, 2) : false)
			local ignore, id

			if (line > 0)
				for ignore, id in workbench.AvailableDrivers
					if (SessionDatabase.getDriverName(workbench.SelectedSimulator, id) = driver) {
						workbenchGui["simDriverDropDown"].Choose(A_Index)

						break
					}

			workbench.updateState()
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
				msgResult := withBlockedWindows(MsgBox, translate("Do you want to add the new entry before or after the currently selected entry?"), translate("Insert"), 262179)
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
				msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected driver?"), translate("Delete"), 262436)
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

		selectSimWeather(listView, line, selected) {
			if selected
				chooseSimWeather(listView, line)
		}

		chooseSimWeather(listView, line, *) {
			local time := (line ? string2Values(":", workbench.WeatherListView.GetText(line, 1)) : false)
			local currentTime := "20200101000000"

			if (line > 0) {
				currentTime := DateAdd(currentTime, time[1], "Hours")
				currentTime := DateAdd(currentTime, time[2], "Minutes")

				workbenchGui["simWeatherTimeEdit"].Value := currentTime
				workbenchGui["simWeatherAirTemperatureEdit"].Text := workbench.WeatherListView.GetText(line, 3)
				workbenchGui["simWeatherTrackTemperatureEdit"].Text := workbench.WeatherListView.GetText(line, 4)
				workbenchGui["simWeatherDropDown"].Choose(inList(collect(kWeatherConditions, translate), workbench.WeatherListView.GetText(line, 2)))
			}

			workbench.updateState()
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
				msgResult := withBlockedWindows(MsgBox, translate("Do you want to add the new entry before or after the currently selected entry?"), translate("Insert"), 262179)
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
				msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected change of weather?"), translate("Delete"), 262436)
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
		this.iComparisonChartHTML := this.iTelemetryChartHTML

		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Text", "w1334 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(workbenchGui, "Strategy Workbench"))

		workbenchGui.SetFont("s9 Norm", "Arial")

		workbenchGui.Add("Documentation", "x588 YP+20 w174 Center H:Center", translate("Strategy Workbench")
					   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench")

		workbenchGui.Add("Text", "x8 yp+30 w1350 0x10 W:Grow")

		workbenchGui.SetFont("Norm")
		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x16 yp+12 w30 h30 Section", workbenchGui.Theme.RecolorizeImage(kIconsDirectory . "Sensor.ico"))
		workbenchGui.Add("Text", "x50 yp+5 w120 h26", translate("Telemetry"))

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

		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		this.iAutoInitialize := getMultiMapValue(settings, "Strategy Workbench", "Auto Initialize", true)

		this.iSelectedDataType := getMultiMapValue(settings, "Strategy Workbench", "Data Type", "Electronics")

		chosen := inList(["Electronics", "Tyres"], this.SelectedDataType)

		workbenchGui.Add("DropDownList", "x12 yp+28 w76 Choose" . chosen . " vdataTypeDropDown  +0x200", collect(["Electronics", "Tyres", "-----------------", "Cleanup..."], translate)).OnEvent("Change", chooseDataType)

		this.iDataListView := workbenchGui.Add("ListView", "x12 yp+24 w170 h172 W:Grow(0.1) H:Grow(0.2) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "Map", "#"], translate))
		this.iDataListView.OnEvent("Click", noSelect)
		this.iDataListView.OnEvent("DoubleClick", noSelect)

		workbenchGui.Add("Text", "x190 yp w62 h23 X:Move(0.1) +0x200", translate("Driver"))
		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) vdriverDropDown").OnEvent("Change", chooseDriver)

		compound := this.SelectedCompound[true]
		choices := collect([normalizeCompound("Dry")], translate)
		chosen := inList([normalizeCompound("Dry")], compound)

		if (!chosen && (choices.Length > 0)) {
			compound := choices[1]
			chosen := 1
		}

		workbenchGui.Add("Text", "x190 yp+24 w62 h23 X:Move(0.1) +0x200", translate("Compound"))
		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) Choose" . chosen . "  vcompoundDropDown", choices).OnEvent("Change", chooseCompound)

		workbenchGui.Add("Text", "x190 yp+28 w62 h23 X:Move(0.1) +0x200", translate("X-Axis"))

		schema := filterSchema(LapsDatabase().getSchema("Electronics", true))

		chosen := inList(schema, "Map")

		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) Choose" . chosen . " vdataXDropDown", schema).OnEvent("Change", chooseAxis)

		workbenchGui.Add("Text", "x190 yp+24 w62 h23 X:Move(0.1) +0x200", translate("Series"))

		chosen := inList(schema, "Fuel.Consumption")

		workbenchGui.Add("DropDownList", "x250 yp w130 X:Move(0.1) Choose" . chosen . " vdataY1DropDown", schema).OnEvent("Change", chooseAxis)

		schema := concatenate([translate("None")], schema)

		workbenchGui.Add("DropDownList", "x250 yp+24 w130 X:Move(0.1) Choose1 vdataY2DropDown", schema).OnEvent("Change", chooseAxis)
		workbenchGui.Add("DropDownList", "x250 yp+24 w130 X:Move(0.1) Choose1 vdataY3DropDown", schema).OnEvent("Change", chooseAxis)

		workbenchGui.Add("Text", "x400 ys w60 h23 X:Move(0.1) +0x200", translate("Chart"))
		workbenchGui.Add("DropDownList", "x464 yp w80 X:Move(0.1) Choose1 +0x200 vchartSourceDropDown", collect(["Telemetry", "Strategy", "Comparison"], translate)).OnEvent("Change", chooseChartSource)
		workbenchGui.Add("DropDownList", "x549 yp w80 X:Move(0.1) Choose1 vchartTypeDropDown", collect(["Scatter", "Bar", "Bubble", "Line"], translate)).OnEvent("Change", chooseChartType)

		this.iChartViewer := workbenchGui.Add("HTMLViewer", "x400 yp+24 w950 h350 Border vchartViewer X:Move(0.1) W:Grow(0.9) H:Grow(0.2)")

		workbenchGui.Rules := "Y:Move(0.2)"

		workbenchGui.Add("Text", "x8 yp+358 w1350 0x10 W:Grow")

		workbenchGui.SetFont("s10 Bold", "Arial")

		workbenchGui.Add("Picture", "x16 yp+10 w30 h30 Section", workbenchGui.Theme.RecolorizeImage(kIconsDirectory . "Strategy.ico"))
		workbenchGui.Add("Text", "x50 yp+5 w120 h26", translate("Strategy"))

		workbenchGui.SetFont("s8 Norm", "Arial")

		workbenchGui.Add("DropDownList", "x250 yp-2 w180 Choose1 +0x200 VsettingsMenuDropDown").OnEvent("Change", settingsMenu)

		this.updateSettingsMenu()

		workbenchGui.Add("DropDownList", "x435 yp w180 Choose1 +0x200 VsimulationMenuDropDown", collect(["Simulation", "---------------------------------------------", "Run Simulation", "---------------------------------------------", "Use as Strategy..."], translate)).OnEvent("Change", simulationMenu)

		workbenchGui.Add("DropDownList", "x620 yp w180 Choose1 +0x200 VstrategyMenuDropDown", collect(["Strategy", "---------------------------------------------", "Load current Race Strategy", "Load Strategy...", "Save Strategy...", "---------------------------------------------", "Compare Strategies...", "---------------------------------------------", "Set as Race Strategy", "Clear Race Strategy"], translate)).OnEvent("Change", strategyMenu)

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("Text", "x619 ys+39 w80 h21", translate("Strategy"))
		workbenchGui.Add("Text", "x700 yp+7 w646 0x10 W:Grow")

		workbenchGui.Add("HTMLViewer", "x619 yp+14 w727 h238 Border vstratViewer H:Grow(0.8) W:Grow")

		this.iStrategyViewer := StrategyViewer(workbenchGui, workbenchGui["stratViewer"])

		this.showStrategyInfo(false)

		workbenchGui.SetFont("Norm", "Arial")

		/*
		workbenchGui.Add("Text", "x8 y816 w1350 0x10 Y:Move W:Grow")

		workbenchGui.Add("Button", "x649 y824 w80 h23 Y:Move H:Center", translate("Close")).OnEvent("Click", closeWorkbench)
		*/

		workbenchTab := workbenchGui.Add("Tab3", "x16 ys+39 w593 h261 H:Grow(0.8) -Wrap Section", collect(["Rules && Settings", "Pitstop && Service", "Pitstops (fixed)", "Drivers", "Weather", "Simulation", "Strategy"], translate))

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

		workbenchGui.Add("GroupBox", "x24 ys+34 w199 h217 H:Grow(0.8)", translate("Race"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("DropDownList", "x" . x0 . " yp+21 w70 Choose1  VsessionTypeDropDown", collect(["Time", "Time + 1", "Laps", "Laps + 1"], translate)).OnEvent("Change", chooseSessionType)
		workbenchGui.Add("Edit", "x" . x1 . " yp w50 h20 Limit4 Number VsessionLengthEdit", 60)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range1-9999 0x80", 60)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w50 h20 VsessionLengthLabel", translate("Minutes"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w75 h23 +0x200", translate("Max. Stint"))
		workbenchGui.Add("Edit", "x" . x1 . " yp w50 h20 Limit4 Number VstintLengthEdit", 70)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range1-9999 0x80", 70)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w50 h20", translate("Minutes"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w75 h23 +0x200", translate("Formation"))
		workbenchGui.Add("CheckBox", "x" . x1 . " yp-1 w17 h21 Checked VformationLapCheck")
		workbenchGui.Add("Text", "x" . x4 . " yp+5 w50 h20", translate("Lap"))

		workbenchGui.Add("Text", "x" . x . " yp+19 w75 h23 +0x200", translate("Post Race"))
		workbenchGui.Add("CheckBox", "x" . x1 . " yp-1 w17 h21 Checked VpostRaceLapCheck")
		workbenchGui.Add("Text", "x" . x4 . " yp+5 w50 h20", translate("Lap"))

		workbenchGui.SetFont("Norm", "Arial")
		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x233 ys+34 w364 h217 H:Grow(0.8)", translate("Pitstop"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . (x5 - 10) . " yp+23 w85 h20 +0x200", translate("Pitstop"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp-4 w80 Choose1 VpitstopRuleDropDown", collect(["Optional", "Required"], translate)).OnEvent("Change", choosePitstopRule)
		workbenchGui.Add("Edit", "x" . x11 . " yp+1 w50 h20 Number Limit2 VpitstopRuleEdit", 1).OnEvent("Change", updatePitstopRule)
		workbenchGui.Add("UpDown", "x" . x11 . " yp+1 w50 h20 Range0-99 VpitstopRuleUpDown")

		workbenchGui.Add("Text", "x" . (x5 - 10) . " yp+28 w85 h20 +0x200", translate("Regular"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp-4 w80 Choose1  VpitstopWindowDropDown", collect(["Always", "Window"], translate)).OnEvent("Change", choosePitstopWindow)
		workbenchGui.Add("Edit", "x" . x11 . " yp+1 w50 h20 VpitstopWindowEdit", "25 - 35").OnEvent("Change", updatePitstopWindow)
		workbenchGui.Add("Text", "x" . x12 . " yp+3 w120 h20 VpitstopWindowLabel", translate("Minute (From - To)"))

		workbenchGui.Add("Text", "x" . (x5 - 10) . " yp+22 w85 h23 +0x200 VrefuelRequirementsLabel", translate("Refuel"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp w80 Choose1 VrefuelRequirementsDropDown", collect(["Optional", "Required", "Always", "Disallowed"], translate))

		workbenchGui.Add("Text", "x" . (x5 - 10) . " yp+26 w85 h23 +0x200 VtyreChangeRequirementsLabel", translate("Tyre Change"))
		workbenchGui.Add("DropDownList", "x" . x7 . " yp w80 Choose1 VtyreChangeRequirementsDropDown", collect(["Optional", "Required", "Always", "Disallowed"], translate))

		workbenchGui.Add("Text", "x" . (x5 - 10) . " yp+26 w85 h23 +0x200", translate("Tyre Sets"))

		w12 := (x11 + 40 - x7)

		this.iTyreSetListView := workbenchGui.Add("ListView", "x" . x7 . " yp w" . w12 . " h84 H:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "O", "#"], translate))
		this.iTyreSetListView.OnEvent("Click", chooseTyreSet)
		this.iTyreSetListView.OnEvent("DoubleClick", chooseTyreSet)
		this.iTyreSetListView.OnEvent("ItemSelect", selectTyreSet)

		x13 := (x7 + w12 + 5)

		workbenchGui.Add("DropDownList", "x" . x13 . " yp w85 Choose0 vtyreSetDropDown", [translate(normalizeCompound("Dry"))]).OnEvent("Change", updateTyreSet)

		workbenchGui.Add("Edit", "x" . (x13 + 86) . " yp w40 h20 Limit2 Number vtyreSetLapsEdit", 50).OnEvent("Change", updateTyreSet)
		workbenchGui.Add("UpDown", "x" . (x13 + 86) . " yp w18 h20 0x80 Range0-99")

		workbenchGui.Add("Edit", "x" . x13 . " yp+24 w40 h20 Limit2 Number vtyreSetCountEdit").OnEvent("Change", updateTyreSet)
		workbenchGui.Add("UpDown", "x" . x13 . " yp w18 h20 0x80 Range0-99")

		x13 := (x7 + w12 + 5 + 126 - 48)

		workbenchGui.Add("Button", "x" . x13 . " yp+6 w23 h23 Y:Move(0.8) Center +0x200 vtyreSetAddButton").OnEvent("Click", addTyreSet)
		setButtonIcon(workbenchGui["tyreSetAddButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")

		x13 += 25

		workbenchGui.Add("Button", "x" . x13 . " yp w23 h23 Y:Move(0.8) Center +0x200 vtyreSetDeleteButton").OnEvent("Click", deleteTyreSet)
		setButtonIcon(workbenchGui["tyreSetDeleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		workbenchTab.UseTab(2)

		x := 32
		x0 := x - 4
		x1 := x + 114
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x24 ys+34 w410 h181", translate("Pitstop"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w110 h20 +0x200", translate("Pitlane Delta"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Limit2 Number VpitstopDeltaEdit", 60)
		workbenchGui.Add("UpDown", "x" . x2 . " yp w18 h20 0x80 Range0-99", 60)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20", translate("Seconds (Drive through - Drive by)"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w110 h20 +0x200", translate("Tyre Service"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Limit2 Number VpitstopTyreServiceEdit", 30)
		workbenchGui.Add("UpDown", "x" . x2 . " yp w18 h20 0x80 Range0-99", 30)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20", translate("Seconds (Change four tyres)"))

		workbenchGui.Add("DropDownList", "x" . x0 . " yp+20 w110 Choose2 VpitstopFuelServiceRuleDropdown", collect(["Refuel Fixed", "Refuel Dynamic"], translate)).OnEvent("Change", chooseRefuelService)

		workbenchGui.Add("Edit", "x" . x1 . " yp w50 h20 VpitstopFuelServiceEdit", displayValue("Float", 1.8)).OnEvent("Change", validatePitstopFuelService)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w220 h20 VpitstopFuelServiceLabel", translate("Seconds (Refuel of 10 liters)"))

		workbenchGui.Add("Text", "x" . x . " yp+24 w110 h23", translate("Service"))
		workbenchGui.Add("DropDownList", "x" . x1 . " yp-3 w100 Choose1 vpitstopServiceDropDown", collect(["Simultaneous", "Sequential"], translate))

		workbenchGui.Add("Text", "x" . x . " yp+27 w110 h20 +0x200", translate("Fuel Capacity"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 VfuelCapacityEdit", displayValue("Float", convertUnit("Volume", 125))).OnEvent("Change", validateFuelCapacity)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w90 h20", getUnit("Volume", true))

		workbenchGui.Add("Text", "x" . x . " yp+19 w110 h23 +0x200", translate("Safety Fuel"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w50 h20 Number Limit2 VsafetyFuelEdit", displayValue("Float", convertUnit("Volume", 5), 0))
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99", displayValue("Float", convertUnit("Volume", 4), 0))
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w90 h20", getUnit("Volume", true))

		workbenchTab.UseTab(3)

		x := 32
		x2 := x + 220
		x3 := x2 + 100
		w3 := 140
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		this.iFixedPitstopsListView := workbenchGui.Add("ListView", "x24 ys+34 w216 h217 H:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(kFixedPitstopRefuel ? ["Pitstop", "Lap", "Refuel", "Tyres"] : ["Pitstop", "Lap", "Tyres"], translate))
		this.iFixedPitstopsListView.OnEvent("Click", chooseSimFixedPitstop)
		this.iFixedPitstopsListView.OnEvent("DoubleClick", chooseSimFixedPitstop)
		this.iFixedPitstopsListView.OnEvent("ItemSelect", selectSimFixedPitstop)

		workbenchGui.Add("Text", "x" . x2 . " ys+34 w100 h23 +0x200", translate("Pitstop"))
		workbenchGui.Add("Edit", "x" . x3 . " yp-1 w50 Limit3 Number vsimFixedPitstopEdit").OnEvent("Change", updateSimFixedPitstop)
		workbenchGui.Add("UpDown", "x138 yp-2 w18 Range1-999")

		workbenchGui.Add("Text", "x" . x2 . " yp+25 w100 h23 +0x200", translate("Lap"))
		workbenchGui.Add("Edit", "x" . x3 . " yp-1 w50 Limit3 Number vsimFixedPitstopLapEdit").OnEvent("Change", updateSimFixedPitstop)
		workbenchGui.Add("UpDown", "x138 yp-2 w18 Range1-999")

		if kFixedPitstopRefuel {
			workbenchGui.Add("Text", "x" . x2 . " yp+27 w100 h23 +0x200", translate("Refuel"))
			workbenchGui.Add("Edit", "x" . x3 . " yp-3 w50 Limit3 Number vsimFixedPitstopRefuelEdit").OnEvent("Change", updateSimFixedPitstop)
			workbenchGui.Add("UpDown", "xp yp-2 w18 Range1-999")
			workbenchGui.Add("Text", "x" . (x3 + 55) . " yp+3 w80 h20", getUnit("Volume", true))
		}

		workbenchGui.Add("Text", "x" . x2 . " yp+25 w100 h23 +0x200", translate("Tyres"))

		compound := this.SelectedCompound[true]
		choices := [translate(normalizeCompound("Dry"))]
		chosen := (normalizeCompound("Dry") = compound)

		if (!chosen && (choices.Length > 0)) {
			compound := choices[1]
			chosen := 2
		}

		workbenchGui.Add("DropDownList", "x" . x3 . " yp-1 w" . w3 . " Choose" . chosen . " VsimFixedPitstopCompoundDropDown", concatenate([translate("No Change")], choices)).OnEvent("Change", updateSimFixedPitstop)

		workbenchGui.Add("Button", "x" . x4 . " yp+24 w23 h23 Center +0x200 vaddFixedPitstopButton").OnEvent("Click", addSimFixedPitstop)
		setButtonIcon(workbenchGui["addFixedPitstopButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		workbenchGui.Add("Button", "x" . x5 . " yp w23 h23 Center +0x200 vdeleteFixedPitstopButton").OnEvent("Click", deleteSimFixedPitstop)
		setButtonIcon(workbenchGui["deleteFixedPitstopButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		workbenchTab.UseTab(4)

		x := 32
		x2 := x + 220
		x3 := x2 + 100
		w3 := 140
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		this.iDriversListView := workbenchGui.Add("ListView", "x24 ys+34 w216 h217 H:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Stint", "Driver"], translate))
		this.iDriversListView.OnEvent("Click", chooseSimDriver)
		this.iDriversListView.OnEvent("DoubleClick", chooseSimDriver)
		this.iDriversListView.OnEvent("ItemSelect", selectSimDriver)

		workbenchGui.Add("Text", "x" . x2 . " ys+34 w90 h23 +0x200", translate("Driver"))
		workbenchGui.Add("DropDownList", "x" . x3 . " yp w" . w3 . " vsimDriverDropDown").OnEvent("Change", updateSimDriver)

		workbenchGui.Add("Button", "x" . x4 . " yp+30 w23 h23 Center +0x200 vaddDriverButton").OnEvent("Click", addSimDriver)
		setButtonIcon(workbenchGui["addDriverButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		workbenchGui.Add("Button", "x" . x5 . " yp w23 h23 Center +0x200 vdeleteDriverButton").OnEvent("Click", deleteSimDriver)
		setButtonIcon(workbenchGui["deleteDriverButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		workbenchTab.UseTab(5)

		x := 32
		x2 := x + 220
		x3 := x2 + 70
		w3 := 100
		x4 := x3 + w3 - 50
		x5 := x4 + 25

		x6 := x3 + w3 + 5
		x7 := x6 + 47
		x8 := x7 + 52

		this.iWeatherListView := workbenchGui.Add("ListView", "x24 ys+34 w216 h217 H:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Time", "Weather", "T Air", "T Track"], translate))
		this.iWeatherListView.OnEvent("Click", chooseSimWeather)
		this.iWeatherListView.OnEvent("DoubleClick", chooseSimWeather)
		this.iWeatherListView.OnEvent("ItemSelect", selectSimWeather)

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

		workbenchTab.UseTab(6)

		x := 32
		x0 := x - 4
		x1 := x + 74
		x2 := x1 + 22
		x3 := x2 + 28
		x4 := x1 + 16
		x5 := x3 + 44

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x24 ys+34 w179 h181", translate("Initial Conditions"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w72 h23 +0x200", translate("Compound"))

		compound := this.SelectedCompound[true]
		choices := [translate(normalizeCompound("Dry"))]
		chosen := (normalizeCompound("Dry") = compound)

		if (!chosen && (choices.Length > 0)) {
			compound := choices[1]
			chosen := 1
		}

		workbenchGui.Add("DropDownList", "x" . x1 . " yp w84 Choose" . chosen . " VsimCompoundDropDown", choices)

		workbenchGui.Add("Text", "x" . x . " yp+25 w72 h20 +0x200", translate("Initial Fuel"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w45 h20 Number Limit3 VsimInitialFuelAmountEdit", displayValue("Float", convertUnit("Volume", 90), 0)).OnEvent("Change", validateSimInitialFuelAmount)
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-999", displayValue("Float", convertUnit("Volume", 90), 0))
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w45 r1", getUnit("Volume", true))

		workbenchGui.Add("Text", "x" . x . " yp+58 w72 h20 +0x200", translate("Map"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w45 h20 Number Limit2 VsimMapEdit", "n/a").OnEvent("Change", (*) => this.updateState())
		workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99", "n/a")

		workbenchGui.Add("Text", "x" . x . " yp+23 w72 h23 +0x200", translate("Avg. Lap Time"))
		workbenchGui.Add("Edit", "x" . x1 . " yp w45 h20 VsimAvgLapTimeEdit", displayValue("Float", 120.0)).OnEvent("Change", validateSimAvgLapTime)
		workbenchGui.Add("Text", "x" . x3 . " yp+4 w30 h20", translate("Sec."))

		workbenchGui.Add("Text", "x" . x . " yp+21 w72 h20 +0x200", translate("Consumption"))
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

		workbenchGui.Add("GroupBox", "x214 ys+34 w174 h181", translate("Optimizer"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w100 h20 +0x200", translate("Initial Fuel"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimInitialFuelVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Refuel"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimRefuelVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Tyre Usage"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimTyreUsageVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Tyre Compound"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range0-100 ToolTip VsimTyreCompoundVariation", 0)

		workbenchGui.Add("Text", "x" . x . " yp+35 w100 h20 +0x200", translate("First Stint"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range-100-100 ToolTip VsimFirstStintWeight", 0)

		workbenchGui.Add("Text", "x" . x . " yp+22 w100 h20 +0x200", translate("Last Stint"))
		workbenchGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w60 0x10 Range-100-100 ToolTip VsimLastStintWeight", 0)

		x := 407
		x0 := x - 4
		x1 := x + 89
		x2 := x1 + 32
		x3 := x2 + 16
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x399 ys+34 w197 h120", translate("Summary"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w88 h20 +0x200", translate("# Pitstops"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimNumPitstopResult")

		workbenchGui.Add("Text", "x" . x . " yp+23 w88 h20 +0x200", translate("# Tyre Changes"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimNumTyreChangeResult")

		workbenchGui.Add("Text", "x" . x . " yp+21 w88 h20 +0x200", translate("@ Pitlane"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimPitlaneSecondsResult")
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w50 h20", translate("Seconds"))

		workbenchGui.Add("Text", "x" . x . " yp+21 w88 h20 +0x200", translate("@ Finish"))
		workbenchGui.Add("Edit", "x" . x1 . " yp+1 w40 h20 Disabled VsimSessionResultResult")
		workbenchGui.Add("Text", "x" . x3 . " yp+2 w50 h20 VsimSessionResultLabel", translate("Laps"))

		workbenchGui.Add("Text", "x399 yp+39 w60 h23 +0x200", translate("Use"))

		choices := collect(["Fixed", "Telemetry", "Fixed + Telemetry"], translate)

		workbenchGui.Add("DropDownList", "x460 yp w136 Choose2 VsimInputDropDown", choices).OnEvent("Change", (*) => this.updateState())

		workbenchGui.Add("Button", "x399 yp+26 w197 h20", translate("Simulate!")).OnEvent("Click", runSimulation)

		workbenchTab.UseTab(7)

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

		workbenchGui.Add("GroupBox", "x24 ys+34 w143 h181 H:Grow(0.8)", translate("Electronics"))

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add("Text", "x" . x . " yp+21 w70 h20 +0x200", translate("Map"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Number Limit2 VstrategyStartMapEdit Disabled", 1)
		; workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99 Disabled", 1)

		workbenchGui.Add("Text", "x" . x . " yp+25 w70 h20 +0x200", translate("TC"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Number Limit2 VstrategyStartTCEdit Disabled", 1)
		; workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99 Disabled", 1)

		workbenchGui.Add("Text", "x" . x . " yp+25 w70 h20 +0x200", translate("ABS"))
		workbenchGui.Add("Edit", "x" . x1 . " yp-1 w50 h20 Number Limit2 VstrategyStartABSEdit Disabled", 2)
		; workbenchGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99 Disabled", 2)

		x := 186
		x0 := x + 50
		x1 := x + 70
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		workbenchGui.SetFont("Italic", "Arial")

		workbenchGui.Add("GroupBox", "x178 ys+34 w174 h181 H:Grow(0.8)", translate("Tyres"))

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

		workbenchGui.Add("GroupBox", "x363 ys+34 w233 h181 H:Grow(0.8)", translate("Pitstops"))

		workbenchGui.SetFont("Norm", "Arial")

		this.iPitstopListView := workbenchGui.Add("ListView", "x" . x . " yp+21 w216 h148 H:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Lap", "Driver", "Fuel", "Tyres", "Map"], translate))
		this.iPitstopListView.OnEvent("Click", noSelect)
		this.iPitstopListView.OnEvent("DoubleClick", noSelect)

		workbenchGui.Rules := ""

		workbenchGui.SetFont("Norm", "Arial")

		workbenchGui.Add(StrategyWorkbench.WorkbenchResizer(workbenchGui))

		car := this.SelectedCar
		track := this.SelectedTrack

		workbenchGui["sessionTypeDropDown"].Choose(Max(1, inList(["Time", "Time + 1", "Laps", "Laps + 1"]
															   , getMultiMapValue(settings, "Strategy Workbench", "Session Type", "Time"))))

		chooseSessionType()

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
						.rowStyle { font-size: 11px; color: #%fontColor%; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; color: #%fontColor%; background-color: #%oddRowBackColor%; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)"

			before := substituteVariables(before, {fontColor: this.Window.Theme.TextColor
												 , headerBackColor: this.Window.Theme.ListBackColor["Header"]
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

			html := (before . drawChartFunction . substituteVariables(after, {width: (this.ChartViewer.getWidth() - 4), height: (this.ChartViewer.getHeight() - 4), backColor: this.Window.AltBackColor}))

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

	showStrategyChart(html) {
		this.ChartViewer.document.open()
		this.ChartViewer.document.write(html)
		this.ChartViewer.document.close()

		this.iStrategyChartHTML := html

		this.Control["chartSourceDropDown"].Choose(2)
		this.Control["chartTypeDropDown"].Visible := false
	}

	showComparisonChart(html) {
		this.ChartViewer.document.open()
		this.ChartViewer.document.write(html)
		this.ChartViewer.document.close()

		this.iComparisonChartHTML := html

		this.Control["chartSourceDropDown"].Choose(3)
		this.Control["chartTypeDropDown"].Visible := false
	}

	updateState() {
		local oldTChoice, oldFChoice, index

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

		if (this.Control["simMapEdit"].Text = 0)
			this.Control["simMapEdit"].Text := "n/a"

		this.Control["tyreSetAddButton"].Enabled := (this.TyreCompounds.Length > this.TyreSetListView.GetCount())

		if (this.TyreSetListView.GetNext(0) > 0) {
			this.Control["tyreSetDropDown"].Enabled := true
			this.Control["tyreSetCountEdit"].Enabled := true
			this.Control["tyreSetLapsEdit"].Enabled := true
			this.Control["tyreSetDeleteButton"].Enabled := true
		}
		else {
			this.Control["tyreSetDropDown"].Enabled := false
			this.Control["tyreSetLapsEdit"].Enabled := false
			this.Control["tyreSetCountEdit"].Enabled := false
			this.Control["tyreSetDeleteButton"].Enabled := false

			this.Control["tyreSetDropDown"].Choose(0)
			this.Control["tyreSetLapsEdit"].Text := ""
			this.Control["tyreSetCountEdit"].Text := ""
		}

		if (this.Control["pitstopRuleDropDown"].Value = 2) {
			this.Control["pitstopRuleEdit"].Visible := true
			this.Control["pitstopRuleUpDown"].Visible := true

			if ((Trim(this.Control["pitstopRuleEdit"].Text) = "") || !this.Control["pitstopRuleEdit"].Value)
				this.Control["pitstopRuleEdit"].Text := 1

			oldTChoice := ["Always", "Window"][this.Control["pitstopWindowDropDown"].Value]

			this.Control["pitstopWindowDropDown"].Delete()
			this.Control["pitstopWindowDropDown"].Add(collect(["Always", "Window"], translate))
			this.Control["pitstopWindowDropDown"].Choose(inList(["Always", "Window"], oldTChoice))
		}
		else {
			this.Control["pitstopRuleEdit"].Visible := false
			this.Control["pitstopRuleUpDown"].Visible := false

			this.Control["pitstopWindowDropDown"].Delete()
			this.Control["pitstopWindowDropDown"].Add(collect(["Always"], translate))
			this.Control["pitstopWindowDropDown"].Choose(1)
		}

		if (this.Control["pitstopWindowDropDown"].Value = 2) {
			this.Control["pitstopWindowEdit"].Visible := true
			this.Control["pitstopWindowLabel"].Visible := true

			if !InStr(this.Control["pitstopWindowEdit"].Text, "-")
				this.Control["pitstopWindowEdit"].Text := "25 - 35"
		}
		else {
			this.Control["pitstopWindowEdit"].Visible := false
			this.Control["pitstopWindowLabel"].Visible := false
		}

		if this.Control["tyreChangeRequirementsDropDown"].Value {
			index := inList(collect(["Optional", "Required", "Always", "Disallowed"], translate), this.Control["tyreChangeRequirementsDropDown"].Text)

			oldTChoice := ["Optional", "Required", "Always", "Disallowed"][index]
		}
		else
			oldTChoice := false

		if this.Control["refuelRequirementsDropDown"].Value {
			index := inList(collect(["Optional", "Required", "Always", "Disallowed"], translate), this.Control["refuelRequirementsDropDown"].Text)

			oldFChoice := ["Optional", "Required", "Always", "Disallowed"][index]
		}
		else
			oldFChoice := false

		if (this.Control["pitstopRuleDropDown"].Value = 1) {
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

		this.Control["addFixedPitstopButton"].Enabled := this.FixedPitstops

		if (this.FixedPitstops && this.FixedPitstopsListView.GetNext(0)) {
			this.Control["deleteFixedPitstopButton"].Enabled := true

			this.Control["simFixedPitstopEdit"].Enabled := true
			this.Control["simFixedPitstopLapEdit"].Enabled := true

			if kFixedPitstopRefuel
				this.Control["simFixedPitstopRefuelEdit"].Enabled := true

			this.Control["simFixedPitstopCompoundDropDown"].Enabled := true
		}
		else {
			if this.FixedPitstopsListView.GetNext(0)
				loop this.FixedPitstopsListView.GetCount()
					this.FixedPitstopsListView.Modify(A_Index, "-Select")

			this.Control["deleteFixedPitstopButton"].Enabled := false

			this.Control["simFixedPitstopEdit"].Enabled := false
			this.Control["simFixedPitstopLapEdit"].Enabled := false

			if kFixedPitstopRefuel
				this.Control["simFixedPitstopRefuelEdit"].Enabled := false

			this.Control["simFixedPitstopCompoundDropDown"].Enabled := false

			this.Control["simFixedPitstopEdit"].Text := ""
			this.Control["simFixedPitstopLapEdit"].Text := ""

			if kFixedPitstopRefuel
				this.Control["simFixedPitstopRefuelEdit"].Text := ""

			this.Control["simFixedPitstopCompoundDropDown"].Choose(0)
		}

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
		local settingsMenu := collect(["Settings", "---------------------------------------------"], translate)
		local fileNames := concatenate(getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\")
									 , getFileNames("*.script", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\"))
		local validators, ignore, fileName, validator, found

		if this.AutoInitialize
			settingsMenu.Push(translate("[x]") . A_Space . translate("Auto Initialize"))
		else
			settingsMenu.Push(translate("[  ]") . A_Space . translate("Auto Initialize"))

		settingsMenu.Push(collect(["---------------------------------------------", "Initialize from Strategy", "Initialize from Settings...", "Initialize from Database", "Initialize from Telemetry", "Initialize from Simulation", "---------------------------------------------"], translate)*)

		if this.FixedPitstops
			settingsMenu.Push(translate("[x]") . A_Space . translate("Fixed Pitstops"))
		else
			settingsMenu.Push(translate("[  ]") . A_Space . translate("Fixed Pitstops"))

		settingsMenu.Push(translate("---------------------------------------------"))
		settingsMenu.Push(translate("Validation:"))

		if (fileNames.Length > 0) {
			validators := []
			found := false

			for ignore, fileName in fileNames {
				SplitPath(fileName, , , , &validator)

				if !inList(validators, validator) {
					validators.Push(validator)

					if (validator = this.SelectedValidator) {
						settingsMenu.Push("[x] " . validator)

						found := true
					}
					else
						settingsMenu.Push("[  ] " . validator)
				}
			}

			if !found
				this.iSelectedValidator := false
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

	createConsumablesChart(strategy, width, height, timeSeries, lapSeries, fuelSeries, tyreSeries, &drawChartFunction, &chartID) {
		return this.StrategyViewer.createConsumablesChart(strategy, width, height, timeSeries, lapSeries, fuelSeries, tyreSeries, &drawChartFunction, &chartID)
	}

	showStrategyInfo(strategy, plot := true) {
		this.StrategyViewer.showStrategyInfo(strategy)

		if (strategy && plot)
			this.showStrategyPlot(strategy)
	}

	showStrategyPlot(strategy) {
		local html, drawChartFunction, chartID, width, before, after
		local timeSeries, lapSeries, fuelSeries, tyreSeries

		if strategy {
			before := "
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; color: #%fontColor%; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; color: #%fontColor%; background-color: #%oddRowBackColor%; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table']}).then(drawChart);
			)"

			before := substituteVariables(before, {fontColor: this.Window.Theme.TextColor
												 , headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

			after := "
			(
					</script>
				</head>
			)"

			timeSeries := []
			lapSeries := []
			fuelSeries := []
			tyreSeries := []

			this.createStintsInfo(strategy, &timeSeries, &lapSeries, &fuelSeries, &tyreSeries)

			drawChartFunction := false
			chartID := false

			width := (this.ChartViewer.getWidth() - 4)

			html := this.createConsumablesChart(strategy, width, width / 2, timeSeries, lapSeries, fuelSeries, tyreSeries, &drawChartFunction, &chartID)

			tableCSS := this.StrategyViewer.getTableCSS()

			html := ("<html>" . before . drawChartFunction . "; function drawChart() { drawChart" . chartID . "(); }" . after . "<body style='background-color: #" . this.Window.AltBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } </style>" . html . "</body></html>")

			this.showStrategyChart(html)
		}
		else {
			html := substituteVariables("<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>", {backColor: this.Window.AltBackColor})

			this.showStrategyChart(html)
		}
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
		vAxis := "vAxis: { gridlines: { color: '#" . this.Window.Theme.GridColor . "' }, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}, titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, "

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
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'}}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "', titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, gridlines: { color: '" . this.Window.Theme.GridColor . "' }, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'} }, " . series . ", " . vAxis . "};")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bar") {
			if (minValue = kUndefined)
				minValue := 0

			if (maxValue = kUndefined)
				maxValue := 0

			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'}}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "', minValue: " . minValue . ", maxValue: " . maxValue . ", titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, gridlines: { color: '" . this.Window.Theme.GridColor . "' }, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}}, vAxis: {gridlines: { color: '" . this.Window.Theme.GridColor . "' }, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}} };")
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bubble") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'}}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "', titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, gridlines: { color: '" . this.Window.Theme.GridColor . "'}, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}, viewWindowMode: 'pretty' }, vAxis: { title: '" . translate(yAxises[1]) . "', gridlines: { color: '" . this.Window.Theme.GridColor . "'}, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}, titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, viewWindowMode: 'pretty' }, colorAxis: { legend: {position: 'none'}, colors: ['blue', 'red'] }, sizeAxis: { maxSize: 15 } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BubbleChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Line") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'}}, vAxis: { gridlines: { color: '" . this.Window.Theme.GridColor . "' }, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}}, hAxis: { title: '" . translate(xAxis) . "', titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, gridlines: { color: '" . this.Window.Theme.GridColor . "' }, textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'}}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "' };")

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

			this.Control["simMapEdit"].Text := "n/a"

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

			if (track && this.AutoInitialize)
				this.chooseSettingsMenu("Database")
		}
	}

	loadWeather(weather, force := false) {
		if (force || (this.SelectedWeather != weather)) {
			this.iSelectedWeather := weather

			this.Control["weatherDropDown"].Choose(inList(kWeatherConditions, weather))

			this.loadDataType(this.SelectedDataType, true)
		}
	}

	loadDataType(dataType, force := false) {
		local tyreCompound, tyreCompoundColor, lapsDB, ignore, column, categories, field, category, value, settings
		local driverNames, index, names, schema, availableCompounds, settings, axis, value

		if (force || (this.SelectedDataType != dataType)) {
			this.showTelemetryChart(false)

			this.iSelectedDataType := dataType
			this.iSelectedDrivers := false

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Strategy Workbench", "Data Type", dataType)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			lapsDB := LapsDatabase(this.SelectedSimulator, this.SelectedCar
								 , this.SelectedTrack, this.SelectedDrivers)

			this.DataListView.Delete()

			while this.DataListView.GetCount("Col")
				this.DataListView.DeleteCol(1)

			if (this.SelectedDataType = "Electronics") {
				for ignore, column in collect(["Compound", "Map", "#"], translate)
					this.DataListView.InsertCol(A_Index, "", column)

				categories := lapsDB.getMapsCount(this.SelectedWeather)
				field := "Map"
			}
			else if (this.SelectedDataType = "Tyres") {
				for ignore, column in collect(["Compound", "Pressure", "#"], translate)
					this.DataListView.InsertCol(A_Index, "", column)

				categories := lapsDB.getPressuresCount(this.SelectedWeather)
				field := "Tyre.Pressure"
			}

			availableCompounds := []

			for ignore, category in categories {
				value := category[field]

				if (value = "n/a")
					value := translate(value)

				tyreCompound := category["Tyre.Compound"]

				if InStr(tyreCompound, ",")
					tyreCompound := compounds(string2Values(",", tyreCompound)
											, string2Values(",", category["Tyre.Compound.Color"]))
				else
					tyreCompound := [compound(tyreCompound, category["Tyre.Compound.Color"])]

				this.DataListView.Add("", values2String(", ", collect(tyreCompound, translate)*), value, category["Count"])

				if (tyreCompound.Length = 1) {
					tyreCompound := tyreCompound[1]

					if !inList(availableCompounds, tyreCompound)
						availableCompounds.Push(tyreCompound)
				}
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

			if (availableCompounds.Length > 0) {
				driverNames := SessionDatabase.getAllDrivers(this.SelectedSimulator, true)

				for index, names in driverNames
					driverNames[index] := values2String(", ", names*)

				this.Control["driverDropDown"].Add(Array(translate("All"), driverNames*))
				this.Control["driverDropDown"].Choose(1)

				schema := filterSchema(lapsDB.getSchema(dataType, true))

				this.Control["dataXDropDown"].Add(schema)
				this.Control["dataY1DropDown"].Add(schema)
				this.Control["dataY2DropDown"].Add(Array(translate("None"), schema*))
				this.Control["dataY3DropDown"].Add(Array(translate("None"), schema*))

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				value := getMultiMapValue(settings, "Strategy Workbench", "Chart." . dataType . ".Type", kUndefined)

				if (value != kUndefined) {
					this.Control["chartTypeDropDown"].Choose(inList(["Scatter", "Bar", "Bubble", "Line"], value))

					this.iSelectedChartType := value

					field := getMultiMapValue(settings, "Strategy Workbench", "Chart." . dataType . ".X-Axis")

					if (field = "Tyre.Laps")
						field := "Tyre.Laps.Front.Left"

					this.Control["dataXDropDown"].Choose(inList(schema, field))

					loop 3
						this.Control["dataY" . A_Index . "DropDown"].Choose(1)

					for axis, value in string2Values(";", getMultiMapValue(settings, "Strategy Workbench", "Chart." . dataType . ".Y-Axises"))
						this.Control["dataY" . axis . "DropDown"].Choose(inList(schema, value) + ((axis = 1) ? 0 : 1))
				}
				else if (dataType = "Electronics") {
					this.Control["dataXDropDown"].Choose(inList(schema, "Map"))
					this.Control["dataY1DropDown"].Choose(inList(schema, "Fuel.Consumption"))
					this.Control["dataY2DropDown"].Choose(1)
					this.Control["dataY3DropDown"].Choose(1)
				}
				else if (dataType = "Tyres") {
					this.Control["dataXDropDown"].Choose(inList(schema, "Tyre.Laps.Front.Left"))
					this.Control["dataY1DropDown"].Choose(inList(schema, "Tyre.Pressure"))
					this.Control["dataY2DropDown"].Choose(inList(schema, "Tyre.Temperature") + 1)
					this.Control["dataY3DropDown"].Choose(1)
				}
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
		this.Control["simFixedPitstopCompoundDropDown"].Delete()
		this.Control["simFixedPitstopCompoundDropDown"].Add(concatenate([translate("No Change")], translatedCompounds))

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
			this.TyreSetListView.Add("", translate(compound), 50, 99)

		this.TyreSetListView.ModifyCol()
		this.TyreSetListView.ModifyCol(1, 65)
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

	loadChart(chartType, save := false) {
		local lapsDB, records, schema, xAxis, yAxises
		local report, compound

		this.iSelectedChartType := chartType

		this.Control["chartTypeDropDown"].Choose(inList(["Scatter", "Bar", "Bubble", "Line"], chartType))

		lapsDB := LapsDatabase(this.SelectedSimulator, this.SelectedCar
								  , this.SelectedTrack, this.SelectedDrivers)

		if (this.SelectedDataType = "Electronics")
			records := lapsDB.getElectronicEntries(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		else if (this.SelectedDataType = "Tyres")
			records := lapsDB.getTyreEntries(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor)
		else
			records := []

		schema := filterSchema(lapsDB.getSchema(this.SelectedDataType, true))

		try {
			xAxis := schema[this.Control["dataXDropDown"].Value]
			yAxises := Array(schema[this.Control["dataY1DropDown"].Value])

			if (this.Control["dataY2DropDown"].Value > 1)
				yAxises.Push(schema[this.Control["dataY2DropDown"].Value - 1])

			if (this.Control["dataY3DropDown"].Value > 1)
				yAxises.Push(schema[this.Control["dataY3DropDown"].Value - 1])

			if save {
				report := this.SelectedDataType
				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(settings, "Strategy Workbench", "Chart." . report . ".Type", chartType)
				setMultiMapValue(settings, "Strategy Workbench", "Chart." . report . ".X-Axis", xAxis)
				setMultiMapValue(settings, "Strategy Workbench", "Chart." . report . ".Y-Axises", values2String(";", yAxises*))

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
			}

			this.showDataPlot(records, xAxis, yAxises)
		}
		catch Any as exception {
			logError(exception)

			this.showTelemetryChart(false)
		}

		this.updateState()
	}

	selectSessionType(sessionType, additionalLaps := 0) {
		local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		this.iSelectedSessionType := sessionType
		this.iSelectedAdditionalLaps := additionalLaps

		if (sessionType = "Duration") {
			sessionType := ("Time" . (additionalLaps ? (" + " . additionalLaps) : ""))

			this.Control["sessionTypeDropDown"].Choose(1 + additionalLaps)
			this.Control["sessionLengthLabel"].Text := translate("Minutes")
			this.Control["simSessionResultLabel"].Text := translate("Laps")
		}
		else {
			sessionType := ("Laps" . (additionalLaps ? (" + " . additionalLaps) : ""))

			this.Control["sessionTypeDropDown"].Choose(3 + additionalLaps)
			this.Control["sessionLengthLabel"].Text := translate("Laps")
			this.Control["simSessionResultLabel"].Text := translate("Seconds")
		}

		setMultiMapValue(settings, "Strategy Workbench", "Session Type", sessionType)

		writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
	}

	chooseSettingsMenu(line) {
		local simulator := this.SelectedSimulator
		local car := this.SelectedCar
		local track := this.SelectedTrack
		local strategy, pitstopRule, pitstopWindow
		local ignore, descriptor, directory, numPitstops, name, pitstop, tyreCompound, tyreCompoundColor, tyreLife
		local simulator, car, track, simulatorCode, dirName, file, settings, settingsDB, msgResult
		local lapsDB, fastestLapTime, row, lapTime, prefix, data, fuelCapacity, initialFuelAmount, map
		local validators, index, fileName, validator, index, forecast, time, hour, minute, value, fixedPitstop, found

		switch line {
			case 3:
				this.iAutoInitialize := !this.AutoInitialize

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(settings, "Strategy Workbench", "Auto Initialize", this.AutoInitialize)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
			case 5, "Strategy": ; "Load from Strategy"
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
							this.Control["pitstopRuleDropDown"].Choose(1)

							value := ""
						}
						else {
							this.Control["pitstopRuleDropDown"].Choose(2)

							value := pitstopRule
						}

						this.Control["pitstopRuleEdit"].Text := value

						pitstopWindow := strategy.PitstopWindow

						if !pitstopWindow {
							this.Control["pitstopWindowDropDown"].Choose(1)

							value := ""
						}
						else {
							this.Control["pitstopWindowDropDown"].Delete()
							this.Control["pitstopWindowDropDown"].Add(collect(["Always", "Window"], translate))

							this.Control["pitstopWindowDropDown"].Choose(2)

							value := values2String("-", pitstopWindow*)
						}

						this.Control["pitstopWindowEdit"].Text := value

						if pitstopRule {
							this.Control["tyreChangeRequirementsDropDown"].Delete()
							this.Control["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))
							this.Control["refuelRequirementsDropDown"].Delete()
							this.Control["refuelRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))

							this.Control["refuelRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"], strategy.RefuelRule))
							this.Control["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"], strategy.TyreChangeRule))
						}
						else {
							this.Control["tyreChangeRequirementsDropDown"].Delete()
							this.Control["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))
							this.Control["refuelRequirementsDropDown"].Delete()
							this.Control["refuelRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))

							this.Control["refuelRequirementsDropDown"].Choose(inList(["Optional", "Always", "Disallowed"], strategy.RefuelRule))
							this.Control["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Always", "Disallowed"], strategy.TyreChangeRule))
						}

						for ignore, descriptor in strategy.TyreSets {
							found := false

							loop this.TyreSetListView.GetCount()
								if (translate(compound(descriptor[1], descriptor[2])) = this.TyreSetListView.GetText(A_Index, 1)) {
									found := true

									break
								}

							/*
							if !found
								if (descriptor.Length > 3)
									this.TyreSetListView.Add("", translate(compound(descriptor[1], descriptor[2])), descriptor[4], descriptor[3])
								else
									this.TyreSetListView.Add("", translate(compound(descriptor[1], descriptor[2])), 50, descriptor[3])
							*/

							loop this.TyreSetListView.GetCount()
								if (translate(compound(descriptor[1], descriptor[2])) = this.TyreSetListView.GetText(A_Index, 1)) {
									this.TyreSetListView.Modify(A_Index, "Col3", descriptor[3])

									if (descriptor.Length > 3)
										this.TyreSetListView.Modify(A_Index, "Col2", descriptor[4])
								}
						}

						this.TyreSetListView.ModifyCol()
						this.TyreSetListView.ModifyCol(1, 65)

						this.iStintDrivers := []

						numPitstops := strategy.Pitstops.Length

						name := SessionDatabase.getDriverName(simulator, strategy.Driver)

						this.FixedPitstopsListView.Delete()

						for pitstop, fixedPitstop in strategy.FixedPitstops {
							this.iFixedPitstops := true

							if kFixedPitstopRefuel
								this.FixedPitstopsListView.Add("", pitstop, fixedPitstop.Lap
															 , fixedPitstop.HasProp("Refuel") ? fixedPitstop.Refuel : 0
															 , fixedPitstop.Compound ? translate(fixedPitstop.Compound) : translate("-"))
							else
								this.FixedPitstopsListView.Add("", pitstop, fixedPitstop.Lap
																 , fixedPitstop.Compound ? translate(fixedPitstop.Compound) : translate("-"))
						}

						this.DriversListView.Delete()

						this.DriversListView.Add("", (numPitstops = 0) ? "1+" : 1, name)

						this.StintDrivers.Push((InStr(name, "John Doe") = 1) ? false : strategy.Driver)

						for ignore, pitstop in strategy.Pitstops {
							name := SessionDatabase.getDriverName(simulator, pitstop.Driver)

							this.DriversListView.Add("", (numPitstops = A_Index) ? ((A_Index + 1) . "+") : (A_Index + 1), name)

							this.StintDrivers.Push((InStr(name, "John Doe") = 1) ? false : pitstop.Driver)
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

						this.selectSessionType(strategy.SessionType, strategy.AdditionalLaps)

						this.Control["sessionLengthEdit"].Text := Round(strategy.SessionLength)

						this.Control["stintLengthEdit"].Text := strategy.StintLength
						this.Control["formationLapCheck"].Value := strategy.FormationLap
						this.Control["postRaceLapCheck"].Value := strategy.PostRaceLap

						tyreCompound := strategy.TyreCompound
						tyreCompoundColor := strategy.TyreCompoundColor

						this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))

						this.Control["simAvgLapTimeEdit"].Text := displayValue("Float", strategy.AvgLapTime, 1)
						this.Control["simFuelConsumptionEdit"].Text := displayValue("Float", convertUnit("Volume", strategy.FuelConsumption))
						this.Control["simInitialFuelAmountEdit"].Text := displayValue("Float", convertUnit("Volume", strategy.StartFuel), 0)
						this.Control["simMapEdit"].Text := strategy.Map

						; this.Control["simConsumptionVariation"].Value := strategy.ConsumptionVariation
						this.Control["simTyreUsageVariation"].Value := strategy.TyreUsageVariation
						this.Control["simtyreCompoundVariation"].Value := strategy.TyreCompoundVariation
						this.Control["simInitialFuelVariation"].Value := strategy.InitialFuelVariation
						this.Control["simRefuelVariation"].Value := strategy.RefuelVariation

						this.Control["simFirstStintWeight"].Value := strategy.FirstStintWeight
						this.Control["simLastStintWeight"].Value := strategy.LastStintWeight

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
						withBlockedWindows(MsgBox, translate("There is no current Strategy."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("You must first select a car and a track."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 6: ; "Load from Settings..."
				if (simulator && car && track) {
					if GetKeyState("Ctrl") {
						directory := SessionDatabase.DatabasePath
						simulatorCode := SessionDatabase.getSimulatorCode(simulator)

						dirName := directory . "User\" . simulatorCode . "\" . car . "\" . track . "\Race Settings"

						DirCreate(dirName)

						this.Window.Opt("+OwnDialogs")

						OnMessage(0x44, translateLoadCancelButtons)
						file := withBlockedWindows(FileSelect, 1, dirName, translate("Load Race Settings..."), "Settings (*.settings)")
						OnMessage(0x44, translateLoadCancelButtons, 0)
					}
					else
						file := getFileName("Race.settings", kUserConfigDirectory)

					if (file != "") {
						settings := readMultiMap(file)

						if (settings.Count > 0) {
							this.Control["formationLapCheck"].Value := getMultiMapValue(settings, "Session Settings", "Lap.Formation", false)
							this.Control["postRaceLapCheck"].Value := getMultiMapValue(settings, "Session Settings", "Lap.PostRace", false)

							this.Control["pitstopDeltaEdit"].Text := getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta", 60)
							this.Control["pitstopTyreServiceEdit"].Text := getMultiMapValue(settings, "Strategy Settings", "Service.Tyres", 30)

							value := getMultiMapValue(settings, "Strategy Settings", "Service.Refuel.Rule", "Dynamic")

							this.Control["pitstopFuelServiceRuleDropDown"].Choose(1 + (value != "Fixed"))
							this.Control["pitstopFuelServiceLabel"].Text := translate(["Seconds", "Seconds (Refuel of 10 liters)"][1 + (value != "Fixed")])
							this.Control["pitstopFuelServiceEdit"].Text := displayValue("Float", getMultiMapValue(settings, "Strategy Settings", "Service.Refuel", 1.8))

							this.Control["pitstopServiceDropDown"].Choose((getMultiMapValue(settings, "Strategy Settings", "Service.Order", "Simultaneous") = "Simultaneous") ? 1 : 2)
							this.Control["safetyFuelEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.SafetyMargin", 4)), 0)

							tyreCompound := getMultiMapValue(settings, "Session Setup", "Tyre.Compound", "Dry")
							tyreCompoundColor := getMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", "Black")

							this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))

							this.Control["simAvgLapTimeEdit"].Text := displayValue("Float", getMultiMapValue(settings, "Session Settings", "Lap.AvgTime", 120), 1)
							this.Control["simFuelConsumptionEdit"].Text := displayValue("Float", convertUnit("Volume", getMultiMapValue(settings, "Session Settings", "Fuel.AvgConsumption", 3.0)))

							if (getMultiMapValue(settings, "Session Rules", "Strategy", "No") = "Yes") {
								this.Control["stintLengthEdit"].Text := getMultiMapValue(settings, "Session Rules", "Stint.Length", 70)

								pitstopRule := getMultiMapValue(settings, "Session Rules", "Pitstop.Rule", 0)

								if !pitstopRule {
									this.Control["pitstopRuleDropDown"].Choose(1)

									value := ""
								}
								else {
									this.Control["pitstopRuleDropDown"].Choose(2)

									value := pitstopRule
								}

								this.Control["pitstopRuleEdit"].Text := value

								pitstopWindow := getMultiMapValue(settings, "Session Rules", "Pitstop.Window", false)

								if !pitstopWindow {
									this.Control["pitstopWindowDropDown"].Choose(1)

									value := ""
								}
								else {
									this.Control["pitstopWindowDropDown"].Delete()
									this.Control["pitstopWindowDropDown"].Add(collect(["Always", "Window"], translate))

									this.Control["pitstopWindowDropDown"].Choose(2)

									value := values2String("-", pitstopWindow*)
								}

								this.Control["pitstopWindowEdit"].Text := value

								if pitstopRule {
									this.Control["tyreChangeRequirementsDropDown"].Delete()
									this.Control["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))
									this.Control["refuelRequirementsDropDown"].Delete()
									this.Control["refuelRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))

									this.Control["refuelRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"], getMultiMapValue(settings, "Session Rules", "Pitstop.Refuel", "Optional")))
									this.Control["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"], getMultiMapValue(settings, "Session Rules", "Pitstop.Tyre", "Optional")))
								}
								else {
									this.Control["tyreChangeRequirementsDropDown"].Delete()
									this.Control["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))
									this.Control["refuelRequirementsDropDown"].Delete()
									this.Control["refuelRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))

									this.Control["refuelRequirementsDropDown"].Choose(inList(["Optional", "Always", "Disallowed"], getMultiMapValue(settings, "Session Rules", "Pitstop.Refuel", "Optional")))
									this.Control["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Always", "Disallowed"], getMultiMapValue(settings, "Session Rules", "Pitstop.Tyre", "Optional")))
								}

								for ignore, descriptor in string2Values(";", getMultiMapValue(settings, "Session Rules", "Tyre.Sets", "")) {
									descriptor := string2Values(InStr(descriptor, ":") ? ":" : "#", descriptor)

									loop this.TyreSetListView.GetCount()
										if (translate(compound(descriptor[1], descriptor[2])) = this.TyreSetListView.GetText(A_Index, 1)) {
											this.TyreSetListView.Modify(A_Index, "Col3", descriptor[3])

											if (descriptor.Length > 3)
												this.TyreSetListView.Modify(A_Index, "Col2", descriptor[4])
										}
								}

								this.TyreSetListView.ModifyCol()
								this.TyreSetListView.ModifyCol(1, 65)

								this.updateState()
							}
						}
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("You must first select a car and a track."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 7, "Database":
				if (simulator && car && track) {
					settings := SettingsDatabase().loadSettings(simulator, car, track, this.SelectedWeather)

					if (settings.Count > 0) {
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

						if (getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage", kUndefined) != kUndefined)
							for tyreCompound, tyreLife in string2Map(";", "->", getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage"))
								loop this.TyreSetListView.GetCount()
									if (translate(tyreCompound) = this.TyreSetListView.GetText(A_Index, 1))
										this.TyreSetListView.Modify(A_Index, "Col2", tyreLife)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("You must first select a car and a track."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 8: ; "Update from Telemetry..."
				if (simulator && car && track) {
					lapsDB := LapsDatabase(simulator, car, track, this.SelectedDrivers)

					fastestLapTime := false

					for ignore, row in lapsDB.getMapData(this.SelectedWeather, this.SelectedCompound, this.SelectedCompoundColor) {
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
					withBlockedWindows(MsgBox, translate("You must first select a car and a track."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 9: ; "Import from Simulation..."
				if simulator {
					prefix := SessionDatabase.getSimulatorCode(simulator)

					if !prefix {
						OnMessage(0x44, translateOkButton)
						withBlockedWindows(MsgBox, translate("This is not supported for the selected simulator..."), translate("Warning"), 262192)
						OnMessage(0x44, translateOkButton, 0)

						return
					}

					data := readSimulator(prefix, car, track)

					if ((getMultiMapValue(data, "Session Data", "Car") != car) || (getMultiMapValue(data, "Session Data", "Track") != track))
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

						if ((tyreCompound != kUndefined) && (tyreCompoundColor != kUndefined))
							this.Control["simCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)))

						map := getMultiMapValue(data, "Car Data", "Map", kUndefined)

						if (map != kUndefined)
							this.Control["simMapEdit"].Text := (isNumber(map) ? Round(map) : map)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("You must first select a simulation."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 11:
				if this.FixedPitstops {
					this.iFixedPitstops := false

					this.updateState()
				}
				else {
					OnMessage(0x44, translateYesNoButtons)
					msgResult := withBlockedWindows(MsgBox, translate("Do you really want to use fixed pitstops? Using fixed pitstops can result in invalid strategies."), translate("Warning"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes") {
						this.iFixedPitstops := true

						this.updateState()
					}
				}
			default:
				if (line = 13) {
					this.Window.Block()

					try {
						ValidatorsEditor(this).editValidators(this.Window)
					}
					finally {
						this.Window.Unblock()
					}
				}
				else if (line > 13) {
					validators := []

					for ignore, fileName in concatenate(getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\")
													  , getFileNames("*.script", kResourcesDirectory . "Strategy\Validators\", kUserHomeDirectory . "Validators\")) {
						SplitPath(fileName, , , , &validator)

						if !inList(validators, validator)
							validators.Push(validator)
					}

					validator := validators[line - 13]

					if (this.iSelectedValidator = validator)
						this.iSelectedValidator := false
					else
						this.iSelectedValidator := validator

					this.updateSettingsMenu()
				}
		}

		this.updateSettingsMenu()
	}

	chooseSimulationMenu(line) {
		local strategy, selectStrategy

		switch line {
			case 3: ; "Run Simulation"
				selectStrategy := GetKeyState("Ctrl")

				this.runSimulation()

				if (selectStrategy && !GetKeyState("Escape"))
					this.chooseSimulationMenu(5)
			case 5: ; "Use as Strategy..."
				strategy := this.SelectedScenario

				if strategy
					this.selectStrategy(strategy)
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("There is no current scenario. Please run a simulation first..."), translate("Warning"), 262192)
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
					strategy := readMultiMap(fileName)

					if (strategy.Count > 0) {
						this.selectStrategy(this.createStrategy(strategy))

						if this.AutoInitialize
							this.chooseSettingsMenu("Strategy")
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("There is no active Race Strategy."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 4: ; "Load Strategy..."
				if GetKeyState("Ctrl") {
					this.Window.Opt("+OwnDialogs")

					OnMessage(0x44, translateLoadCancelButtons)
					fileName := withBlockedWindows(FileSelect, 1, dirName, translate("Load Strategy..."), "Strategy (*.strategy)")
					OnMessage(0x44, translateLoadCancelButtons, 0)

					if (fileName != "") {
						strategy := readMultiMap(fileName)

						if (strategy.Count > 0) {
							this.selectStrategy(this.createStrategy(strategy))

							if this.AutoInitialize
								this.chooseSettingsMenu("Strategy")
						}
					}
				}
				else {
					sessionDB := SessionDatabase()

					this.Window.Block()

					try {
						fileName := browseStrategies(this.Window, &simulator, &car, &track)
					}
					finally {
						this.Window.Unblock()
					}

					if (fileName && (fileName != "")) {
						SplitPath(fileName, , &directory, , &fileName)

						if (simulator && car && track
						 && ((normalizeDirectoryPath(directory) = normalizeDirectoryPath(sessionDB.getStrategyDirectory(simulator, car, track, "User")))
						  || (normalizeDirectoryPath(directory) = normalizeDirectoryPath(sessionDB.getStrategyDirectory(simulator, car, track, "Community"))))) {
							try {
								strategy := sessionDB.readStrategy(simulator, car, track, fileName)

								if (strategy && (strategy.Count > 0)) {
									this.selectStrategy(this.createStrategy(strategy))

									if this.AutoInitialize
										this.chooseSettingsMenu("Strategy")
								}
							}
							catch Any as exception {
								logError(exception)

								folder := ""
							}
						}
						else {
							strategy := readMultiMap(directory . "\" . fileName . ".strategy")

							if (strategy.Count > 0) {
								this.selectStrategy(this.createStrategy(strategy))

								if this.AutoInitialize
									this.chooseSettingsMenu("Strategy")
							}
						}
					}
				}
			case 5: ; "Save Strategy..."
				if this.SelectedStrategy {
					fileName := (((dirName != "") ? (dirName . "\") : "") . this.SelectedStrategy.Name . ".strategy")
					fileName := StrReplace(fileName, "n/a", "n.a.")
					fileName := StrReplace(fileName, "/", "-")

					this.Window.Opt("+OwnDialogs")

					OnMessage(0x44, translateSaveCancelButtons)
					fileName := withBlockedWindows(FileSelect, "S17", fileName, translate("Save Strategy..."), "Strategy (*.strategy)")
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
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("There is no current Strategy."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 7: ; "Compare Strategies..."
				this.Window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Compare", "Cancel"])

				OnMessage(0x44, translator)
				files := withBlockedWindows(FileSelect, "M1", dirName, translate("Choose two or more Race Strategies for comparison..."), "Strategy (*.strategy)")
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
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("There is no current Strategy."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
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
		local charts := ""
		local drawChartFunction := ""
		local drawChartsFunction := "function drawCharts() {"
		local chartID := false
		local strategy, before, after, chart, ignore, laps, exhausted, index, hasData
		local sLaps, html, timeSeries, lapSeries, fuelSeries, tyreSeries, width, chartArea, tableCSS

		compare(a, b) {
			if ((a.SessionType = "Duration") && (b.SessionType = "Duration")) {
				if (a.getSessionLaps() < b.getSessionLaps())
					return true
				else if (a.getSessionLaps() > b.getSessionLaps())
					return false
				else
					return (a.getSessionDuration() > b.getSessionDuration())
			}
			else
				return (a.getSessionDuration() > b.getSessionDuration())
		}

		bubbleSort(&strategies, compare)

		before := "
		(
			<meta charset='utf-8'>
			<head>
				<style>
					.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
					.rowStyle { font-size: 11px; color: #%fontColor%; background-color: #%evenRowBackColor%; }
					.oddRowStyle { font-size: 11px; color: #%fontColor%; background-color: #%oddRowBackColor%; }
				</style>
				<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
				<script type="text/javascript">
					google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawCharts);
		)"

		before := substituteVariables(before, {fontColor: this.Window.Theme.TextColor
											 , headerBackColor: this.Window.Theme.ListBackColor["Header"]
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

			html .= ("<br><br><div id=`"header`"><i>" . translate("Consumables") . "</i></div>")

			drawChartFunction := false
			chartID := false

			width := (this.ChartViewer.getWidth() - 4)

			html .= this.createConsumablesChart(strategy, width, width / 2, timeSeries, lapSeries, fuelSeries, tyreSeries, &drawChartFunction, &chartID)

			charts .= (";`n" . drawChartFunction)

			drawChartsFunction .=  (A_Space . "drawChart" . chartID . "();")
		}

		drawChartsFunction .= (A_Space . "drawChart(); }`n")

		chart .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right', textStyle: { color: '" . this.Window.Theme.TextColor . "'} }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Minute") . "', titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, textStyle: { color: '" . this.Window.Theme.TextColor["Disabled"] . "'}, gridlines: { color: '#" . this.Window.Theme.GridColor . "', textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'} } }, vAxis: { title: '" . translate("Lap") . "', titleTextStyle: { color: '" . this.Window.Theme.TextColor . "'}, textStyle: { color: '" . this.Window.Theme.TextColor["Disabled"] . "'}, gridlines: { color: '#" . this.Window.Theme.GridColor . "', textStyle: { color: '" . this.Window.Theme.TextColor["Grid"] . "'} }, viewWindow: { min: 0 } }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		chart .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")

		chartArea := ("<div id=`"header`"><i><b>" . translate("Performance") . "</b></i></div><br><div id=`"chart_id`" style=`"width: " . (this.ChartViewer.getWidth() - 24) . "px; height: 348px`"></div>")

		tableCSS := this.StrategyViewer.getTableCSS()

		html := ("<html>" . before . chart . charts . ";`n" . drawChartsFunction . after . "<body style='background-color: #" . this.Window.AltBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } table, p, div { color: #" . this.Window.Theme.TextColor . " } </style>" . html . "<br><hr style=`"width: 50%`"><br>" . chartArea . "</body></html>")

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
					  , &sessionType, &sessionLength, &additionalLaps
					  , &tyreCompound, &tyreCompoundColor, &tyrePressures) {
		local lapsDB, lowestLapTime, ignore, row, lapTime, settings

		simulator := this.SelectedSimulator
		car := this.SelectedCar
		track := this.SelectedTrack

		weather := this.SelectedWeather
		airTemperature := this.AirTemperature
		trackTemperature := this.TrackTemperature

		sessionType := this.SelectedSessionType
		sessionLength := this.Control["sessionLengthEdit"].Text
		additionalLaps := this.SelectedAdditionalLaps

		splitCompound(this.TyreCompounds[this.Control["simCompoundDropDown"].Value], &tyreCompound, &tyreCompoundColor)

		tyrePressures := false

		lapsDB := this.LapsDatabase
		lowestLapTime := false

		for ignore, row in lapsDB.getLapTimePressures(weather, tyreCompound, tyreCompoundColor) {
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

	getPitstopRules(&validator, &pitstopRule, &pitstopWindow, &refuelRule, &tyreChangeRule, &tyreSets) {
		local result := true
		local tyreCompound, tyreCompoundColor, translatedCompounds, count, index, laps

		this.validatePitstopRule("Full")
		this.validatePitstopWindow("Full")

		validator := this.SelectedValidator

		switch this.Control["pitstopRuleDropDown"].Value {
			case 1:
				pitstopRule := false
			case 2:
				if isInteger(this.Control["pitstopRuleEdit"].Text)
					pitstopRule := Max(this.Control["pitstopRuleEdit"].Text, 1)
				else {
					pitstopRule := 1

					result := false
				}
		}

		switch this.Control["pitstopWindowDropDown"].Value {
			case 1:
				pitstopWindow := false
			case 2:
				pitstopWindow := string2Values("-", this.Control["pitstopWindowEdit"].Text)

				if (pitstopWindow.Length = 2)
					pitstopWindow := [Round(pitstopWindow[1]), Round(pitstopWindow[2])]
				else {
					pitstopWindow := [25, 35]

					result := false
				}
		}

		index := inList(collect(["Optional", "Required", "Always", "Disallowed"], translate), this.Control["refuelRequirementsDropDown"].Text)

		refuelRule := ["Optional", "Required", "Always", "Disallowed"][index]

		index := inList(collect(["Optional", "Required", "Always", "Disallowed"], translate), this.Control["tyreChangeRequirementsDropDown"].Text)

		tyreChangeRule := ["Optional", "Required", "Always", "Disallowed"][index]

		translatedCompounds := collect(this.TyreCompounds, translate)
		tyreSets := []

		loop this.TyreSetListView.GetCount() {
			tyreCompound := this.TyreSetListView.GetText(A_Index, 1)
			laps := this.TyreSetListView.GetText(A_Index, 2)
			count := this.TyreSetListView.GetText(A_Index, 3)

			splitCompound(this.TyreCompounds[inList(translatedCompounds, tyreCompound)], &tyreCompound, &tyreCompoundColor)

			tyreSets.Push(Array(tyreCompound, tyreCompoundColor, count, laps))
		}

		return result
	}

	getFixedPitstops() {
		local fixedPitstops := CaseInsenseMap()
		local fixedPitstop

		if this.FixedPitstops
			loop this.FixedPitstopsListView.GetCount() {
				fixedPitstop := {Lap: this.FixedPitstopsListView.GetText(A_Index, 2)}

				if kFixedPitstopRefuel
					fixedPitstop.Refuel := Round(convertUnit("Volume"
														   , internalValue("Float", this.FixedPitstopsListView.GetText(A_Index, 3))
														   , false), 1)

				if (this.FixedPitstopsListView.GetText(A_Index, 3 + kFixedPitstopRefuel) = translate("-"))
					fixedPitstop.Compound := false
				else
					fixedPitstop.Compound := this.TyreCompounds[inList(collect(this.TyreCompounds, translate), this.FixedPitstopsListView.GetText(A_Index, 3 + kFixedPitstopRefuel))]

				fixedPitstops[Integer(this.FixedPitstopsListView.GetText(A_Index))] := fixedPitstop
			}

		return fixedPitstops
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

			bubbleSort(&weathers, (w1, w2) => strGreater(w1[1], w2[1]))

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
					 , &initialTyreSet, &initialTyreLaps, &initialFuelAmount
					 , &initialMap, &initialFuelConsumption, &initialAvgLapTime) {
		initialStint := 1
		initialLap := 0
		initialStintTime := 0
		initialSessionTime := 0
		initialTyreSet := false
		initialTyreLaps := 0
		initialFuelAmount := convertUnit("Volume", internalValue("Float", this.Control["simInitialFuelAmountEdit"].Text), false)
		initialMap := this.Control["simMapEdit"].Text
		initialFuelConsumption := convertUnit("Volume", internalValue("Float", this.Control["simFuelConsumptionEdit"].Text), false)
		initialAvgLapTime := internalValue("Float", this.Control["simAvgLapTimeEdit"].Text)
	}

	getSimulationSettings(&useInitialConditions, &useTelemetryData
						, &consumptionVariation, &initialFuelVariation, &refuelVariation
						, &tyreUsageVariation, &tyreCompoundVariation
						, &firstStintWeight, &lastStintWeight) {
		local simInputDropDown := this.Control["simInputDropDown"].Value

		consumptionVariation := 0 ; this.Control["simConsumptionVariation"].Value
		initialFuelVariation := this.Control["simInitialFuelVariation"].Value
		refuelVariation := this.Control["simRefuelVariation"].Value
		tyreUsageVariation := this.Control["simTyreUsageVariation"].Value
		tyreCompoundVariation := this.Control["simTyreCompoundVariation"].Value

		firstStintWeight := this.Control["simFirstStintWeight"].Value
		lastStintWeight := this.Control["simLastStintWeight"].Value

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
		return this.Simulation.calcAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather
											, tyreCompound, tyreCompoundColor, tyreLaps
											, default ? default : internalValue("Float", this.Control["simAvgLapTimeEdit"].Text)
											, this.LapsDatabase)
	}

	runSimulation() {
		local lapsDB := LapsDatabase(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)
		local simulation

		this.iLapsDatabase := lapsDB

		try {
			simulation := VariationSimulation(this, lapsDB, this.SelectedSessionType, this.SelectedAdditionalLaps)

			this.iSimulation := simulation

			simulation.runSimulation(true)
		}
		finally {
			this.iLapsDatabase := false
			this.iSimulation := false
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
			; this.Control["simConsumedFuelResult"].Text := displayValue("Float", convertUnit("Volume", consumedFuel), 1)
			this.Control["simPitlaneSecondsResult"].Text := Ceil(strategy.getPitstopTime())

			if (this.SelectedSessionType = "Duration")
				this.Control["simSessionResultResult"].Text := strategy.getSessionLaps()
			else
				this.Control["simSessionResultResult"].Text := Ceil(strategy.getSessionDuration())

			this.showStrategyPlot(strategy)
		}
		else {
			this.Control["simNumPitstopResult"].Text := ""
			this.Control["simNumTyreChangeResult"].Text := ""
			; this.Control["simConsumedFuelResult"].Text := ""
			this.Control["simPitlaneSecondsResult"].Text := ""
			this.Control["simSessionResultResult"].Text := ""

			this.showStrategyPlot(false)
		}

		this.iSelectedScenario := strategy
	}

	validatePitstopRule(full := false) {
		local pitstopRuleEdit := this.Control["pitstopRuleEdit"].Text

		if (StrLen(Trim(pitstopRuleEdit)) > 0) {
			if (this.Control["pitstopRuleDropDown"].Value == 2) {
				if isInteger(pitstopRuleEdit) {
					if (pitstopRuleEdit < 1)
						this.Control["pitstopRuleEdit"].Text := 1
				}
				else
					this.Control["pitstopRuleEdit"].Value := 1
			}
		}
	}

	validatePitstopWindow(full := false) {
		local reset, count, pitOpen, pitClose
		local pitstopWindowEdit := this.Control["pitstopWindowEdit"].Text
		local pitstopWindowDropDown := this.Control["pitstopWindowDropDown"].Value

		if (StrLen(Trim(pitstopWindowEdit)) > 0) {
			if (pitstopWindowDropDown == 1)
				this.Control["pitstopWindowEdit"].Text := ""
			else if (pitstopWindowDropDown == 2) {
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

class ValidatorsEditor {
	iWorkbench := false

	iWindow := false
	iResult := false

	iValidatorsListView := false
	iNameField := false
	iScriptEditor := false

	iValidators := []
	iSelectedValidator := false

	class ValidatorsEditorWindow extends Window {
		iValidatorsEditor := false

		ValidatorsEditor {
			Get {
				return this.iValidatorsEditor
			}
		}

		__New(editor) {
			this.iValidatorsEditor := editor

			super.__New({Descriptor: ("Strategy Workbench.Validators Editor"), Closeable: true, Resizeable: true, Options: "0x400000"})
		}

		Close(*) {
			local translator

			if this.Closeable {
				translator := translateMsgBoxButtons.Bind(["Yes", "No", "Cancel"])

				OnMessage(0x44, translator)
				msgResult := withBlockedWindows(MsgBox, translate("Do you want to save your changes?"), translate("Close"), 262179)
				OnMessage(0x44, translator, 0)

				if (msgResult = "Yes")
					this.ValidatorsEditor.iResult := kOk
				else if (msgResult = "No")
					this.ValidatorsEditor.iResult := kCancel
				else if (msgResult = "Cancel")
					return true
			}
			else
				return true
		}
	}

	Workbench {
		Get {
			return this.iWorkbench
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

	ValidatorsListView {
		Get {
			return this.iValidatorsListView
		}
	}

	NameField {
		Get {
			return this.iNameField
		}
	}

	ScriptEditor {
		Get {
			return this.iScriptEditor
		}
	}

	Validators[key?] {
		Get {
			return (isSet(key) ? this.iValidators[key] : this.iValidators)
		}

		Set {
			return (isSet(key) ? (this.iValidators[key] := value) : (this.iValidators := value))
		}
	}

	SelectedValidator {
		Get {
			return this.iSelectedValidator
		}
	}

	__New(workbench) {
		this.iWorkbench := workbench
	}

	createGui() {
		local editorGui

		chooseValidator(listView, line, *) {
			this.selectValidator(line ? this.Validators[line] : false)
		}

		updateValidatorsList(*) {
			if this.SelectedValidator
				this.ValidatorsListView.Modify(inList(this.Validators, this.SelectedValidator), ""
											 , Trim(this.Control["validatorNameEdit"].Text))

			this.updateState()
		}

		; editorGui := Window({Descriptor: (this.Type . " Editor"), Resizeable: true, Options: "0x400000"})

		editorGui := ValidatorsEditor.ValidatorsEditorWindow(this)

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w848 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Strategy Workbench.Validators Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x308 YP+20 w248 H:Center Center", translate("Validation Rules")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#scenario-validation")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w848 W:Grow 0x10")

		this.iValidatorsListView := editorGui.Add("ListView", "x16 y+10 w332 h140 H:Grow(0.25) -Multi -LV0x10 AltSubmit NoSort NoSortHdr"
												, collect(["Name"], translate))

		this.iValidatorsListView.OnEvent("Click", chooseValidator)
		this.iValidatorsListView.OnEvent("DoubleClick", chooseValidator)

		editorGui.Add("Button", "x276 yp+145 w23 h23 Center +0x200 Y:Move(0.25) vaddValidatorButton").OnEvent("Click", (*) => this.addValidator())
		setButtonIcon(editorGui["addValidatorButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		editorGui.Add("Button", "x300 yp w23 h23 Center +0x200 Y:Move(0.25) vcopyValidatorButton").OnEvent("Click", (*) => this.copyValidator())
		setButtonIcon(editorGui["copyValidatorButton"], kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		editorGui.Add("Button", "x324 yp w23 h23 Center +0x200 Y:Move(0.25) vdeleteValidatorButton").OnEvent("Click", (*) => this.deleteValidator())
		setButtonIcon(editorGui["deleteValidatorButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Text", "x16 yp+2 w70 h23 Y:Move(0.25)", translate("Name"))
		editorGui.Add("Edit", "x86 yp-2 h23 w177 Y:Move(0.25) vvalidatorNameEdit").OnEvent("Change", updateValidatorsList)

		editorGui.SetFont("Norm", "Courier New")

		this.iScriptEditor := editorGui.Add("CodeEditor", "x16 yp+30 w832 h140 DefaultOpt SystemTheme Border Disabled W:Grow Y:Move(0.25) H:Grow(0.75)")

		editorGui.Add("Text", "x8 yp+150 w848 Y:Move W:Grow 0x10")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Button", "x350 yp+10 w80 h23 Default X:Move(0.5) Y:Move", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x436 yp w80 h23 X:Move(0.5) Y:Move", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)

		this.updateState()
	}

	setScript(type, text, readOnly := false) {
		initializeLanguage(type) {
			if (type = "Rules") {
				this.ScriptEditor.CaseSense := false

				this.ScriptEditor.SetKeywords("priority"
											, "Any All None One Predicate"
											, "Call Prove ProveAll Set Get Clear Produce Option Sqrt Unbound Append get"
											, "messageShow messageBox"
											, "? ! fail"
											, ""
											, "true false")

				this.ScriptEditor.Brace.Chars := "()[]{}"
				this.ScriptEditor.SyntaxEscapeChar := "``"
				this.ScriptEditor.SyntaxCommentLine := ";"
			}
			else {
				this.ScriptEditor.CaseSense := true

				this.ScriptEditor.SetKeywords("_VERSION assert collectgarbage dofile error gcinfo loadfile loadstring print rawget rawset require tonumber tostring type unpack"
											, "_ALERT _ERRORMESSAGE _INPUT _PROMPT _OUTPUT _STDERR _STDIN _STDOUT call dostring foreach foreachi getn globals newtype sort tinsert tremove"
											, "and break do else elseif end false for function if in local nil not or repeat return then true until while"
											, "abs acos asin atan atan2 ceil cos deg exp floor format frexp gsub ldexp log log10 max min mod rad random randomseed sin sqrt strbyte strchar strfind strlen strlower strrep strsub strupper tan"
											, "openfile closefile readfrom writeto appendto remove rename flush seek tmpfile tmpname read write clock date difftime execute exit getenv setlocale time"
											, "_G getfenv getmetatable ipairs loadlib next pairs pcall rawequal setfenv setmetatable xpcall string table math coroutine io os debug load module select"
											, "string.byte string.char string.dump string.find string.len string.lower string.rep string.sub string.upper string.format string.gfind string.gsub table.concat table.foreach table.foreachi table.getn table.sort table.insert table.remove table.setn math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.deg math.exp math.floor math.frexp math.ldexp math.log math.log10 math.max math.min math.mod math.pi math.pow math.rad math.random math.randomseed math.sin math.sqrt math.tan string.gmatch string.match string.reverse table.maxn math.cosh math.fmod math.modf math.sinh math.tanh math.huge")

				this.ScriptEditor.Brace.Chars := "()[]{}"
				this.ScriptEditor.SyntaxEscapeChar := ""
				this.ScriptEditor.SyntaxCommentLine := "--"
			}

			this.ScriptEditor.Tab.Width := 4
		}

		this.ScriptEditor.Loading := true

		try {
			initializeLanguage(type)

			this.ScriptEditor.Content[true] := text
			this.ScriptEditor.Editable := !readOnly
			this.ScriptEditor.Enabled := true
		}
		finally {
			this.ScriptEditor.Loading := false
		}
	}

	editValidators(owner := false) {
		local window, x, y, w, h

		this.createGui()

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Strategy Workbench.Validators Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Strategy Workbench.Validators Editor", &w, &h)
			window.Resize("Initialize", w, h)

		this.loadValidators()

		try {
			loop {
				loop
					Sleep(200)
				until this.iResult

				if (this.iResult = kOk) {
					this.iResult := this.saveValidators()

					if this.iResult
						return this.iResult
					else
						this.iResult := false
				}
				else
					return false
			}
		}
		finally {
			this.ScriptEditor.Destroy()

			window.Destroy()
		}
	}

	updateState() {
		local type

		this.Control["addValidatorButton"].Enabled := true

		if this.SelectedValidator {
			this.Control["copyValidatorButton"].Enabled := true

			if this.SelectedValidator.Builtin {
				this.Control["deleteValidatorButton"].Enabled := false

				this.Control["validatorNameEdit"].Opt("+ReadOnly")
			}
			else {
				this.Control["deleteValidatorButton"].Enabled := true

				this.Control["validatorNameEdit"].Opt("-ReadOnly")
			}

			if (this.ScriptEditor.Content[true] = "")
				if (this.SelectedValidator.Type = "Rules")
					this.setScript("Rules", "; Insert your rules here...`n`n", this.SelectedValidator.Builtin)
				else
					this.setScript("Script", "-- Insert your script here...`n`n", this.SelectedValidator.Builtin)

			this.ScriptEditor.Visible := true
		}
		else {
			this.Control["copyValidatorButton"].Enabled := false
			this.Control["deleteValidatorButton"].Enabled := false

			this.setScript("Rules", "", true)
			this.Control["validatorNameEdit"].Text := ""

			this.ScriptEditor.Visible := true
			this.Control["validatorNameEdit"].Opt("+ReadOnly")
		}
	}

	selectValidator(validator, force := false, save := true) {
		if (force || (this.SelectedValidator != validator)) {
			if (save && this.SelectedValidator)
				if !this.saveValidator(this.SelectedValidator) {
					this.ValidatorsListView.Modify(inList(this.Validators, this.SelectedValidator), "Select Vis")

					return
				}

			if validator
				this.ValidatorsListView.Modify(inList(this.Validators, validator), "Select Vis")

			this.iSelectedValidator := validator

			this.loadValidator(validator)

			this.updateState()
		}
	}

	addValidator() {
		local validator, translator, msgResult

		if this.SelectedValidator
			if !this.saveValidator(this.SelectedValidator) {
				this.ValidatorsListView.Modify(inList(this.Validators, this.SelectedValidator), "Select Vis")

				return
			}

		translator := translateMsgBoxButtons.Bind(["Rules", "Script", "Cancel"])

		OnMessage(0x44, translator)
		msgResult := withBlockedWindows(MsgBox, translate("Do you want to use rules or do you want to write a script?"), translate("Validator"), 262179)
		OnMessage(0x44, translator, 0)

		if (msgResult = "Cancel")
			return

		if (msgResult = "Yes")
			validator := {Type: "Rules", Name: "", Builtin: false, Script: ""}
		else
			validator := {Type: "Script", Name: "", Builtin: false, Script: ""}

		this.Validators.Push(validator)

		this.ValidatorsListView.Add("", "")

		this.selectValidator(validator, true, false)
	}

	copyValidator() {
		local validator

		if this.SelectedValidator
			if !this.saveValidator(this.SelectedValidator) {
				this.ValidatorsListView.Modify(inList(this.Validators, this.SelectedValidator), "Select Vis")

				return
			}

		validator := this.SelectedValidator.Clone()

		validator.Builtin := false

		loop
			if (choose(this.Validators, (v) => (v.Name = (validator.Name . " (" . A_Index . ")"))).Length = 0) {
				validator.Name := (validator.Name . " (" . A_Index . ")")

				break
			}

		this.Validators.Push(validator)

		this.ValidatorsListView.Add("", validator.Name)

		this.selectValidator(validator, true, false)
	}

	deleteValidator() {
		local index := inList(this.Validators, this.SelectedValidator)

		this.ValidatorsListView.Delete(index)

		this.Validators.RemoveAt(index)

		this.selectValidator(false, true, false)
	}

	loadValidator(validator) {
		local ignore

		if validator {
			this.Control["validatorNameEdit"].Text := validator.Name

			this.setScript(validator.Type, validator.Script, validator.Builtin)
		}
		else {
			this.Control["validatorNameEdit"].Text := ""

			this.setScript("Rules", "", true)
		}

		this.updateState()
	}

	saveValidator(validator) {
		local valid := true
		local name := this.Control["validatorNameEdit"].Text
		local errorMessage := ""
		local ignore, other, type, fileName, context, message

		if (Trim(name) = "") {
			errorMessage .= ("`n" . translate("Error: ") . "Name cannot be empty...")

			valid := false
		}

		for ignore, other in this.Validators
			if ((other != validator) && (name = other.Name)) {
				errorMessage .= ("`n" . translate("Error: ") . "Name must be unique...")

				valid := false
			}

		if (validator.Type = "Rules") {
			try {
				RuleCompiler().compileRules(this.ScriptEditor.Content[true], &ignore := false, &ignore := false)
			}
			catch Any as exception {
				errorMessage .= ("`n" . translate("Error: ") . (isObject(exception) ? exception.Message : exception))

				valid := false
			}
		}
		else {
			fileName := temporaryFilename("Script", "script")

			try {
				context := scriptOpenContext()

				FileAppend(this.ScriptEditor.Content[true], fileName)

				if !scriptLoadScript(context, fileName, &message)
					throw message

				scriptCloseContext(context)
			}
			catch Any as exception {
				errorMessage .= ("`n" . translate("Error: ") . (isObject(exception) ? exception.Message : exception))

				valid := false
			}
			finally {
				deleteFile(fileName)
			}
		}

		if valid {
			validator.Name := name

			validator.Script := this.ScriptEditor.Content[true]

			this.ValidatorsListView.Modify(inList(this.Validators, validator), "", validator.Name)
		}
		else {
			if (StrLen(errorMessage) > 0)
				errorMessage := ("`n" . errorMessage)

			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct...") . errorMessage, translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}

		return valid
	}

	loadValidators() {
		local validators := []
		local ignore, fileName, validator

		for ignore, fileName in getFileNames("*.rules", kResourcesDirectory . "Strategy\Validators\") {
			SplitPath(fileName, , , , &validator)

			if (choose(validators, (v) => v.Name = validator).Length = 0)
				validators.Push({Type: "Rules", Name: validator, Builtin: true, Script: FileRead(fileName)})
		}

		for ignore, fileName in getFileNames("*.script", kResourcesDirectory . "Strategy\Validators\") {
			SplitPath(fileName, , , , &validator)

			if (choose(validators, (v) => v.Name = validator).Length = 0)
				validators.Push({Type: "Script", Name: validator, Builtin: true, Script: FileRead(fileName)})
		}

		for ignore, fileName in getFileNames("*.rules", kUserHomeDirectory . "Validators\") {
			SplitPath(fileName, , , , &validator)

			if (choose(validators, (v) => v.Name = validator).Length = 0)
				validators.Push({Type: "Rules", Name: validator, Builtin: false, Script: FileRead(fileName)})
		}

		for ignore, fileName in getFileNames("*.script", kUserHomeDirectory . "Validators\") {
			SplitPath(fileName, , , , &validator)

			if (choose(validators, (v) => v.Name = validator).Length = 0)
				validators.Push({Type: "Script", Name: validator, Builtin: false, Script: FileRead(fileName)})
		}

		this.Validators := validators

		this.ValidatorsListView.Delete()

		for ignore, validator in this.Validators
			this.ValidatorsListView.Add("", validator.Name)

		this.ValidatorsListView.ModifyCol()

		loop this.ValidatorsListView.GetCount("Col")
			this.ValidatorsListView.ModifyCol(A_Index, "AutoHdr")
	}

	saveValidators(save := true) {
		local ignore, validator

		if this.SelectedValidator
			if !this.saveValidator(this.SelectedValidator) {
				this.ValidatorsListView.Modify(inList(this.Validators, this.SelectedValidator), "Select Vis")

				return false
			}

		deleteDirectory(kUserHomeDirectory . "Validators", false)

		for ignore, validator in this.Validators
			if !validator.Builtin
				FileAppend(validator.Script, kUserHomeDirectory . "Validators\" . validator.Name . "." . validator.Type)

		return true
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

filterSchema(schema) {
	local newSchema := []
	local ignore, column

	for ignore, column in schema
		if !inList(["Driver", "Identifier", "Synchronized", "Weather", "Tyre.Laps", "Tyre.Compound", "Tyre.Compound.Color"], column)
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

startupStrategyWorkbench() {
	local icon := kIconsDirectory . "Workbench.ico"
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
	local load := false
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
			case "-Load":
				load := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}

	if (airTemperature <= 0)
		airTemperature := 23

	if (trackTemperature <= 0)
		trackTemperature := 27

	try {
		workbench := StrategyWorkbench(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor)

		workbench.createGui(workbench.Configuration)

		if load {
			load := readMultiMap(load)

			if (load.Count > 0)
				workbench.selectStrategy(workbench.createStrategy(load))
		}

		workbench.show()

		startupApplication()
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Strategy Workbench"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

if kLogStartup
	logMessage(kLogOff, "Loading plugins...")

#Include "..\Plugins\Simulator Providers.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startupStrategyWorkbench()