<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(sea(context))
            Case "MakeResult"
                context.Response.Write(mr(context))
            Case "PagiNation"
                context.Response.Write(pn(context))
        End Select
    End Sub

    Public Function sea(ByVal context As HttpContext) As String
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

        Dim sSendRecv As String = "" '送信/受信
        Dim sStatusNumber As Integer = 0 'ステータス
        Dim sLog As String = ""
        Dim sDateFm As String = ""
        Dim sDateTo As String = ""
        Dim sSere As String = ""
        Dim sCond_Status As String = ""

        Dim iCount As Integer = 0

        Try
            sSendRecv = context.Request.Item("SendRecv")
            sStatusNumber = context.Request.Item("StatusNumber")
            sLog = context.Request.Item("Log")
            sDateFm = context.Request.Item("DateFm")
            sDateTo = context.Request.Item("DateTo")
            sSere = context.Request.Item("Sere")
            sCond_Status = context.Request.Item("Status")

            sTempTable = cCom.CmnGet_TableName("logitiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("SendRecv", sSendRecv, 1)
            Cki.Set_Cookies("StatusNumber", sStatusNumber, 1)
            Cki.Set_Cookies("Log", sLog, 1)
            Cki.Set_Cookies("logitiran", sTempTable, 1)

            sSQL.Clear()
            sSQL.Append(" CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append(" wRowNo        INT NOT NULL AUTO_INCREMENT")
            sSQL.Append(" ,wSendRecv      VARCHAR(4) NOT NULL")
            sSQL.Append(" ,wStatusNumber        INT NOT NULL")
            sSQL.Append(" ,wLog         VARCHAR(10000) NOT NULL")
            sSQL.Append(" ,wDatetime         DATETIME NOT NULL")
            sSQL.Append(" ,PRIMARY KEY (wRowNo)")
            sSQL.Append(" )")
            cDB.ExecuteSQL(sSQL.ToString)

            sWhere.Clear()
            cDB.ParameterClear()

            If sSendRecv <> "" Then
                sWhere.Append(" AND SendRecv LIKE @SendRecv")
                cDB.AddWithValue("@SendRecv", "%" & sSendRecv & "%")
            End If

            If sLog <> "" Then
                sWhere.Append(" AND Log <= @Log")
                cDB.AddWithValue("@Log", sLog)
            End If

            sSQL.Clear()
            sSQL.Append(" INSERT INTO " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append(" wSendRecv")
            sSQL.Append(" ,wStatusNumber")
            sSQL.Append(" ,wLog")
            sSQL.Append(" ,wDatetime")
            sSQL.Append(" )")
            sSQL.Append(" SELECT")
            sSQL.Append(" SendRecv")
            sSQL.Append(" ,Status")
            sSQL.Append(" ,Log")
            sSQL.Append(" ,Datetime")
            sSQL.Append(" FROM " & cCom.gctbl_LogMst)
            sSQL.Append(" WHERE ")
            If sDateFm <> "" Then
                sSQL.Append(" '" & CDate(sDateFm) & "' <= Datetime AND")
            End If
            If sDateTo <> "" Then
                sSQL.Append(" '" & CDate(sDateTo) & "' >= Datetime AND")
            End If
            If sSere = "send" Then
                sSQL.Append(" 'Send' = SendRecv AND")
            ElseIf sSere = "reception" Then
                sSQL.Append(" 'Recv' = SendRecv AND")
            End If
            If sCond_Status = "normal" Then
                sSQL.Append(" 200 = Status AND")
            ElseIf sCond_Status = "abnormality" Then
                sSQL.Append(" 200 != Status AND")
            End If
            sSQL.Append(" 1=1" & sWhere.ToString)
            iCount = cDB.ExecuteSQL(sSQL.ToString)

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
            hHash.Add("count", iCount)
            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function
    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Public Function mr(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim iCnt As Integer = 1
        Dim sRow As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim sPNList As New StringBuilder
        Dim iCount As Integer = 0

        Try


            sTempTable = Cki.Get_Cookies("logitiran")

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" COUNT(*) AS Count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)


            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wRowNo")
            sSQL.Append(" ,wSendRecv")
            sSQL.Append(" ,wStatusNumber")
            sSQL.Append(" ,wLog")
            sSQL.Append(" ,DATE_FORMAT(wDatetime,'%Y/%m/%d %T') AS wDatetime")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" ORDER BY wRowNo")
            sSQL.Append(" LIMIT 10 OFFSET 0")
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table id=""table"" border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<th width=""05%"" class=""text-center"">詳細</th >")
            sHTML.Append("<th width=""15%"" class=""text-center"">送信/受信</th>")
            sHTML.Append("<th width=""15%"" class=""text-center"">ステータス</th>")
            sHTML.Append("<th width=""35%"" class=""text-center"">通信ログ</th>")
            sHTML.Append("<th width=""30%"" class=""text-center"">通信時間</th>")
            Do Until Not cDB.ReadDr

                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td><input type=""button""name=""detail"" class=""btn btn-success btn-sm btnDetail"" id=""detail" & cDB.DRData("wRowNo") & """ value=""詳細"" /></td>")
                sHTML.Append("<td class=""text-center"">&nbsp;" & cDB.DRData("wSendRecv") & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wStatusNumber") & "</td>")
                sHTML.Append("<td align=""left"" class=""text-truncate"" style=""max-width:0px;"">&nbsp;" & cDB.DRData("wLog") & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wDatetime") & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")

            sPNList.Clear()
            sPNList.Append("<ul class=""pagination"" >")
            sPNList.Append("<li class=""page-item"" id=""pista"">")
            sPNList.Append("<a class=""page-link"" href=""#"" aria-label=""Previous"">")
            sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
            sPNList.Append("</a>")
            sPNList.Append("</li>")
            sPNList.Append("<li class=""page-item"" id=""piback""><a class=""page-link"" href=""#"">‹</a></li>")
            sPNList.Append("<li class=""page-item"" id=""pi1""><a class=""page-link"" href=""#"">1</a></li>")
            If iCount > 10 Then
                sPNList.Append("<li class=""page-item"" id=""pi2""><a class=""page-link"" href=""#"">2</a></li>")
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi2""><a class=""page-link text-secondary"" href=""#"">2</a></li>")
            End If

            If iCount > 20 Then
                sPNList.Append("<li class=""page-item"" id=""pi3""><a class=""page-link"" href=""#"">3</a></li>")
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi3""><a class=""page-link text-secondary"" href=""#"">3</a></li>")
            End If
            sPNList.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"" href=""#"">›</a></li>")
            sPNList.Append("<li class=""page-item"" id=""piend"">")
            sPNList.Append("<a class=""page-link"" href=""#"" aria-label=""Next"">")
            sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
            sPNList.Append("</a>")
            sPNList.Append("</li>")
            sPNList.AppendLine("</ul>")

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
    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Public Function pn(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim iCnt As Integer = 1
        Dim sRow As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim iCount As Integer = 0
        Dim NowPage As Integer = 1
        Dim OffSet As Integer = 0

        Try

            NowPage = context.Request.Item("nowpage")
            Cki.Set_Cookies("nowpage", NowPage, 1)
            OffSet = 10 * (NowPage - 1)

            sTempTable = Cki.Get_Cookies("logitiran")

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" COUNT(*) As Count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)


            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" wRowNo")
            sSQL.Append(" ,wSendRecv")
            sSQL.Append(" ,wStatusNumber")
            sSQL.Append(" ,wLog")
            sSQL.Append(" ,DATE_FORMAT(wDatetime,'%Y/%m/%d %T') AS wDatetime")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" ORDER BY wRowNo")
            sSQL.Append(" LIMIT 10 OFFSET " & OffSet)
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table id=""table"" border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<th width=""05%"" class=""text-center"">詳細</th >")
            sHTML.Append("<th width=""15%"" class=""text-center"">送信/受信</th>")
            sHTML.Append("<th width=""15%"" class=""text-center"">ステータス</th>")
            sHTML.Append("<th width=""35%"" class=""text-center"">通信ログ</th>")
            sHTML.Append("<th width=""30%"" class=""text-center"">通信時間</th>")
            Do Until Not cDB.ReadDr

                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td><input type=""button""name=""detail"" value=""詳細"" class=""btn btn-success btn-sm btnDetail"" id=""detail" & cDB.DRData("wRowNo") & """ value=""詳細"" /></td>")
                sHTML.Append("<td class=""text-center"">&nbsp;" & cDB.DRData("wSendRecv") & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wStatusNumber") & "</td>")
                sHTML.Append("<td align=""left"" class=""text-truncate"" style=""max-width:0px;"">&nbsp;" & cDB.DRData("wLog") & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wDatetime") & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")

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