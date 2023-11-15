
Partial Class Sample_Detail
    Inherits System.Web.UI.Page
    Public cCom As New Common
    Public DefaultDate As String = ""
    Public EndDate As String = ""

    Public Sub Page_Load() Handles Me.Load
        Dim cCom As New Common
        Dim cDB As New CommonDB
        Dim Cki As New Cookie
        Dim sSQL As New StringBuilder
        Dim sRet As String = ""


        Try
            Cki.Set_Cookies("iCnt", "0", 1)
            Cki.Set_Cookies("CouponCode", cCom.gcFormatCouponCode, 1)

            DefaultDate = cCom.gcDate_DefaultDate
            EndDate = cCom.gcDate_EndDate
            DefaultDate = DefaultDate.Replace("/", "-")
            EndDate = EndDate.Replace("/", "-")
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
