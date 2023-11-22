// ＜jsの最初に追加＞
function_login_check();
DspLoginUserName();

const uid = sessionStorage.getItem("UserID");
const u_admin = sessionStorage.getItem("Admin");
const u_name = sessionStorage.getItem("UserName");

var Ajax_File = "Index.ashx"
var Nod = 0; // 検索に引っかかった件数
var TotalPage = 0; // 全体ページ
var NowPage = 0; // 表示ページ
var page_item = document.querySelectorAll(".page-item");
var detail_button = document.querySelectorAll(".btnDetail");
var SearchPage = 1;
var GetLogNowPage = "";
if(getCookie("LogNowPage") != ""){
    GetLogNowPage = getCookie("LogNowPage");
}

var PageMedian = 2; // ページャの中央値 [ 1 , ② , 3 ]

// 初期検索
Search();

// 通信ログ検索
function btnSearchClick() {
    SearchPage = 1;
    document.cookie = "LogNowPage=" + 0 + "; max-age=86400; path=/";
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

// 検索
function Search() {
    // 入力値取得
    let DateFm = $("#DateFm").val();
    let DateTo = $("#DateTo").val();
    let Sere = $("#Sere").val();
    let Status = $("#Status").val();
    let Order = $("#Order").val();

    // 通信ログ時間のFm,Toを正す
    if (DateFm != "" && DateTo != "") {
        if (DateFm > DateTo) {
            let work = DateFm;
            DateFm = DateTo;
            DateTo = work;
            $("#DateFm").val(DateFm);
            $("#DateTo").val(DateTo);
        };
    };

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
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
                    Nod = data.count; // 検索ヒット数
                    TotalPage = Math.ceil(Nod / 10); // ページの最大値
                    MakeLogTable(1); // 初期検索・検索(1ページ目を強制表示)
                } else {
                    alert(data.status);
                };
            };
        }
    });
}

// 検索結果表示 v.2
function MakeLogTable(PagerID) {
    // ━━━━━━━ ページャ処理開始
    // PagerIDが[null: エラー, ある: クッキーの有無で代入]
    if (PagerID == "") {
        document.getElementById("error_modal").click();
        return false;
    } else if (GetLogNowPage != "") {
        PagerID = GetLogNowPage;
        GetLogNowPage = "";
    }
    // ページャのボタンが押されていれば[真] 
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
                if(SearchPage == TotalPage){
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
        // 検索するページが1 または、ヒット数が30件以下の場合は中央値を2固定
        if (SearchPage == 1 || Nod < 31) {
            PageMedian = 2;
        }
        PagerID = "";
    } else {
        SearchPage = 1;
    }
    // ━━━━━━━ ページャ処理終了

    // 検索結果表示
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: { // モード, 表示したいページ, ページャの中央値
            "mode": "MakeLogTable", 
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

                            if (NowPage == 1) { // 表示ページが1またはヒット数が30件以下でボタンを押下できなくする
                                document.querySelector("#pista a").classList.add("disabled");
                                document.getElementById("pista").style.pointerEvents = "none";
                                document.querySelector("#piback a").classList.add("disabled");
                                document.getElementById("piback").style.pointerEvents = "none";
                            }
                            if (NowPage == TotalPage) { // 表示ページが最後またはヒット数が30件以下でボタンを押下できなくする
                                document.querySelector("#pinext a").classList.add("disabled");
                                document.getElementById("pinext").style.pointerEvents = "none";
                                document.querySelector("#piend a").classList.add("disabled");
                                document.getElementById("piend").style.pointerEvents = "none";
                            }
                            detail_btn(); // 詳細ボタンのid振り分け
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