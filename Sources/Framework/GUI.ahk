;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - GUI Functions                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Debug.ahk
#Include ..\Framework\Strings.ahk
#Include ..\Framework\Localization.ahk
#Include ..\Framework\Configuration.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getControllerActionDefinitions(type) {
	local fileName := ("Controller Action " . type . "." . getLanguage())
	local definitions, section, values, key, value

	if (!FileExist(kTranslationsDirectory . fileName) && !FileExist(kUserTranslationsDirectory . fileName))
		fileName := ("Controller Action " . type . ".en")

	definitions := readConfiguration(kTranslationsDirectory . fileName)

	for section, values in readConfiguration(kUserTranslationsDirectory . fileName)
		for key, value in values
			setConfigurationValue(definitions, section, key, value)

	return definitions
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

setButtonIcon(buttonHandle, file, index := 1, options := "") {
	local ptrSize, button_il, normal_il, L, T, R, B, A, W, H, S, DW, PTR
	local BCM_SETIMAGELIST

;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
}

fixIE(version := 0, exeName := "") {
	local previousValue

	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := {7: 7000, 8: 8888, 9: 9999, 10: 10001, 11: 11001}

	if versions.HasKey(version)
		version := versions[version]

	if !exeName {
		if A_IsCompiled
			exeName := A_ScriptName
		else
			SplitPath A_AhkPath, exeName
	}

	RegRead previousValue, HKCU, %key%, %exeName%

	if (version = "") {
		RegDelete, HKCU, %key%, %exeName%
		RegDelete, HKLM, %key%, %exeName%
	}
	else {
		RegWrite, REG_DWORD, HKCU, %key%, %exeName%, %version%
		RegWrite, REG_DWORD, HKLM, %key%, %exeName%, %version%
	}

	return previousValue
}

moveByMouse(window, descriptor := false) {
	local curCoordMode := A_CoordModeMouse
	local anchorX, anchorY, winX, winY, newX, newY, x, y, w, h
	local curCoordMode, anchorX, anchorY, winX, winY, x, y, w, h, newX, newY, settings

	if window is not Alpha
		window := A_Gui

	CoordMode Mouse, Screen

	try {
		MouseGetPos anchorX, anchorY
		WinGetPos winX, winY, w, h, A

		newX := winX
		newY := winY

		while GetKeyState("LButton", "P") {
			MouseGetPos x, y

			newX := winX + (x - anchorX)
			newY := winY + (y - anchorY)

			Gui %window%:Show, X%newX% Y%newY%
		}

		if descriptor {
			settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

			setConfigurationValue(settings, "Window Positions", descriptor . ".X", newX)
			setConfigurationValue(settings, "Window Positions", descriptor . ".Y", newY)

			writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)
		}
	}
	finally {
		CoordMode Mouse, curCoordMode
	}
}

getWindowPosition(descriptor, ByRef x, ByRef y) {
	local settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")
	local posX := getConfigurationValue(settings, "Window Positions", descriptor . ".X", kUndefined)
	local posY := getConfigurationValue(settings, "Window Positions", descriptor . ".Y", kUndefined)
	local count, screen, screenLeft, screenRight, screenTop, screenBottom


	if ((posX == kUndefined) || (posY == kUndefined))
		return false
	else {
		SysGet count, MonitorCount

		loop %count% {
			SysGet, screen, MonitorWorkArea, %A_Index%

			if ((posX >= screenLeft) && (posX <= screenRight) && (posY >= screenTop) && (posY <= screenBottom)) {
				x := posX
				y := posY

				return true
			}
		}

		return false
	}
}

translateMsgBoxButtons(buttonLabels) {
	local curDetectHiddenWindows := A_DetectHiddenWindows
	local index, label

    DetectHiddenWindows, On

	try {
		Process, Exist

		If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
			for index, label in buttonLabels
				try {
					ControlSetText Button%index%, % translate(label)
				}
				catch exception {
					logError(exception)
				}
		}
	}
	finally {
		DetectHiddenWindows %curDetectHiddenWindows%
	}
}

getControllerActionLabels() {
	return getControllerActionDefinitions("Labels")
}

getControllerActionIcons() {
	local icons := getControllerActionDefinitions("Icons")
	local section, values, key, value

	for section, values in icons
		for key, value in values
			values[key] := substituteVariables(value)

	return icons
}