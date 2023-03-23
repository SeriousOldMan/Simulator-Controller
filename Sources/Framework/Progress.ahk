;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Progress Bar                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Constants.ahk"
#Include "..\Framework\Variables.ahk"
#Include "..\Framework\Localization.ahk"
#Include "..\Framework\MultiMap.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showProgress(options := unset) {
	local x, y, w, h, color, count
	local screenLeft, screenRight, screenTop, screenBottom
	local newOptions, key, value

	static popupPosition

	static progressGui := false
	static progressBar
	static progressTitle
	static progressMessage

	if (isSet(options) && !options && progressGui) {
		progressGui.Destroy()

		progressGui := false
	}
	else {
		if !progressGui {
			if !isSet(popupPosition)
				popupPosition := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
												, "General", "Popup Position", "Bottom")

			if !isSet(options)
				options := {}

			w := (options.HasProp("Width") ? options.Width : 280)
			h := 90

			if options.HasProp("X")
				x := options.X
			else
				x := "Center"

			if options.HasProp("Y")
				y := options.Y
			else
				y := popupPosition

			if InStr(popupPosition, "2nd Screen")
				MonitorGetWorkArea(1 + ((MonitorGetCount() > 1) ? 1 : 0), &screenLeft, &screenTop, &screenRight, &screenBottom)
			else
				MonitorGetWorkArea(, &screenLeft, &screenTop, &screenRight, &screenBottom)

			if !isInteger(x)
				switch x, false {
					case "Left":
						x := 25
					case "Right":
						x := screenRight - w - 25
					default:
						x := Round(screenLeft + ((screenRight - screenLeft) / 2) - (w / 2))
				}

			if !isInteger(y)
				switch y, false {
					case "Top", "2nd Screen Top":
						y := screenTop + 25
					case "Bottom", "2nd Screen Bottom":
						y := screenBottom - h - 25
					default:
						y := Round(screenTop + ((screenBottom - screenTop) / 2) - (h / 2))
				}

			color := (options.HasProp("Color") ? options.Color : "Green")

			progressGui := Gui()

			progressGui.Opt("-Border") ; -Caption
			progressGui.BackColor := "D0D0D0"

			progressGui.SetFont("s10 Bold", "Arial")

			progressTitle := progressGui.Add("Text", "x10 w" . (w - 20) . " Center")

			progressBar := progressGui.Add("Progress", "x10 y30 w" . (w - 20) . " h20 c" . color . " BackgroundGray", "0")

			progressGui.SetFont("s8 Norm", "Arial")

			progressMessage := progressGui.Add("Text", "x10 y55 w" . (w - 20) . " Center")

			progressGui.Opt("+AlwaysOnTop")
			progressGui.Show("x" . x . " y" . y . " AutoSize NoActivate")
		}

		if options.HasProp("title")
			progressTitle.Value := options.Title

		if options.HasProp("message")
			progressMessage.Value := options.Message

		if options.HasProp("progress")
			progressBar.Value := Round(options.Progress)

		if options.HasProp("color")
			progressBar.Opt("+c" . options.Color)
	}

	return progressGui
}

hideProgress() {
	showProgress(false)
}