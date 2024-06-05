;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Type Functions                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

isNull(value) {
	return ((value = kNull) || (value == "__Null__"))
}

toObject(candidate, class := Object) {
	local key, value

	if !isInstance(candidate, class) {
		local result := class()

		if isInstance(candidate, Map) {
			for key, value in candidate
				result.%key% := value
		}
		else
			for key, value in candidate.OwnProps()
				result.%key% := value

		return result
	}
	else
		return candidate
}

isInstance(object, root) {
	return (object is root)
}