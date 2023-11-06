var Ajax_File = "Detail.ashx";

const re_UserID = sessionStorage.getItem('UserID');

$(function () {
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
    document.getElementById("buttonEye_1").addEventListener("click", btnEyeClick, false);
    document.getElementById("buttonEye_2").addEventListener("click", btnEyeClick, false);
});

// 登録ボタンクリック
function btnRegistrationClick() {
    var User_ID = $("#user_ID").val();
    var Password = $("#user_password").val();
    var Password_confirmation = $("#user_password_confirmation").val();
    var User_Name = $("#user_Name").val();
    var Admin_Check = $('input[name="contact"]:checked').val();

    console.log(User_ID);
    console.log(Password);
    console.log(Password_confirmation);
    console.log(User_Name);
    console.log(Admin_Check);


    if (Password != Password_confirmation) {
        console.log("パスワードが一致しません");
    } else {
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Registration",
                "User_ID": User_ID,
                "Password": Password,
                "User_Name": User_Name,
                "Admin_Check": Admin_Check,
                "Re_UserID": re_UserID
            },
            dataType: "json",
            success: function (data) {
                console.log(data);
                //if (data != "") {
                //    if (data.status == "OK") {
                //        if (Number(data.count) > 0) {
                //            // セッションに追加（ユーザーIDとユーザーネームと管理者権限があるかどうか）
                //            var UserID = Number(data.UserID);
                //            var Admin = Number(data.Admin);

                //            sessionStorage.setItem('UserID', UserID);
                //            sessionStorage.setItem('UserName', data.UserName);
                //            sessionStorage.setItem('Admin', Admin);

                //            // セッションに追加（ログインをしてから他の画面に遷移したか）
                //            const login_check = 1;
                //            sessionStorage.setItem("login_check", login_check);

                //            window.location.href = "../Menu/Index.aspx";
                //        } else {
                //            const error_p = document.createElement('p');
                //            error_p.textContent = "該当するユーザーが存在しません";
                //            error_p.style.color = "red";
                //            error_div.appendChild(error_p);
                //            user_ID_input.focus();
                //        };
                //    } else {
                //        alert("エラーが発生しました。");
                //    };
                //};
            }

        });
    }

};

// パスワード入力欄の横にある👁を押すと、入力したパスワードが見えるようになったり見えなくなったりするようになる
function btnEyeClick() {
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
