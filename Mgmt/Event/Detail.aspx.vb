
Partial Class Sample_Detail
    Inherits System.Web.UI.Page

    Public Sub Page_Load() Handles Me.Load
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim sRet As String = ""

        Try

            sSQL.Clear()
            sSQL.Append(" SELECT")
            sSQL.Append("  um_Name")
            sSQL.Append(" ,um_Age")
            sSQL.Append(" ,um_Address")
            sSQL.Append(" FROM " & cCom.gctbl_UserMst)
            sSQL.Append(" WHERE um_UserID = @UserID")
            cDB.SelectSQL(sSQL.ToString)

        Catch ex As Exception
            sRet = ex.Message
        Finally
            cDB.DrClose()
            cDB.Dispose()
            If sRet <> "" Then
                cCom.CmnWriteStepLog(sRet)
            End If
        End Try
    End Sub
End Class
