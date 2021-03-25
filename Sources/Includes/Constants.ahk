;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Constants Library        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAHKDirectory = "C:\Program Files\AutoHotkey\"

global kHomeDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\" : "\..\..\"))
global kUserHomeDirectory = A_MyDocuments . "\Simulator Controller\"

global kResourcesDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Resources\" : "\..\..\Resources\"))
global kSourcesDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Sources\" : "\..\..\Sources\"))
global kIncludesDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Sources\Includes\" : "\..\..\Sources\Includes\"))
global kLibrariesDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Sources\Libraries\" : "\..\..\Sources\Libraries\"))
global kBinariesDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Binaries\" : "\..\..\Binaries\"))

global kLogsDirectory = kUserHomeDirectory . "Logs\"
global kSetupDatabaseDirectory = kUserHomeDirectory . "Setup Database\"

global kPluginsDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Sources\Plugins\" : "\..\..\Sources\Plugins\"))
global kUserPluginsDirectory = kUserHomeDirectory . "Plugins\"

global kConfigDirectory = normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Config\" : "\..\..\Config\"))
global kUserConfigDirectory = kUserHomeDirectory . "Config\"

global kSplashMediaDirectory = kResourcesDirectory . "Splash Media\"
global kUserSplashMediaDirectory = kUserHomeDirectory . "Splash Media\"

global kScreenImagesDirectory = kResourcesDirectory . "Screen Images\"
global kUserScreenImagesDirectory = kUserHomeDirectory . "Screen Images\"

global kButtonBoxImagesDirectory = kResourcesDirectory . "Button Box Images\"
global kIconsDirectory = kResourcesDirectory . "Icons\"

global kSimulatorConfigurationFile = "Simulator Configuration.ini"
global kSimulatorSettingsFile = "Simulator Settings.ini"

global kUndefined = "__Undefined__"

global kVersion = kUndefined

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

global kActivate = "activate"
global kDeactivate = "deactivate"

global kIncrease = "increase"
global kDecrease = "decrease"

global kLogInfo = 1
global kLogWarn = 2
global kLogCritical = 3
global kLogOff = 4

global kLocalMessage = 0
global kWindowMessage = 1
global kPipeMessage = 2
global kFileMessage = 3