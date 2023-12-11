//ログインされているかをチェックする関数
function_login_check();
DspLoginUserName();

var Ajax_File = "Confirm.ashx";
const re_UserID = sessionStorage.getItem('UserID');
const User_ID = sessionStorage.getItem("iUser_ID");
const User_Name = sessionStorage.getItem("iUser_Name");
const Admin_Check = sessionStorage.getItem("iAdmin_Check");
const Password = sessionStorage.getItem("iPassword");
const hUser_ID = sessionStorage.getItem("hUserID");
var location_flag = 0;

document.querySelector("#user_ID").value = User_ID;
document.querySelector("#user_Name").value = User_Name;
document.querySelector("#user_password").value = Password;
document.querySelector("#user_password_confirmation").value = Password;

if (Admin_Check == 0) {
    document.querySelector("#Admin_input").value = "OFF";
} else if (Admin_Check == 1) {
    document.querySelector("#Admin_input").value = "ON";
};

const dUser_ID = sessionStorage.getItem("dUser_ID");
if (dUser_ID) {
    // ユーザー登録画面で削除ボタンを押下してきた場合
    const registration_button = document.getElementById("registration_button");
    registration_button.id = "delete_button";
    registration_button.value = "削除";
    registration_button.classList.remove("btn-outline-primary");
    registration_button.classList.add("btn-outline-danger");
    document.getElementById("delete_button").addEventListener("click", btnDeleteClick, false);
} else {
    // ユーザー検索画面で登録ボタンを押下してきた場合
    if (sessionStorage.getItem("koushin_mode") == "Yes") {
        document.querySelector("#registration_button").value = "更新";
    }
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
};

$(function () {
    document.getElementById("back_button").addEventListener("click", btnBackClick, false);
});

// 登録ボタンクリック
function btnRegistrationClick() {
    const hUserID = sessionStorage.getItem("hUserID");
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            mode: "Save",
            "User_ID": User_ID,
            "Password": Password,
            "User_Name": User_Name,
            "Admin_Check": Admin_Check,
            "Re_UserID": re_UserID,
            "hUser_ID": hUserID
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (data.ErrorMessage == "") {
                        if (data.Mode == "Ins") {
                            // 新規登録が完了した
                            sessionStorage.removeItem('Detail_UserID');
                            sessionStorage.removeItem('Detail_UserName');
                            sessionStorage.removeItem('Detail_AdminCheck');
                            sessionStorage.removeItem('Detail_Password');
                            $('#staticBackdrop1').modal('show');
                        } else {
                            // 更新が完了した
                            const modal_sentence1 = document.querySelector('#modal_sentence1');
                            modal_sentence1.textContent = "更新が完了しました。";
                            $('#staticBackdrop1').modal('show');
                            sessionStorage.removeItem('koushin_mode');
                        };
                        sessionStorage.removeItem('hUserID');
                        if (sessionStorage.getItem("dUser_ID")) {
                            sessionStrorage.removeItem('dUser_ID');
                        }
                        document.querySelector('#modal_close1').addEventListener('click', functionSeni_Index);
                    } else {
                        // 追加しようとしたユーザーが既に登録されていた場合
                        $('#staticBackdrop3').modal('show');
                        document.querySelector('#modal_close3').addEventListener('click', functionSeni_Detail);
                    };                    
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// クッキーの情報を削除して、ユーザー検索画面に遷移する
function functionSeni_Index() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Clear",
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    window.location.href = "Index.aspx";
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
    window.location.href = "Index.aspx";
};

// ユーザー登録画面に遷移する
function functionSeni_Detail() {
    if (location_flag == 1) {
        functionSeni_Index();
    } else {
        window.location.href = "Detail.aspx";
    }
};

// 該当するデータを削除する
function btnDeleteClick() {
    $('#staticBackdrop5').modal('show');
    document.querySelector('#modal_Yes').addEventListener('click', fnc_Yes);
    document.querySelector('#modal_No').addEventListener('click', fnc_No);
}

// 本当に削除してよいかのモーダルで削除ボタンを押下した場合
function fnc_Yes() {
    const hUserID = sessionStorage.getItem('hUserID');
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            mode: "Delete",
            "User_ID": hUserID
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                console.log(data);
                if (data.status == "OK") {
                    // 表示するコードを書く
                        
                    sessionStorage.removeItem("hUserID");
                    if (sessionStorage.getItem("dUser_ID")) {
                        sessionStorage.removeItem("dUser_ID");
                    };
                    if (data.ErrorMessage == "") {
                        // 削除が完了した場合
                        sessionStorage.removeItem("koushin_mode");
                        const modal_sentence2 = document.querySelector('#modal_sentence1');
                        modal_sentence2.textContent = "削除が完了しました。";
                        $('#staticBackdrop1').modal('show');
                    } else {
                        // ログインしているユーザーを削除しようとした場合
                        location_flag = 1;
                        const modal_sentence4 = document.querySelector('#modal_sentence3');
                        modal_sentence4.textContent = "現在ログインしているユーザーのため、削除することが出来ません。";
                        $('#staticBackdrop3').modal('show');
                        document.querySelector('#modal_close3').addEventListener('click', functionSeni_Index);
                    }
                    
                    document.querySelector('#modal_close1').addEventListener('click', functionSeni_Index);
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    })
};

// 本当に削除してよいかのモーダルでキャンセルボタンを押下した場合
function fnc_No() {
    $('#staticBackdrop5').modal('hide');
};

// 戻るボタンを押下した場合
function btnBackClick() {
    if (sessionStorage.getItem('dUser_ID')) {
        sessionStorage.removeItem('dUser_ID');
    }
    // 新規登録画面から確認画面に来て戻るボタンを押下した場合
    sessionStorage.setItem("Detail_UserID", User_ID);
    sessionStorage.setItem("Detail_UserName", User_Name);
    sessionStorage.setItem("Detail_AdminCheck", Admin_Check);
    sessionStorage.setItem("Detail_Password", Password);

    window.location.href = "Detail.aspx";
};
