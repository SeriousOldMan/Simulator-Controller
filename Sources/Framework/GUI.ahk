;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - GUI Functions                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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
				case "EvenRow", "OddRow":
					return this.AlternateBackColor
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
				case "EvenRow", "OddRow":
					return this.AlternateBackColor
				case "Frame":
					return "000000"
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
				case "Unavailable":
					return "Silver"
			}
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
				case "Text", "Picture", "GroupBox", "Radio", "Slider", "Link":
					options .= (" Background" . this.WindowBackColor)
			}
		}

		; if (!RegExMatch(options, "c[0-9a-fA-F]{6}") && !InStr(options, "c" . this.LinkColor))
		;	options .= (" c" . this.TextColor)

		return options
	}

	ApplyThemeProperties(window, control) {
	}
}

/*
class UserTheme extends ConfigurationItem {
	iDescriptor := false

	iWindowBackground := false
	iAltBackground := false
	iFieldBackground := false
	iMenuBackground := false
	iHeaderBackground := false
	iTextColor := false
	iButtonColor := false
	iDropDownColor := false

	Descriptor {
		Get {
			return this.iDescriptor
		}
	}

	WindwBackground {
		Get {
			return this.iWindowBackground
		}
	}

	AltBackground {
		Get {
			return this.iAltBackground
		}
	}

	FieldBackground {
		Get {
			return this.iFieldBackground
		}
	}

	MenuBackground {
		Get {
			return this.iMenuBackground
		}
	}

	HeaderBackground {
		Get {
			return this.iHeaderBackground
		}
	}

	TextColor {
		Get {
			return this.iTextColor
		}
	}

	ButtonColor {
		Get {
			return this.iButtonColor
		}
	}

	DropDownColor {
		Get {
			return this.iDropDownColor
		}
	}

	__New(descriptor, configuration := false) {
		this.iDescriptor := descriptor

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.iWindowBackground := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "WindowBackground"))
		this.iAltBackground := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "AltBackground"))
		this.iFieldBackground := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "FieldBackground"))
		this.iMenuBackground := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "MenuBackground"))
		this.iHeaderBackground := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "HeaderBackground"))
		this.iTextColor := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "TextColor"))
		this.iButtonColor := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "ButtonColor"))
		this.iDropDownColor := getMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "DropDownColor"))
	}

	saveToConfiguration(configuration) {
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "WindowBackground"), this.WindowBackground)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "AltBackground"), this.AltBackground)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "FieldBackground"), this.FieldBackground)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "MenuBackground"), this.MenuBackground)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "HeaderBackground"), this.HeaderBackground)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "TextColor"), this.TextColor)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "ButtonColor"), this.ButtonColor)
		setMultiMapValue(configuration, "Themes", ConfigurationItem.descriptor(this.Descriptor, "DropDownColor"), this.DropDownColor)
	}
}
*/

class WindowsTheme extends Theme {
	Descriptor {
		Get {
			return "Windows"
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

	InitializeWindow(window) {
	}

	ComputeControlOptions(window, type, options) {
		options := StrReplace(options, "-Theme", "")

		if ((type = "Text") && (InStr(options, "0x10") && !InStr(options, "0x100")))
			options := StrReplace(options, "0x10", "h1 Border")

		return options
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
					return "E8E8E8"
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
					return "E8E8E8"
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
			return ((mode = "Normal") ? "000000" : ((mode = "Disabled") ? "505050" : "808080"))
		}
	}

	LinkColor {
		Get {
			return "Blue"
		}
	}
}

class DarkTheme extends ClassicTheme {
	Descriptor {
		Get {
			return "Dark"
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
}

class Window extends Gui {
	static sCustomControlTypes := CaseInsenseMap()

	iTheme := false

	iCloseable := false
	iResizeable := false

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
			return this.iCloseable
		}
	}

	Resizeable {
		Get {
			return this.iResizeable
		}
	}

	MinWidth {
		Get {
			return this.iMinWidth
		}

		Set {
			try {
				return (this.iMinWidth := value)
			}
			finally {
				this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	MinHeight {
		Get {
			return this.iMinHeight
		}

		Set {
			try {
				return (this.iMinHeight := value)
			}
			finally {
				this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	MaxWidth {
		Get {
			return this.iMaxWidth
		}

		Set {
			try {
				return (this.iMaxWidth := value)
			}
			finally {
				if this.MaxWidth
					this.Opt("+MaxSize" . this.MaxWidth . "x")
				else
					this.Opt("-MaxSize")

				this.Resize("Auto", this.Width, this.Height)
			}
		}
	}

	MaxHeight {
		Get {
			return this.iMaxHeight
		}

		Set {
			try {
				return (this.iMaxHeight := value)
			}
			finally {
				if this.MaxHeight
					this.Opt("+MaxSize" . "x" . this.MaxHeight)
				else
					this.Opt("-MaxSize")

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
						Task.startTask(ObjBindMethod(this, "UpdatePosition", argument), 2000, kLowPriority)
				case "Options":
					options := argument
			}

		super.__New("", title, arguments*)

		if !this.Theme
			this.iTheme := Theme.CurrentTheme

		this.OnEvent("Close", this.Close)

		if this.Resizeable {
			this.Opt("+Resize")

			this.OnEvent("Size", this.Resize)
		}
		else
			this.Opt("-SysMenu -Border -Caption +0x800000")

		if !isObject(options)
			this.Opt("-DPIScale " . options)
		else
			this.Opt("-DPIScale")

		this.InitializeTheme()
	}

	static DefineCustomControl(type, constructor) {
		Window.sCustomControlTypes[type] := constructor
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

		if type is Window.Resizer
			return this.AddResizer(type)
		else {
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

		super.Show(arguments*)

		for ignore, control in this.iCustomControls
			if (control.Visible && control.HasProp("Show"))
				control.Show()

		if !this.MinWidth {
			WinGetClientPos(&x, &y, &cWidth, &cHeight, this)
			WinGetPos(&x, &y, &width, &height, this)

			width := screen2Window(width)
			height := screen2Window(height)
			cWidth := screen2Window(cWidth)
			cHeight := screen2Window(cHeight)

			this.iTitleBarHeight := height - cHeight

			this.iMinWidth := width
			this.iMinHeight := height

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
					if GetKeyState(button, "P")
						return Task.CurrentTask

				resizeTask := false
			}

			curPriority := Task.block(kInterruptPriority)

			try {
				WinGetPos( , , &width, &height, this)

				width := screen2Window(width)
				height := screen2Window(height)

				if (width < this.MinWidth) {
					width := this.MinWidth
					restricted := true
				}
				else if (this.MaxWidth && (width > this.MaxWidth)) {
					width := this.MaxWidth
					restricted := true
				}

				if (height < this.MinHeight) {
					height := this.MinHeight
					restricted := true
				}
				else if (this.MaxHeight && (height > this.MaxHeight)) {
					height := this.MaxHeight
					restricted := true
				}

				if this.ControlsRestrictResize(&width, &height)
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
		local deltaWidth := (width - this.MinWidth)
		local deltaHeight := (height - this.MinHeight)
		local restricted := false
		local ignore, resizer

		for ignore, resizer in this.Resizers
			if resizer.RestrictResize(&deltaWidth, &deltaHeight)
				restricted := true

		if restricted {
			width := (this.MinWidth + deltaWidth)
			height := (this.MinHeight + deltaHeight)
		}

		return restricted
	}

	ControlsResize(width, height) {
		local deltaWidth := (width - this.MinWidth)
		local deltaHeight := (height - this.MinHeight)
		local ignore, resizer

		for ignore, resizer in this.Resizers
			resizer.Resize(deltaWidth, deltaHeight)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getAllUIThemes(configuration) {
	return [WindowsTheme(), ClassicTheme(), DarkTheme()]
}

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

openDocumentation(dialog, url, *) {
	Run(url)
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

		while GetKeyState("LButton", "P") {
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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeGUI() {
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

	Window.DefineCustomControl("Documentation", createDocumentation)

	try {
		Theme.CurrentTheme := %getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "General", "UI Theme", "Classic") . "Theme"%()
	}
	catch Any as exception {
		Theme.CurrentTheme := ClassicTheme()
	}

	; DllCall("User32\SetProcessDpiAwarenessContext", "UInt" , -1)
	; DllCall("User32\SetThreadDpiAwarenessContext", "UInt" , -1)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeGUI()