// global変数
let Ajax_File = "Index.ashx";

// ボタンクリック時の関数
$(function () {
    document.getElementById("btnSearch").addEventListener("mouseup", btnSearchClick, false);
});

// 検索処理
function btnSearchClick() {
    // 入力値取得
    let DisplayName = $("#txtDisplayName").val();

    // 非同期通信でデータベース検索
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Search",
            "DisplayName": DisplayName
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    if (Number(data.count) > 0) {
                        MakeItiran();
                    } else {
                        document.getElementById("ItiranArea").innerText = "該当するユーザーが存在しません。";
                    };
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
}

// 一覧を生成
function MakeItiran() {
    document.getElementById("ItiranArea").innerHTML = "";

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Itiran"
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    document.getElementById("ItiranArea").innerHTML = data.html
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};