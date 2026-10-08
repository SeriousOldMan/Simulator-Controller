;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Extended Hotkey Managment       ;;;
;;;                                                                         ;;;
;;;   Author:     Tim Harbeck and Oliver Juwig (TheBigO)                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Extensions\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kMaxLegacyControllers := 16


;;;-------------------------------------------------------------------------;;;
;;;                    Private Classes Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

class TriggerDetectorTask extends Task {
	iCallback := false
	iOptions := []
	iControllers := []

	Options {
		Get {
			return this.iOptions
		}
	}

	CallBack {
		Get {
			return this.iCallback
		}
	}

	Stopped {
		Get {
			return super.Stopped
		}

		Set {
			if value
				ToolTip(, , 1)

			return (super.Stopped := value)
		}
	}

	Controllers[key?] {
		Get {
			return (isSet(key) ? this.iControllers[key] : this.iControllers)
		}
	}

	__New(callback, options, arguments*) {
		this.iOptions := options
		this.iCallback := callback

		super.__New(false, arguments*)
	}

	run() {
		local controllers := []
		local ctrlName, ignore, controllerNumber

		loop kMaxLegacyControllers { ; Query each controller number to find out which ones exist.
			ctrlName := (GetKeyState(A_Index . "JoyName") ? "D" : "")

			if (ctrlName != "")
				controllers.Push(A_Index)
		}

		; Everything beyond the 16 controllers supported by the legacy multimedia API is
		; detected using Raw Input (see HIDControllers).

		HIDControllers.updateControllers(true)

		this.iControllers := concatenate(controllers, HIDControllers.Controllers)

		return TriggerDetectorContinuation(Task.CurrentTask)
	}
}

class TriggerDetectorContinuation extends Continuation {
	__New(task, arguments*) {
		super.__New(task, false, arguments*)
	}

	controllerName(number) {
		return ((number > kMaxLegacyControllers) ? HIDControllers.getName(number)
												 : GetKeyState(number . "JoyName"))
	}

	controllerButtons(number) {
		return ((number > kMaxLegacyControllers) ? HIDControllers.getButtonCount(number)
												 : GetKeyState(number . "JoyButtons"))
	}

	controllerInfo(number) {
		return ((number > kMaxLegacyControllers) ? ""
												 : GetKeyState(number . "JoyInfo"))
	}

	controllerButtonState(number, button) {
		return ((number > kMaxLegacyControllers) ? HIDControllers.getButtonState(number, button)
												 : GetKeyState(number . "Joy" . button))
	}

	run() {
		local key := false
		local found, controllers, controllerNumber
		local ctrl_buttons, ctrl_name, ctrl_state, buttons_down, ctrl_info
		local axis_info, buttonsDown, callback

		if !this.Task.Stopped {
			found := false

			if GetKeyState("Esc") {
				this.stop()

				return false
			}

			key := (inList(this.Task.Options, "Key") ? this.detectKey(inList(this.Task.Options, "Multi"))
													 : false)

			if key {
				if InStr(key, "Esc") {
					this.stop()

					return false
				}

				found := true

				ToolTip(key, , , 1)
			}
			else if inList(this.Task.Options, "Button") {
				controllers := this.Task.Controllers

				loop controllers.Length {
					controllerNumber := controllers[1]

					controllers.RemoveAt(1)
					controllers.Push(controllerNumber)

					; SetFormat Float, 03  ; Omit decimal point from axis position percentages.

					ctrl_buttons := this.controllerButtons(controllerNumber)
					ctrl_name := this.controllerName(controllerNumber)
					ctrl_info := this.controllerInfo(controllerNumber)

					buttons_down := ""
					buttons := []

					loop ctrl_buttons {
						if this.controllerButtonState(controllerNumber, A_Index) {
							buttons_down := (buttons_down . A_Space . A_Index)

							found := A_Index
						}
					}

					axis_info := ""

					if (ctrl_info != "") {
						axis_info := ("X" . (GetKeyState(controllerNumber . "JoyX") ? "D" : "U"))

						axis_info := (axis_info . A_Space . A_Space . "Y" .  (GetKeyState(controllerNumber . "JoyY") ? "D" : "U"))

						if InStr(ctrl_info, "Z")
							axis_info := (axis_info . A_Space . A_Space . "Z" . (GetKeyState(controllerNumber . "JoyZ") ? "D" : "U"))

						if InStr(ctrl_info, "R")
							axis_info := (axis_info . A_Space . A_Space . "R" . (GetKeyState(controllerNumber . "JoyR") ? "D" : "U"))

						if InStr(ctrl_info, "U")
							axis_info := (axis_info . A_Space . A_Space . "U" . (GetKeyState(controllerNumber . "JoyU") ? "D" : "U"))

						if InStr(ctrl_info, "V")
							axis_info := (axis_info . "" . A_Space . "" . A_Space . "V" . (GetKeyState(controllerNumber "JoyV", ) ? "D" : "U"))

						if InStr(ctrl_info, "P")
							axis_info := (axis_info . A_Space . A_Space . "POV" . (GetKeyState(controllerNumber "JoyPOV") ? "D" : "U"))
					}

					buttonsDown := translate("Buttons Down:")
				}
				until found

				if found
					ToolTip(ctrl_name . " (#" controllerNumber "):`n" . axis_info . "`n" . buttonsDown . A_Space . buttons_down, , , 1)
			}

			if found {
				if !key
					key := (controllerNumber . "Joy" . found)

				A_Clipboard := key

				if this.Task.Callback {
					this.Task.Callback.Call(key)

					this.stop()

					return false
				}
				else
					return TriggerDetectorContinuation(this.Task, 2000)
			}
			else
				ToolTip(translate("Waiting..."), , , 1)

			return TriggerDetectorContinuation(this.Task, 0)
		}
		else {
			this.stop()

			return false
		}
	}

	detectKey(multi) {
		local input := InputHook("T0.1")
		local key, expired

		static lastTicks := false
		static lastKeys := []

		expired := (lastTicks ? ((A_TickCount - lastTicks) > 500) : false)

		if !multi
			lastKeys := []

		input.KeyOpt("{All}", "IE")

		input.VisibleText := false
		input.VisibleNonText := false

		input.Start()

		input.Wait()

		key := input.EndKey

		input.Stop()

		if (key && (key != ""))
			if multi {
				if !expired {
					if (lastKeys.Length = 0)
						lastTicks := A_TickCount

					if !inList(lastKeys, key)
						lastKeys.Push(key)
				}
			}
			else
				return key

		if (multi && expired) {
			lastTicks := false

			if (lastKeys.Length > 0) {
				key := this.createHotkey(lastKeys)

				lastKeys := []

				return key
			}
			else
				return false
		}

		return false
	}

	createHotkey(keys) {
		local baseKeys := []
		local baseKey := kUndefined
		local ignore, key, modifiers

		loop 26
			baseKeys.Push(Chr(Ord("a") + A_Index - 1))

		loop 10 {
			baseKeys.Push(String(A_Index - 1))
			baseKeys.Push("Numpad" . (A_Index - 1))
		}

		loop 24
			baseKeys.Push("F" . A_Index)

		for ignore, key in ["Space", "BackSpace", "Tab", "Enter", "Up", "Down", "Left", "Right"
						  , "Home", "End", "Delete", "Insert", "PgUp", "PgDn"]
			baseKeys.Push(key)

		for ignore, key in keys.Clone()
			if inList(baseKeys, key) {
				if (baseKey == kUndefined)
					baseKey := key

				keys := remove(keys, key)
			}

		if (baseKey != kUndefined) {
			modifiers := ""

			for ignore, key in keys
				switch key, false {
					case "LShift":
						modifiers .= "<+"
					case "RShift":
						modifiers .= ">+"
					case "LControl":
						modifiers .= "<^"
					case "RControl":
						modifiers .= ">^"
					case "LAlt":
						modifiers .= "<!"
					case "RAlt":
						modifiers .= ">!"
					case "AltGr":
						modifiers .= "<^>!"
					case "Win":
						modifiers .= "#"
				}

			return (modifiers . baseKey)
		}
		else
			return values2String(" & ", keys*)
	}
}

;;;-------------------------------------------------------------------------;;;
;;; HIDControllers                                                          ;;;
;;;                                                                         ;;;
;;; The legacy multimedia controller API of Windows, which is used by the   ;;;
;;; builtin controller support of AutoHotkey, can only address a maximum of ;;;
;;; 16 game controllers. Everything beyond that is invisible for            ;;;
;;; *GetKeyState* and for controller hotkeys. This class provides an        ;;;
;;; alternative, Raw Input (HID) based implementation, which enumerates all ;;;
;;; connected game controllers and reports their button state. The devices  ;;;
;;; are numbered starting with 17, so that the numbers of all already       ;;;
;;; configured triggers (1 - 16) stay valid.                                ;;;
;;;-------------------------------------------------------------------------;;;

class HIDControllers {
	static sDevices := []
	static sByNumber := Map()
	static sByHandle := Map()
	static sHotkeys := Map()

	static sEnumerated := false
	static sListening := false
	static sLastRefresh := 0

	; Raw Input / HID API constants

	static kRIMTypeHID := 2
	static kRIDIPreparsedData := 0x20000005
	static kRIDIDeviceName := 0x20000007
	static kRIDIDeviceInfo := 0x2000000B
	static kRIDInput := 0x10000003
	static kRIDEVInputSink := 0x00000100
	static kRIDEVDeviceNotify := 0x00002000
	static kWMInput := 0x00FF
	static kWMInputDeviceChange := 0x00FE
	static kGIDCRemoval := 2
	static kHIDPStatusSuccess := 0x00110000
	static kHIDPInput := 0
	static kButtonUsagePage := 0x09

	static Controllers {
		Get {
			HIDControllers.startup()

			return collect(HIDControllers.sDevices, (d) => d.ID)
		}
	}

	static FirstNumber {
		Get {
			return (kMaxLegacyControllers + 1)
		}
	}

	static parseHotkey(theHotkey := "") {
		local descriptor, parts

		if (isObject(theHotkey) || !isInstance(theHotkey, String))
			return false

		if (InStr(theHotkey, "HID") == 1) {
			parts := string2Values("#", theHotKey)

			return {Device: SubStr(parts[1], 4), Key: theHotkey, Button: parts[2]}
		}

		return false
	}

	static setHotkey(trigger, function?, state?) {
		local descriptor, argument

		trigger := this.parseHotkey(trigger)

		if !trigger
			throw "Unsupported controller hotkey detected in HIDControllers.setHotkey..."

		HIDControllers.listen()

		if HIDControllers.sHotkeys.Has(trigger.Key)
			descriptor := HIDControllers.sHotkeys[trigger.Key]
		else {
			descriptor := {Callback: false, Enabled: true}

			HIDControllers.sHotkeys[trigger.Key] := descriptor
		}

		if isSet(function) {
			if isInstance(function, String) {
				state := function
				function := unset
			}

			descriptor.Callback := function
		}

		if isSet(state)
			if InStr(state, "Toggle")
				descriptor.Enabled := !descriptor.Enabled
			else if InStr(state, "Off")
				descriptor.Enabled := false
			else if InStr(state, "On")
				descriptor.Enabled := true
	}

	static getName(device) {
		HIDControllers.startup()

		return (HIDControllers.sByNumber.Has(device) ? HIDControllers.sByNumber[device].Name : "")
	}

	static getButtonCount(device) {
		HIDControllers.startup()

		return (HIDControllers.sByNumber.Has(device) ? HIDControllers.sByNumber[device].Buttons : 0)
	}

	static getButtonState(device, button) {
		HIDControllers.startup()

		return (HIDControllers.sByNumber.Has(device) ? HIDControllers.sByNumber[device].State.Has(button)
													 : false)
	}

	static startup() {
		if !HIDControllers.sEnumerated
			HIDControllers.refresh()
	}

	static listen() {
		local size := (A_PtrSize = 8) ? 16 : 12
		local devices := Buffer(3 * size, 0)
		local index, usage, offset

		HIDControllers.startup()

		if HIDControllers.sListening
			return true

		for index, usage in [0x04, 0x05, 0x08] {
			offset := ((index - 1) * size)

			NumPut("UShort", 0x01, devices, offset)
			NumPut("UShort", usage, devices, offset + 2)
			NumPut("UInt", HIDControllers.kRIDEVInputSink | HIDControllers.kRIDEVDeviceNotify
						 , devices, offset + 4)
			NumPut("Ptr", A_ScriptHwnd, devices, offset + 8)
		}

		if DllCall("RegisterRawInputDevices", "Ptr", devices, "UInt", 3, "UInt", size, "Int") {
			OnMessage(HIDControllers.kWMInput, ObjBindMethod(HIDControllers, "handleInput"))
			OnMessage(HIDControllers.kWMInputDeviceChange, ObjBindMethod(HIDControllers, "handleDeviceChange"))

			HIDControllers.sListening := true
		}

		return HIDControllers.sListening
	}

	static handleDeviceChange(wParam, lParam, message, hwnd) {
		local device

		if (wParam = HIDControllers.kGIDCRemoval) {
			if HIDControllers.sByHandle.Has(lParam) {
				device := HIDControllers.sByHandle[lParam]

				device.State := Map()
			}
		}

		HIDControllers.refresh()
	}

	static refresh() {
		local entrySize := (A_PtrSize = 8) ? 16 : 8
		local known := Map()
		local devices := []
		local count := 0
		local deviceList, handle, deviceType, device, ignore, index, inner
		local assignments, paths := Map(), number, path, nextNumber := HIDControllers.FirstNumber
		local changed := false, mutex, waitResult

		HIDControllers.sEnumerated := true
		HIDControllers.sLastRefresh := A_TickCount

		for ignore, device in HIDControllers.sDevices
			known[device.Path] := device

		if (DllCall("GetRawInputDeviceList", "Ptr", 0, "UInt*", &count
										   , "UInt", entrySize, "UInt") = 0xFFFFFFFF)
			return

		if count {
			deviceList := Buffer(count * entrySize, 0)

			count := DllCall("GetRawInputDeviceList", "Ptr", deviceList, "UInt*", &count
													, "UInt", entrySize, "UInt")

			if (count = 0xFFFFFFFF)
				return

			loop count {
				handle := NumGet(deviceList, (A_Index - 1) * entrySize, "Ptr")
				deviceType := NumGet(deviceList, (A_Index - 1) * entrySize + A_PtrSize, "UInt")

				if (deviceType != HIDControllers.kRIMTypeHID)
					continue

				device := HIDControllers.createDevice(handle, known)

				if device
					devices.Push(device)
			}
		}

		loop (devices.Length - 1) {
			index := A_Index + 1
			device := devices[index]

			while (index > 1) {
				inner := devices[index - 1]

				if (StrCompare(inner.Path, device.Path) <= 0)
					break

				devices[index] := inner

				index -= 1
			}

			devices[index] := device
		}

		mutex := DllCall("CreateMutexW", "Ptr", 0, "Int", 0
									   , "Str", "Local\SimulatorControllerHIDNumbers", "Ptr")

		if !mutex
			throw "Cannot synchronize HID controller numbers..."

		try {
			waitResult := DllCall("WaitForSingleObject", "Ptr", mutex, "UInt", 5000, "UInt")

			if ((waitResult != 0) && (waitResult != 0x80))
				throw "Cannot acquire HID controller number lock..."

			try {
				assignments := readMultiMap(kUserConfigDirectory . "Controller Devices.ini")

				for number, path in getMultiMapValues(assignments, "Devices")
					if (RegExMatch(number, "^\d+$") && (number + 0 >= HIDControllers.FirstNumber)
													&& !paths.Has(path)) {
						paths[path] := number + 0
						nextNumber := Max(nextNumber, number + 1)
					}

				HIDControllers.sDevices := devices
				HIDControllers.sByNumber := Map()
				HIDControllers.sByHandle := Map()

				for index, device in devices {
					if paths.Has(device.Path) {
						device.Number := paths[device.Path]
						device.ID := paths[device.Path]
					}
					else {
						device.Number := nextNumber++
						device.ID := device.Number
						paths[device.Path] := device.Number
						setMultiMapValue(assignments, "Devices", device.Number, device.Path)
						changed := true
					}

					HIDControllers.sByNumber[device.Number] := device
					HIDControllers.sByHandle[device.Handle] := device
				}

				if changed
					writeMultiMap(kUserConfigDirectory . "Controller Devices.ini", assignments)
			}
			finally
				DllCall("ReleaseMutex", "Ptr", mutex)
		}
		finally
			DllCall("CloseHandle", "Ptr", mutex)
	}

	static createDevice(handle, known) {
		local size := 32
		local info := Buffer(32, 0)
		local usagePage, usage, path, preparsed, device

		NumPut("UInt", 32, info, 0)

		if (DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDControllers.kRIDIDeviceInfo
											, "Ptr", info, "UInt*", &size, "UInt") = 0xFFFFFFFF)
			return false

		if (NumGet(info, 4, "UInt") != HIDControllers.kRIMTypeHID)
			return false

		usagePage := NumGet(info, 20, "UShort")
		usage := NumGet(info, 22, "UShort")

		if ((usagePage != 0x01) || ((usage != 0x04) && (usage != 0x05) && (usage != 0x08)))
			return false

		path := HIDControllers.getDevicePath(handle)

		if (path = "")
			return false

		if known.Has(path) {
			device := known[path]

			device.Handle := handle

			return device
		}

		preparsed := HIDControllers.getPreparsedData(handle)

		if !preparsed
			return false

		return {Handle: handle, Path: path, Number: 0, ID: 0, State: Map()
			  , Name: HIDControllers.getProductName(path), Preparsed: preparsed
			  , Buttons: HIDControllers.getButtonRange(preparsed)
			  , MaxUsages: DllCall("Hid\HidP_MaxUsageListLength", "Int", HIDControllers.kHIDPInput
															    , "UShort", HIDControllers.kButtonUsagePage
															    , "Ptr", preparsed, "UInt")}
	}

	static getDevicePath(handle) {
		local size := 0
		local pathData

		DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDControllers.kRIDIDeviceName
										, "Ptr", 0, "UInt*", &size, "UInt")

		if !size
			return ""

		pathData := Buffer((size + 1) * 2, 0)

		if (DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDControllers.kRIDIDeviceName
											, "Ptr", pathData, "UInt*", &size, "UInt") = 0xFFFFFFFF)
			return ""

		return StrGet(pathData, "UTF-16")
	}

	static getPreparsedData(handle) {
		local size := 0
		local preparsedData

		DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDControllers.kRIDIPreparsedData
										, "Ptr", 0, "UInt*", &size, "UInt")

		if !size
			return false

		preparsedData := Buffer(size, 0)

		if (DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDControllers.kRIDIPreparsedData
											, "Ptr", preparsedData, "UInt*", &size, "UInt") = 0xFFFFFFFF)
			return false

		return preparsedData
	}

	static getProductName(path) {
		local name := ""
		local productData := Buffer(512, 0)
		local file := DllCall("CreateFileW", "Str", path, "UInt", 0, "UInt", 3
										   , "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")

		if (file != -1) {
			if DllCall("Hid\HidD_GetProductString", "Ptr", file, "Ptr", productData, "UInt", 512, "Int")
				name := Trim(StrGet(productData, "UTF-16"))

			DllCall("CloseHandle", "Ptr", file)
		}

		return ((name != "") ? name : path)
	}

	static getButtonRange(preparsed) {
		local caps := Buffer(64, 0)
		local buttons := 0
		local capsCount, buttonCaps, length, offset

		static kButtonCapsSize := 72

		if (DllCall("Hid\HidP_GetCaps", "Ptr", preparsed
									  , "Ptr", caps, "Int") != HIDControllers.kHIDPStatusSuccess)
			return 0

		capsCount := NumGet(caps, 46, "UShort")

		if !capsCount
			return 0

		buttonCaps := Buffer(capsCount * kButtonCapsSize, 0)
		length := capsCount

		if (DllCall("Hid\HidP_GetButtonCaps", "Int", HIDControllers.kHIDPInput, "Ptr", buttonCaps
										    , "UShort*", &length
											, "Ptr", preparsed, "Int") != HIDControllers.kHIDPStatusSuccess)
			return 0

		loop length {
			offset := ((A_Index - 1) * kButtonCapsSize)

			if (NumGet(buttonCaps, offset, "UShort") != HIDControllers.kButtonUsagePage)
				continue

			if NumGet(buttonCaps, offset + 12, "UChar")		; IsRange
				buttons := Max(buttons, NumGet(buttonCaps, offset + 58, "UShort"))
			else
				buttons := Max(buttons, NumGet(buttonCaps, offset + 56, "UShort"))
		}

		return buttons
	}

	static handleInput(wParam, lParam, message, hwnd) {
		local headerSize := (A_PtrSize = 8) ? 24 : 16
		local size := 0
		local inputData, handle, device, reportSize, reportCount

		if (DllCall("GetRawInputData", "Ptr", lParam, "UInt", HIDControllers.kRIDInput, "Ptr", 0
									 , "UInt*", &size, "UInt", headerSize, "UInt") = 0xFFFFFFFF)
			return

		if !size
			return

		inputData := Buffer(size, 0)

		if (DllCall("GetRawInputData", "Ptr", lParam, "UInt", HIDControllers.kRIDInput, "Ptr", inputData
									 , "UInt*", &size, "UInt", headerSize, "UInt") = 0xFFFFFFFF)
			return

		if (NumGet(inputData, 0, "UInt") != HIDControllers.kRIMTypeHID)
			return

		handle := NumGet(inputData, 8, "Ptr")

		if !HIDControllers.sByHandle.Has(handle) {
			if ((A_TickCount - HIDControllers.sLastRefresh) < 2000)
				return

			HIDControllers.refresh()

			if !HIDControllers.sByHandle.Has(handle)
				return
		}

		device := HIDControllers.sByHandle[handle]
		reportSize := NumGet(inputData, headerSize, "UInt")
		reportCount := NumGet(inputData, headerSize + 4, "UInt")

		if !reportSize
			return

		loop reportCount
			HIDControllers.updateState(device
									 , inputData.Ptr + headerSize + 8 + ((A_Index - 1) * reportSize)
									 , reportSize)
	}

	static updateState(device, report, reportSize) {
		local length := device.MaxUsages
		local state := Map()
		local usages, button, ignore

		if (length <= 0)
			return

		usages := Buffer(length * 2, 0)

		if (DllCall("Hid\HidP_GetUsages", "Int", HIDControllers.kHIDPInput
										, "UShort", HIDControllers.kButtonUsagePage
										, "UShort", 0, "Ptr", usages, "UInt*", &length
										, "Ptr", device.Preparsed, "Ptr", report
										, "UInt", reportSize, "Int") != HIDControllers.kHIDPStatusSuccess)
			return

		loop length {
			button := NumGet(usages, (A_Index - 1) * 2, "UShort")

			if button
				state[button] := true
		}

		for button, ignore in state
			if !device.State.Has(button)
				HIDControllers.fireHotkey(device.ID, button)

		device.State := state
	}

	static fireHotkey(id, button) {
		local key := ("HID" . id "#" . button) ; (number . "Joy" . button)
		local descriptor

		if HIDControllers.sHotkeys.Has(key) {
			descriptor := HIDControllers.sHotkeys[key]

			if (descriptor.Enabled && descriptor.Callback)
				try {
					descriptor.Callback.Call(key)
				}
				catch Any as exception {
					logError(exception, false, false)
				}
		}
	}

	static updateControllers(refresh := false) {
		if refresh
			HIDControllers.refresh()

		HIDControllers.listen()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Classes Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

class Hotkeys {
	static registerHotkey(theHotkey, function?, state?) {
		if (InStr(theHotkey, "HID") == 1)
			return HIDControllers.setHotkey(theHotkey, function?, state?)
		else
			return Hotkey(theHotkey, function?, state?)
	}

	static unregisterHotkey(theHotkey) {
		if (InStr(theHotkey, "HID") == 1)
			return HIDControllers.setHotkey(theHotkey, "Off")
		else
			Hotkey(theHotkey, "Off")
	}

	static pressed(theHotkey) {
		local trigger := HIDControllers.parseHotkey(theHotkey)

		if trigger {
			HIDControllers.listen()

			return HIDControllers.getButtonState(trigger.Device, trigger.Button)
		}
		else
			return GetKeyState(theHotkey, "P")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Functions Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

triggerDetector(callback := false, options := ["Button", "Key"]) {
	static detectorTask := false

	if (callback = "Active")
		return (detectorTask && !detectorTask.Stopped)
	else {
		if (detectorTask && detectorTask.Stopped)
			detectorTask := false

		if detectorTask {
			detectorTask.stop()

			detectorTask := false
		}
		else if (callback != "Stop") {
			detectorTask := TriggerDetectorTask(callback, options, 100)

			detectorTask.start()
		}
	}
}