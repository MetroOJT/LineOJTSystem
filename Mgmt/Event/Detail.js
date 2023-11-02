//ログインなされているかをチェックする関数
function_login_check();

let Ajax_File = "Detail.ashx";

//直前に閲覧したページのURLを保持しておく変数
let Referrer = document.referrer;



$(function () {
    //ヘッダーの担当者名を入れる関数
    DspLoginUserName();

    document.getElementById("Savebtn").addEventListener("mouseup", SavebtnClick, false);
    document.getElementById("Deletebtn").addEventListener("mouseup", DeletebtnClick, false);
    document.getElementById("Backbtn").addEventListener("mouseup", BackbtnClick, false);
    document.getElementById("MessageAddbtn").addEventListener("mouseup", MessageAddbtnClick, false);

    //登録モードか更新モードかを判別する
    if (sessionStorage.getItem("EventID") != null) {
        EventLoad();
        $("#Deletebtn").prop("disabled", false);
    } else {
        MessageAddbtnClick();
        $("#Deletebtn").prop("disabled", true);
    }
})

//更新するデータをロードする関数
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
                    //更新対象のデータをフォームに入力された状態で表示
                    $("#Savebtn").val("更新");
                    $("#txtEventName").val(data.EventName);
                    console.log(data.EventStatus)
                    if (data.EventStatus == 1) {
                        $('input[value="1"]').prop('checked', true);
                    } else if (data.EventStatus == 0) {
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

                    //テキストの文字数を初期値として設定
                    for (let i = 0; i < $(".MessageContainer").length; i++) {
                        let txtMessagelength = $("#txtMessage" + i).val().length;
                        $("#txtCount" + i).text(txtMessagelength + "/500");
                    }

                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

//登録・更新を行う関数
function SavebtnClick() {

    let EventName = $("#txtEventName").val();
    let EventStatus = "";
    let ScheduleFm = $("#txtScheduleFm").val();
    let ScheduleTo = $("#txtScheduleTo").val();
    let Keyword = $("#txtKeyword").val();
    let Messages = [];
    let work = "";

    //スケジュールの日付を整形
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
    let form = document.querySelector('#main');
    let elm = form.querySelectorAll('.form-control')
    console.log(elm)
    //各データの入力チェック
    form.querySelectorAll('.form-control').forEach(function (elm) {
        let required = elm.required;
        if (required && (elm.value.length == 0)) {
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
            event.preventDefault();
            event.stopPropagation();
        } else {
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
        }
    })

    
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

    //空白のメッセージコンテナがないか、メッセージが一つ以上入力されているかを判別
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

    //メッセージをリストに入れこむ
    for(ele of document.getElementsByClassName("txtMessage")) {
        Messages.push(ele.value)
    }

    //確認アラート表示
    if ($("#Savebtn").val() == "登録") {
        if (!window.confirm("登録を行いますか？")) {
            return false;
        };
    } else {
        if (!window.confirm("更新を行いますか？")) {
            return false;
        };
    }
    
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
            "Update_UserID": sessionStorage.getItem("UserID"),
            "Update_EventID": sessionStorage.getItem("EventID")
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {

                    if (data.ErrorMessage != "") {
                        alert(data.ErrorMessage);
                    } else {
                        //完了アラート表示
                        if (data.Mode == "Ins") {
                            alert("登録が完了しました。");
                        } else {
                            alert("更新が完了しました。");
                        }
                        
                        //更新・登録したEventIDをセッション変数としてセットする
                        sessionStorage.setItem("EventID", data.EventID)

                        //ページをリロードし、登録ページの場合は更新ページに切り替わる
                        window.location.reload(true);
                    }

                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

//データを削除する関数
function DeletebtnClick() {

    //確認アラート
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
                    //完了アラート
                    alert("データを削除しました。");

                    //セッション変数「EventID」を削除する
                    sessionStorage.removeItem("EventID");

                    //直前に閲覧したページに遷移する
                    window.location.href = Referrer;
                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

//直前に閲覧したページに戻る関数
function BackbtnClick() {
    sessionStorage.removeItem("EventID");
    window.location.href = Referrer;
};

//メッセージコンテナを一つ追加する関数
function MessageAddbtnClick() {

    //現在のメッセージコンテナの数を取得しcookieにセット
    let Container_num = $(".MessageContainer").length
    setCookie("iCnt", Container_num, 1);

    //メッセージが5つ以下かそうではないかを判定する
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
                        //data.htmlが文字列なのでhtml要素に変換する
                        let html = createElementFromHTML(data.html);

                        //メッセージエリアにメッセージコンテナを追加する
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

//メッセージコンテナの位置替えを行う関数(上のコンテナと位置替え)
function MessageUpbtnClick() {
    let UpIndex;
    let MessageArea = document.getElementById("MessageArea");
    let MessageContainer = MessageArea.getElementsByClassName("MessageContainer");
    //位置替え対象コンテナのidを取得
    let UpId = $(event.target).parent().parent().parent().attr("id");
    
    //位置替え対象のidを検索(idが順番通りに並んでいない可能性があるため)
    for (let i = 0; i < MessageContainer.length; i++) {
        if (UpId == MessageContainer[i].id) {
            UpIndex = i;
            break;
        }
    }

    //位置替えを実行する
    if (UpIndex != 0) {
        MessageArea.insertBefore(MessageContainer[UpIndex], MessageContainer[UpIndex - 1])
    }

}

//メッセージコンテナの位置替えを行う関数(下のコンテナと位置替え)
function MessageDownbtnClick() {
    let DownIndex;
    let MessageArea = document.getElementById("MessageArea");
    let MessageContainer = MessageArea.getElementsByClassName("MessageContainer");
    let DownId = $(event.target).parent().parent().parent().attr("id");

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

//対象メッセージコンテナを削除する関数
function MessageDeletebtnClick() {

    //メッセージコンテナが２つ以上ある時のみ削除する
    if (document.getElementsByClassName("txtMessage").length > 1) {
        $(event.target).parent().parent().parent().remove();

        //削除した後にメッセージコンテナ要素のidを整理する
        for (var i = 0; i <= document.getElementsByClassName("MessageContainer").length - 1; i++) {
            document.getElementsByClassName("MessageUpbtn")[i].id = "MessageUpbtn" + i;
            document.getElementsByClassName("MessageDownbtn")[i].id = "MessageDownbtn" + i;
            document.getElementsByClassName("MessageDeletebtn")[i].id = "MessageDeletebtn" + i;
            document.getElementsByClassName("txtMessage")[i].id = "txtMessage" + i;
            document.getElementsByClassName("CouponCodeAddbtn")[i].id = "CouponCodeAddbtn" + i;
            document.getElementsByClassName("txtCount")[i].id = "txtCount" + i;

        }
        setCookie("iCnt", i, 1);
    }
}

//クーポンコードをテキストエリアに追加する関数
function CouponCodeAddbtnClick() {
    let ID = $(event.target).attr("id").slice(-1);
    let CouponCode = getCookie("CouponCode");
    document.getElementById("txtMessage" + ID).value += CouponCode;
}

//テキストエリア内の文字数をリアルタイムに反映する関数
function txtCountUpd() {
    let txtMessagelength = $(event.target).val().length;
    let ID = $(event.target).attr("id").slice(-1);
    $("#txtCount" + ID).text(txtMessagelength + "/500");
}


