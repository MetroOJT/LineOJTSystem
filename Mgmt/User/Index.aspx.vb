
Partial Class Mgmt_User_Index
    Inherits System.Web.UI.Page
    Public cCom As New Common
    Dim Cki_UserID As String = ""
    Dim Cki_UserName As String = ""
    Dim Cki_Admin_Check As String = ""
    Dim Cki_DateFm As String = ""
    Dim Cki_DateTo As String = ""

    Public Sub Pre_Load(sender As Object, e As EventArgs) Handles Me.PreLoad
        Dim Cki As New Cookie

        Try
            Cki_UserID = Cki.Get_Cookies("u_User_ID")
            Cki_UserName = Cki.Get_Cookies("User_Name")
            Cki_Admin_Check = Cki.Get_Cookies("Admin_Check")
            Cki_DateFm = Cki.Get_Cookies("DateFm")
            Cki_DateTo = Cki.Get_Cookies("DateTo")
        Catch ex As Exception

        End Try
    End Sub

    Public Sub Page_Load() Handles Me.Load

        Dim Cki As New Cookie

        Try
            user_ID.Value = Cki_UserID
            user_Name.Value = Cki_UserName
            If Cki_Admin_Check = 1 Then
                kanrisya_on.Checked = True
            ElseIf Cki_Admin_Check = 0 Then
                kanrisya_off.Checked = True
            End If
            DateFm.Value = Cki_DateFm
            DateTo.Value = Cki_DateTo

        Catch ex As Exception

        End Try
    End Sub
End Class
