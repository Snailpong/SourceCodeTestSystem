<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.FileReader"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="scts.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>SCTS</title>
<link rel="stylesheet" href="css/problem.css">
<script type="text/javascript" src="js/markdown/jquery-1.6.1.min.js"></script>
<script type="text/javascript" src="js/markdown/jquery.autosize-min.js"></script>
<script type="text/javascript" src="js/markdown/markdown.js"></script>
<jsp:useBean id="activityinfo" scope="request" class="scts.ActivityInfo" />
<jsp:useBean id="bean" class="scts.Bean"/>
<style type="text/css" media="screen">
    #editorContainer {
    width: 100%;
    height: 100%;
    position: relative;
	}
	#editor { 
	    position: absolute;
	    top: 0;
	    right: 0;
	    bottom: 0;
	    left: 0;
	}
</style>
</head>
<body>
<%
	String courseidforclass =  request.getParameter("courseidforclass");
	int problemid = Integer.parseInt(request.getParameter("problemid"));
	ArrayList<ActivityInfo> infos = bean.getActivityInfoForStudent((String)session.getAttribute("id"), courseidforclass);
	
	ActivityInfo info = new ActivityInfo();
	for(ActivityInfo info_t : infos){
		if(info_t.getActivityid() == Integer.parseInt(request.getParameter("activityid"))){
			info = info_t;
			break;
		}
	}
	
	ArrayList<ActivityProblem> acp = bean.getActivityProblem(courseidforclass, info.getActivityid());
	ActivityProblem ap = new ActivityProblem();
	
	for(ActivityProblem ap_t : acp){
		if(ap_t.getProblemid() == problemid){
			ap = ap_t;
			break;
		}
	}
	
	int problemnum = ap.getProblemnum();
	
	String problem_markdown = "";
	String prob_filename = "prob_" + ap.getProblemnum() + ".txt";
	String io_filename = "io_" + ap.getProblemnum() + ".txt"; 
	String rltv = "/problems/code/" + courseidforclass + "/";
	String filePath = application.getRealPath(rltv);

    FileReader fileReader = new FileReader(filePath + prob_filename);

    try (BufferedReader bufferedReader = new BufferedReader(fileReader)) {
    	String line;
      	while((line = bufferedReader.readLine()) != null) {
      		int nbsp = 0;
      		while(line.charAt(nbsp) == ' ') nbsp++;
      		line = String.join("", Collections.nCopies(nbsp, "&nbsp;")) + line;
      		problem_markdown += line + "  \n";
      	}
    }
    
    fileReader.close();
    
%>
    <div id="wapper">
        <!--헤더시작-->
        <header id="bar">
            <p style = "padding: 0px 0px 0px 15px;">
            <%= request.getParameter("coursename") %> (<%= request.getParameter("courseclassnum") %>)</p>
        </header>
        <header>
        <table><tr style="width:100%;">
            <td><div style = "padding: 10px 0px 0px 15px;"><%= activityinfo.getActivityname() %></div></td>
            <td><div style = "padding: 10px 0px 0px 0px; float:right">
            	<button id="prev" onclick="prev();">이전 문제</button>
            	<button id="next" onclick="next();">다음 문제</button>
            	<button id="submit" onclick="submit();">제출</button></div></td>
        </tr></table></header>
        <!--네비게이션-->
        <nav>
            <div style = "padding: 0px 15px 0px 15px;">
            <div id="container">
		      <div id="content" class="section">
		        <div id="edit" class="mode">
		          <div class="content" style="display:none">
		            <textarea id="markdown"><%= problem_markdown %></textarea>
		          </div>
		        </div>
		
		        <div id="preview" class="mode">
		          <div id="output" class="content markdown-body">
		          </div>
		        </div>
		      </div>
		    </div>
            </div>
        </nav>
        <!--콘텐츠부분-->
        <section>
        <table>
        <tr>
        <div id="editorContainer">
        	<div id="editor">public class solution {
    public static void main(String args[]) {
        System.out.println("this is example");
    }
}</div></div>
        </tr>
        <tr height="150px"> 여기에 실행 결과가 표시됩니다.
        </tr>
        </table>
        	
    
<script src="${pageContext.request.contextPath}/js/ace-builds/src-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
<script>
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/chrome");
    editor.session.setMode("ace/mode/java");
    document.getElementById('editor').style.fontSize='18px';
    editor.getValue();
    $('#output').html(markdown.toHTML($('#markdown').val()));
    
    function prev() {
    	alert("버튼1을 누르셨습니다.");
    }
    
    function next() {
    	alert("버튼1을 누르셨습니다.");
    }
    
    function submit() {
    	alert("버튼1을 누르셨습니다.");
    }
</script>
        </section>
        <!--풋터-->
        <footer>
        </footer>
    </div>
</body>
</html>