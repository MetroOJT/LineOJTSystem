<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Sample_Detail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <%="<script src='Detail.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <title>イベント登録画面</title>
</head>
<body>
    <form id="main" runat="server">
        <div class="container">
            <%=cCom.CmnDspHeader() %>
            <div id="FormArea" class="">
                <div id="ButtonArea" class="row">
                    <div class="col-2 d-grid">
                    <input type="button" id="Savebtn" class="btn btn-primary btn-lg" value="登録" />
                    </div>
                    <div class="col-2 d-grid">
                    <input type="button" id="Deletebtn" class="btn btn-danger btn-lg" value="削除" />
                    </div>
                    <div class="col-6"></div>
                    <div class="col-2 d-grid">
                    <input type="button" id="Backbtn" class="btn btn-secondary btn-lg" value="戻る" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-3 text-center">
                        <label>イベント名</label>
                    </div>
                    <div class="col-9">
                        <input type="text" id="txtEventName" class="w-100"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-3 text-center">
                        <label>ステータス</label>
                    </div>
                    <div class="col-9">
                        <input type="radio" id="EventStatusOn" name="EventStatus" value="1" />
                        <label for="EventStatusOn">オン</label>
                        <input type="radio" id="EventStatusOff" name="EventStatus" value="0" />
                        <label for="EventStatusOff">オフ</label>
                    </div>
                </div>
                <div class="d-flex row">
                    <div class="col-3 text-center">
                    <label>スケジュール</label>
                    </div>
                    <div class="d-flex col-9">
                        <input type="date" id="txtScheduleFm" />
                        <p>～</p>
                        <input type="date" id="txtScheduleTo" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-3 text-center">
                        <label>キーワード</label>
                    </div>
                    <div class="col-9">
                        <input type="text" id="txtKeyword" class="w-100"/>
                    </div>        
                </div>
            </div>
            <p>※メッセージは5個まで追加できます</p>
            <div id="MessageArea" class="row"></div>
            <div id="MessagebtnArea">
                <input type="button" id="MessageAddbtn" value="メッセージ追加" />
            </div>
        </div>
    </form>
</body>
</html>
