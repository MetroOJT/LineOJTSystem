var Ajax_File = "Index.ashx";

const unauthorized_access = sessionStorage.getItem("unauthorized_access");
if (unauthorized_access == 1) {
    const unauthorized_access_div = document.querySelector(".unauthorized_access_div");
    const unauthorized_access_p = document.createElement('p');
    unauthorized_access_p.textContent = "不正なアクセスです。ログインをしてください。";
    unauthorized_access_p.style.color = "red";
    unauthorized_access_p.style.fontSize = "30px";
    unauthorized_access_div.appendChild(unauthorized_access_p);
}

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
        error_p.textContent = "パスワードを入力してください";
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


                            const login_check = 1;
                            sessionStorage.setItem("login_check", login_check);

                            window.location.href = "../Menu/Index.aspx";
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
