<%@ page contentType="text/html;charset=UTF-8" language="java"
    import="javax.servlet.jsp.JspWriter"
    import="java.nio.file.Files"
    import="java.nio.file.Paths"
    import="java.nio.file.Path"
    import="java.io.*"
%>
<%!
    // Page info
    private final static String CGI_NAME = "index.jsp"; // Page domain name
    private final static String CGI_TITLE = "CMS system"; // Upper page info
    private final static String JSP_VERSION = "$id$"; // Id for jsp version
    private JspWriter out;

    private final String PARAM_PATH = "path";
    private final String PARAM_FILE = "file";

    private final short elementsMargin = 7;

    private String currentDirectory = "/";
    private String homeDirectoryUnix = "/home/";
    private File [] currentDirectoryFiles = new File(currentDirectory).listFiles();
    private String [] fileNames;

    private final String unixRootDir = "/";
    private final String staticHomeDirUnix = "/home/";
    private final String nLine = "<br/>";
    private final String tab = "&nbsp;";
    private final String windowsSlash = "\\";
    private final String unixSlash = "/";
    private final String directory = "DIRECTORY";
    private final String file = "FILE";
    private final String [] fileTypes = { directory, file };
    private boolean fileOpenStatus = false;

    private final char dotForDownsideSlide = '.';

    private final char directoryStatus = 'd';
    private final char linkStatus = 'l';

    private final char noPermission = '-';
    private final char readPermission = 'r';
    private final char writePermission = 'w';
    private final char executePermission = 'x';
    private final String userPermissions = new String(new char[]{readPermission, writePermission, executePermission});
    private final String groupPermissions = new String(new char[]{readPermission, writePermission, executePermission});
    private final String otherPermissions = new String(new char[]{readPermission, writePermission, executePermission});
    private final String [] filePermissions = new String[] {userPermissions, groupPermissions, otherPermissions};

    private final String ACTION_CREATE_DIR = "create_dir";
    private final String ACTION_CREATE_FILE = "create_file";
    private final String ACTION_DELETE_FILE = "delete_file";

    private final String ACTION_DOWNLOAD = "download";

    private final String PARAM_FILENAME = "file";


    private void initUser() {
        if(System.getProperty("os.name").equals("Linux") | System.getProperty("os.name").equals("Unix"))
            homeDirectoryUnix = staticHomeDirUnix + getServletConfig().getServletContext().getInitParameter("user") + "/";
    }

    private boolean createDir(String path, String dirName) throws Exception {
        Path pathToDir = getPath(path, dirName);
        File directory = new File(pathToDir.toUri());
        if(directory.exists())
            return true;
        else
            return directory.mkdir();
    }

    private boolean createFile(String path, String fileName) throws Exception {
        Path pathToFile = getPath(path, fileName);
        File file = new File(pathToFile.toUri());
        return file.createNewFile();
    }

    private boolean deleteFile(String path, String fileName) throws Exception {
        Path pathToFile = getPath(path, fileName);
        File file = new File(pathToFile.toUri());
        return file.delete();
    }

    private File[] getFilesNames() {
        currentDirectoryFiles = new File(currentDirectory).listFiles();
        return currentDirectoryFiles;
    }

    private Path getPath(String pathToFile, String fileName) throws FileNotFoundException, Exception {
        pathToFile = pathToFile.trim(); fileName = fileName.trim();
        Path filePath = null;
        if(!(pathToFile.endsWith(unixSlash) | pathToFile.endsWith(windowsSlash))) {
            if(pathToFile.contains(unixSlash)) { pathToFile += unixSlash; }
            else if(pathToFile.contains(windowsSlash)) { pathToFile += windowsSlash; }
        }
        try{ filePath = Paths.get(pathToFile + fileName); }
        catch (Exception ex) { throw new FileNotFoundException("File not found!"); }
        return filePath;
    }

    private boolean isExecutable(String path, String fileName) throws FileNotFoundException, Exception {
        Path pathToFile = getPath(path, fileName);
        return Files.isExecutable(pathToFile);
    }

    private boolean isDir(String path, String fileName) throws FileNotFoundException, Exception {
        Path pathToFile = getPath(path, fileName);
        return Files.isDirectory(pathToFile);
    }

    private short countDotsToEnd(short start, short end) {
        if(end < start)
            return 0;
        else if(end < 0 | start < 0)
            return  0;
        return  (short)(end - start);
    }

    private String getRequestParameter(ServletRequest request, String param){
        return getRequestParameter(request, param, null);
    }

    private boolean checkShellInjection(String param){ return param.contains(".."); }

    private String getRequestParameter(ServletRequest request, String param, String default_value){
        String value = request.getParameter(param);
        if(value == null) value = default_value;
        if(value == null) return (null);
        switch (param){
            case PARAM_PATH:
                if(!(value.endsWith(unixSlash) | value.endsWith(windowsSlash)))
                    value += unixSlash;
            case PARAM_FILE:
                if(checkShellInjection(value))
                    throw new RuntimeException("Shell injection");
        }
        return value;
    }

    private String goToFile(String fileName) throws Exception {
        if(isDir(currentDirectory, fileName)) {
            String targetPath = currentDirectory + fileName;
            return getPathReference(targetPath, fileName);
        }
        return openFile(currentDirectory, fileName);
    }
    private String openFile(String href, String value){ return new String(value); }
    private String getPathReference(String path, String value) {
        return new String("<a href='" + CGI_NAME + "?" + PARAM_PATH +"="+ path + unixSlash +"'>" + value + "</a>");
    }
    private String goUpside(String folderName) throws Exception{
        if(folderName.endsWith(unixSlash)) {
            folderName = folderName.substring(0, folderName.length() - 1);
            folderName = folderName.substring(0, folderName.lastIndexOf(unixRootDir));
        }
        return folderName;
    }
    private void beginDiv(String className) throws Exception{ out.println("<div class='"+className+"'>"); }
    private void endDiv() throws Exception{ out.println("</div>"); }
%>
<html>
<head>
    <title><%=CGI_TITLE%></title>
    <script rel="script" src="js/javascript.js"></script>
    <style rel="stylesheet">
        body {
            margin: <%=elementsMargin%>;
        }
        .explorer{
            margin: <%=elementsMargin%>px;
        }
    </style>
</head>
<body>
<h1>Hello and welcome to the start page of our CMS!</h1>
<%
    this.out = out;
    long enter_time = System.currentTimeMillis();
    initUser();

    String p_filename = request.getParameter(PARAM_FILENAME);
    out.print(p_filename);

    String pathParam = getRequestParameter(request, PARAM_PATH, homeDirectoryUnix);
    String fileParam = getRequestParameter(request, PARAM_FILE);
    currentDirectory = pathParam;

    out.print(currentDirectory);

    try {
        beginDiv("explorer");

        if(currentDirectory.equals(unixRootDir)){out.println("Root directory"); out.print(nLine);}
        else { out.print(getPathReference(goUpside(currentDirectory), "<- Go back")); out.print(nLine); out.print(nLine); }

        File [] filesInDir = getFilesNames();
        fileNames = new String[filesInDir.length];

        for(int i = 0; i < filesInDir.length; i++){
            fileNames[i] = filesInDir[i].getName();
            out.print(goToFile(filesInDir[i].getName()));
            out.print(nLine);
        }
        endDiv();
    }catch (Exception ex){
        ex.printStackTrace();
    }

%>

<hr>

<form method="POST" action="download">
    <input type="hidden" name="path" value="<%=currentDirectory%>">
    <input type="text" name="file" value="">
    <input type="submit" value="Скачать">
</form>


<form method="POST" enctype="multipart/form-data" action="upload">
    <input type="hidden" name="path" value="<%=currentDirectory%>">
    File to upload: <input type="file" name="upfile" multiple><br/>
    <br/>
    <input type="submit" value="Загрузить"> to upload the file!
</form>

<hr>
<i>timing : <%= ((System.currentTimeMillis() - enter_time) + " ms") %>
</i>
<br>
Hello! your web-server is <%= application.getServerInfo() %><br>
<i><%= JSP_VERSION %>
</i>
<!-- Привет this is just for UTF-8 testing (must be russian word "Privet") -->
</body>
</html>