;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Message Popup                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Localization.ahk"
#Include "MultiMap.ahk"
#Include "GUI.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showMessage(message, title := false, icon := kUndefined, duration := 1000
		  , x := "Center", y := kUndefined, width := 400, height := 100, *) {
	local screenLeft, screenRight, screenTop, screenBottom, messageGui
	local innerWidth := width - 16

	static popupPosition

	if !isSet(popupPosition)
		popupPosition := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
										, "General", "Popup Position", "Bottom")

	if (y = kUndefined)
		y := popupPosition

	messageGui := Window()

	if (icon = kUndefined)
		icon := "Information.ico"

	if (!title || (title = ""))
		title := translate("Modular Simulator Controller System")

	messageGui.SetFont("s10 Bold")
	messageGui.Add("Text", "x8 y8 W" . innerWidth . " +0x200 +0x1 BackgroundTrans", title)
	messageGui.SetFont()

	if icon {
		messageGui.Add("Picture", "w50 h50", messageGui.Theme.RecolorizeImage(kIconsDirectory . icon))

		innerWidth -= 66

		messageGui.Add("Text", "X74 YP+5 W" . innerWidth . " H" . height, message)
	}
	else
		messageGui.Add("Text", "X8 YP+30 W" . innerWidth . " H" . height, message)

	if InStr(popupPosition, "2nd Screen")
		MonitorGetWorkArea(1 + ((MonitorGetCount() > 1) ? 1 : 0), &screenLeft, &screenTop, &screenRight, &screenBottom)
	else
		MonitorGetWorkArea(, &screenLeft, &screenTop, &screenRight, &screenBottom)

	if !isInteger(x)
		switch x, false {
			case "Left":
				x := 25
			case "Right":
				x := screenRight - width - 25
			default:
				x := Round(screenLeft + ((screenRight - screenLeft) / 2) - (width / 2))
		}

	if !isInteger(y)
		switch y, false {
			case "Top", "2nd Screen Top":
				y := screenTop + 25
			case "Bottom", "2nd Screen Bottom":
				y := screenBottom - height - 25
			default:
				y := Round(screenTop + ((screenBottom - screenTop) / 2) - (height / 2))
		}

	messageGui.Opt("+AlwaysOnTop")
	messageGui.Show("X" . x . " Y" . y . " W" . width . " H" . height . " NoActivate")

	Sleep(duration)

	messageGui.Destroy()
}