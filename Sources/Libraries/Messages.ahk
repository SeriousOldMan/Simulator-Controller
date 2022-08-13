;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Inter Process Messages          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk


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
	static sMessageHandlers := {}
	static sOutgoingMessages := []

	class MessageHandler {
		iHandler := false

		Handler[] {
			Get {
				return this.iHandler
			}
		}

		__New(handler := false) {
			this.iHandler := handler
		}

		call(category, data) {
			local handler := this.Handler

			if handler
				%handler%(category, data)
			else if InStr(data, ":") {
				data := StrSplit(data, ":", , 2)

				withProtection(data[1], string2Values(";", data[2])*)
			}
			else
				withProtection(data)

			return false
		}
	}

	class FunctionMessageHandler extends MessageManager.MessageHandler {
	}

	class MethodMessageHandler extends MessageManager.MessageHandler {
		iObject := false

		Object[] {
			Get {
				return this.iObject
			}
		}

		__New(object, handler := false) {
			this.iObject := object

			base.__New(handler)
		}

		call(category, data) {
			local handler := this.Handler

			if handler
				%handler%(category, this.Object, data)
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
		iMessages := false

		__New(messages) {
			this.iMessages := messages

			base.__New()
		}

		run() {
			local ignore, message

			for ignore, message in this.iMessages
				withProtection(ObjBindMethod(message[1], "call", message[2], message[3]))

			return false
		}
	}

	MessageHandlers[key := false] {
		Get {
			return (key ? MessageManager.sMessageHandlers[key] : MessageManager.sMessageHandlers)
		}

		Set {
			return (key ? (MessageManager.sMessageHandlers[key] := value) : (MessageManager.sMessageHandlers := value))
		}
	}

	OutgoingMessages[key := false] {
		Get {
			return (key ? MessageManager.sOutgoingMessages[key] : MessageManager.sOutgoingMessages)
		}
	}

	__New() {
		MessageManager.Instance := this

		base.__New(false, 4000, kHighPriority)
	}

	receivePipeMessages() {
		local messageHandlers := this.MessageHandlers
		local result := []
		local messageHandler, category, data, handler, pipeName

		for category, handler in messageHandlers {
			if (category = "*")
				continue

			pipeName := "\\.\pipe\SC." . category

			if DllCall("WaitNamedPipe", "Str", pipeName, "UInt", 0xF)
				loop Read, %pipeName%
				{
					data := StrSplit(A_LoopReadLine, ":", , 2)
					category := data[1]

					messageHandler := (messageHandlers.HasKey(category) ? messageHandlers[category] : false)

					if (!messageHandler)
						messageHandler := messageHandlers["*"]

					logMessage(kLogInfo, translate("Dispatching message """) . category . (data[2] ? translate(""": ") . data[2] : translate("""")))

					result.Push(Array(messageHandler, category, data[2]))
				}
		}

		return result
	}

	receiveFileMessages() {
		local result := []
		local messageHandlers, messageHandler, result, pid, fileName, file, line, data, category

		Process Exist

		pid := ErrorLevel

		fileName := kTempDirectory . "Messages\" . pid . ".msg"

		if FileExist(fileName) {
			file := false

			try {
				file := FileOpen(fileName, "rw-rwd")
			}
			catch exception {
				return false
			}

			messageHandlers := this.MessageHandlers

			while !file.AtEOF {
				line := Trim(file.ReadLine(), " `t`n`r")

				if (StrLen(line) == 0)
					break

				data := StrSplit(line, ":", , 2)
				category := data[1]

				messageHandler := (messageHandlers.HasKey(category) ? messageHandlers[category] : false)

				if (!messageHandler)
					messageHandler := messageHandlers["*"]

				logMessage(kLogInfo, translate("Dispatching message """) . category . (data[2] ? translate(""": ") . data[2] : translate("""")))

				result.Push(Array(messageHandler, category, data[2]))
			}

			file.Length := 0

			file.Close()
		}

		return result
	}

	sendPipeMessage(category, data) {
		local pipeName, pipe

		static ERROR_PIPE_CONNECTED := 535
		static ERROR_PIPE_LISTENING := 536
		static ptr

		pipeName := "\\.\pipe\SC." . category

		pipe := DllCall("CreateNamedPipe", "str", pipeName, "uint", 2, "uint", 0, "uint", 255, "uint", 1024, "uint", 1024, "uint", 0, ptr, 0)

		DllCall("ConnectNamedPipe", ptr, pipe, ptr, 0)

		if (true || (A_LastError = ERROR_PIPE_CONNECTED)) {
			category := (A_IsUnicode ? chr(0xfeff) : chr(239) chr(187) chr(191)) . (category . ":" . data)

			DllCall("WriteFile", ptr, pipe, "str", category, "uint", (StrLen(category) + 1) * (A_IsUnicode ? 2 : 1), "uint*", 0, ptr, 0)

			DllCall("CloseHandle", ptr, pipe)

			return true
		}
		else
			return false
	}

	sendFileMessage(pid, category, data) {
		local text := category . ":" . data . "`n"

		try {
			FileAppend %text%, % kTempDirectory . "Messages\" . pid . ".msg"
		}
		catch exception {
			return false
		}

		return true
	}

	receiveMessages() {
		local fileMessages := this.receiveFileMessages()

		return ((fileMessages.Length() > 0) ? fileMessages : this.receivePipeMessages())
	}

	deliverMessage() {
		local outgoingMessages := this.OutgoingMessages
		local handler

		if (outgoingMessages.Length() > 0) {
			handler := outgoingMessages[1]

			if %handler%()
				outgoingMessages.RemoveAt(1)
		}
	}

	run() {
		local messages

		protectionOn()

		try {
			messages := this.receiveMessages()

			if (messages.Length() > 0)
				Task.startTask(new this.MessagesDispatcher(messages))
			else
				this.deliverMessage()
		}
		finally {
			protectionOff()
		}

		this.Sleep := 200
	}

	sendMessage(messageType, category, data, target := false) {
		local messageHandlers, messageHandler

		switch messageType {
			case kLocalMessage:
				logMessage(kLogInfo, translate("Sending message """) . category . (data ? translate(""": ") . data : translate("""")) . translate(" in current process"))

				messageHandlers := this.MessageHandlers

				messageHandler := (messageHandlers.HasKey(category) ? messageHandlers[category] : false)

				if (!messageHandler)
					messageHandler := messageHandlers["*"]

				logMessage(kLogInfo, translate("Dispatching message """) . category . (data ? translate(""": ") . data : translate("""")))

				Task.startTask(ObjBindMethod(messageHandler, "call", category, data))
			case kWindowMessage:
				logMessage(kLogInfo, translate("Sending message """) . category . (data ? translate(""": ") . data : translate("""")) . translate(" to target ") . target)

				this.OutgoingMessages.Push(ObjBindMethod(this, "sendWindowMessage", target, category, data))
			case kPipeMessage:
				logMessage(kLogInfo, translate("Sending message """) . category . (data ? translate(""": ") . data : translate("""")))

				this.OutgoingMessages.Push(ObjBindMethod(this, "sendPipeMessage", category, data))
			case kFileMessage:
				logMessage(kLogInfo, translate("Sending message """) . category . (data ? translate(""": ") . data : translate("""")) . translate(" to target ") . target)

				this.OutgoingMessages.Push(ObjBindMethod(this, "sendFileMessage", target, category, data))
			default:
				throw "Unknown message type (" . messageType . ") detected in sendMessage..."
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

createMessageReceiver() {
	Gui MR:New, , % A_ScriptName
	Gui MR:Color, D0D0D0, D8D8D8
	Gui MR:Add, Text, X10 Y10, Modular Simulator Controller System
	Gui MR:Add, Text, , % A_ScriptName

	Gui MR:Margin, 10, 10
	Gui MR:Show, X0 Y0 Hide AutoSize
}

unknownMessageHandler(category, data) {
	logMessage(kLogCritical, translate("Unhandled message """) . category . translate(""": ") . data)

	sendMessage(kLocalMessage, category, data)
}

encodeDWORD(string) {
	local result := 0

	loop % StrLen(string) {
        result <<= 8
        result += Asc(SubStr(string, A_Index, 1))
    }

    return result
}

decodeDWORD(data) {
	local result := ""

    loop 4 {
        result := Chr(data & 0xFF) . result
        data >>= 8
    }

    return result
}

sendWindowMessage(target, category, data) {
	local curDetectHiddenWindows := A_DetectHiddenWindows
	local curTitleMatchMode := A_TitleMatchMode
	local dwData, cbData, lpData, struct, message, wParam, lParam, control

	category := (category . ":" . data)

	;---------------------------------------------------------------------------
	; construct the message to send
	;---------------------------------------------------------------------------
	dwData := encodeDWORD("EVNT")
	cbData := StrLen(category) * (A_IsUnicode + 1) + 1 ; length of DATA string (incl. ZERO)
	lpData := &category                                ; pointer to DATA string

	;---------------------------------------------------------------------------
	; put the message in a COPYDATASTRUCT
	;---------------------------------------------------------------------------
	VarSetCapacity(struct, A_PtrSize * 3, 0)        ; initialize COPYDATASTRUCT
	NumPut(dwData, struct, A_PtrSize * 0, "UInt")   ; DWORD
	NumPut(cbData, struct, A_PtrSize * 1, "UInt")   ; DWORD
	NumPut(lpData, struct, A_PtrSize * 2, "UInt")   ; 32bit pointer

	;---------------------------------------------------------------------------
	; parameters for SendMessage command
	;---------------------------------------------------------------------------
	message := 0x4a     ; WM_COPYDATA
	wParam  := ""       ; not used
	lParam  := &struct  ; COPYDATASTRUCT
	control := ""       ; not needed

	SetTitleMatchMode 2 ; match part of the title
	DetectHiddenWindows On ; needed for sending messages

	try {
		SendMessage %message%, %wParam%, %lParam%, %control%, %target%

		return (ErrorLevel != "FAIL")
	}
	catch exception {
		return false
	}
	finally {
		DetectHiddenWindows %curDetectHiddenWindows%
		SetTitleMatchMode %curTitleMatchMode%
	}
}

receiveWindowMessage(wParam, lParam) {
	local messageHandlers, messageHandler, dwData, cbData, lpData, request, length, category, data, callable

	;---------------------------------------------------------------------------
    ; retrieve info from COPYDATASTRUCT
    ;---------------------------------------------------------------------------
    dwData := NumGet(lParam + A_PtrSize * 0)    ; DWORD encoded request
    cbData := NumGet(lParam + A_PtrSize * 1)    ; length of DATA string (incl ZERO)
    lpData := NumGet(lParam + A_PtrSize * 2)    ; pointer to DATA string

	;---------------------------------------------------------------------------
    ; interpret available info
    ;---------------------------------------------------------------------------
    request := decodeDWORD(dwData)              ; 4-char decoded request

	if (request = "EVNT") {
		length  := (cbData - 1) / (A_IsUnicode + 1) ; length of DATA string (excl ZERO)
		data    := StrGet(lpData, length)           ; DATA string from pointer
	}
	else if ((request = "RS") || (request = "SD")) {
		length  := (cbData - 1)						; length of DATA string (excl ZERO)
		data    := StrGet(lpData, length, "")       ; DATA string from pointer
	}
	else
		throw % "Unhandled message received: " . request . " in receiveWindowMessage..."

	data := StrSplit(data, ":", , 2)
	category := data[1]

	messageHandlers := MessageManager.Instance.MessageHandlers

	messageHandler := (messageHandlers.HasKey(category) ? messageHandlers[category] : false)

	if (!messageHandler)
		messageHandler := messageHandlers["*"]

	logMessage(kLogInfo, translate("Dispatching message """) . category . (data[2] ? translate(""": ") . data[2] : translate("""")))

	callable := ObjBindMethod(messageHandler, "call", category, data[2])

	if (request = "RS")
		withProtection(callable)
	else
		Task.startTask(callable)
}

stopMessageManager() {
	local pid

	Task.removeTask(MessageManager.Instance)

	Process Exist

	pid := ErrorLevel

	if FileExist(kTempDirectory . "Messages\" . pid . ".msg")
		FileDelete %kTempDirectory%Messages\%pid%.msg

	return false
}

startMessageManager() {
	local pid

	FileCreateDir %kTempDirectory%Messages

	OnMessage(0x4a, "receiveWindowMessage")

	registerMessageHandler("*", "unknownMessageHandler")

	Task.startTask(new MessageManager())

	Process Exist

	pid := ErrorLevel

	if FileExist(kTempDirectory . "Messages\" . pid . ".msg")
		FileDelete %kTempDirectory%Messages\%pid%.msg

	OnExit("stopMessageManager")
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

functionMessageHandler(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		return withProtection(data[1], string2Values(";", data[2])*)
	}
	else
		return withProtection(data)
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
			MessageManager.MessageHandlers[category] := new MessageManager.MethodMessageHandler(object, handler)
		else
			MessageManager.MessageHandlers[category] := new MessageManager.FunctionMessageHandler(handler)
	}
}

sendMessage(messageType, category, data, target := false) {
	MessageManager.Instance.sendMessage(messageType, category, data, target)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

createMessageReceiver()
startMessageManager()
