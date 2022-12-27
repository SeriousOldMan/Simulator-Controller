;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Messages Test                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

; SetBatchLines -1				; Maximize CPU utilization
; ListLines Off					; Disable execution history


global vBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Messages.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vIncomingValues := []


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

exit() {
	ExitApp 0
}

class MessagesTest extends Assert {
	listEqual(list1, list2) {
		if (list1.Length() == list2.Length()) {
			for index, value in list1
				if (list2[index] != value)
					return false

			return true
		}
		else
			return false
	}

	Messages_Order_Test() {
		Sleep 5000

		Process Exist

		pid := ErrorLevel

		loop 5
			sendMessage(kFileMessage, "Test", "registerValue:" . A_Index, pid)

		while (vIncomingValues.Length() < 5) {
			Random priority, 1, 4

			Task.startTask("disturb", 50, Round(priority))

			Sleep 1
		}

		this.AssertEqual(true, this.listEqual(vIncomingValues, [1,2,3,4,5]), "Message order is not retained...")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Private Function Section                        ;;;
;;;-------------------------------------------------------------------------;;;

registerValue(value) {
	vIncomingValues.Push(value)
}

ignore(arguments*) {
}

disturb() {
	Process Exist

	pid := ErrorLevel

	loop 2
		sendMessage(kFileMessage, "Test", "ignore:" . A_Index, pid)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

registerMessageHandler("Test", "functionMessageHandler")

AHKUnit.AddTestClass(MessagesTest)

AHKUnit.Run()