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

static final String MT_DROPDOWN = "D";
static final String MT_SEPARATOR = "-";
static final String MT_HREF = "H";
static final String MT_CMD = "C";
static final String MT_CMD_D = "CD";
static final String MT_CMD_JS = "JS";
static final String MT_LANG = "JS";

static final String Y = "Y";
static final String N = "Y";
static String[] MENU = new String[]{
//lvl,	id,	enabled,type,	action,	caption[en],ru,zh,custom
null,null,null,null,null,null,null,null,null, // this item ignored
//"-",	MNU_MAIN,	Y,MT_HREF,	"./",	"Main","Главная","主要",null,
//"--",	MNU_CMS_CP,	Y,MT_CMD,	null,   "Copy..","Копировать","复制",null,
//"-",	MNU_SCRIPT,	Y,MT_DROPDOWN,	null,	"Script","Скрипты",脚本,null,
//"--",	MNU_LANG_ZH,	Y,MT_LANG,	null,	"中文","中文","中文",null,
"-",	"main",	Y,MT_HREF,	"./",	"Main","Главная","主要",null,
"-",	"doc",	Y,MT_DROPDOWN,	null,	"Document","Документы","文件",
 "--",	"view",	Y,MT_CMD,	null,   "View","Просмотр","看",null,
 "--",	"mv",	Y,MT_CMD,	null,   "Move",	"Переместить","迁移" ,null,
 "--",	"rename",Y,MT_CMD,	null,   "Rename","Переименовать","改名",null,
 "--",	"cp",	Y,MT_CMD,	null,   "Copy..","Копировать","复制",null,
 "--",	"edit",	Y,MT_CMD,	null,   "Edit","Редактировать","编辑",null,
 "---",	"text",	Y,MT_CMD,	null,   "as text","как текст","文本",null,
 "---",	"create",Y,MT_CMD,	null,   "Create","Создать","创建",null,
 "---",	"rm",	Y,MT_CMD,	null,   "Delete","Удалить","删除",null,
 "--",	"locks",Y,MT_DROPDOWN,	null,	"Locks","Блокировки","锁",null,
 "---",	"lock",	Y,MT_CMD,	null,   "Lock","Заблокировать","锁",null,
 "---",	"unlock",Y,MT_CMD,	null,   "Unlock","Разблокиовать","开锁",null,
"-",	"repo",	Y,MT_DROPDOWN,	null,	"Repo","Репозитории","仓库",null,
 "--",	"mnu1",	Y,MT_CMD,	null,	"Menu 1","Меню 1","選單 一",null,
 "--",	"mnu2",	Y,MT_CMD,	null,	"Menu 2","Меню 2","選單 二",null,
 "--",	"mnu3",	Y,MT_CMD,	null,	"Menu 3","Меню 3","選單 三",null,
 "--",	"sep1",	Y,MT_SEPARATOR,	null,	"-","-","-",null,
 "--",	"mnu3",	Y,MT_CMD,	null,	"Menu 4","Меню 4","選單 二乘二",null,
//"-",	"dir",	Y,MT_DROPDOWN,	null,	"Dir","Директории","Dir",null,
"-",	"meta",	Y,MT_DROPDOWN,	null,	"Meta-data","Мета-данные","元数据",null,
 "--",	"mnu1",	Y,MT_CMD,	null,	"Menu 1","Меню 1","選單 一",null,
 "--",	"mnu2",	Y,MT_CMD,	null,	"Menu 2","Меню 2","選單 二",null,
 "--",	"mnu3",	Y,MT_CMD,	null,	"Menu 3","Меню 3","選單 三",null,
 "--",	"sep1",	Y,MT_SEPARATOR,	null,	"-","-","-",null,
 "--",	"mnu3",	Y,MT_CMD,	null,	"Menu 4","Меню 4","選單 二乘二",null,
"-",	"scrpt",Y,MT_DROPDOWN,	null,	"Script","Скрипты","脚本",null,
 "--",	"mnu1",	Y,MT_CMD,	null,	"Menu 1","Меню 1","選單 一",null,
 "--",	"mnu2",	Y,MT_CMD,	null,	"Menu 2","Меню 2","選單 二",null,
 "--",	"mnu3",	Y,MT_CMD,	null,	"Menu 3","Меню 3","選單 三",null,
 "--",	"sep1",	Y,MT_SEPARATOR,	null,	"-","-","-",null,
 "--",	"mnu3",	Y,MT_CMD,	null,	"Menu 4","Меню 4","選單 二乘二",null,
"-",	"net",	Y,MT_DROPDOWN,	null,	"Net","Сеть","网",null,
"-",	"help",	Y,MT_DROPDOWN,	null,	"Help","Справка","咨询室",null,
"-",	"lang",	Y,MT_DROPDOWN,	null,	"Lang","Язык","语言",null,
 "--",	"ru",	Y,MT_LANG,	null,	"Русский","Русский","Русский",null,
 "--",	"en",	Y,MT_LANG,	null,	"English","English","English",null,
 "--",	"zh",	Y,MT_LANG,	null,	"中文","中文","中文",null,
 "--",	"customlang",Y,MT_LANG,	null,	"Custom language","Пользовательский язык","自订语言",null,
null,null,null,null,null,null,null,null,null // this item ignored too
};

public static final String LANG_RU = "ru";
public static final String LANG_EN = "en";
public static final String LANG_ZH = "zh";
public static final String LANG_CUSTOM = "customlan";

public static final int MENU_II_LEVEL = 0;
public static final int MENU_II_ID = 1;
public static final int MENU_II_ENABLED = 2;
public static final int MENU_II_TYPE = 3;
public static final int MENU_II_ACTION = 4;
public static final int CAPTION_EN = 5;
public static final int CAPTION_RU = 6;
public static final int CAPTION_ZH = 7;
public static final int CAPTION_CUSTOM = 8;
public static final int MENU_II_CAPTION_DEFAULT = CAPTION_RU;
public int MENU_II_CAPTION = MENU_II_CAPTION_DEFAULT;


private static final int MAX_MENU_PATH = 5;
private static final String MENU_ID_PREFIX = "mnu";
private static final String MENU_ID_SEP = "_";

String[] MENU_PATH = new String[MAX_MENU_PATH]; // current path to menu
private int MENU_LEVEL=0; //current level of menu
private String get_menu_id(String id){MENU_PATH[MENU_LEVEL]=id; id=MENU_ID_PREFIX; for(int i=0;i<MENU_LEVEL;i++){id=id + MENU_ID_SEP + MENU_PATH[i];} return(id); }

// print whole menu for curent page
public void printMenuPage() {print_MenuPage(); }
//set of WASkin methods for creating menu
public void beginMenuNavBar(){print_beginMenuNavBar(); }
public void closeMenuNavBar(){print_closeMenuNavBar();}
public void beginMenu(){MENU_LEVEL++;print_beginMenu();} // do nothing or something
public void closeMenu(){MENU_LEVEL--;print_closeMenu();}
public void printMenuItem(String id,String type,String action, String caption){print_MenuItem(id,type,action,caption);}

//
// private methods - implementeation of public ones
//
public void print_MenuPage()
{
 //
}
//set of WASkin methods for creating menu
public void print_beginMenuNavBar(){
 //print_begingMenuNavBar();
}
public void print_closeMenuNavBar(){
 //print_closeMenuNavBar();
}
public void print_beginMenu(){
MENU_LEVEL++;print_beginMenu();
}
public void print_closeMenu(){
 MENU_LEVEL--;print_closeMenu();
}
public void print_MenuItem(String id,String type,String action, String caption){
//print_MenuItem(id,type,action,caption);
}
//
// basic WASkin methods
//
    private JspWriter out;
    private void w(String s) {
        boolean is_error = false;
        try { out.print(s); }
        catch (Exception e) { is_error = true; }
    }
    private void wln(String s){ w(s);w("\n");}
    private void wln(){w("\n");}
void setMenuOut(JspWriter m_out) {out = m_out;}

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
    <img src="img/beacon.png" width="30" height="30" class="d-inline-block align-center" alt="beacon.png">&lt;=menu_main[0]%&gt;</a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
<%
// printMenu();
%>
<div class="collapse navbar-collapse" id="navbarSupportedContent">
<ul class="navbar-nav mr-auto" style='justify-content: space-around; width: 70%;'>
<div>
      <li class="nav-item dropdown">
        <a class="btn btn-outline-secondary dropdown-toggle" href="#" id="mn_directory"
           role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">&lt;=menu_main[3]%&gt;</a>
	<div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls">&lt;=menu_directory[0]%&gt;</a>
          <a class="dropdown-item" href="#view">&lt;=menu_directory[1]%&gt;</a>
          <a class="dropdown-item" href="#mv">&lt;=menu_directory[2]%&gt;</a>
          <a class="dropdown-item" href="#rename">&lt;=menu_directory[3]%&gt;</a>
          <a class="dropdown-item" href="#mkdir">&lt;=menu_directory[4]%&gt;</a>
          <a class="dropdown-item" href="#rmdir">&lt;=menu_directory[5]%&gt;</a>
          <a class="dropdown-item" href="#lock">&lt;=menu_directory[6]%&gt;</a>
          <a class="dropdown-item" href="#unlock">&lt;=menu_directory[7]%&gt;</a>
          <a class="dropdown-item" href="#create">&lt;=menu_directory[8]%&gt;</a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
		 <div class="btn-group">

  <button type="button" class="btn btn-outline-secondary dropdown-toggle dropdown-toggle-split" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
  <button type="button" class="btn btn-outline-secondary">&lt;=menu_main[2]%&gt;</button>
    <span class="sr-only">Toggle Dropdown</span>
  </button>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#rename">&lt;=menu_repository[0]%&gt;</a>
          <a class="dropdown-item" href="#ci">&lt;=menu_repository[1]%&gt;</a>
          <a class="dropdown-item" href="#co">&lt;=menu_repository[2]%&gt;</a>
          <a class="dropdown-item" href="#lock">&lt;=menu_repository[3]%&gt;</a>
          <a class="dropdown-item" href="#unlock">&lt;=menu_repository[4]%&gt;</a>
          <a class="dropdown-item" href="#create">&lt;=menu_repository[5]%&gt;</a>
          <a class="dropdown-item" href="#commit">&lt;=menu_repository[6]%&gt;</a>
          <a class="dropdown-item" href="#rollbck">&lt;=menu_repository[7]%&gt;</a>
        </div>
        </div>
      </li>
</div>
<div>
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_document" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">&lt;=menu_main[1]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls">&lt;=menu_document[0]%&gt;</a>
          <a class="dropdown-item" href="#view">&lt;=menu_document[1]%&gt;</a>
          <a class="dropdown-item" href="#mv">&lt;=menu_document[2]%&gt;</a>
          <a class="dropdown-item" href="#rename">&lt;=menu_document[3]%&gt;</a>
          <a class="dropdown-item" href="#rm">&lt;=menu_document[4]%&gt;</a>
          <a class="dropdown-item" href="#unrm">&lt;=menu_document[5]%&gt;</a>
          <a class="dropdown-item" href="#restore">&lt;=menu_document[6]%&gt;</a>
          <a class="dropdown-item" href="#cp">&lt;=menu_document[7]%&gt;</a>
          <a class="dropdown-item" href="#edit">&lt;=menu_document[8]%&gt;</a>
          <a class="dropdown-item" href="#lock">&lt;=menu_document[9]%&gt;</a>
          <a class="dropdown-item" href="#unlock">&lt;=menu_document[10]%&gt;</a>
          <a class="dropdown-item" href="#create">&lt;=menu_document[11]%&gt;</a>
          <a class="dropdown-item" href="#open">&lt;=menu_document[12]%&gt;</a>
          <a class="dropdown-item" href="#write">&lt;=menu_document[13]%&gt;</a>
          <a class="dropdown-item" href="#wread">&lt;=menu_document[14]%&gt;</a>
          <a class="dropdown-item" href="#read">&lt;=menu_document[15]%&gt;</a>
          <a class="dropdown-item" href="#insert">&lt;=menu_document[16]%&gt;</a>
          <a class="dropdown-item" href="#update">&lt;=menu_document[17]%&gt;</a>
          <a class="dropdown-item" href="#delete">&lt;=menu_document[18]%&gt;</a>
          <a class="dropdown-item" href="#select">&lt;=menu_document[19]%&gt;</a>
        </div>
    </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_meta-data" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">&lt;=menu_main[4]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="nav-link dropdown-toggle" href="#" id="mn_meta_doc" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Document</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls">&lt;=menu_meta[0]%&gt;</a>
          <a class="dropdown-item" href="#lock">&lt;=menu_meta[1]%&gt;</a>
          <a class="dropdown-item" href="#unlock">&lt;=menu_meta[2]%&gt;</a>
          <a class="dropdown-item" href="#create">&lt;=menu_meta[3]%&gt;</a>
          <a class="dropdown-item" href="#chown">&lt;=menu_meta[4]%&gt;</a>
          <a class="dropdown-item" href="#chmod">&lt;=menu_meta[5]%&gt;</a>
          <a class="dropdown-item" href="#set">&lt;=menu_meta[6]%&gt;</a>
        </div>


          <a class="nav-link dropdown-toggle" href="#" id="mn_meta_dir" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Directory</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls">&lt;=menu_meta[0]%&gt;</a>
          <a class="dropdown-item" href="#lock">&lt;=menu_meta[1]%&gt;</a>
          <a class="dropdown-item" href="#unlock">&lt;=menu_meta[2]%&gt;</a>
          <a class="dropdown-item" href="#create">&lt;=menu_meta[3]%&gt;</a>
          <a class="dropdown-item" href="#chown">&lt;=menu_meta[4]%&gt;</a>
          <a class="dropdown-item" href="#chmod">&lt;=menu_meta[5]%&gt;</a>
          <a class="dropdown-item" href="#set">&lt;=menu_meta[6]%&gt;</a>
        </div>
        </div>
      </li>
</div>

<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_script" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          &lt;=menu_main[5]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#exec">&lt;=menu_script[0]%&gt;</a>
          <a class="dropdown-item" href="#lexec">&lt;=menu_script[1]%&gt;</a>
          <a class="dropdown-item" href="#rename">&lt;=menu_script[2]%&gt;</a>
          <a class="dropdown-item" href="#lock">&lt;=menu_script[3]%&gt;</a>
          <a class="dropdown-item" href="#unlock">&lt;=menu_script[4]%&gt;</a>
          <a class="dropdown-item" href="#create">&lt;=menu_script[5]%&gt;</a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_network" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          &lt;=menu_main[6]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#get">&lt;=menu_network[0]%&gt;</a>
          <a class="dropdown-item" href="#post">&lt;=menu_network[1]%&gt;</a>
          <a class="dropdown-item" href="#sln">&lt;=menu_network[2]%&gt;</a>
          <a class="dropdown-item" href="#fetch">&lt;=menu_network[3]%&gt;</a>
		      <a class="dropdown-item" href="#upload">&lt;=menu_network[4]%&gt;</a>
          <a class="dropdown-item" href="#downld">&lt;=menu_network[5]%&gt;</a>
        </div>
      </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_help" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          &lt;=menu_main[7]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#help">&lt;=menu_help[0]%&gt;</a>
          <a class="dropdown-item" href="#about">&lt;=menu_help[1]%&gt;</a>
          <a class="dropdown-item" href="?lang=ru">&lt;=menu_lang[MNU_LANG_RU]%&gt;</a>
          <a class="dropdown-item" href="?lang=en">&lt;=menu_lang[MNU_LANG_EN]%&gt;</a>
          <a class="dropdown-item" href="?lang=zh">&lt;=menu_lang[MNU_LANG_ZH]%&gt;</a>
        </div>
      </li>
</div>
</ul> </div> </nav>
</header>



<!-- FOOTER -->

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
