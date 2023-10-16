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
    <form runat="server" id="form1" style="width: 70%; margin: 0 auto;">
    <div>
        <%-- type > value > name > id > class > style --%>
        <div id="Header" class="row">
            <label id="SystemTitle" class="h1 col-6" >通信ログ</label>
            <div class="col-6"><input type="button" value="ログアウト" name="btnLogOut" id="btnLogOut" class="btn btn-warning w-50" /></div>
            <div class="w-100"></div>
            <div class="col-6"></div>
            <label id="Manager" class="col-6 h6">担当者名: サムズ・アップ</label>
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
                                <option value="2">Two</option>
                                <option value="3">Three</option>
                            </select>
                        </div>
                        
                        <div>
                            <label class="col-sm-2 col-form-label">ステータス</label>
                            <select aria-label="全て" class="form-select form-select-sm" style="display: inline-block; width: 20%;" id="Status">
                                <option value="all" selected>全て</option>
                                <option value="on">オン</option>
                                <option value="off">オフ</option>
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
            <p id="DB_Result_Number">件数: 〇件</p>
            <nav aria-label="Page navigation example">
                <ul class="pagination">
                    <li class="page-item">
                        <a class="page-link" href="#" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#" aria-label="Back">‹</a>
                    </li>
                    <li class="page-item"><a class="page-link" href="#">1</a></li>
                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                    <li class="page-item">
                        <a class="page-link" href="#" aria-label="Next">›</a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#" aria-label="End">
                        <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
            <table class="table table-striped table-bordered">
                <thead>
                    <tr>
                        <th scope="col">詳細</th>
                        <th scope="col">送信/受信</th>
                        <th scope="col">ステータス</th>
                        <th scope="col">メッセージ</th>
                        <th scope="col">通信時間</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="button" value="詳細" name="detail" class="btn btn-success btn-sm" /></td>
                        <td class="text-center">送信</td>
                        <td class="text-center">101</td>
                        <td>てってて</td>
                        <td class="text-center">YYYY/MM/DD hh:mm:ss</td>
                    </tr>
                    <tr>
                        <td><input type="button" value="詳細" name="detail" class="btn btn-success btn-sm" /></td>
                        <td class="text-center">受信</td>
                        <td class="text-center">220</td>
                        <td>すーーー</td>
                        <td class="text-center">YYYY/MM/DD hh:mm:ss</td>
                    </tr>
                    <tr>
                        <td><input type="button" value="詳細" name="detail" class="btn btn-success btn-sm" /></td>
                        <td class="text-center">送信</td>
                        <td class="text-center">300</td>
                        <td>とおおおおおおおおおおおお</td>
                        <td class="text-center">YYYY/MM/DD hh:mm:ss</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
