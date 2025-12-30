;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - GUI Functions                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
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
#Include "Progress.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\GDIP.ahk"

#DllLoad gdi32.dll


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

	if (type = "Icons")
		definitions := readMultiMap(kUserTranslationsDirectory . ("Controller Action " . type . ".en"))
	else
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

	class ThemedDialog {
		class RECT {
			left: i32, top: i32, right: i32, bottom: i32
		}

		static Call(_this, params*) {
			static WM_COMMNOTIFY := 0x44
			static WM_INITDIALOG := 0x0110

			if !isInstance(Theme.CurrentTheme, DarkTheme)
				if InStr(_this.Name, "MsgBox")
					return MsgBox(params*)
				else
					return InputBox(params*)

			iconNumber := 1
			iconFile   := ""

			if (params.length = (_this.MaxParams + 2))
				iconNumber := params.Pop()

			if (params.length = (_this.MaxParams + 1))
				iconFile := params.Pop()

			if (!iconFile && InStr(_this.Name, "MsgBox") && (params.Length > 2))
				if (params[3] & 16) {
					iconNumber := 1
					iconFile := (kIconsDirectory . "Dlg Error.png")
				}
				else if (params[3] & 32) {
					iconNumber := 2
					iconFile := (kIconsDirectory . "Dlg Question.png")
				}
				else if (params[3] & 48) {
					iconNumber := 3
					iconFile := (kIconsDirectory . "Dlg Warning.png")
				}
				else if (params[3] & 64) {
					iconNumber := 4
					iconFile := (kIconsDirectory . "Dlg Info.png")
				}

			SetThreadDpiAwarenessContext(-5)

			if InStr(_this.Name, "MsgBox")
				OnMessage(WM_COMMNOTIFY, ON_WM_COMMNOTIFY, -1)
			else
				OnMessage(WM_INITDIALOG, ON_WM_INITDIALOG, -1)

			return _this(params*)

			ON_WM_INITDIALOG(wParam, lParam, msg, hwnd) {
				OnMessage(WM_INITDIALOG, ON_WM_INITDIALOG, 0)

				WNDENUMPROC(hwnd)
			}

			ON_WM_COMMNOTIFY(wParam, lParam, msg, hwnd) {
				DetectHiddenWindows(true)

				if ((msg = 68) && (wParam = 1027))
					OnMessage(0x44, ON_WM_COMMNOTIFY, 0), EnumThreadWindows(GetCurrentThreadId(), CallbackCreate(WNDENUMPROC), 0)
			}

			WNDENUMPROC(hwnd, *) {
				static SM_CICON         := "W" SysGet(11) " H" SysGet(12)
				static SM_CSMICON       := "W" SysGet(49) " H" SysGet(50)
				static ICON_BIG         := 1
				static ICON_SMALL       := 0
				static WM_SETICON       := 0x80
				static WS_CLIPCHILDREN  := 0x02000000
				static WS_CLIPSIBLINGS  := 0x04000000
				static WS_EX_COMPOSITED := 0x02000000
				static WS_VSCROLL       := 0x00200000
				static winAttrMap       := Map(2, 2, 4, 0, 10, true, 17, true, 20, true, 38, 4, 35, 0x2b2b2b)

				SetWinDelay(-1)
				SetControlDelay(-1)

				DetectHiddenWindows(true)

				if !WinExist("ahk_class #32770 ahk_id" hwnd)
					return 1

				WinSetStyle("+" (WS_CLIPCHILDREN | WS_CLIPSIBLINGS))
				WinSetExStyle("+" (WS_EX_COMPOSITED))

				SetWindowTheme(hwnd, "DarkMode_Explorer")

				/*
				if iconFile {
					hICON_SMALL := LoadPicture(iconFile, , &handleType) ; , SM_CSMICON " Icon" iconNumber, &handleType)
					hICON_BIG   := LoadPicture(iconFile, , &handleType) ; , SM_CICON " Icon" iconNumber, &handleType)

					PostMessage(WM_SETICON, ICON_SMALL, hICON_SMALL)
					PostMessage(WM_SETICON, ICON_BIG, hICON_BIG)
				}
				*/

				for dwAttribute, pvAttribute in winAttrMap
					DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute)

				GWL_WNDPROC(hwnd, hICON_SMALL?, hICON_BIG?)

				return 0
			}

			GWL_WNDPROC(winId := "", hIcons*) {
				static SetWindowLong     := DllCall.Bind(A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong", "ptr", , "int", , "ptr", , "ptr")
				static BS_FLAT           := 0x8000
				static BS_BITMAP         := 0x0080
				static DPI               := (A_ScreenDPI / 96)
				static WM_CLOSE          := 0x0010
				static WM_CTLCOLORBTN    := 0x0135
				static WM_CTLCOLORDLG    := 0x0136
				static WM_CTLCOLOREDIT   := 0x0133
				static WM_CTLCOLORSTATIC := 0x0138
				static WM_DESTROY        := 0x0002
				static WM_SETREDRAW      := 0x000B

				DetectHiddenWindows(true)
				SetControlDelay(-1)

				btns     := []
				btnHwnd  := ""
				iconHwnd := ""

				for ctrl in WinGetControlsHwnd(winId) {
					classNN := ControlGetClassNN(ctrl)

					SetWindowTheme(ctrl, !InStr(classNN, "Edit") ? "DarkMode_Explorer" : "DarkMode_CFD")

					if InStr(classNN, "Static1")
						iconHwnd := ctrl

					if !InStr(classNN, "B")
						continue

					btns.Push(btnHwnd := ctrl)
				}

				/*
				if (iconFile && iconHwnd) {
					icon := LoadPicture(iconFile, , &imgType)

					result := SendMessage(0x172, imgType, icon, iconHwnd)
				}
				*/

				WindowProcOld := SetWindowLong(winId, -4, CallbackCreate(WNDPROC))

				WNDPROC(hwnd, uMsg, wParam, lParam)
				{
					SetWinDelay(-1)
					SetControlDelay(-1)

					switch uMsg {
						case WM_CTLCOLORSTATIC:
							hbrush := SelectObject(wParam, GetStockObject(18))

							SetDCBrushColor(wParam, 0x2b2b2b)
							SetBkMode(wParam, 0)
							SetTextColor(wParam, 0xFFFFFF)

							for _hwnd in btns
								PostMessage(WM_SETREDRAW,,,_hwnd)

							GetClientRect(winId, rcC := this.RECT())

							ControlGetPos(, &btnY,, &btnH, btnHwnd)

							hdc        := GetDC(winId)
							rcC.top    := btnY - (rcC.bottom - (btnY+btnH))
							rcC.bottom *= 2
							rcC.right  *= 2

							SetBkMode(hdc, 0)
							SelectObject(hdc, hbrush := GetStockObject(18))
							SetDCBrushColor(hdc, 0x202020)
							FillRect(hdc, rcC, hbrush)
							ReleaseDC(winId, hdc)

							for _hwnd in btns
								PostMessage(WM_SETREDRAW, 1,,_hwnd)

							return hbrush
						case WM_CTLCOLORBTN, WM_CTLCOLORDLG, WM_CTLCOLOREDIT:
							SelectObject(wParam, hbrush := GetStockObject(18))
							SetDCBrushColor(wParam, 0x2b2b2b)
							SetBkMode(wParam, 0)
							SetTextColor(wParam, 0xFFFFFF)

							return hbrush
						case WM_DESTROY:
							for v in hIcons
								(v??0) && DestroyIcon(v)
					}

					return CallWindowProc(WindowProcOld, hwnd, uMsg, wParam, lParam)
				}
			}

			CallWindowProc(lpPrevWndFunc, hWnd, uMsg, wParam, lParam) => DllCall("CallWindowProc", "Ptr", lpPrevWndFunc, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)

			DestroyIcon(hIcon) => DllCall("DestroyIcon", "ptr", hIcon)

			DWMSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute := 4) => DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr" , hwnd, "UInt", dwAttribute
																															 , "Ptr*", &pvAttribute, "UInt", cbAttribute)

			DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')

			EnumThreadWindows(dwThreadId, lpfn, lParam) => DllCall("User32\EnumThreadWindows", "uint", dwThreadId, "ptr", lpfn, "uptr", lParam, "int")

			FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

			GetClientRect(hWnd, lpRect) => DllCall("User32\GetClientRect", "ptr", hWnd, "ptr", lpRect, "int")

			GetCurrentThreadId() => DllCall("Kernel32\GetCurrentThreadId", "uint")

			GetDC(hwnd := 0) => DllCall("GetDC", "ptr", hwnd, "ptr")

			GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')

			GetWindowRect(hWnd, lpRect) => DllCall("User32\GetWindowRect", "ptr", hWnd, "ptr", lpRect, "uptr")

			ReleaseDC(hWnd, hDC) => DllCall("User32\ReleaseDC", "ptr", hWnd, "ptr", hDC, "int")

			SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')

			SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')

			SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')

			SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')

			SetTextColor(hdc, crColor) => DllCall('Gdi32\SetTextColor', 'ptr', hdc, 'uint', crColor, 'uint')

			SetThreadDpiAwarenessContext(dpiContext) => DllCall("SetThreadDpiAwarenessContext", "ptr", dpiContext, "ptr")

			SetWindowTheme(hwnd, pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(pszSubAppName)
																										 , "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0)
																	    ? true : false)
		}
	}

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

	RecolorizeImage(fileName) {
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
				case "Edit", "ComboBox":
					options .= (" Background" . this.FieldBackColor)
				case "Button":
					options .= (" Background" . this.ButtonBackColor)
				case "Text", "Picture", "GroupBox", "CheckBox", "Radio", "Slider", "Link":
					options .= (" Background" . this.WindowBackColor)
				case "Tab3", "Tab2", "Tab":
					options .= (" 0x8000")
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
}

class DarkTheme extends Theme {
	static sDarkColors := CaseInsenseMap("Background", "202020", "AltBackground", "2F2F2F", "Controls", "404040"
									   , "Font", "D0D0D0", "DsbldFont", "808080", "PssvFont", "505050")
	static sTextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkTheme.sDarkColors["Background"], "Ptr")

	class DarkCheckBox extends Gui.CheckBox {
		static kCheckWidth := 23
		static kCheckShift := 1

		iClickHandlers := []

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
			options := RegExReplace(options, "i)[\s]+w[0-9]+", " w21")
			options := RegExReplace(options, "i)^w[0-9]+", "w21")

			if !RegExMatch(options, "i)^w[0-9]+")
				options .= " w23"

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

		HandleLabelClick(arguments*) {
			local ignore, handler

			if this.Enabled {
				this.Value := !this.Value

				if this.HasProp("iClickHandlers")
					for ignore, handler in this.iClickHandlers
						handler(arguments*)
			}
		}

		OnEvent(event, function := false) {
			if function
				if !this.HasProp("iClickHandlers")
					this.iClickHandlers := Array(function)
				else
					this.iClickHandlers.Push(function)

			return super.OnEvent(event, function)
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

			SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Ptr", StrPtr(appName), "Ptr", subIdList ?? 0)
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

	RecolorizeImage(fileName) {
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

		return withBlockedWindows(() {
			return withTask(RecolorizerTask(), modifiedImage.Bind(fileName, "Invrt", whiteIcon))
		})
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

			label.OnEvent("Click", (arguments*) => checkBox.HandleLabelClick(arguments*))

			checkBox.GetPos( , &y)
			label.Move( , y + 2)

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
	iScrollable := false

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

	iScrollbar := false

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

	class ScrollBar {
		iWindow := false
		iScrollCallback := false

		iScrollInfo := Window.Scrollbar.ScrollInfo()

		class ScrollInfo {
			iScrollInfo := Buffer(28, 0)

			Ptr {
				Get {
					return this.iScrollInfo.Ptr
				}
			}

			CBSize {
				Get {
					return NumGet(this.iScrollInfo, "UInt")
				}
			}

			FMask {
				Get => NumGet(this.iScrollInfo, 4, "UInt")
				Set => NumPut("UInt", value, this.iScrollInfo, 4)
			}

			Min {
				Get => NumGet(this.iScrollInfo, 8, "Int")
				Set => NumPut("Int", value, this.iScrollInfo, 8)
			}

			Max {
				Get => NumGet(this.iScrollInfo, 12, "Int")
				Set => NumPut("Int", value, this.iScrollInfo, 12)
			}

			Page {
				Get => NumGet(this.iScrollInfo, 16, "UInt")
				Set => NumPut("UInt", value, this.iScrollInfo, 16)
			}

			Pos {
				Get => NumGet(this.iScrollInfo, 20, "Int")
				Set => NumPut("Int", value, this.iScrollInfo, 20)
			}

			TrackPos {
				Get => NumGet(this.iScrollInfo, 24, "Int")
				Set => NumPut("Int", value, this.iScrollInfo, 24)
			}

			__New() {
				NumPut("UInt", this.iScrollInfo.Size, this.iScrollInfo)
			}
		}

		WM_HSCROLL => 0x114
		WM_VSCROLL => 0x115

		SB_HORZ => 0
		SB_VERT => 1
		SB_BOTH => 3

		SIF_RANGE => 1
		SIF_PAGE => 2
		SIF_POS => 4
		SIF_TRACKPOS => 16
		SIF_ALL => (this.SIF_RANGE | this.SIF_PAGE | this.SIF_POS | this.SIF_TRACKPOS)

		SB_LINELEFT => 0
		SB_LINEUP => 0
		SB_LINERIGHT => 1
		SB_LINEDOWN => 1

		SB_PAGELEFT => 2
		SB_PAGEUP => 2
		SB_PAGERIGHT => 3
		SB_PAGEDOWN => 3

		SB_THUMBPOSITION => 4
		SB_THUMBTRACK => 5

		SB_LEFT => 6
		SB_TOP => 6
		SB_RIGHT => 7
		SB_BOTTOM => 7

		SB_ENDSCROLL => 8

		Rect := Buffer(16)

		FixedControls := []

		Window {
			Get {
				return this.iWindow
			}
		}

		__New(window, width, height) {
			local left, right, top, bottom, scrollInfo, scrollHeight, scrollWidth

			if (window is Gui) {
				this.iWindow := window

				this.ShowScrollBar(this.SB_BOTH, true)

				this.iScrollCallback := ObjBindMethod(this, 'ScrollMsg')

				OnMessage(this.WM_HSCROLL, this.iScrollCallback)
				OnMessage(this.WM_VSCROLL, this.iScrollCallback)

				this.GetEdges(&left, &right, &top, &bottom)

				scrollHeight := (bottom - top)
				scrollWidth := (right - left)

				if (isNumber(width) && isNumber(height) && (width > 0) && (height > 0)) {
					scrollInfo := this.iScrollInfo

					scrollInfo.Min := 0
					scrollInfo.Max := scrollHeight
					scrollInfo.Page := height

					scrollInfo.Mask := (this.SIF_RANGE | this.SIF_PAGE)

					this.SetScrollInfo(this.SB_VERT, true)

					scrollInfo.Min := 0
					scrollInfo.Max := scrollWidth
					scrollInfo.Page := width

					scrollInfo.Mask := (this.SIF_RANGE | this.SIF_PAGE)

					this.SetScrollInfo(this.SB_HORZ, true)

					scrollInfo.Mask := this.SIF_ALL
				}
				else
					throw "Width and height must be valid numbers in Window.Scrollbar.__New..."
			}
			else
				throw "Parent is not a Window in Window.Scrollbar.__New..."
		}

		__Delete() {
			OnMessage(this.WM_HSCROLL, this.iScrollCallback, 0)
			OnMessage(this.WM_VSCROLL, this.iScrollCallback, 0)
		}

		Dispose() {
			this.__Delete()
		}

		UpdateFixedControlsPosition() {
			local hasFixed := false
			local ignore, control

			for ignore, control in this.FixedControls {
				control.Move(control.__CX, control.__CY)

				hasFixed := true
			}

			if hasFixed
				WinRedraw(this.Window)
		}

		AddFixedControls(controls*) {
			local ignore, control

			for ignore, control in controls
				this.FixedControls.Push(control)
		}

		UpdateScrollBars(width := false, height := false) {
			local x := 0
			local y := 0
			local left, right, top, bottom, scrollHeight, scrollWidth, scrollInfo

			this.GetEdges(&left, &right, &top, &bottom)

			scrollWidth := Max(right - left, width)
			scrollHeight := Max(bottom - top, height)

			scrollInfo := this.GetScrollInfo(this.SB_VERT)

			scrollInfo.Mask := (this.SIF_RANGE | this.SIF_PAGE)

			scrollInfo.Min := 0
			scrollInfo.Max := scrollHeight
			scrollInfo.Page := this.GetHeight()

			this.SetScrollInfo(this.SB_VERT, true)

			scrollInfo := this.GetScrollInfo(this.SB_HORZ)

			scrollInfo.Min := 0
			scrollInfo.Max := scrollWidth
			scrollInfo.Page := this.GetWidth()

			scrollInfo.Mask := (this.SIF_RANGE | this.SIF_PAGE)

			this.SetScrollInfo(this.SB_HORZ, true)

			if ((left < 0) && (right < this.GetWidth()))
				x := ((Abs(left) > this.GetWidth() - right) ? (this.GetWidth() - right) : Abs(left))

			if ((top < 0) && (bottom < this.GetHeight()))
				y := ((Abs(top) > this.GetHeight() - bottom) ? (this.GetHeight() - bottom) : Abs(top))

			if (x || y)
				DllCall("ScrollWindow", "Ptr", this.Window.Hwnd, "Int", x, "Int", y, "UInt", 0, "UInt", 0)

			DllCall("SetScrollRange", "Ptr", this.Window.Hwnd, "Int", this.SB_VERT, "Int", 0, "Int", scrollHeight, "Int", false)
			DllCall("SetScrollRange", "Ptr", this.Window.Hwnd, "Int", this.SB_HORZ, "Int", 0, "Int", scrollWidth, "Int", false)

			scrollInfo.Mask := this.SIF_ALL
		}

		ScrollMsg(wParam, lParam, msg, hwnd) {
			switch msg {
				case this.WM_HSCROLL:
					this.ScrollAction(this.SB_HORZ, wParam)

					this.ScrollWindow(this.OldPos - this.iScrollInfo.Pos, 0)

					this.UpdateFixedControlsPosition()
				case this.WM_VSCROLL:
					this.ScrollAction(this.SB_VERT, wParam)

					this.ScrollWindow(0, this.OldPos - this.iScrollInfo.Pos)

					this.UpdateFixedControlsPosition()
			}
		}

		ScrollOrigin() {
			this.ScrollTo(this.SB_VERT, 0)
			this.ScrollTo(this.SB_HORZ, 0)
		}

		ScrollTo(typeOfScrollBar, position) {
			local scrollInfo := this.GetScrollInfo(typeOfScrollBar)
			local delta

			position := Max(scrollInfo.Min, Min(scrollInfo.Max, position))
			delta := (position - scrollInfo.Pos)

			if (delta != 0) {
				scrollInfo.Pos := position
				scrollInfo.TrackPos := position

				this.SetScrollInfo(typeOfScrollBar, true)

				DllCall("SetScrollPos", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Int", position, "Int", true)

				if (typeOfScrollBar = this.SB_HORZ)
					this.ScrollWindow(-delta, 0)
				else
					this.ScrollWindow(0, -delta)

				this.UpdateFixedControlsPosition()
			}
		}

		ScrollAction(typeOfScrollBar, wParam) {
			local scrollInfo := this.GetScrollInfo(typeOfScrollBar)
			local minPos, maxPos, maxThumbPos

			HiWord(wParam) {
				return (wParam >> 16)
			}

			LoWord(wParam) {
				return (wParam & 0xFFFF)
			}

			this.OldPos := scrollInfo.Pos

			this.GetScrollRange(typeOfScrollBar, &minPos, &maxPos)

			maxThumbPos := (scrollInfo.Max - scrollInfo.Min + 1 - scrollInfo.Page)

			switch LoWord(wParam) {
				case this.SB_LINELEFT, this.SB_LINEUP:
					scrollInfo.Pos := Max(scrollInfo.Pos - 15, minPos)
				case this.SB_PAGELEFT, this.SB_PAGEUP:
					scrollInfo.Pos := Max(scrollInfo.Pos - scrollInfo.Page, minPos)
				case this.SB_LINERIGHT, this.SB_LINEDOWN:
					scrollInfo.Pos := Min(scrollInfo.Pos + 15, maxThumbPos)
				case this.SB_PAGERIGHT, this.SB_PAGEDOWN:
					scrollInfo.Pos := Min(scrollInfo.Pos + scrollInfo.Page, maxThumbPos)
				case this.SB_THUMBTRACK:
					scrollInfo.Pos := HiWord(wParam)
				default:
					return
			}

			this.SetScrollInfo(typeOfScrollBar, true)

			DllCall("SetScrollPos", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Int", scrollInfo.Pos, "Int", true)
		}

		GetClientRect() {
			return DllCall("GetClientRect", "UInt", this.Window.Hwnd, "Ptr", this.Rect.Ptr)
		}

		GetHeight() {
			this.GetClientRect()

			return NumGet(this.Rect, 12, "Int")
		}

		GetWidth() {
			this.GetClientRect()

			return NumGet(this.Rect, 8, "Int")
		}

		GetEdges(&left?, &right?, &top?, &bottom?) {
			local ignore, control, cX, cY, cW, cH

			left := top := 9999
			right := bottom := 0

			for ignore, control in WinGetControls(this.Window.Hwnd) {
				this.Window[control].GetPos(&cX, &cY, &cW, &cH)

				if (cX < left)
					left := cX

				if (cY < top)
					top := cY

				if ((cX + cW) > right)
					right := (cX + cW)

				if ((cY + cH) > bottom)
					bottom := (cY + cH)
			}

			/*
			left -= 8
			top -= 8
			right += 8
			bottom += 8
			*/
		}

		ShowScrollBar(typeOfScrollBar, bool) {
			return DllCall("ShowScrollBar", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Int", bool)
		}

		GetScrollInfo(typeOfScrollBar) {
			local minPos, maxPos

			this.iScrollInfo.Mask := this.SIF_ALL

			DllCall("GetScrollInfo", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Ptr", this.iScrollInfo.Ptr)

			this.iScrollInfo.Pos := DllCall("GetScrollPos", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Int")

			this.GetScrollRange(typeOfScrollBar, &minPos, &maxPos)

			this.iScrollInfo.Min := minPos
			this.iScrollInfo.Max := maxPos

			return this.iScrollInfo
		}

		SetScrollInfo(typeOfScrollBar, redraw) {
			DllCall("SetScrollInfo", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Ptr", this.iScrollInfo.Ptr, "Int", redraw)
		}

		GetScrollRange(typeOfScrollBar, &minPos, &maxPos) {
			local minnn := Buffer(4)
			local maxxx := Buffer(4)
			local r := DllCall("GetScrollRange", "Ptr", this.Window.Hwnd, "Int", typeOfScrollBar, "Ptr", minnn.Ptr, "Ptr", maxxx.Ptr)

			minPos := NumGet(minnn, "Int")
			maxPos := NumGet(maxxx, "Int")

			return r
		}

		ScrollWindow(xAmount, yAmount) {
			return DllCall("ScrollWindow", "Ptr", this.Window.Hwnd, "Int", xAmount, "Int", yAmount, "Ptr", 0, "Ptr", 0, "Int")
		}
	}

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
							logError("Unknown variable detected in ControlResizer.Optimize...")
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
			local control := this.Control
			local x := this.OriginalX
			local y := this.OriginalY
			local w := this.OriginalWidth
			local h := this.OriginalHeight

			this.Rule[true](&x, &y, &w, &h, deltaWidth, deltaHeight)

			ControlMove(x, y, w, h, control)

			control.__CX := x
			control.__CY := y
			control.__CWidth := w
			control.__CHeight := h
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

	Scrollable {
		Get {
			return this.iScrollable
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

	Scrollbar {
		Get {
			return this.iScrollbar
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
				case "Scrollable":
					this.iScrollable := argument
				case "Descriptor":
					this.iDescriptor := argument

					if argument
						Task.startTask(ObjBindMethod(this, "UpdatePosition", argument), 5000, kHighPriority)
				case "Options":
					options := argument
			}

		DllCall("SetThreadDpiAwarenessContext", "Ptr", -5, "Ptr")

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

		this.SetFont("s8", "Arial")

		this.InitializeTheme()
	}

	Destroy() {
		if this.Scrollbar {
			this.Scrollbar.Dispose()

			this.iScrollbar := false
		}

		super.Destroy()
	}

	static DefineCustomControl(type, constructor) {
		Window.sCustomControlTypes[type] := constructor
	}

	Block() {
		if (this.iBlockLevel++ = 0)
			try
				this.Opt("+Disabled")
	}

	Unblock() {
		if (--this.iBlockLevel <= 0) {
			this.iBlockLevel := 0

			try
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
		local checkBox, label, x, y, w, h

		control := this.Theme.AddControl(this, type, options, arguments*)

		if control
			return control

		if (isDevelopment() && (Strsplit(A_ScriptName, ".")[1] != "Simulator Tools"))
			options .= " Border"

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

			ControlGetPos(&x, &y, &w, &h, control)

			control.__CX := x
			control.__CY := y
			control.__CWidth := w
			control.__CHeight := h

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

		SetWindowAttribute(dwAttribute, pvAttribute?) => DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', this.Hwnd, "uint", dwAttribute, "uint*", pvAttribute, "int", 4)

		this.Theme.InitializeControls(this)

		super.Show(arguments*)

		for ignore, control in this.iCustomControls
			if (control.Visible && control.HasProp("Show"))
				control.Show()

		if !this.OrigWidth {
			WinGetClientPos(&x, &y, &cWidth, &cHeight, this)
			WinGetPos(&x, &y, &width, &height, this)

			if (VerCompare(A_OSVersion, "10.0.22000") >= 0)
				SetWindowAttribute(33, 2)

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

			if this.Scrollable {
				this.iScrollbar := Window.Scrollbar(this, cWidth, cHeight)

				this.Scrollbar.UpdateScrollBars()
			}
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

			if ((x && y) && ((this.iLastX != x) || (this.iLastY != y))) {
				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(settings, "Window Positions", descriptor . ".X", x)
				setMultiMapValue(settings, "Window Positions", descriptor . ".Y", y)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

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

				if this.Scrollbar {
					width -= 16
					height -= 16
				}

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

		if this.Scrollbar
			this.Scrollbar.ScrollOrigin()

		if InStr(minMax, "Init")
			WinMove( , , width + (this.Scrollbar ? 16 : 0), height + (this.Scrollbar ? 16 : 0), this)
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
;;;                     Private Class Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class RecolorizerTask extends PeriodicTask {
	iProgressWindow := false

	iStart := A_TickCount
	iProgress := false

	__New() {
		super.__New(false, 200, kInterruptPriority)
	}

	run() {
		if (A_TickCount > (this.iStart + 250))
			if !this.iProgress
				this.iProgressWindow := ProgressWindow.showProgress({progress: this.iProgress++, color: "Blue"
																   , title: translate("Recoloring Image")})
			else if (this.iProgress != "Stop")
				this.iProgressWindow.updateProgress({progress: Min(100, this.iProgress++)})
	}

	stop() {
		this.iProgress := "Stop"

		if this.iProgressWindow
			this.iProgressWindow.hideProgress()

		super.stop()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;


MsgDlg(Text?, Title?, Options?, IconPath?) => Theme.ThemedDialog(MsgBox, Text?, Title?, Options?, IconPath?)

InputDlg(Prompt?, Title?, Options?, Default?) => Theme.ThemedDialog(InputBox, Prompt?, Title?, Options?, Default?)

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
		file := window.Theme.RecolorizeImage(file)

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

trackMouse(button, tracker) {
	local curCoordMode := A_CoordModeMouse
	local startX, startY, x, y

	CoordMode("Mouse", "Screen")

	try {
		MouseGetPos(&startX, &startY)

		startX := screen2Window(startX)
		startY := screen2Window(startY)

		while GetKeyState(button) {
			MouseGetPos(&x, &y)

			tracker.Call(startX, startY, screen2Window(x), screen2Window(y))
		}
	}
	finally {
		CoordMode("Mouse", curCoordMode)
	}
}

moveByMouse(window, descriptor := false, *) {
	local winX, winY, settings

	WinGetPos(&winX, &winY, , , window)

	winX := screen2Window(winX)
	winY := screen2Window(winY)

	trackMouse("LButton", (startX, startY, newX, newY) {
		newX := (winX + (newX - startX))
		newY := (winY + (newY - startY))

		WinMove(newX, newY, , , window)
	})

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

			if isDebug()
				logMessage(kLogDebug, values2String(A_Space, "Checking (", posX, posY, ") against:", A_index, "-"
														   , screenLeft, screenTop, screenRight, screenBottom))

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
			if WinActive(theWindow)
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
	return modifiedImage(fileName, postFix, modifier, "Icons")
}

modifiedImage(fileName, postFix, modifier, cache := "Images") {
	local extension, name, modifiedFileName, token, bitmap, graphics, create

	SplitPath(fileName, , , &extension, &name)

	if (extension = "ico")
		extension := "png"

	modifiedFileName := (kTempDirectory . cache . "\" . name . "_" . postFix . "." . extension)

	create := !FileExist(modifiedFileName)

	if !create
		create := (FileGetTime(modifiedFileName, "M") < FileGetTime(fileName, "M"))

	if create {
		deleteFile(modifiedFileName)

		DirCreate(kTempDirectory . cache)

		token := Gdip_Startup()

		bitmap := Gdip_CreateBitmapFromFile(fileName)

		graphics := Gdip_GraphicsFromImage(bitmap)

		modifier(graphics, bitmap)

		try {
			Gdip_SaveBitmapToFile(bitmap, modifiedFileName)
		}
		catch Any as exception {
			if !FileExist(modifiedFileName) {
				logError(exception, true)

				return fileName
			}
		}
		finally {
			Gdip_DisposeImage(bitmap)

			Gdip_DeleteGraphics(graphics)

			Gdip_Shutdown(token)
		}
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
	catch Any {
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