;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Plugins Include Sequence        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ..\Plugins\ButtonBox Plugin.ahk				; Optional, but must be always first, so that ..\Plugins can adopt to the button box layout
#Include ..\Plugins\System Plugin.ahk					; Required, must be loaded before all other ..\Plugins
#Include ..\Plugins\Core Plugin.ahk						; Required, must be loaded directly after System Plugin

#Include ..\Plugins\Motion Feedback Plugin.ahk
#Include ..\Plugins\Tactile Feedback Plugin.ahk
#Include ..\Plugins\Pedal Calibration Plugin.ahk
#Include ..\Plugins\AC Plugin.ahk
#Include ..\Plugins\ACC Plugin.ahk
#Include ..\Plugins\RF2 Plugin.ahk
#Include ..\Plugins\RST Plugin.ahk
