<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Sample_hirashima_menu" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Index.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <title>通信ログ</title>
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
            <label class="col-5 h6" id="Manager">担当者名: </label>
        </div>

        <div class="accordion">
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
                            <input type="datetime-local" id="DateFm" class="form-control" style="margin-right: 20px;" />～
                            <input type="datetime-local" id="DateTo" class="form-control" style="margin-left: 20px"; />
                        </div>
                        
                        <div>
                            <label class="col-sm-2 col-form-label">送信/受信</label>
                            <select aria-label="全て" class="form-select form-select-sm" style="display: inline-block; width: 20%;" id="Sere">
                                <option value="all" selected>全て</option>
                                <option value="send">送信</option>
                                <option value="reception">受信</option>
                            </select>
                        </div>
                        
                        <div>
                            <label class="col-sm-2 col-form-label">ステータス</label>
                            <select aria-label="全て" class="form-select form-select-sm" style="display: inline-block; width: 20%;" id="Status">
                                <option value="all" selected>全て</option>
                                <option value="normal">正常</option>
                                <option value="abnormality">異常</option>
                            </select>
                        </div>
                    </div>
                </div>
                <h2 class="row accordion-header">
                    <div id="cona" class="col-10"></div>
                    <div id="conb" class="col-2">
                        <button class="accordion-button" type="button" id="btnClose" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="true" aria-controls="panelsStayOpen-collapseOne">
                        閉じる
                        </button>
                    </div>
                </h2>
            </div>
        </div>

        <%-- データベースから取得したデータを表示 --%>
        <div id="DB_Result">
            <div id="CntArea" style="margin-bottom: 20px;"></div>
            <nav aria-label="Page navigation example">
                <ul class="pagination">
                    <li class="page-item" id="pista">
                        <a class="page-link" href="#" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <li class="page-item" id="piback"><a class="page-link" href="#">‹</a></li>
                    <li class="page-item" id="pi1"><a class="page-link" href="#">1</a></li>
                    <li class="page-item" id="pi2"><a class="page-link" href="#">2</a></li>
                    <li class="page-item" id="pi3"><a class="page-link" href="#">3</a></li>
                    <li class="page-item" id="pinext"><a class="page-link" href="#">›</a></li>
                    <li class="page-item" id="piend">
                        <a class="page-link" href="#" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
            <div id="ResultArea"></div>
        </div>
    </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
