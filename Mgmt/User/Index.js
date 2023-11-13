//ログインなされているかをチェックする関数
// function_login_check();

var Ajax_File = "Index.ashx";

var Nod = 0; // 検索に引っかかった件数
var Npage = 1; // ページ設定
var page_item = document.querySelectorAll(".page-item");
var detail_button = document.querySelectorAll(".btnDetail");

var PageMedian = 2; // ページャの中央値 [ 1 , ② , 3 ]
var StyleBold = 1; // 現在表示しているページの強調

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
};

$(function () {
    document.getElementById("btnSearch").addEventListener("click", btnSearchClick, false);
    document.getElementById("btnSign_up").addEventListener("click", btnSignUpClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
});

// 検索ボタンが押された時の処理
function btnSearchClick() {
    var User_ID = $("#user_ID").val();
    var User_Name = $("#user_Name").val();
    var Admin_Check = $('input[name="contact"]:checked').val();
    var Date_Fm = $("#DateFm").val();
    var Date_To = $("#DateTo").val();

    if (typeof Admin_Check === 'undefined') {
        Admin_Check = "";
    };

    console.log(User_ID);
    console.log(User_Name);
    console.log(Admin_Check);
    console.log(Date_Fm);
    console.log(Date_To);

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
            console.log(data);
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
                    alert(data.status);
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

            //const elmrow = (parseInt(elm.id.replace("detail", "")) - 1) % 10 + 1;
            //const tb = document.getElementById("table");
            //const tds = tb.rows[elmrow].querySelectorAll("td");
            //const ary = [];
            //tds.forEach(td_elm => {
            //    if (td_elm.querySelector("input")) {
            //    } else {
            //        ary.push(td_elm.innerHTML);
            //    }
            //})
            sessionStorage.setItem("hUserID", );
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
    window.location.href = "../Menu/Index.aspx";
};
