let Ajax_File = "Detail.ashx";
let Referrer = document.referrer;
console.log(Referrer);

$(function () {
   
    document.getElementById("Savebtn").addEventListener("mouseup", SavebtnClick, false);
    document.getElementById("Deletebtn").addEventListener("mouseup", DeletebtnClick, false);
    document.getElementById("Backbtn").addEventListener("mouseup", BackbtnClick, false);
    document.getElementById("MessageAddbtn").addEventListener("mouseup", MessageAddbtnClick, false);
    if (sessionStorage.getItem("EventID") != null) {
        EventLoad();
    } else {
        MessageAddbtnClick();
    }
    
    
})

function EventLoad() {
    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Load",
            "EventID": sessionStorage.getItem("EventID")
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    alert("Load成功");
                    $("#txtEventName").val(data.EventName);
                    if (data.EventStatus == 1) {
                        $('input[value="1"]').prop('checked', true);
                    } else if (data.EventStatus === 0) {
                        $('input[value="0"]').prop('checked', true);
                    }
                    let ScheduleFm = data.ScheduleFm.replaceAll("/", "-");
                    
                    if (ScheduleFm != "1900-01-01") {
                        $("#txtScheduleFm").val(ScheduleFm);
                    } else {
                        $("#txtScheduleFm").val("");
                    }

                    let ScheduleTo = data.ScheduleTo.replaceAll("/", "-");
                    if (ScheduleTo != "2099-12-31") {
                        $("#txtScheduleTo").val(ScheduleTo);
                    } else {
                        $("#txtScheduleTo").val("");
                    }
                    
                    $("#txtKeyword").val(data.Keyword);

                    document.getElementById("MessageArea").innerHTML = data.Html;

                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};


function SavebtnClick() {

    let EventName = $("#txtEventName").val();
    let EventStatus = "";
    let ScheduleFm = $("#txtScheduleFm").val();
    let ScheduleTo = $("#txtScheduleTo").val();
    let Keyword = $("#txtKeyword").val();
    let Messages = [];
    let work = "";

    if ($("input[name=EventStatus]:checked").is(':checked')) {
        EventStatus = $('input[name="EventStatus"]:checked').val();

        if (ScheduleFm != "" && ScheduleTo != "") {
            if (ScheduleFm > ScheduleTo) {
                work = ScheduleFm;
                ScheduleFm = ScheduleTo;
                ScheduleTo = work;
                $("#txtScheduleFm").val(ScheduleFm);
                $("#txtScheduleTo").val(ScheduleTo);
            };
        };
    };


    if (EventName == "") {
        alert("イベント名を入力してください。")
        return false;
    };

    if (EventStatus == "") {
        alert("ステータスを選択してください。")
        return false;
    };

    if (ScheduleFm == "" && ScheduleTo == "") {
        alert("スケジュールを入力して下さい。");
        return false;
    };

    if (Keyword == "") {
        alert("キーワードを入力して下さい。");
        return false;
    };
   
    if (document.getElementsByClassName("txtMessage").length != 0) {
        for(ele of document.getElementsByClassName("txtMessage")) {
            if (ele.value == "") {
                alert("メッセージを全て入力してください。");
                return false;
            }
        }
    } else {
        alert("メッセージを1つ以上入力してください。");
        return false;
    }

    for(ele of document.getElementsByClassName("txtMessage")){
        Messages.push(ele.value)
    }
    console.log(Messages)
  

    if (!window.confirm("登録を行いますか？")) {
        return false;
    };

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Save",
            "EventName": EventName,
            "EventStatus": EventStatus,
            "ScheduleFm": ScheduleFm,
            "ScheduleTo": ScheduleTo,
            "Keyword": Keyword,
            "Messages": Messages,
            "Update_UserID": sessionStorage.getItem("UserID")
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    alert("登録が完了しました。");
                    sessionStorage.setItem("EventID", data.EventID);
                    $('#Savebtn').prop('disabled', true);
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

function DeletebtnClick() {

    if (!window.confirm("本当に削除しますか？")) {
        return false;
    };

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "Delete",
            "EventID": sessionStorage.getItem("EventID")
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    alert("データを削除しました。");

                    location.href = Referrer

                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

function BackbtnClick() {
    location.href = "../Menu/Index.aspx";
};

function MessageAddbtnClick() {

    if (document.getElementsByClassName("MessageContainer").length < 5) {
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
                        let html = createElementFromHTML(data.html);
                        document.getElementById("MessageArea").appendChild(html);
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });
    } else {
        alert("メッセージは5つまでしか追加できません。")
    }

   
};

function MessageUpbtnClick() {
    let UpIndex;
    let MessageArea = document.getElementById("MessageArea");
    let MessageContainer = MessageArea.getElementsByClassName("MessageContainer");
    let UpId = $(event.target).parent().parent().attr("id");

    for (let i = 0; i < MessageContainer.length; i++) {
        if (UpId == MessageContainer[i].id) {
            UpIndex = i;
            break;
        }
    }

    if (UpIndex != 0) {
        MessageArea.insertBefore(MessageContainer[UpIndex], MessageContainer[UpIndex - 1])
    }
   
}

function MessageDownbtnClick() {
    console.log("test")
    let DownIndex;
    let MessageArea = document.getElementById("MessageArea");
    let MessageContainer = MessageArea.getElementsByClassName("MessageContainer");
    let DownId = $(event.target).parent().parent().attr("id");

    for (let i = 0; i < MessageContainer.length; i++) {
        if (DownId == MessageContainer[i].id) {
            DownIndex = i;
            break;
        }
    }

    if (DownIndex != MessageContainer.length - 1) {
        MessageArea.insertBefore(MessageContainer[DownIndex], MessageContainer[DownIndex + 2])
    }

}

function MessageDeletebtnClick() {
    console.log(document.getElementsByClassName("txtMessage").length)
    if (document.getElementsByClassName("txtMessage").length > 1) {
        $(event.target).parent().parent().remove();

        for (var i = 0; i <= document.getElementsByClassName("MessageContainer").length - 1; i++) {
            document.getElementsByClassName("MessageContainer")[i].id = "MessageContainer" + i;
        }
        setCookie("iCnt", i, 1);
    }    
}

function txtCountUpd() {
    console.log("test")
    let txtMessagelength = $(event.target).val().length;
    $(event.target).next().text(txtMessagelength + "/500")
}
    

    