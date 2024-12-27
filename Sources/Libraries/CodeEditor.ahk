;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Syntax coloring Code Editor     ;;;
;;;                                                                         ;;;
;;;   Based on the great work of the TheArkive and Scintilla.org.           ;;;
;;;   See https://github.com/TheArkive/scintilla_ahk2 for more information  ;;;
;;;   and the download of the original work.                                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#include "..\Framework\Framework.ahk"
#include "..\Framework\Gui.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#include "..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class CodeEditor extends Gui.Custom {
    iEditable := true

    static p := A_PtrSize
    static u := StrLen(Chr(0xFFFF))

    static DirectFunc := 0
    static DirectStatusFunc := 0

    static WM_Notify := {AutoCCancelled: 0x7E9
                       , AutoCCharDeleted: 0x7EA
                       , AutoCCompleted: 0x7EE
                       , AutoCSelection: 0x7E6
                       , AutoCSelectionChange: 0x7F0
                       , CallTipClick: 0x7E5
                       , CharAdded: 0x7D1
                       , DoubleClick: 0x7D6
                       , DwellEnd: 0x7E1
                       , DwellStart: 0x7E0
                       , FocusIn: 0x7EC
                       , FocusOut: 0x7ED
                       , HotSpotClick: 0x7E3
                       , HotSpotDoubleClick: 0x7E4
                       , HotSpotReleaseClick: 0x7EB
                       , IndicatorClick: 0x7E7
                       , IndicatorRelease: 0x7E8
                       , Key: 0x7D5
                       , MacroRecord: 0x7D9
                       , MarginClick: 0x7DA
                       , MarginRightClick: 0x7EF
                       , Modified: 0x7D8
                       , ModifyAtTempTRO: 0x7D4
                       , NeedShown: 0x7DB
                       , Painted: 0x7DD
                       , SavePointLeft: 0x7D3
                       , SavePointReached: 0x7D2
                       , StyleNeeded: 0x7D0
                       , UpdateUI: 0x7D7
                       , UriDropped: 0x7DF
                       , UserListSelection: 0x7DE
                       , Zoom: 0x7E2}

    static scn_id := this.p
         , scn_wmmsg := this.p * 2
         , scn_pos := (this.p = 4)                  ? 12 : 24
         , scn_ch := (this.p = 4)                   ? 16 : 32
         , scn_mod := (this.p = 4)                  ? 20 : 36
         , scn_modType := (this.p = 4)              ? 24 : 40
         , scn_text := (this.p = 4)                 ? 28 : 48
         , scn_length := (this.p = 4)               ? 32 : 56
         , scn_linesAdded := (this.p = 4)           ? 36 : 64
         , scn_message := (this.p = 4)              ? 40 : 72
         , scn_wParam := (this.p = 4)               ? 44 : 80
         , scn_lParam := (this.p = 4)               ? 48 : 88
         , scn_line := (this.p = 4)                 ? 52 : 96
         , scn_foldLevelNow := (this.p = 4)         ? 56 : 104
         , scn_foldLevelPrev := (this.p = 4)        ? 60 : 108
         , scn_margin := (this.p = 4)               ? 64 : 112
         , scn_listType := (this.p = 4)             ? 68 : 116
         , scn_x := (this.p = 4)                    ? 72 : 120
         , scn_y := (this.p = 4)                    ? 76 : 124
         , scn_token := (this.p = 4)                ? 80 : 128
         , scn_annotationLinesAdded := (this.p = 4) ? 84 : 136
         , scn_updated := (this.p = 4)              ? 88 : 144
         , scn_listCompletionMethod := (this.p = 4) ? 92 : 148
         , scn_characterSource := (this.p = 4)      ? 96 : 152

    static sc_eol := {Hidden: 0
                    , Standard: 0x1
                    , Boxed: 0x2
                    , Stadium: 0x100
                    , FlatCircle: 0x101
                    , AngleCircle: 0x102
                    , CircleFlat: 0x110
                    , Flats: 0x111
                    , AngleFlat: 0x112
                    , CircleAngle: 0x120
                    , FlatAngle: 0x121
                    , Angles: 0x122}

    static sc_mod := {Ctrl: 2, Alt: 4, Shift: 1, Meta: 16, Super: 8}

    static sc_updated := {Content: 0x1, Selection: 2, VScroll: 4, HScroll: 8}

    static sc_marker := {Circle: 0x0
                       , RoundRect: 0x1
                       , Arrow: 0x2
                       , SmallRect: 0x3
                       , ShortArrow: 0x4
                       , Empty: 0x5
                       , ArrowDown: 0x6
                       , Minus: 0x7
                       , Plus: 0x8
                       , Vline: 0x9
                       , LCorner: 0xA
                       , TCorner: 0xB
                       , BoxPlus: 0xC
                       , BoxPlusConnected: 0xD
                       , BoxMinus: 0xE
                       , BoxMinusConnected: 0xF
                       , LCornerCurve: 0x10
                       , TCornerCurve: 0x11
                       , CirclePlus: 0x12
                       , CirclePlusconnected: 0x13
                       , CircleMinus: 0x14
                       , CircleMinusconnected: 0x15
                       , Background: 0x16
                       , DotDotDot: 0x17
                       , Arrows: 0x18
                       , Pixmap: 0x19
                       , FullRect: 0x1A
                       , LeftRect: 0x1B
                       , Available: 0x1C
                       , Underline: 0x1D
                       , RgbaImage: 0x1E
                       , Bookmark: 0x1F
                       , VerticalBookmark: 0x20
                       , Character: 0x2710}

    static sc_MarkerNum := {FolderEnd: 0x19
                          , FolderOpenMid: 0x1A
                          , FolderMidTail: 0x1B
                          , FolderTail: 0x1C
                          , FolderSub: 0x1D
                          , Folder: 0x1E
                          , FolderOpen: 0x1F}

    static sc_modType := {None: 0
                        , InsertText: 0x1
                        , DeleteText: 0x2
                        , ChangeStyle: 0x4
                        , ChangeFold: 0x8
                        , User: 0x10
                        , Undo: 0x20
                        , Redo: 0x40
                        , MultiStepUndoRedo: 0x80
                        , LastStepInUndoRedo: 0x100
                        , ChangeMarker: 0x200
                        , BeforeInsert: 0x400
                        , BeforeDelete: 0x800
                        , ChangeIndicator: 0x4000
                        , ChangeLineState: 0x8000
                        , ChangeTabStops: 0x200000
                        , LexerState: 0x80000
                        , ChangeMargin: 0x10000
                        , ChangeAnnotation: 0x20000
                        , InsertCheck: 0x100000
                        , MultiLineUndoRedo: 0x1000
                        , StartAction: 0x2000
                        , Container: 0x40000}

    static sc_search := {None: 0x0
                       , WholeWord: 0x2
                       , MatchCase: 0x4
                       , WordStart: 0x100000
                       , RegXP: 0x200000
                       , POSIX: 0x400000
                       , CXX11RegEx: 0x800000}

    static charset := {8859_15: 0x3E8, ANSI: 0x0, ARABIC: 0xB2, BALTIC: 0xBA, CHINESEBIG5: 0x88, CYRILLIC: 0x4E3, DEFAULT: 0x1
                     , EASTEUROPE: 0xEE, GB2312: 0x86, GREEK: 0xA1, HANGUL: 0x81, HEBREW: 0xB1, JOHAB: 0x82, MAC: 0x4D, OEM: 0xFF
                     , OEM866: 0x362, RUSSIAN: 0xCC, SHIFTJIS: 0x80, SYMBOL: 0x2, THAI: 0xDE, TURKISH: 0xA2, VIETNAMESE: 0xA3}

    static cp := Map("UTF-8", 65001, "Japanese Shift_JIS", 932, "Simplified Chinese GBK", 936
                   , "Korean Unified Hangul Code", 949, "Traditional Chinese Big5", 950
                   , "Korean Johab", 1361)

    Editable {
        Get {
            return this.iEditable
        }

        Set {
            return (this.iEditable := value)
        }
    }

    Content[work := false] {
        Get {
            return (work ? this.Text : this.iContent)
        }

        Set {
            return (work ? (this.Text := this.iContent := value) : (this.iContent := value))
        }
    }

    static AddCodeEditor(window, options) {
		local DefaultOpt := false
		local SystemTheme := false
        local DefaultTheme := false
        local LightTheme := false
        local newOptions := ""
		local ignore, option, ctl, buf, result

        refresh() {
            if !ctl.Zombie {
                if (!ctl.Editable && (ctl.Content != ctl.Text))
                    ctl.Text := ctl.Content

                try
                    if ctl.HasProp("_wordList")
                        DllCall("CustomLexer\ChunkColoring", "UPtr", ctl.all_data().ptr, "Int", ctl.Loading
                                                           , "UPtr", ctl._wordList.ptr, "Int", ctl.CaseSense)

                Task.CurrentTask.Sleep := 50

                return Task.CurrentTask
            }
            else
                return false
        }

        for ignore, option in StrSplit(options," ")
            if RegExMatch(option, "DefaultOpts?")
                DefaultOpt := true
            else if (option = "SystemTheme")
                SystemTheme := true
            else if (option = "DefaultTheme")
                DefaultTheme := true
            else if (option = "LightTheme")
                LightTheme := true
            else
                newOptions .= ((newOptions ? A_Space : "") . option)

        ctl := window.Add("Custom", "ClassScintilla " . newOptions)
        ctl.Base := CodeEditor.Prototype
        ctl.Zombie := false

        buf := Buffer(8, 0)

		NumPut("UPtr", ctl.Hwnd, buf)

        result := DllCall("CustomLexer\Init", "UPtr", ctl.Hwnd, "UPtr")

        ctl.msg_cb := ObjBindMethod(ctl, "WM_Messages")

        Task.startTask(OnMessage.Bind(0x4E, ctl.msg_cb), 1000, kLowPriority)

        ctl.Loading := 0
        ctl.Callback := ""
        ctl.State := ""
        ctl._StatusD := 0
        ctl._UsePopup := true
        ctl._UseDirect := false
        ctl._DirectPtr := 0
        ctl.LastCode := 0

        ctl._AutoSizeNumberMargin := false
        ctl._AutoBraceMatch := false
        ctl._AutoPunctColor := false
        ctl._CharIndex := 0
        ctl.SyntaxCommentLine := ";"
        ctl.SyntaxCommentBlockA := "/*"
        ctl.SyntaxCommentBlockB := "*/"
        ctl.SyntaxStringChar := Chr(34)
        ctl.SyntaxEscapeChar := Chr(96)
        ctl.SyntaxPunctChars := "!`"$%&'()*+,-./:;<=>?@[\]^``{|}~"
        ctl.SyntaxWordChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_#"
        ctl.SyntaxString1 := Chr(34)
        ctl.SyntaxString2 := "'"
        ctl.CaseSense := false
        ctl.CustomSyntaxHighlighting := true

        ctl.InitClasses()

        ctl.BufferedDraw := 0
        ctl.SetTechnology := 2

        if DefaultOpt
            ctl.DefaultOpt()
        if SystemTheme
            ctl.SystemTheme()
        if DefaultTheme
            ctl.DefaultTheme()
        if LightTheme
            ctl.LightTheme()

        ctl.Destroy := (*) => ctl.Zombie := true

        Task.startTask(refresh, 2000, kInterruptPriority)

        return ctl
    }

    InitClasses() {
        this.Brace := CodeEditor.Brace(this)
        this.Caret := CodeEditor.Caret(this)
        this.Doc := CodeEditor.Doc(this)
        this.Edge := CodeEditor.Edge(this)
        this.EOLAnn := CodeEditor.EOLAnn(this)
        this.HotSpot := CodeEditor.Hotspot(this)
        this.LineEnding := CodeEditor.LineEnding(this)
        this.Macro := CodeEditor.Macro(this)
        this.Margin := CodeEditor.Margin(this)
        this.Marker := CodeEditor.Marker(this)
        this.Punct := CodeEditor.Punct(this)
        this.Selection := CodeEditor.Selection(this)
        this.Style := CodeEditor.Style(this)
        this.Styling := CodeEditor.Styling(this)
        this.Tab := CodeEditor.Tab(this)
        this.Target := CodeEditor.Target(this)
        this.WhiteSpace := CodeEditor.WhiteSpace(this)
        this.Word := CodeEditor.Word(this)
        this.Wrap := CodeEditor.Wrap(this)
        this.Cust := CodeEditor.Cust(this)

        this.kw1 := "", this.kw1_utf8 := Buffer(1, 0), this.kw5 := "", this.kw5_utf8 := Buffer(1, 0)
        this.kw2 := "", this.kw2_utf8 := Buffer(1, 0), this.kw6 := "", this.kw6_utf8 := Buffer(1, 0)
        this.kw3 := "", this.kw3_utf8 := Buffer(1, 0), this.kw7 := "", this.kw7_utf8 := Buffer(1, 0)
        this.kw4 := "", this.kw4_utf8 := Buffer(1, 0), this.kw8 := "", this.kw8_utf8 := Buffer(1, 0)
    }

    static Lookup(member, value) {
		local property, candidate

        for property, candidate in this.%member%.OwnProps()
            if (candidate = value)
                return property

        return ""
    }

    static GetFlags(member, value, all := false) {
        local result := ""
		local property, candidate

        for property, candidate in CodeEditor.%member%.OwnProps()
            if (candidate & value)
                result .= ((result ? A_Space : "") . property)

        return result
    }

    static RGB(R, G, B) => Format("0x{:06X}", (R << 16) | (G << 8) | B)

    WM_Messages(wParam, lParam, msg, hwnd) {
		local scn := CodeEditor.SCNotification(lParam)
		local event, msg_num, data, ticks

        static modType := CodeEditor.sc_modType

        if (this.Zombie || !this.Editable || !this.Enabled
         || this.ReadOnly || !this.Visible || !this.HasProp("_wordList"))
            return

        try {
            scn.LineBeforeInsert := this.CurLine
            scn.LinesBeforeInsert := this.Lines

            event := scn.wmmsg_txt := CodeEditor.Lookup("WM_Notify", (msg_num := scn.wmmsg))

            if this.AutoSizeNumberMargin
                this.MarginWidth(0, 33, scn)

            if (this.CustomSyntaxHighlighting && this.HasProp("_wordList")) {
                data := this.scn_data(scn)

                if ((scn.modType & modType.InsertText) || ((event = "UpdateUI") && ((scn.updated = 4) || (scn.updated = 8)))) {
                    if ((event = "Modified") && (scn.length > 1))
                        result := this.ChunkColoring(scn, data, this._wordList)
                    else if ((event = "Modified") && !scn.linesAdded)
                        result := this.ChunkColoring(scn, data, this._wordList)
                }
                else if (scn.modType & modType.BeforeDelete)
                    this.DeleteRoutine(scn, data)
                else if (scn.modType & modType.DeleteText)
                    this.ChunkColoring(scn, data, this._wordList)

                if (scn.wmmsg_txt = "StyleNeeded")
                    this.Pacify()
            }

            if this.Callback
                f := this.Callback(scn)
        }
        catch Any {
        }
    }

    MarginWidth(margin := 0, style := 33, scn := "") {
		local min_width, width

        static modType := CodeEditor.sc_modType

        if (!scn || !((scn.wmmsg_txt = "Modified") && ((scn.modType & modType.DeleteText) || (scn.modType & modType.InsertText))))
            return

        this.Style.ID := style
        this.Margin.ID := margin

        min_width := this.Margin.MinWidth
        width := (this.TextWidth(this.Lines) + this.TextWidth("0"))

        this.Margin.Width := ((width >= min_width) ? width : min_width)
    }

    Pacify() {
        local _lastPos := (this.Length - 1)
		local _style := this.GetStyle(_lastPos)

        this._sms(0x7F0, _lastPos, 0)
        this._sms(0x7F1, 1, _style)
    }

    SetKeywords(keywords*) {
		local string

        loop 8 {
            string := ((keywords.Has(A_Index)) ? (A_Space . (this.CaseSense ? Trim(keywords[A_Index])
																			: Trim(StrLower(keywords[A_Index]))) . A_Space)
											   : "")

            this.kw%A_Index% := string
            this.kw%A_Index%_utf8 := Buffer(StrPut(string, "UTF-8"), 0)

			StrPut(string, this.kw%A_Index%_utf8, "UTF-8")
        }

        this._wordList := this.MakeWordLists()
    }

    MakeWordLists() {
        local buf := Buffer(8 + (8 * A_PtrSize), 0)

        loop 8
            NumPut("Char", this.Cust.kw%A_Index%.ID, buf, A_Index - 1)

        loop 8
            NumPut("UPtr", this.kw%A_Index%_utf8.ptr, buf, ((A_Index - 1) * 8) + 8)

        return buf
    }

    scn_data(scn) {
        local buf := ((A_PtrSize = 8) ? Buffer(96, 0) : Buffer(60, 0))
		local braceStr, comment1, comment2a, comment2b, escapeChar, punctChar, str1, str2, wordChars

        NumPut("UInt", scn.pos, "UInt", scn.length, "UInt", scn.linesAdded, buf)

        NumPut("UChar", this.Cust.String1.ID, buf, 16)
        NumPut("UChar", this.Cust.String2.ID, buf, 17)
        NumPut("UChar", this.Cust.Comment1.ID, buf, 18)
        NumPut("UChar", this.Cust.Comment2.ID, buf, 19)
        NumPut("UChar", this.Cust.Brace.ID, buf, 20)
        NumPut("UChar", this.Cust.BraceHBad.ID, buf, 21)
        NumPut("UChar", this.Cust.Punct.ID, buf, 22)
        NumPut("UChar", this.Cust.Number.ID, buf, 23)

        braceStr := Buffer(StrPut(this.Brace.Chars, "UTF-8"), 0)

		StrPut(this.Brace.Chars, braceStr, "UTF-8")
        NumPut("UPtr", braceStr.ptr, buf, 24)

        comment1 := Buffer(StrPut(this.SyntaxCommentLine, "UTF-8"), 0)

        StrPut(this.SyntaxCommentLine, comment1, "UTF-8")
        NumPut("UPtr", comment1.ptr, buf, (A_PtrSize = 8) ? 32 : 28)

        comment2a := Buffer(StrPut(this.SyntaxCommentBlockA, "UTF-8"), 0)

        StrPut(this.SyntaxCommentBlockA, comment2a, "UTF-8")
        NumPut("UPtr", comment2a.ptr, buf, (A_PtrSize = 8) ? 40 : 32)

        comment2b := Buffer(StrPut(this.SyntaxCommentBlockB, "UTF-8"), 0)

        StrPut(this.SyntaxCommentBlockB, comment2b, "UTF-8")
        NumPut("UPtr", comment2b.ptr, buf, (A_PtrSize = 8) ? 48 : 36)

        escapeChar := Buffer(StrPut(this.SyntaxEscapeChar, "UTF-8"), 0)

        StrPut(this.SyntaxEscapeChar, escapeChar, "UTF-8")
        NumPut("UPtr", escapeChar.ptr, buf, (A_PtrSize = 8) ? 56 : 40)

        punctChar := Buffer(StrPut(this.SyntaxPunctChars, "UTF-8"), 0)

        StrPut(this.SyntaxPunctChars, punctChar, "UTF-8")
        NumPut("UPtr", punctChar.ptr, buf, (A_PtrSize = 8) ? 64: 44)

        str1 := Buffer(StrPut(this.SyntaxString1,"UTF-8"), 0)

        StrPut(this.SyntaxString1, str1, "UTF-8")
        NumPut("UPtr", str1.ptr, buf, (A_PtrSize = 8) ? 72 : 48)

        str2 := Buffer(StrPut(this.SyntaxString2, "UTF-8"), 0)

        StrPut(this.SyntaxString2, str2, "UTF-8")
        NumPut("UPtr", str2.ptr, buf, (A_PtrSize = 8) ? 80 : 52)

        wordChars := Buffer(StrPut(this.SyntaxWordChars, "UTF-8"), 0)

        StrPut(this.SyntaxWordChars, wordChars, "UTF-8")
        NumPut("UPtr", wordChars.ptr, buf, (A_PtrSize = 8) ? 88 : 56)

        return buf
    }

    all_data() {
        local buf := ((A_PtrSize = 8) ? Buffer(96, 0) : Buffer(60, 0))
		local braceStr, comment1, comment2a, comment2b, escapeChar, punctChar, str1, str2, wordChars

        NumPut("UInt", 0, "UInt", StrLen(this.Text), "UInt", 0, buf)

        NumPut("UChar", this.Cust.String1.ID, buf, 16)
        NumPut("UChar", this.Cust.String2.ID, buf, 17)
        NumPut("UChar", this.Cust.Comment1.ID, buf, 18)
        NumPut("UChar", this.Cust.Comment2.ID, buf, 19)
        NumPut("UChar", this.Cust.Brace.ID, buf, 20)
        NumPut("UChar", this.Cust.BraceHBad.ID, buf, 21)
        NumPut("UChar", this.Cust.Punct.ID, buf, 22)
        NumPut("UChar", this.Cust.Number.ID, buf, 23)

        braceStr := Buffer(StrPut(this.Brace.Chars, "UTF-8"), 0)

		StrPut(this.Brace.Chars, braceStr, "UTF-8")
        NumPut("UPtr", braceStr.ptr, buf, 24)

        comment1 := Buffer(StrPut(this.SyntaxCommentLine, "UTF-8"), 0)

        StrPut(this.SyntaxCommentLine, comment1, "UTF-8")
        NumPut("UPtr", comment1.ptr, buf, (A_PtrSize = 8) ? 32 : 28)

        comment2a := Buffer(StrPut(this.SyntaxCommentBlockA, "UTF-8"), 0)

        StrPut(this.SyntaxCommentBlockA, comment2a, "UTF-8")
        NumPut("UPtr", comment2a.ptr, buf, (A_PtrSize = 8) ? 40 : 32)

        comment2b := Buffer(StrPut(this.SyntaxCommentBlockB, "UTF-8"), 0)

        StrPut(this.SyntaxCommentBlockB, comment2b, "UTF-8")
        NumPut("UPtr", comment2b.ptr, buf, (A_PtrSize = 8) ? 48 : 36)

        escapeChar := Buffer(StrPut(this.SyntaxEscapeChar, "UTF-8"), 0)

        StrPut(this.SyntaxEscapeChar, escapeChar, "UTF-8")
        NumPut("UPtr", escapeChar.ptr, buf, (A_PtrSize = 8) ? 56 : 40)

        punctChar := Buffer(StrPut(this.SyntaxPunctChars, "UTF-8"), 0)

        StrPut(this.SyntaxPunctChars, punctChar, "UTF-8")
        NumPut("UPtr", punctChar.ptr, buf, (A_PtrSize = 8) ? 64: 44)

        str1 := Buffer(StrPut(this.SyntaxString1, "UTF-8"), 0)

        StrPut(this.SyntaxString1, str1, "UTF-8")
        NumPut("UPtr", str1.ptr, buf, (A_PtrSize = 8) ? 72 : 48)

        str2 := Buffer(StrPut(this.SyntaxString2, "UTF-8"), 0)

        StrPut(this.SyntaxString2, str2, "UTF-8")
        NumPut("UPtr", str2.ptr, buf, (A_PtrSize = 8) ? 80 : 52)

        wordChars := Buffer(StrPut(this.SyntaxWordChars, "UTF-8"), 0)

        StrPut(this.SyntaxWordChars, wordChars, "UTF-8")
        NumPut("UPtr", wordChars.ptr, buf, (A_PtrSize = 8) ? 88 : 56)

        return buf
    }

    ChunkColoring(scn, data, wordList) {
        try {
            result := DllCall("CustomLexer\ChunkColoring", "UPtr", data.ptr, "Int", this.Loading, "UPtr", wordList.ptr, "Int", this.CaseSense)
        }
        catch Any {
            result := 0
        }

        this.Loading := 0

        return result
    }

    DeleteRoutine(scn, data) {
        try {
            return DllCall("CustomLexer\DeleteRoutine", "UPtr", data.ptr)
        }
        catch Any {
            result := 0
        }
    }

    DefaultOpt() {
        this.Wrap.Mode := 1
        this.EndAtLastLine := false
        this.Caret.PolicyX(13, 50)
        this.Caret.LineVisible := true

        this.Margin.ID := 0
        this.Margin.Style(0, 33)
        this.Margin.Width := 20

        this.Margin.ID := 1
        this.Margin.Sensitive := true

        this.Tab.Use := false
        this.Tab.Width := 4

        this.Selection.Multi := true
        this.Selection.MultiTyping := true
        this.Selection.RectModifier := 4
        this.Selection.RectWithMouse := true
    }

    SystemTheme() {
        this.Cust.Caret.LineBack := ("0x" . Theme.CurrentTheme.FieldBackColor)
        this.Cust.Editor.Back := ("0x" . Theme.CurrentTheme.FieldBackColor)

        this.Cust.Editor.Fore := ("0x" . Theme.CurrentTheme.TextColor)
        this.Cust.Editor.Font := "Consolas"
        this.Cust.Editor.Size := 10

        this.Style.ClearAll()

        this.Cust.Margin.Back := ("0x" . Theme.CurrentTheme.WindowBackColor)
        this.Cust.Margin.Fore := ("0x" . Theme.CurrentTheme.TextColor)

        if isInstance(Theme.CurrentTheme, DarkTheme) {
            this.Cust.Caret.Fore := 0x00FF00
            this.Cust.Selection.Back := 0x550000

            this.Cust.Brace.Fore     := 0x60BB60
            this.Cust.BraceH.Fore    := 0x00FF00
            this.Cust.BraceHBad.Fore := 0xFF0000
            this.Cust.Punct.Fore     := 0x9090FF
            this.Cust.String1.Fore   := 0x666666
            this.Cust.String2.Fore   := 0x666666

            this.Cust.Comment1.Fore  := 0x008800
            this.Cust.Comment2.Fore  := 0x008800
            this.Cust.Number.Fore    := 0xFFFF00

            this.Cust.kw1.Fore := 0xc94969
            this.Cust.kw2.Fore := 0x6b66ff
            this.Cust.kw3.Fore := 0xbde03c
            this.Cust.kw4.Fore := 0xd6f955
            this.Cust.kw5.Fore := 0xf9c543
            this.Cust.kw6.Fore := 0xb5b2ff
            this.Cust.kw7.Fore := 0x127782
        }
        else {
            this.Cust.Caret.Fore := 0x222222
            this.Cust.Selection.Back := 0x398FFB
            this.Cust.Selection.ForeColor := 0xFFFFFF

            this.Cust.Brace.Fore     := 0x5F6364
            this.Cust.BraceH.Fore    := 0x00FF00
            this.Cust.BraceHBad.Fore := 0xFF0000
            this.Cust.Punct.Fore     := 0xC57F5B
            this.Cust.String1.Fore   := 0x329C1B
            this.Cust.String2.Fore   := 0x329C1B

            this.Cust.Comment1.Fore  := 0x7D8B98
            this.Cust.Comment2.Fore  := 0x7D8B98
            this.Cust.Number.Fore    := 0xC72A31

            this.Cust.kw1.Fore := 0x329C1B
            this.Cust.kw2.Fore := 0x1049BF
            this.Cust.kw2.Bold := true
            this.Cust.kw3.Fore := 0x2390B6
            this.Cust.kw3.Bold := true
            this.Cust.kw4.Fore := 0x3F8CD4
            this.Cust.kw5.Fore := 0xC72A31

            this.Cust.kw6.Fore := 0xEC9821
            this.Cust.kw7.Fore := 0x2390B6
        }
    }

    DefaultTheme() {
        this.Cust.Caret.LineBack := 0x151515

        this.Cust.Editor.Back := 0x080808
        this.Cust.Editor.Fore := 0xAAAAAA
        this.Cust.Editor.Font := "Consolas"
        this.Cust.Editor.Size := 12

        this.Style.ClearAll()

        this.Cust.Margin.Back := 0x202020
        this.Cust.Margin.Fore := 0xAAAAAA

        this.Cust.Caret.Fore := 0x00FF00
        this.Cust.Selection.Back := 0x550000

        this.Cust.Brace.Fore     := 0x0900ff
        this.Cust.BraceH.Fore    := 0x00FF00
        this.Cust.BraceHBad.Fore := 0xFF0000
        this.Cust.Punct.Fore     := 0x9090FF
        this.Cust.String1.Fore   := 0x666666
        this.Cust.String2.Fore   := 0x666666

        this.Cust.Comment1.Fore  := 0x008800
        this.Cust.Comment2.Fore  := 0x008800
        this.Cust.Number.Fore    := 0xFFFF00

        this.Cust.kw1.Fore := 0xc94969
        this.Cust.kw2.Fore := 0x6b66ff
        this.Cust.kw3.Fore := 0xbde03c
        this.Cust.kw4.Fore := 0xd6f955
        this.Cust.kw5.Fore := 0xf9c543
        this.Cust.kw6.Fore := 0xb5b2ff
        this.Cust.kw7.Fore := 0x127782
    }

    LightTheme() {
        this.Cust.Caret.LineBack := 0xF6F9FC
        this.Cust.Editor.Back := 0xFDFDFD

        this.Cust.Editor.Fore := 0x000000
        this.Cust.Editor.Font := "Consolas"
        this.Cust.Editor.Size := 10

        this.Style.ClearAll()

        this.Cust.Margin.Back := 0xF0F0F0
        this.Cust.Margin.Fore := 0x000000

        this.Cust.Caret.Fore := 0x00FF00
        this.Cust.Selection.Back := 0x398FFB
        this.Cust.Selection.ForeColor := 0xFFFFFF

        this.Cust.Brace.Fore     := 0x5F6364
        this.Cust.BraceH.Fore    := 0x00FF00
        this.Cust.BraceHBad.Fore := 0xFF0000
        this.Cust.Punct.Fore     := 0xA57F5B
        this.Cust.String1.Fore   := 0x329C1B
        this.Cust.String2.Fore   := 0x329C1B

        this.Cust.Comment1.Fore  := 0x7D8B98
        this.Cust.Comment2.Fore  := 0x7D8B98
        this.Cust.Number.Fore    := 0xC72A31

        this.Cust.kw1.Fore := 0x329C1B
        this.Cust.kw2.Fore := 0x1049BF
        this.Cust.kw2.Bold := true
        this.Cust.kw3.Fore := 0x2390B6
        this.Cust.kw3.Bold := true
        this.Cust.kw4.Fore := 0x3F8CD4
        this.Cust.kw5.Fore := 0xC72A31

        this.Cust.kw6.Fore := 0xEC9821
        this.Cust.kw7.Fore := 0x2390B6
    }

    class Cust {
        __New(sup) {
            this.Number := CodeEditor.Cust.subItem(sup, 45)
            this.Comment1 := CodeEditor.Cust.subItem(sup, 44)
            this.Comment2 := CodeEditor.Cust.subItem(sup, 47)
            this.String1 := CodeEditor.Cust.subItem(sup, 43)
            this.String2 := CodeEditor.Cust.subItem(sup, 46)
            this.Punct := CodeEditor.Cust.subItem(sup, 42)
            this.BraceH := CodeEditor.Cust.subItem(sup, 34)
            this.BraceHBad := CodeEditor.Cust.subItem(sup, 41)
            this.Brace := CodeEditor.Cust.subItem(sup, 40)
            this.Selection := sup.Selection
            this.Caret := sup.Caret
            this.Margin := CodeEditor.Cust.subItem(sup, 33)
            this.Editor := CodeEditor.Cust.subItem(sup, 32)

            this.kw1 := CodeEditor.Cust.subItem(sup, 64), this.kw5 := CodeEditor.Cust.subItem(sup, 68)
            this.kw2 := CodeEditor.Cust.subItem(sup, 65), this.kw6 := CodeEditor.Cust.subItem(sup, 69)
            this.kw3 := CodeEditor.Cust.subItem(sup, 66), this.kw7 := CodeEditor.Cust.subItem(sup, 70)
            this.kw4 := CodeEditor.Cust.subItem(sup, 67), this.kw8 := CodeEditor.Cust.subItem(sup, 71)
        }

        class subItem {
            __New(sup, ID := 0) {
                this.DefineProp("sup", {Value: sup})
                this.DefineProp("ID", {Value: ID})
            }

            __Get(n, p) {
                this.sup.Style.ID := this.ID

                return this.sup.Style.%n%
            }

            __Set(n, p, v) {
                this.sup.Style.ID := this.ID, this.sup.Style.%n% := v
            }
        }
    }

    AppendText(pos, text := "") => this._PutStr(0x8EA, pos, text)

    Characters(start, end) {
        return this._sms(0xA49, start, end)
    }

    CharIndex {
        Get => this._sms(0xA96)

        Set {
            if (value != this._CharIndex) {
                this._sms(0xA98, this._CharIndex)
                this._sms(0xA97, (this._CharIndex := value))
            }
        }
    }

    CodeUnits(start, end) => this._sms(0xA9B, start, end)

    Column(pos) => this._sms(0x851, pos)

    CurLine => this.LineFromPos(this.CurPos)

    CurPos {
        Get => this._sms(0x7D8)
        Set => this._sms(0x7E9, value)
    }

    DeleteRange(start, end) => this._sms(0xA55, start, end)

    DocLine(visible) => this._sms(0x8AD, visible)

    FindColumn(line, pos) => this._sms(0x998, line, pos)

    FirstVisibleDocLine => this.DocLine(this.FirstVisibleLine)

    FirstVisibleLine {
        Get => this._sms(0x868)
        Set => this._sms(0xA35, value)
    }

    GetChar(pos) {
        return ((pos < this.Length) ? this.GetTextRange(pos, this.NextCharPos(pos)) : "")
    }

    GetTextRange(start, end) {
		local tr

        this._sms(0x872, 0, (tr := CodeEditor.TextRange( , start, end)).ptr)

		return StrGet(tr.buf, "UTF-8")
    }

    GetStyle(pos) => this._sms(0x7DA, pos)

    InsertText(pos := -1, text := "") => this._PutStr(0x7D3, pos, text)

    Length => this._sms(0x7D6)

    LineEndPos(line) => this._sms(0x858, line)

    LineLength(line) => this._sms(0x92E, line)

    Lines => this._sms(0x86A)

    LineFromPos(pos) => this._sms(0x876, pos)

    LinesOnScreen => this._sms(0x942)

    LineText(line) {
        local buf := Buffer(this.LineLength(line))

        this._sms(0x869, line, buf.ptr)

		return StrGet(buf, "UTF-8")
    }

    NextChar(pos, offset := 1) => ((p1 := this.NextCharPos(pos, offset)) ? this.GetChar(p1) : "")

    NextCharPos(pos, offset:=1) => this._sms(0xA6E, pos, offset)

    PointFromPos(pos) => {x: this._sms(0x874,,pos), y: this._sms(0x875,,pos)}

    PosFromLine(line) => this._sms(0x877, line)

    PosFromPoint(x, y) => this._sms(0x7E7, x, y)

    PosFromPointAny(x, y) => this._sms(0x7E6, x, y)

    PosRelative(pos, length) => this._sms(0xA6E, pos, length)

    PrevChar(pos, offset := -1) => ((p1 := this.NextCharPos(pos, offset)) ? this.GetChar(p1) : "")

    PrevCharPos(pos, offset := -1) => this._sms(0xA6E, pos, offset)

    ReadOnly {
        Get => this._sms(0x85C)
        Set => this._sms(0x87B, value)
    }

    Text {
        Get => this._GetStr(0x886, this.Length + 1)
        Set => this._PutStr(0x885, 0, value)
    }

    TextWidth(txt, style := "") {
        style := ((style != "") ? style : this.Style.ID)

        return this._PutStr(0x8E4, style, txt)
    }

    Value {
        Get => this._GetStr(0x886, this.Length + 1)
        Set => this._PutStr(0x885, 0, value)
    }

    Clear() => this._sms(0x884)

    ClearAll() => this._sms(0x7D4)

    Copy() => this._sms(0x882)

    CopyLine() => this._sms(0x9D7)

    CopyRange(start, end) => this._sms(0x973, start, end)

    Cut() => this._sms(0x881)

    Focus() => this._sms(0x960)

    LinesJoin() => this._sms(0x8F0)

    LinesSplit(pixels) => this._sms(0x8F1, pixels)

    Paste() => this._sms(0x883)

    SelectAll() => this._sms(0x7DD)

    VisibleFromDocLine(_in) => this._sms(0x8AC, _in)

    Zoom {
        Get => this._sms(0x946)
        Set => this._sms(0x945, value)
    }

    ZoomIN() => this._sms(0x91D)

    ZoomOUT() => this._sms(0x91E)

	AddUndo(token, flags := 1) => this._sms(0xA00, token, flags)

    CanUndo => this._sms(0x87E)

    CanRedo => this._sms(0x7E0)

    BeginUndo() => this._sms(0x81E)

    EndUndo() => this._sms(0x81F)

    Redo() => this._sms(0x7DB)

    Undo() => this._sms(0x880)

    UndoActive {
        Get => this._sms(0x7E3)
        Set => this._sms(0x7DC, value)
    }

	UndoEmpty() => this._sms(0x87F)

    CanPaste => this._sms(0x87D)

    Focused => this._sms(0x94D)

    Modified => this._sms(0x86F)

    Status => this._StatusD

    Accessibility {
        Get => this._sms(0xA8F)
        Set => this._sms(0xA8E, value)
    }

    AutoBraceMatch {
        Get => this._AutoBraceMatch
        Set => (this._AutoBraceMatch := value)
    }

    AutoPunctColor {
        Get => this._AutoPunctColor
        Set => (this._AutoPunctColor := value)
    }

    AutoSizeNumberMargin {
        Get => this._AutoSizeNumberMargin
        Set => (this._AutoSizeNumberMargin := value)
    }

    BiDirectional {
        Get => this._sms(0xA94)
        Set => this._sms(0xA95, value)
    }

    BufferedDraw {
        Get => this._sms(0x7F2)
        Set => this._sms(0x7F3, value)
    }

    CodePage {
        Get => this._sms(0x859)
        Set => this._sms(0x7F5, value)
    }

    CommandEvents {
        Get => this._sms(0xA9E)
        Set => this._sms(0xA9D, value)
    }

    Cursor {
        Get => this._sms(0x953)
        Set => this._sms(0x952, value)
    }

    EndAtLastLine {
        Get => this._sms(0x8E6)
        Set => this._sms(0x8E5, value)
    }

    EventMask {
        Get => this._sms(0x94A)
        Set => this._sms(0x937, value)
    }

    FontQuality {
        Get => this._sms(0xA34)
        Set => this._sms(0xA33, value)
    }

    FontLocale {
        Get => this._sms(0xAC9)
        Set => this._sms(0xAC8, value)
    }

    Identifier {
        Get => this._sms(0xA3F)
        Set => this._sms(0xA3E, value)
    }

    ImeInteraction {
        Get => this._sms(0xA76)
        Set => this._sms(0xA77, value)
    }

    MouseDownCaptures {
        Get => this._sms(0x951)
        Set => this._sms(0x950)
    }

    MouseDwellTime {
        Get => this._sms(0x8D9)
        Set => this._sms(0x8D8, value)
    }

    MouseWheelCaptures {
        Get => this._sms(0xA89)
        Set => this._sms(0xA88, value)
    }

    OverType {
        Get => this._sms(0x88B)
        Set => this._sms(0x88A, value)
    }

    PasteConvertEndings {
        Get => this._sms(0x9A4)
        Set => this._sms(0x9A3)
    }

    PhaseDraw {
        Get => this._sms(0x8EB)
        Set => this._sms(0x8EC, value)
    }

    ScrollWidthTracking {
        Get => this._sms(0x9D5)
        Set => this._sms(0x9D4, value)
    }

    SetTechnology {
        Get => this._sms(0xA47)
        Set => this._sms(0xA46, value)
    }

    ScrollH {
        Get => this._sms(0x853)
        Set => this._sms(0x852, value)
    }

    ScrollV {
        Get => this._sms(0x8E9)
        Set => this._sms(0x8E8, value)
    }

    ScrollWidth {
        Get => this._sms(0x8E3)
        Set => this._sms(0x8E2, value)
    }

    SupportsFeature(n) {
        return this._sms(0xABE, n)
    }

    UsePopup {
        Get => this._UsePopup
        Set => this._sms(0x943, (this._UsePopup := value))
    }

    DirectFunc => CodeEditor.DirectFunc

    DirectPtr => this._DirectPtr

    DirectStatusFunc => CodeEditor.DirectStatusFunc

    CharacterPointer => this._sms(0x9D8)

    GapPosition => this._sms(0xA54)

    RangePointer(start, length) => this._sms(0xA53, start, length)

    UseDirect {
        Get => this._UseDirect
        Set {
            if (!CodeEditor.DirectFunc And (value = true))
                CodeEditor.DirectFunc := SendMessage(0x888, 0, 0, this.Hwnd)

            if (!CodeEditor.DirectStatusFunc And (value = true))
                CodeEditor.DirectStatusFunc := SendMessage(0xAD4, 0, 0, this.Hwnd)

            if (!this.DirectPtr And (value = true))
                this._DirectPtr  := SendMessage(0x889, 0, 0, this.Hwnd)

            this._UseDirect := value
        }
    }

    class Brace extends CodeEditor.scint_base {
        Chars := "[]{}()<>"

        BadColor {
            Get {
                this.Style.ID := 35

                return this.Style.Fore
            }
            Set {
                this.Style.ID := 35

                this.Style.Fore := value
            }
        }
        BadLight(in_pos := -1) {
            return this._sms(0x930, in_pos)
        }

        BadLightIndicator(on_off, indicator_int) {
            return this._sms(0x9C3, on_off, indicator_int)
        }

        Color {
            Get {
                this.Style.ID := 34

                return this.Style.Fore
            }
            Set {
                this.Style.ID := 34
                this.Style.Fore := value
            }
        }

        Highlight(pos_A, pos_B) {
            return this._sms(0x92F, pos_A, pos_B)
        }

        HighlightIndicator(on_off, indicator_int) {
            return this._sms(0x9C2, on_off, indicator_int)
        }

        Match(in_pos) {
            return this._sms(0x931, in_pos)
        }

        MatchNext(in_pos, start_pos) {
            return this._sms(0x941, in_pos, start_pos)
        }
    }

    class Caret extends CodeEditor.scint_base {
        Blink {
            Get => this._sms(0x81B)
            Set => this._sms(0x81C, value)
        }

        ChooseX() {
            return this._sms(0x95F)
        }

        Focus() {
            return this._sms(0x961)
        }

        Fore {
            Get => this._RGB_BGR(this._sms(0x85A))
            Set => this._sms(0x815, this._RGB_BGR(value))
        }

        GoToLine(line) {
            return this._sms(0x7E8, line)
        }

        GoToPos(pos := "") {
            pos := ((pos!="") ? pos : this.ctl.CurPos)

            return this._sms(0x7E9, pos)
        }

        LineBack {
            Get => this._sms(0xAC2, 0x32)
            Set => this._sms(0xAC1, 0x32, this._RGB_BGR(value))
        }

        LineFrame {
            Get => this._sms(0xA90)
            Set => this._sms(0xA91, value)
        }

        LineLayer {
            Get => this._sms(0xACC)
            Set => this._sms(0xACD)
        }

        LineVisibleAlways {
            Get => this._sms(0xA5E)
            Set => this._sms(0xA5F, value)
        }

        Multi {
            Get => this._sms(0xA31)
            Set => this._sms(0xA30, value)
        }

        MultiFore {
            Get => this._RGB_BGR(this._sms(0xA2D))
            Set => this._sms(0xA2C, this._RGB_BGR(value))
        }

        MultiBlink {
            Get => this._sms(0xA08)
            Set => this._sms(0xA07, value)
        }

        PolicyX(policy := 0, pixels := 0) {
            return this._sms(0x962, policy, pixels)
        }

        PolicyY(policy := 0, pixels := 0) {
            return this._sms(0x963, policy, pixels)
        }

        SetPos(pos) {
            return this._sms(0x9FC, pos)
        }

        Sticky {
            Get => this._sms(0x999)
            Set => this._sms(0x99A, value)
        }

        StickyToggle() {
            return this._sms(0x99B)
        }

        Style {
            Get => this._sms(0x9D1)
            Set => this._sms(0x9D0, value)
        }

        Width {
            Get => this._sms(0x88D)
            Set => this._sms(0x88C, value)
        }
    }

    class Doc extends CodeEditor.scint_base {
        AddRef(doc_ptr) {
            return this._sms(0x948, 0, doc_ptr)
        }

        Create(size, options:=0) {
            return this._sms(0x947, size, options)
        }

        Options {
            Get => this._sms(0x94B)
        }

        Ptr {
            Get => this._sms(0x935)
            Set => this._sms(0x936, 0, value)
        }

        Release(doc_ptr) {
            return this._sms(0x949, 0, doc_ptr)
        }
    }

    class Edge extends CodeEditor.scint_base {
        __New(ctl) {
            this.ctl := ctl
            this.Multi := CodeEditor.Edge.Multi(ctl)
        }

        Add(column, color) {
            return this._sms(0xA86, column, color)
        }

        Clear() {
            this._sms(0xA87)
        }

        Column {
            Get => this._sms(0x938)
            Set => this._sms(0x939, value)
        }

        Color {
            Get => this._RGB_BGR(this._sms(0x93C))
            Set => this._sms(0x93D, this._RGB_BGR(value))
        }

        GetNext(start_pos:=0) {
            return this._sms(0xABD, start_pos)
        }

        Mode {
            Get => this._sms(0x93A)
            Set => this._sms(0x93B, value)
        }

        class Multi extends CodeEditor.scint_base {
            Add(pos, color) {
                return this._sms(0xA86, pos, this._RGB_BGR(color))
            }

            ClearAll() {
                return this._sms(0xA87)
            }

            GetColumn(which) {
                return this._sms(0xABD, which)
            }
        }
    }

    class EOLAnn extends CodeEditor.scint_base {
        Line := 0

        ClearAll() {
            return this._sms(0xAB8)
        }

        Style {
            Get => this._sms(0xAB7, this.Line)
            Set => this._sms(0xAB6, this.Line, value)
        }

        StyleOffset {
            Get => this._sms(0xABC)
            Set => this._sms(0xABB, value)
        }

        Text {
            Get => this._GetStr(0xAB5, this.Line)
            Set => this._PutStr(0xAB4, this.Line, value)
        }

        Visible {
            Get => this._sms(0xABA)
            Set => this._sms(0xAB9, value)
        }
    }

    class Hotspot extends CodeEditor.scint_base {
        _BackColor := 0xFFFFFF
        _BackEnabled := true
        _ForeColor := 0x000000
        _ForeEnabled := true

        Back(bool, color) {
            this._BackEnabled := bool
            this._BackColor := color

            return this._sms(0x96B, bool, this._RGB_BGR(color))
        }

        BackEnabled {
            Get => this._BackEnabled
            Set => this._sms(0x96B, (this._BackEnabled := value), this._RGB_BGR(this.BackColor))
        }

        BackColor {
            Get => ((0xFF000000 & this._BackColor) ? Format("0x{:08X}", this._BackColor) : Format("0x{:06X}", this._BackColor))
            Set => this._sms(0x96B, this._BackEnabled, this._RGB_BGR(this._BackColor := value))
        }

        Fore(bool, color) {
            this._ForeEnabled := bool
            this._ForeColor := color

            return this._sms(0x96A, bool, this._RGB_BGR(color))
        }

        ForeEnabled {
            Get => this.ForeEnabled
            Set => this._sms(0x96A, (this._ForeEnabled := value), this._RGB_BGR(this._ForeColor))
        }

        ForeColor {
            Get => ((0xFF000000 & this._ForeColor) ? Format("0x{:08X}", this._ForeColor) : Format("0x{:06X}", this._ForeColor))
            Set => this._sms(0x96A, this._ForeEnabled, this._RGB_BGR(this._ForeColor := value))
        }

        SingleLine {
            Get => this._sms(0x9C1)
            Set => this._sms(0x975, value)
        }

        Underline {
            Get => this._sms(0x9C0)
            Set => this._sms(0x96C, value)
        }
    }

    class LineEnding extends CodeEditor.scint_base {
        Convert(mode) {
            return this._sms(0x7ED, mode)
        }

        Mode {
            Get => this._sms(0x7EE)
            Set => this._sms(0x7EF, value)
        }

        View {
            Get => this._sms(0x933)
            Set => this._sms(0x934, value)
        }

        TypesActive {
            Get => this._sms(0xA62)
        }

        TypesAllowed {
            Get => this._sms(0xA61)
            Set => this._sms(0xA60, value)
        }

        TypesSupported {
            Get => this._sms(0xFB2)
        }
    }

    class Macro extends CodeEditor.scint_base {
        Start() {
            return this._sms(0xBB9)
        }

        Stop() {
            return this._sms(0xBBA)
        }
    }

    class Margin extends CodeEditor.scint_base {
        ID := 0
        _MinWidth := Map()
        _FoldColorEnabled := false
        _FoldColor := 0
        _FoldHiColorEnabled := false
        _FoldHiColor := 0

        Back {
            Get => this._RGB_BGR(this._sms(0x8CB, this.ID))
            Set => this._sms(0x8CA, this.ID, this._RGB_BGR(value))
        }

        Count {
            Get => this._sms(0x8CD)
            Set => this._sms(0x8CC, value)
        }

        Cursor {
            Get => this._sms(0x8C9, this.ID)
            Set => this._sms(0x8C8, this.ID, value)
        }

        Fold(bool, color) {
            this._FoldColorEnabled := bool
            this._FoldColor := color

            return this._sms(0x8F2, bool, this._RGB_BGR(color))
        }

        FoldColor {
            Get => ((0xFF000000 & this._FoldColor) ? Format("0x{:08X}", this._FoldColor) : Format("0x{:06X}", this._FoldColor))
            Set => this._sms(0x8F2, this._FoldColorEnabled, this._RGB_BGR(this._FoldColor := value))
        }

        FoldColorEnabled {
            Get => this._FoldColorEnabled
            Set => this._sms(0x8F2, (this._FoldColorEnabled := value), this._RGB_BGR(this._FoldColor))
        }

        FoldHi(bool, color) {
            this._FoldHiColorEnabled := bool
            this._FoldHiColor := color

            return this._sms(0x8F3, bool, this._RGB_BGR(color))
        }

        FoldHiColor {
            Get => ((0xFF000000 & this._FoldHiColor) ? Format("0x{:08X}", this._FoldHiColor) : Format("0x{:06X}", this._FoldHiColor))
            Set => this._sms(0x8F3, this._FoldHiColorEnabled, this._RGB_BGR(this._FoldHiColor := value))
        }

        FoldHiColorEnabled {
            Get => this._FoldHiColorEnabled
            Set => this._sms(0x8F3, (this._FoldHiColorEnabled := value), this._RGB_BGR(this._FoldHiColor))
        }

        Left {
            Get => this._sms(0x86C)
            Set => this._sms(0x86B, 0, value)
        }

        Mask {
            Get => this._sms(0x8C5, this.ID)
            Set => this._sms(0x8C4, this.ID, value)
        }

        MinWidth {
            Get => (this._MinWidth.Has(String(this.ID)) ? this._MinWidth[String(this.ID)] : this.ctl.TextWidth("00") + 2)
            Set => this._MinWidth[String(this.ID)] := value
        }

        Right {
            Get => this._sms(0x86E)
            Set => this._sms(0x86D, 0, value)
        }

        Sensitive {
            Get => this._sms(0x8C7, this.ID)
            Set => this._sms(0x8C6, this.ID, value)
        }

        Style(line, style := "") {
            if (style = "")
                return this._sms(0x9E5, line)
            else
                return this._sms(0x9E4, line, style)
        }

        Text(line, text := A_Space) {
            if (text = A_Space)
                return this._GetStr(0x9E3, line)
            else
                return this._PutStr(0x9E2, line, text)
        }

        Type {
            Get => this._sms(0x8C1, this.ID)
            Set => this._sms(0x8C0, this.ID, value)
        }

        Width {
            Get => this._sms(0x8C3, this.ID)
            Set => this._sms(0x8C2, this.ID, value)
        }
    }

    class Marker extends CodeEditor.scint_base {
        num := 0
        _width := 0
        _height := 0
        _scale := 100
        _ForeColor := -1
        _BackColor := -1
        _BackSelectedColor := -1
        _StrokeWidth := 100
        _HighlightEnabled := false
        _Alpha := 255

        Add(line, markerNum:="") {
            return this._sms(0x7FB, line, (markerNum != "") ? markerNum : this.num)
        }

        AddSet(line, markerMask) {
            return this._sms(0x9A2, line, markerMask)
        }

        Alpha {
            Get => this._Alpha
            Set => this._sms(0x9AC, (this._Alpha := value))
        }
        Back {
            Get => ((0xFF000000 & this._BackColor) ? Format("0x{:08X}", this._BackColor) : Format("0x{:06X}", this._BackColor))
            Set {
                if (0xFF000000 & value)
                    this._sms(0x8F7, this.num, this._RGB_BGR(this._ForeColor := value))
                else
                    this._sms(0x7FA, this.num, this._RGB_BGR(this._ForeColor := value))
            }
        }

        BackSelected {
            Get => ((0xFF000000 & this._BackSelectedColor) ? Format("0x{:08X}", this._BackSelectedColor) : Format("0x{:06X}", this._BackSelectedColor))
            Set {
                if (0xFF000000 & value)
                    this._sms(0x8F8, this.num, this._RGB_BGR(this._ForeColor := value))
                else
                    this._sms(0x8F4, this.num, this._RGB_BGR(this._ForeColor := value))
            }
        }

        Delete(line, markerNum := "") {
            return this._sms(0x7FC, line, (markerNum != "") ? markerNum : this.num)
        }

        DeleteAll(markerNum := "") {
            return this._sms(0x7FD, (markerNum != "") ? markerNum : this.num)
        }

        DeleteHandle(marker) {
            return this._sms(0x7E2, marker)
        }

        Fore {
            Get => ((0xFF000000 & this._ForeColor) ? Format("0x{:08X}", this._ForeColor) : Format("0x{:06X}", this._ForeColor))
            Set {
                if (0xFF000000 & value)
                    this._sms(0x8F6, this.num, this._RGB_BGR(this._ForeColor := value))
                else
                    this._sms(0x7F9, this.num, this._RGB_BGR(this._ForeColor := value))
            }
        }

        Get(line) {
            return this._sms(0x7FE, line)
        }

        Handle(line, which) {
            return this._sms(0xAAC, line, which)
        }

        Highlight {
            Get => this._HighlightEnabled
            Set => this._sms(0x8F5, (this._HighlightEnabled := value))
        }

        Layer {
            Get => this._sms(0xAAE)
            Set => this._sms(0xAAF, value)
        }

        Line(marker) {
            return this._sms(0x7E1, marker)
        }

        Next(line, markerMask) {
            return this._sms(0x7FF, line, markerMask)
        }

        Number(line, which) {
            return this._sms(0xAAD, line, which)
        }

        PixMap {
            Set => this._sms(0x801, this.num, (Type(value) = "Buffer") ? value.ptr : value)
        }

        Prev(line, markerMask) {
            return this._sms(0x800, line, markerMask)
        }

        StrokeWidth {
            Get => this._StrokeWidth
            Set => this._sms(0x8F9, (this._StrokeWidth := value))
        }

        Type {
            Get => this._sms(0x9E1, this.num)
            Set => this._sms(0x7F8, this.num, value)
        }

        Height {
            Get => this._height
            Set => this._sms(0xA41, this.num, (this._height := value))
        }

        Scale {
            Get => this._scale
            Set => this._sms(0xA5B, this.num, (this._scale := value))
        }

        Width {
            Get => this._width
            Set => this._sms(0xA40, this.num, (this._width := value))
        }

        RGBA {
            Set => this._sms(0xA42, this.num, (Type(value) = "Buffer") ? value.ptr : value)
        }
    }

    class Punct extends CodeEditor.scint_base {
        Chars {
            Get => this._GetStr(0xA59,,true)
            Set => this._PutStr(0xA58,,value)
        }
    }

    class Selection extends CodeEditor.scint_base {
        _BackColor := 0xFFFFFF
        _BackEnabled := true
        _ForeColor := 0x000000
        _ForeEnabled := true
        _MultiBack := 0x000000
        _MultiFore := 0x000000

        Add(anchor, caret) {
            return this._sms(0xA0D, anchor, caret)
        }

        AddEach() {
            return this._sms(0xA81)
        }

        AddNext() {
            return this._sms(0xA80)
        }

        Alpha {
            Get => this._sms(0x9AD)
            Set => this._sms(0x9AE, value)
        }

        AnchorPos(pos := "", sel := 0) {
            if (pos = "")
                return this._sms(0xA13, sel)
            else
                return this._sms(0xA12, sel, pos)
        }

        AnchorVS(pos := "", sel := 0) {
            if (pos = "")
                return this._sms(0xA17, sel)
            else
                return this._sms(0xA16, sel, pos)
        }

        Back {
            Get => ((0xFF000000 & this._BackColor) ? Format("0x{:08X}", this._BackColor) : Format("0x{:06X}", this._BackColor))
            Set => this._sms(0x814, this._BackEnabled, this._RGB_BGR(this._BackColor := value))
        }

        BackEnabled {
            Get => this._BackEnabled
            Set => this._sms(0x814, (this._BackEnabled := value), this._RGB_BGR(this._BackColor))
        }

        CaretPos(pos := "", sel := 0) {
            if (pos = "")
                return this._sms(0xA11, sel)
            else
                return this._sms(0xA10, sel, pos)
        }

        CaretVS(pos := "", sel := 0) {
            if (pos = "")
                return this._sms(0xA15, sel)
            else
                return this._sms(0xA14, sel, pos)
        }

        Clear() {
            return this._sms(0xA0B)
        }

        Count {
            Get => this._sms(0xA0A)
        }

        Drop(sel_num) {
            return this._sms(0xA6F, sel_num)
        }

        End(pos := "", sel := 0) {
            if (pos="")
                return this._sms(0xA1B, sel)
            else
                return this._sms(0xA1A, sel, pos)
        }

        EndVS(sel := 0) {
            return this._sms(0xAA7, sel)
        }

        EOLFilled {
            Get => this._sms(0x9AF)
            Set => this._sms(0x9B0, value)
        }

        Fore(bool, color) {
            this._ForeEnabled := bool
            this._ForeColor := color

            return this._sms(0x813, bool, this._RGB_BGR(color))
        }

        ForeEnabled {
            Get => this._ForeEnabled
            Set => this._sms(0x813, (this._ForeEnabled := value), this._RGB_BGR(this._ForeColor))
        }

        ForeColor {
            Get => ((0xFF000000 & this._ForeColor) ? Format("0x{:08X}", this._ForeColor) : Format("0x{:06X}", this._ForeColor))
            Set => this._sms(0x813, this._ForeEnabled, this._RGB_BGR(this._ForeColor := value))
        }

        Get(sel_num := 0) {
            local tr := CodeEditor.TextRange()

            tr.cpMin := this.ctl.Selection.Start( , sel_num)
            tr.cpMax := this.ctl.Selection.End( , sel_num)

            this._sms(0x872, 0, tr.ptr)

            return StrGet(tr.buf, "UTF-8")
        }

        GetAll() {
            local _str := ""

            if (this.IsRect And (this.RectAnchor > this.RectCaret)) {
                loop (i := this.Count)
                    _str .= (((A_Index = 1) ? "" : "`r`n") . this.Get(i - 1 - (A_Index - 1)))
            } else {
                loop this.Count
                    _str .= (((A_Index = 1) ? "" : "`r`n") . this.Get(A_Index-1))
            }

            return _str
        }

        IsEmpty {
            Get => this._sms(0xA5A)
        }

        IsExtend {
            Get => this._sms(0xA92)
        }

        IsRect {
            Get => this._sms(0x944)
        }

        Main {
            Get => this._sms(0xA0F)
            Set => this._sms(0xA0E, value)
        }

        Mode {
            Get => this._sms(0x977)
            Set => this._sms(0x976, value)
        }

        Multi {
            Get => this._sms(0xA04)
            Set => this._sms(0xA03, value)
        }

        MultiAlpha {
            Get => this._sms(0xA2B)
            Set => this._sms(0xA2A, value)
        }

        MultiBack {
            Get => ((0xFF000000 & this._MultiBack) ? Format("0x{:08X}", this._MultiBack) : Format("0x{:06X}", this._MultiBack))
            Set => this._sms(0xA29, this._RGB_BGR(this._MultiBack := value))
        }

        MultiFore {
            Get => (0xFF000000 & this._MultiFore) ? Format("0x{:08X}", this._MultiFore) : Format("0x{:06X}", this._MultiFore)
            Set => this._sms(0xA28, this._RGB_BGR(this._MultiFore := value))
        }

        MultiPaste {
            Get => this._sms(0xA37)
            Set => this._sms(0xA36, value)
        }

        MultiTyping {
            Get => this._sms(0xA06)
            Set => this._sms(0xA05, value)
        }

        RectAnchor {
            Get => this._sms(0xA1F)
            Set => this._sms(0xA1E, value)
        }

        RectAnchorVS {
            Get => this._sms(0xA23)
            Set => this._sms(0xA22, value)
        }

        RectCaret {
            Get => this._sms(0xA1D)
            Set => this._sms(0xA1C, value)
        }

        RectCaretVS {
            Get => this._sms(0xA21)
            Set => this._sms(0xA20, value)
        }

        RectModifier {
            Get => this._sms(0xA27)
            Set => this._sms(0xA26, value)
        }

        RectWithMouse {
            Get => this._sms(0xA6D)
            Set => this._sms(0xA6C, value)
        }

        Replace(text := "") {
            loop this.Count {
                this.Main := A_Index - 1
                this._PutStr(0x87A,,text)
            }
        }

        Rotate() {
            return this._sms(0xA2E)
        }

        Set(anchor, caret) {
            return this._sms(0xA0C, anchor, caret)
        }

        Start(pos := "", sel := 0) {
            if (pos = "")
                return this._sms(0xA19, sel)
            else
                return this._sms(0xA18, sel, pos)
        }

        StartVS(sel:=0) {
            return this._sms(0xAA6, sel)
        }

        SwapMainAnchorCaret() {
            return this._sms(0xA2F)
        }

        VirtualSpaceOpt {
            Get => this._sms(0xA25)
            Set => this._sms(0xA24, value)
        }
    }

    class Style extends CodeEditor.scint_base {
        ID := 32

        Back {
            Get => this._RGB_BGR(this._sms(0x9B2, this.ID))
            Set => this._sms(0x804, this.ID, this._RGB_BGR(value))
        }

        Bold {
            Get => this._sms(0x9B3, this.ID)
            Set => this._sms(0x805, this.ID, value)
        }

        Case {
            Get => this._sms(0x9B9, this.ID)
            Set => this._sms(0x80C, this.ID, value)
        }

        Changeable {
            Get => this._sms(0x9BC, this.ID)
            Set => this._sms(0x833, this.ID, value)
        }

        ClearAll() {
            return this._sms(0x802)
        }

        EOLFilled {
            Get => this._sms(0x9B7, this.ID)
            Set {
                local cs := "8859_15`r`nANSI`r`nArabic`r`nBaltic`r`nChineseBig5`r`nCyrillic`r`nDefault`r`nEastEurope`r`nGB2312`r`nGreek`r`nHangul`r`n"
                          . "Hebrew`r`nJohab`r`nMAC`r`nOEM`r`nOEM866`r`nRussian`r`nShiftJIS`r`nSymbol`r`nThai`r`nTurkish`r`nVietnamese"

                if (!CodeEditor.charset.Has(value) And !isInteger(value))
                    throw "Invalid charset detected in CodeEditor.Style.EOLFilled..."

                if (CodeEditor.charset.Has(value))
                    value := CodeEditor.charset.%value%
                else
                    value := ""

                this._sms(0x809, this.ID, value)
            }
        }

        Font {
            Get => this._GetStr(0x9B6, this.ID)
            Set => this._PutStr(0x808, this.ID, value)
        }

        Fore {
            Get => this._RGB_BGR(this._sms(0x9B1, this.ID))
            Set => this._sms(0x803, this.ID, this._RGB_BGR(value))
        }

        Hotspot {
            Get => this._sms(0x9BC, this.ID)
            Set => this._sms(0x833, this.ID, value)
        }

        Italic {
            Get => this._sms(0x9BD, this.ID)
            Set => this._sms(0x969, this.ID, value)
        }

        ResetDefault() {
            return this._sms(0x80A)
        }

        Size {
            Get => (this._sms(0x80E, this.ID) / 100)
            Set => this._sms(0x80D, this.ID, value * 100)
        }

        Underline {
            Get => this._sms(0x9B8, this.ID)
            Set => this._sms(0x80B, this.ID, value)
        }

        Visible {
            Get => this._sms(0x9BB, this.ID)
            Set => this._sms(0x81A, this.ID, value)
        }

        Weight {
            Get => this._sms(0x810)
            Set => this._sms(0x80F, value)
        }
    }

    class Styling extends CodeEditor.scint_base {
        Clear() {
            return this._sms(0x7D5)
        }

        Idle {
            Get => this._sms(0xA85)
            Set => this._sms(0xA84, value)
        }

        Last {
            Get => this._sms(0x7EC)
        }

        LineState(line, state := "") {
            if (state = "")
                return this._sms(0x82D, line)
            else
                return this._sms(0x82C, line, state)
        }

        MaxLineState {
            Get => this._sms(0x82E)
        }

        Set(length, style) {
            return this._sms(0x7F1, length, style)
        }

        SetEx(length, style_bytes_ptr) {
            return this._sms(0x819, length, style_bytes_ptr)
        }

        Start(pos) {
            return this._sms(0x7F0, pos)
        }
    }

    class Tab extends CodeEditor.scint_base {
        Add(line, pixels) {
            return this._sms(0xA74, line, pixels)
        }

        Clear(line) {
            return this._sms(0xA73, line)
        }

        HighlightGuide {
            Get => this._sms(0x857)
            Set => this._sms(0x856, value)
        }

        Indents {
            Get => this._sms(0x8D5)
            Set => this._sms(0x8D4, value)
        }

        IndentGuides {
            Get => this._sms(0x855)
            Set => this._sms(0x854, value)
        }

        IndentPosition(line) {
            return this._sms(0x850, line)
        }

        LineIndentation(line, spaces:="") {
            if (spaces="")
                return this._sms(0x84F, line)
            else
                return this._sms(0x84E, line, spaces)
        }

        MinimumWidth {
            Get => this._sms(0xAA5)
            Set => this._sms(0xAA4, value)
        }

        Next(line, pixels_pos) {
            return this._sms(0xA75, line, pixels_pos)
        }

        Unindents {
            Get => this._sms(0x8D7)
            Set => this._sms(0x8D6, value)
        }

        Use {
            Get => this._sms(0x84D)
            Set => this._sms(0x84C, value)
        }

        Indent {
            Get => this._sms(0x84B)
            Set => this._sms(0x84A, value)
        }

        Width {
            Get => this._sms(0x849)
            Set => this._sms(0x7F4, value)
        }
    }

    class Target extends CodeEditor.scint_base {
        All() {
            return this._sms(0xA82)
        }

        Anchor() {
            return this._sms(0x93E)
        }

        End {
            Get => this._sms(0x891)
            Set => this._sms(0x890, value)
        }

        EndVS {
            Get => this._sms(0xAAB)
            Set => this._sms(0xAAA, value)
        }

        Flags {
            Get => this._sms(0x897)
            Set => this._sms(0x896, value)
        }

        Next(txt, flags := "") {
            flags := ((flags != "") ? flags : this.Flags)

            return this._PutStr(0x93F, flags, txt)
        }

        Prev(txt, flags := "") {
            flags := ((flags != "") ? flags : this.Flags)

            return this._PutStr(0x940, flags, txt)
        }

        Range(start, end) {
            return this._sms(0xA7E, start, end)
        }

        Replace(txt := "") {
            return this._PutStr(0x892, StrLen(txt), txt)
        }

        Search(txt) {
            local len := StrPut(txt, "UTF-8")

            len := (((len - 1) != StrLen(txt)) ? (len - 2) : (len - 1))

            return this._SetStr(0x895, len, txt)
        }

        Selection() {
            return this._sms(0x8EF)
        }

        Start {
            Get => this._sms(0x88F)
            Set => this._sms(0x88E, value)
        }

        StartVS {
            Get => this._sms(0xAA9)
            Set => this._sms(0xAA8, value)
        }

        Tag(n) {
            return this._GetStr(0xA38, n)
        }

        Text {
            Get => this._GetStr(0xA7F)
        }
    }

    class WhiteSpace extends CodeEditor.scint_base {
        _BackColor := 0xFFFFFF
        _BackEnabled := true
        _ForeColor := 0x000000
        _ForeEnabled := true

        Back(bool, color) {
            this._BackEnabled := bool
            this._BackColor := color

            return this._sms(0x825, bool, this._RGB_BGR(color))
        }

        BackEnabled {
            Get => this._BackEnabled
            Set => this._sms(0x825, (this._BackEnabled := value), this._RGB_BGR(this._BackColor))
        }

        BackColor {
            Get => ((0xFF000000 & this._BackColor) ? Format("0x{:08X}", this._BackColor) : Format("0x{:06X}", this._BackColor))
            Set => this._sms(0x825, this._BackEnabled, this._RGB_BGR(this._BackColor := value))
        }

        Chars {
            Get => this._GetStr(0xA57,,true)
            Set => this._PutStr(0x98B,,value)
        }

        ExtraAscent {
            Get => this._sms(0x9DE)
            Set => this._sms(0x9DD, value)
        }

        ExtraDecent {
            Get => this._sms(0x9E0)
            Set => this._sms(0x9DF, value)
        }

        Fore(bool, color) {
            this._ForeEnabled := bool
            this._ForeColor := color

            return this._sms(0x824, bool, this._RGB_BGR(color))
        }

        ForeEnabled {
            Get => this._ForeEnabled
            Set => this._sms(0x824, (this._ForeEnabled := value), this._RGB_BGR(this._ForeColor))
        }

        ForeColor {
            Get => ((0xFF000000 & this._ForeColor) ? Format("0x{:08X}", this._ForeColor) : Format("0x{:06X}", this._ForeColor))
            Set => this._sms(0x824, this._ForeEnabled, this._RGB_BGR(this._ForeColor := value))
        }

        Size {
            Get => this._sms(0x827)
            Set => this._sms(0x826, value)
        }

        TabDrawMode {
            Get => this._sms(0xA8A)
            Set => this._sms(0xA8B, value)
        }

        View {
            Get => this._sms(0x7E4)
            Set => this._sms(0x7E5, value)
        }
    }

    class Word extends CodeEditor.scint_base {
        CharCatOpt {
            Get => this._sms(0xAA1)
            Set => this._sms(0xAA0, value)
        }

        Chars {
            Get => this._GetStr(0xA56, , true)
            Set => this._PutStr(0x81D, , value)
        }

        Default() {
            return this._sms(0x98C)
        }

        EndPos(start_pos, onlyWordChars := true) {
            return this._sms(0x8DB, start_pos, onlyWordChars)
        }

        IsRangeWord(start_pos, end_pos) {
            return this._sms(0xA83, start_pos, end_pos)
        }

        StartPos(start_pos, OnlyWordChars:=true) {
            return this._sms(0x8DA, start_pos, OnlyWordChars)
        }
    }

    class Wrap extends CodeEditor.scint_base {
        Count(line) {
            return this._sms(0x8BB, line)
        }

        IndentMode {
            Get => this._sms(0x9A9)
            Set => this._sms(0x9A8, value)
        }

        LayoutCache {
            Get => this._sms(0x8E1)
            Set => this._sms(0x8E0, value)
        }

        Location {
            Get => this._sms(0x99F)
            Set => this._sms(0x99E, value)
        }

        Mode {
            Get => this._sms(0x8DD)
            Set => this._sms(0x8DC, value)
        }

        PositionCache {
            Get => this._sms(0x9D3)
            Set => this._sms(0x9D2, value)
        }

        Visual {
            Get => this._sms(0x99D)
            Set => this._sms(0x99C, value)
        }
    }

    class scint_base {
        LastCode := 0

        __New(ctl) {
            this.ctl := ctl
        }

        _GetStr(msg, wParam := 0, reverse := false) {
            local buf := Buffer(this._sms(msg, wParam) + 1, 0)
            local out_str := ""
            local offset, _asc

            this._sms(msg, wParam, buf.ptr)

            if reverse
                loop (offset := buf.Size - 1)
                    if (_asc := NumGet(buf, offset - (A_Index - 1), "UChar"))
                        out_str .= Chr(_asc)

            return (reverse ? out_str : StrGet(buf, "UTF-8"))
        }

        _PutStr(msg, wParam := 0, str := "") {
            local str_size := StrPut(str, "UTF-8")
            local buf := Buffer(str_size, 0)

            StrPut(str, buf, "UTF-8")

            return this._sms(msg, wParam, buf.ptr)
        }

        _SetStr(msg, wParam := 0, str := "") {
            local buf := Buffer(StrPut(str, "UTF-8"), 0)
            local len, buf2

            StrPut(str, buf, "UTF-8")

            len := ((NumGet(buf, buf.size - 3, "UShort") = 0) ? (buf.size - 2) : (buf.size - 1))
            buf2 := Buffer(len, 0)

            DllCall("RtlMoveMemory", "UPtr", buf2.ptr, "UPtr", buf.ptr, "UPtr", len)

            buf := ""

            return this._sms(msg, wParam, buf2.ptr)
        }

        _RGB_BGR(_in) {
            if (0xFF000000 & _in)
                return Format("0x{:06X}", (_in & 0xFF) << 24 | (_in & 0xFF00) << 8 | (_in & 0xFF0000) >> 8 | (_in >> 24))
            else
                return Format("0x{:06X}", (_in & 0xFF) << 16 | (_in & 0xFF00) | (_in >> 16))
        }

        _sms(msg, wParam := 0, lParam := 0) {
            local obj := ((this.__Class = "CodeEditor") ? this : this.ctl)
            local r, status

            if obj.Hwnd {
                if obj.UseDirect {
                    r := DllCall(obj.DirectStatusFunc, "UPtr", obj.DirectPtr, "UInt", msg, "Int", wParam, "Int", lParam, "Int*", &status := 0)

                    obj._StatusD := status
                }
                else
                    r := SendMessage(msg, wParam, lParam, obj.Hwnd)
            }

            return (obj.LastCode := r)
        }

        _GetRect(_ptr, offset := 0) {
            a := []

            loop 4
                a.Push(NumGet(_ptr, offset + ((A_Index - 1) * 4), "UInt"))

            return a
        }

        _SetRect(value, _ptr, offset := 0) {
            if ((Type(value) != "Array") Or (value.Length != 4))
                throw "Inalid property type detected in CodeEditor.scint_base._SetRect..."

            loop 4
                NumPut("UInt", value[A_Index], _ptr, offset + ((A_Index - 1) * 4))
        }
    }

    class CharRange {
        __New(ptr := 0) {
            this.DefineProp("struct", {Value: !ptr ? Buffer(8, 0) : {ptr: ptr}})
            this.DefineProp("o", {Value: {cpMin: {o: 0, t: "UInt"}, cpMax: {o: 4, t: "UInt"}}})
            this.DefineProp("Ptr", {Get: (o) => this.struct.ptr})
        }

        __Get(n, p) => NumGet(this.ptr, this.o.%n%.o, this.o.%n%.t)
        __Set(n, p, v) => NumPut(this.o.%n%.t, v, this.ptr, this.o.%n%.o)
    }

    class TextRange {
        __New(ptr := 0, cpMin := 0, cpMax := 0) {
            this.DefineProp("struct", {Value: (!ptr ? Buffer((A_PtrSize = 4) ? 12 : 16, 0) : {ptr: ptr})})
            this.DefineProp("Ptr", {Get: (o) => this.struct.ptr})
            this.DefineProp("buf", {Value: ""})
            this.DefineProp("o", {Value: {cpMin: {o: 0, t: "UInt"}, cpMax: {o: 4, t: "UInt"}, lpText: {o: 8, t: "UPtr"}}})

            this.cpMin := cpMin
            this.cpMax := cpMax
            this.buf := Buffer(Abs(this.cpMax - this.cpMin) + 2, 0)
            this.lpText := this.buf.ptr
        }

        __Get(n, p) => NumGet(this.ptr, this.o.%n%.o, this.o.%n%.t)
        __Set(n, p, v) => NumPut(this.o.%n%.t, v, this.ptr, this.o.%n%.o)
    }

    class SCNotification {
        __New(ptr := 0) => (this.ptr := ptr)

        hwnd => NumGet(this.ptr, 0, "UPtr")
        id => NumGet(this.ptr, CodeEditor.scn_id, "UPtr")
        wmmsg => NumGet(this.ptr, CodeEditor.scn_wmmsg, "UInt")
        pos => NumGet(this.ptr, CodeEditor.scn_pos, "Int")
        ch => NumGet(this.ptr, CodeEditor.scn_ch, "Int")
        mod => NumGet(this.ptr, CodeEditor.scn_mod, "Int")
        modType => NumGet(this.ptr, CodeEditor.scn_modType, "Int")
        text => ((ptr := NumGet(this.ptr, CodeEditor.scn_text, "UPtr")) ? StrGet(ptr, this.length, "UTF-8") : "")
        textPtr => NumGet(this.ptr, CodeEditor.scn_text, "UPtr")
        length => NumGet(this.ptr, CodeEditor.scn_length, "Int")
        linesAdded => NumGet(this.ptr, CodeEditor.scn_linesAdded, "Int")
        message => NumGet(this.ptr, CodeEditor.scn_message, "Int")
        wParam => NumGet(this.ptr, CodeEditor.scn_wParam, "UPtr")
        lParam => NumGet(this.ptr, CodeEditor.scn_lParam, "Ptr")
        line => NumGet(this.ptr, CodeEditor.scn_line, "Int")
        foldLevelNow => NumGet(this.ptr, CodeEditor.scn_foldLevelNow, "Int")
        foldLevelPrev => NumGet(this.ptr, CodeEditor.scn_foldLevelPrev, "Int")
        margin => NumGet(this.ptr, CodeEditor.scn_margin, "Int")
        listType => NumGet(this.ptr, CodeEditor.scn_listType, "Int")
        x => NumGet(this.ptr, CodeEditor.scn_x, "Int")
        y => NumGet(this.ptr, CodeEditor.scn_y, "Int")
        token => NumGet(this.ptr, CodeEditor.scn_token, "Int")
        annotationLinesAdded => NumGet(this.ptr, CodeEditor.scn_annotationLinesAdded, "Int")
        updated => NumGet(this.ptr, CodeEditor.scn_updated, "Int")
        listCompletionMethod => NumGet(this.ptr, CodeEditor.scn_listCompletionMethod, "Int")
        characterSource => NumGet(this.ptr, CodeEditor.scn_characterSource, "Int")
    }
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

initializeCodeEditor() {
    if !DllCall("LoadLibrary", "Str", kBinariesDirectory . "Code Editor\Scintilla.dll", "UPtr")
        throw "Scintilla library not found..."

    if !DllCall("LoadLibrary", "Str", kBinariesDirectory . "Code Editor\CustomLexer.dll", "UPtr")
        throw "CustomLexer library not found..."

    Window.Prototype.AddCodeEditor := ObjBindMethod(CodeEditor, "AddCodeEditor")

    Window.DefineCustomControl("CodeEditor", ObjBindMethod(CodeEditor, "AddCodeEditor"))

    for prop in CodeEditor.scint_base.Prototype.OwnProps() ; attach utility methods to prototype
        if !(SubStr(prop,1,2) = "__") And (SubStr(prop,1,1) = "_")
            CodeEditor.Prototype.%prop% := CodeEditor.scint_base.prototype.%prop%
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeCodeEditor()