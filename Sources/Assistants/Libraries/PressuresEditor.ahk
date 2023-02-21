;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pressures Editor                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Framework.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PressuresEditor                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global pressuresViewer
global temperaturesDropDown
global compoundDropDown

global upPressureButton
global downPressureButton
global clearPressureButton

class PressuresEditor {
	iSessionDatabase := false
	iClosed := false

	iPressuresDatabase := false

	iPressuresListView := false

	iTemperatures := []

	SessionDatabase[] {
		Get {
			return this.iSessionDatabase
		}
	}

	PressuresDatabase[] {
		Get {
			return this.iPressuresDatabase
		}
	}

	Temperatures[key := false] {
		Get {
			return (key ? this.iTemperatures[key] : this.iTemperatures)
		}
	}

	PressuresListView[] {
		Get {
			return this.iPressuresListView
		}
	}

	__New(sessionDatabase, compound, compoundColor, airTemperature, trackTemperature) {
		this.iSessionDatabase := sessionDatabase
		this.iPressuresDatabase := new TyresDatabase().getTyresDatabase(sessionDatabase.SelectedSimulator
																	  , sessionDatabase.SelectedCar
																	  , sessionDatabase.SelectedTrack)

		PressuresEditor.Instance := this

		this.createGui(compound, compoundColor, airTemperature, trackTemperature)
	}

	createGui(tyreCompound, tyreCompoundColor, airTemperature, trackTemperature) {
		local sessionDatabase := this.SessionDatabase
		local compounds := []
		local temperatures := []
		local weather, ignore, row, compound, temperature, chosen

		Gui PE:Default

		Gui PE:-Border ; -Caption
		Gui PE:Color, D0D0D0, D8D8D8

		Gui PE:Font, s10 Bold, Arial

		Gui PE:Add, Text, w388 Center gmovePressuresEditor, % translate("Modular Simulator Controller System")

		Gui PE:Font, s9 Norm, Arial
		Gui PE:Font, Italic Underline, Arial

		Gui PE:Add, Text, x158 YP+20 w88 cBlue Center gopenPressuresDocumentation, % translate("Tyre Pressures")

		Gui PE:Font, s8 Norm, Arial

		Gui PE:Add, Text, x8 yp+30 w410 0x10

		Gui PE:Font, Norm, Arial

		Gui PE:Add, Text, x16 yp+10 w80 h23 +0x200, % translate("Simulator")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % sessionDatabase.SelectedSimulator

		Gui PE:Add, Text, x16 yp+20 w80 h23 +0x200, % translate("Car")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % sessionDatabase.getCarName(sessionDatabase.SelectedSimulator, sessionDatabase.SelectedCar)

		Gui PE:Add, Text, x16 yp+20 w80 h23 +0x200, % translate("Track")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % sessionDatabase.getTrackName(sessionDatabase.SelectedSimulator, sessionDatabase.SelectedTrack)

		weather := sessionDatabase.SelectedWeather

		if (weather == true)
			weather := "All"

		Gui PE:Add, Text, x16 yp+20 w80 h23 +0x200, % translate("Weather")
		Gui PE:Add, Text, x100 yp+4 w160 h23, % translate(weather)

		for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
													  , {Select: ["Compound", "Compound.Color", "Temperature.Air", "Temperature.Track"]
													   , By: ["Compound", "Compound.Color", "Temperature.Air", "Temperature.Track"]
													   , Where: {Weather: weather, Type: "Cold", Driver: this.SessionDatabase.SessionDatabase.ID}}) {
			compound := compound(row.Compound, row["Compound.Color"])

			if !inList(compounds, compound)
				compounds.Push(compound)

			temperature := (row["Temperature.Air"] . translate(" / ") . row["Temperature.Track"])

			if !inList(temperatures, temperature)
				temperatures.Push(temperature)
		}

		bubbleSort(compounds)
		bubbleSort(temperatures)

		loop % temperatures.Length()
		{
			temperature := string2Values(translate(" / "), temperatures[A_Index])

			this.Temperatures.Push(Array(temperature[1], temperature[2]))

			temperatures[A_Index] := (Round(convertUnit("Temperature", temperature[1])) . translate(" / ") . Round(convertUnit("Temperature", temperature[2])))
		}

		Gui PE:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Compound")

		if (compounds.Length() > 0) {
			chosen := inList(compounds, tyreCompound)

			if !chosen {
				chosen := 1

				splitCompound(compounds[1], tyreCompound, tyreCompoundColor)
			}
		}
		else
			chosen := 0

		Gui PE:Add, DropDownList, x96 yp w100 Choose%chosen% vcompoundDropDown, % values2String("|", compounds*)

		if (temperatures.Length() > 0) {
			temperature := (Round(convertUnit("Temperature", airTemperature)) . translate(" / ") . Round(convertUnit("Temperature", trackTemperature)))
			chosen := inList(temperatures, temperature)

			if !chosen {
				chosen := 1

				airTemperature := this.Temperatures[1][1]
				trackTemperature := this.Temperatures[1][2]
			}
		}
		else
			chosen := 0

		Gui PE:Add, DropDownList, x205 yp w60 Choose%chosen% vtemperaturesDropDown, % values2String("|", temperatures*)

		Gui PE:Add, Text, x270 yp w140 h23 +0x200, % substituteVariables(translate("Temperature (%unit%)"), {unit: getUnit("Temperature", true)})

		Gui PE:Add, ActiveX, x16 yp+30 w394 h160 Border vpressuresViewer, shell.explorer

		pressuresViewer.Navigate("about:blank")
		pressuresViewer.Document.Write("<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>")

		Gui PE:Add, ListView, x16 yp+170 w394 h160 -Multi -LV0x10 AltSubmit HwndpressuresListViewHandle gchoosePressure, % values2String("|", map(["Tyre", "Pressure", "#"], "translate")*) ; NoSort NoSortHdr

		this.iPressuresListView := pressuresListViewHandle

		Gui PE:Add, Button, x338 yp+162 w23 h23 HWNDupPressureButtonHandle vupPressureButton gupPressure
		Gui PE:Add, Button, xp+24 yp w23 h23 HWNDdownPressureButtonHandle vdownPressureButton gdownPressure
		Gui PE:Add, Button, xp+24 yp w23 h23 HWNDclearPressureButtonHandle vclearPressureButton gclearPressure

		setButtonIcon(upPressureButtonHandle, kIconsDirectory . "Up Arrow.ico", 1, "W12 H12 L6 T6 R6 B6")
		setButtonIcon(downPressureButtonHandle, kIconsDirectory . "Down Arrow.ico", 1, "W12 H12 L4 T4 R4 B4")
		setButtonIcon(clearPressureButtonHandle, kIconsDirectory . "Minus.ico", 1, "W12 H12 L4 T4 R4 B4")

		Gui PE:Font, s8 Norm, Arial

		Gui PE:Add, Text, x8 yp+30 w410 0x10

		Gui PE:Add, Button, x126 yp+10 w80 h23 Default GsavePressuresEditor, % translate("Save")
		Gui PE:Add, Button, x214 yp w80 h23 GcancelPressuresEditor, % translate("&Cancel")

		if ((compounds.Length() > 0) && (temperatures.Length() > 0))
			this.loadPressures(weather, tyreCompound, tyreCompoundColor, airTemperature, trackTemperature)
	}

	editPressures() {
		local x, y

		if getWindowPosition("Session Database.Pressures Editor", x, y)
			Gui PE:Show, x%x% y%y%
		else
			Gui PE:Show

		loop
			Sleep 200
		until this.iClosed

		try {
			if (this.iClosed == kOk) {
				return true
			}
			else
				return false
		}
		finally {
			Gui PE:Destroy
		}
	}

	closeEditor(save) {
		this.iClosed := (save ? kOk : kCancel)
	}

	updateState() {
		local index, count

		Gui PE:Default

		Gui ListView, % this.PressuresListView

		index := LV_GetNext(0)

		if index {
			LV_GetText(count, index, 3)

			GuiControl Enable, upPressureButton

			if (count > 1)
				GuiControl Enable, downPressureButton
			else
				GuiControl Disable, downPressureButton

			GuiControl Enable, clearPressureButton
		}
		else {
			GuiControl Disable, upPressureButton
			GuiControl Disable, downPressureButton
			GuiControl Disable, clearPressureButton
		}
	}

	loadPressures(weather, compound, compoundColor, airTemperature, trackTemperature) {
		local tyres := {FL: translate("Front Left"), FR: translate("Front Right")
					  , RL: translate("Rear Left"), RR: translate("Rear Right")}
		local pressures := []
		local ignore, row, lastTyre

		Gui PE:Default

		Gui ListView, % this.PressuresListView

		LV_Delete()

		for ignore, row in this.PressuresDatabase.query("Tyres.Pressures.Distribution"
													  , {Select: ["Count", "Tyre", "Pressure"]
													   , Where: {Weather: weather, Type: "Cold", Driver: this.SessionDatabase.SessionDatabase.ID
															   , Compound: compound, "Compound.Color": compoundColor
															   , "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature}})
			pressures.Push(Array(tyres[row.Tyre], displayValue("Float", convertUnit("Pressure", row.Pressure)), row.Count))

		bubbleSort(pressures, "comparePressures")

		lastTyre := false

		for ignore, row in pressures
			if (pressures[A_Index][1] = lastTyre)
				pressures[A_Index][1] := ""
			else
				lastTyre := pressures[A_Index][1]

		loop % pressures.Length()
			LV_Add("", pressures[A_Index, 1], pressures[A_Index, 2], pressures[A_Index, 3])

		LV_ModifyCol()

		loop 3
			LV_ModifyCol(A_Index, "AutoHdr")

		this.updateState()
		this.updateStatistics()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

comparePressures(a, b) {
	return (a[1] > b[1])
}

choosePressure() {
	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0))
		PressuresEditor.Instance.updateState()
}

upPressure() {
	local editor := PressuresEditor.Instance
	local index, count

	Gui PE:Default

	Gui ListView, % editor.PressuresListView

	index := LV_GetNext(0)

	if index {
		LV_GetText(count, index, 3)

		LV_Modify(index, "Col3", count + 1)
	}

	editor.updateState()
	editor.updateStatistics()
}

downPressure() {
	local editor := PressuresEditor.Instance
	local index, count

	Gui PE:Default

	Gui ListView, % editor.PressuresListView

	index := LV_GetNext(0)

	if index {
		LV_GetText(count, index, 3)

		LV_Modify(index, "Col3", count - 1)
	}

	editor.updateState()
	editor.updateStatistics()
}

clearPressure() {
	local editor := PressuresEditor.Instance
	local index, tyre, nextTyre

	Gui PE:Default

	Gui ListView, % editor.PressuresListView

	index := LV_GetNext(0)

	if index {
		LV_GetText(tyre, index)

		if ((tyre != "") && (index < LV_GetCount())) {
			LV_GetText(nextTyre, index + 1)

			if (nextTyre = "")
				LV_Modify(index + 1, "", tyre)
		}

		LV_Delete(index)
	}

	editor.updateState()
	editor.updateStatistics()
}

savePressuresEditor() {
	protectionOn()

	try {
		PressuresEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelPressuresEditor() {
	protectionOn()

	try {
		PressuresEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}

movePressuresEditor() {
	moveByMouse("PE", "Session Database.Pressures Editor")
}

openPressuresDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database
}