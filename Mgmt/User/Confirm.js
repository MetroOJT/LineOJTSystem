//ログインなされているかをチェックする関数
// function_login_check();

var Ajax_File = "Confirm.ashx";

const re_UserID = sessionStorage.getItem('UserID');
const User_ID = sessionStorage.getItem("iUser_ID");
const User_Name = sessionStorage.getItem("iUser_Name");
const Admin_Check = sessionStorage.getItem("iAdmin_Check");
const Password = sessionStorage.getItem("iPassword");

console.log(User_ID);
console.log(Password);
console.log(User_Name);
console.log(Admin_Check);

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
    console.log("a", hUserID);
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
            console.log(data);
            if (data != "") {
                if (data.status == "OK") {
                    if (data.ErrorMessage == "") {
                        if (data.Mode == "Ins") {
                            alert("新規登録が完了しました。");
                        } else {
                            alert("更新が完了しました。");
                        };
                        sessionStorage.removeItem('hUserID');
                        if (sessionStorage.getItem("dUser_ID")) {
                            sessionStrorage.removeItem('dUser_ID');
                        }
                        window.location.href = "Index.aspx";
                    } else {
                        alert(data.ErrorMessage);
                    };                    
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

// 該当するデータを削除する
function btnDeleteClick() {
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
                        window.location.href = "index.aspx";
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        })
    }
}

function btnBackClick() {
    window.history.back();
};
