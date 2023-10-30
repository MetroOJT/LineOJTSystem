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
            Case "Save"
                context.Response.Write(Save(context))
            Case "Delete"
                context.Response.Write(Delete(context))
            Case "MessageAdd"
                context.Response.Write(MessageAdd(context))
        End Select
    End Sub

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
        Dim iCnt As Integer = 1

        Try
            sEventID = context.Request.Item("EventID")

            If sEventID <> "" Then
                sWhere.Clear()
                sWhere.Append(" WHERE EventID = @EventID")
                cDB.AddWithValue("@EventID", sEventID)

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


                sSQL.Clear()
                sSQL.Append("SELECT ")
                sSQL.Append(" Message")
                sSQL.Append(" FROM " & cCom.gctbl_MessageMst)
                sSQL.Append(sWhere.ToString)

                cDB.SelectSQL(sSQL.ToString)

                sHTML.Clear()
                Do Until Not cDB.ReadDr

                    sHTML.Append("<div class=""MessageContainer"" id=""MessageContainer" & iCnt & """>")
                    sHTML.Append("<div class=""MessagebtnArea row"">")
                    sHTML.Append("<input type=""button"" id =""MessageUpbtn" & iCnt & """value=""△"" onclick=""MessageUpbtnClick()""/>")
                    sHTML.Append("<input type=""button"" id =""MessageDownbtn" & iCnt & """value=""▽"" onclick=""MessageDownbtnClick()""/>")
                    sHTML.Append("<input type=""button"" id =""MessageDeletebtn" & iCnt & """value=""×"" onclick=""MessageDeletebtnClick()""/>")
                    sHTML.Append("</div>")
                    sHTML.Append("<div class=""row"">")
                    sHTML.Append("<div class=""col-1""></div>")
                    sHTML.Append("<textarea class=""txtMessage col-10"" id=""txtMessage" & iCnt & """ maxlength=500 onkeyup=""txtCountUpd()"">" & cDB.DRData("Message") & "</textarea>")
                    sHTML.Append("<div class=""col-1""></div>")
                    sHTML.Append("</div>")
                    sHTML.Append("<div class=""d-flex"">")
                    sHTML.Append("<input type=""button"" id =""CouponCodeAddbtn" & iCnt & """value=""クーポンコード追加"" onclick=""CouponCodeAddbtnClick()""/>")
                    sHTML.Append("<p class=""txtCount"" id=""txtCount" & iCnt & """>0/500</p>")
                    sHTML.Append("</div>")
                    sHTML.Append("</div>")
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
            cCom.CmnWriteStepLog(sHTML.ToString)
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
            sUserID = context.Request.Item("UserID")
            sEventID = context.Request.Item("Update_EventID")
            sEventName = context.Request.Item("EventName")
            sEventStatus = context.Request.Item("EventStatus")
            sScheduleFm = context.Request.Item("ScheduleFm")
            sScheduleTo = context.Request.Item("ScheduleTo")
            sKeyword = context.Request.Item("Keyword")
            lMessages = context.Request.Item("Messages[]").Split(",")

            If sEventID = "" Then
                sMode = "Ins"
            Else
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


            If sUserID = "" Then
                cDB.AddWithValue("@UserID", "99999")
            ElseIf sUserID <> "" Then
                cDB.AddWithValue("@UserID", sUserID)
            End If

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
                        sSQL.Clear()

                        sSQL.Append("Select MAX(EventID) As MaxID")
                        sSQL.Append(" FROM " & cCom.gctbl_EventMst)
                        cDB.SelectSQL(sSQL.ToString)

                        If cDB.ReadDr Then
                            MaxID = cDB.DRData("MaxID")

                        End If

                        sEventID = MaxID + 1
                        cDB.AddWithValue("@EventID", sEventID)

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
                        'cDB.AddWithValue("@EventID", sEventID)

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

                        sSQL.Clear()
                        sSQL.Append(" DELETE FROM " & cCom.gctbl_MessageMst)
                        sSQL.Append(" WHERE EventID = @EventID")
                        cDB.ExecuteSQL(sSQL.ToString)

                End Select

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
            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON

    End Function


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
            iCnt = Cki.Get_Cookies("iCnt")

            If (iCnt = "") Then
                iCnt = "0"
                Cki.Set_Cookies("iCnt", iCnt, 1)
            End If

            sHTML.Clear()
            sHTML.Append("<div class=""MessageContainer border"" id=""MessageContainer" & iCnt & """>")
            sHTML.Append("<div class=""MessagebtnArea row"">")
            sHTML.Append("<div class=""col-1""></div>")
            sHTML.Append("<div class=""col-7""></div>")
            sHTML.Append("<div class=""col-1 d-grid"">")
            'sHTML.Append("<button type=""button"" id =""MessageUpbtn" & iCnt & " onclick=""MessageUpbtnClick()""><i Class=""bi bi-caret-up-fill""></i></button>")
            sHTML.Append("<input type=""button"" id =""MessageUpbtn" & iCnt & """value=""△"" onclick=""MessageUpbtnClick()""/>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""col-1 d-grid"">")
            sHTML.Append("<input type=""button"" id =""MessageDownbtn" & iCnt & """value=""▽"" onclick=""MessageDownbtnClick()""/>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""col-1 d-grid"">")
            sHTML.Append("<input type=""button"" id =""MessageDeletebtn" & iCnt & """value=""×"" onclick=""MessageDeletebtnClick()""/>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""col-1""></div>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""row"">")
            sHTML.Append("<div class=""col-1""></div>")
            sHTML.Append("<div class=""col-10"">")
            sHTML.Append("<textarea class=""txtMessage w-100 form-control"" id=""txtMessage" & iCnt & """ maxlength=500 rows=""5"" onkeyup=""txtCountUpd()""></textarea>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""col-1""></div>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""row"">")
            sHTML.Append("<div class=""col-1""></div>")
            sHTML.Append("<div class=""col-2"">")
            sHTML.Append("<input type=""button"" id =""CouponCodeAddbtn" & iCnt & """value=""クーポンコード追加"" onclick=""CouponCodeAddbtnClick()""/>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""col-7""></div>")
            sHTML.Append("<div class=""col-1"">")
            sHTML.Append("<p class=""txtCount m-0"" id=""txtCount" & iCnt & """>0/500</p>")
            sHTML.Append("</div>")
            sHTML.Append("<div class=""col-1""></div>")
            sHTML.Append("</div>")
            sHTML.Append("</div>")

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