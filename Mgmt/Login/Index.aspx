﻿<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_Login_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <link rel="stylesheet" href="Index.css" />
    <link href="https://use.fontawesome.com/releases/v5.6.1/css/all.css" rel="stylesheet" />
    <title>ログイン</title>
</head>
<body>
    <form id="form1" runat="server" style="width: 80%; margin: 0 auto" class="needs-validation" novalidate>
    <div class="container">
        <%=cCom.CmnDspHeader("Login") %>
        <div id="option" class="w-100 d-flex flex-column mt-5">
            <p id="option_title" class="h4 text-center">ログイン画面</p>
            <div class="mx-auto m-2 mt-4">
                <div class="d-flex">
                    <label class="m-auto">ユーザーID</label>
                    <div class="InputField_div" style="border-color: #dee2e6; border-radius: 0.375rem">
                        <input type="text" id="user_ID" required="required" class="border-0 w-100 form-control" maxlength="20"/>
                    </div>
                    <div class="invalid-feedback">Required.</div>
                </div>
                <div class="d-flex mt-2">
                    <label class="m-auto">パスワード</label>
                    <div class="InputField_div" style="border-color: #dee2e6; border-radius: 0.375rem">
                        <input type="password" id="user_password" required="required" class="border-0 w-100 form-control" autocomplete="off" maxlength="20"/>
                        <span id="buttonEye" class="fa fa-eye-slash"></span>
                    </div>
                    <div class="invalid-feedback">Required.</div>
                </div>
            </div>
            <div class="error_div"></div>
            <input type="button" value="ログイン" id="login_button" class="btn btn-primary shadow h-50 mt-4 me-auto mb-4 ms-auto w-25 h5" />
            <div class="unauthorized_access_div mt-2 text-center"></div>
        </div>
    </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <script src="Index.js"></script>
</body>
</html>
