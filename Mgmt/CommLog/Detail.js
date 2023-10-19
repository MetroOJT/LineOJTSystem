// var Ajax_File = "Detail.ashx"

// ログアウト
function btnLogOutClick() {
    window.location = "http://localhost:808/LineOJTSystem/Mgmt/Login/Index.aspx";
    console.log("ログアウト");
}

// 戻る
function btnBackClick() {
    console.log("メニュー画面へ遷移");
    window.location = "http://localhost:808/LineSampleSystem/Sample/hirashima/Index.aspx";
}

$(function () {
    document.getElementById("btnLogOut").addEventListener("click", btnLogOutClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
});