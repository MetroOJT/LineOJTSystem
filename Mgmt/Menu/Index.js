// ＜jsの最初に追加＞
var Ajax_File = "Index.ashx"

const uid = sessionStorage.getItem("UserID");
const u_admin = sessionStorage.getItem("Admin");
const u_name = sessionStorage.getItem("UserName");

window.onload = function () {
    function_login_check();
    DspLoginUserName();
    let Admin = u_admin;
    MakeMenu();
    CommLogDeleteCookie();
}

function CommLogDeleteCookie() {
    deleteCookie("LogNowPage");
    deleteCookie("pagemedian");
    deleteCookie("LogDateFm");
    deleteCookie("LogDateTo");
    deleteCookie("LogSendRecv");
    deleteCookie("LogStatusNumber");
    deleteCookie("LogOrder");
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
                    document.getElementById("option").innerHTML = data.html;
                } else {
                    alert(data.status);
                };
            };
        }
    });
}

function transition(url) {
    window.location = url;
}