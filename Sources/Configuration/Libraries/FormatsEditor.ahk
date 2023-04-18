;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Formats Editor                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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

	__New(configuration) {
		super.__New(configuration)

		FormatsEditor.Instance := this
	}

	createGui(configuration) {
		local chosen

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

		formatsGui := Window({Descriptor: "Formats Editor", Options: "0x400000"}, "")

		this.Window := formatsGui

		formatsGui.Add("Text", "w238 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(formatsGui, "Formats Editor"))

		formatsGui.SetFont("Norm", "Arial")
		formatsGui.SetFont("Italic Underline", "Arial")

		formatsGui.Add("Text", "x63 YP+20 w128 cBlue Center", translate("Units && Formats")).OnEvent("Click", openDocumentation.Bind(formatsGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#units-and-formats"))

		formatsGui.SetFont("Norm", "Arial")

		chosen := inList(kTemperatureUnits, this.Value["temperatureUnit"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Temperature"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vtemperatureUnitDropDown", kTemperatureUnits)

		chosen := inList(kMassUnits, this.Value["massUnit"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Mass"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vmassUnitDropDown", kMassUnits)

		chosen := inList(kPressureUnits, this.Value["pressureUnit"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Pressure"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vpressureUnitDropDown", kPressureUnits)

		chosen := inList(kVolumeUnits, this.Value["volumeUnit"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Volume"))
		ogcvolumeUnitDropDown := formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vvolumeUnitDropDown", kVolumeUnits)

		chosen := inList(kLengthUnits, this.Value["lengthUnit"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Length"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vlengthUnitDropDown", kLengthUnits)

		chosen := inList(kSpeedUnits, this.Value["speedUnit"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Speed"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vspeedUnitDropDown", kSpeedUnits)

		chosen := inList(kNumberFormats, this.Value["numberFormat"])

		formatsGui.Add("Text", "x16 yp+30 w100 h23 +0x200", translate("Float"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vnumberFormatDropDown", kNumberFormats)

		chosen := inList(kTimeFormats, this.Value["timeFormat"])

		formatsGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Time"))
		formatsGui.Add("DropDownList", "x120 yp w125 Choose" . chosen . " vtimeFormatDropDown", kTimeFormats)

		formatsGui.Add("Text", "x24 y+10 w213 0x10")

		formatsGui.Add("Button", "x36 yp+10 w80 h23 Default", translate("Save")).OnEvent("Click", saveFormatsEditor)
		formatsGui.Add("Button", "x139 yp w80 h23", translate("&Cancel")).OnEvent("Click", cancelFormatsEditor)
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
}