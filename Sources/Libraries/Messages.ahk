;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Inter Process Messages          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLocalMessage := 0
global kWindowMessage := 1
global kPipeMessage := 2
global kFileMessage := 3


;;;-------------------------------------------------------------------------;;;
;;;                         Public Classes Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                        MessageManager                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class MessageManager extends PeriodicTask {
	static sPriority := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Messages", "Schedule", 200)

	static sMessageHandlers := false
	static sOutgoingMessages := []

	iPaused := false

	class MessageHandler {
		iHandler := false

		Handler {
			Get {
				return this.iHandler
			}
		}

		__New(handler := false) {
			this.iHandler := handler
		}

		call(category, data) {
			throw "Virtual method MessageHandler.call must be implemented in a subclass..."
		}
	}

	class FunctionMessageHandler extends MessageManager.MessageHandler {
		call(category, data) {
			local handler := this.Handler

			if handler
				handler.Call(category, data)
			else if InStr(data, ":") {
				data := StrSplit(data, ":", , 2)

				withProtection(%data[1]%, string2Values(";", data[2])*)
			}
			else
				withProtection(%data%)

			return false
		}
	}

	class MethodMessageHandler extends MessageManager.MessageHandler {
		iObject := false

		Object {
			Get {
				return this.iObject
			}
		}

		__New(object, handler := false) {
			this.iObject := object

			super.__New(handler)
		}

		call(category, data) {
			local handler := this.Handler

			if handler
				handler.Call(category, this.Object, data)
			else if InStr(data, ":") {
				data := StrSplit(data, ":", , 2)

				return withProtection(ObjBindMethod(this.Object, data[1], string2Values(";", data[2])*))
			}
			else
				return withProtection(ObjBindMethod(this.Object, data))

			return false
		}
	}

	class MessagesDispatcher extends Task {
		static sWait := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Messages", "Dispatch", 100)

		iMessages := false

		__New(messages) {
			this.iMessages := messages

			super.__New(false, MessageManager.MessagesDispatcher.sWait)
		}

		run() {
			local ignore, message

			for ignore, message in this.iMessages
				try {
					withProtection(ObjBindMethod(message[1], "call", message[2], message[3]))
				}
				catch Any as exception {
					logError(exception, true)
				}

			return false
		}
	}

	Paused {
		Get {
			return this.iPaused
		}
	}

	static MessageHandlers[key?] {
		Get {
			MessageManager.initializeMessageHandlers()

			return (isSet(key) ? MessageManager.sMessageHandlers[key] : MessageManager.sMessageHandlers)
		}

		Set {
			MessageManager.initializeMessageHandlers()

			return (key ? (MessageManager.sMessageHandlers[key] := value) : (MessageManager.sMessageHandlers := value))
		}
	}

	OutgoingMessages[key?] {
		Get {
			return (isSet(key) ? MessageManager.sOutgoingMessages[key] : MessageManager.sOutgoingMessages)
		}

		Set {
			return (isSet(key) ? (MessageManager.sOutgoingMessages[key] := value) : (MessageManager.sOutgoingMessages := value))
		}
	}

	__New() {
		MessageManager.Instance := this

		super.__New(false, 4000, kHighPriority)
	}

	static initializeMessageHandlers() {
		if !MessageManager.sMessageHandlers {
			local cMap := Map()

			cMap.CaseSens := false

			MessageManager.sMessageHandlers := cMap
		}
	}

	static isPaused() {
		return MessageManager.Instance.Paused
	}

	static pause() {
		MessageManager.Instance.iPaused := true
	}

	static resume() {
		MessageManager.Instance.iPaused := false
	}

	receivePipeMessages() {
		local messageHandlers := MessageManager.MessageHandlers
		local result := []
		local messageHandler, category, data, handler, pipeName

		for category, handler in messageHandlers {
			if (category = "*")
				continue

			pipeName := "\\.\pipe\SC." . category

			if DllCall("WaitNamedPipe", "Str", pipeName, "UInt", 0xF)
				loop Read, pipeName {
					data := StrSplit(A_LoopReadLine, ":", , 2)
					category := data[1]

					messageHandler := (messageHandlers.Has(category) ? messageHandlers[category] : messageHandlers["*"])

					logMessage(kLogInfo, translate("Dispatching message `"") . category . translate("`": ") . data[2])

					result.Push(Array(messageHandler, category, decode(data[2])))
				}
		}

		return result
	}

	receiveFileMessages() {
		local result := []
		local messageHandlers, messageHandler, result, pid, fileName, file, line, request, data, category

		pid := ProcessExist()

		fileName := (kTempDirectory . "Messages\" . pid . ".msg")

		if FileExist(fileName) {
			file := false

			try {
				file := FileOpen(fileName, "rw-rwd")

				if !file
					return result
			}
			catch Any as exception {
				logError(exception)

				if isDevelopment()
					logMessage(kLogWarn, "Waiting for file `"" . fileName . "`"...")

				return result
			}

			messageHandlers := MessageManager.MessageHandlers

			while !file.AtEOF {
				line := Trim(file.ReadLine(), " `t`n`r")

				if (StrLen(line) == 0)
					break

				if InStr(line, ":") {
					line := StrSplit(line, ":", , 3)

					request := line[1]
					category := line[2]
					data := line[3]

					messageHandler := (messageHandlers.Has(category) ? messageHandlers[category] : messageHandlers["*"])

					logMessage(kLogInfo, translate("Dispatching message `"") . category . (data ? translate("`": ") . data : translate("`"")))

					if (request = "INTR") {
						try {
							withProtection(ObjBindMethod(messageHandler, "call", category, decode(data)))
						}
						catch Any as exception {
							logError(exception, true)
						}
					}
					else
						result.Push(Array(messageHandler, category, decode(data)))
				}
			}

			file.Length := 0

			file.Close()
		}

		return result
	}

	sendPipeMessage(category, data) {
		local zero := 0
		local pipeName, pipe

		static ERROR_PIPE_CONNECTED := 535
		static ERROR_PIPE_LISTENING := 536

		pipeName := "\\.\pipe\SC." . category

		pipe := DllCall("CreateNamedPipe", "str", pipeName, "uint", 2, "uint", 0, "uint", 255, "uint", 1024, "uint", 1024, "uint", 0, "ptr", 0)

		DllCall("ConnectNamedPipe", "ptr", pipe, "ptr", 0)

		if (true || (A_LastError = ERROR_PIPE_CONNECTED)) {
			category := (chr(0xfeff) . (category . ":" . encode(data)))

			DllCall("WriteFile", "ptr", pipe, "str", category, "uint", (StrLen(category) + 1) * 2, "uint*", &zero, "ptr", 0)

			DllCall("CloseHandle", "ptr", pipe)

			return true
		}
		else
			return false
	}

	sendFileMessage(pid, category, data, request) {
		local text := (request . ":" . category . ":" . encode(data) . "`n")

		try {
			FileAppend(text, kTempDirectory . "Messages\" . pid . ".msg")
		}
		catch Any as exception {
			return false
		}

		return true
	}

	receiveMessages() {
		local fileMessages := this.receiveFileMessages()

		return ((fileMessages.Length > 0) ? fileMessages : this.receivePipeMessages())
	}

	deliverMessages() {
		local outgoingMessages := this.OutgoingMessages
		local failed := []
		local worked := true
		local handler

		while worked {
			worked := false

			if (outgoingMessages.Length > 0) {
				handler := outgoingMessages[1]

				if !inList(failed, handler)
					if handler.Call() {
						outgoingMessages.RemoveAt(1)

						worked := true
					}
					else
						failed.Push(handler)
			}
		}
	}

	run() {
		local messages

		if !this.Paused {
			protectionOn()

			try {
				messages := this.receiveMessages()

				if (messages.Length > 0)
					MessageManager.MessagesDispatcher(messages).start()
				else
					this.deliverMessages()
			}
			finally {
				protectionOff()
			}
		}

		this.Sleep := MessageManager.sPriority
	}

	messageSend(messageType, category, data, target := false, request := "NORM") {
		local messageHandlers, messageHandler

		switch messageType {
			case kLocalMessage:
				logMessage(kLogInfo, translate("Sending message `"") . category . (data ? translate("`": ") . data : translate("`"")) . translate(" in current process"))

				messageHandlers := MessageManager.MessageHandlers

				messageHandler := (messageHandlers.Has(category) ? messageHandlers[category] : messageHandler := messageHandlers["*"])

				logMessage(kLogInfo, translate("Dispatching message `"") . category . (data ? translate("`": ") . data : translate("`"")))

				Task.startTask(ObjBindMethod(messageHandler, "call", category, data))
			case kWindowMessage:
				logMessage(kLogInfo, translate("Sending message `"") . category . (data ? translate("`": ") . data : translate("`"")) . translate(" to target ") . target)

				if (request = "INTR")
					sendWindowMessage(target, category, data, request)
				else
					this.OutgoingMessages.Push(sendWindowMessage.Bind(target, category, data, request))
			case kPipeMessage:
				logMessage(kLogInfo, translate("Sending message `"") . category . (data ? translate("`": ") . data : translate("`"")))

				this.OutgoingMessages.Push(ObjBindMethod(this, "sendPipeMessage", category, data))
			case kFileMessage:
				logMessage(kLogInfo, translate("Sending message `"") . category . (data ? translate("`": ") . data : translate("`"")) . translate(" to target ") . target)

				this.OutgoingMessages.Push(ObjBindMethod(this, "sendFileMessage", target, category, data, request))
			default:
				throw "Unknown message type (" . messageType . ") detected in messageSend..."
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

createMessageReceiver() {
	local messageReceiverGui := Gui("ToolWindow -Caption -SysMenu", A_ScriptName)

	messageReceiverGui.BackColor := "D0D0D0"

	messageReceiverGui.Add("Text", "X10 Y10", "Modular Simulator Controller System")
	messageReceiverGui.Add("Text", , A_ScriptName)

	messageReceiverGui.MarginX := "10"
	messageReceiverGui.MarginY := "10"

	messageReceiverGui.Show("X-100 Y-100 W1 H1 NA")

	WinSetTransparent(0, messageReceiverGui)
}

unknownMessageHandler(category, data) {
	logMessage(kLogCritical, translate("Unhandled message `"") . category . translate("`": ") . data)
}

encodeDWORD(string) {
	local result := 0

	loop StrLen(string) {
        result <<= 8

        result += Ord(SubStr(string, A_Index, 1))
    }

    return result
}

decodeDWORD(data) {
	local result := ""
	local char

    loop 4 {
		result := (Chr(data & 0xFF) . result)

        data >>= 8
    }
	until !data

    return result
}

sendWindowMessage(target, category, data, request) {
	local curDetectHiddenWindows := A_DetectHiddenWindows
	local curTitleMatchMode := A_TitleMatchMode
	local dwData, cbData, lpData, struct, message, wParam, lParam

	category := (category . ":" . data)

	;---------------------------------------------------------------------------
	; construct the message to send
	;---------------------------------------------------------------------------
	dwData := encodeDWORD(request)
	cbData := (StrLen(category) * 2) + 1 			; length of DATA string (incl. ZERO)
	lpData := StrPtr(category)						; pointer to DATA string

	;---------------------------------------------------------------------------
	; put the message in a COPYDATASTRUCT
	;---------------------------------------------------------------------------
	struct := Buffer(A_PtrSize * 3, 0)        		; initialize COPYDATASTRUCT
	NumPut("UPtr", dwData, struct, A_PtrSize * 0)   ; DWORD
	NumPut("UPtr", cbData, struct, A_PtrSize * 1)   ; DWORD
	NumPut("UPtr", lpData, struct, A_PtrSize * 2)   ; 32bit pointer

	;---------------------------------------------------------------------------
	; parameters for PostMessage command
	;---------------------------------------------------------------------------
	message := 0x4a			; WM_COPYDATA
	wParam  := ""			; not used
	lParam  := struct		; COPYDATASTRUCT

	SetTitleMatchMode(2) 		; match part of the title
	DetectHiddenWindows(true)	; needed for sending messages

	try {
		SendMessage(message, wParam, lParam, , target)

		return true
	}
	catch Any as exception {
		logError(exception, true)

		return false
	}
	finally {
		DetectHiddenWindows(curDetectHiddenWindows)

		SetTitleMatchMode(curTitleMatchMode)
	}
}

receiveWindowMessage(wParam, lParam, *) {
	local messageHandlers, messageHandler, dwData, cbData, lpData, request, length, category, data

	;---------------------------------------------------------------------------
    ; retrieve info from COPYDATASTRUCT
    ;---------------------------------------------------------------------------
    dwData := NumGet(lParam + A_PtrSize * 0, "UPtr")    ; DWORD encoded request
    cbData := NumGet(lParam + A_PtrSize * 1, "UPtr")    ; length of DATA string (incl ZERO)
    lpData := NumGet(lParam + A_PtrSize * 2, "UPtr")    ; pointer to DATA string

	;---------------------------------------------------------------------------
    ; interpret available info
    ;---------------------------------------------------------------------------
    request := decodeDWORD(dwData)					; 4-char decoded request

	if ((request = "RS") || (request = "SD")) {
		length  := (cbData - 1)						; length of DATA string (excl ZERO)
		data    := StrGet(lpData, length)       	; DATA string from pointer
	}
	else if ((request = "NORM") || (request = "INTR")) {
		length  := (cbData - 1) / 2					; length of DATA string (excl ZERO)
		data    := StrGet(lpData, length)           ; DATA string from pointer
	}
	else
		throw "Unhandled message received: " . request . " in receiveWindowMessage..."

	data := StrSplit(data, ":", , 2)
	category := data[1]

	messageHandlers := MessageManager.MessageHandlers

	messageHandler := (messageHandlers.Has(category) ? messageHandlers[category] : messageHandlers["*"])

	logMessage(kLogInfo, translate("Dispatching message `"") . request . "/" . category . (data[2] ? translate("`": ") . data[2] : translate("`"")))

	if ((request = "RS") || (request = "INTR")) {
		try {
			withProtection(ObjBindMethod(messageHandler, "call", category, data[2]))
		}
		catch Any as exception {
			logError(exception, true)
		}
	}
	else
		Task.startTask(ObjBindMethod(messageHandler, "call", category, data[2]))
}

stopMessageManager(arguments*) {
	local pid

	if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
		return false

	Task.stopTask(MessageManager.Instance)

	pid := ProcessExist()

	if FileExist(kTempDirectory . "Messages\" . pid . ".msg")
		deleteFile(kTempDirectory . "Messages\" . pid . ".msg")

	return false
}

startMessageManager(*) {
	local pid

	DirCreate(kTempDirectory . "Messages")

	OnMessage(0x4a, receiveWindowMessage)

	registerMessageHandler("*", unknownMessageHandler)

	MessageManager().start()

	pid := ProcessExist()

	if FileExist(kTempDirectory . "Messages\" . pid . ".msg")
		deleteFile(kTempDirectory . "Messages\" . pid . ".msg")

	OnExit(stopMessageManager)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

functionMessageHandler(category, data) {
	local function

	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		return withProtection(%data[1]%, string2Values(";", data[2])*)
	}
	else
		return withProtection(%data%)
}

methodMessageHandler(category, object, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		return withProtection(ObjBindMethod(object, data[1], string2Values(";", data[2])*))
	}
	else
		return withProtection(ObjBindMethod(object, data))
}

registerMessageHandler(category, handler, object := false) {
	if isInstance(handler, MessageManager.MessageHandler)
		MessageManager.MessageHandlers[category] := handler
	else {
		if object
			MessageManager.MessageHandlers[category] := MessageManager.MethodMessageHandler(object, handler)
		else
			MessageManager.MessageHandlers[category] := MessageManager.FunctionMessageHandler(handler)
	}
}

messageSend(messageType, category, data, target := false, request := "NORM") {
	MessageManager.Instance.messageSend(messageType, category, data, target, request)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

createMessageReceiver()
startMessageManager()