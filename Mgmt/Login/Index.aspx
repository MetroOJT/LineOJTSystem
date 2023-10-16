<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_Login_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div>
            <%--共通のヘッダーを後で追加する--%>
        </div>
        <div>
            <p>ログイン画面</p>
            <table width="600px">
                <tr>
                    <th width="30%">ユーザーID</th>
                    <td width="70%"><input type="text" id="user_ID" autofocus /></td>
                </tr>
                <tr>
                    <th width="30%">パスワード</th>
                    <td width="70%"><input type="password" id="user_password" onkeydown="go();" /></td>
                </tr>
            </table>
            <div class="error_div" style="width: 600px"; text-align: center"></div>
            <input type="button" value="ログイン" id="login_button" />
        </div>

    </div>
    </form>
    <script src="Index.js"></script>
</body>
</html>
