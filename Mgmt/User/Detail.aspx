<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Mgmt_UserRegistration_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <link rel="stylesheet" href="Detail.css" />
    <link href="https://use.fontawesome.com/releases/v5.6.1/css/all.css" rel="stylesheet" />
    <title>ユーザー登録</title>
</head>
<body>
    <form id="form1" runat="server" style="width: 80%; margin: 0 auto" class="needs-validation" novalidate>
    <div class="container">
        <%--<%=cCom.CmnDspHeader() %>--%>
        <div>
            <input type="button" value="登録" id="registration_button" class="btn btn-outline-primary shadow h-50 mt-4 me-auto mb-4 ms-auto w-25 h5" />
            <input type="button" value="削除" id="delete_button" class="btn btn-outline-danger shadow h-50 mt-4 me-auto mb-4 ms-auto w-25 h5" />
            <input type="button" value="戻る" id="back_button" class="btn btn-outline-secondary shadow h-50 mt-4 me-auto mb-4 ms-auto w-25 h5" />
        </div>
        <div id="option" class="w-100 d-flex flex-column mt-5">
            <div class="mx-auto m-2 mt-4">
                <div class="d-flex">
                    <label class="m-auto">ユーザーID</label>
                    <div class="InputField_div">
                        <input type="text" id="user_ID" required="required" class="border-0 w-100 form-control" maxlength="20" data-regexp="^[0-9]{5}$" />
                    </div>
                    <div class="invalid-feedback">Required.</div>
                </div>
                <div class="d-flex mt-4">
                    <label class="m-auto">ユーザー名</label>
                    <div class="InputField_div">
                        <input type="text" id="user_Name" required="required" class="border-0 w-100 form-control" maxlength="20" data-regexp="^[0-9]{5}$" />
                    </div>
                    <div class="invalid-feedback">Required.</div>
                </div>
                <div class="d-flex mt-4">
                    <label class="mt-auto mb-auto" style="width: 100px">管理者</label>
                    <div style="display: flex; margin-left: 55px; width: 300px;">
                        <input type="radio" id="contactChoice1" name="contact" value="True" />
                        <label for="contactChoice1" style="width: auto;">オン</label>
                        <input type="radio" id="contactChoice2" name="contact" value="False" style=" margin-left: 10px;" />
                        <label for="contactChoice2" style="width: auto;">オフ</label>
                    </div>
                    <div class="invalid-feedback">Required.</div>
                </div>
                <div class="d-flex mt-4">
                    <label class="m-auto">パスワード</label>
                    <span class="InputField_div">
                        <input type="password" id="user_password" required="required" class="border-0 w-100 form-control" autocomplete="off" maxlength="20" data-maxlen=20 data-regexp="^[0-9a-z]{1,}$"/>
                        <span id="buttonEye_1" class="fa fa-eye-slash"></span>
                    </span>
                </div>
                <div class="invalid-feedback">Required.</div>
                <div class="d-flex mt-4">
                    <label class="m-auto">パスワード（確認用）</label>
                    <span class="InputField_div">
                        <input type="password" id="user_password_confirmation" required="required" class="border-0 w-100 form-control" autocomplete="off" maxlength="20" data-maxlen=20 data-regexp="^[0-9a-z]{1,}$"/>
                        <span id="buttonEye_2" class="fa fa-eye-slash"></span>
                    </span>
                </div>
                <div class="invalid-feedback">Required.</div>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Detail.js"></script>
</body>
</html>
