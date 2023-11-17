<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Mgmt_User_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Index.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <script src="../../Common/js/Common.js"></script>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <title>ユーザー検索</title>
</head>
<body>
    <form runat="server" id="form1" style="margin: 0 auto;" onsubmit="return false">
    <div>
        <div class="container">
            <%=cCom.CmnDspHeader() %>
        </div>

        <div class="accordion" style="width: 90%; margin: 0 auto;">
            <div class="accordion-item">
                <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse show">
                    <div id="btnOption" class="row accordion-body">
                        <input type="button" value="検索" name="Search" id="btnSearch" class="col-sm btn btn-outline-primary" />
                        <input type="button" value="新規登録" name="Clear" id="btnSign_up" class="col-sm btn btn-outline-success" />
                        <div class="col-sm"></div>
                        <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary" />
                    </div>
                    <div id="Condition" class="accordion-body">
                        
                        <div class="d-flex">
                            <label class="col-sm-2 col-form-label">ユーザーID</label>
                            <input type="text" class="form-control w-25" id="user_ID" runat="server" />
                        </div>
                        
                        <div class="d-flex">
                            <label class="col-sm-2 col-form-label">ユーザー名</label>
                            <input type="text" class="form-control w-25" id="user_Name" runat="server" />
                        </div>

                        <div class="d-flex">
                            <label class="col-sm-2 col-form-label">管理者</label>
                            <select aria-label="全て" class="form-select form-select-sm w-25" id="Kanrisya" name="kanrisya" runat="server">
                                <option value="all" selected="" id="kanrisya_all" runat="server" >全て</option>
                                <option value="1" id="kanrisya_on" runat="server" >オン</option>
                                <option value="0" id="kanrisya_off" runat="server" >オフ</option>
                            </select>
                        </div>

                        <div> 
                            <label class="col-sm-2 col-form-label">登録日</label>
                            <input type="datetime-local" id="DateFm" class="form-control initial-time" style="margin-right: 20px;" runat="server" />～
                            <input type="datetime-local" id="DateTo" class="form-control initial-time" style="margin-left: 20px;" runat="server" />
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
    <%=cCom.CmnDspFooter() %>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
</body>
</html>
