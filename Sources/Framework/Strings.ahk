;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - String Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

encode(text) {
	return StrReplace(StrReplace(StrReplace(text, "\", "\\"), "=", "\="), "`n", "\n")
}

decode(text) {
	text := StrReplace(StrReplace(StrReplace(text, "\\", "_#_AC_#_"), "\=", "_#_EQ_#_"), "\n", "_#_CR_#_")

	return StrReplace(StrReplace(StrReplace(text, "_#_EQ_#_", "="), "_#_AC_#_", "\"), "_#_CR_#_", "`n")
}

encodeB16(buf, size := kUndefined) {
	local result := ""

	if (size == kUndefined)
		size := buf.Size

	VarSetStrCapacity(&result, size * 2)

	loop size
		result .= Format("{1:02X}", NumGet(buf, A_Index - 1, "UChar"))

	return result
}

decodeB16(string) {
	local size := (StrLen(string) >> 1)
	local buf := Buffer(size)

	loop size
		NumPut("UChar", Integer("0x" . SubStr(string, (A_Index * 2) - 1, 2)), buf, A_Index - 1)

	return buf
}

substituteString(text, pattern, replacement) {
	local result := text

	loop {
		text := result

		result := StrReplace(text, pattern, replacement)
	}
	until (result = text)

	return result
}

substituteVariables(text, values := false) {
	local result := text
	local startPos := 1
	local hasPercent := false
	local isMap := isInstance(values, Map)
	local isObject := isInstance(values, Object)
	local variable, startPos, endPos, value, pChar

	loop {
		startPos := InStr(result, "%", false, startPos)

		if startPos {
			startPos += 1

			if (startPos > 2) {
				pChar := SubStr(result, startPos - 2, 1)

				if ((pChar = "``") || (pChar = "\")) {
					hasPercent := true

					continue
				}
			}

			try {
				variable := false

				endPos := InStr(result, "%", false, startPos)

				if endPos {
					variable := Trim(SubStr(result, startPos, endPos - startPos))

					if (isMap && values && values.Has(variable))
						value := values[variable]
					else if (isObject && values && values.HasProp(variable))
						value := values.%variable%
					else
						try {
							value := %variable%
						}
						catch Any as exception {
							logMessage(kLogCritical, "Variable " . variable . " not found in `"" . text . "`"")

							logError(exception, true)

							value := ""
						}

					result := StrReplace(result, "%" . variable . "%", value)

					startPos -= 1
				}
				else
					throw "Second % not found while scanning `"" . text . "`" for variables in substituteVariables..."
			}
			catch Any as exception {
				logError(exception, true)
			}
		}
		else
			break
	}

	return (hasPercent ? StrReplace(result, "``%", "%") : result)
}

string2Values(delimiter, text, count := false, class := Array) {
	if (class == Array)
		return (count ? StrSplit(Trim(text), delimiter, " `t", count) : StrSplit(Trim(text), delimiter, " `t"))
	else
		return toArray((count ? StrSplit(Trim(text), delimiter, " `t", count) : StrSplit(Trim(text), delimiter, " `t")), class)
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
	local result := CaseInsenseMap()
	local ignore, keyValue

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