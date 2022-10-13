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
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class FTP {
	static hWININET := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")

	open(agent, proxy := "", proxyBypass := "") {
		if (hInternet := this.internetOpen(agent, proxy, proxyBypass))
			return hInternet
		else
			return false
	}

	close(hInternet) {
		if (hInternet && this.internetCloseHandle(hInternet))
			return true
		else
			return false
	}

	connect(hInternet, serverName, userName := "", password := "", port := 21, FTP_PASV := 1) {
		local hConnect

		if (hConnect := this.internetConnect(hInternet, serverName, port, userName, password, FTP_PASV))
			return hConnect
		else
			return false
	}

	disconnect(hConnect) {
		if (hConnect && this.internetCloseHandle(hConnect))
			return true
		else
			return false
	}

	createDirectory(hConnect, directory) {
		if (DllCall("wininet\FtpCreateDirectory", "ptr", hConnect, "ptr", &directory))
			return true
		else
			return false
	}

	removeDirectory(hConnect, directory) {
		if (DllCall("wininet\FtpRemoveDirectory", "ptr", hConnect, "ptr", &directory))
			return true
		else
			return false
	}

	getCurrentDirectory(hConnect) {
		local BUFFER_SIZE, currentDirectory

		static MAX_PATH := 260 + 8

		BUFFER_SIZE := VarSetCapacity(currentDirectory, MAX_PATH, 0)

		if (DllCall("wininet\FtpGetCurrentDirectory", "ptr", hConnect, "ptr", &currentDirectory, "uint*", BUFFER_SIZE))
			return StrGet(&CurrentDirectory)
		else
			return false
	}

	setCurrentDirectory(hconnect, directory) {
		if (DllCall("wininet\FtpSetCurrentDirectory", "ptr", hConnect, "ptr", &directory))
			return true
		else
			return false
	}

	findFiles(hConnect, pattern := "*.*") {
		local hEnum
		local files := []
		local find := this.findFirstFile(hConnect, hEnum, pattern)

		static FILE_ATTRIBUTE_DIRECTORY := 0x10

		if find {
			if !(find.FileAttr & FILE_ATTRIBUTE_DIRECTORY)
				files.Push(find)

			while (find := this.FindNextFile(hEnum))
				if !(find.FileAttr & FILE_ATTRIBUTE_DIRECTORY)
					files.Push(find)
		}

		this.close(hEnum)

		return files
	}

	findFolders(hConnect, pattern := "*.*") {
		local hEnum
		local folders := []
		local find := this.findFirstFile(hConnect, hEnum, pattern)

		static FILE_ATTRIBUTE_DIRECTORY := 0x10

		if find {
			if (find.FileAttr & FILE_ATTRIBUTE_DIRECTORY)
				folders.Push(find)

			while (find := this.findNextFile(hEnum))
				if (find.FileAttr & FILE_ATTRIBUTE_DIRECTORY)
					folders.Push(find)
		}

		this.close(hEnum)

		return folders
	}

	putFile(hConnect, localFile, remoteFile, flags := 0) {
		if (DllCall("wininet\FtpPutFile", "ptr", hConnect, "ptr", &localFile, "ptr", &remoteFile, "uint", flags, "uptr", 0))
			return true
		else
			return false
	}

	renameFile(hConnect, existingFile, newName) {
		if (DllCall("wininet\FtpRenameFile", "ptr", hConnect, "ptr", &existingFile, "ptr", &newName))
			return true
		else
			return false
	}

	deleteFile(hConnect, fileName) {
		if (DllCall("wininet\FtpDeleteFile", "ptr", hConnect, "ptr", &fileName))
			return true
		else
			return false
	}

	getFile(hConnect, remoteFile, localFile, overWrite := false, flags := 0) {
		if (DllCall("wininet\FtpGetFile", "ptr", hConnect, "ptr", &remoteFile, "ptr", &localFile, "int", !overWrite, "uint", 0, "uint", flags, "uptr", 0))
			return true
		else
			return false
	}

	getFileSize(hConnect, fileName, sizeFormat := "auto", sizeSuffix := false) {
		local hFile, fileSizeHigh, fileSizeLow

		static GENERIC_READ := 0x80000000

		if (hFile := this.openFile(hConnect, fileName, GENERIC_READ)) {
			VarSetCapacity(fileSizeHigh, 8)

			if (fileSizeLow := DllCall("wininet\FtpGetFileSize", "ptr", hFile, "uint*", fileSizeHigh, "uint")) {
				this.internetCloseHandle(hFile)

				return this.formatBytes(fileSizeLow + (fileSizeHigh << 32), sizeFormat, sizeSuffix)
			}
			else {
				this.internetCloseHandle(hFile)

				return false
			}
		}
		else
			return false
	}

	fileAttributes(attributes) {
		local fileAttributes := []
		local k, v

		static FILE_ATTRIBUTE := { 0x1: "READONLY", 0x2: "HIDDEN", 0x4: "SYSTEM", 0x10: "DIRECTORY", 0x20: "ARCHIVE", 0x40: "DEVICE", 0x80: "NORMAL"
								 , 0x100: "TEMPORARY", 0x200: "SPARSE_FILE", 0x400: "REPARSE_POINT", 0x800: "COMPRESSED", 0x1000: "OFFLINE"
								 , 0x2000: "NOT_CONTENT_INDEXED", 0x4000: "ENCRYPTED", 0x8000: "INTEGRITY_STREAM", 0x10000: "VIRTUAL"
								 , 0x20000: "NO_SCRUB_DATA", 0x40000: "RECALL_ON_OPEN", 0x400000: "RECALL_ON_DATA_ACCESS" }

		fileAttributes := []

		for k, v in FILE_ATTRIBUTE
			if (k & attributes)
				fileAttributes.Push(v)

		return fileAttributes
	}

	findData(ByRef WIN32_FIND_DATA, sizeFormat := "auto", sizeSuffix := false) {
		local addr := &WIN32_FIND_DATA
		local result := []

		static MAX_PATH := 260
		static MAXDWORD := 0xffffffff

		result["FileAttr"]          := NumGet(addr + 0, "uint")
		result["FileAttributes"]    := this.fileAttributes(NumGet(addr + 0, "uint"))
		result["CreationTime"]      := this.fileTime(NumGet(addr +  4, "uint64"))
		result["LastAccessTime"]    := this.fileTime(NumGet(addr + 12, "uint64"))
		result["LastWriteTime"]     := this.fileTime(NumGet(addr + 20, "uint64"))
		result["FileSize"]          := this.formatBytes((NumGet(addr + 28, "uint") * (MAXDWORD + 1)) + NumGet(addr + 32, "uint"), sizeFormat, sizeSuffix)
		result["FileName"]          := StrGet(addr + 44, "utf-16")
		result["AlternateFileName"] := StrGet(addr + 44 + MAX_PATH * (A_IsUnicode ? 2 : 1), "utf-16")

		return result
	}

	findFirstFile(hConnect, ByRef hFind, pattern := "*.*", sizeFormat := "auto", sizeSuffix := false) {
		VarSetCapacity(WIN32_FIND_DATA, (A_IsUnicode ? 592 : 320), 0)

		if (hFind := DllCall("wininet\FtpFindFirstFile", "ptr", hConnect, "str", pattern, "ptr", &WIN32_FIND_DATA, "uint", 0, "uint*", 0))
			return this.findData(WIN32_FIND_DATA, sizeFormat, sizeSuffix)

		VarSetCapacity(WIN32_FIND_DATA, 0)

		return false
	}

	findNextFile(hFind, pattern := "*.*", sizeFormat := "auto", sizeSuffix := false) {
		VarSetCapacity(WIN32_FIND_DATA, (A_IsUnicode ? 592 : 320), 0)

		if (DllCall("wininet\InternetFindNextFile", "ptr", hFind, "ptr", &WIN32_FIND_DATA))
			return this.FindData(WIN32_FIND_DATA, sizeFormat, sizeSuffix)

		VarSetCapacity(WIN32_FIND_DATA, 0)

		return false
	}

	systemTimeToTzSpecificLocalTime(systemTime, ByRef localTime) {
		VarSetCapacity(localTime, 16, 0)

		if (DllCall("SystemTimeToTzSpecificLocalTime", "ptr", 0, "ptr", systemTime, "ptr", &localTime))
			return true
		else
			return false
	}

	fileTime(addr) {
		this.fileTimeToSystemTime(addr, systemTime)

		this.systemTimeToTzSpecificLocalTime(&systemTime, localTime)

		return Format("{:04}{:02}{:02}{:02}{:02}{:02}"
					, NumGet(localTime,  0, "ushort")
					, NumGet(localTime,  2, "ushort")
					, NumGet(localTime,  6, "ushort")
					, NumGet(localTime,  8, "ushort")
					, NumGet(localTime, 10, "ushort")
					, NumGet(localTime, 12, "ushort"))
	}

	fileTimeToSystemTime(fileTime, ByRef systemTime) {
		VarSetCapacity(systemTime, 16, 0)

		if (DllCall("FileTimeToSystemTime", "int64*", fileTime, "ptr", &systemTime))
			return true
		else
			return false
	}

	formatBytes(bytes, sizeFormat := "auto", suffix := false) {
		local buf, size, output

		static SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT    := 0x0001
		static SFBS_FLAGS_TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS := 0x0002
		static S_OK := 0

		if (sizeFormat = "auto") {
			size := VarSetCapacity(buf, 1024, 0)

			if (DllCall("shlwapi\StrFormatByteSizeEx", "int64", bytes, "int", SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT, "str", buf, "uint", size) = S_OK)
				output := buf
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

	internetOpen(agent, proxy := "", proxyBypass := "") {
		local hInternet

		static INTERNET_OPEN_TYPE_DIRECT := 1
		static INTERNET_OPEN_TYPE_PROXY  := 3

		if (hInternet := DllCall("wininet\InternetOpen", "ptr",  &agent
													   , "uint", (proxy ? INTERNET_OPEN_TYPE_PROXY : INTERNET_OPEN_TYPE_DIRECT)
													   , "ptr",  (proxy ? &proxy : 0)
													   , "ptr",  (proxyBypass ? &proxyBypass : 0)
													   , "uint", 0
													   , "ptr"))
			return hInternet
		else
			return false
	}

	internetConnect(hInternet, serverName, port := 21, userName := "", password := "", FTP_PASV := 1) {
		local hConnect

		static INTERNET_DEFAULT_FTP_PORT := 21
		static INTERNET_SERVICE_FTP      := 1
		static INTERNET_FLAG_PASSIVE     := 0x08000000

		if (hConnect := DllCall("wininet\InternetConnect", "ptr",    hInternet
														 , "ptr",    &serverName
														 , "ushort", (port = 21 ? INTERNET_DEFAULT_FTP_PORT : port)
														 , "ptr",    (userName ? &userName : 0)
														 , "ptr",    (password ? &password : 0)
														 , "uint",   INTERNET_SERVICE_FTP
														 , "uint",   (FTP_PASV ? INTERNET_FLAG_PASSIVE : 0)
														 , "uptr",   0
														 , "ptr"))
			return hConnect
		else
			return false
	}

	internetCloseHandle(hInternet) {
		if (DllCall("wininet\InternetCloseHandle", "ptr", hInternet))
			return true
		else
			return false
	}

	openFile(hConnect, fileName, access) {
		local hFTPSession

		static FTP_TRANSFER_TYPE_BINARY := 2

		if (hFTPSession := DllCall("wininet\FtpOpenFile", "ptr", hConnect, "ptr", &fileName, "uint", access, "uint", FTP_TRANSFER_TYPE_BINARY, "uptr", 0))
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
		files.Push(file.FileName)

	FTP.disconnect(hSession)

	FTP.close(hFTP)

	return files
}

ftpClearDirectory(server, user, password, directory) {
	local hFTP := FTP.open("AHK-FTP")
	local hSession := FTP.connect(hFTP, server, user, password)
	local ignore, file

	for ignore, file in FTP.findFiles(hSession, directory)
		FTP.deleteFile(hSession, directory . "\" . file.FileName)

	FTP.disconnect(hSession)

	FTP.close(hFTP)
}

ftpUpload(server, user, password, localFile, remoteFile) {
	local m, h, f

    static a := "AHK-FTP"

	m := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")
	h := DllCall("wininet\InternetOpen", "ptr", &a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")

    if (!m || !h)
        return false

	f := DllCall("wininet\InternetConnect", "ptr", h, "ptr", &server, "ushort", 21, "ptr", &user, "ptr", &password, "uint", 1, "uint", 0x08000000, "uptr", 0, "ptr")

    if f {
        if !DllCall("wininet\FtpPutFile", "ptr", f, "ptr", &localFile, "ptr", &remoteFile, "uint", 0, "uptr", 0)
            return false, (DllCall("wininet\InternetCloseHandle", "ptr", h) && DllCall("FreeLibrary", "ptr", m))

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