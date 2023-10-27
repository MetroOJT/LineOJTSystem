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
    window.location = "../Menu/Index.aspx";
}

$(function () {
    document.getElementById("btnBack").addEventListener("click", btnBackClick, false);
});