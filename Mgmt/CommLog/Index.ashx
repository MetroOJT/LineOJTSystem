<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(sea(context))
            Case "MakeLogTable"
                context.Response.Write(mlt(context))
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

        Dim sDateFm As String = ""
        Dim sDateTo As String = ""
        Dim sSendRecv As String = ""
        Dim sCond_Status As String = ""
        Dim sOrder As String = ""

        Dim iCount As Integer = 0

        Try
            sDateFm = context.Request.Item("DateFm")
            sDateTo = context.Request.Item("DateTo")
            sSendRecv = context.Request.Item("Sere")
            sCond_Status = context.Request.Item("Status")
            sOrder = context.Request.Item("Order")

            sTempTable = cCom.CmnGet_TableName("logitiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("LogDateFm", sDateFm, 1)
            Cki.Set_Cookies("LogDateTo", sDateTo, 1)
            Cki.Set_Cookies("LogSendRecv", sSendRecv, 1)
            Cki.Set_Cookies("LogStatusNumber", sCond_Status, 1)
            Cki.Set_Cookies("LogOrder", sOrder, 1)
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
            sOb.Clear()
            cDB.ParameterClear()

            If sSendRecv <> "" Then
                sWhere.Append(" AND SendRecv LIKE @SendRecv")
                cDB.AddWithValue("@SendRecv", "%" & sSendRecv & "%")
            End If

            If sCond_Status <> "" Then
                If sCond_Status = "normal" Then
                    sWhere.Append(" AND 200 = Status")
                Else
                    sWhere.Append(" AND 200 <> Status")
                End If
            End If

            If sDateFm <> "" Then
                sWhere.Append(" AND '" & CDate(sDateFm) & "' <= Datetime")
            End If

            If sDateTo <> "" Then
                sWhere.Append(" AND '" & CDate(sDateTo) & "' >= Datetime")
            End If

            If sOrder = "time_asc" Then
                sOb.Append(" ORDER BY Datetime ASC")
            ElseIf sOrder = "time_desc" Then
                sOb.Append(" ORDER BY Datetime DESC")
            End If

            '仮テーブル作成のSQL
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
            hHash.Add("sql", sSendRecv)
            hHash.Add("count", iCount)
            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function
    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    '通信ログテーブル表示
    Public Function mlt(ByVal context As HttpContext) As String
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

        Dim sHTML As New StringBuilder 'テーブル
        Dim sPNList As New StringBuilder 'ページャリスト
        Dim iCount As Integer = 0 '検索ヒット数
        Dim NowPage As Integer = 1 '表示ページ
        Dim OffSet As Integer = 0 '表示するデータの開始地点
        Dim PageMedian As Integer 'ページャの中央値
        Dim SearchPage As Integer '表示したいページ
        Dim TotalPage As Integer '全ページ数

        Try

            sTempTable = Cki.Get_Cookies("logitiran")

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" COUNT(*) As Count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If

            TotalPage = Math.Ceiling(iCount / 10)

            SearchPage = context.Request.Item("searchpage")

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

            '検索ヒットしたデータを表示
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

                sError = ""
                If cDB.DRData("wStatusNumber") <> "200" Then
                    sError = " text-danger"
                End If

                sHTML.Append("<tr class=""" & sRow & "" & sError & """>")
                sHTML.Append("<td><input type=""button""name=""detail"" value=""詳細"" class=""btn btn-success btn-sm btnDetail"" id=""detail" & cDB.DRData("wRowNo") & """ value=""詳細"" /></td>")
                sHTML.Append("<td class=""" & sError & " text-center"">&nbsp;" & cDB.DRData("wSendRecv") & "</td>")
                sHTML.Append("<td class=""" & sError & " text-center"">" & cDB.DRData("wStatusNumber") & "</td>")
                sHTML.Append("<td align=""left"" class=""" & sError & " text-truncate"" style=""max-width:0px;"">&nbsp;" & cDB.DRData("wLog") & "</td>")
                sHTML.Append("<td class=""" & sError & " text-center"">" & cDB.DRData("wDatetime") & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")

            'ページネーション作成
            sPNList.Clear()
            sPNList.Append("<div class=""col"">")
            sPNList.Append("<ul class=""pagination"" >")
            If iCount > 10 Then '1ページのみの表示であれば1以外を表示しない


                sPNList.Append("<li class=""page-item"" id=""pista"" onclick=""MakeLogTable('pista')"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Previous"">")
                sPNList.Append("<span aria-hidden=""True"">&laquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
                sPNList.Append("<li class=""page-item"" id=""piback"" onclick=""MakeLogTable('piback')""><a class=""page-link"">‹</a></li>")
                If NowPage = 1 Then
                    sPNList.Append("<li class=""page-item pe-none"" id=""pi1"" onclick=""MakeLogTable('pi1')""><a class=""page-link bg-primary text-white"">" & PageMedian - 1 & "</a></li>")
                Else
                    sPNList.Append("<li class=""page-item"" id=""pi1"" onclick=""MakeLogTable('pi1')""><a class=""page-link"">" & PageMedian - 1 & "</a></li>")
                End If

                '表示しているページは押下できなくする
                If iCount > 10 Then 'データが11件以上であればページ2も表示
                    If NowPage <> 1 And NowPage <> TotalPage Then
                        sPNList.Append("<li class=""page-item pe-none"" id=""pi2"" onclick=""MakeLogTable('pi2')""><a class=""page-link bg-primary text-white"">" & PageMedian & "</a></li>")
                    ElseIf NowPage = 2 And iCount < 21 Then
                        sPNList.Append("<li class=""page-item pe-none"" id=""pi2"" onclick=""MakeLogTable('pi2')""><a class=""page-link bg-primary text-white"">" & PageMedian & "</a></li>")
                    Else
                        sPNList.Append("<li class=""page-item"" id=""pi2"" onclick=""MakeLogTable('pi2')""><a class=""page-link"">" & PageMedian & "</a></li>")
                    End If
                Else
                    sPNList.Append("<li class=""page-item pe-none"" id=""pi2"" onclick=""MakeLogTable('pi2')""><a class=""page-link disabled"">" & PageMedian & "</a></li>")
                End If

                If iCount > 20 Then 'データが21件以上であればページ3も表示
                    If NowPage = TotalPage Then
                        sPNList.Append("<li class=""page-item pe-none"" id=""pi3"" onclick=""MakeLogTable('pi3')""><a class=""page-link bg-primary text-white"" >" & PageMedian + 1 & "</a></li>")
                    Else
                        sPNList.Append("<li class=""page-item"" id=""pi3"" onclick=""MakeLogTable('pi3')""><a class=""page-link"" >" & PageMedian + 1 & "</a></li>")
                    End If
                Else
                    'sPNList.Append("<li class=""page-item pe-none"" id=""pi3"" onclick=""MakeLogTable('pi3')""><a class=""page-link disabled"">" & PageMedian + 1 & "</a></li>")
                End If

                sPNList.Append("<li class=""page-item"" id=""pinext"" onclick=""MakeLogTable('pinext')""><a Class=""page-link"">›</a></li>")
                sPNList.Append("<li class=""page-item"" id=""piend""  onclick=""MakeLogTable('piend')"">")
                sPNList.Append("<a class=""page-link"" aria-label=""Next"">")
                sPNList.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPNList.Append("</a>")
                sPNList.Append("</li>")
            Else
                sPNList.Append("<li class=""page-item pe-none"" id=""pi1"" onclick=""MakeLogTable('pi1')""><a class=""page-link bg-primary text-white"">" & PageMedian - 1 & "</a></li>")
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
            sPNList.Append("<input type=""text"" inputmode=""numeric"" pattern=""^[1-9][0-9]*$"" maxlength=""8"" oninput=""value = value.replace(/[^0-9]+/i,'');"" id=""PageNumber"" Class=""form-control"" aria-labelledby=""passwordHelpInline"">")
            sPNList.Append("</div>")
            sPNList.Append("<div Class=""col-auto"">")
            sPNList.Append("<input type=""button"" class=""btn btn-primary"" onclick=""MakeLogTable(document.getElementById('PageNumber').value);"" value=""検索"" />")
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
            hHash.Add("AshxNowPage", NowPage)

            Cki.Set_Cookies("LogNowPage", NowPage, 1)

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