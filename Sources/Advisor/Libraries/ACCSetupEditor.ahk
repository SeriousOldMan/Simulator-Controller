;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for ACC            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                           Local Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\JSON.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACCSetup                                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACCSetup extends Setup {
	iOriginalData := false
	iModifiedData := false
	
	Data[original := false] {
		Get {
			return (original ? this.iOriginalData : this.iModifiedData)
		}
	}
	
	__New(editor, originalFileName := false) {
		iEditor := editor
		
		base.__New(editor, originalFileName)
		
		this.iOriginalData := JSON.parse(this.Setup[true])
		this.iModifiedData := JSON.parse(this.Setup[false])
	}
	
	getValue(setting, original := false, default := false) {
		data := this.Data[original]
		
		for ignore, path in string2Values(".", getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting)) {
			if InStr(path, "[") {
				path := string2Values("[", SubStr(path, 1, StrLen(path) - 1))
				
				if data.HasKey(path[1]) {
					data := data[path[1]]
					
					if data.HasKey(path[2])
						data := data[path[2]]
					else
						return default
				}
				else
					return default
			}
			else if data.HasKey(path)
				data := data[path]
			else
				return default
		}
		
		return data
	}
	
	setValue(setting, value) {
		data := this.Data
		elements := string2Values(".", getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting))
		length := elements.Length()
		
		try {
			for index, path in elements {
				last := (index == length)
			
				if InStr(path, "[") {
					path := string2Values("[", SubStr(path, 1, StrLen(path) - 1))
					
					if data.HasKey(path[1]) {
						data := data[path[1]]
						
						if data.HasKey(path[2]) {
							if last
								return (data[path[2]] := value)
							else
								data := data[path[2]]
						}
						else
							return value
					}
					else
						return value
				}
				else if data.HasKey(path) {
					if last
						return (data[path] := value)
					else
						data := data[path]
				}
				else
					return value
			}
			
			return (this.iModifiedData := value)
		}
		finally {
			this.Setup := JSON.print(this.Data, false, "  ")
		}
	}
	
	reset() {
		base.reset()
		
		this.iModifiedData := JSON.parse(this.Setup[false])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACCSetupEditor                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACCSetupEditor extends SetupEditor {
	editSetup(theSetup := false) {
		if !theSetup
			theSetup := this.chooseSetup(false)

		if theSetup
			return base.editSetup(theSetup)
		else
			return false
	}
	
	chooseSetup(load := true) {
		title := translate("Load ACC Setup File...")
	
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %A_MyDocuments%\Assetto Corsa Competizione\Setups, %title%, Setup (*.json)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACCSetup(this, fileName)
			
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
		
		this.Settings := []
		
		for ignore, setting in this.Advisor.Settings {
			handler := this.createSettingHandler(setting)
			
			originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
			modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))
			
			if (originalValue = modifiedValue)
				value := originalValue
			else if (modifiedValue > originalValue)
				value := (modifiedValue . A_Space . translate("(") . "+" . (modifiedValue - originalValue) . translate(")"))
			else
				value := (modifiedValue . A_Space . translate("(") . "-" . (originalValue - modifiedValue) . translate(")"))
			
			LV_Add("", settingsLabels[setting], value, settingsUnits[setting])
			
			this.Settings.Push(setting)
		}
		
		LV_ModifyCol()
		
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
	}
	
	updateSetting(setting, newValue) {
		local setup := this.Setup
		
		setup.setValue(setting, newValue)
		
		row := inList(this.Settings, setting)
		
		window := this.Window
		
		Gui %window%:Default
		
		Gui ListView, % this.SettingsListView
		
		handler := this.createSettingHandler(setting)
		originalValue := handler.convertToDisplayValue(setup.getValue(setting, true))
		modifiedValue := handler.convertToDisplayValue(setup.getValue(setting, false))
		
		if (originalValue = modifiedValue)
			value := originalValue
		else if (modifiedValue > originalValue)
			value := (modifiedValue . A_Space . translate("(") . "+" . (modifiedValue - originalValue) . translate(")"))
		else
			value := (modifiedValue . A_Space . translate("(") . "-" . (originalValue - modifiedValue) . translate(")"))
		
		LV_Modify(row, "+Vis Col2", value)
		LV_ModifyCol(2, "AutoHdr")
	}
}