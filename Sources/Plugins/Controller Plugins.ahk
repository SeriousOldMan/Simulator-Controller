;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Plugins              ;;;
;;;                                         Include Sequence                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include "Button Box Plugin.ahk"				; Optional, but should be always first, so that Plugins can adopt to the controller layout
#Include "Stream Deck Plugin.ahk"				; Optional, but should be always first, so that Plugins can adopt to the controller layout

#Include "System Plugin.ahk"					; Required, must be loaded before all other ..\Plugins, but after controller plugins
#Include "Core Plugin.ahk"						; Optional, but must be loaded directly after System Plugin

#Include "Motion Feedback Plugin.ahk"
#Include "Tactile Feedback Plugin.ahk"
#Include "Pedal Calibration Plugin.ahk"
#Include "Team Server Plugin.ahk"				; Must be loaded before the Race Assistant Plugins
#Include "Race Engineer Plugin.ahk"				; Must be loaded before any other Simulator Plugins
#Include "Race Strategist Plugin.ahk"			; Must be loaded before any other Simulator Plugins
#Include "Race Spotter Plugin.ahk"				; Must be loaded before any other Simulator Plugins
#Include "AC Plugin.ahk"
#Include "AMS2 Plugin.ahk"
#Include "ACC Plugin.ahk"
#Include "IRC Plugin.ahk"
#Include "R3E Plugin.ahk"
#Include "RF2 Plugin.ahk"
#Include "PCARS2 Plugin.ahk"
#Include "RSP Plugin.ahk"
#Include "RST Plugin.ahk"

#include "Integration Plugin.ahk"				; Must be loaded last, if at all
