var Ajax_File = "Index.ashx";

// ログインをせずに他の画面を表示しようとした時に、ログイン画面に戻ってきてメッセージを表示する
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
    document.getElementById("buttonEye").addEventListener("click", btnEyeClock, false);
    document.getElementById("user_ID").addEventListener("keydown", go_next, false);
    document.getElementById("user_password").addEventListener("keydown", go_login, false);
});

// 画面を表示したときにユーザーID入力欄に自動でフォーカスする
const user_ID_input = document.querySelector('#user_ID');
const user_password_button = document.querySelector('#user_password');
user_ID_input.focus();

// ユーザーID入力欄でエンターキーを押すと、パスワード入力欄にフォーカスが移動する
function go_next() {
    if (window.event.keyCode == 13) {
        user_password_button.focus();
    }
}

// パスワード入力欄でエンターキーを押すと、ログインボタンを押したときと同じ動きをする
function go_login() {
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

    const form = document.querySelector("#form1");
    console.log("a");
    form.querySelectorAll('.form-control').forEach(function (elm) {
        var maxlen = elm.getAttribute('data-maxlen');
        var regexp = elm.getAttribute('data-regexp');
        console.log("値：", elm.value);
        console.log(maxlen);
        console.log("length: ", elm.value.length);
        console.log(regexp);
        console.log("正規表現：", elm.value.match(regexp));

        if ((maxlen && (maxlen < elm.value.length)) ||
            (regexp && !(elm.value.match(regexp)))) {
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
            console.log("b");
        } else {
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
        }
    });



    // 入力値のチェック
    if (User_ID == "") {
        const error_p = document.createElement('p');
        error_p.textContent = "ユーザーIDを入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
        user_ID_input.focus();
    } else if (Password == "") {
        const error_p = document.createElement('p');
        error_p.textContent = "パスワードを入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
        user_password_button.focus();
    // 全角で入力していた場合
    } else if (User_ID.match(/[^\x01-\x7E\uFF61-\uFF9F]+/)) {
        const error_p = document.createElement('p');
        error_p.textContent = "ユーザーIDは半角で入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
        user_ID_input.focus();
    } else if (Password.match(/[^\x01-\x7E\uFF61-\uFF9F]+/)) {
        const error_p = document.createElement('p');
        error_p.textContent = "パスワードは半角で入力してください";
        error_p.style.color = "red";
        error_div.appendChild(error_p);
        user_password_button.focus();
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
                            // セッションに追加（ユーザーIDとユーザーネームと管理者権限があるかどうか）
                            var UserID = Number(data.UserID);
                            var Admin = Number(data.Admin);

                            sessionStorage.setItem('UserID', UserID);
                            sessionStorage.setItem('UserName', data.UserName);
                            sessionStorage.setItem('Admin', Admin);

                            // セッションに追加（ログインをしてから他の画面に遷移したか）
                            const login_check = 1;
                            sessionStorage.setItem("login_check", login_check);

                            window.location.href = "../Menu/Index.aspx";
                        } else {
                            const error_p = document.createElement('p');
                            error_p.textContent = "該当するユーザーが存在しません";
                            error_p.style.color = "red";
                            error_div.appendChild(error_p);
                           user_ID_input.focus();
                        };
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    }
};

// パスワード入力欄の横にある👁を押すと、入力したパスワードが見えるようになったり見えなくなったりするようになる
function btnEyeClock() {
    const user_password = document.querySelector("#user_password");
    const buttonEye = document.querySelector("#buttonEye");

    if (user_password.type == "password") {
        user_password.type = "text";
        buttonEye.className = "fa fa-eye";
    } else {
        user_password.type = "password";
        buttonEye.className = "fa fa-eye-slash";
    };
};
