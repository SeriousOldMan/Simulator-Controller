;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Item List         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationItemList                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfigurationItemList extends ConfigurationItem {
	static sListControls := {}
	
	iListHandle := false
	iAddButton := ""
	iDeleteButton := ""
	iUpdateButton := ""
	iUpButton := false
	iDownButton := false
	
	iItemList := []
	iCurrentItem := 0
	
	ListHandle[] {
		Get {
			return this.iListHandle
		}
	}
	
	AutoSave[] {
		Get {
#Warn UseUnsetLocal, Off
			try {
				if ConfigurationEditor
					return ConfigurationEditor.Instance.AutoSave
				else
					return false
			}
			catch exception {
				return false
			}
		}
	}
	
	ItemList[index := "__Undefined__"] {
		Get {
			if (index != kUndefined)
				return this.iItemList[index]
			else
				return this.iItemList
		}
		
		Set {
			if (index != kUndefined)
				return this.iItemList[index] := value
			else
				return this.iItemList := value
		}
	}
	
	CurrentItem[] {
		Get {
			return this.iCurrentItem
		}
		
		Set {
			return this.iCurrentItem := value
		}
	}
	
	initializeList(listHandle, listVariable, addButton := false, deleteButton := false, updateButton := false, upButton := false, downButton := false) {
		this.iListHandle := listHandle
		this.iAddButton := addButton
		this.iDeleteButton := deleteButton
		this.iUpdateButton := updateButton
		this.iUpButton := upButton
		this.iDownButton := downButton
		
		ConfigurationItemList.associateList(listVariable, this)
		
		if addButton
			ConfigurationItemList.associateList(addButton, this)
		
		if deleteButton
			ConfigurationItemList.associateList(deleteButton, this)
		
		if updateButton
			ConfigurationItemList.associateList(updateButton, this)
		
		if upButton
			ConfigurationItemList.associateList(upButton, this)
		
		if downButton
			ConfigurationItemList.associateList(downButton, this)
		
		this.loadList(this.ItemList)
		this.updateState()
	}
	
	saveToConfiguration(configuration) {
		if this.AutoSave {
			if (this.CurrentItem != 0) {
				this.updateItem()
			}
		}
	}

	associateList(variable, itemList) {
		ConfigurationItemList.sListControls[variable] := itemList
	}
	
	getList(variable) {
		return ConfigurationItemList.sListControls[variable]
	}
	
	clickEvent(line, count) {
		this.openEditor(line)
	}
	
	selectEvent(line) {
		this.openEditor(line)
	}
	
	processListEvent() {
		local event
		
		static lastEvent := false
		static lastEditor := false
		
		event := (A_GuiEvent . A_Space . A_GuiControl . A_Space . A_EventInfo)
		
		if (event = lastEvent)
			return false
		else {
			lastEvent := event
		
			return true
		}
		
		editor := (A_GuiControl . "." . A_EventInfo)
		
		if (editor = lastEditor)
			return false
		else {
			lastEditor := editor
		
			return true
		}
	}
	
	listEvent() {
		info := ErrorLevel
		
		if this.processListEvent() {
			if (A_GuiEvent == "DoubleClick")
				this.clickEvent(A_EventInfo, 2)
			else if (A_GuiEvent == "Normal")
				this.clickEvent(A_EventInfo, 1)
			else if (A_GuiEvent == "I") {
				if InStr(info, "S", true)
					this.selectEvent(A_EventInfo)
			}
		}
	}
	
	loadList(items) {
		Throw "Virtual method ConfigurationItemList.loadList must be implemented in a subclass..."
	}
	
	updateState() {
		if (this.CurrentItem != 0) {
			if (this.iDeleteButton != false)
				GuiControl Enable, % this.iDeleteButton
			if (this.iUpdateButton != false)
				GuiControl Enable, % this.iUpdateButton
			
			if (this.iUpButton != false)
				if (this.CurrentItem > 1)
					GuiControl Enable, % this.iUpButton
				else
					GuiControl Disable, % this.iUpButton
			
			if (this.iDownButton != false)
				if (this.CurrentItem < this.ItemList.Length())
					GuiControl Enable, % this.iDownButton
				else
					GuiControl Disable, % this.iDownButton
		}
		else {
			if (this.iUpButton != false)
				GuiControl Disable, % this.iUpButton
			
			if (this.iDownButton != false)
				GuiControl Disable, % this.iDownButton
			
			if (this.iDeleteButton != false)
				GuiControl Disable, % this.iDeleteButton
			if (this.iUpdateButton != false)
				GuiControl Disable, % this.iUpdateButton
		}
	}
	
	loadEditor(item) {
		Throw "Virtual method ConfigurationItemList.loadEditor must be implemented in a subclass..."
	}
	
	clearEditor() {
		Throw "Virtual method ConfigurationItemList.clearEditor must be implemented in a subclass..."
	}
	
	buildItemFromEditor(isNew := false) {
		Throw "Virtual method ConfigurationItemList.buildItemFromEditor must be implemented in a subclass..."
	}
	
	openEditor(itemNumber) {
		if (itemNumber != this.CurrentItem) {
			if this.AutoSave {
				if (this.CurrentItem != 0)
					this.updateItem()
					
				this.selectItem(itemNumber)
			}
						
			this.CurrentItem := itemNumber
			
			this.loadEditor(this.ItemList[this.CurrentItem])
			
			this.updateState()
		}
	}
	
	selectItem(itemNumber) {
		this.CurrentItem := itemNumber
		
		Gui ListView, % this.ListHandle
			
		if itemNumber
			LV_Modify(itemNumber, "Vis +Select +Focus")
		
		this.updateState()
	}
	
	addItem() {
		item := this.buildItemFromEditor(true)
		
		if item {
			this.ItemList.Push(item)
		
			this.loadList(this.ItemList)
			
			this.selectItem(inList(this.ItemList, item))
		}
	}
	
	deleteItem() {
		this.ItemList.RemoveAt(this.CurrentItem)
		
		this.loadList(this.ItemList)
		
		this.clearEditor()
		
		this.CurrentItem := 0
		
		this.updateState()
	}

	updateItem() {
		static recurse := false
		
		if recurse
			return
		else {
			recurse := true
		
			try {
				item := this.buildItemFromEditor()
				
				if item {
					this.ItemList[this.CurrentItem] := item
					
					this.loadList(this.ItemList)
					
					this.selectItem(this.CurrentItem)
				}
			}
			finally {
				recurse := false
			}
		}
	}

	upItem() {
		item := this.ItemList[this.CurrentItem]
		
		this.ItemList[this.CurrentItem] := this.ItemList[this.CurrentItem - 1]
		this.ItemList[this.CurrentItem - 1] := item
		
		this.loadList(this.ItemList)
			
		this.selectItem(this.CurrentItem - 1)
		
		this.updateState()
	}

	downItem() {
		item := this.ItemList[this.CurrentItem]
		
		this.ItemList[this.CurrentItem] := this.ItemList[this.CurrentItem + 1]
		this.ItemList[this.CurrentItem + 1] := item
		
		this.loadList(this.ItemList)
			
		this.selectItem(this.CurrentItem + 1)
		
		this.updateState()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

listEvent() {
	protectionOn()
	
	try {
		ConfigurationItemList.getList(A_GuiControl).listEvent()
	}
	finally {
		protectionOff()
	}
}

addItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).addItem()
	}
	finally {
		protectionOff()
	}
}

deleteItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).deleteItem()
	}
	finally {
		protectionOff()
	}
}

updateItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).updateItem()
	}
	finally {
		protectionOff()
	}
}

upItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).upItem()
	}
	finally {
		protectionOff()
	}
}

downItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).downItem()
	}
	finally {
		protectionOff()
	}
}