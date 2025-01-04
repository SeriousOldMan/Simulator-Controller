;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for LMU            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                           Local Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Plugins\Libraries\LMURESTProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LMUSetup                                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class LMUSetup extends FileSetup {
	iHeader := ""

	iOriginalData := false
	iModifiedData := false

	Header {
		Get {
			return this.iHeader
		}
	}

	Data[original := false] {
		Get {
			return (original ? this.iOriginalData : this.iModifiedData)
		}
	}

	Setup[original := false] {
		Get {
			return super.Setup[original]
		}

		Set {
			local setup, settings

			setup := parseMultiMap(value, false)

			settings := this.Editor.Settings

			if !settings.Has("Aero.Height.Front.Right")
				setMultiMapValue(setup, "FRONTRIGHT", "RideHeightSetting", getMultiMapValue(setup, "FRONTLEFT", "RideHeightSetting"))

			if !settings.Has("Aero.Height.Rear.Right")
				setMultiMapValue(setup, "REARRIGHT", "RideHeightSetting", getMultiMapValue(setup, "REARLEFT", "RideHeightSetting"))

			return (super.Setup[original] := (this.Header . StrReplace(StrReplace(printMultiMap(setup), "=true", "=1"), "=false", "=0")))
		}
	}

	__New(editor, originalFileName := false, modifiedFileName := false) {
		local header := ""
		local line

		iEditor := editor

		super.__New(editor, originalFileName, modifiedFileName)

		this.iOriginalData := parseMultiMap(this.Setup[true], false)
		this.iModifiedData := parseMultiMap(this.Setup[false], false)

		loop Parse, this.Setup[true], "`n", "`r" {
			line := Trim(A_LoopField)

			if (InStr(line, "[") = 1)
				break
			else
				header := (header . line . "`n")
		}

		this.iHeader := header
	}

	valueAvailable(setting, original := false) {
		/*
		setting := StrSplit(getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting), ".", , 2)

		return (getMultiMapValue(this.Data[original], setting[1], setting[2], kUndefined) != kUndefined)
		*/

		return super.valueAvailable(setting, original)
	}

	getValue(setting, original := false, default := false) {
		local data := this.Data[original]
		local path := StrSplit(getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting), ".", , 2)

		try {
			if (getMultiMapValue(data, path[1], path[2], kUndefined) != kUndefined)
				return StrSplit(getMultiMapValue(data, path[1], path[2]), "//", , 2)[1]
			else if (getMultiMapValue(data, path[1], "//" . path[2], kUndefined) != kUndefined)
				return StrSplit(getMultiMapValue(data, path[1], "//" . path[2]), "//", , 2)[1]
			else
				throw "Undefined setting..."
		}
		catch Any {
			throw ("Undefined setting `"" . setting . "`" detected in LMUSetupEditor.getValue...")
		}
	}

	setValue(setting, value, display := false) {
		local path := StrSplit(getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting), ".", , 2)
		local data := (display ? display : this.Data)

		try {
			if (getMultiMapValue(data, path[1], path[2], kUndefined) != kUndefined)
				setMultiMapValue(data, path[1], path[2], value) ; . "//" . StrSplit(getMultiMapValue(data, path[1], path[2]), "//", , 2)[2])
			else if (getMultiMapValue(data, path[1], "//" . path[2], kUndefined) != kUndefined)
				setMultiMapValue(data, path[1], path[2], value) ; . "//" . StrSplit(getMultiMapValue(data, path[1], "//" . path[2]), "//", , 2)[2])

			if !display
				this.Setup := this.printSetup(data)
		}
		catch Any {
			throw ("Undefined setting `"" . setting . "`" detected in LMUSetupEditor.getValue...")
		}

		return value
	}

	printSetup(setup) {
		local display := setup.Clone()
		local ignore, setting, section, values, key, value

		for section, values in setup
			for key, value in values
				setMultiMapValue(display, section, key, value)

		for ignore, setting in this.Editor.Workbench.Settings
			if this.valueAvailable(setting, true)
				this.setValue(setting, this.getValue(setting, !this.Enabled[setting]), display)

		return (this.Header . printMultiMap(display))
	}

	enable(setting) {
		super.enable(setting)

		if setting
			this.setValue(setting, this.getValue(setting))
	}

	disable(setting) {
		super.disable(setting)

		if setting
			this.setValue(setting, this.getValue(setting))
	}

	reset() {
		super.reset()

		this.iModifiedData := parseMultiMap(this.Setup[false], false)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LMUSetupEditor                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class LMUSetupEditor extends FileSetupEditor {
	SetupClass {
		Get {
			return "LMUSetup"
		}
	}

	chooseSetup(load := true) {
		local lmuApplication := Application("Le Mans Ultimate", kSimulatorConfiguration)
		local car := SessionDatabase.getCarCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedCar[false])
		local track := SessionDatabase.getTrackCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedTrack[false])
		local directory := ""
		local fileName, theSetup

		if (lmuApplication.ExePath != "") {
			SplitPath(lmuApplication.ExePath, , &directory)

			directory := normalizeDirectoryPath(directory . "\UserData\player\Settings")
		}

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			loop Files, directory "\*.*", "D"
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . A_LoopFileName)

					break
				}

		if this.Window {
			this.Workbench.Window.Opt("-OwnDialogs")

			this.Window.Opt("+OwnDialogs")
		}
		else
			this.Workbench.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, 1, directory, translate("Load LMU Setup File..."), "Setup (*.svm)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if fileName {
			theSetup := LMUSetup(this, fileName)

			if load
				return this.loadSetup(&theSetup)

			return theSetup
		}
		else
			return false
	}

	saveSetup() {
		local fileName := this.Setup.FileName
		local directory, text

		if (fileName = this.Setup.FileName[true])
			SplitPath(fileName, , &directory)
		else
			directory := fileName

		if this.Window
			this.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := withBlockedWindows(FileSelect, "S17", directory, translate("Save LMU Setup File..."), "Setup (*.svm)")
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			if !InStr(fileName, ".svm")
				fileName := (fileName . ".svm")

			deleteFile(fileName)

			text := this.Setup.Setup

			FileAppend(text, fileName)

			this.Setup.FileName := fileName

			if Application("Le Mans Ultimate", kSimulatorConfiguration).isRunning()
				LMURESTProvider.GarageData().refreshSetups()
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LMUSetupComparator                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class LMUSetupComparator extends FileSetupComparator {
	chooseSetup(type, load := true) {
		local lmuApplication := Application("Le Mans Ultimate", kSimulatorConfiguration)
		local car := SessionDatabase.getCarCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedCar[false])
		local track := SessionDatabase.getTrackCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedTrack[false])
		local directory := ""
		local fileName, theSetup, ignore

		if (lmuApplication.ExePath != "") {
			SplitPath(lmuApplication.ExePath, , &directory)

			directory := normalizeDirectoryPath(directory . "\UserData\player\Settings")
		}

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			loop Files, directory "\*.*", "D"
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . A_LoopFileName)

					break
				}

		if this.Window {
			this.Editor.Window.Opt("-OwnDialogs")

			this.Window.Opt("+OwnDialogs")
		}
		else
			this.Editor.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, 1, directory, (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" LMU Setup File...")), "Setup (*.svm)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if fileName {
			theSetup := ACSetup(this, fileName)

			if load {
				if (type = "A")
					this.loadSetups(&theSetup)
				else
					this.loadSetups(&ignore := false, &theSetup)
			}

			return theSetup
		}
		else
			return false
	}
}