;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Plugin               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimpleButtonBox extends ButtonBox {
	iControlHandles := {}
	
	createWindow(ByRef window, ByRef windowWidth, ByRef windowHeight) {
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
		
		Gui SBB:-Border -Caption +AlwaysOnTop
		
		Gui SBB:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		Gui SBB:Font, s12 Bold cSilver
		Gui SBB:Add, Text, x40 y8 w457 h23 +0x200 +0x1 BackgroundTrans, Modular Simulator Controller System
		Gui SBB:Font, s10 cSilver
		Gui SBB:Add, Text, x40 y28 w457 h23 +0x200 +0x1 BackgroundTrans, Button Box
		Gui SBB:Color, 0x000000
		Gui SBB:Add, Picture, x33 y60 w54 h85 BackgroundTrans vtoggle1 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui SBB:Add, Picture, x137 y60 w54 h85 BackgroundTrans vtoggle2 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui SBB:Add, Picture, x241 y60 w54 h85 BackgroundTrans vtoggle3 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui SBB:Add, Picture, x345 y60 w54 h85 BackgroundTrans vtoggle4 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui SBB:Add, Picture, x449 y60 w54 h85 BackgroundTrans vtoggle5 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Toggle Switch.png"
		Gui SBB:Add, Picture, x40 y196 w40 h40 BackgroundTrans vbutton1 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x40 y284 w40 h40 BackgroundTrans vbutton5 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x144 y196 w40 h40 BackgroundTrans vbutton2 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x248 y196 w40 h40 BackgroundTrans vbutton3 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x352 y196 w40 h40 BackgroundTrans vbutton4 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x144 y284 w40 h40 BackgroundTrans vbutton6 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x248 y284 w40 h40 BackgroundTrans vbutton7 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x352 y284 w40 h40 BackgroundTrans vbutton8 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Push Button 3.png"
		Gui SBB:Add, Picture, x455 y195 w42 h42 BackgroundTrans vdial1 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Rotary Dial 3.png"
		Gui SBB:Add, Picture, x455 y283 w42 h42 BackgroundTrans vdial2 gfunctionClick, % kButtonBoxImagesDirectory . "Photorealistic\Rotary Dial 3.png"

		Gui SBB:Add, Text, x32 y148 w56 h30 Hwndtoggle1 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x136 y148 w56 h30 Hwndtoggle2 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x240 y148 w56 h30 Hwndtoggle3 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x344 y148 w56 h30 Hwndtoggle4 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x448 y148 w56 h30 Hwndtoggle5 +Border -Background  +0x1000 +0x1

		Gui SBB:Add, Text, x32 y239 w56 h30 Hwndbutton1 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x136 y239 w56 h30 Hwndbutton2 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x240 y239 w56 h30 Hwndbutton3 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x344 y239 w56 h30 Hwndbutton4 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x32 y327 w56 h30 Hwndbutton5 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x135 y327 w56 h30 Hwndbutton6 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x240 y327 w56 h30 Hwndbutton7 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x344 y327 w56 h30 Hwndbutton8 +Border -Background  +0x1000 +0x1

		Gui SBB:Add, Text, x448 y239 w56 h30 Hwnddial1 +Border -Background  +0x1000 +0x1
		Gui SBB:Add, Text, x448 y327 w56 h30 Hwnddial2 +Border -Background  +0x1000 +0x1

		Gui SBB:Add, Picture, x-10 y-10 gmoveButtonBox 0x4000000, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"

		Gui SBB:+AlwaysOnTop
			
		controlHandles := Object()
		
		Loop 5 {
			toggle := "toggle" . A_Index
		
			controlHandles[ConfigurationItem.descriptor(k2WayToggleType, A_Index)] := %toggle%
		}

		Loop 8 {
			button := "button" . A_Index
		
			controlHandles[ConfigurationItem.descriptor(kButtonType, A_Index)] := %button%
		}

		Loop 2 {
			dial := "dial" . A_Index
		
			controlHandles[ConfigurationItem.descriptor(kDialType, A_Index)] := %dial%
		}
		
		this.iControlHandles := controlHandles
		
		window := "SBB"
		windowWidth := 543
		windowHeight := 368
	}
	
	getControlHandle(descriptor) {
		if this.iControlHandles.HasKey(descriptor)
			return this.iControlHandles[descriptor]
		else
			return false
	}
}

initializeButtonBoxPlugin() {
	new SimpleButtonBox(SimulatorController.Instance, SimulatorController.Instance.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

functionClick() {
	MouseGetPos x, y
	
	if InStr(A_GuiControl, "button")
		pushButton(SubStr(A_GuiControl, 7, 1))
	else if InStr(A_GuiControl, "toggle")
		switchToggle(k2WayToggleType, SubStr(A_GuiControl, 7, 1), (y > 105) ? "Off" : "On")
	else
		rotateDial(SubStr(A_GuiControl, 5, 1), (x > 475) ? "Increase" : "Decrease")
}

moveButtonBox() {
	ButtonBox.Instance.moveByMouse()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeButtonBoxPlugin()