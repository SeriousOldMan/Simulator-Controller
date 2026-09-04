;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Formats Editor                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FormatsEditor                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FormatsEditor extends ConfiguratorPanel {
	iClosed := false

	iUnitSets := newMultiMap()
	iSelectedUnitSet := "Standard"

	UnitSets {
		Get {
			return this.iUnitSets
		}
	}

	SelectedUnitSet {
		Get {
			return this.iSelectedUnitSet
		}
	}

	__New(configuration) {
		this.iUnitSets := readMultiMap(kUserConfigDirectory . "Units.ini")
		this.iSelectedUnitSet := currentUnits()

		super.__New(configuration)

		FormatsEditor.Instance := this

		if (this.UnitSets.Count = 0)
			this.saveUnitSet(this.SelectedUnitSet, false)
	}

	createGui(configuration) {
		local chosen, choices

		static formatsGui

		saveFormatsEditor(*) {
			protectionOn()

			try {
				this.closeEditor(true)
			}
			finally {
				protectionOff()
			}
		}

		cancelFormatsEditor(*) {
			protectionOn()

			try {
				this.closeEditor(false)
			}
			finally {
				protectionOff()
			}
		}

		chooseUnitSet(*) {
			protectionOn()

			try {
				this.chooseUnitSet(this.Control["unitSetsDropDown"].Text)
			}
			finally {
				protectionOff()
			}
		}

		addUnitSet(*) {
			protectionOn()

			try {
				this.addUnitSet()
			}
			finally {
				protectionOff()
			}
		}

		deleteUnitSet(*) {
			protectionOn()

			try {
				this.deleteUnitSet()
			}
			finally {
				protectionOff()
			}
		}

		formatsGui := Window({Descriptor: "Formats Editor", Options: "0x400000"})

		this.Window := formatsGui

		formatsGui.SetFont("Bold", "Arial")

		formatsGui.Add("Text", "w238 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(formatsGui, "Formats Editor"))

		formatsGui.SetFont("Norm", "Arial")

		formatsGui.Add("Documentation", "x63 YP+20 w128 Center", translate("Units && Formats")
					 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#units-and-formats")

		formatsGui.SetFont("Norm", "Arial")

		choices := getKeys(this.UnitSets)
		chosen := inList(choices, this.SelectedUnitSet)

		formatsGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Units"))
		formatsGui.Add("DropDownList", "x110 yp w87 Choose" . chosen . " vunitSetsDropDown", choices).OnEvent("Change", chooseUnitSet)

		formatsGui.Add("Button", "x198 yp-1 w23 h23 vaddUnitSetButton").OnEvent("Click", addUnitSet)
		formatsGui.Add("Button", "x222 yp w23 h23 vdeleteUnitSetButton").OnEvent("Click", deleteUnitSet)

		setButtonIcon(formatsGui["addUnitSetButton"], kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(formatsGui["deleteUnitSetButton"], kIconsDirectory . "Minus.ico", 1)

		formatsGui.Add("Text", "x24 yp+40 w213 0x10")

		chosen := inList(kTemperatureUnits, this.Value["temperatureUnit"])

		formatsGui.Add("Text", "x16 yp+10 w90 h23 +0x200", translate("Temperature"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vtemperatureUnitDropDown", kTemperatureUnits)

		chosen := inList(kMassUnits, this.Value["massUnit"])

		formatsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Mass"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vmassUnitDropDown", kMassUnits)

		chosen := inList(kPressureUnits, this.Value["pressureUnit"])

		formatsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Pressure"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vpressureUnitDropDown", kPressureUnits)

		chosen := inList(kVolumeUnits, this.Value["volumeUnit"])

		formatsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Volume"))
		ogcvolumeUnitDropDown := formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vvolumeUnitDropDown", kVolumeUnits)

		chosen := inList(kLengthUnits, this.Value["lengthUnit"])

		formatsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Length"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vlengthUnitDropDown", kLengthUnits)

		chosen := inList(kSpeedUnits, this.Value["speedUnit"])

		formatsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Speed"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vspeedUnitDropDown", kSpeedUnits)

		chosen := inList(kNumberFormats, this.Value["numberFormat"])

		formatsGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Float"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vnumberFormatDropDown", kNumberFormats)

		chosen := inList(kTimeFormats, this.Value["timeFormat"])

		formatsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Time"))
		formatsGui.Add("DropDownList", "x110 yp w135 Choose" . chosen . " vtimeFormatDropDown", kTimeFormats)

		formatsGui.Add("Text", "x24 y+10 w213 0x10")

		formatsGui.Add("Button", "x36 yp+10 w80 h23 Default", translate("Save")).OnEvent("Click", saveFormatsEditor)
		formatsGui.Add("Button", "x139 yp w80 h23", translate("&Cancel")).OnEvent("Click", cancelFormatsEditor)

		this.updatetState()
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.Value["massUnit"] := getMultiMapValue(configuration, "Localization", "MassUnit", "Kilogram")
		this.Value["temperatureUnit"] := getMultiMapValue(configuration, "Localization", "TemperatureUnit", "Celsius")
		this.Value["pressureUnit"] := getMultiMapValue(configuration, "Localization", "PressureUnit", "PSI")
		this.Value["volumeUnit"] := getMultiMapValue(configuration, "Localization", "VolumeUnit", "Liter")
		this.Value["lengthUnit"] := getMultiMapValue(configuration, "Localization", "LengthUnit", "Meter")
		this.Value["speedUnit"] := getMultiMapValue(configuration, "Localization", "SpeedUnit", "km/h")

		this.Value["numberFormat"] := getMultiMapValue(configuration, "Localization", "NumberFormat", "#.##")
		this.Value["timeFormat"] := getMultiMapValue(configuration, "Localization", "TimeFormat", "[H:]M:S.##")

		if (this.Value["volumeUnit"] = "Gallon")
			this.Value["volumeUnit"] := "Gallon (GB)"
	}

	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Localization", "TemperatureUnit", kTemperatureUnits[this.Control["temperatureUnitDropDown"].Value])
		setMultiMapValue(configuration, "Localization", "MassUnit", kMassUnits[this.Control["massUnitDropDown"].Value])
		setMultiMapValue(configuration, "Localization", "PressureUnit", kPressureUnits[this.Control["pressureUnitDropDown"].Value])
		setMultiMapValue(configuration, "Localization", "VolumeUnit", kVolumeUnits[this.Control["volumeUnitDropDown"].Value])
		setMultiMapValue(configuration, "Localization", "LengthUnit", kLengthUnits[this.Control["lengthUnitDropDown"].Value])
		setMultiMapValue(configuration, "Localization", "SpeedUnit", kSpeedUnits[this.Control["speedUnitDropDown"].Value])

		setMultiMapValue(configuration, "Localization", "NumberFormat", kNumberFormats[this.Control["numberFormatDropDown"].Value])
		setMultiMapValue(configuration, "Localization", "TimeFormat", kTimeFormats[this.Control["timeFormatDropDown"].Value])
	}

	editFormats(owner := false) {
		local window, x, y, configuration

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Formats Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		loop
			Sleep(200)
		until this.iClosed

		try {
			if (this.iClosed == kOk) {
				configuration := newMultiMap()

				this.saveToConfiguration(configuration)

				this.saveUnitSet(this.SelectedUnitSet)

				writeMultiMap(kUserConfigDirectory . "Units.ini", this.UnitSets)

				return configuration
			}
			else
				return false
		}
		finally {
			window.Destroy()
		}
	}

	closeEditor(save) {
		this.iClosed := (save ? kOk : kCancel)
	}

	updatetState() {
		this.Control["deleteUnitSetButton"].Enabled := (this.UnitSets.Count > 1)
	}

	loadUnitSet(unitSet) {
		local unitSets := this.UnitSets

		this.iSelectedUnitSet := unitSet

		this.Control["temperatureUnitDropDown"].Choose(inList(kTemperatureUnits
															, getMultiMapValue(unitSets, unitSet, "TemperatureUnit")))
		this.Control["massUnitDropDown"].Choose(inList(kMassUnits
													 , getMultiMapValue(unitSets, unitSet, "MassUnit")))
		this.Control["pressureUnitDropDown"].Choose(inList(kPressureUnits
														 , getMultiMapValue(unitSets, unitSet, "PressureUnit")))
		this.Control["volumeUnitDropDown"].Choose(inList(kVolumeUnits
													   , getMultiMapValue(unitSets, unitSet, "VolumeUnit")))
		this.Control["speedUnitDropDown"].Choose(inList(kSpeedUnits
													  , getMultiMapValue(unitSets, unitSet, "SpeedUnit")))
		this.Control["numberFormatDropDown"].Choose(inList(kNumberFormats
														 , getMultiMapValue(unitSets, unitSet, "NumberFormat")))
		this.Control["timeFormatDropDown"].Choose(inList(kTimeFormats
													   , getMultiMapValue(unitSets, unitSet, "TimeFormat")))
	}

	saveUnitSet(unitSet, fromEditor := true) {
		local unitSets := this.UnitSets

		if fromEditor {
			setMultiMapValue(unitSets, unitSet, "TemperatureUnit", kTemperatureUnits[this.Control["temperatureUnitDropDown"].Value])
			setMultiMapValue(unitSets, unitSet, "MassUnit", kMassUnits[this.Control["massUnitDropDown"].Value])
			setMultiMapValue(unitSets, unitSet, "PressureUnit", kPressureUnits[this.Control["pressureUnitDropDown"].Value])
			setMultiMapValue(unitSets, unitSet, "VolumeUnit", kVolumeUnits[this.Control["volumeUnitDropDown"].Value])
			setMultiMapValue(unitSets, unitSet, "LengthUnit", kLengthUnits[this.Control["lengthUnitDropDown"].Value])
			setMultiMapValue(unitSets, unitSet, "SpeedUnit", kSpeedUnits[this.Control["speedUnitDropDown"].Value])

			setMultiMapValue(unitSets, unitSet, "NumberFormat", kNumberFormats[this.Control["numberFormatDropDown"].Value])
			setMultiMapValue(unitSets, unitSet, "TimeFormat", kTimeFormats[this.Control["timeFormatDropDown"].Value])
		}
		else {
			setMultiMapValue(unitSets, unitSet, "MassUnit", this.Value["massUnit"])
			setMultiMapValue(unitSets, unitSet, "TemperatureUnit", this.Value["temperatureUnit"])
			setMultiMapValue(unitSets, unitSet, "PressureUnit", this.Value["pressureUnit"])
			setMultiMapValue(unitSets, unitSet, "VolumeUnit", this.Value["volumeUnit"])
			setMultiMapValue(unitSets, unitSet, "LengthUnit", this.Value["lengthUnit"])
			setMultiMapValue(unitSets, unitSet, "SpeedUnit", this.Value["speedUnit"])
			setMultiMapValue(unitSets, unitSet, "NumberFormat", this.Value["numberFormat"])
			setMultiMapValue(unitSets, unitSet, "TimeFormat", this.Value["timeFormat"])
		}
	}

	chooseUnitSet(unitSet) {
		this.saveUnitSet(this.SelectedUnitSet)

		this.loadUnitSet(unitSet)

		this.iSelectedUnitSet := unitSet

		this.Control["unitSetsDropDown"].Choose(inList(getKeys(this.UnitSets), this.SelectedUnitSet))

		this.updatetState()
	}

	addUnitSet() {
		local result

		this.saveUnitSet(this.SelectedUnitSet)

		result := withBlockedWindows(InputDlg, translate("Please enter the name for the units:"), translate("Units"), "w200 h80")

		if (result.Result = "Ok") {
			this.iSelectedUnitSet := result.Value

			this.saveUnitSet(this.SelectedUnitSet)

			this.Control["unitSetsDropDown"].Delete()
			this.Control["unitSetsDropDown"].Add(getKeys(this.UnitSets))
			this.Control["unitSetsDropDown"].Choose(inList(getKeys(this.UnitSets), this.SelectedUnitSet))
		}

		this.updatetState()
	}

	deleteUnitSet() {
		local msgResult

		msgResult := withBlockedWindows(MsgDlg, translate("Do you really want to delete this units?")
											  , translate("Delete")
											  , {Options: 262436, Mode: "Question"
											   , Buttons: collect(["Yes", "No"], translate)})

		if (msgResult = translate("Yes")) {
			removeMultiMapValues(this.UnitSets, this.SelectedUnitSet)

			this.Control["unitSetsDropDown"].Delete()
			this.Control["unitSetsDropDown"].Add(getKeys(this.UnitSets))

			this.chooseUnitSet(getKeys(this.UnitSets)[1])
		}
	}
}