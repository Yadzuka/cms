<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.math.BigDecimal"
%>
<%!
static int dim_menu_main = 8;
static int dim_menu_directory = 9;
static int dim_menu_repository = 8;
static int dim_menu_document = 20;
static int dim_menu_script = 6;
static int dim_menu_network = 6;
static int dim_menu_meta = 7;
static int dim_menu_help = 2;
static int dim_menu_lang = 3;

String[] menu_main = new String[dim_menu_main];
String[] menu_main_ru = new String[]{"Главная","Документы","Репозитории","Директории","Мета-данные","Скрипты","Сети","О программе"};
String[] menu_main_en = new String[]{"Main","Document","Repository","Directory","Meta-data","Script","Network","About"};

String[] menu_directory= new String[dim_menu_directory];
String[] menu_directory_ru = new String[]{"Содержимое","Просмотр","Переместить","Переименовать","Создать","Удалить","Заблокировать","Разблокиовать","#Cоздать#"};
String[] menu_directory_en = new String[]{"Content","View","Move","Rename","Create","Delete","Block","Unblock","#create#"};

String[] menu_repository= new String[dim_menu_repository];
String[] menu_repository_ru = new String[]{"Переименовать","Сохранить версию","Восстановить версию","Заблокировать","Разблокиовать","Создать","Применить изменения","Отменить изменения"};
String[] menu_repository_en = new String[]{"Rename","To save a version","Restored version","Block","Unblock","Create","Apply the changes","Undo the changes"};

String[] menu_document= new String[dim_menu_document];
String[] menu_document_ru = new String[]{"Содержимое","Просмотр","Переместить","Переименовать","Удалить документ","Восстановить","Восстановить версию","Копировать","Редактировать","Заблокировать","Разблокиовать","Создать","Открыть","Записать","Прочитать записанное","Прочитать","Вставить запись","Обновить запись","Удалить запись","Выбрать записи"};
String[] menu_document_en = new String[]{"Content","View","Move","Rename","Delete document","Restore","Restore version","Copy","Edit","Block","Unblock","Create","Open","Write","Read recorded","Read","Insert record","Update record","Delete record","Select records"};

String[] menu_script= new String[dim_menu_script];
String[] menu_script_ru = new String[]{"Исполнить","Исполнить локально","Переименовать","Заблокировать","Разблокиовать","Создать"};
String[] menu_script_en = new String[]{"Execute","To execute locally","Rename","Block","Unblock","Create"};

String[] menu_network= new String[dim_menu_network];
String[] menu_network_ru = new String[]{"HTTP/GET","HTTP/POST","Создать символическую ссылку","Загрузить файл из сети по url","Загрузить","Зыгрузить"
};
String[] menu_network_en = new String[]{"HTTP/GET","HTTP/POST","Create a symbolic link","Upload using the url","Upload","Download"};

String[] menu_meta= new String[dim_menu_meta];
String[] menu_meta_ru = new String[]{"Содержимое","Заблокировать","Разблокиовать","Создать","Изменить [группу] владельца директории","Изменить права","Установить мета-параметры документа"};
String[] menu_meta_en = new String[]{"Content","Block","Unblock","Create","Change the [group] of the directory owner","Change permissions","Set document meta parameters"};

String[] menu_help= new String[dim_menu_help];
String[] menu_help_ru = new String[]{"Помощь","О программе"};
String[] menu_help_en = new String[]{"Help","About"};

String[] menu_lang= new String[dim_menu_lang];
String[] menu_lang_ru = new String[]{"Русский","Английский","Китайский"};
String[] menu_lang_en = new String[]{"Russian","English","Chinese"};

public static final int MNU_LANG_RU = 0;
public static final int MNU_LANG_EN = 1;
public static final int MNU_LANG_ZH = 2;

public static final String LANG_RU = "ru";
public static final String LANG_EN = "en";
public static final String LANG_ZH = "zh";

%>

<!DOCTYPE html>
<html lang="ru">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
	<link rel="shortcut icon" href="img/beacon.png" type="image/png">
   <link rel="icon" href="img/beacon.png" tyPe="image/png">
	<title>CMS CMD menu</title>
<style>
body {
	width: 100%;
	height: 100vh;
	color: #333;
	background: #DEF;
	font-size: 1em;
	font-family: "Tahoma", sans-serif;
	line-height: 135%;
	padding:15px;
}
.btn.btn-link {
  color:black;
}
/*@media (max-width: 992px) {
#left_menu{
  display: none;
}
#right_menu{
  display: none;
}
}
.close{
  position:relative;
  top: -25px;
  right: 25px;
} */
</style>

</head>
<body>

<header>

<nav class="navbar navbar-expand-lg navbar-light bg-light">
 	  <a class="navbar-brand" href="#">
    <img src="img/beacon.png" width="30" height="30" class="d-inline-block align-center" alt="beacon.png"><%=menu_main[0]%></a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
<%
String lang = LANG_RU;

lang = request.getParameter("lang"); //SIC!


menu_main = menu_main_ru;
menu_directory = menu_directory_ru;
menu_repository = menu_repository_ru;
menu_document = menu_document_ru;
menu_script = menu_script_ru;
menu_meta = menu_meta_ru;
menu_network = menu_network_ru;
menu_help = menu_help_ru;
menu_lang = menu_lang_ru;

if(LANG_EN.equals(lang)) {
menu_main = menu_main_en;
menu_directory = menu_directory_en;
menu_repository = menu_repository_en;
menu_document = menu_document_en;
menu_script = menu_script_en;
menu_meta = menu_meta_en;
menu_network = menu_network_en;
menu_help = menu_help_en;
menu_lang = menu_lang_en;
}


%>
  <div class="collapse navbar-collapse" id="navbarSupportedContent">
    <ul class="navbar-nav mr-auto" style='justify-content: space-around; width: 70%;'>
<div>
      <li class="nav-item dropdown">
        <a class="btn btn-outline-secondary dropdown-toggle" href="#" id="mn_directory" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu_main[3]%></a>
	    <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls"><%=menu_directory[0]%></a>
          <a class="dropdown-item" href="#view"><%=menu_directory[1]%></a>
          <a class="dropdown-item" href="#mv"><%=menu_directory[2]%></a>
          <a class="dropdown-item" href="#rename"><%=menu_directory[3]%></a>
          <a class="dropdown-item" href="#mkdir"><%=menu_directory[4]%></a>
          <a class="dropdown-item" href="#rmdir"><%=menu_directory[5]%></a>
          <a class="dropdown-item" href="#lock"><%=menu_directory[6]%></a>
          <a class="dropdown-item" href="#unlock"><%=menu_directory[7]%></a>
          <a class="dropdown-item" href="#create"><%=menu_directory[8]%></a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
		 <div class="btn-group">

  <button type="button" class="btn btn-outline-secondary dropdown-toggle dropdown-toggle-split" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
  <button type="button" class="btn btn-outline-secondary"><%=menu_main[2]%></button>
    <span class="sr-only">Toggle Dropdown</span>
  </button>

    <!--    <a class="nav-link dropdown-toggle" href="#" id="mn_repository" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu_main[2]%></a>
    -->
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#rename"><%=menu_repository[0]%></a>
          <a class="dropdown-item" href="#ci"><%=menu_repository[1]%></a>
          <a class="dropdown-item" href="#co"><%=menu_repository[2]%></a>
          <a class="dropdown-item" href="#lock"><%=menu_repository[3]%></a>
          <a class="dropdown-item" href="#unlock"><%=menu_repository[4]%></a>
          <a class="dropdown-item" href="#create"><%=menu_repository[5]%></a>
          <a class="dropdown-item" href="#commit"><%=menu_repository[6]%></a>
          <a class="dropdown-item" href="#rollbck"><%=menu_repository[7]%></a>
        </div>
        </div>
      </li>
</div>
<div>
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_document" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu_main[1]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls"><%=menu_document[0]%></a>
          <a class="dropdown-item" href="#view"><%=menu_document[1]%></a>
          <a class="dropdown-item" href="#mv"><%=menu_document[2]%></a>
          <a class="dropdown-item" href="#rename"><%=menu_document[3]%></a>
          <a class="dropdown-item" href="#rm"><%=menu_document[4]%></a>
          <a class="dropdown-item" href="#unrm"><%=menu_document[5]%></a>
          <a class="dropdown-item" href="#restore"><%=menu_document[6]%></a>
          <a class="dropdown-item" href="#cp"><%=menu_document[7]%></a>
          <a class="dropdown-item" href="#edit"><%=menu_document[8]%></a>
          <a class="dropdown-item" href="#lock"><%=menu_document[9]%></a>
          <a class="dropdown-item" href="#unlock"><%=menu_document[10]%></a>
          <a class="dropdown-item" href="#create"><%=menu_document[11]%></a>
          <a class="dropdown-item" href="#open"><%=menu_document[12]%></a>
          <a class="dropdown-item" href="#write"><%=menu_document[13]%></a>
          <a class="dropdown-item" href="#wread"><%=menu_document[14]%></a>
          <a class="dropdown-item" href="#read"><%=menu_document[15]%></a>
          <a class="dropdown-item" href="#insert"><%=menu_document[16]%></a>
          <a class="dropdown-item" href="#update"><%=menu_document[17]%></a>
          <a class="dropdown-item" href="#delete"><%=menu_document[18]%></a>
          <a class="dropdown-item" href="#select"><%=menu_document[19]%></a>
        </div>
    </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_meta-data" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu_main[4]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="nav-link dropdown-toggle" href="#" id="mn_meta_doc" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Document</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls"><%=menu_meta[0]%></a>
          <a class="dropdown-item" href="#lock"><%=menu_meta[1]%></a>
          <a class="dropdown-item" href="#unlock"><%=menu_meta[2]%></a>
          <a class="dropdown-item" href="#create"><%=menu_meta[3]%></a>
          <a class="dropdown-item" href="#chown"><%=menu_meta[4]%></a>
          <a class="dropdown-item" href="#chmod"><%=menu_meta[5]%></a>
          <a class="dropdown-item" href="#set"><%=menu_meta[6]%></a>
        </div>


          <a class="nav-link dropdown-toggle" href="#" id="mn_meta_dir" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Directory</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls"><%=menu_meta[0]%></a>
          <a class="dropdown-item" href="#lock"><%=menu_meta[1]%></a>
          <a class="dropdown-item" href="#unlock"><%=menu_meta[2]%></a>
          <a class="dropdown-item" href="#create"><%=menu_meta[3]%></a>
          <a class="dropdown-item" href="#chown"><%=menu_meta[4]%></a>
          <a class="dropdown-item" href="#chmod"><%=menu_meta[5]%></a>
          <a class="dropdown-item" href="#set"><%=menu_meta[6]%></a>
        </div>
        </div>
      </li>
</div>

<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_script" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <%=menu_main[5]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#exec"><%=menu_script[0]%></a>
          <a class="dropdown-item" href="#lexec"><%=menu_script[1]%></a>
          <a class="dropdown-item" href="#rename"><%=menu_script[2]%></a>
          <a class="dropdown-item" href="#lock"><%=menu_script[3]%></a>
          <a class="dropdown-item" href="#unlock"><%=menu_script[4]%></a>
          <a class="dropdown-item" href="#create"><%=menu_script[5]%></a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_network" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <%=menu_main[6]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#get"><%=menu_network[0]%></a>
          <a class="dropdown-item" href="#post"><%=menu_network[1]%></a>
          <a class="dropdown-item" href="#sln"><%=menu_network[2]%></a>
          <a class="dropdown-item" href="#fetch"><%=menu_network[3]%></a>
		      <a class="dropdown-item" href="#upload"><%=menu_network[4]%></a>
          <a class="dropdown-item" href="#downld"><%=menu_network[5]%></a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_help" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <%=menu_main[7]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#help"><%=menu_help[0]%></a>
          <a class="dropdown-item" href="#about"><%=menu_help[1]%></a>
          <a class="dropdown-item" href="?lang=ru"><%=menu_lang[MNU_LANG_RU]%></a>
          <a class="dropdown-item" href="?lang=en"><%=menu_lang[MNU_LANG_EN]%></a>
          <a class="dropdown-item" href="?lang=zh"><%=menu_lang[MNU_LANG_ZH]%></a>
        </div>
      </li>
</div>
</ul>
</div>
<div class="btn-group btn-group-toggle" data-toggle="buttons">
  <label class="btn btn-outline-secondary active">
    <input type="radio" name="options" id="option1" checked><%=menu_lang[MNU_LANG_RU]%></label>
  <label class="btn btn-outline-secondary">
    <input type="radio" name="options" id="option2"><%=menu_lang[MNU_LANG_EN]%></label>
  <label class="btn btn-outline-secondary">
    <input type="radio" name="options" id="option3"><%=menu_lang[MNU_LANG_ZH]%></label>
</div>
</nav>
</header>



<footer class="fixed-bottom" style="background-color: #dfdfdf; height: 50px; font-size: 1em; font-family: sans-serif; font-style:italic">
 <div class="footer-copyright text-center py-3">© Eustrosoft, ConcepTIS v0.4 - stable version of UI (see for UI variants)</div>
</footer>

<script>
/*
 let ru = document.getElementById("option1");
 let eng = document.getElementById("option2");
 let chi = document.getElementById("option3");
 ru.onclick= function () {alert(ru.id)};
 eng.onclick= function () {alert(eng.id)};
 chi.onclick= function () {alert(chi.id)};
*/
</script>

<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</html>
