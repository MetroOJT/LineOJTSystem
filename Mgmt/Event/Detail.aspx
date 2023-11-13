<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Sample_Detail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
    <link rel="stylesheet" href="Detail.css" />

    <title>イベント登録画面</title>
</head>
<body>
    <div class="container">
        <%=cCom.CmnDspHeader() %>
        <!--ヘッダーの読み込み-->
        <form id="main" runat="server">
            <div id="FormArea" class="">
                <div id="ButtonArea" class="row mb-3">
                    <div class="col-2 d-grid">
                        <input type="button" id="Savebtn" class="btn btn-outline-primary btn-lg" data-bs-toggle="modal" data-bs-target="#ConfirmModal" value="登録" />
                    </div>
                    <div class="col-2 d-grid">
                        <input type="button" id="Deletebtn" class="btn btn-outline-danger btn-lg" data-bs-toggle="modal" data-bs-target="#ConfirmModal"  value="削除" />
                    </div>
                    <div class="col-6"></div>
                    <div class="col-2 d-grid">
                        <input type="button" id="Backbtn" class="btn btn-outline-secondary btn-lg" data-bs-toggle="modal" data-bs-target="#ConfirmModal"  value="戻る" />
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-3 text-center">
                        <label style="font-weight: bold;">イベント名</label>
                    </div>
                    <div class="col-5">
                        <input type="text" id="txtEventName" class="form-control" maxlength="50" required />
                        <div class="invalid-feedback">
                            <p class="h6">イベント名を入力してください。</p>
                        </div>
                    </div>
                    <div class="col-4"></div>
                </div>
                <div class="row">
                    <div class="col-3 text-center">
                        <label style="font-weight: bold;">ステータス</label>
                    </div>
                    <div class="col-1">
                        <div class="form-check">
                            <input type="radio" id="EventStatusOn" class="Radio form-check-input" name="EventStatus" value="1" />
                            <label for="EventStatusOn" class="h6 form-check-label">オン</label>
                        </div>
                    </div>
                    <div class="col-1">
                        <div class="form-check">
                            <input type="radio" id="EventStatusOff" class="Radio form-check-input" name="EventStatus" value="0" />
                            <label for="EventStatusOff" class="h6 form-check-label">オフ</label>
                        </div>
                    </div>
                    <div class="col-7"></div>
                </div>
                <div class="row">
                    <div class="col-3"></div>
                    <div class="col-9">
                        <p class="h6" style="color: #dc3545" id="Status-invalid-feedback"></p>
                    </div>
                </div>
                <div class="row ">
                    <div class="col-3 text-center">
                        <label style="font-weight: bold;">スケジュール</label>
                    </div>
                    <div class="col-2">
                        <input type="date" class="form-control" id="txtScheduleFm" required />
                    </div>
                    <div class="col-1 text-center">
                        <p class="h6">～</p>
                    </div>
                    <div class="col-2">
                        <input type="date" class="form-control" id="txtScheduleTo" required />
                    </div>
                </div>
                <div class="row" style="margin-top: 4px; margin-bottom: 21px;">
                    <div class="col-3"></div>
                    <div class="col-9">
                        <p class="h6" style="color: #dc3545" id="Schedule-invalid-feedback"></p>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-3 text-center">
                        <label style="font-weight: bold;">キーワード</label>
                    </div>
                    <div class="col-5">
                        <input type="text" id="txtKeyword" class="form-control" maxlength="30" required />
                        <div class="invalid-feedback">
                            <p class="h6">キーワードを入力してください。</p>
                        </div>
                    </div>
                    <div class="col-4"></div>
                </div>
            </div>
            <p class="mt-5 h5">※メッセージは5個まで追加できます</p>
            <div id="MessageArea" class="row">
                <!-- ここにメッセージコンテナが入る-->
            </div>
            <div id="MessagebtnArea" class="row mt-2 mb-2">
                <div class="col-3">
                    <input type="button" id="MessageAddbtn" class="btn btn-primary btn-lg w-100"　data-bs-toggle="modal" data-bs-target="#ConfirmMessageModal" value="メッセージ追加" />
                </div>
                <div class="col-9"></div>
            </div>
        </form>
    </div>
    <div id="ModalArea"></div>
    <div id="MessageModalArea"></div>    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <%="<script src='../../Common/js/Common.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
    <%="<script src='Detail.js?ts=" & cCom.CmnTimeStamp & "'></script>" %>
</body>
</html>
