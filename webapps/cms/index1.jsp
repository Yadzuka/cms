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
%>
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

    // File differences class
    private final diff_match_patch diffMatchPatch = new diff_match_patch();

    // User info
    private String userIP;
    private final static String homeDirectory = "/s/usersdb/";
    private String currentDirectory = homeDirectory;

    private final static String unixSlash = "/";

    private void initUser(HttpServletRequest request) {
        userIP = request.getRemoteAddr();
        currentDirectory = homeDirectory + getServletConfig().getServletContext().getInitParameter("user") + "/";
        try {
            if (!Files.exists(Paths.get(currentDirectory))) {
                File newDir = new File(currentDirectory);
                newDir.mkdir();
            }
        } catch (Exception ex) {
            try {
                out.print("Can't create directory!");
            } catch (Exception e) { log.e("Error in initUser(request) by user "+ userIP); }
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
                out.print("Error with getting path");
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

    private String getRequestParameter(ServletRequest request, String param){
        return getRequestParameter(request, param, null);
    }

    private String getRequestParameter(ServletRequest request, String param, String default_value){
        String value = request.getParameter(param);
        if(value == null) value = default_value;
        if(value == null) return (null);
        if (PARAM_PATH.equals(value)) {
            if (!(value.endsWith(unixSlash)))
                value += unixSlash;
            if (!value.startsWith(homeDirectory))
                value = default_value;

            if (checkShellInjection(value))
                throw new RuntimeException("Shell injection");
        } else if (PARAM_FILE.equals(value)) {
            if (checkShellInjection(value))
                throw new RuntimeException("Shell injection");
        }
        return value;
    }

    private String goToFile(String fileName) {
        if(isDir(currentDirectory, fileName)) {
            String targetPath = currentDirectory + fileName;
            return getPathReference(targetPath, fileName);
        }
        return openFile(currentDirectory, fileName);
    }
    private String openFile(String href, String value){ return value; }

    private String getPathReference(String path, String value) {
        return "<a href='" + CGI_NAME + "?" + PARAM_PATH +"="+ path + unixSlash +"'>" + value + "</a>";
    }

    private String getPathReference(String path) { return CGI_NAME + "?" + PARAM_PATH +"="+ path + unixSlash; }
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

    private void printFileForm(String directory, String fileName, String status, String fileText) {
        if(status.equals(ACTION_VIEW)) {
            startForm("POST", getFileReference(directory, fileName, ACTION_VIEW));
            printText(FILE_TEXTAREA_NAME, 72, 10, fileText); nLine();
            printFileEditButtons();
            endForm();
        }
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
    private void wln(String s){w(s);w("\n");}
    private void wln(){w("\n");}
    private void setReference(String reference, String insides) { w("<a href=\""+reference+"\">"); w(insides); w("</a>"); }

    private void startForm(String method, String action) { try{ out.print("<form method='" + method +"' action='"+action + "'>");} catch (Exception ex) {}}
    private void endForm() {try{ out.print("</form>");}catch (Exception ex){}}
    private void printText(String name, int cols, int rows, String innerText) {
        try{
            out.print("<textarea name='" + name + "' cols=" + cols + " rows=" + rows + ">");
                if(innerText != null)
                    out.print(innerText);
            out.print("</textarea>");
        } catch (Exception ex){}
    }
    private void nLine() { try { out.print("<br/>");} catch (Exception ex) {}}
%>
<!DOCTYPE HTML>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">  <!-- SIC! external-ref (см выше) -->
    <link href="css/style.css" rel="stylesheet">
    <link rel="icon" href="img/user.png" type="image/png">
    <title>Просмотр файлов </title>
</head>
<body>
<%
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

    if(fileParam != null) {
        StringBuilder sb = new StringBuilder();
        String fileBuffer = "";

        if(request.getParameter(ACTION_SAVE) != null) {
            BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter
                            (new FileOutputStream(currentDirectory + fileParam, false), StandardCharsets.UTF_8));
            out.print("Saved");
            String fileText = request.getParameter(FILE_TEXTAREA_NAME);
            bufferedWriter.write(fileText);
            bufferedWriter.flush();
            bufferedWriter.close();
        }
        if(request.getParameter(ACTION_DELETE) != null) {
            deleteFile(currentDirectory + fileParam);
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
            out.print("cant read file");
        }
        if(fileStatus.equals(ACTION_VIEW)) {
            printFileForm(currentDirectory, fileParam, fileStatus, sb.toString());
        }
    }

    File actual = null;

    try {
     actual = new File(currentDirectory);
%>
<div class="container">
    <div class="row">
        <div class="col">
          <h3><%out.println("Содержание директории: "+ currentDirectory);%> </h3>
        </div>
    <div class="col" align="right">
          <div class="dropright"> 
            <button
              class="btn btn-light btn-lg dropdown-toggle"
              type="button"
              id="dropdownMenuButton"
              data-toggle="dropdown"
              aria-haspopup="true"
              aria-expanded="false">
             <i class="icon-folder-open">   Сервер</i>
            </button>
            <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
              <h5 class="dropdown-header">Обращение к серверу</h5>
              <div class="dropdown-divider"></div>
                <form method="POST" enctype="multipart/form-data" action="upload">
                  <input type="hidden" name="path" value="<%=currentDirectory%>">
                  <input class="dropdown-item" type="file" name="file" multiple>
                  <input class="dropdown-item" type="submit" value="Загрузить (Apache Commons)">
                </form>
                <form method="POST" enctype="multipart/form-data" action="upload_new_version">
                    <input type="hidden" name="path" value="<%=currentDirectory%>">
                    <input class="dropdown-item" type="file" name="file" multiple>
                    <input class="dropdown-item" type="submit" value="Загрузить (Servlet V3.1)">
                </form>
              <div class="dropdown-divider"></div>
              <a class="dropdown-item" href="#">Что-то ещё</a>
            </div>
          </div>
        </div>
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
<tr>
    <td scope="row" class="viewer"><a href="<%=getPathReference(goUpside(currentDirectory))%>"><i class="icon-share"> . . . </i></a></td>
</tr>
<%
    String ico="";
    String readwrite="";
    for(File f : actual.listFiles()) {
    if (f.isDirectory()&!f.isFile()) {ico="<i class=\"icon-folder\"></i>";}
        else if(!f.isDirectory()&f.isFile()){ico="<i class=\"icon-file-text2\"></i>";}
            else ico="<i class=\"icon-link\" ></i>";
    if (f.canWrite()&f.canRead()) {readwrite="чтение/запись";}
        else if (!f.canWrite()&f.canRead()){readwrite="чтение";}
            else {readwrite="запись";}
%>
<tr>
    <td scope="row" class="viewer"><%out.println(ico + " " + goToFile(f.getName()));%></td>
    <td scope="row" align="right"><%=f.length()%></td>
    <td scope="row"><%out.println(readwrite);%></td>
    <td scope="row" align="center"><%=new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified())%></td>
    <td scope="row">
    <% if(f.isFile()&f.canRead()) { %>
        <a href="<%=getFileReference(currentDirectory, f.getName(), ACTION_VIEW)%>">Просмотреть файл</a><br/>
        <!-- <form method="POST" action="download">
            <input type="hidden" name="path" value="<%--=currentDirectory--%>">
            <input type="hidden" name="file" value="<%--=f.getName()--%>">
            <input type="submit" value="Скачать">
        </form>-->
        <a href="download?path=<%=currentDirectory%>&file=<%=f.getName()%>">Скачать файл</a>  <!-- Возможно внедрение вредоноского кода и скачка файлов из других директорий (потом переделаю) -->
    <% } %>
    </td>
</tr>
<%
    } //for( File f : actual.listFiles())
}catch (IOException ex){
    out.println("Ошибка ввода вывода : " + ex);
}
catch(Exception e) {
    out.println("Нераспознанная ошибка: " + e);
    out.println("попробуйте другую операцию" );
}
finally{ }
%>
</tbody>
</table>
</div>
<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script> 
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</html>
