// global変数
let Ajax_File = "Index.ashx";

const docBtnPushMessage = document.getElementById("btnPushMessage");
docBtnPushMessage.disabled = true;
const docTxtPushMessage = document.getElementById("txtPushMessage");
let selectUserFlg = false;
let nowSearchID;

// ボタンクリック時の関数
$(function () {
    document.getElementById("btnSearch").addEventListener("mouseup", btnSearchClick, false);
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
                            MakeMessageBody(LineUser.id);
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
            "SearchID": SearchID.slice(6)
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    document.getElementById("MessageBox").innerHTML = data.html;
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

                }
            }
        }
    })
}

docTxtPushMessage.addEventListener("keyup", function () {
    if (docTxtPushMessage.value != "" && selectUserFlg) {
        docBtnPushMessage.disabled = false;
        docBtnPushMessage.classList.remove("disabled");
        docBtnPushMessage.classList.add("btn-outline-primary");
    }
    else {
        docBtnPushMessage.disabled = true;
        docBtnPushMessage.classList.add("disabled");
        docBtnPushMessage.classList.remove("btn-outline-primary");
    }
})