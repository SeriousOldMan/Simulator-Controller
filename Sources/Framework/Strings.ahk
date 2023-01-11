;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - String Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

substituteVariables(string, values := false) {
	local result := string
	local variable, startPos, endPos, value

	loop {
		startPos := InStr(result, "%")

		if startPos {
			startPos += 1
			endPos := InStr(result, "%", false, startPos)

			if endPos {
				variable := Trim(SubStr(result, startPos, endPos - startPos))

				value := (values && values.HasKey(variable)) ? values[variable] : %variable%

				result := StrReplace(result, "%" . variable . "%", value)
			}
			else
				throw "Second % not found while scanning (" . string . ") for variables in substituteVariables..."
		}
		else
			break
	}

	return result
}

string2Values(delimiter, string, count := false) {
	return (count ? StrSplit(Trim(string), delimiter, " `t", count) : StrSplit(Trim(string), delimiter, " `t"))
}

values2String(delimiter, values*) {
	local result := ""
	local index, value

	for index, value in values {
		if (index > 1)
			result .= delimiter

		result .= value
	}

	return result
}

string2Map(elementSeparator, valueSeparator, map) {
	local result := {}
	local ignore, keyValue

	for ignore, keyValue in string2Values(elementSeparator, map) {
		keyValue := string2Values(valueSeparator, keyValue)

		result[keyValue[1]] := keyValue[2]
	}

	return result
}

map2String(elementSeparator, valueSeparator, map) {
	local result := []
	local key, value

	for key, value in map
		result.Push(key . valueSeparator . value)

	return values2String(elementSeparator, result*)
}