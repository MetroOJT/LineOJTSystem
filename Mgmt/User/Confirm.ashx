﻿<%@ WebHandler Language="VB" Class="Confirm" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports Newtonsoft.Json

Public Class Confirm : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Save"
                context.Response.Write(Save(context))
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
            sRe_UserID = context.Request.Item("Re_UserID")
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
                        sSQL.Append(" ,Update_ID")
                        sSQL.Append(" )")
                        sSQL.Append(" VALUES")
                        sSQL.Append(" (")
                        sSQL.Append("  @UserID")
                        sSQL.Append(" ,@Password")
                        sSQL.Append(" ,@User_Name")
                        sSQL.Append(" ,b" & "'" & sAdmin_Check & "'")
                        sSQL.Append(" ,NOW()")
                        sSQL.Append(" ,@Re_UserID")
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
                        sSQL.Append(" ,Update_ID      = @Re_UserID")
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


    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class
