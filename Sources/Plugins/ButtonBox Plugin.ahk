;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Plugin               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

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
		Gui BB1:Add, Text, x40 y8 w457 h23 +0x200 +0x1 BackgroundTrans, % translate("Modular Simulator Controller System")
		Gui BB1:Font, s10 cSilver
		Gui BB1:Add, Text, x40 y28 w457 h23 +0x200 +0x1 BackgroundTrans, % translate("Button Box")
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
		
		this.associateGui("BB1", 543, 368)
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
		Gui BB2:Add, Text, x40 y8 w359 h23 +0x200 +0x1 BackgroundTrans, % translate("Modular Simulator Controller System")
		Gui BB2:Font, s10 cSilver
		Gui BB2:Add, Text, x40 y28 w359 h23 +0x200 +0x1 BackgroundTrans, % translate("Button Box")
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
		
		this.associateGui("BB2", 432, 323)
	}
}

initializeButtonBoxPlugin() {
	controller := SimulatorController.Instance
	
	new ButtonBox1(controller, controller.Configuration)
	new ButtonBox2(controller, controller.Configuration)
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

moveButtonBox() {
	ButtonBox.findButtonBox(A_Gui).moveByMouse(A_Gui)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeButtonBoxPlugin()