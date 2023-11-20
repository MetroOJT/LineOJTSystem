<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_hirashima_menu" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Index.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <title>通信ログ</title>
</head>
<body>
    <form runat="server" id="form1" style="margin: 0 auto;" onsubmit="return false">
    <div>
        <%-- type > value > name > id > class > style --%>
        <div class="container">
            <%=cCom.CmnDspHeader() %>
        </div>

        <div class="accordion" style="width: 90%; margin: 0 auto;">
            <div class="accordion-item">
                <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse show">
                    <div id="btnOption" class="row accordion-body">
                        <input type="button" value="検索" name="Search" id="btnSearch" class="col-sm btn btn-outline-primary" />
                        <input type="button" value="クリア" name="Clear" id="btnClear" class="col-sm btn btn-outline-danger" />
                        <div class="col-sm"></div>
                        <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary" />
                    </div>
                    <div id="Condition" class="accordion-body">
                        <div> 
                            <label class="col-sm-2 col-form-label">通信日時</label>
                            <input type="datetime-local" id="DateFm" class="form-control initial-time" runat="server" style="margin-right: 20px;" />～
                            <input type="datetime-local" id="DateTo" class="form-control initial-time" runat="server" style="margin-left: 20px;" />
                        </div>
                        
                        <div>
                            <label class="col-sm-2 col-form-label">送信/受信</label>
                            <select aria-label="全て" class="form-select form-select-sm" runat="server" style="display: inline-block; width: 20%;" id="Sere">
                                <option value="" selected>全て</option>
                                <option value="Send">送信</option>
                                <option value="Recv">受信</option>
                            </select>
                        </div>
                        
                        <div>
                            <label class="col-sm-2 col-form-label">ステータス</label>
                            <select aria-label="全て" class="form-select form-select-sm" runat="server" style="display: inline-block; width: 20%;" id="Status">
                                <option value="" selected>全て</option>
                                <option value="normal">正常</option>
                                <option value="abnormality">異常</option>
                            </select>
                        </div>

                        <div>
                            <label class="col-sm-2 col-form-label">並べ替え</label>
                            <select aria-label="全て" class="form-select form-select-sm" runat="server" style="display: inline-block; width: 20%;" id="Order">
                                <option value="all" selected>指定なし</option>
                                <option value="time_asc">通信日時(昇順)</option>
                                <option value="time_desc">通信日時(降順)</option>
                            </select>
                        </div>
                    </div>
                </div>
                <h1 class="row accordion-header">
                    <div id="cona" class="col-10"></div>
                    <div id="conb" class="col-2">
                        <button class="accordion-button" type="button" id="btnClose" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="true" aria-controls="panelsStayOpen-collapseOne">
                        閉じる
                        </button>
                    </div>
                </h1>
            </div>
        </div>

        <%-- データベースから取得したデータを表示 --%>
        <div id="DB_Result" style="width: 90%; margin: 0 auto;">
            <div id="CntArea" style="margin-bottom: 20px;"></div>
            <nav aria-label="Page navigation example" id="PNArea" class="row row-cols-auto"></nav>
            <div id="ResultArea"></div>
        </div>
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
    </form>
    <script src="../../Common/js/Common.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
