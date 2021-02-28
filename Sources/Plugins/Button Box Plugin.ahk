;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Plugin               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global bbControl1
global bbControl2
global bbControl3
global bbControl4
global bbControl5
global bbControl6
global bbControl7
global bbControl8
global bbControl9
global bbControl10
global bbControl11
global bbControl12
global bbControl13
global bbControl14
global bbControl15
global bbControl16
global bbControl17
global bbControl18
global bbControl19
global bbControl20
global bbControl21
global bbControl22
global bbControl23
global bbControl24
global bbControl25
global bbControl26
global bbControl27
global bbControl28
global bbControl29
global bbControl30
global bbControl31
global bbControl32
global bbControl33
global bbControl34
global bbControl35
global bbControl36
global bbControl37
global bbControl38
global bbControl39
global bbControl40
global bbControl41
global bbControl42
global bbControl43
global bbControl44
global bbControl45
global bbControl46
global bbControl47
global bbControl48
global bbControl49
global bbControl50


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class GridButtonBox extends ButtonBox {
	static kHeaderHeight := 60
	static kLabelMargin := 5
	
	static kRowMargin := 20
	static kColumnMargin := 30
	
	static kBorderMargin := 30
	static kBottomMargin := 20
	
	static sHandleCounter := 1
	static sWindowCounter := 1
	
	iName := false
	
	iRows := 0
	iColumns := 0
	iDirection := false
	
	iRowDefinitions := []
	iControls := {}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	Rows[] {
		Get {
			return this.iRows
		}
	}
	
	Columns[] {
		Get {
			return this.iColumns
		}
	}
	
	Direction[] {
		Get {
			return this.iDirection
		}
	}
	
	RowDefinitions[row := false] {
		Get {
			if row
				return this.iRowDefinitions[row]
			else
				return this.iRowDefinitions
		}
	}
	
	__New(name, controller, configuration) {
		this.iName := name
		
		base.__New(controller, configuration)
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		layout := string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, "Layout"), ""))
		
		this.iDirection := layout[2]
		
		layout := string2Values("x", layout[1])
		
		this.iRows := layout[1]
		this.iColumns := layout[2]
		
		rows := []
		
		Loop % this.Rows
			rows.Push(string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, A_Index), "")))
		
		this.iRowDefinitions := rows
	}
	
	createGui() {
		local function
		
		window := "bbWindow" . this.windowCounter++
		
		num1WayToggles := 0
		num2WayToggles := 0
		numButtons := 0
		numDials := 0
		
		rowHeights := false
		columnWidths := false
		
		this.computeLayout(rowHeights, columnWidths)
		
		height := 0
		Loop % rowHeights.Length()
			height += rowHeights[A_Index]
		
		width := 0
		Loop % columnWidths.Length()
			width += columnWidths[A_Index]
		
		height += ((rowHeights.Length() - 1) * this.kRowMargin) + this.kHeaderHeight + this.kBottomMargin
		width += ((columnWidths.Length() - 1) * this.kColumnMargin) + (2 * this.kBorderMargin)
		
		Gui %window%:-Border -Caption +AlwaysOnTop
		
		Gui %window%:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		Gui %window%:Font, s12 Bold cSilver
		Gui %window%:Add, Text, x0 y8 w%width% h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate("Modular Simulator Controller System")
		Gui %window%:Font, s10 cSilver
		Gui %window%:Add, Text, x0 y28 w%width% h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate(this.Name)
		Gui %window%:Color, 0x000000
		Gui %window%:Font, Norm, Arial
		
		vertical := this.kHeaderHeight
		
		Loop % this.Rows
		{
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]
		
			horizontal := this.kBorderMargin
			
			Loop % this.Columns
			{
				columnWidth := columnWidths[A_Index]
			
				descriptor := string2Values(",", rowDefinition[A_Index])
				
				label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
				labelWidth := label[1]
				labelHeight := label[2]
				
				descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
				number := descriptor[2]
				
				descriptor := string2Values(";", getConfigurationValue(this.Configuration, "Controls", descriptor[1], ""))
				
				function := descriptor[1]
				image := substituteVariables(descriptor[2])
				
				descriptor := string2Values("x", descriptor[3])
				imageWidth := descriptor[1]
				imageHeight := descriptor[2]
				
				switch function {
					case k1WayToggleType:
						num1WayToggles += 1
					case k2WayToggleType:
						num2WayToggles += 1
					case kButtonType:
						numButtons += 1
					case kDialType:
						numDials += 1
				}
				
				function := ConfigurationItem.descriptor(function, number)

				x := horizontal + Round((columnWidth - imageWidth) / 2)
				y := vertical + Round((rowHeight - (labelHeight + this.kLabelMargin) - imageWidth) / 2)
				msgbox % x . " " . y
				variable := "bbControl" + this.sHandleCounter++
				
				Gui %window%:Add, Picture, x%x% y%y% w%imageWidth% h%imageHeight% BackgroundTrans v%variable% gcontrolClick, %image%

				this.registerControl(variable, function, x, y, imageWidth, imageHeight)
				
				Gui %window%:Font, Norm
		
				x := horizontal + Round((columnWidth - labelWidth) / 2)
				y := vertical + rowHeight - labelHeight
				
				Gui %window%:Add, Text, x%x% y%y% w%labelWidth% h%labelHeight% Hwnd%variable% +Border -Background  +0x1000 +0x1
				
				this.registerControlHandle(function, variable)
				
				horizontal += (columnWidth + this.kColumnMargin)
			}
		
			vertical += (rowHeight + this.kRowMargin)
		}
		
		this.associateGui(window, width, height, num1WayToggles, num1WayToggles, numButtons, numDials)
		
		msgbox % "Create " . values2String(", ", this.Configuration.Count(), this.Rows, this.Columns, window, width, height, num1WayToggles, num1WayToggles, numButtons, numDials)
	}
	
	computeLayout(ByRef rowHeights, ByRef columnWidths) {
		columnWidths := []
		rowHeights := []
		
		Loop % this.Columns
			columnWidths.Push(0)
		
		Loop % this.Rows
		{
			rowHeight := 0
		
			rowDefinition := this.RowDefinitions[A_Index]
			
			Loop % this.Columns
			{
				descriptor := string2Values(",", rowDefinition[A_Index])
				
				label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
				labelWidth := label[1]
				labelHeight := label[2]
				
				descriptor := string2Values(";", getConfigurationValue(this.Configuration, "Controls", ConfigurationItem.splitDescriptor(descriptor[1])[1], ""))
				descriptor := string2Values("x", descriptor[3])
				
				imageWidth := descriptor[1]
				imageHeight := descriptor[2]
				
				rowHeight := Max(rowHeight, imageHeight + this.kLabelMargin + labelHeight)
				
				columnWidths[A_Index] := Max(columnWidths[A_Index], Max(imageWidth, labelWidth))
			}
			
			rowHeights.Push(rowHeight)
			
			showMessage(rowHeight)
		}
	}
	
	registerControl(variable, function, x, y, width, height) {
		this.iControls[variable] := Array(function, x, y, width, height)
	}
	
	findControl(variable) {
		if this.iControls.HasKey(variable)
			return this.iControls[variable]
		else
			return false
	}
}

class ButtonBox1 extends ButtonBox {
	createGui() {
		static toggle1
		static toggle2
		static toggle3
		static toggle4
		static toggle5
		static button1
		static button2
		static button3
		static button4
		static button5
		static button6
		static button7
		static button8
		static dial1
		static dial2
		
		Gui BB1:-Border -Caption +AlwaysOnTop
		
		Gui BB1:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		Gui BB1:Font, s12 Bold cSilver
		Gui BB1:Add, Text, x40 y8 w457 h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate("Modular Simulator Controller System")
		Gui BB1:Font, s10 cSilver
		Gui BB1:Add, Text, x40 y28 w457 h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate("Button Box")
		Gui BB1:Color, 0x000000
		Gui BB1:Font, Norm, Arial
		Gui BB1:Add, Picture, x33 y60 w54 h85 BackgroundTrans vtoggle1 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui BB1:Add, Picture, x137 y60 w54 h85 BackgroundTrans vtoggle2 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui BB1:Add, Picture, x241 y60 w54 h85 BackgroundTrans vtoggle3 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui BB1:Add, Picture, x345 y60 w54 h85 BackgroundTrans vtoggle4 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui BB1:Add, Picture, x449 y60 w54 h85 BackgroundTrans vtoggle5 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui BB1:Add, Picture, x40 y196 w40 h40 BackgroundTrans vbutton1 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x144 y196 w40 h40 BackgroundTrans vbutton2 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x248 y196 w40 h40 BackgroundTrans vbutton3 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x352 y196 w40 h40 BackgroundTrans vbutton4 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x40 y284 w40 h40 BackgroundTrans vbutton5 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x144 y284 w40 h40 BackgroundTrans vbutton6 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x248 y284 w40 h40 BackgroundTrans vbutton7 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x352 y284 w40 h40 BackgroundTrans vbutton8 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB1:Add, Picture, x455 y195 w42 h42 BackgroundTrans vdial1 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Rotary Dial 3.png"
		Gui BB1:Add, Picture, x455 y283 w42 h42 BackgroundTrans vdial2 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Rotary Dial 3.png"

		Gui BB1:Font, Norm
		
		Gui BB1:Add, Text, x32 y148 w56 h30 Hwndtoggle1 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x136 y148 w56 h30 Hwndtoggle2 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x240 y148 w56 h30 Hwndtoggle3 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x344 y148 w56 h30 Hwndtoggle4 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x448 y148 w56 h30 Hwndtoggle5 +Border -Background  +0x1000 +0x1

		Gui BB1:Add, Text, x32 y239 w56 h30 Hwndbutton1 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x136 y239 w56 h30 Hwndbutton2 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x240 y239 w56 h30 Hwndbutton3 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x344 y239 w56 h30 Hwndbutton4 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x32 y327 w56 h30 Hwndbutton5 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x135 y327 w56 h30 Hwndbutton6 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x240 y327 w56 h30 Hwndbutton7 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x344 y327 w56 h30 Hwndbutton8 +Border -Background  +0x1000 +0x1

		Gui BB1:Add, Text, x448 y239 w56 h30 Hwnddial1 +Border -Background  +0x1000 +0x1
		Gui BB1:Add, Text, x448 y327 w56 h30 Hwnddial2 +Border -Background  +0x1000 +0x1

		Gui BB1:Add, Picture, x-10 y-10 gmoveButtonBox 0x4000000, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"

		Gui BB1:+AlwaysOnTop
		
		Loop 5 {
			toggle := "toggle" . A_Index
		
			this.registerControlHandle(ConfigurationItem.descriptor(k2WayToggleType, A_Index), %toggle%)
		}

		Loop 8 {
			button := "button" . A_Index
		
			this.registerControlHandle(ConfigurationItem.descriptor(kButtonType, A_Index), %button%)
		}

		Loop 2 {
			dial := "dial" . A_Index
		
			this.registerControlHandle(ConfigurationItem.descriptor(kDialType, A_Index), %dial%)
		}
		
		this.associateGui("BB1", 543, 368, 0, 5, 8, 2)
	}
}

class ButtonBox2 extends ButtonBox {
	createGui() {
		static button9
		static button10
		static button11
		static button12
		static button13
		static button14
		static button15
		static button16
		static button17
		static button18
		static button19
		static button20
		
		Gui BB2:-Border -Caption +AlwaysOnTop
		
		Gui BB2:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		Gui BB2:Font, s12 Bold cSilver
		Gui BB2:Add, Text, x40 y8 w359 h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate("Modular Simulator Controller System")
		Gui BB2:Font, s10 cSilver
		Gui BB2:Add, Text, x40 y28 w359 h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate("Button Box")
		Gui BB2:Color, 0x000000
		Gui BB1:Font, Norm, Arial
		Gui BB2:Add, Picture, x40 y60 w40 h40 BackgroundTrans vbutton9 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x145 y60 w40 h40 BackgroundTrans vbutton10 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x248 y60 w40 h40 BackgroundTrans vbutton11 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x352 y60 w40 h40 BackgroundTrans vbutton12 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x40 y151 w40 h40 BackgroundTrans vbutton13 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x144 y151 w40 h40 BackgroundTrans vbutton14 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x248 y151 w40 h40 BackgroundTrans vbutton15 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x352 y151 w40 h40 BackgroundTrans vbutton16 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x40 y239 w40 h40 BackgroundTrans vbutton17 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x144 y239 w40 h40 BackgroundTrans vbutton18 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x248 y239 w40 h40 BackgroundTrans vbutton19 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui BB2:Add, Picture, x352 y239 w40 h40 BackgroundTrans vbutton20 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"

		Gui BB2:Font, Norm
		
		Gui BB2:Add, Text, x32 y103 w56 h30 Hwndbutton9 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x136 y103 w56 h30 Hwndbutton10 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x240 y103 w56 h30 Hwndbutton11 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x344 y103 w56 h30 Hwndbutton12 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x32 y194 w56 h30 Hwndbutton13 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x136 y194 w56 h30 Hwndbutton14 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x240 y194 w56 h30 Hwndbutton15 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x344 y194 w56 h30 Hwndbutton16 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x32 y282 w56 h30 Hwndbutton17 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x135 y282 w56 h30 Hwndbutton18 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x240 y282 w56 h30 Hwndbutton19 +Border -Background  +0x1000 +0x1
		Gui BB2:Add, Text, x344 y282 w56 h30 Hwndbutton20 +Border -Background  +0x1000 +0x1

		Gui BB2:Add, Picture, x-10 y-10 gmoveButtonBox 0x4000000, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"

		Gui BB2:+AlwaysOnTop
		
		Loop 12 {
			button := "button" . (A_Index + 8)
		
			this.registerControlHandle(ConfigurationItem.descriptor(kButtonType, A_Index + 8), %button%)
		}
		
		this.associateGui("BB2", 432, 323, 0, 0, 12, 0)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

functionClick() {
	MouseGetPos x, y
	
	if InStr(A_GuiControl, "button")
		pushButton(SubStr(A_GuiControl, 7))
	else if InStr(A_GuiControl, "toggle")
		switchToggle(k2WayToggleType, SubStr(A_GuiControl, 7), (y > 105) ? "Off" : "On")
	else
		rotateDial(SubStr(A_GuiControl, 5), (x > 475) ? "Increase" : "Decrease")
}

controlClick() {
	local function
	
	MouseGetPos x, y
	
	function := ButtonBox.findButtonBox(A_Gui).findFunction(A_GuiControl)
	
	if function {
		MouseGetPos x, y
				
		switch ConfigurationItem.splitDescriptor(function[1])[1] {
			case kButtonType:
				pushButton(function[1])
			case kDialType:
				rotateDial(function[1], (x > (function[2] + Round(function[4] / 2))) ? "Increase" : "Descrease")
			case k1WayToggleType:
				switchToggle(k1WayToggleType, (y > (function[3] + Round(function[5] / 2))) ? "Off" : "On")
			case k2WayToggleType:
				switchToggle(k2WayToggleType, (y > (function[3] + Round(function[5] / 2))) ? "Off" : "On")
		}
	}
}

moveButtonBox() {
	ButtonBox.findButtonBox(A_Gui).moveByMouse(A_Gui)
}

initializeButtonBoxPlugin() {
	controller := SimulatorController.Instance
	
	; new ButtonBox1(controller, controller.Configuration)
	; new ButtonBox2(controller, controller.Configuration)
	
	new GridButtonBox("Master Controller", controller, readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeButtonBoxPlugin()