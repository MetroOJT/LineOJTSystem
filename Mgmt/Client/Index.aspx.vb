Imports Newtonsoft.Json
Imports System.Net

Partial Class Mgmt_Client_Index
    Inherits System.Web.UI.Page
    Public cCom As New Common

    '読み込む前にTLS1.2を適用する
    Public Sub Pre_Load(sender As Object, e As EventArgs) Handles Me.PreLoad
        ServicePointManager.SecurityProtocol = ServicePointManager.SecurityProtocol Or SecurityProtocolType.Tls12
    End Sub
    
    Public Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

    End Sub
End Class

