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
let beforeLogIDList = {};

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
    beforeLogIDList = {};
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

// '...'で文字列短縮
function StrShortening(obj) {
    //　初回スルーのためのnull
    let previousRect = null;
    let count = 0;
    //　一文字ずつy座標を比較
    for (let i = 0; i < obj.firstChild.length; ++i) {
        count++;
        const range = document.createRange();
        range.setStart(obj.firstChild, i);
        range.setEnd(obj.firstChild, i + 1);
        const rect = range.getBoundingClientRect();
        // rect.y が1文字前のものと異なるなら改行されている
        if (previousRect && previousRect.y < rect.y) {
            // '...'を改行されないぎりぎりで追加
            for (let j = 1; j < Math.min(4, i); j++) {
                let new_line_flg = false;
                obj.innerText = obj.innerText.slice(0, i - j) + "...";
                let previousRect2 = null;
                // 一文字ずつy座標を比較
                for (let k = 0; k < obj.firstChild.length; ++k) {
                    const range2 = document.createRange();
                    range2.setStart(obj.firstChild, k);
                    range2.setEnd(obj.firstChild, k + 1);
                    const rect2 = range2.getBoundingClientRect();
                    // rect.y が1文字前のものと異なるなら改行されている
                    if (previousRect2 && previousRect2.y < rect2.y) {
                        new_line_flg = true;
                        break;
                    }
                    previousRect2 = rect2;
                }
                // 改行がなくなったら抜ける
                if (!new_line_flg) {
                    break;
                }
            }
            break;
        }
        previousRect = rect;
    }
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
                    beforeLogIDList = data.beforelogidlist;
                    document.getElementById("ItiranArea").innerHTML = data.html;

                    // 一覧内のメッセージの表記を1行に
                    const SearchMessages = document.querySelectorAll(".search-message");
                    for (let SearchMessage of SearchMessages) {
                        StrShortening(SearchMessage);
                    }
                    // 一覧にクリックイベント追加
                    const LineUsers = document.querySelectorAll(".LineUser");
                    LineUsers.forEach(LineUser => {
                        LineUser.addEventListener("click", function () {
                            document.getElementById(LineUser.id).firstChild.classList.add("hidden");
                            MakeMessageBody(LineUser.id.slice(6), undefined, fromclick = true);
                        })
                    });
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// メッセージボディ作成
//  scrollUnder:プッシュメッセージ送信と、一覧クリックの場合true,
//  fromclick:一覧クリックの場合true
function MakeMessageBody(SearchID, scrollUnder = false, fromclick = false) {
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
                    // 一覧クリックからなら、通知を表示しない
                    if (fromclick) {
                        beforeLogIDList[nowSearchID] = data.lastlogid;
                        checkLogUpd(nowSearchID);
                    }
                    const scrollPosition = document.getElementById("MessageBody").scrollTop;
                    const MessageBox = document.getElementById("MessageBox");
                    MessageBox.innerHTML = data.html;
                    const MessageBody = document.getElementById("MessageBody");
                    const SearchMessage = document.getElementById("Search" + SearchID + "_message");
                    // 選択されたユーザーの背景色を変更
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
                    
                    StrShortening(SearchMessage);
                    if (beforeSearchID == nowSearchID) {
                        MessageBody.scrollTop = scrollPosition;
                        // SearchIDがそのままで、ログが変わるとフッター(通知)を表示
                        if (data.lastlogid != beforeLogIDList[nowSearchID]) {
                            const name = document.getElementById("MessageHeaderName").innerText;
                            const MessageFooter = document.getElementById("MessageFooter");
                            MessageFooter.innerText = name + ":" + data.lastusermessage.replace(/\n/g, " ");
                            
                            StrShortening(MessageFooter);

                            document.getElementById("MessageFooter").style.buttom = document.getElementById("MessageFooter").offsetHeight / 2 + "px";
                            // 画面に最新ログが見えたら、フッター(通知)削除
                            document.querySelector("#MessageBody").addEventListener("scroll", function () {
                                const LastUserMessage = $(".UserMessage:last");
                                target_position = LastUserMessage.position().top + 7;
                                if (MessageBody.offsetHeight >= target_position) {
                                    document.getElementById("MessageFooter").innerText = "";
                                    beforeLogIDList[nowSearchID] = data.lastlogid;
                                    checkLogUpd(nowSearchID);
                                    document.getElementById("Search" + SearchID).firstChild.classList.remove("hidden");
                                }
                            }, true);
                            // MessageFooterクリック時、フッター削除と一番下にスクロール
                            document.querySelector("#MessageFooter").addEventListener("click", function () {
                                MessageBody.scrollTo(0, MessageBody.scrollHeight);
                                beforeLogIDList[nowSearchID] = data.lastlogid;
                                checkLogUpd(nowSearchID);
                                document.getElementById("Search" + SearchID).firstChild.classList.remove("hidden");
                            })
                        }
                    }
                    else {
                        // 選択ユーザが変わった場合
                        MessageBody.scrollTo(0, MessageBody.scrollHeight);
                        beforeLogIDList[nowSearchID] = data.lastlogid;
                        checkLogUpd(nowSearchID);
                    }
                    // プッシュメッセージと一覧クリックの場合
                    if (scrollUnder) {
                        MessageBody.scrollTo(0, MessageBody.scrollHeight);
                    }
                    beforeSearchID = nowSearchID;
                    selectUserFlg = true;
                    // 送信ボタンを押せるようにするため
                    PushMessageKeyUp();
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// 更新チェック(緑点の表示)
function checkLogUpd(SearchID) {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "GetLastLog",
            "SearchID": SearchID
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (beforeLogIDList[SearchID] != data.lastlogid && nowSearchID != SearchID) {
                        // 新規ログがあり、現在選択中のユーザーではない場合
                        document.getElementById("Search" + SearchID).firstChild.classList.remove("hidden");
                        const SearchMessage = document.getElementById("Search" + SearchID + "_message");
                        SearchMessage.innerText = data.lastmessage.replace(/\n/g, " ");
                    
                        StrShortening(SearchMessage);
                    }
                    else {
                        document.getElementById("Search" + SearchID).firstChild.classList.add("hidden");
                    }
                }
                else {
                    alert("エラーが発生しました。");
                }
            }
        }
    })
}

// 送信ボタンクリック
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
                    beforeLogIDList[nowSearchID] = data.lastlogid;
                    checkLogUpd(nowSearchID);
                }
                else {
                    alert("エラーが発生しました。");
                }
            }
        }
    })
}

// 送信ボタンが押せるかを制御
docTxtPushMessage.addEventListener("keyup", PushMessageKeyUp);
function PushMessageKeyUp(){
    // ブランク、空白改行のみ、ユーザー未選択の場合、非活性
    if (docTxtPushMessage.value == "" || docTxtPushMessage.value.match(/^[\n| |　]+$/) !== null || !selectUserFlg) {
        docBtnPushMessage.disabled = true;
        docBtnPushMessage.classList.add("disabled");
        docBtnPushMessage.classList.remove("btn-primary");
    }
    else {
        docBtnPushMessage.disabled = false;
        docBtnPushMessage.classList.remove("disabled");
        docBtnPushMessage.classList.add("btn-primary");
    }
}

// 戻るボタンの処理
function btnBackClick() {
    location.href = "../Menu/Index.aspx";
};

// テキストエリアの高さ自動調整(最大4行,それ以上はスクロール)
docTxtPushMessage.addEventListener("input", setTextareaHeight);

function setTextareaHeight() {
    this.style.height = "auto";
    this.style.height = `${this.scrollHeight}px`;
}

// Setinterbalでメッセージボックス更新,新規ログ確認(5s)
const timer = setInterval(function () {
    for (let key in beforeLogIDList) {
        checkLogUpd(key);
    }
    if (nowSearchID != "0") {
        MakeMessageBody(nowSearchID);
    }
}, 5000);
