var Ajax_File = "Detail.ashx";
function_login_check();
DspLoginUserName();

var iUserID;
var iUserName;
var iPassword;
var iAdmin;

$(function () {
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
    document.getElementById("delete_button").addEventListener("click", btnDeleteClick, false);
    document.getElementById("back_button").addEventListener("click", btnBackClick, false);
    document.getElementById("buttonEye_1").addEventListener("click", btnEyeClick_1, false);
    document.getElementById("buttonEye_2").addEventListener("click", btnEyeClick_2, false);
});
//console.log(sessionStorage.getItem('hUserID'));
if (sessionStorage.getItem('hUserID') != null) {
    const hUserID = sessionStorage.getItem('hUserID');
    //console.log(hUserID);
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
                        iUserID = data.UserID;
                        iUserName = data.UserName;
                        iPassword = data.Password;
                        document.querySelector("#user_ID").value = iUserID;
                        document.querySelector("#user_Name").value = iUserName;
                        document.querySelector("#user_password").value = iPassword;
                        document.querySelector("#user_password_confirmation").value = iPassword;
                        iAdmin = data.Admin;
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
    document.getElementById("delete_button").style.display = "none";
    document.getElementById("delete_button").classList.remove("btn-outline-danger");
    document.getElementById("delete_button").classList.add("btn-secondary");
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
        if (elm.value == "") {
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
        } else if ((maxlen && (maxlen < elm.value.length)) ||
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
            if (c_element == 1) {
                error_message_p.textContent = "ユーザーIDは半角数字5桁で入力してください";
            } else if (c_element == 4) {
                error_message_p.textContent = "パスワードは半角英数字8～20文字以下で入力してください";
                error_message_div.style.marginLeft = null;
                error_message_div.style.textAlign = "right";
            } else if (c_element == 5) {
                error_message_p.textContent = "パスワード（確認用）は半角英数字8～20文字以下で入力してください";
                const i_element = document.querySelector("#user_password");
                if (i_element.value != c_element.value) {
                    const i_div = document.querySelector("#error_message_div_4");
                    error_message_p.textContent = "パスワードが一致しません";
                    i_div.append.appendChild(error_message_p);
                }
                error_message_div.style.marginLeft = null;
            }else {
                error_message_p.textContent = `${p_textcontent}を入力してください。`;
            }
        
            error_message_div.appendChild(error_message_p);

        } else {
            // 緑にする
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
            error_judgement.push(0);
            elm.parentNode.style.borderColor = "#198754";
            // 既に登録されているユーザーIDがないかチェック
            if (c_element == 1) {
                const User_ID = elm.value;
                $.ajax({
                    url: Ajax_File,
                    method: "POST",
                    data: {
                        "mode": "Search",
                        "User_ID": User_ID,
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data != "") {
                            console.log(data);
                            if (data.status == "OK") {
                                if (data.ErrorMessage != "") {
                                    // 赤にする
                                    elm.classList.add('is-invalid');
                                    elm.classList.remove('is-valid');
                                    error_judgement.push(1);
                                    elm.parentNode.style.borderColor = "#dc3545";
                                    console.log(c_element);
                                    const error_message_div = document.querySelector(`#error_message_div_1`);
                                    const error_message_p = document.createElement("p");
                                    error_message_p.className = "h6";
                                    error_message_p.id = `p_1`;
                                    error_message_p.style.color = "#dc3545";
                                    error_message_p.textContent = "このユーザーIDは既に登録されています。";
                                    error_message_div.appendChild(error_message_p);
                                }
                            } else {
                                alert("エラーが発生しました。");
                            };
                        };
                    }
                });
            }
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
            // パスワードが一致している場合
            error_judgement.push(0);
        } else {
            // パスワードが一致していない場合
            error_judgement.push(1);
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

if (error_judgement.every(v => v == 0)){
        sessionStorage.setItem("iUser_ID", User_ID);
        sessionStorage.setItem("iPassword", Password);
        sessionStorage.setItem("iUser_Name", User_Name);
        sessionStorage.setItem("iAdmin_Check", Admin_Check);
        window.location.href = "Confirm.aspx";
    };
};

// 削除ボタンを押された時の処理
function btnDeleteClick() {
    var User_ID = iUserID;
    var Password = iPassword;
    var Password_confirmation = iPassword;
    var User_Name = iUserName;
    var Admin_Check = iAdmin;
    sessionStorage.setItem("iUser_ID", User_ID);
    sessionStorage.setItem("iPassword", Password);
    sessionStorage.setItem("iUser_Name", User_Name);
    sessionStorage.setItem("iAdmin_Check", Admin_Check);
    sessionStorage.setItem("dUser_ID", User_ID);
    window.location.href = "Confirm.aspx";
}

// 戻るボタンを押したときの処理
function btnBackClick() {
    sessionStorage.removeItem('hUserID');
    sessionStorage.removeItem('dUser_ID');
    window.location.href = "Index.aspx";
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
