//ログインなされているかをチェックする関数
function_login_check();
DspLoginUserName();

var Ajax_File = "Index.ashx";

var Nod = 0; // 検索に引っかかった件数
var Npage = 1; // ページ設定
var page_item = document.querySelectorAll(".page-item");
var detail_button = document.querySelectorAll(".btnDetail");

var PageMedian = 2; // ページャの中央値 [ 1 , ② , 3 ]
var StyleBold = 1; // 現在表示しているページの強調

var oac = 1; // アコーディオン[開:1,閉:0]

window.onload = function () {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Load",
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (data.nowpage == 1) {
                        const User_ID = data.User_ID;
                        const User_Name = data.User_Name;
                        const Admin_Check = data.Admin_Check;
                        const Date_Fm = data.Date_Fm;
                        const Date_To = data.DateTo;
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
                            },
                            dataType: "json",
                            success: function (data) {
                                //console.log(data);
                                if (data != "") {
                                    if (data.status == "OK") {
                                        Nod = data.count;
                                        MakeResult();
                                    } else {
                                        alert("エラーが発生しました。");
                                    };
                                };
                            }
                        });

                    }else if (data.nowpage > 1){
                        Npage = data.nowpage;
                        PageMedian = Npage;
                        if (Npage <= 1 || Nod < 31) {
                            PageMedian = 2;
                        } else if (Npage >= Math.ceil(Nod / 10)) {
                            PageMedian = Math.ceil(Nod / 10) - 1;
                        }
                        console.log(PageMedian);
                        
                        $.ajax({
                            url: Ajax_File,
                            method: "POST",
                            data: {
                                "mode": "PagiNation",
                                "nowpage": Npage,
                                "pagemedian": PageMedian
                            },
                            dataType: "json",
                            success: function (data) {
                                if (data != "") {
                                    if (data.status == "OK") {
                                        if (Number(data.count) > 0) {
                                            if (Npage > data.count / 10) {
                                                Npage = Math.ceil(data.count / 10);
                                            } else if (Npage < 1) {
                                                Npage = 1;
                                            }
                                            const NpageFm = (parseInt(Npage) - 1) * 10 + 1; // 件数表示(前)
                                            var NpageTo = 0; // 件数表示(後)
                                            if (Npage == Math.ceil(data.count / 10)) {
                                                NpageTo = data.count;
                                            } else {
                                                NpageTo = parseInt(Npage) * 10;
                                            }
                                            document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " / " + Math.ceil(data.count / 10) + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                                            if (data.html != "") {
                                                document.getElementById("PNArea").innerHTML = data.pnlist;
                                                document.getElementById("ResultArea").innerHTML = data.html;
                                                document.getElementById("PageNumber").value = Npage;
                                                page_item = document.querySelectorAll(".page-item");
                                                page_item.forEach(pi => {
                                                    pi.addEventListener('click', function () {
                                                        PagiNation(pi.id);
                                                    });
                                                });
                                                if (Npage == 1 || data.count < 31) {
                                                    document.querySelector("#pista a").style.color = "black";
                                                    document.querySelector("#pista a").style.backgroundColor = "silver";
                                                    document.getElementById("pista").style.pointerEvents = "none";
                                                    document.querySelector("#piback a").style.color = "black";
                                                    document.querySelector("#piback a").style.backgroundColor = "silver";
                                                    document.getElementById("piback").style.pointerEvents = "none";
                                                }
                                                if (Npage == Math.ceil(data.count / 10) || data.count < 31) {
                                                    document.querySelector("#pinext a").style.color = "black";
                                                    document.querySelector("#pinext a").style.backgroundColor = "silver";
                                                    document.getElementById("pinext").style.pointerEvents = "none";
                                                    document.querySelector("#piend a").style.color = "black";
                                                    document.querySelector("#piend a").style.backgroundColor = "silver";
                                                    document.getElementById("piend").style.pointerEvents = "none";
                                                }
                                                //console.log(data.pm, PageMedian)
                                                transition();
                                            }
                                        } else {
                                            document.getElementById("PNArea").innerHTML = "";
                                            document.getElementById("ResultArea").innerText = "該当するデータが存在しませんでした。";
                                        }
                                    } else {
                                        alert("エラーが発生しました。");
                                    }
                                }
                            }
                        });

                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

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
});

// 検索ボタンが押された時の処理
function btnSearchClick() {
    var User_ID = $("#user_ID").val();
    var User_Name = $("#user_Name").val();
    var Admin_Check = $("#Kanrisya").val();
    var Date_Fm = $("#DateFm").val();
    var Date_To = $("#DateTo").val();

    //console.log(User_ID);
    //console.log(User_Name);
    //console.log(Admin_Check);
    //console.log(Date_Fm);
    //console.log(Date_To);

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
        },
        dataType: "json",
        success: function (data) {
            //console.log(data);
            if (data != "") {
                if (data.status == "OK") {
                    Nod = data.count;
                    MakeResult();
                } else {
                    alert("エラーが発生しました。");
                };
            };
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
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " / " + Math.ceil(data.count / 10) + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("PNArea").innerHTML = data.pnlist;
                            document.getElementById("ResultArea").innerHTML = data.html;
                            page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                pi.addEventListener('click', function () {
                                    PagiNation(pi.id);
                                });
                            });
                            transition();
                        }
                    } else {
                        document.getElementById("CntArea").innerText = "";
                        document.getElementById("PNArea").innerHTML = "";
                        document.getElementById("ResultArea").innerText = "該当するデータが存在しませんでした。";
                    }
                } else {
                    alert("エラーが発生しました。");
                }
            }
        }
    });
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
            console.log(data);
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

// ページネーション
function PagiNation(pid) {
    switch (pid) {
        case "pista":
            Npage = 1;
            PageMedian = 2;
            break;
        case "piback":
            if (Npage > 1) {
                Npage -= 1;
            }
            if (Npage == 1) {
                PageMedian = 2;
            } else {
                PageMedian = Npage;
            }
            break;
        case "pi1": // 現在表示しているページの１つ前
            Npage = PageMedian - 1;
            if (Nod < 31 || Npage == 1) {
                PageMedian = 2;
            } else {
                PageMedian = Npage;
            }
            break;
        case "pi2":
            Npage = PageMedian;
            if (Nod < 31) {
                PageMedian = 2;
            } else {
                PageMedian = Npage;
            }
            break;
        case "pi3": // 現在表示しているページの１つ後
            Npage = PageMedian + 1;
            if (Nod < 31) {
                PageMedian = 2;
            } else if (Npage == Math.ceil(Nod / 10)) {
                PageMedian = Npage - 1;
            } else {
                PageMedian = Npage;
            }
            break;
        case "pinext":
            if (Npage < Math.ceil(Nod / 10)) {
                Npage += 1;
            }
            if (Npage == Math.ceil(Nod / 10)) {
                PageMedian = Npage - 1;
            } else {
                PageMedian = Npage;
            }
            break;
        case "piend":
            Npage = Math.ceil(Nod / 10);
            PageMedian = Npage - 1;
            break;
        default:
            Npage = pid;
            PageMedian = Npage;
            if (Npage <= 1 || Nod < 31) {
                PageMedian = 2;
            } else if (Npage >= Math.ceil(Nod / 10)) {
                PageMedian = Math.ceil(Nod / 10) - 1;
            }
            break;
    }

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "PagiNation",
            "nowpage": Npage,
            "pagemedian": PageMedian
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        if (Npage > data.count / 10) {
                            Npage = Math.ceil(data.count / 10);
                        } else if (Npage < 1) {
                            Npage = 1;
                        }
                        const NpageFm = (parseInt(Npage) - 1) * 10 + 1; // 件数表示(前)
                        var NpageTo = 0; // 件数表示(後)
                        if (Npage == Math.ceil(data.count / 10)) {
                            NpageTo = data.count;
                        } else {
                            NpageTo = parseInt(Npage) * 10;
                        }
                        document.getElementById("CntArea").innerText = "件数：" + data.count + "件" + " (表示中: " + Npage + " / " + Math.ceil(data.count / 10) + " ページ , " + NpageFm + "件 ～ " + NpageTo + "件)";
                        if (data.html != "") {
                            document.getElementById("PNArea").innerHTML = data.pnlist;
                            document.getElementById("ResultArea").innerHTML = data.html;
                            document.getElementById("PageNumber").value = Npage;
                            page_item = document.querySelectorAll(".page-item");
                            page_item.forEach(pi => {
                                pi.addEventListener('click', function () {
                                    PagiNation(pi.id);
                                });
                            });
                            if (Npage == 1 || data.count < 31) {
                                document.querySelector("#pista a").style.color = "black";
                                document.querySelector("#pista a").style.backgroundColor = "silver";
                                document.getElementById("pista").style.pointerEvents = "none";
                                document.querySelector("#piback a").style.color = "black";
                                document.querySelector("#piback a").style.backgroundColor = "silver";
                                document.getElementById("piback").style.pointerEvents = "none";
                            }
                            if (Npage == Math.ceil(data.count / 10) || data.count < 31) {
                                document.querySelector("#pinext a").style.color = "black";
                                document.querySelector("#pinext a").style.backgroundColor = "silver";
                                document.getElementById("pinext").style.pointerEvents = "none";
                                document.querySelector("#piend a").style.color = "black";
                                document.querySelector("#piend a").style.backgroundColor = "silver";
                                document.getElementById("piend").style.pointerEvents = "none";
                            }
                            //console.log(data.pm, PageMedian)
                            transition();
                        }
                    } else {
                        document.getElementById("PNArea").innerHTML = "";
                        document.getElementById("ResultArea").innerText = "該当するデータが存在しませんでした。";
                    }
                } else {
                    alert("エラーが発生しました。");
                }
            }
        }
    });
};

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
