var Ajax_File = "Index.ashx"

const uid = sessionStorage.getItem("UserID");
const u_admin = sessionStorage.getItem("Admin");
const u_name = sessionStorage.getItem("UserName");

window.onload = function () {
    let MenuID = $("#txtMenuID").val();
    let MenuName = $("#txtMenuName").val();
    let Admin = $("#txtAdmin").val();

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "CreateTable",
            "MenuID": MenuID,
            "MenuName": MenuName,
            "Admin": Admin
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    console.log("ct実行完了")
                    console.log("UserID: ", uid);
                    console.log("Admin: ", u_admin);
                    console.log("UserName: ", u_name);
                    document.getElementById("Manager").textContent = "担当者名: " + u_name;
                    MakeMenu();
                } else {
                    console.log("ctエラー")
                    alert(data.status); 
                };
            };
        }
    });
}

function MakeMenu() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "MakeMenu",
            "U_Admin": u_admin
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    console.log("mm実行完了")
                    document.getElementById("option").innerHTML = data.html;
                } else {
                    console.log("mmエラー")
                    alert(data.status);
                };
            };
        }
    });
}

// ログアウト
function btnLogOutClick() {
    console.log("ログアウト");
    window.location = "http://localhost:808/LineOJTSystem/Mgmt/Login/Index.aspx";
}

// イベント登録
function btnEventRegClick() {
    console.log("イベント登録");
}

// イベント検索
function btnEventSearchClick() {
    console.log("イベント検索");
}

// 通信ログ
function btnComLogClick() {
    console.log("通信ログ");
    window.location = "http://localhost:808/LineSampleSystem/Sample/hirashima/CommLog/Index.aspx";
}

$(function () {
    document.getElementById("btnLogOut").addEventListener("click", btnLogOutClick, false);
});

//window.onload = function () {
    //    let UserID = $("#txtUserID").val();
    //    let UserName = $("#txtUserName").val();
    //    let Admin = $("#txtAdmin").val();

    //    $.ajax({
    //        url: Ajax_File,
    //        method: "POST",
    //        data: {
    //            "admin": "1",
    //            "UserID": UserID,
    //            "UserName": UserName,
    //            "Admin": Admin
    //        },
    //        dataType: "json",
    //        success: function (data) {
    //            if (data != "") {
    //                if (data.status == "OK") {
    //                    if (Number(data.count) > 0) {
    //                        console.log("実行できたで")
    //                        console.log(data.html)
    //                    } else {
    //                        console.log("うーむ....")
    //                    };
    //                } else {
    //                    alert(data.status);
    //                };
    //            };
    //        }
    //    });
    //}