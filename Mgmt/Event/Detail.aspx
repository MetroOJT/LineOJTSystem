<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Detail.aspx.vb" Inherits="Sample_Detail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="Detail.js"></script>
    <title>DBテスト-詳細</title>
</head>
<body>
    <form id="main" runat="server" action="Index.aspx">
        <div id="ButtonArea" style="margin-bottom: 20px">
            <input type="button" id="Savebtn" runat="server" value="登録" />
            <input type="button" id="Backbtn" runat="server" value="戻る" />
        </div>
        <div id="SearchArea" style="margin-bottom: 20px">
            <table width="600px">
                <tr>
                    <th width="30%">氏名</th>
                    <td width="70%"><input type="text" id="txtSaveName" maxlength="20" runat="server" /></td>
                </tr>
                <tr>
                    <th>年齢</th>
                    <td><input type="number" id="txtSaveAge" min="0" max="150" runat="server" /></td>
                </tr>
                <tr>
                    <th>住所</th>
                    <td><input type="text" id="txtSaveAddress" maxlength="100" runat="server" style="width: 450px;" /></td>
                </tr>

            </table>
        </div>
        <input type="hidden" id="hdUserID" runat="server" value="" />
    </form>
</body>
</html>
