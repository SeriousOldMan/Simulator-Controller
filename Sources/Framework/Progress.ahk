;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Progress Bar                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "Localization.ahk"
#Include "MultiMap.ahk"
#Include "GUI.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                     Public Classes Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

class ProgressWindow extends Window {
	static sPopupPosition := false

	iProgressBar := false
	iTitle := false
	iMessage := false

	static PopupPosition {
		Get {
			return ProgressWindow.sPopupPosition
		}
	}

	ProgressBar {
		Get {
			return this.iProgressBar
		}
	}

	Title {
		Get {
			return this.iTitle
		}
	}

	Message {
		Get {
			return this.iMessage
		}
	}

	static showProgress(options) {
		local x, y, w, h, color, count
		local screenLeft, screenRight, screenTop, screenBottom
		local progressGui

		if !ProgressWindow.sPopupPosition
			ProgressWindow.sPopupPosition := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
															, "General", "Popup Position", "Bottom")

		w := (options.HasProp("Width") ? options.Width : 280)
		h := 90

		if options.HasProp("X")
			x := options.X
		else
			x := "Center"

		if options.HasProp("Y")
			y := options.Y
		else
			y := ProgressWindow.PopupPosition

		if InStr(ProgressWindow.PopupPosition, "2nd Screen")
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

		progressGui := ProgressWindow()

		progressGui.SetFont("s10 Bold", "Arial")

		progressGui.iTitle := progressGui.Add("Text", "x10 w" . (w - 20) . " Center")

		progressGui.iProgressBar := progressGui.Add("Progress", "x10 y30 w" . (w - 20) . " h20 c" . color . " BackgroundGray", "0")

		progressGui.SetFont("s8 Norm", "Arial")

		progressGui.iMessage := progressGui.Add("Text", "x10 y55 w" . (w - 20) . " Center")

		progressGui.Opt("+AlwaysOnTop")
		progressGui.Show("x" . x . " y" . y . " AutoSize NoActivate")

		progressGui.updateProgress(options)

		return progressGui
	}

	updateProgress(options) {
		try {
			if options.HasProp("title")
				this.Title.Value := options.Title

			if options.HasProp("message")
				this.Message.Value := options.Message

			if options.HasProp("progress")
				this.ProgressBar.Value := Round(options.Progress)

			if options.HasProp("color")
				this.ProgressBar.Opt("+c" . options.Color)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	hideProgress() {
		this.Destroy()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showProgress(options := unset) {
	static progressGui := false

	if (isSet(options) && !options && progressGui) {
		progressGui.Destroy()

		progressGui := false
	}
	else {
		if !isSet(options)
			options := {}

		if !progressGui
			progressGui := ProgressWindow.showProgress(options)
		else
			progressGui.updateProgress(options)
	}

	return progressGui
}

hideProgress() {
	showProgress(false)
}