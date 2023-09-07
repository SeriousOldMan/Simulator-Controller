;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Classes Library          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "Strings.ahk"
#Include "Collections.ahk"
#Include "MultiMap.ahk"
#Include "Message.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class:          Configurable Item                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfigurationItem {
	iConfiguration := false

	Configuration {
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

	static descriptor(values*) {
		local result := ""
		local index, value

		for index, value in values {
			if (index > 1)
				result .= "."

			result .= value
		}

		return result
	}

	descriptor(values*) {
		return ConfigurationItem.descriptor(values*)
	}

	static splitDescriptor(descriptor) {
		return toArray(StrSplit(descriptor, "."), WeakArray)
	}

	splitDescriptor(descriptor) {
		return ConfigurationItem.splitDescriptor(descriptor)
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

	Application {
        Get {
            return this.iApplication
        }
    }

	ExePath {
        Get {
            return this.iExePath
        }
    }

	WorkingDirectory {
        Get {
            return this.iWorkingDirectory
        }
    }

	WindowTitle {
        Get {
            return this.iWindowTitle
        }
    }

	SpecialStartup {
        Get {
            return this.iSpecialStartup
        }
    }

	SpecialShutdown {
        Get {
            return this.iSpecialShutdown
        }
    }

	SpecialIsRunning {
        Get {
            return this.iSpecialIsRunning
        }
    }

	CurrentPID {
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

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local exePath, workingDirectory

		super.loadFromConfiguration(configuration)

		this.iExePath := getMultiMapValue(configuration, this.Application, "Exe Path", "")
		this.iWorkingDirectory := getMultiMapValue(configuration, this.Application, "Working Directory", "")
		this.iWindowTitle := getMultiMapValue(configuration, this.Application, "Window Title", "")

		if ((this.iExePath != "") && (this.iWorkingDirectory == "")) {
			exePath := this.iExePath

			SplitPath(exePath, , &workingDirectory)

			this.iWorkingDirectory := workingDirectory
		}

		this.iSpecialStartup := getMultiMapValue(configuration, "Application Hooks"
													, ConfigurationItem.descriptor(this.Application, "Startup"), false)
		this.iSpecialShutdown := getMultiMapValue(configuration, "Application Hooks"
													 , ConfigurationItem.descriptor(this.Application, "Shutdown"), false)
		this.iSpecialIsRunning := getMultiMapValue(configuration, "Application Hooks"
													  , ConfigurationItem.descriptor(this.Application, "Running"), false)
	}

	saveToConfiguration(configuration) {
		local startHandler, shutdownHandler, runningHandler

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, this.Application, "Exe Path", this.ExePath)
		setMultiMapValue(configuration, this.Application, "Working Directory", this.WorkingDirectory)
		setMultiMapValue(configuration, this.Application, "Window Title", this.WindowTitle)

		startHandler := this.SpecialStartup
		shutdownHandler := this.SpecialShutdown
		runningHandler := this.SpecialIsRunning

		if (startHandler && (startHandler != ""))
			setMultiMapValue(configuration, "Application Hooks", ConfigurationItem.descriptor(this.Application, "Startup"), startHandler)
		if (shutdownHandler && (shutdownHandler != ""))
			setMultiMapValue(configuration, "Application Hooks", ConfigurationItem.descriptor(this.Application, "Shutdown"), shutdownHandler)
		if (runningHandler && (runningHandler != ""))
			setMultiMapValue(configuration, "Application Hooks", ConfigurationItem.descriptor(this.Application, "Running"), runningHandler)
	}

	startup(special := true, wait := false, options := "") {
		local specialStartup := this.iSpecialStartup

		logMessage(kLogInfo, "Starting application " . this.Application)

		if (special && (specialStartup && specialStartup != "")) {
			try {
				return (this.iRunningPID := %specialStartup%())
			}
			catch Any as exception {
				logError(exception)

				return (this.iRunningPID := Application.run(this.Application, this.ExePath, this.WorkingDirectory, options, wait))
			}
		}
		else
			return (this.iRunningPID := Application.run(this.Application, this.ExePath, this.WorkingDirectory, options, wait))
	}

	shutdown(special := true) {
		local specialShutdown := this.iSpecialShutdown

		logMessage(kLogInfo, "Stopping application " . this.Application)

		if (special && specialShutdown && (specialShutdown != "")) {
			try {
				%specialShutdown%()
			}
			catch Any as exception {
				logError(exception)

				try {
					WinClose("ahk_pid " . this.iRunningPID)
					ProcessClose(this.iRunningPID)
				}
				catch Any as exception {
					logError(exception)
				}
			}

			this.iRunningPID := 0
		}
		else {
			if (this.iRunningPID > 0) {
				try {
					WinClose("ahk_pid " . this.iRunningPID)
					ProcessClose(this.iRunningPID)
				}
				catch Any as exception {
					logError(exception)
				}
			}
			else if (this.ExePath != "") {
				WinClose("ahk_exe " . this.ExePath)
			}
			else if (this.WindowTitle != "")
				WinClose(this.WindowTitle)

			this.iRunningPID := 0
		}
	}

	isRunning(special := true) {
		local specialIsRunning := this.iSpecialIsRunning

		if (special && specialIsRunning && (specialIsRunning != ""))
			try {
				if %specialIsRunning%()
					return true
				else if (this.getProcessID() != 0)
					return true
				else
					return false
			}
			catch Any as exception {
				logError(exception)
			}

		return (this.getProcessID() != 0)
	}

	getProcessID() {
		local processID := false
		local curDetectHiddenWindows := A_DetectHiddenWindows

		DetectHiddenWindows(true)

		try {
			if (this.iRunningPID > 0)
				processID := ((ProcessExist(this.iRunningPID) != 0) || WinExist("ahk_pid " . this.iRunningPID)) ? this.iRunningPID : 0

			if (!processID && (this.WindowTitle != ""))
				if WinExist(this.WindowTitle)
					processID := WinGetPID(this.WindowTitle)

			if (!processID && (this.ExePath != ""))
				if WinExist("ahk_exe " . this.ExePath)
					processID := WinGetPID("ahk_exe " . this.ExePath)
		}
		finally {
			DetectHiddenWindows(curDetectHiddenWindows)
		}

		return (this.iRunningPID := processID)
	}

	static run(application, exePath, workingDirectory, options := "", wait := false) {
		local pid, message, result

		try {
			if InStr(exePath, A_Space)
				exePath := ("`"" . exePath . "`"")

			if wait {
				result := RunWait(exePath, workingDirectory, options)

				logMessage(kLogInfo, translate("Application ") . application . translate(" executed with result code ") . result)

				return result
			}
			else {
				Run(exePath, workingDirectory, options, &pid)

				logMessage(kLogInfo, translate("Application ") . application . translate(" started"))

				return pid
			}
		}
		catch Any as exception {
			logError(exception, true)

			message := (isObject(exception) ? exception.Message : exception)

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
	iLabel := false
	iNumber := 0
	iHotkeys := CaseInsenseMap()
	iActions := CaseInsenseMap()

	Type {
		Get {
			throw "Virtual property Function.Type must be implemented in a subclass..."
		}
	}

	Label {
		Get {
			return this.iLabel
		}

		Set {
			return (this.iLabel := value)
		}
	}

	Number {
		Get {
			return this.iNumber
		}
	}

	Descriptor {
		Get {
			return (this.Type . "." . this.Number)
		}
	}

	Trigger {
		Get {
			throw "Virtual property Function.Trigger must be implemented in a subclass..."
		}
	}

	Hotkeys[trigger := false, asText := false] {
		Get {
			local result, hotkeys

			if trigger {
				if this.iHotkeys.Has(trigger) {
					result := this.iHotkeys[trigger]

					if asText
						result := values2String(" | ", result*)

					return result
				}
				else if asText
					return ""
				else
					return CaseInsenseMap()
			}
			else if asText {
				result := CaseInsenseMap()

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
			local ignore, action, arguments, index, argument, result, actions, callables

			callActions(actions, *) {
				local ignore, action

				for ignore, action in actions
					action.Call()
			}

			if trigger {
				actions := this.iActions[trigger]
				callables := []

				if asText {
					for ignore, action in actions {
						arguments := []

						if (action && (action.Length == 2)) {
							arguments := action[2].Clone()

							for index, argument in arguments
								if (argument == true)
									arguments[index] := kTrue
								else if (argument == false)
									arguments[index] := kFalse
						}

						if action
							callables.Push((action && (action.Length == 2) && action[1]) ? (action[1] . "(" . values2String(", ", arguments*) . ")") : "")
					}

					return ((callables.Length > 0) ? values2String(" | ", callables*) : "")
				}
				else {
					if (actions.Length > 0) {
						for ignore, action in actions {
							action := this.actionCallable(trigger, action)

							if action
								callables.Push(action)
							else
								return false
						}
					}
					else {
						action := this.actionCallable(trigger, false)

						if action
							callables.Push(action)
						else
							return false
					}

					return ((callables.Length > 0) ? ((callables.Length = 1) ? callables[1] : callActions.Bind(callables)) : false)
				}
			}
			else {
				result := CaseInsenseMap()

				for trigger, actions in this.iActions {
					callables := []

					for ignore, action in actions
						if asText {
							arguments := []

							if (action && (action.Length == 2)) {
								arguments := action[2].Clone()

								for index, argument in arguments
									if (argument == true)
										arguments[index] := kTrue
									else if (argument == false)
										arguments[index] := kFalse
							}

							if action
								callables.Push((action && (action.Length == 2)) ? (action[1] . "(" . values2String(", ", arguments*) . ")") : "")
						}
						else {
							action := this.actionCallable(trigger, action)

							if action
								callables.Push(action)
							else {
								callables := []

								continue 2
							}
						}

					if (!asText && (callables.Length = 0)) {
						action := this.actionCallable(trigger, false)

						if action
							callables.Push(action)
					}

					result[trigger] := (asText ? values2String(" | ", callables*)
											   : ((callables.Length > 0) ? ((callables.Length = 1) ? callables[1] : callActions.Bind(callables)) : false))
				}

				return result
			}
		}
	}

	__New(functionNumber, configuration := false, hotkeyActions*) {
		local index := 1
		local ignore, trigger

		this.iNumber := functionNumber

		for ignore, trigger in this.Trigger {
			if (index > hotkeyActions.Length)
				break

			this.loadFromDescriptor(trigger, hotkeyActions[index++])
			this.loadFromDescriptor(trigger . ".Action", hotkeyActions[index++])
		}

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local functionDescriptor, descriptorValues, trigger

		super.loadFromConfiguration(configuration)

		for functionDescriptor, descriptorValues in getMultiMapValues(configuration, "Controller Functions") {
			functionDescriptor := ConfigurationItem.splitDescriptor(functionDescriptor)

			if ((functionDescriptor[1] == this.Type) && (functionDescriptor[2] == this.Number)) {
				if (functionDescriptor.Length = 4) {
					functionDescriptor[3] := ConfigurationItem.descriptor(functionDescriptor[3], functionDescriptor[4])

					functionDescriptor.RemoveAt(4)
				}

				this.loadFromDescriptor(functionDescriptor[3], descriptorValues)
			}
		}
	}

	loadFromDescriptor(trigger, value) {
		if InStr(trigger, ".Action") {
			trigger := SubStr(trigger, 1, StrLen(trigger) - StrLen(".Action"))

			this.iActions[trigger] := this.computeActions(trigger, value)
		}
		else if InStr(trigger, " Action") {
			trigger := SubStr(trigger, 1, StrLen(trigger) - StrLen(" Action"))

			this.iActions[trigger] := this.computeActions(trigger, value)
		}
		else if (trigger = "Label")
			this.iLabel := value
		else
			this.iHotkeys[trigger] := this.computeHotkeys(value)
	}

	saveToConfiguration(configuration) {
		local descriptor := this.Descriptor
		local ignore, trigger, hotkeys

		super.saveToConfiguration(configuration)

		for ignore, trigger in this.Trigger {
			setMultiMapValue(configuration, "Controller Functions", descriptor . "." . trigger, this.Hotkeys[trigger, true])
			setMultiMapValue(configuration, "Controller Functions", descriptor . "." . trigger . ".Action", this.Actions[trigger, true])
		}
	}

	static createFunction(descriptor, configuration := false, onHotkeys := "", onAction := "", offHotkeys := "", offAction := "") {
		descriptor := ConfigurationItem.splitDescriptor(descriptor)

		switch descriptor[1], false {
			case k1WayToggleType:
				return OneWayToggleFunction(descriptor[2], configuration, onHotkeys, onAction)
			case k2WayToggleType:
				return TwoWayToggleFunction(descriptor[2], configuration, onHotkeys, onAction, offHotkeys, offAction)
			case kButtonType:
				return ButtonFunction(descriptor[2], configuration, onHotkeys, onAction)
			case kDialType:
				return DialFunction(descriptor[2], configuration, onHotkeys, onAction, offHotkeys, offAction)
			case kCustomType:
				return CustomFunction(descriptor[2], configuration, onHotkeys, onAction)
			default:
				throw "Unknown controller function (" . descriptor[1] . ") detected in Function.createFunction..."
		}
	}

	computeHotkeys(value) {
		return StrSplit(value, "|", " `t")
	}

	computeActions(trigger, action) {
		local arguments, argument, index, ignore, actions

		action := Trim(action)

		if (!action || (action == ""))
			return []
		else {
			actions := []

			for ignore, action in (InStr(action, "|") ? StrSplit(action, "|") : StrSplit(action, ";")) {
				action := StrSplit(action, "(", " `t", 2)

				arguments := string2Values(",", SubStr(action[2], 1, StrLen(action[2]) - 1))
				action := action[1]

				for index, argument in arguments {
					if (argument = kTrue)
						arguments[index] := true
					else if (argument = kFalse)
						arguments[index] := false
				}

				actions.Push(Array(action, arguments))
			}

			return actions
		}
	}

	actionCallable(__trigger__, __action__) {
		local __function__ := false

		if (__action__ != false) {
			__function__ := __action__[1]

			if !isInstance(__function__, Func)
				try {
					__function__ := %__function__%
				}
				catch Any as exception {
					logError(exception, false, false)

					__function__ := false
				}
		}

		return (__function__ ? __function__.Bind(__action__[2]*) : false)
	}

	fireAction(trigger) {
		local action := this.Actions[trigger]

		if action
			action.Call()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for 1-way Toggle Switches             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class OneWayToggleFunction extends Function {
	Type {
		Get {
			return k1WayToggleType
		}
	}

	Trigger {
		Get {
			return ["On"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for 2-way Toggle Switches             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TwoWayToggleFunction extends Function {
	Type {
		Get {
			return k2WayToggleType
		}
	}

	Trigger {
		Get {
			return ["On", "Off"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for Push Buttons                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonFunction extends Function {
	Type {
		Get {
			return kButtonType
		}
	}

	Trigger {
		Get {
			return ["Push"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for Rotary Dials                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DialFunction extends Function {
	Type {
		Get {
			return kDialType
		}
	}

	Trigger {
		Get {
			return ["Increase", "Decrease"]
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; [Controller Functions}:  Function for Custom Controls                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CustomFunction extends Function {
	Type {
		Get {
			return kCustomType
		}
	}

	Trigger {
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
	iArguments := CaseInsenseMap()

	Name {
		Get {
			return this.iPlugin
		}
	}

	Plugin {
		Get {
			return this.iPlugin
		}
	}

	Active {
		Get {
			return this.iIsActive
		}
	}

	Simulators {
		Get {
			return this.iSimulators
		}
	}

	Arguments[asText := false] {
		Get {
			local argument, value, result

			if asText {
				result := []

				for argument, value in this.Arguments
					if (value == "")
						result.Push(argument)
					else
						result.Push(argument . ": " . value)

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

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local descriptor

		super.loadFromConfiguration(configuration)

		descriptor := getMultiMapValue(configuration, "Plugins", this.Plugin, "")

		if (StrLen(descriptor) > 0) {
			descriptor := StrSplit(descriptor, "|", " `t", 3)

			if (descriptor.Length > 0) {
				this.iIsActive := ((descriptor[1] == true) || (descriptor[1] = kTrue)) ? true : false
				this.iSimulators := StrSplit(descriptor[2], [",", ";"], " `t")
				this.iArguments := this.computeArgments(descriptor[3])
			}
		}
	}

	saveToConfiguration(configuration) {
		local descriptor, arguments, key, value, result, argument, values

		super.saveToConfiguration(configuration)

		descriptor := getMultiMapValue(configuration, "Plugins", this.Plugin, "")

		if (StrLen(descriptor) > 0) {
			descriptor := StrSplit(descriptor, "|", " `t", 3)

			if (descriptor.Length > 0) {
				arguments := this.computeArgments(descriptor[3])

				for key, value in this.Arguments
					arguments[key] := value

				result := []

				for argument, values in arguments
					if (values == "")
						result.Push(argument)
					else
						result.Push(argument . ": " . values)

				return values2String("; ", result*)
			}
			else
				arguments := this.Arguments[true]
		}
		else
			arguments := this.Arguments[true]

		setMultiMapValue(configuration, "Plugins", this.Plugin, (this.Active ? kTrue : kFalse) . "|" . values2String(", ", this.Simulators*) . "|" . arguments)
	}

	computeArgments(arguments) {
		local ignore, argument
		local result := CaseInsenseMap()

		for ignore, argument in string2Values(";", arguments)
			if (Trim(argument) != "") {
				argument := string2Values(":", argument, 2)

				result[argument[1]] := ((argument.Length == 1) ? "" : argument[2])
			}

		return result
	}

	hasArgument(parameter) {
		return this.Arguments.Has(parameter)
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
		local arguments := Map()

		loop {
			startPos := InStr(string, "`"")

			if startPos {
				startPos += 1
				endPos := InStr(string, "`"", false, startPos)

				if endPos {
					argument := SubStr(string, startPos, endPos - startPos)
					key := "/#/" . A_Index . "/#/"

					arguments[key] := argument

					string := StrReplace(string, "`"" . argument . "`"", key)
				}
				else
					throw "Second `" not found while parsing (" . string . ") for quoted argument values in Plugin.parseValues..."
			}
			else
				break
		}

		result := []

		for ignore, value in string2Values(delimiter, string)
			result.Push(arguments.Has(value) ? arguments[value] : value)

		return result
	}
}