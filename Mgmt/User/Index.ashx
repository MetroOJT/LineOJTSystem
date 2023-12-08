<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(sea(context))
            Case "MakeUserTable"
                context.Response.Write(mut(context))
            Case "Clear"
                context.Response.Write(clear(context))
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
        Dim sFirst As String = ""

        Dim iCount As Integer = 0

        Try
            sUser_ID = context.Request.Item("User_ID")
            sUser_Name = context.Request.Item("User_Name")
            sAdmin_Check = context.Request.Item("Admin_Check")
            sDateFm = context.Request.Item("DateFm")
            sDateTo = context.Request.Item("DateTo")
            sFirst = context.Request.Item("First_Flag")

            sTempTable = cCom.CmnGet_TableName("Useritiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("u_User_ID", sUser_ID, 1)
            Cki.Set_Cookies("User_Name", sUser_Name, 1)
            Cki.Set_Cookies("User_Index_Admin_Check", sAdmin_Check, 1)
            Cki.Set_Cookies("DateFm", sDateFm, 1)
            Cki.Set_Cookies("DateTo", sDateTo, 1)
            Cki.Set_Cookies("Useritiran", sTempTable, 1)
            Cki.Set_Cookies("FirstFlag", sFirst, 1)

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
                sWhere.Append(" AND UserName LIKE @UserName")
                cDB.AddWithValue("@UserName", "%" & sUser_Name & "%")
            End If

            If sAdmin_Check <> "all" Then
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
                sSQL.Append(" '" & CDate(sDateTo).AddDays(1) & "' > Update_Date AND")
                hHash.Add("DateTo", CDate(sDateTo).AddDays(1))
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

            Cki.Set_Cookies("count", iCount, 1)
            hHash.Add("status", sStatus)
            hHash.Add("count", iCount)

            hHash.Add("SearchPage", Cki.Get_Cookies("UserNowPage"))

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function
    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    '検索結果表示
    Public Function mut(ByVal context As HttpContext) As String
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
        Dim NowPage As Integer = 1 '表示ページ
        Dim OffSet As Integer = 0 '表示するデータの開始地点
        Dim PageMedian As Integer 'ページャの中央値
        Dim SearchPage As Integer '表示したいページ
        Dim TotalPage As Integer '全ページ数

        Dim Admin As String = ""
        Dim wCount As Integer = 0
        Dim Cookie_hantei As String = ""

        Try


            sTempTable = Cki.Get_Cookies("Useritiran")

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" COUNT(*) As count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)


            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If

            TotalPage = Math.Ceiling(iCount / 10)

            SearchPage = context.Request.Item("searchpage")
            Cookie_hantei = context.Request.Item("Cookie_hantei")
            If Cookie_hantei <> "" Then
                SearchPage = Cki.Get_Cookies("UserNowPage")
            End If
            '検索したいページが存在しないページであれば1/最後に変更する
            If SearchPage <= TotalPage And SearchPage > 0 Then
                NowPage = SearchPage
            Else
                If SearchPage > TotalPage Then
                    NowPage = TotalPage
                Else
                    NowPage = 1
                End If
            End If
            OffSet = 10 * (NowPage - 1)
            If TotalPage = 0 Then
                OffSet = 0
            End If

            PageMedian = context.Request.Item("pagemedian")
            'If Cookie_hantei <> "" Then
            '    PageMedian = SearchPage
            'End If
            sSQL.Clear()
            sSQL.Append(" SELECT")
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
                wCount += 1
                sRow = ""

                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                If cDB.DRData("wAdmin") = 0 Then
                    Admin = "OFF"
                ElseIf cDB.DRData("wAdmin") = 1 Then
                    Admin = "ON"
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

            'ページネーション作成
            sPNList.Clear()
            sPNList.Append("<div class=""col"">")
            sPNList.Append("<ul class=""pagination"" >")
            If TotalPage <> 1 Then
                sPNList.Append("<li class=""page-item"" id=""pista"" onclick=""MakeUserTable('pista')"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Previous"">")
                sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.Append("<li class=""page-item"" id=""piback"" onclick=""MakeUserTable('piback')""><a class=""page-link"">‹</a></li>")
            End If
            If NowPage = 1 Then
                sPNList.Append("<li class=""page-item pe-none"" id=""pi1"" onclick=""MakeUserTable('pi1')""><a class=""page-link bg-primary text-white"">" & PageMedian - 1 & "</a></li>")
            Else
                sPNList.Append("<li class=""page-item"" id=""pi1"" onclick=""MakeUserTable('pi1')""><a class=""page-link"">" & PageMedian - 1 & "</a></li>")
            End If

            If TotalPage >= 2 Then
                '表示しているページは押下できなくする
                If iCount > 10 Then 'データが11件以上であればページ2も表示
                    If NowPage <> 1 And NowPage <> TotalPage Then
                        sPNList.Append("<li class=""page-item pe-none"" id=""pi2"" onclick=""MakeUserTable('pi2')""><a class=""page-link bg-primary text-white"">" & PageMedian & "</a></li>")
                    ElseIf NowPage = 2 And iCount < 21 Then
                        sPNList.Append("<li class=""page-item pe-none"" id=""pi2"" onclick=""MakeUserTable('pi2')""><a class=""page-link bg-primary text-white"">" & PageMedian & "</a></li>")
                    Else
                        sPNList.Append("<li class=""page-item"" id=""pi2"" onclick=""MakeUserTable('pi2')""><a class=""page-link"">" & PageMedian & "</a></li>")
                    End If
                Else
                    sPNList.Append("<li class=""page-item pe-none"" id=""pi2"" onclick=""MakeUserTable('pi2')""><a class=""page-link disabled"">" & PageMedian & "</a></li>")
                End If
            End If

            If TotalPage >= 3 Then
                If iCount > 20 Then 'データが21件以上であればページ3も表示
                    If NowPage = TotalPage Then
                        sPNList.Append("<li class=""page-item pe-none"" id=""pi3"" onclick=""MakeUserTable('pi3')""><a class=""page-link bg-primary text-white"" >" & PageMedian + 1 & "</a></li>")
                    Else
                        sPNList.Append("<li class=""page-item"" id=""pi3"" onclick=""MakeUserTable('pi3')""><a class=""page-link"" >" & PageMedian + 1 & "</a></li>")
                    End If
                Else
                    sPNList.Append("<li class=""page-item pe-none"" id=""pi3"" onclick=""MakeUserTable('pi3')""><a class=""page-link disabled"">" & PageMedian + 1 & "</a></li>")
                End If
            End If


            If TotalPage <> 1 Then
                sPNList.Append("<li class=""page-item"" id=""pinext"" onclick=""MakeUserTable('pinext')""><a Class=""page-link"">›</a></li>")
                sPNList.Append("<li class=""page-item"" id=""piend""  onclick=""MakeUserTable('piend')"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
            End If

            sPNList.AppendLine("</ul>")
            sPNList.Append("</div>")

            'ページ検索作成
            sPNList.Append("<div class=""col"">")
            sPNList.Append("<div Class=""row g-3 align-items-center"">")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<Label for=""PageNumber"" class=""col-form-label"">ページ検索</label>")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""text"" inputmode=""numeric"" pattern=""^[1-9][0-9]*$"" maxlength=""8"" oninput=""value = (value.replace(/[^0-9]+/i,'')).replace(/^0/i,'');"" id=""PageNumber"" Class=""form-control"" aria-labelledby=""passwordHelpInline"">")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""button"" class=""btn btn-primary"" onclick=""MakeUserTable(document.getElementById('PageNumber').value);"" value=""検索"" />")
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

            Cki.Set_Cookies("UserNowPage", NowPage, 1)
            Cki.Release_Cookies("First_Flag")

            hHash.Add("status", sStatus)
            hHash.Add("html", sHTML.ToString)
            hHash.Add("pnlist", sPNList.ToString)
            hHash.Add("count", iCount)
            hHash.Add("AshxNowPage", NowPage)
            hHash.Add("TotalPage", TotalPage)

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON

    End Function

    '戻る
    Public Function clear(ByVal context As HttpContext) As String
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
        Dim clear_flag As String = ""

        Try

            clear_flag = context.Request.Item("clear_flag")

            Cki.Release_Cookies("u_User_ID")
            Cki.Release_Cookies("User_Name")
            Cki.Release_Cookies("User_Index_Admin_Check")
            Cki.Release_Cookies("DateFm")
            Cki.Release_Cookies("DateTo")

            If clear_flag = "No" Then
                Cki.Release_Cookies("PNList")
                Cki.Release_Cookies("Useritiran")
                Cki.Release_Cookies("pagemedian")
                Cki.Release_Cookies("nowpage")
                Cki.Release_Cookies("count")
                Cki.Release_Cookies("UserNowPage")
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