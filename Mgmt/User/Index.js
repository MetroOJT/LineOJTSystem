﻿//ログインなされているかをチェックする関数
function_login_check();
DspLoginUserName();

var Ajax_File = "Index.ashx";

var StyleBold = 1; // 現在表示しているページの強調

var oac = 1; // アコーディオン[開:1,閉:0]
var Nod = 0; // 検索に引っかかった件数
var TotalPage = 0; // 全体ページ
var NowPage = 0; // 表示ページ
var page_item = document.querySelectorAll(".page-item");
var detail_button = document.querySelectorAll(".btnDetail");
var SearchPage = 1;
var GetLogNowPage = "";
if (getCookie("LogNowPage") != "") {
    GetLogNowPage = getCookie("LogNowPage");
}

var PageMedian = 2; // ページャの中央値 [ 1 , ② , 3 ]

window.onload = function () {
    $.datepicker.setDefaults({
        showButtonPanel: "true",
        changeMonth: "true",
        changeYear: "true",
        minDate: new Date(1900, 1, 1),
        maxDate: new Date(),
    });

    let fm = $("#DateFm").datepicker({
        onSelect: function (selectedDate) {
            $("#DateTo").datepicker("option", "minDate", selectedDate);
        }
    });

    let to = $("#DateTo").datepicker({
        onSelect: function (selectedDate) {
            $("#DateFm").datepicker("option", "maxDate", selectedDate);
        }
    });

    // 初期検索
    Search("Yes");
}


function btnSearchClick() {
    SearchPage = 1;
    document.cookie = document.cookie = "LogNowPage=" + 0 + "; max-age=86400; path=/";
    Search();
}

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
};

$(function () {
    document.getElementById("btnSearch").addEventListener("click", btnSearchClick, false);
    document.getElementById("btnSign_up").addEventListener("click", btnSignUpClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("click", btnCloseClick, false);
    document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
});

// 検索ボタンが押された時の処理
function Search(first_flag) {
    var User_ID = $("#user_ID").val();
    var User_Name = $("#user_Name").val();
    var Admin_Check = $("#Kanrisya").val();
    var Date_Fm = $("#DateFm").val();
    var Date_To = $("#DateTo").val();
    var w;

    if (Date_Fm > Date_To) {
        w = Date_Fm;
        Date_Fm = Date_To;
        Date_To = w;

        document.querySelector("#DateFm").value = Date_Fm;
        document.querySelector("#DateTo").value = Date_To;
    }

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "User_ID": User_ID,
            "User_Name": User_Name,
            "Admin_Check": Admin_Check,
            "DateFm": Date_Fm,
            "DateTo": Date_To,
            "First_Flag": first_flag
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    Nod = data.count; // 検索ヒット数
                    TotalPage = Math.ceil(Nod / 10); // ページの最大値
                    if (first_flag == "Yes") {
                        let PagerID = 1;
                        if (data.SearchPage != null) {
                            PagerID = data.SearchPage
                        }
                        MakeUserTable(PagerID);
                    } else {
                        MakeUserTable(1); // 初期検索・検索(1ページ目を強制表示)
                    }
                } else {
                    alert(data.status);
                };
            };
        }
    });
}
function MakeUserTable(PagerID){
    if (PagerID != "") {
        switch (PagerID) {
            case "pista":
                SearchPage = 1;
                break;
            case "piback":
                SearchPage = Number(NowPage) - 1;
                PageMedian = SearchPage;
                break;
            case "pi1": // 現在表示しているページの１つ前
                SearchPage = Number(PageMedian) - 1;
                PageMedian = SearchPage;
                break;
            case "pi2":
                SearchPage = PageMedian;
                PageMedian = SearchPage;
                break;
            case "pi3": // 現在表示しているページの１つ後
                SearchPage = Number(PageMedian) + 1;
                if (SearchPage == TotalPage) {
                    PageMedian = Number(SearchPage) - 1;
                } else {
                    PageMedian = SearchPage;
                }
                break;
            case "pinext":
                if (NowPage < TotalPage) {
                    SearchPage = Number(NowPage) + 1;
                }
                if (SearchPage == TotalPage) {
                    PageMedian = Number(SearchPage) - 1;
                } else {
                    PageMedian = SearchPage;
                }
                break;
            case "piend":
                SearchPage = TotalPage;
                PageMedian = Number(SearchPage) - 1;
                break;
            default:
                SearchPage = PagerID;
                PageMedian = SearchPage;
                if (SearchPage <= 1 || Nod < 31) {
                    PageMedian = 2;
                } else if (SearchPage >= TotalPage) {
                    PageMedian = Number(TotalPage) - 1;
                }
                break;
        }
        if (SearchPage == 1 || Nod < 31) {
            PageMedian = 2;
        }
        PageID = "";
    } else {
        SearchPage = 1;
    }
    if (PagerID == 0) {
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: { // モード, 表示したいページ, ページャの中央値
                "mode": "MakeUserTable",
                "searchpage": SearchPage,
                "pagemedian": PageMedian,
                "Cookie_hantei": 1
            },
            dataType: "json",
            success: function (data) {
                if (data != "") {
                    if (data.status == "OK") { // エラーの有無
                        if (Nod > 0) { // 検索ヒット数が1以上であれば検索結果表示
                            NowPage = data.AshxNowPage;
                            document.cookie = "LogNowPage=" + NowPage + "; max-age=86400; path=/";
                            const NowPageFm = (NowPage - 1) * 10 + 1;
                            var NowPageTo = NowPage * 10;

                            if (NowPageTo > Nod) {
                                NowPageTo = Nod;
                            }
                            document.getElementById("CntArea").innerText = "件数：" + Nod + "件" + " (表示中: " + NowPage + " / " + TotalPage + " ページ , " + NowPageFm + "件 ～ " + NowPageTo + "件)";

                            if (data.html != "") {
                                document.getElementById("PNArea").innerHTML = data.pnlist;
                                document.getElementById("ResultArea").innerHTML = data.html;

                                if (NowPage == 1 || Nod < 31) { // 表示ページが1またはヒット数が30件以下でボタンを押下できなくする
                                    document.querySelector("#pista a").classList.add("disabled");
                                    document.getElementById("pista").style.pointerEvents = "none";
                                    document.querySelector("#piback a").classList.add("disabled");
                                    document.getElementById("piback").style.pointerEvents = "none";
                                }
                                if (NowPage == TotalPage || Nod < 31) { // 表示ページが最後またはヒット数が30件以下でボタンを押下できなくする
                                    document.querySelector("#pinext a").classList.add("disabled");
                                    document.getElementById("pinext").style.pointerEvents = "none";
                                    document.querySelector("#piend a").classList.add("disabled");
                                    document.getElementById("piend").style.pointerEvents = "none";
                                }
                                transition(); // 詳細ボタンのid振り分け
                            }
                        } else {
                            document.getElementById("CntArea").innerText = "";
                            document.getElementById("PNArea").innerHTML = "";
                            document.getElementById("ResultArea").innerText = "該当するデータが存在しませんでした。";
                        }
                    } else {
                        alert(data.status);
                    }
                }
            }
        });
    } else {
        // 検索結果表示
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: { // モード, 表示したいページ, ページャの中央値
                "mode": "MakeUserTable",
                "searchpage": SearchPage,
                "pagemedian": PageMedian
            },
            dataType: "json",
            success: function (data) {
                if (data != "") {
                    if (data.status == "OK") { // エラーの有無
                        if (Nod > 0) { // 検索ヒット数が1以上であれば検索結果表示
                            NowPage = data.AshxNowPage;
                            document.cookie = "LogNowPage=" + NowPage + "; max-age=86400; path=/";
                            const NowPageFm = (NowPage - 1) * 10 + 1;
                            var NowPageTo = NowPage * 10;

                            if (NowPageTo > Nod) {
                                NowPageTo = Nod;
                            }
                            document.getElementById("CntArea").innerText = "件数：" + Nod + "件" + " (表示中: " + NowPage + " / " + TotalPage + " ページ , " + NowPageFm + "件 ～ " + NowPageTo + "件)";

                            if (data.html != "") {
                                document.getElementById("PNArea").innerHTML = data.pnlist;
                                document.getElementById("ResultArea").innerHTML = data.html;

                                if (NowPage == 1 || Nod < 11) { // 表示ページが1またはヒット数が30件以下でボタンを押下できなくする
                                    if (document.querySelector("#pista a")) {
                                        document.querySelector("#pista a").classList.add("disabled");
                                    }
                                    if (document.getElementById("pista")) {
                                        document.getElementById("pista").style.pointerEvents = "none";
                                    }
                                    if (document.querySelector("#piback a")) {
                                        document.querySelector("#piback a").classList.add("disabled");
                                    }
                                    if (document.getElementById("piback")) {
                                        document.getElementById("piback").style.pointerEvents = "none";
                                    }
                                }
                                if (NowPage == TotalPage || Nod < 11) { // 表示ページが最後またはヒット数が30件以下でボタンを押下できなくする
                                    if (document.querySelector("#pinext a")) {
                                        document.querySelector("#pinext a").classList.add("disabled");
                                    }
                                    if (document.getElementById("pinext")) {
                                        document.getElementById("pinext").style.pointerEvents = "none";
                                    }
                                    if (document.querySelector("#piend a")) {
                                        document.querySelector("#piend a").classList.add("disabled");
                                    }
                                    if (document.getElementById("piend")) {
                                        document.getElementById("piend").style.pointerEvents = "none";
                                    }
                                }
                                transition(); // 詳細ボタンのid振り分け
                            }
                        } else {
                            document.getElementById("CntArea").innerText = "";
                            document.getElementById("PNArea").innerHTML = "";
                            document.getElementById("ResultArea").innerText = "該当するデータが存在しませんでした。";
                        }
                    } else {
                        alert(data.status);
                    }
                }
            }
        });
    }
};

// ユーザー登録画面遷移
function transition() {
    transition_element = document.querySelectorAll(".UserName");
    transition_element.forEach(elm => {
        elm.addEventListener('click', function () {
            const UserName = elm.innerHTML;
            const id_number = elm.id.replace("UserName", "");
            const hUserID = document.querySelector(`#UserID${id_number}`).textContent;
            
            sessionStorage.setItem("hUserID", hUserID);
            location.href = "Detail.aspx";
        });
    });
}

// 新規登録ボタンが押された時の処理
function btnSignUpClick() {
    window.location.href = "Detail.aspx";
};

// 戻るボタンが押された時の処理
function btnBackClick() {
    // クッキーの情報を削除したい
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
                    window.location.href = "../Menu/Index.aspx";
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// クリアボタンが押された時の処理
function btnClearClick() {
    document.querySelector("#user_ID").value = "";
    document.querySelector("#user_Name").value = "";
    document.querySelector("#DateFm").value = "";
    document.querySelector("#DateTo").value = "";
    document.querySelector("#kanrisya_all").selected = true;
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
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
}

// エンターキー無効
function NoEnter() {
    if (window.event.keyCode == 13) {
        return false;
    }
};

// ページ検索
function PageNumber_Search() {
    const PageNumber = document.getElementById("PageNumber").value;
    if (PageNumber == "") {
        document.getElementById("error_modal").click();
    } else {
        PagiNation(parseInt(PageNumber));
    }
};
