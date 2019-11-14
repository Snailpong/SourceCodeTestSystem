<%@page import="java.io.FileReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.io.File"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="scts.*, java.util.*" %>
<!DOCTYPE html>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="bean" class="scts.Bean"/>
<jsp:useBean id="cmd" class="scts.Cmd"/>

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
		String skeleton = request.getParameter("skeleton");
		
		skeleton.replaceAll("\n", "");
		skeleton.replaceAll(" ", "");
		skeleton.replaceAll("\r", "");
		skeleton.replaceAll("\t", "");
		
		ArrayList<String> inputs = new ArrayList<String>();
		ArrayList<String> outputs = new ArrayList<String>();
		int num = 0;
		
		while(request.getParameter("input_" + num) != null || request.getParameter("output_" + num) != null){
			inputs.add(request.getParameter("input_" + num));
			outputs.add(request.getParameter("output_" + num));
			num++;
		}
		
		int count = bean.makeProblem(courseidforclass, num, auto_scoring_yn, problemname);
		
		String prob_filename = "prob.txt";
		
		try{
			String rltv = "/problems/code/" + courseidforclass + "/problems/probnum_" + count + "/";
			String filePath = application.getRealPath(rltv);
			File file = new File(filePath);
			if(!file.exists()) file.mkdirs();
			PrintWriter pw = new PrintWriter(filePath + prob_filename);
			pw.println(markdown);
			pw.close();
			
			pw = new PrintWriter(filePath + "skeleton.txt");
			pw.print(skeleton);
			pw.close();
			
			for(int i=0; i!=num; ++i){
				pw = new PrintWriter(filePath + "input_" + (i+1) + ".txt");
				pw.println(inputs.get(i));
				pw.close();
				
				pw = new PrintWriter(filePath + "output_" + (i+1) + ".txt");
				pw.println(outputs.get(i));
				pw.close();
			}
			
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
	
	if(action.equals("submitproblem")){
		String code = request.getParameter("code");
		String id = (String)session.getAttribute("id");
		
		String courseidforclass = request.getParameter("courseidforclass");
		int activityid = Integer.parseInt(request.getParameter("activityid"));
		int problemid = Integer.parseInt(request.getParameter("problemid"));
		ArrayList<ActivityInfo> activityInfo = 
				bean.getActivityInfoForStudent(id, courseidforclass);
		int language_i = activityInfo.get(activityid-1).getLanguage();
		String language = bean.langInt2Str(activityInfo.get(activityid-1).getLanguage());
		String filename;
		String resp = "";
		
		ArrayList<ActivityProblem> acp = bean.getActivityProblem(courseidforclass, activityid);
		ActivityProblem ap = new ActivityProblem();
		
		for(ActivityProblem ap_t : acp){
			if(ap_t.getProblemid() == problemid){
				ap = ap_t;
				break;
			}
		}
		
		
		try{
			String rltv = "/problems/code/" + courseidforclass + "/activities/activity_" + activityid +
					"/problemid_" + request.getParameter("problemid") + "/" + id + "/";
			String filePath = application.getRealPath(rltv);
			File file = new File(filePath);
			if(!file.exists()) file.mkdirs();
			filename = id + language;
			PrintWriter pw = new PrintWriter(filePath + filename);
			pw.println(code);
			pw.close();
			
			if(ap.isAutocheck()){
				switch(language_i){
				case 0:
				case 1:
					resp = cmd.cppCompile(filePath, filename);
					if(resp == null || resp.length() == 0){
						
						String rltv_input = "/problems/code/" + courseidforclass +
								"/problems/probnum_" + ap.getProblemnum() + "/";
						String filePath_input = application.getRealPath(rltv_input);
						String code_test = new String(code);
						
						if(!code_test.contains("stdio.h"))
							code_test = "#include <stdio.h>\n" + code_test;
						int mainIndex = code_test.indexOf("main(");
						int startIndex = code_test.indexOf('{', mainIndex+1);
						code_test = code_test.substring(0, startIndex+1) +
								"\n" +  "freopen(\"input.txt\", \"r\", stdin);\n" +
								"freopen(\"output.txt\", \"w\", stdout);\n" +
								code_test.substring(startIndex + 1);
						pw = new PrintWriter(filePath + id + "_test" + language);
						pw.println(code_test);
						pw.close();
						
						resp = cmd.cppCompile(filePath, id + "_test" + language);
						
						int correct = 0;
						
						for(int i=0; i!=ap.getTestcasenum(); ++i){
							File problemInput = new File(filePath_input + "input_" + (i+1) + ".txt");
							File submitInput = new File(filePath + "input.txt");
							
							if(!submitInput.exists()) submitInput.createNewFile();
							
							FileInputStream fis = new FileInputStream(problemInput);
				            FileOutputStream fos = new FileOutputStream(submitInput);
				            
				            int fileByte = 0; 
				            while((fileByte = fis.read()) != -1) {
				                fos.write(fileByte);
				            }
				            fis.close();
				            fos.close();
				            
				            long start = System.currentTimeMillis();
				            resp += cmd.cppTest(filePath, id + "_test" + language);
				            long end = System.currentTimeMillis();
				            long millis = end - start;
				            
				            File problemOutput = new File(filePath_input + "output_" + (i+1) + ".txt");
							File submitOutput = new File(filePath + "output.txt");
							
							if(!submitOutput.exists()) submitOutput.createNewFile();
							
							String answer_output = "";
							String submit_output = "";
							
							try (BufferedReader bufferedReader = new BufferedReader(new FileReader(filePath_input + "output_" + (i+1) + ".txt"))) {
						    	String line;
						      	while((line = bufferedReader.readLine()) != null) {
						      		int nbsp = 0;
						      		while(line.charAt(nbsp) == ' ') nbsp++;
						      		line = String.join("", Collections.nCopies(nbsp, "&nbsp;")) + line;
						      		answer_output += line + "  \n";
						      	}
						    } catch(Exception e){
						    	e.printStackTrace();
						    }
							
							try (BufferedReader bufferedReader = new BufferedReader(new FileReader(filePath + "output.txt"))) {
						    	String line;
						      	while((line = bufferedReader.readLine()) != null) {
						      		int nbsp = 0;
						      		while(line.charAt(nbsp) == ' ') nbsp++;
						      		line = String.join("", Collections.nCopies(nbsp, "&nbsp;")) + line;
						      		submit_output += line + "  \n";
						      	}
						    } catch(Exception e){
						    	e.printStackTrace();
						    }
							
							if(answer_output.equals(submit_output)){
								resp += "Test case #" + (i+1) + ": Correct (" + millis + "ms)<br>";
								correct++;
							} else {
								resp += "Test case #" + (i+1) + ": Wrong" + "<br>";
							}
							
						}
						double score = ap.getMaxscore() * correct / ap.getTestcasenum(); 
						resp += "→ Score : " + score  + " / " + ap.getMaxscore();
								
						bean.insertScore(id, courseidforclass, activityid, problemid, score);
						
					}
				}
			}

		}catch(Exception e){
			e.printStackTrace();
		}
		
		request.setAttribute("activityinfo", activityInfo.get(activityid-1));
		request.setAttribute("problemid", request.getParameter("problemid"));
		request.setAttribute("activityid", request.getParameter("activityid"));
		request.setAttribute("coursename", request.getParameter("coursename"));
		request.setAttribute("courseclassnum", request.getParameter("courseclassnum"));
		request.setAttribute("resp", resp);
		
		pageContext.forward("problem.jsp");
		
	}
%>