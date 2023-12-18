<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports Newtonsoft.Json
Imports System.Net
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    '公式アカウントアクセス用のトークン
    Const AccessToken As String = "p/w9bCbcf1BCehRo4gVCvfz7mG+sCLiUF3AeLm3kzrL8ugjKA0JsRYMx/WDnoqNzQhqLjbFXX9QFn/mBQr5wpC9Nrd7uDVjtBGVLDGqlIsbUh+ycI9zhl1rw/UJE6BUawPXWJZ4VMLRk/ItsQkKA3QdB04t89/1O/w1cDnyilFU="

    'LINEに送るJSONオブジェクトのためのクラス
    Public Class Requestmessage
        Public Property [to] As String
        Public Property messages As New List(Of Object)
        Public Sub add_message(str As String)
            Dim message As Messages = New Messages
            message.type = "text"
            message.text = str
            messages.Add(message)
        End Sub
    End Class

    'Requestmessage.messagesに追加するJSONオブジェクトのクラス
    Public Class Messages
        Public Property type As String
        Public Property text As String
    End Class

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(Search(context))
            Case "Itiran"
                context.Response.Write(Itiran(context))
            Case "MessageBox"
                context.Response.Write(MessageBox(context))
            Case "PushMessage"
                context.Response.Write(PushMessage(context))
            Case "GetLastLog"
                context.Response.Write(GetLastLog(context))
        End Select
    End Sub

    '検索
    Public Function Search(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sStatus As String = "OK"
        Dim sRet As String = ""
        Dim hHash As New Hashtable
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim enc As Encoding = Encoding.GetEncoding("UTF-8")
        Dim sSQL As New StringBuilder
        Dim sValues As New StringBuilder

        Dim sDisplayName As String = ""
        Dim iCount As Integer = 0

        Try
            '送信データ取得
            sDisplayName = HttpUtility.UrlDecode(context.Request.Item("DisplayName"))

            '作業用テーブルの生成
            Dim sTempTable As String = cCom.CmnGet_TableName("LineUserItiran")
            cDB.DeleteTable(sTempTable)

            'メモ：連番を与えてそれを主キーにする
            sSQL.Clear()
            sSQL.Append("CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append("  SearchID          INT NOT NULL AUTO_INCREMENT")
            sSQL.Append("  ,wLine_UserID     VARCHAR(100) NOT NULL")
            sSQL.Append("  ,wDisplayName     VARCHAR(100) NOT NULL")
            sSQL.Append("  ,wPictureUrl      VARCHAR(10000) NOT NULL")
            sSQL.Append("  ,PRIMARY KEY (SearchID) ")
            sSQL.Append("  )")
            cDB.ExecuteSQL(sSQL.ToString)

            'ラインユーザーIDを最終ログの降順で取得
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" Line_UserID")
            sSQL.Append(" FROM " & cCom.gctbl_LineUserMst)
            sSQL.Append(" ORDER BY Last_LogID DESC")
            cDB.SelectSQL(sSQL.ToString)
            sValues.Clear()

            Dim SearchID As Integer = 1
            Do Until Not cDB.ReadDr
                Dim Line_UserID As String = cDB.DRData("Line_UserID")
                'ユーザ名とアイコン取得用のWebRequest
                Dim req As System.Net.WebRequest =
                    System.Net.WebRequest.Create("https://api.line.me/v2/bot/profile/" & Line_UserID)
                req.Method = "GET"
                req.Headers.Add("Authorization", "Bearer " & AccessToken)
                'サーバーからの応答を受信するためのWebResponseを取得
                Dim res As System.Net.HttpWebResponse = req.GetResponse()
                '応答データを受信するためのStreamを取得
                Dim resStream As System.IO.Stream = res.GetResponseStream()
                '受信して表示
                Dim sr As New System.IO.StreamReader(resStream, enc)
                Dim sGetData As String = sr.ReadToEnd()
                Dim jGetData As Object = JsonConvert.DeserializeObject(sGetData)
                Dim displayName As String = jGetData("displayName").ToString
                Dim pictureUrl As String = jGetData("pictureUrl").ToString
                If sDisplayName = "" OrElse displayName.Contains(sDisplayName) Then
                    sValues.Append("(" & Chr(39) & Line_UserID & Chr(39) & ", " & Chr(39) & displayName & Chr(39) & ", " & Chr(39) & pictureUrl & Chr(39) & "),")
                End If
            Loop
            If sValues.Length <> 0 Then
                sValues.Remove(sValues.Length - 1, 1)
                '検索結果を挿入
                sSQL.Clear()
                sSQL.Append(" INSERT INTO " & sTempTable)
                sSQL.Append(" (")
                sSQL.Append("  wLine_UserID")
                sSQL.Append("  ,wDisplayName")
                sSQL.Append("  ,wPictureUrl")
                sSQL.Append(" )")
                sSQL.Append(" VALUES " & sValues.ToString)
                iCount = cDB.ExecuteSQL(sSQL.ToString)
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
            hHash.Add("count", iCount)
            sJSON = jJSON.Serialize(hHash)
        End Try
        Return sJSON
    End Function

    '一覧作成
    Public Function Itiran(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim hHash As New Hashtable
        Dim jJson As New JavaScriptSerializer
        Dim sJson As String = ""
        Dim sSQL As New StringBuilder
        Dim sHTML As New StringBuilder
        'SearchIDごとにLastLogIDを保存
        Dim hLogIDList As New Hashtable
        Try
            Dim sTempTable As String = cCom.CmnGet_TableName("LineUserItiran")
            '最終ログを添付テーブルに結合
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" SearchID")
            sSQL.Append(" ,wLine_UserID")
            sSQL.Append(" ,wDisplayName")
            sSQL.Append(" ,wPictureUrl")
            sSQL.Append(" ,SendRecv")
            sSQL.Append(" ,Log")
            sSQL.Append(" ,MaxLogID")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" JOIN")
            sSQL.Append(" (")
            sSQL.Append(" SELECT")
            sSQL.Append(" MAX(LogID) AS MaxLogID")
            sSQL.Append(" ,Line_UserID")
            sSQL.Append(" FROM " & cCom.gctbl_LogMst)
            sSQL.Append(" WHERE Status = 200")
            sSQL.Append(" GROUP BY Line_UserID")
            sSQL.Append(" ) AS A")
            sSQL.Append(" ON " & sTempTable & ".wLine_UserID = A.Line_UserID")
            sSQL.Append(" JOIN " & cCom.gctbl_LogMst)
            sSQL.Append(" ON A.MaxLogID = " & cCom.gctbl_LogMst & ".LogID")
            cDB.SelectSQL(sSQL.ToString)
            sHTML.Clear()
            '最終ログから最終メッセージを取得
            Do Until Not cDB.ReadDr
                Dim sLastLog As String = cDB.DRData("Log")
                Dim sLastMessage As String = ""
                Dim jLastLog As Object = JsonConvert.DeserializeObject(sLastLog)
                If cDB.DRData("SendRecv").ToString = "Send" Then
                    Dim jLastMessages As Object
                    Dim jLastMessage As Object = Nothing
                    jLastMessages = jLastLog("messages")
                    jLastMessage = jLastMessages.Last()
                    sLastMessage = jLastMessage("text").ToString
                ElseIf cDB.DRData("SendRecv").ToString = "Recv" Then
                    Dim eventsObj As Object = jLastLog("events")(0)
                    Dim messageObj As Object = eventsObj("message")
                    sLastMessage = messageObj("text").ToString()
                End If
                '一覧のhtmlを生成
                sHTML.Append("<div id=Search" & cDB.DRData("SearchID") & " class=""LineUser d-flex align-items-center"">")
                sHTML.Append("<div class=""hidden text-success dot"">.</div>")
                sHTML.Append("<img src = """ & cDB.DRData("wPictureUrl") & """ Class=""rounded-circle""/>")
                sHTML.Append("<div Class=""d-flex flex-column"">")
                sHTML.Append("<div id = Search" & cDB.DRData("SearchID") & "_name>" & cDB.DRData("wDisplayName") & "</div>")
                '改行を半角空白に
                sHTML.Append("<div id = Search" & cDB.DRData("SearchID") & "_message Class=""text-black-50 text-break search-message"">" & sLastMessage.Replace(vbLf, " ") & "</div>")
                sHTML.Append("</div>")
                sHTML.Append("</div>")
                hLogIDList.Add(cDB.DRData("SearchID").ToString, cDB.DRData("MaxLogID").ToString)
            Loop
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
            hHash.Add("beforelogidlist", hLogIDList)

            sJson = jJSON.Serialize(hHash)
        End Try

        Return sJSON
    End Function

    'メッセージボディー作成
    Public Function MessageBox(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim hHash As New Hashtable
        Dim sHTML As New StringBuilder
        Dim jJson As New JavaScriptSerializer
        Dim sJson As String = ""
        Dim sSQL As New StringBuilder
        Dim dLogDate As Date = Nothing
        Dim sLastUserLogID As String = ""
        Dim sLastLogID As String = ""
        Dim sLastUserMessage As String = ""
        Dim sLastMessage As String = ""

        Try
            Dim sTempTable As String = cCom.CmnGet_TableName("LineUserItiran")

            '送信データ取得
            Dim SearchID As Integer = context.Request.Item("SearchID")

            '添付テーブルからデータの取得
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wLine_UserID")
            sSQL.Append(" ,wDisplayName")
            sSQL.Append(" ,wPictureUrl")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE SearchID = " & SearchID)
            cDB.SelectSQL(sSQL.ToString)
            'ヘッダーの生成
            If cDB.ReadDr Then
                sHTML.Clear()
                sHTML.Append("<div id=""MessageHeader"" Class=""d-flex align-items-center"">")
                sHTML.Append("<img id=""MessageHeaderImg"" src=""" & cDB.DRData("wPictureUrl") & """ Class=""rounded-circle""/>")
                sHTML.Append("<p id=""MessageHeaderName"">" & cDB.DRData("wDisplayName") & "</p>")
                sHTML.Append("</div>")
                cDB.AddWithValue("@Line_UserID", cDB.DRData("wLine_UserID"))
            End If

            '有効なログの読み込み
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" LogID")
            sSQL.Append(" ,SendRecv")
            sSQL.Append(" ,Log")
            sSQL.Append(" ,Datetime")
            sSQL.Append(" FROM " & cCom.gctbl_LogMst)
            sSQL.Append(" WHERE Line_UserID = @Line_UserID")
            sSQL.Append("   AND Status = 200")
            sSQL.Append(" ORDER BY LogID")
            cDB.SelectSQL(sSQL.ToString)

            'ボディーの生成
            sHTML.Append("<div id=""MessageBody"">")
            Do Until Not cDB.ReadDr
                'ログをObjectに変換
                Dim sLog As String = cDB.DRData("Log")
                Dim sMessage As New StringBuilder
                Dim jLog As Object = JsonConvert.DeserializeObject(sLog)
                Dim dLogDatetime As Date = Date.Parse(cDB.DRData("Datetime").ToString)
                '日付変更時
                If dLogDate = Nothing OrElse dLogDate.Year < dLogDatetime.Year OrElse dLogDate.Month < dLogDatetime.Month OrElse dLogDate.Day < dLogDatetime.Day Then
                    dLogDate = Date.Parse(cDB.DRData("Datetime").ToString)
                    sHTML.Append("<div class=""text-center"">" & dLogDate.ToString("yyyy/MM/dd") & "</div>")
                End If
                '右側緑メッセージ
                If cDB.DRData("SendRecv").ToString = "Send" Then
                    Dim jMessages As Object
                    Dim jMessage As Object = Nothing
                    jMessages = jLog("messages")
                    jMessage = jMessages.Last()
                    sMessage.Clear()
                    sMessage.Append(jMessage("text").ToString)
                    sLastMessage = sMessage.ToString
                    sLastLogID = cDB.DRData("LogID")
                    sHTML.Append("<div class=""row"">")
                    sHTML.Append("<div class=""col-6""></div>")
                    sHTML.Append("<div class=""col-6 text-end"">")
                    sHTML.Append("<div class=""border MessageTextArea"" style=""background:rgba(76,199,100,0.5);"">")
                    '改行終わりの場合、有効にするために半角スペース挿入
                    If sMessage.ToString.Substring(sMessage.Length - 1) = vbLf Then
                        sMessage.Append("&thinsp;")
                    End If
                    sHTML.Append("<span class=""MessageText text-start text-break"">" & sMessage.ToString & "</span>")
                    sHTML.Append("</div>")
                    sHTML.Append("</div>")
                    sHTML.Append("</div>")
                    sHTML.Append("<div class=""row"">")
                    sHTML.Append("<div class=""col-6""></div>")
                    sHTML.Append("<div class=""col-6 text-end"">" & dLogDatetime.ToString("hh:mm") & "</div>")
                    sHTML.Append("</div>")
                ElseIf cDB.DRData("SendRecv").ToString = "Recv" Then
                    '左側白メッセージ
                    Dim eventsObj As Object = jLog("events")(0)
                    Dim messageObj As Object = eventsObj("message")
                    sMessage.Clear()
                    sMessage.Append(messageObj("text").ToString)
                    sLastUserLogID = cDB.DRData("LogID").ToString
                    sLastLogID = sLastUserLogID
                    sLastUserMessage = sMessage.ToString
                    sLastMessage = sLastUserMessage
                    sHTML.Append("<div class=""row"">")
                    sHTML.Append("<div class=""col-6 text-start"">")
                    sHTML.Append("<div class=""border MessageTextArea"">")
                    '改行終わりの場合、有効にするために半角スペース挿入
                    If sMessage.ToString.Substring(sMessage.Length - 1) = vbLf Then
                        sMessage.Append("&thinsp;")
                    End If
                    sHTML.Append("<span class=""MessageText UserMessage text-break"">" & sMessage.ToString & "</span>")
                    sHTML.Append("</div>")
                    sHTML.Append("</div>")
                    sHTML.Append("<div class=""col-6""></div>")
                    sHTML.Append("</div>")
                    sHTML.Append("<div class=""row"">")
                    sHTML.Append("<div class=""col-6 text-start"">" & dLogDatetime.ToString("hh:mm") & "</div>")
                    sHTML.Append("<div class=""col-6""></div>")
                    sHTML.Append("</div>")
                End If
            Loop
            'フッター用のdiv用意
            sHTML.Append("<div id=""MessageFooter"" class=""row text-break""></div>")
            sHTML.Append("</div>")
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
            hHash.Add("lastuserlogid", sLastUserLogID)
            hHash.Add("lastlogid", sLastLogID)
            hHash.Add("lastusermessage", sLastUserMessage)
            hHash.Add("lastmessage", sLastMessage)

            sJson = jJson.Serialize(hHash)
        End Try

        Return sJson
    End Function

    'ログ更新チェック
    Public Function GetLastLog(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim hHash As New Hashtable
        Dim jJson As New JavaScriptSerializer
        Dim sJson As String = ""
        Dim sSQL As New StringBuilder
        Dim sLastLogID As String = ""
        Dim sLastMessage As String = ""
        Try
            '送信データ取得
            Dim SearchID As String = context.Request.Item("SearchID")

            Dim sTempTable As String = cCom.CmnGet_TableName("LineUserItiran")

            '添付テーブルからデータ取得
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wLine_UserID")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE SearchID = " & SearchID)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                'ユーザーの最終ログを取得
                cDB.AddWithValue("@Line_UserID", cDB.DRData("wLine_UserID"))
                sSQL.Clear()
                sSQL.Append(" SELECT " & cCom.gctbl_LineUserMst & ".Line_UserID, MAX(LogID) AS Last_LogID")
                sSQL.Append(" FROM " & cCom.gctbl_LineUserMst)
                sSQL.Append(" JOIN " & cCom.gctbl_LogMst)
                sSQL.Append(" ON " & cCom.gctbl_LineUserMst & ".Line_UserID = " & cCom.gctbl_LogMst & ".Line_UserID")
                sSQL.Append(" WHERE " & cCom.gctbl_LineUserMst & ".Line_UserID = @Line_UserID")
                sSQL.Append("   AND Status = 200")
                sSQL.Append(" GROUP BY Line_UserID")
                cDB.SelectSQL(sSQL.ToString)
                If cDB.ReadDr Then
                    'LineUserMstのLast_LogIDを更新
                    sLastLogID = cDB.DRData("Last_LogID").ToString
                    cDB.AddWithValue("@Last_LogID", sLastLogID)
                    sSQL.Clear()
                    sSQL.Append(" UPDATE " & cCom.gctbl_LineUserMst)
                    sSQL.Append(" SET Last_LogID = @Last_LogID")
                    sSQL.Append(" WHERE Line_UserID = @Line_UserID")
                    cDB.ExecuteSQL(sSQL.ToString)
                End If

                '最終ログの内容を取得
                sSQL.Clear()
                sSQL.Append(" SELECT")
                sSQL.Append(" Log")
                sSQL.Append(" ,SendRecv")
                sSQL.Append(" FROM " & cCom.gctbl_LogMst)
                sSQL.Append(" WHERE LogID = @Last_LogID")
                cDB.SelectSQL(sSQL.ToString)
                'メッセージ文を取得
                If cDB.ReadDr Then
                    Dim sLastLog As String = cDB.DRData("Log")
                    Dim jLastLog As Object = JsonConvert.DeserializeObject(sLastLog)
                    If cDB.DRData("SendRecv").ToString = "Send" Then
                        Dim jLastMessages As Object
                        Dim jLastMessage As Object = Nothing
                        jLastMessages = jLastLog("messages")
                        jLastMessage = jLastMessages.Last()
                        sLastMessage = jLastMessage("text").ToString
                    ElseIf cDB.DRData("SendRecv").ToString = "Recv" Then
                        Dim eventsObj As Object = jLastLog("events")(0)
                        Dim messageObj As Object = eventsObj("message")
                        sLastMessage = messageObj("text").ToString
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

            hHash.Add("status", sStatus)
            hHash.Add("lastlogid", sLastLogID)
            hHash.Add("lastmessage", sLastMessage)

            sJson = jJson.Serialize(hHash)
        End Try

        Return sJson
    End Function

    'プッシュメッセージ
    Public Function PushMessage(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim hHash As New Hashtable
        Dim jJson As New JavaScriptSerializer
        Dim sJson As String = ""
        Dim sSQL As New StringBuilder
        Dim enc As Encoding = Encoding.GetEncoding("UTF-8")
        Dim sLastLogID As String = ""
        Try
            'Requestmessageのインスタンス化
            Dim requestmessage As Requestmessage = New Requestmessage

            Dim sTempTable As String = cCom.CmnGet_TableName("LineUserItiran")

            '送信データ取得
            Dim message As String = HttpUtility.UrlDecode(context.Request.Item("message"))
            Dim nowSearchID As Integer = context.Request.Item("nowSearchID")

            cDB.AddWithValue("@SearchID", nowSearchID)

            cDB.BeginTran()

            '添付テーブルからデータ取得
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wLine_UserID")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" WHERE SearchID = @SearchID")
            cDB.SelectSQL(sSQL.ToString)
            If cDB.ReadDr Then
                Dim Line_UserID As String = cDB.DRData("wLine_UserID")
                requestmessage.to = Line_UserID
                requestmessage.add_message(message)

                '仮送信ログを登録
                cDB.AddWithValue("@Send", "Send")
                cDB.AddWithValue("@Line_UserID", Line_UserID)
                sSQL.Clear()
                sSQL.Append(" INSERT INTO " & cCom.gctbl_LogMst)
                sSQL.Append(" (SendRecv, Line_UserID, Status, Log, Datetime)")
                sSQL.Append(" VALUES(@Send, @Line_UserID, 999, 'Log', NOW())")
                cDB.ExecuteSQL(sSQL.ToString)

                'PushMessageのWebRequest
                Dim req As System.Net.WebRequest =
                    System.Net.WebRequest.Create("https://api.line.me/v2/bot/message/push")
                'POST送信するデータを作成
                Dim postData As String = JsonConvert.SerializeObject(requestmessage)
                req.Method = "POST"
                req.ContentType = "application/json"
                req.Headers.Add("Authorization", "Bearer " & AccessToken)

                Using reqStream As New System.IO.StreamWriter(req.GetRequestStream())
                    'POST送信
                    reqStream.Write(postData)
                End Using
                'サーバーからの応答を受信するためのWebResponseを取得
                Dim res As System.Net.HttpWebResponse = req.GetResponse()
                '応答データを受信するためのStreamを取得
                Dim resStream As System.IO.Stream = res.GetResponseStream()
                '受信して表示
                Dim sr As New System.IO.StreamReader(resStream, enc)
                Dim statuscode As Integer = res.StatusCode
                cDB.AddWithValue("@SendLog", postData)
                cDB.AddWithValue("@Status", statuscode)

                '送信ログを更新
                sSQL.Clear()
                sSQL.Append(" UPDATE " & cCom.gctbl_LogMst)
                sSQL.Append(" SET Status = @Status, Log = @SendLog")
                sSQL.Append(" WHERE Status = 999")
                sSQL.Append(" ORDER BY LogID DESC LIMIT 1")
                cDB.ExecuteSQL(sSQL.ToString)

                '最後のログIDを取得
                sSQL.Clear()
                sSQL.Append(" SELECT")
                sSQL.Append(" MAX(LogID) AS Last_LogID")
                sSQL.Append(" FROM " & cCom.gctbl_LogMst)
                sSQL.Append(" WHERE Line_UserID = @Line_UserID")
                sSQL.Append(" WHERE Status = 200")
                cDB.SelectSQL(sSQL.ToString)
                If cDB.ReadDr Then
                    sLastLogID = cDB.DRData("Last_LogID").ToString
                    cDB.AddWithValue("@Last_LogID", cDB.DRData("Last_LogID"))
                End If

                'Line_UserIDが登録済みか確認
                sSQL.Clear()
                sSQL.Append(" SELECT")
                sSQL.Append(" *")
                sSQL.Append(" FROM " & cCom.gctbl_LineUserMst)
                sSQL.Append(" WHERE Line_UserID = @Line_UserID")
                cDB.SelectSQL(sSQL.ToString)

                '未登録の場合挿入
                If Not cDB.IsSelectExistRecord() Then
                    sSQL.Clear()
                    sSQL.Append(" INSERT INTO " & cCom.gctbl_LineUserMst)
                    sSQL.Append(" VALUES (@Line_UserID, NOW(), @Last_LogID)")
                    cDB.ExecuteSQL(sSQL.ToString)
                Else
                    '登録済みの場合更新
                    sSQL.Clear()
                    sSQL.Append(" UPDATE " & cCom.gctbl_LineUserMst)
                    sSQL.Append(" SET Last_LogID = @Last_LogID")
                    sSQL.Append(" WHERE Line_UserID = @Line_UserID")
                    cDB.ExecuteSQL(sSQL.ToString)
                End If

            End If
            cDB.CommitTran()

        Catch ex As Exception
            sRet = ex.Message
            cDB.RollBackTran()
        Finally
            cDB.DrClose()
            cDB.Dispose()
            If sRet <> "" Then
                sStatus = "NG"
                cCom.CmnWriteStepLog(sRet)
            End If

            hHash.Add("status", sStatus)
            hHash.Add("lastlogid", sLastLogID)

            sJson = jJson.Serialize(hHash)
        End Try

        Return sJson
    End Function

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class