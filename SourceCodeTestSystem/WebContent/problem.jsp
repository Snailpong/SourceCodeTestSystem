<%@page import="java.io.File"%>
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
<%! String result = ""; %>
<%! String code; %>
<%
	String courseidforclass =  request.getParameter("courseidforclass");
	int problemid = Integer.parseInt(request.getParameter("problemid"));
	String id = (String)session.getAttribute("id");
	String activityid = request.getParameter("activityid");
	double currentscore = bean.getProblemScore(id, courseidforclass, Integer.parseInt(activityid), problemid);
	ArrayList<ActivityInfo> infos = bean.getActivityInfoForStudent((String)session.getAttribute("id"), courseidforclass);
	
	ActivityInfo info = new ActivityInfo();
	for(ActivityInfo info_t : infos){
		if(info_t.getActivityid() == Integer.parseInt(activityid)){
			info = info_t;
			break;
		}
	}
	
	int language = info.getLanguage();
	Date nowTime = new Date();
	Date startTime = info.getStarttime();
	Date endTime = info.getEndtime();
	String disable = "";
	
	if(!(nowTime.compareTo(startTime) == 1 && nowTime.compareTo(endTime) == -1))
		disable = "disabled";
	
	ArrayList<ActivityProblem> acp = bean.getActivityProblem(courseidforclass, info.getActivityid());
	ActivityProblem ap = new ActivityProblem();
	
	for(ActivityProblem ap_t : acp){
		if(ap_t.getProblemid() == problemid){
			ap = ap_t;
			break;
		}
	}
	
	int problemnum = ap.getProblemnum();
	code = bean.getExample(problemnum);
	
	String problem_markdown = "";
	String prob_filename = "prob.txt";
	String rltv = "/problems/code/" + courseidforclass + "/problems/probnum_" + ap.getProblemnum() + "/";
	String filePath = application.getRealPath(rltv);
	result = (String)request.getAttribute("resp");
	if(result == null || result.length() == 0) result = "여기에 실행 결과가 표시됩니다.";

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
    
    rltv = "/problems/code/" + courseidforclass + "/activities/activity_" + activityid +
			"/problemid_" + problemid + "/" + id + "/" + id + bean.langInt2Str(info.getLanguage());
	filePath = application.getRealPath(rltv);
    
    File file = new File(filePath);
	if(file.exists()){
		code = "";
		fileReader = new FileReader(file);

	    try (BufferedReader bufferedReader = new BufferedReader(fileReader)) {
	    	String line;
	      	while((line = bufferedReader.readLine()) != null) {
	      		code += line + "\n";
	      	}
	    }
	    code = code.substring(0, code.length()-1);
	    code = code.replace("<", "&lt;");
	    fileReader.close();
	} else {

	}
    
%>
<form action=control.jsp method=post id=forms>
<input type=hidden name="action" value="submitproblem">
<input type=hidden name="courseidforclass" value="<%= request.getParameter("courseidforclass") %>">
<input type=hidden name="coursename" value="<%= request.getParameter("coursename") %>">
<input type=hidden name="courseclassnum" value="<%= request.getParameter("courseclassnum") %>">
<input type=hidden name="problemid" value="<%= request.getParameter("problemid") %>">
<input type=hidden name="activityid" value="<%= request.getParameter("activityid") %>">
</form>
    <div id="wapper">
        <!--헤더시작-->
        <header id="bar">
            <p style = "padding: 0px 0px 0px 15px;">
            <%= request.getParameter("coursename") %> (<%= request.getParameter("courseclassnum") %>)</p>
        </header>
        <header>
        <table><tr>
            <td style="width:300px"><div style="padding: 10px 0px 0px 15px;">
            <%= activityinfo.getActivityname() + " " + problemid + "번"%></div></td>
            <td style="width:calc(100vw - 300px)"><div style = "padding: 10px 10px 0px 0px; float:right">
            	<button id="prev" onclick="prev();">이전 문제</button>
            	<button id="next" onclick="next();">다음 문제</button>
            	<button onclick="submit();" <%= disable %>>제출</button>
            	<button id="exit" onclick="exit();">종료</button></div></td>
        </tr></table></header>
        <!--네비게이션-->
        <nav>
            <div style = "padding: 0px 15px 0px 15px;">
            <div id="container">
		      <div id="content" class="section">
		        <div id="edit" class="mode">
		          <div class="content" style="display:none">
		            <textarea id="markdown" ><%= problem_markdown %></textarea>
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
        	<div id="editor"><%= code %></div></div>
        </tr>
        <tr id="over"><div id="over"><%= result %></div>
        </tr>
        </table>
 
<script src="${pageContext.request.contextPath}/js/ace-builds/src-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
<script>
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/chrome");
    editor.session.setMode("ace/mode/<%= bean.langInt2Opt(language) %>");
    document.getElementById('editor').style.fontSize='18px';
    

    $('#output').html(markdown.toHTML($('#markdown').val()));
    
    var courseidforclass = '<%=request.getParameter("courseidforclass")%>'
    var activityid = <%=request.getAttribute("activityid")%>
    var coursename = '<%=request.getAttribute("coursename")%>'
    var courseclassnum = '<%=request.getAttribute("courseclassnum")%>'
    var problemid = <%=request.getAttribute("problemid")%>
    var selected = "";
    
    if(problemid == 1) document.getElementById('prev').disabled = true;
    if(problemid == <%= acp.size() %>) document.getElementById('next').disabled = true;
    
    const editorContainer = document.getElementById('editorContainer');
    
    function prev() {
    	if(problemid != 1){
    		location.href ='control.jsp?action=seeproblem&courseidforclass=' + courseidforclass + 
    		'&coursename=' + coursename + '&courseclassnum=' + courseclassnum + 
			'&activityid=' + activityid + '&problemid=' + (problemid - 1)
    	}
    	
    }
    
    function next() {
    	if(problemid != <%= acp.size() %>){
    		location.href ='control.jsp?action=seeproblem&courseidforclass=' + courseidforclass + 
    		'&coursename=' + coursename + '&courseclassnum=' + courseclassnum + 
			'&activityid=' + activityid + '&problemid=' + (problemid + 1)
    	}
    }
    
    function unescapeHtml(str) {

    	 if (str == null) {
    	  return "";
    	 }

    	 return str
    	   .replace(/&amp;/g, '&')
    	   .replace(/&lt;/g, '<')
    	   .replace(/&gt;/g, '>')
    	   .replace(/&quot;/g, '"')
    	   .replace(/&#039;/g, "'")
    	   .replace(/&#39;/g, "'");
    	}
    
    function submit() {
    	var form = document.getElementById('forms');
    	var code = editor.getValue();
    	code = unescapeHtml(code);
    	
    	var hiddenField = document.createElement("input");
    	hiddenField.setAttribute("type", "hidden");
    	hiddenField.setAttribute("name", "code");
    	hiddenField.setAttribute("value", code);
    	form.appendChild(hiddenField);
    	
    	form.submit();
    }
    
    function exit() {
    	location.href ='control.jsp?action=seecourse_init'
    }
   
</script>
        </section>
        <!--풋터-->
        <footer>
        <table style="padding: 10px 10px 0px 0px; float:right">
        <tr><td width="100px"><b>문제 점수</b></td><td width="110px"><%= currentscore %> / <%= ap.getMaxscore() %></td>
        <td width="100px"><b>총 점수</b></td><td width="100px"><%= info.getScore() %> / <%= info.getMaxscore() %></td></tr></table>
        </footer>
    </div>
</body>
</html>