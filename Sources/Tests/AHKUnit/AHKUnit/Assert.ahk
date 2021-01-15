; Copyright (c) 2011, SATO Kentaro
; BSD 2-Clause license

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
