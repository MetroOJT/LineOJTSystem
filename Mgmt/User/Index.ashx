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

    '検索
    Public Function sea(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim sWhere As New StringBuilder
        Dim sOb As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sTempTable As String = ""

        Dim sUser_ID As String = ""
        Dim sUser_Name As String = ""
        Dim sAdmin_Check As String = ""
        Dim sDateFm As String = ""
        Dim sDateTo As String = ""
        Dim sSere As String = ""
        Dim sCond_Status As String = ""
        Dim sOrder As String = ""

        Dim iCount As Integer = 0

        Try
            sUser_ID = context.Request.Item("User_ID")
            sUser_Name = context.Request.Item("User_Name")
            sAdmin_Check = context.Request.Item("Admin_Check")
            sDateFm = context.Request.Item("DateFm")
            sDateTo = context.Request.Item("DateTo")

            sTempTable = cCom.CmnGet_TableName("Useritiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("u_User_ID", sUser_ID, 1)
            Cki.Set_Cookies("User_Name", sUser_Name, 1)
            Cki.Set_Cookies("Admin_Check", sAdmin_Check, 1)
            Cki.Set_Cookies("DateFm", sDateFm, 1)
            Cki.Set_Cookies("DateTo", sDateTo, 1)
            Cki.Set_Cookies("Useritiran", sTempTable, 1)

            sSQL.Clear()
            sSQL.Append(" CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append(" wUserID         VARCHAR(20) NOT NULL")
            sSQL.Append(" ,wUserName      VARCHAR(20) NOT NULL")
            sSQL.Append(" ,wAdmin         BIT(1) NOT NULL")
            sSQL.Append(" ,wUpdate_Date   DATETIME NOT NULL")
            sSQL.Append(" ,PRIMARY KEY (wUserID)")
            sSQL.Append(" )")
            cDB.ExecuteSQL(sSQL.ToString)

            sWhere.Clear()
            sOb.Clear()
            cDB.ParameterClear()

            If sUser_ID <> "" Then
                sWhere.Append(" AND UserID = @UserID")
                cDB.AddWithValue("@UserID", sUser_ID)
            End If

            If sUser_Name <> "" Then
                sWhere.Append(" AND UserName = @UserName")
                cDB.AddWithValue("@UserName", sUser_Name)
            End If

            If sAdmin_Check <> "" Then
                sWhere.Append(" AND Admin = @Admin_Check")
                cDB.AddWithValue("@Admin_Check", sAdmin_Check)
            End If

            sSQL.Clear()
            sSQL.Append(" INSERT INTO " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append(" wUserID")
            sSQL.Append(" ,wUserName")
            sSQL.Append(" ,wAdmin")
            sSQL.Append(" ,wUpdate_Date")
            sSQL.Append(" )")
            sSQL.Append(" SELECT")
            sSQL.Append(" UserID")
            sSQL.Append(" ,UserName")
            sSQL.Append(" ,Admin")
            sSQL.Append(" ,Update_Date")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE ")

            If sDateFm <> "" Then
                sSQL.Append(" '" & CDate(sDateFm) & "' <= Update_Date AND")
            End If

            If sDateTo <> "" Then
                sSQL.Append(" '" & CDate(sDateTo) & "' >= Update_Date AND")
            End If

            sSQL.Append(" 1=1" & sWhere.ToString)
            sSQL.Append(" " & sOb.ToString)
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
    '検索結果表示
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
        Dim sError As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim sPNList As New StringBuilder
        Dim iCount As Integer = 0

        Dim Admin As String = ""
        Dim wCount As Integer = 0

        Try


            sTempTable = Cki.Get_Cookies("Useritiran")

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" COUNT(*) AS Count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)


            If cDB.ReadDr Then
                iCount = cDB.DRData("Count")
            End If

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wUserID")
            sSQL.Append(" ,wUserName")
            sSQL.Append(" ,wAdmin")
            sSQL.Append(" ,DATE_FORMAT(wUpdate_Date,'%Y/%m/%d %T') AS wUpdate_Date")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" ORDER BY wUserID")
            sSQL.Append(" LIMIT 10 OFFSET 0")
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table id=""table"" border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<th width=""20%"" class=""text-center"">ユーザーID</th >")
            sHTML.Append("<th width=""25%"" class=""text-center"">ユーザー名</th>")
            sHTML.Append("<th width=""15%"" class=""text-center"">管理者</th>")
            sHTML.Append("<th width=""40%"" class=""text-center"">登録日</th>")
            Do Until Not cDB.ReadDr
                wCount += 1
                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                If cDB.DRData("wAdmin") = 0 Then
                    Admin = "オフ"
                ElseIf cDB.DRData("wAdmin") = 1 Then
                    Admin = "オン"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td class=""text-center"" id=""UserID" & wCount & """>" & cDB.DRData("wUserID") & "</td>")
                sHTML.Append("<td class=""text-center UserName"" id=""UserName" & wCount & """ style=""color: #1a0dab; text-decoration:underline; text-decoration-color:#1a0dab;"">" & cDB.DRData("wUserName") & "</td>")
                sHTML.Append("<td class=""text-center"">" & Admin & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wUpdate_Date") & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")

            sPNList.Clear()
            sPNList.Append("<div class=""col"">")
            sPNList.Append("<ul class=""pagination"" >")
            sPNList.Append("<li class=""page-item pe-none"" id=""pista"">")
            sPNList.Append("<a class=""page-link"" href=""#"" style=""color:black; background-color:silver;"" aria-label=""Previous"">")
            sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
            sPNList.Append("</a>")
            sPNList.Append("</li>")
            sPNList.Append("<li class=""page-item pe-none"" id=""piback""><a class=""page-link"" href=""#"" style=""color:black; background-color:silver;"">‹</a></li>")
            sPNList.Append("<li class=""page-item"" id=""pi1""><a class=""page-link text-danger fw-bold"" href=""#"">1</a></li>")
            If iCount > 10 Then
                sPNList.Append("<li class=""page-item"" id=""pi2""><a class=""page-link"" href=""#"">2</a></li>")
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi2""><a class=""page-link text-dark"" href=""#"" style=""background-color: silver;"">2</a></li>")
            End If

            If iCount > 20 Then
                sPNList.Append("<li class=""page-item"" id=""pi3""><a class=""page-link"" href=""#"">3</a></li>")
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi3""><a class=""page-link text-dark"" href=""#"" style=""background-color: silver;"">3</a></li>")
            End If

            If iCount > 30 Then
                sPNList.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"" href=""#"">›</a></li>")
                sPNList.Append("<li class=""page-item"" id=""piend"">")
                sPNList.Append("<a class=""page-link"" href=""#"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pinext""><a Class=""page-link"" href=""#"" style=""color:black; background-color:silver;"">›</a></li>")
                sPNList.Append("<li class=""page-item pe-none"" id=""piend"">")
                sPNList.Append("<a class=""page-link"" href=""#"" style=""color:black; background-color:silver;"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
            End If

            sPNList.AppendLine("</ul>")
            sPNList.Append("</div>")

            sPNList.Append("<div class=""col"">")
            sPNList.Append("<div Class=""row g-3 align-items-center"">")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<Label for=""PageNumber"" class=""col-form-label"">ページ検索</label>")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""text"" inputmode=""numeric"" pattern=""^[1-9][0-9]*$"" maxlength=""8"" oninput=""value = value.replace(/[^0-9]+/i,'');"" id=""PageNumber"" Class=""form-control"" aria-labelledby=""passwordHelpInline"">")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""button"" class=""btn btn-primary"" onclick=""PageNumber_Search()"" value=""検索"" />")
            sPNList.Append("</div>")
            sPNList.Append("</div>")
            sPNList.Append("</div>")

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
    'ページネーション
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
        Dim sError As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim sPNList As New StringBuilder
        Dim iCount As Integer = 0
        Dim NowPage As Integer = 1
        Dim OffSet As Integer = 0
        Dim PageMedian As Integer
        Dim wCount As Integer = 0


        Try

            NowPage = context.Request.Item("nowpage")
            Cki.Set_Cookies("nowpage", NowPage, 1)
            OffSet = 10 * (NowPage - 1)

            PageMedian = context.Request.Item("pagemedian")
            Cki.Set_Cookies("pagemedian", PageMedian, 1)

            sTempTable = Cki.Get_Cookies("Useritiran")

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" COUNT(*) As Count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)


            If cDB.ReadDr Then
                iCount = cDB.DRData("Count")
            End If

            If NowPage > Math.Ceiling(iCount / 10) Then
                NowPage = Math.Ceiling(iCount / 10)
                OffSet = 10 * (NowPage - 1)
            ElseIf NowPage < 1 Then
                NowPage = 1
                OffSet = 0
            End If

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" wUserID")
            sSQL.Append(" ,wUserName")
            sSQL.Append(" ,wAdmin")
            sSQL.Append(" ,DATE_FORMAT(wUpdate_Date,'%Y/%m/%d %T') AS wUpdate_Date")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" ORDER BY wUserID")
            sSQL.Append(" LIMIT 10 OFFSET " & OffSet)
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table id=""table"" border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<th width=""20%"" class=""text-center"">ユーザーID</th >")
            sHTML.Append("<th width=""25%"" class=""text-center"">ユーザー名</th>")
            sHTML.Append("<th width=""15%"" class=""text-center"">管理者</th>")
            sHTML.Append("<th width=""40%"" class=""text-center"">登録日</th>")
            Do Until Not cDB.ReadDr
                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td class=""text-center"" id=""UserID" & OffSet & """>" & cDB.DRData("wUserID") & "</td>")
                sHTML.Append("<td class=""text-center UserName"" id=""UserName" & OffSet & """ style=""color: #1a0dab; text-decoration:underline; text-decoration-color:#1a0dab;"">" & cDB.DRData("wUserName") & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wAdmin") & "</td>")
                sHTML.Append("<td class=""text-center"">" & cDB.DRData("wUpdate_Date") & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
                OffSet += 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")

            sPNList.Clear()
            sPNList.Append("<div class=""col"">")
            sPNList.Append("<ul class=""pagination"" >")
            sPNList.Append("<li class=""page-item"" id=""pista"">")
            sPNList.Append("<a class=""page-link"" href=""#"" aria-label=""Previous"">")
            sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
            sPNList.Append("</a>")
            sPNList.Append("</li>")
            sPNList.Append("<li class=""page-item"" id=""piback""><a class=""page-link"" href=""#"">‹</a></li>")
            If NowPage = 1 Then
                sPNList.Append("<li class=""page-item"" id=""pi1""><a class=""page-link text-danger fw-bold"" href=""#"">" & PageMedian - 1 & "</a></li>")
            Else
                sPNList.Append("<li class=""page-item"" id=""pi1""><a class=""page-link"" href=""#"">" & PageMedian - 1 & "</a></li>")
            End If

            If iCount > 10 Then 'データが11件以上であればページ2も表示
                If NowPage <> 1 And NowPage <> Math.Ceiling(iCount / 10) Then
                    sPNList.Append("<li class=""page-item"" id=""pi2""><a class=""page-link text-danger fw-bold"" href=""#"">" & PageMedian & "</a></li>")
                ElseIf NowPage = 2 And iCount < 21 Then
                    sPNList.Append("<li class=""page-item"" id=""pi2""><a class=""page-link text-danger fw-bold"" href=""#"">" & PageMedian & "</a></li>")
                Else
                    sPNList.Append("<li class=""page-item"" id=""pi2""><a class=""page-link"" href=""#"">" & PageMedian & "</a></li>")
                End If
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi2""><a class=""page-link text-dark"" href=""#"" style=""background-color: silver;"">" & PageMedian & "</a></li>")
            End If

            If iCount > 20 Then 'データが21件以上であればページ3も表示
                If NowPage = Math.Ceiling(iCount / 10) Then
                    sPNList.Append("<li class=""page-item"" id=""pi3""><a class=""page-link text-danger fw-bold"" href=""#"" >" & PageMedian + 1 & "</a></li>")
                Else
                    sPNList.Append("<li class=""page-item"" id=""pi3""><a class=""page-link"" href=""#"" >" & PageMedian + 1 & "</a></li>")
                End If
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi3""><a class=""page-link text-dark"" href=""#"" style=""background-color: silver;"">" & PageMedian + 1 & "</a></li>")
            End If

            sPNList.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"" href=""#"">›</a></li>")
            sPNList.Append("<li class=""page-item"" id=""piend"">")
            sPNList.Append("<a class=""page-link"" href=""#"" aria-label=""Next"">")
            sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
            sPNList.Append("</a>")
            sPNList.Append("</li>")
            sPNList.AppendLine("</ul>")
            sPNList.Append("</div>")

            sPNList.Append("<div class=""col"">")
            sPNList.Append("<div Class=""row g-3 align-items-center"">")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<Label for=""PageNumber"" class=""col-form-label"">ページ検索</label>")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""text"" inputmode=""numeric"" pattern=""^[1-9][0-9]*$"" maxlength=""8"" oninput=""value = value.replace(/[^0-9]+/i,'');"" id=""PageNumber"" Class=""form-control"" aria-labelledby=""passwordHelpInline"">")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""button"" class=""btn btn-primary"" onclick=""PageNumber_Search()"" value=""検索"" />")
            sPNList.Append("</div>")
            sPNList.Append("</div>")
            sPNList.Append("</div>")

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
            hHash.Add("pm", NowPage)

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