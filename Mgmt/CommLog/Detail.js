function_login_check();

var DD_Sere = sessionStorage.getItem("DD_Sere");
var DD_Status = sessionStorage.getItem("DD_Status");
var DD_Log = sessionStorage.getItem("DD_Log");
var DD_Time = sessionStorage.getItem("DD_Time");

document.getElementById("DetailSere").value = DD_Sere;
document.getElementById("DetailStatus").value = DD_Status;
document.getElementById("DetailLog").value = DD_Log;
document.getElementById("DetailTime").value = DD_Time;

const u_name = sessionStorage.getItem("UserName");
document.getElementById("Manager").textContent = "担当者名: " + u_name;

// ログアウト
function btnLogOutClick() {
    // ＜ログアウトをしたときの処理に追加＞
    sessionStorage.removeItem("unauthorized_access");
    window.location = "../Login/Index.aspx";
}

// 戻る
function btnBackClick() {
    window.location = "../Menu/Index.aspx";
}

$(function () {
    document.getElementById("btnLogOut").addEventListener("click", btnLogOutClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
});