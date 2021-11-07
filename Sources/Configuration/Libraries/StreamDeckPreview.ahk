;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Preview              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; StreamDeckPreview                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class StreamDeckPreview extends ControllerPreview {
	Type[] {
		Get {
			return "Stream Deck"
		}
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
		
		Gui %window%:-Border -Caption
		
		previewMover := this.PreviewManager.getPreviewMover()
		previewMover := (previewMover ? ("g" . previewMover) : "")
		
		Gui %window%:Add, Text, x16 y16 w150 r1 %previewMover%, Hello World!
		
		this.Width := 182
		this.Height := 50
	}
}