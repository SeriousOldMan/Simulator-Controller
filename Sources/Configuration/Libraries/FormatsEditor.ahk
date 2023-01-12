;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Formats Editor                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Framework.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FormatsEditor                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global massUnitDropDown
global temperatureUnitDropDown
global pressureUnitDropDown
global volumeUnitDropDown
global lengthUnitDropDown
global speedUnitDropDown
global numberFormatDropDown
global timeFormatDropDown

class FormatsEditor extends ConfigurationItem {
	iClosed := false

	__New(configuration) {
		base.__New(configuration)

		FormatsEditor.Instance := this

		this.createGui(configuration)
	}

	createGui(configuration) {
		local chosen

		Gui FE:Default

		Gui FE:-Border ; -Caption
		Gui FE:Color, D0D0D0, D8D8D8

		Gui FE:Font, Bold, Arial

		Gui FE:Add, Text, w238 Center gmoveFormatsEditor, % translate("Modular Simulator Controller System")

		Gui FE:Font, Norm, Arial
		Gui FE:Font, Italic Underline, Arial

		Gui FE:Add, Text, x63 YP+20 w128 cBlue Center gopenFormatsDocumentation, % translate("Units && Formats")

		Gui FE:Font, Norm, Arial

		chosen := inList(kTemperatureUnits, temperatureUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Temperature")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vtemperatureUnitDropDown, % values2String("|", kTemperatureUnits*)

		chosen := inList(kMassUnits, massUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Mass")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vmassUnitDropDown, % values2String("|", kMassUnits*)

		chosen := inList(kPressureUnits, pressureUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Pressure")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vpressureUnitDropDown, % values2String("|", kPressureUnits*)

		chosen := inList(kVolumeUnits, volumeUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Volume")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vvolumeUnitDropDown, % values2String("|", kVolumeUnits*)

		chosen := inList(kLengthUnits, lengthUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Length")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vlengthUnitDropDown, % values2String("|", kLengthUnits*)

		chosen := inList(kSpeedUnits, speedUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Speed")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vspeedUnitDropDown, % values2String("|", kSpeedUnits*)

		chosen := inList(kNumberFormats, numberFormatDropDown)

		Gui FE:Add, Text, x16 yp+30 w100 h23 +0x200, % translate("Float")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vnumberFormatDropDown, % values2String("|", kNumberFormats*)

		chosen := inList(kTimeFormats, timeFormatDropDown)

		Gui FE:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Time")
		Gui FE:Add, DropDownList, x120 yp w125 AltSubmit Choose%chosen% vtimeFormatDropDown, % values2String("|", kTimeFormats*)

		Gui FE:Add, Text, x24 y+10 w213 0x10

		Gui FE:Add, Button, x36 yp+10 w80 h23 Default GsaveFormatsEditor, % translate("Save")
		Gui FE:Add, Button, x139 yp w80 h23 GcancelFormatsEditor, % translate("&Cancel")
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		massUnitDropDown := getConfigurationValue(configuration, "Localization", "MassUnit", "Kilogram")
		temperatureUnitDropDown := getConfigurationValue(configuration, "Localization", "TemperatureUnit", "Celsius")
		pressureUnitDropDown := getConfigurationValue(configuration, "Localization", "PressureUnit", "PSI")
		volumeUnitDropDown := getConfigurationValue(configuration, "Localization", "VolumeUnit", "Liter")
		lengthUnitDropDown := getConfigurationValue(configuration, "Localization", "LengthUnit", "Meter")
		speedUnitDropDown := getConfigurationValue(configuration, "Localization", "SpeedUnit", "km/h")

		numberFormatDropDown := getConfigurationValue(configuration, "Localization", "NumberFormat", "#.##")
		timeFormatDropDown := getConfigurationValue(configuration, "Localization", "TimeFormat", "[H:]M:S.##")
	}

	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		GuiControlGet temperatureUnitDropDown
		GuiControlGet massUnitDropDown
		GuiControlGet pressureUnitDropDown
		GuiControlGet volumeUnitDropDown
		GuiControlGet lengthUnitDropDown
		GuiControlGet speedUnitDropDown
		GuiControlGet numberFormatDropDown
		GuiControlGet timeFormatDropDown

		setConfigurationValue(configuration, "Localization", "TemperatureUnit", kTemperatureUnits[temperatureUnitDropDown])
		setConfigurationValue(configuration, "Localization", "MassUnit", kMassUnits[massUnitDropDown])
		setConfigurationValue(configuration, "Localization", "PressureUnit", kPressureUnits[pressureUnitDropDown])
		setConfigurationValue(configuration, "Localization", "VolumeUnit", kVolumeUnits[volumeUnitDropDown])
		setConfigurationValue(configuration, "Localization", "LengthUnit", kLengthUnits[lengthUnitDropDown])
		setConfigurationValue(configuration, "Localization", "SpeedUnit", kSpeedUnits[speedUnitDropDown])

		setConfigurationValue(configuration, "Localization", "NumberFormat", kNumberFormats[numberFormatDropDown])
		setConfigurationValue(configuration, "Localization", "TimeFormat", kTimeFormats[timeFormatDropDown])
	}

	editFormats() {
		local x, y, configuration

		if getWindowPosition("Formats Editor", x, y)
			Gui FE:Show, x%x% y%y%
		else
			Gui FE:Show

		loop
			Sleep 200
		until this.iClosed

		try {
			if (this.iClosed == kOk) {
				configuration := newConfiguration()

				this.saveToConfiguration(configuration)

				return configuration
			}
			else
				return false
		}
		finally {
			Gui FE:Destroy
		}
	}

	closeEditor(save) {
		if save
			Gui FE:Submit

		this.iClosed := (save ? kOk : kCancel)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveFormatsEditor() {
	protectionOn()

	try {
		FormatsEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelFormatsEditor() {
	protectionOn()

	try {
		FormatsEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}

moveFormatsEditor() {
	moveByMouse("FE", "Formats Editor")
}

openFormatsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#units-and-formats
}