//上限日、下限日の設定
var LowerLimitDate = new Date(1900, 1 - 1, 1);
var UpperLimitDate = new Date(2099, 12 - 1, 31);
var Com_Ajax_File = "../../Common/ashx/Common.ashx";

$(function () {
    history.pushState(null, null, location.href); //ブラウザバック無効化
    //ブラウザバックボタン押下時
    $(window).on("popstate", function (event) {
        history.go(1);
    });
});


// クッキーを設定する関数
function setCookie(name, value, days) {
    let date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    let expires = "; expires=" + date.toUTCString();
    document.cookie = name + "=" + value + expires + "; path=/";
}

// クッキーを取得する関数
function getCookie(name) {
    let cookieName = name + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let cookies = decodedCookie.split(';');

    for (let i = 0; i < cookies.length; i++) {
        let cookie = cookies[i].trim();
        if (cookie.indexOf(cookieName) === 0) {
            return cookie.substring(cookieName.length, cookie.length);
        }
    }
    return "";
}

// クッキーを削除する関数
function deleteCookie(name) {
    setCookie(name, "", -1);
}

// クッキーを更新する関数
function updateCookie(name, newValue, newDays) {
    let existingCookieValue = getCookie(name);
    if (existingCookieValue !== "") {
        let days = newDays ? newDays : getCookieDays(name);
        setCookie(name, newValue, days);
    }
}

// クッキーの有効期限（日数）を取得する補助関数
function getCookieDays(name) {
    // この関数は、クッキーの作成時に有効期限を取得するために使用されます。
    // 必要に応じて実装を追加してください。
}

//　文字列をHTML要素に変換する関数
function createElementFromHTML(html) {
    const tempEl = document.createElement('div');
    tempEl.innerHTML = html;
    return tempEl.firstElementChild;
}

// ログインして画面を開いたかを確認する関数
function function_login_check() {
    const login_check = sessionStorage.getItem("login_check");
    if (login_check != 1) {
        const unauthorized_access = 1;
        sessionStorage.setItem("unauthorized_access", unauthorized_access);
                window.location.href = "../../Mgmt/Login/Index.aspx";
    }
}

function DspLoginUserName() {
    const LoginUserName = sessionStorage.getItem("UserName");
    document.getElementById("LoginUserName").textContent = LoginUserName;
}

function LogOut() {
    $.ajax({
        url: Com_Ajax_File,
        method: "POST",
        data: {
            "mode": "LogOut",
        },
        dataType: "json",
        success: function (data) {
            if (data != "") {
                if (data.status == "OK") {
                    sessionStorage.clear();
                    document.cookie.split(";").forEach(function (c) { document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); });
                    window.location.href = "../../Mgmt/Login/Index.aspx";
                }
                else if (data.status == "PASS") {
                    return;
                }
                else {
                    alert("エラーが発生しました。");
                }
            }
        }
    })
    
}

function CmnRegExp(event) {
    event.target.value = event.target.value.replace(/[!-/:-@[-`{-~]/g, '');
}

function CmnFlatpickr(sFmObj, sToObj, dMinDate, dMaxDate, bTimeFlg) {
    let lang = "ja";
    let sFormat = "";
    let SetMinDate = dMinDate;
    let SetMaxDate = dMaxDate;

    if (bTimeFlg) {
        sFormat = "Y/m/d H:i";
    } else {
        sFormat = "Y/m/d";
    }

    flatpickr("#" + sFmObj, {
        locale: lang,
        minuteIncrement: 10,
        showMonths:3,
        dateFormat: sFormat,
        enableTime: bTimeFlg,
        minDate: dMinDate,
        maxDate: dMaxDate
    })

    flatpickr("#" + sToObj, {
        locale: lang,
        minuteIncrement: 10,
        showMonths: 3,
        dateFormat: sFormat,
        enableTime: bTimeFlg,
        minDate: dMinDate,
        maxDate: dMaxDate
    })

    $('#' + sFmObj).change(function () {
        console.log("test")
        if ($('#' + sFmObj).val() != "") {
            SetMinDate = $('#' + sFmObj).val();
        } else {
            SetMinDate = dMinDate;
        }

        flatpickr("#" + sToObj, {
            locale: lang,
            minuteIncrement: 10,
            showMonths: 3,
            dateFormat: sFormat,
            enableTime: bTimeFlg,
            minDate: SetMinDate,
            maxDate: dMaxDate
        })
    });

    $("#" + sToObj).change(function () {
        if ($("#" + sToObj).val() != "") {
            SetMaxDate = $("#" + sToObj).val();
        } else {
            SetMaxDate = dMaxDate;
        }

        flatpickr("#" + sFmObj, {
            locale:lang,
            minuteIncrement: 10,
            showMonths: 3,
            dateFormat: sFormat,
            enableTime: bTimeFlg,
            minDate: dMinDate,
            maxDate: SetMaxDate
        })
    });
}

//モーダルを生成する関数

function ModalSet(Area, title, body, savebtn, savebtnstyle, cancelbtn, onclick) {
    let Modal = "";
    Modal += '<div class="modal fade" id="ConfirmModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">'
    Modal += '    <div class="modal-dialog">'
    Modal += '        <div class="modal-content">'
    Modal += '            <div class="modal-header">'
    Modal += '                <h1 class="modal-title fs-5" id="ConfirmModalTitle">' + title + '</h1>'
    Modal += '            </div>'
    Modal += '            <div class="modal-body" id="ModalBody">' + body + '</div>'
    Modal += '            <div class="modal-footer">'
    if (savebtn != "") {
        Modal += '                <button type="button" id="ModalSavebtn" class="btn ' + savebtnstyle + '">' + savebtn + '</button>'
    }
    Modal += '                <button type="button" id="ModalBackbtn" class="btn btn-outline-secondary" data-bs-dismiss="modal">' + cancelbtn + '</button>'
    Modal += '            </div>'
    Modal += '        </div>'
    Modal += '    </div>'
    Modal += '</div>'
    document.getElementById(Area).innerHTML = Modal;
    if (savebtn != "") {
        document.getElementById("ModalSavebtn").setAttribute("onclick", onclick)
    }
}





