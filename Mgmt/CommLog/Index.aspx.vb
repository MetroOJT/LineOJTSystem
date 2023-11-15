
Partial Class Sample_hirashima_menu
    Inherits System.Web.UI.Page
    Public cCom As New Common
    Dim Cki_LogDateFm As String = ""
    Dim Cki_LogDateTo As String = ""
    Dim Cki_LogSendRecv As String = ""
    Dim Cki_LogStatusNumber As String = ""
    Dim Cki_LogOrder As String = ""

    Public Sub Pre_Load(sender As Object, e As EventArgs) Handles Me.PreLoad
        Dim Cki As New Cookie

        Try
            Cki_LogDateFm = Cki.Get_Cookies("LogDateFm")
            Cki_LogDateTo = Cki.Get_Cookies("LogDateTo")
            Cki_LogSendRecv = Cki.Get_Cookies("LogSendRecv")
            Cki_LogStatusNumber = Cki.Get_Cookies("LogStatusNumber")
            Cki_LogOrder = Cki.Get_Cookies("LogOrder")
        Catch ex As Exception

        End Try
    End Sub
    Public Sub Page_Load() Handles Me.Load

        Dim Cki As New Cookie

        Try
            DateFm.Value = Cki_LogDateFm
            DateTo.Value = Cki_LogDateTo
            Sere.Value = Cki_LogSendRecv
            Status.Value = Cki_LogStatusNumber
            Order.Value = Cki_LogOrder
        Catch ex As Exception

        End Try
    End Sub
End Class
