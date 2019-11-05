<%@page import="java.io.File"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="scts.*, java.util.*" %>
<!DOCTYPE html>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="bean" class="scts.Bean"/>

<%
	String action = request.getParameter("action");

	if(session.getAttribute("id") == null && !action.equals("login")) {
		out.println("<script>alert('세션이 만료되었습니다. 다시 로그인해 주세요.'); location.href='login.jsp';</script>");
	}
	
	if(action.equals("login")) {
		Member member;
		String id = request.getParameter("id");
		if(id != null){
			member = bean.checkID(id, request.getParameter("pw"));
			if(member.getName() == null){
				out.println("<script>alert('아이디나 비밀번호를 확인하세요'); location.href='login.jsp';</script>");
			} else {
				session.setAttribute("id", id);
				session.setAttribute("name", member.getName());
				ArrayList<Course> courses = bean.getCoursesForStudent(id);
				session.setAttribute("courses", courses);
				
				request.setAttribute("courseidforclass", courses.get(0).getCourseIdForClass());
				request.setAttribute("coursename", courses.get(0).getCourseName());
				request.setAttribute("courseyear", courses.get(0).getCourseYear());
				request.setAttribute("coursesemester", courses.get(0).getCourseSemester());
				request.setAttribute("courseid", courses.get(0).getCourseId());
				request.setAttribute("courseclassnum", courses.get(0).getCourseClassNum());
				request.setAttribute("professorid", courses.get(0).getProfessorId());
				
				ArrayList<ActivityInfo> activityInfo = bean.getActivityInfoForStudent(id, courses.get(0).getCourseIdForClass());
				request.setAttribute("activityinfo", activityInfo);
			
				pageContext.forward("problemset.jsp");
			}
		}
		else {
			out.println("<script>alert('아이디나 비밀번호를 확인하세요'); location.href='login.jsp';</script>");
		}
	}
	
	if(action.equals("seecourse")){
		int num = Integer.parseInt(request.getParameter("num"));
		ArrayList<Course> courses = bean.getCoursesForStudent((String)session.getAttribute("id"));
		
		session.setAttribute("courses", courses);
		request.setAttribute("courseidforclass", courses.get(num).getCourseIdForClass());
		request.setAttribute("coursename", courses.get(num).getCourseName());
		request.setAttribute("courseyear", courses.get(num).getCourseName());
		request.setAttribute("coursesemester", courses.get(num).getCourseSemester());
		request.setAttribute("courseid", courses.get(num).getCourseId());
		request.setAttribute("courseclassnum", courses.get(num).getCourseClassNum());
		request.setAttribute("professorid", courses.get(num).getProfessorId());
		
		ArrayList<ActivityInfo> activityInfo = 
				bean.getActivityInfoForStudent((String)session.getAttribute("id"), courses.get(num).getCourseIdForClass());
		request.setAttribute("activityinfo", activityInfo);
		
		pageContext.forward("problemset.jsp");
	}
	
	if(action.equals("seeproblem")){
		String courseidforclass = request.getParameter("courseidforclass");
		int activityid = Integer.parseInt(request.getParameter("activityid"));
		ArrayList<ActivityInfo> activityInfo = 
				bean.getActivityInfoForStudent((String)session.getAttribute("id"), courseidforclass);
		
		request.setAttribute("activityinfo", activityInfo.get(activityid-1));
		request.setAttribute("activityid", request.getParameter("activityid"));
		request.setAttribute("coursename", request.getParameter("coursename"));
		request.setAttribute("courseclassnum", request.getParameter("courseclassnum"));
		
		pageContext.forward("problem.jsp");
	}
	
	if(action.equals("makeproblem")){
		String courseidforclass = request.getParameter("courseidforclass");
		String problemname = request.getParameter("problemname");
		boolean auto_scoring_yn = request.getParameter("auto_scoring_yn").equals("auto");
		double maxscore = Double.parseDouble(request.getParameter("maxscore"));
		String markdown = request.getParameter("markdown");
		
		ArrayList<String> inputs = new ArrayList<String>();
		ArrayList<String> outputs = new ArrayList<String>();
		int num = 0;
		
		while(request.getParameter("input_" + num) != null || request.getParameter("output_" + num) != null){
			inputs.add(request.getParameter("input_" + num));
			outputs.add(request.getParameter("output_" + num));
			num++;
		}
		
		String prob_filename = "prob_" + "0" + ".txt";
		String io_filename = "io_" + "0" + ".txt"; 
		
		try{
			String rltv = "/problems/code/" + courseidforclass + "/";
			String filePath = application.getRealPath(rltv);
			File file = new File(filePath);
			if(!file.exists()) file.mkdirs();
			PrintWriter pw = new PrintWriter(filePath + prob_filename);
			pw.println(markdown);
			pw.close();

			pw = new PrintWriter(filePath + io_filename);
			
			for(int i=0; i!=num; ++i){
				pw.println(inputs.get(i));
				pw.println("!-!-!-!-!-!-");
				pw.println(outputs.get(i));
				pw.println("!-!-!-!-!-!-");
			}
			
			pw.close();
			out.println("<script>alert('저장 성공');</script>");
			
		}catch(Exception e){
			out.println("<script>alert('저장 실패: "+ e.getMessage() +"');</script>");
			e.printStackTrace();
		}
		
		out.println("<script>alert('" + courseidforclass + " " + problemname + " " + auto_scoring_yn + " " + maxscore + " " + markdown + " " + num + "');</script>");
		
		bean.makeProblem(courseidforclass, num, auto_scoring_yn, maxscore, problemname);
		
		//pageContext.forward("login.jsp");
	}
	
%>