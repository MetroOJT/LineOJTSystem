//ログインなされているかをチェックする関数
function_login_check();
DspLoginUserName();
var Ajax_File = "Confirm.ashx";

const re_UserID = sessionStorage.getItem('UserID');
const User_ID = sessionStorage.getItem("iUser_ID");
const User_Name = sessionStorage.getItem("iUser_Name");
const Admin_Check = sessionStorage.getItem("iAdmin_Check");
const Password = sessionStorage.getItem("iPassword");
const hUser_ID = sessionStorage.getItem("hUserID");

console.log(re_UserID);
console.log(User_ID);
console.log(User_Name);
console.log(Admin_Check);
console.log(Password);


document.querySelector("#user_ID").value = User_ID;
document.querySelector("#user_Name").value = User_Name;
document.querySelector("#user_password").value = Password;
document.querySelector("#user_password_confirmation").value = Password;

if (Admin_Check == 0) {
    document.querySelector("#Admin_input").value = "オフ";
} else if (Admin_Check == 1) {
    document.querySelector("#Admin_input").value = "オン";
};

const dUser_ID = sessionStorage.getItem("dUser_ID");
//console.log(dUser_ID);
if (dUser_ID) {
    const registration_button = document.getElementById("registration_button");
    registration_button.id = "delete_button";
    registration_button.value = "削除";
    registration_button.classList.remove("btn-outline-primary");
    registration_button.classList.add("btn-outline-danger");
    document.getElementById("delete_button").addEventListener("click", btnDeleteClick, false);
} else {
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
            //console.log(data);
            if (data != "") {
                if (data.status == "OK") {
                    if (data.ErrorMessage == "") {
                        if (data.Mode == "Ins") {
                            // 新規登録が完了した
                            $('#staticBackdrop1').modal('show');
                        } else {
                            // 更新が完了した
                            const modal_sentence1 = document.querySelector('#modal_sentence1');
                            modal_sentence1.textContent = "更新が完了しました";
                            $('#staticBackdrop1').modal('show');
                        };
                        sessionStorage.removeItem('hUserID');
                        if (sessionStorage.getItem("dUser_ID")) {
                            sessionStrorage.removeItem('dUser_ID');
                        }
                        document.querySelector('#modal_close1').addEventListener('click', functionSeni_Index);
                    } else {
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

function functionSeni_Index() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Clear",
        },
        dataType: "json",
        success: function (data) {
            console.log(data);
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

function functionSeni_Detail() {
    window.location.href = "Detail.aspx";
};

// 該当するデータを削除する
function btnDeleteClick() {
    $('#staticBackdrop5').modal('show');
    document.querySelector('#modal_Yes').addEventListener('click', fnc_Yes);
    document.querySelector('#modal_No').addEventListener('click', fnc_No);
}

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
            //console.log(data);
            if (data != "") {
                if (data.status == "OK") {
                    // 表示するコードを書く
                    sessionStorage.removeItem("hUserID");
                    if (sessionStorage.getItem("dUser_ID")) {
                        sessionStorage.removeItem("dUser_ID");
                    };
                    const modal_sentence2 = document.querySelector('#modal_sentence1');
                    modal_sentence2.textContent = "削除が完了しました";
                    $('#staticBackdrop1').modal('show');
                    document.querySelector('#modal_close1').addEventListener('click', functionSeni_Index);
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    })
};

function fnc_No() {
    $('#staticBackdrop5').modal('hide');
};

function btnBackClick() {
    sessionStorage.removeItem('iUser_ID');
    sessionStorage.removeItem('iPassword');
    sessionStorage.removeItem('iUser_Name');
    sessionStorage.removeItem('iAdmin_Check');
    if (sessionStorage.getItem('dUser_ID')) {
        sessionStorage.removeItem('dUser_ID');
    }
    window.location.href = "Detail.aspx";
};
