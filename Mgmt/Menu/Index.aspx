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
        <div id="Header" class="row">
            <label class="h1 col-7" id="SystemTitle">クーポン発行サービス</label>
            <div class="col-5"><input type="button" value="ログアウト" name="btnLogOut" id="btnLogOut" class="btn btn-warning w-75" /></div>
            <div class="w-100"></div>
            <div class="col-7"></div>
            <label class="col-5 h6" id="Manager"></label>
        </div>
        <div id="option"></div>
    </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
