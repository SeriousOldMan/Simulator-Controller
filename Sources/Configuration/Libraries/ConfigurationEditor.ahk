;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ConfigurationItemList.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vResult = false


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kConfigurationEditor = false

global kApply = "apply"
global kOk = "ok"
global kCancel = "cancel"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vShowTriggerDetector = false
global vTriggerDetectorCallback = false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationEditor                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global saveModeDropDown

class ConfigurationEditor extends ConfigurationItem {
	iWindow := "SE"
	iGeneralTab := false
	
	iConfigurators := []
	
	iDevelopment := false
	iSaveMode := false
	
	Configurators[] {
		Get {
			return this.iConfigurators
		}
	}
	
	AutoSave[] {
		Get {
			return (this.iSaveMode = "Auto")
		}
	}
	
	Window[] {
		Get {
			return this.iWindow
		}
	}
	
	__New(development, configuration) {
		this.iDevelopment := development
		this.iGeneralTab := new GeneralTab(development, configuration)
		
		base.__New(configuration)
		
		ConfigurationEditor.Instance := this
	}
	
	registerConfigurator(label, configurator) {
		this.Configurators.Push(Array(label, configurator))
	}
	
	unregisterConfigurator(labelOrConfigurator) {
		for ignore, configurator in this.Configurators
			if ((configurator[1] = labelOrConfigurator) || (configurator[2] = labelOrConfigurator)) {
				this.Configurators.RemoveAt(A_Index)
			
				break
			}
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, Bold, Arial

		Gui %window%:Add, Text, w478 Center gmoveConfigurationEditor, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w478 cBlue Center gopenConfigurationDocumentation, % translate("Configuration")

		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Button, x232 y528 w80 h23 Default gsaveAndExit, % translate("Save")
		Gui %window%:Add, Button, x320 y528 w80 h23 gcancelAndExit, % translate("&Cancel")
		Gui %window%:Add, Button, x408 y528 w77 h23 gsaveAndStay, % translate("&Apply")
		
		choices := ["Auto", "Manual"]
		chosen := inList(choices, saveModeDropDown)
		
		Gui %window%:Add, Text, x8 y528 w55 h23 +0x200, % translate("Save")
		Gui %window%:Add, DropDownList, x63 y528 w75 AltSubmit Choose%chosen% gupdateSaveMode VsaveModeDropDown, % values2String("|", map(choices, "translate")*)
		
		labels := []
		
		for ignore, configurator in this.Configurators
			labels.Push(configurator[1])

		Gui %window%:Add, Tab3, x8 y48 w478 h472 -Wrap, % values2String("|", concatenate(Array(translate("General")), labels)*)
		
		tab := 1
		
		Gui %window%:Tab, % tab++
		
		this.iGeneralTab.createGui(this, 16, 80, 458, 425)
		
		for ignore, configurator in this.Configurators {
			Gui %window%:Tab, % tab++
		
			configurator[2].createGui(this, 16, 80, 458, 425)
		}
	}
	
	registerWidget(plugin, widget) {
		GuiControl Show, %widget%
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iSaveMode := getConfigurationValue(configuration, "General", "Save", "Manual")
		
		saveModeDropDown := this.iSaveMode
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		GuiControlGet saveModeDropDown
		
		this.iSaveMode := ["Auto", "Manual"][saveModeDropDown]
		
		setConfigurationValue(configuration, "General", "Save", this.iSaveMode)
		
		this.iGeneralTab.saveToConfiguration(configuration)
		
		if this.iDevelopment
			this.iDevelopmentTab.saveToConfiguration(configuration)
		
		for ignore, configurator in this.Configurators
			configurator[2].saveToConfiguration(configuration)
	}
	
	show() {
		static first := true
		
		window := this.Window
		
		if first {
			first := false
			
			Gui %window%:Show, AutoSize Center
		}
		else
			Gui %window%:Show
	}
	
	hide() {
		window := this.Window
		
		Gui %window%:Hide
	}
	
	close() {
		window := this.Window
		
		Gui %window%:Destroy
	}
	
	toggleTriggerDetector(callback := false) {
		if callback {
			if !vShowTriggerDetector
				vTriggerDetectorCallback := callback
		}
		else
			vTriggerDetectorCallback := false
	
		vShowTriggerDetector := !vShowTriggerDetector
		
		if vShowTriggerDetector
			SetTimer showTriggerDetector, -100
	}
	
	getSimulators() {
		return this.iGeneralTab.getSimulators()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveAndExit() {
	vResult := kOk
}

cancelAndExit() {
	vResult := kCancel
}

saveAndStay() {
	vResult := kApply
}

moveConfigurationEditor() {
	moveByMouse(ConfigurationEditor.Instance.Window)
}

updateSaveMode() {
	GuiControlGet saveModeDropDown
	
	ConfigurationEditor.Instance.iSaveMode := ["Auto", "Manual"][saveModeDropDown]
}

openConfigurationDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;


showTriggerDetector() {
	returnHotKey := vTriggerDetectorCallback
	joystickNumbers := []
	
	vTriggerDetectorCallback := false

	Loop 16 { ; Query each joystick number to find out which ones exist.
		GetKeyState joyName, %A_Index%JoyName
		
		if (joyName != "")
			joystickNumbers.Push(A_Index)
	}

	if (joystickNumbers.Length() == 0) {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Warning")
		MsgBox 262192, %title%, % translate("No controller detected...")
		OnMessage(0x44, "")
		
		vShowTriggerDetector := false
	}

	if vShowTriggerDetector {
		found := false
		
		Loop {
			if GetKeyState("Esc", "P")
				vShowTriggerDetector := false
	
			if (vTriggerDetectorCallback && (returnHotKey != vTriggerDetectorCallback))
				returnHotKey := vTriggerDetectorCallback
			
			joystickNumber := joystickNumbers[1]
			
			joystickNumbers.RemoveAt(1)
			joystickNumbers.Push(joystickNumber)
		
			SetFormat Float, 03  ; Omit decimal point from axis position percentages.
		
			GetKeyState joy_buttons, %joystickNumber%JoyButtons
			GetKeyState joy_name, %joystickNumber%JoyName
			GetKeyState joy_info, %joystickNumber%JoyInfo

			if !vShowTriggerDetector {
				ToolTip, , , 1
				
				break
			}
			
			buttons_down := ""
			
			Loop %joy_buttons%
			{
				GetKeyState joy%A_Index%, %joystickNumber%joy%A_Index%
		
				if (joy%A_Index% = "D") {
					buttons_down = %buttons_down%%A_Space%%A_Index%
					
					found := A_Index
				}
			}
	
			GetKeyState joyX, %joystickNumber%JoyX
			
			axis_info = X%joyX%
			
			GetKeyState joyY, %joystickNumber%JoyY
	
			axis_info = %axis_info%%A_Space%%A_Space%Y%joyY%
	
			IfInString joy_info, Z
			{
				GetKeyState joyZ, %joystickNumber%JoyZ

				axis_info = %axis_info%%A_Space%%A_Space%Z%joyZ%
			}
			
			IfInString joy_info, R
			{
				GetKeyState joyR, %joystickNumber%JoyR
		
				axis_info = %axis_info%%A_Space%%A_Space%R%joyR%
			}
			
			IfInString joy_info, U
			{
				GetKeyState joyU, %joystickNumber%JoyU
		
				axis_info = %axis_info%%A_Space%%A_Space%U%joyU%
			}
			
			IfInString joy_info, V
			{
				GetKeyState joyV, %joystickNumber%JoyV
		
				axis_info = %axis_info%%A_Space%%A_Space%V%joyV%
			}
			
			IfInString joy_info, P
			{
				GetKeyState joyp, %joystickNumber%JoyPOV
				
				axis_info = %axis_info%%A_Space%%A_Space%POV%joyp%
			}
			
			buttonsDown := translate("Buttons Down:")
			
			ToolTip %joy_name% (#%joystickNumber%):`n%axis_info%`n%buttonsDown% %buttons_down%, , , 1
						
			if found {
				if returnHotkey
					%returnHotkey%(joystickNumber . "Joy" . found)
				else
					Sleep 2000
				
				found := false
			}
			else				
				Sleep 750
			
			if vResult
				break
		}
	}
}

setButtonIcon(buttonHandle, file, index := 1, options := "") {
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