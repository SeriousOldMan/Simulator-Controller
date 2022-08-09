;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AHKUnit test framework          ;;;
;;;                                         (by Kentaro Sato - see License) ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
#Include AHKUnit\AHKUnit\AhkUnit.ahk
#Include AHKUnit\AHKUnit\Assert.ahk
#Include AHKUnit\AHKUnit\Framework.ahk
#Include AHKUnit\AHKUnit\GuiRunner.ahk
#Include AHKUnit\AHKUnit\ParentReporter.ahk
#Include AHKUnit\AHKUnit\Runner.ahk
*/

class AhkUnit {
	__New() {
	}

	SetDefaultRunner(runnerClass) {
		AhkUnit.defaultRunner := runnerClass
	}
	
	RunTestClass(testClass, runner = false) {
		if (!runner) {
			runner := new AhkUnit.defaultRunner()
			runner.Default()
		}
		runner.Run(testClass)
		return runner
	}
	
	AddTest(testInstance) { ; deprecated
		AhkUnit.AddTestClass(testInstance.base)
	}
	
	AddTestClass(testClass) {
		AhkUnit.testClasses.Insert(testClass)
	}
	
	Run(runner = false) {
		if (AhkUnit.nesting != 0) {
			return
		}
		if (!runner) {
			runner := new AhkUnit.defaultRunner()
			runner.Default()
		}
		for key in AhkUnit.testClasses {
			runner.Run(AhkUnit.testClasses[key])
		}
	}
	
	Begin() {
		AhkUnit.nesting++
	}
	
	End(runner = false) {
		if (AhkUnit.nesting == 0) {
			MsgBox,AhkUnit.Begin() not called.
			Exit
		}
		AhkUnit.nesting--
		return AhkUnit.Run(runner)
	}
	
	class FrameworkCore {
		; method_
		; result_, message_, assertionCount_
		
		SetUpBeforeClass() {
		}
		
		TearDownAfterClass() {
		}
		
		SetUp() {
		}
		
		TearDown() {
		}
		
		AuInit(method) {
			this.method_ := method
			this.result_ := true
			this.message_ := ""
			this.assertionCount_ := 0
		}
		
		AuSuccess() {
			this.assertionCount_++
		}
		
		AuFailed(message) {
			this.assertionCount_++
			this.result_ := false
			if (this.message_ != "") {
				this.message_ .= "`n"
			}
			this.message_ .= message
		}
		
		AuGetMethod() {
			return this.method_
		}
		
		AuGetResult() {
			return this.result_
		}
		
		AuGetMessage() {
			return this.message_
		}
		
		AuGetAssertionCount() {
			return this.assertionCount_
		}
	}
}

AhkUnit.nesting := 0
AhkUnit.testClasses := []
AhkUnit.SetDefaultRunner(AhkUnit.Runner)


class AhkUnit_GuiRunner extends AhkUnit_Runner {
	static nextGuiWindowIndex := 1
	; guiWindowName
	; savedDefaultGuiWindow
	
	__New() {
		global ahkUnitResultTree
		base.__New()
		guiWindowIndex := AhkUnit_GuiRunner.nextGuiWindowIndex++
		this.guiWindowName := "AhkUnitGuiRunner" . guiWindowIndex
		this.GuiBegin_()
		Gui,Add,TreeView,vahkUnitResultTree R30 w600
		Gui,Add,Button,Default W72 gAhkUnitGuiOk,&OK
		Gui,Add,Button,W72 gAhkUnitGuiReload xp+80 yp+0,&Reload
		Gui,+LabelAhkUnitGui
		this.GuiEnd_()
	}
	
	Default() {
		base.Default()
		this.ShowReport()
	}
	
	GuiBegin_() {
		this.savedDefaultGuiWindow := A_Gui ? A_Gui : 1
		guiWindowName := this.guiWindowName
		Gui,%guiWindowName%:Default
	}
	
	GuiEnd_() {
		savedDefaultGuiWindow := this.savedDefaultGuiWindow
		Gui,%savedDefaultGuiWindow%:Default
		this.savedDefaultGuiWindow := 0
	}
	
	Run(params*) {
		global ahkUnitResultTree
		base.Run(params*)
		this.GuiBegin_()
		GuiControl,-Redraw,ahkUnitResultTree
		count := this.GetCount()
		statusString := this.testClass.__Class
		statusOptions := ""
		if (count.failure) {
			statusOptions := "Expand Bold"
		} else if (count.incomplete) {
			statusString .= ": Incomplete"
		} else {
			statusString .= ": OK"
		}
		statusItem := TV_Add(statusString, 0, statusOptions)
		reportItem := TV_Add(this.GetResult(), statusItem)
		reportItem := TV_Add(this.GetCountString(), statusItem)
		message := this.GetMessage()
		if (message != "") {
			reportItem := TV_Add("", statusItem)
			reportItem := this.TV_AddMultiLine(message, statusItem)
		}
		GuiControl,+Redraw,ahkUnitResultTree
		this.GuiEnd_()
	}
	
	TV_AddMultiLine(string, parent = 0, options = "Expand") {
		while (SubStr(string, 0, 1) == "`n") {
			StringTrimRight,string,string,1
		}
		previousItem := 0
		loop,parse,string,`n
		{
			itemString := A_LoopField
			itemParent := parent
			if (previousItem && SubStr(itemString, 1, 2) == "  ") {
				itemParent := previousItem
				StringTrimLeft,itemString,itemString,2
			}
			newItem := TV_Add(itemString, itemParent, options)
			if (itemParent == parent) {
				previousItem := newItem
			}
	    }
	}
	
	ShowReport() {
		guiWindowName := this.guiWindowName
		Gui,%guiWindowName%:Show
	}
}

AhkUnit.GuiRunner := AhkUnit_GuiRunner
AhkUnit.SetDefaultRunner(AhkUnit.GuiRunner)

if (false) {
	; currently we cannot close each runner independently
	AhkUnitGuiClose:
		ExitApp
		return
	AhkUnitGuiOk:
		ExitApp
		return
	AhkUnitGuiReload:
		Reload
		return
}

class AhkUnit_Assert {
	mixin(destObject, sourceClass) {
		for property in sourceClass {
			if (SubStr(property, 1, 2) != "__") {
				destObject[property] := sourceClass[property]
			}
		}
	}
	
	class Base_ {
	}
	
	class Case_ {
		; noCase
	
		IgnoreCase() {
			this.noCase := true
			return this
		}
	}
	
	class Arg1_ extends AhkUnit_Assert.Base_ {
		; actual
		
		__New(actual) {
			base.__New()
			this.actual := actual
		}
	}
	
	class Arg2_ extends AhkUnit_Assert.Base_ {
		; expected, actual
		
		__New(expected, actual) {
			base.__New()
			this.expected := expected
			this.actual := actual
		}
	}
	
	class Message extends AhkUnit_Assert.Base_ {
		; message
		
		__New(message) {
			base.__New()
			this.message := message
		}
		
		Evaluate() {
			return false
		}
		
		GetMesssage() {
			return this.message
		}
	}
	
	class Equal extends AhkUnit_Assert.Arg2_ {
		__New(params*) {
			base.__New(params*)
			AhkUnit.Assert.mixin(this, AhkUnit.Assert.Case_)
		}
		
		Evaluate() {
			if (this.noCase) {
				return this.expected = this.actual
			}
			return this.expected == this.actual
		}
		
		GetMesssage() {
			message := "Expected: " this.expected "`n"
			message .= "Actual  : " this.actual
			return message
		}
	}
	
	class NotEqual extends AhkUnit_Assert.Equal {
		Evaluate() {
			return !base.Evaluate()
		}
		
		GetMesssage() {
			return "Bad value: " . this.actual
		}
	}
	
	class ObjectEqual extends AhkUnit_Assert.Arg2_ {
		; message
		
		Evaluate() {
			if (!IsObject(this.expected) || !IsObject(this.actual)) {
				this.message := "Not an object"
				return false
			}
			expected := this.expected._NewEnum()
			actual := this.actual._NewEnum()
			; easy comparison
			messageExpected := ""
			messageActual := ""
			while expected[expectedKey, expectedValue] {
				actual[actualKey, actualValue]
				if (expectedKey != actualKey) {
					messageExpected .= ", [" . expectedKey . "]"
					messageActual .= ", [" . actualKey . "]"
					break
				}
				if (!(expectedValue == actualValue)) {
					messageExpected .= ", [" . expectedKey . "] = " . expectedValue
					messageActual .= ", [" . actualKey . "] = " . actualValue
				}
			}
			this.message := ""
			if (messageExpected != "") {
				this.message := SubStr(messageExpected, 3) . "`n" . SubStr(messageActual, 3)
			}
			if (actual[actualKey, actualValue]) {
				if (this.message != "") {
					this.message .= "`n"
				}
				this.message .= "Excess key: " . actualKey
			}
			return this.message == ""
		}
		
		GetMesssage() {
			return this.message
		}
	}
	
	class Not extends AhkUnit_Assert.Base_ {
		; assertion, message
		
		__New(assertion, message = "") {
			base.__New()
			this.assertion := assertion
			this.message := message
		}
		
		Evaluate() {
			return !this.assertion.Evaluate()
		}
		
		GetMesssage() {
			if (this.message == "") {
				return "Not: " . this.assertion.GetMessage()
			}
			return this.message
		}
	}
	
	class False extends AhkUnit_Assert.Arg1_ {
		; isStrict
		
		Strict() {
			this.isStrict := true
			return this
		}
		
		Evaluate() {
			return this.isStrict ? (this.actual == false) : !this.actual
		}
		
		GetMesssage() {
			return "False expected: " . this.actual
		}
	}
	
	class True extends AhkUnit_Assert.False {
		Evaluate() {
			return this.isStrict ? (this.actual == true) : !!this.actual
		}
		
		GetMesssage() {
			return "True expected: " . this.actual
		}
	}
	
	class Empty extends AhkUnit_Assert.Arg1_ {
		Evaluate() {
			return this.actual == ""
		}
		
		GetMesssage() {
			return "Empty expected: " . this.actual
		}
	}
	
	class NotEmpty extends AhkUnit_Assert.Empty {
		Evaluate() {
			return !base.Evaluate()
		}
		
		GetMesssage() {
			return "Non-empty expected"
		}
	}
	
	class Object extends AhkUnit_Assert.Arg1_ {
		Evaluate() {
			return IsObject(this.actual)
		}
		
		GetMesssage() {
			return "Object expected: " . this.actual
		}
	}
}

AhkUnit.Assert := AhkUnit_Assert

class AhkUnit_Runner {
	; result, message, count
	; test
	
	Default() {
	}
	
	Run(testClass) {
		this.result := ""
		this.message := ""
		this.count := { test: 0, assertion: 0, failure: 0, incomplete: 0 }
		this.testClass := testClass
		try {
			testClass.SetUpBeforeClass()
		} catch e {
			this._AddFailure("Exception thrown in SetUpBeforeClass")
			return
		}
		testInstances := Object()
		for key in testClass {
			if (SubStr(key, -3) == "Test") {
				this.count.test++
				try {
					testInstance := { base: testClass }
					testInstance.__New()
					; cannot do %test_class_name% without global %test_class_name%.
					; also, directly calling __New() doesn't initialize instance variables.
				}
				catch {
					this._AddFailure("Exception thrown in constructor")
					continue
				}
				try {
					testInstance.SetUp()
				}
				catch {
					this._AddFailure("Exception thrown in SetUp")
					continue
				}
				testInstances[key] := testInstance
			}
		}
		for key, testInstance in testInstances {
			try {
				testInstance.AuInit(key)
				testInstance[key]()
			} catch e {
				thrownClass := (e.__Class == "") ? "Exception" : e.__Class
				expectedClass := testInstance[key . "_throws"]
				if (expectedClass != "") {
					assertion := new AhkUnit.Assert.Equal("throw " . expectedClass, "throw " . thrownClass)
					caller := IsObject(e) ? e : Object()
					testInstance.Assert_(assertion, "", caller)
				} else {
					this._AddFailure("Exception thrown in " . key)
					continue
				}
			}
			assertionCount := testInstance.AuGetAssertionCount()
			this.count.assertion += assertionCount
			if (assertionCount == 0) {
				this.result .= "I"
				this.count.incomplete++
				this.message .= key . " has no assertions.`n`n"
			} else if (!testInstance.AuGetResult()) {
				this._AddFailure(testInstance.AuGetMessage())
			} else {
				this.result .= "."
			}
		}
		for key, testInstance in testInstances {
			try {
				testInstance.TearDown()
			}
			catch {
				this._AddFailure("Exception thrown in TearDown")
			}
		}
		try {
			testClass.TearDownAfterClass()
		} catch e {
			this._AddFailure("Exception thrown in TearDownAfterClass")
		}
	}
	
	_AddFailure(message) {
		this.result .= "F"
		this.count.failure++
		this.message .= message . "`n`n"
	}
	
	GetCountString() {
		count := this.GetCount()
		report := "Tests: " . count.test . ", Assertions: " . count.assertion
		if (count.failure) {
			report .= ", Failures: " . count.failure
		}
		if (count.incomplete) {
			report .= ", Incomplete: " . count.incomplete
		}
		return report
	}
	
	GetReport() {
		result := this.GetResult()
		count := this.GetCount()
		report := "Result: " . result . "`n"
		if (!count.failure) {
			report .= "OK, "
		}
		report .= this.GetCountString() . "`n`n"
		report .= this.GetMessage()
		return report
	}
	
	GetResult() {
		return this.result
	}
	
	GetMessage() {
		return this.message
	}
	
	GetCount() {
		return this.count
	}
}

AhkUnit.Runner := AhkUnit_Runner

class Assert extends AhkUnit.FrameworkCore {
	__New() {
		base.__New()
		this.callstackDepth := 0
	}
	
	; deprecated
	SetFile(filePath) {
	}
	
	ReportParent_(increase) {
		if (increase) {
			this.callstackDepth++
		} else {
			this.callstackDepth--
		}
	}
	
	Assert_(assertion, message, caller) {
		if (IsObject(assertion)) {
			if (assertion.Evaluate()) {
				this.AuSuccess()
				return ""
			}
		} else {
			assertion := new AhkUnit.Assert.Message("Bad assertion object.")
		}
		caller := IsObject(caller) ? caller : Exception("", -caller - 1)
		file := caller.file
		line := caller.line
		pos := ""
		if (file != "") {
			pos .= file
		}
		if (line != "") {
			pos .= " (" . line . ")"
		}
		if (pos != "") {
			pos .= ", "
		}
		pos .= this.AuGetMethod()
		if (message != "") {
			message := ": " . message
		}
		assertionMessage := assertion.GetMesssage()
		if (assertionMessage != "") {
			StringReplace,assertionMessage,assertionMessage,`n,% "`n  ",All
			assertionMessage := "  " . assertionMessage
			message .= "`n" . assertionMessage
		}
		this.AuFailed(pos . message)
	}
	
	Assert(assertion, message = "") {
		this.Assert_(assertion, message, 2 + this.callstackDepth)
	}
	
	AssertEqual(expected, actual, message = "") {
		this.Assert(new AhkUnit.Assert.Equal(expected, actual), message)
	}
	
	AssertNotEqual(expected, actual, message = "") {
		this.Assert(new AhkUnit.Assert.NotEqual(expected, actual), message)
	}
	
	AssertEqualIgnoreCase(expected, actual, message = "") {
		this.Assert(new AhkUnit.Assert.Equal(expected, actual).IgnoreCase(), message)
	}
	
	AssertNotEqualIgnoreCase(expected, actual, message = "") {
		this.Assert(new AhkUnit.Assert.NotEqual(expected, actual).IgnoreCase(), message)
	}
	
	AssertObjectEqual(expected, actual, message = "") {
		this.Assert(new AhkUnit.Assert.ObjectEqual(expected, actual), message)
	}
	
	AssertTrue(actual, message = "") {
		this.Assert(new AhkUnit.Assert.True(actual), message)
	}
	
	AssertFalse(actual, message = "") {
		this.Assert(new AhkUnit.Assert.False(actual), message)
	}
	
	AssertEmpty(actual, message = "") {
		this.Assert(new AhkUnit.Assert.Empty(actual), message)
	}
	
	AssertNotEmpty(actual, message = "") {
		this.Assert(new AhkUnit.Assert.NotEmpty(actual), message)
	}
	
	AssertObject(actual, message = "") {
		this.Assert(new AhkUnit.Assert.Object(actual), message)
	}
}