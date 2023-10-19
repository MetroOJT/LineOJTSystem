var Ajax_File = "Index.ashx"
var Nod = 0;
var Npage = 1;

// ログアウト
function btnLogOutClick() {
    window.location = "http://localhost:808/LineOJTSystem/Mgmt/Login/Index.aspx";
    console.log("ログアウト");
}

// 通信ログ検索
function btnSearchClick() {
    console.log("通信ログ検索");
    Search();
}

// 通信ログクリア
function btnClearClick() {
    console.log("通信ログクリア");
}

// 戻る
function btnBackClick() {
    console.log("メニュー画面へ遷移");
    window.location = "http://localhost:808/LineSampleSystem/Sample/hirashima/Index.aspx";
}

var oac = 1;
// 閉じる
function btnCloseClick() {
    const cona = document.getElementById("cona");
    const conb = document.getElementById("conb");
    if (oac == 1) {
        oac = 0;        
        cona.classList.remove("col-10");
        cona.classList.add("col-7");
        conb.classList.remove("col-2");
        conb.classList.add("col-5");
        document.getElementById("btnClose").textContent = "検索する際はこちらのボタンをクリックしてください";
    } else {
        oac = 1;
        cona.classList.remove("col-7");
        cona.classList.add("col-10");
        conb.classList.remove("col-5");
        conb.classList.add("col-2");
        document.getElementById("btnClose").textContent = "閉じる";
    }
}

const page_item = document.querySelectorAll(".page-item");
page_item.forEach(pi => {
    pi.addEventListener('click', function () {
        PagiNation(pi.id);
    });
});

const detail_button = document.querySelectorAll(".btnDetail");
detail_button.forEach(elm => {
    elm.addEventListener('click', function () {
        console.log("ててて");
    });
});

function Search() {
    let SendRecv = $("#txtSendRecv").val();
    let StatusNumber = $("#txtStatusNumber").val();
    let Log = $("#txtLog").val();
    let DateTime = $("#txtDateTime").val();

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "SendRecv": SendRecv,
            "StatusNumber": StatusNumber,
            "Log": Log,
            "DateTime": DateTime
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    console.log("検索完了")
                    Nod = data.count;
                    MakeResult();
                } else {
                    console.log("検索エラー")
                    alert(data.status);
                };
            };
        }
    });
}
function PagiNation(pid) {
    console.log(pid);
    switch (pid) {
        case "pista":
            Npage = 1;
            break;
        case "pinext":
            Npage += 1;
            break;
        case "pi1":
            Npage = 1;
            break;
    }
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "PagiNation"
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件";
                        if (data.html != "") {
                            document.getElementById("ResultArea").innerHTML = data.html;
                        }
                    } else {
                        document.getElementById("ResultArea").innerText = "該当するユーザーが存在しません。";
                    }
                } else {
                    alert(data.status);
                }
            }
        }
    });
};

function MakeResult() {
    document.getElementById("CntArea").innerText = "";
    document.getElementById("ResultArea").innerHTML = "";

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "MakeResult"
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件";
                        if (data.html != "") {
                            document.getElementById("ResultArea").innerHTML = data.html;
                        }
                    } else {
                        document.getElementById("ResultArea").innerText = "該当するユーザーが存在しません。";
                    }
                } else {
                    alert(data.status);
                }
            }
        }
    });
};

$(function () {
    document.getElementById("btnLogOut").addEventListener("click", btnLogOutClick, false);
    document.getElementById("btnSearch").addEventListener("click", btnSearchClick, false);
    document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("click", btnCloseClick, false);
});