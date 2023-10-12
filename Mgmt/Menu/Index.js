// var Ajax_File = "Index.ashx"

// ログアウト
function btnLogOutClick() {
    console.log("ログアウト");
}

// イベント登録
function btnEventRegClick() {
    console.log("イベント登録");
    window.location = "http://localhost:808/LineSampleSystem/Sample/hirashima/EventRegistration/EventReg.aspx";
}

// イベント検索
function btnEventSearchClick() {
    console.log("イベント検索");
}

// 通信ログ
function btnComLogClick() {
    console.log("通信ログ");
}

$(function () {
    document.getElementById("btnLogOut").addEventListener("click", btnLogOutClick, false);
    document.getElementById("btnEventReg").addEventListener("click", btnEventRegClick, false);
    document.getElementById("btnEventSearch").addEventListener("click", btnEventSearchClick, false);
    document.getElementById("btnComLog").addEventListener("click", btnComLogClick, false);
});