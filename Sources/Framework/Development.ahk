;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Development Setup               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Requires AutoHotkey >=v2.0
#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.

global kBuildConfiguration := "Development"