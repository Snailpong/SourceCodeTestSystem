<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<br>활동 이름 <input type="text" id="activityname">
<br><br>
채점 언어 <select id="language" name="language">
	<option value="c">C</option>
	<option value="cplusplus">C++</option>
	<option value="java">Java</option>
	<option value="python">Python</option>
</select>
<br><br>시작 시간
<input type="datetime-local" id="starttime"
       name="starttime">
<br><br>종료 시간
<input type="datetime-local" id="endtime"
       name="endtime">
<br><br>분석여부 <select name="analysis_yn">
	<option value="yes">Y</option>
	<option value="no">N</option>
</select>
<br><br>비밀번호 설정 
<select name="ispassword">
	<option value="yes">Y</option>
	<option value="no">N</option></select>
<input type="text" id="password">

</body>
</html>