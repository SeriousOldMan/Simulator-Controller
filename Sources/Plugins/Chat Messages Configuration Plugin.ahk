;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Chat Messages                   ;;;
;;;                                         Configuration Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\SpeechGenerator.ahk
#Include ..\Libraries\SpeechRecognizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ChatMessagesConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global chatMessagesListView = false
global chatMessageNumberEdit = 1
global chatMessageLabelEdit = ""
global chatMessageMessageEdit = ""
global chatMessageAddButton
global chatMessageDeleteButton
global chatMessageUpdateButton
		
class ChatMessagesConfigurator extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		ChatMessagesConfigurator.Instance := this
	}
					
	createGui(editor, x, y, width, height) {
		window := editor.Window
		configuration := editor.Configuration
		
		Gui %window%:Add, ListView, x16 y80 w457 h205 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndchatMessagesListViewHandle VchatMessagesListView glistEvent
						, % values2String("|", map(["#", "Label", "Text"], "translate")*)
		
		Gui %window%:Add, Text, x16 y295 w86 h23 +0x200, % translate("Button")
		Gui %window%:Add, Text, x95 y295 w23 h23 +0x200, % translate("#")
		Gui %window%:Add, Edit, x110 y295 w40 h21 Number VchatMessageNumberEdit, %chatMessageNumberEdit%
		Gui %window%:Add, UpDown, x150 y295 w17 h21, 1
		
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
		base.loadFromConfiguration(configuration)
		
		for descriptor, chatMessage in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			chatMessage := string2Values("|", chatMessage)

			this.iItemsList.Push(Array(descriptor[2], chatMessage[1], chatMessage[2]))
		}
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		for ignore, chatMessage in this.iItemsList
			setConfigurationValue(configuration, "Chat Messages", ConfigurationItem.descriptor("Button", chatMessage[1]), values2String("|", chatMessage[2], chatMessage[3]))	
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		bubbleSort(items, "compareChatMessages")
		
		this.iItemsList := items
		
		for ignore, chatMessage in items
			LV_Add("", chatMessage[1], chatMessage[2], chatMessage[3])
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(2, "AutoHdr")
			
			first := false
		}
	}
	
	loadEditor(item) {
		chatMessageNumberEdit := item[1]
		chatMessageLabelEdit := item[2]
		chatMessageMessageEdit := item[3]
			
		GuiControl Text, chatMessageNumberEdit, %chatMessageNumberEdit%
		GuiControl Text, chatMessageLabelEdit, %chatMessageLabelEdit%
		GuiControl Text, chatMessageMessageEdit, %chatMessageMessageEdit%
	}
	
	clearEditor() {
		chatMessageNumberEdit := 1
		chatMessageLabelEdit := ""
		chatMessageMessageEdit := ""
		
		GuiControl Text, chatMessageNumberEdit, %chatMessageNumberEdit%
		GuiControl Text, chatMessageLabelEdit, %chatMessageLabelEdit%
		GuiControl Text, chatMessageMessageEdit, %chatMessageMessageEdit%
	}
	
	buildItemFromEditor(isNew := false) {
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
			for ignore, item in this.iItemsList
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
		chatMessage := this.buildItemFromEditor()
	
		if (chatMessage && (chatMessage[1] != this.iItemsList[this.iCurrentItemIndex][1])) {
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
	editor := ConfigurationEditor.Instance
	
	editor.registerConfigurator(translate("Chat"), new ChatMessagesConfigurator(editor.Configuration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeChatMessagesConfigurator()