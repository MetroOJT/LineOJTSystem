function_login_check();
DspLoginUserName();

var DD_Sere = sessionStorage.getItem("DD_Sere");
var DD_Status = sessionStorage.getItem("DD_Status");
var DD_Log = sessionStorage.getItem("DD_Log");
var DD_Time = sessionStorage.getItem("DD_Time");

document.getElementById("DetailSere").value = DD_Sere;
document.getElementById("DetailStatus").value = DD_Status;
document.getElementById("DetailLog").value = DD_Log;
document.getElementById("DetailTime").value = DD_Time;

if (DD_Status != "200") {
    document.getElementById("DetailSere").style.color = "red";
    document.getElementById("DetailStatus").style.color = "red";
    document.getElementById("DetailLog").style.color = "red";
    document.getElementById("DetailTime").style.color = "red";
}

// 戻る
function btnBackClick() {
    window.location = document.referrer;
}

window.addEventListener("DOMContentLoaded", () => {
    // textareaタグを全て取得
    const textareaEl = document.getElementById("DetailLog");

    // デフォルト値としてスタイル属性を付与
    textareaEl.setAttribute("style", `height: ${textareaEl.scrollHeight + 10}px; resize: none;`);
    // inputイベントが発生するたびに関数呼び出し
    textareaEl.addEventListener("input", setTextareaHeight);

    // textareaの高さを計算して指定する関数
    function setTextareaHeight() {
        this.style.height = "auto";
        this.style.height = `${this.scrollHeight}px`;
    }
},{once: true});

$(function () {
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
});