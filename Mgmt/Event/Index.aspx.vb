
Partial Class Sample_Index
    Inherits System.Web.UI.Page
    '起動時にCommon.vbを読み込む
    Public cCom As New Common
    Dim Cki_EventName As String = ""
    Dim Cki_EventStatus As String = ""
    Dim Cki_ScheduleFm As String = ""
    Dim Cki_ScheduleTo As String = ""
    Dim Cki_Keyword As String = ""
    Dim Cki_NowPage As String = ""

    Public Sub Pre_Load(sender As Object, e As EventArgs) Handles Me.PreLoad
        Dim Cki As New Cookie

        Try
            Cki_EventName = Cki.Get_Cookies("EventName")
            Cki_EventStatus = Cki.Get_Cookies("EventStatus")
            Cki_ScheduleFm = Cki.Get_Cookies("ScheduleFm")
            Cki_ScheduleTo = Cki.Get_Cookies("ScheduleTo")
            Cki_Keyword = Cki.Get_Cookies("Keyword")
        Catch ex As Exception

        End Try
    End Sub
    Public Sub Page_Load() Handles Me.Load

        Dim Cki As New Cookie

        Try
            txtEventName.Value = Cki_EventName
            EventStatus.Value = Cki_EventStatus
            txtScheduleFm.Value = Cki_ScheduleFm
            txtScheduleTo.Value = Cki_ScheduleTo
            txtKeyword.Value = Cki_Keyword
        Catch ex As Exception

        End Try
    End Sub
End Class
