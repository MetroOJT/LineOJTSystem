<%@ WebHandler Language="VB" Class="Detail" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports Newtonsoft.Json


Public Class Detail : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Load"
                context.Response.Write(Load(context))
            Case "FinalCheck"
                context.Response.Write(FinalCheck(context))
            Case "Save"
                context.Response.Write(Save(context))
            Case "Delete"
                context.Response.Write(Delete(context))
            Case "MessageAdd"
                context.Response.Write(MessageAdd(context))
        End Select
    End Sub

    'ページロード時に動作する関数
    Public Function Load(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sSQL As New StringBuilder
        Dim sWhere As New StringBuilder
        Dim sHTML As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sEventID As String
        Dim EventName As String = ""
        Dim EventStatus As String = ""
        Dim ScheduleFm As String = ""
        Dim ScheduleTo As String = ""
        Dim Keyword As String = ""
        Dim iCnt As Integer = 0

        Try
            sEventID = context.Request.Item("EventID")

            'セッション変数に「EventID」が存在する場合のみデータベース検索を行う
            If sEventID <> "" Then

                'EventIDをキーにデータベース検索を行う
                sWhere.Clear()
                sWhere.Append(" WHERE EventID = @EventID")
                cDB.AddWithValue("@EventID", sEventID)

                'eventmstを検索
                sSQL.Clear()
                sSQL.Append("SELECT ")
                sSQL.Append(" EventName")
                sSQL.Append(" , Status")
                sSQL.Append(" , ScheduleFm")
                sSQL.Append(" , ScheduleTo")
                sSQL.Append(" , Keyword")
                sSQL.Append(" FROM " & cCom.gctbl_EventMst)
                sSQL.Append(sWhere.ToString)

                cDB.SelectSQL(sSQL.ToString)

                If cDB.ReadDr Then
                    EventName = cDB.DRData("EventName")
                    EventStatus = cDB.DRData("Status")
                    ScheduleFm = cDB.DRData("ScheduleFm")
                    ScheduleTo = cDB.DRData("ScheduleTo")
                    Keyword = cDB.DRData("Keyword")
                End If

                'messagemstを検索
                sSQL.Clear()
                sSQL.Append("SELECT ")
                sSQL.Append(" Message")
                sSQL.Append(" FROM " & cCom.gctbl_MessageMst)
                sSQL.Append(sWhere.ToString)

                cDB.SelectSQL(sSQL.ToString)

                'HTML要素の作成
                sHTML.Clear()
                Do Until Not cDB.ReadDr
                    sHTML.Append(CreateMessageContainer(CStr(iCnt), cDB.DRData("Message")))
                    iCnt += 1
                Loop

            End If


        Catch ex As Exception
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()
            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If
            hHash.Add("EventName", EventName)
            hHash.Add("EventStatus", EventStatus)
            hHash.Add("ScheduleFm", ScheduleFm)
            hHash.Add("ScheduleTo", ScheduleTo)
            hHash.Add("Keyword", Keyword)
            hHash.Add("Html", sHTML.ToString)
            hHash.Add("status", sStatus)

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function

    Public Function FinalCheck(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sSQL As New StringBuilder
        Dim sWhere As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sMode As String = ""
        Dim sStatus As String = "OK"
        Dim sEventID As String = ""
        Dim sEventName As String = ""
        Dim sKeyword As String = ""
        Dim sEventNameErrMsg As String = ""
        Dim sKeywordErrMsg As String = ""

        Try
            '各変数を設定
            sEventID = context.Request.Item("Update_EventID")
            sEventName = HttpUtility.UrlDecode(context.Request.Item("EventName"))
            sKeyword = HttpUtility.UrlDecode(context.Request.Item("Keyword"))

            If sEventID = "" Then
                sMode = "Ins"
            Else
                '更新モードの場合のみパラメータクエリ「@EventID」を設定
                sMode = "Upd"
                cDB.AddWithValue("@EventID", sEventID)
            End If

            '同一のイベント名がデータベース内にないかチェック
            sWhere.Clear()
            sWhere.Append(" WHERE EventName = @EventName")
            If sMode = "Upd" Then
                sWhere.Append(" AND EventID <> @EventID")
            End If
            cDB.AddWithValue("@EventName", sEventName)

            sSQL.Clear()
            sSQL.Append("SELECT COUNT(*) AS SameEN")
            sSQL.Append(" FROM " & cCom.gctbl_EventMst)
            sSQL.Append(sWhere)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                If cDB.DRData("SameEN") <> 0 Then
                    sEventNameErrMsg = "このイベント名は既に登録されています。"
                End If
            End If

            '同一のキーワードがデータベース内にないかチェック
            If sKeyword.Trim() <> "" Then
                sWhere.Clear()
                sWhere.Append(" WHERE Keyword = @Keyword")
                If sMode = "Upd" Then
                    sWhere.Append(" AND EventID <> @EventID")
                End If
                cDB.AddWithValue("@Keyword", sKeyword)
                sSQL.Clear()
                sSQL.Append("SELECT COUNT(*) AS SameKW")
                sSQL.Append(" FROM " & cCom.gctbl_EventMst)
                sSQL.Append(sWhere)
                cDB.SelectSQL(sSQL.ToString)
                If cDB.ReadDr Then
                    cCom.CmnWriteStepLog(cDB.DRData("SameKW"))
                    If cDB.DRData("SameKW") <> 0 Then
                        sKeywordErrMsg = "このキーワードは既に登録されています。"
                    End If
                End If
            End If

        Catch ex As Exception
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()

            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("EventNameErrMsg", sEventNameErrMsg)
            hHash.Add("KeywordErrMsg", sKeywordErrMsg)
            hHash.Add("status", sStatus)
            sJSON = jJSON.Serialize(hHash)

        End Try

        Return sJSON
    End Function


    Public Function CreateMessageContainer(ByVal iCnt As String, Optional ByVal Data As String = "") As String
        Dim sHTML As New StringBuilder

        sHTML.Append("<div class=""MessageContainer border border-secondary border-3 mb-2"" id=""MessageContainer" & iCnt & """>")
        sHTML.Append("<div class=""MessagebtnArea row"">")
        sHTML.Append("<div class=""col-1""></div>")
        sHTML.Append("<div class=""col-7""></div>")
        sHTML.Append("<div class=""col-1 d-grid"">")
        sHTML.Append("<input type=""image"" style=""width:30px; height:30px;"" src=""../../Common/img/up_triangle.png"" id =""MessageUpbtn" & iCnt & """ class=""MessageUpbtn"" onclick=""MessageUpbtnClick(); return false;""/>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""col-1 d-grid"">")
        sHTML.Append("<input type=""image"" style=""width:30px; height:30px;""  src=""../../Common/img/down_triangle.png"" id =""MessageDownbtn" & iCnt & """ class=""MessageDownbtn"" onclick=""MessageDownbtnClick(); return false;""/>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""col-1 d-grid"">")
        sHTML.Append("<input type=""image"" style=""width:30px; height:30px;"" src=""../../Common/img/cross.png"" id =""MessageDeletebtn" & iCnt & """ class=""MessageDeletebtn"" onclick=""MessageDeletebtnClick(); return false;""/>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""col-1""></div>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""row"">")
        sHTML.Append("<div class=""col-1""></div>")
        sHTML.Append("<div class=""col-10"">")
        sHTML.Append("<textarea class=""txtMessage w-100 form-control"" id=""txtMessage" & iCnt & """ maxlength=500 rows=""5"" onkeyup=""txtCountUpd()"" required>" & Data & "</textarea>")
        sHTML.Append("<div class=""invalid-feedback""><p class=""h6"">メッセージを入力してください。</p></div>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""col-1""></div>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""row mt-2 mb-2"">")
        sHTML.Append("<div class=""col-1""></div>")
        sHTML.Append("<div class=""col-2"">")
        sHTML.Append("<input type=""button"" class=""col-sm btn btn-success CouponCodeAddbtn"" id =""CouponCodeAddbtn" & iCnt & """value=""クーポンコード追加"" onclick=""CouponCodeAddbtnClick()""/>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""col-7""></div>")
        sHTML.Append("<div class=""col-1"">")
        sHTML.Append("<p class=""txtCount m-0 text-end h5"" id=""txtCount" & iCnt & """>0/500</p>")
        sHTML.Append("</div>")
        sHTML.Append("<div class=""col-1""></div>")
        sHTML.Append("</div>")
        sHTML.Append("</div>")

        Return sHTML.ToString
    End Function

    'データの登録・更新時に動作する関数
    Public Function Save(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sSQL As New StringBuilder
        Dim sWhere As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sMode As String = ""
        Dim sUserID As String = ""
        Dim sEventID As String = ""
        Dim sEventName As String = ""
        Dim sEventStatus As String = ""
        Dim sScheduleFm As String = ""
        Dim sScheduleTo As String = ""
        Dim sKeyword As String = ""
        Dim lMessages() As String
        Dim MaxID As Integer = 0
        Dim CurrentID As Integer = 0
        Dim sErrorMessage As String = ""

        Try
            '各変数を設定
            sUserID = context.Request.Item("Update_UserID")
            sEventID = context.Request.Item("Update_EventID")
            sEventName = HttpUtility.UrlDecode(context.Request.Item("EventName"))
            sEventStatus = HttpUtility.UrlDecode(context.Request.Item("EventStatus"))
            sScheduleFm = HttpUtility.UrlDecode(context.Request.Item("ScheduleFm"))
            sScheduleTo = HttpUtility.UrlDecode(context.Request.Item("ScheduleTo"))
            sKeyword = HttpUtility.UrlDecode(context.Request.Item("Keyword"))
            lMessages = Array.ConvertAll(context.Request.Item("Messages[]").Split(","), AddressOf HttpUtility.UrlDecode)

            If sEventID = "" Then
                sMode = "Ins"
            Else
                '更新モードの場合のみパラメータクエリ「@EventID」を設定
                sMode = "Upd"
                cDB.AddWithValue("@EventID", sEventID)
            End If

            cDB.AddWithValue("@EventStatus", sEventStatus)

            If sScheduleFm = "" Then
                cDB.AddWithValue("@ScheduleFm", cCom.gcDate_DefaultDate)
            ElseIf sScheduleFm <> "" Then
                cDB.AddWithValue("@ScheduleFm", sScheduleFm)
            End If

            If sScheduleTo = "" Then
                cDB.AddWithValue("@ScheduleTo", cCom.gcDate_EndDate)
            ElseIf sScheduleTo <> "" Then
                cDB.AddWithValue("@ScheduleTo", sScheduleTo)
            End If

            cDB.AddWithValue("@UserID", sUserID)

            '同一のイベント名がデータベース内にないかチェック
            sWhere.Clear()
            sWhere.Append(" WHERE EventName = @EventName")
            If sMode = "Upd" Then
                sWhere.Append(" AND EventID <> @EventID")
            End If
            cDB.AddWithValue("@EventName", sEventName)

            sSQL.Clear()
            sSQL.Append("SELECT COUNT(*) AS SameEN")
            sSQL.Append(" FROM " & cCom.gctbl_EventMst)
            sSQL.Append(sWhere)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                If cDB.DRData("SameEN") <> 0 Then
                    sErrorMessage = "同じイベント名は登録できません。"
                End If
            End If

            '同一のキーワードがデータベース内にないかチェック
            If sErrorMessage = "" Then
                sWhere.Clear()
                sWhere.Append(" WHERE Keyword = @Keyword")
                If sMode = "Upd" Then
                    sWhere.Append(" AND EventID <> @EventID")
                End If
                cDB.AddWithValue("@Keyword", sKeyword)

                sSQL.Clear()
                sSQL.Append("SELECT COUNT(*) AS SameKW")
                sSQL.Append(" FROM " & cCom.gctbl_EventMst)
                sSQL.Append(sWhere)
                cDB.SelectSQL(sSQL.ToString)

                If cDB.ReadDr Then
                    If cDB.DRData("SameKW") <> 0 Then
                        sErrorMessage = "同じキーワードは登録できません。"
                    End If
                End If
            End If

            If sErrorMessage = "" Then
                cDB.BeginTran()

                Select Case sMode
                    Case "Ins"
                        '登録するデータのイベントIDを設定
                        sSQL.Clear()
                        sSQL.Append("Select IFNULL(MAX(EventID), 1) As MaxID")
                        sSQL.Append(" FROM " & cCom.gctbl_EventMst)
                        cDB.SelectSQL(sSQL.ToString)

                        If cDB.ReadDr Then
                            MaxID = cDB.DRData("MaxID")

                        End If

                        sEventID = MaxID + 1
                        cDB.AddWithValue("@EventID", sEventID)

                        'eventmstにINSERT文を実行
                        sSQL.Clear()
                        sSQL.Append(" INSERT INTO " & cCom.gctbl_EventMst)
                        sSQL.Append(" (")
                        sSQL.Append("  EventID")
                        sSQL.Append(" ,EventName")
                        sSQL.Append(" ,Status")
                        sSQL.Append(" ,ScheduleFm")
                        sSQL.Append(" ,ScheduleTo")
                        sSQL.Append(" ,Keyword")
                        sSQL.Append(" ,Update_Date")
                        sSQL.Append(" ,Update_UserID")
                        sSQL.Append(" )")
                        sSQL.Append(" VALUES")
                        sSQL.Append(" (")
                        sSQL.Append("  @EventID")
                        sSQL.Append(" ,@EventName")
                        sSQL.Append(" ,b" & "'" & sEventStatus & "'")
                        sSQL.Append(" ,@ScheduleFm")
                        sSQL.Append(" ,@ScheduleTo")
                        sSQL.Append(" ,@Keyword")
                        sSQL.Append(" ,NOW()")
                        sSQL.Append(" ,@UserID")
                        sSQL.Append(" )")
                        cDB.ExecuteSQL(sSQL.ToString)

                    Case "Upd"

                        'eventmstにINSERT文を実行
                        sSQL.Clear()
                        sSQL.Append(" UPDATE " & cCom.gctbl_EventMst)
                        sSQL.Append(" SET")
                        sSQL.Append("  EventName      = @EventName")
                        sSQL.Append(" ,Status         = " & "b" & "'" & sEventStatus & "'")
                        sSQL.Append(" ,ScheduleFm     = @ScheduleFm")
                        sSQL.Append(" ,ScheduleTo     = @ScheduleTo")
                        sSQL.Append(" ,Keyword        = @Keyword")
                        sSQL.Append(" ,Update_Date    = NOW()")
                        sSQL.Append(" ,Update_UserID  = @UserID")
                        sSQL.Append(" WHERE EventID   = @EventID")
                        cDB.ExecuteSQL(sSQL.ToString)

                        '更新モードの場合のみmessagemstの該当データを削除する
                        sSQL.Clear()
                        sSQL.Append(" DELETE FROM " & cCom.gctbl_MessageMst)
                        sSQL.Append(" WHERE EventID = @EventID")
                        cDB.ExecuteSQL(sSQL.ToString)

                End Select

                'messagemstにINSERT文を実行(登録、更新モード共通の処理)
                For MessageID As Integer = 1 To lMessages.Length
                    cDB.AddWithValue("@Message" & MessageID, lMessages(MessageID - 1))

                    sSQL.Clear()
                    sSQL.Append(" INSERT INTO " & cCom.gctbl_MessageMst)
                    sSQL.Append(" (")
                    sSQL.Append("  EventID")
                    sSQL.Append(" ,MessageID")
                    sSQL.Append(" ,Message")
                    sSQL.Append(" )")
                    sSQL.Append(" VALUES")
                    sSQL.Append(" (")
                    sSQL.Append("  @EventID")
                    sSQL.Append(" ," & MessageID)
                    sSQL.Append(" ,@Message" & MessageID)
                    sSQL.Append(" )")
                    cDB.ExecuteSQL(sSQL.ToString)
                Next

                cDB.CommitTran()

            End If

        Catch ex As Exception
            cDB.RollBackTran()
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()

            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("ErrorMessage", sErrorMessage)
            hHash.Add("status", sStatus)
            hHash.Add("EventID", sEventID)
            hHash.Add("Mode", sMode)
            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON

    End Function

    'データの削除時に動作する関数
    Public Function Delete(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sSQL As New StringBuilder
        Dim sWhere As New StringBuilder
        Dim Cki As New Cookie
        Dim sStatus As String = "OK"
        Dim hHash As New Hashtable
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim sRet As String = ""
        Dim sEventID As String

        Try
            sEventID = context.Request.Item("EventID")

            cDB.AddWithValue("@EventID", sEventID)

            'EventIDをキーにeventmst,messagemstにDELETE文を実行
            cDB.BeginTran()

            sSQL.Clear()
            sSQL.Append(" DELETE FROM " & cCom.gctbl_MessageMst)
            sSQL.Append(" WHERE EventID = @EventID ")
            cDB.ExecuteSQL(sSQL.ToString)

            sSQL.Clear()
            sSQL.Append(" DELETE FROM " & cCom.gctbl_EventMst)
            sSQL.Append(" WHERE EventID = @EventID ")
            cDB.ExecuteSQL(sSQL.ToString)

            cDB.CommitTran()

        Catch ex As Exception
            cDB.RollBackTran()
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()
            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("status", sStatus)
            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function

    'メッセージコンテナを追加する際に動作する関数
    Public Function MessageAdd(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim Cki As New Cookie
        Dim sStatus As String = "OK"
        Dim sHTML As New StringBuilder
        Dim hHash As New Hashtable
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim sRet As String = ""
        Dim iCnt As String = ""

        Try
            '追加するメッセージコンテナに割り振るidを取得する(cookie)
            iCnt = Cki.Get_Cookies("iCnt")

            'cookieがセットされていない場合はcookieに0をセットしidにも0を割り振る
            If (iCnt = "") Then
                iCnt = "0"
                Cki.Set_Cookies("iCnt", iCnt, 1)
            End If

            'メッセージコンテナ要素を作成
            sHTML.Clear()
            sHTML.Append(CreateMessageContainer(CStr(iCnt)))


            '現在割り振られたid + 1をcookieにセットする
            iCnt = CStr(CInt(iCnt) + 1)
            Cki.Set_Cookies("iCnt", iCnt, 1)

        Catch ex As Exception
            sRet = ex.Message
        Finally
            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("status", sStatus)
            hHash.Add("html", sHTML.ToString)

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON


    End Function

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class