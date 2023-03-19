;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - .NET Common Language Runtime    ;;;
;;;                                                                         ;;;
;;;                         .NET Framework Interop                          ;;;
;;;              http://www.autohotkey.com/forum/topic26191.html            ;;;
;;;   Author:     Lexikos                                                   ;;;
;;;   Version:    1.2                                                       ;;;
;;;   Requires:	AutoHotkey_L v1.0.96+                                       ;;;
;;;                                                                         ;;;
;;;   Modified by evilC for compatibility with AHK_H as well as AHK_L       ;;;
;;;   "null" is a reserved word in AHK_H, so did search & Replace from      ;;;
;;;   "null" to "_null"                                                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

CLR_LoadLibrary(AssemblyName, AppDomain := 0) {
	local e, assembly, args, typeofAssembly

	if !AppDomain
		AppDomain := CLR_GetDefaultDomain()

	e := ComObjError(0)

	loop 1 {
		if assembly := AppDomain.Load_2(AssemblyName)
			break

		static _null := ComValue(13, 0)

		args := ComObjArray(0xC, 1),  args[0] := AssemblyName
		typeofAssembly := AppDomain.GetType().Assembly.GetType()

		if assembly := typeofAssembly.InvokeMember_3("LoadWithPartialName", 0x158, _null, _null, args)
			break

		if assembly := typeofAssembly.InvokeMember_3("LoadFrom", 0x158, _null, _null, args)
			break
	}

	ComObjError(e)

	return assembly
}

CLR_CreateObject(Assembly, TypeName, Args*) {
	local argCount, vargs

	if !(argCount := Args.MaxIndex())
		return Assembly.CreateInstance_2(TypeName, true)

	vargs := ComObjArray(0xC, argCount)

	loop argCount
		vargs[A_Index - 1] := Args[A_Index]

	static Array_Empty := ComObjArray(0xC, 0)
	static _null := ComValue(13, 0)

	return Assembly.CreateInstance_3(TypeName, true, 0, _null, vargs, _null, Array_Empty)
}

CLR_CompileC#(Code, References = "", AppDomain = 0, FileName = "", CompilerOptions = "") {
	return CLR_CompileAssembly(Code, References, "System", "Microsoft.CSharp.CSharpCodeProvider", AppDomain, FileName, CompilerOptions)
}

CLR_CompileVB(Code, References := "", AppDomain := 0, FileName := "", CompilerOptions := "") {
	return CLR_CompileAssembly(Code, References, "System", "Microsoft.VisualBasic.VBCodeProvider", AppDomain, FileName, CompilerOptions)
}

CLR_StartDomain(&AppDomain, BaseDirectory := "") {
	local args

	static _null := ComValue(13, 0)

	args := ComObjArray(0xC, 5), args[0] := "", args[2] := BaseDirectory, args[4] := ComValue(0xB, false)

	AppDomain := CLR_GetDefaultDomain().GetType().InvokeMember_3("CreateDomain", 0x158, _null, _null, args)

	return A_LastError >= 0
}

CLR_StopDomain(&AppDomain) {
	local hr, RtHst

	DllCall("SetLastError", "uint", hr := DllCall(NumGet(NumGet(RtHst := CLR_Start(), 0, "UPtr"), 20 * A_PtrSize, "UPtr"), "ptr", RtHst, "ptr", ComObjValue(AppDomain)))

	AppDomain := ""

	return hr >= 0
}

CLR_Start(Version := "") {
	local SystemRoot, CLSID_CorRuntimeHost, IID_ICorRuntimeHost

	static RtHst := 0

	; The simple method gives no control over versioning, and seems to load .NET v2 even when v4 is present:
	; return RtHst ? RtHst : (RtHst:=COM_CreateObject("CLRMetaData.CorRuntimeHost","{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}"), DllCall(NumGet(NumGet(RtHst+0)+40),"uint",RtHst))

	if RtHst
		return RtHst

	SystemRoot := EnvGet("SystemRoot")

	if (Version = "")
		loop Files, SystemRoot . "\Microsoft.NET\Framework" . (A_PtrSize = 8 ? "64" : "") "\*", "D"
			if (FileExist(A_LoopFilePath "\mscorlib.dll") && A_LoopFileName > Version)
				Version := A_LoopFileName

	if (DllCall("mscoree\CorBindToRuntimeEx", "wstr", Version, "ptr", 0, "uint", 0
			  , "ptr", CLR_GUID(&CLSID_CorRuntimeHost, "{CB2F6723-AB3A-11D2-9C40-00C04FA30A3E}")
			  , "ptr", CLR_GUID(&IID_ICorRuntimeHost,  "{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}"), "ptr*", &RtHst) >= 0)
		DllCall(NumGet(NumGet(RtHst, 0, "UPtr"), 10 * A_PtrSize, "UPtr"), "ptr", RtHst) ; Start

	return RtHst
}

CLR_GetDefaultDomain() {
	local p := 0
	local RtHst, p

	static defaultDomain := 0

	if !defaultDomain {
		if (DllCall(NumGet(NumGet(RtHst := CLR_Start(), 0, "UPtr"), 13 * A_PtrSize, "UPtr"), "ptr", RtHst, "ptr*", &p) >= 0)
			defaultDomain := ComValue(p), ObjRelease(p)
	}

	return defaultDomain
}

CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, AppDomain := 0, FileName := "", CompilerOptions := "") {
	local asmProvider, codeProvider, codeCompiler, Refs
	local prms, aRefs, compilerRes, errors, error_count, error_text, e, asmSystem

	if !AppDomain
		AppDomain := CLR_GetDefaultDomain()

	if !(asmProvider := CLR_LoadLibrary(ProviderAssembly, AppDomain))
	|| !(codeProvider := asmProvider.CreateInstance(ProviderType))
	|| !(codeCompiler := codeProvider.CreateCompiler())
		return 0

	if !(asmSystem := (ProviderAssembly = "System") ? asmProvider : CLR_LoadLibrary("System", AppDomain))
		return 0

	Refs := StrSplit(References, "|" , A_Space . A_Tab)

	aRefs := ComObjArray(8, Refs.Length)

	loop Refs.Length
		aRefs[A_Index - 1] := Refs[A_Index]

	; Set parameters for compiler.
	prms := CLR_CreateObject(asmSystem, "System.CodeDom.Compiler.CompilerParameters", aRefs)

	prms.OutputAssembly          := FileName
	prms.GenerateInMemory        := (FileName = "")
	prms.GenerateExecutable      := (SubStr(FileName, -4) = ".exe")
	prms.CompilerOptions         := CompilerOptions
	prms.IncludeDebugInformation := true

	compilerRes := codeCompiler.CompileAssemblyFromSource(prms, Code)

	if error_count := (errors := compilerRes.Errors).Count {
		error_text := ""

		loop error_count
			error_text .= ((e := errors.Item[A_Index - 1]).IsWarning ? "Warning " : "Error ") . e.ErrorNumber " on line " e.Line ": " e.ErrorText "`n`n"

		MsgBox(error_text, "Compilation Failed", 16)

		return 0
	}

	return compilerRes[FileName = "" ? "CompiledAssembly" : "PathToAssembly"]
}

CLR_GUID(&GUID, sGUID) {
	VarSetStrCapacity(&GUID, 16)

	return ((DllCall("ole32\CLSIDFromString", "wstr", sGUID, "ptr", GUID) >= 0) ? GUID : "")
}
