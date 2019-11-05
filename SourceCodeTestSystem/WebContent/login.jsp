<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
-로그인-
<form action=control.jsp method=post>
<input type=hidden name="action" value="login">
<input type="text" name="id"><br>
<input type="password" name="pw"><br>
<input type="submit" value="로그인"><br><br>
예시<br>
학생1: 1234/5678<br>
학생2: 1235/5679<br>
교수1: 9999/8888<br>
</form>
</body>
</html>