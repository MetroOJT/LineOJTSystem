// var Ajax_File = "Index.ashx"

// ログアウト
function btnLogOutClick() {
    console.log("ログアウト");
}

// 通信ログ検索
function btnSearchClick() {
    console.log("イベント登録");
    window.location = "http://localhost:808/LineSampleSystem/Sample/hirashima/EventRegistration/EventReg.aspx";
}

// 通信ログクリア
function btnClearClick() {
    console.log("イベント検索");
}

// 戻る
function btnBackClick() {
    console.log("通信ログ");
}

var oac = 1;
// 閉じる
function btnCloseClick() {
    const cona = document.getElementById("cona");
    const conb = document.getElementById("conb");
    if (oac == 1) {
        oac = 0;        
        cona.classList.remove("col-10");
        cona.classList.add("col-6");
        conb.classList.remove("col-2");
        conb.classList.add("col-6");
        document.getElementById("btnClose").textContent = "検索する際はこちらのボタンをクリックしてください";
    } else {
        oac = 1;
        cona.classList.remove("col-6");
        cona.classList.add("col-10");
        conb.classList.remove("col-6");
        conb.classList.add("col-2");
        document.getElementById("btnClose").textContent = "閉じる";
    }
    
}

$(function () {
    document.getElementById("btnLogOut").addEventListener("click", btnLogOutClick, false);
    document.getElementById("btnSearch").addEventListener("click", btnSearchClick, false);
    document.getElementById("btnClear").addEventListener("click", btnClearClick, false);
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
    document.getElementById("btnClose").addEventListener("click", btnCloseClick, false);
});