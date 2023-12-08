<%@ WebHandler Language="VB" Class="Confirm" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports Newtonsoft.Json

Public Class Confirm : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Save"
                context.Response.Write(Save(context))
            Case "Delete"
                context.Response.Write(Delete(context))
            Case "Clear"
                context.Response.Write(clear(context))
        End Select
    End Sub

    'ユーザーマスタに新規登録・更新
    Public Function Save(ByVal context As HttpContext) As String
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
        Dim sMode As String = ""
        Dim sTempTable As String = ""

        Dim rsameUserID As New StringBuilder

        Dim sUser_ID As String = ""
        Dim sPassword As String = ""
        Dim sUser_Name As String = ""
        Dim sAdmin_Check As String = ""
        Dim sRe_UserID As String = ""
        Dim sH_UserID As String = ""

        Dim iCount As Integer = 0
        Dim sErrorMessage As String = ""

        Try
            ' jsからのデータを取得
            sUser_ID = context.Request.Item("User_ID")
            sPassword = context.Request.Item("Password")
            sUser_Name = context.Request.Item("User_Name")
            sAdmin_Check = context.Request.Item("Admin_Check")
            'sRe_UserID = context.Request.Item("Re_UserID")
            sRe_UserID = Cki.Get_Cookies("User_ID")
            sH_UserID = context.Request.Item("hUser_ID")

            cDB.AddWithValue("@UserID", sUser_ID)
            cDB.AddWithValue("@Password", sPassword)
            cDB.AddWithValue("@User_Name", sUser_Name)
            cDB.AddWithValue("@Admin_Check", sAdmin_Check)
            cDB.AddWithValue("@Re_UserID", sRe_UserID)
            cDB.AddWithValue("@H_UserID", sH_UserID)

            If sH_UserID = "" Then
                sMode = "Ins"
            Else
                sMode = "Upd"
            End If

            '同一のユーザーIDがデータベース内にないかチェック
            If sErrorMessage = "" Then
                If sMode = "Ins" Then
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
                End If
            End If



            If sErrorMessage = "" Then
                Select Case sMode
                    Case "Ins"

                        'usermstにINSERT文を実行
                        sSQL.Clear()
                        sSQL.Append(" INSERT INTO " & cCom.gctbl_UserMst)
                        sSQL.Append(" (")
                        sSQL.Append("  UserID")
                        sSQL.Append(" ,Password")
                        sSQL.Append(" ,UserName")
                        sSQL.Append(" ,Admin")
                        sSQL.Append(" ,Update_Date")
                        sSQL.Append(" ,Update_UserID")
                        sSQL.Append(" )")
                        sSQL.Append(" VALUES")
                        sSQL.Append(" (")
                        sSQL.Append("  @UserID")
                        sSQL.Append(" ,@Password")
                        sSQL.Append(" ,@User_Name")
                        sSQL.Append(" ,b" & "'" & sAdmin_Check & "'")
                        sSQL.Append(" ,NOW()")
                        sSQL.Append(" ," & sRe_UserID & "")
                        sSQL.Append(" )")
                        cDB.ExecuteSQL(sSQL.ToString)

                    Case "Upd"

                        'usermstにUPDATE文を実行
                        sSQL.Clear()
                        sSQL.Append(" UPDATE " & cCom.gctbl_UserMst)
                        sSQL.Append(" SET")
                        sSQL.Append("  UserID         = @UserID")
                        sSQL.Append(" ,Password       = @Password")
                        sSQL.Append(" ,UserName       = @User_Name")
                        sSQL.Append(" ,Admin          = " & "b" & "'" & sAdmin_Check & "'")
                        sSQL.Append(" ,Update_Date    = NOW()")
                        sSQL.Append(" ,Update_UserID      = @Re_UserID")
                        sSQL.Append(" WHERE UserID    = @H_UserID")
                        cDB.ExecuteSQL(sSQL.ToString)

                End Select

                If cDB.ReadDr Then
                    iCount = 1
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
            hHash.Add("Mode", sMode)
            hHash.Add("ErrorMessage", sErrorMessage)

            sJSON = jJSON.Serialize(hHash)
        End Try
        Return sJSON
    End Function

    ' ユーザーマスタから該当行の削除
    Public Function Delete(ByVal context As HttpContext) As String
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
        Dim Cookie_UserID As String = ""

        Dim sUser_ID As String = ""
        Dim sErrorMessage As String = ""

        Dim iCount As Integer = 0

        Try
            sUser_ID = context.Request.Item("User_ID")

            cDB.AddWithValue("@UserID", sUser_ID)
            Cookie_UserID = Cki.Get_Cookies("User_ID")
            If sUser_ID = Cookie_UserID Then
                sErrorMessage = "現在ログインしているユーザーのため、削除することが出来ません。"
            End If
            If sErrorMessage = "" Then
                'ユーザーマスタに新規登録する
                sSQL.Clear()
                sSQL.Append("DELETE")
                sSQL.Append(" FROM " & cCom.gctbl_UserMst)
                sSQL.Append(" WHERE UserID = @UserID")
                cDB.ExecuteSQL(sSQL.ToString)
            End If

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

            hHash.Add("ErrorMessage", sErrorMessage)
            hHash.Add("status", sStatus)
            hHash.Add("count", iCount)

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

        Try

            Cki.Release_Cookies("u_User_ID")
            Cki.Release_Cookies("User_Name")
            Cki.Release_Cookies("User_Index_Admin_Check")
            Cki.Release_Cookies("DateFm")
            Cki.Release_Cookies("DateTo")
            Cki.Release_Cookies("PNList")
            Cki.Release_Cookies("Useritiran")
            Cki.Release_Cookies("pagemedian")
            Cki.Release_Cookies("nowpage")


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
