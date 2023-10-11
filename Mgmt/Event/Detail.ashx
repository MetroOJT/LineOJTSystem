<%@ WebHandler Language="VB" Class="Detail" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Detail : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Save"
                context.Response.Write(Save(context))
        End Select
    End Sub

    Public Function Save(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim sMode As String = ""

        Dim sUserID As String = ""
        Dim sName As String = ""
        Dim sAge As String = ""
        Dim sAddress As String = ""

        Try
            sUserID = context.Request.Item("UserID")
            sName = context.Request.Item("Name")
            sAge = context.Request.Item("Age")
            sAddress = context.Request.Item("Address")

            If sUserID = "" Then
                sMode = "Ins"
            Else
                sMode = "Upd"
            End If

            cDB.AddWithValue("@UserID", sUserID)
            cDB.AddWithValue("@Name", sName)
            cDB.AddWithValue("@Age", sAge)
            cDB.AddWithValue("@Address", sAddress)

            cDB.BeginTran()

            Select Case sMode
                Case "Ins"
                    sSQL.Clear()
                    sSQL.Append(" INSERT INTO " & cCom.gctbl_UserMst)
                    sSQL.Append(" (")
                    sSQL.Append("  um_Name")
                    sSQL.Append(" ,um_Age")
                    sSQL.Append(" ,um_Address")
                    sSQL.Append(" ,um_UpdateTime")
                    sSQL.Append(" )")
                    sSQL.Append(" VALUES")
                    sSQL.Append(" (")
                    sSQL.Append("  @Name")
                    sSQL.Append(" ,@Age")
                    sSQL.Append(" ,@Address")
                    sSQL.Append(" ,NOW()")
                    sSQL.Append(" )")
                    cDB.ExecuteSQL(sSQL.ToString)
                Case "Upd"
                    sSQL.Clear()
                    sSQL.Append(" UPDATE " & cCom.gctbl_UserMst)
                    sSQL.Append(" SET")
                    sSQL.Append("  um_Name        = @Name")
                    sSQL.Append(" ,um_Age         = @Age")
                    sSQL.Append(" ,um_Address     = @Address")
                    sSQL.Append(" ,um_UpdateTime  = NOW()")
                    sSQL.Append(" WHERE um_UserID = @UserID")
                    cDB.ExecuteSQL(sSQL.ToString)
            End Select

            cDB.CommitTran()

        Catch ex As Exception
            cDB.RollBackTran()
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