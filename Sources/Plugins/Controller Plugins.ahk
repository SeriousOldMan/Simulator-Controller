;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Plugins              ;;;
;;;                                         Include Sequence                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ..\Plugins\Button Box Plugin.ahk				; Optional, but should be always first, so that Plugins can adopt to the controller layout
#Include ..\Plugins\Stream Deck Plugin.ahk				; Optional, but should be always first, so that Plugins can adopt to the controller layout
#Include ..\Plugins\System Plugin.ahk					; Required, must be loaded before all other ..\Plugins
#Include ..\Plugins\Core Plugin.ahk						; Required, must be loaded directly after System Plugin

#Include ..\Plugins\Motion Feedback Plugin.ahk
#Include ..\Plugins\Tactile Feedback Plugin.ahk
#Include ..\Plugins\Pedal Calibration Plugin.ahk
#Include ..\Plugins\Team Server Plugin.ahk				; Must be loaded before the Race Assistant Plugins
#Include ..\Plugins\Race Engineer Plugin.ahk			; Must be loaded before any other Simulator Plugins
#Include ..\Plugins\Race Strategist Plugin.ahk			; Must be loaded before any other Simulator Plugins
#Include ..\Plugins\Race Spotter Plugin.ahk				; Must be loaded before any other Simulator Plugins
#Include ..\Plugins\AC Plugin.ahk
#Include ..\Plugins\AMS2 Plugin.ahk
#Include ..\Plugins\ACC Plugin.ahk
#Include ..\Plugins\IRC Plugin.ahk
#Include ..\Plugins\R3E Plugin.ahk
#Include ..\Plugins\RF2 Plugin.ahk
#Include ..\Plugins\PCARS2 Plugin.ahk
#Include ..\Plugins\RST Plugin.ahk
