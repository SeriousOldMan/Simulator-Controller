;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - WebView2 Control                ;;;
;;;                                                                         ;;;
;;;   Based on the great work of the AutoHotkey wizard thqby.               ;;;
;;;   See https://www.autohotkey.com/boards/viewtopic.php?t=95666 for       ;;;
;;;   more information and the download of the original WebView2.ahk.       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"
#Include "..\Framework\Gui.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kExplorerVersions := CaseInsenseMap("Simulator Setup", 10)

kExplorerVersions.Default := 11


;;;-------------------------------------------------------------------------;;;
;;;                         Private Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class ComVariable {
	Ptr => this.var.Ptr
	Size => this.var.Size

	Type {
		Get => NumGet(this.var, "ushort")

		Set {
			if !this.IsVariant
				throw PropertyError("VarType is not VT_VARIANT, Type is read-only.", -2)

			NumPut("ushort", Value, this.var)
		}
	}

	IsVariant => ComObjType(this.ref) & 0xC

	__New(vVal := unset, vType := 0xC, convert := false) {
		/**
		 * Construction VARIANT struct, `ptr` property points to the address, `__Item` property returns var's Value
		 * @param vVal Values that need to be wrapped, supports String, Integer, Double, Array, ComValue, ComObjArray
		 * ### example
		 * `var1 := ComVariable('string'), MsgBox(var1[])`
		 *
		 * `var2 := ComVariable([1,2,3,4], , true)`
		 *
		 * `var3 := ComVariable(ComValue(0xb, -1))`
		 * @param vType Variant's type, VT_VARIANT(default)
		 * @param convert Convert AHK's array to ComObjArray
		 */

		static size := 8 + 2 * A_PtrSize

		this.var := Buffer(size, 0)
		this.owner := true
		this.ref := ComValue(0x4000 | vType, this.var.Ptr + (vType = 0xC ? 0 : 8))

		if isSet(vVal)
			if (Type(vVal) == "ComVariable") {
				this.var := vVal.var
				this.ref := vVal.ref
				this.obj := vVal
				this.owner := false
			}
			else {
				if (isObject(vVal)) {
					if (vType != 0xC)
						this.ref := ComValue(0x400C, this.var.ptr)

					if convert && (vVal is Array) {
						switch Type(vVal[1]) {
							case "Integer":
								vType := 3
							case "String":
								vType := 8
							case "Float":
								vType := 5
							case "ComValue", "ComObject":
								vType := ComObjType(vVal[1])
							default:
								vType := 0xC
						}

						ComObjFlags(obj := ComObjArray(vType, vVal.Length), -1)

						i := 0

						this.ref[] := obj

						for v in vVal
							obj[i++] := v
					}
					else
						this.ref[] := vVal
				}
				else
					this.ref[] := vVal
			}
	}

	__Delete() => (this.owner ? DllCall("oleaut32\VariantClear", "ptr", this.var) : 0)

	__Item {
		Get => this.ref[]
		Set => this.ref[] := value
	}
}

class WebView2 extends WebView2.Base {
	static CAPTURE_PREVIEW_IMAGE_FORMAT := { PNG: 0, JPEG: 1 }
	static COOKIE_SAME_SITE_KIND := { NONE: 0, LAX: 1, STRICT: 2 }
	static HOST_RESOURCE_ACCESS_KIND := { DENY: 0, ALLOW: 1, DENY_CORS: 2 }
	static SCRIPT_DIALOG_KIND := { ALERT: 0, CONFIRM: 1, PROMPT: 2, BEFOREUNLOAD: 3 }
	static PROCESS_FAILED_KIND := {
		BROWSER_PROCESS_EXITED: 0,
		RENDER_PROCESS_EXITED: 1,
		RENDER_PROCESS_UNRESPONSIVE: 2,
		FRAME_RENDER_PROCESS_EXITED: 3,
		UTILITY_PROCESS_EXITED: 4,
		SANDBOX_HELPER_PROCESS_EXITED: 5,
		GPU_PROCESS_EXITED: 6,
		PPAPI_PLUGIN_PROCESS_EXITED: 7,
		PPAPI_BROKER_PROCESS_EXITED: 8,
		UNKNOWN_PROCESS_EXITED: 9
	}
	static PROCESS_FAILED_REASON := { UNEXPECTED: 0, UNRESPONSIVE: 1, TERMINATED: 2, CRASHED: 3, LAUNCH_FAILED: 4, OUT_OF_MEMORY: 5 }
	static PERMISSION_KIND := {
		UNKNOWN_PERMISSION: 0,
		MICROPHONE: 1,
		CAMERA: 2,
		GEOLOCATION: 3,
		NOTIFICATIONS: 4,
		OTHER_SENSORS: 5,
		CLIPBOARD_READ: 6
	}
	static PERMISSION_STATE := { DEFAULT: 0, ALLOW: 1, DENY: 2 }
	static WEB_ERROR_STATUS := {
		UNKNOWN: 0,
		CERTIFICATE_COMMON_NAME_IS_INCORRECT: 1,
		CERTIFICATE_EXPIRED: 2,
		CLIENT_CERTIFICATE_CONTAINS_ERRORS: 3,
		CERTIFICATE_REVOKED: 4,
		CERTIFICATE_IS_INVALID: 5,
		SERVER_UNREACHABLE: 6,
		TIMEOUT: 7,
		ERROR_HTTP_INVALID_SERVER_RESPONSE: 8,
		CONNECTION_ABORTED: 9,
		CONNECTION_RESET: 10,
		DISCONNECTED: 11,
		CANNOT_CONNECT: 12,
		HOST_NAME_NOT_RESOLVED: 13,
		OPERATION_CANCELED: 14,
		REDIRECT_FAILED: 15,
		UNEXPECTED_ERROR: 16
	}
	static WEB_RESOURCE_CONTEXT := {
		ALL: 0,
		DOCUMENT: 1,
		STYLESHEET: 2,
		IMAGE: 3,
		MEDIA: 4,
		FONT: 5,
		SCRIPT: 6,
		XML_HTTP_REQUEST: 7,
		FETCH: 8,
		TEXT_TRACK: 9,
		EVENT_SOURCE: 10,
		WEBSOCKET: 11,
		MANIFEST: 12,
		SIGNED_EXCHANGE: 13,
		PING: 14,
		CSP_VIOLATION_REPORT: 15,
		OTHER: 16
	}
	static MOVE_FOCUS_REASON := { PROGRAMMATIC: 0, NEXT: 1, PREVIOUS: 2 }
	static KEY_EVENT_KIND := { KEY_DOWN: 0, KEY_UP: 1, SYSTEM_KEY_DOWN: 2, SYSTEM_KEY_UP: 3 }
	static BROWSER_PROCESS_EXIT_KIND := { NORMAL: 0, FAILED: 1 }
	static MOUSE_EVENT_KIND := {
		HORIZONTAL_WHEEL: 0x20e,
		LEFT_BUTTON_DOUBLE_CLICK: 0x203,
		LEFT_BUTTON_DOWN: 0x201,
		LEFT_BUTTON_UP: 0x202,
		LEAVE: 0x2a3,
		MIDDLE_BUTTON_DOUBLE_CLICK: 0x209,
		MIDDLE_BUTTON_DOWN: 0x207,
		MIDDLE_BUTTON_UP: 0x208,
		MOVE: 0x200,
		RIGHT_BUTTON_DOUBLE_CLICK: 0x206,
		RIGHT_BUTTON_DOWN: 0x204,
		RIGHT_BUTTON_UP: 0x205,
		WHEEL: 0x20a,
		X_BUTTON_DOUBLE_CLICK: 0x20d,
		X_BUTTON_DOWN: 0x20b,
		X_BUTTON_UP: 0x20c
	}
	static MOUSE_EVENT_VIRTUAL_KEYS := {
		NONE: 0,
		LEFT_BUTTON: 0x1,
		RIGHT_BUTTON: 0x2,
		SHIFT: 0x4,
		CONTROL: 0x8,
		MIDDLE_BUTTON: 0x10,
		X_BUTTON1: 0x20,
		X_BUTTON2: 0x40
	}
	static POINTER_EVENT_KIND := {
		ACTIVATE: 0x24b,
		DOWN: 0x246,
		ENTER: 0x249,
		LEAVE: 0x24a,
		UP: 0x247,
		UPDATE: 0x245
	}
	static BOUNDS_MODE := { USE_RAW_PIXELS: 0, USE_RASTERIZATION_SCALE: 1 }
	static CLIENT_CERTIFICATE_KIND := { SMART_CARD: 0, PIN: 1, OTHER: 2 }
	static DOWNLOAD_STATE := { IN_PROGRESS: 0, INTERRUPTED: 1, COMPLETED: 2 }
	static DOWNLOAD_INTERRUPT_REASON := {
		NONE: 0,
		FILE_FAILED: 1,
		FILE_ACCESS_DENIED: 2,
		FILE_NO_SPACE: 3,
		FILE_NAME_TOO_LONG: 4,
		FILE_TOO_LARGE: 5,
		FILE_MALICIOUS: 6,
		FILE_TRANSIENT_ERROR: 7,
		FILE_BLOCKED_BY_POLICY: 8,
		FILE_SECURITY_CHECK_FAILED: 9,
		FILE_TOO_SHORT: 10,
		FILE_HASH_MISMATCH: 11,
		NETWORK_FAILED: 12,
		NETWORK_TIMEOUT: 13,
		NETWORK_DISCONNECTED: 14,
		NETWORK_SERVER_DOWN: 15,
		NETWORK_INVALID_REQUEST: 16,
		SERVER_FAILED: 17,
		SERVER_NO_RANGE: 18,
		SERVER_BAD_CONTENT: 19,
		SERVER_UNAUTHORIZED: 20,
		SERVER_CERTIFICATE_PROBLEM: 21,
		SERVER_FORBIDDEN: 22,
		SERVER_UNEXPECTED_RESPONSE: 23,
		SERVER_CONTENT_LENGTH_MISMATCH: 24,
		SERVER_CROSS_ORIGIN_REDIRECT: 25,
		USER_CANCELED: 26,
		USER_SHUTDOWN: 27,
		USER_PAUSED: 28,
		DOWNLOAD_PROCESS_CRASHED: 29
	}
	static PRINT_ORIENTATION := { PORTRAIT: 0, LANDSCAPE: 1 }
	static DEFAULT_DOWNLOAD_DIALOG_CORNER_ALIGNMENT := { TOP_LEFT: 0, TOP_RIGHT: 1, BOTTOM_LEFT: 2, BOTTOM_RIGHT: 3 }

	/**
	 * create Edge WebView2 control.
	 * @param hwnd the hwnd of Gui or Control.
	 * @param callback Wait for the WebView2 control to be created when the callback is unset; otherwise, don't wait and call the callback function after completion.
	 * @param createdEnvironment Create WebView2 controls from the created environment.
	 * @param datadir User data folder.
	 * @param edgeruntime The path of Edge Runtime or Edge(dev..) Bin.
	 * @param options The environment options of Edge. `{TargetCompatibleBrowserVersion?: string, AdditionalBrowserArguments?: string, AllowSingleSignOnUsingOSPrimaryAccount?: bool, Language?: string, ExclusiveUserDataFolderAccess?: bool}`
	 * @param dllPath The path of `WebView2Loader.dll`.
	 */
	static create(hwnd, callback := unset
				, createdEnvironment := 0, datadir := '', edgeruntime := '', options := 0
				, dllPath := (kBinariesDirectory . "Microsoft\WebView2Loader.dll")) {
		EnvironmentCompleted_Invoke(com_this, hresult, createdEnvironment) {
			if !createdEnvironment
				throw OSError(hresult)

			ComCall(3, createdEnvironment, 'ptr', hwnd, 'ptr', ControllerCompletedHandler)

			EnvironmentCompletedHandler := 0

			return 0
		}

		ControllerCompleted_Invoke(com_this, hresult, createdController) {
			if !createdController
				throw OSError(hresult)

			DllCall('user32\GetClientRect', 'ptr', hwnd, 'ptr', RECT := Buffer(16))

			ObjAddRef(createdController)

			Controller.ptr := createdController, Controller.Bounds := RECT

			if isSet(callback)
				try
					callback(Controller)

			ControllerCompletedHandler := 0

			return 0
		}

		Controller := WebView2.Controller()
		ControllerCompletedHandler := WebView2.Handler(ControllerCompleted_Invoke)

		if createdEnvironment
			ComCall(3, createdEnvironment, 'ptr', hwnd, 'ptr', ControllerCompletedHandler)
		else {
			if (!FileExist(dllPath) && FileExist(t := A_LineFile . '\..\' . (A_PtrSize * 8) . 'bit\WebView2Loader.dll'))
				dllPath := t

			if !edgeruntime {
				ver := '0.0.0.0'

				loop files 'C:\Program Files (x86)\Microsoft\EdgeWebView\Application\*', 'D'
					if (RegExMatch(A_LoopFilePath, '\\([\d.]+)$', &m) && VerCompare(m[1], ver) > 0)
						edgeruntime := A_LoopFileFullPath, ver := m[1]
			}

			EnvironmentCompletedHandler := WebView2.Handler(EnvironmentCompleted_Invoke)

			if options {
				if !options.HasProp('TargetCompatibleBrowserVersion')
					options.TargetCompatibleBrowserVersion := ver

				options := WebView2.EnvironmentOptions(options)
			}

			if (R := DllCall(dllPath . '\CreateCoreWebView2EnvironmentWithOptions', 'str', edgeruntime,
				'str', datadir || RegExReplace(A_AppData, 'Roaming$', 'Local\Microsoft\Edge\User Data'), 'ptr', options,
				'ptr', EnvironmentCompletedHandler, 'uint')) {
				ControllerCompletedHandler := EnvironmentCompletedHandler := 0

				throw OSError(R)
			}
		}

		if !isSet(callback)
			while (!Controller.ptr)
				Sleep(-1)

		return Controller
	}

	static AHKObjHelper() {
		get(this, prop, params := unset) {
			if !isSet(params) {
				if (this is Array && prop is Integer) || (this is Map)
					return this[prop]

				params := []
			}

			return this.%prop%[params*]
		}

		set(this, prop, value, params := unset) {
			if !isSet(params) {
				if (this is Array && prop is Integer) || (this is Map)
					return this[prop] := value

				params := []
			}

			return this.%prop%[params*] := value
		}

		call(this, method, params*) => this.%method%(params*)

		return { get: get, set: set, call: call }
	}

	class Base {
		ptr := 0

		__New(ptr := unset, addref := true) {
			if isSet(ptr) {
				this.ptr := ptr

				if addref
					ObjAddRef(ptr)
			}
		}

		__Delete() {
			if (this.ptr)
				this.Release()
		}

		__Call(Name, Params) {
			if (HasMethod(this, 'add_' Name)) {
				if (!isInteger(handler := Params[1]) && !(handler is WebView2.Handler))
					handler := WebView2.Handler(Params*)

				token := this.add_%Name%(handler)

				return { ptr: this.ptr, handler: handler, __Delete: this.remove_%Name%.Bind( , token) }
			}
			else
				throw Error('This value of type "' . this.__Class . '" has no method named "' . Name . '".', -1)
		}

		AddRef() => ObjAddRef(this.ptr)

		Release() => ObjRelease(this.ptr)
	}

	class AcceleratorKeyPressedEventArgs extends WebView2.Base {
		static IID := '{9f760f8a-fb79-42be-9990-7b56900fa9c7}'

		KeyEventKind => (ComCall(3, this, 'int*', &keyEventKind := 0), keyEventKind)

		VirtualKey => (ComCall(4, this, 'uint*', &virtualKey := 0), virtualKey)

		KeyEventLParam => (ComCall(5, this, 'int*', &lParam := 0), lParam)

		PhysicalKeyStatus => (ComCall(6, this, 'int*', &physicalKeyStatus := 0), physicalKeyStatus)

		Handled {
			Get => (ComCall(7, this, 'int*', &handled := 0), handled)

			Set => ComCall(8, this, 'int', Value)
		}
	}

	class BrowserProcessExitedEventArgs extends WebView2.Base {
		static IID := '{1f00663f-af8c-4782-9cdd-dd01c52e34cb}'

		BrowserProcessExitKind => (ComCall(3, this, 'int*', &browserProcessExitKind := 0), browserProcessExitKind)

		BrowserProcessId => (ComCall(4, this, 'uint*', &value := 0), value)
	}

	class CompositionController extends WebView2.Base {
		static IID := '{3df9b733-b9ae-4a15-86b4-eb9ee9826469}'
		static IID_2 := '{0b6a3d24-49cb-4806-ba20-b5e0734a7b26}'

		UIAProvider => (ComCall(11, this, 'ptr*', &provider := 0), ComValue(0xd, provider))

		RootVisualTarget {
			Get => (ComCall(3, this, 'ptr*', &target := 0), ComValue(0xd, target))

			Set => ComCall(4, this, 'ptr', Value)
		}

		Cursor => (ComCall(7, this, 'ptr*', &cursor := 0), cursor)

		SystemCursorId => (ComCall(8, this, 'uint*', &systemCursorId := 0), systemCursorId)

		SendMouseInput(eventKind, virtualKeys, mouseData, point) => ComCall(5, this, 'int', eventKind, 'int', virtualKeys, 'uint', mouseData, 'int64', point)

		SendPointerInput(eventKind, pointerInfo) => ComCall(6, this, 'int', eventKind, 'ptr', pointerInfo)

		add_CursorChanged(eventHandler) => (ComCall(9, this, 'ptr', eventHandler, 'int64*', &token := 0), token)

		remove_CursorChanged(token) => ComCall(10, this, 'int64', token)
	}

	class Controller extends WebView2.Base {
		static IID := '{4d00c0d1-9434-4eb6-8078-8697a560334f}'
		static IID_2 := '{c979903e-d4ca-4228-92eb-47ee3fa96eab}'
		static IID_3 := '{f9614724-5d2b-41dc-aef7-73d62b51543b}'

		CoreWebView2 => (ComCall(25, this, 'ptr*', coreWebView2 := WebView2.Core()), coreWebView2)

		DefaultBackgroundColor {
			Get => (ComCall(26, this, 'int*', &backgroundColor := 0), backgroundColor)

			Set => ComCall(27, this, 'int', Value)
		}

		RasterizationScale {
			Get => (ComCall(28, this, 'double*', &scale := 0), scale)

			Set => ComCall(29, this, 'double', Value)
		}

		ShouldDetectMonitorScaleChanges {
			Get => (ComCall(30, this, 'int*', &value := 0), value)

			Set => ComCall(31, this, 'int', Value)
		}

		BoundsMode {
			Get => (ComCall(34, this, 'int*', &boundsMode := 0), boundsMode)

			Set => ComCall(35, this, 'int', Value)
		}

		ParentWindow {
			Get => (ComCall(21, this, 'ptr*', &parentWindow := 0), parentWindow)

			Set => ComCall(22, this, 'ptr', Value)
		}

		IsVisible {
			Get => (ComCall(3, this, 'int*', &isVisible := 0), isVisible)

			Set => ComCall(4, this, 'int', Value)
		}

		Bounds {
			Get => (ComCall(5, this, 'ptr', bounds := Buffer(16)), bounds)

			Set => (A_PtrSize = 8 ? ComCall(6, this, 'ptr', Value) : ComCall(6, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}

		ZoomFactor {
			Get => (ComCall(7, this, 'double*', &zoomFactor := 0), zoomFactor)

			Set => ComCall(8, this, 'double', Value)
		}

		__Delete() {
			if this.ptr {
				this.Close()

				super.__Delete()
			}
		}

		Fill() {
			if !this.ptr
				return

			DllCall('user32\GetClientRect', 'ptr', this.ParentWindow, 'ptr', RECT := Buffer(16))

			this.Bounds := RECT
		}

		SetBoundsAndZoomFactor(bounds, zoomFactor) => (A_PtrSize = 8 ? ComCall(11, this, 'ptr', bounds, 'double', zoomFactor) : ComCall(11, this, 'int64', NumGet(bounds, 'int64'), 'int64', NumGet(bounds, 8, 'int64'), 'double', zoomFactor))

		MoveFocus(reason) => ComCall(12, this, 'int', reason)

		NotifyParentWindowPositionChanged() => ComCall(23, this)

		Close() => ComCall(24, this)

		add_ZoomFactorChanged(eventHandler) => (ComCall(9, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_ZoomFactorChanged(token) => ComCall(10, this, 'int64', token)

		add_MoveFocusRequested(eventHandler) => (ComCall(13, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_MoveFocusRequested(token) => ComCall(14, this, 'int64', token)

		add_GotFocus(eventHandler) => (ComCall(15, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_GotFocus(token) => ComCall(16, this, 'int64', token)

		add_LostFocus(eventHandler) => (ComCall(17, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_LostFocus(token) => ComCall(18, this, 'int64', token)

		add_AcceleratorKeyPressed(eventHandler) => (ComCall(19, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_AcceleratorKeyPressed(token) => ComCall(20, this, 'int64', token)

		add_RasterizationScaleChanged(eventHandler) => (ComCall(32, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_RasterizationScaleChanged(token) => ComCall(33, this, 'int64', token)
	}

	class ContentLoadingEventArgs extends WebView2.Base {
		static IID := '{0c8a1275-9b6b-4901-87ad-70df25bafa6e}'

		IsErrorPage => (ComCall(3, this, 'int*', &isErrorPage := 0), isErrorPage)

		NavigationId => (ComCall(4, this, 'int64*', &navigationId := 0), navigationId)
	}

	class Cookie extends WebView2.Base {
		static IID := '{AD26D6BE-1486-43E6-BF87-A2034006CA21}'

		Name => (ComCall(3, this, 'ptr*', &name := 0), CoTaskMem_String(name))

		Value {
			Get => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			Set => ComCall(5, this, 'wstr', Value)
		}

		Domain => (ComCall(6, this, 'ptr*', &domain := 0), CoTaskMem_String(domain))

		Path => (ComCall(7, this, 'ptr*', &path := 0), CoTaskMem_String(path))

		Expires {
			Get => (ComCall(8, this, 'double*', &expires := 0), expires)

			Set => ComCall(9, this, 'double', Value)
		}

		IsHttpOnly {
			Get => (ComCall(10, this, 'int*', &isHttpOnly := 0), isHttpOnly)
			Set => ComCall(11, this, 'int', Value)
		}

		SameSite {
			Get => (ComCall(12, this, 'int*', &sameSite := 0), sameSite)

			Set => ComCall(13, this, 'int', Value)
		}

		IsSecure {
			Get => (ComCall(14, this, 'int*', &isSecure := 0), isSecure)

			Set => ComCall(15, this, 'int', Value)
		}

		IsSession => (ComCall(16, this, 'int*', &isSession := 0), isSession)
	}

	class CookieList extends WebView2.Base {
		static IID := '{F7F6F714-5D2A-43C6-9503-346ECE02D186}'

		Count => (ComCall(3, this, 'uint*', &cnt := 0), cnt)

		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', cookie := WebView2.Cookie()), cookie)
	}

	class CookieManager extends WebView2.Base {
		static IID := '{177CD9E7-B6F5-451A-94A0-5D7A3A4C4141}'

		CreateCookie(name, value, domain, path) => (ComCall(3, this, 'wstr', name, 'wstr', value, 'wstr', domain, 'wstr', path, 'ptr*', cookie := WebView2.Cookie()), cookie)

		CopyCookie(cookieParam) => (ComCall(4, this, 'ptr', cookieParam, 'ptr*', cookie := WebView2.Cookie()), cookie)

		GetCookies(uri, handler) => ComCall(5, this, 'wstr', uri, 'ptr', handler)

		AddOrUpdateCookie(cookie) => ComCall(6, this, 'ptr', cookie)

		DeleteCookie(cookie) => ComCall(7, this, 'ptr', cookie)

		DeleteCookies(name, uri) => ComCall(8, this, 'wstr', name, 'wstr', uri)

		DeleteCookiesWithDomainAndPath(name, domain, path) => ComCall(9, this, 'wstr', name, 'wstr', domain, 'wstr', path)

		DeleteAllCookies() => ComCall(10, this)
	}

	class Core extends WebView2.Base {
		static IID := '{76eceacb-0462-4d94-ac83-423a6793775e}'
		static IID_2 := '{9E8F0CF8-E670-4B5E-B2BC-73E061E3184C}'
		static IID_3 := '{A0D6DF20-3B92-416D-AA0C-437A9C727857}'
		static IID_4 := '{20d02d59-6df2-42dc-bd06-f98a694b1302}'
		static IID_5 := '{bedb11b8-d63c-11eb-b8bc-0242ac130003}'
		static IID_6 := '{499aadac-d92c-4589-8a75-111bfc167795}'
		static IID_7 := '{79c24d83-09a3-45ae-9418-487f32a58740}'
		static IID_8 := '{E9632730-6E1E-43AB-B7B8-7B2C9E62E094}'

		BrowserProcessID => (ComCall(37, this, 'uint*', &value := 0), value)

		CookieManager => (ComCall(66, this, 'ptr*', cookieManager := WebView2.CookieManager()), cookieManager)

		Environment => (ComCall(67, this, 'ptr*', environment := WebView2.Environment()), environment)

		DocumentTitle => (ComCall(48, this, 'ptr*', &title := 0), CoTaskMem_String(title))

		Source => (ComCall(4, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

		ContainsFullScreenElement => (ComCall(54, this, 'int*', &containsFullScreenElement := 0), containsFullScreenElement)

		Settings => (ComCall(3, this, 'ptr*', settings := WebView2.Settings()), settings)

		CanGoBack => (ComCall(38, this, 'int*', &canGoBack := 0), canGoBack)

		CanGoForward => (ComCall(39, this, 'int*', &canGoForward := 0), canGoForward)

		IsSuspended => (ComCall(70, this, 'int*', &isSuspended := 0), isSuspended)

		IsDocumentPlayingAudio => (ComCall(87, this, 'int*', &value := 0), value)

		IsMuted {
			Get => (ComCall(83, this, 'int*', &value := 0), value)

			Set => ComCall(84, this, 'int', Value)
		}

		AddScriptToExecuteOnDocumentCreated(javaScript, handler) => ComCall(27, this, 'wstr', javaScript, 'ptr', handler)

		RemoveScriptToExecuteOnDocumentCreated(id) => ComCall(28, this, 'wstr', id)

		ExecuteScript(javaScript, handler) => ComCall(29, this, 'wstr', javaScript, 'ptr', handler)

		CapturePreview(imageFormat, imageStream, handler) => ComCall(30, this, 'int', imageFormat, 'ptr', imageStream, 'ptr', handler)

		PostWebMessageAsJson(webMessageAsJson) => ComCall(32, this, 'wstr', webMessageAsJson)

		PostWebMessageAsString(webMessageAsString) => ComCall(33, this, 'wstr', webMessageAsString)

		OpenDevToolsWindow() => ComCall(51, this)

		CallDevToolsProtocolMethod(methodName, parametersAsJson, handler) => ComCall(36, this, 'wstr', methodName, 'wstr', parametersAsJson, 'ptr', handler)

		GetDevToolsProtocolEventReceiver(eventName) => (ComCall(42, this, 'wstr', eventName, 'ptr*', receiver := WebView2.DevToolsProtocolEventReceiver()), receiver)

		Reload() => ComCall(31, this)

		GoBack() => ComCall(40, this)

		GoForward() => ComCall(41, this)

		Stop() => ComCall(43, this)

		AddHostObjectToScript(name, object) => ComCall(49, this, 'wstr', name, 'ptr', ComVariable(object))

		RemoveHostObjectFromScript(name) => ComCall(50, this, 'wstr', name)

		AddWebResourceRequestedFilter(uri, resourceContext) => ComCall(57, this, 'wstr', uri, 'int', resourceContext)

		RemoveWebResourceRequestedFilter(uri, resourceContext) => ComCall(58, this, 'wstr', uri, 'int', resourceContext)

		AddAHKObjHelper() => this.AddHostObjectToScript('AHKObjHelper', WebView2.AHKObjHelper())

		Navigate(uri) => ComCall(5, this, 'wstr', uri)

		NavigateToString(htmlContent) => ComCall(6, this, 'wstr', htmlContent)

		NavigateWithWebResourceRequest(request) => ComCall(63, this, 'ptr', request)

		SetVirtualHostNameToFolderMapping(hostName, folderPath, accessKind) => ComCall(71, this, 'wstr', hostName, 'wstr', folderPath, 'int', accessKind)

		ClearVirtualHostNameToFolderMapping(hostName) => ComCall(72, this, 'wstr', hostName)

		TrySuspend(handler) => ComCall(68, this, 'ptr', handler)

		Resume() => ComCall(69, this)

		OpenTaskManagerWindow() => ComCall(79, this)

		PrintToPdf(resultFilePath, printSettings, handler) => ComCall(80, this, 'wstr', resultFilePath, 'ptr', printSettings, 'ptr', handler)

		add_NavigationStarting(eventHandler) => (ComCall(7, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_NavigationStarting(token) => ComCall(8, this, 'int64', token)

		add_ContentLoading(eventHandler) => (ComCall(9, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_ContentLoading(token) => ComCall(10, this, 'int64', token)

		add_SourceChanged(eventHandler) => (ComCall(11, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_SourceChanged(token) => ComCall(12, this, 'int64', token)

		add_HistoryChanged(eventHandler) => (ComCall(13, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_HistoryChanged(token) => ComCall(14, this, 'int64', token)

		add_NavigationCompleted(eventHandler) => (ComCall(15, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_NavigationCompleted(token) => ComCall(16, this, 'int64', token)

		add_FrameNavigationStarting(eventHandler) => (ComCall(17, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_FrameNavigationStarting(token) => ComCall(18, this, 'int64', token)

		add_FrameNavigationCompleted(eventHandler) => (ComCall(19, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_FrameNavigationCompleted(token) => ComCall(20, this, 'int64', token)

		add_ScriptDialogOpening(eventHandler) => (ComCall(21, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_ScriptDialogOpening(token) => ComCall(22, this, 'int64', token)

		add_PermissionRequested(eventHandler) => (ComCall(23, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_PermissionRequested(token) => ComCall(24, this, 'int64', token)

		add_ProcessFailed(eventHandler) => (ComCall(25, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_ProcessFailed(token) => ComCall(26, this, 'int64', token)

		add_WebMessageReceived(handler) => (ComCall(34, this, 'ptr', handler, 'int64*', &token := 0), token)
		remove_WebMessageReceived(token) => ComCall(35, this, 'int64', token)

		add_NewWindowRequested(eventHandler) => (ComCall(44, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_NewWindowRequested(token) => ComCall(45, this, 'int64', token)

		add_DocumentTitleChanged(eventHandler) => (ComCall(46, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_DocumentTitleChanged(token) => ComCall(47, this, 'int64', token)

		add_ContainsFullScreenElementChanged(eventHandler) => (ComCall(52, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_ContainsFullScreenElementChanged(token) => ComCall(53, this, 'int64', token)

		add_WebResourceRequested(eventHandler) => (ComCall(55, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_WebResourceRequested(token) => ComCall(56, this, 'int64', token)

		add_WindowCloseRequested(eventHandler) => (ComCall(59, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_WindowCloseRequested(token) => ComCall(60, this, 'int64', token)

		add_WebResourceResponseReceived(eventHandler) => (ComCall(61, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_WebResourceResponseReceived(token) => ComCall(62, this, 'int64', token)

		add_DOMContentLoaded(eventHandler) => (ComCall(64, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_DOMContentLoaded(token) => ComCall(65, this, 'int64', token)

		add_FrameCreated(eventHandler) => (ComCall(73, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_FrameCreated(token) => ComCall(74, this, 'int64', token)

		add_DownloadStarting(eventHandler) => (ComCall(75, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_DownloadStarting(token) => ComCall(76, this, 'int64', token)

		add_ClientCertificateRequested(eventHandler) => (ComCall(77, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_ClientCertificateRequested(token) => ComCall(78, this, 'int64', token)

		add_IsMutedChanged(eventHandler) => (ComCall(81, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_IsMutedChanged(token) => ComCall(82, this, 'int64', token)

		add_IsDocumentPlayingAudioChanged(eventHandler) => (ComCall(85, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_IsDocumentPlayingAudioChanged(token) => ComCall(86, this, 'int64', token)
	}

	class ClientCertificate extends WebView2.Base {
		static IID := '{e7188076-bcc3-11eb-8529-0242ac130003}'

		Subject => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		Issuer => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		ValidFrom => (ComCall(5, this, 'double*', &value := 0), value)

		ValidTo => (ComCall(6, this, 'double*', &value := 0), value)

		DerEncodedSerialNumber => (ComCall(7, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		DisplayName => (ComCall(8, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		PemEncodedIssuerCertificateChain => (ComCall(10, this, 'ptr*', value := WebView2.StringCollection()), value)

		Kind => (ComCall(11, this, 'int*', &value := 0), value)

		ToPemEncoding() => (ComCall(9, this, 'ptr*', &pemEncodedData := 0), CoTaskMem_String(pemEncodedData))
	}

	class StringCollection extends WebView2.Base {
		static IID := '{f41f3f8a-bcc3-11eb-8529-0242ac130003}'

		Count => (ComCall(3, this, 'uint*', &value := 0), value)

		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', &value := 0), CoTaskMem_String(value))
	}

	class ClientCertificateCollection extends WebView2.Base {
		static IID := '{ef5674d2-bcc3-11eb-8529-0242ac130003}'

		Count => (ComCall(3, this, 'uint*', &value := 0), value)

		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', certificate := WebView2.ClientCertificate()), certificate)
	}

	class ClientCertificateRequestedEventArgs extends WebView2.Base {
		static IID := '{bc59db28-bcc3-11eb-8529-0242ac130003}'

		Host => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		Port => (ComCall(4, this, 'int*', &value := 0), value)

		IsProxy => (ComCall(5, this, 'int*', &value := 0), value)

		AllowedCertificateAuthorities => (ComCall(6, this, 'ptr*', value := WebView2.StringCollection()), value)

		MutuallyTrustedCertificates => (ComCall(7, this, 'ptr*', value := WebView2.ClientCertificateCollection()), value)

		SelectedCertificate {
			Get => (ComCall(8, this, 'ptr*', value := WebView2.ClientCertificate()), value)

			Set => ComCall(9, this, 'ptr', value)
		}

		Cancel {
			Get => (ComCall(10, this, 'int*', &value := 0), value)

			Set => ComCall(11, this, 'int', Value)
		}

		Handled {
			Get => (ComCall(12, this, 'int*', &value := 0), value)

			Set => ComCall(13, this, 'int', Value)
		}

		GetDeferral() => (ComCall(14, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}

	class DOMContentLoadedEventArgs extends WebView2.Base {
		static IID := '{16B1E21A-C503-44F2-84C9-70ABA5031283}'

		NavigationId => (ComCall(3, this, 'int64*', &navigationId := 0), navigationId)
	}

	class Deferral extends WebView2.Base {
		static IID := '{c10e7f7b-b585-46f0-a623-8befbf3e4ee0}'

		Complete() => ComCall(3, this)
	}

	class DevToolsProtocolEventReceivedEventArgs extends WebView2.Base {
		static IID := '{653c2959-bb3a-4377-8632-b58ada4e66c4}'

		ParameterObjectAsJson => (ComCall(3, this, 'ptr*', &parameterObjectAsJson := 0), CoTaskMem_String(parameterObjectAsJson))
	}

	class DevToolsProtocolEventReceiver extends WebView2.Base {
		static IID := '{b32ca51a-8371-45e9-9317-af021d080367}'

		add_DevToolsProtocolEventReceived(handler) => (ComCall(3, this, 'ptr', handler, 'int64*', &token := 0), token)
		remove_DevToolsProtocolEventReceived(token) => ComCall(4, this, 'int64', token)
	}

	class DownloadOperation extends WebView2.Base {
		static IID := '{3d6b6cf2-afe1-44c7-a995-c65117714336}'

		Uri => (ComCall(9, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

		ContentDisposition => (ComCall(10, this, 'ptr*', &contentDisposition := 0), CoTaskMem_String(contentDisposition))

		MimeType => (ComCall(11, this, 'ptr*', &mimeType := 0), CoTaskMem_String(mimeType))

		TotalBytesToReceive => (ComCall(12, this, 'int64*', &totalBytesToReceive := 0), totalBytesToReceive)

		BytesReceived => (ComCall(13, this, 'int64*', &bytesReceived := 0), bytesReceived)

		EstimatedEndTime => (ComCall(14, this, 'ptr*', &estimatedEndTime := 0), CoTaskMem_String(estimatedEndTime))

		ResultFilePath => (ComCall(15, this, 'ptr*', &resultFilePath := 0), CoTaskMem_String(resultFilePath))

		State => (ComCall(16, this, 'int*', &downloadState := 0), downloadState)	; COREWEBVIEW2_DOWNLOAD_STATE

		InterruptReason => (ComCall(17, this, 'int*', &interruptReason := 0), interruptReason)

		Cancel() => ComCall(18, this)

		Pause() => ComCall(19, this)

		Resume() => ComCall(20, this)

		CanResume => (ComCall(21, this, 'int*', &canResume := 0), canResume)

		add_BytesReceivedChanged(eventHandler) => (ComCall(3, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_BytesReceivedChanged(token) => ComCall(4, this, 'int64', token)

		add_EstimatedEndTimeChanged(eventHandler) => (ComCall(5, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_EstimatedEndTimeChanged(token) => ComCall(6, this, 'int64', token)

		add_StateChanged(eventHandler) => (ComCall(7, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_StateChanged(token) => ComCall(8, this, 'int64', token)
	}

	class DownloadStartingEventArgs extends WebView2.Base {
		static IID := '{e99bbe21-43e9-4544-a732-282764eafa60}'

		DownloadOperation => (ComCall(3, this, 'ptr*', downloadOperation := WebView2.DownloadOperation()), downloadOperation)

		Cancel {
			Get => (ComCall(4, this, 'int*', &cancel := 0), cancel)

			Set => ComCall(5, this, 'int', Value)
		}

		ResultFilePath {
			Get => (ComCall(6, this, 'ptr*', &resultFilePath := 0), CoTaskMem_String(resultFilePath))

			Set => ComCall(7, this, 'wstr', Value)
		}

		Handled {
			Get => (ComCall(8, this, 'int*', &handled := 0), handled)

			Set => ComCall(9, this, 'int', Value)
		}

		GetDeferral() => (ComCall(10, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}

	class Environment extends WebView2.Base {
		static IID := '{b96d755e-0319-4e92-a296-23436f46a1fc}'
		static IID_2 := '{41F3632B-5EF4-404F-AD82-2D606C5A9A21}'
		static IID_3 := '{80a22ae3-be7c-4ce2-afe1-5a50056cdeeb}'
		static IID_4 := '{20944379-6dcf-41d6-a0a0-abc0fc50de0d}'
		static IID_5 := '{319e423d-e0d7-4b8d-9254-ae9475de9b17}'
		static IID_6 := '{e59ee362-acbd-4857-9a8e-d3644d9459a9}'
		static IID_7 := '{43C22296-3BBD-43A4-9C00-5C0DF6DD29A2}'

		BrowserVersionString => (ComCall(5, this, 'ptr*', &versionInfo := 0), CoTaskMem_String(versionInfo))

		UserDataFolder => (ComCall(15, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		CreateWebResourceRequest(uri, method, postData, headers) => (ComCall(8, this, 'wstr', uri, 'wstr', method, 'ptr', postData, 'wstr', headers, 'ptr*', request := WebView2.WebResourceRequest()), request)

		CreateWebResourceResponse(content, statusCode, reasonPhrase, headers) => (ComCall(4, this, 'ptr', content, 'int', statusCode, 'wstr', reasonPhrase, 'wstr', headers, 'ptr*', response := WebView2.WebResourceResponse()), response)

		CreateCoreWebView2CompositionController(parentWindow, handler) => ComCall(9, this, 'ptr', parentWindow, 'ptr', handler)

		CreateCoreWebView2Controller(parentWindow, handler) => ComCall(3, this, 'ptr', parentWindow, 'ptr', handler)

		CreateCoreWebView2PointerInfo() => (ComCall(10, this, 'ptr*', pointerInfo := WebView2.PointerInfo()), pointerInfo)

		GetProviderForHwnd(hwnd) => (ComCall(11, this, 'ptr', hwnd, 'ptr*', &provider := 0), ComValue(0xd, provider))

		CreatePrintSettings() => (ComCall(14, this, 'ptr*', printSettings := WebView2.PrintSettings()), printSettings)

		add_NewBrowserVersionAvailable(eventHandler) => (ComCall(6, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_NewBrowserVersionAvailable(token) => ComCall(7, this, 'int64', token)

		add_BrowserProcessExited(eventHandler) => (ComCall(12, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_BrowserProcessExited(token) => ComCall(13, this, 'int64', token)
	}

	class EnvironmentOptions extends Buffer {
		__New(opts) {
			QueryInterface(this, riid, ppvObject) {
				static IID_ICoreWebView2EnvironmentOptions := '{2FDE08A8-1E9A-4766-8C05-95A9CEB9D1C5}'
				static IID_ICoreWebView2EnvironmentOptions2 := '{1821A568-A141-4D77-B3D8-2878E383D8DD}'

				DllCall("ole32.dll\StringFromGUID2", "ptr", riid, "ptr", buf := Buffer(78), "int", 39)

				iid := StrGet(buf)

				if ((iid = IID_ICoreWebView2EnvironmentOptions) || (iid = IID_ICoreWebView2EnvironmentOptions2)) {
					ObjAddRef(this)

					NumPut('ptr', this, ppvObject)

					return 0
				}

				NumPut('ptr', 0, ppvObject)

				return 0x80004002
			}

			AddRef(this) => ObjAddRef(NumGet(this, A_PtrSize, 'ptr'))

			Release(this) => ObjRelease(NumGet(this, A_PtrSize, 'ptr'))

			set_AdditionalBrowserArguments(*) => 0

			set_AllowSingleSignOnUsingOSPrimaryAccount(*) => 0

			set_Language(*) => 0

			set_TargetCompatibleBrowserVersion(*) => 0

			set_ExclusiveUserDataFolderAccess(*) => 0

			get_AdditionalBrowserArguments(this, pvalue) {
				this := ObjFromPtrAddRef(NumGet(this, A_PtrSize, 'ptr'))

				if this.HasOwnProp('AdditionalBrowserArguments') {
					p := DllCall('ole32\CoTaskMemAlloc', 'uptr', s := StrLen(v := this.AdditionalBrowserArguments) * 2 + 2, 'ptr')

					DllCall('RtlMoveMemory', 'ptr', p, 'ptr', StrPtr(v), 'uptr', s)

					NumPut('ptr', p, pvalue)
				}
				else
					NumPut('ptr', 0, pvalue)

				return 0
			}

			get_AllowSingleSignOnUsingOSPrimaryAccount(this, pvalue) {
				this := ObjFromPtrAddRef(NumGet(this, A_PtrSize, 'ptr'))

				if this.HasOwnProp('AllowSingleSignOnUsingOSPrimaryAccount')
					NumPut('int', !!this.AllowSingleSignOnUsingOSPrimaryAccount, pvalue)
				else
					NumPut('int', 0, pvalue)

				return 0
			}

			get_ExclusiveUserDataFolderAccess(this, pvalue) {
				this := ObjFromPtrAddRef(NumGet(this, A_PtrSize, 'ptr'))

				if this.HasOwnProp('ExclusiveUserDataFolderAccess')
					NumPut('int', !!this.ExclusiveUserDataFolderAccess, pvalue)
				else
					NumPut('int', 0, pvalue)

				return 0
			}

			get_Language(this, pvalue) {
				this := ObjFromPtrAddRef(NumGet(this, A_PtrSize, 'ptr'))

				if this.HasOwnProp('Language') {
					p := DllCall('ole32\CoTaskMemAlloc', 'uptr', s := StrLen(v := this.Language) * 2 + 2, 'ptr')

					DllCall('RtlMoveMemory', 'ptr', p, 'ptr', StrPtr(v), 'uptr', s)

					NumPut('ptr', p, pvalue)
				}
				else
					NumPut('ptr', 0, pvalue)

				return 0
			}

			get_TargetCompatibleBrowserVersion(this, pvalue) {
				this := ObjFromPtrAddRef(NumGet(this, A_PtrSize, 'ptr'))

				if this.HasOwnProp('TargetCompatibleBrowserVersion') {
					p := DllCall('ole32\CoTaskMemAlloc', 'uptr', s := StrLen(v := this.TargetCompatibleBrowserVersion) * 2 + 2, 'ptr')

					DllCall('RtlMoveMemory', 'ptr', p, 'ptr', StrPtr(v), 'uptr', s)

					NumPut('ptr', p, pvalue)
				}
				else
					NumPut('ptr', 0, pvalue)

				return 0
			}

			super.__New(15 * A_PtrSize, 0)

			p := NumPut('ptr', this.Ptr + 2 * A_PtrSize, 'ptr', p := ObjPtr(this), this)

			for cb in [QueryInterface, AddRef, Release,
					   get_AdditionalBrowserArguments, set_AdditionalBrowserArguments,
					   get_Language, set_Language,
					   get_TargetCompatibleBrowserVersion, set_TargetCompatibleBrowserVersion,
					   get_AllowSingleSignOnUsingOSPrimaryAccount, set_AllowSingleSignOnUsingOSPrimaryAccount,
					   get_ExclusiveUserDataFolderAccess, set_ExclusiveUserDataFolderAccess]
				p := NumPut('ptr', CallbackCreate(cb), p)

			for n in opts.OwnProps()
				this.%n% := opts.%n%
		}

		__Delete() {
			loop 13
				CallbackFree(NumGet(this, (A_Index + 1) * A_PtrSize, 'ptr'))
		}
	}

	class Frame extends WebView2.Base {
		static IID := '{f1131a5e-9ba9-11eb-a8b3-0242ac130003}'

		Name => (ComCall(3, this, 'ptr*', &name := 0), CoTaskMem_String(name))

		AddAHKObjHelper() => this.AddHostObjectToScriptWithOrigins('AHKObjHelper', WebView2.AHKObjHelper())

		AddHostObjectToScriptWithOrigins(name, object, originsArr*) {
			if (originsCount := originsArr.Length) {
				p := (origins := Buffer(originsCount * A_PtrSize)).Ptr

				loop originsCount
					p := NumPut('ptr', StrPtr(originsArr[A_Index]), p)
			}

			ComCall(6, this, 'wstr', name, 'ptr', ComVariable(object), 'uint', originsCount, 'ptr', origins)
		}

		RemoveHostObjectFromScript(name) => ComCall(7, this, 'wstr', name)

		IsDestroyed() => (ComCall(10, this, 'int*', &destroyed := 0), destroyed)

		add_NameChanged(eventHandler) => (ComCall(4, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_NameChanged(token) => ComCall(5, this, 'int64', token)

		add_Destroyed(eventHandler) => (ComCall(8, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_Destroyed(token) => ComCall(9, this, 'int64', token)
	}

	class FrameCreatedEventArgs extends WebView2.Base {
		static IID := '{4d6e7b5e-9baa-11eb-a8b3-0242ac130003}'

		Frame => (ComCall(3, this, 'ptr*', frame := WebView2.Frame()), frame)
	}

	class FrameInfo extends WebView2.Base {
		static IID := '{da86b8a1-bdf3-4f11-9955-528cefa59727}'

		Name => (ComCall(3, this, 'ptr*', &name := 0), CoTaskMem_String(name))

		Source => (ComCall(4, this, 'ptr*', &source := 0), CoTaskMem_String(source))
	}

	class FrameInfoCollection extends WebView2.Base {
		static IID := '{8f834154-d38e-4d90-affb-6800a7272839}'

		GetIterator() => (ComCall(3, this, 'ptr*', iterator := WebView2.FrameInfoCollectionIterator()), iterator)
	}

	class FrameInfoCollectionIterator extends WebView2.Base {
		static IID := '{1bf89e2d-1b2b-4629-b28f-05099b41bb03}'

		HasCurrent => (ComCall(3, this, 'int*', &hasCurrent := 0), hasCurrent)

		GetCurrent() => (ComCall(4, this, 'ptr*', frameInfo := WebView2.FrameInfo()), frameInfo)

		MoveNext() => (ComCall(5, this, 'int*', &hasNext := 0), hasNext)
	}

	class Handler extends Buffer {
		__New(invoke_cb, paramcount := 0) {
			/**
			 * Construct ICoreWebView2 Event or Completed Handler.
			 * @param invoke_cb Invoke function of handler.
			 * The first parameter of the callback function is the event interface pointer, and other parameters are as follows.
			 * #### Handlers:
			 * - BrowserProcessExitedEventHandler::Invoke(Environment*, BrowserProcessExitedEventArgs*);
			 * - BytesReceivedChangedEventHandler::Invoke(DownloadOperation*, IUnknown*);
			 * - ContentLoadingEventHandler::Invoke(ICoreWebView2*, ContentLoadingEventArgs*);
			 * - ClientCertificateRequestedEventHandler::Invoke(ICoreWebView2*, ClientCertificateRequestedEventArgs*);
			 * - ContainsFullScreenElementChangedEventHandler::Invoke(ICoreWebView2*, IUnknown*);
			 * - CursorChangedEventHandler::Invoke(CompositionController*, IUnknown*);
			 * - DocumentTitleChangedEventHandler::Invoke(ICoreWebView2*, IUnknown*);
			 * - DOMContentLoadedEventHandler::Invoke(ICoreWebView2*, DOMContentLoadedEventArgs*);
			 * - DevToolsProtocolEventReceivedEventHandler::Invoke(ICoreWebView2*, DevToolsProtocolEventReceivedEventArgs*);
			 * - DownloadStartingEventHandler::Invoke(ICoreWebView2*, DownloadStartingEventArgs*);
			 * - EstimatedEndTimeChangedEventHandler::Invoke(DownloadOperation*, IUnknown*);
			 * - FrameCreatedEventHandler::Invoke(ICoreWebView2*, FrameCreatedEventArgs*);
			 * - FrameDestroyedEventHandler::Invoke(Frame*, IUnknown*);
			 * - FrameNameChangedEventHandler::Invoke(Frame*, IUnknown*);
			 * - FocusChangedEventHandler::Invoke(Controller*, IUnknown*);
			 * - HistoryChangedEventHandler::Invoke(ICoreWebView2*, IUnknown*);
			 * - MoveFocusRequestedEventHandler::Invoke(Controller*, MoveFocusRequestedEventArgs*);
			 * - NavigationCompletedEventHandler::Invoke(ICoreWebView2*, NavigationCompletedEventArgs*);
			 * - NavigationStartingEventHandler::Invoke(ICoreWebView2*, NavigationStartingEventArgs*);
			 * - NewBrowserVersionAvailableEventHandler::Invoke(Environment*, IUnknown*);
			 * - NewWindowRequestedEventHandler::Invoke(ICoreWebView2*, NewWindowRequestedEventArgs*);
			 * - PermissionRequestedEventHandler::Invoke(ICoreWebView2*, PermissionRequestedEventArgs*);
			 * - ProcessFailedEventHandler::Invoke(ICoreWebView2*, ProcessFailedEventArgs*);
			 * - RasterizationScaleChangedEventHandler::Invoke(Controller*, IUnknown*);
			 * - ScriptDialogOpeningEventHandler::Invoke(ICoreWebView2*, ScriptDialogOpeningEventArgs*);
			 * - SourceChangedEventHandler::Invoke(ICoreWebView2*, SourceChangedEventArgs*);
			 * - StateChangedEventHandler::Invoke(DownloadOperation*, IUnknown*);
			 * - WebMessageReceivedEventHandler::Invoke(ICoreWebView2*, WebMessageReceivedEventArgs*);
			 * - WebResourceRequestedEventHandler::Invoke(ICoreWebView2*, WebResourceRequestedEventArgs*);
			 * - WebResourceResponseReceivedEventHandler::Invoke(ICoreWebView2*, WebResourceResponseReceivedEventArgs*);
			 * - WindowCloseRequestedEventHandler::Invoke(ICoreWebView2*, IUnknown*);
			 * - ZoomFactorChangedEventHandler::Invoke(Controller*, IUnknown*);
			 * - IWebView2CreateWebView2EnvironmentCompletedHandler::Invoke(Controller *sender, AcceleratorKeyPressedEventArgs *args);
			 * - AddScriptToExecuteOnDocumentCreatedCompletedHandler::Invoke(HRESULT errorCode, LPCWSTR id);
			 * - CallDevToolsProtocolMethodCompletedHandler::Invoke(HRESULT errorCode, LPCWSTR returnObjectAsJson);
			 * - CapturePreviewCompletedHandler::Invoke(HRESULT errorCode);
			 * - CreateCoreWebView2CompositionControllerCompletedHandler::Invoke(HRESULT errorCode, CompositionController *webView);
			 * - CreateCoreWebView2ControllerCompletedHandler::Invoke(HRESULT errorCode, Controller *createdController);
			 * - CreateCoreWebView2EnvironmentCompletedHandler::Invoke(HRESULT errorCode, Environment *createdEnvironment);
			 * - ExecuteScriptCompletedHandler::Invoke(HRESULT errorCode, LPCWSTR resultObjectAsJson);
			 * - GetCookiesCompletedHandler::Invoke(HRESULT result, CookieList *cookieList);
			 * - PrintToPdfCompletedHandler::Invoke(HRESULT result, BOOL isSuccessful);
			 * - TrySuspendCompletedHandler::Invoke(HRESULT errorCode, BOOL isSuccessful);
			 * - WebResourceResponseViewGetContentCompletedHandler::Invoke(HRESULT errorCode, IStream *content);
			 * - CoreWebView2IsDefaultDownloadDialogOpenChangedEventHandler::Invoke(ICoreWebView2 *sender, IUnknown *args);
			 * - CoreWebView2IsMutedChangedEventHandler::Invoke(ICoreWebView2 *sender, IUnknown *args);
			 */

			QueryInterface(interface, riid, ppvObject) {
			}

			AddRef(this) => ObjAddRef(NumGet(this, A_PtrSize, 'ptr'))

			Release(this) => ObjRelease(NumGet(this, A_PtrSize, 'ptr'))

			super.__New(6 * A_PtrSize)

			NumPut('ptr', this.Ptr + 2 * A_PtrSize, 'ptr', p := ObjPtr(this), this)

			for cb in [QueryInterface, AddRef, Release]
				NumPut('ptr', CallbackCreate(cb), this, (A_Index + 1) * A_PtrSize)

			NumPut('ptr', paramcount ? CallbackCreate(invoke_cb, , paramcount) : CallbackCreate(invoke_cb), this, 5 * A_PtrSize)
		}

		__Delete() {
			loop 4
				CallbackFree(NumGet(this, (A_Index + 1) * A_PtrSize, 'ptr'))
		}
	}

	class HttpHeadersCollectionIterator extends WebView2.Base {
		static IID := '{0702fc30-f43b-47bb-ab52-a42cb552ad9f}'

		HasCurrentHeader => (ComCall(4, this, 'int*', &hasCurrent := 0), hasCurrent)

		GetCurrentHeader(&name, &value) {
			ComCall(3, this, 'ptr*', &name := 0, 'ptr*', &value := 0)

			name := CoTaskMem_String(name)
			value := CoTaskMem_String(value)
		}

		MoveNext() => (ComCall(5, this, 'int*', &hasNext := 0), hasNext)
	}

	class HttpRequestHeaders extends WebView2.Base {
		static IID := '{e86cac0e-5523-465c-b536-8fb9fc8c8c60}'

		GetHeader(name) => (ComCall(3, this, 'wstr', name, 'ptr*', &value := 0), CoTaskMem_String(value))

		GetHeaders(name) => (ComCall(4, this, 'wstr', name, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)

		RetVal(name) => (ComCall(5, this, 'wstr', name, 'int*', &RetVal := 0), RetVal)

		SetHeader(name, value) => ComCall(6, this, 'wstr', name, 'wstr', value)

		RemoveHeader(name) => ComCall(7, this, 'wstr', name)

		GetIterator() => (ComCall(8, this, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)
	}

	class HttpResponseHeaders extends WebView2.Base {
		static IID := '{03c5ff5a-9b45-4a88-881c-89a9f328619c}'

		AppendHeader(name, value) => ComCall(3, this, 'wstr', name, 'wstr', value)

		RetVal(name) => (ComCall(4, this, 'wstr', name, 'int*', &RetVal := 0), RetVal)

		GetHeader(name) => (ComCall(5, this, 'wstr', name, 'ptr*', &value := 0), CoTaskMem_String(value))

		GetHeaders(name) => (ComCall(6, this, 'wstr', name, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)

		GetIterator() => (ComCall(7, this, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)
	}

	class MoveFocusRequestedEventArgs extends WebView2.Base {
		static IID := '{2d6aa13b-3839-4a15-92fc-d88b3c0d9c9d}'

		Reason => (ComCall(3, this, 'int*', &reason := 0), reason)

		Handled {
			Get => (ComCall(4, this, 'int*', &value := 0), value)

			Set => ComCall(5, this, 'int', Value)
		}
	}

	class NavigationCompletedEventArgs extends WebView2.Base {
		static IID := '{30d68b7d-20d9-4752-a9ca-ec8448fbb5c1}'

		IsSuccess => (ComCall(3, this, 'int*', &isSuccess := 0), isSuccess)

		WebErrorStatus => (ComCall(4, this, 'int*', &webErrorStatus := 0), webErrorStatus)

		NavigationId => (ComCall(5, this, 'int64*', &navigationId := 0), navigationId)
	}

	class NavigationStartingEventArgs extends WebView2.Base {
		static IID := '{5b495469-e119-438a-9b18-7604f25f2e49}'

		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

		IsUserInitiated => (ComCall(4, this, 'int*', &isUserInitiated := 0), isUserInitiated)

		IsRedirected => (ComCall(5, this, 'int*', &isRedirected := 0), isRedirected)

		RequestHeaders => (ComCall(6, this, 'ptr*', requestHeaders := WebView2.HttpRequestHeaders()), requestHeaders)

		Cancel {
			Get => (ComCall(7, this, 'int*', &cancel := 0), cancel)

			Set => ComCall(8, this, 'int', Value)
		}

		NavigationID => (ComCall(9, this, 'int64*', &navigationId := 0), navigationId)
	}
	class NewWindowRequestedEventArgs extends WebView2.Base {
		static IID := '{34acb11c-fc37-4418-9132-f9c21d1eafb9}'
		static IID_2 := '{bbc7baed-74c6-4c92-b63a-7f5aeae03de3}'

		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

		Name => (ComCall(11, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		NewWindow {
			Get => (ComCall(5, this, 'ptr*', newWindow := WebView2.Core()), newWindow)

			Set => ComCall(4, this, 'ptr', Value)
		}

		Handled {
			Get => (ComCall(7, this, 'int*', &handled := 0), handled)

			Set => ComCall(6, this, 'int', Value)
		}

		IsUserInitiated => (ComCall(8, this, 'int*', &isUserInitiated := 0), isUserInitiated)

		WindowFeatures => (ComCall(10, this, 'ptr*', value := WebView2.WindowFeatures()), value)

		GetDeferral() => (ComCall(9, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}

	class PermissionRequestedEventArgs extends WebView2.Base {
		static IID := '{973ae2ef-ff18-4894-8fb2-3c758f046810}'

		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

		PermissionKind => (ComCall(4, this, 'int*', &permissionKind := 0), permissionKind)

		IsUserInitiated => (ComCall(5, this, 'int*', &isUserInitiated := 0), isUserInitiated)

		State {
			Get => (ComCall(6, this, 'int*', &state := 0), state)

			Set => ComCall(7, this, 'int', Value)
		}

		GetDeferral() => (ComCall(8, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}

	class PointerInfo extends WebView2.Base {
		static IID := '{e6995887-d10d-4f5d-9359-4ce46e4f96b9}'

		PointerKind {
			Get => (ComCall(3, this, 'uint*', &pointerKind := 0), pointerKind)

			Set => ComCall(4, this, 'uint', Value)
		}

		PointerID {
			Get => (ComCall(5, this, 'uint*', &pointerId := 0), pointerId)

			Set => ComCall(6, this, 'uint', Value)
		}

		FrameId {
			Get => (ComCall(7, this, 'uint*', &frameId := 0), frameId)

			Set => ComCall(8, this, 'uint', Value)
		}

		PointerFlags {
			Get => (ComCall(9, this, 'uint*', &pointerFlags := 0), pointerFlags)

			Set => ComCall(10, this, 'uint', Value)
		}

		PointerDeviceRect {
			Get => (ComCall(11, this, 'ptr', pointerDeviceRect := Buffer(16)), pointerDeviceRect)

			Set => (A_PtrSize = 8 ? ComCall(12, this, 'ptr', Value) : ComCall(12, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}

		DisplayRect {
			Get => (ComCall(13, this, 'ptr', displayRect := Buffer(16)), displayRect)

			Set => (A_PtrSize = 8 ? ComCall(14, this, 'ptr', Value) : ComCall(14, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}

		PixelLocation {
			Get => (ComCall(15, this, 'int64*', &pixelLocation := 0), pixelLocation)

			Set => ComCall(16, this, 'int64', Value)
		}

		HimetricLocation {
			Get => (ComCall(17, this, 'int64*', &himetricLocation := 0), himetricLocation)

			Set => ComCall(18, this, 'int64', Value)
		}

		PixelLocationRaw {
			Get => (ComCall(19, this, 'int64*', &pixelLocationRaw := 0), pixelLocationRaw)

			Set => ComCall(20, this, 'int64', Value)
		}

		HimetricLocationRaw {
			Get => (ComCall(21, this, 'int64*', &himetricLocationRaw := 0), himetricLocationRaw)

			Set => ComCall(22, this, 'int64', Value)
		}

		Time {
			Get => (ComCall(23, this, 'uint*', &time := 0), time)

			Set => ComCall(24, this, 'uint', Value)
		}

		HistoryCount {
			Get => (ComCall(25, this, 'uint*', &historyCount := 0), historyCount)

			Set => ComCall(26, this, 'uint', Value)
		}

		InputData {
			Get => (ComCall(27, this, 'int*', &inputData := 0), inputData)

			Set => ComCall(28, this, 'int', Value)
		}

		KeyStates {
			Get => (ComCall(29, this, 'uint*', &keyStates := 0), keyStates)

			Set => ComCall(30, this, 'uint', Value)
		}

		PerformanceCount {
			Get => (ComCall(31, this, 'uint64*', &performanceCount := 0), performanceCount)

			Set => ComCall(32, this, 'uint64', Value)
		}

		ButtonChangeKind {
			Get => (ComCall(33, this, 'int*', &buttonChangeKind := 0), buttonChangeKind)

			Set => ComCall(34, this, 'int', Value)
		}

		PenFlags {
			Get => (ComCall(35, this, 'uint*', &penFLags := 0), penFLags)

			Set => ComCall(36, this, 'uint', Value)
		}

		PenMask {
			Get => (ComCall(37, this, 'uint*', &penMask := 0), penMask)

			Set => ComCall(38, this, 'uint', Value)
		}

		PenPressure {
			Get => (ComCall(39, this, 'uint*', &penPressure := 0), penPressure)

			Set => ComCall(40, this, 'uint', Value)
		}

		PenRotation {
			Get => (ComCall(41, this, 'uint*', &penRotation := 0), penRotation)

			Set => ComCall(42, this, 'uint', Value)
		}

		PenTiltX {
			Get => (ComCall(43, this, 'int*', &penTiltX := 0), penTiltX)

			Set => ComCall(44, this, 'int', Value)
		}

		PenTiltY {
			Get => (ComCall(45, this, 'int*', &penTiltY := 0), penTiltY)

			Set => ComCall(46, this, 'int', Value)
		}

		TouchFlags {
			Get => (ComCall(47, this, 'uint*', &touchFlags := 0), touchFlags)

			Set => ComCall(48, this, 'uint', Value)
		}

		TouchMask {
			Get => (ComCall(49, this, 'uint*', &touchMask := 0), touchMask)

			Set => ComCall(50, this, 'uint', Value)
		}

		TouchContact {
			Get => (ComCall(51, this, 'ptr', touchContact := Buffer(16)), touchContact)

			Set => (A_PtrSize = 8 ? ComCall(52, this, 'ptr', Value) : ComCall(52, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}

		TouchContactRaw {
			Get => (ComCall(53, this, 'ptr', touchContactRaw := Buffer(16)), touchContactRaw)

			Set => (A_PtrSize = 8 ? ComCall(54, this, 'ptr', Value) : ComCall(54, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}

		TouchOrientation {
			Get => (ComCall(55, this, 'uint*', &touchOrientation := 0), touchOrientation)

			Set => ComCall(56, this, 'uint', Value)
		}

		TouchPressure {
			Get => (ComCall(57, this, 'uint*', &touchPressure := 0), touchPressure)

			Set => ComCall(58, this, 'uint', Value)
		}
	}

	class PrintSettings extends WebView2.Base {
		static IID := '{377f3721-c74e-48ca-8db1-df68e51d60e2}'

		Orientation {
			Get => (ComCall(3, this, 'int*', &orientation := 0), orientation)

			Set => ComCall(4, this, 'int', Value)
		}

		ScaleFactor {
			Get => (ComCall(5, this, 'double*', &scaleFactor := 0), scaleFactor)

			Set => ComCall(6, this, 'double', Value)
		}

		PageWidth {
			Get => (ComCall(7, this, 'double*', &pageWidth := 0), pageWidth)

			Set => ComCall(8, this, 'double', Value)
		}

		PageHeight {
			Get => (ComCall(9, this, 'double*', &pageHeight := 0), pageHeight)

			Set => ComCall(10, this, 'double', Value)
		}

		MarginTop {
			Get => (ComCall(11, this, 'double*', &marginTop := 0), marginTop)

			Set => ComCall(12, this, 'double', Value)
		}

		MarginBottom {
			Get => (ComCall(13, this, 'double*', &marginBottom := 0), marginBottom)

			Set => ComCall(14, this, 'double', Value)
		}

		MarginLeft {
			Get => (ComCall(15, this, 'double*', &marginLeft := 0), marginLeft)

			Set => ComCall(16, this, 'double', Value)
		}

		MarginRight {
			Get => (ComCall(17, this, 'double*', &marginRight := 0), marginRight)

			Set => ComCall(18, this, 'double', Value)
		}

		ShouldPrintBackgrounds {
			Get => (ComCall(19, this, 'int*', &shouldPrintBackgrounds := 0), shouldPrintBackgrounds)

			Set => ComCall(20, this, 'int', Value)
		}

		ShouldPrintSelectionOnly {
			Get => (ComCall(21, this, 'int*', &shouldPrintSelectionOnly := 0), shouldPrintSelectionOnly)

			Set => ComCall(22, this, 'int', Value)
		}

		ShouldPrintHeaderAndFooter {
			Get => (ComCall(23, this, 'int*', &shouldPrintHeaderAndFooter := 0), shouldPrintHeaderAndFooter)

			Set => ComCall(24, this, 'int', Value)
		}

		HeaderTitle {
			Get => (ComCall(25, this, 'ptr*', &headerTitle := 0), CoTaskMem_String(headerTitle))

			Set => ComCall(26, this, 'wstr', Value)
		}

		FooterUri {
			Get => (ComCall(27, this, 'ptr*', &footerUri := 0), CoTaskMem_String(footerUri))

			Set => ComCall(28, this, 'wstr', Value)
		}
	}

	class ProcessFailedEventArgs extends WebView2.Base {
		static IID := '{8155a9a4-1474-4a86-8cae-151b0fa6b8ca}'
		static IID_2 := '{4dab9422-46fa-4c3e-a5d2-41d2071d3680}'

		ProcessFailedKind => (ComCall(3, this, 'int*', &processFailedKind := 0), processFailedKind)	; COREWEBVIEW2_PROCESS_FAILED_KIND

		Reason => (ComCall(4, this, 'int*', &reason := 0), reason)	; COREWEBVIEW2_PROCESS_FAILED_REASON

		ExitCode => (ComCall(5, this, 'int*', &exitCode := 0), exitCode)

		ProcessDescription => (ComCall(6, this, 'ptr*', &processDescription := 0), CoTaskMem_String(processDescription))

		FrameInfosForFailedProcess => (ComCall(7, this, 'ptr*', frames := WebView2.FrameInfoCollection()), frames)
	}

	class ScriptDialogOpeningEventArgs extends WebView2.Base {
		static IID := '{7390bb70-abe0-4843-9529-f143b31b03d6}'

		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

		Kind => (ComCall(4, this, 'int*', &kind := 0), kind)	; COREWEBVIEW2_SCRIPT_DIALOG_KIND

		Message => (ComCall(5, this, 'ptr*', &message := 0), CoTaskMem_String(message))

		DefaultText => (ComCall(7, this, 'ptr*', &defaultText := 0), CoTaskMem_String(defaultText))

		ResultText {
			Get => (ComCall(8, this, 'ptr*', &resultText := 0), CoTaskMem_String(resultText))

			Set => ComCall(9, this, 'wstr', Value)
		}

		Accept() => ComCall(6, this)

		GetDeferral() => (ComCall(10, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}

	class Settings extends WebView2.Base {
		static IID := '{e562e4f0-d7fa-43ac-8d71-c05150499f00}'
		static IID_2 := '{ee9a0f68-f46c-4e32-ac23-ef8cac224d2a}'
		static IID_3 := '{fdb5ab74-af33-4854-84f0-0a631deb5eba}'
		static IID_4 := '{cb56846c-4168-4d53-b04f-03b6d6796ff2}'
		static IID_5 := '{183e7052-1d03-43a0-ab99-98e043b66b39}'
		static IID_6 := '{11cb3acd-9bc8-43b8-83bf-f40753714f87}'

		IsScriptEnabled {
			Get => (ComCall(3, this, 'int*', &isScriptEnabled := 0), isScriptEnabled)

			Set => ComCall(4, this, 'int', Value)
		}

		IsWebMessageEnabled {
			Get => (ComCall(5, this, 'int*', &isWebMessageEnabled := 0), isWebMessageEnabled)

			Set => ComCall(6, this, 'int', Value)
		}

		AreDefaultScriptDialogsEnabled {
			Get => (ComCall(7, this, 'int*', &areDefaultScriptDialogsEnabled := 0), areDefaultScriptDialogsEnabled)

			Set => ComCall(8, this, 'int', Value)
		}

		IsStatusBarEnabled {
			Get => (ComCall(9, this, 'int*', &isStatusBarEnabled := 0), isStatusBarEnabled)

			Set => ComCall(10, this, 'int', Value)
		}

		AreDevToolsEnabled {
			Get => (ComCall(11, this, 'int*', &areDevToolsEnabled := 0), areDevToolsEnabled)

			Set => ComCall(12, this, 'int', Value)
		}

		AreDefaultContextMenusEnabled {
			Get => (ComCall(13, this, 'int*', &enabled := 0), enabled)

			Set => ComCall(14, this, 'int', Value)
		}

		AreHostObjectsAllowed {
			Get => (ComCall(15, this, 'int*', &allowed := 0), allowed)

			Set => ComCall(16, this, 'int', Value)
		}

		IsZoomControlEnabled {
			Get => (ComCall(17, this, 'int*', &enabled := 0), enabled)

			Set => ComCall(18, this, 'int', Value)
		}

		IsBuiltInErrorPageEnabled {
			Get => (ComCall(19, this, 'int*', &enabled := 0), enabled)

			Set => ComCall(20, this, 'int', Value)
		}

		UserAgent {
			Get => (ComCall(21, this, 'ptr*', &userAgent := 0), CoTaskMem_String(userAgent))

			Set => ComCall(22, this, 'wstr', Value)
		}

		AreBrowserAcceleratorKeysEnabled {
			Get => (ComCall(23, this, 'int*', &areBrowserAcceleratorKeysEnabled := 0), areBrowserAcceleratorKeysEnabled)

			Set => ComCall(24, this, 'int', Value)
		}

		IsPasswordAutosaveEnabled {
			Get => (ComCall(25, this, 'int*', &value := 0), value)

			Set => ComCall(26, this, 'int', Value)
		}

		IsGeneralAutofillEnabled {
			Get => (ComCall(27, this, 'int*', &value := 0), value)

			Set => ComCall(28, this, 'int', Value)
		}

		IsPinchZoomEnabled {
			Get => (ComCall(29, this, 'int*', &enabled := 0), enabled)

			Set => ComCall(30, this, 'int', Value)
		}

		IsSwipeNavigationEnabled {
			Get => (ComCall(31, this, 'int*', &enabled := 0), enabled)

			Set => ComCall(32, this, 'int', Value)
		}
	}

	class SourceChangedEventArgs extends WebView2.Base {
		static IID := '{31e0e545-1dba-4266-8914-f63848a1f7d7}'

		IsNewDocument => (ComCall(3, this, 'int*', &isNewDocument := 0), isNewDocument)
	}

	class WebMessageReceivedEventArgs extends WebView2.Base {
		static IID := '{0f99a40c-e962-4207-9e92-e3d542eff849}'

		Source => (ComCall(3, this, 'ptr*', &source := 0), CoTaskMem_String(source))

		WebMessageAsJson => (ComCall(4, this, 'ptr*', &webMessageAsJson := 0), CoTaskMem_String(webMessageAsJson))

		TryGetWebMessageAsString() => (ComCall(5, this, 'ptr*', &webMessageAsString := 0), CoTaskMem_String(webMessageAsString))
	}

	class WebResourceRequest extends WebView2.Base {
		static IID := '{97055cd4-512c-4264-8b5f-e3f446cea6a5}'

		Uri {
			Get => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))

			Set => ComCall(4, this, 'wstr', Value)
		}

		Method {
			Get => (ComCall(5, this, 'ptr*', &method := 0), CoTaskMem_String(method))

			Set => ComCall(6, this, 'wstr', Value)
		}

		Content {
			Get => (ComCall(7, this, 'ptr*', &content := 0), content)	; IStream*

			Set => ComCall(8, this, 'ptr', Value)
		}

		Headers => (ComCall(9, this, 'ptr*', headers := WebView2.HttpRequestHeaders()), headers)
	}

	class WebResourceRequestedEventArgs extends WebView2.Base {
		static IID := '{453e667f-12c7-49d4-be6d-ddbe7956f57a}'

		Request => (ComCall(3, this, 'ptr*', request := WebView2.WebResourceRequest()), request)

		Response {
			Get => (ComCall(4, this, 'ptr*', response := WebView2.WebResourceResponse()), response)

			Set => ComCall(5, this, 'ptr', Value)
		}

		ResourceContext => (ComCall(7, this, 'int*', &context := 0), context)	; COREWEBVIEW2_WEB_RESOURCE_CONTEXT

		GetDeferral() => (ComCall(6, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}

	class WebResourceResponse extends WebView2.Base {
		static IID := '{aafcc94f-fa27-48fd-97df-830ef75aaec9}'

		Content {
			Get => (ComCall(3, this, 'ptr*', &content := 0), content)	; IStream*

			Set => ComCall(4, this, 'ptr', Value)
		}

		Headers => (ComCall(5, this, 'ptr*', headers := WebView2.HttpResponseHeaders()), headers)

		StatusCode {
			Get => (ComCall(6, this, 'int*', &statusCode := 0), statusCode)

			Set => ComCall(7, this, 'int', Value)
		}

		ReasonPhrase {
			Get => (ComCall(8, this, 'ptr*', &reasonPhrase := 0), CoTaskMem_String(reasonPhrase))

			Set => ComCall(9, this, 'wstr', Value)
		}
	}

	class WebResourceResponseReceivedEventArgs extends WebView2.Base {
		static IID := '{D1DB483D-6796-4B8B-80FC-13712BB716F4}'

		Request => (ComCall(3, this, 'ptr*', request := WebView2.WebResourceRequest()), request)

		Response => (ComCall(4, this, 'ptr*', response := WebView2.WebResourceResponseView()), response)
	}

	class WebResourceResponseView extends WebView2.Base {
		static IID := '{79701053-7759-4162-8F7D-F1B3F084928D}'

		Headers => (ComCall(3, this, 'ptr*', headers := WebView2.HttpResponseHeaders()), headers)

		StatusCode => (ComCall(4, this, 'int*', &statusCode := 0), statusCode)

		ReasonPhrase => (ComCall(5, this, 'ptr*', &reasonPhrase := 0), CoTaskMem_String(reasonPhrase))

		GetContent(handler) => ComCall(6, this, 'ptr', handler)	; ICoreWebView2WebResourceResponseViewGetContentCompletedHandler
	}

	class WindowFeatures extends WebView2.Base {
		static IID := '{5eaf559f-b46e-4397-8860-e422f287ff1e}'

		HasPosition => (ComCall(3, this, 'int*', &value := 0), value)

		HasSize => (ComCall(4, this, 'int*', &value := 0), value)

		Left => (ComCall(5, this, 'uint*', &value := 0), value)

		Top => (ComCall(6, this, 'uint*', &value := 0), value)

		Width => (ComCall(8, this, 'uint*', &value := 0), value)

		Height => (ComCall(7, this, 'uint*', &value := 0), value)

		ShouldDisplayMenuBar => (ComCall(9, this, 'int*', &value := 0), value)

		ShouldDisplayStatus => (ComCall(10, this, 'int*', &value := 0), value)

		ShouldDisplayToolbar => (ComCall(11, this, 'int*', &value := 0), value)

		ShouldDisplayScrollBars => (ComCall(12, this, 'int*', &value := 0), value)
	}

	class PHYSICAL_KEY_STATUS extends Buffer {
		__New() {
			super.__New(24, 0)
		}

		RepeatCount {
			Get => NumGet(this, 'uint')

			Set => NumPut('uint', Value, this)
		}

		ScanCode {
			Get => NumGet(this, 4, 'uint')

			Set => NumPut('uint', Value, this, 4)
		}

		IsExtendedKey {
			Get => NumGet(this, 8, 'int')

			Set => NumPut('int', Value, this, 8)
		}

		IsMenuKeyDown {
			Get => NumGet(this, 12, 'int')

			Set => NumPut('int', Value, this, 12)
		}

		WasKeyDown {
			Get => NumGet(this, 16, 'int')

			Set => NumPut('int', Value, this, 16)
		}

		IsKeyReleased {
			Get => NumGet(this, 20, 'int')

			Set => NumPut('int', Value, this, 20)
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class HTMLViewer {
	iControl := false

	Control {
		Get {
			return this.iControl
		}
	}

	Document {
	}

	Location {
	}

	__New(control) {
		this.iControl := control
	}

	Resized() {
	}

	Navigate(uri) {
	}

	Open() {
	}

	Close() {
	}

	Write(html, force := false) {
	}

	Reload() {
	}
}

class WebView2Viewer extends HTMLViewer {
	iWebView2 := false

	iHTML := false
	iHTMLFile := false

	WebView2 {
		Get {
			return this.iWebView2
		}
	}

	Document {
		Get {
			return this
		}
	}

	Location {
		Get {
			return this
		}
	}

	__New(control) {
		local application := Strsplit(A_ScriptName, ".")[1]

		this.iHTMLFile := temporaryFileName("HTML\" . application . "\" . "html" . Random(1, 1000), "html")

		super.__New(control)
	}

	Show() {
		if this.Control.Visible {
			if !this.WebView2
				this.iWebView2 := WebView2.create(this.Control.Hwnd)

			if this.iHTML
				this.Write(StrReplace(this.iHTML, "<div></div>", ""), true)
		}
	}

	Hide() {
		this.iWebView2 := false
	}

	Resized() {
		if this.WebView2
			this.WebView2.Fill()
	}

	Write(html, force := false) {
		local file

		if (force || (html != this.iHTML)) {
			if this.WebView2 {
				if !FileExist(this.iHTMLFile)
					FileAppend(html, this.iHTMLFile, "UTF-8")
				else
					loop
						try {
							file := FileOpen(this.iHTMLFile, "w-rwd", "UTF-8")

							file.Length := 0
							file.Write(html)

							file.Close()

							break
						}
						catch Any as exception {
							logError(exception)

							Sleep(100)
						}

				this.WebView2.CoreWebView2.Navigate(this.iHTMLFile)
				this.WebView2.CoreWebView2.Resume()
			}

			this.iHTML := html
		}
	}

	Reload() {
		if this.WebView2
			this.WebView2.CoreWebView2.Reload()
	}
}

class IEViewer extends HTMLViewer {
	iExplorer := false

	Explorer {
		Get {
			return this.iExplorer
		}
	}

	Document {
		Get {
			return this.Explorer.document
		}
	}

	Location {
		Get {
			return this.Explorer.location
		}
	}

	__New(control) {
		this.iExplorer := control.Value

		super.__New(control)
	}

	Navigate(uri) {
	}

	Open() {
		this.Document.open()
	}

	Close() {
		this.Document.close()
	}

	Write(html, force := false) {
		this.Document.write(html)
	}

	Resized() {
		if this.Control.Visible {
			this.Control.Visible := false
			this.Control.Visible := true
		}
	}

	Reload() {
		; this.Location.reload()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

CoTaskMem_String(ptr) {
	s := StrGet(ptr)

	DllCall('ole32\CoTaskMemFree', 'ptr', ptr)

	return s
}

fixIE(version := 0, exeName := "") {
	local previousValue := ""

	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := Map(7, 7000, 8, 8888, 9, 9999, 10, 10001, 11, 11001)

	if versions.Has(version)
		version := versions[version]

	if !exeName {
		if A_IsCompiled
			exeName := A_ScriptName
		else
			SplitPath(A_AhkPath, &exeName)
	}

	try {
		previousValue := RegRead("HKCU\" . key, exeName, "")
	}
	catch Any as exception {
		logError(exception, false, false)
	}

	try {
		if (version = "") {
			RegDelete("HKCU\" . key, exeName)
			RegDelete("HKLM\" . key, exeName)
		}
		else {
			RegWrite(version, "REG_DWORD", "HKCU\" . key, exeName)
			RegWrite(version, "REG_DWORD", "HKLM\" . key, exeName)
		}
	}
	catch Any as exception {
		logError(exception, false, false)
	}

	return previousValue
}

initializeHTMLViewer() {
	createWebView2Viewer(window, arguments*) {
		local control := window.Add("Picture", arguments*)
		local viewer := WebView2Viewer(control)

		viewer.Navigate("about:blank")

		control.HTMLViewer := viewer
		control.Document := viewer

		show() {
			control.Visible := true
			viewer.Show()
		}

		hide() {
			viewer.Hide()
			control.Visible := false
		}

		width() {
			local width

			ControlGetPos( , , &width, , control)

			return width
		}

		height() {
			local height

			ControlGetPos( , , , &height, control)

			return height
		}

		control.Show := (*) => show()
		control.Hide := (*) => hide()
		control.Navigate := (obj, uri) => viewer.Navigate(uri)
		control.Resized := (*) => viewer.Resized()
		control.getWidth := (*) => width()
		control.getHeight := (*) => height()

		return control
	}

	createIEViewer(window, options) {
		local control := window.Add("ActiveX", options, "shell.explorer")
		local viewer := IEViewer(control)
		local explorer := viewer.Explorer

		explorer.navigate("about:blank")

		control.HTMLViewer := viewer
		control.Document := explorer.document

		show() {
			control.Visible := true
		}

		hide() {
			control.Visible := false
		}

		width() {
			return explorer.Width
		}

		height() {
			return explorer.Height
		}

		control.Show := (*) => show()
		control.Hide := (*) => hide()
		control.Navigate := (obj, uri) => explorer.Navigate(uri)
		control.Resized := (*) => viewer.Resized()
		control.getWidth := (*) => width()
		control.getHeight := (*) => height()

		return control
	}

	fixIE(kExplorerVersions[Strsplit(A_ScriptName, ".")[1]])

	if ((getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "HTML", "Viewer", "IE11") = "WebView2") ||
		(getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
						, "General", "HTML Viewer", "IE11") = "WebView2")) {
		deleteDirectory(kTempDirectory . "HTML\" . Strsplit(A_ScriptName, ".")[1])

		DirCreate(kTempDirectory . "HTML\" . Strsplit(A_ScriptName, ".")[1])

		Window.DefineCustomControl("HTMLViewer", createWebView2Viewer)
	}
	else
		Window.DefineCustomControl("HTMLViewer", createIEViewer)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeHTMLViewer()