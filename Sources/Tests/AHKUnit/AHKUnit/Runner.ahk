; Copyright (c) 2011, SATO Kentaro
; BSD 2-Clause license

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
