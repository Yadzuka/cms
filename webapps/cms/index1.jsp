<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.io.*"
         import="java.text.SimpleDateFormat"
         import="java.nio.file.Paths"
         import="java.nio.file.Path"
         import="java.nio.file.Files"
         import="org.eustrosoft.providers.LogProvider"
%><%!
    // Page info
    private final static String CGI_NAME = "index1.jsp"; // Page domain name
    private final static String CGI_TITLE = "CMS system"; // Upper page info
    private final static String JSP_VERSION = "$id$"; // Id for jsp version
    private final static LogProvider log = new LogProvider();
    private JspWriter out;

    private final String PARAM_PATH = "path";
    private final String PARAM_FILE = "file";

    // User info
    private String userIP;
    private final String homeDirectory = "/s/usersdb/";
    private String currentDirectory = homeDirectory;
    private File [] currentDirectoryFiles = new File(homeDirectory).listFiles();

    private final String unixSlash = "/";
    private final String PARAM_FILENAME = "file";

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

    private File[] getFilesNames() {
        currentDirectoryFiles = new File(currentDirectory).listFiles();
        return currentDirectoryFiles;
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

    private String getPathReference(String path) {
        return CGI_NAME + "?" + PARAM_PATH +"="+ path + unixSlash;
    }

    private String goUpside(String folderName) {
        if(folderName.endsWith(unixSlash)) {
            folderName = folderName.substring(0, folderName.length() - 1);
            folderName = folderName.substring(0, folderName.lastIndexOf(unixSlash));
        }
        return folderName;
    }

    private void nLine() { try { out.print("<br/>");} catch (Exception ex) {}}
    private void beginDiv(String className) throws Exception{ out.println("<div class='"+className+"'>"); }
    private void endDiv() throws Exception{ out.println("</div>"); }
%>
<%
    this.out = out;
    long enter_time = System.currentTimeMillis();
    initUser(request);
    //-------------------------INIT SECTION ENDED------------------------//

    String p_filename = request.getParameter(PARAM_FILENAME);
    String pathParam = getRequestParameter(request, PARAM_PATH, currentDirectory);
    String fileParam = getRequestParameter(request, PARAM_FILE);
    currentDirectory = pathParam;

    File actual = null;

    try {
     actual = new File(currentDirectory);
%>
<!Doctype HTML>
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
                  <input class="dropdown-item" type="file" name="file/" multiple>
                  <input class="dropdown-item" type="submit" value="Загрузить">
                </form>
              <a class="dropdown-item" href="#">Скачать</a>
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
            <th scope="col">Путь</th>
            <th scope="col">Свойство</th>
            <th scope="col">Последняя модификация</th>
            <th scope="col">Размер,байт</th>
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
    <td scope="row"><%=f.getPath() %></td>
    <td scope="row"><%out.println(readwrite);%></td>
    <td scope="row" align="center"><%=new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified())%></td>
    <td scope="row" align="right"><%=f.length()%></td>
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
<script>
</script>
<!--
<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script> 
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
-->
</body>
</html>
