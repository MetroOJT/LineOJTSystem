<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Index.aspx.vb" Inherits="Mgmt_User_Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="Index.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/ui-lightness/jquery-ui.css"/>
    <script src="../../Common/js/Common.js"></script>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <title>ユーザー検索</title>
</head>
<body>
    <form runat="server" id="form1" style="margin: 0 auto;" onsubmit="return false">
    <div>
        <div class="container">
            <%=cCom.CmnDspHeader() %>
            <div class="accordion" margin: 0 auto;">
                <div class="accordion-item">
                    <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse show">
                        <div id="btnOption" class="row accordion-body">
                            <input type="button" value="検索" name="Search" id="btnSearch" class="col-sm btn btn-outline-primary" />
                            <input type="button" value="クリア" name="Clear" id="btnClear" class="col-sm btn btn-outline-danger" />
                            <input type="button" value="新規登録" name="Signup" id="btnSign_up" class="col-sm btn btn-outline-success" />
                            <input type="button" value="戻る" name="Back" id="btnBack" class="col-sm btn btn-outline-secondary" />
                        </div>
                        <div id="Condition" class="accordion-body">
                        
                            <div class="d-flex">
                                <label class="col-sm-2 col-form-label">ユーザーID</label>
                                <input type="text" class="form-control w-25" id="user_ID" runat="server" maxlength="20" />
                            </div>
                        
                            <div class="d-flex">
                                <label class="col-sm-2 col-form-label">ユーザー名</label>
                                <input type="text" class="form-control w-25" id="user_Name" runat="server"  maxlength="20" />
                            </div>

                            <div class="d-flex">
                                <label class="col-sm-2 col-form-label">管理者</label>
                                <select aria-label="全て" class="form-select form-select-sm w-25" id="Kanrisya" name="kanrisya" runat="server">
                                    <option value="all" selected="" id="kanrisya_all" runat="server" >全て</option>
                                    <option value="1" id="kanrisya_on" runat="server" >ON</option>
                                    <option value="0" id="kanrisya_off" runat="server" >OFF</option>
                                </select>
                            </div>

                            <div class="d-flex"> 
                                <label class="col-sm-2 col-form-label">登録日</label>
                                <input type="text" id="DateFm" class="form-control initial-time" style="margin-right: 20px;" runat="server"  maxlength="10" readonly /><span class="mt-auto mb-auto">～</span>
                                <input type="text" id="DateTo" class="form-control initial-time" style="margin-left: 20px;" runat="server"  maxlength="10" readonly />
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
            <div id="DB_Result" style="margin: 0 auto;">
                <div id="CntArea" style="margin-top: 20px;"></div>
                <nav aria-label="Page navigation example" id="PNArea" class="row row-cols-auto"></nav>
                <div id="ResultArea"></div>
            </div>
        </div>
    <%=cCom.CmnDspFooter() %>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Index.js"></script>
    <!-- jQuery UI -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
    <!-- 日本語化ファイル -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.4/i18n/jquery.ui.datepicker-ja.min.js"></script>
</body>
</html>
