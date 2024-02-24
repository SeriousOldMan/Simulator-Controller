;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database                        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Math.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Database {
	iDirectory := false
	iSchemas := CaseInsenseMap()
	iTables := CaseInsenseMap()
	iFiles := CaseInsenseMap()
	iTableChanged := CaseInsenseMap()

	class Row extends CaseInsenseMap {
		__New(arguments*) {
			this.Default := kNull

			super.__New(arguments*)
		}
	}

	Directory {
		Get {
			return this.iDirectory
		}
	}

	Schemas[name := false] {
		Get {
			return (name ? this.iSchemas[name] : this.iSchemas)
		}
	}

	Schema[name := false] {
		Get {
			return this.Schemas[name]
		}
	}

	Files[name := false] {
		Get {
			return (name ? (this.iFiles.Has(name) ? this.iFiles[name] : false) : this.iFiles)
		}

		Set {
			return (name ? (this.iFiles[name] := value) : this.iFiles := value)
		}
	}

	File[name := false] {
		Get {
			return this.Files[name]
		}
	}

	Tables[name := false] {
		Get {
			local tries := 100
			local schema, data, row, values, length, ignore, column
			local file, line

			if name {
				if !this.iTables.Has(name) {
					schema := this.Schemas[name]
					data := []

					if this.Directory {
						file := this.Files[name]

						if file {
							file.Pos := 0

							while !file.AtEOF {
								line := Trim(file.ReadLine(), " `t`n`r")

								row := Database.Row()

								values := string2Values(";", line)
								length := values.Length

								for ignore, column in schema
									if (length >= A_Index)
										row[column] := values[A_Index]
									else
										row[column] := kNull

								data.Push(row)
							}
						}
						else if FileExist(this.Directory . name . ".CSV")
							loop {
								try {
									loop Read, (this.Directory . name . ".CSV") {
										row := Database.Row()

										values := string2Values(";", A_LoopReadLine)
										length := values.Length

										for ignore, column in schema
											if (length >= A_Index)
												row[column] := values[A_Index]
											else
												row[column] := kNull

										data.Push(row)
									}

									break
								}
								catch Any as exception {
									data := []

									if (tries-- > 0)
										Sleep(200)
									else {
										if isDevelopment()
											logMessage(kLogWarn, "Waiting for file `"" . this.Directory . name . ".CSV" . "`"...")

										throw exception
									}
								}
							}
					}

					this.iTables[name] := data
				}

				return this.iTables[name]
			}
			else
				return this.iTables
		}
	}

	Table[name := false] {
		Get {
			return this.Tables[name]
		}
	}

	__New(directory, schemas) {
		this.iDirectory := (normalizeDirectoryPath(directory) . "\")

		this.iSchemas := toMap(schemas, CaseInsenseMap)
	}

	lock(name := false, wait := true) {
		local done := false
		local locked := []
		local directory, file, ignore, result, counter

		if (!name && !wait)
			throw "Inconsistent parameters detected in Database.lock..."

		if name {
			if !this.Files.Has(name) {
				directory := this.Directory

				DirCreate(directory)

				while !done {
					file := false

					try {
						file := FileOpen(directory . name . ".CSV", "rw-rwd")
					}
					catch Any as exception {
						if !wait
							logError(exception)

						if file
							try
								file.Close()

						file := false
					}

					if (!file && wait) {
						if !isSet(counter)
							counter := 0

						if (isDevelopment() && (counter++ > 20)) {
							counter := 0

							logMessage(kLogWarn, "Waiting for file `"" . directory . name  . ".CSV`"...")
						}

						Sleep(100)
					}
					else
						done := true
				}

				if file {
					this.Files[name] := file

					return true
				}
				else
					return false
			}
			else
				return true
		}
		else {
			result := true

			for name, ignore in getKeys(this.Schemas)
				if this.lock(name, wait)
					locked.Push(name)
				else {
					result := false

					break
				}

			if !result
				for ignore, name in locked
					this.unlock(name)

			return result
		}
	}

	unlock(name := false, backup := false) {
		local file, ignore

		if (name && (name != true)) {
			file := this.Files[name]

			if file {
				this.flush(name, backup)

				this.Files.Delete(name)

				file.Close()
			}
			else
				throw "Trying to unlock a file that is not locked in Database.unlock..."
		}
		else
			for name, ignore in getKeys(this.Schemas)
				this.unlock(name, backup)
	}

	query(name, query) {
		local predicate, schema, transform, rows, needsClone, predicate, selection, ignore, row, projection, projectedRows
		local column, projectedRow

		schema := this.Schemas[name]
		rows := this.Tables[name]
		needsClone := true

		if query.HasProp("Where") {
			predicate := query.Where

			selection := []

			if !isInstance(predicate, Func)
				predicate := constraintColumns.Bind(predicate)

			for ignore, row in rows
				if predicate.Call(row)
					selection.Push(row)

			rows := selection
			needsClone := false
		}

		if query.HasProp("Transform") {
			transform := query.Transform

			rows := transform.Call(rows)
		}

		if (query.HasProp("Group") || query.HasProp("By")) {
			rows := groupRows(query.HasProp("By") ? query.By : [], query.HasProp("Group") ? query.Group : [], rows)
			needsClone := false
		}

		if query.HasProp("Select") {
			projection := query.Select
			projectedRows := []

			for ignore, row in rows {
				projectedRow := Database.Row()

				for ignore, column in projection
					projectedRow[column] := row[column]

				projectedRows.Push(projectedRow)
			}

			rows := projectedRows
			needsClone := false
		}

		return (needsClone ? rows.Clone() : rows)
	}

	reload(name, flush := true, backup := false) {
		if flush
			this.flush(name, backup)

		if this.iTables.Has(name)
			this.iTables.Delete(name)
	}

	add(name, values, flush := false) {
		local tries := 100
		local row, directory, fileName, ignore, column, value, newValues, file

		if !isInstance(values, Database.Row)
			values := toMap(values, Database.Row)

		this.Tables[name].Push(values)

		if flush {
			row := []

			for ignore, column in this.Schemas[name]
				row.Push(values.Has(column) ? StrReplace(StrReplace(StrReplace(values[column], ";", ","), "`n", A_Space), "|", "-") : kNull)

			file := this.Files[name]

			if file {
				file.Pos := file.Length

				file.WriteLine(values2String(";", row*))
			}
			else {
				directory := this.Directory
				fileName := (directory . name . ".CSV")

				DirCreate(directory)

				row := (values2String(";", row*) . "`n")

				loop
					try {
						FileAppend(row, fileName)

						break
					}
					catch Any as exception {
						if (tries-- > 0)
							Sleep(200)
						else {
							if isDevelopment()
								logMessage(kLogWarn, "Waiting for file `"" . fileName . "`"...")

							throw exception
						}
					}
			}
		}
		else
			this.iTableChanged[name] := true
	}

	combine(table, query, field, values) {
		local results := []
		local ignore, key, value, result, where

		query := query.Clone()

		where := (isInstance(query.Where, Map) ? query.Where.Clone() : toMap(query.Where, CaseInsenseMap))

		query.Where := where

		for ignore, value in values {
			where[field] := value

			for ignore, result in this.query(table, query)
				results.Push(result)
		}

		return results
	}

	remove(name, where, predicate := false, flush := false, backup := false) {
		local rows := []
		local ignore, row

		if (where && !isInstance(where, Func))
			where := constraintColumns.Bind(where)

		for ignore, row in this.Tables[name]
			if (!where || where.Call(row)) {
				if (!predicate || !predicate.Call(row))
					rows.Push(row)
			}
			else
				rows.Push(row)

		this.iTables[name] := rows
		this.iTableChanged[name] := true

		if flush
			this.flush(name, backup)
	}

	clear(name, flush := false, backup := false) {
		this.iTables[name] := []
		this.iTableChanged[name] := true

		if flush
			this.flush(name, backup)
	}

	changed(name) {
		this.iTableChanged[name] := true
	}

	flush(name := false, backup := false) {
		local bakFile := false
		local directory, fileName, schema, ignore, row, values, column, file

		if (name && (name != true)) {
			if (this.Tables.Has(name) && this.iTableChanged.Has(name)) {
				directory := this.Directory
				fileName := (directory . name . ".CSV")
				file := this.Files[name]

				if file {
					if backup
						try {
							file.Pos := 0

							bakFile := FileOpen(fileName . ".bak", "w")

							bakFile.Write(file.Read())
						}
						catch Any as exception {
							logError(exception)
							
							if isDevelopment()
								logMessage(kLogWarn, "Waiting for file `"" . fileName . ".bak`"...")
						}
						finally {
							if bakFile
								bakFile.Close()
						}

					file.Length := 0

					schema := this.Schemas[name]

					for ignore, row in this.Tables[name] {
						values := []

						for ignore, column in schema
							values.Push(row.Has(column) ? StrReplace(StrReplace(StrReplace(row[column], ";", ","), "`n", A_Space), "|", "-") : kNull)

						file.WriteLine(values2String(";", values*))
					}
				}
				else {
					directory := this.Directory
					fileName := (directory . name . ".CSV")

					DirCreate(directory)

					deleteFile(fileName, backup)

					schema := this.Schemas[name]

					for ignore, row in this.Tables[name] {
						values := []

						for ignore, column in schema
							values.Push(row.Has(column) ? StrReplace(StrReplace(StrReplace(row[column], ";", ","), "`n", A_Space), "|", "-") : kNull)

						row := (values2String(";", values*) . "`n")

						FileAppend(row, fileName)
					}
				}

				this.iTableChanged.Delete(name)
			}
		}
		else
			for name, ignore in this.Tables
				this.flush(name, backup)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

valueOrNull(value) {
	return ((value != "") ? value : kNull)
}

always(value, ignore*) {
	return value
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

constraintColumns(constraints, row) {
	local column, value

	if isInstance(constraints, Map) {
		for column, value in constraints
			if (row.Has(column) && (row[column] != value))
				return false
	}
	else
		for column, value in constraints.OwnProps()
			if (row.Has(column) && (row[column] != value))
				return false

	return true
}

groupRows(groupedByColumns, groupedColumns, rows) {
	local values := CaseInsenseMap()
	local function, ignore, row, column, key, result, group, groupedRows, columnValues
	local resultRow, valueColumn, resultColumn, columnDescriptor

	if !isObject(groupedByColumns)
		groupedByColumns := Array(groupedByColumns)

	for ignore, row in rows {
		key := []

		for ignore, column in groupedByColumns
			key.Push(StrReplace(StrReplace(StrReplace(row[column], ";", ","), "`n", A_Space), "|", "-"))

		key := values2String("|", key*)

		if values.Has(key)
			values[key].Push(row)
		else
			values[key] := Array(row)
	}

	result := []

	for group, groupedRows in values {
		group := string2Values("|", group)

		resultRow := Database.Row()

		for ignore, column in groupedByColumns
			resultRow[column] := group[A_Index]

		for ignore, columnDescriptor in groupedColumns {
			valueColumn := columnDescriptor[1]
			function := columnDescriptor[2]
			resultColumn := columnDescriptor[3]

			columnValues := []

			for ignore, row in groupedRows
				columnValues.Push(row[valueColumn])

			resultRow[resultColumn] := function(columnValues)
		}

		result.Push(resultRow)
	}

	return result
}