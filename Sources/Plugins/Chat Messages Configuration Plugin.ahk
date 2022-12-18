;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Chat Messages                   ;;;
;;;                                         Configuration Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ChatMessagesConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global chatMessagesListView := false
global chatMessageNumberEdit := 1
global chatMessageLabelEdit := ""
global chatMessageMessageEdit := ""
global chatMessageAddButton
global chatMessageDeleteButton
global chatMessageUpdateButton

class ChatMessagesConfigurator extends ConfigurationItemList {
	iEditor := false

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	__New(editor, configuration) {
		this.iEditor := editor

		base.__New(configuration)

		ChatMessagesConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local configuration := editor.Configuration

		Gui %window%:Add, ListView, x16 y80 w457 h205 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndchatMessagesListViewHandle VchatMessagesListView glistEvent
						, % values2String("|", map(["#", "Label", "Text"], "translate")*)

		Gui %window%:Add, Text, x16 y295 w86 h23 +0x200, % translate("Button")
		Gui %window%:Add, Text, x95 y295 w23 h23 +0x200, % translate("#")
		Gui %window%:Add, Edit, x110 y295 w40 h21 Number Limit3 VchatMessageNumberEdit, %chatMessageNumberEdit%
		Gui %window%:Add, UpDown, x150 y295 w17 h21 Range1-999, 1

		Gui %window%:Add, Text, x16 y319 w86 h23 +0x200, % translate("Label")
		Gui %window%:Add, Edit, x110 y319 w80 h21 VchatMessageLabelEdit, %chatMessageLabelEdit%

		Gui %window%:Add, Text, x16 y343 w86 h23 +0x200, % translate("Message")
		Gui %window%:Add, Edit, x110 y343 w363 h21 VchatMessageMessageEdit, %chatMessageMessageEdit%

		Gui %window%:Add, Button, x264 y490 w46 h23 VchatMessageAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y490 w50 h23 Disabled VchatMessageDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x418 y490 w55 h23 Disabled VchatMessageUpdateButton gupdateItem, % translate("&Save")

		this.initializeList(configuration, chatMessagesListViewHandle, "chatMessagesListView"
						  , "chatMessageAddButton", "chatMessageDeleteButton", "chatMessageUpdateButton")
	}

	loadFromConfiguration(configuration) {
		local descriptor, chatMessage

		base.loadFromConfiguration(configuration)

		for descriptor, chatMessage in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			chatMessage := string2Values("|", chatMessage)

			this.ItemList.Push(Array(descriptor[2], chatMessage[1], chatMessage[2]))
		}
	}

	saveToConfiguration(configuration) {
		local ignore, chatMessage

		base.saveToConfiguration(configuration)

		for ignore, chatMessage in this.ItemList
			setConfigurationValue(configuration, "Chat Messages", ConfigurationItem.descriptor("Button", chatMessage[1]), values2String("|", chatMessage[2], chatMessage[3]))
	}

	loadList(items) {
		local ignore, chatMessage

		static first := true

		Gui ListView, % this.ListHandle

		LV_Delete()

		bubbleSort(items, "compareChatMessages")

		this.ItemList := items

		for ignore, chatMessage in items
			LV_Add("", chatMessage[1], chatMessage[2], chatMessage[3])

		if first {
			LV_ModifyCol()
			LV_ModifyCol(2, "AutoHdr")

			first := false
		}
	}

	loadEditor(item) {
		GuiControl Text, chatMessageNumberEdit, % item[1]
		GuiControl Text, chatMessageLabelEdit, % item[2]
		GuiControl Text, chatMessageMessageEdit, % item[3]
	}

	clearEditor() {
		GuiControl Text, chatMessageNumberEdit, 1
		GuiControl Text, chatMessageLabelEdit, % ""
		GuiControl Text, chatMessageMessageEdit, % ""
	}

	buildItemFromEditor(isNew := false) {
		local title, ignore, item

		GuiControlGet chatMessageNumberEdit
		GuiControlGet chatMessageLabelEdit
		GuiControlGet chatMessageMessageEdit

		if ((chatMessageLabelEdit = "") || (chatMessageMessageEdit = "")) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
		else if isNew
			for ignore, item in this.ItemList
				if (item[1] = chatMessageNumberEdit) {
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					title := translate("Error")
					MsgBox 262160, %title%, % translate("A chat message for this button already exists - please use different values...")
					OnMessage(0x44, "")

					return false
				}

		return Array(chatMessageNumberEdit, chatMessageLabelEdit, chatMessageMessageEdit)
	}

	updateItem() {
		local chatMessage := this.buildItemFromEditor()
		local title

		if (chatMessage && (chatMessage[1] != this.ItemList[this.CurrentItem][1])) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("The button number of an existing chat message may not be changed...")
			OnMessage(0x44, "")
		}
		else
			base.updateItem()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compareChatMessages(c1, c2) {
	return (c1[1] >= c2[1])
}

initializeChatMessagesConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Chat"), new ChatMessagesConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeChatMessagesConfigurator()