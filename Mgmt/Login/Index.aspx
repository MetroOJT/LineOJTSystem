<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_Login_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <link rel="stylesheet" href="Index.css" />
    <link href="https://use.fontawesome.com/releases/v5.6.1/css/all.css" rel="stylesheet">
    <title>ログイン</title>
</head>
<body>
    <form id="form1" runat="server" style="width: 80%; margin: 0 auto">
    <div>
        <div id="Header" class="row">
            <label class="h1" id="SystemTitle">クーポン発行サービス</label>
        </div>
        <div id="option">
            <p id="option_title" class="h4">ログイン画面</p>
            <div class="mx-auto" style="margin-top: 10px;">
                <div style="display: flex;">
                    <label>ユーザーID</label>
                    <div class="InputField_div">
                        <input type="text" id="user_ID" style="border: none; width: 200px;" onkeydown="go_next()" />
                    </div>
                    
                </div>
                <div style="display: flex; margin-top: 10px;">
                    <label>パスワード</label>
                    <div class="InputField_div">
                        <input type="password" id="user_password" onkeydown="go_login();" style="border: none; width: 200px;" />
                        <span id="buttonEye" class="fa fa-eye-slash" style="margin: auto;"></span>
                    </div>
                </div>
            </div>
            <div class="error_div" style="margin-top: 10px; text-align: center"></div>
            <input type="button" value="ログイン" id="login_button" class="btn btn-primary shadow" />
            <div class="unauthorized_access_div" style="margin-top: 10px; text-align: center;"></div>
        </div>
    </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
