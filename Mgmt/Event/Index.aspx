<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <link rel="stylesheet" href="Index.css"/>    
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
    <title>DBテスト</title>
</head>
<body>
    <form id="form1" runat="server">
        
        <div id="FormArea">
            <div id="TopButtonArea">
                <input type="button" id="Searchbtn" value="検索" />
                <input type="button" id="Backbtn" value="戻る" />
            </div>
            <div>
                <label>イベント名</label>
                <input type="text" id="txtEvent"/>
            </div>
            <div>
                <label>ステータス</label>
                <input type="radio" id="EventStatusOn" name="EventStatus" value="1"/>
                <label for="EventStatusOn">オン</label>
                <input type="radio" id="EventStatusOff" name="EventStatus" value="0"/>
                <label for="EventStatusOff">オフ</label>
            </div>
            <div class="d-flex">
                <label>スケジュール</label>
                <div class="d-flex">
                    <input type="date" id="txtDateFm"/>
                    <p>～</p>
                    <input type="date" id="txtDateTo"/>
                </div>
            </div>
            <div>
                <label>キーワード</label>
                <input type="text" id="txtKeyword" />
            </div>
            <div id="BottomButtonArea">
                <input type="button" id="Closebtn" value="閉じる" />
            </div> 
        </div>
        <div id="ItiranArea">
            <div id="NumberCnt"></div>
            <div id="Pager"></div>
            <div id="ResultTable"></div>
        </div>
    </form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
</body>
</html>
