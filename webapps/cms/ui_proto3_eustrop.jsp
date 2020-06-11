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
"-",	"doc",	Y,MT_DROPDOWN,	null,	"Document","Документы","文件",null,
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
public void beginMenu(){MENU_LEVEL++;if(MENU_LEVEL==1){print_beginMenu();}else{print_beginMenu2();}} // do nothing or something
public void closeMenu(){MENU_LEVEL--;if(MENU_LEVEL==0){print_closeMenu();}else{print_closeMenu2();}}
public int currentMenuLevel(){return(MENU_LEVEL);}
public void printMenuItem(String id,String type,String action, String caption){print_MenuItem(id,type,action,caption);}

//
// private methods - implementation of public ones
//
public void print_MenuPage()
{
 //
 int item_size=CAPTION_CUSTOM+1;
 int menu_count=MENU.length/(item_size);
 int i = 0;
 int current_level=0;
 int level=0;
 //w("<pre>");
 for(i=0;i<menu_count;i++)
 {
  int item=i*item_size;
  if(MENU[item]==null)continue;
  level=MENU[item].length();
  String id=MENU[item + MENU_II_ID];
  String enabled=MENU[item + MENU_II_ENABLED];
  String type=MENU[item + MENU_II_TYPE];
  String action=MENU[item + MENU_II_ACTION];
  String caption=MENU[item + MENU_II_CAPTION];
  if(level == 1 && current_level == 1){closeMenu();current_level--;}
  if(level > current_level) for(;level>current_level;current_level++){beginMenu();}
  if(level < current_level) for(;level<=current_level;current_level--){closeMenu();}
  printMenuItem(id,type,action,caption);
  //w("<a href='#'>" + level + " ");
  //w(MENU[item]); w("\t"); w(caption); w("\t"); w(MENU[item + CAPTION_ZH]); 
  //wln("</a>");
 }
  for(;0<current_level;current_level--){closeMenu();}
 //w("</pre>");
}
//set of WASkin methods for creating menu
public void print_beginMenuNavBar(){
      w("<nav class=\"navbar navbar-expand-lg navbar-light bg-light\">\n");
      //w(" <a class=\"navbar-brand\" href=\"#\">\n");
      //w("    <img src=\"img/beacon.png\" width=\"30\" height=\"30\" class=\"d-inline-block align-center\" alt=\"beacon.png\">&lt;=menu_main[0]%&gt;\n");
      //w("&lt;=menu_main[0]%&gt;</a>\n");
      //w("    <img src=\"img/beacon.png\" width=\"30\" height=\"30\" class=\"d-inline-block align-center\" alt=\"beacon.png\">\n");
      w("  <button class=\"navbar-toggler\" type=\"button\" data-toggle=\"collapse\" data-target=\"#navbarSupportedContent\" aria-controls=\"navbarSupportedContent\" aria-expanded=\"false\" aria-label=\"Toggle navigation\">\n");
      w("    <span class=\"navbar-toggler-icon\"></span>\n");
      w("  </button>\n");
      w("<div class=\"collapse navbar-collapse\" id=\"navbarSupportedContent\">\n");
      w("<ul class=\"navbar-nav mr-auto\" style='justify-content: space-around; width: 70%;'>\n");
}
public void print_closeMenuNavBar(){
      //w("</div>\n");
      w("</ul> </div> </nav>\n");
}
public void print_beginMenu(){
      w("<div>\n");
      w("      <li class=\"nav-item dropdown\">\n");
}
public void print_closeMenu(){
      w("      </li>\n");
      w("</div>\n");
}
public void print_beginMenu2(){
      w("        <div class=\"dropdown-menu\" aria-labelledby=\"navbarDropdown\">\n");
}
public void print_closeMenu2(){
      w("        </div>\n");
}
public void print_MenuItem(String id,String type,String action, String caption){
if(action==null)action="#";
      w("        <a id='" + id + "' ");
      if(MT_DROPDOWN.equals(type)) {
      w(" class=\"nav-link dropdown-toggle\" href=\"#\" role=\"button\" data-toggle=\"dropdown\" aria-haspopup=\"true\" aria-expanded=\"false\"");
      }
      else {
      w(" class=\"dropdown-item\" href=\"");
      w(action);
      w("\"");
      }
      w(" >");
      w(caption);
      w("</a>\n");
} //print_MenuItem
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

<%
setMenuOut(out);
beginMenuNavBar();
printMenuPage();
closeMenuNavBar();
%>
<!-- а вот это все мы удалим (85 строк) : 85dd
<div>
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_document" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">&lt;=menu_main[1]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls">&lt;=menu_document[0]%&gt;</a>
          <a class="dropdown-item" href="#view">&lt;=menu_document[1]%&gt;</a>
          <a class="dropdown-item" href="#mv">&lt;=menu_document[2]%&gt;</a>
          <a class="dropdown-item" href="#rename">&lt;=menu_document[3]%&gt;</a>
          <a class="dropdown-item" href="#rm">&lt;=menu_document[4]%&gt;</a>
        </div>
    </li>
</div>
<div>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" id="mn_meta-data" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">&lt;=menu_main[4]%&gt;</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="#ls">&lt;=menu_document[0]%&gt;</a>
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
          <a class="dropdown-item" href="#ls">&lt;=menu_document[0]%&gt;</a>
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
-->
</header>
<div id='main'>
<H1> Здесь будет результат выполнения текущей команды </H1>
</div>



<!-- FOOTER (<pre> tag inserted to avoid tail of page loss) -->
<pre>



</pre>

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
