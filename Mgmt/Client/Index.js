// 最初にログインチェック
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
    selectUserFlg = false;
    nowSearchID = "0";
    beforeSearchID = "0";
    beforeLogID = "0";
    document.getElementById("MessageHeader").innerHTML = '<img id="MessageHeaderImg" class="rounded-circle"/><p id="MessageHeaderName">氏名</p>';
    document.getElementById("MessageBody").innerText = "";
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

                    const TextBreak = document.getElementsByClassName("search-message");
                    for (let SearchMessage of TextBreak) {
                        let previousRect = null;
                        for (let i = 0; i < SearchMessage.firstChild.length; ++i) {
                            const range = new Range();
                            range.setStart(SearchMessage.firstChild, i);
                            range.setEnd(SearchMessage.firstChild, i + 1);
                            const rect = range.getBoundingClientRect();
                            // rect.y が1文字前のものと異なるなら改行されているかも
                            if (previousRect && previousRect.y < rect.y && i > 3) {
                                SearchMessage.innerText = SearchMessage.innerText.slice(0, i - 1) + "...";
                                break;
                            }
                            previousRect = rect;
                        }
                    }

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
function MakeMessageBody(SearchID, scrollUnder = false) {
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
                    const SearchMessage = document.getElementById("Search" + SearchID + "_message");
                    const LineUsers = document.querySelectorAll(".LineUser");
                    for (let LineUser of LineUsers) {
                        if (LineUser.id == "Search" + SearchID) {
                            LineUser.classList.add("SelectUser");
                        }
                        else {
                            LineUser.classList.remove("SelectUser");
                        }
                    }
                    SearchMessage.innerText = data.lastmessage.replace(/\n/g, " ");
                    
                    let previousRect = null;
                    for (let i = 0; i < SearchMessage.firstChild.length; ++i) {
                        const range = document.createRange();
                        range.setStart(SearchMessage.firstChild, i);
                        range.setEnd(SearchMessage.firstChild, i + 1);
                        const rect = range.getBoundingClientRect();
                        // rect.y が1文字前のものと異なるなら改行されているかも
                        if (previousRect && previousRect.y < rect.y && i > 3) {
                            SearchMessage.innerText = SearchMessage.innerText.slice(0, i - 1) + "...";
                            break;
                        }
                        previousRect = rect;
                    }
                    if (beforeSearchID == nowSearchID) {
                        MessageBody.scrollTop = scrollPosition;
                        if (data.lastlogid != beforeLogID) {
                            const name = document.getElementById("MessageHeaderName").innerText;
                            const MessageFooter = document.getElementById("MessageFooter");
                            MessageFooter.innerText = name + ":" + data.lastusermessage.replace(/\n/g, " ");
                            
                            let previousRect = null;
                            for (let i = 0; i < MessageFooter.firstChild.length; ++i) {
                                const range = document.createRange();
                                range.setStart(MessageFooter.firstChild, i);
                                range.setEnd(MessageFooter.firstChild, i + 1);
                                const rect = range.getBoundingClientRect();
                                // rect.y が1文字前のものと異なるなら改行されているかも
                                if (previousRect && previousRect.y < rect.y && i > 3) {
                                    MessageFooter.innerText = MessageFooter.innerText.slice(0, i - 1) + "...";
                                    break;
                                }
                                previousRect = rect;
                            }

                            document.getElementById("MessageFooter").style.buttom = document.getElementById("MessageFooter").offsetHeight / 2 + "px";
                            document.querySelector("#MessageBody").addEventListener("scroll", function () {
                                const LastUserMessage = $(".UserMessage:last");
                                target_position = LastUserMessage.position().top + 7;
                                if (MessageBody.offsetHeight >= target_position) {
                                    document.getElementById("MessageFooter").innerText = "";
                                    beforeLogID = data.lastlogid;
                                }
                            }, true);
                            document.querySelector("#MessageFooter").addEventListener("click", function () {
                                MessageBody.scrollTo(0, MessageBody.scrollHeight);
                                beforeLogID = data.lastlogid;
                            })
                        }
                    }
                    else {
                        MessageBody.scrollTo(0, MessageBody.scrollHeight);
                        beforeLogID = data.lastlogid;
                    }
                    if (scrollUnder) {
                        MessageBody.scrollTo(0, MessageBody.scrollHeight);
                    }
                    beforeSearchID = nowSearchID;
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
                    MakeMessageBody(nowSearchID, true);
                    docTxtPushMessage.value = "";
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

// Setinterbalでメッセージボックス更新(5s)
const timer = setInterval(function () {
    if (nowSearchID != "0") {
        MakeMessageBody(nowSearchID);
    }
}, 5000);
