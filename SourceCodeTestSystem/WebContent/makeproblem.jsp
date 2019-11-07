<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="css/problem.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/js/tui.editor/examples/css/tuidoc-example-style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/js/tui.editor/dist/tui-editor.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/js/tui.editor/dist/tui-editor-contents.css">
<script src="https://code.jquery.com/jquery-1.10.2.js"></script>
<script src="${pageContext.request.contextPath}/js/tui.editor/dist/tui-editor-Editor-full.js"></script>
<script src="${pageContext.request.contextPath}/js/ace-builds/src-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.48.4/codemirror.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css">
<script src="../dist/tui-editor-Editor-full.js"></script>
<meta charset="UTF-8">
<title>SCTS</title>

</head>
<body>

<form action=control.jsp method=post id=forms>
<input type=hidden name="action" value="makeproblem">
<input type=hidden name="courseidforclass" value="<%= request.getParameter("courseidforclass") %>">
<br>문제 이름 <input type="text" name="problemname">
<br><br>문제<br>
<div class="contents code-html">
<div id="editSection"></div>
</div><br><br>
자동 채점 여부 <select name="auto_scoring_yn">
	<option value="auto">자동 채점</option>
	<option value="notauto">수동 채점</option>
</select>

<br><br>테스트 케이스<br>
<button type="button" name="addStaff">테스트 케이스 추가</button>
<button class="btn btn-default" type="button" name="delStaff">테스트 케이스 삭제</button>
    <br>
    <br>
    <table>
        <tbody>
            <tr name="trStaff">
                <td>
                    <input type="text" name="input_0" placeholder="입력1" style="width:400px; height:100px">
                    <input type="text" name="output_0" placeholder="출력1" style="width:400px; height:100px">
                    
                </td>
            </tr>
        </tbody>
    </table>
<br><br><input type="submit" value="확인" onclick="submitfunc()">
</form>

<script class="code-js">
	
	var editor = new tui.Editor({
	    el: document.querySelector('#editSection'),
	    previewStyle: 'vertical',
	    height: '500px',
	    initialEditType: 'wysiwyg'
	  });
	
	var num = 1;
    //추가 버튼
    $(document).on("click","button[name=addStaff]",function(){
        
        var addStaffText =  '<tr name="trStaff">'+
            '   <td>'+
            '   <input type="text" name="input_' + num+ + '" placeholder="입력" style="width:400px; height:100px">' +
            '       <input type="text" name="output_' + num + '" placeholder="출력" style="width:400px; height:100px">'+
            '       </td>'+
            '       </tr>';
        
        var trHtml = $( "tr[name=trStaff]:last" ); //last를 사용하여 trStaff라는 명을 가진 마지막 태그 호출
         
        trHtml.after(addStaffText); //마지막 trStaff명 뒤에 붙인다.
        num = num + 1;
         
    });
     
    //삭제 버튼
    $(document).on("click","button[name=delStaff]",function(){
        if(num != 1){
        	num = num - 1;
        	var trHtml = $( "input[name=input_" + num + "]" ).parent().parent();
            trHtml.remove(); //tr 테그 삭제
        }
    });
    
    function submitfunc(){
    	var form = document.getElementById('forms');
    	var markdown = editor.getValue();
    	
    	var hiddenField = document.createElement("input");
    	hiddenField.setAttribute("type", "hidden");
    	hiddenField.setAttribute("name", "markdown");
    	hiddenField.setAttribute("value", markdown);

    	form.appendChild(hiddenField);
    }
    
</script>

</body>
</html>