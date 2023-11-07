var Ajax_File = "Detail.ashx";


$(function () {
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
    document.getElementById("buttonEye_1").addEventListener("click", btnEyeClick_1, false);
    document.getElementById("buttonEye_2").addEventListener("click", btnEyeClick_2, false);
});

window.onload = function () {
    if (sessionStorage.getItem('hUserID') != null) {
        const hUserID = sessionStorage.getItem('hUserID');
        console.log(hUserID);
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Load",
                "User_ID": hUser_ID
            },
            dataType: "json",
            success: function (data) {
                console.log(data);
                if (data != "") {
                    if (data.status == "OK") {
                        // 表示するコードを書く
                        console.log("表示する");
                        document.querySelector("#user_ID").value = data.User_ID;
                        document.querySelector("#user_Name").value = data.User_Name;
                        document.querySelector("#user_password").value = data.Password;
                        document.querySelector("#user_password_confirmation").value = data.Password;
                        if (data.Admin == 1) {
                            document.querySelector("#contactChoice1").checked = True;
                        } else if (data.Admin == 0) {
                            document.querySelector("#contaceChoice2").checked = True;
                        };
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    }
}

// 登録ボタンクリック
function btnRegistrationClick() {
    var User_ID = $("#user_ID").val();
    var Password = $("#user_password").val();
    var Password_confirmation = $("#user_password_confirmation").val();
    var User_Name = $("#user_Name").val();
    var Admin_Check = $('input[name="contact"]:checked').val();

    if (Admin_Check == "True") {
        Admin_Check = 1;
    } else if (Admin_Check == "False") {
        Admin_Check = 0;
    };

    console.log(User_ID);
    console.log(Password);
    console.log(Password_confirmation);
    console.log(User_Name);
    console.log(Admin_Check);
    console.log(typeof (Admin_Check));

    if (User_ID == "") {
        console.log("ユーザーIDを入力してください");
    } else if (User_Name == "") {
        console.log("ユーザー名を入力してください");
    } else if ((Admin_Check != 0) && (Admin_Check != 1)) {
        console.log("管理者権限を付与するか選択してください");
    } else if (Password == "") {
        console.log("パスワードを入力してください");
    } else if (Password_confirmation == "") {
        console.log("確認用のパスワードを入力してください");
    } else if (Password != Password_confirmation) {
        console.log("パスワードが一致しません");
    } else {
        console.log("OK");
        sessionStorage.setItem("iUser_ID", User_ID);
        sessionStorage.setItem("iPassword", Password);
        sessionStorage.setItem("iUser_Name", User_Name);
        sessionStorage.setItem("iAdmin_Check", Admin_Check);
        window.location.href = "Confirm.aspx";
    };

};

// パスワード入力欄の横にある👁を押すと、入力したパスワードが見えるようになったり見えなくなったりするようになる
function btnEyeClick_1() {
    const user_password = document.querySelector("#user_password");
    const buttonEye = document.querySelector("#buttonEye_1");

    if (user_password.type == "password") {
        user_password.type = "text";
        buttonEye.className = "fa fa-eye";
    } else {
        user_password.type = "password";
        buttonEye.className = "fa fa-eye-slash";
    };
};

function btnEyeClick_2() {
    const user_password = document.querySelector("#user_password_confirmation");
    const buttonEye = document.querySelector("#buttonEye_2");

    if (user_password.type == "password") {
        user_password.type = "text";
        buttonEye.className = "fa fa-eye";
    } else {
        user_password.type = "password";
        buttonEye.className = "fa fa-eye-slash";
    };
};