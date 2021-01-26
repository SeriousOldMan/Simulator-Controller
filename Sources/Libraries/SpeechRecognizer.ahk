;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speach Recognizer               ;;;
;;;                                                                         ;;;
;;;   Part of this code is based on work of evilC. See the GitHub page      ;;;
;;;   https://github.com/evilC/HotVoice for mor information.                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SpeechRecognizer                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SpeechRecognizer {
	_grammarCallbacks := {}
	
	__New(recognizer := false) {
		dllName := "Speech.Recognizer.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Speech.Recognizer.dll not found in " . kBinariesDirectory))
				
				Throw "Unable to find Speech.Recognizer.dll in " . kBinariesDirectory . "..."
			}

			this.Instance := CLR_LoadLibrary(dllFile).CreateInstance("HotVoice.HotVoice")

			if (this.Instance.OkCheck() != "OK") {
				logMessage(kLogCritical, translate("Could not communicate with speech recognizer library (") . dllName . translate(")"))
				logMessage(kLogCritical, translate("Try running the powershell command ""Get-ChildItem -Path '.' -Recurse | Unblock-File"" in the Binaries folder."))
				
				Throw "Could not communicate with speech recognizer library (" . dllName . ")..."
			}
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing speech recognition system - please check the configuration"))

			title := translate("Modular Simulator Controller System")
			
			SplashTextOn 800, 60, %title%, % translate("Error while initializing speech recognition system - please check the configuration") . translate("...")
					
			Sleep 5000
		}
		
		this.RecognizerList := this.createRecognizerList()
		
		if (!(this.RecognizerList.Length() >= 0)) {
			logMessage(kLogCritical, translate("No languages found while initializing speech recognition system - please check the configuration"))

			title := translate("Modular Simulator Controller System")
			
			SplashTextOn 800, 60, %title%, % translate("No languages while initializing speech recognition system - please check the configuration") . translate("...")
					
			Sleep 5000
		}
		
		if (recognizer && (recognizer != true))
			for ignore, recognizerDescriptor in this.getRecognizerList()
				if (recognizerDescriptor["Name"] = recognizer) {
					recognizer := recognizerDescriptor["ID"]
					
					break
				}
		
		if (recognizer == true)
			recognizer := false
		
		this.initialize(recognizer ? recognizer : 0)
	}

	createRecognizerList() {
		recognizerList := []
		
		Loop % this.Instance.GetRecognizerCount() {
			index := A_Index - 1
			
			recognizerList.Push({ID: index, Name: this.Instance.GetRecognizerName(index)
							   , TwoLetterISOLanguageName: this.Instance.GetRecognizerTwoLetterISOLanguageName(index)
							   , LanguageDisplayName: this.Instance.GetRecognizerLanguageDisplayName(index)})
		}
		
		return recognizerList
	}
	
	initialize(id) {
		if (id > this.Instance.getRecognizerCount() - 1)
			Throw "Invalid recognizer ID (" . id . ")detected in SpeechRecognizer.initialize..."
		else
			return this.Instance.Initialize(id)
	}
	
	startRecognizer(){
		return this.Instance.StartRecognizer()
	}
	
	stopRecognizer(){
		return this.Instance.StopRecognizer()
	}
	
	getRecognizerList() {
		return this.RecognizerList
	}
	
	getWords(list) {
		result := []
		
		Loop % list.MaxIndex() + 1
			result.Push(list[A_Index - 1])
		
		return result
	}
	
	getChoices(name) {
		return this.Instance.GetChoices(name)
	}
	
	newGrammar() {
		return this.Instance.NewGrammar()
	}
	
	newChoices(choiceList) {
		return this.Instance.NewChoices(choiceList)
	}
	
	loadGrammar(name, grammar, callback) {
		if (this._grammarCallbacks.HasKey(name))
			Throw "Grammar " . name . " already exists in SpeechRecognizer.loadGrammar..."
		
		this._grammarCallbacks[name] := callback
		
		fn := this._onGrammarCallback.Bind(this)
		
		return this.Instance.LoadGrammar(grammar, name, fn)
	}
	
	compileGrammar(text) {
		return new GrammarCompiler(this).compileGrammar(text)
	}
	
	subscribeVolume(cb) {
		return this.Instance.SubscribeVolume(cb)
	}
	
	_onGrammarCallback(grammarName, wordArr) {
		words := this.getWords(wordArr)
		
		this._grammarCallbacks[grammarName].Call(grammarName, words)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarCompiler                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarCompiler {
	iSpeechRecognizer := false
	
	SpeechRecognizer[] {
		Get {
			return this.iSpeechRecognizer
		}
	}
	
	__New(recognizer) {
		this.iSpeechRecognizer := recognizer
	}
	
	compileGrammars(text) {
		grammars := []
		
		Loop Parse, text, `n, `r
		{
			line := Trim(A_LoopField)
			
			if ((line != "") && this.skipDelimiter(";", line, 1, false))
				line := ""
		
			if (incompleteLine && (line != "")) {
				line := incompleteLine . line
				incompleteLine := false
			}
			
			if ((line != "") && (SubStr(line, StrLen(line), 1) == "\"))
				incompleteLine := SubStr(line, 1, StrLen(line) - 1)
				
			if (!incompleteLine && (line != ""))
				grammars.Push(this.compileGrammar(line))
		}
		
		return grammars
	}
	
	compileGrammar(text) {
		local nextCharIndex := 1
		
		grammar := this.readGrammar(text, nextCharIndex)
		
		if !grammar
			Throw "Syntax error detected in """ . text . """ at 1 in GrammarCompiler.compileGrammar..."
		
		return this.parseGrammar(grammar)
	}
	
	readGrammar(ByRef text, ByRef nextCharIndex, level := 0) {
		this.skipWhiteSpace(text, nextCharIndex)
		
		if (SubStr(text, nextCharIndex, 1) = "[") {
			if (level = 0)
				return this.readGrammars(text, nextCharIndex, level)
			else
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in GrammarCompiler.readGrammar..."
		}
		else
			return this.readList(text, nextCharIndex)
	}
	
	readGrammars(ByRef text, ByRef nextCharIndex, level := 0) {
		grammars := []
		
		this.skipDelimiter("[", text, nextCharIndex)
		
		Loop {
			grammars.Push(this.readGrammar(text, nextCharIndex, level + 1))
			
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				break
		}

		this.skipDelimiter("]", text, nextCharIndex)
		
		return new GrammarGrammars(grammars)
	}
	
	readList(ByRef text, ByRef nextCharIndex) {
		grammars := []
		
		while !this.isEmpty(text, nextCharIndex) {
			this.skipWhiteSpace(text, nextCharIndex)
		
			if (SubStr(text, nextCharIndex, 1) = "{")
				grammars.Push(this.readChoices(text, nextCharIndex))
			else {
				literalValue := this.readLiteral(text, nextCharIndex)
			
				if literalValue
					grammars.Push(literalValue)
				else
					break
			}
		}

		return new GrammarList(grammars)
	}
	
	readChoices(ByRef text, ByRef nextCharIndex) {
		grammars := []
		
		this.skipDelimiter("{", text, nextCharIndex)
		
		Loop {
			literalValue := this.readLiteral(text, nextCharIndex)
		
			if literalValue
				grammars.Push(literalValue)
			else
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in GrammarCompiler.readChoices..."
			
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				break
		}

		this.skipDelimiter("}", text, nextCharIndex)
		
		return new GrammarChoices(grammars)
	}
	
	readLiteral(ByRef text, ByRef nextCharIndex, delimiters := "{}[]`,") {
		local literal
		
		length := StrLen(text)
		
		this.skipWhiteSpace(text, nextCharIndex)
		
		beginCharIndex := nextCharIndex
		
		Loop {
			character := SubStr(text, nextCharIndex, 1)
			
			if (InStr(delimiters, character) || (nextCharIndex > length)) {
				if (beginCharIndex == nextCharIndex)
					return false
				else
					return new GrammarLiteral(SubStr(text, beginCharIndex, nextCharIndex - beginCharIndex))
			}
			else
				nextCharIndex += 1
		}
	}
	
	isEmpty(ByRef text, ByRef nextCharIndex) {
		remainingText := Trim(SubStr(text, nextCharIndex))
		
		if ((remainingText != "") && this.skipDelimiter(";", remainingText, 1, false))
			remainingText := ""
		
		return (remainingText == "")
	}
	
	skipWhiteSpace(ByRef text, ByRef nextCharIndex) {
		length := StrLen(text)
		
		Loop {
			if (nextCharIndex > length)
				return
				
			if InStr(" `t`n`r", SubStr(text, nextCharIndex, 1))
				nextCharIndex += 1
			else
				return
		}
	}
	
	skipDelimiter(delimiter, ByRef text, ByRef nextCharIndex, throwError := true) {
		length := StrLen(delimiter)
		
		this.skipWhiteSpace(text, nextCharIndex)
	
		if (SubStr(text, nextCharIndex, length) = delimiter) {
			nextCharIndex += length
			
			return true
		}
		else if throwError
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in GrammarCompiler.skipDelimiter..."
		else
			return false
	}
	
	parseGrammar(grammar) {
		return this.createGrammarParser(grammar).parse(grammar)
	}
	
	createGrammarParser(grammar) {
		return new GrammarParser(this)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarParser                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarParser {
	iCompiler := false
	
	Compiler[] {
		Get {
			return this.iCompiler
		}
	}
	
	__New(compiler) {
		this.iCompiler := compiler
	}
	
	parse(grammar) {
		if isInstance(grammar, GrammarList)
			return this.parseList(grammar)
		else if isInstance(grammar, GrammarGrammars)
			return grammar.parse(this)
		else if isInstance(grammar, GrammarChoices) {
			newGrammar := this.Compiler.SpeechRecognizer.newGrammar()
			
			newGrammar.AppendChoices(grammar.parse(this))
			
			return newGrammar
		}
		else
			Throw "Grammars may only contain literals, choices or other grammars in GrammarParser.parse..."
	}
	
	parseList(grammarList) {
		newGrammar := this.Compiler.SpeechRecognizer.newGrammar()
		
		for ignore, grammar in grammarList.List
			if isInstance(grammar, GrammarLiteral)
				newGrammar.AppendString(grammar.Value)
			else if isInstance(grammar, GrammarChoices)
				newGrammar.AppendChoices(grammar.parse(this))
			else
				Throw "Grammar lists may only contain literals or choices in GrammarParser.parseList..."
		
		return newGrammar
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarGrammars                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarGrammars {
	iGrammarLists := []
	
	GrammarLists[] {
		Get {
			return this.iGrammarLists
		}
	}
	
	__New(grammarLists) {
		this.iGrammarLists := grammarLists
	}
	
	toString() {
		result := "["
			
		for ignore, list in this.GrammarLists {
			if (A_Index > 1)
				result .= ", "
			
			result .= list.toString()
		}
			
		return (result . "]")
	}
	
	parse(parser) {
		grammars := []
		
		for ignore, list in this.GrammarLists
			grammars.Push(parser.parseList(list))
		
		grammar := parser.Compiler.SpeechRecognizer.newGrammar()
		
		grammar.AppendGrammars(grammars*)
		
		return grammar
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarChoices                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarChoices {
	iChoices := []
	
	Choices[] {
		Get {
			return this.iChoices
		}
	}
	
	__New(choices) {
		this.iChoices := choices
	}
	
	toString() {
		result := "{"
			
		for ignore, choice in this.Choices {
			if (A_Index > 1)
				result .= ", "
			
			result .= choice.toString()
		}
			
		return (result . "}")
	}
	
	parse(parser) {
		choices := []
		
		for ignore, choice in this.Choices {
			if !isInstance(choice, GrammarLiteral)
				Throw "Invalid choice (" . choice.toString() . ") detected in GrammarChoices.parse..."
			
			choices.Push(choice.Value)
		}
		
		return parser.Compiler.SpeechRecognizer.newChoices(choices*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarList                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarList {
	iList := []
	
	List[] {
		Get {
			return this.iList
		}
	}
	
	__New(list) {
		this.iList := list
	}
	
	toString() {
		result := ""
			
		for ignore, value in this.List {
			if (A_Index > 1)
				result .= " "
			
			result .= value.toString()
		}
			
		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarLiteral                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarLiteral {
	iValue := []
	
	Value[] {
		Get {
			return this.iValue
		}
	}
	
	__New(value) {
		this.iValue := value
	}
	
	toString() {
		return this.Value
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

; =============================================================================
;                           .NET Framework Interop
;                http://www.autohotkey.com/forum/topic26191.html
; =============================================================================
;
;   Author:     Lexikos
;   Version:    1.2
;   Requires:	AutoHotkey_L v1.0.96+
;
; Modified by evilC for compatibility with AHK_H as well as AHK_L
; "null" is a reserved word in AHK_H, so did search & Replace from "null" to "_null"

CLR_LoadLibrary(AssemblyName, AppDomain=0)
{
	if !AppDomain
		AppDomain := CLR_GetDefaultDomain()
	e := ComObjError(0)
	Loop 1 {
		if assembly := AppDomain.Load_2(AssemblyName)
			break
		static _null := ComObject(13,0)
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

CLR_CreateObject(Assembly, TypeName, Args*)
{
	if !(argCount := Args.MaxIndex())
		return Assembly.CreateInstance_2(TypeName, true)
	
	vargs := ComObjArray(0xC, argCount)
	Loop % argCount
		vargs[A_Index-1] := Args[A_Index]
	
	static Array_Empty := ComObjArray(0xC,0), _null := ComObject(13,0)
	
	return Assembly.CreateInstance_3(TypeName, true, 0, _null, vargs, _null, Array_Empty)
}

CLR_CompileC#(Code, References="", AppDomain=0, FileName="", CompilerOptions="")
{
	return CLR_CompileAssembly(Code, References, "System", "Microsoft.CSharp.CSharpCodeProvider", AppDomain, FileName, CompilerOptions)
}

CLR_CompileVB(Code, References="", AppDomain=0, FileName="", CompilerOptions="")
{
	return CLR_CompileAssembly(Code, References, "System", "Microsoft.VisualBasic.VBCodeProvider", AppDomain, FileName, CompilerOptions)
}

CLR_StartDomain(ByRef AppDomain, BaseDirectory="")
{
	static _null := ComObject(13,0)
	args := ComObjArray(0xC, 5), args[0] := "", args[2] := BaseDirectory, args[4] := ComObject(0xB,false)
	AppDomain := CLR_GetDefaultDomain().GetType().InvokeMember_3("CreateDomain", 0x158, _null, _null, args)
	return A_LastError >= 0
}

CLR_StopDomain(ByRef AppDomain)
{	; ICorRuntimeHost::UnloadDomain
	DllCall("SetLastError", "uint", hr := DllCall(NumGet(NumGet(0+RtHst:=CLR_Start())+20*A_PtrSize), "ptr", RtHst, "ptr", ComObjValue(AppDomain))), AppDomain := ""
	return hr >= 0
}

; NOTE: IT IS NOT NECESSARY TO CALL THIS FUNCTION unless you need to load a specific version.
CLR_Start(Version="") ; returns ICorRuntimeHost*
{
	static RtHst := 0
	; The simple method gives no control over versioning, and seems to load .NET v2 even when v4 is present:
	; return RtHst ? RtHst : (RtHst:=COM_CreateObject("CLRMetaData.CorRuntimeHost","{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}"), DllCall(NumGet(NumGet(RtHst+0)+40),"uint",RtHst))
	if RtHst
		return RtHst
	EnvGet SystemRoot, SystemRoot
	if Version =
		Loop % SystemRoot "\Microsoft.NET\Framework" (A_PtrSize=8?"64":"") "\*", 2
			if (FileExist(A_LoopFileFullPath "\mscorlib.dll") && A_LoopFileName > Version)
				Version := A_LoopFileName
	if DllCall("mscoree\CorBindToRuntimeEx", "wstr", Version, "ptr", 0, "uint", 0
	, "ptr", CLR_GUID(CLSID_CorRuntimeHost, "{CB2F6723-AB3A-11D2-9C40-00C04FA30A3E}")
	, "ptr", CLR_GUID(IID_ICorRuntimeHost,  "{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}")
	, "ptr*", RtHst) >= 0
		DllCall(NumGet(NumGet(RtHst+0)+10*A_PtrSize), "ptr", RtHst) ; Start
	return RtHst
}

CLR_GetDefaultDomain()
{
	static defaultDomain := 0
	if !defaultDomain
	{	; ICorRuntimeHost::GetDefaultDomain
		if DllCall(NumGet(NumGet(0+RtHst:=CLR_Start())+13*A_PtrSize), "ptr", RtHst, "ptr*", p:=0) >= 0
			defaultDomain := ComObject(p), ObjRelease(p)
	}
	return defaultDomain
}

CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, AppDomain=0, FileName="", CompilerOptions="")
{
	if !AppDomain
		AppDomain := CLR_GetDefaultDomain()
	
	if !(asmProvider := CLR_LoadLibrary(ProviderAssembly, AppDomain))
	|| !(codeProvider := asmProvider.CreateInstance(ProviderType))
	|| !(codeCompiler := codeProvider.CreateCompiler())
		return 0

	if !(asmSystem := (ProviderAssembly="System") ? asmProvider : CLR_LoadLibrary("System", AppDomain))
		return 0
	
	; Convert | delimited list of references into an array.
	StringSplit, Refs, References, |, %A_Space%%A_Tab%
	aRefs := ComObjArray(8, Refs0)
	Loop % Refs0
		aRefs[A_Index-1] := Refs%A_Index%
	
	; Set parameters for compiler.
	prms := CLR_CreateObject(asmSystem, "System.CodeDom.Compiler.CompilerParameters", aRefs)
	, prms.OutputAssembly          := FileName
	, prms.GenerateInMemory        := FileName=""
	, prms.GenerateExecutable      := SubStr(FileName,-3)=".exe"
	, prms.CompilerOptions         := CompilerOptions
	, prms.IncludeDebugInformation := true
	
	; Compile!
	compilerRes := codeCompiler.CompileAssemblyFromSource(prms, Code)
	
	if error_count := (errors := compilerRes.Errors).Count
	{
		error_text := ""
		Loop % error_count
			error_text .= ((e := errors.Item[A_Index-1]).IsWarning ? "Warning " : "Error ") . e.ErrorNumber " on line " e.Line ": " e.ErrorText "`n`n"
		MsgBox, 16, Compilation Failed, %error_text%
		return 0
	}
	; Success. Return Assembly object or path.
	return compilerRes[FileName="" ? "CompiledAssembly" : "PathToAssembly"]
}

CLR_GUID(ByRef GUID, sGUID)
{
	VarSetCapacity(GUID, 16, 0)
	return DllCall("ole32\CLSIDFromString", "wstr", sGUID, "ptr", &GUID) >= 0 ? &GUID : ""
}
