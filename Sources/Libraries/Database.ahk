;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database                        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Database {
	iDirectory := false
	iSchemas := false
	iTables := {}
	iTableChanged := {}

	Directory[] {
		Get {
			return this.iDirectory
		}
	}

	Schemas[name := false] {
		Get {
			return (name ? this.iSchemas[name] : this.iSchemas)
		}
	}

	Tables[name := false] {
		Get {
			if name {
				if !this.iTables.HasKey(name) {
					schema := this.Schemas[name]
					data := []

					if this.Directory
						Loop Read, % (this.Directory . name . ".CSV")
						{
							row := {}
							values := string2Values(";", A_LoopReadLine)
							length := values.Length()

							for ignore, column in schema
								if (length >= A_Index)
									row[column] := values[A_Index]
								else
									row[column] := kNull

							data.Push(row)
						}

					this.iTables[name] := data
				}

				return this.iTables[name]
			}
			else
				return this.iTables
		}
	}

	__New(directory, schemas) {
		this.iDirectory := directory
		this.iSchemas := schemas
	}

	query(name, query) {
		local predicate

		schema := this.Schemas[name]
		rows := this.Tables[name]
		needsClone := true

		if query.HasKey("Where") {
			predicate := query["Where"]
			selection := []

			if !predicate.MinParams
				predicate := Func("constraintColumns").Bind(predicate)

			for ignore, row in rows
				if %predicate%(row)
					selection.Push(row)

			rows := selection
			needsClone := false
		}

		if query.HasKey("Transform") {
			transform := query["Transform"]

			rows := %transform%(rows)
		}

		if (query.HasKey("Group") || query.HasKey("By")) {
			rows := groupRows(query.HasKey("By") ? query["By"] : [], query.HasKey("Group") ? query["Group"] : [], rows)
			needsClone := false
		}

		if query.HasKey("Select") {
			projection := query["Select"]
			projectedRows := []

			for ignore, row in rows {
				projectedRow := {}

				for ignore, column in projection
					projectedRow[column] := row[column]

				projectedRows.Push(projectedRow)
			}

			rows := projectedRows
			needsClone := false
		}

		return (needsClone ? rows.Clone() : rows)
	}

	reload(name, flush := true) {
		if flush
			this.flush(name)

		this.iTables.Delete(name)
	}

	add(name, values, flush := false) {
		this.Tables[name].Push(values)

		if flush {
			row := []

			for ignore, column in this.Schemas[name]
				row.Push(values.HasKey(column) ? values[column] : kNull)

			directory := this.Directory
			fileName := (directory . name . ".CSV")

			FileCreateDir %directory%

			row := (values2String(";", row*) . "`n")

			FileAppend %row%, %fileName%
		}
		else
			this.iTableChanged[name] := true
	}

	combine(table, query, field, values) {
		results := []

		for ignore, value in values {
			query.Where[field] := value

			for ignore, result in this.query(table, query)
				results.Push(result)
		}

		return results
	}

	remove(name, where, predicate := false, flush := false) {
		rows := []

		if (where && !where.MinParams)
			where := Func("constraintColumns").Bind(where)

		for ignore, row in this.Tables[name]
			if (!where || %where%(row)) {
				if (!predicate || !%predicate%(row))
					rows.Push(row)
			}
			else
				rows.Push(row)

		this.iTables[name] := rows
		this.iTableChanged[name] := true

		if flush
			this.flush(name)
	}

	clear(name, flush := false) {
		if this.Tables.HasKey(name) {
			this.iTables[name] := []
			this.iTableChanged[name] := true

			if flush
				this.flush(name)
		}
	}

	changed(name) {
		this.iTableChanged[name] := true
	}

	flush(name := false) {
		if name {
			if (this.Tables.HasKey(name) && this.iTableChanged.HasKey(name)) {
				directory := this.Directory
				fileName := (directory . name . ".CSV")

				FileCreateDir %directory%

				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}

				schema := this.Schemas[name]

				for ignore, row in this.Tables[name] {
					values := []

					for ignore, column in schema
						values.Push(row.HasKey(column) ? row[column] : kNull)

					row := (values2String(";", values*) . "`n")

					FileAppend %row%, %fileName%
				}

				this.iTableChanged.Delete(name)
			}
		}
		else
			for name, ignore in this.Tables
				this.flush(name)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

valueOrNull(value) {
	return ((value != "") ? value : kNull)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

constraintColumns(constraints, row) {
	for column, value in constraints
		if (row.HasKey(column) && (row[column] != value))
			return false

	return true
}

groupRows(groupedByColumns, groupedColumns, rows) {
	local function

	values := {}

	if !IsObject(groupedByColumns)
		groupedByColumns := Array(groupedByColumns)

	for ignore, row in rows {
		key := []

		for ignore, column in groupedByColumns
			key.Push(row[column])

		key := values2String("|", key*)

		if values.HasKey(key)
			values[key].Push(row)
		else
			values[key] := Array(row)
	}

	result := []

	for group, groupedRows in values {
		group := string2Values("|", group)

		resultRow := Object()

		for ignore, column in groupedByColumns
			resultRow[column] := group[A_Index]

		for ignore, columnDescriptor in groupedColumns {
			valueColumn := columnDescriptor[1]
			function := columnDescriptor[2]
			resultColumn := columnDescriptor[3]

			columnValues := []

			for ignore, row in groupedRows
				columnValues.Push(row[valueColumn])

			resultRow[resultColumn] := %function%(columnValues)
		}

		result.Push(resultRow)
	}

	return result
}