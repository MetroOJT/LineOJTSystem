<%@ WebHandler Language="VB" Class="Index" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization

Public Class Index : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Select Case context.Request.Item("mode")
            Case "Search"
                context.Response.Write(Search(context))
            Case "Delete"
                context.Response.Write(Delete(context))
            Case "Itiran"
                context.Response.Write(Itiran(context))
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

        Dim sEvent As String = ""
        Dim sEventStatus As String = ""
        Dim sDateFm As String = ""
        Dim sDateTo As String = ""
        Dim sKeyword As String = ""

        Dim iCount As Integer = 0

        Try

            sEvent = context.Request.Item("Event")
            sEventStatus = context.Request.Item("EventStatus")
            sDateFm = context.Request.Item("DateFm")
            sDateTo = context.Request.Item("DateTo")
            sKeyword = context.Request.Item("Keyword")

            sTempTable = cCom.CmnGet_TableName("Itiran")
            cDB.DeleteTable(sTempTable)

            Cki.Set_Cookies("Event", sEvent, 1)
            Cki.Set_Cookies("EventStatus", sEventStatus, 1)
            Cki.Set_Cookies("DateFm", sDateFm, 1)
            Cki.Set_Cookies("DateTo", sDateTo, 1)
            Cki.Set_Cookies("Keyword", sKeyword, 1)
            Cki.Set_Cookies("TempTable", sTempTable, 1)

            sSQL.Clear()
            sSQL.Append("CREATE TABLE " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append("  wRowNo       INT NOT NULL AUTO_INCREMENT")
            sSQL.Append("  ,wUserID     INT NOT NULL")
            sSQL.Append("  ,wName       VARCHAR(40) NOT NULL")
            sSQL.Append("  ,wAge        INT NOT NULL")
            sSQL.Append("  ,wAddress    VARCHAR(200) NOT NULL")
            sSQL.Append("  ,wUpdateTime DATETIME NOT NULL ")
            sSQL.Append("  ,PRIMARY KEY (wRowNo) ")
            sSQL.Append("  )")
            cDB.ExecuteSQL(sSQL.ToString)

            sWhere.Clear()
            cDB.ParameterClear()

            If sEvent <> "" Then
                sWhere.Append(" AND um_Name LIKE @Event")
                cDB.AddWithValue("@Event", "%" & sEvent & "%")

            End If

            If sEventStatus <> "" Then
                sWhere.Append(" AND um_Age = @EventStatus")
                cDB.AddWithValue("@EventStatus", sEventStatus)
            End If

            If sDateFm <> "" Then
                sWhere.Append(" AND um_Age >= @DateFm")
                cDB.AddWithValue("@DateFm", sDateFm)
            End If


            If sDateTo <> "" Then
                sWhere.Append(" AND um_Age <= @DateTo")
                cDB.AddWithValue("@DateTo", sDateTo)
            End If

            If sKeyword <> "" Then
                sWhere.Append(" AND um_Address LIKE @Keyword")
                cDB.AddWithValue("@Keyword", "%" & sKeyword & "%")
            End If

            sSQL.Clear()
            sSQL.Append(" INSERT INTO " & sTempTable)
            sSQL.Append(" (")
            sSQL.Append("  wUserID")
            sSQL.Append(" ,wName")
            sSQL.Append(" ,wAge")
            sSQL.Append(" ,wAddress")
            sSQL.Append(" ,wUpdateTime")
            sSQL.Append(" )")
            sSQL.Append(" SELECT")
            sSQL.Append("  um_UserID")
            sSQL.Append(" ,um_Name")
            sSQL.Append(" ,um_Age")
            sSQL.Append(" ,um_Address")
            sSQL.Append(" ,um_UpdateTime")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE 1=1" & sWhere.ToString)
            sSQL.Append(" ORDER BY um_UpdateTime")
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

    Public Function Delete(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"

        Dim sDelList As String = ""
        Dim sTempTable As String = ""

        Try

            sDelList = context.Request.Item("DelList")
            sTempTable = Cki.Get_Cookies("TempTable")

            cDB.BeginTran()

            sSQL.Clear()
            sSQL.Append(" DELETE FROM " & sTempTable)
            sSQL.Append(" WHERE wUserID IN (" & sDelList & ")")
            cDB.ExecuteSQL(sSQL.ToString)

            sSQL.Clear()
            sSQL.Append(" DELETE FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE um_UserID IN (" & sDelList & ")")
            cDB.ExecuteSQL(sSQL.ToString)


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

    Public Function Itiran(ByVal context As HttpContext) As String
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim jJSON As New JavaScriptSerializer
        Dim sJSON As String = ""
        Dim hHash As New Hashtable
        Dim sRet As String = ""
        Dim sStatus As String = "OK"
        Dim iCnt As Integer = 1
        Dim sRow As String = ""

        Dim sTempTable As String = ""

        Dim sHTML As New StringBuilder
        Dim iCount As Integer = 0

        Try

            sTempTable = Cki.Get_Cookies("TempTable")

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append(" COUNT(*) AS Count")
            sSQL.Append(" FROM " & sTempTable)
            cDB.SelectSQL(sSQL.ToString)

            If cDB.ReadDr Then
                iCount = cDB.DRData("count")
            End If


            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append("  wUserID")
            sSQL.Append(" ,wName")
            sSQL.Append(" ,wAge")
            sSQL.Append(" ,wAddress")
            sSQL.Append(" ,DATE_FORMAT(wUpdateTime,'%Y/%m/%d %T') AS wUpdateTime")
            sSQL.Append(" FROM " & sTempTable)
            sSQL.Append(" ORDER BY wRowNo")
            cDB.SelectSQL(sSQL.ToString)

            sHTML.Clear()
            sHTML.Append("<table border=""1"" width=""1000px"" style=""border-collapse: collapse;"">")
            sHTML.Append("<tr style=""background-color: #CCCCCC;"">")
            sHTML.Append("<td width=""05%"" align=""center"">選択</td>")
            sHTML.Append("<td width=""20%"" align=""center"">氏名</td>")
            sHTML.Append("<td width=""10%"" align=""center"">年齢</td>")
            sHTML.Append("<td width=""35%"" align=""center"">住所</td>")
            sHTML.Append("<td width=""30%"" align=""center"">登録日</td>")
            Do Until Not cDB.ReadDr

                sRow = ""
                If iCnt Mod 2 = 0 Then
                    sRow = " evenRow"
                End If

                sHTML.Append("<tr class=""" & sRow & """>")
                sHTML.Append("<td align=""center""><input type=""checkbox""name=""chkUser"" id=""chk" & iCnt & """ value=""" & cDB.DRData("wUserID") & """ /></td>")
                sHTML.Append("<td align=""left"">&nbsp;" & cDB.DRData("wName") & "</td>")
                sHTML.Append("<td align=""center"">" & cDB.DRData("wAge") & "</td>")
                sHTML.Append("<td align=""left"">&nbsp;" & cDB.DRData("wAddress") & "</td>")
                sHTML.Append("<td align=""center"">" & cDB.DRData("wUpdateTime") & "</td>")
                sHTML.Append("</tr>")

                iCnt = iCnt + 1
            Loop
            sHTML.Append("</tr>")
            sHTML.Append("</table>")

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