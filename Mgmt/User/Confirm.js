var Ajax_File = "Detail.ashx";

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


$(function () {
    document.getElementById("registration_button").addEventListener("click", btnRegistrationClick, false);
    document.getElementById("back_button").addEventListener("click", btnBackClick, false);
});

// 登録ボタンクリック
function btnRegistrationClick() {
    const hUserID = sessionStorage.getItem("hUserID");
    console.log("a", hUserID);
    if (!hUserID) {
        console.log("a");
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
                if (data != "") {
                    if (data.status == "OK") {
                        alert("追加が完了しました");
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    } else {
        console.log("b");
        // 更新
        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                mode: "Update",
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
                        console.log("更新しました");
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    }
    
};

function btnBackClick() {
    window.history.back();
};
