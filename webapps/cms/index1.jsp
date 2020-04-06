<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.math.BigDecimal"
         import="java.io.*"
         import="java.text.SimpleDateFormat"
        import="java.lang.AutoCloseable"
%>

<%!
//-static int num_of_participants = 4;

public int random_err_call_no=0; //SIC! это пример для порождения случайных ошибок
public void random_err(){
 random_err_call_no++;
 int i=random_err_call_no;
 if( ((i/3)*3-i) == 0 ) throw( new
RuntimeException("Я разваливаюсь каждый третий раз, try нужен для борьбы со мной"));
}

%>

<%   String dirpath="";
    //dirpath="<a href=qxyz.ru>qxyz.ru/";
    //dirpath="&lt;a&nbsp;href=qxyz.ru&gt;qxyz.ru/";
    dirpath="/tmp/"; //SIC!hranking/webapps/fileinfo/ это я для проверки остального функционала себе заготовил: 
    //dirpath="http://ale777opp.ru"; //SIC! странный выбор для директории для тестового примера, ну хотябы /usr/share/ ;), но ладно
    //SIC! у меня директории dirpath нет, соотв смотрим следующий  "SIC! dirpath" ниже, а также другие SIC! */
    //dirpath="/usr/share/";
    File actual = null;
    try {
     actual = new File(dirpath);
%>
<!Doctype HTML>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
   <!-- <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
   crossorigin="anonymous">  SIC! external-ref давно хотел рассказать на недопустимость ссылок на внешние ресурсы в корпоративных приложениях. Пока оставляй так, но это то, что надо очень хорошо понять -->
   <!-- Bootstrap CSS -->
   <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" 
   crossorigin="anonymous">  <!-- SIC! external-ref (см выше) -->
   <link href="css/style.css" rel="stylesheet">
   <!-- <link rel="shortcut icon" href="img/user.png" type="image/png"> -->
   <link rel="icon" href="img/user.png" type="image/png"> <!-- SIC! кстати, а ты знаешь, что это такое и зачем это нужно? ;)-->
   <title>Просмотр файлов </title>
</head>
<body>
<div class="container">
    <h3 class="text-center"><%out.println("Содержание директории: "+dirpath);%> </h3>  
                                        <!--SIC! любой вывод текста в браузер надо пропускать через
										 функцию экранирования HTML-спецсимволов, их список из
										 ConcepTIS/src/java/zWebapps/ru/mave/ConcepTIS/webapps/WAMessages.java :
										 HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
										 HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","<br>\n"}; -->
	    <table class="table">
        <thead class="thead-light">
        <tr>
            <th scope="col">Имя</th>
            <th scope="col">Путь</th>
            <th scope="col">Свойство</th>
<% random_err(); //SIC! это закладка, чтобы показать проблему с которой мы боремся
%>
            <th scope="col">Последняя модификация</th>
            <th scope="col">Размер,байт</th>
        </tr>
        </thead>
<tbody>
<%
    String ico="";
    String readwrite="";
    for( File f : actual.listFiles()) {
        // SIC! dirpath: соответственно, здесь я получаю HTTP Status 500 – Internal Server Error по NullPointerException
		// исправляй, разбирайся с try & catch, для этого сделай dirname="/path/to/notexists/"
        //   out.println ("Полный путь: " + f.getAbsolutePath());
        //   out.println ("Родительский каталог: " +f.getParent());


    if (f.isDirectory()&!f.isFile()) {ico="<i class=\"icon-folder\"></i>";}
        else if(!f.isDirectory()&f.isFile()){ico="<i class=\"icon-file-text2\"></i>";}
            else ico="<i class=\"icon-share\" ></i>";

    if (f.canWrite()&f.canRead()) {readwrite="чтение/запись";}
        else if (!f.canWrite()&f.canRead()){readwrite="чтение";}
            else {readwrite="запись";}
%>
<tr>
    <td scope="row" class="viewer"><%out.println (ico+"   "+f.getName());%></th>
    <td scope="row"><%=f.getPath() %></td>
    <td scope="row"><%out.println(readwrite);%></td>
    <td scope="row" align="center"><%=new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified())%></td>
    <td scope="row" align="right"><%=f.length()%></td>
</tr>
<%
        } //for( File f : actual.listFiles())
}catch (IOException ex){
out.println("Ошибка ввода вывода : " + ex); //SIC! это пойдет в браузер
ex.printStackTrace(); // SIC! а вот это куда-то в /dev/stderr и оттуда видимо в catalina.out
}
catch(Exception e){ //SIC! для отладки этот блок иногда стоит отключать
out.println("Нераспознанная ошибка: " + e); //SIC! это пойдет в браузер
out.println("попробуйте другую операцию" ); //SIC! это пойдет в браузер (вместо ошибки 500)
}
finally{ //SIC! это эквивалент try(actual){} который есть синтаксический сахар
 // if(actual != null) try{ actual.close(); }catch(Exception e){} // SIC! Но! у объекта File нет метода close()! Файлы не всегда то, чем кажутся (CUNC)
                                                                  // соответственно его вообще нельзя использовать в конструкции try(o){}
}
%>
</tbody>
</table>
</div>
<script>
    let viewers=document.getElementsByClassName("viewer");

    for (let i=0;i<viewers.length;i++){
        viewers[i].addEventListener('click',()=>{

            alert("клик");

        });
    }
</script>
</body>
</html>
