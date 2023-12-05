<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous"/>
    <link rel="stylesheet" href="Index.css"/>
    <link rel="stylesheet" href="../../Common/css/Common.css" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <%--ヘッダー・フッター読み込み用--%>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <title>DBテスト</title>
</head>
<body>
    <div class="container">
        <%--ヘッダー読み込み--%>
        <%=cCom.CmnDspHeader() %>
        <%--開閉するフォーム--%>
        <div class="accordion">
            <div class="accordion-item">
                <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse show">
                    <form id="form1" runat="server">
                        <div id="btnOption" class="row accordion-body">
                            <input type="button" value="検索" name="Search" id="btnSearch" class="col-sm btn btn-outline-primary"/>
                            <input type="button" value="クリア" name="Clear" id="btnClear" class="col-sm btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#staticBackdrop"/>
                            <div class="col-sm"></div>
                            <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary"/>
                        </div>
                        <div id="Condition" class="accordion-body">
                            <div class="row">
                                <label class="col-sm-2 col-form-label">イベント名</label>
                                <input type="text" id="txtEventName" class="form-control" runat="server" maxlength="50"/>
                            </div>
                            <div>
                                <label class="col-sm-2 col-form-label">ステータス</label>
                                <select aria-label="全て" class="form-select form-select-sm" id="EventStatus" runat="server">
                                    <option value="" selected="">全て</option>
                                    <option value="1">ON</option>
                                    <option value="0">OFF</option>
                                </select>
                            </div>
                            <div>
                                <label class="col-sm-2 col-form-label">スケジュール</label>
                                <input type="text" class="form-control flatpickr-input active" id="txtScheduleFm" name="" required="required" autocomplete="off" readonly="readonly" runat="server">～
                                <input type="text" class="form-control flatpickr-input" id="txtScheduleTo" required="required" autocomplete="off" readonly="readonly" runat="server">
                            </div>
                            <div class="row">
                                <label class="col-sm-2 col-form-label">キーワード</label>
                                <input type="text" id="txtKeyword"  class="form-control" runat="server" maxlength="30"/>
                            </div>
                        </div>
                    </form>
                </div>
            <h2 class="row accordion-header">
                <div id="cola" class="col-10"></div>
                <div id="colb" class="col-2">
                    <button class="accordion-button" type="button" id="btnClose" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="true" aria-controls="panelsStayOpen-collapseOne">閉じる</button>
                </div>
            </h2>
            </div>
        </div>
        <div id="CntArea"></div>
        <nav aria-label="Page navigation example" id="PageNationArea" class="row row-cols-auto"></nav>
        <div id="ItiranArea"></div>
        <%=cCom.CmnDspFooter()%>

        <!-- Button trigger modal -->
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#exampleModal" id="error_modal" style="display:none;">
            Launch demo modal
        </button>
            
        <!-- Modal -->
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="exampleModalLabel">Error</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        検索するページを入力してください。
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <%--モーダルウィンドウ(要件にない追加項目)--%>
    <%--<div class="modal fade" id="staticBackdrop" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h1 class="modal-title fs-5" id="staticBackdropLabel">Modal title</h1>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div id="modalBody" class="modal-body">
              ...
            </div>
            <div class="modal-footer">
              <input type="button" class="btn btn-secondary" data-bs-dismiss="modal" value="いいえ"/>
              <input type="button" id="modalBtnDelete" class="btn btn-primary" value="はい"/>
              <input type="button" id="modalBtnClear" class="btn btn-primary" value="はい"/>
            </div>
          </div>
        </div>
    </div>--%>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js"></script>
    <script src="Index.js"></script>
</body>
</html>



