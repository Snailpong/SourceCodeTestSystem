<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="scts.*, java.util.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<script src="https://code.jquery.com/jquery-1.10.2.js"></script>
<jsp:useBean id="bean" class="scts.Bean"/>
<title>SCTS</title>
</head>
<body>
<form action=control.jsp method=post>
<input type=hidden name="action" value="makeactivity">
<input type=hidden name="courseidforclass" value="<%= request.getParameter("courseidforclass") %>">
<br>활동 이름 <input type="text" name="activityname">
<br><br>
채점 언어 <select id="language" name="language">
	<option value="1">C</option>
	<option value="2">C++</option>
	<option value="3">Java</option>
	<option value="4">Python</option>
</select>
<br><br>시작 시간
<input type="datetime-local" id="starttime"
       name="starttime">
<br><br>종료 시간
<input type="datetime-local" id="endtime"
       name="endtime">
<br><br>분석여부 <select name="analysis_yn">
	<option value="no">N</option>
	<option value="yes">Y</option>

</select>
<br><br>비밀번호 설정 
<select name="ispassword">
	<option value="no">N</option>
	<option value="yes">Y</option></select>
<input type="text" id="password">

<br><br>
<button type="button" name="addStaff">문제 추가</button>
<button class="btn btn-default" type="button" name="delStaff">문제 삭제</button>
    <br>
    <br>
    <table>
        <tbody>
        <tr><td>번호</td><td style="width:400px">문제</td><td>최대 점수</td></tr>
            <tr name="trStaff">
            	<td>1</td><td>
                <select name="prob_1" style="width:400px">
                	<%
                	for(Problem pb : bean.getProblems(request.getParameter("courseidforclass"))){
                	%>
					<option value="<%= pb.getProblemnum() %>"><%= pb.getProblemname() %></option>
					<%}%>
                </select></td><td><input type="text" name="maxscore_1"></td>
            </tr>
        </tbody>
    </table>
    
    <input type="submit" value="확인"><br><br>
<br><br>
</form>
<script>
	var num = 2;
	//추가 버튼
	$(document).on("click","button[name=addStaff]",function(){
	    
	    var addStaffText =  '<tr name="trStaff">'+
	        '   <td>' + num + '</td><td>'+
	        '   <select name="prob_' + num + '" style="width:400px">' +
	           <% for(Problem pb : bean.getProblems(request.getParameter("courseidforclass"))){ %>
	        ' <option value="<%= pb.getProblemnum() %>"><%= pb.getProblemname() %></option>' + <%}%>
	        '       </select></td><td><input type="text" name="maxscore_' + num + '"></td>' +
	        '       </tr>';
	    
	    var trHtml = $( "tr[name=trStaff]:last" ); //last를 사용하여 trStaff라는 명을 가진 마지막 태그 호출
	     
	    trHtml.after(addStaffText); //마지막 trStaff명 뒤에 붙인다.
	    num = num + 1;
	});
	 
	//삭제 버튼
	$(document).on("click","button[name=delStaff]",function(){
	    if(num != 2){
	    	num = num - 1;
	    	var trHtml = $( "tr[name=trStaff]:last" );
	        trHtml.remove(); //tr 테그 삭제
	    }
	});
	
</script>

</body>
</html>