<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="scts.*, java.util.*, java.net.URLEncoder, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SCTS</title>
<link rel="stylesheet" href="css/problemset.css">
<jsp:useBean id="courses" scope="session" class="java.util.ArrayList" />
<jsp:useBean id="activityinfo" scope="request" class="java.util.ArrayList" />
</head>
<body>
<%
	request.setCharacterEncoding("utf-8");

	if(session.getAttribute("id") == null) {
		out.println("<script>alert('세션이 만료되었습니다. 다시 로그인해 주세요.'); location.href='login.jsp';</script>");
	}
%>
<div id="wapper">
        <!--헤더시작-->
        <header id="bar">
            <p style = "padding: 0px 0px 0px 15px;">
            <%=request.getAttribute("coursename") +
            " (" + request.getAttribute("courseclassnum") + ")" %>
            </p>
        </header>
        <nav>
        <div id="padd">
<center><b>수강 과목</b></center>
<%
	request.setCharacterEncoding("UTF-8");
	String courseyearss = "";
	int i = 0;
	for(Course course : (ArrayList<Course>)courses){
		if(!(course.getCourseYear()+course.getCourseSemester()).equals(courseyearss)){
			courseyearss = course.getCourseYear()+course.getCourseSemester();
			%><br><b><%=course.getCourseYear()%>학년도 <%= course.getSemesterString() %>학기</b><br><%
		}
		%><a href="control.jsp?action=seecourse&num=<%=i%>">
		<%=course.getCourseName() + " (" + course.getCourseClassNum() + ")"%></a><br>
		<%i++;
	}
	boolean isprofessor = session.getAttribute("id").equals(request.getAttribute("professorid"));
%>
        </div></nav>
        <section>
	        <header>
	            <p style = "padding: 0px 0px 0px 20px;">학습 활동</p>
	        </header>
	        <table id="activitylist">
			<tr bgcolor="#eeeeee">
			<td width=75% height="40px" align="center">과제명 </td><td width=25% align="center">점수</td></tr>
			<%
			SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			for(ActivityInfo info : (ArrayList<ActivityInfo>)activityinfo){
			%>
			<tr><td width=75% height="40px">
			<% if(!isprofessor){ %>
			<a href="control.jsp?action=seeproblem&courseidforclass=
			<%=info.getCourseidforclass()%>&coursename=<%= request.getAttribute("coursename") %>
			&courseclassnum=<%= request.getAttribute("courseclassnum") %>
			&activityid=<%=info.getActivityid() %>&problemid=1">
			<%=info.getActivityname() %></a>
			<%} else {%>
			<a href="activityinfo.jsp?courseidforclass=
			<%=info.getCourseidforclass()%>&activityid=<%=info.getActivityid() %>">
			<%=info.getActivityname() %></a>
			 <% }%> <font color="red" size="2">
			<%= transFormat.format(info.getStarttime()) + " ~ " + transFormat.format(info.getEndtime())%></font></td>
			<td width=25%  align="center"><% if(!isprofessor){ %>
			<%=info.getScore() + " / " + info.getMaxscore() %><%} %></td></tr>
			<%} %>
		</table>
		
		<% if(session.getAttribute("id").equals(request.getAttribute("professorid"))){ %>
		<button type=button onclick="location.href='makeactivity.jsp?courseidforclass=<%=request.getAttribute("courseidforclass")%>'">활동 추가</button> 
		<button type=button onclick="location.href='makeproblem.jsp?courseidforclass=<%=request.getAttribute("courseidforclass")%>'">문제 추가</button>
		<%} %>
        </section>

</body>
</html>