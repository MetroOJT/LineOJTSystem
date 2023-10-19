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


function createElementFromHTML(html) {
    const tempEl = document.createElement('div');
    tempEl.innerHTML = html;
    return tempEl.firstElementChild;
}
