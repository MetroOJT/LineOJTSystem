﻿// 最初にログインチェック
function_login_check();

// 担当者名表示
DspLoginUserName();

// global変数
let Ajax_File = "Index.ashx";

const docBtnPushMessage = document.getElementById("btnPushMessage");
docBtnPushMessage.disabled = true;
const docTxtPushMessage = document.getElementById("txtPushMessage");
let selectUserFlg = false;
let nowSearchID = "0";
let beforeSearchID = "0";
let beforeLogID = "0";

// 初期検索
btnSearchClick();

// ボタンクリック時の関数
$(function () {
    document.getElementById("btnSearch").addEventListener("mouseup", btnSearchClick, false);
    document.getElementById("btnBack").addEventListener("mouseup", btnBackClick, false);
    document.getElementById("btnPushMessage").addEventListener("mouseup", btnPushMessageClick, false);
});

// 検索処理
function btnSearchClick() {
    // 入力値取得
    let DisplayName = $("#txtDisplayName").val();

    // 非同期通信でデータベース検索
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "DisplayName": DisplayName
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        MakeItiran();
                    } else {
                        document.getElementById("ItiranArea").innerText = "該当するユーザーが存在しません。";
                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
}

// 一覧を生成
function MakeItiran() {
    document.getElementById("ItiranArea").innerHTML = "";

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Itiran"
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    document.getElementById("ItiranArea").innerHTML = data.html;
                    const LineUsers = document.querySelectorAll(".LineUser");
                    LineUsers.forEach(LineUser => {
                        LineUser.addEventListener("click", function () {
                            MakeMessageBody(LineUser.id.slice(6));
                        })
                    });
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// 一覧クリック
function MakeMessageBody(SearchID) {
    nowSearchID = SearchID;
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "MessageBox",
            "SearchID": SearchID
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    const scrollPosition = document.getElementById("MessageBody").scrollTop;
                    const MessageBox = document.getElementById("MessageBox");
                    MessageBox.innerHTML = data.html;
                    const MessageBody = document.getElementById("MessageBody");
                    if (beforeSearchID == nowSearchID) {
                        MessageBody.scrollTop = scrollPosition;
                        if (data.lastlogid != beforeLogID) {
                            const name = document.getElementById("MessageHeaderName").innerText;
                            document.getElementById("MessageFooter").innerText = name + ":" + data.lastmessage;
                            document.getElementById("MessageFooter").style.buttom = document.getElementById("MessageFooter").offsetHeight / 2 + "px";
                            document.querySelector("#MessageBody").addEventListener("scroll", function () {
                                const LastUserMessage = $(".UserMessage:last");
                                target_position = LastUserMessage.position().top;
                                if (MessageBody.offsetHeight >= target_position) {
                                    document.getElementById("MessageFooter").innerText = "";
                                }
                            }, true);
                            document.querySelector("#MessageFooter").addEventListener("click", function () {
                                MessageBody.scrollTo(0, MessageBody.scrollHeight);
                            })
                        }
                    }
                    else {
                        MessageBody.scrollTo(0, MessageBody.scrollHeight);
                    }
                    beforeSearchID = nowSearchID;
                    beforeLogID = data.lastlogid;
                    selectUserFlg = true;
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

function btnPushMessageClick() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "PushMessage",
            "message": docTxtPushMessage.value,
            "nowSearchID": nowSearchID
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    MakeMessageBody(nowSearchID);
                }
                else {
                    alert("エラーが発生しました。");
                }
            }
        }
    })
}

docTxtPushMessage.addEventListener("keyup", function () {
    if (docTxtPushMessage.value == "" || docTxtPushMessage.value.match(/^[\n| ]+$/) !== null || !selectUserFlg) {
        docBtnPushMessage.disabled = true;
        docBtnPushMessage.classList.add("disabled");
        docBtnPushMessage.classList.remove("btn-outline-primary");
    }
    else {
        docBtnPushMessage.disabled = false;
        docBtnPushMessage.classList.remove("disabled");
        docBtnPushMessage.classList.add("btn-outline-primary");
    }
})

// 戻るボタンの処理
function btnBackClick() {
    location.href = "../Menu/Index.aspx";
};

// inputイベントが発生するたびに関数呼び出し
docTxtPushMessage.addEventListener("input", setTextareaHeight);

// textareaの高さを計算して指定する関数
function setTextareaHeight() {
    this.style.height = "auto";
    this.style.height = `${this.scrollHeight}px`;
}

// Setinterbalでメッセージボックス更新(30s)
const timer = setInterval(function () {
    if (nowSearchID != "0") {
        MakeMessageBody(nowSearchID)
    }
}, 5000);
