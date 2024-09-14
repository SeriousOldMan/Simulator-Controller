;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Viewer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\HTMLViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variables Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryViewer {
	static sChartID := 1

	iManager := false

	iWindow := false
	iTelemetryViewer := false

	Window {
		Get {
			return this.iWindow
		}
	}

	TelemetryViewer {
		Get {
			return this.iTelemetryViewer
		}
	}

	__New(manager, window, telemetryViewer := false) {
		this.iManager := manager
		this.iWindow := window
		this.iTelemetryViewer := telemetryViewer
	}

	showTelemetryChart(lapFileName, referenceLapFileName := false) {
		local lapTelemetry := []
		local entry, index, field

		loop Read, lapFileName {
			entry := string2Values(";", A_LoopReadLine)

			for index, value in entry
				if !isNumber(value)
					entry[index] := kNull

			lapTelemetry.Push(entry)
		}
	}
}