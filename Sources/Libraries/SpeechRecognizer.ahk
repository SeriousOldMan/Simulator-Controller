;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Recognizer               ;;;
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
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SpeechRecognizer                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SpeechRecognizer {
	iChoices := {}
	_grammarCallbacks := {}
	
	__New(recognizer := false, language := false) {
		dllName := "Speech.Recognizer.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Speech.Recognizer.dll not found in " . kBinariesDirectory))
				
				Throw "Unable to find Speech.Recognizer.dll in " . kBinariesDirectory . "..."
			}

			this.Instance := CLR_LoadLibrary(dllFile).CreateInstance("Speech.SpeechRecognizer")

			if (this.Instance.OkCheck() != "OK") {
				logMessage(kLogCritical, translate("Could not communicate with speech recognizer library (") . dllName . translate(")"))
				logMessage(kLogCritical, translate("Try running the Powershell command ""Get-ChildItem -Path '.' -Recurse | Unblock-File"" in the Binaries folder"))
				
				Throw "Could not communicate with speech recognizer library (" . dllName . ")..."
			}
			
			this.RecognizerList := this.createRecognizerList()
			
			if (this.RecognizerList.Length() == 0) {
				logMessage(kLogCritical, translate("No languages found while initializing speech recognition system - please install the speech recognition software"))
				
				showMessage(translate("No languages found while initializing speech recognition system - please install the speech recognition software") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
			
			if ((recognizer == true) && language) {
				for ignore, recognizerDescriptor in this.getRecognizerList()
					if (recognizerDescriptor["TwoLetterISOLanguageName"] = language) {
						recognizer := recognizerDescriptor["ID"]
						
						break
					}
			}
			else if (recognizer && (recognizer != true))
				for ignore, recognizerDescriptor in this.getRecognizerList()
					if (recognizerDescriptor["Name"] = recognizer) {
						recognizer := recognizerDescriptor["ID"]
						
						break
					}
			
			if (recognizer == true)
				recognizer := false

			this.initialize(recognizer ? recognizer : 0)
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing speech recognition module - please install the speech recognition software"))
			
			showMessage(translate("Error while initializing speech recognition module - please install the speech recognition software") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
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
	
	startRecognizer() {
		return this.Instance.StartRecognizer()
	}
	
	stopRecognizer() {
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
		if this.iChoices.HasKey(name)
			return this.iChoices[name]
		else
			return this.Instance.GetChoices(name)
	}
	
	setChoices(name, choiceList) {
		this.iChoices[name] := this.newChoices(choiceList)
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
			else if (SubStr(text, nextCharIndex, 1) = "(")
				grammars.Push(this.readBuiltinChoices(text, nextCharIndex))
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
	
	readBuiltinChoices(ByRef text, ByRef nextCharIndex) {
		builtin := false
		
		this.skipDelimiter("(", text, nextCharIndex)
		
		literalValue := this.readLiteral(text, nextCharIndex)
		
		if literalValue
			builtin := literalValue.Value
		else
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in GrammarCompiler.readBuiltinChoices..."
			
		this.skipDelimiter(")", text, nextCharIndex)
		
		return new GrammarBuiltinChoices(builtin)
	}
	
	readLiteral(ByRef text, ByRef nextCharIndex, delimiters := "{}[]()`,") {
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
			else if (isInstance(grammar, GrammarChoices) || isInstance(grammar, GrammarBuiltinChoices))
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
		
		return parser.Compiler.SpeechRecognizer.newChoices(values2String(", ", choices*))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarBuiltinChoices                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarBuiltinChoices {
	iBuiltin := false
	
	Builtin[] {
		Get {
			return this.iBuiltin
		}
	}
	
	__New(builtin) {
		this.iBuiltin := builtin
	}
	
	toString() {
		return "(" . this.Builtin . ")"
	}
	
	parse(parser) {
		choices := this.Builtin
		
		if (choices = "number")
			choices := "percent"
		
		return parser.Compiler.SpeechRecognizer.getChoices(choices)
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