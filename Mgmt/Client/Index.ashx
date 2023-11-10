<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports Newtonsoft.Json
Imports System.Net
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    '公式アカウントアクセス用のトークン
    Const AccessToken As String = "p/w9bCbcf1BCehRo4gVCvfz7mG+sCLiUF3AeLm3kzrL8ugjKA0JsRYMx/WDnoqNzQhqLjbFXX9QFn/mBQr5wpC9Nrd7uDVjtBGVLDGqlIsbUh+ycI9zhl1rw/UJE6BUawPXWJZ4VMLRk/ItsQkKA3QdB04t89/1O/w1cDnyilFU="

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(Search(context))
            Case "Itiran"
                context.Response.Write(Itiran(context))
        End Select
    End Sub

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
        Dim sTempTable As String = ""
        Dim sDisplayName As String = ""
        Dim iCount As Integer = 0

        Try
            '送信データ取得
            sDisplayName = context.Request.Item("DisplayName")

            '作業用テーブルの生成
            sTempTable = cCom.CmnGet_TableName("LineUserItiran")
            cDB.DeleteTable(sTempTable)

            'メモ：連番を与えてそれを主キーにする
            sSQL.Clear()
            sSQL.Append("CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append("  wLine_UserID      VARCHAR(100) NOT NULL")
            sSQL.Append("  ,wDisplayName     VARCHAR(100) NOT NULL")
            sSQL.Append("  ,wPictureUrl      VARCHAR(10000) NOT NULL")
            sSQL.Append("  ,PRIMARY KEY (wLine_UserID) ")
            sSQL.Append("  )")
            cDB.ExecuteSQL(sSQL.ToString)

            'ラインユーザーIDをリストで取得
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" Line_UserID")
            sSQL.Append(" FROM " & cCom.gctbl_LineUserMst)
            sSQL.Append(" ORDER BY Last_Log_Datetime DESC")
            cDB.SelectSQL(sSQL.ToString)
            sValues.Clear()
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
            End If
            sSQL.Clear()
            sSQL.Append(" INSERT INTO " & sTempTable)
            sSQL.Append(" VALUES " & sValues.ToString)
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
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim hHash As New Hashtable
        Dim jJson As New JavaScriptSerializer
        Dim sJson As String
        Dim sTempTable As String = ""
        Dim sSQL As New StringBuilder
        Dim sHTML As New StringBuilder
        Try
            sTempTable = cCom.CmnGet_TableName("LineUserItiran")
            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" wLine_UserID")
            sSQL.Append(" ,wDisplayName")
            sSQL.Append(" ,wPictureUrl")
            sSQL.Append(" ,SendRecv")
            sSQL.Append(" ,Log")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" JOIN")
            sSQL.Append(" (")
            sSQL.Append(" SELECT")
            sSQL.Append(" MAX(LogID) AS MaxLogID")
            sSQL.Append(" ,Line_UserID")
            sSQL.Append(" FROM " & cCom.gctbl_LogMst)
            sSQL.Append(" GROUP BY Line_UserID")
            sSQL.Append(" ) AS A")
            sSQL.Append(" ON " & sTempTable & ".wLine_UserID = A.Line_UserID")
            sSQL.Append(" JOIN " & cCom.gctbl_LogMst)
            sSQL.Append(" ON A.MaxLogID = " & cCom.gctbl_LogMst & ".LogID")
            cDB.SelectSQL(sSQL.ToString)
            sHTML.Clear()
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
                sHTML.Append("<div class=""LineUser d-flex align-items-center""><img src=""" & cDB.DRData("wPictureUrl") & """ class=""rounded-circle""/><p>" & cDB.DRData("wDisplayName") & "<br>" & sLastMessage & "</p></div>")
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