;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - FTP Session Wrapper Library     ;;;
;;;                                                                         ;;;
;;;                      Based on the work of jNizM                         ;;;
;;;          https://www.autohotkey.com/boards/viewtopic.php?t=79142        ;;;
;;;   Author:   jNizM                                                       ;;;
;;;   Release:  2020-07-26                                                  ;;;
;;;   Modified: 2020-07-31                                                  ;;;
;;;   Github:   https://github.com/jNizM/Class_FTP                          ;;;
;;;   Forum:    https://www.autohotkey.com/boards/viewtopic.php?t=79142     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class FTP {
	static hWININET := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")

	static open(agent, proxy := "", proxyBypass := "") {
		if (hInternet := FTP.internetOpen(agent, proxy, proxyBypass))
			return hInternet
		else
			return false
	}

	static close(hInternet) {
		if (hInternet && FTP.internetCloseHandle(hInternet))
			return true
		else
			return false
	}

	static connect(hInternet, serverName, userName := "", password := "", port := 21, FTP_PASV := 1) {
		local hConnect

		if (hConnect := FTP.internetConnect(hInternet, serverName, port, userName, password, FTP_PASV))
			return hConnect
		else
			return false
	}

	static disconnect(hConnect) {
		if (hConnect && FTP.internetCloseHandle(hConnect))
			return true
		else
			return false
	}

	static createDirectory(hConnect, directory) {
		if (DllCall("wininet\FtpCreateDirectory", "ptr", hConnect, "str", directory))
			return true
		else
			return false
	}

	static removeDirectory(hConnect, directory) {
		if (DllCall("wininet\FtpRemoveDirectory", "ptr", hConnect, "str", directory))
			return true
		else
			return false
	}

	static getCurrentDirectory(hConnect) {
		local currentDirectory

		static MAX_PATH := 260 + 8

		currentDirectory := Buffer(MAX_PATH, 0)

		if (DllCall("wininet\FtpGetCurrentDirectory", "ptr", hConnect, "ptr", currentDirectory, "uint*", currentDirectory.Size))
			return StrGet(currentDirectory)
		else
			return false
	}

	static setCurrentDirectory(hconnect, directory) {
		if (DllCall("wininet\FtpSetCurrentDirectory", "ptr", hConnect, "str", directory))
			return true
		else
			return false
	}

	static findFiles(hConnect, pattern := "*.*") {
		local hEnum
		local files := []
		local find := FTP.findFirstFile(hConnect, &hEnum, pattern)

		static FILE_ATTRIBUTE_DIRECTORY := 0x10

		if find {
			if !(find["FileAttr"] & FILE_ATTRIBUTE_DIRECTORY)
				files.Push(find)

			while (find := FTP.findNextFile(hEnum))
				if !(find["FileAttr"] & FILE_ATTRIBUTE_DIRECTORY)
					files.Push(find)
		}

		FTP.close(hEnum)

		return files
	}

	static findFolders(hConnect, pattern := "*.*") {
		local hEnum
		local folders := []
		local find := FTP.findFirstFile(hConnect, &hEnum, pattern)

		static FILE_ATTRIBUTE_DIRECTORY := 0x10

		if find {
			if (find["FileAttr"] & FILE_ATTRIBUTE_DIRECTORY)
				folders.Push(find)

			while (find := FTP.findNextFile(hEnum))
				if (find["FileAttr"] & FILE_ATTRIBUTE_DIRECTORY)
					folders.Push(find)
		}

		FTP.close(hEnum)

		return folders
	}

	static putFile(hConnect, localFile, remoteFile, flags := 0) {
		if (DllCall("wininet\FtpPutFile", "ptr", hConnect, "ptr", localFile, "ptr", remoteFile, "uint", flags, "uptr", 0))
			return true
		else
			return false
	}

	static renameFile(hConnect, existingFile, newName) {
		if (DllCall("wininet\FtpRenameFile", "ptr", hConnect, "str", existingFile, "str", newName))
			return true
		else
			return false
	}

	static deleteFile(hConnect, fileName) {
		if (DllCall("wininet\FtpDeleteFile", "ptr", hConnect, "str", fileName))
			return true
		else
			return false
	}

	static getFile(hConnect, remoteFile, localFile, overWrite := false, flags := 0) {
		if (DllCall("wininet\FtpGetFile", "ptr", hConnect, "str", remoteFile, "str", localFile, "int", !overWrite, "uint", 0, "uint", flags, "uptr", 0))
			return true
		else
			return false
	}

	static getFileSize(hConnect, fileName, sizeFormat := "auto", sizeSuffix := false) {
		local hFile, fileSizeHigh, fileSizeLow

		static GENERIC_READ := 0x80000000

		if (hFile := FTP.openFile(hConnect, fileName, GENERIC_READ)) {
			fileSizeHigh := 0

			if (fileSizeLow := DllCall("wininet\FtpGetFileSize", "ptr", hFile, "uint*", &fileSizeHigh, "uint")) {
				FTP.internetCloseHandle(hFile)

				return FTP.formatBytes(fileSizeLow + (fileSizeHigh << 32), sizeFormat, sizeSuffix)
			}
			else {
				FTP.internetCloseHandle(hFile)

				return false
			}
		}
		else
			return false
	}

	static fileAttributes(attributes) {
		local fileAttributes := []
		local k, v

		static FILE_ATTRIBUTE := Map(1, "READONLY", 2, "HIDDEN", 4, "SYSTEM", 16, "DIRECTORY", 32, "ARCHIVE", 64, "DEVICE", 128, "NORMAL"
								   , 256, "TEMPORARY", 512, "SPARSE_FILE", 1024, "REPARSE_POINT", 2048, "COMPRESSED", 4096, "OFFLINE"
								   , 8192, "NOT_CONTENT_INDEXED", 16384, "ENCRYPTED", 32768, "INTEGRITY_STREAM", 65536, "VIRTUAL"
								   , 131072, "NO_SCRUB_DATA", 262144, "RECALL_ON_OPEN", 4194304, "RECALL_ON_DATA_ACCESS" )

		fileAttributes := []

		for k, v in FILE_ATTRIBUTE
			if (k & attributes)
				fileAttributes.Push(v)

		return fileAttributes
	}

	static findData(WIN32_FIND_DATA, sizeFormat := "auto", sizeSuffix := false) {
		local result := Map()

		static MAX_PATH := 260
		static MAXDWORD := 0xffffffff

		result["FileAttr"]          := NumGet(WIN32_FIND_DATA, 0, "uint")
		result["FileAttributes"]    := FTP.fileAttributes(NumGet(WIN32_FIND_DATA, 0, "uint"))
		result["CreationTime"]      := FTP.fileTime(NumGet(WIN32_FIND_DATA,  4, "uint64"))
		result["LastAccessTime"]    := FTP.fileTime(NumGet(WIN32_FIND_DATA, 12, "uint64"))
		result["LastWriteTime"]     := FTP.fileTime(NumGet(WIN32_FIND_DATA, 20, "uint64"))
		result["FileSize"]          := FTP.formatBytes((NumGet(WIN32_FIND_DATA, 28, "uint") * (MAXDWORD + 1)) + NumGet(WIN32_FIND_DATA, 32, "uint"), sizeFormat, sizeSuffix)
		try {
			result["FileName"]      := StrGet(WIN32_FIND_DATA.Ptr + 44, MAX_PATH, "utf-16")
		}
		catch Any {
			result["FileName"]      := ""
		}

		try {
			result["AlternateFileName"] := StrGet(WIN32_FIND_DATA.Ptr + 44 + MAX_PATH, MAX_PATH, "utf-16")
		}
		catch Any {
			result["AlternateFileName"] := ""
		}

		return result
	}

	static findFirstFile(hConnect, &hFind, pattern := "*.*", sizeFormat := "auto", sizeSuffix := false) {
		local zero := 0

		WIN32_FIND_DATA := Buffer(592, 0)

		if (hFind := DllCall("wininet\FtpFindFirstFile", "ptr", hConnect, "str", pattern, "ptr", WIN32_FIND_DATA, "uint", 0, "uint*", zero))
			return FTP.findData(WIN32_FIND_DATA, sizeFormat, sizeSuffix)

		WIN32_FIND_DATA := Buffer(0)

		return false
	}

	static findNextFile(hFind, pattern := "*.*", sizeFormat := "auto", sizeSuffix := false) {
		WIN32_FIND_DATA := Buffer(592, 0)

		if (DllCall("wininet\InternetFindNextFile", "ptr", hFind, "ptr", WIN32_FIND_DATA))
			return FTP.findData(WIN32_FIND_DATA, sizeFormat, sizeSuffix)

		WIN32_FIND_DATA := Buffer(0)

		return false
	}

	static systemTimeToTzSpecificLocalTime(systemTime, &localTime) {
		localTime := Buffer(16, 0)

		if (DllCall("SystemTimeToTzSpecificLocalTime", "ptr", 0, "ptr", systemTime, "ptr", localTime))
			return true
		else
			return false
	}

	static fileTime(addr) {
		local systemTime, localTime

		FTP.fileTimeToSystemTime(addr, &systemTime)

		FTP.systemTimeToTzSpecificLocalTime(systemTime, &localTime)

		return Format("{:04}{:02}{:02}{:02}{:02}{:02}"
					, NumGet(localTime, 0, "ushort")
					, NumGet(localTime, 2, "ushort")
					, NumGet(localTime, 6, "ushort")
					, NumGet(localTime, 8, "ushort")
					, NumGet(localTime, 10, "ushort")
					, NumGet(localTime, 12, "ushort"))
	}

	static fileTimeToSystemTime(fileTime, &systemTime) {
		systemTime := Buffer(16, 0)

		if (DllCall("FileTimeToSystemTime", "int64*", &fileTime, "ptr", systemTime))
			return true
		else
			return false
	}

	static formatBytes(bytes, sizeFormat := "auto", suffix := false) {
		local size, buf, output

		static SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT    := 0x0001
		static SFBS_FLAGS_TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS := 0x0002
		static S_OK := 0

		if (sizeFormat = "auto") {
			buf := Buffer(1024, 0)

			if (DllCall("shlwapi\StrFormatByteSizeEx", "int64", bytes, "int", SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT, "ptr", buf, "uint", buf.Size) = S_OK)
				output := StrGet(buf)
		}
		else if (sizeFormat = "kilobytes" || sizeFormat = "kb")
			output := Round(bytes / 1024, 2) . (suffix ? " KB" : "")
		else if (sizeFormat = "megabytes" || sizeFormat = "mb")
			output := Round(bytes / 1024**2, 2) . (suffix ? " MB" : "")
		else if (sizeFormat = "gigabytes" || sizeFormat = "gb")
			output := Round(bytes / 1024**3, 2) . (suffix ? " GB" : "")
		else if (sizeFormat = "terabytes" || sizeFormat = "tb")
			output := Round(bytes / 1024**4, 2) . (suffix ? " TB" : "")
		else
			output := Round(bytes, 2) . (suffix ? " Bytes" : "")

		return output
	}

	static internetOpen(agent, proxy := "", proxyBypass := "") {
		local hInternet

		static INTERNET_OPEN_TYPE_DIRECT := 1
		static INTERNET_OPEN_TYPE_PROXY  := 3

		if (hInternet := DllCall("wininet\InternetOpen", "str", agent, "uint", (proxy ? INTERNET_OPEN_TYPE_PROXY : INTERNET_OPEN_TYPE_DIRECT)
													   , "ptr", (proxy ? StrPtr(proxy) : 0), "ptr", (proxyBypass ? StrPtr(proxyBypass) : 0), "uint", 0, "ptr"))
			return hInternet
		else
			return false
	}

	static internetConnect(hInternet, serverName, port := 21, userName := "", password := "", FTP_PASV := 1) {
		local hConnect

		static INTERNET_DEFAULT_FTP_PORT := 21
		static INTERNET_SERVICE_FTP      := 1
		static INTERNET_FLAG_PASSIVE     := 0x08000000

		if (hConnect := DllCall("wininet\InternetConnect", "ptr", hInternet, "ptr", StrPtr(serverName), "ushort", (port = 21 ? INTERNET_DEFAULT_FTP_PORT : port)
														 , "ptr", (userName ? StrPtr(userName) : 0), "ptr", (password ? StrPtr(password) : 0)
														 , "uint", INTERNET_SERVICE_FTP, "uint", (FTP_PASV ? INTERNET_FLAG_PASSIVE : 0), "uptr", 0, "ptr"))
			return hConnect
		else
			return false
	}

	static internetCloseHandle(hInternet) {
		if (DllCall("wininet\InternetCloseHandle", "ptr", hInternet))
			return true
		else
			return false
	}

	static openFile(hConnect, fileName, access) {
		local hFTPSession

		static FTP_TRANSFER_TYPE_BINARY := 2

		if (hFTPSession := DllCall("wininet\FtpOpenFile", "ptr", hConnect, "ptr", StrPtr(fileName), "uint", access, "uint", FTP_TRANSFER_TYPE_BINARY, "uptr", 0))
			return hFTPSession
		else
			return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

ftpListFiles(server, user, password, path) {
	local files := []
	local hFTP := FTP.open("AHK-FTP")
	local hSession := FTP.connect(hFTP, server, user, password)
	local ignore, file

	for ignore, file in FTP.findFiles(hSession, path)
		files.Push(file["FileName"])

	FTP.disconnect(hSession)

	FTP.close(hFTP)

	return files
}

ftpClearDirectory(server, user, password, directory) {
	local hFTP := FTP.open("AHK-FTP")
	local hSession := FTP.connect(hFTP, server, user, password)
	local ignore, file

	for ignore, file in FTP.findFiles(hSession, directory)
		FTP.deleteFile(hSession, directory . "\" . file["FileName"])

	FTP.disconnect(hSession)

	FTP.close(hFTP)
}

ftpCreateDirectory(server, user, password, directory, subdirectory) {
	local hFTP := FTP.open("AHK-FTP")
	local hSession := FTP.connect(hFTP, server, user, password)
	local ignore, file

	for ignore, file in FTP.findFiles(hSession, directory)
		FTP.createDirectory(hSession, directory . "\" . subdirectory)

	FTP.disconnect(hSession)

	FTP.close(hFTP)
}

ftpRemoveDirectory(server, user, password, directory, subdirectory) {
	local hFTP := FTP.open("AHK-FTP")
	local hSession := FTP.connect(hFTP, server, user, password)
	local ignore, file

	for ignore, file in FTP.findFiles(hSession, directory)
		FTP.removeDirectory(hSession, directory . "\" . subdirectory)

	FTP.disconnect(hSession)

	FTP.close(hFTP)
}

ftpUpload(server, user, password, localFile, remoteFile) {
	local m, h, f

    static a := "AHK-FTP"

	m := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")
	h := DllCall("wininet\InternetOpen", "ptr", StrPtr(a), "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")

    if (!m || !h)
        return false

	f := DllCall("wininet\InternetConnect", "ptr", h, "ptr", StrPtr(server), "ushort", 21, "ptr", StrPtr(user), "ptr", StrPtr(password), "uint", 1, "uint", 0x08000000, "uptr", 0, "ptr")

    if f {
        if !DllCall("wininet\FtpPutFile", "ptr", f, "ptr", StrPtr(localFile), "ptr", StrPtr(remoteFile), "uint", 0, "uptr", 0) {
			DllCall("wininet\InternetCloseHandle", "ptr", h) && DllCall("FreeLibrary", "ptr", m)

			return false
		}

        DllCall("wininet\InternetCloseHandle", "ptr", f)
    }

	DllCall("wininet\InternetCloseHandle", "ptr", h) && DllCall("FreeLibrary", "ptr", m)

	return true
}

ftpDownload(server, user, password, remoteFile, localFile) {
	local hFTP := FTP.open("AHK-FTP")
	local hSession := FTP.connect(hFTP, server, user, password)

	FTP.getFile(hSession, remoteFile, localFile)

	FTP.disconnect(hSession)

	FTP.close(hFTP)
}