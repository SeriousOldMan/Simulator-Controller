;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - GUI Functions                   ;;;
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
#Include "Strings.ahk"
#Include "Localization.ahk"
#Include "MultiMap.ahk"
#Include "Configuration.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\GDIP.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Public Constants Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kScreenResolution := 96

global kSystemColors := CaseInsenseMap("ButtonTextColor", 18, "NormalTextColor", 8, "LinkTextColor", 26
									 , "HighlightTextColor", 14, "HighlightBackColor", 13, "DisabledTextColor", 17
									 , "ControlBackColor", 15, "WinBackColor", 5)


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getControllerActionDefinitions(type) {
	local fileName := ("Controller Action " . type . "." . getLanguage())
	local definitions, section, values, key, value

	if (!FileExist(kTranslationsDirectory . fileName) && !FileExist(kUserTranslationsDirectory . fileName))
		fileName := ("Controller Action " . type . ".en")

	definitions := readMultiMap(kTranslationsDirectory . fileName)

	for section, values in readMultiMap(kUserTranslationsDirectory . fileName)
		for key, value in values
			setMultiMapValue(definitions, section, key, value)

	return definitions
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class Theme {
	static sCurrentTheme := false

	static CurrentTheme {
		Get {
			return Theme.sCurrentTheme
		}

		Set {
			return (Theme.sCurrentTheme := value)
		}
	}

	Descriptor {
		Get {
			throw "Virtual property Theme.Descriptor must be implemented in a subclass"
		}
	}

	WindowBackColor {
		Get {
			return Theme.GetSystemColor("WinBackColor")
		}
	}

	AlternateBackColor {
		Get {
			return this.WindowBackColor
		}
	}

	FieldBackColor {
		Get {
			return this.AlternateBackColor
		}
	}

	ListBackColor[type := "Header"] {
		Get {
			switch type, false {
				case "Background":
					return this.AlternateBackColor
				case "Header":
					return this.FieldBackColor
				case "EvenRow":
					return this.AlternateBackColor
				case "OddRow":
					return this.WindowBackColor
			}
		}
	}

	TableColor[type := "Header"] {
		Get {
			switch type, false {
				case "Background":
					return this.AlternateBackColor
				case "Header":
					return this.FieldBackColor
				case "EvenRow":
					return this.AlternateBackColor
				case "OddRow":
					return this.WindowBackColor
				case "Frame":
					return this.FieldBackColor
			}
		}
	}

	ButtonBackColor {
		Get {
			return this.WindowBackColor
		}
	}

	TextColor[mode := "Normal"] {
		Get {
			switch mode, false {
				case "Normal":
					return Theme.GetSystemColor("NormalTextColor")
				case "Disabled":
					return Theme.GetSystemColor("DisabledTextColor")
				case "Grid":
					return Theme.GetSystemColor("DisabledTextColor")
				case "Unavailable":
					return "Silver"
			}
		}
	}

	GridColor {
		Get {
			return this.TextColor["Disabled"]
		}
	}

	LinkColor {
		Get {
			return Theme.GetSystemColor("LinkTextColor")
		}
	}

	ButtonColor {
		Get {
			return Theme.GetSystemColor("ButtonTextColor")
		}
	}

	static GetSystemColor(code, asText := true) {
		local BGR

		if !isNumber(code) && kSystemColors.Has(code)
			code := kSystemColors[code]

		BGR := DllCall("User32.dll\GetSysColor", "Int", code, "UInt")

		BGR := ((BGR & 255) << 16 | (BGR & 65280) | (BGR >> 16))

		return (asText ? Format("{:06X}", BGR) : BGR)
	}

	InitializeWindow(window) {
		window.BackColor := this.WindowBackColor
	}

	InitializeControls(window) {
	}

	InitializeImage(fileName) {
		return fileName
	}

	GetControlType(type) {
		return type
	}

	ComputeControlOptions(window, type, options) {
		options := StrReplace(options, "-Theme", "")

		if ((type = "Text") && (InStr(options, "0x10") && !InStr(options, "0x100")))
			options := StrReplace(options, "0x10", "h1 Border")

		if !InStr(options, "Background") {
			switch type, false {
				case "ListView", "ListBox":
					options .= (" Background" . this.ListBackColor["Background"])
				case "Edit":
					options .= (" Background" . this.FieldBackColor)
				case "Button":
					options .= (" Background" . this.ButtonBackColor)
				case "Text", "Picture", "GroupBox", "CheckBox", "Radio", "Slider", "Link", "ComboBox":
					options .= (" Background" . this.WindowBackColor)
			}
		}

		; if (!RegExMatch(options, "c[0-9a-fA-F]{6}") && !InStr(options, "c" . this.LinkColor))
		;	options .= (" c" . this.TextColor)

		return options
	}

	ApplyThemeProperties(window, control) {
	}

	AddControl(window, type, options, arguments*) {
		return false
	}
}

class ClassicTheme extends Theme {
	Descriptor {
		Get {
			return "Classic"
		}
	}

	WindowBackColor {
		Get {
			return "D0D0D0"
		}
	}

	AlternateBackColor {
		Get {
			return "D8D8D8"
		}
	}

	FieldBackColor {
		Get {
			return "E0E0E0"
		}
	}

	ListBackColor[type := "Header"] {
		Get {
			switch type, false {
				case "Background":
					return this.AlternateBackColor
				case "Header":
					return "FFFFFF"
				case "EvenRow":
					return "E0E0E0"
				case "OddRow":
					return "C0C0C0"
			}
		}
	}

	TableColor[type := "Header"] {
		Get {
			switch type, false {
				case "Background":
					return this.AlternateBackColor
				case "Header":
					return "B0B0B0"
				case "EvenRow":
					return "E0E0E0"
				case "OddRow":
					return "C0C0C0"
				case "Frame":
					return "B0B0B0"
			}
		}
	}

	ButtonBackColor {
		Get {
			return "CCCCCC"
		}
	}

	TextColor[mode := "Normal"] {
		Get {
			return ((mode = "Normal") ? "000000"
									  : ((mode = "Disabled") ? "505050"
															 : ((mode = "Grid") ? "A0A0A0" : "808080")))
		}
	}

	GridColor {
		Get {
			return "A0A0A0"
		}
	}

	LinkColor {
		Get {
			return "Blue"
		}
	}
}

class GrayTheme extends ClassicTheme {
	Descriptor {
		Get {
			return "Gray"
		}
	}

	WindowBackColor {
		Get {
			return "909090"
		}
	}

	AlternateBackColor {
		Get {
			return "A0A0A0"
		}
	}

	ButtonBackColor {
		Get {
			return "959595"
		}
	}

	TableColor[type := "Header"] {
		Get {
			switch type, false {
				case "OddRow", "Header", "Frame":
					return "E8E8E8"
				default:
					return super.TableColor[type]
			}
		}
	}

	TextColor[mode := "Normal"] {
		Get {
			if (mode = "Grid")
				return "808080"
			else
				return super.TextColor[mode]
		}
	}

	GridColor {
		Get {
			return "808080"
		}
	}
}

class LightTheme extends Theme {
	Descriptor {
		Get {
			return "Light"
		}
	}

	WindowBackColor {
		Get {
			return "F0F0F0"
		}
	}

	AlternateBackColor {
		Get {
			return "FFFFFF"
		}
	}

	TableColor[type := "Header"] {
		Get {
			switch type, false {
				case "Background":
					return this.AlternateBackColor
				case "Header":
					return this.WindowBackColor
				case "EvenRow":
					return this.AlternateBackColor
				case "OddRow":
					return this.WindowBackColor
				case "Frame":
					return this.WindowBackColor
			}
		}
	}

	TextColor[mode := "Normal"] {
		Get {
			if (mode = "Grid")
				return "BFBFBF"
			else
				return super.TextColor[mode]
		}
	}

	GridColor {
		Get {
			return "BFBFBF"
		}
	}

	InitializeWindow(window) {
	}
}

class DarkTheme extends Theme {
	static sDarkColors := CaseInsenseMap("Background", "202020", "AltBackground", "2F2F2F", "Controls", "404040"
									   , "Font", "E0E0E0", "DsbldFont", "606060", "PssvFont", "404040")
	static sTextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkTheme.sDarkColors["Background"], "Ptr")

	class DarkCheckBox extends Gui.CheckBox {
		static kCheckWidth := 28
		static kCheckShift := 1

		Enabled {
			Get {
				return super.Enabled
			}

			Set {
				if value
					this.Label.Opt("c" . this.Gui.Theme.TextColor)
				else
					this.Label.Opt("c" . this.Gui.Theme.TextColor["Disabled"])

				return (super.Enabled := value)
			}
		}

		Visible {
			Get {
				return super.Visible
			}

			Set {
				this.Label.Visible := value

				return (super.Visible := value)
			}
		}

		Text {
			Get {
				return this.Label.Text
			}

			Set {
				return (this.Label.Text := value)
			}
		}

		static IsLabeled(options, arguments) {
			return ((arguments.Length > 0) && !isNumber(arguments[1]))
		}

		static GetCheckBoxArguments(options, arguments) {
			options := RegExReplace(options, "i)[\s]+w[0-9]+", " w23")
			options := RegExReplace(options, "i)^w[0-9]+", "w23")

			options := RegExReplace(options, "i)[\s]+x[0-9ps\-\+]+", " xp-" . DarkTheme.DarkCheckBox.kCheckWidth)
			options := RegExReplace(options, "i)^x[0-9ps\-\+]+", "xp-" . DarkTheme.DarkCheckBox.kCheckWidth)
			options := RegExReplace(options, "i)[\s]+y[0-9ps\-\+]+", " yp-" . DarkTheme.DarkCheckBox.kCheckShift)
			options := RegExReplace(options, "i)^y[0-9ps\-\+]+", "yp-" . DarkTheme.DarkCheckBox.kCheckShift)

			return [options]
		}

		static GetLabelArguments(options, arguments) {
			local argument := false

			shiftCoord(axis, offset) {
				local shift, prefix

				if (RegExMatch(options, "i)[\s]+" . axis . "[0-9ps\-\+]+", &argument) || RegExMatch(options, "i)^" . axis . "[0-9ps\-\+]+", &argument)) {
					argument := Trim(argument[])

					if ((InStr(argument, axis . "p") = 1) || (InStr(argument, axis . "s") = 1)) {
						prefix := SubStr(argument, 1, 2)
						argument := SubStr(argument, 3)
					}
					else if (InStr(argument, axis) = 1) {
						prefix := SubStr(argument, 1, 1)
						argument := SubStr(argument, 2)
					}

					if (StrLen(argument) = 0)
						argument := (A_Space . prefix . "+" . offset)
					else {
						shift := ((InStr(argument, "+") = 1) || (InStr(argument, "-") = 1))

						if shift
							argument := SubStr(argument, 2)

						argument += offset

						if shift {
							if (argument >= 0)
								argument := (A_Space . prefix . "+" . argument)
							else
								argument := (A_Space . prefix . argument)
						}
						else
							argument := (A_Space . prefix . argument)
					}

					options := RegExReplace(options, "i)[\s]+" . axis . "[0-9ps\-\+]+", argument)
					options := RegExReplace(options, "i)^" . axis . "[0-9ps\-\+]+", argument)
				}
			}

			options := RegExReplace(options, "i)[\s]+v[^\s]+", " ")
			options := RegExReplace(options, "i)^v[^\s]+", "")
			options := RegExReplace(options, "i)[\s]+Checked[^\s]*", " ")
			options := RegExReplace(options, "i)^Checked[^\s]*", "")
			options := RegExReplace(options, "i)[\s]+Disabled\s*", " ")
			options := RegExReplace(options, "i)^Disabled\s*", " ")
			options := RegExReplace(options, "i)[\s]+Disabled$", " ")
			options := RegExReplace(options, "i)^Disabled$", " ")

			if RegExMatch(options, "i)[\s]+w[0-9]+", &argument)
				options := RegExReplace(options, "i)[\s]+w[0-9]+", " w" . (SubStr(Trim(argument[]), 2) - DarkTheme.DarkCheckBox.kCheckWidth))

			if RegExMatch(options, "i)^w[0-9]+", &argument)
				options := RegExReplace(options, "i)^w[0-9]+", "w" . (SubStr(Trim(argument[]), 2) - DarkTheme.DarkCheckBox.kCheckWidth))

			shiftCoord("x", DarkTheme.DarkCheckBox.kCheckWidth)
			shiftCoord("y", DarkTheme.DarkCheckBox.kCheckShift)

			return Array(options, arguments*)
		}
	}

	class DarkListView extends Gui.ListView {
		class RECT {
			left: i32, top: i32, right: i32, bottom: i32
		}

		class NMHDR {
			hwndFrom: uptr
			idFrom  : uptr
			code    : i32
		}

		class NMCUSTOMDRAW {
			hdr        : DarkTheme.DarkListView.NMHDR
			dwDrawStage: u32
			hdc        : uptr
			rc         : DarkTheme.DarkListView.RECT
			dwItemSpec : uptr
			uItemState : u32
			lItemlParam: iptr
		}

		static __New() {
			static LVM_GETHEADER := 0x101F

			super.Prototype.GetHeader   := SendMessage.Bind(LVM_GETHEADER, 0, 0)
			super.Prototype.SetDarkMode := this.SetDarkMode.Bind(this)
		}

		static Initialize() {
		}

		static SetDarkMode(lv) {
			static LVS_EX_DOUBLEBUFFER := 0x10000
			static NM_CUSTOMDRAW       := -12
			static UIS_SET             := 1
			static UISF_HIDEFOCUS      := 0x1
			static WM_CHANGEUISTATE    := 0x0127
			static WM_NOTIFY           := 0x4E
			static WM_THEMECHANGED     := 0x031A

			lv.Header := lv.GetHeader()

			lv.OnMessage(WM_THEMECHANGED, (*) => 0)

			lv.OnMessage(WM_NOTIFY, (lv, wParam, lParam, Msg) {
				static CDDS_ITEMPREPAINT   := 0x10001
				static CDDS_PREPAINT       := 0x1
				static CDRF_DODEFAULT      := 0x0
				static CDRF_NOTIFYITEMDRAW := 0x20

				if (StructFromPtr(DarkTheme.DarkListView.NMHDR, lParam).Code != NM_CUSTOMDRAW)
					return

				nmcd := StructFromPtr(DarkTheme.DarkListView.NMCUSTOMDRAW, lParam)

				if (nmcd.hdr.hWndFrom != lv.Header)
					return

				switch nmcd.dwDrawStage {
					case CDDS_PREPAINT:
						return CDRF_NOTIFYITEMDRAW
					case CDDS_ITEMPREPAINT:
						SetTextColor(nmcd.hdc, DarkTheme.DarkColors["Font", true])
				}

				return CDRF_DODEFAULT
			})

			lv.Opt("+LV" . LVS_EX_DOUBLEBUFFER)

			SendMessage(WM_CHANGEUISTATE, (UIS_SET << 8) | UISF_HIDEFOCUS, 0, lv)

			SetWindowTheme(lv.Header, "DarkMode_ItemsView")
			SetWindowTheme(lv.Hwnd, "DarkMode_Explorer")

			SetTextColor(hdc, color) => DllCall("SetTextColor", "Ptr", hdc, "UInt", color)

			SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(appName), "ptr", subIdList ?? 0)
		}
	}

	Descriptor {
		Get {
			return "Dark"
		}
	}

	static DarkColors[key, asNumber := true] {
		Get {
			local value := DarkTheme.sDarkColors[key]

			return (asNumber ? ("0x" . value) : value)
		}
	}

	DarkColors[key, asNumber := true] {
		Get {
			return DarkTheme.DarkColors[key, asNumber]
		}
	}

	static TextBackgroundBrush {
		Get {
			return DarkTheme.sTextBackgroundBrush
		}
	}

	TextBackgroundBrush {
		Get {
			return DarkTheme.TextBackgroundBrush
		}
	}

	WindowBackColor {
		Get {
			return this.DarkColors["Background", false]
		}
	}

	AlternateBackColor {
		Get {
			return this.DarkColors["AltBackground", false]
		}
	}

	FieldBackColor {
		Get {
			return this.DarkColors["Controls", false]
		}
	}

	ButtonBackColor {
		Get {
			return this.AlternateBackColor
		}
	}

	TextColor[mode := "Normal"] {
		Get {
			switch mode, false {
				case "Normal":
					return this.DarkColors["Font", false]
				case "Disabled":
					return this.DarkColors["DsbldFont", false]
				case "Unavailable":
					return this.DarkColors["PssvFont", false]
				case "Grid":
					return "606060"
			}
		}
	}

	GridColor {
		Get {
			return "606060"
		}
	}

	LinkColor {
		Get {
			return Theme.GetSystemColor("LinkTextColor")
		}
	}

	ButtonColor {
		Get {
			return this.DarkColors["Font", false]
		}
	}

	SetWindowAttribute(window) {
		local DWMWA_USE_IMMERSIVE_DARK_MODE, uxTheme

		static GWL_WNDPROC        := -4
		static PreferredAppMode := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)
		static SetWindowLong    := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"

		if (VerCompare(A_OSVersion, "10.0.17763") >= 0) {
			DWMWA_USE_IMMERSIVE_DARK_MODE := 19

			if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
				DWMWA_USE_IMMERSIVE_DARK_MODE := 20

			uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")

			DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", window.Hwnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)

			DllCall(DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr") , "Int", PreferredAppMode["ForceDark"])
			DllCall(DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr"))

			window.BackColor := this.DarkColors["Background"]

			; if !window.HasProp("WindowProc")
			;	window.WindowProc := DllCall("user32\" . SetWindowLong, "Ptr", window.Hwnd, "Int", GWL_WNDPROC
			;														  , "Ptr", CallbackCreate(windowProc), "Ptr")
		}
	}

	SetControlTheme(control) {
		static GWL_STYLE          := -16
		static ES_MULTILINE       := 0x0004
		static LVM_SETTEXTCOLOR   := 0x1024
		static LVM_SETTEXTBKCOLOR := 0x1026
		static LVM_SETBKCOLOR     := 0x1001
		static LVM_GETHEADER      := 0x101F
		static MCSC_BACKGROUND    := 0
		static MCSC_TEXT          := 1
		static MCSC_TITLEBK       := 2
		static MCSC_TITLETEXT     := 3
		static MCSC_MONTHBK       := 4
		static MCSC_TRAILINGTEXT  := 5
		static DTM_SETMCCOLOR     := 0x1006
		static GetWindowLong      := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"

		switch control.Type, false {
			case "Button", "CheckBox", "ListBox", "UpDown", "DateTime":
				DllCall("uxtheme\SetWindowTheme", "Ptr", control.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
			case "ComboBox", "DDL":
				DllCall("uxtheme\SetWindowTheme", "Ptr", control.Hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
			case "Edit":
				if (DllCall("user32\" . GetWindowLong, "Ptr", control.Hwnd, "Int", GWL_STYLE) & ES_MULTILINE)
					DllCall("uxtheme\SetWindowTheme", "Ptr", control.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
				else
					DllCall("uxtheme\SetWindowTheme", "Ptr", control.Hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
			case "ListView":
				control.Opt("-Redraw")

				SendMessage(LVM_SETTEXTCOLOR,   0, this.DarkColors["Font"],       control.Hwnd)
				SendMessage(LVM_SETTEXTBKCOLOR, 0, this.DarkColors["Background"], control.Hwnd)
				SendMessage(LVM_SETBKCOLOR,     0, this.DarkColors["Background"], control.Hwnd)

				DllCall("uxtheme\SetWindowTheme", "Ptr", control.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)

				LV_Header := SendMessage(LVM_GETHEADER, 0, 0, control.Hwnd)

				DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", "DarkMode_ItemsView", "Ptr", 0)

				control.SetDarkMode()

				control.Opt("+Redraw")
			case "DateTime":
				control.Opt("-Redraw")

				SendMessage(DTM_SETMCCOLOR, MCSC_BACKGROUND, this.DarkColors["BackGround"], control.Hwnd)
				SendMessage(DTM_SETMCCOLOR, MCSC_TEXT, this.DarkColors["Font"], control.Hwnd)

				control.Opt("+Redraw")
		}
	}

	InitializeWindow(window) {
		this.SetWindowAttribute(window)
	}

	InitializeImage(fileName) {
		whiteIcon(graphics, bitmap) {
			local x, y, value

			loop Gdip_GetImageHeight(bitmap) {
				y := A_Index - 1

				loop Gdip_GetImageWidth(bitmap) {
					x := A_Index - 1

					value := Gdip_GetPixel(bitmap, x, y)

					Gdip_SetPixel(bitmap, x, y, ((value & 0xFF000000) + ((value & 0x00FFFFFF) ^ 0xFFFFFF)))
				}
			}
		}

		return modifiedIcon(fileName, "Invrt", whiteIcon)
	}

	ComputeControlOptions(window, type, options) {
		options := super.ComputeControlOptions(window, type, options)

		if (!RegExMatch(options, "c[0-9a-fA-F]{6}") && !InStr(options, "c" . this.LinkColor))
			options .= (" c" . this.TextColor)

		return options
	}

	ApplyThemeProperties(window, control) {
		this.SetControlTheme(control)
	}

	GetControlType(type) {
		if (type = "DarkCheckBox")
			return "CheckBox"
		else
			return super.GetControlType(type)
	}

	AddControl(window, type, options, arguments*) {
		if ((type = "CheckBox") && DarkTheme.DarkCheckBox.IsLabeled(options, arguments)) {
			label := window.Add("Text", DarkTheme.DarkCheckBox.GetLabelArguments(options, arguments)*)
			checkBox := window.Add("DarkCheckBox", DarkTheme.DarkCheckBox.GetCheckBoxArguments(options, arguments)*)

			checkBox.Label := label
			checkBox.Enabled := checkBox.Enabled

			checkBox.Base := DarkTheme.DarkCheckBox.Prototype

			return checkBox
		}
		else
			return super.AddControl(window, type, options, arguments*)
	}
}

class Window extends Gui {
	static sConstrainWindow := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
											  , "Windows", "ConstrainWindow", true)
	static sConstrainControls := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
												, "Windows", "ConstrainControls", true)
	static sCustomControlTypes := CaseInsenseMap()

	iTheme := false

	iCloseable := false
	iResizeable := false

	iOrigWidth := 0
	iOrigHeight := 0

	iMinWidth := 0
	iMinHeight := 0
	iMaxWidth := 0
	iMaxHeight := 0

	iWidth := 0
	iHeight := 0

	iResizers := []
	iCustomControls := []

	iDescriptor := false

	iLastX := false
	iLastY := false

	iRules := []

	iTitleBarHeight := 0

	iAutoActivate := true
	iBlockLevel := 0
	iBlockRedraw := 0

	iCurrentFont := false
	iCurrentFontOptions := false

	class Resizer {
		iWindow := false

		Window {
			Get {
				return this.iWindow
			}
		}

		Control {
			Get {
				return false
			}
		}

		__New(window) {
			this.iWindow := window
		}

		Initialize() {
		}

		RestrictResize(&deltaWidth, &deltaHeight) {
			return false
		}

		Resize(deltaWidth, deltaHeight) {
		}

		Redraw() {
		}
	}

	class ControlResizer extends Window.Resizer {
		iRule := false
		iCompiledRule := false

		iControl := false

		iOriginalX := 0
		iOriginalY := 0
		iOriginalWidth := 0
		iOriginalHeight := 0

		Control {
			Get {
				return this.iControl
			}
		}

		Rule[optimized := false] {
			Get {
				return (optimized ? this.iCompiledRule : this.iRule)
			}
		}

		OriginalX {
			Get {
				return this.iOriginalX
			}

			Set {
				return (this.iOriginalX := value)
			}
		}

		OriginalY {
			Get {
				return this.iOriginalY
			}

			Set {
				return (this.iOriginalY := value)
			}
		}

		OriginalWidth {
			Get {
				return this.iOriginalWidth
			}

			Set {
				return (this.iOriginalWidth := value)
			}
		}

		OriginalHeight {
			Get {
				return this.iOriginalHeight
			}

			Set {
				return (this.iOriginalHeight := value)
			}
		}

		__New(window, control, rule) {
			this.iControl := control
			this.iRule := rule

			super.__New(window)

			this.Optimize()
		}

		Initialize() {
			local x, y, w, h

			try {
				ControlGetPos(&x, &y, &w, &h, this.Control)

				this.iOriginalX := x
				this.iOriginalY := y
				this.iOriginalWidth := w
				this.iOriginalHeight := h
			}
			catch Any as exception {
				logError(exception)
			}
		}

		Reset() {
			this.Optimize()
		}

		Optimize() {
			local ignore, part, variable, horizontal, rule, factor, rules

			callRules(rules, &x, &y, &w, &h, dw, dh) {
				local ignore, rule

				for ignore, rule in rules
					rule(&x, &y, &w, &h, dw, dh)
			}

			fastMover(horizontal, variable, factor) {
				move(&x, &y, &w, &h, dw, dh) {
					switch variable, false {
						case "x":
							x += Round((horizontal ? dw : dh) * factor)
						case "y":
							y += Round((horizontal ? dw : dh) * factor)
						case "w":
							w += Round((horizontal ? dw : dh) * factor)
						case "h":
							h += Round((horizontal ? dw : dh) * factor)
						default:
							logError("Unknown variable detected in Resizre.Optimize...")
					}
				}

				return move
			}

			fastGrower := fastMover

			fastCenter(horizontal, variable, factor) {
				if (variable = "h")
					return (&x, &y, &w, &h, dw, dh) => (x := Round((this.Window.Width / 2) - (w / 2)))
				else
					return (&x, &y, &w, &h, dw, dh) => (y := Round((this.Window.Height / 2) - (h / 2)))
			}

			rules := []

			for ignore, part in string2Values(A_Space, this.Rule) {
				part := StrSplit(part, ":", , 2)
				variable := part[1]

				if (variable = "Width")
					variable := "w"
				else if (variable = "Height")
					variable := "h"
				else if (variable = "Horizontal")
					variable := "h"
				else if (variable = "Vertical")
					variable := "v"

				horizontal := ((variable = "x") || (variable = "w"))

				rule := part[2]

				if Instr(rule, "(") {
					rule := StrSplit(rule, "(", " `t)", 2)

					factor := rule[2]
					rule := rule[1]
				}
				else
					factor := 1

				switch rule, false {
					case "Move":
						rules.Push(fastMover(horizontal, variable, factor))
					case "Grow":
						rules.Push(fastGrower(horizontal, variable, factor))
					case "Center":
						rules.Push(fastCenter(horizontal, variable, factor))
				}
			}

			this.iCompiledRule := callRules.Bind(rules)
		}

		RestrictResize(&deltaWidth, &deltaHeight) {
			return false
		}

		Resize(deltaWidth, deltaHeight) {
			local x := this.OriginalX
			local y := this.OriginalY
			local w := this.OriginalWidth
			local h := this.OriginalHeight

			this.Rule[true](&x, &y, &w, &h, deltaWidth, deltaHeight)

			ControlMove(x, y, w, h, this.Control)
		}

		Redraw() {
			this.Control.Redraw()
		}
	}

	Theme {
		Get {
			return this.iTheme
		}
	}

	Descriptor {
		Get {
			return this.iDescriptor
		}

		Set {
			return (this.iDescriptor := value)
		}
	}

	Closeable {
		Get {
			return (this.iCloseable && !Task.Critical)
		}
	}

	Resizeable {
		Get {
			return this.iResizeable
		}
	}

	OrigWidth {
		Get {
			return this.iOrigWidth
		}
	}

	OrigHeight {
		Get {
			return this.iOrigHeight
		}
	}

	MinWidth[resize := true, restrict := true] {
		Get {
			return this.iMinWidth
		}

		Set {
			try {
				if restrict
					this.Opt("+MinSize" . value . "x" . (this.MinHeight - this.TitleBarHeight))

				return (this.iMinWidth := value)
			}
			finally {
				if resize
					this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	MinHeight[resize := true, restrict := true] {
		Get {
			return this.iMinHeight
		}

		Set {
			try {
				if restrict
					this.Opt("+MinSize" . this.MinWidth . "x" . (value - this.TitleBarHeight))

				return (this.iMinHeight := value)
			}
			finally {
				if resize
					this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	MaxWidth[resize := true, restrict := true] {
		Get {
			return this.iMaxWidth
		}

		Set {
			try {
				return (this.iMaxWidth := value)
			}
			finally {
				if restrict
					if this.MaxWidth
						this.Opt("+MaxSize" . this.MaxWidth . "x")
					else
						this.Opt("-MaxSize")

				if resize
					this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	MaxHeight[resize := true, restrict := true] {
		Get {
			return this.iMaxHeight
		}

		Set {
			try {
				return (this.iMaxHeight := value)
			}
			finally {
				if restrict
					if this.MaxHeight
						this.Opt("+MaxSize" . "x" . this.MaxHeight)
					else
						this.Opt("-MaxSize")

				if resize
					this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	Width {
		Get {
			return this.iWidth
		}
	}

	Height {
		Get {
			return this.iHeight
		}
	}

	TitleBarHeight {
		Get {
			return this.iTitleBarHeight
		}
	}

	AltBackColor {
		Get {
			return this.Theme.AlternateBackColor
		}
	}

	CurrentFont {
		Get {
			return this.iCurrentFont
		}
	}

	CurrentFontOptions {
		Get {
			return this.iCurrentFontOptions
		}
	}

	AutoActivate {
		Get {
			return this.iAutoActivate
		}

		Set {
			return (this.iAutoActivate := value)
		}
	}

	Resizers[control?] {
		Get {
			if isSet(control) {
				local resizers := []
				local ignore, resizer

				for ignore, resizer in this.Resizers
					if (resizer.Control = control)
						resizers.Push(resizer)

				return resizers
			}
			else
				return this.iResizers
		}
	}

	Rules[asText := true] {
		Get {
			return (asText ? values2String(A_Space, this.iRules*) : this.iRules)
		}

		Set {
			this.iRules := (isObject(value) ? value : ((Trim(value) = "") ? [] : string2Values(A_Space, value)))

			return this.Rules[asText]
		}
	}

	__New(options := {}, title := Strsplit(A_ScriptName, ".")[1], arguments*) {
		local ignore, argument

		for name, argument in options.OwnProps()
			switch name, false {
				case "Theme":
					this.iTheme := argument
				case "Closeable":
					this.iCloseable := argument
				case "Resizeable":
					this.iResizeable := argument
				case "Descriptor":
					this.iDescriptor := argument

					if argument
						Task.startTask(ObjBindMethod(this, "UpdatePosition", argument), 5000, kLowPriority)
				case "Options":
					options := argument
			}

		super.__New("", title, arguments*)

		if !this.Theme
			this.iTheme := Theme.CurrentTheme

		this.OnEvent("Close", this.Close)

		if this.Resizeable {
			this.Opt("+Resize +OwnDialogs")

			this.OnEvent("Size", this.Resize)
		}
		else
			this.Opt("+OwnDialogs -SysMenu -Border -Caption +0x800000")

		if !isObject(options)
			this.Opt("-DPIScale " . options)
		else
			this.Opt("-DPIScale")

		this.InitializeTheme()
	}

	static DefineCustomControl(type, constructor) {
		Window.sCustomControlTypes[type] := constructor
	}

	Block() {
		if (this.iBlockLevel++ = 0)
			this.Opt("+Disabled")
	}

	Unblock() {
		if (--this.iBlockLevel <= 0) {
			this.iBlockLevel := 0

			this.Opt("-Disabled")
		}
	}

	Opt(options) {
		super.Opt(options)

		if (InStr(options, "-Disabled") && this.AutoActivate)
			this.Show("NA")
	}

	SetFont(options?, font?) {
		if isSet(options)
			this.iCurrentFontOptions := options

		if isSet(font)
			this.iCurrentFont := font

		super.SetFont(options?, font?)
	}

	InitializeTheme() {
		this.Theme.InitializeWindow(this)
	}

	ComputeControlOptions(type, options) {
		return this.Theme.ComputeControlOptions(this, type, options)
	}

	ApplyThemeProperties(control) {
		this.Theme.ApplyThemeProperties(this, control)
	}

	Add(type, options := "", arguments*) {
		local rules := false
		local newOptions, ignore, option, control
		local checkBox, label

		control := this.Theme.AddControl(this, type, options, arguments*)

		if control
			return control

		if type is Window.Resizer
			return this.AddResizer(type)
		else {
			type := this.Theme.GetControlType(type)

			options := this.ComputeControlOptions(type, options)

			if RegExMatch(options, "i)[xywhv].*:") {
				newOptions := []
				rules := []

				for ignore, option in string2Values(A_Space, options)
					if RegExMatch(option, "i)[xywhv].*:")
						rules.Push(option)
					else
						newOptions.Push(option)

				options := values2String(A_Space, newOptions*)
			}

			if Window.sCustomControlTypes.Has(type) {
				control := Window.sCustomControlTypes[type](this, options, arguments*)

				this.iCustomControls.Push(control)
			}
			else
				control := super.Add(type, options, arguments*)

			if (rules || this.Rules[false].Length > 0) {
				if !rules
					rules := []

				this.DefineResizeRule(control, values2String(" ", concatenate(this.Rules[false], rules)*))
			}

			this.ApplyThemeProperties(control)

			return control
		}
	}

	AddResizer(resizer) {
		this.Resizers.Push(resizer)

		return resizer
	}

	DefineResizeRule(control, rule) {
		this.AddResizer(Window.ControlResizer(this, control, rule))
	}

	Show(arguments*) {
		local x, y, cWidth, cHeight, width, height
		local fullHeight, clientHeight

		this.Theme.InitializeControls(this)

		super.Show(arguments*)

		for ignore, control in this.iCustomControls
			if (control.Visible && control.HasProp("Show"))
				control.Show()

		if !this.OrigWidth {
			WinGetClientPos(&x, &y, &cWidth, &cHeight, this)
			WinGetPos(&x, &y, &width, &height, this)

			width := screen2Window(width)
			height := screen2Window(height)
			cWidth := screen2Window(cWidth)
			cHeight := screen2Window(cHeight)

			this.iTitleBarHeight := (height - cHeight)

			this.iOrigWidth := width
			this.iOrigHeight := height

			this.iMinWidth := width
			this.iMinHeight := height

			if Window.sConstrainWindow
				this.Opt("MinSize" . cWidth . "x" . cHeight)

			this.iWidth := width
			this.iHeight := height

			for ignore, resizer in this.Resizers
				resizer.Initialize()
		}
	}

	DisableRedraw() {
		if (this.iBlockRedraw++ = 0)
			SendMessage(0xB, 0, 0, , this)
	}

	EnableRedraw() {
		if (--this.iBlockRedraw = 0) {
			SendMessage(0xB, 1, 0, , this)

			WinRedraw(this)
		}
		else if (this.iBlockRedraw < 0)
			throw "Nesting error detected in Window.EnableRedraw..."
	}

	WithoutRedraw(function) {
		this.DisableRedraw()

		try {
			return function.Call()
		}
		finally {
			this.EnableRedraw()
		}
	}

	UpdatePosition(descriptor) {
		local x, y, settings

		try {
			WinGetPos(&x, &y, , , this)

			x := screen2Window(x)
			y := screen2Window(y)

			if (x && y) {
				if ((this.iLastX != x) || (this.iLastY != y)) {
					settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

					setMultiMapValue(settings, "Window Positions", descriptor . ".X", x)
					setMultiMapValue(settings, "Window Positions", descriptor . ".Y", y)

					writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
				}

				this.iLastX := x
				this.iLastY := y
			}
		}
		catch Any {
		}

		return Task.CurrentTask
	}

	Close(*) {
		if this.Closeable
			ExitApp(0)
		else
			return true
	}

	Resize(minMax, width, height) {
		local restricted := false
		local x, y, w, h, ignore, resizer

		static resizeTask := false

		updateSettings(width, height) {
			local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Window Positions", this.Descriptor . ".Width", width)
			setMultiMapValue(settings, "Window Positions", this.Descriptor . ".Height", height)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
		}

		runResizers(synchronous := false) {
			local curPriority, width, height, ignore, button, fullWidth, fullHeight, deltaWidth, deltaHeight

			if !synchronous {
				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button)
						return Task.CurrentTask

				resizeTask := false
			}

			curPriority := Task.block(kInterruptPriority)

			try {
				WinGetPos( , , &width, &height, this)

				width := screen2Window(width)
				height := screen2Window(height)

				if (Window.sConstrainWindow && (width < this.MinWidth)) {
					width := this.MinWidth
					restricted := true
				}
				else if (this.MaxWidth && (width > this.MaxWidth)) {
					width := this.MaxWidth
					restricted := true
				}

				if (Window.sConstrainWindow && (height < this.MinHeight)) {
					height := this.MinHeight
					restricted := true
				}
				else if (this.MaxHeight && (height > this.MaxHeight)) {
					height := this.MaxHeight
					restricted := true
				}

				if (Window.sConstrainControls && this.ControlsRestrictResize(&width, &height))
					restricted := true

				this.iWidth := width
				this.iHeight := height

				this.ControlsResize(width, height)

				if restricted
					WinMove( , , width, height, this)
				else {
					this.DisableRedraw()

					try {
						for ignore, resizer in this.Resizers
							resizer.Redraw()
					}
					finally {
						this.EnableRedraw()
					}
				}

				if this.Descriptor
					Task.startTask(updateSettings.Bind(width, height), 1000, kLowPriority)
			}
			catch Any as exception {
				Task.startTask(logError.Bind(exception), 100, kLowPriority)
			}
			finally {
				Task.unblock(curPriority)
			}
		}

		if InStr(minMax, "Init")
			WinMove( , , width, height, this)
		else if this.Width {
			if (this.Resizeable = "Deferred") {
				if !resizeTask {
					resizeTask := Task(runResizers, 100)

					resizeTask.start()
				}
			}
			else
				runResizers(true)
		}
	}

	ControlsRestrictResize(&width, &height) {
		local deltaWidth := (width - this.OrigWidth)
		local deltaHeight := (height - this.OrigHeight)
		local restricted := false
		local ignore, resizer

		for ignore, resizer in this.Resizers
			if resizer.RestrictResize(&deltaWidth, &deltaHeight)
				restricted := true

		if restricted {
			width := (this.OrigWidth + deltaWidth)
			height := (this.OrigHeight + deltaHeight)
		}

		return restricted
	}

	ControlsResize(width, height) {
		local deltaWidth := (width - this.OrigWidth)
		local deltaHeight := (height - this.OrigHeight)
		local ignore, resizer

		for ignore, resizer in this.Resizers
			resizer.Resize(deltaWidth, deltaHeight)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getAllUIThemes(configuration) {
	return [ClassicTheme(), GrayTheme(), LightTheme(), DarkTheme()]
}

setButtonIcon(buttonHandle, file, index := 1, options := "", theme := true) {
	local window := ((buttonHandle is Gui.Control) ? buttonHandle.Gui : GuiCtrlFromHwnd(buttonHandle).Gui)
	local ptrSize, button_il, normal_il, L, T, R, B, A, W, H, S, DW, PTR
	local BCM_SETIMAGELIST

;   Parameters:
;   1) {Handle} 	Hwnd handle of Gui button
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

	if theme
		file := window.Theme.InitializeImage(file)

	RegExMatch(options, "i)w\K\d+", &W), !W ? W := 16 : W := W[]
	RegExMatch(options, "i)h\K\d+", &H), !H ? H := 16 : H := H[]
	RegExMatch(options, "i)s\K\d+", &S), S ? W := H := S[] :
	RegExMatch(options, "i)l\K\d+", &L), !L ? L := 0 : L := L[]
	RegExMatch(options, "i)t\K\d+", &T), !T ? T := 0 : T := T[]
	RegExMatch(options, "i)r\K\d+", &R), !R ? R := 0 : R := R[]
	RegExMatch(options, "i)b\K\d+", &B), !B ? B := 0 : B := B[]
	RegExMatch(options, "i)a\K\d+", &A), !A ? A := 4 : A := A[]

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	button_il := Buffer(20 + ptrSize, 0)

	NumPut(Ptr, normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0)	; Width & Height
	NumPut(DW, L, button_il, 0 + ptrSize)		; Left Margin
	NumPut(DW, T, button_il, 4 + ptrSize)		; Top Margin
	NumPut(DW, R, button_il, 8 + ptrSize)		; Right Margin
	NumPut(DW, B, button_il, 12 + ptrSize)		; Bottom Margin
	NumPut(DW, A, button_il, 16 + ptrSize)		; Alignment

	SendMessage(BCM_SETIMAGELIST := 5634, 0, button_il, , "AHK_ID " . (buttonHandle is Gui.Control) ? buttonHandle.Hwnd : buttonHandle)

	return IL_Add(normal_il, file, index)
}

openDocumentation(dialog, link, arguments*) {
	if isInstance(link, Func)
		link.Call(arguments*)
	else
		Run(link)
}

window2Screen := (value) => Round(value * kScreenResolution / 96)

screen2Window := (value) => Round(value / kScreenResolution * 96)

moveByMouse(window, descriptor := false, *) {
	local curCoordMode := A_CoordModeMouse
	local anchorX, anchorY, winX, winY, x, y, newX, newY, settings

	CoordMode("Mouse", "Screen")

	try {
		MouseGetPos(&anchorX, &anchorY)
		WinGetPos(&winX, &winY, , , window)

		anchorX := screen2Window(anchorX)
		anchorY := screen2Window(anchorY)
		winX := screen2Window(winX)
		winY := screen2Window(winY)

		newX := winX
		newY := winY

		while GetKeyState("LButton") {
			MouseGetPos(&x, &y)

			x := screen2Window(x)
			y := screen2Window(y)

			newX := winX + (x - anchorX)
			newY := winY + (y - anchorY)

			WinMove(newX, newY, , , window)
		}

		WinGetPos(&winX, &winY, , , window)

		winX := screen2Window(winX)
		winY := screen2Window(winY)

		if descriptor {
			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Window Positions", descriptor . ".X", winX)
			setMultiMapValue(settings, "Window Positions", descriptor . ".Y", winY)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
		}
	}
	finally {
		CoordMode("Mouse", curCoordMode)
	}
}

getWindowPosition(descriptor, &x, &y) {
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
	local posX := getMultiMapValue(settings, "Window Positions", descriptor . ".X", kUndefined)
	local posY := getMultiMapValue(settings, "Window Positions", descriptor . ".Y", kUndefined)
	local screen, screenLeft, screenRight, screenTop, screenBottom

	if ((posX == kUndefined) || (posY == kUndefined))
		return false
	else {
		loop MonitorGetCount() {
			MonitorGetWorkArea(A_Index, &screenLeft, &screenTop, &screenRight, &screenBottom)

			if ((posX >= (screenLeft - 50)) && (posX <= screenRight) && (posY >= screenTop) && (posY <= screenBottom)) {
				x := posX
				y := posY

				return true
			}
		}

		return false
	}
}

getWindowSize(descriptor, &width, &height) {
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

	width := getMultiMapValue(settings, "Window Positions", descriptor . ".Width", kUndefined)
	height := getMultiMapValue(settings, "Window Positions", descriptor . ".Height", kUndefined)

	if ((width == kUndefined) || (height == kUndefined))
		return false
	else
		return true
}

getScrollPosition(edit) {
	local SB_VERT := 1

	return DllCall("GetScrollPos", "UInt", edit.Hwnd, "Int", SB_VERT)
}

setScrollPosition(edit, pos) {
	local WM_VSCROLL := 0x0115
	local SB_THUMBPOSITION := 4

	SendMessage(WM_VSCROLL, (pos * 65536) + SB_THUMBPOSITION, , edit)
}

translateMsgBoxButtons(buttonLabels, *) {
	local curDetectHiddenWindows := A_DetectHiddenWindows
	local index, label

    DetectHiddenWindows(true)

	try {
		if WinExist("ahk_class #32770 ahk_pid " . ProcessExist()) {
			for index, label in buttonLabels
				try {
					ControlSetText(translate(label), "Button" index)
				}
				catch Any as exception {
					logError(exception)
				}
		}
	}
	finally {
		DetectHiddenWindows(curDetectHiddenWindows)
	}
}

translateYesNoButtons := translateMsgBoxButtons.Bind(["Yes", "No"])
translateOkButton := translateMsgBoxButtons.Bind(["Ok"])
translateOkCancelButtons := translateMsgBoxButtons.Bind(["Ok", "Cancel"])
translateLoadCancelButtons := translateMsgBoxButtons.Bind(["Load", "Cancel"])
translateSaveCancelButtons := translateMsgBoxButtons.Bind(["Save", "Cancel"])
translateSelectCancelButtons := translateMsgBoxButtons.Bind(["Select", "Cancel"])

withBlockedWindows(function, arguments*) {
	local windows := []
	local ignore, Hwnd, theWindow

	for ignore, Hwnd in WinGetList("ahk_exe " . A_ScriptName) {
		theWindow := GuiFromHwnd(Hwnd)

		if (isObject(theWindow) && isInstance(theWindow, Window)) {
			theWindow.Opt("+OwnDialogs")

			windows.Push(theWindow)
		}
	}

	for ignore, theWindow in windows
		theWindow.Block()

	try {
		return function(arguments*)
	}
	finally {
		for ignore, theWindow in windows
			theWindow.Unblock()
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

modifiedIcon(fileName, postFix, modifier) {
	local extension, name, modifiedFileName, token, bitmap, graphics

	SplitPath(fileName, , , &extension, &name)

	if (extension = "ico")
		extension := "png"

	modifiedFileName := (kTempDirectory . "Icons\" . name . "_" . postFix . "." . extension)

	if !FileExist(modifiedFileName) {
		DirCreate(kTempDirectory . "Icons")

		token := Gdip_Startup()

		bitmap := Gdip_CreateBitmapFromFile(fileName)

		graphics := Gdip_GraphicsFromImage(bitmap)

		modifier(graphics, bitmap)

		Gdip_SaveBitmapToFile(bitmap, modifiedFileName)

		Gdip_DisposeImage(bitmap)

		Gdip_DeleteGraphics(graphics)

		Gdip_Shutdown(token)
	}

	return modifiedFileName
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeGUI() {
	AddDocumentation(window, arguments*) {
		return createDocumentation(window, arguments*)
	}

	createDocumentation(window, options, label?, link?) {
		local curFontOptions := window.CurrentFontOptions
		local control

		window.SetFont("Italic Underline")

		control := window.Add("Text", "c" . window.Theme.LinkColor . A_Space
									. StrReplace(options, "c" . window.Theme.TextColor, "")
									, label?)

		window.SetFont(curFontOptions)

		if isSet(link)
			control.Link := link

		control.OnEvent("Click", (*) => openDocumentation(window, control.Link))

		return control
	}

	DllCall("SetThreadDpiAwarenessContext", "Ptr", -5, "Ptr")

	Window.Prototype.AddDocumentation := AddDocumentation

	Window.DefineCustomControl("Documentation", createDocumentation)

	DarkTheme.DarkListView.Initialize()

	try {
		Theme.CurrentTheme := %getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "General", "UI Theme", "Classic") . "Theme"%()
	}
	catch Any as exception {
		Theme.CurrentTheme := ClassicTheme()
	}

	; DllCall("User32\SetProcessDpiAwarenessContext", "UInt" , -1)
	; DllCall("User32\SetThreadDpiAwarenessContext", "UInt" , -1)
}

WindowProc(hwnd, uMsg, wParam, lParam) {
	Critical

	local window := GuiFromHwnd(hwnd)
	local theme := window.Theme
	local control := GuiCtrlFromHwnd(lParam)

	static WM_CTLCOLOREDIT    := 0x0133
	static WM_CTLCOLORLISTBOX := 0x0134
	static WM_CTLCOLORBTN     := 0x0135
	static WM_CTLCOLORSTATIC  := 0x0138
	static DC_BRUSH           := 18

	switch uMsg {
		case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
			DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", theme.DarkColors["Font"])
			DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", theme.DarkColors["Controls"])
			DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", theme.DarkColors["Controls"], "UInt")

			return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
		case WM_CTLCOLORBTN:
			DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", theme.DarkColors["Background"], "UInt")

			return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")

		/*
		case WM_CTLCOLORSTATIC:
			if isInstance(control, Gui.Edit) {
				DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", theme.DarkColors["Font"])
				DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", theme.DarkColors["Background"])

				return theme.TextBackgroundBrush
			}
		*/
	}

	return DllCall("user32\CallWindowProc", "Ptr", window.WindowProc, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeGUI()