;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Classes Library          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

; #Warn ClassOverwrite, Off


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Constants.ahk
#Include ..\Includes\Variables.ahk
#Include ..\Includes\Functions.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class:          Configurable Item                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfigurationItem {
	iConfiguration := false

	Configuration[] {
        Get {
            return this.iConfiguration
        }
    }

	__New(configuration := false) {
		if configuration {
			this.iConfiguration := configuration

			this.loadFromConfiguration(configuration)
		}
	}

	loadFromConfiguration(configuration) {
		this.iConfiguration := configuration
	}

	saveToConfiguration(configuration) {
	}

	descriptor(values*) {
		local result := ""
		local index, value

		for index, value in values {
			if (index > 1)
				result .= "."

			result .= value
		}

		return result
	}

	splitDescriptor(descriptor) {
		return StrSplit(descriptor, ".")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Applications]:          General Configurable Applications              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Application extends ConfigurationItem {
	iApplication := ""
	iExePath := ""
	iWorkingDirectory := ""
	iWindowTitle := ""
	iSpecialStartup := false
	iSpecialShutdown := false
	iSpecialIsRunning := false

	iRunningPID := 0

	Application[] {
        Get {
            return this.iApplication
        }
    }

	ExePath[] {
        Get {
            return this.iExePath
        }
    }

	WorkingDirectory[] {
        Get {
            return this.iWorkingDirectory
        }
    }

	WindowTitle[] {
        Get {
            return this.iWindowTitle
        }
    }

	SpecialStartup[] {
        Get {
            return this.iSpecialStartup
        }
    }

	SpecialShutdown[] {
        Get {
            return this.iSpecialShutdown
        }
    }

	SpecialIsRunning[] {
        Get {
            return this.iSpecialIsRunning
        }
    }

	CurrentPID[] {
		Get {
			if ((this.iRunningPID == 0) || (this.iRunningPID == -1))
				this.iRunningPID := this.getProcessID()

			return this.iRunningPID
		}
	}

	__New(application, configuration := false, exePath := "", workingDirectory := "", windowTitle := "", specialStartup := "", specialShutdown := "", specialIsRunning := "") {
		this.iApplication := application
		this.iExePath := exePath
		this.iWorkingDirectory := workingDirectory
		this.iWindowTitle := windowTitle
		this.iSpecialStartup := specialStartup
		this.iSpecialShutdown := specialShutdown
		this.iSpecialIsRunning := specialIsRunning

		base.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local exePath, workingDirectory

		base.loadFromConfiguration(configuration)

		this.iExePath := getConfigurationValue(configuration, this.Application, "Exe Path", "")
		this.iWorkingDirectory := getConfigurationValue(configuration, this.Application, "Working Directory", "")
		this.iWindowTitle := getConfigurationValue(configuration, this.Application, "Window Title", "")

		if ((this.iExePath != "") && (this.iWorkingDirectory == "")) {
			exePath := this.iExePath

			SplitPath exePath, , workingDirectory

			this.iWorkingDirectory := workingDirectory
		}

		this.iSpecialStartup := getConfigurationValue(configuration, "Application Hooks"
													, ConfigurationItem.descriptor(this.Application, "Startup"), false)
		this.iSpecialShutdown := getConfigurationValue(configuration, "Application Hooks"
													 , ConfigurationItem.descriptor(this.Application, "Shutdown"), false)
		this.iSpecialIsRunning := getConfigurationValue(configuration, "Application Hooks"
													  , ConfigurationItem.descriptor(this.Application, "Running"), false)
	}

	saveToConfiguration(configuration) {
		local startHandler, shutdownHandler, runningHandler

		base.saveToConfiguration(configuration)

		setConfigurationValue(configuration, this.Application, "Exe Path", this.ExePath)
		setConfigurationValue(configuration, this.Application, "Working Directory", this.WorkingDirectory)
		setConfigurationValue(configuration, this.Application, "Window Title", this.WindowTitle)

		startHandler := this.SpecialStartup
		shutdownHandler := this.SpecialShutdown
		runningHandler := this.SpecialIsRunning

		if (startHandler && (startHandler != ""))
			setConfigurationValue(configuration, "Application Hooks", ConfigurationItem.descriptor(this.Application, "Startup"), startHandler)
		if (shutdownHandler && (shutdownHandler != ""))
			setConfigurationValue(configuration, "Application Hooks", ConfigurationItem.descriptor(this.Application, "Shutdown"), shutdownHandler)
		if (runningHandler && (runningHandler != ""))
			setConfigurationValue(configuration, "Application Hooks", ConfigurationItem.descriptor(this.Application, "Running"), runningHandler)
	}

	startup(special := true, wait := false, options := "") {
		local specialStartup := this.iSpecialStartup

		logMessage(kLogInfo, "Starting application " . this.Application)

		if (special && (specialStartup && specialStartup != "")) {
			if IsLabel(specialStartup) {
				Gosub %specialStartup%

				return this.CurrentPID
			}
			else
				return (this.iRunningPID := %specialStartup%())
		}
		else
			return (this.iRunningPID := Application.run(this.Application, this.ExePath, this.WorkingDirectory, options, wait))
	}

	shutdown(special := true) {
		local specialShutdown := this.iSpecialShutdown

		logMessage(kLogInfo, "Stopping application " . this.Application)

		if (special && specialShutdown && (specialShutdown != "")) {
			if IsLabel(specialShutdown)
				Gosub %specialShutdown%
			else
				%specialShutdown%()

			this.iRunningPID := 0
		}
		else {
			if (this.iRunningPID > 0)
				try {
					WinClose % "ahk_pid " . this.iRunningPID
					Process Close, % this.iRunningPID
				}
				catch exception {
					; Ignored
				}
			else if (this.ExePath != "")
				WinClose % "ahk_exe " . this.ExePath
			else if (this.WindowTitle != "")
				WinClose % this.WindowTitle

			this.iRunningPID := 0
		}
	}

	isRunning(special := true) {
		local specialIsRunning := this.iSpecialIsRunning

		if (special && specialIsRunning && (specialIsRunning != ""))
			if (Func(specialIsRunning) && %specialIsRunning%())
				return true
			else if (this.getProcessID() != 0)
				return true
			else
				return false

		return (this.getProcessID() != 0)
	}

	getProcessID() {
		local processID := false
		local curDetectHiddenWindows := A_DetectHiddenWindows

		DetectHiddenWindows On

		try {
			if (this.iRunningPID > 0) {
				Process Exist, % this.iRunningPID

				processID := ((ErrorLevel != 0) || WinExist("ahk_pid " . this.iRunningPID)) ? this.iRunningPID : 0
			}

			if (!processID && (this.WindowTitle != ""))
				if WinExist(this.WindowTitle)
					WinGet processID, PID, % this.WindowTitle

			if (!processID && (this.ExePath != ""))
				if WinExist("ahk_exe " . this.ExePath)
					WinGet processID, PID, % "ahk_exe " . this.ExePath
		}
		finally {
			DetectHiddenWindows % curDetectHiddenWindows
		}

		return (this.iRunningPID := processID)
	}

	run(application, exePath, workingDirectory, options := "", wait := false) {
		local pid, message, result

		try {
			if InStr(exePath, A_Space)
				exePath := ("""" . exePath . """")

			if InStr(workingDirectory, A_Space)
				workingDirectory := ("""" . workingDirectory . """")

			if wait {
				RunWait %exePath%, %workingDirectory%, %options%

				result := ErrorLevel

				logMessage(kLogInfo, translate("Application ") . application . translate(" executed with result code ") . result)

				return result
			}
			else {
				Run %exePath%, %workingDirectory%, %options%, pid

				logMessage(kLogInfo, translate("Application ") . application . translate(" started"))

				return pid
			}
		}
		catch exception {
			message := (IsObject(exception) ? exception.Message : exception)

			logMessage(kLogCritical, translate("Error while starting application ") . application . translate(" (") . exePath . translate("): ") . message . " - please check the configuration")

			showMessage(substituteVariables(translate("Cannot start %application% (%exePath%) - please check the configuration..."), {application: application, exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return 0
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class:          Configurable Function                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Function extends ConfigurationItem {
	iNumber := 0
	iHotkeys := {}
	iActions := {}

	Type[] {
		Get {
			throw "Virtual property Function.Type must be implemented in a subclass..."
		}
	}

	Number[] {
		Get {
			return this.iNumber
		}
	}

	Descriptor[] {
		Get {
			return this.Type . "." . this.Number
		}
	}

	Trigger[] {
		Get {
			throw "Virtual property Function.Trigger must be implemented in a subclass..."
		}
	}

	Hotkeys[trigger := false, asText := false] {
		Get {
			local result, hotkeys

			if trigger {
				result := this.iHotkeys[trigger]

				if asText
					result := values2String(" | ", result*)

				return result
			}
			else if asText {
				result := {}

				for trigger, hotkeys in this.iHotkeys
					result[trigger] := values2String(" | ", hotkeys*)

				return result
			}
			else
				return this.iHotkeys
		}
	}

	Actions[trigger := false, asText := false] {
		Get {
			local action, arguments, index, argument, theAction, result

			if trigger {
				action := this.iActions[trigger]

				if asText {
					arguments := []

					if (action && (action.Length() == 2)) {
						arguments := action[2].Clone()

						for index, argument in arguments
							if (argument == true)
								arguments[index] := kTrue
							else if (argument == false)
								arguments[index] := kFalse
					}

					action := ((action && (action.Length() == 2) && action[1]) ? (action[1] . "(" . values2String(", ", arguments*) . ")") : "")
				}
				else
					action := this.actionCallable(trigger, action)

				return action
			}
			else {
				result := {}

				for trigger, theAction in this.iActions
					if asText {
						arguments := []

						if (theAction && (theAction.Length() == 2)) {
							arguments := theAction[2].Clone()

							for index, argument in arguments
								if (argument == true)
									arguments[index] := kTrue
								else if (argument == false)
									arguments[index] := kFalse
						}

						result[trigger] := ((theAction && (theAction.Length() == 2)) ? (theAction[1] . "(" . values2String(", ", arguments*) . ")") : "")
					}
					else
						result[trigger] := this.actionCallable(trigger, action)

				return result
			}
		}
	}

	__New(functionNumber, configuration := false, hotkeyActions*) {
		local index := 1
		local ignore, trigger

		this.iNumber := functionNumber

		for ignore, trigger in this.Trigger {
			if (index > hotkeyActions.Length())
				break

			this.loadFromDescriptor(trigger, hotkeyActions[index++])
			this.loadFromDescriptor(trigger . " Action", hotkeyActions[index++])
		}

		base.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local functionDescriptor, descriptorValues

		base.loadFromConfiguration(configuration)

		for functionDescriptor, descriptorValues in getConfigurationSectionValues(configuration, "Controller Functions", Object()) {
			functionDescriptor := ConfigurationItem.splitDescriptor(functionDescriptor)

			if ((functionDescriptor[1] == this.Type) && (functionDescriptor[2] == this.Number))
				this.loadFromDescriptor(functionDescriptor[3], descriptorValues)
		}
	}

	loadFromDescriptor(trigger, value) {
		if InStr(trigger, " Action") {
			trigger := SubStr(trigger, 1, StrLen(trigger) - StrLen(" Action"))

			this.iActions[trigger] := this.computeAction(trigger, value)
		}
		else
			this.iHotkeys[trigger] := this.computeHotkeys(value)
	}

	saveToConfiguration(configuration) {
		local descriptor := this.Descriptor
		local ignore, trigger

		base.saveToConfiguration(configuration)

		for ignore, trigger in this.Trigger {
			setConfigurationValue(configuration, "Controller Functions", descriptor . "." . trigger, this.Hotkeys[trigger, true])
			setConfigurationValue(configuration, "Controller Functions", descriptor . "." . trigger . " Action", this.Actions[trigger, true])
		}
	}

	createFunction(descriptor, configuration := false, onHotkeys := false, onAction := false, offHotkeys := false, offAction := false) {
		descriptor := ConfigurationItem.splitDescriptor(descriptor)

		switch descriptor[1] {
			case k1WayToggleType:
				return new 1WayToggleFunction(descriptor[2], configuration, onHotkeys, onAction)
			case k2WayToggleType:
				return new 2WayToggleFunction(descriptor[2], configuration, onHotkeys, onAction, offHotkeys, offAction)
			case kButtonType:
				return new ButtonFunction(descriptor[2], configuration, onHotkeys, onAction)
			case kDialType:
				return new DialFunction(descriptor[2], configuration, onHotkeys, onAction, offHotkeys, offAction)
			case kCustomType:
				return new CustomFunction(descriptor[2], configuration, onHotkeys, onAction)
			default:
				throw "Unknown controller function (" . descriptor[1] . ") detected in Function.createFunction..."
		}
	}

	computeHotkeys(value) {
		return StrSplit(value, "|", " `t")
	}

	computeAction(trigger, action) {
		local arguments, argument, index

		action := Trim(action)

		if (action == "")
			return false
		else {
			action := StrSplit(action, "(", " `t", 2)

			arguments := string2Values(",", SubStr(action[2], 1, StrLen(action[2]) - 1))
			action := action[1]

			for index, argument in arguments {
				if (argument = kTrue)
					arguments[index] := true
				else if (argument = kFalse)
					arguments[index] := false
			}

			return Array(action, arguments)
		}
	}

	actionCallable(trigger, action) {
		local function := (action != false) ? Func(action[1]) : false

		return (function != false) ? function.Bind(action[2]*) : false
	}

	fireAction(trigger) {
		local action := this.Actions[trigger]

		if action
			%action%()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for 1-way Toggle Switches             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class 1WayToggleFunction extends Function {
	Type[] {
		Get {
			return k1WayToggleType
		}
	}

	Trigger[] {
		Get {
			return ["On"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for 2-way Toggle Switches             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class 2WayToggleFunction extends Function {
	Type[] {
		Get {
			return k2WayToggleType
		}
	}

	Trigger[] {
		Get {
			return ["On", "Off"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for Push Buttons                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonFunction extends Function {
	Type[] {
		Get {
			return kButtonType
		}
	}

	Trigger[] {
		Get {
			return ["Push"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for Rotary Dials                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DialFunction extends Function {
	Type[] {
		Get {
			return kDialType
		}
	}

	Trigger[] {
		Get {
			return ["Increase", "Decrease"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for Custom Controls                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CustomFunction extends Function {
	Type[] {
		Get {
			return kCustomType
		}
	}

	Trigger[] {
		Get {
			return ["Call"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Plugins]:               Plugin Description                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Plugin extends ConfigurationItem {
	iPlugin := ""
	iIsActive := false
	iSimulators := []
	iArguments := {}

	Name[] {
		Get {
			return this.iPlugin
		}
	}

	Plugin[] {
		Get {
			return this.iPlugin
		}
	}

	Active[] {
		Get {
			return this.iIsActive
		}
	}

	Simulators[] {
		Get {
			return this.iSimulators
		}
	}

	Arguments[asText := false] {
		Get {
			local argument, values, result

			if asText {
				result := []

				for argument, values in this.Arguments
					if (values == "")
						result.Push(argument)
					else
						result.Push(argument . ": " . values)

				return values2String("; ", result*)
			}
			else
				return this.iArguments
		}
	}

	__New(plugin, configuration := false, active := false, simulators := "", arguments := "") {
		local ignore, simulator

		this.iPlugin := plugin
		this.iIsActive := active

		for ignore, simulator in string2Values(",", simulators)
			this.iSimulators.Push(simulator)

		this.iArguments := this.computeArgments(arguments)

		base.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local descriptor

		base.loadFromConfiguration(configuration)

		descriptor := getConfigurationValue(configuration, "Plugins", this.Plugin, "")

		if (StrLen(descriptor) > 0) {
			descriptor := StrSplit(descriptor, "|", " `t", 3)

			if (descriptor.Length() > 0) {
				this.iIsActive := ((descriptor[1] == true) || (descriptor[1] = kTrue)) ? true : false
				this.iSimulators := StrSplit(descriptor[2], [",", ";"], " `t")
				this.iArguments := this.computeArgments(descriptor[3])
			}
		}
	}

	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		setConfigurationValue(configuration, "Plugins", this.Plugin, (this.Active ? kTrue : kFalse) . "|" . values2String(", ", this.Simulators*) . "|" . this.Arguments[true])
	}

	computeArgments(arguments) {
		local ignore, argument
		local result := {}

		for ignore, argument in string2Values(";", arguments) {
			argument := string2Values(":", argument, 2)

			result[argument[1]] := ((argument.Length() == 1) ? "" : argument[2])
		}

		return result
	}

	hasArgument(parameter) {
		return this.Arguments.HasKey(parameter)
	}

	getArgumentValue(argument, default := false) {
		if this.hasArgument(argument)
			return this.iArguments[argument]
		else
			return default
	}

	setArgumentValue(argument, value) {
		this.iArguments[argument] := value
	}

	parseValues(delimiter, string) {
		local startPos, endPos, argument, key, result, ignore, value
		local arguments := {}

		loop {
			startPos := InStr(string, """")

			if startPos {
				startPos += 1
				endPos := InStr(string, """", false, startPos)

				if endPos {
					argument := SubStr(string, startPos, endPos - startPos)
					key := "/#/" . A_Index . "/#/"

					arguments[key] := argument

					string := StrReplace(string, """" . argument . """", key)
				}
				else
					throw "Second "" not found while parsing (" . string . ") for quoted argument values in Plugin.parseValues..."
			}
			else
				break
		}

		result := []

		for ignore, value in string2Values(delimiter, string)
			result.Push(arguments.HasKey(value) ? arguments[value] : value)

		return result
	}
}