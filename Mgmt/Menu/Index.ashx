<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "MakeMenu"
                context.Response.Write(mm(context))
        End Select
    End Sub

    Public Function mm(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim uAdmin As Integer = 0

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder

        Try
            uAdmin = context.Request.Item("U_Admin")

            Cki.Set_Cookies("U_Admin", uAdmin, 1)

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" MenuName")
            sSQL.Append(" ,URL")
            sSQL.Append(" FROM " & cCom.gctbl_MenuMst)
            sSQL.Append(" WHERE Admin <= " & uAdmin)
            sSQL.Append(" ORDER BY MenuID")
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            Do Until Not cDB.ReadDr
                sHTML.Append("<input type=""button"" class=""btn btn-outline-secondary"" style=""margin-top: 40px;"" value=""" & cDB.DRData("MenuName") & """ onclick=""transition('../" & cDB.DRData("URL") & "')"">")
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