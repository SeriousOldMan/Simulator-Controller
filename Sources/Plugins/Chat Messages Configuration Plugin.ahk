﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Chat Messages                   ;;;
;;;                                         Configuration Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ChatMessagesConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ChatMessagesConfigurator extends ConfigurationItemList {
	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		ChatMessagesConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		window.Add("ListView", "x16 y80 w457 h245 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VchatMessagesListView", collect(["#", "Label", "Message"], translate))

		window.Add("Text", "x16 y335 w81 h23 Y:Move +0x200", translate("Button"))
		window.Add("Text", "x98 y335 w12 h23 Y:Move +0x200", translate("#"))
		window.Add("Edit", "x110 y335 w40 h21 Y:Move Number Limit3 VchatMessageNumberEdit")
		window.Add("UpDown", "x150 y335 w17 h21 Y:Move Range1-999")

		window.Add("Text", "x16 y359 w90 h23 Y:Move +0x200", translate("Label"))
		window.Add("Edit", "x110 y359 w80 h21 Y:Move W:Grow(0.2) VchatMessageLabelEdit")

		window.Add("Text", "x16 y383 w90 h23 Y:Move +0x200", translate("Message"))
		window.Add("Edit", "x110 y383 w363 h21 Y:Move W:Grow VchatMessageMessageEdit")

		/*
		window.Add("Button", "x264 y530 w46 h23 Y:Move X:Move VchatMessageAddButton", translate("Add"))
		window.Add("Button", "x312 y530 w50 h23 Y:Move X:Move Disabled VchatMessageDeleteButton", translate("Delete"))
		window.Add("Button", "x418 y530 w55 h23 Y:Move X:Move Disabled VchatMessageUpdateButton", translate("&Save"))
		*/

		window.Add("Button", "x396 y530 w23 h23 X:Move Y:Move VchatMessageAddButton")
		setButtonIcon(window["chatMessageAddButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		window.Add("Button", "x420 y530 w23 h23 X:Move Y:Move Disabled VchatMessageDeleteButton")
		setButtonIcon(window["chatMessageDeleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		window.Add("Button", "x450 y530 w23 h23 X:Move Y:Move Disabled VchatMessageUpdateButton")
		setButtonIcon(window["chatMessageUpdateButton"], kIconsDirectory . "Save.ico", 1, "L4 T4 R4 B4")

		this.initializeList(editor, window["chatMessagesListView"], window["chatMessageAddButton"], window["chatMessageDeleteButton"], window["chatMessageUpdateButton"])
	}

	loadFromConfiguration(configuration) {
		local descriptor, chatMessage

		super.loadFromConfiguration(configuration)

		for descriptor, chatMessage in getMultiMapValues(configuration, "Chat Messages") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			chatMessage := string2Values("|", chatMessage)

			this.ItemList.Push(Array(descriptor[2], chatMessage[1], chatMessage[2]))
		}
	}

	saveToConfiguration(configuration) {
		local ignore, chatMessage

		super.saveToConfiguration(configuration)

		for ignore, chatMessage in this.ItemList
			setMultiMapValue(configuration, "Chat Messages", ConfigurationItem.descriptor("Button", chatMessage[1]), values2String("|", chatMessage[2], chatMessage[3]))
	}

	loadList(items) {
		local ignore, chatMessage

		static first := true

		this.Control["chatMessagesListView"].Delete()

		bubbleSort(&items, (c1, c2) => (c1[1] >= c2[1]))

		this.ItemList := items

		for ignore, chatMessage in items
			this.Control["chatMessagesListView"].Add("", chatMessage[1], chatMessage[2], chatMessage[3])

		if first {
			this.Control["chatMessagesListView"].ModifyCol()
			this.Control["chatMessagesListView"].ModifyCol(2, "AutoHdr")

			first := false
		}
	}

	loadEditor(item) {
		this.Control["chatMessageNumberEdit"].Text := item[1]
		this.Control["chatMessageLabelEdit"].Text := item[2]
		this.Control["chatMessageMessageEdit"].Text := item[3]
	}

	clearEditor() {
		this.Control["chatMessageNumberEdit"].Text := 1
		this.Control["chatMessageLabelEdit"].Text := ""
		this.Control["chatMessageMessageEdit"].Text := ""
	}

	buildItemFromEditor(isNew := false) {
		local ignore, item

		if ((Trim(this.Control["chatMessageLabelEdit"].Text) = "") || (Trim(this.Control["chatMessageMessageEdit"].Text) = "")) {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else if isNew
			for ignore, item in this.ItemList
				if (item[1] = this.Control["chatMessageNumberEdit"].Text) {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("A chat message for this button already exists - please use different values..."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					return false
				}

		return Array(this.Control["chatMessageNumberEdit"].Text, this.Control["chatMessageLabelEdit"].Text, this.Control["chatMessageMessageEdit"].Text)
	}

	updateItem() {
		local chatMessage := this.buildItemFromEditor()

		if (chatMessage && (chatMessage[1] != this.ItemList[this.CurrentItem][1])) {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("The button number of an existing chat message may not be changed..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else
			return super.updateItem()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeChatMessagesConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Chat"), ChatMessagesConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-chat")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeChatMessagesConfigurator()