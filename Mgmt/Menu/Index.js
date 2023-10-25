﻿// ＜jsの最初に追加＞
function_login_check();

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
                    document.getElementById("Manager").textContent = "担当者名: " + u_name;
                    MakeMenu();
                } else {
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
    // ＜ログアウトをしたときの処理に追加＞
    sessionStorage.removeItem("unauthorized_access");
    console.log("ログアウト");
    window.location = "../Login/Index.aspx";
}

// イベント登録
function btnEventRegClick() {
    console.log("イベント登録");
    window.location = "../Event/Detail.aspx";
}

// イベント検索
function btnEventSearchClick() {
    console.log("イベント検索");
    window.location = "../Event/Index.aspx";
}

// 通信ログ
function btnComLogClick() {
    console.log("通信ログ");
    window.location = "../CommLog/Index.aspx";
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