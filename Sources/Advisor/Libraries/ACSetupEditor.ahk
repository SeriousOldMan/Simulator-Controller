;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for AC             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetup                                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetup extends Setup {
	iOriginalData := false
	iModifiedData := false

	Data[original := false] {
		Get {
			return (original ? this.iOriginalData : this.iModifiedData)
		}
	}

	Setup[original := false] {
		Get {
			return base.Setup[original]
		}

		Set {
			return (base.Setup[original] := StrReplace(StrReplace(value, "=true", "=1"), "=false", "=0"))
		}
	}

	__New(editor, originalFileName := false) {
		iEditor := editor

		base.__New(editor, originalFileName)

		this.iOriginalData := parseConfiguration(this.Setup[true])
		this.iModifiedData := parseConfiguration(this.Setup[false])
	}

	getValue(setting, original := false, default := false) {
		return getConfigurationValue(this.Data[original], getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE")
	}

	setValue(setting, value) {
		setConfigurationValue(this.Data, getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE", value)

		this.Setup := printConfiguration(this.Data)

		return value
	}

	reset() {
		base.reset()

		this.iModifiedData := parseConfiguration(this.Setup[false])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetupEditor                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetupEditor extends SetupEditor {
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
		static carNames := false

		if !carNames
			carNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Car Names")

		directory := (A_MyDocuments . "\Assetto Corsa\setups")
		car := this.Advisor.SelectedCar[false]
		track := this.Advisor.SelectedTrack[false]

		if (car && (car != true))
			directory .= ("\" . (carNames.HasKey(car) ? carNames[car] : car))

		if (track && (track != true))
			directory .= ("\" . track)

		title := translate("Load AC Setup File...")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %directory%, %title%, Setup (*.ini)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACSetup(this, fileName)

			if load
				this.loadSetup(theSetup)
			else
				return theSetup
		}
		else
			return false
	}

	loadSetup(setup := false) {
		base.loadSetup(setup)

		categories := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories")

		categoriesLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories.Labels." . getLanguage(), Object())

		if (categoriesLabels.Count() == 0)
			categoriesLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories.Labels.EN", Object())

		settingsLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Settings.Labels." . getLanguage(), Object())

		if (settingsLabels.Count() == 0)
			settingsLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Settings.Labels.EN", Object())

		settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units." . getLanguage(), Object())

		if (settingsUnits.Count() == 0)
			settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units.EN", Object())

		window := this.Window

		Gui %window%:Default

		Gui ListView, % this.SettingsListView

		LV_Delete()

		this.Settings := {}

		for ignore, setting in this.Advisor.Settings {
			handler := this.createSettingHandler(setting)

			if handler {
				originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
				modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))

				if (originalValue = modifiedValue)
					value := originalValue
				else if (modifiedValue > originalValue)
					value := (modifiedValue . A_Space . translate("(") . "+" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))
				else
					value := (modifiedValue . A_Space . translate("(") . "-" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

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

				LV_Add("", categoriesLabels[category], label, value, settingsUnits[setting])

				this.Settings[setting] := label
				this.Settings[label] := setting
			}
		}

		LV_ModifyCol()

		LV_ModifyCol(1, "AutoHdr Sort")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")

		lastCategory := ""

		Loop % LV_getCount()
		{
			LV_GetText(category, A_Index)

			if (category = lastCategory)
				LV_Modify(A_Index, "", "")

			lastCategory := category
		}
	}

	saveSetup() {
		fileName := this.Setup.FileName

		if fileName = this.Setup.FileName[true]
			SplitPath fileName, , directory
		else
			directory := fileName

		title := translate("Save AC Setup File...")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
		FileSelectFile fileName, S17, %directory%, %title%, Setup (*.ini)
		OnMessage(0x44, "")

		if (fileName != "") {
			if !InStr(fileName, ".ini")
				fileName := (fileName . ".ini")

			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}

			text := this.Setup.Setup

			FileAppend %text%, %fileName%

			this.Setup.FileName := fileName
		}
	}

	updateSetting(setting, newValue) {
		local setup := this.Setup

		setup.setValue(setting, newValue)

		label := this.Settings[setting]
		row := false

		Loop {
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

		if (originalValue = modifiedValue)
			value := originalValue
		else if (modifiedValue > originalValue)
			value := (modifiedValue . A_Space . translate("(") . "+" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))
		else
			value := (modifiedValue . A_Space . translate("(") . "-" . handler.formatValue(Abs(originalValue - modifiedValue)) . translate(")"))

		LV_Modify(row, "+Vis Col3", value)
		LV_ModifyCol(3, "AutoHdr")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetupComparator                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetupComparator extends SetupComparator {
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

	chooseSetup(type, load := true) {
		static carNames := false

		if !carNames
			carNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Car Names")

		directory := (A_MyDocuments . "\Assetto Corsa\setups")
		car := this.Editor.Advisor.SelectedCar[false]
		track := this.Editor.Advisor.SelectedTrack[false]

		if (car && (car != true))
			directory .= ("\" . (carNames.HasKey(car) ? carNames[car] : car))

		if (track && (track != true))
			directory .= ("\" . track)

		title := (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" AC Setup File..."))

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %directory%, %title%, Setup (*.ini)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACSetup(this, fileName)

			if load {
				if (type = "A")
					this.loadSetups(theSetup)
				else
					this.loadSetups(false, theSetup)
			}
			else
				return theSetup
		}
		else
			return false
	}

	loadABSetup() {
	}

	loadSetups(ByRef setupA := false, ByRef setupB := false, mix := 0) {
		base.loadSetups(setupA, setupB)

		setupAB := new ACSetup(this.Editor, setupA.FileName[true])

		setupAB.FileName[false] := setupA.FileName[false]
		setupAB.Setup[false] := setupA.Setup[false]

		this.SetupAB := setupAB

		categories := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories")

		categoriesLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories.Labels." . getLanguage(), Object())

		if (categoriesLabels.Count() == 0)
			categoriesLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Categories.Labels.EN", Object())

		settingsLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Settings.Labels." . getLanguage(), Object())

		if (settingsLabels.Count() == 0)
			settingsLabels := getConfigurationSectionValues(this.Advisor.Definition, "Setup.Settings.Labels.EN", Object())

		settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units." . getLanguage(), Object())

		if (settingsUnits.Count() == 0)
			settingsUnits := getConfigurationSectionValues(this.Configuration, "Setup.Settings.Units.EN", Object())

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

				Loop {
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

		Loop % LV_getCount()
		{
			LV_GetText(category, A_Index)

			if (category = lastCategory)
				LV_Modify(A_Index, "", "")

			lastCategory := category
		}
	}

	updateSetting(setting, newValue) {
		local setup := this.SetupAB

		setup.setValue(setting, newValue)

		label := this.Settings[setting]
		row := false

		Loop {
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

		LV_Modify(row, "+Vis Col5", value)
		LV_ModifyCol(5, "AutoHdr")
	}
}