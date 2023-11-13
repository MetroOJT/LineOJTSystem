var Ajax_File = "Detail.ashx";


$(function () {
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
    document.getElementById("delete_button").addEventListener("click", btnDeleteClick, false);
    document.getElementById("back_button").addEventListener("click", btnBackClick, false);
    document.getElementById("buttonEye_1").addEventListener("click", btnEyeClick_1, false);
    document.getElementById("buttonEye_2").addEventListener("click", btnEyeClick_2, false);
});

sessionStorage.setItem('hUserID', 80000);
//sessionStorage.removeItem('hUserID');

window.onload = function () {
    if (sessionStorage.getItem('hUserID') != null) {
        const hUserID = sessionStorage.getItem('hUserID');
        console.log(hUserID);
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Load",
                "User_ID": hUserID
            },
            dataType: "json",
            success: function (data) {
                console.log(data);
                if (data != "") {
                    if (data.status == "OK") {
                        if (Number(data.count) > 0) {
                            // 表示するコードを書く
                            document.querySelector("#user_ID").value = data.UserID;
                            document.querySelector("#user_Name").value = data.UserName;
                            document.querySelector("#user_password").value = data.Password;
                            document.querySelector("#user_password_confirmation").value = data.Password;
                            console.log(data.Admin);
                            if (data.admin != "") {
                                if (data.Admin == 1) {
                                    $('input[value="0"]').prop('checked', true);
                                } else if (data.Admin == 0) {
                                    $('input[value="1"]').prop('checked', true);
                                };
                            };
                        };
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    } else {
        document.getElementById("delete_button").disabled = true;
    }
}

// #dc3545 赤
// #198754 緑
// h6かborder-weidgh

// 登録ボタンクリック
function btnRegistrationClick() {
    // バリデータのクリア
    for (let i = 1; i < 6; i++) {
        if (document.querySelector(`#p_${i}`)) {
            document.querySelector(`#error_message_div_${i}`).removeChild(document.querySelector(`#p_${i}`));
        };
    };

    var User_ID = $("#user_ID").val();
    var Password = $("#user_password").val();
    var Password_confirmation = $("#user_password_confirmation").val();
    var User_Name = $("#user_Name").val();
    var Admin_Check = $('input[name="contact"]:checked').val();

    if (Admin_Check == "0") {
        Admin_Check = 1;
    } else if (Admin_Check == "1") {
        Admin_Check = 0;
    };

    console.log(User_ID);
    console.log(Password);
    console.log(Password_confirmation);
    console.log(User_Name);
    console.log(Admin_Check);
    console.log(typeof (Admin_Check));

    // ラジオボタン以外のバリデータ
    const form = document.querySelector("#form1");
    const error_judgement = [];
    const isBelowThreshold = (currentValue) => currentValue == 0;
    var c_element = 0;
    form.querySelectorAll('.form-control').forEach(function (elm) {
        if (c_element == 2) {
            c_element += 2;
        } else {
            c_element += 1;
        };
        
        var maxlen = elm.getAttribute('data-maxlen');
        var regexp = elm.getAttribute('data-regexp');
        if ((maxlen && (maxlen < elm.value.length)) ||
            (regexp && !(elm.value.match(regexp)))) {
            // 赤にする
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
            error_judgement.push(1);
            elm.parentNode.style.borderColor = "#dc3545";
            const error_message_div = document.querySelector(`#error_message_div_${c_element}`);
            const error_message_p = document.createElement("p");
            error_message_p.className = "h6";
            error_message_p.id = `p_${c_element}`;
            error_message_p.style.color = "#dc3545";
            
            const p_textcontent = document.querySelector(`#label_${c_element}`).textContent;
            error_message_p.textContent = `${p_textcontent}を入力してください。`;
            error_message_div.appendChild(error_message_p);

        } else {
            // 緑にする
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
            error_judgement.push(0);
            elm.parentNode.style.borderColor = "#198754";
        }
    });

    // ラジオボタンのバリデータ
    let c_radio = [];
    form.querySelectorAll('.form-check-input').forEach(function (elm) {
        if (!elm.checked) {
            // 赤にする
            c_radio.push(0);
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
        } else {
            // 緑にする
            c_radio.push(1);
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
        };
    });
    if (c_radio[0] == 1) {
        document.querySelector("#contactChoice_2").classList.add('is-valid');
        document.querySelector("#contactChoice_2").classList.remove('is-invalid');
    } else if (c_radio[1] == 1){
        document.querySelector("#contactChoice_1").classList.add('is-valid');
        document.querySelector("#contactChoice_1").classList.remove('is-invalid');
    };
    if (c_radio.every(v => v == 0)) {
        error_judgement.push(1);
        const error_p = document.createElement('p');
        error_p.textContent = "管理者を選択してください。";
        error_p.style.color = "#dc3545";
        error_p.className = "h6";
        error_p.id = `p_3`;
        document.querySelector("#error_message_div_3").appendChild(error_p);
    } else {
        error_judgement.push(0);
    };

    // パスワードが一致しているか
    if (error_judgement[2] == 0 && error_judgement[3] == 0) {
        if (document.querySelector("#user_password").value == document.querySelector("#user_password_confirmation").value) {
            error_judgement.push(0);
            console.log("パスワードが一致");
        } else {
            error_judgement.push(1);
            console.log("パスワードが不一致");
            console.log(document.querySelector("#user_password"));
            const user_password = document.querySelector("#user_password");
            const user_password_confirmation = document.querySelector("#user_password_confirmation");
            user_password.classList.add('is-invalid');
            user_password.classList.remove('is-valid');
            user_password_confirmation.classList.add('is-invalid');
            user_password_confirmation.classList.remove('is-valid');
            user_password.parentNode.style.borderColor = "#dc3545";
            user_password_confirmation.parentNode.style.borderColor = "#dc3545";

            const error_message_p_1 = document.createElement("p");
            error_message_p_1.className = "h6";
            error_message_p_1.id = `p_4`;
            error_message_p_1.style.color = "#dc3545";
            const error_message_p_2 = document.createElement("p");
            error_message_p_2.className = "h6";
            error_message_p_2.id = `p_5`;
            error_message_p_2.style.color = "#dc3545";
            error_message_p_1.textContent = `パスワードが一致しません。`;
            document.querySelector("#error_message_div_4").appendChild(error_message_p_1);
            error_message_p_2.textContent = `パスワードが一致しません。`;
            document.querySelector("#error_message_div_5").appendChild(error_message_p_2);
        };
    };
    
    console.log(error_judgement);

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
    } else if (error_judgement.every(v => v == 0)){
        console.log("OK");
        sessionStorage.setItem("iUser_ID", User_ID);
        sessionStorage.setItem("iPassword", Password);
        sessionStorage.setItem("iUser_Name", User_Name);
        sessionStorage.setItem("iAdmin_Check", Admin_Check);
        window.location.href = "Confirm.aspx";
    };

};

// 該当するデータを削除する
function btnDeleteClick () {
    if (window.confirm("本当に削除しますか？")) {
        const hUserID = sessionStorage.getItem('hUserID');
        console.log(hUserID);
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Delete",
                "User_ID": hUserID
            },
            dataType: "json",
            success: function (data) {
                console.log(data);
                if (data != "") {
                    if (data.status == "OK") {
                        // 表示するコードを書く
                        console.log("削除が完了しました");
                        sessionStorage.removeItem("hUserID");
                        window.history.back();
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        })
    }
}

// 戻るボタンを押したときの処理
function btnBackClick() {
    window.history.back();
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
