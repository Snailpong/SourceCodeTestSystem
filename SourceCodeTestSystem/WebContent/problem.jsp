<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="scts.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>SCTS</title>
<link rel="stylesheet" href="css/problem.css">
<jsp:useBean id="activityinfo" scope="request" class="scts.ActivityInfo" />
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
    <div id="wapper">
        <!--헤더시작-->
        <header id="bar">
            <p style = "padding: 0px 0px 0px 15px;">
            <%= request.getParameter("coursename") %> (<%= request.getParameter("courseclassnum") %>)</p>
        </header>
        <header>
            <p style = "padding: 0px 0px 0px 15px;"><%= activityinfo.getActivityname() %></p>
        </header>
        <!--네비게이션-->
        <nav>
            <div style = "padding: 0px 15px 0px 15px;"><p><b>문제</b></p><p>SeekBar는 안드로이드 스튜디오에서 제공하는 기본 위젯 중 하나이다. 아래 그림에서 알 수 있듯이, 왼쪽과 오른쪽으로 잡아당길 수 있으며, 일정 범위 내에서만 값을 조정할 수 있다. 왼쪽으로 당기면 값이 줄어들고, 오른쪽으로 당기면 값이 늘어난다. 최솟값은 1로 고정할 때, 이를 클래스로 구현해 보자.</p><p></p><pre style="border: 1px solid black; padding: 5px; background-color:rgb(255,255,255); font-size:11.0pt;font-family:Consolas;"><img src="http://plms.pusan.ac.kr/draftfile.php/302764/user/draft/564657554/%EC%A0%9C%EB%AA%A9%20%EC%97%86%EC%9D%8C.png" role="presentation" class="img-responsive">
    	</pre><p></p><p style="text-align: center;"><br></p><p></p><p><b>메서드</b></p><p>&nbsp;- Constructor(int max) : 최댓값을 설정해 SeekBar를 생성한다. 초기값은 max/2 (반올림)로 설정한다. (단, max&gt;2)</p><p>&nbsp;- void add() : 1만큼 오른쪽으로 당긴다. 값이 max일 때에는 동작하지 않는다.</p><p>&nbsp;- void substract() : 1만큼 왼쪽으로 당긴다. 값이 1일 때에는 동작하지 않는다.</p><p>&nbsp;- int getValue() : 현재 SeekBar의 값을 리턴한다.</p><p>&nbsp;- drawGraph() : 아래 그림과 같이 현재 위치를 나타내는 그래프를 그린다.</p><p></p><pre style="border: 1px solid black; padding: 5px; background-color:rgb(245,245,245); font-size:11.0pt;font-family:Consolas;">1 2 3 4 5 6
----o
    	</pre>
    	<p></p><br><p></p><p><b>스켈레톤 코드</b></p><p></p><pre style="border: 1px solid black; padding: 5px; background-color:rgb(245,245,245); font-size:11.0pt;font-family:Consolas;">class SeekBar {
	int value;
	int maxValue;

	SeekBar(int max){}
	void add(){}
	void substract(){}
	int getValue(){}
	void drawGraph(){}
}
    	</pre>
    	<p></p><br><b>메인 메서드 예시</b><p></p><pre style="border: 1px solid black; padding: 5px; background-color:rgb(245,245,245); font-size:11.0pt;font-family:Consolas;">public static void main(String[] args) {
	SeekBar sb = new SeekBar(4);
	sb.add();
	sb.add();
	sb.add();
	System.out.printl<a></a>n("current: " + sb.getValue());
	sb.substract();
	sb.drawGraph();
}
    	</pre>
    	<p></p><br><p></p><p><b>메인 메서드 출력</b></p><pre style="border: 1px solid black; padding: 5px; background-color:rgb(245,245,245); font-size:11.0pt;font-family:Consolas;">current: 4
1 2 3 4
----o
    	</pre></div>
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
    //editor.resize();
</script>
        </section>
        <!--풋터-->
        <footer>
        </footer>
    </div>
</body>
</html>