<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Sample_hirashima_CommLog_Detail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Detail.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <title>通信ログ詳細</title>
</head>
<body>
    <form runat="server" id="form1" style="margin: 0 auto;">
    <div>
    <%-- type > value > name > id > class > style --%>
        <div class="container">
            <%=cCom.CmnDspHeader() %>
        </div>
        <div id="Detail" style="width: 90%; margin: 0 auto;">
            <div id="btnOption" class="row accordion-body">
                <div class="col-sm"></div>
                <div class="col-sm"></div>
                <div class="col-sm"></div>
                <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary" />
            </div>
            <div id="Condition" class="accordion-body">
                <div>
                    <label class="col-sm-2 col-form-label">送信/受信</label>
                    <input type="text" id="DetailSere" class="w-25" disabled />
                </div>
                <div>
                    <label class="col-sm-2 col-form-label">ステータス</label>
                    <input type="text" id="DetailStatus" class="w-25" disabled />
                </div>
                <div>
                    <label class="col-sm-2 col-form-label">通信時間</label>
                    <input type="text" id="DetailTime" class="w-25" disabled />
                </div>
                <div>
                    <label for="DetailLog" class="col-form-label">通信ログ</label>
                    <textarea class="form-control form-control-sm" id="DetailLog" rows="7" style="resize: none;" disabled></textarea>
                </div>
            </div>
        </div>
    </div>
    </form>
    <%--＜aspsファイルのheadタグの中に追加＞--%>
    <script src="../../Common/js/Common.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Detail.js"></script>
</body>
</html>
