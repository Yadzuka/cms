<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.math.BigDecimal"
%>
<%!
static int DIM_MENU_MAIN = 9;
static int DIM_MENU_DOCUMENT = 20;
static int DIM_MENU_REPOSITORY = 8;
static int DIM_MENU_DIRECTORY = 9;
static int DIM_MENU_META = 7;
static int DIM_MENU_SCRIPT = 6;
static int DIM_MENU_NETWORK = 6;
static int DIM_MENU_HELP = 2;
static int DIM_MENU_LANG = 3;

public final static int DIM_MENU = 70;

public static String menu[] = new String[DIM_MENU];

public final static String[] menu_ru = {
//main
"Главная","Документы","Репозитории","Директории","Мета-данные","Скрипты","Сети","О программе","Выбор языка",
//directory
"Содержимое","Просмотр","Переместить","Переименовать","Создать","Удалить","Заблокировать","Разблокиовать","#Cоздать#",
//repository
"Переименовать","Сохранить версию","Восстановить версию","Заблокировать","Разблокиовать","Создать","Применить изменения","Отменить изменения",
//document
"Содержимое","Просмотр","Переместить","Переименовать","Удалить документ","Восстановить","Восстановить версию","Копировать","Редактировать","Заблокировать","Разблокиовать","Создать","Открыть","Записать","Прочитать записанное","Прочитать","Вставить запись","Обновить запись","Удалить запись","Выбрать записи",
//meta
"Содержимое","Заблокировать","Разблокиовать","Создать","Изменить [группу] владельца директории","Изменить права","Установить мета-параметры документа",
//script
"Исполнить","Исполнить локально","Переименовать","Заблокировать","Разблокиовать","Создать",
//network
"HTTP/GET","HTTP/POST","Создать символическую ссылку","Загрузить файл из сети по url","Обновить","Загрузить",
//help
"Помощь","О программе",
//language
"Русский","Английский","Китайский"
};

public final static String[] menu_en = {
//main
"Main","Document","Repository","Directory","Meta-data","Script","Network","About","Select language",
//directory
"Content","View","Move","Rename","Create","Delete","Block","Unblock","#create#",
//repository
"Rename","To save a version","Restored version","Block","Unblock","Create","Apply the changes","Undo the changes",
//document
"Content","View","Move","Rename","Delete document","Restore","Restore version","Copy","Edit","Block","Unblock","Create","Open","Write","Read recorded","Read","Insert record","Update record","Delete record","Select records",
//meta
"Content","Block","Unblock","Create","Change the [group] of the directory owner","Change permissions","Set document meta parameters",
//script
"Execute","To execute locally","Rename","Block","Unblock","Create",
//network
"HTTP/GET","HTTP/POST","Create a symbolic link","Upload using the url","Upload","Download",
//help
"Help","About",
//language
"Russian","English","Chinese"
};

public static final int IND_MAIN_MAIN = 0;
public static final int IND_MAIN_DOC = 1;
public static final int IND_MAIN_REPO = 2;
public static final int IND_MAIN_DIR = 3;
public static final int IND_MAIN_META = 4;
public static final int IND_MAIN_SCRIPT = 5;
public static final int IND_MAIN_NET = 6;
public static final int IND_MAIN_HELP = 7;
public static final int IND_MAIN_LANG = 8;

public static final int IND_DOC_LS = DIM_MENU_MAIN;
public static final int IND_DOC_VIEW = DIM_MENU_MAIN+1;
public static final int IND_DOC_MV = DIM_MENU_MAIN+2;
public static final int IND_DOC_RENAME = DIM_MENU_MAIN+3;
public static final int IND_DOC_RM = DIM_MENU_MAIN+4;
public static final int IND_DOC_UNRM = DIM_MENU_MAIN+5;
public static final int IND_DOC_RESTORE = DIM_MENU_MAIN+6;
public static final int IND_DOC_CP = DIM_MENU_MAIN+7;
public static final int IND_DOC_EDIT = DIM_MENU_MAIN+8;
public static final int IND_DOC_LOCK = DIM_MENU_MAIN+9;
public static final int IND_DOC_UNLOCK = DIM_MENU_MAIN+10;
public static final int IND_DOC_CREATE = DIM_MENU_MAIN+11;
public static final int IND_DOC_OPEN = DIM_MENU_MAIN+12;
public static final int IND_DOC_WRITE = DIM_MENU_MAIN+13;
public static final int IND_DOC_WREAD = DIM_MENU_MAIN+14;
public static final int IND_DOC_READ = DIM_MENU_MAIN+15;
public static final int IND_DOC_INSERT = DIM_MENU_MAIN+16;
public static final int IND_DOC_UPDATE = DIM_MENU_MAIN+17;
public static final int IND_DOC_DELETE = DIM_MENU_MAIN+18;
public static final int IND_DOC_SELECT = DIM_MENU_MAIN+19;

public static final int IND_REPO=DIM_MENU_MAIN + DIM_MENU_DOCUMENT;

public static final int IND_REPO_RENAME = IND_REPO;
public static final int IND_REPO_CI = IND_REPO + 1;
public static final int IND_REPO_CO = IND_REPO + 2;
public static final int IND_REPO_LOCK = IND_REPO + 3;
public static final int IND_REPO_UNLOCK = IND_REPO + 4;
public static final int IND_REPO_CREATE = IND_REPO + 5;
public static final int IND_REPO_COMMIT = IND_REPO + 6;
public static final int IND_REPO_ROLLBCK = IND_REPO + 7;

public static final int IND_DIR = IND_REPO + DIM_MENU_REPOSITORY;

public static final int IND_DIR_LS = IND_DIR;
public static final int IND_DIR_VIEW = IND_DIR + 1;
public static final int IND_DIR_MV = IND_DIR + 2;
public static final int IND_DIR_RENAME = IND_DIR + 3;
public static final int IND_DIR_MKDIR = IND_DIR + 4;
public static final int IND_DIR_RMDIR = IND_DIR + 5;
public static final int IND_DIR_LOCK = IND_DIR + 6;
public static final int IND_DIR_UNLOCK = IND_DIR + 7;
public static final int IND_DIR_CREATE = IND_DIR + 8;

public static final int IND_META = IND_DIR + DIM_MENU_DIRECTORY;

public static final int IND_META_LS = IND_META;
public static final int IND_META_LOCK = IND_META + 1;
public static final int IND_META_UNLOCK = IND_META + 2;
public static final int IND_META_CREATE = IND_META + 3;
public static final int IND_META_CHOWN = IND_META + 4;
public static final int IND_META_CHMOD = IND_META + 5;
public static final int IND_META_SET = IND_META + 6;

public static final int IND_SCRIPT = IND_META + DIM_MENU_META;

public static final int IND_SCRIPT_EXEC = IND_SCRIPT;
public static final int IND_SCRIPT_LEXEC = IND_SCRIPT + 1;
public static final int IND_SCRIPT_RENAME = IND_SCRIPT + 2;
public static final int IND_SCRIPT_LOCK = IND_SCRIPT + 3;
public static final int IND_SCRIPT_UNLOCK = IND_SCRIPT + 4;
public static final int IND_SCRIPT_CREATE = IND_SCRIPT + 5;

public static final int IND_NET = IND_SCRIPT + DIM_MENU_SCRIPT;

public static final int IND_NET_GET = IND_NET;
public static final int IND_NET_POST = IND_NET + 1;
public static final int IND_NET_SLN = IND_NET + 2;
public static final int IND_NET_FETCH = IND_NET + 3;
public static final int IND_NET_UPLOAD = IND_NET + 4;
public static final int IND_NET_DOUWLD = IND_NET + 5;

public static final int IND_HELP = IND_NET + DIM_MENU_NETWORK;

public static final int IND_HELP_HELP = IND_HELP;
public static final int IND_HELP_ABOUT = IND_HELP + 1;

public static final int IND_LANG = IND_HELP + DIM_MENU_HELP;

public static final int IND_LANG_RU = IND_LANG;
public static final int IND_LANG_EN = IND_LANG + 1;
public static final int IND_LANG_ZH = IND_LANG + 2;

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
  <link rel="shortcut icon" href="beacon.png" type="image/png">
   <link rel="icon" href="beacon.png" type="image/png">
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

} */
</style>

</head>
<body>

<header>
<%
String lang = LANG_RU;
menu = menu_ru;
lang = request.getParameter("lang"); //SIC!
if(LANG_EN.equals(lang)) {
menu = menu_en;
lang = LANG_EN;
}
%>

<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="#">
    <img src="beacon.png" width="30" height="30" class="d-inline-block align-center" alt="beacon.png"><%=menu[IND_MAIN_MAIN]%></a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>

  <div class="collapse navbar-collapse" id="navbarSupportedContent">
    <ul class="navbar-nav mr-auto" style='justify-content: space-around; width: 70%;'>

<div>
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_document" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_DOC]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?doc=ls"><%=menu[IND_DOC_LS]%></a>
          <a class="dropdown-item" href="?doc=view"><%=menu[IND_DOC_VIEW]%></a>
          <a class="dropdown-item" href="?doc=mv"><%=menu[IND_DOC_MV]%></a>
          <a class="dropdown-item" href="?doc=rename"><%=menu[IND_DOC_RENAME]%></a>
          <a class="dropdown-item" href="?doc=rm"><%=menu[IND_DOC_RM]%></a>
          <a class="dropdown-item" href="?doc=unrm"><%=menu[IND_DOC_UPDATE]%></a>
          <a class="dropdown-item" href="?doc=restore"><%=menu[IND_DOC_RESTORE]%></a>
          <a class="dropdown-item" href="?doc=cp"><%=menu[IND_DOC_CP]%></a>
          <a class="dropdown-item" href="?doc=edit"><%=menu[IND_DOC_EDIT]%></a>
          <a class="dropdown-item" href="?doc=lock"><%=menu[IND_DOC_LOCK]%></a>
          <a class="dropdown-item" href="?doc=unlock"><%=menu[IND_DOC_UPDATE]%></a>
          <a class="dropdown-item" href="?doc=create"><%=menu[IND_DOC_CREATE]%></a>
          <a class="dropdown-item" href="?doc=open"><%=menu[IND_DOC_OPEN]%></a>
          <a class="dropdown-item" href="?doc=write"><%=menu[IND_DOC_WRITE]%></a>
          <a class="dropdown-item" href="?doc=wread"><%=menu[IND_DOC_WREAD]%></a>
          <a class="dropdown-item" href="?doc=read"><%=menu[IND_DOC_READ]%></a>
          <a class="dropdown-item" href="?doc=insert"><%=menu[IND_DOC_INSERT]%></a>
          <a class="dropdown-item" href="?doc=update"><%=menu[IND_DOC_UPDATE]%></a>
          <a class="dropdown-item" href="?doc=delete"><%=menu[IND_DOC_DELETE]%></a>
          <a class="dropdown-item" href="?doc=select"><%=menu[IND_DOC_SELECT]%></a>
        </div>
    </li>
</div>

<div>
      <li class="nav-item dropdown">
     <div class="btn-group">

  <button type="button" class="btn btn-outline-secondary dropdown-toggle dropdown-toggle-split" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
  <button type="button" class="btn btn-outline-secondary"><%=menu[IND_MAIN_REPO]%></button>
    <span class="sr-only">Toggle Dropdown</span>
  </button>

    <!--    <a class="nav-link dropdown-toggle" href="#" id="mn_repository" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_REPO]%></a>
    -->
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?repo=rename"><%=menu[IND_REPO_RENAME]%></a>
          <a class="dropdown-item" href="?repo=ci"><%=menu[IND_REPO_CI]%></a>
          <a class="dropdown-item" href="?repo=co"><%=menu[IND_REPO_CO]%></a>
          <a class="dropdown-item" href="?repo=lock"><%=menu[IND_REPO_LOCK]%></a>
          <a class="dropdown-item" href="?repo=unlock"><%=menu[IND_REPO_UNLOCK]%></a>
          <a class="dropdown-item" href="?repo=create"><%=menu[IND_REPO_CREATE]%></a>
          <a class="dropdown-item" href="?repo=commit"><%=menu[IND_REPO_COMMIT]%></a>
          <a class="dropdown-item" href="?repo=rollbck"><%=menu[IND_REPO_ROLLBCK]%></a>
        </div>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="btn btn-outline-secondary dropdown-toggle" href="#" id="mn_directory" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_DIR]%></a>
      <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?dir=ls"><%=menu[IND_DIR_LS]%></a>
          <a class="dropdown-item" href="?dir=view"><%=menu[IND_DIR_VIEW]%></a>
          <a class="dropdown-item" href="?dir=mv"><%=menu[IND_DIR_MV]%></a>
          <a class="dropdown-item" href="?dir=rename"><%=menu[IND_DIR_RENAME]%></a>
          <a class="dropdown-item" href="?dir=mkdir"><%=menu[IND_DIR_MKDIR]%></a>
          <a class="dropdown-item" href="?dir=rmdir"><%=menu[IND_DIR_RMDIR]%></a>
          <a class="dropdown-item" href="?dir=lock"><%=menu[IND_DIR_LOCK]%></a>
          <a class="dropdown-item" href="?dir=unlock"><%=menu[IND_DIR_UNLOCK]%></a>
          <a class="dropdown-item" href="?dir=create"><%=menu[IND_DIR_CREATE]%></a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_meta_data" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_META]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="nav-link dropdown-toggle" href="#" id="mn_meta_doc" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_DOC]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?meta_doc=ls"><%=menu[IND_META_LS]%></a>
          <a class="dropdown-item" href="?meta_doc=lock"><%=menu[IND_META_LOCK]%></a>
          <a class="dropdown-item" href="?meta_doc=unlock"><%=menu[IND_META_UNLOCK]%></a>
          <a class="dropdown-item" href="?meta_doc=create"><%=menu[IND_META_CREATE]%></a>
          <a class="dropdown-item" href="?meta_doc=chown"><%=menu[IND_META_CHOWN]%></a>
          <a class="dropdown-item" href="?meta_doc=chmod"><%=menu[IND_META_CHMOD]%></a>
          <a class="dropdown-item" href="?meta_doc=set"><%=menu[IND_META_SET]%></a>
        </div>

          <a class="nav-link dropdown-toggle" href="#" id="mn_meta_dir" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_DIR]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?meta_doc=ls"><%=menu[IND_META_LS]%></a>
          <a class="dropdown-item" href="?meta_doc=lock"><%=menu[IND_META_LOCK]%></a>
          <a class="dropdown-item" href="?meta_doc=unlock"><%=menu[IND_META_UNLOCK]%></a>
          <a class="dropdown-item" href="?meta_doc=create"><%=menu[IND_META_CREATE]%></a>
          <a class="dropdown-item" href="?meta_doc=chown"><%=menu[IND_META_CHOWN]%></a>
          <a class="dropdown-item" href="?meta_doc=chmod"><%=menu[IND_META_CHMOD]%></a>
          <a class="dropdown-item" href="?meta_doc=set"><%=menu[IND_META_SET]%></a>
        </div>
        </div>
      </li>
</div>

<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_script" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <%=menu[IND_MAIN_SCRIPT]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?script=exec"><%=menu[IND_SCRIPT_EXEC]%></a>
          <a class="dropdown-item" href="?script=lexec"><%=menu[IND_SCRIPT_LEXEC]%></a>
          <a class="dropdown-item" href="?script=rename"><%=menu[IND_SCRIPT_RENAME]%></a>
          <a class="dropdown-item" href="?script=lock"><%=menu[IND_SCRIPT_LOCK]%></a>
          <a class="dropdown-item" href="?script=unlock"><%=menu[IND_SCRIPT_UNLOCK]%></a>
          <a class="dropdown-item" href="?script=create"><%=menu[IND_SCRIPT_CREATE]%></a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_network" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <%=menu[IND_MAIN_NET]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?network=get"><%=menu[IND_NET_GET]%></a>
          <a class="dropdown-item" href="?network=post"><%=menu[IND_NET_POST]%></a>
          <a class="dropdown-item" href="?network=sln"><%=menu[IND_NET_SLN]%></a>
          <a class="dropdown-item" href="?network=fetch"><%=menu[IND_NET_FETCH]%></a>
      <a class="dropdown-item" href="?network=upload"><%=menu[IND_NET_UPLOAD]%></a>
          <a class="dropdown-item" href="?network=downld"><%=menu[IND_NET_DOUWLD]%></a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_help" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <%=menu[IND_MAIN_HELP]%></a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="?help=help"><%=menu[IND_HELP_HELP]%></a>
          <a class="dropdown-item" href="?help=about"><%=menu[IND_HELP_ABOUT]%></a>
        </div>
      </li>
</div>
</ul>
</div>

<div class="dropdown">
  <a class="btn btn-outline-secondary dropdown-toggle" href="#" role="button" id="mn_lang" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%=menu[IND_MAIN_LANG]%></a>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
    <a class="dropdown-item" href="?lang=ru"><%=menu[IND_LANG_RU]%></a>
    <a class="dropdown-item" href="?lang=en"><%=menu[IND_LANG_EN]%></a>
    <a class="dropdown-item" href="?lang=zh"><%=menu[IND_LANG_ZH]%></a>
  </div>
</div>
</nav>
</header>

<footer class="fixed-bottom" style="background-color: #dfdfdf; height: 50px; font-size: 1em; font-family: sans-serif; font-style:italic">
 <div class="footer-copyright text-center py-3">© Eustrosoft, ConcepTIS v0.4 - stable version of UI (see for UI variants)</div>
</footer>

<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</html>