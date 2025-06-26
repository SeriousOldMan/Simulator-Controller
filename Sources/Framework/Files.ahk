﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - File Functions                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "Strings.ahk"
#Include "Collections.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

normalizeFileName(fileName) {
	local ignore, character

	static disallowedCharacters := ["/" , ":", "*", "?", "<", ">", "|"]

	for ignore, character in disallowedCharacters
		fileName := StrReplace(fileName, character, "")

	return fileName
}

getFileName(fileName, directories*) {
	local driveName, ignore, directory

	fileName := substituteVariables(fileName)

	SplitPath(fileName, , , , , &driveName)

	if (driveName && (driveName != ""))
		return fileName
	else {
		for ignore, directory in directories
			if FileExist(directory . fileName)
				return (directory . fileName)

		if (directories.Length > 0)
			return (directories[1] . fileName)
		else
			return fileName
	}
}

getFileNames(filePattern, directories*) {
	local result := []
	local ignore, directory, pattern

	for ignore, directory in directories {
		pattern := directory . filePattern

		loop Files, pattern, "FD"
			result.Push(A_LoopFileFullPath)
	}

	return result
}

normalizeFilePath(filePath) {
	local position, index

	loop {
		position := InStr(filePath, "\..")

		if position {
			index := position - 1

			loop {
				if (index == 0)
					return filePath
				else if (SubStr(filePath, index, 1) == "\") {
					filePath := StrReplace(filePath, SubStr(filePath, index, position + 3 - index), "")

					break
				}

				index -= 1
			}
		}
		else
			return filePath
	}
}

directoryContains(directory, fileOrDirectory) {
	local curWorkingDir := A_WorkingDir
	local folder, container

	try {
		SetWorkingDir(directory)

		container := A_WorkingDir

		if InStr(FileExist(fileOrDirectory), "D") {
			SetWorkingDir(fileOrDirectory)

			return InStr(A_WorkingDir, container)
		}
		else if InStr(FileExist(fileOrDirectory), "F") {
			SplitPath(fileOrDirectory, , &folder)

			SetWorkingDir(folder)

			return InStr(A_WorkingDir, container)
		}
		else
			return InStr(fileOrDirectory, directory)
	}
	finally {
		SetWorkingDir(curWorkingDir)
	}
}

normalizeDirectoryPath(path) {
	while (SubStr(path, StrLen(path)) = "\")
		path := SubStr(path, 1, StrLen(path) - 1)

	return path
}

temporaryFileName(name, extension := "") {
	if extension != ""
		extension := ("." . extension)

	return (kTempDirectory . name . "_" . Round(Random(1, 100000)) . extension)
}

deleteFile(fileName, backup := false) {
	try {
		if backup
			FileMove(fileName, fileName . ".bak", 1)
		else
			FileDelete(fileName)

		return true
	}
	catch Any as exception {
		if FileExist(fileName) {
			logError(exception, false, true)

			return false
		}
		else
			return true
	}
}

deleteDirectory(directoryName, includeDirectory := true, recurse := true) {
	local files, ignore, fileName, result

	if includeDirectory {
		try {
			recurse := (recurse != false)

			DirDelete(directoryName, recurse)

			return true
		}
		catch Any as exception {
			if FileExist(directoryName) {
				logError(exception, false, true)

				return false
			}
			else
				return true
		}
	}
	else {
		files := []
		result := true

		loop Files, directoryName . "\*.*", "DF"
			files.Push(A_LoopFilePath)

		for ignore, fileName in files {
			if InStr(FileExist(fileName), "D") {
				if !deleteDirectory(fileName)
					result := false
			}
			else if !deleteFile(fileName)
				result := false
		}

		return result
	}
}