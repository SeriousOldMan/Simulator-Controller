;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Production Setup                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Requires AutoHotkey >=v2.0
#SingleInstance Force			; Ony one instance allowed
#Warn All, Off					; Disable warnings in the production code.

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.

ListLines(false)				; Disable execution history

global kBuildConfiguration := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", A_MyDocuments . "\Simulator Controller\Config\"
																	  , normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Config\" : "\..\..\Config\"))))
											 , "Build", "Configuration", "Production")