<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.math.BigDecimal"
         import="java.io.*"
         import="java.text.SimpleDateFormat"
        import="java.lang.*"
%>

<%!
public static String text2html(String textin) {
String textout="";
String[] HTML_UNSAFE_CHARACTERS = {"<",">", "&", "\n"," "};
String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;", "&gt;", "&amp;", "<br>\n","&nbsp;"};
char[] textArray = textin.toCharArray();
for (char c:textArray) {

    String word = String.valueOf(c);
        for (int j=0;j<HTML_UNSAFE_CHARACTERS.length;j++) {
            if (HTML_UNSAFE_CHARACTERS[j].equals(word)) {
            word = HTML_UNSAFE_CHARACTERS_SUBST[j];
            break;
            }
        }
    textout = textout + word;
}
return textout;
}
%>

<%
    String dir="";
    String dirpath="";
    //dir="<a href=qxyz.ru>qxyz.ru/";
    dir="/usr/share/";
    dirpath = text2html(dir);
    File actual = null;
    try {
     actual = new File(dirpath);
%>
<!Doctype HTML>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link href="css/style.css" rel="stylesheet">
    <link rel="shortcut icon" href="img/beacon.png" type="image/png">
   <link rel="icon" href="img/beacon.png" type="image/png">
   <title>Просмотр файлов </title>
    <style>
      body {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        overflow: visible;
        font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
	font-size: 1rem;
	font-weight: 400;
	line-height: 1.5;
	color: #212529;
	text-align: left;
       }
      #container {
        display: flex;
        height: 100%;
        width: 100%;
        position: absolute;
       }
     .content {
        display: flex;
        flex-wrap:wrap;
        max-width: 950px;
        margin: 0 auto;
        padding:0 15px;
      }
      .row {
        display: flex;
        border: 2px solid #dee2e6;
        width: 100%;
        flex-wrap: nowrap;
        height: 50px;
      }
      .col {
        display: flex;
        width: 50%;
        margin-left: 15px;
        margin-right: 15px;
     /*   margin-top: 5px;
        margin-bottom: 5px; */
      }
.down_menu {
    display: block;
    position:absolute;
	border: 2px solid #000;
	border-radius: 10%;
	left:1150px;
	width:150px;
	background-color:#f4f4f4;
    padding: 10px;
    text-align: left;
    }
h2 {
	font-face:Arial;
	font-weight:500;
	font-size:1.75rem;"
	}

a {
        font-size: 20px;
	    text-decoration: none;
        color: #000;
      }
a.disabled {
    pointer-events: none;
    cursor: default;
    color: #fa8e47;
    font-family:cursive;
}
.down-item{
	padding:10px;
}
th,td  {
	border-bottom: 1px solid #dee2e6;
	padding:10px;
	color: #495057;
}
table {
    border-collapse: collapse;
   }
tbody tr:hover {
    background: #eaf4ff;
   }
.modal {
    display: none;
    position: fixed;
    z-index: 1;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgba(0,0,0,0.6);
    z-index: 1000;
}
.modal .modal_content {
    background-color: #fefefe;
    margin: 15% auto;
    padding: 10px;
    border: 1px solid #888;
    width: 50%;
    z-index: 99999;
}
.modal .modal_content .close_modal_window {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
}
    </style>
  </head>
<body>
<div id="container">
  <div class="content" style="align-items:center">
    <div class="row">
      <div class="col" style="justify-content: flex-start; align-items:center;">

        <h2>Содержание директории:</h2>

      </div>
      <div class="col" style="justify-content: flex-end; align-items:center;">
        <h2><%out.println(dirpath);%></h2>
      </div>
    </div>

<div class="table" style="width: 100%">
	    <table width="100%">
        <thead >
        <tr style="background-color: #e9ecef;">
            <th scope="col">Имя</th>
            <th scope="col">Путь</th>
            <th scope="col">Свойство</th>
            <th scope="col">Последняя модификация</th>
            <th scope="col">Размер,байт</th>
        </tr>
        </thead>
        <tbody>

                            <tr>
                            <td scope="row" class="viewer"><i class="icon-share"> ...</i></td>
                            <td scope="row">____</td>
                            <td scope="row" align="center">____</td>
                            <td scope="row" align="center">____</td>
                            <td scope="row" align="right">____</td>
                            </tr>
<%          String ico="";
            String readwrite="";

     for( File f : actual.listFiles()) {

                            if (f.isDirectory()&!f.isFile()) {ico="<i class=\"icon-folder\"></i>";}
                                else if(!f.isDirectory()&f.isFile()){ico="<i class=\"icon-file-text2\"></i>";}
                                    else ico="<i class=\"icon-link\" ></i>";

                            if (f.canWrite()&f.canRead()) {readwrite="чтение/запись";}
                                else if (!f.canWrite()&f.canRead()){readwrite="чтение";}
                                    else {readwrite="запись";}
%>
                        <tr class="strdir">
                            <td scope="row" class="viewer"><%out.println (ico+"   "+f.getName());%></td>
                            <td scope="row"><%=f.getPath() %></td>
                            <td scope="row" align="center"><%out.println(readwrite);%></td>
                            <td scope="row" align="center"><%=new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified())%></td>
                            <td scope="row" align="right"><%=f.length()%></td>
                        </tr>
<%
        } //for( File f : actual.listFiles())
            }catch (IOException ex){
            out.println("Ошибка ввода вывода : " + ex);
            ex.printStackTrace();
            }
            catch(Exception e){
            out.println("Нераспознанная ошибка: " + e);
            out.println("попробуйте другую операцию" );
            }
            finally{}
%>
</tbody>
</table>
</div>


</div>
<script>
	let item_col=0;
    let button = document.getElementsByClassName("strdir");
    for(let i=0;i<button.length;i++){
      	button[i].addEventListener("click",itemClick);
  }

/*
let item = event.currentTarget.offsetTop;
let item1 = event.currentTarget.innerText;
let item2 = event.currentTarget.rowIndex;
let item3 = event.currentTarget.sectionRowIndex;
*/

function itemClick(event) {
/*let items_sel = [];*/
	let item_sel=event.currentTarget;
	    if (item_sel.style.backgroundColor == ''){
         	item_sel.style.backgroundColor = 'rgb(170, 213, 255)';
         	item_col++;
         	coordY = item_sel.offsetTop;
			coordY = coordY+'px';
         	if(item_col==1){
        		let div = document.createElement('div');
        		div.innerHTML = `<div class="down-item"><a id="btn_modal_window" href="#" onclick="editor()">Просмотреть</a></div>
            	<div class="down-item"><a href="#">Скачать</a></div><hr>
				      <div class="down-item"><a>Выбрано: <span id="col_sel"></span></a></div>`;
       			div.className="down_menu";
       			div.id='menu'
    			document.body.append(div);
    		}
    		menu.style.top= coordY;
    		document.getElementById('col_sel').innerHTML=item_col;
    		if(item_col>=2){menu.children[0].children[0].className='disabled';}
        } else {
        	item_sel.style.backgroundColor = '';
        	item_col--;
        	coordY = item_sel.offsetTop;
			coordY = coordY+'px';
			menu.style.top= coordY;
        	if (item_col==1){menu.children[0].children[0].className='';}
        	if (item_col==0){menu.remove();
        	}else{document.getElementById('col_sel').innerHTML=item_col;}
        }
}
function editor(event){
let edit = document.createElement('div');
    edit.innerHTML = `<div>
    <div class="modal_content">
    <p align="center" style="font-size: 28px;">Редактирование/просмотр <span class="close_modal_window">×</span></p>
    <hr>
<br>
<iframe id="iframe_redactor" width='100%' height='100%' scrolling='yes' frameborder='yes' src='#' ></iframe>
</div></div>`;
    edit.className="modal";
    edit.id='my_modal'
 document.body.append(edit);

var modal = document.getElementById("my_modal");
var btn = document.getElementById("btn_modal_window");
var span = document.getElementsByClassName("close_modal_window")[0];

 btn.onclick = function () {
    modal.style.display = "block";
    Init();
 }

 span.onclick = function () {
    modal.style.display = "none";
 }

 window.onclick = function (event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
function Init()
    {
    //	document.getElementById("iframe_redactor").contentWindow.document.designMode = "On";

    let isframe = document.getElementById("iframe_redactor");
    let isWindow = isframe.contentWindow;
    let isDocument = isframe.contentDocument;
    iHTML = "<html><head></head><body style='background-color: yellow;font-size: 20px;'><span>Lorem ipsum dolor sitt,..</span></body></html>";
    isDocument.open();
    isDocument.write(iHTML);
    isDocument.close();
    isDocument.designMode = "on";
}
function save() {
      document.getElementById("content").value = isDocument.body.innerHTML;
      alert(iDoc.body.innerHTML);
      iHTML_content=isDocument.body.innerHTML;
      return true;
    }

}
</script>
</body>
</html>
