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
	local secondScreen, secondScreenLeft, secondScreenRight, secondScreenTop, secondScreenBottom

	static popupPosition := false

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
			if !popupPosition
				popupPosition := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
													 , "General", "Popup Position", "Bottom")

			if options.Has("X")
				x := options.X
			else if options.Has("Width")
				x := Round((A_ScreenWidth - options.Width) / 2)
			else
				x := Round((A_ScreenWidth - 300) / 2)

			if options.Has("Y")
				y := options.Y
			else {
				count := MonitorGetCount()

				if (count > 1)
					MonitorGetWorkArea(2, &secondScreenLeft, &secondScreenTop, &secondScreenRight, &secondScreenBottom)

				if ((count > 1) && (popupPosition = "2nd Screen Top"))
					y := (secondScreenTop + 150)
				else if ((count > 1) && (popupPosition = "2nd Screen Bottom"))
					y := (secondScreenTop + (secondScreenBottom - secondScreenTop) - 150)
				else
					y := ((popupPosition = "Top") ? 150 : A_ScreenHeight - 150)
			}

			if options.Has("Width")
				w := (options.Width - 20)
			else
				w := 280

			color := (options.Has("Color") ? options.color : "Green")

			progressGui := Gui()
			
			progressGui.Opt("-Border") ; -Caption
			progressGui.BackColor := "D0D0D0"

			progressGui.SetFont("s10 Bold", "Arial")

			progressTitle := progressGui.Add("Text", "x10 w" . w . " Center vvProgressTitle")

			progressBar := progressGui.Add("Progress", "x10 y30 w" . w . " h20 c" . color . " BackgroundGray vvProgressBar", "0")

			progressGui.SetFont("s8 Norm", "Arial")

			progressMessage := progressGui.Add("Text", "x10 y55 w" . w . " Center vvProgressMessage")

			progressGui.Opt("+AlwaysOnTop")
			progressGui.Show("x" . x . " y" . y . " AutoSize NoActivate")
		}

		if isSet(options) {
			if options.Has("title")
				progressTitle.Value := options.title

			if options.Has("message")
				progressMessage.Value := options.message

			if options.Has("progress")
				progressBar.Value := Round(options.progress)

			if options.Has("color") {
				color := options.color

				progressBar.Options("+c" . color)
			}
		}
	}

	return progressGui
}

hideProgress() {
	showProgress(false)
}