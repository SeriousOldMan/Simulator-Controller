;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Message Popup                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Localization.ahk
#Include ..\Framework\Configuration.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showMessage(message, title := false, icon := "__Undefined__", duration := 1000
		  , x := "Center", y := "__Undefined__", width := 400, height := 100) {
	local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom
	local innerWidth := width - 16

	static popupPosition := false

	if (y = kUndefined) {
		if !popupPosition
			popupPosition := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Application Settings.ini")
																   , "General", "Popup Position", "Bottom")

		y := popupPosition
	}

	if (icon = kUndefined)
		icon := "Information.png"

	if (!title || (title = ""))
		title := translate("Modular Simulator Controller System")

	Gui MSGW:-Border -Caption
	Gui MSGW:Color, D0D0D0, D8D8D8
	Gui MSGW:Font, s10 Bold
	Gui MSGW:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans, %title%
	Gui MSGW:Font

	if icon {
		Gui MSGW:Add, Picture, w50 h50, % kIconsDirectory . Icon

		innerWidth -= 66

		Gui MSGW:Add, Text, X74 YP+5 W%innerWidth% H%height%, % message
	}
	else
		Gui MSGW:Add, Text, X8 YP+30 W%innerWidth% H%height%, % message

	SysGet mainScreen, MonitorWorkArea

	if x is not Integer
		switch x {
			case "Left":
				x := 25
			case "Right":
				x := mainScreenRight - width - 25
			default:
				x := "Center"
		}

	if y is not Integer
		switch y {
			case "Top":
				y := 25
			case "Bottom":
				y := mainScreenBottom - height - 25
			default:
				y := "Center"
		}

	Gui MSGW:+AlwaysOnTop
	Gui MSGW:Show, X%x% Y%y% W%width% H%height% NoActivate

	Sleep %duration%

	Gui MSGW:Destroy
}