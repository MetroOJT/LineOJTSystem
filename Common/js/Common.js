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
function function_login_check(){
    const login_check = sessionStorage.getItem("login_check");
    if (login_check != 1) {
        const unauthorized_access = 1;
        sessionStorage.setItem("unauthorized_access", unauthorized_access);
        window.location.href = "http://localhost:808/LineOJTSystem/Mgmt/Login/Index.aspx";
    }
}

function DspLoginUserName() {
    const LoginUserName = sessionStorage.getItem("UserName");
    document.getElementById("LoginUserName").textContent = "担当者名：" + LoginUserName;
}

function LogOut() {
    sessionStorage.clear();
    window.location.href = "../../Mgmt/Login/Index.aspx";
}