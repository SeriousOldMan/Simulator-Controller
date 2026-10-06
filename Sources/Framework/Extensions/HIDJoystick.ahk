;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Extended Joystick Support       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kMaxLegacyJoysticks := 16


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;-------------------------------------------------------------------------;;;
;;; HIDJoystick                                                             ;;;
;;;                                                                         ;;;
;;; The legacy multimedia joystick API of Windows, which is used by the      ;;;
;;; builtin joystick support of AutoHotkey, can only address a maximum of    ;;;
;;; 16 game controllers. Everything beyond that is invisible for             ;;;
;;; *GetKeyState* and for joystick hotkeys. This class provides an           ;;;
;;; alternative, Raw Input (HID) based implementation, which enumerates all  ;;;
;;; connected game controllers and reports their button state. The devices   ;;;
;;; are numbered starting with 17, so that the numbers of all already        ;;;
;;; configured triggers (1 - 16) stay valid.                                 ;;;
;;;-------------------------------------------------------------------------;;;

class HIDJoystick {
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

	static Joysticks {
		Get {
			local result := []
			local ignore, device

			HIDJoystick.startup()

			for ignore, device in HIDJoystick.sDevices
				result.Push(device.Number)

			return result
		}
	}

	static FirstNumber {
		Get {
			return (kMaxLegacyJoysticks + 1)
		}
	}

	static parseHotkey(theHotkey := "") {
		local descriptor

		if (isObject(theHotkey) || !(theHotkey is String))
			return false

		if RegExMatch(theHotkey, "i)^[~$*]*(\d+)Joy(\d+)$", &descriptor)
			if (descriptor[1] + 0 > kMaxLegacyJoysticks)
				return {Number: descriptor[1] + 0, Button: descriptor[2] + 0
					  , Key: (descriptor[1] + 0) . "Joy" . (descriptor[2] + 0)}

		return false
	}

	static setHotkey(arguments*) {
		local trigger := HIDJoystick.parseHotkey(arguments.Has(1) ? arguments[1] : "")
		local callback := false
		local options := ""
		local descriptor, argument

		if !trigger
			throw "Unsupported joystick hotkey in HIDJoystick.setHotkey..."

		if (arguments.Length > 1) {
			argument := arguments[2]

			if (argument is String)
				options := argument
			else if argument
				callback := argument
		}

		if (arguments.Length > 2)
			options := arguments[3]

		HIDJoystick.listen()

		if HIDJoystick.sHotkeys.Has(trigger.Key)
			descriptor := HIDJoystick.sHotkeys[trigger.Key]
		else {
			descriptor := {Callback: false, Enabled: true}

			HIDJoystick.sHotkeys[trigger.Key] := descriptor
		}

		if callback
			descriptor.Callback := callback

		if InStr(options, "Toggle")
			descriptor.Enabled := !descriptor.Enabled
		else if InStr(options, "Off")
			descriptor.Enabled := false
		else if InStr(options, "On")
			descriptor.Enabled := true
	}

	static getName(number) {
		HIDJoystick.startup()

		return (HIDJoystick.sByNumber.Has(number) ? HIDJoystick.sByNumber[number].Name : "")
	}

	static getButtonCount(number) {
		HIDJoystick.startup()

		return (HIDJoystick.sByNumber.Has(number) ? HIDJoystick.sByNumber[number].Buttons : 0)
	}

	static getButtonState(number, button) {
		HIDJoystick.startup()

		return (HIDJoystick.sByNumber.Has(number) ? HIDJoystick.sByNumber[number].State.Has(button) : false)
	}

	static startup() {
		if !HIDJoystick.sEnumerated
			HIDJoystick.refresh()
	}

	static listen() {
		local size := (A_PtrSize = 8) ? 16 : 12
		local devices := Buffer(3 * size, 0)
		local index, usage, offset

		HIDJoystick.startup()

		if HIDJoystick.sListening
			return true

		for index, usage in [0x04, 0x05, 0x08] {
			offset := ((index - 1) * size)

			NumPut("UShort", 0x01, devices, offset)
			NumPut("UShort", usage, devices, offset + 2)
			NumPut("UInt", HIDJoystick.kRIDEVInputSink | HIDJoystick.kRIDEVDeviceNotify, devices, offset + 4)
			NumPut("Ptr", A_ScriptHwnd, devices, offset + 8)
		}

		if DllCall("RegisterRawInputDevices", "Ptr", devices, "UInt", 3, "UInt", size, "Int") {
			OnMessage(HIDJoystick.kWMInput, ObjBindMethod(HIDJoystick, "handleInput"))
			OnMessage(HIDJoystick.kWMInputDeviceChange, ObjBindMethod(HIDJoystick, "handleDeviceChange"))

			HIDJoystick.sListening := true
		}

		return HIDJoystick.sListening
	}

	static handleDeviceChange(wParam, lParam, message, hwnd) {
		local device

		if (wParam = HIDJoystick.kGIDCRemoval) {
			if HIDJoystick.sByHandle.Has(lParam) {
				device := HIDJoystick.sByHandle[lParam]

				device.State := Map()
			}
		}

		HIDJoystick.refresh()
	}

	static refresh() {
		local entrySize := (A_PtrSize = 8) ? 16 : 8
		local known := Map()
		local devices := []
		local count := 0
		local deviceList, handle, deviceType, device, ignore, index, inner
		local assignments, paths := Map(), number, path, nextNumber := HIDJoystick.FirstNumber
		local changed := false, mutex, waitResult

		HIDJoystick.sEnumerated := true
		HIDJoystick.sLastRefresh := A_TickCount

		for ignore, device in HIDJoystick.sDevices
			known[device.Path] := device

		if (DllCall("GetRawInputDeviceList", "Ptr", 0, "UInt*", &count, "UInt", entrySize, "UInt") = 0xFFFFFFFF)
			return

		if count {
			deviceList := Buffer(count * entrySize, 0)

			count := DllCall("GetRawInputDeviceList", "Ptr", deviceList, "UInt*", &count, "UInt", entrySize, "UInt")

			if (count = 0xFFFFFFFF)
				return

			loop count {
				handle := NumGet(deviceList, (A_Index - 1) * entrySize, "Ptr")
				deviceType := NumGet(deviceList, (A_Index - 1) * entrySize + A_PtrSize, "UInt")

				if (deviceType != HIDJoystick.kRIMTypeHID)
					continue

				device := HIDJoystick.createDevice(handle, known)

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
			throw "Cannot synchronize HID joystick numbers..."

		try {
			waitResult := DllCall("WaitForSingleObject", "Ptr", mutex, "UInt", 5000, "UInt")

			if ((waitResult != 0) && (waitResult != 0x80))
				throw "Cannot acquire HID joystick number lock..."

			try {
				assignments := readMultiMap(kUserConfigDirectory . "HID Joysticks.ini")

				for number, path in getMultiMapValues(assignments, "Devices")
					if (RegExMatch(number, "^\d+$") && (number + 0 >= HIDJoystick.FirstNumber) && !paths.Has(path)) {
						paths[path] := number + 0
						nextNumber := Max(nextNumber, number + 1)
					}

				HIDJoystick.sDevices := devices
				HIDJoystick.sByNumber := Map()
				HIDJoystick.sByHandle := Map()

				for index, device in devices {
					if paths.Has(device.Path)
						device.Number := paths[device.Path]
					else {
						device.Number := nextNumber++
						paths[device.Path] := device.Number
						setMultiMapValue(assignments, "Devices", device.Number, device.Path)
						changed := true
					}

					HIDJoystick.sByNumber[device.Number] := device
					HIDJoystick.sByHandle[device.Handle] := device
				}

				if changed
					writeMultiMap(kUserConfigDirectory . "HID Joysticks.ini", assignments)
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

		if (DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDJoystick.kRIDIDeviceInfo
											, "Ptr", info, "UInt*", &size, "UInt") = 0xFFFFFFFF)
			return false

		if (NumGet(info, 4, "UInt") != HIDJoystick.kRIMTypeHID)
			return false

		usagePage := NumGet(info, 20, "UShort")
		usage := NumGet(info, 22, "UShort")

		if ((usagePage != 0x01) || ((usage != 0x04) && (usage != 0x05) && (usage != 0x08)))
			return false

		path := HIDJoystick.getDevicePath(handle)

		if (path = "")
			return false

		if known.Has(path) {
			device := known[path]

			device.Handle := handle

			return device
		}

		preparsed := HIDJoystick.getPreparsedData(handle)

		if !preparsed
			return false

		return {Handle: handle, Path: path, Number: 0, State: Map()
			  , Name: HIDJoystick.getProductName(path)
			  , Preparsed: preparsed
			  , Buttons: HIDJoystick.getButtonRange(preparsed)
			  , MaxUsages: DllCall("Hid\HidP_MaxUsageListLength", "Int", HIDJoystick.kHIDPInput
															   , "UShort", HIDJoystick.kButtonUsagePage
															   , "Ptr", preparsed, "UInt")}
	}

	static getDevicePath(handle) {
		local size := 0
		local pathData

		DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDJoystick.kRIDIDeviceName
										, "Ptr", 0, "UInt*", &size, "UInt")

		if !size
			return ""

		pathData := Buffer((size + 1) * 2, 0)

		if (DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDJoystick.kRIDIDeviceName
											, "Ptr", pathData, "UInt*", &size, "UInt") = 0xFFFFFFFF)
			return ""

		return StrGet(pathData, "UTF-16")
	}

	static getPreparsedData(handle) {
		local size := 0
		local preparsedData

		DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDJoystick.kRIDIPreparsedData
										, "Ptr", 0, "UInt*", &size, "UInt")

		if !size
			return false

		preparsedData := Buffer(size, 0)

		if (DllCall("GetRawInputDeviceInfoW", "Ptr", handle, "UInt", HIDJoystick.kRIDIPreparsedData
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

		if (DllCall("Hid\HidP_GetCaps", "Ptr", preparsed, "Ptr", caps, "Int") != HIDJoystick.kHIDPStatusSuccess)
			return 0

		capsCount := NumGet(caps, 46, "UShort")

		if !capsCount
			return 0

		buttonCaps := Buffer(capsCount * kButtonCapsSize, 0)
		length := capsCount

		if (DllCall("Hid\HidP_GetButtonCaps", "Int", HIDJoystick.kHIDPInput, "Ptr", buttonCaps
										    , "UShort*", &length, "Ptr", preparsed, "Int") != HIDJoystick.kHIDPStatusSuccess)
			return 0

		loop length {
			offset := ((A_Index - 1) * kButtonCapsSize)

			if (NumGet(buttonCaps, offset, "UShort") != HIDJoystick.kButtonUsagePage)
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

		if (DllCall("GetRawInputData", "Ptr", lParam, "UInt", HIDJoystick.kRIDInput, "Ptr", 0
									 , "UInt*", &size, "UInt", headerSize, "UInt") = 0xFFFFFFFF)
			return

		if !size
			return

		inputData := Buffer(size, 0)

		if (DllCall("GetRawInputData", "Ptr", lParam, "UInt", HIDJoystick.kRIDInput, "Ptr", inputData
									 , "UInt*", &size, "UInt", headerSize, "UInt") = 0xFFFFFFFF)
			return

		if (NumGet(inputData, 0, "UInt") != HIDJoystick.kRIMTypeHID)
			return

		handle := NumGet(inputData, 8, "Ptr")

		if !HIDJoystick.sByHandle.Has(handle) {
			if ((A_TickCount - HIDJoystick.sLastRefresh) < 2000)
				return

			HIDJoystick.refresh()

			if !HIDJoystick.sByHandle.Has(handle)
				return
		}

		device := HIDJoystick.sByHandle[handle]
		reportSize := NumGet(inputData, headerSize, "UInt")
		reportCount := NumGet(inputData, headerSize + 4, "UInt")

		if !reportSize
			return

		loop reportCount
			HIDJoystick.updateState(device, inputData.Ptr + headerSize + 8 + ((A_Index - 1) * reportSize), reportSize)
	}

	static updateState(device, report, reportSize) {
		local length := device.MaxUsages
		local state := Map()
		local usages, button, ignore

		if (length <= 0)
			return

		usages := Buffer(length * 2, 0)

		if (DllCall("Hid\HidP_GetUsages", "Int", HIDJoystick.kHIDPInput, "UShort", HIDJoystick.kButtonUsagePage
										, "UShort", 0, "Ptr", usages, "UInt*", &length, "Ptr", device.Preparsed
										, "Ptr", report, "UInt", reportSize, "Int") != HIDJoystick.kHIDPStatusSuccess)
			return

		loop length {
			button := NumGet(usages, (A_Index - 1) * 2, "UShort")

			if button
				state[button] := true
		}

		for button, ignore in state
			if !device.State.Has(button)
				HIDJoystick.fireHotkey(device.Number, button)

		device.State := state
	}

	static fireHotkey(number, button) {
		local key := (number . "Joy" . button)
		local descriptor

		if HIDJoystick.sHotkeys.Has(key) {
			descriptor := HIDJoystick.sHotkeys[key]

			if (descriptor.Enabled && descriptor.Callback)
				try {
					descriptor.Callback.Call(key)
				}
				catch Any as exception {
					logError(exception, false, false)
				}
		}
	}
}
