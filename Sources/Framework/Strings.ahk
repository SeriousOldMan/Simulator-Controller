;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - String Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

substituteVariables(text, values := false) {
	local result := text
	local variable, startPos, endPos, value

	loop {
		startPos := InStr(result, "%")

		if startPos {
			startPos += 1
			endPos := InStr(result, "%", false, startPos)

			if endPos {
				variable := Trim(SubStr(result, startPos, endPos - startPos))

				if (values is Map)
					value := (values && values.Has(variable)) ? values[variable] : %variable%
				else if (values is Object)
					value := (values && values.HasProp(variable)) ? values.%variable% : %variable%
				else
					value := %variable%

				result := StrReplace(result, "%" . variable . "%", value)
			}
			else
				throw "Second % not found while scanning (" . text . ") for variables in substituteVariables..."
		}
		else
			break
	}

	return result
}

string2Values(delimiter, text, count := false) {
	return (count ? StrSplit(Trim(text), delimiter, " `t", count) : StrSplit(Trim(text), delimiter, " `t"))
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

string2Map(elementSeparator, valueSeparator, text) {
	local result := Map()
	local ignore, keyValue

	result.CaseSense := false

	for ignore, keyValue in string2Values(elementSeparator, text) {
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