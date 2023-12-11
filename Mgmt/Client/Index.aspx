<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Mgmt_Client_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous"/>
    <link rel="stylesheet" href="Index.css"/>
    <title>お客様一覧</title>
</head>
<body>
    <div class="container">
        <%--ヘッダー読み込み--%>
        <%=cCom.CmnDspHeader() %>
        <div id="btnOption" class="row w-100">
            <div class="col-10"></div>
            <input type="button" value="戻る" name="Back" id="btnBack" class="col-2 btn btn-outline-secondary"/>
        </div>
        <div class="d-flex">
            <div id="ItiranBox" class="w-25">
                <div class="input-group">
                    <input type="text" class="form-control" id="txtDisplayName" placeholder="検索" runat="server" maxlength="40"/>
                    <a class="btn btn-outline-success" id="btnSearch">
                        <i class="bi bi-search">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-search" viewBox="0 0 16 16">
                               <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z"/>
                            </svg>
                        </i>
                    </a>
                </div>
                <div id="ItiranArea" class="d-flex flex-column"></div>
            </div>
            <div id="MessageArea" class="w-75 d-flex flex-column">
                <div id="MessageBox">
                    <div id="MessageHeader" class="d-flex align-items-center">
                        <img id="MessageHeaderImg" class="rounded-circle"/>
                        <p id="MessageHeaderName">氏名</p>
                    </div>
                    <div id="MessageBody"></div>
                </div>
                <div id="PushMessage">
                    <form id="form1" runat="server">
                        <div class="input-group">
                            <textarea class="form-control" id="txtPushMessage" maxlength="500" rows="1"></textarea>
                            <input type="button" class="btn disabled" id="btnPushMessage" value="送信" />
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <%=cCom.CmnDspFooter()%>
    </div>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <script src="Index.js"></script>
</body>
</html>


