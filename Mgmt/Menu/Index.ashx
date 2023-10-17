<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "CreateTable"
                context.Response.Write(ct(context))
            Case "MakeMenu"
                context.Response.Write(mm(context))
        End Select
    End Sub

    Public Function ct(ByVal context As HttpContext) As String
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
        Dim test As String = ""

        Dim sMenuID As String = ""
        Dim sMenuName As String = ""
        Dim sAdmin As String = ""

        Dim iCount As Integer = 0

        Try
            sMenuID = context.Request.Item("MenuID")
            sMenuName = context.Request.Item("MenuName")
            sAdmin = context.Request.Item("Admin")

            sTempTable = cCom.CmnGet_TableName("menuitiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("MenuID", sMenuID, 1)
            Cki.Set_Cookies("MenuName", sMenuName, 1)
            Cki.Set_Cookies("Admin", sAdmin, 1)
            Cki.Set_Cookies("TempTable", sTempTable, 1)

            sSQL.Clear()
            sSQL.Append(" CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append(" wRowNo        INT NOT NULL AUTO_INCREMENT")
            sSQL.Append(" ,wMenuID      INT NOT NULL")
            sSQL.Append(" ,wMenuName        VARCHAR(40) NOT NULL")
            sSQL.Append(" ,wAdmin         INT NOT NULL")
            sSQL.Append(" ,PRIMARY KEY (wRowNo)")
            sSQL.Append(" )")
            cDB.ExecuteSQL(sSQL.ToString)

            sWhere.Clear()
            cDB.ParameterClear()

            If sMenuID <> "" Then
                sWhere.Append(" AND MenuID LIKE @MenuID")
                cDB.AddWithValue("@MenuID", "%" & sMenuID & "%")
            End If

            If sMenuName <> "" Then
                sWhere.Append(" AND MenuName >= @MenuName")
                cDB.AddWithValue("@MenuName", sMenuName)
            End If

            If sAdmin <> "" Then
                sWhere.Append(" AND Admin <= @Admin")
                cDB.AddWithValue("@Admin", sAdmin)
            End If

            sSQL.Clear()
            sSQL.Append(" INSERT INTO " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append(" wMenuID")
            sSQL.Append(" ,wMenuName")
            sSQL.Append(" ,wAdmin")
            sSQL.Append(" )")
            sSQL.Append(" SELECT")
            sSQL.Append(" MenuID")
            sSQL.Append(" ,MenuName")
            sSQL.Append(" ,Admin")
            sSQL.Append(" FROM lineojtdb.menumst")
            'sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE 1=1" & sWhere.ToString)
            sSQL.Append(" ORDER BY MenuID")
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
    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

            sHTML.Append("<input type=""button"" value=""イベント登録"" class="""" name=""btnEventReg"" id=""btnEventReg"" onclick=""btnEventRegClick()"" />")
            sHTML.Append("<input type=""button"" value=""イベント検索"" class="""" name=""btnEventSearch"" id=""btnEventSearch"" onclick=""btnEventSearchClick()"" />")
            If uAdmin = 1 Then
                sHTML.Append("<input type=""button"" value=""通信ログ"" class="""" name=""btnComLog"" id=""btnComLog"" onclick=""btnComLogClick()"" />")
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

'Public Class Index : Implements IHttpHandler

'    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
'        Select Case context.Request.Item("admin")
'            'Case "0"
'            '    context.Response.Write(noadmin(context))
'            Case "1"
'                context.Response.Write(admin(context))
'        End Select
'    End Sub

'    Public Function admin(ByVal context As HttpContext) As String
'        Dim cCom As New Common
'        Dim cDB As New CommonDB
'        Dim Cki As New Cookie
'        Dim sSQL As New StringBuilder
'        Dim sWhere As New StringBuilder
'        Dim jJSON As New JavaScriptSerializer
'        Dim sJSON As String = ""
'        Dim hHash As New Hashtable
'        Dim sRet As String = ""
'        Dim sStatus As String = "OK"
'        Dim sTempTable As String = ""
'        Dim test As String = ""

'        Dim sUserID As String = ""
'        Dim sUserName As String = ""
'        Dim sAdmin As String = ""

'        Dim iCount As Integer = 0

'        Try
'            sUserID = context.Request.Item("UserID")
'            sUserName = context.Request.Item("UserName")
'            sAdmin = context.Request.Item("Admin")

'            sTempTable = cCom.CmnGet_TableName("Itiran")
'            cDB.DeleteTable(sTempTable)

'            Cki.Set_Cookies("UserID", sUserID, 1)
'            Cki.Set_Cookies("UserName", sUserName, 1)
'            Cki.Set_Cookies("Admin", sAdmin, 1)
'            Cki.Set_Cookies("TempTable", sTempTable, 1)

'            sSQL.Clear()
'            sSQL.Append(" CREATE TABLE " & sTempTable)
'            sSQL.Append(" (")
'            sSQL.Append(" wRowNo        INT NOT NULL AUTO_INCREMENT")
'            sSQL.Append(" ,wUserID      INT NOT NULL")
'            sSQL.Append(" ,wUserName        VARCHAR(40) NOT NULL")
'            sSQL.Append(" ,wAdmin         INT NOT NULL")
'            sSQL.Append(" ,PRIMARY KEY (wRowNo)")
'            sSQL.Append(" )")
'            cDB.ExecuteSQL(sSQL.ToString)

'            sWhere.Clear()
'            cDB.ParameterClear()

'            If sUserID <> "" Then
'                sWhere.Append(" AND UserID LIKE @UserID")
'                cDB.AddWithValue("@UserID", "%" & sUserID & "%")
'            End If

'            If sUserName <> "" Then
'                sWhere.Append(" AND UserName >= @UserName")
'                cDB.AddWithValue("@UserName", sUserName)
'            End If

'            If sAdmin <> "" Then
'                sWhere.Append(" AND Admin <= @Admin")
'                cDB.AddWithValue("@Admin", sAdmin)
'            End If

'            sSQL.Clear()
'            sSQL.Append(" INSERT INTO " & sTempTable)
'            sSQL.Append(" (")
'            sSQL.Append(" wUserID")
'            sSQL.Append(" ,wUserName")
'            sSQL.Append(" ,wAdmin")
'            sSQL.Append(" )")
'            sSQL.Append(" SELECT")
'            sSQL.Append(" UserID")
'            sSQL.Append(" ,UserName")
'            sSQL.Append(" ,Admin")
'            sSQL.Append(" FROM lineojtdb.usermst")
'            'sSQL.Append(" FROM " & cCom.gctbl_UserMst)
'            sSQL.Append(" WHERE 1=1" & sWhere.ToString)
'            sSQL.Append(" ORDER BY UserID")
'            iCount = cDB.ExecuteSQL(sSQL.ToString)

'        Catch ex As Exception
'            sRet = ex.Message
'        Finally
'            cDB.DrClose()
'            cDB.Dispose()
'            If sRet <> "" Then
'                sStatus = "NG"
'                cCom.CmnWriteStepLog(sRet)
'            End If

'            hHash.Add("status", sStatus)
'            hHash.Add("count", iCount)
'            sJSON = jJSON.Serialize(hHash)
'        End Try

'        Return sJSON
'    End Function

'    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
'        Get
'            Return False
'        End Get
'    End Property

'End Class