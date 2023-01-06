;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Utility Functions               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

createGUID() {
	local guid, pGuid, sGuid, size

    VarSetCapacity(pGuid, 16, 0)

	if !DllCall("ole32.dll\CoCreateGuid", "ptr", &pGuid) {
        size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)

        if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pGuid, "ptr", &sGuid, "int", size)) {
			guid := StrGet(&sGuid)

            return SubStr(SubStr(guid, 1, StrLen(guid) - 1), 2)
		}
    }

    return ""
}

isNull(value) {
	return ((value = kNull) || (value == "__Null__"))
}

isInstance(object, root) {
	local candidate, classVar, outerClassVar

	if IsObject(object) {
		candidate := object.base

		while IsObject(candidate)
			if (candidate == root)
				return true
			else {
				classVar := (candidate.base ? candidate.base.__Class : false)

				if (classVar && (classVar != "")) {
					if InStr(classVar, ".") {
						classVar := StrSplit(classVar, ".")
						outerClassVar := classVar[1]

						candidate := %outerClassVar%[classVar[2]]
					}
					else
						candidate := %classVar%
				}
				else
					return false
			}
	}

	return false
}