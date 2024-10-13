;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Database Tool           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Session Database.ico
;@Ahk2Exe-ExeName Session Database.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\GDIP.ahk"
#Include "..\Libraries\CLR.ahk"
#Include "Libraries\SettingsDatabase.ahk"
#Include "Libraries\TelemetryDatabase.ahk"
#Include "Libraries\TyresDatabase.ahk"
#Include "Libraries\PressuresEditor.ahk"
#Include "Libraries\TelemetryViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"
global kClose := "Close"

global kSetupNames := CaseInsenseMap("DQ", "Qualifying (Dry)", "DR", "Race (Dry)", "WQ", "Qualifying (Wet)", "WR", "Race (Wet)")


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global gActionInfoEnabled := true


;;;-------------------------------------------------------------------------;;;
;;;                         Public Classes Section                          ;;;
;;;-------------------------------------------------------------------------;;;

class SessionDatabaseEditor extends ConfigurationItem {
	iWindow := false

	iRequestorPID := false
	iSettingDescriptors := newMultiMap()

	iSessionDatabase := SessionDatabase()

	iSelectedSimulator := false
	iSelectedCar := true
	iSelectedTrack := true
	iSelectedWeather := true

	iAllTracks := []

	iAirTemperature := 23
	iTrackTemperature := 27
	iTyreCompound := false
	iTyreCompoundColor := false

	iAvailableModules := CaseInsenseMap("Settings", false, "Setups", false, "Pressures", false)
	iSelectedModule := false

	iSelectedSetupType := false

	iDataListView := false
	iSettingsListView := false
	iSessionListView := false
	iTelemetryListView := false
	iStrategyListView := false
	iSetupListView := false
	iAdministrationListView := false
	iTrackAutomationsListView := false

	iTrackAutomations := []
	iSelectedTrackAutomation := false

	iTrackMap := false
	iTrackImage := false

	iTrackDisplay := false
	iTrackDisplayArea := false

	iSettings := []

	iSelectedValue := false

	class TelemetryManager {
		iSessionDatabase := false

		__New(sessionDatabase) {
			this.iSessionDatabase := sessionDatabase
		}

		closedTelemetryViewer() {
		}

		getSessionInformation(&simulator, &car, &track) {
			simulator := this.iSessionDatabase.SelectedSimulator
			car := this.iSessionDatabase.SelectedCar
			track := this.iSessionDatabase.SelectedTrack
		}

		getLapInformation(lapNumber, &driver, &lapTime, &sectorTimes) {
			driver := "John Doe (JD)"
			lapTime := "-"
			sectorTimes := ["-"]
		}
	}

	class EditorTyresDatabase extends TyresDatabase {
		__New(controllerState := false) {
			super.__New()

			this.UseCommunity[false] := SessionDatabaseEditor.Instance.UseCommunity
		}
	}

	class EditorResizer extends Window.Resizer {
		iRedraw := false

		__New(arguments*) {
			super.__New(arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawTrackViewer"), 500, kHighPriority)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iRedraw := true
		}

		RestrictResize(&deltaWidth, &deltaHeight) {
			if (deltaWidth > 300) {
				deltaWidth := 300

				return true
			}
			else
				return false
		}

		RedrawTrackViewer() {
			if this.iRedraw {
				local editor := SessionDatabaseEditor.Instance
				local ignore, button

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button)
						return Task.CurrentTask

				this.iRedraw := false

				if (editor.SelectedModule = "Automation")
					editor.updateTrackMap()

				WinRedraw(this.Window)
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

	RequestorPID {
		Get {
			return this.iRequestorPID
		}
	}

	SettingDescriptors {
		Get {
			return this.iSettingDescriptors
		}
	}

	UseCommunity[persistent := false] {
		Get {
			return this.SessionDatabase.UseCommunity
		}

		Set {
			return (this.SessionDatabase.UseCommunity[persistent] := value)
		}
	}

	SessionDatabase {
		Get {
			return this.iSessionDatabase
		}
	}

	SelectedSimulator[label := false] {
		Get {
			if (label = "*")
				return ((this.iSelectedSimulator == true) ? "*" : this.iSelectedSimulator)
			else if label
				return this.iSelectedSimulator
			else
				return this.iSelectedSimulator
		}
	}

	SelectedCar[label := false] {
		Get {
			if ((label = "*") && (this.iSelectedCar == true))
				return "*"
			else if (label && (this.iSelectedCar == true))
				return translate("All")
			else
				return this.iSelectedCar
		}
	}

	SelectedTrack[label := false] {
		Get {
			if ((label = "*") && (this.iSelectedTrack == true))
				return "*"
			else if (label && (this.iSelectedTrack == true))
				return translate("All")
			else
				return this.iSelectedTrack
		}
	}

	SelectedWeather[label := false] {
		Get {
			if ((label = "*") && (this.iSelectedWeather == true))
				return "*"
			else if (label && (this.iSelectedWeather == true))
				return translate("All")
			else
				return this.iSelectedWeather
		}
	}

	SelectedModule {
		Get {
			return this.iSelectedModule
		}
	}

	SelectedSetupType {
		Get {
			return this.iSelectedSetupType
		}
	}

	DataListView {
		Get {
			return this.iDataListView
		}
	}

	SettingsListView {
		Get {
			return this.iSettingsListView
		}
	}

	SessionListView {
		Get {
			return this.iSessionListView
		}
	}

	TelemetryListView {
		Get {
			return this.iTelemetryListView
		}
	}

	StrategyListView {
		Get {
			return this.iStrategyListView
		}
	}

	SetupListView {
		Get {
			return this.iSetupListView
		}
	}

	AdministrationListView {
		Get {
			return this.iAdministrationListView
		}
	}

	TrackAutomations[key?] {
		Get {
			return (isSet(key) ? this.iTrackAutomations[key] : this.iTrackAutomations)
		}

		Set {
			return (isSet(key) ? (this.iTrackAutomations[key] := value) : (this.iTrackAutomations := value))
		}
	}

	SelectedTrackAutomation {
		Get {
			return this.iSelectedTrackAutomation
		}
	}

	TrackMap {
		Get {
			return this.iTrackMap
		}
	}

	TrackImage {
		Get {
			return this.iTrackImage
		}
	}

	TrackAutomationsListView {
		Get {
			return this.iTrackAutomationsListView
		}
	}

	__New(simulator := false, car := false, track := false
		, weather := false, airTemperature := false, trackTemperature := false
		, compound := false, compoundColor := false, requestorPID := false) {
		if simulator {
			this.iSelectedSimulator := this.SessionDatabase.getSimulatorName(simulator)
			this.iSelectedCar := car
			this.iSelectedTrack := track
			this.iSelectedWeather := weather
			this.iAirTemperature := airTemperature
			this.iTrackTemperature := trackTemperature
			this.iTyreCompound := compound
			this.iTyreCompoundColor := compoundColor
		}

		this.iRequestorPID := requestorPID

		super.__New(kSimulatorConfiguration)

		SessionDatabaseEditor.Instance := this

		this.getAvailableSettings()
	}

	createGui(configuration) {
		local editor := this
		local x, y, car, track, weather, simulators, simulator, choices, chosen, tabs, button, editorGui

		closeSessionDatabaseEditor(*) {
			ExitApp(0)
		}

		showSettings(*) {
			editorGui.Block()

			try {
				editSettings(editor, editorGui)
			}
			finally {
				editorGui.Unblock()
			}
		}

		chooseSimulator(*) {
			editor.loadSimulator(editor.Control["simulatorDropDown"].Text)
		}

		chooseCar(*) {
			local simulator := editor.SelectedSimulator
			local carDropDown := editor.Control["carDropDown"].Text
			local index, car

			if (carDropDown = translate("All"))
				editor.loadCar(true)
			else
				for index, car in editor.getCars(simulator)
					if (carDropDown = editor.getCarName(simulator, car)) {
						editor.loadCar(car)

						break
					}
		}

		chooseTrack(*) {
			local trackDropDown := editor.Control["trackDropDown"].Text
			local simulator, tracks, trackNames

			if (trackDropDown = translate("All"))
				editor.loadTrack(true)
			else {
				simulator := editor.SelectedSimulator
				tracks := editor.getTracks(simulator, editor.SelectedCar)
				trackNames := collect(tracks, ObjBindMethod(editor, "getTrackName", simulator))

				editor.loadTrack(tracks[inList(trackNames, trackDropDown)])
			}
		}

		chooseWeather(*) {
			local weatherDropDown := editor.Control["weatherDropDown"].Value

			editor.loadWeather((weatherDropDown == 1) ? true : kWeatherConditions[weatherDropDown - 1])
		}

		updateNotes(*) {
			editor.updateNotes(editor.Control["notesEdit"].Value)
		}

		navSetting(listView, line, selected) {
			if selected
				chooseSetting(listView, line)
		}

		chooseSetting(listView, line) {
			if line
				this.chooseSetting()
			else
				this.updateState()
		}

		addSetting(*) {
			local settings, labels, ignore, setting, type, value, default

			settings := editor.getAvailableSettings(false)

			labels := []

			for ignore, setting in settings
				labels.Push(editor.getSettingLabel(setting[1], setting[2]))

			bubbleSort(&labels)

			editorGui["settingDropDown"].Enabled := true

			editorGui["settingDropDown"].Delete()
			editorGui["settingDropDown"].Add(labels)
			editorGui["settingDropDown"].Choose(1)

			default := false

			type := editor.getSettingType(settings[1][1], settings[1][2], &default)

			if isObject(type) {
				editorGui["settingValueEdit"].Visible := false
				editorGui["settingValueText"].Visible := false
				editorGui["settingValueCheck"].Visible := false
				editorGui["settingValueDropDown"].Visible := true
				editorGui["settingValueDropDown"].Enabled := true

				labels := collect(type, translate)

				editorGui["settingValueDropDown"].Delete()
				editorGui["settingValueDropDown"].Add(labels)
				editorGui["settingValueDropDown"].Choose(inList(type, default))

				value := default
			}
			else if (type = "Boolean") {
				editorGui["settingValueDropDown"].Visible := false
				editorGui["settingValueEdit"].Visible := false
				editorGui["settingValueText"].Visible := false
				editorGui["settingValueCheck"].Visible := true
				editorGui["settingValueCheck"].Enabled := true

				editorGui["settingValueCheck"].Value := default

				value := default
			}
			else if (type = "Text") {
				editorGui["settingValueDropDown"].Visible := false
				editorGui["settingValueCheck"].Visible := false
				editorGui["settingValueEdit"].Visible := false
				editorGui["settingValueText"].Visible := true
				editorGui["settingValueText"].Enabled := true

				editorGui["settingValueText"].Text := default

				value := default
			}
			else {
				editorGui["settingValueDropDown"].Visible := false
				editorGui["settingValueCheck"].Visible := false
				editorGui["settingValueText"].Visible := false
				editorGui["settingValueEdit"].Visible := true
				editorGui["settingValueEdit"].Enabled := true

				value := default

				editor.iSelectedValue := displayValue("Float", value)
				editorGui["settingValueEdit"].Text := editor.iSelectedValue
			}

			editor.addSetting(settings[1][1], settings[1][2], value)
		}

		deleteSetting(*) {
			local settingDropDown := editorGui["settingDropDown"].Text
			local selected, settings, section, key, ignore, setting

			selected := editor.SettingsListView.GetNext(0)

			if !selected
				return

			settings := editor.getAvailableSettings(selected)

			section := false
			key := false

			for ignore, setting in settings
				if (settingDropDown = editor.getSettingLabel(setting[1], setting[2])) {
					section := setting[1]
					key := setting[2]

					break
				}

			SessionDatabaseEditor.Instance.deleteSetting(section, key)
		}

		selectSetting(*) {
			selectSettingAsync() {
				local settingDropDown := editorGui["settingDropDown"].Text
				local selected, settings, section, key, ignore, setting, type, value, default, labels

				selected := editor.SettingsListView.GetNext(0)

				if !selected
					return

				settings := editor.getAvailableSettings(selected)

				section := false
				key := false

				for ignore, setting in settings
					if (settingDropDown = editor.getSettingLabel(setting[1], setting[2])) {
						section := setting[1]
						key := setting[2]

						break
					}

				default := false

				type := editor.getSettingType(section, key, &default)

				if isObject(type) {
					editorGui["settingValueEdit"].Visible := false
					editorGui["settingValueText"].Visible := false
					editorGui["settingValueCheck"].Visible := false
					editorGui["settingValueDropDown"].Visible := true
					editorGui["settingValueDropDown"].Enabled := true

					labels := collect(type, translate)

					editorGui["settingValueDropDown"].Delete()
					editorGui["settingValueDropDown"].Add(labels)
					editorGui["settingValueDropDown"].Choose(inList(type, default))

					value := default
				}
				else if (type = "Boolean") {
					editorGui["settingValueDropDown"].Visible := false
					editorGui["settingValueEdit"].Visible := false
					editorGui["settingValueText"].Visible := false
					editorGui["settingValueCheck"].Visible := true
					editorGui["settingValueCheck"].Enabled := true

					editorGui["settingValueCheck"].Value := default

					value := default
				}
				else if (type = "Text") {
					editorGui["settingValueDropDown"].Visible := false
					editorGui["settingValueEdit"].Visible := false
					editorGui["settingValueCheck"].Visible := false
					editorGui["settingValueText"].Visible := true
					editorGui["settingValueText"].Enabled := true

					editorGui["settingValueText"].Text := default

					value := default
				}
				else {
					editorGui["settingValueDropDown"].Visible := false
					editorGui["settingValueCheck"].Visible := false
					editorGui["settingValueText"].Visible := false
					editorGui["settingValueEdit"].Visible := true
					editorGui["settingValueEdit"].Enabled := true

					value := default

					editor.iSelectedValue := displayValue("Float", value)
					editorGui["settingValueEdit"].Text := editor.iSelectedValue
				}

				editor.updateSetting(section, key, value)
			}

			Task.startTask(selectSettingAsync)
		}

		changeSetting(*) {
			changeSettingAsync() {
				local selected, settings, section, key, ignore, setting
				local type, value, oldValue, settingDropDown, settingValue

				if (editor.SelectedModule = "Settings") {
					selected := editor.SettingsListView.GetNext(0)

					if !selected
						return

					settingDropDown := editorGui["settingDropDown"].Text

					settings := editor.getAvailableSettings(selected)

					section := false
					key := false

					for ignore, setting in settings
						if (settingDropDown = editor.getSettingLabel(setting[1], setting[2])) {
							section := setting[1]
							key := setting[2]

							break
						}

					ignore := false

					type := editor.getSettingType(section, key, &ignore)

					if isObject(type)
						value := type[inList(collect(type, translate), editorGui["settingValueDropDown"].Text)]
					else if (type = "Boolean")
						value := editorGui["settingValueCheck"].Value
					else if (type = "Text") {
						settingValue := editorGui["settingValueText"].Value

						if InStr(settingValue, "`n") {
							settingValue := StrReplace(StrReplace(settingValue, "`n", A_Space), "`r", "")

							editorGui["settingValueText"].Value := settingValue
						}

						value := settingValue
					}
					else {
						oldValue := editor.iSelectedValue

						settingValue := editorGui["settingValueEdit"].Text

						if (type = "Integer") {
							if !isInteger(settingValue) {
								settingValue := oldValue

								editorGui["settingValueEdit"].Text := oldValue

								loop 10
									SendEvent("{Right}")
							}

							value := settingValue
						}
						else if (type = "Float") {
							value := internalValue("Float", editorGui["settingValueEdit"].Text)

							if !isNumber(value) {
								editorGui["settingValueEdit"].Text := oldValue

								value := internalValue("Float", oldValue)

								loop 10
									SendEvent("{Right}")
							}
						}
					}

					editor.updateSetting(section, key, value)
				}
			}

			Task.startTask(changeSettingAsync)
		}

		navSession(listView, line, selected) {
			if selected
				chooseSession(listView, line)
		}

		chooseSession(listView, line, *) {
			if line
				SessionDatabaseEditor.Instance.selectSession(line)
			else
				editor.updateState()
		}

		openSession(listView, line, *) {
			if line
				SessionDatabaseEditor.Instance.selectSession(line, true)
			else
				editor.updateState()
		}

		updateSessionAccess(*) {
			local sessionDB := editor.SessionDatabase
			local selected, category, name

			selected := editor.SessionListView.GetNext(0)

			if selected {
				name := editor.SessionListView.GetText(selected, 3)
				category := ((editor.SessionListView.GetText(selected, 2) = translate("Solo")) ? "Solo" : "Team")

				info := sessionDB.readSessionInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, category, name)

				setMultiMapValue(info, "Session", "Synchronized", false)
				setMultiMapValue(info, "Access", "Synchronize", editor.Control["shareSessionWithTeamServerCheck"].Value)

				sessionDB.writeSessionInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, category, name, info)
			}
		}

		renameSession(*) {
			local category := editor.SessionListView.GetText(editor.SessionListView.GetNext(0), 2)

			if (category = translate("Solo"))
				category := "Solo"
			else
				category := "Team"

			editor.renameSession(category, editor.SessionListView.GetText(editor.SessionListView.GetNext(0), 3))
		}

		deleteSession(*) {
			local category := editor.SessionListView.GetText(editor.SessionListView.GetNext(0), 2)

			if (category = translate("Solo"))
				category := "Solo"
			else
				category := "Team"

			editor.deleteSession(category, editor.SessionListView.GetText(editor.SessionListView.GetNext(0), 3))
		}

		navTelemetry(listView, line, selected) {
			if selected
				chooseTelemetry(listView, line)
		}

		chooseTelemetry(listView, line, *) {
			if line
				SessionDatabaseEditor.Instance.selectTelemetry(line)
			else
				editor.updateState()
		}

		openTelemetry(listView, line, *) {
			if line
				SessionDatabaseEditor.Instance.selectTelemetry(line, true)
			else
				editor.updateState()
		}

		updateTelemetryAccess(*) {
			local sessionDB := editor.SessionDatabase
			local selected, name

			selected := editor.TelemetryListView.GetNext(0)

			if selected {
				name := editor.TelemetryListView.GetText(selected, 2)

				info := sessionDB.readTelemetryInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, name)

				setMultiMapValue(info, "Telemetry", "Synchronized", false)
				setMultiMapValue(info, "Access", "Share", editor.Control["shareTelemetryWithCommunityCheck"].Value)
				setMultiMapValue(info, "Access", "Synchronize", editor.Control["shareTelemetryWithTeamServerCheck"].Value)

				sessionDB.writeTelemetryInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, name, info)
			}
		}

		uploadTelemetry(*) {
			editor.uploadTelemetry()
		}

		downloadTelemetry(*) {
			editor.downloadTelemetry(editor.TelemetryListView.GetText(editor.TelemetryListView.GetNext(0), 2))
		}

		renameTelemetry(*) {
			editor.renameTelemetry(editor.TelemetryListView.GetText(editor.TelemetryListView.GetNext(0), 2))
		}

		deleteTelemetry(*) {
			editor.deleteTelemetry(editor.TelemetryListView.GetText(editor.TelemetryListView.GetNext(0), 2))
		}

		navStrategy(listView, line, selected) {
			if selected
				chooseStrategy(listView, line)
		}

		chooseStrategy(listView, line, *) {
			if line
				SessionDatabaseEditor.Instance.selectStrategy(line)
			else
				editor.updateState()
		}

		openStrategy(listView, line, *) {
			if line
				SessionDatabaseEditor.Instance.selectStrategy(line, true)
			else
				editor.updateState()
		}

		updateStrategyAccess(*) {
			local sessionDB := editor.SessionDatabase
			local selected, name

			selected := editor.StrategyListView.GetNext(0)

			if selected {
				name := editor.StrategyListView.GetText(selected, 2)

				info := sessionDB.readStrategyInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, name)

				setMultiMapValue(info, "Strategy", "Synchronized", false)
				setMultiMapValue(info, "Access", "Share", editor.Control["shareStrategyWithCommunityCheck"].Value)
				setMultiMapValue(info, "Access", "Synchronize", editor.Control["shareStrategyWithTeamServerCheck"].Value)

				sessionDB.writeStrategyInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, name, info)
			}
		}

		uploadStrategy(*) {
			editor.uploadStrategy()
		}

		downloadStrategy(*) {
			editor.downloadStrategy(editor.StrategyListView.GetText(editor.StrategyListView.GetNext(0), 2))
		}

		renameStrategy(*) {
			editor.renameStrategy(editor.StrategyListView.GetText(editor.StrategyListView.GetNext(0), 2))
		}

		deleteStrategy(*) {
			editor.deleteStrategy(editor.StrategyListView.GetText(editor.StrategyListView.GetNext(0), 2))
		}

		chooseSetupType(dropDown, *) {
			editor.loadSetups(kSetupTypes[dropDown.Value])
		}

		navSetup(listView, line, selected) {
			if selected
				chooseSetup(listView, line)
		}

		chooseSetup(listView, line, *) {
			if line
				editor.selectSetup(line)
			else
				editor.updateState()
		}

		updateSetupAccess(*) {
			local sessionDB := editor.SessionDatabase
			local selected, type, name

			type := kSetupTypes[editor.Control["setupTypeDropDown"].Value]

			selected := editor.SetupListView.GetNext(0)

			if selected {
				name := editor.SetupListView.GetText(selected, 2)

				info := sessionDB.readSetupInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, type, name)

				setMultiMapValue(info, "Setup", "Synchronized", false)
				setMultiMapValue(info, "Access", "Share", editor.Control["shareSetupWithCommunityCheck"].Value)
				setMultiMapValue(info, "Access", "Synchronize", editor.Control["shareSetupWithTeamServerCheck"].Value)

				sessionDB.writeSetupInfo(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack, type, name, info)
			}
		}

		uploadSetup(*) {
			editor.uploadSetup(kSetupTypes[editor.Control["setupTypeDropDown"].Value])
		}

		downloadSetup(*) {
			editor.downloadSetup(kSetupTypes[editor.Control["setupTypeDropDown"].Value], editor.SetupListView.GetText(editor.SetupListView.GetNext(0), 2))
		}

		renameSetup(*) {
			editor.renameSetup(kSetupTypes[editor.Control["setupTypeDropDown"].Value], editor.SetupListView.GetText(editor.SetupListView.GetNext(0), 2))
		}

		deleteSetup(*) {
			editor.deleteSetup(kSetupTypes[editor.Control["setupTypeDropDown"].Value], editor.SetupListView.GetText(editor.SetupListView.GetNext(0), 2))
		}

		loadPressures(*) {
			if (editor.SelectedModule = "Pressures")
				WindowTask(editor.Window, ObjBindMethod(editor, "loadPressures"), 100).start()
		}

		editPressures(*) {
			if (editor.SelectedModule = "Pressures")
				WindowTask(editor.Window, ObjBindMethod(editor, "openPressuresEditor"), 100).start()
		}

		selectTrackAction(*) {
			local coordinateX := false
			local coordinateY := false
			local action := false
			local x, y, originalX, originalY, currentX, currentY, msgResult

			MouseGetPos(&x, &y)

			x := screen2Window(x)
			y := screen2Window(y)

			if editor.findTrackCoordinate(x - editor.iTrackDisplayArea[1], y - editor.iTrackDisplayArea[2], &coordinateX, &coordinateY) {
				action := editor.findTrackAction(coordinateX, coordinateY)

				if action {
					if GetKeyState("Ctrl") {
						OnMessage(0x44, translateYesNoButtons)
						msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected action?"), translate("Delete"), 262436)
						OnMessage(0x44, translateYesNoButtons, 0)

						if (msgResult = "Yes")
							editor.deleteTrackAction(action)
					}
					else {
						originalX := action.X
						originalY := action.Y

						while (GetKeyState("LButton")) {
							MouseGetPos(&x, &y)

							x := screen2Window(x)
							y := screen2Window(y)

							if editor.findTrackCoordinate(x - editor.iTrackDisplayArea[1], y - editor.iTrackDisplayArea[2], &coordinateX, &coordinateY) {
								action.X := coordinateX
								action.Y := coordinateY

								editor.updateTrackMap()
							}
						}

						currentX := action.X
						currentY := action.Y

						action.X := originalX
						action.Y := originalY

						if (editor.findTrackAction(currentX, currentY) == action) {
							editor.updateTrackMap()

							editor.actionClicked(originalX, originalY, action)
						}
						else {
							action.X := currentX
							action.Y := currentY
						}
					}
				}
				else
					editor.trackClicked(coordinateX, coordinateY)
			}
		}

		navTrackAutomation(listView, line, selected) {
			if selected
				selectTrackAutomation(listView, line)
		}

		selectTrackAutomation(listView, line, *) {
			local index, trackAutomation, checkedRows, checked, changed, ignore, row

			if line {
				trackAutomation := editor.TrackAutomations[line].Clone()
				trackAutomation.Actions := trackAutomation.Actions.Clone()
				trackAutomation.Origin := editor.TrackAutomations[line]

				editor.iSelectedTrackAutomation := trackAutomation

				editorGui["trackAutomationNameEdit"].Value := trackAutomation.Name

				editor.updateTrackAutomationInfo()

				editor.createTrackMap(editor.SelectedTrackAutomation.Actions)

				editor.updateState()

				checkedRows := []
				checked := editor.TrackAutomationsListView.GetNext(0, "C")

				while checked {
					checkedRows.Push(checked)

					checked := editor.TrackAutomationsListView.GetNext(checked, "C")
				}

				changed := false

				for index, trackAutomation in editor.TrackAutomations
					if !inList(checkedRows, index)
						if trackAutomation.Active {
							trackAutomation.Active := false

							changed := true
						}

				for index, row in checkedRows
					if !editor.TrackAutomations[row].Active {
						editor.TrackAutomations[row].Active := true

						checkedRows.RemoveAt(index)

						changed := true

						break
					}

				if changed {
					for ignore, row in checkedRows {
						editor.TrackAutomations[row].Active := false

						editor.TrackAutomationsListView.Modify(row, "-Check")
					}

					editor.writeTrackAutomations(false)
				}

				editor.TrackAutomationsListView.Modify(line, "Select Vis")
			}
			else {
				editor.iSelectedTrackAutomation := false

				editor.updateState()
			}
		}

		addTrackAutomation(*) {
			editor.addTrackAutomation()
		}

		deleteTrackAutomation(*) {
			local msgResult

			OnMessage(0x44, translateYesNoButtons)
			msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected automation?"), translate("Delete"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				editor.deleteTrackAutomation()
		}

		saveTrackAutomation(*) {
			editor.saveTrackAutomation()
		}

		selectData(*) {
			editor.updateState()
		}

		selectAllData(*) {
			local listView := editor.AdministrationListView
			local dataSelectCheck := editor.Control["dataSelectCheck"].Value

			if (dataSelectCheck == -1) {
				dataSelectCheck := 0

				editor.Control["dataSelectCheck"].Value := 0
			}

			loop listView.GetCount()
				listView.Modify(A_Index, dataSelectCheck ? "Check" : "-Check")

			editor.updateState()
		}

		exportData(*) {
			local folder

			editor.Window.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			folder := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Select target folder..."))
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (folder != "")
				editor.exportData(folder . "\Export_" . A_Now)
		}

		importData(*) {
			local folder, info, selection

			editorGui.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			folder := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Select export folder..."))
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (folder != "")
				if FileExist(folder . "\Export.info") {
					info := readMultiMap(folder . "\Export.info")

					if (getMultiMapValue(info, "General", "Type", "Data") = "Data") {
						if (getMultiMapValue(info, "General", "Simulator") = editor.SelectedSimulator) {
							editorGui.Block()

							try {
								selection := selectImportData(editor, folder, editorGui)

								if selection
									editor.importData(folder, selection)
							}
							finally {
								editorGui.Unblock()
							}
						}
						else {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, translate("The data has not been exported for the currently selected simulator."), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						withBlockedWindows(MsgBox, translate("This is not a valid folder with exported data."), translate("Error"), 262160)
						OnMessage(0x44, translateOkButton, 0)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("This is not a valid folder with exported data."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}
		}

		exportSettings(*) {
			local full := GetKeyState("Ctrl")
			local folder

			editor.Window.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			folder := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Select target folder..."))
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (folder != "")
				editor.exportSettings(folder . "\Export_" . A_Now, full || GetKeyState("Ctrl"))
		}

		importSettings(*) {
			local folder, info, selection

			editorGui.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			folder := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Select export folder..."))
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (folder != "")
				if FileExist(folder . "\Export.info") {
					info := readMultiMap(folder . "\Export.info")

					if (getMultiMapValue(info, "General", "Type", "Data") = "Settings") {
						if (getMultiMapValue(info, "General", "Simulator") = editor.SelectedSimulator) {
							editorGui.Block()

							try {
								selection := selectImportSettings(editor, folder, editorGui)

								if selection
									editor.importSettings(folder, selection)
							}
							finally {
								editorGui.Unblock()
							}
						}
						else {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, translate("The settings has not been exported for the currently selected simulator."), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)
						}
					}
					else {
						OnMessage(0x44, translateOkButton)
						withBlockedWindows(MsgBox, translate("This is not a valid folder with exported settings."), translate("Error"), 262160)
						OnMessage(0x44, translateOkButton, 0)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("This is not a valid folder with exported settings."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}
		}

		deleteData(*) {
			local msgResult

			OnMessage(0x44, translateYesNoButtons)
			msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected data?"), translate("Delete"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				editor.deleteData()
		}

		chooseTab(module, *) {
			if editor.moduleAvailable(module)
				editor.selectModule(module)
		}

		chooseDatabaseScope(*) {
			local persistent, msgResult

			persistent := false

			if GetKeyState("Ctrl") {
				OnMessage(0x44, translateYesNoButtons)
				msgResult := withBlockedWindows(MsgBox, translate("Do you really want to change the scope for all applications?"), translate("Modular Simulator Controller System"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes")
					persistent := true
			}

			if (persistent || ((editor.Control["databaseScopeDropDown"].Value == 2) != editor.UseCommunity)) {
				editor.UseCommunity[persistent] := (editor.Control["databaseScopeDropDown"].Value == 2)

				editor.loadSimulator(editor.SelectedSimulator, true)
			}
		}

		transferPressures(*) {
			local sessionDB := editor.SessionDatabase
			local tyrePressures, compounds, compound, compoundColor, ignore, pressureInfo, driver

			if (editorGui["driverDropDown"].Text = translate("All"))
				driver := true
			else
				driver := [sessionDB.getDriverID(editor.SelectedSimulator, editorGui["driverDropDown"].Text)]

			tyrePressures := []

			compounds := sessionDB.getTyreCompounds(editor.SelectedSimulator, editor.SelectedCar, editor.SelectedTrack)

			compound := false
			compoundColor := false

			splitCompound(compounds[editorGui["tyreCompoundDropDown"].Value], &compound, &compoundColor)

			for ignore, pressureInfo in SessionDatabaseEditor.EditorTyresDatabase().getPressures(editor.SelectedSimulator, editor.SelectedCar
																							   , editor.SelectedTrack, editor.SelectedWeather
																							   , convertUnit("Temperature", editorGui["airTemperatureEdit"].Value, false)
																							   , convertUnit("Temperature", editorGui["trackTemperatureEdit"].Value, false)
																							   , compound, compoundColor, driver)
				tyrePressures.Push(pressureInfo["Pressure"] + ((pressureInfo["Delta Air"] + Round(pressureInfo["Delta Track"] * 0.49)) * 0.1))

			messageSend(kFileMessage, "Setup", "setTyrePressures:" . values2String(";", compound, compoundColor, tyrePressures*), editor.RequestorPID)
		}

		testSettings(*) {
			local exePath := kBinariesDirectory . "Race Settings.exe"
			local fileName := kTempDirectory . "Temp.settings"
			local settings, section, values, key, value, options

			try {
				settings := readMultiMap(getFileName("Race.settings", kUserConfigDirectory, kConfigDirectory))

				for section, values in SettingsDatabase().loadSettings(editor.SelectedSimulator, editor.SelectedCar["*"]
																	 , editor.SelectedTrack["*"], editor.SelectedWeather["*"], false)
					for key, value in values
						setMultiMapValue(settings, section, key, value)

				writeMultiMap(fileName, settings)

				options := "-NoTeam -Test -File `"" . fileName . "`""

				if (editor.SelectedSimulator)
					options .= (" -Simulator `"" . editor.SelectedSimulator . "`"")

				if (editor.SelectedCar)
					options .= (" -Car `"" . editor.SelectedCar . "`"")

				if (editor.SelectedTrack)
					options .= (" -Track `"" . editor.SelectedTrack . "`"")

				Run("`"" . exePath . "`" " . options, kBinariesDirectory)
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		editorGui := Window({Descriptor: "Session Database", Closeable: true, Resizeable: true, Options: "-MaximizeBox"})

		this.iWindow := editorGui

		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Text", "w664 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Session Database"))

		editorGui.SetFont("s9 Norm", "Arial")

		editorGui.Add("Documentation", "x228 YP+20 w224 H:Center Center", translate("Session Database")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database")

		editorGui.Add("Text", "x8 yp+30 w670 W:Grow 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+12 w30 h30 Section", this.themeIcon(kIconsDirectory . "Road.ico"))
		editorGui.Add("Text", "x50 yp+5 w180 h26", translate("Selection"))

		editorGui.SetFont("s8 Norm", "Arial")

		editorGui.Add("Text", "x16 yp+32 w80 h23 +0x200", translate("Simulator"))

		car := this.SelectedCar
		track := this.SelectedTrack
		weather := this.SelectedWeather

		simulators := this.getSimulators()
		simulator := 0

		if (simulators.Length > 0) {
			if this.SelectedSimulator
				simulator := inList(simulators, this.SelectedSimulator)

			if (simulator == 0)
				simulator := 1
		}

		editorGui.Add("DropDownList", "x100 yp w170 W:Grow(0.2) vsimulatorDropDown Choose" . simulator, simulators).OnEvent("Change", chooseSimulator)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		editorGui.Add("Text", "x16 yp+24 w80 h23 +0x200", translate("Car"))
		editorGui.Add("DropDownList", "x100 yp w170 W:Grow(0.2) vcarDropDown Choose1", [translate("All")]).OnEvent("Change", chooseCar)

		editorGui.Add("Text", "x16 yp+24 w80 h23 +0x200", translate("Track"))
		editorGui.Add("DropDownList", "x100 yp w170 W:Grow(0.2) vtrackDropDown Choose1", [translate("All")]).OnEvent("Change", chooseTrack)

		editorGui.Add("Text", "x16 yp+24 w80 h23 +0x200", translate("Weather"))

		choices := collect(kWeatherConditions, translate)
		choices.InsertAt(1, translate("All"))
		chosen := inList(kWeatherConditions, weather)

		if (!chosen && (choices.Length > 0)) {
			weather := true
			chosen := 1
		}

		editorGui.Add("DropDownList", "x100 yp w170 W:Grow(0.2) vweatherDropDown Choose" . chosen, choices).OnEvent("Change", chooseWeather)

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x280 ys w30 h30 X:Move(0.2) Section", this.themeIcon(kIconsDirectory . "Report.ico"))
		editorGui.Add("Text", "xp+34 yp+5 w180 h26 X:Move(0.2) W:Grow(0.8)", translate("Notes"))

		button := editorGui.Add("Button", "x647 yp w23 h23 X:Move")
		button.OnEvent("Click", showSettings)
		setButtonIcon(button, kIconsDirectory . "General Settings.ico", 1)

		editorGui.SetFont("s8 Norm", "Arial")

		editorGui.Add("Edit", "x280 yp+32 w390 h94 X:Move(0.2) W:Grow(0.8) vnotesEdit").OnEvent("Change", updateNotes)

		editorGui.Add("Text", "x16 yp+104 w654 W:Grow 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+12 w30 h30 Section vsettingsImg1", this.themeIcon(kIconsDirectory . "General Settings.ico")).OnEvent("Click", chooseTab.Bind("Settings"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab1", translate("Race Settings")).OnEvent("Click", chooseTab.Bind("Settings"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+12 w30 h30 vsettingsImg2", this.themeIcon(kIconsDirectory . "Sessions.ico")).OnEvent("Click", chooseTab.Bind("Sessions"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab2", translate("Sessions")).OnEvent("Click", chooseTab.Bind("Sessions"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+10 w30 h30 vsettingsImg3", this.themeIcon(kIconsDirectory . "Tacho.ico")).OnEvent("Click", chooseTab.Bind("Laps"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab3", translate("Laps")).OnEvent("Click", chooseTab.Bind("Laps"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+10 w30 h30 vsettingsImg4", this.themeIcon(kIconsDirectory . "Strategy.ico")).OnEvent("Click", chooseTab.Bind("Strategies"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab4", translate("Strategies")).OnEvent("Click", chooseTab.Bind("Strategies"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+10 w30 h30 vsettingsImg5", this.themeIcon(kIconsDirectory . "Tools BW.ico")).OnEvent("Click", chooseTab.Bind("Setups"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab5", translate("Setups")).OnEvent("Click", chooseTab.Bind("Setups"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+10 w30 h30 vsettingsImg6", this.themeIcon(kIconsDirectory . "Pressure.ico")).OnEvent("Click", chooseTab.Bind("Pressures"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab6", translate("Tyre Pressures")).OnEvent("Click", chooseTab.Bind("Pressures"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+10 w30 h30 vsettingsImg7", this.themeIcon(kIconsDirectory . "Road.ico")).OnEvent("Click", chooseTab.Bind("Automation"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab7", translate("Automations")).OnEvent("Click", chooseTab.Bind("Automation"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("Norm")
		editorGui.SetFont("s10 Bold", "Arial")

		editorGui.Add("Picture", "x16 yp+10 w30 h30 vsettingsImg8", this.themeIcon(kIconsDirectory . "Sensor.ico")).OnEvent("Click", chooseTab.Bind("Data"))
		editorGui.Add("Text", "x50 yp+5 w220 h26 W:Grow(0.2) vsettingsTab8", translate("Administration")).OnEvent("Click", chooseTab.Bind("Data"))

		editorGui.Add("Text", "x16 yp+32 w267 W:Grow(0.2) 0x10")

		editorGui.SetFont("s8 Norm", "Arial")

		editorGui.Add("Picture", "x280 ys-2 w390 h554 Border X:Move(0.2) W:Grow(0.8) H:Grow")

		tabs := collect(["Settings", "Session", "Laps", "Stratgies", "Setups", "Pressures", "Automation", "Data"], translate)

		editorGui.Add("Tab2", "x296 ys+16 w0 h0 -Wrap Section vsettingsTab", tabs)

		editorGui["settingsTab"].UseTab(1)

		this.iSettingsListView := editorGui.Add("ListView", "x296 ys w360 h413 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Setting", "Value"], translate))
		this.iSettingsListView.OnEvent("Click", chooseSetting)
		this.iSettingsListView.OnEvent("DoubleClick", chooseSetting)
		this.iSettingsListView.OnEvent("ItemSelect", navSetting)

		editorGui.Add("Text", "x296 yp+419 w80 h23 X:Move(0.2) Y:Move +0x200", translate("Setting"))
		editorGui.Add("DropDownList", "xp+90 yp w270 Y:Move X:Move(0.2) W:Grow(0.8) vsettingDropDown").OnEvent("Change", selectSetting)

		editorGui.Add("Text", "x296 yp+24 w80 h23 X:Move(0.2) Y:Move +0x200", translate("Value"))
		editorGui.Add("DropDownList", "xp+90 yp w180 Y:Move vsettingValueDropDown").OnEvent("Change", changeSetting)
		editorGui.Add("Edit", "xp yp w50 X:Move(0.2) Y:Move vsettingValueEdit").OnEvent("Change", changeSetting)
		editorGui.Add("Edit", "xp yp w210 h57 Y:Move X:Move(0.2) W:Grow(0.8) vsettingValueText").OnEvent("Change", changeSetting)
		editorGui.Add("CheckBox", "xp yp+4 X:Move(0.2) Y:Move vsettingValueCheck").OnEvent("Click", changeSetting)

		editorGui.Add("Button", "x606 yp+30 w23 h23 X:Move Y:Move vaddSettingButton").OnEvent("Click", addSetting)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vdeleteSettingButton").OnEvent("Click", deleteSetting)
		setButtonIcon(editorGui["addSettingButton"], kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(editorGui["deleteSettingButton"], kIconsDirectory . "Minus.ico", 1)

		editorGui.Add("Button", "x296 yp+30 w90 h23 X:Move(0.2) Y:Move vexportSettingsButton", translate("Export...")).OnEvent("Click", exportSettings)
		editorGui.Add("Button", "xp+95 yp w90 h23 X:Move(0.2) Y:Move vimportSettingsButton", translate("Import...")).OnEvent("Click", importSettings)

		editorGui.Add("Button", "x574 yp w80 h23 Y:Move X:Move", translate("Test...")).OnEvent("Click", testSettings)

		editorGui["settingsTab"].UseTab(2)

		this.iSessionListView := editorGui.Add("ListView", "x296 ys w360 h433 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Source", "Category", "Name"], translate))
		this.iSessionListView.OnEvent("Click", chooseSession)
		this.iSessionListView.OnEvent("DoubleClick", openSession)
		this.iSessionListView.OnEvent("ItemSelect", navSession)

		editorGui.Add("Button", "xp+310 yp+440 w23 h23 X:Move Y:Move vrenameSessionButton").OnEvent("Click", renameSession)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vdeleteSessionButton").OnEvent("Click", deleteSession)
		setButtonIcon(editorGui["renameSessionButton"], kIconsDirectory . "Pencil.ico", 1)
		setButtonIcon(editorGui["deleteSessionButton"], kIconsDirectory . "Minus.ico", 1)

		editorGui.Add("Text", "x296 yp w80 h23 X:Move(0.2) Y:Move +0x200", translate("Share"))
		editorGui.Add("CheckBox", "xp+90 yp+4 w140 X:Move(0.2) Y:Move vshareSessionWithTeamServerCheck", translate("on Team Server")).OnEvent("Click", updateSessionAccess)

		editorGui["settingsTab"].UseTab(3)

		this.iTelemetryListView := editorGui.Add("ListView", "x296 ys w360 h433 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Source", "Name"], translate))
		this.iTelemetryListView.OnEvent("Click", chooseTelemetry)
		this.iTelemetryListView.OnEvent("DoubleClick", openTelemetry)
		this.iTelemetryListView.OnEvent("ItemSelect", navTelemetry)

		editorGui.Add("Button", "xp+260 yp+440 w23 h23 X:Move Y:Move vuploadTelemetryButton").OnEvent("Click", uploadTelemetry)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vdownloadTelemetryButton").OnEvent("Click", downloadTelemetry)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vrenameTelemetryButton").OnEvent("Click", renameTelemetry)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vdeleteTelemetryButton").OnEvent("Click", deleteTelemetry)
		setButtonIcon(editorGui["uploadTelemetryButton"], kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(editorGui["downloadTelemetryButton"], kIconsDirectory . "Download.ico", 1)
		setButtonIcon(editorGui["renameTelemetryButton"], kIconsDirectory . "Pencil.ico", 1)
		setButtonIcon(editorGui["deleteTelemetryButton"], kIconsDirectory . "Minus.ico", 1)

		editorGui.Add("Text", "x296 yp w80 h23 X:Move(0.2) Y:Move +0x200", translate("Share"))
		editorGui.Add("CheckBox", "xp+90 yp+4 w140 X:Move(0.2) Y:Move vshareTelemetryWithCommunityCheck", translate("with Community")).OnEvent("Click", updateTelemetryAccess)
		editorGui.Add("CheckBox", "x386 yp+24 w140 X:Move(0.2) Y:Move vshareTelemetryWithTeamServerCheck", translate("on Team Server")).OnEvent("Click", updateTelemetryAccess)

		editorGui["settingsTab"].UseTab(4)

		this.iStrategyListView := editorGui.Add("ListView", "x296 ys w360 h433 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Source", "Name"], translate))
		this.iStrategyListView.OnEvent("Click", chooseStrategy)
		this.iStrategyListView.OnEvent("DoubleClick", openStrategy)
		this.iStrategyListView.OnEvent("ItemSelect", navStrategy)

		editorGui.Add("Button", "xp+260 yp+440 w23 h23 X:Move Y:Move vuploadStrategyButton").OnEvent("Click", uploadStrategy)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vdownloadStrategyButton").OnEvent("Click", downloadStrategy)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vrenameStrategyButton").OnEvent("Click", renameStrategy)
		editorGui.Add("Button", "xp+25 yp w23 h23 X:Move Y:Move vdeleteStrategyButton").OnEvent("Click", deleteStrategy)
		setButtonIcon(editorGui["uploadStrategyButton"], kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(editorGui["downloadStrategyButton"], kIconsDirectory . "Download.ico", 1)
		setButtonIcon(editorGui["renameStrategyButton"], kIconsDirectory . "Pencil.ico", 1)
		setButtonIcon(editorGui["deleteStrategyButton"], kIconsDirectory . "Minus.ico", 1)

		editorGui.Add("Text", "x296 yp w80 h23 X:Move(0.2) Y:Move +0x200", translate("Share"))
		editorGui.Add("CheckBox", "xp+90 yp+4 w140 X:Move(0.2) Y:Move vshareStrategyWithCommunityCheck", translate("with Community")).OnEvent("Click", updateStrategyAccess)
		editorGui.Add("CheckBox", "x386 yp+24 w140 X:Move(0.2) Y:Move vshareStrategyWithTeamServerCheck", translate("on Team Server")).OnEvent("Click", updateStrategyAccess)

		editorGui["settingsTab"].UseTab(5)

		editorGui.Add("Text", "x296 ys w80 h23 +0x200 X:Move(0.2)", translate("Purpose"))
		editorGui.Add("DropDownList", "xp+90 yp w270 X:Move(0.2) W:Grow(0.8) Choose2 vsetupTypeDropDown"
					, collect(["Qualifying (Dry)", "Race (Dry)", "Qualifying (Wet)", "Race (Wet)"], translate)).OnEvent("Change", chooseSetupType)

		this.iSetupListView := editorGui.Add("ListView", "x296 yp+24 w360 h409 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Source", "Name"], translate))
		this.iSetupListView.OnEvent("Click", chooseSetup)
		this.iSetupListView.OnEvent("DoubleClick", chooseSetup)
		this.iSetupListView.OnEvent("ItemSelect", navSetup)

		this.iSelectedSetupType := kDryRaceSetup

		editorGui.Add("Button", "xp+260 yp+416 w23 h23 Y:Move X:Move vuploadSetupButton").OnEvent("Click", uploadSetup)
		editorGui.Add("Button", "xp+25 yp w23 h23 Y:Move X:Move vdownloadSetupButton").OnEvent("Click", downloadSetup)
		editorGui.Add("Button", "xp+25 yp w23 h23 Y:Move X:Move vrenameSetupButton").OnEvent("Click", renameSetup)
		editorGui.Add("Button", "xp+25 yp w23 h23 Y:Move X:Move vdeleteSetupButton").OnEvent("Click", deleteSetup)
		setButtonIcon(editorGui["uploadSetupButton"], kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(editorGui["downloadSetupButton"], kIconsDirectory . "Download.ico", 1)
		setButtonIcon(editorGui["renameSetupButton"], kIconsDirectory . "Pencil.ico", 1)
		setButtonIcon(editorGui["deleteSetupButton"], kIconsDirectory . "Minus.ico", 1)

		editorGui.Add("Text", "x296 yp w80 h23 X:Move(0.2) Y:Move +0x200", translate("Share"))
		editorGui.Add("CheckBox", "xp+90 yp+4 w140 X:Move(0.2) Y:Move vshareSetupWithCommunityCheck", translate("with Community")).OnEvent("Click", updateSetupAccess)
		editorGui.Add("CheckBox", "x386 yp+24 w140 X:Move(0.2) Y:Move vshareSetupWithTeamServerCheck", translate("on Team Server")).OnEvent("Click", updateSetupAccess)

		editorGui["settingsTab"].UseTab(6)

		editorGui.Add("Text", "x296 ys w85 h23 +0x200 X:Move(0.2)", translate("Driver"))
		editorGui.Add("DropDownList", "x386 yp w100 X:Move(0.2) vdriverDropDown").OnEvent("Change", loadPressures)

		editorGui.Add("Button", "x494 yp w22 h22 X:Move(0.2) veditPressuresButton").OnEvent("Click", editPressures)
		setButtonIcon(editorGui["editPressuresButton"], kIconsDirectory . "Pencil.ico", 1, "L2 T2 R2 B2")

		editorGui.Add("Text", "x296 yp+24 w85 h23 +0x200 X:Move(0.2)", translate("Compound"))
		editorGui.Add("DropDownList", "x386 yp w100 X:Move(0.2) vtyreCompoundDropDown").OnEvent("Change", loadPressures)

		editorGui.Add("Edit", "x494 yp w40 X:Move(0.2) -Background Number Limit2 vairTemperatureEdit"
					, Round(convertUnit("Temperature", this.iAirTemperature))).OnEvent("Change", loadPressures)
		editorGui.Add("UpDown", "xp+32 yp-2 w18 h20 X:Move(0.2) Range0-99", Round(convertUnit("Temperature", this.iAirTemperature)))
		editorGui.Add("Text", "xp+42 yp+2 w120 h23 X:Move(0.2) +0x200", substituteVariables(translate("Temp. Air (%unit%)"), {unit: getUnit("Temperature", true)}))

		editorGui.Add("Edit", "x494 yp+24 w40 X:Move(0.2) -Background Number Limit2 vtrackTemperatureEdit"
					, Round(convertUnit("Temperature", this.iTrackTemperature))).OnEvent("Change", loadPressures)
		editorGui.Add("UpDown", "xp+32 yp-2 w18 h20 X:Move(0.2) Range0-99", Round(convertUnit("Temperature", this.iTrackTemperature)))
		editorGui.Add("Text", "xp+42 yp+2 w120 h23 +0x200 X:Move(0.2)", substituteVariables(translate("Temp. Track (%unit%)"), {unit: getUnit("Temperature", true)}))

		editorGui.SetFont("Norm", "Arial")
		editorGui.SetFont("Bold Italic", "Arial")

		editorGui.Add("Text", "x342 yp+30 w267 0x10 X:Move(0.2)")
		editorGui.Add("Text", "x296 yp+10 w370 h20 X:Move(0.2) Center BackgroundTrans", substituteVariables(translate("Pressures (%unit%)"), {unit: getUnit("Pressure")}))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x296 yp+30 w85 h23 X:Move(0.2) +0x200", translate("Front Left"))
		editorGui.Add("Edit", "xp+90 yp w50 X:Move(0.2) Disabled Center vflPressure1", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vflPressure2", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Center +Background vflPressure3", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vflPressure4", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vflPressure5", displayValue("Float", 0.0))

		editorGui.Add("Text", "x296 yp+30 w85 h23 +0x200 X:Move(0.2)", translate("Front Right"))
		editorGui.Add("Edit", "xp+90 yp w50 X:Move(0.2) Disabled Center vfrPressure1", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vfrPressure2", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Center +Background vfrPressure3", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vfrPressure4", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vfrPressure5", displayValue("Float", 0.0))

		editorGui.Add("Text", "x296 yp+30 w85 h23 +0x200 X:Move(0.2)", translate("Rear Left"))
		editorGui.Add("Edit", "xp+90 yp w50 X:Move(0.2) Disabled Center vrlPressure1", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vrlPressure2", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Center +Background vrlPressure3", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vrlPressure4", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vrlPressure5", displayValue("Float", 0.0))

		editorGui.Add("Text", "x296 yp+30 w85 h23 +0x200 X:Move(0.2)", translate("Rear Right"))
		editorGui.Add("Edit", "xp+90 yp w50 X:Move(0.2) Disabled Center vrrPressure1", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vrrPressure2", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Center +Background vrrPressure3", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vrrPressure4", displayValue("Float", 0.0))
		editorGui.Add("Edit", "xp+54 yp w50 X:Move(0.2) Disabled Center vrrPressure5", displayValue("Float", 0.0))

		editorGui.Add("Picture", "x440 yp+40 w158 h8 X:Move(0.2) Center", kResourcesDirectory . "Icons\Pressures.png")
		editorGui.Add("Text", "x440 yp+10 w80 h23 X:Move(0.2) Left", translate("Exact"))
		editorGui.Add("Text", "x518 yp w80 h23 X:Move(0.2) Right", translate("Estimated"))

		if this.RequestorPID
			editorGui.Add("Button", "x440 yp+50 w80 h23 X:Move(0.2) vtransferPressuresButton", translate("Load")).OnEvent("Click", transferPressures)

		editorGui["settingsTab"].UseTab(7)

		this.iTrackDisplayArea := [297, 239, 358, 350]

		editorGui.Add("Picture", "x296 y238 w360 h382 X:Move(0.2) W:Grow(0.8) H:Grow(0.9) Border vtrackDisplayArea")
		this.iTrackDisplay := editorGui.Add("Picture", "x297 y239 BackgroundTrans vtrackDisplay")
		this.iTrackDisplay.OnEvent("Click", selectTrackAction)

		this.iTrackAutomationsListView := editorGui.Add("ListView", "x296 y627 w110 h142 Y:Move(0.9) X:Move(0.2) W:Grow(0.2) H:Grow(0.1) -Multi -LV0x10 Checked AltSubmit NoSort NoSortHdr", collect(["Name", "#"], translate))
		this.iTrackAutomationsListView.OnEvent("Click", selectTrackAutomation)
		this.iTrackAutomationsListView.OnEvent("DoubleClick", selectTrackAutomation)
		this.iTrackAutomationsListView.OnEvent("ItemSelect", navTrackAutomation)

		editorGui.Add("Text", "x415 yp w60 h23 Y:Move(0.9) X:Move(0.8) +0x200", translate("Name"))
		editorGui.Add("Edit", "xp+60 yp w109 Y:Move(0.9) X:Move(0.8) W:Grow(0.2) vtrackAutomationNameEdit")

		editorGui.Add("Button", "x584 yp w23 h23 Y:Move(0.9) X:Move vaddTrackAutomationButton").OnEvent("Click", addTrackAutomation)
		editorGui.Add("Button", "xp+25 yp w23 h23 Y:Move(0.9) X:Move vdeleteTrackAutomationButton").OnEvent("Click", deleteTrackAutomation)
		editorGui.Add("Button", "xp+25 yp w23 h23 Y:Move(0.9) X:Move Center +0x200 vsaveTrackAutomationButton").OnEvent("Click", saveTrackAutomation)
		setButtonIcon(editorGui["addTrackAutomationButton"], kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(editorGui["deleteTrackAutomationButton"], kIconsDirectory . "Minus.ico", 1)
		setButtonIcon(editorGui["saveTrackAutomationButton"], kIconsDirectory . "Save.ico", 1, "L5 T5 R5 B5")

		editorGui.Add("Text", "x415 yp+24 w60 h23 Y:Move(0.9) X:Move(0.8) +0x200", translate("Actions"))
		editorGui.Add("Edit", "xp+60 yp w181 h118 Y:Move(0.9) X:Move(0.8) W:Grow(0.2) H:Grow(0.1) ReadOnly -Wrap vtrackAutomationInfoEdit")

		editorGui["settingsTab"].UseTab(8)

		editorGui.Add("CheckBox", "Check3 x296 ys+2 w15 h21 X:Move(0.2) vdataSelectCheck").OnEvent("Click", selectAllData)

		this.iAdministrationListView := editorGui.Add("ListView", "x314 ys w342 h491 X:Move(0.2) W:Grow(0.8) H:Grow -Multi -LV0x10 Checked AltSubmit", collect(["Type", "Car / Track", "Driver", "#"], translate))
		this.iAdministrationListView.OnEvent("ItemCheck", selectData)
		this.iAdministrationListView.OnEvent("Click", noSelect)
		this.iAdministrationListView.OnEvent("DoubleClick", noSelect)

		editorGui.Add("Button", "x314 yp+506 w90 h23 X:Move(0.2) Y:Move vexportDataButton", translate("Export...")).OnEvent("Click", exportData)
		editorGui.Add("Button", "xp+95 yp w90 h23 X:Move(0.2) Y:Move vimportDataButton", translate("Import...")).OnEvent("Click", importData)

		editorGui.Add("Button", "x566 yp w90 h23 Y:Move X:Move vdeleteDataButton", translate("Delete...")).OnEvent("Click", deleteData)

		editorGui["settingsTab"].UseTab()

		editorGui.Add("Text", "x16 ys+361 w100 h23 +0x200", translate("Available Data"))

		choices := ["User", "User & Community"]
		chosen := (this.UseCommunity ? 2 : 1)

		editorGui.Add("DropDownList", "x120 yp w150 W:Grow(0.2) Choose" . chosen . " vdatabaseScopeDropDown", collect(choices, translate)).OnEvent("Change", chooseDatabaseScope)

		this.iDataListView := editorGui.Add("ListView", "x16 ys+385 w254 h151 W:Grow(0.2) H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Source", "Type", "#"], translate))
		this.iDataListView.OnEvent("Click", noSelect)
		this.iDataListView.OnEvent("DoubleClick", noSelect)

		editorGui.Add(SessionDatabaseEditor.EditorResizer(editorGui))

		this.loadSimulator(simulator, true)
		this.loadCar(car, true)
		this.loadTrack(track, true)
		this.loadWeather(weather, true)
	}

	show() {
		local window := this.Window
		local x, y, w, h

		showActionInfo(*) {
			global gActionInfoEnabled

			local x, y, coordinateX, coordinateY, window

			static currentAction := false
			static previousAction := false
			static actionInfo := ""

			displayToolTip() {
				SetTimer(displayToolTip, 0)

				ToolTip(actionInfo)

				SetTimer(removeToolTip, 10000)
			}

			removeToolTip() {
				SetTimer(removeToolTip, 0)

				ToolTip()
			}

			if ((this.SelectedModule = "Automation") && gActionInfoEnabled) {
				MouseGetPos(&x, &y)

				x := screen2Window(x)
				y := screen2Window(y)

				coordinateX := false
				coordinateY := false

				if this.findTrackCoordinate(x - this.iTrackDisplayArea[1], y - this.iTrackDisplayArea[2], &coordinateX, &coordinateY) {
					currentAction := this.findTrackAction(coordinateX, coordinateY)

					if !currentAction
						currentAction := (coordinateX . ";" . coordinateY)

					if (currentAction && (currentAction != previousAction)) {
						ToolTip()

						if isObject(currentAction) {
							switch currentAction.Type, false {
								case "Hotkey":
									actionInfo := translate(InStr(currentAction.Action, "|") ? "Hotkey(s): " : "Hotkey: ")
								case "Command":
									actionInfo := translate("Command: ")
								case "Speech":
									actionInfo := translate("Speech: ")
								case "Audio":
									actionInfo := translate("Audio: ")
								default:
									throw "Unknown action type detected in SessionDatabaseEditor.show..."
							}

							actionInfo := (inList(this.SelectedTrackAutomation.Actions, currentAction) . translate(": ")
										 . (Round(currentAction.X, 3) . translate(", ") . Round(currentAction.Y, 3))
										 . translate(" -> ")
										 . actionInfo . currentAction.Action)
						}
						else
							actionInfo := (Round(string2Values(";", currentAction)[1], 3) . translate(", ") . Round(string2Values(";", currentAction)[2], 3))

						SetTimer(removeToolTip, 0)
						SetTimer(displayToolTip, 1000)

						previousAction := currentAction
					}
					else if !currentAction {
						ToolTip()

						SetTimer(removeToolTip, 0)

						previousAction := false
					}
				}
				else {
					ToolTip()

					SetTimer(removeToolTip, 0)

					previousAction := false
				}
			}
		}

		if getWindowPosition("Session Database", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Session Database", &w, &h)
			window.Resize("Initialize", w, h)

		if (this.RequestorPID && this.moduleAvailable("Pressures"))
			this.selectModule("Pressures")
		else
			this.selectModule("Settings")

		OnMessage(0x0200, showActionInfo)
	}

	themeIcon(fileName) {
		return this.Window.Theme.RecolorizeImage(fileName)
	}

	getSimulators() {
		return this.SessionDatabase.getSimulators()
	}

	getCars(simulator) {
		return this.SessionDatabase.getCars(simulator)
	}

	getTracks(simulator, car := false) {
		local tracks, ignore, track

		if !car
			return []
		else if ((car == true) || (car = "*")) {
			if (this.iAllTracks.Length > 0)
				return this.iAllTracks
			else {
				tracks := []

				for ignore, car in this.getCars(simulator)
					for ignore, track in this.getTracks(simulator, car)
						if !inList(tracks, track)
							tracks.Push(track)

				this.iAllTracks := tracks

				return tracks
			}
		}
		else
			return this.SessionDatabase.getTracks(simulator, car)
	}

	getCarName(simulator, car) {
		return this.SessionDatabase.getCarName(simulator, car)
	}

	getCarCode(simulator, car) {
		return this.SessionDatabase.getCarCode(simulator, car)
	}

	getTrackName(simulator, track) {
		return this.SessionDatabase.getTrackName(simulator, track, false)
	}

	getTrackCode(simulator, track) {
		return this.SessionDatabase.getTrackCode(simulator, track)
	}

	updateState() {
		local window := this.Window
		local sessionDB := this.SessionDatabase
		local simulator, car, track, selected, selectedEntries, row, type
		local name, info, index, driver

		simulator := this.SelectedSimulator
		car := this.SelectedCar
		track := this.SelectedTrack

		if simulator {
			if !((car && (car != true)) && (track && (track != true)))
				if ((this.SelectedModule = "Sessions") || (this.SelectedModule = "Laps") || (this.SelectedModule = "Strategies") || (this.SelectedModule = "Setups") || (this.SelectedModule = "Pressures"))
					this.selectModule("Settings")
		}

		if this.moduleAvailable("Settings") {
			window["settingsImg1"].Enabled := true
			window["settingsImg1"].Value := this.themeIcon(kIconsDirectory . "General Settings.ico")
			window["settingsTab1"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg1"].Enabled := false
			window["settingsImg1"].Value := this.themeIcon(kIconsDirectory . "General Settings Gray.ico")
			window["settingsTab1"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Sessions") {
			window["settingsImg2"].Enabled := true
			window["settingsImg2"].Value := this.themeIcon(kIconsDirectory . "Sessions.ico")
			window["settingsTab2"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg2"].Enabled := false
			window["settingsImg2"].Value := this.themeIcon(kIconsDirectory . "Sessions Gray.ico")
			window["settingsTab2"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Laps") {
			window["settingsImg3"].Enabled := true
			window["settingsImg3"].Value := this.themeIcon(kIconsDirectory . "Tacho.ico")
			window["settingsTab3"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg3"].Enabled := false
			window["settingsImg3"].Value := this.themeIcon(kIconsDirectory . "Tacho Gray.ico")
			window["settingsTab3"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Strategies") {
			window["settingsImg4"].Enabled := true
			window["settingsImg4"].Value := this.themeIcon(kIconsDirectory . "Strategy.ico")
			window["settingsTab4"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg4"].Enabled := false
			window["settingsImg4"].Value := this.themeIcon(kIconsDirectory . "Strategy Gray.ico")
			window["settingsTab4"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Setups") {
			window["settingsImg5"].Enabled := true
			window["settingsImg5"].Value := this.themeIcon(kIconsDirectory . "Tools BW.ico")
			window["settingsTab5"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg5"].Enabled := false
			window["settingsImg5"].Value := this.themeIcon(kIconsDirectory . "Tools Gray.ico")
			window["settingsTab5"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Pressures") {
			window["settingsImg6"].Enabled := true
			window["settingsImg6"].Value := this.themeIcon(kIconsDirectory . "Pressure.ico")
			window["settingsTab6"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg6"].Enabled := false
			window["settingsImg6"].Value := this.themeIcon(kIconsDirectory . "Pressure Gray.ico")
			window["settingsTab6"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Automation") {
			window["settingsImg7"].Enabled := true
			window["settingsImg7"].Value := this.themeIcon(kIconsDirectory . "Road.ico")
			window["settingsTab7"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg7"].Enabled := false
			window["settingsImg7"].Value := this.themeIcon(kIconsDirectory . "Road Gray.ico")
			window["settingsTab7"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		if this.moduleAvailable("Data") {
			window["settingsImg8"].Enabled := true
			window["settingsImg8"].Value := this.themeIcon(kIconsDirectory . "Sensor.ico")
			window["settingsTab8"].SetFont("s10 Bold c" . window.Theme.TextColor["Disabled"], "Arial")
		}
		else {
			window["settingsImg8"].Enabled := false
			window["settingsImg8"].Value := this.themeIcon(kIconsDirectory . "Sensor Gray.ico")
			window["settingsTab8"].SetFont("s10 Bold c" . window.Theme.TextColor["Unavailable"], "Arial")
		}

		switch this.SelectedModule, false {
			case "Settings":
				window["settingsTab1"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(1)
			case "Sessions":
				window["settingsTab2"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(2)
			case "Laps":
				window["settingsTab3"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(3)
			case "Strategies":
				window["settingsTab4"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(4)
			case "Setups":
				window["settingsTab5"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(5)
			case "Pressures":
				window["settingsTab6"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(6)

				window["editPressuresButton"].Enabled := false

				if ((this.SelectedWeather != true) && !this.UseCommunity)
					for index, driver in sessionDB.getAllDrivers(this.SelectedSimulator)
						if (driver = sessionDB.ID) {
							if (window["driverDropDown"].Text = sessionDB.getDriverName(this.SelectedSimulator, driver))
								window["editPressuresButton"].Enabled := true

							break
						}
			case "Automation":
				window["settingsTab7"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(7)
			case "Data":
				window["settingsTab8"].SetFont("s10 Bold c" . window.Theme.TextColor, "Arial")

				window["settingsTab"].Choose(8)
		}

		selected := this.SessionListView.GetNext(0)

		if selected {
			type := this.SessionListView.GetText(selected, 1)
			name := this.SessionListView.GetText(selected, 3)

			if (type != translate("Community")) {
				type := this.SessionListView.GetText(selected, 2)

				if (type = translate("Solo"))
					type := "Solo"
				else
					type := "Team"

				info := this.SessionDatabase.readSessionInfo(simulator, car, track, type, name)

				window["deleteSessionButton"].Enabled := true

				if (!info || (getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID)) {
					window["renameSessionButton"].Enabled := true
					window["shareSessionWithTeamServerCheck"].Enabled := true
				}
				else {
					window["renameSessionButton"].Enabled := false
					window["shareSessionWithTeamServerCheck"].Enabled := false

					window["shareSessionWithTeamServerCheck"].Value := 0
				}
			}
			else {
				window["deleteSessionButton"].Enabled := false
				window["renameSessionButton"].Enabled := false
				window["shareSessionWithTeamServerCheck"].Enabled := false

				window["shareSessionWithTeamServerCheck"].Value := 0
			}
		}
		else {
			window["deleteSessionButton"].Enabled := false
			window["renameSessionButton"].Enabled := false
			window["shareSessionWithTeamServerCheck"].Enabled := false

			window["shareSessionWithTeamServerCheck"].Value := 0
		}

		selected := this.TelemetryListView.GetNext(0)

		if selected {
			type := this.TelemetryListView.GetText(selected, 1)
			name := this.TelemetryListView.GetText(selected, 2)

			window["downloadTelemetryButton"].Enabled := true

			if (type != translate("Community")) {
				info := this.SessionDatabase.readTelemetryInfo(simulator, car, track, name)

				window["deleteTelemetryButton"].Enabled := true

				if (!info || (getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID)) {
					window["renameTelemetryButton"].Enabled := true
					window["shareTelemetryWithCommunityCheck"].Enabled := true
					window["shareTelemetryWithTeamServerCheck"].Enabled := true
				}
				else {
					window["renameTelemetryButton"].Enabled := false
					window["shareTelemetryWithCommunityCheck"].Enabled := false
					window["shareTelemetryWithTeamServerCheck"].Enabled := false

					window["shareTelemetryWithCommunityCheck"].Value := 0
					window["shareTelemetryWithTeamServerCheck"].Value := 0
				}
			}
			else {
				window["deleteTelemetryButton"].Enabled := false
				window["renameTelemetryButton"].Enabled := false
				window["shareTelemetryWithCommunityCheck"].Enabled := false
				window["shareTelemetryWithTeamServerCheck"].Enabled := false

				window["shareTelemetryWithCommunityCheck"].Value := 0
				window["shareTelemetryWithTeamServerCheck"].Value := 0
			}
		}
		else {
			window["downloadTelemetryButton"].Enabled := false
			window["deleteTelemetryButton"].Enabled := false
			window["renameTelemetryButton"].Enabled := false
			window["shareTelemetryWithCommunityCheck"].Enabled := false
			window["shareTelemetryWithTeamServerCheck"].Enabled := false

			window["shareTelemetryWithCommunityCheck"].Value := 0
			window["shareTelemetryWithTeamServerCheck"].Value := 0
		}

		selected := this.StrategyListView.GetNext(0)

		if selected {
			type := this.StrategyListView.GetText(selected, 1)
			name := this.StrategyListView.GetText(selected, 2)

			window["downloadStrategyButton"].Enabled := true

			if (type != translate("Community")) {
				info := this.SessionDatabase.readStrategyInfo(simulator, car, track, name)

				window["deleteStrategyButton"].Enabled := true

				if (!info || (getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID)) {
					window["renameStrategyButton"].Enabled := true
					window["shareStrategyWithCommunityCheck"].Enabled := true
					window["shareStrategyWithTeamServerCheck"].Enabled := true
				}
				else {
					window["renameStrategyButton"].Enabled := false
					window["shareStrategyWithCommunityCheck"].Enabled := false
					window["shareStrategyWithTeamServerCheck"].Enabled := false

					window["shareStrategyWithCommunityCheck"].Value := 0
					window["shareStrategyWithTeamServerCheck"].Value := 0
				}
			}
			else {
				window["deleteStrategyButton"].Enabled := false
				window["renameStrategyButton"].Enabled := false
				window["shareStrategyWithCommunityCheck"].Enabled := false
				window["shareStrategyWithTeamServerCheck"].Enabled := false

				window["shareStrategyWithCommunityCheck"].Value := 0
				window["shareStrategyWithTeamServerCheck"].Value := 0
			}
		}
		else {
			window["downloadStrategyButton"].Enabled := false
			window["deleteStrategyButton"].Enabled := false
			window["renameStrategyButton"].Enabled := false
			window["shareStrategyWithCommunityCheck"].Enabled := false
			window["shareStrategyWithTeamServerCheck"].Enabled := false

			window["shareStrategyWithCommunityCheck"].Value := 0
			window["shareStrategyWithTeamServerCheck"].Value := 0
		}

		selected := this.SetupListView.GetNext(0)

		if selected {
			type := this.SetupListView.GetText(selected, 1)
			name := this.SetupListView.GetText(selected, 2)

			window["downloadSetupButton"].Enabled := true

			if (type != translate("Community")) {
				info := this.SessionDatabase.readSetupInfo(simulator, car, track, kSetupTypes[window["setupTypeDropDown"].Value], name)

				window["deleteSetupButton"].Enabled := true

				if (!info || (getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID)) {
					window["renameSetupButton"].Enabled := true
					window["shareSetupWithCommunityCheck"].Enabled := true
					window["shareSetupWithTeamServerCheck"].Enabled := true
				}
				else {
					window["renameSetupButton"].Enabled := false
					window["shareSetupWithCommunityCheck"].Enabled := false
					window["shareSetupWithTeamServerCheck"].Enabled := false

					window["shareSetupWithCommunityCheck"].Value := 0
					window["shareSetupWithTeamServerCheck"].Value := 0
				}
			}
			else {
				window["deleteSetupButton"].Enabled := false
				window["renameSetupButton"].Enabled := false
				window["shareSetupWithCommunityCheck"].Enabled := false
				window["shareSetupWithTeamServerCheck"].Enabled := false

				window["shareSetupWithCommunityCheck"].Value := 0
				window["shareSetupWithTeamServerCheck"].Value := 0
			}
		}
		else {
			window["downloadSetupButton"].Enabled := false
			window["deleteSetupButton"].Enabled := false
			window["renameSetupButton"].Enabled := false
			window["shareSetupWithCommunityCheck"].Enabled := false
			window["shareSetupWithTeamServerCheck"].Enabled := false

			window["shareSetupWithCommunityCheck"].Value := 0
			window["shareSetupWithTeamServerCheck"].Value := 0
		}

		selected := this.SettingsListView.GetNext(0)

		if selected {
			window["deleteSettingButton"].Enabled := true
			window["settingDropDown"].Enabled := true
			window["settingValueDropDown"].Enabled := true
			window["settingValueEdit"].Enabled := true
			window["settingValueText"].Enabled := true
			window["settingValueCheck"].Enabled := true
		}
		else {
			window["deleteSettingButton"].Enabled := false
			window["settingDropDown"].Enabled := false
			window["settingValueDropDown"].Visible := false
			window["settingValueDropDown"].Enabled := false
			window["settingValueCheck"].Visible := false
			window["settingValueCheck"].Enabled := false
			window["settingValueText"].Visible := false
			window["settingValueText"].Enabled := false
			window["settingValueEdit"].Visible := true
			window["settingValueEdit"].Enabled := false

			window["settingDropDown"].Choose(0)
			window["settingValueDropDown"].Choose(0)

			this.iSelectedValue := ""
			window["settingValueEdit"].Text := ""
		}

		if (this.getAvailableSettings().Length == 0)
			window["addSettingButton"].Enabled := false
		else
			window["addSettingButton"].Enabled := true

		window["exportSettingsButton"].Enabled := (this.SettingsListView.GetCount() > 0)

		selectedEntries := 0

		row := this.AdministrationListView.GetNext(0, "C")

		while row {
			selectedEntries += 1

			row := this.AdministrationListView.GetNext(row, "C")
		}

		window["importDataButton"].Enabled := true

		if (selectedEntries > 0) {
			window["exportDataButton"].Enabled := true
			window["deleteDataButton"].Enabled := true
		}
		else {
			window["exportDataButton"].Enabled := false
			window["deleteDataButton"].Enabled := false
		}

		if (selectedEntries = this.AdministrationListView.GetCount())
			window["dataSelectCheck"].Value := 1
		else if (selectedEntries > 0)
			window["dataSelectCheck"].Value := -1
		else
			window["dataSelectCheck"].Value := 0

		window["addTrackAutomationButton"].Enabled := true

		if this.SelectedTrackAutomation {
			window["trackAutomationNameEdit"].Enabled := true
			window["deleteTrackAutomationButton"].Enabled := true
			window["saveTrackAutomationButton"].Enabled := true
		}
		else {
			window["trackAutomationNameEdit"].Enabled := false
			window["deleteTrackAutomationButton"].Enabled := false
			window["saveTrackAutomationButton"].Enabled := false

			this.clearTrackAutomationEditor()

			if this.TrackMap
				this.createTrackMap()
		}
	}

	loadSimulator(simulator, force := false) {
		local window, choices, index, car, settings

		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window

			this.iSelectedSimulator := simulator

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Session Database", "Simulator", simulator)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			this.iAllTracks := []

			window["simulatorDropDown"].Choose(inList(this.getSimulators(), simulator))

			choices := this.getCars(simulator)

			for index, car in choices
				choices[index] := this.getCarName(simulator, car)

			choices.InsertAt(1, translate("All"))

			window["carDropDown"].Delete()
			window["carDropDown"].Add(choices)

			this.loadCar(true, true)
		}
	}

	loadCar(car, force := false) {
		local window, tracks, trackNames, settings

		if (force || (car != this.SelectedCar)) {
			this.iSelectedCar := car

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Session Database", "Car", car)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			window := this.Window

			if (car == true)
				window["carDropDown"].Choose(1)
			else
				window["carDropDown"].Choose(inList(this.getCars(this.SelectedSimulator), car) + 1)

			tracks := this.getTracks(this.SelectedSimulator, car).Clone()
			trackNames := collect(tracks, ObjBindMethod(this, "getTrackName", this.SelectedSimulator))

			tracks.InsertAt(1, true)
			trackNames.InsertAt(1, translate("All"))

			window["trackDropDown"].Delete()
			window["trackDropDown"].Add(trackNames)

			this.loadTrack(true, true)
		}
	}

	loadTrack(track, force := false) {
		local window, settings

		if (force || (track != this.SelectedTrack)) {
			this.iSelectedTrack := track

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Session Database", "Track", track)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			window := this.Window

			if (track == true) {
				this.iSelectedTrack := true

				window["trackDropDown"].Choose(1)
			}
			else
				window["trackDropDown"].Choose(inList(this.getTracks(this.SelectedSimulator, this.SelectedCar), track) + 1)

			this.updateModules()
		}
	}

	loadWeather(weather, force := false) {
		local window

		if (force || (weather != this.SelectedWeather)) {
			this.iSelectedWeather := weather

			window := this.Window

			if (weather == true)
				window["weatherDropDown"].Choose(1)
			else
				window["weatherDropDown"].Choose(inList(kWeatherConditions, weather) + 1)

			this.updateModules()
		}
	}

	loadSessions(select := false) {
		local window := this.Window
		local sessions, infos, index, name, info, origi

		this.SessionListView.Delete()

		for ignore, type in ["Solo", "Team"] {
			this.SessionDatabase.getSessions(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, type, &sessions, &infos := true)

			for index, name in sessions {
				origin := getMultiMapValue(infos[index], "Creator", "ID", this.SessionDatabase.ID)

				origin := this.SessionDatabase.getDriverName(this.SelectedSimulator, origin)

				if (select = name) {
					this.SessionListView.Add("Select Vis", origin, translate(type), name)

					select := this.StrategyListView.GetCount()
				}
				else
					this.SessionListView.Add("", origin, translate(type), name)
			}
		}

		this.SessionListView.ModifyCol()

		loop 3
			this.SessionListView.ModifyCol(A_Index, 10)

		loop 3
			this.SessionListView.ModifyCol(A_Index, "AutoHdr")

		if select
			this.selectSession(select)
		else
			this.updateState()
	}

	loadTelemetries(select := false) {
		local window, userTelemetries, communityTelemetries, ignore, name, info, origin

		window := this.Window

		this.TelemetryListView.Delete()

		userTelemetries := true
		communityTelemetries := this.UseCommunity

		this.SessionDatabase.getTelemetryNames(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, &userTelemetries, &communityTelemetries)

		for ignore, name in userTelemetries {
			info := this.SessionDatabase.readTelemetryInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, name)

			if !info
				origin := translate("User")
			else {
				origin := getMultiMapValue(info, "Origin", "Driver", this.SessionDatabase.ID)

				origin := this.SessionDatabase.getDriverName(this.SelectedSimulator, origin)
			}

			if (select = name) {
				this.TelemetryListView.Add("Select Vis", origin, name)

				select := this.TelemetryListView.GetCount()
			}
			else
				this.TelemetryListView.Add("", origin, name)
		}

		if communityTelemetries
			for ignore, name in communityTelemetries
				if !inList(userTelemetries, name)
					this.TelemetryListView.Add("", translate("Community"), name)

		this.TelemetryListView.ModifyCol()

		loop 2
			this.TelemetryListView.ModifyCol(A_Index, 10)

		loop 2
			this.TelemetryListView.ModifyCol(A_Index, "AutoHdr")

		if isNumber(select)
			this.selectTelemetry(select)
		else
			this.updateState()
	}

	loadStrategies(select := false) {
		local window := this.Window
		local userStrategies, communityStrategies, ignore, name, info, origin

		this.StrategyListView.Delete()

		userStrategies := true
		communityStrategies := this.UseCommunity

		this.SessionDatabase.getStrategyNames(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, &userStrategies, &communityStrategies)

		for ignore, name in userStrategies {
			info := this.SessionDatabase.readStrategyInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, name)

			if !info
				origin := translate("User")
			else {
				origin := getMultiMapValue(info, "Origin", "Driver", this.SessionDatabase.ID)

				origin := this.SessionDatabase.getDriverName(this.SelectedSimulator, origin)
			}

			if (select = name) {
				this.StrategyListView.Add("Select Vis", origin, name)

				select := this.StrategyListView.GetCount()
			}
			else
				this.StrategyListView.Add("", origin, name)
		}

		if communityStrategies
			for ignore, name in communityStrategies
				if !inList(userStrategies, name)
					this.StrategyListView.Add("", translate("Community"), name)

		this.StrategyListView.ModifyCol()

		loop 2
			this.StrategyListView.ModifyCol(A_Index, 10)

		loop 2
			this.StrategyListView.ModifyCol(A_Index, "AutoHdr")

		if isNumber(select)
			this.selectStrategy(select)
		else
			this.updateState()
	}

	loadSetups(setupType, force := false, select := false) {
		local window, userSetups, communitySetups, ignore, name, info, origin

		if (force || (setupType != this.SelectedSetupType)) {
			window := this.Window

			this.SetupListView.Delete()

			this.iSelectedSetupType := setupType

			window["setupTypeDropDown"].Choose(inList(kSetupTypes, setupType))

			userSetups := true
			communitySetups := this.UseCommunity

			this.SessionDatabase.getSetupNames(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, &userSetups, &communitySetups)

			userSetups := userSetups[setupType]

			for ignore, name in userSetups {
				info := this.SessionDatabase.readSetupInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, setupType, name)

				if !info
					origin := translate("User")
				else {
					origin := getMultiMapValue(info, "Origin", "Driver", this.SessionDatabase.ID)

					origin := this.SessionDatabase.getDriverName(this.SelectedSimulator, origin)
				}

				if (select = name) {
					this.SetupListView.Add("Select Vis", origin, name)

					select := this.SetupListView.GetCount()
				}
				else
					this.SetupListView.Add("", origin, name)
			}

			if communitySetups
				for ignore, name in communitySetups[setupType]
					if !inList(userSetups, name)
						this.SetupListView.Add("", translate("Community"), name)

			this.SetupListView.ModifyCol()

			loop 2
				this.SetupListView.ModifyCol(A_Index, 10)

			loop 2
				this.SetupListView.ModifyCol(A_Index, "AutoHdr")

			if isNumber(select)
				this.selectSetup(select)
			else
				this.updateState()
		}
	}

	exportSettings(directory, full := false) {
		local window := this.Window
		local progressWindow := showProgress({color: "Blue", title: translate("Exporting Settings")})
		local settings := newMultiMap()
		local progress := 0
		local count := 0
		local overall, simulator, ignore, car, track, weather, section, key, value

		directory := normalizeDirectoryPath(directory)

		progressWindow.Opt("+Owner" . window.Hwnd)
		window.Block()

		try {
			simulator := this.SelectedSimulator

			if full {
				overall := (this.getCars(simulator).Length * this.getTracks(simulator, "*").Length * kWeatherConditions.Length)

				showProgress({message: translate("Parsing database...")})

				for ignore, car in concatenate(["*"], this.getCars(simulator))
					for ignore, track in concatenate(["*"], this.getTracks(simulator, "*"))
						for ignore, weather in concatenate(["*"], kWeatherConditions) {
							count += SettingsDatabase().readSettings(simulator, car, track, weather, false, false).Length

							showProgress({progress: Round((++progress / overall) * 100)})
						}

				showProgress({Progress: (progress := 0), Color: "Green"})

				for ignore, car in concatenate(["*"], this.getCars(simulator))
					for ignore, track in concatenate(["*"], this.getTracks(simulator, "*"))
						for ignore, weather in concatenate(["*"], kWeatherConditions)
							for ignore, setting in SettingsDatabase().readSettings(simulator, car, track, weather, false, false) {
								section := setting["Section"]
								key := setting["Key"]
								value := setting["Value"]

								showProgress({progress: Round((++progress / count) * 100), message: this.getSettingLabel(section, key) . translate("...")})

								Sleep(50)

								setMultiMapValue(settings, values2String(" | ", section, car, track, weather), key, value)
							}
			}
			else {
				car := this.SelectedCar["*"]
				track := this.SelectedTrack["*"]
				weather := this.SelectedWeather["*"]

				count := this.SettingsListView.GetCount()

				for ignore, setting in SettingsDatabase().readSettings(simulator, car, track, weather, false, false) {
					section := setting["Section"]
					key := setting["Key"]
					value := setting["Value"]

					showProgress({progress: Round((++progress / count) * 100), message: this.getSettingLabel(section, key) . translate("...")})

					Sleep(50)

					setMultiMapValue(settings, values2String(" | ", section, car, track, weather), key, value)
				}
			}

			info := newMultiMap()

			setMultiMapValue(info, "General", "Type", "Settings")
			setMultiMapValue(info, "General", "Simulator", simulator)
			setMultiMapValue(info, "General", "Creator", this.SessionDatabase.ID)
			setMultiMapValue(info, "General", "Origin", this.SessionDatabase.DatabaseID)

			writeMultiMap(directory . "\Export.info", info)

			writeMultiMap(directory . "\Export.settings", settings)
		}
		catch Any as exception {
			logError(exception)
		}
		finally {
			window.Unblock()

			hideProgress()
		}
	}

	importSettings(directory, selection) {
		local window := this.Window
		local info := readMultiMap(directory . "\Export.info")
		local simulator, progress, progressWindow, ignore, setting, settingsDB
		local section, values, key, value

		directory := normalizeDirectoryPath(directory)

		if !this.Window {
			if (getMultiMapValue(info, "General", "Type", "Data") = "Settings") {
				simulator := getMultiMapValue(info, "General", "Simulator", "Unknown")

				try {
					settingsDB := SettingsDatabase()

					for section, values in readMultiMap(directory . "\Export.settings") {
						section := string2Values(" | ", section)

						for key, value in values
							settingsDB.setSettingValue(simulator, section[2], section[3], section[4], section[1], key, value)
					}
				}
				catch Any as exception {
					logError(exception, true)
				}
			}
		}
		else {
			window := this.Window
			simulator := this.SelectedSimulator
			progress := 0

			if ((this.SessionDatabase.getSimulatorName(getMultiMapValue(info, "General", "Simulator", "Unknown")) = simulator)
			 && (getMultiMapValue(info, "General", "Type", "Data") = "Settings")) {
				progressWindow := showProgress({color: "Green", title: translate("Importing Settings")})

				progressWindow.Opt("+Owner" . window.Hwnd)
				window.Block()

				try {
					settingsDB := SettingsDatabase()

					for ignore, setting in selection {
						showProgress({progress: ++progress, message: this.getSettingLabel(setting[4], setting[5]) . translate("...")})

						Sleep(50)

						settingsDB.setSettingValue(simulator, setting[1], setting[2], setting[3], setting[4], setting[5], setting[6])
					}
				}
				catch Any as exception {
					logError(exception)
				}
				finally {
					window.Unblock()

					hideProgress()
				}

				this.selectSettings()
			}
		}
	}

	loadSettings() {
		local window := this.Window
		local ignore, setting, type, value

		this.SettingsListView.Delete()

		this.iSettings := []

		for ignore, setting in SettingsDatabase().readSettings(this.SelectedSimulator, this.SelectedCar["*"]
															 , this.SelectedTrack["*"], this.SelectedWeather["*"]
															 , false, false) {
			type := this.getSettingType(setting["Section"], setting["Key"], &ignore)

			if type {
				if isObject(type)
					value := translate(setting["Value"])
				else if (type = "Boolean")
					value := (setting["Value"] ? "x" : "")
				else if (type = "Float")
					value := displayValue("Float", setting["Value"])
				else
					value := setting["Value"]

				this.iSettings.Push(Array(setting["Section"], setting["Key"]))

				this.SettingsListView.Add("", this.getSettingLabel(setting["Section"], setting["Key"]), value)
			}
		}

		this.SettingsListView.ModifyCol()

		loop 3
			this.SettingsListView.ModifyCol(A_Index, 10)

		loop 3
			this.SettingsListView.ModifyCol(A_Index, "AutoHdr")

		this.updateState()
	}

	selectSettings(load := true) {
		local window := this.Window
		local ignore, column, references, setting, reference, count

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Reference", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		references := {Car: 0, AllCar: 0, Track: 0, AllTrack: 0, Weather: 0, AllWeather: 0}

		for ignore, setting in SettingsDatabase().readSettings(this.SelectedSimulator, this.SelectedCar["*"]
															 , this.SelectedTrack["*"], this.SelectedWeather["*"]
															 , true, false) {
			if (setting["Car"]!= "*")
				references.Car += 1
			else
				references.AllCar += 1

			if (setting["Track"] != "*")
				references.Track += 1
			else
				references.AllTrack += 1

			if (setting["Weather"] != "*")
				references.Weather += 1
			else
				references.AllWeather += 1
		}

		for reference, count in references.OwnProps()
			if (count > 0) {
				switch reference, false {
					case "AllCar":
						reference := (translate("Car: ") . translate("All"))
					case "AllTrack":
						reference := (translate("Track: ") . translate("All"))
					case "AllWeather":
						reference := (translate("Weather: ") . translate("All"))
					case "Car":
						reference := (translate("Car: ") . this.getCarName(this.SelectedSimulator, this.SelectedCar))
					case "Track":
						reference := (translate("Track: ") . this.getTrackName(this.SelectedSimulator, this.SelectedTrack))
					case "Weather":
						reference := (translate("Weather: ") . translate(this.SelectedWeather))
				}

				this.DataListView.Add("", reference, count)
			}

		this.DataListView.ModifyCol()

		loop 2
			this.DataListView.ModifyCol(A_Index, 10)

		loop 2
			this.DataListView.ModifyCol(A_Index, "AutoHdr")

		if load
			this.loadSettings()
	}

	findTrackCoordinate(x, y, &coordinateX, &coordinateY, threshold := 40) {
		local trackMap := this.TrackMap
		local trackImage := this.TrackImage
		local scale, offsetX, offsetY, marginX, marginY, width, height, imgWidth, imgHeight, imgScale
		local candidateX, candidateY, deltaX, deltaY, coordX, coordY, dX, dY

		if (this.SelectedTrackAutomation && trackMap && trackImage) {
			scale := getMultiMapValue(trackMap, "Map", "Scale")

			offsetX := getMultiMapValue(trackMap, "Map", "Offset.X")
			offsetY := getMultiMapValue(trackMap, "Map", "Offset.Y")

			marginX := getMultiMapValue(trackMap, "Map", "Margin.X")
			marginY := getMultiMapValue(trackMap, "Map", "Margin.Y")

			width := this.iTrackDisplayArea[3]
			height := this.iTrackDisplayArea[4]

			imgWidth := ((getMultiMapValue(trackMap, "Map", "Width") + (2 * marginX)) * scale)
			imgHeight := ((getMultiMapValue(trackMap, "Map", "Height") + (2 * marginY)) * scale)

			imgScale := Min(width / imgWidth, height / imgHeight)

			x := (x / imgScale)
			y := (y / imgScale)

			x := ((x / scale) - offsetX - marginX)
			y := ((y / scale) - offsetY - marginY)

			candidateX := kUndefined
			candidateY := false
			deltaX := false
			deltaY := false

			threshold := (threshold / scale)

			loop getMultiMapValue(trackMap, "Map", "Points") {
				coordX := getMultiMapValue(trackMap, "Points", A_Index . ".X")
				coordY := getMultiMapValue(trackMap, "Points", A_Index . ".Y")

				dX := Abs(coordX - x)
				dY := Abs(coordY - y)

				if ((dX <= threshold) && (dY <= threshold) && ((candidateX == kUndefined) || ((dx + dy) < (deltaX + deltaY)))) {
					candidateX := coordX
					candidateY := coordY
					deltaX := dX
					deltaY := dY
				}
			}

			if (candidateX != kUndefined) {
				coordinateX := candidateX
				coordinateY := candidateY

				return true
			}
			else
				return false
		}
		else
			return false
	}

	findTrackAction(coordinateX, coordinateY, threshold := 40) {
		local trackMap := this.TrackMap
		local trackImage := this.TrackImage
		local candidate, deltaX, deltaY, dX, dY
		local index, action

		if (this.SelectedTrackAutomation && trackMap && trackImage) {
			candidate := false
			deltaX := false
			deltaY := false

			threshold := (threshold / getMultiMapValue(trackMap, "Map", "Scale"))

			for index, action in this.SelectedTrackAutomation.Actions {
				dX := Abs(coordinateX - action.X)
				dY := Abs(coordinateY - action.Y)

				if ((dX <= threshold) && (dY <= threshold) && (!candidate || ((dX + dy) < (deltaX + deltaY)))) {
					candidate := action

					deltaX := dx
					deltaY := dy
				}
			}

			return candidate
		}
		else
			return false
	}

	trackClicked(coordinateX, coordinateY) {
		local oldCoordMode := A_CoordModeMouse
		local x, y, action

		CoordMode("Mouse", "Screen")

		MouseGetPos(&x, &y)

		x := screen2Window(x)
		y := screen2Window(y)

		CoordMode("Mouse", oldCoordMode)

		action := actionDialog(x, y)

		if action {
			action.X := coordinateX
			action.Y := coordinateY

			this.addTrackAction(action)
		}
	}

	actionClicked(coordinateX, coordinateY, action) {
		local oldCoordMode := A_CoordModeMouse
		local x, y

		CoordMode("Mouse", "Screen")

		MouseGetPos(&x, &y)

		x := screen2Window(x)
		y := screen2Window(y)

		CoordMode("Mouse", oldCoordMode)

		action := actionDialog(x, y, action)

		if action
			this.updateTrackAction(action)
	}

	addTrackAction(action) {
		this.SelectedTrackAutomation.Actions.Push(action)

		this.updateTrackMap()
		this.updateTrackAutomationInfo()
	}

	updateTrackAction(action) {
		local index, candidate

		for index, candidate in this.SelectedTrackAutomation.Actions
			if ((action.X = candidate.X) && (action.Y = candidate.Y)) {
				this.SelectedTrackAutomation.Actions[index] := action

				this.updateTrackMap()
				this.updateTrackAutomationInfo()

				break
			}
	}

	deleteTrackAction(action) {
		local index, candidate

		for index, candidate in this.SelectedTrackAutomation.Actions
			if ((action.X = candidate.X) && (action.Y = candidate.Y)) {
				this.SelectedTrackAutomation.Actions.RemoveAt(index)

				this.updateTrackMap()
				this.updateTrackAutomationInfo()

				break
			}
	}

	addTrackAutomation() {
		local window := this.Window

		this.readTrackAutomations()

		this.iSelectedTrackAutomation := {Name: "...", Actions: [], Active: false}

		this.updateState()

		window["trackAutomationNameEdit"].Value := ""

		ControlFocus(window["trackAutomationNameEdit"])
	}

	deleteTrackAutomation() {
		if this.SelectedTrackAutomation.HasProp("Origin") {
			this.TrackAutomations.RemoveAt(inList(this.TrackAutomations, this.SelectedTrackAutomation.Origin))

			this.writeTrackAutomations()
		}
		else {
			this.clearTrackAutomationEditor()

			this.iSelectedTrackAutomation := false

			this.createTrackMap()

			this.updateState()
		}
	}

	saveTrackAutomation() {
		local window := this.Window
		local trackAutomation, origin, newTrackAutomation, row

		trackAutomation := this.SelectedTrackAutomation

		trackAutomation.Name := window["trackAutomationNameEdit"].Value

		if trackAutomation.HasProp("Origin") {
			origin := this.SelectedTrackAutomation.Origin

			origin.Name := trackAutomation.Name
			origin.Actions := trackAutomation.Actions.Clone()

			this.TrackAutomationsListView.Modify(this.TrackAutomationsListView.GetNext(0), "", trackAutomation.Name, trackAutomation.Actions.Length)
		}
		else {
			newTrackAutomation := trackAutomation.Clone()
			newTrackAutomation.Actions := trackAutomation.Actions.Clone()

			trackAutomation.Origin := newTrackAutomation

			this.TrackAutomations.Push(newTrackAutomation)

			row := this.TrackAutomationsListView.Add("", trackAutomation.Name, trackAutomation.Actions.Length)

			this.TrackAutomationsListView.Modify(row, "Vis Select")
		}

		this.TrackAutomationsListView.ModifyCol()

		loop 2
			this.TrackAutomationsListView.ModifyCol(A_Index, 10)

		loop 2
			this.TrackAutomationsListView.ModifyCol(A_Index, "AutoHdr")

		this.writeTrackAutomations(false)
	}

	clearTrackAutomationEditor() {
		local window := this.Window

		window["trackAutomationNameEdit"].Value := ""
		window["trackAutomationInfoEdit"].Value := ""
	}

	readTrackAutomations() {
		local trackAutomations, ignore, trackAutomation, option

		this.clearTrackAutomationEditor()

		this.TrackAutomations := []
		this.iSelectedTrackAutomation := false

		this.TrackAutomationsListView.Delete()

		trackAutomations := this.SessionDatabase.getTrackAutomations(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)

		this.iTrackAutomations := trackAutomations

		for ignore, trackAutomation in trackAutomations {
			option := (trackAutomation.Active ? "Check" : "")

			this.TrackAutomationsListView.Add(option, trackAutomation.Name, trackAutomation.Actions.Length)
		}

		this.TrackAutomationsListView.ModifyCol()

		loop 2
			this.TrackAutomationsListView.ModifyCol(A_Index, 10)

		loop 2
			this.TrackAutomationsListView.ModifyCol(A_Index, "AutoHdr")

		this.loadTrackMap(this.SessionDatabase.getTrackMap(this.SelectedSimulator, this.SelectedTrack)
														 , this.SessionDatabase.getTrackImage(this.SelectedSimulator, this.SelectedTrack))

		this.updateState()
	}

	writeTrackAutomations(read := true) {
		this.SessionDatabase.setTrackAutomations(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, this.TrackAutomations)

		if read
			this.readTrackAutomations()
	}

	createTrackMap(actions := false) {
		local trackMap := this.TrackMap
		local trackImage := this.TrackImage
		local scale := getMultiMapValue(trackMap, "Map", "Scale")
		local offsetX := getMultiMapValue(trackMap, "Map", "Offset.X")
		local offsetY := getMultiMapValue(trackMap, "Map", "Offset.Y")
		local marginX := getMultiMapValue(trackMap, "Map", "Margin.X")
		local marginY := getMultiMapValue(trackMap, "Map", "Margin.Y")
		local imgWidth := ((getMultiMapValue(trackMap, "Map", "Width") + (2 * marginX)) * scale)
		local imgHeight := ((getMultiMapValue(trackMap, "Map", "Height") + (2 * marginY)) * scale)
		local x, y, w, h, imgScale, deltaX, deltaY
		local token, bitmap, graphics, brushHotkey, brushCommand, r, ignore, action, imgX, imgY, trackImage

		ControlGetPos(&x, &y, &w, &h, this.Control["trackDisplayArea"])

		x += 2
		y += 2
		w -= 4
		h -= 4

		imgScale := Min(w / imgWidth, h / imgHeight)

		if actions {
			token := Gdip_Startup()

			bitmap := Gdip_CreateBitmapFromFile(trackImage)

			graphics := Gdip_GraphicsFromImage(bitmap)

			Gdip_SetSmoothingMode(graphics, 4)

			brushHotkey := Gdip_BrushCreateSolid(0xff00ff00)
			brushCommand := Gdip_BrushCreateSolid(0xffff0000)

			r := Round(15 / (imgScale * 3))

			for ignore, action in actions {
				imgX := Round((marginX + offsetX + action.X) * scale)
				imgY := Round((marginX + offsetY + action.Y) * scale)

				Gdip_FillEllipse(graphics, (action.Type = "Hotkey") ? brushHotkey : brushCommand, imgX - r, imgY - r, r * 2, r * 2)
			}

			Gdip_DeleteBrush(brushHotkey)
			Gdip_DeleteBrush(brushCommand)

			trackImage := temporaryFileName("Track Images\TrackMap", "png")

			Gdip_SaveBitmapToFile(bitmap, trackImage)

			Gdip_DisposeImage(bitmap)

			Gdip_DeleteGraphics(graphics)

			Gdip_Shutdown(token)
		}

		imgWidth *= imgScale
		imgHeight *= imgScale

		deltaX := ((w - imgWidth) / 2)
		deltaY := ((h - imgHeight) / 2)

		x := Round(x + deltaX)
		y := Round(y + deltaY)

		this.iTrackDisplayArea := [x, y, w, h, deltaX, deltaY]

		this.iTrackDisplay.Opt("-Redraw")

		ControlMove(x, y, w, h, this.iTrackDisplay)

		this.iTrackDisplay.Value := ("*w" . imgWidth . " *h" . imgHeight . A_Space . trackImage)

		this.iTrackDisplay.Opt("+Redraw")
	}

	updateTrackMap() {
		this.createTrackMap(this.SelectedTrackAutomation ? this.SelectedTrackAutomation.Actions : false)
	}

	updateTrackAutomationInfo() {
		local info := ""
		local index, action, actionInfo

		if this.SelectedTrackAutomation {
			for index, action in this.SelectedTrackAutomation.Actions {
				if (index > 1)
					info .= "`n"

				switch action.Type, false {
					case "Hotkey":
						actionInfo := translate(InStr(action.Action, "|") ? "Hotkey(s): " : "Hotkey: ")
					case "Command":
						actionInfo := translate("Command: ")
					case "Speech":
						actionInfo := translate("Speech: ")
					case "Audio":
						actionInfo := translate("Audio: ")
					default:
						throw "Unknown action type detected in SessionDatabaseEditor.show..."
				}

				info .= (index . translate(" -> ") . actionInfo . action.Action)
			}

			this.Control["trackAutomationInfoEdit"].Value := info
		}
	}

	loadTrackMap(trackMap, trackImage) {
		local directory := kTempDirectory . "Track Images"

		deleteDirectory(directory)

		DirCreate(directory)

		this.iTrackMap := trackMap
		this.iTrackImage := this.Window.Theme.RecolorizeImage(trackImage)

		this.createTrackMap()
	}

	unloadTrackMap() {
		this.iTrackDisplay.Value := (kIconsDirectory . "Empty.png")

		this.iTrackMap := false
		this.iTrackImage := false
	}

	selectAutomation() {
		local ignore, column

		if this.TrackMap
			this.unloadTrackMap()

		this.readTrackAutomations()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Type", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		this.DataListView.Delete()

		this.DataListView.Add("", translate("Track: "), 1)
		this.DataListView.Add("", translate("Automations: "), this.TrackAutomations.Length)

		this.DataListView.ModifyCol()

		loop 2
			this.DataListView.ModifyCol(A_Index, 10)

		loop 2
			this.DataListView.ModifyCol(A_Index, "AutoHdr")
	}

	deleteEntries(connectors, database, localTable, serverTable, driver) {
		local ignore, connector, row

		database.lock(localTable)

		try {
			if (driver = this.SessionDatabase.ID)
				for ignore, connector in connectors
					try {
						for ignore, row in database.query(localTable, {Where: {Driver: driver}})
							if (row["Identifier"] != kNull)
								connector.DeleteData(serverTable, row["Identifier"])
					}
					catch Any as exception {
						logError(exception, true)
					}

			database.remove(localTable, {Driver: driver}, always.Bind(true))
		}
		finally {
			database.unlock(localTable)
		}
	}

	deleteData() {
		local connectors := this.SessionDatabase.Connectors
		local window := this.Window
		local progressWindow, simulator, count, row, type, data, car, track
		local driver, telemetryDB, tyresDB, code, candidate, progress
		local ignore, identifier, identifiers, name, extension

		progressWindow := showProgress({color: "Green", title: translate("Deleting Data")})

		progressWindow.Opt("+Owner" . window.Hwnd)
		window.Block()

		try {
			simulator := this.SelectedSimulator

			count := 1

			row := this.AdministrationListView.GetNext(0, "C")

			while (row := this.AdministrationListView.GetNext(row, "C"))
				count += 1

			row := this.AdministrationListView.GetNext(0, "C")
			progress := 0

			while row {
				progress += 1

				type := this.AdministrationListView.GetText(row, 1)
				data := this.AdministrationListView.GetText(row, 2)

				if InStr(data, " / ") {
					data := string2Values(" / ", data)

					car := data[1]
					track := data[2]
				}
				else if (type = translate("Tracks")) {
					car := "-"
					track := data
				}
				else {
					car := "-"
					track := "-"
				}

				driver := this.AdministrationListView.GetText(row, 3)

				showProgress({progress: Round((progress / count) * 100), message: translate("Car: ") . car . translate(", Track: ") . track})

				driver := this.SessionDatabase.getDriverID(simulator, driver)
				car := this.getCarCode(simulator, car)
				track := this.getTrackCode(simulator, track)

				switch type, false {
					case translate("Telemetry"):
						telemetryDB := TelemetryDatabase(simulator, car, track).Database

						this.deleteEntries(connectors, telemetryDB, "Electronics", "Electronics", driver)
						this.deleteEntries(connectors, telemetryDB, "Tyres", "Tyres", driver)
					case translate("Pressures"):
						tyresDB := TyresDatabase().getTyresDatabase(simulator, car, track)

						this.deleteEntries(connectors, tyresDB, "Tyres.Pressures", "TyresPressures", driver)
						this.deleteEntries(connectors, tyresDB, "Tyres.Pressures.Distribution", "TyresPressuresDistribution", driver)
					case translate("Strategies"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Race Strategies\*.strategy", "F"
							this.SessionDatabase.removeStrategy(simulator, car, track, A_LoopFileName)
					case translate("Sessions"):
						for ignore, type in ["Solo", "Team"]
							loop Files, this.SessionDatabase.getSessionDirectory(simulator, car, track, type) . "*." . StrLower(type), "F" {
								SplitPath(A_LoopFileName, , , , &name)

								this.SessionDatabase.removeSession(simulator, car, track, type, name)
							}
					case translate("Laps"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Lap Telemetries\*.telemetry", "F"
							this.SessionDatabase.removeTelemetry(simulator, car, track, A_LoopFileName)
					case translate("Setups"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						for ignore, type in kSetupTypes
							loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Car Setups\" . type . "\*.*", "F" {
								SplitPath(A_LoopFileName, &name, , &extension)

								if (extension != "info")
									this.SessionDatabase.removeSetup(simulator, car, track, type, name)
							}
					case translate("Tracks"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						loop Files, kDatabaseDirectory . "User\Tracks\" . code . "\*.*", "F" {

							SplitPath(A_LoopFileName, , , , &candidate)

							if (candidate = track)
								deleteFile(A_LoopFileFullPath)
						}
					case translate("Automations"):
						if this.SessionDatabase.hasTrackAutomations(simulator, car, track)
							this.SessionDatabase.setTrackAutomations(simulator, car, track, [])
				}

				row := this.AdministrationListView.GetNext(row, "C")
			}
		}
		finally {
			window.Unblock()

			hideProgress()
		}

		this.selectData()
	}

	exportData(directory) {
		local window := this.Window
		local progressWindow := showProgress({color: "Green", title: translate("Exporting Data")})
		local simulator, count, row, drivers, schemas, progress, type, data, car, track, driver, id
		local targetDirectory, sourceDB, targetDB, ignore, type, entry, code, candidate
		local trackAutomations, info, id, name, schema, fields
		local type, ext, folder, fileName

		directory := normalizeDirectoryPath(directory)

		progressWindow.Opt("+Owner" . window.Hwnd)
		window.Block()

		try {
			simulator := this.SelectedSimulator

			count := 1

			row := this.AdministrationListView.GetNext(0, "C")

			while (row := this.AdministrationListView.GetNext(row, "C"))
				count += 1

			row := this.AdministrationListView.GetNext(0, "C")

			drivers := CaseInsenseMap()
			schemas := CaseInsenseMap()
			progress := 0

			while row {
				progress += 1

				type := this.AdministrationListView.GetText(row, 1)
				data := this.AdministrationListView.GetText(row, 2)

				if InStr(data, " / ") {
					data := string2Values(" / ", data)

					car := data[1]
					track := data[2]
				}
				else if (type = translate("Tracks")) {
					car := "-"
					track := data
				}
				else {
					car := "-"
					track := "-"
				}

				driver := this.AdministrationListView.GetText(row, 3)

				id := this.SessionDatabase.getDriverID(simulator, driver)

				showProgress({progress: Round((progress / count) * 100), message: translate("Car: ") . car . translate(", Track: ") . track})

				if id {
					drivers[id] := driver

					driver := id
				}

				car := this.getCarCode(simulator, car)
				track := this.getTrackCode(simulator, track)

				targetDirectory := (directory . "\" . car . "\" . track . "\")

				switch type, false {
					case translate("Telemetry"):
						sourceDB := TelemetryDatabase(simulator, car, track).Database
						targetDB := Database(targetDirectory, kTelemetrySchemas)

						schemas["Electronics"] := kTelemetrySchemas["ELectronics"]
						schemas["Tyres"] := kTelemetrySchemas["Tyres"]

						for ignore, entry in sourceDB.query("Electronics", {Where: {Driver: driver}})
							targetDB.add("Electronics", entry, true)

						for ignore, entry in sourceDB.query("Tyres", {Where: {Driver: driver}})
							targetDB.add("Tyres", entry, true)
					case translate("Pressures"):
						sourceDB := TyresDatabase().getTyresDatabase(simulator, car, track)
						targetDB := Database(targetDirectory, kTyresSchemas)

						schemas["Tyres.Pressures"] := kTyresSchemas["Tyres.Pressures"]
						schemas["Tyres.Pressures.Distribution"] := kTyresSchemas["Tyres.Pressures.Distribution"]

						for ignore, entry in sourceDB.query("Tyres.Pressures", {Where: {Driver: driver}})
							targetDB.add("Tyres.Pressures", entry, true)

						for ignore, entry in sourceDB.query("Tyres.Pressures.Distribution", {Where: {Driver: driver}})
							targetDB.add("Tyres.Pressures.Distribution", entry, true)
					case translate("Sessions"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						for type, ext in Map("Team Sessions", "team", "Solo Sessions", "solo") {
							DirCreate(targetDirectory . type)

							loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\" . type . "\*." . ext, "F"
								if (getMultiMapValue(readMultiMap(A_LoopFileFullPath), "Creator", "ID") = driver) {
									SplitPath(A_LoopFileFullPath, , &folder, , &fileName)

									try {
										FileCopy(A_LoopFileFullPath, targetDirectory . type . "\" . A_LoopFileName)
										FileCopy(folder . "\" . fileName . ".session", targetDirectory . type . "\" . fileName . ".session")
									}
									catch Any as exception {
										logError(exception)
									}
								}
						}
					case translate("Laps"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						DirCreate(targetDirectory . "Lap Telemetries")

						loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Lap Telemetries\*.*", "F"
							try {
								FileCopy(A_LoopFileFullPath, targetDirectory . "Lap Telemetries\" . A_LoopFileName)
							}
							catch Any as exception {
								logError(exception)
							}
					case translate("Strategies"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						DirCreate(targetDirectory . "Race Strategies")

						loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Race Strategies\*.*", "F"
							try {
								FileCopy(A_LoopFileFullPath, targetDirectory . "Race Strategies\" . A_LoopFileName)
							}
							catch Any as exception {
								logError(exception)
							}
					case translate("Setups"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						for ignore, type in kSetupTypes
							loop Files, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Car Setups\" . type . "\*.*", "F" {
								DirCreate(targetDirectory . "Car Setups\" . type)

								try {
									FileCopy(A_LoopFileFullPath, targetDirectory . "Car Setups\" . type . "\" . A_LoopFileName)
								}
								catch Any as exception {
									logError(exception)
								}
							}
					case translate("Tracks"):
						code := this.SessionDatabase.getSimulatorCode(simulator)

						DirCreate(directory . "\.Tracks")

						loop Files, kDatabaseDirectory . "User\Tracks\" . code . "\*.*", "F" {
							SplitPath(A_LoopFileName, , , , &candidate)

							if (candidate = track)
								try {
									FileCopy(A_LoopFileFullPath, directory . "\.Tracks\" . A_LoopFileName)
								}
								catch Any as exception {
									logError(exception)
								}
						}
					case translate("Automations"):
						trackAutomations := this.SessionDatabase.getTrackAutomations(simulator, car, track)

						this.SessionDatabase.saveTrackAutomations(trackAutomations, targetDirectory . "Track.automations")
				}

				row := this.AdministrationListView.GetNext(row, "C")
			}

			info := newMultiMap()

			setMultiMapValue(info, "General", "Type", "Data")
			setMultiMapValue(info, "General", "Simulator", simulator)
			setMultiMapValue(info, "General", "Creator", this.SessionDatabase.ID)
			setMultiMapValue(info, "General", "Origin", this.SessionDatabase.DatabaseID)

			for id, name in drivers
				setMultiMapValue(info, "Driver", id, name)

			for schema, fields in schemas
				setMultiMapValue(info, "Schema", schema, values2String(",", fields*))

			writeMultiMap(directory . "\Export.info", info)
		}
		catch Any as exception {
			logError(exception)
		}
		finally {
			window.Unblock()

			hideProgress()
		}
	}

	importData(directory, selection) {
		local window := this.Window
		local simulator := this.SelectedSimulator
		local info := readMultiMap(directory . "\Export.info")
		local progressWindow, schemas, schema, fields, id, name, progress, tracks, code, ignore, row, field, type
		local targetDirectory, car, carName, track, trackName, key, sourceDirectory, drivers, driver, sourceDB, targetDB
		local tyresDB, data, targetName, name, folder, fileName, automations, automation, trackAutomations, trackName, extension

		directory := normalizeDirectoryPath(directory)

		if ((!window || (this.SessionDatabase.getSimulatorName(getMultiMapValue(info, "General", "Simulator", "Unknown")) = simulator))
		 && (getMultiMapValue(info, "General", "Type", "Data") = "Data")) {
			progressWindow := showProgress({color: "Green", title: translate("Importing Data")})

			if window {
				progressWindow.Opt("+Owner" . window.Hwnd)

				window.Block()
			}

			schemas := CaseInsenseMap()

			schemas["Electronics"] := kTelemetrySchemas["Electronics"]
			schemas["Tyres"] := kTelemetrySchemas["Tyres"]
			schemas["Tyres.Pressures"] := kTyresSchemas["Tyres.Pressures"]
			schemas["Tyres.Pressures.Distribution"] := kTyresSchemas["Tyres.Pressures.Distribution"]

			for schema, fields in getMultiMapValues(info, "Schema")
				schemas[schema] := string2Values(",", fields)

			try {
				for id, name in getMultiMapValues(info, "Driver")
					this.SessionDatabase.registerDriver(simulator, id, name)

				progress := 0

				if FileExist(directory . "\.Tracks") {
					tracks := []

					code := this.SessionDatabase.getSimulatorCode(simulator)

					loop Files, directory . "\.Tracks\*.*", "F" {
						SplitPath(A_LoopFileName, , , , &track)

						if !inList(tracks, track)
							tracks.Push(track)
					}

					for ignore, track in tracks
						if selection.Has("-." . track . ".Tracks") {
							targetDirectory := (kDatabaseDirectory . "User\Tracks\" . code)

							DirCreate(targetDirectory)

							try {
								FileCopy(directory . "\.Tracks\" . track . ".*", targetDirectory, 1)
							}
							catch Any as exception {
							   logError(exception)
							}
						}
				}

				loop Files, directory . "\*.*", "D"	; Car
					if (InStr(A_LoopFileName, ".") != 1) {
						car := A_LoopFileName
						carName := this.getCarName(simulator, car)

						loop Files, directory . "\" . car . "\*.*", "D" {
							track := A_LoopFileName
							trackName := this.getTrackName(simulator, track)

							key := (car . "." . track . ".")

							showProgress({progress: ++progress, message: translate("Car: ") . carName . translate(", Track: ") . trackName})

							if (progress >= 100)
								progress := 0

							sourceDirectory := (A_LoopFileDir . "\" . track)

							if selection.Has(key . "Telemetry") {
								drivers := selection[key . "Telemetry"]

								sourceDB := Database(sourceDirectory . "\", schemas)
								targetDB := TelemetryDatabase(simulator, car, track).Database

								targetDB.lock("Electronics")

								try {
									for ignore, driver in drivers
										for ignore, row in sourceDB.query("Electronics", {Where: {Driver: driver}}) {
											data := Database.Row()

											for ignore, field in schemas["Electronics"]
												data[field] := row[field]

											targetDB.add("Electronics", data, true)
										}
								}
								finally {
									targetDB.unlock("Electronics")
								}

								targetDB.lock("Tyres")

								try {
									for ignore, driver in drivers
										for ignore, row in sourceDB.query("Tyres", {Where: {Driver: driver}}) {
											data := Database.Row()

											for ignore, field in schemas["Tyres"]
												data[field] := row[field]

											targetDB.add("Tyres", data, true)
										}
								}
								finally {
									targetDB.unlock("Tyres")
								}
							}

							if selection.Has(key . "Pressures") {
								drivers := selection[key . "Pressures"]

								tyresDB := TyresDatabase()
								sourceDB := Database(sourceDirectory . "\", schemas)
								targetDB := tyresDB.lock(simulator, car, track)

								try {
									for ignore, driver in drivers {
										for ignore, row in sourceDB.query("Tyres.Pressures", {Where: {Driver: driver}}) {
											data := Database.Row()

											for ignore, field in schemas["Tyres.Pressures"]
												data[field] := row[field]

											targetDB.add("Tyres.Pressures", data, true)
										}

										for ignore, row in sourceDB.query("Tyres.Pressures.Distribution", {Where: {Driver: driver}}) {
											tyresDB.updatePressure(simulator, car, track, row["Weather"], row["Temperature.Air"], row["Temperature.Track"]
																 , row["Compound"], row["Compound.Color"]
																 , row["Type"], row["Tyre"], row["Pressure"], row["Count"]
																 , false, true, "User", driver)
										}
									}
								}
								finally {
									tyresDB.unlock()
								}
							}

							if selection.Has(key . "Sessions")
								for type, ext in Map("Team Sessions", "team", "Solo Sessions", "solo") {
									drivers := selection[key . "Sessions"]
									code := this.SessionDatabase.getSimulatorCode(simulator)

									targetDirectory := (kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\" . type)

									DirCreate(targetDirectory)

									loop Files, sourceDirectory . "\" . type . "\*." . ext, "F"
										for ignore, driver in drivers
											if (getMultiMapValue(readMultiMap(A_LoopFileFullPath), "Creator", "ID") = driver) {
												SplitPath(A_LoopFileFullPath, , &folder, , &fileName)

												targetName := (fileName . "." . ext)

												while FileExist(targetDirectory . "\" . targetName)
													targetName := (fileName . " (" . (A_Index + 1) . ")." . ext)

												try {
													FileCopy(A_LoopFilePath, targetDirectory . "\" . targetName)
												}
												catch Any as exception {
													logError(exception)
												}

												if FileExist(A_LoopFilePath . ".info")
													try {
														FileCopy(A_LoopFilePath . ".info", targetDirectory . "\" . targetName ".info")
													}
													catch Any as exception {
														logError(exception)
													}

												SplitPath(targetName, , , , &targetName)

												try {
													FileCopy(folder . "\" . fileName . ".session", targetDirectory . "\" . targetName . ".session")
												}
												catch Any as exception {
													logError(exception)
												}
											}
								}

							if (selection.Has(key . "Telemetries") && FileExist(sourceDirectory . "\Lap Telemetries")) {
								code := this.SessionDatabase.getSimulatorCode(simulator)

								targetDirectory := (kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Lap Telemetries")

								DirCreate(targetDirectory)

								loop Files, sourceDirectory . "\Lap Telemetries\*.telemetry", "F" {
									fileName := A_LoopFileName
									targetName := fileName

									while FileExist(targetDirectory . "\" . targetName) {
										SplitPath(fileName, , , , &name)

										targetName := (name . " (" . (A_Index + 1) . ").telemetry")
									}

									try {
										FileCopy(A_LoopFilePath, targetDirectory . "\" . targetName)
									}
									catch Any as exception {
										logError(exception)
									}

									if FileExist(A_LoopFilePath . ".info")
										try {
											FileCopy(A_LoopFilePath . ".info", targetDirectory . "\" . targetName ".info")
										}
										catch Any as exception {
											logError(exception)
										}
								}
							}

							if (selection.Has(key . "Strategies") && FileExist(sourceDirectory . "\Race Strategies")) {
								code := this.SessionDatabase.getSimulatorCode(simulator)

								targetDirectory := (kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Race Strategies")

								DirCreate(targetDirectory)

								loop Files, sourceDirectory . "\Race Strategies\*.strategy", "F" {
									fileName := A_LoopFileName
									targetName := fileName

									while FileExist(targetDirectory . "\" . targetName) {
										SplitPath(fileName, , , , &name)

										targetName := (name . " (" . (A_Index + 1) . ").strategy")
									}

									try {
										FileCopy(A_LoopFilePath, targetDirectory . "\" . targetName)
									}
									catch Any as exception {
										logError(exception)
									}

									if FileExist(A_LoopFilePath . ".info")
										try {
											FileCopy(A_LoopFilePath . ".info", targetDirectory . "\" . targetName ".info")
										}
										catch Any as exception {
											logError(exception)
										}
								}
							}

							if (selection.Has(key . "Setups") && FileExist(sourceDirectory . "\Car Setups")) {
								code := this.SessionDatabase.getSimulatorCode(simulator)

								for ignore, type in kSetupTypes {
									targetDirectory := (kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Car Setups\" . type)

									DirCreate(targetDirectory)

									loop Files, sourceDirectory . "\Car Setups\" . type . "\*.*", "F" {
										SplitPath(A_LoopFileName, , , &extension)

										if (extension != "info") {
											try {
												FileCopy(A_LoopFilePath, targetDirectory . "\" . A_LoopFileName)
											}
											catch Any as exception {
												logError(exception)
											}

											if FileExist(A_LoopFilePath . ".info")
												try {
													FileCopy(A_LoopFilePath . ".info", targetDirectory . "\" . A_LoopFileName . ".info")
												}
												catch Any as exception {
													logError(exception)
												}
										}
									}
								}
							}

							if (selection.Has(key . "Automations") && FileExist(sourceDirectory . "\Track.automations")) {
								code := this.SessionDatabase.getSimulatorCode(simulator)

								automations := this.SessionDatabase.loadTrackAutomations(sourceDirectory . "\Track.automations")

								trackAutomations := this.SessionDatabase.getTrackAutomations(simulator, car, track)

								for ignore, automation in automations {
									automation.Active := false

									trackAutomations.Push(automation)
								}

								this.SessionDatabase.setTrackAutomations(simulator, car, track, trackAutomations)
							}
						}
					}
			}
			catch Any as exception {
				logError(exception)
			}
			finally {
				if window
					window.Unblock()

				hideProgress()
			}

			if window
				this.selectData()
		}
	}

	loadData() {
		local window := this.Window
		local progressWindow := showProgress({color: "Green", title: translate("Analyzing Data")})
		local selectedSimulator, selectedCar, selectedTrack, drivers, simulator, progress, tracks, track
		local car, carName, found, targetDirectory, telemetryDB, ignore, driver, tyresDB, result, number, strategies
		local sessions, telemetries, automations, trackName, setups, ignore, type, extension

		progressWindow.Opt("+Owner" . window.Hwnd)
		window.Block()

		try {
			this.AdministrationListView.Delete()

			selectedSimulator := this.SelectedSimulator
			selectedCar := this.SelectedCar
			selectedTrack := this.SelectedTrack

			if selectedSimulator {
				drivers := this.SessionDatabase.getAllDrivers(selectedSimulator)
				simulator := this.SessionDatabase.getSimulatorCode(selectedSimulator)

				progress := 0

				tracks := []

				loop Files, kDatabaseDirectory . "User\Tracks\" . simulator . "\*.*", "F" {
					SplitPath(A_LoopFileName, , , , &track)

					if (((selectedTrack = true) || (track = selectedTrack)) && !inList(tracks, track)) {
						this.AdministrationListView.Add("", translate("Tracks"), this.getTrackName(selectedSimulator, track), "-", 1)

						tracks.Push(track)
					}
				}

				loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D"
					if (InStr(A_LoopFileName, ".") != 1) {
						car := A_LoopFileName

						if ((selectedCar == true) || (car = selectedCar)) {
							carName := this.getCarName(selectedSimulator, car)

							loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\*.*", "D" {
								track := A_LoopFileName

								if ((selectedTrack == true) || (track = selectedTrack)) {
									trackName := this.getTrackName(selectedSimulator, track)
									found := false

									showProgress({progress: ++progress, message: translate("Car: ") . carName . translate(", Track: ") . trackName})

									if (progress >= 100)
										progress := 0

									targetDirectory := (kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\")

									telemetryDB := TelemetryDatabase(simulator, car, track)

									for ignore, driver in drivers {
										number := (telemetryDB.getElectronicsCount(driver) + telemetryDB.getTyresCount(driver))

										if (number > 0)
											this.AdministrationListView.Add("", translate("Telemetry"), (carName . " / " . trackName), this.SessionDatabase.getDriverName(selectedSimulator, driver), number)
									}

									tyresDB := TyresDatabase().getTyresDatabase(simulator, car, track)

									for ignore, driver in drivers {
										result := tyresDB.query("Tyres.Pressures", {Group: [["Driver", count, "Count"]]
																				  , Where: {Driver: driver}})

										number := ((result.Length > 0) ? result[1]["Count"] : 0)

										result := tyresDB.query("Tyres.Pressures.Distribution", {Group: [["Driver", count, "Count"]]
																							   , Where: {Driver: driver}})

										number += ((result.Length > 0) ? result[1]["Count"] : 0)

										if (number > 0)
											this.AdministrationListView.Add("", translate("Pressures"), (carName . " / " . trackName), this.SessionDatabase.getDriverName(selectedSimulator, driver), number)
									}

									strategies := 0

									loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Race Strategies\*.strategy", "F"
										strategies += 1

									if (strategies > 0)
										this.AdministrationListView.Add("", translate("Strategies"), (carName . " / " . trackName), "-", strategies)

									telemetries := 0

									loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Lap Telemetries\*.telemetry", "F"
										telemetries += 1

									if (telemetries > 0)
										this.AdministrationListView.Add("", translate("Laps"), (carName . " / " . trackName), "-", telemetries)

									sessions := CaseInsenseMap()

									loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Team Sessions\*.team", "F" {
										driver := getMultiMapValue(readMultiMap(A_LoopFileFullPath), "Creator", "ID")

										if sessions.Has(driver)
											sessions[driver] += 1
										else
											sessions[driver] := 1
									}

									loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Solo Sessions\*.solo", "F" {
										driver := getMultiMapValue(readMultiMap(A_LoopFileFullPath), "Creator", "ID")

										if sessions.Has(driver)
											sessions[driver] += 1
										else
											sessions[driver] := 1
									}

									for driver, number in sessions
										this.AdministrationListView.Add("", translate("Sessions"), (carName . " / " . trackName), this.SessionDatabase.getDriverName(selectedSimulator, driver), number)

									setups := 0

									for ignore, type in kSetupTypes
										loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Car Setups\" . type . "\*.*", "F" {
											SplitPath(A_LoopFileName, , , &extension)

											if (extension != "info")
												setups += 1
										}

									if (setups > 0)
										this.AdministrationListView.Add("", translate("Setups"), (carName . " / " . trackName), "-", setups)

									automations := this.SessionDatabase.getTrackAutomations(simulator, car, track).Length

									if (automations > 0)
										this.AdministrationListView.Add("", translate("Automations"), (carName . " / " . trackName), "-", automations)
								}
							}
						}
					}
			}

			this.AdministrationListView.ModifyCol()

			loop 4
				this.AdministrationListView.ModifyCol(A_Index, 10)

			loop 4
				this.AdministrationListView.ModifyCol(A_Index, "AutoHdr")

			this.updateState()
		}
		finally {
			window.Unblock()

			hideProgress()
		}
	}

	selectData(load := true) {
		local ignore, column, selectedSimulator, selectedCar, selectedTrack, drivers, cars, telemetry
		local pressures, strategies, sessions, telemetries, automations, tracks, simulator, track, car, found, targetDirectory, number
		local ignore, type, extension, setups

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Type", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		selectedSimulator := this.SelectedSimulator
		selectedCar := this.SelectedCar
		selectedTrack := this.SelectedTrack

		if selectedSimulator {
			drivers := this.SessionDatabase.getAllDrivers(selectedSimulator)
			cars := []
			telemetry := 0
			pressures := 0
			strategies := 0
			telemetries := 0
			sessions := 0
			setups := 0
			automations := 0
			tracks := 0

			simulator := this.SessionDatabase.getSimulatorCode(selectedSimulator)

			tracks := []

			loop Files, kDatabaseDirectory . "User\Tracks\" . simulator . "\*.*", "F" {
				SplitPath(A_LoopFileName, , , , &track)

				if (((selectedTrack = true) || (track = selectedTrack)) && !inList(tracks, track))
					tracks.Push(track)
			}

			loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D"
				if (InStr(A_LoopFileName, ".") != 1) {
					car := A_LoopFileName

					if ((selectedCar == true) || (car = selectedCar))
						loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\*.*", "D" {
							track := A_LoopFileName

							if ((selectedTrack == true) || (track = selectedTrack)) {
								found := false

								targetDirectory := (kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\")

								if (FileExist(targetDirectory . "Electronics.CSV") || FileExist(targetDirectory . "Tyres.CSV")) {
									found := true

									telemetry += 1
								}

								if (FileExist(targetDirectory . "Tyres.Pressures.CSV")
								 || FileExist(targetDirectory . "Tyres.Pressures.Distribution.CSV")) {
									found := true

									pressures += 1
								}

								loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Race Strategies\*.strategy", "F" {
									found := true

									strategies += 1
								}

								loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Lap Telemetries\*.telemetry", "F" {
									found := true

									telemetries += 1
								}

								loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Team Sessions\*.team", "F" {
									found := true

									sessions += 1
								}

								loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Solo Sessions\*.solo", "F" {
									found := true

									sessions += 1
								}

								for ignore, type in kSetupTypes
									loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Car Setups\" . type . "\*.*", "F" {
										SplitPath(A_LoopFileName, , , &extension)

										if (extension != "info") {
											found := true

											setups += 1
										}
									}

								number := this.SessionDatabase.getTrackAutomations(simulator, car, track).Length

								if (number > 0) {
									automations += number

									found := true
								}

								if (found && !inList(cars, car))
									cars.Push(car)
							}
						}
			}

			this.DataListView.Add("", translate("Tracks"), tracks.Length)
			this.DataListView.Add("", translate("Automations"), automations)
			this.DataListView.Add("", translate("Drivers"), drivers.Length)
			this.DataListView.Add("", translate("Cars"), cars.Length)
			this.DataListView.Add("", translate("Telemetry"), telemetry)
			this.DataListView.Add("", translate("Pressures"), pressures)
			this.DataListView.Add("", translate("Sessions"), sessions)
			this.DataListView.Add("", translate("Laps"), telemetries)
			this.DataListView.Add("", translate("Strategies"), strategies)
			this.DataListView.Add("", translate("Setups"), setups)

			this.DataListView.ModifyCol()
			this.DataListView.ModifyCol(1, "AutoHdr")
			this.DataListView.ModifyCol(2, "AutoHdr")
		}

		if load
			this.loadData()
	}

	selectSessions() {
		local ignore, column, sessions, infos, type, setups
		local info, origin

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Category", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		userStrategies := true
		communityStrategies := true

		for ignore, type in ["Solo", "Team"] {
			this.SessionDatabase.getSessions(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, type, &sessions, &infos := true)

			this.DataListView.Add("", translate(type), sessions.Length)
		}

		this.DataListView.ModifyCol()

		loop 2
			this.DataListView.ModifyCol(A_Index, 10)

		loop 2
			this.DataListView.ModifyCol(A_Index, "AutoHdr")

		this.loadSessions()
	}

	selectTelemetries() {
		local ignore, column, userTelemetries, communityTelemetries
		local info, origin

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Source", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		userTelemetries := true
		communityTelemetries := true

		this.SessionDatabase.getTelemetryNames(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, &userTelemetries, &communityTelemetries)

		this.DataListView.Add("", translate("User"), userTelemetries.Length)

		this.DataListView.Add("", translate("Community"), communityTelemetries.Length)

		this.DataListView.ModifyCol()

		loop 2
			this.DataListView.ModifyCol(A_Index, 10)

		loop 2
			this.DataListView.ModifyCol(A_Index, "AutoHdr")

		this.loadTelemetries()
	}

	selectStrategies() {
		local ignore, column, userStrategies, communityStrategies
		local info, origin

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Source", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		userStrategies := true
		communityStrategies := true

		this.SessionDatabase.getStrategyNames(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, &userStrategies, &communityStrategies)

		this.DataListView.Add("", translate("User"), userStrategies.Length)

		this.DataListView.Add("", translate("Community"), communityStrategies.Length)

		this.DataListView.ModifyCol()

		loop 2
			this.DataListView.ModifyCol(A_Index, 10)

		loop 2
			this.DataListView.ModifyCol(A_Index, "AutoHdr")

		this.loadStrategies()
	}

	selectSetups() {
		local ignore, column, userSetups, communitySetups, type, setups
		local info, origin

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Source", "Type", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		userSetups := true
		communitySetups := true

		this.SessionDatabase.getSetupNames(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, &userSetups, &communitySetups)

		for type, setups in userSetups
			this.DataListView.Add("", translate("User"), translate(kSetupNames[type]), setups.Length)

		for type, setups in communitySetups
			this.DataListView.Add("", translate("Community"), translate(kSetupNames[type]), setups.Length)

		this.DataListView.ModifyCol()

		loop 3
			this.DataListView.ModifyCol(A_Index, 10)

		loop 3
			this.DataListView.ModifyCol(A_Index, "AutoHdr")

		this.loadSetups(this.SelectedSetupType, true)
	}

	selectPressures() {
		local ignore, column, info, source, simulator

		this.DataListView.Delete()

		loop this.DataListView.GetCount("Col")
			this.DataListView.DeleteCol(1)

		for ignore, column in collect(["Source", "Weather", "T Air", "T Track", "Compound", "#"], translate)
			this.DataListView.InsertCol(A_Index, "", column)

		sessionDB := this.SessionDatabase
		simulator := this.SelectedSimulator

		for ignore, info in SessionDatabaseEditor.EditorTyresDatabase().getPressureInfo(simulator, this.SelectedCar
																					  , this.SelectedTrack, this.SelectedWeather) {
			if (info.Source = "User") {
				if (info.Driver = kNull)
					source := translate("User")
				else
					source := sessionDB.getDriverName(simulator, info.Driver)
			}
			else
				source := translate("Community")

			this.DataListView.Add("", source
									, translate(info.Weather), Round(convertUnit("Temperature", info.AirTemperature)), Round(convertUnit("Temperature", info.TrackTemperature))
									, translate(info.Compound), info.Count)
		}

		this.DataListView.ModifyCol()

		loop 6
			this.DataListView.ModifyCol(A_Index, 10)

		loop 6
			this.DataListView.ModifyCol(A_Index, "AutoHdr")

		this.loadPressures()
	}

	moduleAvailable(module) {
		local simulator := this.SelectedSimulator
		local car := this.SelectedCar
		local track := this.SelectedTrack

		if simulator {
			this.iAvailableModules["Settings"] := true
			this.iAvailableModules["Data"] := true

			if ((car && (car != true)) && (track && (track != true))) {
				this.iAvailableModules["Sessions"] := true
				this.iAvailableModules["Laps"] := true
				this.iAvailableModules["Strategies"] := true
				this.iAvailableModules["Setups"] := true
				this.iAvailableModules["Pressures"] := true
				this.iAvailableModules["Automation"] := this.SessionDatabase.hasTrackMap(simulator, track)
			}
			else {
				this.iAvailableModules["Sessions"] := false
				this.iAvailableModules["Laps"] := false
				this.iAvailableModules["Strategies"] := false
				this.iAvailableModules["Setups"] := false
				this.iAvailableModules["Pressures"] := false
				this.iAvailableModules["Automation"] := false
			}
		}
		else {
			this.iAvailableModules["Settings"] := false
			this.iAvailableModules["Data"] := false
			this.iAvailableModules["Sessions"] := false
			this.iAvailableModules["Laps"] := false
			this.iAvailableModules["Strategies"] := false
			this.iAvailableModules["Setups"] := false
			this.iAvailableModules["Pressures"] := false
			this.iAvailableModules["Automation"] := false
		}

		return this.iAvailableModules[module]
	}

	selectModule(module, force := false) {
		local window

		if this.moduleAvailable(module) {
			if (force || (this.SelectedModule != module)) {
				this.iSelectedModule := module

				window := this.Window

				if ((module != "Automation") && this.TrackMap)
					this.unloadTrackMap()

				switch module, false {
					case "Settings":
						this.selectSettings()
					case "Data":
						this.selectData()
					case "Sessions":
						this.selectSessions()
					case "Laps":
						this.selectTelemetries()
					case "Strategies":
						this.selectStrategies()
					case "Setups":
						this.selectSetups()
					case "Automation":
						this.selectAutomation()
					case "Pressures":
						this.selectPressures()
				}

				this.updateState()
			}
		}
	}

	updateModules() {
		local window := this.Window

		window["notesEdit"].Value := this.SessionDatabase.readNotes(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)

		if (this.SelectedModule && this.moduleAvailable(this.SelectedModule))
			this.selectModule(this.SelectedModule, true)
		else
			this.selectModule("Settings", true)
	}

	updateNotes(notes) {
		this.SessionDatabase.writeNotes(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, notes)
	}

	getSettingLabel(section := false, key := false) {
		local selected

		if !section {
			selected := this.SettingsListView.GetNext(0)

			if selected {
				section := this.iSettings[selected][1]
				key := this.iSettings[selected][2]
			}
		}

		return getMultiMapValue(this.SettingDescriptors, section . ".Labels", key, "")
	}

	getSettingType(section := false, key := false, &default := false) {
		local selected, type

		if !section {
			selected := this.SettingsListView.GetNext(0)

			if selected {
				section := this.iSettings[selected][1]
				key := this.iSettings[selected][2]
			}
			else
				return default
		}

		type := getMultiMapValue(this.SettingDescriptors, section . ".Types", key, false)

		if type {
			if InStr(type, ";") {
				type := string2Values(";", type)

				default := type[2]
				type := type[1]
			}
			else
				default := ""

			if InStr(type, "Choices:")
				type := string2Values(",", string2Values(":", type)[2])

			if (default = kTrue)
				default := true
			else if (default = kFalse)
				default := false

			if (this.SelectedSimulator && (this.SelectedSimulator != true)
			 && this.SelectedCar && (this.SelectedCar != true) && (section = "Session Settings")) {
				if (InStr(key, "Tyre.Dry.Pressure.Target") = 1)
					default := this.SessionDatabase.optimalTyrePressure(this.SelectedSimulator, this.SelectedCar, "Dry", default)
				else if (InStr(key, "Tyre.Wet.Pressure.Target") = 1)
					default := this.SessionDatabase.optimalTyrePressure(this.SelectedSimulator, this.SelectedCar, "Wet", default)
			}
		}

		return type
	}

	getAvailableSettings(selection := false) {
		local found := false
		local fileName, settingDescriptors, section, values, key, value, settings, skip, ignore
		local available, index, candidate

		if (this.SettingDescriptors.Count = 0) {
			settingDescriptors := readMultiMap(kResourcesDirectory . "Database\Settings.ini")

			for ignore, fileName in getFileNames("Settings." . getLanguage(), kTranslationsDirectory, kUserTranslationsDirectory) {
				found := true

				for section, values in readMultiMap(fileName)
					for key, value in values
						setMultiMapValue(settingDescriptors, section, key, value)
			}

			if !found
				for section, values in readMultiMap(kTranslationsDirectory . "Settings.en")
					for key, value in values
						setMultiMapValue(settingDescriptors, section, key, value)

			this.iSettingDescriptors := settingDescriptors
		}

		settings := []

		for section, values in this.SettingDescriptors
			if InStr(section, ".Types") {
				section := StrReplace(section, ".Types", "")

				if (InStr(section, "Simulator.") == 1)
					skip := (StrReplace(section, "Simulator.", "") != this.SelectedSimulator)
				else
					skip := false

				if !skip
					for key, ignore in values {
						available := true

						for index, candidate in this.iSettings
							if (index != selection)
								if ((section = candidate[1]) && (key = candidate[2])) {
									available := false

									break
								}

						if available
							settings.Push(Array(section, key))
					}
			}

		return settings
	}

	chooseSetting() {
		local selected, setting, value, settings, section, key, ignore, candidate
		local labels, descriptor, type

		selected := this.SettingsListView.GetNext(0)

		if !selected
			return

		setting := this.SettingsListView.GetText(selected, 1)
		value := this.SettingsListView.GetText(selected, 2)

		settings := this.getAvailableSettings(selected)

		section := false
		key := false

		for ignore, candidate in settings
			if (setting = this.getSettingLabel(candidate[1], candidate[2])) {
				section := candidate[1]
				key := candidate[2]

				break
			}

		labels := []

		for ignore, descriptor in settings
			labels.Push(this.getSettingLabel(descriptor[1], descriptor[2]))

		bubbleSort(&labels)

		this.Control["settingDropDown"].Delete()
		this.Control["settingDropDown"].Add(labels)
		this.Control["settingDropDown"].Choose(inList(labels, setting))

		ignore := false

		type := this.getSettingType(section, key, &ignore)

		if isObject(type) {
			this.Control["settingValueEdit"].Visible := false
			this.Control["settingValueText"].Visible := false
			this.Control["settingValueCheck"].Visible := false
			this.Control["settingValueDropDown"].Visible := true
			this.Control["settingValueDropDown"].Enabled := true

			labels := collect(type, translate)

			this.Control["settingValueDropDown"].Delete()
			this.Control["settingValueDropDown"].Add(labels)
			this.Control["settingValueDropDown"].Choose(inList(labels, value))
		}
		else if (type = "Boolean") {
			this.Control["settingValueDropDown"].Visible := false
			this.Control["settingValueEdit"].Visible := false
			this.Control["settingValueText"].Visible := false
			this.Control["settingValueCheck"].Visible := true
			this.Control["settingValueCheck"].Enabled := true

			if (this.Control["settingValueCheck"].Value != value)
				this.Control["settingValueCheck"].Value := (value = "x") ? true : false
		}
		else if (type = "Text") {
			this.Control["settingValueDropDown"].Visible := false
			this.Control["settingValueCheck"].Visible := false
			this.Control["settingValueEdit"].Visible := false
			this.Control["settingValueText"].Visible := true
			this.Control["settingValueText"].Enabled := true

			if (this.Control["settingValueText"].Text != value)
				this.Control["settingValueText"].Text := value
		}
		else {
			this.Control["settingValueDropDown"].Visible := false
			this.Control["settingValueCheck"].Visible := false
			this.Control["settingValueText"].Visible := false
			this.Control["settingValueEdit"].Visible := true
			this.Control["settingValueEdit"].Enabled := true

			this.iSelectedValue := value

			if (this.Control["settingValueEdit"].Text != value)
				this.Control["settingValueEdit"].Text := value
		}

		this.updateState()
	}

	addSetting(section, key, value) {
		local window := this.Window
		local type, ignore, display, row

		window.Block()

		try {
			this.iSettings.Push(Array(section, key))

			ignore := false

			type := this.getSettingType(section, key, &ignore)

			if isObject(type)
				display := translate(value)
			else if (type = "Boolean")
				display := (value ? "x" : "")
			else if (type = "Text")
				display := StrReplace(StrReplace(value, "`n", A_Space), "`r", "")
			else if (type = "Float")
				display := displayValue("Float", value)
			else
				display := value

			row := this.SettingsListView.Add("", this.getSettingLabel(section, key), display)

			this.SettingsListView.Modify(row, "Vis Select")

			this.SettingsListView.ModifyCol()

			this.SettingsListView.ModifyCol(1, "AutoHdr")
			this.SettingsListView.ModifyCol(2, "AutoHdr")

			SettingsDatabase().setSettingValue(this.SelectedSimulator
											 , this.SelectedCar["*"], this.SelectedTrack["*"], this.SelectedWeather["*"]
											 , section, key, value)

			this.chooseSetting()

			this.selectSettings(false)
			this.updateState()

			this.SettingsListView.Redraw()
		}
		finally {
			window.Unblock()
		}
	}

	deleteSetting(section, key) {
		local window := this.Window
		local selected

		window.Block()

		try {
			selected := this.SettingsListView.GetNext(0)

			this.SettingsListView.Delete(selected)

			this.SettingsListView.ModifyCol()

			this.SettingsListView.ModifyCol(1, "AutoHdr")
			this.SettingsListView.ModifyCol(2, "AutoHdr")

			SettingsDatabase().removeSettingValue(this.SelectedSimulator
												, this.SelectedCar["*"], this.SelectedTrack["*"], this.SelectedWeather["*"]
												, section, key)

			this.iSettings.RemoveAt(selected)

			this.selectSettings(false)
			this.updateState()

			this.SettingsListView.Redraw()
		}
		finally {
			window.Unblock()
		}
	}

	updateSetting(section, key, value) {
		local window := this.Window
		local selected, type, ignore, display, settingsDB

		window.Block()

		try {
			selected := this.SettingsListView.GetNext(0)

			ignore := false

			type := this.getSettingType(section, key, &ignore)

			if isObject(type)
				display := translate(value)
			else if (type = "Boolean")
				display := (value ? "x" : "")
			else if (type = "Text")
				display := StrReplace(StrReplace(value, "`n", A_Space), "`r", "")
			else if (type = "Float")
				display := displayValue("Float", value)
			else
				display := value

			this.SettingsListView.Modify(selected, "", this.getSettingLabel(section, key), display)

			this.SettingsListView.ModifyCol()

			this.SettingsListView.ModifyCol(1, "AutoHdr")
			this.SettingsListView.ModifyCol(2, "AutoHdr")

			settingsDB := SettingsDatabase()

			if ((this.iSettings[selected][1] != section) || (this.iSettings[selected][2] != key)) {
				settingsDB.removeSettingValue(this.SelectedSimulator
											, this.SelectedCar["*"], this.SelectedTrack["*"], this.SelectedWeather["*"]
											, this.iSettings[selected][1], this.iSettings[selected][2])

				this.iSettings[selected][1] := section
				this.iSettings[selected][2] := key
			}

			settingsDB.setSettingValue(this.SelectedSimulator
									 , this.SelectedCar["*"], this.SelectedTrack["*"], this.SelectedWeather["*"]
									 , section, key, value)

			this.selectSettings(false)
			this.updateState()

			this.SettingsListView.Redraw()
		}
		finally {
			window.Unblock()
		}
	}

	loadPressures() {
		local sessionDB := this.SessionDatabase
		local window, compounds, chosenCompound, tyreCompound, tyreCompoundColor, pressureInfos, index
		local ignore, tyre, postfix, tyre, pressureInfo, pressure, trackDelta, airDelta, color
		local drivers, driver, selectedDriver

		static lastSimulator := false
		static lastCar := false
		static lastTrack := false
		static lastCommunity := kUndefined
		static lastColor := "D0D0D0"

		if (this.SelectedSimulator && (this.SelectedSimulator != true)
		 && this.SelectedCar && (this.SelectedCar != true)
		 && this.SelectedTrack && (this.SelectedTrack != true)) {
			window := this.Window

			lastColor := "D0D0D0"

			try {
				compounds := sessionDB.getTyreCompounds(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack)

				chosenCompound := 0

				if ((this.SelectedSimulator = lastSimulator) && (this.SelectedCar = lastCar) && (this.SelectedTrack = lastTrack))
					chosenCompound := window["tyreCompoundDropDown"].Value
				else if this.iTyreCompound
					chosenCompound := inList(compounds, compound(this.iTyreCompound, this.iTyreCompoundColor))

				if ((chosenCompound == 0) && (compounds.Length > 0))
					chosenCompound := 1

				window["tyreCompoundDropDown"].Delete()
				window["tyreCompoundDropDown"].Add(collect(compounds, translate))
				window["tyreCompoundDropDown"].Choose(chosenCompound)

				if ((this.SelectedSimulator != lastSimulator) || (this.UseCommunity != lastCommunity)) {
					drivers := [translate("All")]
					selectedDriver := false

					if !this.UseCommunity
						for ignore, driver in sessionDB.getAllDrivers(this.SelectedSimulator) {
							if (driver = sessionDB.ID)
								selectedDriver := driver

							drivers.Push(sessionDB.getDriverName(this.SelectedSimulator, driver))
						}

					window["driverDropDown"].Delete()
					window["driverDropDown"].Add(drivers)

					if selectedDriver {
						window["driverDropDown"].Choose(inList(sessionDB.getAllDrivers(this.SelectedSimulator), selectedDriver) + 1)

						driver := [selectedDriver]
					}
					else {
						window["driverDropDown"].Choose(1)

						driver := true
					}
				}
				else {
					if (window["driverDropDown"].Text = translate("All"))
						driver := true
					else
						driver := [sessionDB.getDriverID(this.SelectedSimulator, window["driverDropDown"].Text)]
				}

				lastSimulator := this.SelectedSimulator
				lastCar := this.SelectedCar
				lastTrack := this.SelectedTrack
				lastCommunity := this.UseCommunity

				if chosenCompound {
					tyreCompound := false
					tyreCompoundColor := false

					splitCompound(compounds[chosenCompound], &tyreCompound, &tyreCompoundColor)

					this.iTyreCompound := tyreCompound
					this.iTyreCompoundColor := tyreCompoundColor

					pressureInfos := SessionDatabaseEditor.EditorTyresDatabase().getPressures(this.SelectedSimulator, this.SelectedCar
																							, this.SelectedTrack, this.SelectedWeather
																							, convertUnit("Temperature", window["airTemperatureEdit"].Value, false)
																							, convertUnit("Temperature", window["trackTemperatureEdit"].Value, false)
																							, tyreCompound, tyreCompoundColor, driver)
				}
				else
					pressureInfos := []

				if (pressureInfos.Count == 0) {
					for ignore, tyre in ["fl", "fr", "rl", "rr"]
						for ignore, postfix in ["1", "2", "3", "4", "5"] {
							window[tyre . "Pressure" . postfix].Text := displayValue("Float", 0.0)
							window[tyre . "Pressure" . postfix].Opt("Background" . "D0D0D0")
							window[tyre . "Pressure" . postfix].Enabled := false
						}

					if this.RequestorPID
						window["transferPressuresButton"].Enabled := false
				}
				else {
					for tyre, pressureInfo in pressureInfos {
						pressure := pressureInfo["Pressure"]
						trackDelta := pressureInfo["Delta Track"]
						airDelta := pressureInfo["Delta Air"] + Round(trackDelta * 0.49)

						pressure -= 0.2

						if ((airDelta == 0) && (trackDelta == 0))
							color := "Green"
						else if (airDelta == 0)
							color := "Lime"
						else
							color := "Yellow"

						if (true || (color != lastColor))
							lastColor := color

						for index, postfix in ["1", "2", "3", "4", "5"] {
							window[tyre . "Pressure" . postfix].Text := displayValue("Float", convertUnit("Pressure", pressure))

							if (index = (3 + airDelta)) {
								window[tyre . "Pressure" . postfix].Opt("ReadOnly Background" . color . ((color = "Green") ? " cWhite" : " cBlack"))
								window[tyre . "Pressure" . postfix].Enabled := true
							}
							else {
								window[tyre . "Pressure" . postfix].Opt("Background" . "D0D0D0" . " cBlack")
								window[tyre . "Pressure" . postfix].Enabled := false
							}

							pressure += 0.1
						}

						if this.RequestorPID
							window["transferPressuresButton"].Enabled := true
					}
				}
			}
			catch Any as exception {
				logError(exception)
			}

			this.updateState()
		}
	}

	openPressuresEditor() {
		local window := this.Window
		local configuration

		window.Block()

		try {
			if PressuresEditor(this, this.iTyreCompound, this.iTyreCompoundColor
							 , Round(convertUnit("Temperature", window["airTemperatureEdit"].Value, false))
							 , Round(convertUnit("Temperature", window["trackTemperatureEdit"].Value, false))).editPressures()
				this.selectPressures()
		}
		finally {
			window.Unblock()
		}
	}

	selectSession(row, open := false) {
		local window := this.Window
		local name := this.SessionListView.GetText(row, 3)
		local type := ((this.SessionListView.GetText(row, 2) = translate("Solo")) ? "Solo" : "Team")
		local info := this.SessionDatabase.readSessionInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack
														 , type, this.SessionListView.GetText(row, 3))

		if (info && getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID)
			window["shareSessionWithTeamServerCheck"].Value := getMultiMapValue(info, "Access", "Synchronize", false)
		else
			window["shareSessionWithTeamServerCheck"].Value := 0

		this.updateState()

		if open
			Run("`"" . kBinariesDirectory . type . " Center.exe`" -Load `""
			  . this.SessionDatabase.getSessionDirectory(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, type)
			  . name . "." . StrLower(type), kBinariesDirectory)
	}

	selectTelemetry(row, open := false) {
		local window := this.Window
		local name := this.TelemetryListView.GetText(row, 2)
		local info := this.SessionDatabase.readTelemetryInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, name)
		local viewer, telemetryData, size

		if (info && getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID) {
			window["shareTelemetryWithCommunityCheck"].Value := getMultiMapValue(info, "Access", "Share", false)
			window["shareTelemetryWithTeamServerCheck"].Value := getMultiMapValue(info, "Access", "Synchronize", false)
		}
		else {
			window["shareTelemetryWithCommunityCheck"].Value := 0
			window["shareTelemetryWithTeamServerCheck"].Value := 0
		}

		this.updateState()

		if open {
			telemetryData := this.SessionDatabase.readTelemetry(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, name, &size)

			DirCreate(kTempDirectory . "Telemetry")

			deleteDirectory(kTempDirectory . "Telemetry", false, false)

			DirCreate(kTempDirectory . "Telemetry\Import")

			fileName := (kTempDirectory . "Telemetry\Import\" . name . ".telemetry")

			file := FileOpen(fileName, "w", "")

			if file {
				file.RawWrite(telemetryData, size)

				file.Close()
			}

			viewer := TelemetryViewer(SessionDatabaseEditor.TelemetryManager(this), kTempDirectory . "Telemetry", false)

			viewer.loadLap(fileName, this.TelemetryListView.GetText(row, 1))

			viewer.show()
		}
	}

	selectStrategy(row, open := false) {
		local window := this.Window
		local name := this.StrategyListView.GetText(row, 2)
		local info := this.SessionDatabase.readStrategyInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, name)
		local fileName

		if (info && getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID) {
			window["shareStrategyWithCommunityCheck"].Value := getMultiMapValue(info, "Access", "Share", false)
			window["shareStrategyWithTeamServerCheck"].Value := getMultiMapValue(info, "Access", "Synchronize", false)
		}
		else {
			window["shareStrategyWithCommunityCheck"].Value := 0
			window["shareStrategyWithTeamServerCheck"].Value := 0
		}

		this.updateState()

		if open {
			fileName := temporaryFileName("Race", "strategy")

			writeMultiMap(fileName, this.SessionDatabase.readStrategy(this.SelectedSimulator, this.SelectedCar
																	, this.SelectedTrack, name))

			Run("`"" . kBinariesDirectory . "Strategy Workbench.exe`" -Simulator `"" . this.SelectedSimulator . "`""
																  . " -Car `"" . this.SelectedCar . "`""
																  . " -Track `"" . this.SelectedTrack . "`""
																  . " -Load `"" . fileName . "`"", kBinariesDirectory)
		}
	}

	selectSetup(row) {
		local window := this.Window
		local name, info

		name := this.SetupListView.GetText(row, 2)

		info := this.SessionDatabase.readSetupInfo(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack
												 , kSetupTypes[window["setupTypeDropDown"].Value], name)

		if (info && getMultiMapValue(info, "Origin", "Driver", false) = this.SessionDatabase.ID) {
			window["shareSetupWithCommunityCheck"].Value := getMultiMapValue(info, "Access", "Share", false)
			window["shareSetupWithTeamServerCheck"].Value := getMultiMapValue(info, "Access", "Synchronize", false)
		}
		else {
			window["shareSetupWithCommunityCheck"].Value := 0
			window["shareSetupWithTeamServerCheck"].Value := 0
		}

		this.updateState()
	}

	deleteSession(category, sessionName) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected session?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes") {
			this.SessionDatabase.removeSession(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack
											 , category, sessionName)

			this.loadSessions()
		}
	}

	renameSession(category, sessionName) {
		local window := this.Window
		local result, newName, curExtension, curName

		window.Opt("+OwnDialogs")

		curName := sessionName

		result := withBlockedWindows(InputBox, translate("Please enter the new name for the selected session:"), translate("Rename"), "w300 h200", curName)

		if (result.Result = "Ok") {
			newName := result.Value

			this.SessionDatabase.renameSession(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack
											 , category, sessionName, newName)

			this.loadSessions(newName)
		}
	}

	uploadTelemetry() {
		local window := this.Window
		local fileName, telemetry, file, size, info, driver, name, ignore

		window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, "M1", "", translate("Upload Telemetry File..."), "Lap Telemetry (*.telemetry; *.JSON; *.CSV)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if ((fileName != "") || (isObject(fileName) && (fileName.Length > 0))) {
			for ignore, fileName in isObject(fileName) ? fileName : [fileName] {
				SplitPath(fileName, , , , &name)

				fileName := this.SessionDatabase.importTelemetry(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack
															   , fileName, &info)

				if (fileName && (fileName != "")) {
					file := FileOpen(fileName, "r-wd")

					if file {
						size := file.Length

						telemetry := Buffer(size)

						file.RawRead(telemetry, size)

						file.Close()

						if info
							driver := this.SessionDatabase.getDriverID(this.SelectedSimulator
																	 , getMultiMapValue(readMultiMap(info), "Info", "Driver"
																					  , this.SessionDatabase.getUserName()))
						else
							driver := this.SessionDatabase.ID

						this.SessionDatabase.writeTelemetry(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, name, telemetry, size, false, true, driver)
					}
				}
			}

			if isObject(fileName)
				if (fileName.Length = 1)
					SplitPath(fileName[1], &fileName)
				else
					fileName := false

			if fileName
				SplitPath(fileName, , , , &fileName)

			this.loadTelemetries(fileName)
		}
	}

	downloadTelemetry(telemetryName) {
		local window := this.Window
		local fileName, telemetryData, file, size

		window.Opt("+OwnDialogs")

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := withBlockedWindows(FileSelect, "S16", telemetryName, translate("Download Telemetry File..."), "Lap Telemetry (*.telemetry)")
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			if !InStr(fileName, ".telemetry")
				fileName .= ".telemetry"

			size := false

			telemetryData := this.SessionDatabase.readTelemetry(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, telemetryName, &size)

			deleteFile(fileName)

			file := FileOpen(fileName, "w", "")

			if file {
				file.RawWrite(telemetryData, size)

				file.Close()
			}
		}
	}

	deleteTelemetry(telemetryName) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected lap telemetry?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes") {
			this.SessionDatabase.removeTelemetry(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, telemetryName)

			this.loadTelemetries()
		}
	}

	renameTelemetry(telemetryName) {
		local window := this.Window
		local result, newName, curExtension, curName

		window.Opt("+OwnDialogs")

		SplitPath(telemetryName, , , &curExtension, &curName)

		result := withBlockedWindows(InputBox, translate("Please enter the new name for the selected lap telemetry:"), translate("Rename"), "w300 h200", curName)

		if (result.Result = "Ok") {
			newName := result.Value

			if (StrLen(curExtension) > 0)
				newName .= ("." . curExtension)

			this.SessionDatabase.renameTelemetry(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, telemetryName, newName)

			this.loadTelemetries(newName)
		}
	}

	uploadStrategy() {
		local window := this.Window
		local fileName, strategy

		window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, "M1", "", translate("Upload Strategy File..."), "Strategy (*.strategy)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if ((fileName != "") || (isObject(fileName) && (fileName.Length > 0))) {
			for ignore, fileName in isObject(fileName) ? fileName : [fileName]
				if (fileName && (fileName != "")) {
					strategy := readMultiMap(fileName)

					SplitPath(fileName, &fileName)

					this.SessionDatabase.writeStrategy(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, fileName, strategy
													 , true, true, this.SessionDatabase.ID)
				}

			if isObject(fileName)
				if (fileName.Length = 1)
					SplitPath(fileName[1], &fileName)
				else
					fileName := false

			this.loadStrategies(fileName ? StrReplace(fileName, ".strategy", "") : false)
		}
	}

	downloadStrategy(strategyName) {
		local window := this.Window
		local fileName

		window.Opt("+OwnDialogs")

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := withBlockedWindows(FileSelect, "S16", strategyName, translate("Download Strategy File..."), "Strategy (*.strategy)")
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			if !InStr(fileName, ".strategy")
				fileName .= ".strategy"

			deleteFile(fileName)

			writeMultiMap(fileName, this.SessionDatabase.readStrategy(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, strategyName))
		}
	}

	deleteStrategy(strategyName) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected strategy?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes") {
			this.SessionDatabase.removeStrategy(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, strategyName)

			this.loadStrategies()
		}
	}

	renameStrategy(strategyName) {
		local window := this.Window
		local result, newName, curExtension, curName

		window.Opt("+OwnDialogs")

		SplitPath(strategyName, , , &curExtension, &curName)

		result := withBlockedWindows(InputBox, translate("Please enter the new name for the selected strategy:"), translate("Rename"), "w300 h200", curName)

		if (result.Result = "Ok") {
			newName := result.Value

			if (StrLen(curExtension) > 0)
				newName .= ("." . curExtension)

			this.SessionDatabase.renameStrategy(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, strategyName, newName)

			this.loadStrategies(newName)
		}
	}

	uploadSetup(setupType) {
		local window := this.Window
		local fileName, file, size, setup, ignore

		window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, "M1", "", translate("Upload Setup File..."))
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if ((fileName != "") || (isObject(fileName) && (fileName.Length > 0))) {
			for ignore, fileName in isObject(fileName) ? fileName : [fileName]
				if (fileName && (fileName != "")) {
					file := FileOpen(fileName, "r-wd")

					if file {
						size := file.Length

						setup := Buffer(size)

						file.RawRead(setup, size)

						file.Close()

						SplitPath(fileName, &fileName)

						this.SessionDatabase.writeSetup(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, setupType, fileName, setup, size
													  , false, true, this.SessionDatabase.ID)
					}
				}

			if isObject(fileName)
				if (fileName.Length = 1)
					SplitPath(fileName[1], &fileName)
				else
					fileName := false

			this.loadSetups(this.SelectedSetupType, true, fileName)
		}
	}

	downloadSetup(setupType, setupName) {
		local window := this.Window
		local fileName, setupData, file, size

		window.Opt("+OwnDialogs")

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := withBlockedWindows(FileSelect, "S16", setupName, translate("Download Setup File..."))
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			size := false

			setupData := this.SessionDatabase.readSetup(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, setupType, setupName, &size)

			deleteFile(fileName)

			file := FileOpen(fileName, "w", "")

			if file {
				file.RawWrite(setupData, size)

				file.Close()
			}
		}
	}

	deleteSetup(setupType, setupName) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected setup?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes") {
			this.SessionDatabase.removeSetup(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, setupType, setupName)

			this.loadSetups(this.SelectedSetupType, true)
		}
	}

	renameSetup(setupType, setupName) {
		local window := this.Window
		local result, newName, curExtension, curName

		window.Opt("+OwnDialogs")

		SplitPath(setupName, , , &curExtension, &curName)

		result := withBlockedWindows(InputBox, translate("Please enter the new name for the selected setup:"), translate("Rename"), "w300 h200", curName)

		if (result.Result = "Ok") {
			newName := result.Value

			if (StrLen(curExtension) > 0)
				newName .= ("." . curExtension)

			this.SessionDatabase.renameSetup(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack, setupType, setupName, newName)

			this.loadSetups(this.SelectedSetupType, true, newName)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

noSelect(listView, line, *) {
	if line
		listView.Modify(line, "-Select")
}

copyDirectory(source, destination, progressStep, &count) {
	local files := []
	local ignore, fileName, file, subDirectory

	DirCreate(destination)

	loop Files, source . "\*.*", "DF"
		files.Push(A_LoopFilePath)

	for ignore, fileName in files {
		SplitPath(fileName, &file)

		count += 1

		showProgress({progress: Round(50 + (count * progressStep)), message: translate("Copying ") . file . translate("...")})

		if InStr(FileExist(fileName), "D") {
			SplitPath(fileName, &subDirectory)

			copyDirectory(fileName, destination . "\" . subDirectory, progressStep, &count)
		}
		else
			FileCopy(fileName, destination, 1)
	}
}

copyFiles(source, destination) {
	local count := 0
	local progress := 0
	local step := 0

	source := normalizeDirectoryPath(source)
	destination := normalizeDirectoryPath(destination)

	showProgress({color: "Blue"})

	loop Files, source . "\*", "DFR" {

		if (Mod(count, 20) == 0)
			progress += 1

		showProgress({progress: Min(progress, 50), message: translate("Validating ") . A_LoopFileName . translate("...")})

		Sleep(1)

		count += 1
	}

	showProgress({progress: 50, color: "Green"})

	copyDirectory(source, destination, 50 / count, &step)
}

actionDialog(xOrCommand := false, y := false, action := false, *) {
	global gActionInfoEnabled

	local fileName, chosen, x

	static result := false

	static actionTypeDropDown
	static actionLabel
	static actionEdit
	static commandChooserButton

	static actionDialogGui

	toggleTriggerDetector(*) {
		protectionOn()

		try {
			triggerDetector(false, ["Key", "Multi"])
		}
		finally {
			protectionOff()
		}
	}

	if (xOrCommand == kOk)
		result := kOk
	else if (xOrCommand == kCancel)
		result := kCancel
	else if (xOrCommand = "Type") {
		actionEdit.Value := ""

		actionDialog("Update")
	}
	else if (xOrCommand = "Update") {
		actionLabel.Text := translate(["Hotkey(s)", "Command", "Speech", "Audio"][actionTypeDropDown.Value])

		commandChooserButton.Enabled := ((actionTypeDropDown.Value = 2) || (actionTypeDropDown.Value = 4))
	}
	else if (xOrCommand = "File") {
		actionDialogGui.Opt("+OwnDialogs")

		OnMessage(0x44, translateSelectCancelButtons)
		if (actionTypeDropDown.Value = 2)
			fileName := withBlockedWindows(FileSelect, 1, actionEdit.Text, translate("Select executable file..."), "Script (*.*)")
		else
			fileName := withBlockedWindows(FileSelect, 1, actionEdit.Text, translate("Select Sound File..."), "Audio (*.*)")
		OnMessage(0x44, translateSelectCancelButtons, 0)

		if fileName
			actionEdit.Text := fileName
	}
	else {
		result := false

		actionDialogGui := Window({Options: "0x400000"}, translate("Action"))

		actionDialogGui.SetFont("Norm", "Arial")

		actionDialogGui.Add("Text", "x16 y16 w70 h23 +0x200", translate("Action"))

		if action {
			chosen := inList(["Hotkey", "Command", "Speech", "Audio"], action.Type)

			actionEdit := action.Action
		}
		else {
			chosen := 1

			actionEdit := ""
		}

		actionTypeDropDown := actionDialogGui.Add("DropDownList", "x90 yp+1 w180 Choose" . chosen, collect(["Hotkey(s)", "Command", "Speech", "Audio"], translate))
		actionTypeDropDown.OnEvent("Change", actionDialog.Bind("Type"))

		actionLabel := actionDialogGui.Add("Text", "x16 yp+23 w70 h23 +0x200", translate("Hotkey(s)"))
		actionEdit := actionDialogGui.Add("Edit", "x90 yp+1 w155 h21", actionEdit)
		commandChooserButton := actionDialogGui.Add("Button", "x247 yp w23 h23", translate("..."))
		commandChooserButton.OnEvent("Click", actionDialog.Bind("File"))

		actionDialogGui.Add("Button", "x16 yp+35 w80 h23 Y:Move", translate("Trigger...")).OnEvent("Click", toggleTriggerDetector)
		actionDialogGui.Add("Button", "x104 yp w80 h23 Default", translate("Ok")).OnEvent("Click", actionDialog.Bind(kOk))
		actionDialogGui.Add("Button", "x190 yp w80 h23", translate("&Cancel")).OnEvent("Click", actionDialog.Bind(kCancel))

		x := (xOrCommand - 150)
		y := (y - 35)

		actionDialog("Update")

		actionDialogGui.Opt("+Owner" . SessionDatabaseEditor.Instance.Window.Hwnd)

		actionDialogGui.Show("x" . x . " y" . y . " AutoSize")

		gActionInfoEnabled := false

		ToolTip()

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				if action
					action := action.Clone()
				else
					action := Object()

				action.Type := ["Hotkey", "Command", "Speech", "Audio"][actionTypeDropDown.Value]
				action.Action := actionEdit.Text

				return action
			}
		}
		finally {
			actionDialogGui.Destroy()

			gActionInfoEnabled := true
		}
	}
}

selectImportSettings(sessionDatabaseEditorOrCommand, directory := false, owner := false, *) {
	local x, y, w, h, editor, simulator, code, info, progressWindow, section, key, values, value, type
	local settings, row, selection, car, track, weather

	static importSettingsGui
	static importSelectCheck
	static importListView := false
	static result := false

	selectAllImportEntries(*) {
		if (importSelectCheck.Value == -1) {
			importSelectCheck.Value := 0

			importSelectCheck.Value := 0
		}

		loop importListView.GetCount()
			importListView.Modify(A_Index, importSelectCheck.Value ? "Check" : "-Check")
	}

	selectImportEntry(*) {
		local selected := 0
		local row := 0

		loop {
			row := importListView.GetNext(row, "C")

			if row
				selected += 1
			else
				break
		}

		if (selected == 0)
			importSelectCheck.Value := 0
		else if (selected < importListView.GetCount())
			importSelectCheck.Value := -1
		else
			importSelectCheck.Value := 1
	}

	if (sessionDatabaseEditorOrCommand = kCancel)
		result := kCancel
	else if (sessionDatabaseEditorOrCommand = kOk)
		result := kOk
	else {
		result := false

		importSettingsGui := Window({Descriptor: "Session Database.ImportSettings"
								  , Resizeable: true, Options: "-MaximizeBox -MinimizeBox"}
								  , translate("Import"))

		importSettingsGui.SetFont("s10 Bold", "Arial")

		importSettingsGui.Add("Text", "w394 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(importSettingsGui, "Session Database.ImportSettings"))

		importSettingsGui.SetFont("s9 Norm", "Arial")

		importSettingsGui.Add("Documentation", "x153 YP+20 w104 H:Center Center", translate("Import")
							, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database")

		importSettingsGui.SetFont("s8 Norm", "Arial")

		importSettingsGui.Add("Text", "x8 yp+30 w410 X:Move(0.2) W:Grow(0.8) 0x10")

		importSelectCheck := importSettingsGui.Add("CheckBox", "Check3 x16 yp+12 w15 h21 vimportSelectCheck")
		importSelectCheck.OnEvent("Click", selectAllImportEntries)

		importListView := importSettingsGui.Add("ListView", "x34 yp-2 w375 h400 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 Checked AltSubmit", collect(["Car", "Track", "Weather", "Setting", "Value"], translate))
		importListView.OnEvent("Click", noSelect)
		importListView.OnEvent("DoubleClick", noSelect)
		importListView.OnEvent("ItemCheck", selectImportEntry)

		directory := normalizeDirectoryPath(directory)
		editor := sessionDatabaseEditorOrCommand

		simulator := editor.SelectedSimulator
		code := editor.SessionDatabase.getSimulatorCode(simulator)

		settings := []

		info := readMultiMap(directory . "\Export.info")

		if (getMultiMapValue(info, "General", "Simulator") = simulator) {
			progressWindow := showProgress({color: "Green", title: translate("Analyzing Data")})

			if owner
				progressWindow.Opt("+Owner" . owner.Hwnd)

			try {
				for section, values in readMultiMap(directory . "\Export.settings") {
					section := string2Values(" | ", section)

					car := section[2]
					track := section[3]
					weather := section[4]
					section := section[1]

					showProgress({Progress: Min(A_Index, 100)})

					for key, value in values {
						settings.Push(Array(car, track, weather, section, key, value))

						type := editor.getSettingType(section, key, &default)

						if isObject(type)
							value := translate(value)
						else if (type = "Boolean")
							value := (value ? translate("x") : "")
						else if (type = "Text")
							value := StrReplace(StrReplace(value, "`n", A_Space), "`r", "")
						else
							value := displayValue("Float", value)

						importListView.Add("Check", (car = "*") ? translate("All") : editor.getCarName(simulator, car)
												  , (track = "*") ? translate("All") : editor.getTrackName(simulator, track)
												  , (weather = "*") ? translate("All") : weather
												  , editor.getSettingLabel(section, key), value)
					}
				}
			}
			finally {
				hideProgress()
			}
		}

		importSelectCheck.Value := ((importListView.GetCount() > 0) ? 1 : 0)

		importListView.ModifyCol()

		loop 5
			importListView.ModifyCol(A_Index, 10)

		loop 5
			importListView.ModifyCol(A_Index, "AutoHdr")

		importSettingsGui.SetFont("s8 Norm", "Arial")

		importSettingsGui.Add("Text", "x8 yp+410 w410 X:Move(0.2) W:Grow(0.8) Y:Move 0x10")

		importSettingsGui.Add("Button", "x123 yp+10 w80 h23 Y:Move X:Move(0.5) Default", translate("Ok")).OnEvent("Click", selectImportSettings.Bind(kOk))
		importSettingsGui.Add("Button", "x226 yp w80 h23 Y:Move X:Move(0.5)", translate("&Cancel")).OnEvent("Click", selectImportSettings.Bind(kCancel))

		if owner
			importSettingsGui.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Session Database.ImportSettings", &x, &y)
			importSettingsGui.Show("x" . x . " y" . y)
		else
			importSettingsGui.Show()

		if getWindowSize("Session Database.ImportSettings", &w, &h)
			importSettingsGui.Resize("Initialize", w, h)

		loop
			Sleep(100)
		until result

		if (result = kOk) {
			row := 0

			selection := []

			while (row := importListView.GetNext(row, "C"))
				selection.Push(settings[row])

			result := selection
		}
		else
			result := false

		importSettingsGui.Destroy()

		return result
	}
}

selectImportData(sessionDatabaseEditorOrCommand, directory := false, owner := false, *) {
	local x, y, w, h, editor, simulator, code, info, drivers, id, name, progressWindow, tracks, progress
	local car, carName, track, trackName, sourceDirectory, found, telemetryDB, tyresDB, driver, driverName, rows
	local strategies, telemetries, setups, automations, row, selection, data, type, number, key, sessions, extension

	static importDataGui
	static importSelectCheck
	static importListView := false
	static result := false

	selectAllImportEntries(*) {
		if (importSelectCheck.Value == -1) {
			importSelectCheck.Value := 0

			importSelectCheck.Value := 0
		}

		loop importListView.GetCount()
			importListView.Modify(A_Index, importSelectCheck.Value ? "Check" : "-Check")
	}

	selectImportEntry(*) {
		local selected := 0
		local row := 0

		loop {
			row := importListView.GetNext(row, "C")

			if row
				selected += 1
			else
				break
		}

		if (selected == 0)
			importSelectCheck.Value := 0
		else if (selected < importListView.GetCount())
			importSelectCheck.Value := -1
		else
			importSelectCheck.Value := 1
	}

	if (sessionDatabaseEditorOrCommand = kCancel)
		result := kCancel
	else if (sessionDatabaseEditorOrCommand = kOk)
		result := kOk
	else {
		result := false

		importDataGui := Window({Descriptor: "Session Database.ImportData"
							  , Resizeable: true, Options: "-MaximizeBox -MinimizeBox"}
							  , translate("Import"))

		importDataGui.SetFont("s10 Bold", "Arial")

		importDataGui.Add("Text", "w394 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(importDataGui, "Session Database.ImportData"))

		importDataGui.SetFont("s9 Norm", "Arial")

		importDataGui.Add("Documentation", "x153 YP+20 w104 H:Center Center", translate("Import")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database")

		importDataGui.SetFont("s8 Norm", "Arial")

		importDataGui.Add("Text", "x8 yp+30 w410 X:Move(0.2) W:Grow(0.8) 0x10")

		importSelectCheck := importDataGui.Add("CheckBox", "Check3 x16 yp+12 w15 h21 vimportSelectCheck")
		importSelectCheck.OnEvent("Click", selectAllImportEntries)

		importListView := importDataGui.Add("ListView", "x34 yp-2 w375 h400 H:Grow X:Move(0.2) W:Grow(0.8) -Multi -LV0x10 Checked AltSubmit", collect(["Type", "Car / Track", "Driver", "#"], translate))
		importListView.OnEvent("Click", noSelect)
		importListView.OnEvent("DoubleClick", noSelect)
		importListView.OnEvent("ItemCheck", selectImportEntry)

		directory := normalizeDirectoryPath(directory)
		editor := sessionDatabaseEditorOrCommand

		simulator := editor.SelectedSimulator
		code := editor.SessionDatabase.getSimulatorCode(simulator)

		info := readMultiMap(directory . "\Export.info")

		drivers := CaseInsenseMap()

		drivers["-"] := false

		for id, name in getMultiMapValues(info, "Driver") {
			drivers[id] := name
			drivers[name] := id
		}

		progressWindow := showProgress({color: "Green", title: translate("Analyzing Data")})

		if owner
			progressWindow.Opt("+Owner" . owner.Hwnd)

		try {
			tracks := []

			loop Files, directory . "\.Tracks\*.*", "F" {
				SplitPath(A_LoopFileName, , , , &track)

				if !inList(tracks, track) {
					importListView.Add("Check", translate("Tracks"), editor.getTrackName(simulator, track), "-", 1)

					tracks.Push(track)
				}
			}

			progress := 0

			loop Files, directory . "\*.*", "D" {
				car := A_LoopFileName
				carName := editor.getCarName(simulator, car)

				loop Files, directory . "\" . car . "\*.*", "D" {
					track := A_LoopFileName
					trackName := editor.getTrackName(simulator, track)

					showProgress({progress: ++progress, message: translate("Car: ") . carName . translate(", Track: ") . trackName})

					if (progress >= 100)
						progress := 0

					sourceDirectory := (A_LoopFileDir . "\" . track)

					found := false

					telemetryDB := TelemetryDatabase()

					telemetryDB.setDatabase(Database(sourceDirectory . "\", kTelemetrySchemas))

					for driver, driverName in drivers {
						number := (telemetryDB.getElectronicsCount(driver) + telemetryDB.getTyresCount(driver))

						if (number > 0)
							importListView.Add("Check", translate("Telemetry"), (carName . " / " . trackName), driverName, number)
					}

					tyresDB := Database(sourceDirectory . "\", kTyresSchemas)

					for driver, driverName in drivers {
						rows := tyresDB.query("Tyres.Pressures", {Group: [["Driver", count, "Count"]]
																, Where: {Driver: driver}})

						number := ((rows.Length > 0) ? rows[1]["Count"] : 0)

						rows := tyresDB.query("Tyres.Pressures.Distribution", {Group: [["Driver", count, "Count"]]
																			 , Where: {Driver: driver}})

						number += ((rows.Length > 0) ? rows[1]["Count"] : 0)

						if (number > 0)
							importListView.Add("Check", translate("Pressures"), (carName . " / " . trackName), driverName, number)
					}

					sessions := CaseInsenseMap()

					loop Files, sourceDirectory . "\Team Sessions\*.team", "F" {
						driver := getMultiMapValue(readMultiMap(A_LoopFileFullPath), "Creator", "ID")

						if sessions.Has(driver)
							sessions[driver] += 1
						else
							sessions[driver] := 1
					}

					loop Files, sourceDirectory . "\Solo Sessions\*.solo", "F" {
						driver := getMultiMapValue(readMultiMap(A_LoopFileFullPath), "Creator", "ID")

						if sessions.Has(driver)
							sessions[driver] += 1
						else
							sessions[driver] := 1
					}

					for driver, number in sessions
						importListView.Add("Check", translate("Sessions"), (carName . " / " . trackName), SessionDatabase.getDriverName(simulator, driver), number)

					telemetries := 0

					loop Files, sourceDirectory . "\Lap Telemetries\*.telemetry", "F"
						telemetries += 1

					if (telemetries > 0)
						importListView.Add("Check", translate("Laps"), (carName . " / " . trackName), "-", telemetries)

					strategies := 0

					loop Files, sourceDirectory . "\Race Strategies\*.strategy", "F"		; Strategies
						strategies += 1

					if (strategies > 0)
						importListView.Add("Check", translate("Strategies"), (carName . " / " . trackName), "-", strategies)

					setups := 0

					for ignore, type in kSetupTypes
						loop Files, sourceDirectory . "\Car Setups\" . type . "\*.*", "F" {		; Setups
							SplitPath(A_LoopFileName, , , &extension)

							if (extension != "info")
								setups += 1
						}

					if (setups > 0)
						importListView.Add("Check", translate("Setups"), (carName . " / " . trackName), "-", setups)

					if FileExist(sourceDirectory . "\Track.automations") {
						automations := editor.SessionDatabase.loadTrackAutomations(sourceDirectory . "\Track.automations").Length

						if (automations > 0)
							importListView.Add("Check", translate("Automations"), (carName . " / " . trackName), "-", automations)
					}
				}
			}
		}
		finally {
			hideProgress()
		}

		importSelectCheck.Value := ((importListView.GetCount() > 0) ? 1 : 0)

		importListView.ModifyCol()

		loop 4
			importListView.ModifyCol(A_Index, 10)

		loop 4
			importListView.ModifyCol(A_Index, "AutoHdr")

		importDataGui.SetFont("s8 Norm", "Arial")

		importDataGui.Add("Text", "x8 yp+410 w410 X:Move(0.2) W:Grow(0.8) Y:Move 0x10")

		importDataGui.Add("Button", "x123 yp+10 w80 h23 Y:Move X:Move(0.5) Default", translate("Ok")).OnEvent("Click", selectImportData.Bind(kOk))
		importDataGui.Add("Button", "x226 yp w80 h23 Y:Move X:Move(0.5)", translate("&Cancel")).OnEvent("Click", selectImportData.Bind(kCancel))

		if owner
			importDataGui.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Session Database.ImportData", &x, &y)
			importDataGui.Show("x" . x . " y" . y)
		else
			importDataGui.Show()

		if getWindowSize("Session Database.ImportData", &w, &h)
			importDataGui.Resize("Initialize", w, h)

		loop
			Sleep(100)
		until result

		if (result = kOk) {
			row := 0

			selection := CaseInsenseMap()

			while (row := importListView.GetNext(row, "C")) {
				type := importListView.GetText(row, 1)
				data := importListView.GetText(row, 2)

				if InStr(data, " / ") {
					data := string2Values(" / ", data)

					car := data[1]
					track := data[2]
				}
				else if (type = translate("Tracks")) {
					car := "-"
					track := data
				}
				else {
					car := "-"
					track := "-"
				}

				driver := importListView.GetText(row, 3)

				switch type, false {
					case translate("Tracks"):
						type := "Tracks"
					case translate("Telemetry"):
						type := "Telemetry"
					case translate("Pressures"):
						type := "Pressures"
					case translate("Strategies"):
						type := "Strategies"
					case translate("Laps"):
						type := "Telemetries"
					case translate("Sessions"):
						type := "Sessions"
					case translate("Setups"):
						type := "Setups"
				}

				if ((car = "-") && (track = "-"))
					key := ("-.-." . type)
				else if (car = "-")
					key := ("-." . editor.getTrackCode(simulator, track) . "." . type)
				else
					key := (editor.getCarCode(simulator, car) . "." . editor.getTrackCode(simulator, track) . "." . type)

				if selection.Has(key)
					selection[key].Push(drivers[driver])
				else
					selection[key] := [drivers[driver]]
			}

			result := selection
		}
		else
			result := false

		importDataGui.Destroy()

		return result
	}
}

editSettings(editorOrCommand, arguments*) {
	local x, y, done, configuration, dllFile, connector, connection
	local directory, empty, original, changed, restart, groups, replication
	local oldConnections, ignore, group, enabled, values
	local identifier, serverURL, serverToken, serverURLs, serverTokens
	local availableServerURLs, settings, chosen, translator, msgResult

	static result := false
	static sessionDB := false

	static connections := []
	static currentConnection := 0

	static settingsEditorGui

	static addConnectionButton
	static deleteConnectionButton
	static nextConnectionButton
	static previousConnectionButton

	static databaseLocationEdit := ""
	static synchTelemetryCheck
	static synchPressuresCheck
	static synchSessionsCheck
	static synchSetupsCheck
	static synchStrategiesCheck
	static synchTelemetriesCheck
	static serverIdentifierEdit := ""
	static serverURLEdit := ""
	static serverTokenEdit := ""
	static serverUpdateEdit := 0
	static validateTokenButton
	static rebuildButton

	rebuildDatabase(*) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to rebuild the local database?"), translate("Team Server"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			editSettings("Rebuild")
	}

	if (editorOrCommand == kOk) {
		if currentConnection
			editSettings("SaveConnection")

		serverURLs := CaseInsenseMap()
		serverTokens := CaseInsenseMap()
		groups := CaseInsenseMap()

		for ignore, connection in connections {
			serverURLs[connection[1]] := connection[2]
			serverTokens[connection[1]] := connection[3]
			groups[connection[1]] := values2String(",", connection[4]*)
		}

		if ((groups.Count != connections.Length) || (serverURLs.Count != connections.Length) || (serverTokens.Count != connections.Length)) {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
		else
			result := kOk
	}
	else if (editorOrCommand == kCancel)
		result := kCancel
	else if (editorOrCommand == "AddConnection") {
		editSettings("SaveConnection")

		connections.Push([translate("Standard"), "https://localhost:5001", "", ["Telemetry"]])

		editSettings("LoadConnection", connections.Length)
	}
	else if (editorOrCommand == "DeleteConnection") {
		connections.RemoveAt(currentConnection)

		if (connections.Length > 0)
			editSettings("LoadConnection", 1)
		else {
			currentConnection := false

			editSettings("UpdateState")
		}
	}
	else if (editorOrCommand == "NextConnection") {
		editSettings("SaveConnection")

		currentConnection += 1

		editSettings("LoadConnection", currentConnection)
	}
	else if (editorOrCommand == "PreviousConnection") {
		editSettings("SaveConnection")

		currentConnection -= 1

		editSettings("LoadConnection", currentConnection)
	}
	else if (editorOrCommand == "LoadConnection") {
		currentConnection := arguments[1]

		serverIdentifierEdit.Text := connections[currentConnection][1]

		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		availableServerURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

		if (!inList(availableServerURLs, connections[currentConnection][2]) && StrLen(connections[currentConnection][2]) > 0)
			availableServerURLs.Push(connections[currentConnection][2])

		chosen := inList(availableServerURLs, connections[currentConnection][2])
		if (!chosen && (availableServerURLs.Length > 0))
			chosen := 1

		serverURLEdit.Delete()
		serverURLEdit.Add(availableServerURLs)
		serverURLEdit.Choose(chosen)
		serverTokenEdit.Text := connections[currentConnection][3]

		groups := connections[currentConnection][4]

		synchTelemetryCheck.Value := (inList(groups, "Telemetry") != false)
		synchPressuresCheck.Value := (inList(groups, "Pressures") != false)
		synchSessionsCheck.Value := (inList(groups, "Sessions") != false)
		synchSetupsCheck.Value := (inList(groups, "Setups") != false)
		synchStrategiesCheck.Value := (inList(groups, "Strategies") != false)
		synchTelemetriesCheck.Value := (inList(groups, "Laps") != false)

		editSettings("UpdateState")
	}
	else if (editorOrCommand == "SaveConnection") {
		if currentConnection {
			connections[currentConnection][1] := serverIdentifierEdit.Text
			connections[currentConnection][2] := serverURLEdit.Text
			connections[currentConnection][3] := serverTokenEdit.Text

			groups := []

			for group, enabled in Map("Telemetry", synchTelemetryCheck.Value, "Pressures", synchPressuresCheck.Value
									, "Sessions", synchSessionsCheck.Value
									, "Setups", synchSetupsCheck.Value, "Strategies", synchStrategiesCheck.Value
									, "Laps", synchTelemetriesCheck.Value)
				if enabled
					groups.Push(group)

			connections[currentConnection][4] := groups
		}
	}
	else if (editorOrCommand = "Rebuild") {
		configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

		setMultiMapValue(configuration, "Team Server", "Synchronization", mapToString("|", "->", CaseInsenseMap()))

		writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)
	}
	else if (editorOrCommand = "DatabaseLocation") {
		settingsEditorGui.Opt("+OwnDialogs")

		OnMessage(0x44, translateSelectCancelButtons)
		directory := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Select Session Database folder..."))
		OnMessage(0x44, translateSelectCancelButtons, 0)

		if (directory != "")
			databaseLocationEdit.Text := directory
	}
	else if (editorOrCommand = "ValidateToken") {
		dllFile := (kBinariesDirectory . "Connectors\Data Store Connector.dll")

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Data Store Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Data Store Connector.dll in " . kBinariesDirectory . "..."
			}

			connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.DataConnector")
		}
		catch Any as exception {
			logMessage(kLogCritical, translate("Error while initializing Data Store Connector - please rebuild the applications"))

			showMessage(translate("Error while initializing Data Store Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return
		}

		if GetKeyState("Ctrl") {
			settingsEditorGui.Block()

			try {
				token := loginDialog(connector, serverURLEdit.Text, settingsEditorGui)

				if token
					serverTokenEdit.Text := token
				else
					return
			}
			finally {
				settingsEditorGui.Unblock()
			}
		}

		serverURL := serverURLEdit.Text

		try {
			connector.Initialize(serverURL, serverTokenEdit.Text)

			connection := connector.Connect(serverTokenEdit.Text, sessionDB.ID, sessionDB.getUserName())

			if (connection && (connection != "")) {
				connector.ValidateDataToken()

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				availableServerURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

				if !inList(availableServerURLs, serverURL) {
					availableServerURLs.Push(serverURL)

					setMultiMapValue(settings, "Team Server", "Server URLs", values2String(";", availableServerURLs*))

					writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

					serverURLEdit.Delete()
					serverURLEdit.Add(availableServerURLs)
					serverURLEdit.Choose(inList(availableServerURLs, serverURL))
				}

				showMessage(translate("Successfully connected to the Team Server."))
			}
		}
		catch Any as exception {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
	}
	else if (editorOrCommand = "UpdateState") {
		addConnectionButton.Enabled := true

		if (connections.Length > 0) {
			deleteConnectionButton.Enabled := true
			synchTelemetryCheck.Enabled := true
			synchPressuresCheck.Enabled := true
			synchSessionsCheck.Enabled := true
			synchSetupsCheck.Enabled := true
			synchStrategiesCheck.Enabled := true
			synchTelemetriesCheck.Enabled := true
		}
		else {
			deleteConnectionButton.Enabled := false
			synchTelemetryCheck.Enabled := false
			synchPressuresCheck.Enabled := false
			synchSessionsCheck.Enabled := false
			synchSetupsCheck.Enabled := false
			synchStrategiesCheck.Enabled := false
			synchTelemetriesCheck.Enabled := false

			synchTelemetryCheck.Value := 0
			synchPressuresCheck.Value := 0
			synchSessionsCheck.Value := 0
			synchSetupsCheck.Value := 0
			synchStrategiesCheck.Value := 0
			synchTelemetriesCheck.Value := 0
		}

		if (connections.Length > 1) {
			if (currentConnection = 1)
				previousConnectionButton.Enabled := false
			else
				previousConnectionButton.Enabled := true

			if (currentConnection = connections.Length)
				nextConnectionButton.Enabled := false
			else
				nextConnectionButton.Enabled := true
		}
		else {
			nextConnectionButton.Enabled := false
			previousConnectionButton.Enabled := false
		}

		if ((connections.Length > 0) && !synchTelemetryCheck && !synchPressuresCheck
									 && !synchSessionsCheck && !synchSetupsCheck && !synchStrategiesCheck
									 && !synchTelemetriesCheck) {
			synchTelemetryCheck := true

			synchTelemetryCheck.Value := 1
		}

		if (synchTelemetryCheck.Value || synchPressuresCheck.Value
		 || synchSessionsCheck.Value || synchSetupsCheck.Value || synchStrategiesCheck.Value
		 || synchTelemetriesCheck.Value) {
			serverIdentifierEdit.Enabled := true
			serverURLEdit.Enabled := true
			serverTokenEdit.Enabled := true
			serverUpdateEdit.Enabled := true
			validateTokenButton.Enabled := true
			rebuildButton.Enabled := true

			if (serverUpdateEdit.Text = "")
				serverUpdateEdit.Value := 10
		}
		else {
			serverIdentifierEdit.Enabled := false
			serverURLEdit.Enabled := false
			serverTokenEdit.Enabled := false
			serverUpdateEdit.Enabled := false
			validateTokenButton.Enabled := false
			rebuildButton.Enabled := false

			serverIdentifierEdit.Text := ""
			serverURLEdit.Choose(0)
			serverTokenEdit.Text := ""
			serverUpdateEdit.Text := ""
		}
	}
	else {
		connections := []
		result := false
		sessionDB := editorOrCommand.SessionDatabase

		for identifier, serverURL in sessionDB.ServerURLs
			connections.Push([identifier, serverURL, sessionDB.ServerToken[identifier], sessionDB.Groups[identifier]])

		currentConnection := ((connections.Length = 0) ? 0 : 1)

		configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

		databaseLocationEdit := normalizeDirectoryPath(getMultiMapValue(configuration, "Database", "Path", kDatabaseDirectory))

		replication := getMultiMapValue(configuration, "Team Server", "Replication", false)

		if currentConnection
			groups := connections[currentConnection][4]
		else
			groups := []

		if (groups.Length > 0) {
			synchTelemetryCheck := (inList(groups, "Telemetry") != false)
			synchPressuresCheck := (inList(groups, "Pressures") != false)
			synchSessionsCheck := (inList(groups, "Sessions") != false)
			synchSetupsCheck := (inList(groups, "Setups") != false)
			synchStrategiesCheck := (inList(groups, "Strategies") != false)
			synchTelemetriesCheck := (inList(groups, "Laps") != false)
		}
		else {
			synchTelemetryCheck := (replication != false)
			synchPressuresCheck := (replication != false)
			synchSessionsCheck := (replication != false)
			synchSetupsCheck := (replication != false)
			synchStrategiesCheck := (replication != false)
			synchTelemetriesCheck := (replication != false)
		}

		if (synchTelemetryCheck || synchPressuresCheck || synchSessionsCheck
		 || synchSetupsCheck || synchStrategiesCheck || synchTelemetriesCheck) {
			if currentConnection {
				serverIdentifierEdit := connections[currentConnection][1]
				serverURLEdit := connections[currentConnection][2]
				serverTokenEdit := connections[currentConnection][3]
			}
			else {
				serverIdentifierEdit := "Standard"

				serverURLEdit := stringToMap("|", "->", getMultiMapValue(configuration, "Team Server", "Server.URL", ""), "Standard")
				serverURLEdit := (serverURLEdit.Has("Standard") ? serverURLEdit["Standard"] : "")

				serverTokenEdit := stringToMap("|", "->", getMultiMapValue(configuration, "Team Server", "Server.Token", ""), "Standard")
				serverTokenEdit := (serverTokenEdit.Has("Standard") ? serverTokenEdit["Standard"] : "")
			}

			serverUpdateEdit := replication
		}
		else {
			serverIdentifierEdit := ""
			serverURLEdit := ""
			serverTokenEdit := ""
			serverUpdateEdit := ""
		}

		settingsEditorGui := Window({Descriptor: "Session Database.Settings", Options: "0x400000"}, translate("Settings"))

		settingsEditorGui.SetFont("s10 Bold", "Arial")

		settingsEditorGui.Add("Text", "w394 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(settingsEditorGui, "Session Database.Settings"))

		settingsEditorGui.SetFont("s9 Norm", "Arial")

		settingsEditorGui.Add("Documentation", "x103 YP+20 w204 Center", translate("Database Settings")
							, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration")

		settingsEditorGui.SetFont("s8 Norm", "Arial")

		settingsEditorGui.Add("Text", "x16 y60 w125 h23 +0x200", translate("Database Folder"))
		databaseLocationEdit := settingsEditorGui.Add("Edit", "x146 yp w234 h21", databaseLocationEdit)
		settingsEditorGui.Add("Button", "x382 yp-1 w23 h23", translate("...")).OnEvent("Click", editSettings.Bind("DatabaseLocation"))

		settingsEditorGui.SetFont("Italic", "Arial")

		settingsEditorGui.Add("GroupBox", "x16 yp+30 w388 h240 Section", translate("Team Data"))

		settingsEditorGui.SetFont("Norm", "Arial")

		values := [synchTelemetryCheck, synchPressuresCheck, synchSessionsCheck, synchSetupsCheck, synchStrategiesCheck, synchTelemetriesCheck]

		settingsEditorGui.Add("Text", "x24 yp+16 w117 h23 +0x200", translate("Synchronization"))
		synchTelemetryCheck := settingsEditorGui.Add("CheckBox", "x146 yp+2 w120 h21", translate("Telemetry Data"))
		synchTelemetryCheck.OnEvent("Click", editSettings.Bind("UpdateState"))
		synchStrategiesCheck := settingsEditorGui.Add("CheckBox", "x266 yp w120 h21", translate("Race Strategies"))
		synchStrategiesCheck.OnEvent("Click", editSettings.Bind("UpdateState"))
		synchPressuresCheck := settingsEditorGui.Add("CheckBox", "x146 yp+24 w120 h21", translate("Pressures Data"))
		synchPressuresCheck.OnEvent("Click", editSettings.Bind("UpdateState"))
		synchSetupsCheck := settingsEditorGui.Add("CheckBox", "x266 yp w120 h21", translate("Car Setups"))
		synchSetupsCheck.OnEvent("Click", editSettings.Bind("UpdateState"))
		synchSessionsCheck := settingsEditorGui.Add("CheckBox", "x146 yp+24 w120 h21", translate("Sessions"))
		synchSessionsCheck.OnEvent("Click", editSettings.Bind("UpdateState"))
		synchTelemetriesCheck := settingsEditorGui.Add("CheckBox", "x266 yp w120 h21", translate("Laps"))
		synchTelemetriesCheck.OnEvent("Click", editSettings.Bind("UpdateState"))

		synchTelemetryCheck.Value := values[1]
		synchPressuresCheck.Value := values[2]
		synchSessionsCheck.Value := values[3]
		synchSetupsCheck.Value := values[4]
		synchStrategiesCheck.Value := values[5]
		synchTelemetriesCheck.Value := values[6]

		settingsEditorGui.Add("Text", "x24 yp+30 w117 h23 +0x200", translate("Name"))
		serverIdentifierEdit := settingsEditorGui.Add("Edit", "x146 yp+1 w246", serverIdentifierEdit)

		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		availableServerURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

		if (!inList(availableServerURLs, serverURLEdit) && StrLen(serverURLEdit) > 0)
			availableServerURLs.Push(serverURLEdit)

		chosen := inList(availableServerURLs, serverURLEdit)
		if (!chosen && (availableServerURLs.Length > 0))
			chosen := 1

		settingsEditorGui.Add("Text", "x24 yp+30 w117 h23 +0x200", translate("Server URL"))
		serverURLEdit := settingsEditorGui.Add("ComboBox", "x146 yp+1 w246 Choose" . chosen, availableServerURLs)

		settingsEditorGui.Add("Text", "x24 yp+23 w93 h23 +0x200", translate("Data Token"))
		serverTokenEdit := settingsEditorGui.Add("Edit", "x146 yp w246 h21 Password", serverTokenEdit)

		validateTokenButton := settingsEditorGui.Add("Button", "x122 yp-1 w23 h23 Center +0x200")
		validateTokenButton.OnEvent("Click", editSettings.Bind("ValidateToken"))
		setButtonIcon(validateTokenButton, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

		addConnectionButton := settingsEditorGui.Add("Button", "x296 yp+30 w23 h23 Center +0x200")
		addConnectionButton.OnEvent("Click", editSettings.Bind("AddConnection"))
		setButtonIcon(addConnectionButton, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")

		deleteConnectionButton := settingsEditorGui.Add("Button", "xp+24 yp w23 h23 Center +0x200")
		deleteConnectionButton.OnEvent("Click", editSettings.Bind("DeleteConnection"))
		setButtonIcon(deleteConnectionButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		previousConnectionButton := settingsEditorGui.Add("Button", "xp+24 yp w23 h23 Center +0x200")
		previousConnectionButton.OnEvent("Click", editSettings.Bind("PreviousConnection"))
		setButtonIcon(previousConnectionButton, kIconsDirectory . "Previous.ico", 1, "L4 T4 R4 B4")

		nextConnectionButton := settingsEditorGui.Add("Button", "xp+24 yp w23 h23 Center +0x200")
		nextConnectionButton.OnEvent("Click", editSettings.Bind("NextConnection"))
		setButtonIcon(nextConnectionButton, kIconsDirectory . "Next.ico", 1, "L4 T4 R4 B4")

		values := serverUpdateEdit

		settingsEditorGui.Add("Text", "x24 yp+30 w117 h23 +0x200", translate("Synchronize each"))
		serverUpdateEdit := settingsEditorGui.Add("Edit", "x146 yp w40 Number Limit2", values)
		settingsEditorGui.Add("UpDown", "xp+32 yp-2 w18 h20 Range10-90", values)
		settingsEditorGui.Add("Text", "x190 yp w90 h23 +0x200", translate("Minutes"))

		rebuildButton := settingsEditorGui.Add("Button", "x296 yp w96", translate("Rebuild..."))
		rebuildButton.OnEvent("Click", rebuildDatabase)

		settingsEditorGui.Add("Button", "x122 ys+248 w80 h23", translate("Ok")).OnEvent("Click", editSettings.Bind(kOk))
		settingsEditorGui.Add("Button", "x216 yp w80 h23", translate("&Cancel")).OnEvent("Click", editSettings.Bind(kCancel))

		editSettings("UpdateState")

		settingsEditorGui.Opt("+Owner" . arguments[1].Hwnd)

		if getWindowPosition("Session Database.Settings", &x, &y)
			settingsEditorGui.Show("x" . x . " y" . y)
		else
			settingsEditorGui.Show("AutoSize Center")

		done := false

		while !done {
			result := false

			while !result
				Sleep(100)

			if (result == kCancel)
				done := true
			else if (result == kOk) {
				changed := false
				restart := false

				if (databaseLocationEdit.Text = "") {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("You must enter a valid directory."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					continue
				}
				else if (normalizeDirectoryPath(databaseLocationEdit.Text) != normalizeDirectoryPath(kDatabaseDirectory)) {
					if !FileExist(databaseLocationEdit.Text)
						try {
							DirCreate(databaseLocationEdit.Text)
						}
						catch Any as exception {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, translate("You must enter a valid directory."), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)

							continue
						}

					translator := translateMsgBoxButtons.Bind(["Yes", "No", "Cancel"])

					OnMessage(0x44, translator)
					msgResult := withBlockedWindows(MsgBox, translate("You are about to change the session database location. Do you want to transfer the current content to the new location?")
									  , translate("Session Database"), 262179)
					OnMessage(0x44, translator, 0)

					if (msgResult = "Cancel")
						continue

					if (msgResult = "Yes") {
						empty := true

						loop Files, databaseLocationEdit.Text . "\*.*", "FD" {
							empty := false

							break
						}

						if !empty {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, translate("The new database folder must be empty."), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)

							continue
						}

						original := normalizeDirectoryPath(kDatabaseDirectory)

						showProgress({color: "Green", title: translate("Transfering Session Database"), message: translate("...")})

						copyFiles(original, databaseLocationEdit.Text)

						showProgress({progress: 100, message: translate("Finished...")})

						Sleep(200)

						hideProgress()
					}

					SessionDatabase.DatabasePath := (normalizeDirectoryPath(databaseLocationEdit.Text) . "\")

					changed := true
					restart := true
				}

				if !changed {
					oldConnections := []

					for identifier, serverURL in sessionDB.ServerURLs
						oldConnections.Push([identifier, serverURL, sessionDB.ServerToken[identifier], sessionDB.Groups[identifier]])

					if (oldConnections.Length != connections.Length) {
						changed := true
						restart := true
					}
					else
						loop connections.Length {

							currentConnection := A_Index

							loop 3
								if (oldConnections[currentConnection][A_Index] != connections[currentConnection][A_Index]) {
									changed := true

									if (A_Index > 1)
										restart := true
								}

							if (!changed && (values2String(",", oldConnections[currentConnection][4]*) != values2String(",", connections[currentConnection][4]*))) {
								changed := true
								restart := true
							}
						}
				}

				configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

				setMultiMapValue(configuration, "Team Server", "Replication", serverUpdateEdit.Text)

				if changed {
					setMultiMapValue(configuration, "Team Server", "Synchronization", mapToString("|", "->", CaseInsenseMap()))

					setMultiMapValue(configuration, "Database", "Path", normalizeDirectoryPath(databaseLocationEdit.Text) . "\")

					serverURLs := CaseInsenseMap()
					serverTokens := CaseInsenseMap()
					groups := CaseInsenseMap()

					for ignore, connection in connections {
						serverURLs[connection[1]] := connection[2]
						serverTokens[connection[1]] := connection[3]
						groups[connection[1]] := values2String(",", connection[4]*)
					}

					setMultiMapValue(configuration, "Team Server", "Groups", mapToString("|", "->", groups))
					setMultiMapValue(configuration, "Team Server", "Server.URL", mapToString("|", "->", serverURLs))
					setMultiMapValue(configuration, "Team Server", "Server.Token", mapToString("|", "->", serverTokens))

					writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)

					if restart {
						OnMessage(0x44, translateOkButton)
						withBlockedWindows(MsgBox, translate("The session database configuration has been updated and the application will exit now. Make sure to restart all other applications as well.")
							 , translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)

						broadcastMessage(concatenate(kBackgroundApps, kForegroundApps), "exitProcess")
					}
				}
				else
					writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)

				SessionDatabase.reloadConfiguration()

				done := true
			}
		}

		settingsEditorGui.Destroy()
	}
}

loginDialog(connectorOrCommand := false, teamServerURL := false, owner := false, *) {
	local loginGui

	static name := ""
	static password := ""

	static result := false
	static nameEdit
	static passwordEdit

	if (connectorOrCommand == kOk)
		result := kOk
	else if (connectorOrCommand == kCancel)
		result := kCancel
	else {
		result := false

		loginGui := Window({Options: "0x400000"}, translate("Team Server"))

		loginGui.SetFont("Norm", "Arial")

		loginGui.Add("Text", "x16 y16 w90 h23 +0x200", translate("Server URL"))
		loginGui.Add("Text", "x110 yp w160 h23 +0x200", teamServerURL)

		loginGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Name"))
		nameEdit := loginGui.Add("Edit", "x110 yp+1 w160 h21", name)

		loginGui.Add("Text", "x16 yp+23 w90 h23 +0x200", translate("Password"))
		passwordEdit := loginGui.Add("Edit", "x110 yp+1 w160 h21 Password", password)

		loginGui.Add("Button", "x60 yp+35 w80 h23 Default", translate("Ok")).OnEvent("Click", loginDialog.Bind(kOk))
		loginGui.Add("Button", "x146 yp w80 h23", translate("&Cancel")).OnEvent("Click", loginDialog.Bind(kCancel))

		loginGui.Opt("+Owner" . owner.Hwnd)

		loginGui.Show("AutoSize Center")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				name := nameEdit.Text
				password := passwordEdit.Text

				try {
					connectorOrCommand.Initialize(teamServerURL)

					connectorOrCommand.Login(name, password)

					return connectorOrCommand.GetDataToken()
				}
				catch Any as exception {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					return false
				}
			}
		}
		finally {
			loginGui.Destroy()
		}
	}
}

startupSessionDatabase() {
	local icon := kIconsDirectory . "Session Database.ico"
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getMultiMapValue(settings, "Session Database", "Simulator", false)
	local car := getMultiMapValue(settings, "Session Database", "Car", false)
	local track := getMultiMapValue(settings, "Session Database", "Track", false)
	local weather := false
	local airTemperature := 23
	local trackTemperature := 27
	local compound := false
	local compoundColor := false
	local requestorPID := false
	local import := false
	local index := 1
	local editor, selection, info

	TraySetIcon(icon, "1")
	A_IconTip := "Session Database"

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
			case "-Setup":
				requestorPID := A_Args[index + 1]
				index += 2
			case "-Import":
				import := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}

	if (airTemperature <= 0)
		airTemperature := 23

	if (trackTemperature <= 0)
		trackTemperature := 27

	protectionOn()

	try {
		if import {
			import := (normalizeDirectoryPath(import) . "\")
			info := readMultiMap(import . "Export.info")

			editor := SessionDatabaseEditor(getMultiMapValue(info, "General", "Simulator", "Unknown"))

			if (getMultiMapValue(info, "General", "Type", "Data") = "Settings") {
				selection := selectImportSettings(editor, import)

				if selection
					editor.importSettings(import, selection)
			}
			else if (getMultiMapValue(info, "General", "Type", "Data") = "Data") {
				selection := selectImportData(editor, import)

				if selection
					editor.importData(import, selection)
			}

			ExitApp(0)
		}
		else {
			editor := SessionDatabaseEditor(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, requestorPID)

			editor.createGui(editor.Configuration)

			editor.show()
		}
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Session Database"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}
	finally {
		protectionOff()
	}

	startupApplication()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupSessionDatabase()