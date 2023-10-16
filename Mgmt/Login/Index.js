﻿var Ajax_File = "Index.ashx";

$(function () {
    document.getElementById("login_button").addEventListener("click", btnLoginClick, false);
});

function go() {
    if (window.event.keyCode == 13) {
        btnLoginClick();
    }
}

// ログインボタンクリック
function btnLoginClick() {
    var User_ID = $("#user_ID").val();
    var Password = $("#user_password").val();
    console.log(User_ID);
    console.log(Password);
    
    const error_div = document.querySelector('.error_div');
    error_div.innerHTML = '';

    if (User_ID == "") {
        const error_p = document.createElement('p');
        error_p.textContent = "ユーザーIDを入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
    } else if (Password == "") {
        const error_p = document.createElement('p');
        error_p.textContent = "Passwordを入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
    } else if (User_ID.match(/^[^\x01-\x7E\uFF61-\uFF9F]+$/)) {
        const error_p = document.createElement('p');
        error_p.textContent = "ユーザーIDは半角で入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
    } else {
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Search",
                "User_ID": User_ID,
                "Password": Password
            },
            dataType: "json",
            success: function (data) {
                console.log(data);
                if (data != "") {
                    if (data.status == "OK") {
                        if (Number(data.count) > 0) {
                            var UserID = Number(data.UserID);
                            var Admin = Number(data.Admin);

                            sessionStorage.setItem('UserID', UserID);
                            sessionStorage.setItem('UserName', data.UserName);
                            sessionStorage.setItem('Admin', Admin);

                            window.location.href = "http://localhost:808/LineOJTSystem/Mgmt/Menu/Index.aspx";
                        } else {
                            alert("該当するユーザーが存在しません。");
                        };
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    }
};
