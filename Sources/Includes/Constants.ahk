;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Constants Library        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAHKDirectory = "C:\Program Files\AutoHotkey\"

global kHomeDirectory = A_ScriptDir . (A_IsCompiled ? "\..\" : "\..\..\")
global kResourcesDirectory = A_ScriptDir . (A_IsCompiled ? "\..\Resources\" : "\..\..\Resources\")
global kSourcesDirectory = A_ScriptDir . (A_IsCompiled ? "\..\Sources\" : "\..\..\Sources\")
global kIncludesDirectory = A_ScriptDir . (A_IsCompiled ? "\..\Sources\Includes\" : "\..\..\Sources\Includes\")
global kBinariesDirectory = A_ScriptDir . (A_IsCompiled ? "\..\Binaries\" : "\..\..\Binaries\")
global kConfigDirectory = A_ScriptDir . (A_IsCompiled ? "\..\Config\" : "\..\..\Config\")
global kLogsDirectory = A_ScriptDir . (A_IsCompiled ? "\..\Logs\" : "\..\..\Logs\")

global kSplashImagesDirectory = kResourcesDirectory . "SplashImages\"
global kButtonBoxImagesDirectory = kResourcesDirectory . "ButtonBoxImages\"
global kIconsDirectory = kResourcesDirectory . "Icons\"

global kSimulatorConfigurationFile = kConfigDirectory . "Simulator Configuration.ini"
global kControllerConfigurationFile = kConfigDirectory . "Simulator Controller.ini"
global kToolsConfigurationFile = kConfigDirectory . "Simulator Tools.ini"

global kSimulatorConfiguration

global kSilentMode = false

global kNirCmd = false

global k1WayToggleType = "1WayToggle"
global k2WayToggleType = "2WayToggle"
global kButtonType = "Button"
global kDialType = "Dial"
global kCustomType = "Custom"

global kTrue = "true"
global kFalse = "false"

global kUndefined = "__Undefined__"

global kActivate = "activate"
global kDeactivate = "deactivate"

global kIncrease = "increase"
global kDecrease = "decrease"

global kLogInfo = 1
global kLogWarn = 2
global kLogCritical = 3
global kLogOff = 4