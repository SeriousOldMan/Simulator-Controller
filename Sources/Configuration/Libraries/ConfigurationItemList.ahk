;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Item List         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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
				if (isSet(ConfigurationEditor) && ConfigurationEditor.hasOwnProp("Instance"))
					return ConfigurationEditor.Instance.AutoSave
				else
					return true
			}
			catch Any as exception {
				return true
			}
		}
	}

	ItemList[index?] {
		Get {
			return (isSet(index) ? (this.iItemList.Has(index) ? this.iItemList[index] : false) : this.iItemList)
		}

		Set {
			return (isSet(index) ? (this.iItemList.Has(index) ? (this.iItemList[index] := value) : value) : (this.iItemList := value))
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
		listEvent(type, control, line, arguments*) {
			if (isInstance(listView, Gui.ListView) && (type = "Select") && !arguments[1])
				return

			protectionOn()

			try {
				if isInstance(listView, Gui.ListBox)
					line := listView.Value

				this.listEvent(type, line)
			}
			finally {
				protectionOff()
			}
		}

		addItem(control, *) {
			protectionOn()

			try{
				this.addItem()
			}
			finally {
				protectionOff()
			}
		}

		deleteItem(control, *) {
			protectionOn()

			try{
				this.deleteItem()
			}
			finally {
				protectionOff()
			}
		}

		updateItem(control, *) {
			protectionOn()

			try{
				this.updateItem()
			}
			finally {
				protectionOff()
			}
		}

		upItem(control, *) {
			protectionOn()

			try{
				this.upItem()
			}
			finally {
				protectionOff()
			}
		}

		downItem(control, *) {
			protectionOn()

			try{
				this.downItem()
			}
			finally {
				protectionOff()
			}
		}

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

		if isInstance(listView, Gui.ListView) {
			listView.OnEvent("Click", listEvent.Bind("Click"))
			listView.OnEvent("DoubleClick", listEvent.Bind("DoubleClick"))
			listView.OnEvent("ItemSelect", listEvent.Bind("Select"))
		}
		else if isInstance(listView, Gui.ListBox) {
			listView.OnEvent("DoubleClick", listEvent.Bind("DoubleClick"))
			listView.OnEvent("Change", listEvent.Bind("Select"))
		}

		if addButton {
			associateControl(addButton)

			addButton.OnEvent("Click", addItem)
		}

		if deleteButton {
			associateControl(deleteButton)

			deleteButton.OnEvent("Click", deleteItem)
		}

		if updateButton {
			associateControl(updateButton)

			updateButton.OnEvent("Click", updateItem)
		}

		if upButton {
			associateControl(upButton)

			upButton.OnEvent("Click", upItem)
		}

		if downButton {
			associateControl(downButton)

			downButton.OnEvent("Click", downItem)
		}

		this.loadList(this.ItemList)

		this.updateState()
	}

	saveToConfiguration(configuration, save := false) {
		if (save || this.AutoSave)
			if (this.CurrentItem != 0)
				return this.updateItem()

		return true
	}

	static getList(control) {
		return ConfigurationItemList.sListControls[control]
	}

	clickEvent(line, count) {
		if (line != 0)
			this.openEditor(line)
	}

	selectEvent(line) {
		if this.AutoSave {
			if ((this.CurrentItem != 0) && (line != this.CurrentItem))
				if !this.updateItem() {
					this.selectItem(this.CurrentItem)

					return
				}
		}

		if (line != this.CurrentItem) {
			if (line != 0) {
				this.openEditor(line)

				this.selectItem(line)
			}
			else {
				if isInstance(this.ListView, Gui.ListView) {
					loop this.ListView.GetCount()
						this.ListView.Modify(A_Index, "-Select")
				}
				else
					this.ListView.Choose(0)

				this.clearEditor()
			}

			this.selectItem(line)
		}
		else
			this.updateState()
	}

	processListEvent() {
		return true
	}

	listEvent(type, line) {
		protectionOn(true, true)

		try {
			if this.processListEvent() {
				if (type == "DoubleClick") {
					if line
						this.clickEvent(line, 2)
					else if this.CurrentItem
						this.selectEvent(false)
				}
				else if (type == "Click") {
					if line
						this.clickEvent(line, 1)
					else if this.CurrentItem
						this.selectEvent(false)
				}
				else if ((type == "Select") && line && (line = (isInstance(this.ListView, Gui.ListView) ? this.ListView.GetNext(0) : this.ListView.Value)))
					this.selectEvent(line)
			}
		}
		catch Any as exception {
			logError(exception, true)
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
			this.CurrentItem := itemNumber

			this.loadEditor(this.ItemList[this.CurrentItem])

			this.updateState()
		}
	}

	selectItem(itemNumber) {
		this.CurrentItem := itemNumber

		if itemNumber
			if isInstance(this.ListView, Gui.ListView)
				this.ListView.Modify(itemNumber, "Vis +Select +Focus")
			else
				this.ListView.Choose(itemNumber)

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

		this.selectItem(false)

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

					return true
				}
				else
					return false
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