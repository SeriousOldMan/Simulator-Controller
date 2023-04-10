;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Item List         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ConfigurationEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationItemList                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfigurationItemList extends ConfiguratorPanel {
	static sListControls := Map()

	iListView := false
	iAddButton := false
	iDeleteButton := false
	iUpdateButton := false
	iUpButton := false
	iDownButton := false

	iItemList := []
	iCurrentItem := 0

	ListView {
		Get {
			return this.iListView
		}
	}

	AutoSave {
		Get {
			try {
				if (isSet(ConfigurationEditor) && ConfigurationEditor.Instance)
					return ConfigurationEditor.Instance.AutoSave
				else
					return false
			}
			catch Any as exception {
				return false
			}
		}
	}

	ItemList[index := "__Undefined__"] {
		Get {
			if (index != kUndefined) {
				if !this.iItemList.Has(index)
					MsgBox 1

				return this.iItemList[index]
			}
			else
				return this.iItemList
		}

		Set {
			if (index != kUndefined)
				return (this.iItemList[index] := value)
			else
				return (this.iItemList := value)
		}
	}

	CurrentItem {
		Get {
			return this.iCurrentItem
		}

		Set {
			return (this.iCurrentItem := value)
		}
	}

	initializeList(editor, listView, addButton := false, deleteButton := false, updateButton := false, upButton := false, downButton := false) {
		this.Editor := editor

		this.iListView := listView
		this.iAddButton := addButton
		this.iDeleteButton := deleteButton
		this.iUpdateButton := updateButton
		this.iUpButton := upButton
		this.iDownButton := downButton

		associateControl(control) {
			ConfigurationItemList.sListControls[control] := this
		}

		associateControl(listView)

		if addButton
			associateControl(addButton)

		if deleteButton
			associateControl(deleteButton)

		if updateButton
			associateControl(updateButton)

		if upButton
			associateControl(upButton)

		if downButton
			associateControl(downButton)

		this.loadList(this.ItemList)

		this.updateState()
	}

	saveToConfiguration(configuration) {
		if this.AutoSave
			if (this.CurrentItem != 0)
				this.updateItem()
	}

	static getList(control) {
		return ConfigurationItemList.sListControls[control]
	}

	clickEvent(line, count) {
		if (line != 0)
			this.openEditor(line)
	}

	selectEvent(line) {
		if (line != 0)
			this.openEditor(line)
	}

	processListEvent() {
		return true
	}

	listEvent(type, line) {
		protectionOn(true, true)

		try {
			if this.processListEvent() {
				if (type == "DoubleClick")
					this.clickEvent(line, 2)
				else if (type == "Click")
					this.clickEvent(line, 1)
				else if (type == "Select")
					this.selectEvent(line)
			}
		}
		finally {
			protectionOff(true, true)
		}
	}

	loadList(items) {
		throw "Virtual method ConfigurationItemList.loadList must be implemented in a subclass..."
	}

	updateState() {
		local window := this.Window

		if (this.CurrentItem != 0) {
			if (this.iDeleteButton != false)
				this.iDeleteButton.Enabled := true

			if (this.iUpdateButton != false)
				this.iUpdateButton.Enabled := true

			if (this.iUpButton != false)
				if (this.CurrentItem > 1)
					this.iUpButton.Enabled := true
				else
					this.iUpButton.Enabled := false

			if (this.iDownButton != false)
				if (this.CurrentItem < this.ItemList.Length)
					this.iDownButton.Enabled := true
				else
					this.iDownButton.Enabled := false
		}
		else {
			if (this.iUpButton != false)
				this.iUpButton.Enabled := false

			if (this.iDownButton != false)
				this.iDownButton.Enabled := false

			if (this.iDeleteButton != false)
				this.iDeleteButton.Enabled := false

			if (this.iUpdateButton != false)
				this.iUpdateButton.Enabled := false
		}
	}

	loadEditor(item) {
		throw "Virtual method ConfigurationItemList.loadEditor must be implemented in a subclass..."
	}

	clearEditor() {
		throw "Virtual method ConfigurationItemList.clearEditor must be implemented in a subclass..."
	}

	buildItemFromEditor(isNew := false) {
		throw "Virtual method ConfigurationItemList.buildItemFromEditor must be implemented in a subclass..."
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

		if itemNumber
			this.ListView.Modify(itemNumber, "Vis +Select +Focus")

		this.updateState()
	}

	addItem() {
		local item := this.buildItemFromEditor(true)

		if item {
			this.ItemList.Push(item)

			this.loadList(this.ItemList)

			this.selectItem(inList(this.ItemList, item))
		}
	}

	deleteItem() {
		this.ItemList.RemoveAt(this.CurrentItem)

		this.CurrentItem := 0

		this.loadList(this.ItemList)

		this.clearEditor()

		this.CurrentItem := 0

		this.updateState()
	}

	updateItem() {
		local item

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
		local item := this.ItemList[this.CurrentItem]

		this.ItemList[this.CurrentItem] := this.ItemList[this.CurrentItem - 1]
		this.ItemList[this.CurrentItem - 1] := item

		this.loadList(this.ItemList)

		this.selectItem(this.CurrentItem - 1)

		this.updateState()
	}

	downItem() {
		local item := this.ItemList[this.CurrentItem]

		this.ItemList[this.CurrentItem] := this.ItemList[this.CurrentItem + 1]
		this.ItemList[this.CurrentItem + 1] := item

		this.loadList(this.ItemList)

		this.selectItem(this.CurrentItem + 1)

		this.updateState()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

listEvent(type, control, line, *) {
	protectionOn()

	try {
		ConfigurationItemList.getList(control).listEvent(type, line)
	}
	finally {
		protectionOff()
	}
}

addItem(control, *) {
	protectionOn()

	try{
		ConfigurationItemList.getList(control).addItem()
	}
	finally {
		protectionOff()
	}
}

deleteItem(control, *) {
	protectionOn()

	try{
		ConfigurationItemList.getList(control).deleteItem()
	}
	finally {
		protectionOff()
	}
}

updateItem(control, *) {
	protectionOn()

	try{
		ConfigurationItemList.getList(control).updateItem()
	}
	finally {
		protectionOff()
	}
}

upItem(control, *) {
	protectionOn()

	try{
		ConfigurationItemList.getList(control).upItem()
	}
	finally {
		protectionOff()
	}
}

downItem(control, *) {
	protectionOn()

	try{
		ConfigurationItemList.getList(control).downItem()
	}
	finally {
		protectionOff()
	}
}