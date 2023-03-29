;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AHKUnit test framework          ;;;
;;;                                         (by Kentaro Sato - see License) ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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
	static Runner := false
	static sDefaultRunner := false
	static testClasses := []
	static nesting := 0

	__New() {
	}

	static SetDefaultRunner(runnerClass) {
		AhkUnit.sDefaultRunner := runnerClass
	}

	static DefaultRunner() {
		return AhkUnit.sDefaultRunner
	}

	static RunTestClass(testClass, runner := false) {
		if (!runner) {
			runner := AhkUnit.DefaultRunner()
			runner.Default()
		}
		runner.Run(testClass)
		return runner
	}

	static AddTestClass(testClass) {
		AhkUnit.testClasses.Push(testClass)
	}

	static Run(runner := false) {
		if (AhkUnit.nesting != 0) {
			return
		}
		if (!runner) {
			runner := AhkUnit.DefaultRunner()
			runner.Default()
		}
		for key, value in AhkUnit.testClasses {
			runner.Run(value)
		}
	}

	static Begin() {
		AhkUnit.nesting++
	}

	static End(runner := false) {
		if (AhkUnit.nesting == 0) {
			MsgBox("AhkUnit.Begin() not called.")
			Exit()
		}
		AhkUnit.nesting--
		return AhkUnit.Run(runner)
	}

	class FrameworkCore {
		; method_
		; result_, message_, assertionCount_

		__New() {
		}

		static SetUpBeforeClass() {
		}

		static TearDownAfterClass() {
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

AhkUnit.SetDefaultRunner(AhkUnit.Runner)

class AhkUnit_GuiRunner extends AhkUnit_Runner {
	myGui := false
	myResultTree := false

	__New() {
		super.__New()

		this.GuiBegin_()

		myGui := Gui()
		this.myGui := myGui

		this.myResultTree := myGui.Add("TreeView", "R30 w600")

		myGui.OnEvent("Close", AhkUnitGuiClose)
		myGui.Add("Button", "Default W72", "&OK").OnEvent("Click", AhkUnitGuiOk)
		myGui.Add("Button", "W72  xp+80 yp+0", "&Reload").OnEvent("Click", AhkUnitGuiReload)

		this.GuiEnd_()
	}

	Default() {
		super.Default()
		this.ShowReport()
	}

	GuiBegin_() {
	}

	GuiEnd_() {
	}

	Run(params*) {
		super.Run(params*)
		this.GuiBegin_()
		this.myResultTree.Opt("-Redraw")
		count := this.GetCount()
		statusString := this.testClass.Prototype.__Class
		statusOptions := ""
		if (count.failure) {
			statusOptions := "Expand Bold"
		} else if (count.incomplete) {
			statusString .= ": Incomplete"
		} else {
			statusString .= ": OK"
		}
		statusItem := this.myResultTree.Add(statusString, 0, statusOptions)
		reportItem := this.myResultTree.Add(this.GetResult(), statusItem)
		reportItem := this.myResultTree.Add(this.GetCountString(), statusItem)
		message := this.GetMessage()
		if (message != "") {
			reportItem := this.myResultTree.Add("", statusItem)
			reportItem := this.TV_AddMultiLine(message, statusItem)
		}
		this.myResultTree.Opt("+Redraw")
		this.GuiEnd_()
	}

	TV_AddMultiLine(string, parent := 0, options := "Expand") {
		while (SubStr(string, -1, 1) == "`n") {
			string := SubStr(string, 1, -1*(1))
		}
		previousItem := 0
		Loop Parse, string, "`n"
		{
			itemString := A_LoopField
			itemParent := parent
			if (previousItem && SubStr(itemString, 1, 2) == "  ") {
				itemParent := previousItem
				itemString := SubStr(itemString, (2)+1)
			}
			newItem := this.myResultTree.Add(itemString, itemParent, options)
			if (itemParent == parent) {
				previousItem := newItem
			}
	    }
	}

	ShowReport() {
		this.myGui.Show()
	}
}

AhkUnit.GuiRunner := AhkUnit_GuiRunner()
AhkUnit.SetDefaultRunner(AhkUnit.GuiRunner)

AhkUnitGuiClose(*) {
	ExitApp()
	return
}

AhkUnitGuiOk(*) {
	ExitApp()
	return
}

AhkUnitGuiReload(*) {
	Reload()
	return
}

class AhkUnit_Assert {
	static mixin(destObject, sourceClass) {
		for property in sourceClass.Prototype.OwnProps() {
			if ((SubStr(property, 1, 2) != "__") && sourceClass.HasProp(property)) {
				destObject.DefineProp(property, sourceClass.GetOwnPropDesc(property))
			}
		}
	}

	class Base_ {
		noCase := false

		__New() {
		}
	}

	class Case_ {
		IgnoreCase() {
			this.noCase := true
			return this
		}
	}

	class Arg1_ extends AhkUnit_Assert.Base_ {
		; actual

		__New(actual) {
			super.__New()
			this.actual := actual
		}
	}

	class Arg2_ extends AhkUnit_Assert.Base_ {
		; expected, actual

		__New(expected, actual) {
			super.__New()
			this.expected := expected
			this.actual := actual
		}
	}

	class Message extends AhkUnit_Assert.Base_ {
		; message

		__New(message) {
			super.__New()
			this.message := message
		}

		Evaluate() {
			return false
		}

		GetMesssage() {
			return this.message
		}
	}

	class Equals extends AhkUnit_Assert.Arg2_ {
		__New(params*) {
			super.__New(params*)
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

	class NotEquals extends AhkUnit_Assert.Equals {
		Evaluate() {
			return !super.Evaluate()
		}

		GetMesssage() {
			return "Bad value: " . this.actual
		}
	}

	class AssertNot extends AhkUnit_Assert.Base_ {
		; assertion, message

		__New(assertion, message := "") {
			super.__New()
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

	class AssertFalse extends AhkUnit_Assert.Arg1_ {
		isStrict := false

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

	class AssertTrue extends AhkUnit_Assert.AssertFalse {
		Evaluate() {
			return this.isStrict ? (this.actual == true) : !!this.actual
		}

		GetMesssage() {
			return "True expected: " . this.actual
		}
	}

	class AssertEmpty extends AhkUnit_Assert.Arg1_ {
		Evaluate() {
			return this.actual == ""
		}

		GetMesssage() {
			return "Empty expected: " . this.actual
		}
	}

	class AssertNotEmpty extends AhkUnit_Assert.AssertEmpty {
		Evaluate() {
			return !super.Evaluate()
		}

		GetMesssage() {
			return "Non-empty expected"
		}
	}

	class AssertObject extends AhkUnit_Assert.Arg1_ {
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

	__New() {
	}

	Default() {
	}

	Run(testClass) {
		this.result := ""
		this.message := ""
		this.count := { test: 0, assertion: 0, failure: 0, incomplete: 0 }
		this.testClass := testClass
		try {
			testClass.SetUpBeforeClass()
		} catch {
			this._AddFailure("Exception thrown in SetUpBeforeClass")
			return
		}

		testInstances := Map()
		for key in testClass.Prototype.OwnProps() {
			if (SubStr(key, -4) == "Test") {
				this.count.test++
				try {
					/*
					testInstance := map("base", testClass )
					testInstance.__New()
					; cannot do %test_class_name% without global %test_class_name%.
					; also, directly calling __New() doesn't initialize instance variables.
					*/

					testInstance := testclass.Call()
				}
				catch {
					this._AddFailure("Exception thrown in Constructor")
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
			; try {
				testInstance.AuInit(key)
				method := GetMethod(testInstance, key)
				method.Call(testInstance)
				/*
			} catch Any as e {
				thrownClass := (!IsObject(e) || (e.__Class == "")) ? "Exception" : e.__Class
				expectedClass := testInstance[key . "_throws"]
				if (expectedClass != "") {
					assertion := AhkUnit.Assert.Equals("throw " . expectedClass, "throw " . thrownClass)
					caller := IsObject(e) ? e : Object()
					testInstance.Assert_(assertion, "", caller)
				} else {
					this._AddFailure("Exception thrown in " . key)
					continue
				}
			}
			*/
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
		} catch {
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

AhkUnit.Runner := AhkUnit_Runner()

class Assert extends AhkUnit.FrameworkCore {
	__New() {
		super.__New()

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
			assertion := AhkUnit.Assert.Message("Bad assertion object.")
		}
		caller := IsObject(caller) ? caller : Error("", -caller - 1)
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
			assertionMessage := StrReplace(assertionMessage, "`n", "`n  ")
			assertionMessage := "  " . assertionMessage
			message .= "`n" . assertionMessage
		}
		this.AuFailed(pos . message)
	}

	Assert(assertion, message := "") {
		this.Assert_(assertion, message, 2 + this.callstackDepth)
	}

	AssertEqual(expected, actual, message := "") {
		this.Assert(AhkUnit.Assert.Equals(expected, actual), message)
	}

	AssertNotEqual(expected, actual, message := "") {
		this.Assert(AhkUnit.Assert.NotEquals(expected, actual), message)
	}

	AssertEqualIgnoreCase(expected, actual, message := "") {
		this.Assert(AhkUnit.Assert.Equals(expected, actual).IgnoreCase(), message)
	}

	AssertNotEqualIgnoreCase(expected, actual, message := "") {
		this.Assert(AhkUnit.Assert.NotEquals(expected, actual).IgnoreCase(), message)
	}

	AssertTrue(actual, message := "") {
		this.Assert(AhkUnit.Assert.AssertTrue(actual), message)
	}

	AssertFalse(actual, message := "") {
		this.Assert(AhkUnit.Assert.AssertFalse(actual), message)
	}

	AssertEmpty(actual, message := "") {
		this.Assert(AhkUnit.Assert.AssertEmpty(actual), message)
	}

	AssertNotEmpty(actual, message := "") {
		this.Assert(AhkUnit.Assert.AssertNotEmpty(actual), message)
	}

	AssertObject(actual, message := "") {
		this.Assert(AhkUnit.Assert.AssertObject(actual), message)
	}
}

