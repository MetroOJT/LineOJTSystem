<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(Search(context))
            Case "Itiran"
                context.Response.Write(Itiran(context))
            Case "PagiNation"
                context.Response.Write(PagiNation(context))
            Case "Clear"
                context.Response.Write(Clear(context))
        End Select
    End Sub

    '検索
    Public Function Search(ByVal context As HttpContext) As String
        '変数定義,インスタンス化
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

        Dim sEventName As String = ""
        Dim sEventStatus As String = ""
        Dim sScheduleFm As String = ""
        Dim sScheduleTo As String = ""
        Dim sKeyword As String = ""

        Dim iCount As Integer = 0

        Try
            '送信データ取得
            sEventName = context.Request.Item("EventName")
            sEventStatus = context.Request.Item("EventStatus")
            sScheduleFm = context.Request.Item("ScheduleFm")
            sScheduleTo = context.Request.Item("ScheduleTo")
            sKeyword = context.Request.Item("Keyword")

            'クッキーを保存
            Cki.Set_Cookies("EventName", sEventName, 1)
            Cki.Set_Cookies("EventStatus", sEventStatus, 1)
            Cki.Set_Cookies("ScheduleFm", sScheduleFm, 1)
            Cki.Set_Cookies("ScheduleTo", sScheduleTo, 1)
            Cki.Set_Cookies("Keyword", sKeyword, 1)
            Cki.Set_Cookies("TempTable", sTempTable, 1)

            '作業用テーブルの生成
            sTempTable = cCom.CmnGet_TableName("Itiran")
            cDB.DeleteTable(sTempTable)
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

            'WHERE文の作成
            sWhere.Clear()
            cDB.ParameterClear()

            If sEventName <> "" Then
                sWhere.Append(" AND EventName LIKE BINARY @EventName")
                cDB.AddWithValue("@EventName", "%" & sEventName & "%")

            End If

            If sEventStatus <> "" Then
                sWhere.Append(" AND Status = @EventStatus")
                cDB.AddWithValue("@EventStatus", sEventStatus)
            End If

            If sScheduleFm <> "" Then
                sWhere.Append(" AND ScheduleTo >= @ScheduleFm")
                cDB.AddWithValue("@ScheduleFm", sScheduleFm)
            End If

            If sScheduleTo <> "" Then
                sWhere.Append(" AND ScheduleFm <= @ScheduleTo")
                cDB.AddWithValue("@ScheduleTo", sScheduleTo)
            End If

            If sKeyword <> "" Then
                sWhere.Append(" AND Keyword LIKE BINARY @Keyword")
                cDB.AddWithValue("@Keyword", "%" & sKeyword & "%")
            End If

            sWhere.Append(" AND EventID <> 0")

            '検索結果を作業用テーブルに挿入
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

    '一覧作成
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
        Dim sPageNationHTML As New StringBuilder
        Dim iCount As Integer = 0

        Dim iNowPage As Integer = 1

        Try
            sTempTable = cCom.CmnGet_TableName("Itiran")

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" COUNT(*) AS Count")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID <> 0")
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = cDB.DRData("Count")
            End If

            '上位十件のみSELECT
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

            '一覧のヘッダー生成
            sHTML.Clear()
            sHTML.Append("<table border=""1"" width=""1000px"" style=""border-collapse: collapse;"" class=""table table-striped table-bordered"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<th width=""30%"" align=""center"">イベント名</th>")
            sHTML.Append("<th width=""30%"" align=""center"">スケジュール</th>")
            sHTML.Append("<th width=""30%"" align=""center"">キーワード</th>")
            sHTML.Append("<th width=""10%"" align=""center"">ステータス</th>")
            sHTML.Append("</tr>")

            '一覧の要素挿入
            Do Until Not cDB.ReadDr
                Dim i As Integer = 1
                sRow = ""

                '一件ごとに色変更
                If i Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                'ステータスの表記を"ON","OFF"に
                Dim Status As String = ""
                If cDB.DRData("wStatus") = 1 Then
                    Status = "ON"
                Else
                    Status = "OFF"
                End If

                'スケジュールがDefaultやEndの場合ブランクにする
                Dim ScheduleFm As String = cDB.DRData("wScheduleFm")
                Dim ScheduleTo As String = cDB.DRData("wScheduleTo")
                If ScheduleFm = cCom.gcDate_DefaultDate Then
                    ScheduleFm = ""
                End If
                If ScheduleTo = cCom.gcDate_EndDate Then
                    ScheduleTo = ""
                End If

                '一行分生成
                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td align=""left""><a href=""Detail.aspx"" onclick=""EventIdToSession(" & cDB.DRData("wEventID") & ")"">" & cDB.DRData("wEventName") & "</a></td>")
                sHTML.Append("<td align=""left"">" & ScheduleFm & "～" & ScheduleTo & "</td>")
                sHTML.Append("<td align=""left"">&nbsp;" & cDB.DRData("wKeyword") & "</td>")
                sHTML.Append("<td align=""center"">&nbsp;" & Status & "</td>")
                sHTML.Append("</tr>")

                i = i + 1
            Loop
            sHTML.Append("</table>")

            'PageNation生成
            sPageNationHTML.Clear()
            sPageNationHTML.Append("<div class=""col"">")
            sPageNationHTML.Append("<ul class=""pagination"" >")
            If iCount > 10 Then
                sPageNationHTML.Append("<li class=""page-item disabled"" id=""pista"">")
                sPageNationHTML.Append("<a class=""page-link"" aria-label=""Previous"">")
                sPageNationHTML.Append("<span aria-hidden=""True"">&laquo;</span>")
                sPageNationHTML.Append("</a>")
                sPageNationHTML.Append("</li>")
                sPageNationHTML.Append("<li class=""page-item disabled"" id=""piback""><a class=""page-link"">‹</a></li>")
            End If
            sPageNationHTML.Append("<li class=""page-item pe-none"" id=""pi1""><a class=""page-link bg-primary text-white"">1</a></li>")

            For i As Integer = 2 To cCom.gcPageNationNumCount
                If iCount > (i - 1) * 10 Then
                    sPageNationHTML.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                End If
            Next

            '次のページが存在しない場合 ">", ">>" を押せなくする
            If iCount > 10 Then
                sPageNationHTML.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"">›</a></li>")
                sPageNationHTML.Append("<li class=""page-item"" id=""piend"">")
                sPageNationHTML.Append("<a class=""page-link"" aria-label=""Next"">")
                sPageNationHTML.Append("<span aria-hidden=""true"">&raquo;</span>")
                sPageNationHTML.Append("</a>")
                sPageNationHTML.Append("</li>")
            End If
            sPageNationHTML.Append("</ul>")
            sPageNationHTML.Append("</div>")

            'ページ検索作成
            sPageNationHTML.Append("<div class=""col"">")
            sPageNationHTML.Append("<div Class=""row g-3 align-items-center"">")
            sPageNationHTML.Append("<div Class=""col-auto"">")
            sPageNationHTML.Append("<Label for=""PageNumber"" class=""col-form-label"">ページ検索</label>")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("<div Class=""col-auto"">")
            sPageNationHTML.Append("<input type=""text"" inputmode=""numeric"" pattern=""^[1-9][0-9]*$"" maxlength=""8"" oninput=""value = (value.replace(/[^0-9]+/i,'')).replace(/^0/i,'');"" id=""PageNumber"" Class=""form-control"" aria-labelledby=""passwordHelpInline"">")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("<div Class=""col-auto"">")
            sPageNationHTML.Append("<input type=""button"" class=""btn btn-primary"" onclick=""PagiNation('pi' + document.getElementById('PageNumber').value);"" value=""検索"" />")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("</div>")

            iNowPage = Cki.Get_Cookies("EventNowPage")

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
            hHash.Add("PageNationHTML", sPageNationHTML.ToString)
            hHash.Add("NowPage", iNowPage)

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function

    'ページ遷移
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
        Dim sPageNationHTML As New StringBuilder
        Dim iCount As Integer = 0
        Dim TotalPage As Integer = 0
        Dim NowPage As Integer = 1
        Dim OffSet As Integer = 0

        Try
            NowPage = context.Request.Item("nowpage")

            sTempTable = cCom.CmnGet_TableName("Itiran")

            sSQL.Clear()
            sSQL.Append(" Select")
            sSQL.Append(" COUNT(*) As Count")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE wEventID <> 0")
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If

            TotalPage = Math.Ceiling(iCount / 10)

            '検索したいページが存在しないページであれば1/最後に変更する
            If NowPage > TotalPage Then
                NowPage = TotalPage
            ElseIf NowPage <= 0 Then
                NowPage = 1
            End If
            Cki.Set_Cookies("EventNowPage", NowPage, 1)
            OffSet = 10 * (NowPage - 1)

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
            sHTML.Append("<th width=""30%"" class=""text-center"">イベント名</th>")
            sHTML.Append("<th width=""30%"" class=""text-center"">スケジュール</th>")
            sHTML.Append("<th width=""30%"" class=""text-center"">キーワード</th>")
            sHTML.Append("<th width=""10%"" class=""text-center"">ステータス</th>")
            sHTML.Append("</tr>")
            Do Until Not cDB.ReadDr
                Dim iCnt As Integer = 1
                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If
                Dim Status As String = ""
                If cDB.DRData("wStatus") = 1 Then
                    Status = "ON"
                Else
                    Status = "OFF"
                End If

                'スケジュールがDefaultやEndの場合ブランクにする
                Dim ScheduleFm As String = cDB.DRData("wScheduleFm")
                Dim ScheduleTo As String = cDB.DRData("wScheduleTo")
                If ScheduleFm = cCom.gcDate_DefaultDate Then
                    ScheduleFm = ""
                End If
                If ScheduleTo = cCom.gcDate_EndDate Then
                    ScheduleTo = ""
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td align=""left""><a href=""Detail.aspx"" onclick=""EventIdToSession(" & cDB.DRData("wEventID") & ")"">" & cDB.DRData("wEventName") & "</a></td>")
                sHTML.Append("<td align=""left"">" & ScheduleFm & "～" & ScheduleTo & "</td>")
                sHTML.Append("<td align=""left"">&nbsp;" & cDB.DRData("wKeyword") & "</td>")
                sHTML.Append("<td align=""center"">&nbsp;" & Status & "</td>")
                sHTML.Append("</tr>")
                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")
            sPageNationHTML.Clear()
            sPageNationHTML.Append("<div class=""col"">")
            sPageNationHTML.Append("<ul class=""pagination"" >")
            If iCount > 10 Then
                If NowPage <= 1 Then
                    sPageNationHTML.Append("<li class=""page-item disabled"" id=""pista"">")
                    sPageNationHTML.Append("<a class=""page-link"" aria-label=""Previous"">")
                    sPageNationHTML.Append("<span aria-hidden=""True"">&laquo;</span>")
                    sPageNationHTML.Append("</a>")
                    sPageNationHTML.Append("</li>")
                    sPageNationHTML.Append("<li class=""page-item disabled"" id=""piback""><a class=""page-link"">‹</a></li>")
                Else
                    sPageNationHTML.Append("<li class=""page-item"" id=""pista"">")
                    sPageNationHTML.Append("<a class=""page-link"" aria-label=""Previous"">")
                    sPageNationHTML.Append("<span aria-hidden=""True"">&laquo;</span>")
                    sPageNationHTML.Append("</a>")
                    sPageNationHTML.Append("</li>")
                    sPageNationHTML.Append("<li class=""page-item"" id=""piback""><a class=""page-link"">‹</a></li>")
                End If
            End If
            '末尾のページに遷移したときのページャがおかしい:完了
            If NowPage > cCom.gcPageNationNumCount \ 2 Then
                Dim PageNationNumMax As Integer = Math.Min(NowPage + (cCom.gcPageNationNumCount \ 2), (iCount - 1) \ 10 + 1)
                For i As Integer = PageNationNumMax - cCom.gcPageNationNumCount + 1 To PageNationNumMax
                    If NowPage = i Then
                        sPageNationHTML.Append("<li class=""page-item pe-none"" id=""pi" & i & """><a class=""page-link bg-primary text-white"">" & i & "</a></li>")
                    ElseIf i = 1 Then
                        sPageNationHTML.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    ElseIf iCount \ ((i - 1) * 10) >= 1 Then
                        sPageNationHTML.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    End If
                Next
            Else
                For i As Integer = 1 To cCom.gcPageNationNumCount
                    If i = NowPage Then
                        sPageNationHTML.Append("<li class=""page-item pe-none"" id=""pi" & i & """><a class=""page-link bg-primary text-white"">" & i & "</a></li>")
                    ElseIf i = 1 Then
                        sPageNationHTML.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    ElseIf iCount > (i - 1) * 10 Then
                        sPageNationHTML.Append("<li class=""page-item"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                        'Else
                        '    sPageNationHTML.Append("<li class=""page-item disabled"" id=""pi" & i & """><a class=""page-link"">" & i & "</a></li>")
                    End If
                Next
            End If
            If iCount > 10 Then
                If (iCount - 1) \ (NowPage * 10) >= 1 Then
                    sPageNationHTML.Append("<li class=""page-item"" id=""pinext""><a Class=""page-link"">›</a></li>")
                    sPageNationHTML.Append("<li class=""page-item"" id=""piend"">")
                    sPageNationHTML.Append("<a class=""page-link"" aria-label=""Next"">")
                    sPageNationHTML.Append("<span aria-hidden=""true"">&raquo;</span>")
                    sPageNationHTML.Append("</a>")
                    sPageNationHTML.Append("</li>")
                Else
                    sPageNationHTML.Append("<li class=""page-item disabled"" id=""pinext""><a Class=""page-link"">›</a></li>")
                    sPageNationHTML.Append("<li class=""page-item disabled"" id=""piend"">")
                    sPageNationHTML.Append("<a class=""page-link"" aria-label=""Next"">")
                    sPageNationHTML.Append("<span aria-hidden=""true"">&raquo;</span>")
                    sPageNationHTML.Append("</a>")
                    sPageNationHTML.Append("</li>")
                End If
            End If
            sPageNationHTML.Append("</ul>")
            sPageNationHTML.Append("</div>")

            'ページ検索作成
            sPageNationHTML.Append("<div class=""col"">")
            sPageNationHTML.Append("<div Class=""row g-3 align-items-center"">")
            sPageNationHTML.Append("<div Class=""col-auto"">")
            sPageNationHTML.Append("<Label for=""PageNumber"" class=""col-form-label"">ページ検索</label>")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("<div Class=""col-auto"">")
            sPageNationHTML.Append("<input type=""text"" inputmode=""numeric"" pattern=""^[1-9][0-9]*$"" maxlength=""8"" oninput=""value = value.replace(/[^0-9]+/i,'');"" id=""PageNumber"" Class=""form-control"" aria-labelledby=""passwordHelpInline"">")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("<div Class=""col-auto"">")
            sPageNationHTML.Append("<input type=""button"" class=""btn btn-primary"" onclick=""PagiNation('pi' + document.getElementById('PageNumber').value);"" value=""検索"" />")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("</div>")
            sPageNationHTML.Append("</div>")

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
            hHash.Add("PageNationHTML", sPageNationHTML.ToString)
            hHash.Add("count", iCount)
            hHash.Add("NowPage", NowPage)

            sJSON = jJSON.Serialize(hHash)
        End Try

        Return sJSON

    End Function

    'クリア処理
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
            Cki.Release_Cookies("EventName")
            Cki.Release_Cookies("EventStatus")
            Cki.Release_Cookies("ScheduleFm")
            Cki.Release_Cookies("ScheduleTo")
            Cki.Release_Cookies("Keyword")
            Cki.Release_Cookies("TempTable")
            Cki.Release_Cookies("EventNowPage")
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

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class

