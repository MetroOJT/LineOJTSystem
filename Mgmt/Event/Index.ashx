<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(Search(context))
            Case "Delete"
                context.Response.Write(Delete(context))
            Case "Itiran"
                context.Response.Write(Itiran(context))
            Case "Clear"
                context.Response.Write(Clear(context))
            Case "PagiNation"
                context.Response.Write(PagiNation(context))
        End Select
    End Sub

    Public Function Search(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim sWhere As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sTempTable As String = ""

        Dim sEvent As String = ""
        Dim sEventStatus As String = ""
        Dim sScheduleFm As String = ""
        Dim sScheduleTo As String = ""
        Dim sKeyword As String = ""

        Dim iCount As Integer = 0

        Try

            sEvent = context.Request.Item("Event")
            sEventStatus = context.Request.Item("EventStatus")
            sScheduleFm = context.Request.Item("ScheduleFm")
            sScheduleTo = context.Request.Item("ScheduleTo")
            sKeyword = context.Request.Item("Keyword")

            sTempTable = cCom.CmnGet_TableName("Itiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("Event", sEvent, 1)
            Cki.Set_Cookies("EventStatus", sEventStatus, 1)
            Cki.Set_Cookies("ScheduleFm", sScheduleFm, 1)
            Cki.Set_Cookies("ScheduleTo", sScheduleTo, 1)
            Cki.Set_Cookies("Keyword", sKeyword, 1)
            Cki.Set_Cookies("TempTable", sTempTable, 1)

            sSQL.Clear()
            sSQL.Append("CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append("  wEventID          INT NOT NULL")
            sSQL.Append("  ,wEventName       VARCHAR(50) NOT NULL")
            sSQL.Append("  ,wStatus          BIT(1) NOT NULL")
            sSQL.Append("  ,wScheduleFm      DATE NOT NULL")
            sSQL.Append("  ,wScheduleTo      DATE NOT NULL")
            sSQL.Append("  ,wKeyword         VARCHAR(30) NOT NULL")
            sSQL.Append("  ,PRIMARY KEY (wEventID) ")
            sSQL.Append("  )")
            cDB.ExecuteSQL(sSQL.ToString)

            sWhere.Clear()
            cDB.ParameterClear()

            If sEvent <> "" Then
                sWhere.Append(" AND EventName LIKE @Event")
                cDB.AddWithValue("@Event", "%" & sEvent & "%")

            End If

            If sEventStatus <> "" Then
                sWhere.Append(" AND Status = @EventStatus")
                cDB.AddWithValue("@EventStatus", sEventStatus)
            End If

            If sScheduleFm <> "" And sScheduleTo <> "" Then
                sWhere.Append(" AND ScheduleFm <= @ScheduleFm")
                sWhere.Append(" AND ScheduleTo >= @ScheduleTo")
                cDB.AddWithValue("@ScheduleFm", sScheduleFm)
                cDB.AddWithValue("@ScheduleTo", sScheduleTo)
            ElseIf sScheduleFm <> "" Then
                sWhere.Append(" AND ScheduleFm >= @ScheduleFm")
                cDB.AddWithValue("@ScheduleFm", sScheduleFm)
            ElseIf sScheduleTo <> "" Then
                sWhere.Append(" AND ScheduleTo >= @ScheduleTo")
                cDB.AddWithValue("@ScheduleTo", sScheduleTo)
            End If

            If sKeyword <> "" Then
                sWhere.Append(" AND Keyword LIKE @Keyword")
                cDB.AddWithValue("@Keyword", "%" & sKeyword & "%")
            End If

            sSQL.Clear()
            sSQL.Append(" INSERT INTO " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append("  wEventID")
            sSQL.Append(" ,wEventName")
            sSQL.Append(" ,wStatus")
            sSQL.Append(" ,wScheduleFm")
            sSQL.Append(" ,wScheduleTo")
            sSQL.Append(" ,wKeyword")
            sSQL.Append(" )")
            sSQL.Append(" SELECT")
            sSQL.Append("  EventID")
            sSQL.Append(" ,EventName")
            sSQL.Append(" ,Status")
            sSQL.Append(" ,ScheduleFm")
            sSQL.Append(" ,ScheduleTo")
            sSQL.Append(" ,Keyword")
            sSQL.Append(" FROM " & cCom.gctbl_EventMst)
            sSQL.Append(" WHERE 1=1" & sWhere.ToString)
            sSQL.Append(" ORDER BY EventID")
            iCount = cDB.ExecuteSQL(sSQL.ToString)


        Catch ex As Exception
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()
            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("status", sStatus)
            hHash.Add("count", iCount)
            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function

    Public Function Delete(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"

        Dim sDelList As String = ""
        Dim sTempTable As String = ""

        Try

            sDelList = context.Request.Item("DelList")
            sTempTable = Cki.Get_Cookies("TempTable")

            cDB.BeginTran()

            sSQL.Clear()
            sSQL.Append(" DELETE FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID IN (" & sDelList & ")")
            cDB.ExecuteSQL(sSQL.ToString)

            sSQL.Clear()
            sSQL.Append(" DELETE FROM " & cCom.gctbl_EventMst)
            sSQL.Append(" WHERE EventID IN (" & sDelList & ")")
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

    Public Function Itiran(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sRow As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim sPNList As New StringBuilder
        Dim iCount As Integer = 0

        Try

            sTempTable = Cki.Get_Cookies("TempTable")

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" COUNT(*) AS Count")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID <> 0")
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = cDB.DRData("Count")
            End If


            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wEventID")
            sSQL.Append(" ,wEventName")
            sSQL.Append(" ,wScheduleFm")
            sSQL.Append(" ,wScheduleTo")
            sSQL.Append(" ,wKeyword")
            sSQL.Append(" ,wStatus")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID <> 0")
            sSQL.Append(" ORDER BY wEventID")
            sSQL.Append(" LIMIT 10 OFFSET 0")
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<td width=""30%"" align=""center"">イベント名</td>")
            sHTML.Append("<td width=""30%"" align=""center"">スケジュール</td>")
            sHTML.Append("<td width=""30%"" align=""center"">キーワード</td>")
            sHTML.Append("<td width=""10%"" align=""center"">ステータス</td>")
            sHTML.Append("</tr>")
            Do Until Not cDB.ReadDr
                Dim iCnt As Integer = 1
                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If
                Dim Status As String = ""
                If cDB.DRData("wStatus") = 1 Then
                    Status = "オン"
                Else
                    Status = "オフ"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td align=""left""><a href=""Detail.aspx"" onclick=""EventIdToSession(" & cDB.DRData("wEventID") & ")"">" & cDB.DRData("wEventName") & "</a></td>")
                sHTML.Append("<td align=""left"">" & cDB.DRData("wScheduleFm") & "～" & cDB.DRData("wScheduleTo") & "</td>")
                sHTML.Append("<td align=""left"">&nbsp;" & cDB.DRData("wKeyword") & "</td>")
                sHTML.Append("<td align=""center"">&nbsp;" & Status & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
            Loop
            sHTML.Append("</table>")
            sHTML.Append("<form name=""EventID"" method=""POST"" action=""Detail.aspx"">" &
                         "<input type=hidden name=""EventID"" value=" & cDB.DRData("wEventID") & "/></form>")
            sPNList.Clear()
            sPNList.Append("<ul class=""pagination"" >")
            sPNList.Append("<li class=""page-item disabled"" id=""pista"">")
            sPNList.Append("<a class=""page-link"" aria-label=""Previous"">")
            sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
            sPNList.Append("</a>")
            sPNList.Append("</li>")
            sPNList.Append("<li class=""page-item disabled"" id=""piback""><a class=""page-link"">‹</a></li>")
            sPNList.Append("<li class=""page-item disabled"" id=""pi1""><a class=""page-link"">1</a></li>")
            If iCount > 10 Then
                sPNList.Append("<li class=""page-item"" id=""pi2""><a class=""page-link"">2</a></li>")
            Else
                sPNList.Append("<li class=""page-item disabled"" id=""pi2""><a class=""page-link"">2</a></li>")
            End If

            If iCount > 20 Then
                sPNList.Append("<li class=""page-item"" id=""pi3""><a class=""page-link"">3</a></li>")
            Else
                sPNList.Append("<li class=""page-item disabled"" id=""pi3""><a class=""page-link"">3</a></li>")
            End If

            If iCount < 10 Then
                sPNList.Append("<li class=""page-item disabled"" id=""pinext""><a Class=""page-link"">›</a></li>")
                sPNList.Append("<li class=""page-item disabled"" id=""piend"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.AppendLine("</ul>")
            Else
                sPNList.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"">›</a></li>")
                sPNList.Append("<li class=""page-item"" id=""piend"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.AppendLine("</ul>")
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

            hHash.Add("status", sStatus)
            hHash.Add("html", sHTML.ToString)
            hHash.Add("pnlist", sPNList.ToString)
            hHash.Add("count", iCount)

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function

    Public Function Clear(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Try
            Cki.Release_Cookies("Event")
            Cki.Release_Cookies("EventStatus")
            Cki.Release_Cookies("ScheduleFm")
            Cki.Release_Cookies("ScheduleTo")
            Cki.Release_Cookies("Keyword")
            Cki.Release_Cookies("TempTable")
        Catch ex As Exception
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

    Public Function PagiNation(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sRow As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim sPNList As New StringBuilder
        Dim iCount As Integer = 0
        Dim NowPage As Integer = 1
        Dim OffSet As Integer = 0

        Try

            NowPage = context.Request.Item("nowpage")
            Cki.Set_Cookies("nowpage", NowPage, 1)
            OffSet = 10 * (NowPage - 1)

            sTempTable = Cki.Get_Cookies("TempTable")

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" COUNT(*) As Count")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID <> 0")
            cDB.SelectSQL(sSQL.ToString)


            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wEventID")
            sSQL.Append(" ,wEventName")
            sSQL.Append(" ,wScheduleFm")
            sSQL.Append(" ,wScheduleTo")
            sSQL.Append(" ,wKeyword")
            sSQL.Append(" ,wStatus")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID <> 0")
            sSQL.Append(" ORDER BY wEventID")
            sSQL.Append(" LIMIT 10 OFFSET " & OffSet)
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<td width=""30%"" align=""center"">イベント名</td>")
            sHTML.Append("<td width=""30%"" align=""center"">スケジュール</td>")
            sHTML.Append("<td width=""30%"" align=""center"">キーワード</td>")
            sHTML.Append("<td width=""10%"" align=""center"">ステータス</td>")
            sHTML.Append("</tr>")
            Do Until Not cDB.ReadDr
                Dim iCnt As Integer = 1
                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If
                Dim Status As String = ""
                If cDB.DRData("wStatus") = 1 Then
                    Status = "オン"
                Else
                    Status = "オフ"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td align=""left""><a href=""Detail.aspx"" onclick=""EventIdToSession(" & cDB.DRData("wEventID") & ")"">" & cDB.DRData("wEventName") & "</a></td>")
                sHTML.Append("<td align=""left"">" & cDB.DRData("wScheduleFm") & "～" & cDB.DRData("wScheduleTo") & "</td>")
                sHTML.Append("<td align=""left"">&nbsp;" & cDB.DRData("wKeyword") & "</td>")
                sHTML.Append("<td align=""center"">&nbsp;" & Status & "</td>")
                sHTML.Append("</tr>")
                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")
            If NowPage <= 1 Then
                sPNList.Clear()
                sPNList.Append("<ul class=""pagination"" >")
                sPNList.Append("<li class=""page-item disabled"" id=""pista"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Previous"">")
                sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.Append("<li class=""page-item disabled"" id=""piback""><a class=""page-link"">‹</a></li>")
            Else
                sPNList.Clear()
                sPNList.Append("<ul class=""pagination"" >")
                sPNList.Append("<li class=""page-item"" id=""pista"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Previous"">")
                sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.Append("<li class=""page-item"" id=""piback""><a class=""page-link"">‹</a></li>")
            End If
            If NowPage >= 3 And iCount \ (NowPage * 10) >= 1 And iCount Mod (NowPage * 10) >= 1 Then
                For i As Integer = NowPage - 1 To NowPage + 1
                    If NowPage = i Then
                        sPNList.Append("<li class=""page-item disabled"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    Else
                        sPNList.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    End If
                Next
            Else
                For i As Integer = Math.Max(1, NowPage - 2) To Math.Max(3, NowPage)
                    If i = NowPage Then
                        sPNList.Append("<li class=""page-item disabled"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    ElseIf iCount \ (i * 10) >= 1 Then
                        sPNList.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    Else
                        sPNList.Append("<li class=""page-item disabled"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    End If
                Next
            End If
            If iCount Mod (NowPage * 10) >= 1 And iCount \ (NowPage * 10) >= 1 Then
                sPNList.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"">›</a></li>")
                sPNList.Append("<li class=""page-item"" id=""piend"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.AppendLine("</ul>")
            Else
                sPNList.Append("<li class=""page-item disabled"" id=""pinext""><a Class=""page-link"">›</a></li>")
                sPNList.Append("<li class=""page-item disabled"" id=""piend"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.AppendLine("</ul>")
            End If


        Catch ex As Exception
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()
            If sRet <> "" Then
                sStatus = sRet
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("status", sStatus)
            hHash.Add("html", sHTML.ToString)
            hHash.Add("pnlist", sPNList.ToString)
            hHash.Add("count", iCount)

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

