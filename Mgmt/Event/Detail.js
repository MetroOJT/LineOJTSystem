//ログインなされているかをチェックする関数
function_login_check();

let Ajax_File = "Detail.ashx";

//直前に閲覧したページのURLを保持しておく変数
let Referrer = document.referrer;

let EventName;
let EventStatus;
let ScheduleFm;
let ScheduleTo;
let Keyword;
let Messages;
let iniForm;

$(function () {
    //ヘッダーの担当者名を入れる関数
    DspLoginUserName();

    document.getElementById("Savebtn").addEventListener("mousedown", ModalAreaClear, false);
    document.getElementById("Deletebtn").addEventListener("mousedown", ModalAreaClear, false);

    document.getElementById("Savebtn").addEventListener("mouseup", SavebtnClick, false);
    document.getElementById("Deletebtn").addEventListener("mouseup", DeletebtnClick, false);
    document.getElementById("Backbtn").addEventListener("mouseup", BackbtnClick, false);
    document.getElementById("MessageAddbtn").addEventListener("mouseup", MessageAddbtnClick, false);

    //登録モードか更新モードかを判別する
    if (sessionStorage.getItem("EventID") != null) {
        //更新モード
        EventLoad();
        $("#Deletebtn").css("display", "grid");
        

    } else {
        //登録モード
        MessageAddbtnClick();
        $("#Deletebtn").css("display", "none");
        iniForm = CompareForm();
    }

    //ロード時イベント名にフォーカスを当てる
    $("#txtEventName").focus();


    //datepicker設定
    $.datepicker.setDefaults({
        showButtonPanel: "true",
        changeMonth: "true",
        changeYear: "true",
        minDate: new Date(),
        maxDate: new Date(2099, 12 - 1, 31),
    });

    let fm = $("#txtScheduleFm").datepicker({
        onSelect: function (selectedDate) {
            $("#txtScheduleTo").datepicker("option", "minDate", selectedDate);
        }
    });

    let to = $("#txtScheduleTo").datepicker({
        onSelect: function (selectedDate) {
            $("#txtScheduleFm").datepicker("option", "maxDate", selectedDate);
        }
    });
    
})

//フォームが変更されたかされていないか検出するために使用する関数
function CompareForm() {
    let form
    form += $("#txtEventName").val();
    if ($("#EventStatusOn").prop("checked")) {
        form += "1"
    } else {
        form += "0"
    }
    if ($("#EventStatusOff").prop("checked")) {
        form += "1"
    } else {
        form += "0"
    }
    if ($("#txtScheduleFm").val() == "") {
        form += "1900-01-01";
    } else {
        form += $("#txtScheduleFm").val();
    }
    if ($("#txtScheduleTo").val() == "") {
        form += "2099-12-31";
    } else {
        form += $("#txtScheduleTo").val();
    }
    form += $("#txtKeyword").val();
    for(ele of document.getElementsByClassName("txtMessage")) {
        form += ele.value;

    }
    
    return form;

}

//モーダルを生成する関数
function ModalSet(Area, title, body, savebtn, savebtnstyle, cancelbtn, onclick) {
    let Modal = "";
    let id = "";
    if (Area == "MessageModalArea") {
        id = "ConfirmMessageModal";
    } else if(Area == "ModalArea") {
        id = "ConfirmModal";
    }
    Modal += '<div class="modal fade" id="'+ id +'" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">'
    Modal += '    <div class="modal-dialog">'
    Modal += '        <div class="modal-content">'
    Modal += '            <div class="modal-header">'
    Modal += '                <h1 class="modal-title fs-5" id="ConfirmModalTitle">'+ title +'</h1>'
    Modal += '            </div>'
    Modal += '            <div class="modal-body" id="ModalBody">'+ body +'</div>'
    Modal += '            <div class="modal-footer">'
    if(savebtn != ""){
        Modal += '                <button type="button" id="ModalSavebtn" class="btn '+savebtnstyle +'">'+ savebtn +'</button>'
    }
    Modal += '                <button type="button" id="ModalBackbtn" class="btn btn-outline-secondary" data-bs-dismiss="modal" onclick="ModalbtnCancelClick">'+ cancelbtn +'</button>'
    Modal += '            </div>'
    Modal += '        </div>'
    Modal += '    </div>'
    Modal += '</div>'
    document.getElementById(Area).innerHTML = Modal;
    if (savebtn != "") {
        document.getElementById("ModalSavebtn").setAttribute("onclick", onclick)
    }  
}

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
                    if (data.EventStatus == 1) {
                        $('input[value="1"]').prop('checked', true);
                    } else if (data.EventStatus == 0) {
                        $('input[value="0"]').prop('checked', true);
                    }

                    if (data.ScheduleFm != "1900/01/01") {
                        $("#txtScheduleFm").val(data.ScheduleFm);
                    } else {
                        $("#txtScheduleFm").val("");
                    }

                    if (data.ScheduleTo != "2099/12/31") {
                        $("#txtScheduleTo").val(data.ScheduleTo);
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

                    //メッセージが５つある場合はメッセージ追加ボタンを押下できなくする
                    if (document.getElementsByClassName("MessageContainer").length == 5) {
                        $("#MessageAddbtn").prop("disabled", true);
                        $("#MessageAddbtn").addClass("btn-secondary");
                        $("#MessageAddbtn").removeClass("btn-outline-primary");
                    }

                    //ページロード時のフォーム内容を保存
                    iniForm = CompareForm()

                } else {
                    alert("エラーが発生しました。");
                };
            };
        }
    });
};

//直前に作成したモーダルを削除する関数
function ModalAreaClear() {
    document.getElementById("ModalArea").innerHTML = "";
}

function SameCheck(Flg) {
    let EventNameFlg = true;
    let KeywordFlg = true;
    let BrunkFlg = Flg;
    let SameFlg = false;

    $.ajax({
        url: Ajax_File,
        method: "POST",
        data: {
            "mode": "FinalCheck",
            "EventName": EventName,
            "Keyword":Keyword,
            "Update_EventID": sessionStorage.getItem("EventID")
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    
                    if (data.EventNameErrMsg != "") {
                        $("#EventName-invalid-feedback").text(data.EventNameErrMsg);
                        $("#txtEventName").addClass("is-invalid");
                        $("#txtEventName").removeClass("is-valid");
                        EventNameFlg = false;
                    }
 
                    if (data.KeywordErrMsg != "") {
                        $("#Keyword-invalid-feedback").text(data.KeywordErrMsg);
                        $("#txtKeyword").addClass("is-invalid");
                        $("#txtKeyword").removeClass("is-valid");
                        KeywordFlg = false;
                    }

                    if(EventNameFlg && KeywordFlg){
                        SameFlg = true;
                    }

                    FinalCheck(BrunkFlg, SameFlg)
                    $('#Savebtn').trigger("click");
                    $("#" + $(".is-invalid").first().attr('id')).focus();
                } else {
                    alert("エラーが発生しました。");
                    return false;
                };
            };
        }
    });
}

function FinalCheck(Flg1, Flg2) {
    if (Flg1 && Flg2) {
        if ($("#Savebtn").val() == "登録") {
            ModalSet("ModalArea", "イベント登録", "登録しますか？", "登録", "btn-outline-primary", "戻る", "Modalsavebtnclick()");
        } else {
            ModalSet("ModalArea", "イベント更新", "更新しますか？", "更新", "btn-outline-primary", "戻る", "Modalsavebtnclick()");
        }
    }
}

//登録・更新を行う関数
function SavebtnClick() {
    let EventNameCheckFlag;
    let KeywordCheckFlag;
    let flag = true;

    EventName = $("#txtEventName").val();
    EventStatus = "";
    if ($("input[name=EventStatus]:checked").is(':checked')) {
        EventStatus = $('input[name="EventStatus"]:checked').val();
    };
    ScheduleFm = $("#txtScheduleFm").val();
    ScheduleTo = $("#txtScheduleTo").val();
    Keyword = $("#txtKeyword").val();
    Messages = [];
    work = "";

    let form = document.querySelector('#main');
    let elm = form.querySelectorAll('.form-control');
    //各データの入力チェック
    form.querySelectorAll('.form-control').forEach(function (elm) {
        let required = elm.required;
        if (required && (elm.value.trim().length == 0)) {
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
            event.preventDefault();
            event.stopPropagation();
        } else {
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
        }
    })
    form.querySelectorAll('.form-check-input').forEach(function (elm) {
        if (!elm.checked) {
            elm.classList.add('is-invalid');
            elm.classList.remove('is-valid');
            event.preventDefault();
            event.stopPropagation();
        } else {
            elm.classList.add('is-valid');
            elm.classList.remove('is-invalid');
        }
    })

    //ステータスのエラー制御
    if ($("#EventStatusOn").prop("checked") && !$("#EventStatusOff").prop("checked")) {
        document.getElementById("EventStatusOff").classList.add('is-valid');
        document.getElementById("EventStatusOff").classList.remove('is-invalid');
        document.getElementById("Status-invalid-feedback").classList.remove("invalid-feedback-disp");
        document.getElementById("Status-invalid-feedback").textContent = "";
    } else if (!$("#EventStatusOn").prop("checked") && $("#EventStatusOff").prop("checked")) {
        document.getElementById("EventStatusOn").classList.add('is-valid');
        document.getElementById("EventStatusOn").classList.remove('is-invalid');
        document.getElementById("Status-invalid-feedback").classList.remove("invalid-feedback-disp");
        document.getElementById("Status-invalid-feedback").textContent = "";
    } else if (!$("#EventStatusOn").prop("checked") && !$("#EventStatusOff").prop("checked")) {
        document.getElementById("Status-invalid-feedback").classList.add("invalid-feedback-disp");
        document.getElementById("Status-invalid-feedback").textContent = "ステータスを選択してください。";
    } else {
        document.getElementById("Status-invalid-feedback").classList.remove("invalid-feedback-disp");
        document.getElementById("Status-invalid-feedback").textContent = "";
    }


    //スケジュールのエラー制御
    if ($("#txtScheduleFm").val().length != 0 && $("#txtScheduleTo").val().length == 0) {
        document.getElementById("txtScheduleTo").classList.add('is-valid');
        document.getElementById("txtScheduleTo").classList.remove('is-invalid');
        document.getElementById("Schedule-invalid-feedback").textContent = "";
    } else if ($("#txtScheduleFm").val().length == 0 && $("#txtScheduleTo").val().length != 0) {
        document.getElementById("txtScheduleFm").classList.add('is-valid');
        document.getElementById("txtScheduleFm").classList.remove('is-invalid');
        document.getElementById("Schedule-invalid-feedback").textContent = "";
    } else if ($("#txtScheduleFm").val().length == 0 && $("#txtScheduleTo").val().length == 0) {
        document.getElementById("Schedule-invalid-feedback").textContent = "スケジュールを選択してください。";
    } else {
        document.getElementById("Schedule-invalid-feedback").textContent = "";
    }

    if (EventName.trim() == "") {
        $("#EventName-invalid-feedback").text("イベント名を入力してください。");
        flag = false;
    }

    if (EventStatus == "") {
        flag = false;
    };

    if (ScheduleFm == "" && ScheduleTo == "") {
        flag = false;
    }

    if (Keyword.trim() == "") {
        $("#Keyword-invalid-feedback").text("キーワードを入力してください。");
        flag = false;
    } 

    //空白のメッセージコンテナがないか、メッセージが一つ以上入力されているかを判別
    if (document.getElementsByClassName("txtMessage").length > 0) {
        for(ele of document.getElementsByClassName("txtMessage")) {
            if (ele.value.trim() === "") {
                flag = false;
            }
        }
    } else {
        flag = false;
        alert("エラー")
    }

    SameCheck(flag);

    if (!flag) {
        return false;
    }

    //メッセージをリストに入れこむ
    for(ele of document.getElementsByClassName("txtMessage")) {
        Messages.push(ele.value)
    }

};

//モーダルのsavebtnを押下した際に動く関数
function Modalsavebtnclick() {

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
                    //document.getElementById("ModalSavebtn").style.display = "none";
                    //document.getElementById("ModalBackbtn").textContent = "閉じる";
                    //document.getElementById("ModalBody").textContent = data.ErrorMessage;
                    if (data.ErrorMessage == "同じイベント名は登録できません。") {
                        $("#EventName-invalid-feedback").text("このイベント名は既に登録されています。");
                        $("#txtEventName").addClass("is-invalid");
                        $("#txtEventName").removeClass("is-valid");
                    } else if (data.ErrorMessage == "同じキーワードは登録できません。") {
                        $("#Keyword-invalid-feedback").text("このキーワードは既に登録されています。");
                        $("#txtKeyword").addClass("is-invalid");
                        $("#txtKeyword").removeClass("is-valid");
                    }
                } else {

                    //登録・更新完了後チェックを外す

                    let form = document.querySelector('#main');
                    let elm = form.querySelectorAll('.form-control');

                    form.querySelectorAll('.form-control').forEach(function (elm) {
                        elm.classList.remove("is-valid");
                    })
                    form.querySelectorAll('.form-check-input').forEach(function (elm) {
                        elm.classList.remove("is-valid");
                    })

                    //完了モーダル表示
                    document.getElementById("ModalSavebtn").style.display = "none";
                    document.getElementById("ModalBackbtn").textContent = "閉じる";
                    if (data.Mode == "Ins") {
                        document.getElementById("ModalBody").textContent = "登録が完了しました。";
                        document.getElementById("Savebtn").value = "更新";
                        $("#Deletebtn").css("display", "grid");
                        
                    } else {
                        document.getElementById("ModalBody").textContent = "更新が完了しました。";
                    }

                    //更新・登録したEventIDをセッション変数としてセットする
                    sessionStorage.setItem("EventID", data.EventID)
                    iniForm = CompareForm();

                }

            } else {
                //モーダルの内容をエラーに書き換える
                document.getElementById("ModalSavebtn").style.display = "none";
                document.getElementById("ModalBackbtn").textContent = "閉じる";
                document.getElementById("ModalBody").textContent = "エラーが発生しました。";
            };
        };
    }
});

}

//データを削除する関数
function DeletebtnClick() {
    ModalSet("ModalArea", "イベント削除", "削除しますか？", "削除", "btn-outline-danger", "戻る", "ModalDeletebtnClick()");
};

function ModalDeletebtnClick(){
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
                    document.getElementById("ModalSavebtn").style.display = "none";
                    document.getElementById("ModalBackbtn").textContent = "閉じる";
                    document.getElementById("ModalBody").textContent = "削除が完了しました。";
                    document.getElementById("ModalBackbtn").setAttribute("onclick", "ModalClosebtnClick()");

                    //セッション変数「EventID」を削除する
                    sessionStorage.removeItem("EventID");

                    
                } else {
                    //モーダルの内容をエラーに書き換える
                    document.getElementById("ModalSavebtn").style.display = "none";
                    document.getElementById("ModalBackbtn").textContent = "閉じる";
                    document.getElementById("ModalBody").textContent = "エラーが発生しました。";
                };
            };
        }
    });
}

//モーダルからページ遷移する際に動作する関数
function ModalClosebtnClick() {
    sessionStorage.removeItem("EventID");
    window.location.href = Referrer;
}

//直前に閲覧したページに戻る関数
function BackbtnClick() {
    let curForm = "";
    curForm = CompareForm();
    if (iniForm != curForm) {
        if ($("#Savebtn").val() == "登録") {
            ModalSet("ModalArea", "イベント登録", "登録中ですが戻りますか？", "はい", "btn-outline-primary", "いいえ", "ModalClosebtnClick() ");
        } else {
            ModalSet("ModalArea", "イベント更新", "更新中ですが戻りますか？", "はい", "btn-outline-primary", "いいえ", "ModalClosebtnClick()");
        }
    } else {
        sessionStorage.removeItem("EventID");
        window.location.href = Referrer;
    }
    
    
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

                        if ($(".MessageContainer").length > 1) {
                            $("#txtMessage" + ($(".MessageContainer").length - 1)).focus();
                        }     

                        if (document.getElementsByClassName("MessageContainer").length == 5) {
                            $("#MessageAddbtn").prop("disabled", true);
                            $("#MessageAddbtn").addClass("btn-secondary");
                            $("#MessageAddbtn").removeClass("btn-outline-primary");
                        }
                    } else {
                        alert("エラーが発生しました。");
                    };
                };
            }
        });     
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
        console.log(document.getElementsByClassName("MessageContainer").length)
        for (var i = 0; i <= document.getElementsByClassName("MessageContainer").length - 1; i++) {
            console.log(document.getElementsByClassName("MessageUpbtn")[i])
            document.getElementsByClassName("MessageContainer")[i].id = "MessageContainer" + i;
            document.getElementsByClassName("MessageUpbtn")[i].id = "MessageUpbtn" + i;
            document.getElementsByClassName("MessageDownbtn")[i].id = "MessageDownbtn" + i;
            document.getElementsByClassName("MessageDeletebtn")[i].id = "MessageDeletebtn" + i;
            document.getElementsByClassName("txtMessage")[i].id = "txtMessage" + i;
            document.getElementsByClassName("CouponCodeAddbtn")[i].id = "CouponCodeAddbtn" + i;
            document.getElementsByClassName("txtCount")[i].id = "txtCount" + i;

        }
        setCookie("iCnt", i, 1);
        $("#MessageAddbtn").prop("disabled", false);
        $("#MessageAddbtn").addClass("btn-primary");
        $("#MessageAddbtn").removeClass("btn-secondary");
    }
}

//クーポンコードをテキストエリアに追加する関数
function CouponCodeAddbtnClick() {
    let ID = $(event.target).attr("id").slice(-1);
    let CouponCode = getCookie("CouponCode");
    if ($("#txtMessage" + ID).val().length + CouponCode.length <= 500) {
        document.getElementById("txtMessage" + ID).value += CouponCode;
    }
    $("#txtCount" + ID).text($("#txtMessage" + ID).val().length + "/500");
    $("#txtMessage" + ID).focus();
}

//テキストエリア内の文字数をリアルタイムに反映する関数
function txtCountUpd() {
    let txtMessagelength = $(event.target).val().length;
    let ID = $(event.target).attr("id").slice(-1);
    $("#txtCount" + ID).text(txtMessagelength + "/500");
}