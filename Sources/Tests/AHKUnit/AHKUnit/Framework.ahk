; Copyright (c) 2011, SATO Kentaro
; BSD 2-Clause license

class AhkUnit_Framework extends AhkUnit.FrameworkCore {
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
