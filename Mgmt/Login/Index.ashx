<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(Search(context))
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

        Dim rUserID As New StringBuilder
        Dim rUserName As New StringBuilder
        Dim rAdmin As New StringBuilder

        Dim sUser_ID As String = ""
        Dim sPassword As String = ""

        Dim iCount As Integer = 0

        Try
            sUser_ID = context.Request.Item("User_ID")
            sPassword = context.Request.Item("Password")

            Cki.Set_Cookies("User_ID", sUser_ID, 1)
            Cki.Set_Cookies("Password", sPassword, 1)

            sWhere.Clear()

            If sUser_ID <> "" Then
                sWhere.Append(" AND UserID = @UserID")
                cDB.AddWithValue("@UserID", sUser_ID)
            End If

            If sPassword <> "" Then
                sWhere.Append(" AND Password = @Password")
                cDB.AddWithValue("@Password", sPassword)
            End If


            sSQL.Clear()
            sSQL.Append("SELECT")
            sSQL.Append(" UserID")
            sSQL.Append(" ,UserName")
            sSQL.Append(" ,Admin")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE 1 = 1" & sWhere.ToString)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = 1
                rUserID.Append(cDB.DRData("UserID"))
                rUserName.Append(cDB.DRData("UserName"))
                rAdmin.Append(cDB.DRData("Admin"))
                If Cki.Get_Cookies(cDB.DRData("UserID").ToString & "AttKey") = "" Then
                    Cki.Set_Cookies(cDB.DRData("UserID").ToString & "AttKey", cCom.CmnTimeStamp, 1)
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
            hHash.Add("count", iCount)
            hHash.Add("UserID", rUserID.ToString)
            hHash.Add("UserName", rUserName.ToString)
            hHash.Add("Admin", rAdmin.ToString)
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
