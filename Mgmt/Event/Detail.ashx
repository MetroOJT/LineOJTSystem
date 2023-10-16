<%@ WebHandler Language="VB" Class="Detail" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Detail : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Save"
                context.Response.Write(Save(context))
            Case "MessageAdd"
                context.Response.Write(MessageAdd(context))
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
        Dim sEvent As String = ""
        Dim sEventStatus As String = ""
        Dim sDateFm As String = ""
        Dim sDateTo As String = ""
        Dim sKeyword As String = ""

        Try
            sUserID = context.Request.Item("UserID")
            sEvent = context.Request.Item("Event")
            sEventStatus = context.Request.Item("EventStatus")
            sDateFm = context.Request.Item("DateFm")
            sDateTo = context.Request.Item("DateTo")
            sKeyword = context.Request.Item("Keyword")

            If sUserID = "" Then
                sMode = "Ins"
            Else
                sMode = "Upd"
            End If

            cDB.AddWithValue("@UserID", sUserID)
            'cDB.AddWithValue("@Name", sName)
            'cDB.AddWithValue("@Age", sAge)
            'cDB.AddWithValue("@Address", sAddress)

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

    Public Function MessageAdd(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim Cki As New Cookie
        Dim sStatus As String = "OK"
        Dim sHTML As New StringBuilder
        Dim hHash As New Hashtable
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim sRet As String = ""
        Dim iCnt As String = ""

        Try
            iCnt = Cki.Get_Cookies("iCnt")

            If (iCnt = "") Then
                iCnt = "0"
                Cki.Set_Cookies("iCnt", iCnt, 1)
            End If

            sHTML.Clear()
            sHTML.Append("<div class=""MessageContainer"" id=""MessageContainer" & iCnt & """>")
            sHTML.Append("<div class=""MessagebtnArea"">")
            sHTML.Append("<input type=""button"" id =""MessageUpbtn" & iCnt & """value=""△"" onclick=""MessageUpbtnClick()""/>")
            sHTML.Append("<input type=""button"" id =""MessageDownbtn" & iCnt & """value=""▽"" onclick=""MessageDownbtnClick()""/>")
            sHTML.Append("<input type=""button"" id =""MessageDeletebtn" & iCnt & """value=""×"" onclick=""MessageDeletebtnClick()""/>")
            sHTML.Append("</div>")
            sHTML.Append("<textarea class=""txtMessage"" id=""txtMessage" & iCnt & """ maxlength=500 onkeyup=""txtCountUpd()""></textarea>")
            sHTML.Append("<div class=""txtCount"" id=""txtCount" & iCnt & """>0/500</div>")
            sHTML.Append("</div>")

            iCnt = CStr(CInt(iCnt) + 1)
            Cki.Set_Cookies("iCnt", iCnt, 1)

        Catch ex As Exception
            sRet = ex.Message
        Finally
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