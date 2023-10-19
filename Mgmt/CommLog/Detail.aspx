<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Sample_hirashima_CommLog_Detail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Detail.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <title>通信ログ詳細</title>
</head>
<body>
    <form runat="server" id="form1" style="width: 80%; margin: 0 auto;">
    <div>
    <%-- type > value > name > id > class > style --%>
        <div id="Header" class="row">
            <label class="h1 col-7" id="SystemTitle">クーポン発行サービス</label>
            <div class="col-5"><input type="button" value="ログアウト" name="btnLogOut" id="btnLogOut" class="btn btn-warning w-75" /></div>
            <div class="w-100"></div>
            <div class="col-7"></div>
            <label class="col-5 h6" id="Manager"></label>
        </div>
        <div id="Detail">
            <div id="btnOption" class="row accordion-body">
                <div class="col-sm"></div>
                <div class="col-sm"></div>
                <div class="col-sm"></div>
                <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary" />
            </div>
            <div id="Condition" class="accordion-body">
                <div>
                    <label class="col-sm-2 col-form-label">送信/受信</label>
                    <input type="text" value="受信" id="DetailSere" class="w-25" disabled />
                </div>
                <div>
                    <label class="col-sm-2 col-form-label">ステータス</label>
                    <input type="text" value="200" id="DetailStatus" class="w-25" disabled />
                </div>
                <div>
                    <label class="col-sm-2 col-form-label">通信時間</label>
                    <input type="text" value="YYYY/MM/DD HH:MM:SS" id="DetailTime" class="w-25" disabled />
                </div>
                <div>
                    <label for="DetailLog" class="col-form-label">通信ログ</label>
                    <textarea class="form-control form-control-sm" id="DetailLog" rows="7" style="resize: none;">サムズアップ（英: Thumbs up）とは、親指を立てるジェスチャー。日本では一般にグッドサインと呼ばれていて「Good」を意味する。英語圏では肯定的な意味を持つが、中東、西アフリカ、南アメリカ（ブラジルを除く）では「侮蔑の表現」となる。[要出典]その他、ヨーロッパやアジアの一部の国ではわいせつな表現となる。

正確な起源はわかっていないが、古代ローマの剣闘士競技で観客が使っていた「敗者を許せ」のジェスチャーが由来だという説がある（親指を下向きにするサムズダウンは「敗者を殺せ」の意味が込められている[1]）。</textarea>
                </div>
            </div>
        </div>
    </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Detail.js"></script>
</body>
</html>
