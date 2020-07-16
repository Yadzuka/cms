<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.io.*"
         import="org.eustrosoft.cms.Main"
         import="org.eustrosoft.providers.LogProvider"
%>
<%!
    private static final String CGI_MAIN = "index2.jsp";

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
//"-",	"main",	Y,MT_HREF,	"./",	"Main","Главная","主要",null,
//main
            "-",	"doc",	Y,MT_DROPDOWN,	null,	"Document","Документы","文件",null,
            "--", "ls", Y, MT_CMD, null,"Content","Содержимое","XX",null,
            "--", "view", Y, MT_CMD, null,"View","Просмотр","看",null,
            "--", "mv", Y, MT_CMD, null,"Move","Переместить","迁移",null,
            "--", "rename",Y,MT_CMD,  null, "Rename","Переименовать","改名",null,
            "--", "rm", Y, MT_CMD, null,"Delete document","Удалить документ","删除",null,
            "--", "unrm", Y, MT_CMD, null,"Restore","Восстановить","XX",null,
            "--", "restore", Y, MT_CMD, null,"Restore version","Восстановить версию","XX",null,
            "--", "cp", Y,MT_CMD, null, "Copy..","Копировать..","复制",null,
            "--", "create", Y, MT_CMD, null,"Create","Создать","XX",null,
            "--", "open", Y, MT_CMD, null,"Open","Открыть","XX",null,
            "--", "locks",Y,MT_DROPDOWN,  null, "Locks","Блокировки","锁",null,
            "---", "lock", Y,MT_CMD, null,   "Lock","Заблокировать","锁",null,
            "---",  "unlock",Y,MT_CMD,  null,   "Unlock","Разблокиовать","开锁",null,
            "--", "edit", Y,MT_DROPDOWN,  null,   "Edit","Редактировать","编辑",null,
            "---", "write", Y, MT_CMD, null,"Write","Записать","XX",null,
            "---", "wread", Y, MT_CMD, null,"Read recorded","Прочитать записанное","XX",null,
            "---", "read", Y, MT_CMD, null,"Read","Прочитать","XX",null,
            "---", "insert", Y, MT_CMD, null,"Insert record","Вставить запись","XX",null,
            "---", "update", Y, MT_CMD, null,"Update record","Обновить запись","XX",null,
            "---", "delete", Y, MT_CMD, null,"Delete record","Удалить запись","XX",null,
            "---", "select", Y, MT_CMD, null,"Select records","Выбрать записи","XX",null,
            "-",	"repo",	Y,MT_DROPDOWN,	null,	"Repository","Репозитории","仓库",null,
            "--", "rename", Y, MT_CMD, null, "Rename","Переименовать","XX",null,
            "--", "ci", Y, MT_CMD, null, "To save a version","Сохранить версию","XX",null,
            "--", "co", Y, MT_CMD, null, "Restored version","Восстановить версию","XX",null,
            "--", "sep1", Y,MT_SEPARATOR, null, "-","-","-",null,
            "--", "block", Y, MT_CMD, null, "Block","Заблокировать","XX",null,
            "--", "unblock", Y, MT_CMD, null, "Unblock","Разблокиовать","XX",null,
            "--", "create", Y, MT_CMD, null, "Create","Создать","XX",null,
            "--", "commit", Y, MT_CMD, null, "Apply the changes","Применить изменения","XX",null,
            "--", "rollbck", Y, MT_CMD, null, "Undo the changes","Отменить изменения","XX",null,
            "-",	"dir", Y, MT_DROPDOWN,	null,	"Directory","Директории","目录",null,
            "--", "ls", Y, MT_CMD,null, "Content","Содержимое","XX",null,
            "--", "view", Y, MT_CMD,null, "View","Просмотр","XX",null,
            "--", "move", Y, MT_CMD,null, "Move","Переместить","XX",null,
            "--", "rename", Y, MT_CMD,null, "Rename","Переименовать","XX",null,
            "--", "create", Y, MT_CMD,null, "Create","Создать","XX",null,
            "--", "delete", Y, MT_CMD,null, "Delete","Удалить","XX",null,
            "--", "block", Y, MT_CMD,null, "Block","Заблокировать","XX",null,
            "--", "unblock", Y, MT_CMD,null, "Unblock","Разблокиовать","XX",null,
            "--", "create", Y, MT_CMD,null, "#Create#","#Cоздать#","XX",null,
            "-",	"meta",	Y,MT_DROPDOWN,	null,	"Meta-data","Мета-данные","元数据",null,
            "--",	"ls",	Y,MT_CMD,	null,	"Content","Содержимое","XX",null,
            "--",	"block",	Y,MT_CMD,	null,	"Block","Заблокировать","XX",null,
            "--",	"unblock",	Y,MT_CMD,	null,	"Unblock","Разблокиовать","XX",null,
            "--", "create", Y,MT_CMD, null, "Create","Создать","XX",null,
            "--", "chown", Y,MT_CMD, null, "Change the [group] of the directory owner","Изменить [группу] владельца директории","XX",null,
            "--", "chmod", Y,MT_CMD, null, "Change permissions","Изменить права","XX",null,
            "--", "set", Y,MT_CMD, null, "Set document meta parameters","Установить мета-параметры документа","XX",null,
            "-",  "scrpt",Y,MT_DROPDOWN,  null, "Script","Скрипты","脚本",null,
            "--", "exec", Y,MT_CMD, null, "Execute","Исполнить","XX",null,
            "--", "lexec", Y,MT_CMD, null, "To execute locally","Исполнить локально","XX",null,
            "--", "rename", Y,MT_CMD, null, "Rename","Переименовать","XX",null,
            "--", "lock", Y,MT_CMD, null, "Block","Заблокировать","XX",null,
            "--", "unlock", Y,MT_CMD, null, "Unblock","Разблокиовать","XX",null,
            "--", "create", Y,MT_CMD, null, "Create","Создать","XX",null,
            "--", "dogen", Y,MT_CMD, null, "Contract Generation","Генерация договора","XX",null,
            "-",  "net",  Y,MT_DROPDOWN,  null, "Net","Сеть","网",null,
            "--", "get", Y, MT_CMD, null,"HTTP/GET","HTTP/GET","XX", null,
            "--", "post", Y, MT_CMD, null,"HTTP/POST","HTTP/POST","XX", null,
            "--", "sln", Y, MT_CMD, null,"Create a symbolic link","Создать символическую ссылку","XX", null,
            "--", "fetch", Y, MT_CMD, null,"Upload using the url","Загрузить файл из сети по url","XX", null,
            "--", "upload", Y, MT_CMD, null,"Upload","Обновить","XX", null,
            "--", "downld", Y, MT_CMD, null,"Download","Загрузить","XX", null,
            "-",  "help", Y,MT_DROPDOWN,  null, "Help","Справка","咨询室",null,
            "--", "help", Y, MT_CMD, null,"Help","Помощь","XX", null,
            "--", "about", Y, MT_CMD, null,"About","О программе","XX", null,
            "-",	"lang",	Y,MT_DROPDOWN,	null,	"Lang","Язык","语言",null,
            "--",	"ru",	Y,MT_LANG,"?lang=ru",	"Русский","Русский","Русский",null,
            "--", "en", Y,MT_LANG,"?lang=en", "English","English","English",null,
            "--",	"zh",	Y,MT_LANG,"?lang=zh",	"中文","中文","中文",null,
            "--",	"customlang",Y,MT_LANG,"?lang=customlan",	"Custom language","Пользовательский язык","自订语言",null,
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

// print whole menu for curent page
    public void printMenuPage() {print_MenuPage(); }
    //set of WASkin methods for creating menu
    public void beginMenuNavBar(){print_beginMenuNavBar();}
    public void closeMenuNavBar(){print_closeMenuNavBar();}
    public void beginMenu(String id){
        MENU_LEVEL++;
        if(MENU_LEVEL==1){print_beginMenu(id);
        }else{print_beginMenu2(id);}
    } // do nothing or something
    public void closeMenu(){
        MENU_LEVEL--;
        if(MENU_LEVEL==0){print_closeMenu();
        }else{print_closeMenu2();}
    }
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

            if (i==1){
                beginMenu(id);item_level++;printMenuItem(id,type,action,caption);continue;
            } if (MENU_LEVEL==1 && (level-MENU_LEVEL)==0){
                closeMenu();beginMenu(id);printMenuItem(id,type,action,caption);continue;
            } if (MENU_LEVEL>=1 && (level-MENU_LEVEL)>0){
                beginMenu(id);item_level++;printMenuItem(id,type,action,caption);continue;
            } if (MENU_LEVEL>=2 && (level-MENU_LEVEL)==0){
                printMenuItem(id,type,action,caption);continue;
            } if ((MENU_LEVEL-level)==1 && MENU_LEVEL==3){
                closeMenu();item_level--;printMenuItem(id,type,action,caption);continue;
            } if ((MENU_LEVEL-level)==2 && MENU_LEVEL==3){
                for(;level<=item_level;item_level--){
                    closeMenu();
                }
                beginMenu(id);
                item_level++;
                printMenuItem(id,type,action,caption);
                continue;
            } if ((MENU_LEVEL-level)==1 && MENU_LEVEL==2) {
                for(;level<=item_level;item_level--){
                    closeMenu();
                }
                beginMenu(id);
                item_level++;
                printMenuItem(id,type,action,caption);
                continue;
            }
        }
    }
    //set of WASkin methods for creating menu
    public void print_MenuItem(String id,String type,String action, String caption){
        if(action==null)action=CGI_MAIN + "?action=" + id;
        if(action==null)action="#";
        if(MT_DROPDOWN.equals(type) && MENU_LEVEL==1) {
        }else{
            if(MT_DROPDOWN.equals(type) && MENU_LEVEL>=2) {
                w("<li class='dropdown-item dropdown'>\n");
            }else{
                w("<li class='dropdown-item'>\n");
            }
        }
        w("      <a id='" + id + "' ");
        if(MT_DROPDOWN.equals(type)) {
            w("class='nav-link dropdown-toggle' href='#' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'");
        }else{
            w(" href='");
            w(action);
            w("'");
        }
        w(">");
        w(caption);
        w("</a>\n</li>\n");
    }

    public void print_beginMenu(String id){
        w("<li class='nav-item dropdown'>\n");
    }
    public void print_closeMenu(){
        w("\n");
    }
    public void print_beginMenu2(String id){
        w("<ul class='dropdown-menu' aria-labelledby='"+id+"'>\n");
    }
    public void print_closeMenu2(){
        w("</ul>\n");
    }
    public void print_beginMenuNavBar(){
        w("<nav class='navbar navbar-expand-lg navbar-light' style='background-color: #e3f2fd;'>\n");

        w("<button class='navbar-toggler' type='button' data-toggle='collapse' data-target='#navbarCollapse' aria-controls='navbarCollapse' aria-expanded='false' aria-label='Toggle navigation'>\n");
        w("<span class='navbar-toggler-icon'></span>\n");
        w("</button>\n");
        w("<div class='collapse navbar-collapse' id='navbarCollapse'>\n");
        w("<ul class='navbar-nav mr-auto' style='justify-content: space-around; width: 70%;'>\n");
    }
    public void print_closeMenuNavBar(){
        w("</ul>\n</div>\n</nav>\n");
    }
// basic WASkin methods
//
    private JspWriter out;

    private void w(String s) {
        boolean is_error = false;
        try { out.print(s); }
        catch (Exception e) { is_error = true; }
    }
    private void wln(String s){ w(s);w("\n");}
    void setMenuOut(JspWriter m_out) {out = m_out;}

%>

<!DOCTYPE html>
<html lang="ru">
<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS-->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
    <title>Menu JSP </title>
    <style>
        .navbar .dropdown-toggle, .navbar .dropdown-menu a {
            cursor: pointer;
        }

        .navbar .dropdown-item.active, .navbar .dropdown-item:active {
            color: inherit;
            text-decoration: none;
            background-color: inherit;
        }

        .navbar .dropdown-item:focus, .navbar .dropdown-item:hover {
            color: #16181b;
            text-decoration: none;
            background-color: #f8f9fa;
        }

        @media (min-width: 767px) {
            .navbar .dropdown-toggle:not(.nav-link)::after {
                display: inline-block;
                width: 0;
                height: 0;
                margin-left: .5em;
                vertical-align: 0;
                border-bottom: .3em solid transparent;
                border-top: .3em solid transparent;
                border-left: .3em solid;
            }
        }
    </style>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    setMenuOut(out);
    String lang = LANG_RU;
    try {lang = request.getParameter("lang");
        switch(lang){
            case LANG_RU:
                MENU_II_CAPTION = CAPTION_RU;
                break;
            case LANG_EN:
                MENU_II_CAPTION = CAPTION_EN;
                break;
            case LANG_ZH:
                MENU_II_CAPTION = CAPTION_ZH;
                break;
            case LANG_CUSTOM:
                MENU_II_CAPTION = CAPTION_RU;
                break;
            default:
                MENU_II_CAPTION = CAPTION_RU;
        }
    }catch (Exception e){
        MENU_II_CAPTION = CAPTION_RU;
    }
    beginMenuNavBar();
    printMenuPage();
    w("</ul>\n");
    closeMenuNavBar();

%>
<div class="container" id="main_block">
<%
    RequestDispatcher dispatcher =null;
    if("dogen".equals(request.getParameter("action"))){
        dispatcher = request.getRequestDispatcher("forma.jsp");
    } else {
        Main main = new Main();
        Main.WARHCMS cms = main.getWARHCMSInstance();
        main.CGI_NAME = "index2.jsp";
        main.out = out;
        main.initUser(request);
        request.setCharacterEncoding("UTF-8");
        main.log = new LogProvider(this.getServletContext().getInitParameter("logFilePath"));
        cms.process(request, response);
    }

    /*else {
            dispatcher = request.getRequestDispatcher("index1.jsp");
    }
    out.flush();
    request.setAttribute("FORWARD_REQUEST", Boolean.TRUE);
    dispatcher.include(request, response);*/

%>
</div>
<script type="text/javascript">
    let items=document.getElementsByTagName('a');
    for (let i=0;i<items.length;i++) items[i].addEventListener('click',drop);
    function drop(event) {

        let shown=document.querySelectorAll('.show')
        let parent = event.target.parentElement;
        let child = event.target.parentElement.nextElementSibling;
        if (shown.length>1 && parent.className=='nav-item dropdown') for(let show of shown) show.classList.remove('show');
        parent.classList.toggle('show');
        child.classList.toggle('show');
        if (parent.className.indexOf('nav-item dropdown')!=-1){
            child.style.left = parent.offsetLeft+'px';
        }else{
            console.log(parent.className);
            menu_left= event.target.offsetParent.offsetLeft + event.target.offsetParent.offsetWidth + 'px';
            menu_top= event.target.offsetParent.offsetTop + event.target.offsetParent.offsetHeight - 10 + 'px';
            child.style.left=menu_left;
            child.style.top=menu_top;
        }
    };
</script>
</body>
</html>