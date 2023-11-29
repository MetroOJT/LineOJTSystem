<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Load"
                context.Response.Write(Load(context))
            Case "Search"
                context.Response.Write(sea(context))
        End Select
    End Sub

    '検索から遷移してきた際に最初に表示する値を検索する
    Public Function Load(ByVal context As HttpContext) As String
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
        Dim rPassword As New StringBuilder
        Dim rUserName As New StringBuilder
        Dim rAdmin As New StringBuilder

        Dim sUser_ID As String = ""

        Dim iCount As Integer = 0

        Try
            sUser_ID = context.Request.Item("User_ID")

            cDB.AddWithValue("@UserID", sUser_ID)

            'ユーザーマスタに新規登録する
            sSQL.Clear()
            sSQL.Append("SELECT")
            sSQL.Append(" UserID")
            sSQL.Append(" ,Password")
            sSQL.Append(" ,UserName")
            sSQL.Append(" ,Admin")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE UserID = @UserID")
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = 1
                rUserID.Append(cDB.DRData("UserID"))
                rPassword.Append(cDB.DRData("Password"))
                rUserName.Append(cDB.DRData("UserName"))
                rAdmin.Append(cDB.DRData("Admin"))
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
            hHash.Add("Password", rPassword.ToString)
            hHash.Add("UserName", rUserName.ToString)
            hHash.Add("Admin", rAdmin.ToString)

            sJSON = jJSON.Serialize(hHash)
        End Try
        Return sJSON
    End Function

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
        Dim sSere As String = ""
        Dim sCond_Status As String = ""
        Dim sOrder As String = ""

        Dim iCount As Integer = 0
        Dim sErrorMessage As String = ""

        Try
            sUser_ID = context.Request.Item("User_ID")
            cDB.AddWithValue("@UserID", sUser_ID)

            sWhere.Clear()
            sWhere.Append(" WHERE UserID = @UserID")

            sSQL.Clear()
            sSQL.Append("SELECT COUNT(*) AS SameUserID")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(sWhere)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                If cDB.DRData("SameUserID") <> 0 Then
                    sErrorMessage = "そのユーザーIDはすでに登録されています。"
                End If
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
            hHash.Add("count", iCount)
            hHash.Add("ErrorMessage", sErrorMessage)
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