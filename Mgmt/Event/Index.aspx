<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous"/>
    <link rel="stylesheet" href="Index.css"/>
    <title>DBテスト</title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="accordion" style="width: 90%; margin: 0 auto;">
            <div class="accordion-item">
                <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse show">
                    <div id="btnOption" class="row accordion-body">
                        <input type="button" value="検索" name="Search" id="btnSearch" class="col-sm btn btn-outline-primary"/>
                        <input type="button" value="登録・更新" name="UpdIns" id="btnUpdIns" class="col-sm btn btn-outline-primary"/>
                        <input type="button" value="削除" name="Delete" id="btnDelete" class="col-sm btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#staticBackdrop"/>
                        <input type="button" value="クリア" name="Clear" id="btnClear" class="col-sm btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#staticBackdrop"/>
                        <div class="col-sm"></div>
                        <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary"/>
                    </div>
                    <div id="Condition" class="accordion-body">
                        <div class="row">
                            <label class="col-sm-2 col-form-label">イベント名</label>
                            <input type="text" id="txtEvent" class="form-control"/>
                        </div>
                        <div>
                            <label class="col-sm-2 col-form-label">ステータス</label>
                            <select aria-label="全て" class="form-select form-select-sm" style="display: inline-block; width: 20%;" id="EventStatus">
                                <option value="" selected="">全て</option>
                                <option value="1">オン</option>
                                <option value="0">オフ</option>
                            </select>
                        </div>
                        <div>
                            <label class="col-sm-2 col-form-label">スケジュール</label>
                            <input type="date" id="txtDateFm" class="form-control" style="margin-right: 20px;"/>～
                            <input type="date" id="txtDateTo" class="form-control" style="margin-left: 20px" ;=""/>
                        </div>
                        <div class="row">
                            <label class="col-sm-2 col-form-label">キーワード</label>
                            <input type="text" id="txtKeyword"  class="form-control"/>
                        </div>
                    </div>
                </div>
                <h2 class="row accordion-header">
                    <div id="cona" class="col-10"></div>
                    <div id="conb" class="col-2">
                        <button class="accordion-button" type="button" id="btnClose" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="true" aria-controls="panelsStayOpen-collapseOne">閉じる</button>
                    </div>
                </h2>
            </div>
        </div>
        <div style="width: 90%; margin: 0 auto;">
            <div id="CntArea"></div>
            <div id="ItiranArea">
                <div id="NumberCnt"></div>
                <div id="Pager"></div>
                <div id="ResultTable"></div>
            </div>
        </div>
    </form>
    <div class="modal fade" id="staticBackdrop" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
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
    </div>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="../../Common/js/Common.js"></script>
    <script src="Index.js"></script>
</body>
</html>

