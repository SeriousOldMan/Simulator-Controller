; Copyright (c) 2011, SATO Kentaro
; BSD 2-Clause license

#include AHKUnit\AHKUnit\AhkUnit.ahk

class AhkUnit_GuiRunner extends AhkUnit_Runner {
	static nextGuiWindowIndex := 1
	; guiWindowName
	; savedDefaultGuiWindow
	
	__New() {
		global ahkUnitResultTree
		base.__New()
		guiWindowIndex := AhkUnit_GuiRunner.nextGuiWindowIndex++
		this.guiWindowName := "AhkUnitGuiRunner" . guiWindowIndex
		this.GuiBegin_()
		Gui,Add,TreeView,vahkUnitResultTree R30 w600
		Gui,Add,Button,Default W72 gAhkUnitGuiOk,&OK
		Gui,Add,Button,W72 gAhkUnitGuiReload xp+80 yp+0,&Reload
		Gui,+LabelAhkUnitGui
		this.GuiEnd_()
	}
	
	Default() {
		base.Default()
		this.ShowReport()
	}
	
	GuiBegin_() {
		this.savedDefaultGuiWindow := A_Gui ? A_Gui : 1
		guiWindowName := this.guiWindowName
		Gui,%guiWindowName%:Default
	}
	
	GuiEnd_() {
		savedDefaultGuiWindow := this.savedDefaultGuiWindow
		Gui,%savedDefaultGuiWindow%:Default
		this.savedDefaultGuiWindow := 0
	}
	
	Run(params*) {
		global ahkUnitResultTree
		base.Run(params*)
		this.GuiBegin_()
		GuiControl,-Redraw,ahkUnitResultTree
		count := this.GetCount()
		statusString := this.testClass.__Class
		statusOptions := ""
		if (count.failure) {
			statusOptions := "Expand Bold"
		} else if (count.incomplete) {
			statusString .= ": Incomplete"
		} else {
			statusString .= ": OK"
		}
		statusItem := TV_Add(statusString, 0, statusOptions)
		reportItem := TV_Add(this.GetResult(), statusItem)
		reportItem := TV_Add(this.GetCountString(), statusItem)
		message := this.GetMessage()
		if (message != "") {
			reportItem := TV_Add("", statusItem)
			reportItem := this.TV_AddMultiLine(message, statusItem)
		}
		GuiControl,+Redraw,ahkUnitResultTree
		this.GuiEnd_()
	}
	
	TV_AddMultiLine(string, parent = 0, options = "Expand") {
		while (SubStr(string, 0, 1) == "`n") {
			StringTrimRight,string,string,1
		}
		previousItem := 0
		loop,parse,string,`n
		{
			itemString := A_LoopField
			itemParent := parent
			if (previousItem && SubStr(itemString, 1, 2) == "  ") {
				itemParent := previousItem
				StringTrimLeft,itemString,itemString,2
			}
			newItem := TV_Add(itemString, itemParent, options)
			if (itemParent == parent) {
				previousItem := newItem
			}
	    }
	}
	
	ShowReport() {
		guiWindowName := this.guiWindowName
		Gui,%guiWindowName%:Show
	}
}

AhkUnit.GuiRunner := AhkUnit_GuiRunner
AhkUnit.SetDefaultRunner(AhkUnit.GuiRunner)

if (false) {
	; currently we cannot close each runner independently
	AhkUnitGuiClose:
		ExitApp
		return
	AhkUnitGuiOk:
		ExitApp
		return
	AhkUnitGuiReload:
		Reload
		return
}
