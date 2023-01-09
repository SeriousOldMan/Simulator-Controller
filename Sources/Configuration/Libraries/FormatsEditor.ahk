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
global pressureUnitDropDown
global volumeUnitDropDown
global lengthUnitDropDown
global speedUnitDropDown
global numbersFormatDropDown
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

		Gui FE:Add, Text, x83 YP+20 w88 cBlue Center gopenFormatsDocumentation, % translate("Units && Formats")

		Gui FE:Font, Norm, Arial

		chosen := inList(["Kilogram", "Pound"], massUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Mass")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vmassUnitDropDown, % values2String("|", map(["Kilogram", "Pound"], "translate")*)

		chosen := inList(["BAR", "PSI", "KPa"], pressureUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Pressure")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vpressureUnitDropDown, % values2String("|", map(["BAR", "PSI", "KPa"], "translate")*)

		chosen := inList(["Liter", "Gallon"], volumeUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Volume")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vvolumeUnitDropDown, % values2String("|", map(["Liter", "Gallon"], "translate")*)

		chosen := inList(["Meter", "Foot"], lengthUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Length")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vlengthUnitDropDown, % values2String("|", map(["Meter", "Foot"], "translate")*)

		chosen := inList(["km/h", "mph"], speedUnitDropDown)

		Gui FE:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Speed")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vspeedUnitDropDown, % values2String("|", map(["km/h", "mph"], "translate")*)

		chosen := inList(["#.##", "#,##"], numbersFormatDropDown)

		Gui FE:Add, Text, x16 yp+30 w70 h23 +0x200, % translate("Numbers")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vnumbersFormatDropDown, % values2String("|", map(["#.##", "#,##"], "translate")*)

		chosen := inList(["H:M:S.##", "H:M:S,##", "S.##", "S,##"], timeFormatDropDown)

		Gui FE:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Time")
		Gui FE:Add, DropDownList, x90 yp w155 AltSubmit Choose%chosen% vtimeFormatDropDown, % values2String("|", map(["H:M:S.##", "H:M:S,##", "S.##", "S,##"], "translate")*)

		Gui FE:Add, Text, x24 y+10 w213 0x10

		Gui FE:Add, Button, x36 yp+10 w80 h23 Default GsaveFormatsEditor, % translate("Save")
		Gui FE:Add, Button, x139 yp w80 h23 GcancelFormatsEditor, % translate("&Cancel")
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		massUnitDropDown := getConfigurationValue(configuration, "Localization", "MassUnit", "Kilogram")
		pressureUnitDropDown := getConfigurationValue(configuration, "Localization", "PressureUnit", "PSI")
		volumeUnitDropDown := getConfigurationValue(configuration, "Localization", "VolumeUnit", "Liter")
		lengthUnitDropDown := getConfigurationValue(configuration, "Localization", "LengthUnit", "Meter")
		speedUnitDropDown := getConfigurationValue(configuration, "Localization", "SpeedUnit", "km/h")

		numbersFormatDropDown := getConfigurationValue(configuration, "Localization", "NumbersFormat", "#.##")
		timeFormatDropDown := getConfigurationValue(configuration, "Localization", "TimeFormat", "H:M:S.##")
	}

	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		GuiControlGet massUnitDropDown
		GuiControlGet pressureUnitDropDown
		GuiControlGet volumeUnitDropDown
		GuiControlGet lengthUnitDropDown
		GuiControlGet speedUnitDropDown
		GuiControlGet numbersFormatDropDown
		GuiControlGet timeFormatDropDown

		setConfigurationValue(configuration, "Localization", "MassUnit", ["Kilogram", "Pound"][massUnitDropDown])
		setConfigurationValue(configuration, "Localization", "PressureUnit", ["BAR", "PSI", "KPa"][pressureUnitDropDown])
		setConfigurationValue(configuration, "Localization", "VolumeUnit", ["Liter", "Gallon"][volumeUnitDropDown])
		setConfigurationValue(configuration, "Localization", "LengthUnit", ["Meter", "Foot"][lengthUnitDropDown])
		setConfigurationValue(configuration, "Localization", "SpeedUnit", ["km/h", "mph"][speedUnitDropDown])

		setConfigurationValue(configuration, "Localization", "NumbersFormat", ["#.##", "#,##"][numbersFormatDropDown])
		setConfigurationValue(configuration, "Localization", "TimeFormat", ["H:M:S.##", "H:M:S,##", "S.##", "S,##"][timeFormatDropDown])
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
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#localization-editor
}