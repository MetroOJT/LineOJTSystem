<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Sample_Detail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="../../Common/js/Common.js"></script>
    <script src="Detail.js"></script>
    <title>イベント登録画面</title>
</head>
<body>
    <form id="main" runat="server">
        <div class="container">
            <div id="HeaderArea" class="d-flex p-3" style="height:150px">
                <div class="w-50  h1 text-center m-0" style="vertical-align:middle">クーポン発行サービス</div>
                <div class="w-50 text-end">
                    <input type="button" value="ログアウト" class="btn btn-warning"/>
                    <p id="LoginUserName" class="h5 m-0"></p>
                </div>
            </div>
            <hr class="m-0"/>
            <div id="FormArea" class="w-100 ">
                <div id="ButtonArea" class="w-100 p-3">
                    <input type="button" id="Savebtn" value="登録" />
                    <input type="button" id="Deletebtn" value="削除" />
                    <input type="button" id="Backbtn" value="戻る" />
                </div>
                <div>
                    <label>イベント名</label>
                    <input type="text" id="txtEventName" />
                </div>
                <div>
                    <label>ステータス</label>
                    <input type="radio" id="EventStatusOn" name="EventStatus" value="1" />
                    <label for="EventStatusOn">オン</label>
                    <input type="radio" id="EventStatusOff" name="EventStatus" value="0" />
                    <label for="EventStatusOff">オフ</label>
                </div>
                <div class="d-flex">
                    <label>スケジュール</label>
                    <div class="d-flex">
                        <input type="date" id="txtScheduleFm" />
                        <p>～</p>
                        <input type="date" id="txtScheduleTo" />
                    </div>
                </div>
                <div>
                    <label>キーワード</label>
                    <input type="text" id="txtKeyword" />
                </div>
            </div>
            <p>※メッセージは5個まで追加できます</p>
            <div id="MessageArea" class="w-100 p-3 mx-auto"></div>
            <div id="MessagebtnArea">
                <input type="button" id="MessageAddbtn" value="メッセージ追加" />
            </div>
        </div>
    </form>
</body>
</html>
