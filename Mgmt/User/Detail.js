// ログインチェック
function_login_check();
DspLoginUserName();

var Ajax_File = "Detail.ashx";
var iUserID;
var iUserName;
var iPassword;
var iAdmin;

$(function () {
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
    document.getElementById("delete_button").addEventListener("click", btnDeleteClick, false);
    document.getElementById("back_button").addEventListener("click", btnBackClick, false);
    document.getElementById("user_ID").addEventListener("keydown", go_next_1, false);
    document.getElementById("user_Name").addEventListener("keydown", go_next_2, false);
    document.getElementById("user_Name").addEventListener("input", CmnRegExp, false);
    document.getElementById("user_password").addEventListener("keydown", go_next_3, false);
    document.getElementById("buttonEye_1").addEventListener("click", btnEyeClick_1, false);
    document.getElementById("buttonEye_2").addEventListener("click", btnEyeClick_2, false);
});

// ユーザーID入力欄でエンターキーを押すと、ユーザー名入力欄にフォーカスが移動する
function go_next_1() {
    if (window.event.keyCode == 13) {
        document.querySelector("#user_Name").focus();
    }
}

// ユーザー名入力欄でエンターキーを押すと、パスワード入力欄にフォーカスが移動する
function go_next_2() {
    if (window.event.keyCode == 13) {
        document.querySelector("#user_password").focus();
    }
}

// パスワード入力欄でエンターキーを押すと、パスワード（確認用）入力欄にフォーカスが移動する
function go_next_3() {
    if (window.event.keyCode == 13) {
        document.querySelector("#user_password_confirmation").focus();
    }
}
console.log(sessionStorage.getItem("Detail_UserID"));
if (sessionStorage.getItem("Detail_UserID")) {
    // ユーザー登録確認画面から戻るボタンを押下されて帰ってきた場合
    document.querySelector("#user_ID").value = sessionStorage.getItem("Detail_UserID");
    document.querySelector("#user_Name").value = decodeURI(sessionStorage.getItem("Detail_UserName"));
    document.querySelector("#user_password").value = sessionStorage.getItem("Detail_Password");
    document.querySelector("#user_password_confirmation").value = sessionStorage.getItem("Detail_Password");
    iAdmin = sessionStorage.getItem("Detail_AdminCheck");
    if (iAdmin == 1) {
        $('input[value="0"]').prop('checked', true);
    } else if (iAdmin == 0) {
        $('input[value="1"]').prop('checked', true);
    };
    console.log(sessionStorage.getItem("hUserID"));
    if (sessionStorage.getItem('hUserID') != null) {
        // ユーザー登録確認画面で戻るを押下して来た場合（ユーザー名を押して更新モードの時）
        const hUserID = sessionStorage.getItem('hUserID');
        document.querySelector("#registration_button").value = "更新";
        sessionStorage.setItem("koushin_mode", "Yes");
        document.querySelector('#user_ID').readOnly = true;
    } else {
        // ユーザー登録確認画面で戻るを押下して来た場合（新規登録モードの時）
        document.querySelector("#user_ID").focus();
        document.getElementById("delete_button").style.visibility = "hidden";
        document.getElementById("delete_button").classList.remove("btn-outline-danger");
        document.getElementById("delete_button").classList.add("btn-secondary");
    }
} else {
    if (sessionStorage.getItem('hUserID') != null) {
        // ユーザー検索画面でユーザー名を押下して来た場合
        const hUserID = sessionStorage.getItem('hUserID');
        document.querySelector("#registration_button").value = "更新";
        sessionStorage.setItem("koushin_mode", "Yes");
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Load",
                "User_ID": hUserID
            },
            dataType: "json",
            success: function (data) {
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
                            document.querySelector('#user_ID').readOnly = true;
                        };
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    } else {
        // ユーザー検索画面で新規登録ボタンを押下してきた場合
        document.querySelector("#user_ID").focus();
        document.getElementById("delete_button").style.visibility = "hidden";
        document.getElementById("delete_button").classList.remove("btn-outline-danger");
        document.getElementById("delete_button").classList.add("btn-secondary");
        if (sessionStorage.getItem("Detail_UserID") != null) {
            document.querySelector("#user_ID").value = sessionStorage.getItem("Detail_UserID");
            document.querySelector("#user_Name").value = sessionStorage.getItem("Detail_UserName");
            document.querySelector("#user_password").value = sessionStorage.getItem("Detail_Password");
            document.querySelector("#user_password_confirmation").value = sessionStorage.getItem("Detail_Password");
            iAdmin = sessionStorage.getItem("Detail_AdminCheck");
            if (iAdmin != "") {
                if (iAdmin == 1) {
                    $('input[value="0"]').prop('checked', true);
                } else if (iAdmin == 0) {
                    $('input[value="1"]').prop('checked', true);
                };
            };
        }
    }
}


let error_judgement = [0, 0, 0, 0, 0, 0];
let User_ID;
let Password;
let User_Name;
let Admin_Check;
// 登録ボタンクリック
function btnRegistrationClick() {
    // バリデータのクリア
    for (let i = 1; i < 6; i++) {
        if (document.querySelector(`#p_${i}`)) {
            let delChild = document.querySelector(`#error_message_div_${i}`).firstChild;
            if (delChild) {
                document.querySelector(`#error_message_div_${i}`).removeChild(delChild);
            }
            document.querySelector(`#error_message_div_${i}`).style.marginLeft = "200px";
            document.querySelector(`#error_message_div_${i}`).textAlign = "left";
        };
    };

    User_ID = $("#user_ID").val();
    Password = $("#user_password").val();
    const Password_confirmation = $("#user_password_confirmation").val();
    User_Name = $("#user_Name").val();
    Admin_Check = $('input[name="contact"]:checked').val();

    if (Admin_Check == "0") {
        Admin_Check = 1;
    } else if (Admin_Check == "1") {
        Admin_Check = 0;
    };

    // ラジオボタンのバリデータ
    const form = document.querySelector("#form1");
    error_judgement = [0, 0, 0, 0, 0, 0];
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
        error_judgement[3] = 1;
        const error_p = document.createElement('p');
        error_p.textContent = "管理者を選択してください。";
        error_p.style.color = "#dc3545";
        error_p.className = "h6";
        error_p.id = `p_3`;
        document.querySelector("#error_message_div_3").appendChild(error_p);
    }

    var error_message = "";
    // ラジオボタン以外のバリデータ
    var c_element = 0;
    form.querySelectorAll('.form-control').forEach(function (elm) {
        var color_flag = "green";
        error_message = "";
        var style_change = "No";
        if (c_element == 2) {
            c_element += 2;
        } else {
            c_element += 1;
        };

        var maxlen = elm.getAttribute('data-maxlen');
        var regexp = elm.getAttribute('data-regexp');
        if (elm.value == "") {
            color_flag = "red";
            error_judgement[c_element] = 1;
            // エラーメッセージを入れる
            const error_message_p = document.createElement("p");
            if (c_element == 1) {
                error_message_p.textContent = "ユーザーIDを入力してください。";
            }else if (c_element == 2){
                error_message_p.textContent = "ユーザー名を入力してください。";
            } else if (c_element == 4) {
                error_message_p.textContent = "パスワードを入力してください。";
            } else if (c_element == 5) {
                error_message_p.textContent = "パスワード（確認用）を入力してください。";
            }
            error_message = error_message_p.textContent;
        } else if ((maxlen && (maxlen < elm.value.length)) ||
            (regexp && !(elm.value.match(regexp))) && c_element != 5) {
            const error_message_div = document.querySelector(`#error_message_div_${c_element}`);
            color_flag = "red";
            error_judgement[c_element] = 1;
            const error_message_p = document.createElement("p");
            const p_textcontent = document.querySelector(`#label_${c_element}`).textContent;
            if (c_element == 1) {
                error_message_p.textContent = "ユーザーIDは半角数字5桁で入力してください。";
            } else if (c_element == 4) {
                error_message_p.textContent = "パスワードは半角英数字8～20文字以下で入力してください。";
                style_change = "Yes";
            } else if (c_element == 5) {
                error_message_p.textContent = "パスワード（確認用）は半角英数字8～20文字以下で入力してください。";
                style_change = "Yes";
            } else {
                error_message_p.textContent = `${p_textcontent}を入力してください。`;
            }
            error_message = error_message_p.textContent;

        } else if ((c_element == 5) && (document.querySelector("#user_password").value != document.querySelector("#user_password_confirmation").value)) {
            const i_element = document.querySelector("#user_password");
            const u_element = document.querySelector("#user_password_confirmation");
            color_flag = "red";
            error_judgement[c_element] = 1;
            const error_message_p = document.createElement("p");
            error_message_p.textContent = "パスワードが一致しません。";
            error_message = error_message_p.textContent;

        } else if (c_element == 2) {
            if (elm.value.match(/^[ 　]{1,}/)) {
                color_flag = "red";
                error_judgement[c_element] = 1;
                const error_message_div = document.querySelector(`#error_message_div_${c_element}`);
                const error_message_p = document.createElement("p");
                error_message_p.className = "h6";
                error_message_p.id = `p_${c_element}`;
                error_message_p.style.color = "#dc3545";

                error_message_p.textContent = "ユーザー名は半角数字5桁で入力してください。";
                error_message = error_message_p.textContent;
            } else {
                // 緑にする
                color_flag = "green";
                error_judgement[c_element] = 0;
            }
        } else {
            if ((c_element != 5 && c_element != 4) || (c_element == 5 && error_judgement[4] == 0)) {
                // 緑にする
                color_flag = "green";
                error_judgement[c_element] = 0;
            }
        }
        if (color_flag == "red") {
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
            error_judgement[c_element] = 1;
            elm.parentNode.style.borderColor = "#dc3545";
            const error_message_div = document.querySelector(`#error_message_div_${c_element}`);
            const error_message_p = document.createElement("p");
            error_message_p.className = "h6";
            error_message_p.id = `p_${c_element}`;
            if (style_change == "Yes") {
                error_message_div.style.marginLeft = null;
                error_message_div.style.textAlign = "right";
            } else {
                error_message_div.style.marginLeft = "200px";
                error_message_div.style.textAlign = "left";
            }
            
            error_message_p.style.color = "#dc3545";
            error_message_p.textContent = error_message;
            error_message_div.appendChild(error_message_p);
        } else {
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
            elm.parentNode.style.borderColor = "#198754";
        }
    });
    if (error_judgement[5] == 1) {
        const elm = document.querySelector("#user_password");
        elm.classList.add('is-invalid');
        elm.classList.remove('is-valid');
        error_judgement[c_element] = 1;
        elm.parentNode.style.borderColor = "#dc3545";
    }
    if (error_judgement[4] == 1) {
        const elm = document.querySelector("#user_password_confirmation");
        elm.classList.add('is-invalid');
        elm.classList.remove('is-valid');
        error_judgement[c_element] = 1;
        elm.parentNode.style.borderColor = "#dc3545";
    }
    if (error_judgement[1] == 0) {
        if (!sessionStorage.getItem('hUserID')) {
            elm = document.querySelector("#user_ID");
            // 既に登録されているユーザーIDがないかチェック
            const User_ID = encodeURI(elm.value);
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
                        if (data.status == "OK") {
                            if (data.ErrorMessage != "") {
                                // 赤にする
                                color_flag = "red";
                                error_judgement[1] = 1;
                                
                                const error_message_div = document.querySelector(`#error_message_div_1`);
                                var error_message_p = document.createElement("p");
                                error_message_p.className = "h6";
                                error_message_p.id = `p_1`;
                                error_message_p.style.color = "#dc3545";
                                error_message_p.textContent = data.ErrorMessage;
                                error_message = error_message_p.textContent;
                                const elm = document.querySelector("#user_ID");
                                elm.classList.add('is-invalid');
                                elm.classList.remove('is-valid');
                                elm.parentNode.style.borderColor = "#dc3545";
                                error_message_p.textContent = error_message;
                                error_message_div.appendChild(error_message_p);

                                f_errorjudgement();
                            }
                            f_errorjudgement();
                        } else {
                            alert("エラーが発生しました。");
                        };
                    };
               }
            });
        } else {
            f_errorjudgement();
        }
    }
    else {
        f_errorjudgement();
    }
}

function f_errorjudgement() {
    if (error_judgement.every(v => v == 0)) {
        // 入力チェックで引っかかるものがなかった場合
        sessionStorage.setItem("iUser_ID", User_ID);
        sessionStorage.setItem("iPassword", Password);
        sessionStorage.setItem("iUser_Name", User_Name);
        sessionStorage.setItem("iAdmin_Check", Admin_Check);
        location.href = "Confirm.aspx";
    };
};

// 削除ボタンを押された時の処理
function btnDeleteClick() {
    if (document.querySelector(`#p_1`)) {
        let delChild = document.querySelector(`#error_message_div_1`).firstChild;
        if (delChild) {
            document.querySelector(`#error_message_div_1`).removeChild(delChild);
        }
        document.querySelector(`#error_message_div_1`).style.marginLeft = "200px";
        document.querySelector(`#error_message_div_1`).textAlign = "left";
    };
    var User_ID = iUserID;
    var Password = iPassword;
    var Password_confirmation = iPassword;
    var User_Name = iUserName;
    var Admin_Check = iAdmin;
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search_Delete",
            "User_ID": User_ID
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (data.ErrorMessage != "") {
                        // 赤にする
                        const elm = document.querySelector("#user_ID")
                        elm.classList.add('is-invalid');
                        elm.classList.remove('is-valid');
                        elm.parentNode.style.borderColor = "#dc3545";
                        const error_message_div = document.querySelector(`#error_message_div_1`);
                        const error_message_p = document.createElement("p");
                        error_message_p.className = "h6";
                        error_message_p.id = `p_1`;
                        error_message_p.style.color = "#dc3545";
                        error_message_p.textContent = data.ErrorMessage;
                        error_message_div.appendChild(error_message_p);
                        error_message_div.style.marginLeft = "100px";

                    } else {
                        sessionStorage.setItem("iUser_ID", User_ID);
                        sessionStorage.setItem("iPassword", Password);
                        sessionStorage.setItem("iUser_Name", User_Name);
                        sessionStorage.setItem("iAdmin_Check", Admin_Check);
                        sessionStorage.setItem("dUser_ID", User_ID);
                        window.location.href = "Confirm.aspx";
                    }
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });    
}

// 戻るボタンを押したときの処理
function btnBackClick() {
    sessionStorage.removeItem('hUserID');
    sessionStorage.removeItem('dUser_ID');
    sessionStorage.removeItem('Detail_UserID');
    sessionStorage.removeItem('Detail_UserName');
    sessionStorage.removeItem('Detail_AdminCheck');
    sessionStorage.removeItem('Detail_Password');
    sessionStorage.removeItem('koushin_mode');
    if (sessionStorage.getItem("iUser_ID")) {
        sessionStorage.removeItem('iUser_ID');
        sessionStorage.removeItem('iPassword');
        sessionStorage.removeItem('iUser_Name');
        sessionStorage.removeItem('iAdmin_Check');
    }
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

// パスワード（確認用）入力欄の横にある👁を押すと、入力したパスワードが見えるようになったり見えなくなったりするようになる
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
