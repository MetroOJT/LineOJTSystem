// ＜jsの最初に追加＞
function_login_check();
DspLoginUserName();

const uid = sessionStorage.getItem("UserID");
const u_admin = sessionStorage.getItem("Admin");
const u_name = sessionStorage.getItem("UserName");

var Ajax_File = "Index.ashx"
var Nod = 0; // 検索に引っかかった件数
var Npage = 1; // ページ設定
var page_item = document.querySelectorAll(".page-item");
var detail_button = document.querySelectorAll(".btnDetail");

// 通信ログ検索
function btnSearchClick() {
    Search();
}

// 通信ログクリア
function btnClearClick() {
    const initial_time = document.querySelectorAll(".initial-time");
    initial_time.forEach(it => {
        it.value = "";
    })
    const Sere_select = document.getElementById("Sere");
    const Status_select = document.getElementById("Status");
    const Order_select = document.getElementById("Order");
    Sere_select.options[0].selected = true;
    Status_select.options[0].selected = true;
    Order_select.options[0].selected = true;

}

// 戻る
function btnBackClick() {
    window.location = "../Menu/Index.aspx";
}

var oac = 1; // アコーディオン[開:1,閉:0]
// 閉じる
function btnCloseClick() {
    const cona = document.getElementById("cona");
    const conb = document.getElementById("conb");
    if (oac == 1) {
        oac = 0;        
        cona.classList.remove("col-10");
        cona.classList.add("col-8");
        conb.classList.remove("col-2");
        conb.classList.add("col-4");
        document.getElementById("btnClose").textContent = "検索する際はこちらのボタンをクリックしてください";
    } else {
        oac = 1;
        cona.classList.remove("col-8");
        cona.classList.add("col-10");
        conb.classList.remove("col-4");
        conb.classList.add("col-2");
        document.getElementById("btnClose").textContent = "閉じる";
    }
}

function Search() {
    let SendRecv = $("#txtSendRecv").val();
    let StatusNumber = $("#txtStatusNumber").val();
    let Log = $("#txtLog").val();
    let DateTime = $("#txtDateTime").val();
    let DateFm = document.getElementById("DateFm").value; // 通信時間(前)
    let DateTo = document.getElementById("DateTo").value; // 通信時間(後)
    let Sere = document.getElementById("Sere").value; // 送信,受信
    let Status = document.getElementById("Status").value; // ステータス
    let Order = document.getElementById("Order").value; // 並べ替え

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "SendRecv": SendRecv,
            "StatusNumber": StatusNumber,
            "Log": Log,
            "DateTime": DateTime,
            "DateFm": DateFm,
            "DateTo": DateTo,
            "Sere": Sere,
            "Status": Status,
            "Order": Order
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    Nod = data.count;
                    MakeResult();
                } else {
                    alert(data.status);
                };
            };
        }
    });
}

// ページネーション
function PagiNation(pid) {
    switch (pid) { 
        case "pista":
            Npage = 1;
            break;
        case "piback":
            if (Npage > 1) {
                Npage -= 1;
                break;
            }
        case "pi1":
            Npage = 1;
            break;
        case "pi2":
            Npage = 2;
            break;
        case "pi3":
            Npage = 3;
            break;
        case "pinext":
            if (Npage < Math.ceil(Nod / 10)) {
                Npage += 1;
                break;
            }
        case "piend":
            Npage = Math.ceil(Nod / 10);
            break;
        default:
            Npage = pid;
            break;  
    }

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "PagiNation",
            "nowpage": Npage
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        if (Npage > data.count / 10) {
                            Npage = Math.ceil(data.count / 10);
                        }
                        const NpageFm = (parseInt(Npage) - 1) * 10 + 1; // 件数表示(前)
                        var NpageTo = 0; // 件数表示(後)
                        if (Npage == Math.ceil(data.count / 10)) {
                            NpageTo = data.count;
                        } else {
                            NpageTo = parseInt(Npage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("ResultArea").innerHTML = data.html;
                            document.getElementById("PageNumber").value = Npage;
                            detail_btn();
                        }
                    } else {
                        document.getElementById("PNArea").innerHTML = "";
                        document.getElementById("ResultArea").innerText = "該当するユーザーが存在しません。";
                    }
                } else {
                    alert(data.status);
                }
            }
        }
    });
};

// 検索結果表示
function MakeResult() {
    Npage = 1;

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
                        const NpageFm = (parseInt(Npage) - 1) * 10 + 1;
                        var NpageTo = 0;
                        if (Npage == Math.ceil(data.count / 10)) {
                            NpageTo = data.count;
                        } else {
                            NpageTo = parseInt(Npage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("PNArea").innerHTML = data.pnlist;
                            document.getElementById("ResultArea").innerHTML = data.html;
                            page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                pi.addEventListener('click', function () {
                                    PagiNation(pi.id);
                                });
                            });
                            detail_btn();
                        }
                    } else {
                        document.getElementById("CntArea").innerText = "";
                        document.getElementById("PNArea").innerHTML = "";
                        document.getElementById("ResultArea").innerText = "該当するユーザーが存在しません。";
                    }
                } else {
                    alert(data.status);
                }
            }
        }
    });
};

// 通信ログ詳細画面遷移
function detail_btn(){
    detail_button = document.querySelectorAll(".btnDetail");
    detail_button.forEach(elm => {
        elm.addEventListener('click', function () {
            const elmrow = (parseInt(elm.id.replace("detail", "")) - 1) % 10 + 1;
            const tb = document.getElementById("table");
            const tds = tb.rows[elmrow].querySelectorAll("td");
            const ary = [];
            tds.forEach(td_elm => {
                if (td_elm.querySelector("input")) {
                } else {
                    ary.push(td_elm.innerHTML);
                }
            })
            sessionStorage.setItem("DD_Sere", ary[0].replace("&nbsp;", ""));
            sessionStorage.setItem("DD_Status", ary[1]);
            sessionStorage.setItem("DD_Log", ary[2].replace("&nbsp;", ""));
            sessionStorage.setItem("DD_Time", ary[3]);
            location.href = "../CommLog/Detail.aspx?" + elm.id;
        });
    });
}

// エンターキー無効
function NoEnter() {
    if (window.event.keyCode == 13) {
        return false;
    }
}

// ページ検索
function PageNumber_Search() {
    const PageNumber = document.getElementById("PageNumber").value;
    if (PageNumber == "") {
        document.getElementById("error_modal").click();
    } else {
        PagiNation(parseInt(PageNumber));
    }
}

$(function () {
    document.getElementById("btnSearch").addEventListener("click", btnSearchClick, false);
    document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("click", btnCloseClick, false);
});