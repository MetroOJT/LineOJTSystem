//function_login_check();

let Ajax_File = "Index.ashx";
let Npage = 1;
let page_item = document.querySelectorAll(".page-item");
let Nod = 0;

$(function () {
    document.getElementById("btnSearch").addEventListener("mouseup", SearchbtnClick, false);
    //document.getElementById("btnUpdIns").addEventListener("mouseup", btnUpdInsClick, false);
    //document.getElementById("btnDelete").addEventListener("mouseup", btnDeleteClick, false);
    //document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
    document.getElementById("btnBack").addEventListener("mouseup", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("mouseup", btnCloseClick, false);
    //document.getElementById("modalBtnDelete").addEventListener("click", delete_DB, false);
});

// モーダルの内容変更
function modalChange(title, body, BtnDeleteDisplay, BtnClearDisplay) {
    document.getElementById("staticBackdropLabel").innerText = title;
    document.getElementById("modalBody").innerText = body;
    document.getElementById("modalBtnDelete").style.display = BtnDeleteDisplay;
    document.getElementById("modalBtnClear").style.display = BtnClearDisplay;
}

// 検索ボタンクリック
function SearchbtnClick() {

    let Event = $("#txtEvent").val();
    let EventStatus = $("#EventStatus").val();
    let DateFm = $("#txtDateFm").val();
    let DateTo = $("#txtDateTo").val();
    let Keyword = $("#txtKeyword").val();
    let work = "";

    if (DateFm != "" && DateTo != "") {
        if (DateFm > DateTo) {
            work = DateFm;
            DateFm = DateTo;
            DateTo = work;
            $("#txtDateFm").val(DateFm);
            $("#txtDateTo").val(DateTo);
        };
    };

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "Event": Event,
            "EventStatus": EventStatus,
            "ScheduleFm": DateFm,
            "ScheduleTo": DateTo,
            "Keyword": Keyword
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        Nod = data.count;
                        MakeItiran();
                    } else {
                        document.getElementById("CntArea").innerText = ""
                        document.getElementById("ItiranArea").innerText = "該当するイベントが存在しません。";
                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

function btnUpdInsClick() {
    var iLoop = 0;
    var iCnt = 0;
    var sEventID = "";

    for (iLoop = 0; iLoop < document.getElementsByName("chkEvent").length; iLoop++) {
        if (document.getElementsByName("chkEvent")[iLoop].checked) {
            iCnt++;
            sEventID = document.getElementsByName("chkEvent")[iLoop].value;
        };
    };
    if (iCnt == 0 || iCnt == 1) {
        location.href = "Detail.aspx?EventID=" + sEventID;
    } else if (iCnt >= 2) {
        alert("更新を行う際は、複数選択することが出来ません。");
    };
}

// 削除ボタンクリック
function btnDeleteClick() {
    var iLoop = 0;
    var iCnt = 0;
    DelList = "";

    for (iLoop = 0; iLoop < document.getElementsByName("chkEvent").length; iLoop++) {
        if (document.getElementsByName("chkEvent")[iLoop].checked) {
            iCnt++;
            if (DelList != "") DelList = DelList + ",";
            DelList = DelList + document.getElementsByName("chkEvent")[iLoop].value;
        };
    };

    if (iCnt == 0) {
        modalChange("削除実行エラー", "削除するユーザーが選択されていません。", "none", "none");
    } else if (iCnt >= 1) {
        modalChange("再確認", "削除しますか？", "inline", "none");
    };
};

function delete_DB() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Delete",
            "DelList": DelList
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    modalChange("削除結果通知", "削除完了しました。", "none", "none");
                    MakeItiran();
                } else {
                    modalChange("削除結果通知", "エラーが発生しました。", "none", "none");
                };
            };
        }
    });
};

function btnClearClick() {
    document.getElementById("txtEvent").value = "";
    document.getElementById("EventStatus").options[0].selected = true;
    document.getElementById("txtDateFm").value = "";
    document.getElementById("txtDateTo").value = "";
    document.getElementById("txtKeyword").value = "";
    document.getElementById("CntArea").innerText = "";
    document.getElementById("ItiranArea").innerText = "";
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Clear",
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    modalChange("クリア結果通知", "クリア完了しました。", "none", "none");
                } else {
                    modalChange("クリア結果通知", "エラーが発生しました。", "none", "none");
                };
            };
        }
    });
};

function MakeItiran() {
    Npage = 1;
    document.getElementById("CntArea").innerText = "";
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
                    if (Number(data.count) > 0) {
                        const NpageFm = (parseInt(Npage) - 1) * 10 + 1;
                        let NpageTo = 0;
                        if (Npage == Math.ceil(data.count / 10)) {
                            NpageTo = data.count;
                        } else {
                            NpageTo = parseInt(Npage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("PNArea").innerHTML = data.pnlist;
                            document.getElementById("ItiranArea").innerHTML = data.html;
                            page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                pi.addEventListener('click', function () {
                                    PagiNation(pi.id);
                                });
                            });
                        };
                    } else {
                        document.getElementById("ItiranArea").innerText = "該当するユーザーが存在しません。";
                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

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
        case "pinext":
            if (Npage < Math.ceil(Nod / 10)) {
                Npage += 1;
                break;
            }
        case "piend":
            Npage = Math.ceil(Nod / 10);
            break;
        default:
            Npage = parseInt(pid.slice(2));
            break;
    }
    if (Npage != 1) {
        document.getElementById("pista").classList.remove("disabled");
        document.getElementById("piback").classList.remove("disabled");
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
                            document.getElementById("ItiranArea").innerHTML = data.html;
                            page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                pi.addEventListener('click', function () {
                                    PagiNation(pi.id);
                                });
                            });
                        }
                    } else {
                        document.getElementById("PNArea").innerHTML = "";
                        document.getElementById("ItiranArea").innerText = "該当するユーザーが存在しません。";
                    }
                } else {
                    alert(data.status);
                }
            }
        }
    });
};

function btnBackClick() {
    location.href = "../Menu/Index.aspx";
};

oac = 1;

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

