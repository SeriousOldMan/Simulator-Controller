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
	static kMiniWidth := 254
	static kMiniHeight := 208
	static kStandardWidth := 387
	static kStandardHeight := 267
	static kXLWidth := 572
	static kXLHeight := 330
	
	iSize := "Standard"
	
	Type[] {
		Get {
			return "Stream Deck"
		}
	}
	
	Size[] {
		Get {
			return this.iSize
		}
	}
	
	__New(previewManager, name, configuration) {
		layout := string2Values("x", getConfigurationValue(configuration, "Layouts", name . ".Layout", "3x5"))
		
		if (layout[1] = 2) {
			this.Width := this.kMiniWidth
			this.Height := this.kMiniHeight
			
			this.iSize := "Mini"
		}
		else if (layout[1] = 3) {
			this.Width := this.kStandardWidth
			this.Height := this.kStandardHeight
			
			this.iSize := "Standard"
		}
		else if (layout[1] = 4) {
			this.Width := this.kXLWidth
			this.Height := this.kXLHeight
			
			this.iSize := "XL"
		}
		
		base.__New(previewManager, name, configuration)
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
		
		Gui %window%:-Border -Caption
		
		previewMover := this.PreviewManager.getPreviewMover()
		previewMover := (previewMover ? ("g" . previewMover) : "")
		
		Gui %window%:Add, Picture, x0 y0 %previewMover%, % (kResourcesDirectory . "Stream Deck Images\Stream Deck " . this.Size . ".jpg")
	}
}