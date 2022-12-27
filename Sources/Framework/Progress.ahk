;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Progress Bar                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Localization.ahk
#Include ..\Framework\Configuration.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vProgressIsOpen := false
global vProgressBar
global vProgressTitle
global vProgressMessage


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showProgress(options) {
	local x, y, w, h, color, count
	local secondScreen, secondScreenLeft, secondScreenRight, secondScreenTop, secondScreenBottom

	static popupPosition := false

	if !vProgressIsOpen {
		if !popupPosition
			popupPosition := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Application Settings.ini")
												 , "General", "Popup Position", "Bottom")

		if options.HasKey("X")
			x := options.X
		else if options.HasKey("Width")
			x := Round((A_ScreenWidth - options.Width) / 2)
		else
			x := Round((A_ScreenWidth - 300) / 2)

		if options.HasKey("Y")
			y := options.Y
		else {
			SysGet count, MonitorCount

			if (count > 1)
				SysGet, secondScreen, MonitorWorkArea, 2

			if ((count > 1) && (popupPosition = "2nd Screen Top"))
				y := (secondScreenTop + 150)
			else if ((count > 1) && (popupPosition = "2nd Screen Bottom"))
				y := (secondScreenTop + (secondScreenBottom - secondScreenTop) - 150)
			else
				y := ((popupPosition = "Top") ? 150 : A_ScreenHeight - 150)
		}

		if options.HasKey("Width")
			w := (options.Width - 20)
		else
			w := 280

		color := options.HasKey("color") ? options.color : "Green"

		Gui Progress:Default
		Gui Progress:-Border ; -Caption
		Gui Progress:Color, D0D0D0, D8D8D8

		Gui Progress:Font, s10 Bold, Arial
		Gui Progress:Add, Text, x10 w%w% Center vvProgressTitle

		Gui Progress:Add, Progress, x10 y30 w%w% h20 c%color% BackgroundGray vvProgressBar, 0

		Gui Progress:Font, s8 Norm, Arial
		Gui Progress:Add, Text, x10 y55 w%w% Center vvProgressMessage

		Gui Progress:+AlwaysOnTop
		Gui Progress:Show, x%x% y%y% AutoSize NoActivate

		vProgressIsOpen := true
	}

	Gui Progress:Default

	if options.HasKey("title")
		GuiControl, , vProgressTitle, % options.title

	if options.HasKey("message")
		GuiControl, , vProgressMessage, % options.message

	if options.HasKey("progress")
		GuiControl, , vProgressBar, % Round(options.progress)

	if options.HasKey("color") {
		color := options.color

		GuiControl +c%color%, vProgressBar
	}

	return "Progress"
}

hideProgress() {
	if vProgressIsOpen {
		Gui Progress:Destroy

		vProgressIsOpen := false
	}
}