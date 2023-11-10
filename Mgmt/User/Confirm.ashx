<%@ WebHandler Language="VB" Class="Confirm" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Registration"
                context.Response.Write(Registration(context))
            Case "Update"
                context.Response.Write(Update(context))
        End Select
    End Sub

    'ユーザーマスタに新規登録する
    Public Function Registration(ByVal context As HttpContext) As String
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

        Dim rsameUserID As New StringBuilder

        Dim sUser_ID As String = ""
        Dim sPassword As String = ""
        Dim sUser_Name As String = ""
        Dim sAdmin_Check As String = ""
        Dim sRe_UserID As String = ""

        Dim iCount As Integer = 0
        Dim sErrorMessage As String = ""

        Try
            sUser_ID = context.Request.Item("User_ID")
            sPassword = context.Request.Item("Password")
            sUser_Name = context.Request.Item("User_Name")
            sAdmin_Check = context.Request.Item("Admin_Check")
            sRe_UserID = context.Request.Item("Re_UserID")

            cDB.AddWithValue("@UserID", sUser_ID)
            cDB.AddWithValue("@Password", sPassword)
            cDB.AddWithValue("@User_Name", sUser_Name)
            cDB.AddWithValue("@Admin_Check", sAdmin_Check)
            cDB.AddWithValue("@Re_UserID", sRe_UserID)

            'ユーザーIDが重複していないかを確認する
            sSQL.Clear()
            sSQL.Append("SELECT COUNT(*) AS sameUserID")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE UserID = @UserID")
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                rsameUserID.Append(cDB.DRData("sameUserID"))
                If cDB.DRData("sameUserID") <> 0 Then
                    sErrorMessage = "同じユーザーIDは登録できません。"
                End If
            End If

            If sErrorMessage = "" Then
                sSQL.Clear()
                sSQL.Append("INSERT INTO " & cCom.gctbl_UserMst)
                sSQL.Append(" (")
                sSQL.Append(" UserID")
                sSQL.Append(" ,Password")
                sSQL.Append(" ,UserName")
                sSQL.Append(" ,Admin")
                sSQL.Append(" ,Update_Date")
                sSQL.Append(" ,Update_ID")
                sSQL.Append(" )")
                sSQL.Append(" VALUES")
                sSQL.Append(" (")
                sSQL.Append(" @UserID")
                sSQL.Append(" ,@Password")
                sSQL.Append(" ,@User_Name")
                sSQL.Append(" ,b" & "'" & sAdmin_Check & "'")
                sSQL.Append(", Now()")
                sSQL.Append(" ,@Re_UserID")
                sSQL.Append(" )")
                cDB.ExecuteSQL(sSQL.ToString)

                If cDB.ReadDr Then
                    iCount = 1
                End If
            Else
                hHash.Add("ErrorMessage", sErrorMessage)
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
            hHash.Add("Admin", rsameUserID.ToString)

            sJSON = jJSON.Serialize(hHash)
        End Try
        Return sJSON
    End Function

    'ユーザーマスタの情報を更新する
    Public Function Update(ByVal context As HttpContext) As String
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

        Dim sUser_ID As String = ""
        Dim sPassword As String = ""
        Dim sUser_Name As String = ""
        Dim sAdmin_Check As String = ""
        Dim sRe_UserID As String = ""
        Dim sH_UserID As String = ""

        Dim iCount As Integer = 0

        Try
            sUser_ID = context.Request.Item("User_ID")
            sPassword = context.Request.Item("Password")
            sUser_Name = context.Request.Item("User_Name")
            sAdmin_Check = context.Request.Item("Admin_Check")
            sRe_UserID = context.Request.Item("Re_UserID")
            sH_UserID = context.Request.Item("hUser_ID")

            cDB.AddWithValue("@UserID", sUser_ID)
            cDB.AddWithValue("@Password", sPassword)
            cDB.AddWithValue("@User_Name", sUser_Name)
            cDB.AddWithValue("@Admin_Check", sAdmin_Check)
            cDB.AddWithValue("@Re_UserID", sRe_UserID)
            cDB.AddWithValue("@H_UserID", sH_UserID)


            sSQL.Clear()
            sSQL.Append("UPDATE " & cCom.gctbl_UserMst)
            sSQL.Append(" SET")
            sSQL.Append(" (")
            sSQL.Append(" UserID = @UserID")
            sSQL.Append(" ,Password = @Password")
            sSQL.Append(" ,UserName = @User_Name")
            sSQL.Append(" ,Admin = b" & "'" & sAdmin_Check & "'")
            sSQL.Append(" ,Update_Date = Now()")
            sSQL.Append(" ,Update_ID = @Re_UserID")
            sSQL.Append(" )")
            sSQL.Append(" WHERE")
            sSQL.Append(" UserID = @H_UserID")
            cDB.ExecuteSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = 1
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


    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class
