<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_hirashima_menu" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Index.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <title>メニュー</title>
</head>
<body>
    <form id="form1" runat="server" style="width: 80%; margin: 0 auto;">
    <div>
        <div id="HeaderArea" class="d-flex p-3" style="height:150px">
                <div class="w-50  h1 text-center m-0" style="vertical-align:middle">クーポン発行サービス</div>
                <div class="w-50 text-end">
                    <input type="button" id="btnLogOut" value="ログアウト" class="btn btn-warning"/>
                    <p id="Manager" class="h5 m-0"></p>
                </div>
        </div>
            <hr class="m-0"/>
        <div id="option"></div>
    </div>
    </form>
    <%--＜aspsファイルのheadタグの中に追加＞--%>
    <script src="../../Common/js/Common.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
