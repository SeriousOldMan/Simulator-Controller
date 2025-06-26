;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - HTTP library                    ;;;
;;;                                                                         ;;;
;;;   Based on work found at https://github.com/htadashi/GPT3-AHK           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "JSON.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class WinHTTPRequest extends WinHttpRequest._Call {
    static _doc := ""

    __New(options := "") {
        if !isObject(options)
            options := {}

        this.whr := ComObject("WinHttp.WinHttpRequest.5.1")

        if !options.HasProp("Proxy")
            this.whr.SetProxy(0)
        else if (options.Proxy = "DIRECT")
            this.whr.SetProxy(1)
        else
            this.whr.SetProxy(2, options.Proxy)

        if (options.HasProp("Revocation")) ; EnableCertificateRevocationCheck
            this.whr.Option[18] := options.Revocation
        if (options.HasProp("SslError")) { ; SslErrorIgnoreFlags
            if (options.SslError = false)
                options.SslError := 0x3300 ; Ignore all
            else
                this.whr.Option[18] := true ; Check revocation

            this.whr.Option[4] := options.SslError
        }

        if (!options.HasProp("TLS")) ; SecureProtocols
            this.whr.Option[9] := 0x2800 ; TLS 1.2/1.3

        if (options.HasProp("UA")) ; UserAgentString
            this.whr.Option[0] := options.UA

        if (options.HasProp("Timeouts"))
            this.SetTimeouts(options.Timeouts*)

        if (options.HasProp("Certificate") && (options.Certificate != false))
            this.whr.Option[5] := options.Certificate
    }

    __Delete() {
        this.whr := ""
    }

    static EncodeUri(uri) {
        return WinHTTPRequest._EncodeDecode(uri, true, false)
    }

    static EncodeUriComponent(component) {
        return WinHTTPRequest._EncodeDecode(component, true, true)
    }

    static DecodeUri(uri) {
        return WinHTTPRequest._EncodeDecode(uri, false, false)
    }

    static DecodeUriComponent(component) {
        return WinHTTPRequest._EncodeDecode(component, false, true)
    }

    ObjToQuery(data) {
        local result := ""
        local key, value

        if !isObject(data)
            return data

        for key, value in (isInstance(data, Map) ? data : data.OwnProps()) {
            result .= WinHTTPRequest.EncodeUriComponent(key) "="
            result .= WinHTTPRequest.EncodeUriComponent(value) "&"
        }

        return RTrim(result, "&")
    }

    QueryToObj(data) {
        local result := {}
        local ignore, part, pair, key, value

        if (isObject(data))
            return data

        data := LTrim(data, "?")

        for ignore, part in StrSplit(data, "&") {
            pair := StrSplit(part, "=", , 2)

            key := WinHTTPRequest.DecodeUriComponent(pair[1])
            value := WinHTTPRequest.DecodeUriComponent(pair[2])

            result.%key% := value
        }

        return result
    }

    SetTimeouts(resolve := 0, connect := 60000, send := 30000, receive := 30000) {
        if (!this.whr)
            throw "Internal error detected in WinHTTPRequest.SetTimeouts..."

        this.whr.SetTimeouts(resolve, connect, send, receive)
    }

    Request(method, url, body := "", headers := false, options := false) {
        local multipart, forceSave, result, key, value

        if (!this.whr)
            throw "Internal error detected in WinHTTPRequest.Request..."

        method := Format("{:U}", method)

        if !(method ~= "^(DELETE|GET|HEAD|OPTIONS|PATCH|POST|PUT|TRACE)$")
            throw "Invalid HTTP verb detected in WinHTTPRequest.Request..."

        url := Trim(url)

        if (url = "")
            throw "Empty URL detected in WinHTTPRequest.Request..."

        if !isObject(headers)
            headers := {}

        if !isObject(options)
            options := {}

        if (method = "POST") {
            multipart := (options.HasProp("Multipart") && options.Multipart)

            this._Post(&body, &headers, multipart)
        }
        else if (method = "GET" && body) {
            url := RTrim(url, "&")
            url .= (InStr(url, "?") ? "&" : "?")
            url .= this.ObjToQuery(body)

            VarSetStrCapacity(body, 0)
        }

        this.whr.Open(method, url, true)

        for key, value in (isInstance(headers, Map) ? headers : headers.OwnProps())
            this.whr.SetRequestHeader(key, value)

        if options.HasProp("Content")
            this.whr.SetRequestHeader("Content-Type", options.Content)

        this.whr.Send(body)
        this.whr.WaitForResponse()

        if (options.HasProp("Save") && options.Save) {
            target := RegExReplace(options.Save, "^\h*\*\h*", , &forceSave)

            if ((this.whr.Status = 200) || forceSave)
                this._Save(target)

            return this.whr.Status
        }

        result := WinHTTPRequest._Response()

        result.Headers := this._Headers()
        result.Status := this.whr.Status

        try {
            result.Text := this._Text(options.HasProp("Encoding") && options.Encoding)
        }
        catch {
            result.Text := ""
        }

        return result
    }

    static _EncodeDecode(text, encode, component) {
        local action := ((encode ? "en" : "de") . "codeURI" . (component ? "Component" : ""))

        if (WinHTTPRequest._doc = "") {
            WinHTTPRequest._doc := ComObject("HTMLFile")

            WinHTTPRequest._doc.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
        }

        return (WinHTTPRequest._doc.parentWindow).%action%(text)
    }

    static _Mime(extension) {
        static mime := CaseInsenseMap("7z", "application/x-7z-compressed"
                                    , "gif", "image/gif"
                                    , "jpg", "image/jpeg"
                                    , "json", "application/json"
                                    , "png", "image/png"
                                    , "zip", "application/zip"
                                    , "txt", "text/plain")

        return (mime.Has(extension) ? mime[Extension] : "application/octet-stream")
    }

    _Headers() {
        local headers := RTrim(this.whr.GetAllResponseHeaders(), "`r`n")
        local result := {}
        local ignore, line, pair

        for ignore, line in StrSplit(headers, "`n", "`r") {
            pair := StrSplit(line, ":", " ", 2)

            result.%pair[1]% := pair[2]
        }

        return result
    }

    _MultiPart(&body) {
        local field, value, boundary, ptr

        static EOL := "`r`n"

        this._memLen := 0
        this._memPtr := DllCall("LocalAlloc", "UInt", 0x0040, "UInt", 1)

        boundary := "----------WinHttpRequest-" . A_NowUTC . A_MSec

        for field, value in (isInstance(body, Map) ? body : body.OwnProps())
            this._MultiPartAdd(boundary, EOL, field, value)

        this._MultipartStr("--" . boundary . "--" . EOL)

        body := ComObjArray(0x11, this._memLen)

        ptr := NumGet(ComObjValue(body) + 8 + A_PtrSize, "Ptr")

        DllCall("RtlMoveMemory", "Ptr", ptr, "Ptr", this._memPtr, "Ptr", this._memLen)
        DllCall("LocalFree", "Ptr", this._memPtr)

        return boundary
    }

    _MultiPartAdd(boundary, EOL, field, value) {
        local ignore, path, file, ext

        if !isObject(value) {
            str := ("--" . boundary)
            str .= EOL
            str .= ("Content-Disposition: form-data; name=`"" . field . "`n")
            str .= EOL
            str .= EOL
            str .= value
            str .= EOL

            this._MultipartStr(str)
        }
        else
            for ignore, path in (isInstance(value, Map) ? value : value.OwnProps()) {
                SplitPath(path, &file, , &ext)

                str := ("--" . boundary)
                str .= EOL
                str .= ("Content-Disposition: form-data; name=`"" . field . "`"; filename=`"" . file . "`"")
                str .= EOL
                str .= ("Content-Type: " . WinHTTPRequest._Mime(ext))
                str .= EOL
                str .= EOL

                this._MultipartStr(str)
                this._MultipartFile(path)
                this._MultipartStr(EOL)
            }
    }

    _MultipartFile(path) {
        local file := FileOpen(path, 0x0)

        this._memLen += file.Length
        this._memPtr := DllCall("LocalReAlloc", "Ptr", this._memPtr, "UInt", this._memLen, "UInt", 0x0042)

        file.RawRead(this._memPtr + this._memLen - file.Length, file.Length)
    }

    _MultipartStr(text) {
        local size := (StrPut(text, "UTF-8") - 1)

        this._memLen += size
        this._memPtr := DllCall("LocalReAlloc", "Ptr", this._memPtr, "UInt", this._memLen + 1, "UInt", 0x0042)

        StrPut(text, this._memPtr + this._memLen - size, size, "UTF-8")
    }

    _Post(&body, &headers, multipart) {
        local ignore, value

        if isObject(body)
            for ignore, value in (isInstance(body, Map) ? body : body.OwnProps())
                isMultipart := (multipart || !!isObject(value))

        if multipart {
            body := this.QueryToObj(body)

            boundary := this._MultiPart(&body)

            if isInstance(headers, Map)
                headers["Content-Type"] := ("multipart/form-data; boundary=`"" . boundary . "`"")
            else
                headers.Content_Type := ("multipart/form-data; boundary=`"" . boundary . "`"")
        }
        else {
            body := this.ObjToQuery(body)

            if isInstance(headers, Map) {
                if !headers.Has("Content-Type")
                    headers["Content-Type"] := "application/x-www-form-urlencoded"
            }
            else if !headers.HasProp("Content_Type")
                headers.Content_Type := "application/x-www-form-urlencoded"
        }
    }

    _Save(target) {
        local arr := this.whr.ResponseBody
        local ptr := NumGet(ComObjValue(arr) + 8 + A_PtrSize, "Ptr")
        local length := (arr.MaxIndex() + 1)
        local file := FileOpen(target, 0x1)

        file.RawWrite(ptr + 0, length)
        file.Close()
    }

    _Text(encoding) {
        local response := ""
        local arr, ptr, length

        try
            response := this.whr.ResponseText

        if ((response = "") || encoding) {
            arr := this.whr.ResponseBody
            ptr := NumGet(ComObjValue(arr) + 8 + A_PtrSize, "Ptr")
            length := (arr.MaxIndex() + 1)

            response := StrGet(ptr, length, encoding)
        }

        return response
    }

    class _Call {
        __Call(name, arguments) {
            return this.Request(name, arguments*)
        }
    }

    class _Response {
        JSON {
            get {
                return JSON.parse(this.Text)
            }
        }
    }
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

HTTPRequest(options := false) {
    static instance := false

    if (options = false)
        instance := false
    else if !instance
        instance := WinHTTPRequest(options)

    return instance
}

httpGet(url, options := "", encoding := "UTF-8", content := "text/plain") {
    return WinHttpRequest(options).GET(url, "", false, {Encoding: encoding, Content: content}).Text
}

httpPost(url, data, options := "", encoding := "UTF-8", content := "text/plain") {
    WinHttpRequest(options).POST(url, data, false, {Encoding: encoding})
}