<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.io.*"
%>
<%!
static final String MT_DROPDOWN = "D";
static final String MT_SEPARATOR = "-";
static final String MT_HREF = "H";
static final String MT_CMD = "C";
static final String MT_CMD_D = "CD";
static final String MT_CMD_JS = "JS";
static final String MT_LANG = "JS";

static final String Y = "Y";
static final String N = "N";
static String[] MENU = new String[]{
//lvl,	id,	enabled,type,	action,	caption[en],ru,zh,custom
null,null,null,null,null,null,null,null,null, // this item ignored
"-",	"main",	Y,MT_HREF,	"./",	"Main","Главная","主要",null,
"-",	"doc",	Y,MT_DROPDOWN,	null,	"Document","Документы","文件",null,
"--",	"view",	Y,MT_CMD,	null,   "View","Просмотр","看",null,
"--",	"mv",	Y,MT_CMD,	null,   "Move",	"Переместить","迁移" ,null,
"--",	"rename",Y,MT_CMD,	null,   "Rename","Переименовать","改名",null,
"--",	"cp",	Y,MT_CMD,	null,   "Copy..","Копировать","复制",null,
"--",	"edit",	Y,MT_DROPDOWN,	null,   "Edit","Редактировать","编辑",null,
"---",	"text",	Y,MT_CMD,	null,   "as text","как текст","文本",null,
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
"-",	"dir",	Y,MT_DROPDOWN,	null,	"Dir","Директории","Dir",null,
"-",	"meta",	Y,MT_DROPDOWN,	null,	"Meta-data","Мета-данные","元数据",null,
"--",	"mnu1",	Y,MT_CMD,	null,	"Menu 1","Меню 1","選單 一",null,
"--",	"mnu3",	Y,MT_CMD,	null,	"Menu 3","Меню 3","選單 三",null,
"--",	"sep1",	Y,MT_SEPARATOR,	null,	"-","-","-",null,
"--",	"mnu3",	Y,MT_CMD,	null,	"Menu 4","Меню 4","選單 二乘二",null,
"-",	"scrpt",Y,MT_DROPDOWN,	null,	"Script","Скрипты","脚本",null,
"--",	"mnu1",	Y,MT_CMD,	null,	"Menu 1","Меню 1","選單 一",null,
"--",	"mnu2",	Y,MT_CMD,	null,	"Menu 2","Меню 2","選單 二",null,
"--",	"mnu3",	Y,MT_CMD,	null,	"Menu 3","Меню 3","選單 三",null,
"--",	"mnu3",	Y,MT_CMD,	null,	"Menu 4","Меню 4","選單 二乘二",null,
"-",	"net",	Y,MT_DROPDOWN,	null,	"Net","Сеть","网",null,
"-",	"help",	Y,MT_DROPDOWN,	null,	"Help","Справка","咨询室",null,
"-",	"lang",	Y,MT_DROPDOWN,	null,	"Lang","Язык","语言",null,
"--",	"ru",	Y,MT_LANG,	null,	"Русский","Русский","Русский",null,
"--", "en", Y,MT_LANG,  null, "English","English","English",null,
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
private int MENU_LEVEL=0; //current level of menu

/*
String[] MENU_PATH = new String[MAX_MENU_PATH]; // current path to menu
private String get_menu_id(String id){MENU_PATH[MENU_LEVEL]=id; id=MENU_ID_PREFIX; for(int i=0;i<MENU_LEVEL;i++){id=id + MENU_ID_SEP + MENU_PATH[i];} return(id);
}
*/
// print whole menu for curent page
public void printMenuPage() {print_MenuPage(); }

//set of WASkin methods for creating menu
public void beginMenuNavBar(){print_beginMenuNavBar();}
public void closeMenuNavBar(){print_closeMenuNavBar();}
public void beginMenu(){
MENU_LEVEL++;
if(MENU_LEVEL==1){
print_beginMenu();
}
else
{
print_beginMenu2();
}
} // do nothing or something
public void closeMenu(){
MENU_LEVEL--;
if(MENU_LEVEL==0){
print_closeMenu();
}else{
print_closeMenu2();
}
}

//public int currentMenuLevel(){return(MENU_LEVEL);}

public void printMenuItem(String id,String type,String action, String caption){print_MenuItem(id,type,action,caption);}
// private methods - implementation of public ones
public void print_MenuPage()
{
 int item_size=CAPTION_CUSTOM+1;
 int menu_count=MENU.length/(item_size);
 int i = 0;
 int item_level=0;
 int level=1;
 MENU_LEVEL=0;
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
//w("<br>"+"i="+i+" id="+id+"  type=" + type +"  level="+level+" item_level="+item_level+"  MENU_LEVEL=" + MENU_LEVEL);

if (i==1){beginMenu();item_level++;printMenuItem(id,type,action,caption);continue;}
if (MENU_LEVEL==1 && (level-MENU_LEVEL)==0){closeMenu();beginMenu();printMenuItem(id,type,action,caption);continue;}
if (MENU_LEVEL>=1 && (level-MENU_LEVEL)>0){beginMenu();item_level++;printMenuItem(id,type,action,caption);continue;}

if (MENU_LEVEL>=2 && (level-MENU_LEVEL)==0){printMenuItem(id,type,action,caption);continue;}

if ((MENU_LEVEL-level)==1 && MENU_LEVEL==3){closeMenu();item_level--;printMenuItem(id,type,action,caption);continue;}
if ((MENU_LEVEL-level)==2 && MENU_LEVEL==3){for(;level<=item_level;item_level--){closeMenu();}
beginMenu();
item_level++;
printMenuItem(id,type,action,caption);
continue;}
if ((MENU_LEVEL-level)==1 && MENU_LEVEL==2){for(;level<=item_level;item_level--){closeMenu();}
beginMenu();
item_level++;
printMenuItem(id,type,action,caption);
continue;}
}
}
//for(;0<current_level;current_level--){closeMenu();}
//w("</pre>");

//set of WASkin methods for creating menu
public void print_MenuItem(String id,String type,String action, String caption){
if(action==null)action="#";
w("        <a id='" + id + "' ");
if(MT_DROPDOWN.equals(type)) {
w("class='nav-link dropdown-toggle' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'");
}else{
	w("class='dropdown-item' href='");
	w(action);
    w("'");
}
	w(">");
    w(caption);
    w("</a>\n");
}

public void print_beginMenu(){
      w("<li class='nav-item dropdown'>\n");
}
public void print_closeMenu(){
     w("</li>\n");
}
public void print_beginMenu2(){
      w("<div class='dropdown-menu' aria-labelledby='navbarDropdown'>\n");
}
public void print_closeMenu2(){
      w("</div>\n");
}
public void print_beginMenuNavBar(){
w("<nav class='navbar navbar-expand-lg navbar-light' style='background-color: #e3f2fd;'>\n");
//w("<a class='navbar-brand' href='#'>Navbar</a>");
w("<button class='navbar-toggler' type='button' data-toggle='show' data-target='#navbarSupportedContent' aria-controls='navbarSupportedContent' aria-expanded='false' aria-label='Toggle navigation'>\n");
w("<span class='navbar-toggler-icon'></span>\n");
w("</button>\n");
w("<div class='collapse navbar-collapse' id='navbarSupportedContent'>\n");
w("<ul class='navbar-nav mr-auto'>\n");
w("<!-- print_beginMenuNavBar -->");
}
public void print_closeMenuNavBar(){
     print_closeMenu2();
     print_closeMenu();
     w("</ul>\n</div>\n</nav>\n");
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
  //  private void wln(String s){ w(s);w("\n");}
  //  private void wln(){w("\n");}
void setMenuOut(JspWriter m_out) {out = m_out;}

%>

<!DOCTYPE html>
<html lang="ru">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
    <title>Menu JSP </title>
  </head>
  <body>
<%
//this.out = out;
setMenuOut(out);
beginMenuNavBar();
printMenuPage();
closeMenuNavBar();
%>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
  </body>
</html>
