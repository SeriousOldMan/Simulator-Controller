;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\MultiMap.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Classes Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

class JoystickRegistry {
	static assign(configuration, identities) {
		local numbers := Map()
		local nextNumber := 17
		local identity, number

		for identity, number in getMultiMapValues(configuration, "Controllers") {
			if (!RegExMatch(identity, "i)^\{[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\}$")
			 || !RegExMatch(number, "^\d+$") || (number < 17) || numbers.Has(number + 0))
				throw Error("Invalid extended joystick registry")

			numbers[number + 0] := identity
			nextNumber := Max(nextNumber, number + 1)
		}

		for identity in identities
			if !getMultiMapValue(configuration, "Controllers", identity, false)
				setMultiMapValue(configuration, "Controllers", identity, nextNumber++)

		return configuration
	}

	static update(path, devices) {
		local lock := false
		local configuration, identities := [], device, before, temporary := path . "." . ProcessExist() . ".tmp"
		local directory, file, text

		SplitPath(path, , &directory)
		DirCreate(directory)

		loop 100 {
			try lock := FileOpen(path . ".lock", "a-rwd")
			if lock
				break
			Sleep(10)
		}

		if !lock
			throw Error("Extended joystick registry is locked")

		try {
			configuration := FileExist(path) ? parseMultiMap(FileRead(path)) : newMultiMap()
			if (FileExist(path) && (!configuration.Has("Controllers") || (configuration.Count != 1)
								 || (getMultiMapValues(configuration, "Controllers").Count = 0)))
				throw Error("Invalid extended joystick registry")

			before := printMultiMap(configuration)

			for device in devices
				if (!device.Legacy || getMultiMapValue(configuration, "Controllers", device.Identity, false))
					identities.Push(device.Identity)

			this.assign(configuration, identities)

			if (before != printMultiMap(configuration)) {
				file := FileOpen(temporary, "w", "UTF-16")
				if !file
					throw Error("Cannot write extended joystick registry")
				try {
					text := printMultiMap(configuration)
					if (file.Write(text) != StrLen(text) * 2)
						throw Error("Incomplete extended joystick registry write")
					if !DllCall("FlushFileBuffers", "Ptr", file.Handle)
						throw OSError()
				}
				finally file.Close()

				if !DllCall("MoveFileExW", "Str", temporary, "Str", path, "UInt", 9)
					throw OSError()
			}

			return configuration
		}
		finally {
			try {
				if FileExist(temporary)
					FileDelete(temporary)
			}
			finally lock.Close()
		}
	}
}

class ExtendedJoystickDevice {
	iPointer := 0
	State := Buffer(128, 0)
	Available := false
	Legacy := false
	Buttons := 128

	__New(input, descriptor) {
		local pointer := 0
		local property := Buffer(20, 0)
		local capabilities := Buffer(44, 0)
		local stride := (A_PtrSize = 8) ? 24 : 16
		local objects := Buffer(stride * 128, 0)
		local format := Buffer((A_PtrSize = 8) ? 32 : 24, 0)
		local buttonGuid := Buffer(16)

		this.Identity := descriptor.Identity
		this.Name := descriptor.Name
		ComCall(3, input, "Ptr", descriptor.Guid, "Ptr*", &pointer, "Ptr", 0)
		this.iPointer := pointer

		NumPut("UInt", 20, "UInt", 16, property)
		if (ComCall(5, pointer, "Ptr", 15, "Ptr", property, "Int") >= 0)
			this.Legacy := (NumGet(property, 16, "UInt") < 16)

		NumPut("UInt", 44, capabilities)
		ComCall(3, pointer, "Ptr", capabilities)
		this.Buttons := Min(128, NumGet(capabilities, 16, "UInt"))

		DllCall("ole32\CLSIDFromString", "WStr", "{A36D02F0-C9F3-11CF-BFC7-444553540000}", "Ptr", buttonGuid)
		loop 128 {
			NumPut("Ptr", buttonGuid.Ptr, "UInt", A_Index - 1
				 , "UInt", 0x8000000C | ((A_Index - 1) << 8), "UInt", 0, objects, (A_Index - 1) * stride)
		}
		NumPut("UInt", format.Size, "UInt", stride, "UInt", 2, "UInt", 128, "UInt", 128, format)
		NumPut("Ptr", objects.Ptr, format, (A_PtrSize = 8) ? 24 : 20)
		ComCall(11, pointer, "Ptr", format)
		ComCall(13, pointer, "Ptr", A_ScriptHwnd, "UInt", 10)
	}

	__Delete() {
		if this.iPointer {
			ComCall(8, this.iPointer, "Int")
			ObjRelease(this.iPointer)
		}
	}

	poll() {
		local pointer := this.iPointer

		this.Available := false
		DllCall("RtlZeroMemory", "Ptr", this.State, "UPtr", this.State.Size)

		if (ComCall(7, pointer, "Int") < 0)
			return

		ComCall(25, pointer, "Int")
		this.Available := (ComCall(9, pointer, "UInt", 128, "Ptr", this.State, "Int") >= 0)
	}

	pressed(button) {
		return (this.Available && (button >= 1) && (button <= this.Buttons)
			 && ((NumGet(this.State, button - 1, "UChar") & 0x80) != 0))
	}
}

class ExtendedJoysticks {
	static iInstance := false
	iInput := 0
	iDevices := Map()
	iDescriptors := []
	iHotkeys := Map()
	iRefresh := -2000
	iPoll := -20
	iPolling := false

	static instance() {
		if !this.iInstance
			this.iInstance := this()

		return this.iInstance
	}

	__New() {
		local iid := Buffer(16)
		local input := 0

		DllCall("ole32\CLSIDFromString", "WStr", "{BF798031-483A-4DA2-AA99-5D64ED369700}", "Ptr", iid)
		if (DllCall("dinput8\DirectInput8Create", "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
				  , "UInt", 0x800, "Ptr", iid, "Ptr*", &input, "Ptr", 0, "Int") < 0)
			throw Error("Cannot initialize DirectInput controllers")

		this.iInput := input
	}

	__Delete() {
		this.iDevices.Clear()
		if this.iInput
			ObjRelease(this.iInput)
	}

	enumerate(instance, context) {
		local guid := Buffer(16)
		local identity := Buffer(78)

		DllCall("RtlMoveMemory", "Ptr", guid, "Ptr", instance + 4, "UPtr", 16)
		DllCall("ole32\StringFromGUID2", "Ptr", guid, "Ptr", identity, "Int", 39)
		this.iDescriptors.Push({Guid: guid, Identity: StrGet(identity), Name: StrGet(instance + 40, 260)})

		return 1
	}

	refresh() {
		local callback, descriptors := [], devices := Map(), descriptor, device, configuration, number

		this.iRefresh := A_TickCount
		this.iDescriptors := []
		callback := CallbackCreate(ObjBindMethod(this, "enumerate"), , 2)
		try ComCall(4, this.iInput, "UInt", 4, "Ptr", callback, "Ptr", 0, "UInt", 1)
		finally CallbackFree(callback)

		for descriptor in this.iDescriptors {
			try {
				device := ExtendedJoystickDevice(this.iInput, descriptor)
				descriptors.Push(device)
			}
			catch Any as exception
				logError(exception, false, false)
		}

		configuration := JoystickRegistry.update(kUserConfigDirectory . "Joystick Devices.ini", descriptors)
		for device in descriptors {
			number := getMultiMapValue(configuration, "Controllers", device.Identity, false)
			if number
				devices[number + 0] := device
		}

		this.iDevices := devices
	}

	poll() {
		local number, device

		if this.iPolling
			return

		this.iPolling := true
		try {
			if ((A_TickCount - this.iRefresh) >= 2000) {
				try this.refresh()
				catch Any as exception {
					this.iDevices.Clear()
					logError(exception, false, false)
				}
			}

			if ((A_TickCount - this.iPoll) >= 10) {
				this.iPoll := A_TickCount
				for number, device in this.iDevices
					device.poll()
			}
		}
		finally this.iPolling := false
	}

	state(number, control) {
		this.poll()
		if !this.iDevices.Has(number)
			return (control = "Name") ? "" : 0

		device := this.iDevices[number]
		switch control, false {
			case "Name": return device.Name
			case "Buttons": return device.Buttons
			case "Info": return ""
			default: return IsInteger(control) ? device.pressed(control + 0) : 0
		}
	}

	hotkey(key, action, options := "") {
		local match, enabled

		if !RegExMatch(key, "i)^(\d+)Joy(\d+)$", &match) || (match[2] < 1) || (match[2] > 128)
			throw ValueError("Invalid extended joystick hotkey", , key)

		key := (match[1] + 0) . "Joy" . (match[2] + 0)
		if IsObject(action) {
			enabled := !InStr(options, "Off")
			this.iHotkeys[key] := {Callback: action, Enabled: enabled, Down: false, Number: match[1] + 0, Button: match[2] + 0}
		}
		else {
			if !this.iHotkeys.Has(key)
				throw ValueError("Extended joystick hotkey not registered", , key)
			switch action, false {
				case "On": this.iHotkeys[key].Enabled := true
				case "Off": this.iHotkeys[key].Enabled := false
				case "Toggle": this.iHotkeys[key].Enabled := !this.iHotkeys[key].Enabled
				default: throw ValueError("Unsupported extended joystick hotkey action", , action)
			}
		}

		if !this.HasOwnProp("Timer") {
			this.Timer := ObjBindMethod(this, "dispatch")
			SetTimer(this.Timer, 10)
		}
	}

	dispatch() {
		local key, binding, down, pending := []

		this.poll()
		for key, binding in this.iHotkeys {
			down := this.iDevices.Has(binding.Number) && this.iDevices[binding.Number].pressed(binding.Button)
			if (down && !binding.Down && binding.Enabled)
				pending.Push({Callback: binding.Callback, Key: key})
			binding.Down := down
		}

		for binding in pending
			SetTimer(binding.Callback.Bind(binding.Key), -1)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Functions Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getJoystickState(key, mode := "") {
	local match

	if (RegExMatch(key, "i)^(\d+)Joy(\d+|Name|Buttons|Info|X|Y|Z|R|U|V|POV)$", &match) && (match[1] > 16))
		return ExtendedJoysticks.instance().state(match[1] + 0, match[2])

	return GetKeyState(key, mode)
}

setControllerHotkey(key, action, options := "") {
	local match

	if (RegExMatch(key, "i)^(\d+)Joy", &match) && (match[1] > 16))
		return ExtendedJoysticks.instance().hotkey(key, action, options)

	return Hotkey(key, action, options)
}

getControllerNumbers() {
	local numbers := [], number, device
	local controllers

	loop 16
		if GetKeyState(A_Index . "JoyName")
			numbers.Push(A_Index)

	try {
		controllers := ExtendedJoysticks.instance()
		controllers.poll()
		for number, device in controllers.iDevices
			numbers.Push(number)
	}
	catch Any as exception
		logError(exception, false, false)

	return numbers
}