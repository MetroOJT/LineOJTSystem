// ＜jsの最初に追加＞
function_login_check();
DspLoginUserName();

const uid = sessionStorage.getItem("UserID");
const u_admin = sessionStorage.getItem("Admin");
const u_name = sessionStorage.getItem("UserName");

var Ajax_File = "Index.ashx"
var Nod = 0;
var Npage = 1;
var page_item = document.querySelectorAll(".page-item");
var detail_button = document.querySelectorAll(".btnDetail");

// 通信ログ検索
function btnSearchClick() {
    console.log("通信ログ検索");
    Search();
}

// 通信ログクリア
function btnClearClick() {
    console.log("検索条件を初期値に変更");
    const initial_time = document.querySelectorAll(".initial-time");
    initial_time.forEach(it => {
        it.value = "";
    })
    const Sere_select = document.getElementById("Sere");
    const Status_select = document.getElementById("Status");
    Sere_select.options[0].selected = true;
    Status_select.options[0].selected = true;

}

// 戻る
function btnBackClick() {
    console.log("メニュー画面へ遷移");
    window.location = "../Menu/Index.aspx";
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

function Search() {
    let SendRecv = $("#txtSendRecv").val();
    let StatusNumber = $("#txtStatusNumber").val();
    let Log = $("#txtLog").val();
    let DateTime = $("#txtDateTime").val();
    let DateFm = document.getElementById("DateFm").value;
    let DateTo = document.getElementById("DateTo").value;
    let Sere = document.getElementById("Sere").value;
    let Status = document.getElementById("Status").value;
    console.log(DateFm, DateTo, Sere, Status);

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
            "Status": Status
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
    }
    console.log(Npage);
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
                        const NpageFm = (parseInt(Npage) - 1) * 10 + 1;
                        var NpageTo = 0;
                        if (Npage == Math.ceil(data.count / 10)) {
                            NpageTo = (parseInt(Npage) - 1) * 10 + (data.count % 10);
                        } else {
                            NpageTo = parseInt(Npage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("ResultArea").innerHTML = data.html;
                            detail_btn();
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
                        const NpageFm = (parseInt(Npage) - 1) * 10 + 1;
                        var NpageTo = 0;
                        if (Npage == Math.ceil(data.count / 10)) {
                            NpageTo = (parseInt(Npage) - 1) * 10 + (data.count % 10);
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
                        document.getElementById("ResultArea").innerText = "該当するユーザーが存在しません。";
                    }
                } else {
                    alert(data.status);
                }
            }
        }
    });
};

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

$(function () {
    document.getElementById("btnSearch").addEventListener("click", btnSearchClick, false);
    document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("click", btnCloseClick, false);
});