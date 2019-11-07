<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
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
				
				response.sendRedirect("control.jsp?action=seecourse_init");
			}
		}
		else {
			out.println("<script>alert('아이디나 비밀번호를 확인하세요'); location.href='login.jsp';</script>");
		}
	}
	
	if(action.equals("seecourse_init")){
		String id = (String)session.getAttribute("id");
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
		request.setAttribute("problemid", request.getParameter("problemid"));
		request.setAttribute("activityid", request.getParameter("activityid"));
		request.setAttribute("coursename", request.getParameter("coursename"));
		request.setAttribute("courseclassnum", request.getParameter("courseclassnum"));
		
		pageContext.forward("problem.jsp");
	}
	
	if(action.equals("makeproblem")){
		String courseidforclass = request.getParameter("courseidforclass");
		String problemname = request.getParameter("problemname");
		boolean auto_scoring_yn = request.getParameter("auto_scoring_yn").equals("auto");
		String markdown = request.getParameter("markdown");
		
		ArrayList<String> inputs = new ArrayList<String>();
		ArrayList<String> outputs = new ArrayList<String>();
		int num = 0;
		
		while(request.getParameter("input_" + num) != null || request.getParameter("output_" + num) != null){
			inputs.add(request.getParameter("input_" + num));
			outputs.add(request.getParameter("output_" + num));
			num++;
		}
		
		int count = bean.makeProblem(courseidforclass, num, auto_scoring_yn, problemname);
		
		String prob_filename = "prob_" + count + ".txt";
		String io_filename = "io_" + count + ".txt"; 
		
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
		request.setAttribute("courseidforclass", courseidforclass);
		pageContext.forward("problembank.jsp");
	}
	
	if(action.equals("makeactivity")){
		DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm");
		
		String id = (String)session.getAttribute("id");
		String courseidforclass = request.getParameter("courseidforclass");
		String activityname = request.getParameter("activityname");
		String password = request.getParameter("password");
		int language = Integer.parseInt(request.getParameter("language"));
		boolean analysis_yn = request.getParameter("analysis_yn").equals("yes");
		boolean ispassword = request.getParameter("ispassword").equals("yes");
		Date starttime = (Date)formatter.parse(request.getParameter("starttime")); 
		Date endtime = (Date)formatter.parse(request.getParameter("endtime")); 
		
		int num = 1;
		double sumScore = 0;
		ArrayList<Integer> probnums = new ArrayList<Integer>();
		ArrayList<Double> maxscores = new ArrayList<Double>();
		
		while(request.getParameter("prob_" + num) != null){
			probnums.add(Integer.parseInt(request.getParameter("prob_" + num)));
			maxscores.add(Double.parseDouble(request.getParameter("maxscore_" + num)));
			sumScore += Double.parseDouble(request.getParameter("maxscore_" + num));
			num++;
		}
		
		bean.makeActivity(courseidforclass, activityname, password, language, analysis_yn, ispassword,
				starttime, endtime, num - 1, sumScore, probnums, maxscores, id);
		
		response.sendRedirect("control.jsp?action=seecourse_init");
		
	}
%>