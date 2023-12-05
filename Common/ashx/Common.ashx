<%@ WebHandler Language="VB" Class="CommonAjax" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class CommonAjax : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "LogOut"
                context.Response.Write(LogOut(context))
        End Select
    End Sub

    Public Function LogOut(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim cCki As New Cookie
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sAttKey As String = ""
        Dim sSQL As New StringBuilder
        Dim hHash As New Hashtable
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""

        Try
            sAttKey = cCki.Get_Cookies("AttKey")
            cDB.AddWithValue("@table_schema", "lineojtdb")
            Dim DelTableArray As New List(Of String)

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" TABLE_NAME")
            sSQL.Append(" FROM")
            sSQL.Append(" information_schema.tables")
            sSQL.Append(" WHERE TABLE_SCHEMA = @table_schema")
            sSQL.Append("   AND TABLE_NAME LIKE '%" & sAttKey & "%'")
            cDB.SelectSQL(sSQL.ToString)
            Do Until Not cDB.ReadDr
                DelTableArray.Add(cDB.DRData("TABLE_NAME"))
            Loop

            sSQL.Clear()
            sSQL.Append(" DROP TABLE")
            sSQL.Append(" IF Exists")
            sSQL.Append(" " & String.Join(",", DelTableArray))
            cDB.ExecuteSQL(sSQL.ToString)

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
        Return sJson
    End Function

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class