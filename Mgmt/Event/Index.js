let Ajax_File = "Index.ashx";

$(function () {
    document.getElementById("Searchbtn").addEventListener("mouseup", SearchbtnClick, false)
    document.getElementById("Backbtn").addEventListener("mouseup", BackbtnClick, false)
    document.getElementById("Closebtn").addEventListener("mouseup", ClosebtnClick, false)
});

// 検索ボタンクリック
function SearchbtnClick() {

    let Event = $("#txtEvent").val();
    let EventStatus = "";
    let DateFm = $("#txtDateFm").val();
    let DateTo = $("#txtDateTo").val();
    let Keyword = $("#txtKeyword").val();
    let work = "";

    if ($("input[name=EventStatus]:checked").is(':checked')) {
        EventStatus = $('input[name="EventStatus"]:checked').val();

        if (DateFm != "" && DateTo != "") {
            if (DateFm > DateTo) {
                work = DateFm;
                DateFm = DateTo;
                DateTo = work;
                $("#txtDateFm").val(DateFm);
                $("#txtDateTo").val(DateTo);
            };
        };

        $.ajax({
            url: Ajax_File,
            method: "POST",
            data: {
                "mode": "Search",
                "Event": Event,
                "EventStatus": EventStatus,
                "DateFm": DateFm,
                "DateTo": DateTo,
                "Keyword": Keyword
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
    };


    function MakeItiran() {
        document.getElementById("CntArea").innerText = "";
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
                        if (Number(data.count) > 0) {
                            document.getElementById("CntArea").innerText = "件数：" + data.count + "件";
                            if (data.html != "") {
                                document.getElementById("ItiranArea").innerHTML = data.html;
                            };
                        } else {
                            document.getElementById("ItiranArea").innerText = "該当するユーザーが存在しません。";
                        };
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    };
};

function BackbtnClick() {
    location.href = "../Menu/Index.aspx";
};

function ClosebtnClick() {
    
};