let Ajax_File = "Detail.ashx";

$(function () {
    document.getElementById("Savebtn").addEventListener("mouseup", SavetbtnClick, false);
    document.getElementById("Deletebtn").addEventListener("mouseup", DeletebtnClick, false);
    document.getElementById("Backbtn").addEventListener("mouseup", BackbtnClick, false);
    document.getElementById("MessageAddbtn").addEventListener("mouseup", MessageAddbtnClick, false);
})

function SavebtnClick() {

    let sName = "";
    let sAge = "";
    let sAddress = "";

    sName = $("#txtSaveName").val();
    sAge = $("#txtSaveAge").val();
    sAddress = $("#txtSaveAddress").val();

    if (sName == "") {
        alert("氏名を入力してください。")
        return false;
    };

    if (sAge == "") {
        alert("年齢を入力してください。")
        return false;
    };

    if (sAddress == "") {
        alert("住所を入力して下さい。");
        return false;
    };

    if (!window.confirm("登録を行いますか？")) {
        return false;
    };

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Save",
            "UserID": $("#hdUserID").val(),
            "Name": sName,
            "Age": sAge,
            "Address": sAddress
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    alert("登録が完了しました。");
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

function BackbtnClick() {
    let f = document.forms["main"];
    f.submit();
    return true;
};

function MessageAddbtnClick() {

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "MessageAdd",
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    alert("登録が完了しました。");
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};
