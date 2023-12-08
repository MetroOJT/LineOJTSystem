// 最初にログインチェック
function_login_check();

// 担当者名表示
DspLoginUserName();

let dMinDate = LowerLimitDate;
let dMaxDate = UpperLimitDate;
CmnFlatpickr("txtScheduleFm", "txtScheduleTo", dMinDate, dMaxDate, false);

// global変数
let Ajax_File = "Index.ashx";
let AccordionOpenFlg = true;
let NowPage = 1;
let CountOfHit = 0;

// 初期検索
Search();

// ボタンクリック時の関数
$(function () {
    document.getElementById("btnSearch").addEventListener("mouseup", btnSearchClick, false);
    document.getElementById("btnBack").addEventListener("mouseup", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("mouseup", btnCloseClick, false);
    document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
});

// 検索ボタンクリック
function btnSearchClick() {
    NowPage = 1;
    document.cookie = "EventNowPage=" + NowPage + "; max-age=86,400; path=/";
    Search();
};

// 検索処理
function Search() {
    // 入力値取得
    let EventName = $("#txtEventName").val();
    let EventStatus = $("#EventStatus").val();
    let ScheduleFm = $("#txtScheduleFm").val();
    let ScheduleTo = $("#txtScheduleTo").val();
    let Keyword = $("#txtKeyword").val();

    // スケジュールのFrom,Toを正す
    if (ScheduleFm != "" && ScheduleTo != "") {
        if (ScheduleFm > ScheduleTo) {
            let work = ScheduleFm;
            ScheduleFm = ScheduleTo;
            ScheduleTo = work;
            $("#txtScheduleFm").val(ScheduleFm);
            $("#txtScheduleTo").val(ScheduleTo);
        };
    };

    // 非同期通信でデータベース検索
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "EventName": EventName,
            "EventStatus": EventStatus,
            "ScheduleFm": ScheduleFm,
            "ScheduleTo": ScheduleTo,
            "Keyword": Keyword
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        CountOfHit = data.count;
                        MakeItiran();
                    } else {
                        document.getElementById("CntArea").innerText = "";
                        document.getElementById("PageNationArea").innerText = "";
                        document.getElementById("ItiranArea").innerText = "該当するイベントが存在しません。";
                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
}

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
    document.getElementById("txtEventName").value = "";
    document.getElementById("EventStatus").options[0].selected = true;
    document.getElementById("txtScheduleFm").value = "";
    document.getElementById("txtScheduleTo").value = "";
    document.getElementById("txtKeyword").value = "";
    //document.getElementById("CntArea").innerText = "";
    //document.getElementById("PageNationArea").innerText = "";
    //document.getElementById("ItiranArea").innerText = "";
    //$.ajax({
    //    url: Ajax_File,
    //    method: "POST",
    //    data: {
    //        "mode": "Clear",
    //    },
    //    dataType: "json",
    //    success: function (data) {
    //        if (data != "") {
    //            if (data.status == "OK") {
    //                modalChange("クリア結果通知", "クリア完了しました。", "none", "none");
    //            } else {
    //                modalChange("クリア結果通知", "エラーが発生しました。", "none", "none");
    //            };
    //        };
    //    }
    //});
};

// 一覧を生成
function MakeItiran() {
    // CookieにNowPageが存在しない場合の初期値
    NowPage = 1;

    document.getElementById("CntArea").innerText = "";
    document.getElementById("PageNationArea").innerText = "";
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
                    if (data.NowPage) {
                        NowPage = data.NowPage;
                    }
                    // CookieにNowPageが存在し、そのページが表示できる場合
                    if (data.NowPage && CountOfHit > (data.NowPage - 1) * 10) {
                        PagiNation("pi" + data.NowPage);
                    }
                    else {
                        document.cookie = "EventNowPage=" + NowPage + "; max-age=86400; path=/";
                        // 何件目～何件目を計算
                        const NowPageFm = (parseInt(NowPage) - 1) * 10 + 1;
                        let NowPageTo = 0;
                        if (NowPage == Math.ceil(CountOfHit / 10)) {
                            NowPageTo = CountOfHit;
                        } else {
                            NowPageTo = parseInt(NowPage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + CountOfHit + "件" + " (表示中: " + NowPage + " ページ , " + NowPageFm + "件 ～ " + NowPageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("PageNationArea").innerHTML = data.PageNationHTML;
                            document.getElementById("ItiranArea").innerHTML = data.html;

                            // .page-itemに関数を与える
                            const page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                if (!pi.classList.contains('disabled')) {
                                    pi.addEventListener('click', function () {
                                        PagiNation(pi.id);
                                    });
                                }
                            });
                        };
                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// ページ遷移ボタンの処理
function PagiNation(pid) {

    if (pid == "pi") {
        document.getElementById("error_modal").click();
        return false;
    }
    // 表示するページを求める
    switch (pid) {
        case "pista":
            NowPage = 1;
            break;
        case "piback":
            if (NowPage > 1) {
                NowPage -= 1;
                break;
            }
        case "pinext":
            if (NowPage < Math.ceil(CountOfHit / 10)) {
                NowPage += 1;
                break;
            }
        case "piend":
            NowPage = Math.ceil(CountOfHit / 10);
            break;
        default:
            NowPage = parseInt(pid.slice(2));
            if (NowPage == 0) {
                NowPage = 1;
            }
            break;
    }
    
    
    // ページの中身を取得
    if (NowPage != "") {
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                "mode": "PagiNation",
                "nowpage": NowPage
            },
            dataType: "json",
            success: function (data) {
                if (data != "") {
                    if (data.status == "OK") {
                        if (data.NowPage) {
                            NowPage = data.NowPage;
                        }
                        // 何件目～何件目を計算
                        const NowPageFm = (parseInt(NowPage) - 1) * 10 + 1;
                        var NowPageTo = 0;
                        if (NowPage == Math.ceil(CountOfHit / 10)) {
                            NowPageTo = CountOfHit;
                        } else {
                            NowPageTo = parseInt(NowPage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + CountOfHit + "件" + " (表示中: " + NowPage + " ページ , " + NowPageFm + "件 ～ " + NowPageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("PageNationArea").innerHTML = data.PageNationHTML;
                            document.getElementById("ItiranArea").innerHTML = data.html;
                            // .page-itemに関数を与える
                            const page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                if (!pi.classList.contains('disabled')) {
                                    pi.addEventListener('click', function () {
                                        PagiNation(pi.id);
                                    });
                                }
                            });
                        }
                    } else {
                        alert(data.status);
                    }
                }
            }
        });
    }
    else {
        document.getElementById("error_modal").click();
    }
};

// 戻るボタンの処理
function btnBackClick() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Clear"
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    location.href = "../Menu/Index.aspx";
                }
            }
        }
    })
};

// 閉じるボタンの処理
function btnCloseClick() {
    const cola = document.getElementById("cola");
    const colb = document.getElementById("colb");
    if (AccordionOpenFlg) {
        AccordionOpenFlg = false;
        cola.classList.remove("col-10");
        cola.classList.add("col-8");
        colb.classList.remove("col-2");
        colb.classList.add("col-4");
        document.getElementById("btnClose").textContent = "検索する際はこちらのボタンをクリックしてください";
    } else {
        AccordionOpenFlg = true;
        cola.classList.remove("col-8");
        cola.classList.add("col-10");
        colb.classList.remove("col-4");
        colb.classList.add("col-2");
        document.getElementById("btnClose").textContent = "閉じる";
    }
}

// ページ検索
function PageNumber_Search() {
    const PageNumber = document.getElementById("PageNumber").value;
    if (PageNumber == "") {
        document.getElementById("error_modal").click();
    } else {
        PagiNation("pi" + PageNumber);
    }
}

// EventIDをセッションに
function EventIdToSession(EventID) {
    sessionStorage.setItem("EventID", EventID);
}

