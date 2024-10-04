;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Animated GIF Control            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"
#Include "..\Framework\Gui.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "GDIP.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class GIF {
	static sToken := false
	static sCount := 0

	iFileName := false
	iControl := false

	iCycle := true

	iBitmap := false
	iWidth := 0
	iHeight := 0

	iIsPlaying := false

	iDimensionIDs := false

	iFrameCount := 0
	iCurrentFrame := -1
	iFrameDelays := false

	Control {
		Get {
			return this.iControl
		}
	}

	FileName {
		Get {
			return this.iFileName
		}
	}

	Cycle {
		Get {
			return this.iCycle
		}
	}

	__New(control, fileName, cycle := true) {
		local width, height, frameDimensions, count

		getFrameDelays(pImage) {
			local delays := Map()
			local itemSize := 0
			local item, propLen, propCount

			static PropertyTagFrameDelay := 0x5100

			DllCall("Gdiplus\GdipGetPropertyItemSize", "Ptr", pImage, "UInt", PropertyTagFrameDelay, "UInt*", &itemSize)

			item := Buffer(itemSize, 0)

			DllCall("Gdiplus\GdipGetPropertyItem", "Ptr", pImage, "UInt", PropertyTagFrameDelay, "UInt", itemSize, "Ptr", item)

			propLen := NumGet(item, 4, "UInt")
			propVal := NumGet(item, 8 + A_PtrSize, "UPtr")

			loop propLen // 4 {
				if (!n := NumGet(propVal + 0, (A_Index - 1) * 4, "UInt"))
					n := 10

				delays[A_Index - 1] := (n * 10)
			}

			return delays
		}

		if !GIF.sToken
			GIF.sToken := Gdip_Startup()

		GIF.sCount += 1

		this.iFileName := fileName
		this.iControl := control
		this.iCycle := cycle

		this.iBitmap := Gdip_CreateBitmapFromFile(this.FileName)

		Gdip_GetImageDimensions(this.iBitmap, &width, &height)

		this.iWidth := width, this.iHeight := height

		frameDimensions := 0
		count := 0

		DllCall("Gdiplus\GdipImageGetFrameDimensionsCount", "ptr", this.iBitmap, "uptr*", &frameDimensions)

		this.iDimensionIDs := Buffer(16 * frameDimensions)

		DllCall("Gdiplus\GdipImageGetFrameDimensionsList", "ptr", this.iBitmap, "uptr", this.iDimensionIDs.Ptr, "int", frameDimensions)
		DllCall("Gdiplus\GdipImageGetFrameCount", "ptr", this.iBitmap, "uptr", this.iDimensionIDs.Ptr, "int*", &count)

		this.iFrameCount := count
		this.iCurrentFrame := -1

		this.iFrameDelays := getFrameDelays(this.iBitmap)

		this.__Play(false)
	}

	__Delete() {
		Gdip_DisposeImage(this.iBitmap)

		if (--GIF.sCount = 0) {
			Gdip_ShutDown(GIF.sToken)

			GIF.sToken := false
		}
	}

	Play() {
		this.iIsPlaying := true

		SetTimer(this._fn := ObjBindMethod(this, "__Play"), -1)
	}

	Pause() {
		this.iIsPlaying := false

		if this.HasProp("_fn")
			SetTimer(this._fn, 0)
	}

	Reset() {
		local wasPlaying := this.iIsPlaying

		this.Pause()

		this.iCurrentFrame := -1

		this.__Play(false)

		if wasPlaying
			this.Play()
	}

	__Play(next := true) {
		local hWidth := 0
		local hHeight := 0
		local tWidth := 0
		local tHeight := 0
		local hBitmap, pBitmap, tBitmap, tGraphics, tHBitmap

		this.iCurrentFrame := Mod(++this.iCurrentFrame, this.iFrameCount)

		DllCall("Gdiplus\GdipImageSelectActiveFrame", "ptr", this.iBitmap, "uptr", this.iDimensionIDs.Ptr, "int", this.iCurrentFrame)

		hBitmap := Gdip_CreateHBITMAPFromBitmap(this.iBitmap)

		pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)

		Gdip_GetImageDimensions(pBitmap, &hWidth, &hHeight)

		ControlGetPos( , , &tWidth, &tHeight, this.Control)

		tBitmap := Gdip_CreateBitmap(tWidth, tHeight)

		tGraphics := Gdip_GraphicsFromImage(tBitmap)

		Gdip_DrawImage(tGraphics, pBitmap, 0, 0, tWidth, tHeight, 0, 0, hWidth, hHeight)

		tHBitmap := Gdip_CreateHBITMAPFromBitmap(tBitmap)

		SetImage(this.Control.Hwnd, tHBitmap)

		Gdip_DeleteGraphics(tGraphics)

		Gdip_DisposeImage(pBitmap)
		DeleteObject(hBitmap)
		Gdip_DisposeImage(tBitmap)
		DeleteObject(tHBitmap)

		if (next && this.iCurrentFrame < (this.iCycle ? 0xFFFFFFFF : this.iFrameCount - 1)) {
			fn := this._fn

			SetTimer(fn, -1 * this.iFrameDelays[this.iCurrentFrame])
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class GIFViewer {
	iControl := false
	iGIF := false

	Control {
		Get {
			return this.iControl
		}
	}

	GIF {
		Get {
			return this.iGIF
		}
	}

	__New(control, fileName) {
		this.iControl := control
		this.iGIF := GIF(control, fileName)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

initializeGIFViewer() {
	AddGIFViewer(window, arguments*) {
		return createGIFViewer(window, arguments*)
	}

	createGIFViewer(window, options, fileName) {
		local control := window.Add("Picture", options, fileName)
		local viewer := GIFViewer(control, fileName)

		control.Start := (*) => viewer.GIF.Play()
		control.Stop := (*) => viewer.GIF.Pause()
		control.Reset := (*) => viewer.GIF.Reset()
		control.Show := (*) => control.Visible := true
		control.Hide := (*) => control.Visible := false

		return control
	}

	Window.Prototype.AddGIFViewer := AddGIFViewer

	Window.DefineCustomControl("GIFViewer", createGIFViewer)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeGIFViewer()