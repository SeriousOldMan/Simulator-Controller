;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - File Functions                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Debug.ahk
#Include ..\Framework\Strings.ahk
#Include ..\Framework\Collections.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getFileName(fileName, directories*) {
	local driveName, ignore, directory

	fileName := substituteVariables(fileName)

	SplitPath fileName, , , , , driveName

	if (driveName && (driveName != ""))
		return fileName
	else {
		for ignore, directory in directories
			if FileExist(directory . fileName)
				return (directory . fileName)

		if (directories.Length() > 0)
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

		loop Files, %pattern%, FD
			result.Push(A_LoopFileLongPath)
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

normalizeDirectoryPath(path) {
	return ((SubStr(path, StrLen(path)) = "\") ? SubStr(path, 1, StrLen(path) - 1) : path)
}

temporaryFileName(name, extension) {
	local rnd

	Random rnd, 1, 100000

	return (kTempDirectory . name . "_" . Round(rnd) . "." . extension)
}

deleteFile(fileName) {
	try {
		FileDelete %fileName%

		return !ErrorLevel
	}
	catch exception {
		logError(exception)

		return false
	}
}

deleteDirectory(directoryName, includeDirectory := true, recurse := true) {
	local files, ignore, fileName, result

	if includeDirectory {
		try {
			FileRemoveDir %directoryName%, %recurse%

			return !ErrorLevel
		}
		catch exception {
			logError(exception)

			return false
		}
	}
	else {
		files := []
		result := true

		loop Files, %directoryName%\*.*, DF
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