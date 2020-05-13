<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.io.*"
         import="java.text.SimpleDateFormat"
         import="java.nio.file.Paths"
         import="java.nio.file.Path"
         import="java.nio.file.Files"
         import="org.eustrosoft.providers.LogProvider"
         import="name.fraser.neil.plaintext.diff_match_patch"
         import="java.util.List"
         import="java.nio.charset.StandardCharsets"
         import="java.io.UnsupportedEncodingException"
         import="java.net.URLEncoder" %>
<%!
    // Page info
    private final static String CGI_NAME = "index1.jsp"; // Page domain name
    private final static String CGI_TITLE = "CMS system"; // Upper page info
    private final static String JSP_VERSION = "$id$"; // Id for jsp version
    private static LogProvider log;
    private JspWriter out;

    public static String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
    public static String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","<br>\n"};
    public final static String[] VALUE_CHARACTERS = { "<",">","&","\"","'" };
    public final static String[] VALUE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","&quot;","&#039;"};

    // Files and directories manipulating
    private final static String PARAM_PATH = "path";
    private final static String PARAM_FILE = "file";
    private final static String PARAM_ACTION = "status";
    private final static String FILE_TEXTAREA_NAME = "file_text";

    // File manipulating (view, save, update, delete)
    private final static String ACTION_VIEW = "view";
    private final static String ACTION_SAVE = "save";
    private final static String ACTION_UPDATE = "update";
    private final static String ACTION_DELETE = "delete";
    private final static String ACTION_CREATE = "create";

    private final static String [] IMAGE_DEFINITIONS = { "jpg", "jpeg", "png", "svg", "tiff", "bmp", "bat", "odg", "xps" };
    private final static String [] VIDEO_DEFINITIONS = { "ogg", "mp4", "webm" };
    // File differences class
    private final diff_match_patch diffMatchPatch = new diff_match_patch();

    // User info
    private String userIP;
    private String HOME_DIRECTORY = "/s/usersdb/";
    private String currentDirectory = HOME_DIRECTORY;

    private final static String unixSlash = "/";

    private void initUser(HttpServletRequest request) {
        userIP = request.getRemoteAddr();
        HOME_DIRECTORY = "/s/usersdb/" + getServletConfig().getServletContext().getInitParameter("user") + "/";
        currentDirectory = HOME_DIRECTORY;
        try {
            if (!Files.exists(Paths.get(HOME_DIRECTORY))) {
                File newDir = new File(HOME_DIRECTORY);
                newDir.mkdir();
            }
        } catch (Exception ex) {
            try {
                w("Can't create directory!");
            } catch (Exception e) { log.e("Error in initUser(request) by user " + userIP); }
        }
    }

    private String encodeValue(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString());
        } catch (UnsupportedEncodingException ex) {
            throw new RuntimeException(ex.getCause());
        }
    }

    private boolean createDir(String path, String dirName) {
        Path pathToDir = getPath(path, dirName);
        File directory = new File(pathToDir.toUri());
        if(directory.exists())
            return true;
        else
            return directory.mkdir();
    }

    private boolean createFile(String fileName) throws Exception {
        File file = new File(fileName);
        return file.createNewFile();
    }

    private boolean deleteFile(String fileName) {
        File file = new File(fileName);
        return file.delete();
    }

    private Path getPath(String pathToFile, String fileName) {
        pathToFile = pathToFile.trim(); fileName = fileName.trim();
        Path filePath = null;

        try {
            if (!(pathToFile.endsWith(unixSlash))) {
                pathToFile += unixSlash;
            }
            try {
                filePath = Paths.get(pathToFile + fileName);
            } catch (Exception ex) {
                throw new FileNotFoundException("File not found!");
            }
        } catch (Exception ex) {
            try {
                w("Error with getting path");
            } catch (Exception e) { }
        }
        return filePath;
    }

    private boolean isExecutable(String path, String fileName) {
        Path pathToFile = getPath(path, fileName);
        return Files.isExecutable(pathToFile);
    }

    private boolean isDir(String path, String fileName) {
        Path pathToFile = getPath(path, fileName);
        return Files.isDirectory(pathToFile);
    }

    private boolean checkShellInjection(String param){ return param.contains(".."); }

    private String getRequestParameter(ServletRequest request, String param) throws IOException {
        return getRequestParameter(request, param, null);
    }

    private String getRequestParameter(ServletRequest request, String param, String default_value) throws IOException {
        String value = request.getParameter(param);
        if(value == null) value = default_value;
        if(value == null) return (null);
        if (PARAM_PATH.equals(param)) {
            if (!(value.endsWith(unixSlash)))
                value += unixSlash;
            if (!value.startsWith(HOME_DIRECTORY))
                value = default_value;

            if (checkShellInjection(value))
                throw new RuntimeException("Shell injection");
        } else if (PARAM_FILE.equals(param)) {
            if (checkShellInjection(value))
                throw new RuntimeException("Shell injection");
        }

        return value;
    }

    private String goToFile(String fileName) {
        if(isDir(currentDirectory, fileName)) {
            String targetPath = encodeValue(currentDirectory) + encodeValue(fileName);
            return getPathReference(targetPath, fileName);
        }
        return openFile(currentDirectory, fileName);
    }
    private String openFile(String href, String value){ return value; }

    private String getPathReference(String path, String value) {
        return "<a href='" + CGI_NAME + "?" + PARAM_PATH +"="+ path + "'>" + value + "</a>";
    }

    private String getPathReference(String path) {
        return CGI_NAME + "?" + PARAM_PATH +"="+ path;
    }
    private String getFileReference(String path, String file) {
        return CGI_NAME + "?" + PARAM_PATH + "=" + path + "&" + PARAM_FILE + "=" + file;
    }
    private String getFileReference(String path, String file, String status) {
        return CGI_NAME + "?" + PARAM_PATH + "=" + path + "&" + PARAM_FILE + "=" + file + "&" + PARAM_ACTION + "=" + status;
    }

    private String goUpside(String folderName) {
        if(folderName.endsWith(unixSlash)) {
            folderName = folderName.substring(0, folderName.length() - 1);
            folderName = folderName.substring(0, folderName.lastIndexOf(unixSlash));
        }
        return folderName;
    }

    private List diffFile(String text1, String text2) {
        diff_match_patch diffMatchPatch = new diff_match_patch();
        List<diff_match_patch.Diff> differences = diffMatchPatch.diff_main(text1, text2);
        return differences;
    }

    private void printFileForm(String directory, String fileName, String status, String fileText)  {
        if(status.equals(ACTION_VIEW)) {
            startForm("POST", getFileReference(encodeValue(directory), encodeValue(fileName), ACTION_VIEW));
            printText(FILE_TEXTAREA_NAME, 72, 10, fileText); nLine();
            printFileEditButtons();
            endForm();
        }
    }

    private void process() {

    }

    private void printServerButton() throws IOException {
        startDiv("col", "", "right");
        startDiv("dropright");
        printButton("btn btn-light btn-lg dropdown-toggle", "button", "dropdownMenuButton", "dropdown", "true", "false", getI("   Сервер", "icon-folder-open") );
        startDiv("dropdown-menu", "", "", "dropdownMenuButton");
        printH("Обращение к серверу", "dropdown-header", 5);
        startDiv("dropdown-divider"); endDiv();

        startForm("POST", "upload", "multipart/form-data");
        printInput("hidden", "", "path", "", currentDirectory);
        printInput("file", "dropdown-item", "file", "", true);
        printSubmit("Загрузить (Apache Commons)", "dropdown-item");
        endForm();

        startForm("POST", "upload_new_version", "multipart/form-data");
        printInput("hidden", "", "path", "", currentDirectory);
        printInput("file", "dropdown-item", "file", "", true);
        printSubmit("Загрузить (Servlet V3)", "dropdown-item");
        endForm();

        startDiv("dropdown-divider"); endDiv();

        startForm("POST", "index1.jsp?path="+encodeValue(currentDirectory)+"&status=create");
        printInput("hidden", "", "action", "", "create");
        printInput("text", "dropdown-item", "file", "Введите имя файла", false);
        printSubmit("Создать файл", "dropdown-item");
        endForm();

        startDiv("dropdown-divider"); endDiv();
        endDiv();
        endDiv();
        endDiv();
    }

    private void processFileRequest(String fileParam, String pathParam, String fileStatus, HttpServletRequest request, HttpServletResponse response) throws IOException {
        if(fileParam != null) {
            StringBuilder sb = new StringBuilder();
            String fileBuffer = "";

            if(fileStatus.equals(ACTION_CREATE)) {
                File newFile = new File(pathParam + fileParam);
                if(!newFile.exists())
                    newFile.createNewFile();
                response.sendRedirect(getPathReference(encodeValue(currentDirectory)));
            }

            if(request.getParameter(ACTION_SAVE) != null) {
                saveFile(fileParam, request);
            }

            try {
                FileReader fileReader = new FileReader(currentDirectory + fileParam);
                BufferedReader bufferedReader = new BufferedReader(fileReader);

                fileBuffer = bufferedReader.readLine();
                while(fileBuffer != null) {
                    sb.append(fileBuffer).append('\n');
                    fileBuffer = bufferedReader.readLine();
                }
                fileReader.close();
                bufferedReader.close();
            } catch (Exception ex) {
                w("cant read file");
            }

            if(request.getParameter(ACTION_DELETE) != null) {
                deleteFile(currentDirectory + fileParam);
            }

            if(fileStatus != null) {
                w("<style> body { display: inline-flex; } #main_block { margin: 0; } #left_block { }</style>");
                w("<div id='left_block' class='block' align='right'>");

                w(getPathReference(encodeValue(pathParam), "Скрыть"));

                boolean showed = false;
                if (fileStatus.equals(ACTION_VIEW)) {
                    if(!(printImageFile(currentDirectory, fileParam)
                            || printVideoFile(currentDirectory, fileParam)))
                        printFileForm(currentDirectory, fileParam, fileStatus, sb.toString());
                }
                w("</div>");
            }
        }
    }

    private boolean printImageFile(String directory, String fileParam)  {
        for(int i = 0; i < IMAGE_DEFINITIONS.length; i++) {
            if (fileParam.toLowerCase().endsWith(IMAGE_DEFINITIONS[i])) { printImage(directory, fileParam, 1280, 720); return true;}
        }
        return false;
    }

    private boolean printVideoFile(String directory, String fileParam)  {
        for(int i = 0; i < VIDEO_DEFINITIONS.length; i++) {
            if (fileParam.toLowerCase().endsWith(VIDEO_DEFINITIONS[i])) { printVideo(1280, 720, directory, fileParam);  return true;}
        }
        return false;
    }

    private void printVideo(int width, int height, String directory, String fileParam)  {
        w("<video width='" + width + "' height='" + height + "' controls='controls'>" +
                "<source src='download?path=" + directory + "&file=" + fileParam + "' type='video/ogg'>" +
                "<source src='download?path=" + directory + "&file=" + fileParam + "' type='video/webm'>" +
                "<source src='download?path=" + directory + "&file=" + fileParam + "' type='video/mp4'> " +
                "Your browser does not support the video tag. </video>");
    }

    private void printImage(String directory, String file, int width, int height)  {
        w("<img src='download?path=" + directory + "&file=" + file + "' alt='sample' height='' width=''>");
    }

    private void saveFile(String fileParam, HttpServletRequest request) throws IOException {
        BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter
                (new FileOutputStream(currentDirectory + fileParam, false), StandardCharsets.UTF_8));
        w("Saved");
        String fileText = request.getParameter(FILE_TEXTAREA_NAME);
        bufferedWriter.write(fileText);
        bufferedWriter.flush();
        bufferedWriter.close();
    }

    private void createFile(String pathParam, String fileParam, HttpServletResponse response) throws IOException {
        File newFile = new File(pathParam + fileParam);
        if(!newFile.exists())
            newFile.createNewFile();
        response.sendRedirect(getPathReference(encodeValue(currentDirectory)));
    }

    private void printFileEditButtons() {
        w("<input type=\"submit\" name=\""+ACTION_SAVE+"\" value=\"Сохранить\"/>&nbsp;");
        w("<input type=\"submit\" name=\""+ACTION_DELETE+"\" value=\"Удалить\"/>&nbsp;");
        w("<input type=\"submit\" name=\""+ACTION_UPDATE+"\" value=\"Обновить\"/>&nbsp;");
    }

    private void w(String s) {
        boolean is_error = false;
        try { out.print(s); }
        catch (Exception e) { is_error = true; }
    }
    private void wln(String s){ w(s);w("\n");}
    private void wln(){w("\n");}
    private void setReference(String reference, String insides) { w("<a href=\""+reference+"\">"); w(insides); w("</a>"); }


    private void printInput(String type, String classN, String name, String placeholder, boolean multiple)  {
        if(multiple) w("<input type='" + type + "' class='" + classN + "' name='" + name + "' placeholder='" + placeholder +"' multiple/>");
        else w("<input type='" + type + "' class='" + classN + "' name='" + name + "' placeholder='" + placeholder +"'/>");
    }
    private void printInput(String type, String classN, String name, String placeholder, String value)  {
        w("<input type='" + type + "' class='" + classN + "' name='" + name + "' value='" + value + "' placeholder='" + placeholder +"'/>");
    }
    private void printSubmit(String text)  { w("<input type='submit' value='" + text + "'/>");}
    private void printSubmit(String text, String classN)  { w("<input type='submit' class='"+classN+"' value='" + text + "'/>");}
    private void startDiv(String classN)  { w("<div class='" + classN + "'>"); }
    private void startDiv(String classN, String id) { w("<div class='" + classN + "' id='"+id+"'>"); }
    private void startDiv(String classN, String id, String align)  { w("<div class='" + classN + "' id='"+id+"' align='" + align + "'>"); }
    private void startDiv(String classN, String id, String align, String aria_labelledby) { w("<div class='" + classN + "' id='"+id+"' align='" + align + "' aria-labelledby='" + aria_labelledby + "'>"); }
    private void endDiv() throws IOException { w("</div>"); }

    private void startTable(String classN)  { w("<table class='" + classN + "'>"); }
    private void endTable(String classN)  { w("</table>"); }
    private void startTHead(String classN)  { w("<thead class='" + classN + "'>"); }
    private void endTHead(String classN)  { w("</thead class='" + classN + "'>"); }
    private void startTBody(String classN)  { w("<tbody class='" + classN + "'>"); }
    private void endTBody(String classN)  { w("</tbody class='" + classN + "'>"); }
    private void printTRow(String classN)  { w("<"); }
    private void startTr()  { w("<tr>");}
    private void endTr()  { w("</tr>");}
    private void printTh(String scope, String text)  { w("<th scope='"+scope+"'>" + text + "</th>");}
    private void startTd(String classN, String text)  { w("<td class='"+classN+"'>" + text + "</td>");}
    private void printTd(String scope, String classN, String align, String text) { w("<td align='" + align + "' class='" + classN + "' scope='"+scope+"'>" + text + "</td>");}

    private void printI(String text, String classN) { w("<i class='" + classN + "'>" + text + "</i>"); }
    private String getI(String text, String classN)  { return String.format("<i class='" + classN + "'>" + text + "</i>"); }
    private void printH(String text, int size)  { w("<h" + size + ">" + text + "</h" + size + ">"); }
    private void printH(String text, String classN, int size) { w("<h" + size + " class='"+classN+"'>" + text + "</h" + size + ">"); }

    private void printButton(String classN, String type, String id, String data_toggle, String aria_haspopup, String aria_expanded, String text) throws IOException {
        w("<button class='"+classN+"' type='" + type + "' id='" + id + "' data-toggle='" + data_toggle + "' aria-haspopup='" + aria_haspopup + "' aria-expanded='"+aria_expanded+ "'>" + text + "</button>");
    }

    private void startForm(String method, String action)  { w("<form method='" + method +"' action='"+action + "'>"); }
    private void startForm(String method, String action, String enctype)  { w("<form method='" + method +"' action='"+action + "' enctype='"+enctype+"'>"); }
    private void endForm() { w("</form>");  }
    private void printText(String name, int cols, int rows, String innerText) {
            w("<textarea name='" + name + "' cols=" + cols + " rows=" + rows + ">");
                if(innerText != null)
                    w(innerText);
            w("</textarea>");
    }
    private void nLine() { w("<br/>"); }
%>
<% // этот блок инициализирующего кода выполняется уже в процессе обработки запроса, но в самом начале. я перенес его _до_ тела html документа
    this.out = out;
    long enter_time = System.currentTimeMillis();
    initUser(request);
    request.setCharacterEncoding("UTF-8");
    log = new LogProvider(this.getServletContext().getInitParameter("logFilePath"));
    //-------------------------INIT SECTION ENDED------------------------//

    String pathParam = getRequestParameter(request, PARAM_PATH, currentDirectory);
    String fileParam = getRequestParameter(request, PARAM_FILE);
    String fileStatus = getRequestParameter(request, PARAM_ACTION);

    currentDirectory = pathParam;
    if(!currentDirectory.endsWith(unixSlash))
        currentDirectory = currentDirectory + unixSlash;
%>
<!DOCTYPE HTML>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="contrib/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">  <!-- SIC! external-ref (см выше) -->
    <link href="css/style.css" rel="stylesheet">
    <link rel="icon" href="img/user.png" type="image/png">
    <title>Просмотр файлов </title>
    <style>
        a:hover {
            text-decoration: none;
            color: deeppink;
        }
        a {
            color: dodgerblue;
        }
        body {
            display: flex;
        }
    </style>
</head>
<body>
<%
    processFileRequest(fileParam, pathParam, fileStatus, request, response);
    File actual = null;

    try {
     actual = new File(currentDirectory);
%>
<div id="main_block" class="container">
    <div class="row">
        <div class="col">
          <h3><%wln("Содержание директории: "+ currentDirectory);%></h3>
        </div>
        <% printServerButton(); %>
    </div>
	    <table class="table">
        <thead class="thead-light">
        <tr>
            <th scope="col">Имя</th>
            <th scope="col">Размер,байт</th>
            <th scope="col">Свойство</th>
            <th scope="col">Последняя модификация</th>
            <th scope="col">Операции с файлом</th>
        </tr>
        </thead>
<tbody>
<% if(!currentDirectory.equals(HOME_DIRECTORY)) { %>
<tr>
    <td scope="row" class="viewer"><a href="<%=getPathReference(encodeValue(goUpside(currentDirectory)))%>"><i class="icon-share">. . .</i></a></td>
</tr>
<% } else;

    String ico="";
    String readwrite="";
    for(File f : actual.listFiles()) {
    if (f.isDirectory()&!f.isFile()) {ico="<i class=\"icon-folder\"></i>";}
        else if(!f.isDirectory()&f.isFile()){ico="<i class=\"icon-file-text2\"></i>";}
            else ico="<i class=\"icon-link\" ></i>";
    if (f.canWrite()&f.canRead()) {readwrite="чтение/запись";}
        else if (!f.canWrite()&f.canRead()){readwrite="чтение";}
            else {readwrite=" ";}
%>
<tr>
    <td scope="row" class="viewer">
        <% if(f.isFile()&f.canRead()) { %>
            <a href="<%=getFileReference(encodeValue(currentDirectory), encodeValue(f.getName()), ACTION_VIEW)%>"><%=ico+" "+f.getName()%></a>
        <% } else {
            wln(ico + " " + goToFile(f.getName()));
        } %>
    </td>
    <td scope="row" align="right"><%=f.length()%></td>
    <td scope="row"><%wln(readwrite);%></td>
    <td scope="row" align="center"><%=new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified())%></td>
    <td scope="row">
    <% if(f.isFile()&f.canRead()) { %>
        <a href="download?path=<%=encodeValue(currentDirectory)%>&file=<%=encodeValue(f.getName())%>">Скачать файл</a>  <!-- Возможно внедрение вредоноского кода и скачка файлов из других директорий (потом переделаю) -->
    <% } %>
    </td>
</tr>
<%
    } //for( File f : actual.listFiles())
}catch (IOException ex){
    wln("Ошибка ввода вывода : " + ex);
}
catch(Exception e) {
    wln("Нераспознанная ошибка: " + e);
    wln("попробуйте другую операцию" );
}
finally{ }
%>
</tbody>
</table>
</div>
<div id="issues" >
<h3>Задачи и найденные ошибки в проекте, чтоб глаза мозолило</h3>
<ul>
<li> 01. Трекера задач нет, буду писать сюда ;)
<li> 02. path=%2Fs%2Fusersdb%2Fyadzuka%2F - это плохо, path=/s/usersdb/yadzuka - лучше, но все-равно плохо
<li> 03. path=/s/usersdb/yadzuka - плохо, path=/yadzuka - приемлимо, и даже нормально, то что это /s/usersdb/ пользователю знать не обязательно
<li> 04. Вот этот блок (div), с id="issues", можно загрузить из отдельного файла, через include другой issues.jsp, но это задача Александру
<li> 05. И в догонку к ней - через JS и стили сделать его сокрытие/показывание
<li> 06. Makefile - пустой
<li> 07. README.md - должен быть в wiki формате Markdown (см википедию) о чем говорит расширение .md
<li> 08. в webapps/cms/WEB-INF/lib/ класть надо commons-fileupload-1.4.jar и commons-io-2.6.jar а не в /usr/local/apache-tomcat-9.0/lib/
<li> 09. IOException от w() - не надо гонять по всему стеку, его надо поймать и проигнорировать в самом низу, метод w() есть у нас для этого
<li> 10. при загрузке файлов получаю NullPointer Exception, но файлы грузятся... кто-то где-то накосячил
<li> 11. загрузил я видеоролик, большой, 500 Mb, и решил его просмотреть, и посмотрел я на тот, как на сервере кончилась оперативная память, и понял я, что кто-то не понял, что память конечна и, видимо просто грузит весь файл в память, прежде чем отдать его клиенту, и опечалился я, и кончились у меня силы, и выпил я с горя водки, и пошел я спать... ;)
<li> 12. ...но вернулся я, чтобы дописать - строка 495 - зло, 513 - зло, 515 - зло, 523, 525 - зло. Не надо злоупотреблять if-ми вообще, а внутри jsp или php, где вперемешку html и серверная императивная логика - особенно. 
<li> 13. и самое главное, весь код от строки 484, до строки 540 должен превратиться в вызов всего одного метода warh.process(), пример можно посмотреть здесь <a href='https://bitbucket.org/eustrop/conceptis/src/default/src/java/webapps/tisc/tiscui.jsp'>ConcepTIS/src/java/webapps/tisc/tiscui.jsp</a> строки 119-121, также см строки 43-50, а потом здесь : <a href='https://bitbucket.org/eustrop/conceptis/src/default/src/java/webapps/tisc/tisc.jsp'>ConcepTIS/src/default/src/java/webapps/tisc/tisc.jsp</a>. Все порождение html кода содержательной части документа, зависящей от параметров запроса мы переносим в методы, которые затем перенесем в отдельные классы. В JSP остается только обрамляющая часть HTML-кода, общая для любой страницы, все остальное "рисуется" либо java на сервере, либо JavaScript в браузере. Но для прототипирования и отладки внешнего вида мы иногда пишем так, как написано сейчас, главное - вовремя остановиться. И здесь силы меня оставили совсем 13 мая 2020 г 1:53 мин.

</ul>
</div>
<script src="contrib/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="contrib/nmp/popper.js-1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="contrib/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</body>
</html>
