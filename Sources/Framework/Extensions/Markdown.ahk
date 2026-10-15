;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Markdown Processor              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Constants.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

hoedown_html_renderer_new(render_flags := 0, nesting_level := 0) {
	return DllCall("hoedown\hoedown_html_renderer_new", "uint", render_flags, "int", nesting_level, "ptr")
}

hoedown_document_new(renderer, extensions, max_nesting) {
	return DllCall("hoedown\hoedown_document_new", "ptr", renderer, "uint", extensions
												 , "uint", max_nesting, "ptr")
}

hoedown_buffer_new(unit) {
	return DllCall("hoedown\hoedown_buffer_new", "uint", unit, "ptr")
}

hoedown_document_render(hoedown_document, hoedown_buffer, &data) {
	local dataA := ""
	local size

	StrPutVar(string, &var, encoding) {
		VarSetStrCapacity(&var
						, StrPut(string, encoding) * (((encoding = "UTF-16") || (encoding = "cp1200")) ? 2 : 1))

		return StrPut(string, StrPtr(var), encoding)
	}

	size := StrPutVar(data, &dataA, "UTF-8")

	DllCall("hoedown\hoedown_document_render", "ptr", hoedown_document, "ptr", hoedown_buffer
											 , "ptr", StrPtr(dataA), "uint", size)
}

hoedown_buffer_free(buf) {
	DllCall("hoedown\hoedown_buffer_free", "ptr", buf)
}

hoedown_document_free(doc) {
	DllCall("hoedown\hoedown_document_free", "ptr", doc)
}

hoedown_html_renderer_free(renderer) {
	DllCall("hoedown\hoedown_html_renderer_free", "ptr", renderer)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

markdown2HTML(markdown) {
	local renderer, document, html, data, size, result

	static loaded := false

	if !loaded {
		DllCall("LoadLibrary", "Str", kBinariesDirectory . "Markdown\hoedown.dll", "Ptr")

		loaded := true
	}

	renderer := hoedown_html_renderer_new(0, 0)
	document := hoedown_document_new(renderer, 0xF, 16)

	html := hoedown_buffer_new(16)

	hoedown_document_render(document, html, &markdown)

	data := NumGet(html + 0, "ptr")
	size := NumGet(html + A_PtrSize, "uint")

	result := StrGet(data, size, "UTF-8")

	hoedown_buffer_free(html)
	hoedown_document_free(document)
	hoedown_html_renderer_free(renderer)

	return result
}