var Ajax_File = "Index.ashx"

const sesi = sessionStorage.getItem("UserID");
console.log(sesi)
//window.onload = function () {
//    let MenuID = $("#txtMenuID").val();
//    let MenuName = $("#txtMenuName").val();
//    let Admin = $("#txtAdmin").val();

//    $.ajax({
//        url: Ajax_File,
//        method: "POST",
//        data: {
//            "mode": "MenuGene",
//            "MenuID": MenuID,
//            "MenuName": MenuName,
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

// ログアウト
function btnLogOutClick() {
    console.log("ログアウト");
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
    document.getElementById("btnEventReg").addEventListener("click", btnEventRegClick, false);
    document.getElementById("btnEventSearch").addEventListener("click", btnEventSearchClick, false);
    document.getElementById("btnComLog").addEventListener("click", btnComLogClick, false);
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