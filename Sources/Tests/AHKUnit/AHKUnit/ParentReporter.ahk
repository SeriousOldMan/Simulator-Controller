; Copyright (c) 2011, SATO Kentaro
; BSD 2-Clause license

class AhkUnit_ParentReporter {
	__New(framework) {
		this.framework := framework
		framework.ReportParent_(true)
	}
	
	__Delete() {
		this.framework.ReportParent_(false)
	}
}

AhkUnit.ParentReporter := AhkUnit_ParentReporter
