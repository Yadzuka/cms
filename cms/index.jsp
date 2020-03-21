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

    private static final String ROOT_FOLDER = "Root folder!";

    private final String PARAM_PATH = "path";
    private final String PARAM_FILE = "file";

    private final short elementsMargin = 7;

    private final String homeDirectory = "/s/usersdb/";
    private String currentDirectory = homeDirectory;
    private File [] currentDirectoryFiles = new File(homeDirectory).listFiles();
    private String [] fileNames;

    private final String nLine = "<br/>";
    private final String unixSlash = "/";
    private final String directory = "DIRECTORY";
    private final String file = "FILE";

    private final String PARAM_FILENAME = "file";


    private void initUser() {
        currentDirectory = homeDirectory + getServletConfig().getServletContext().getInitParameter("user") + "/";
        try {
            if (!Files.exists(Paths.get(currentDirectory))) {
                File newDir = new File(currentDirectory);
                newDir.mkdir();
            }
        } catch (Exception ex) {
            try {
                out.print("Can't create directory!");
            } catch (Exception e) {}
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
                if(!(value.endsWith(unixSlash)))
                    value += unixSlash;
                if(!value.startsWith(homeDirectory))
                    value = homeDirectory;
            case PARAM_FILE:
                if(checkShellInjection(value))
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
    private String openFile(String href, String value){ return new String(value); }

    private String getPathReference(String path, String value) {
        return new String("<a href='" + CGI_NAME + "?" + PARAM_PATH +"="+ path + unixSlash +"'>" + value + "</a>");
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

    String pathParam = getRequestParameter(request, PARAM_PATH, homeDirectory);
    String fileParam = getRequestParameter(request, PARAM_FILE);
    currentDirectory = pathParam;

    out.print(currentDirectory);

    try {
        beginDiv("explorer");

        if(currentDirectory.equals(homeDirectory)){
            out.println(ROOT_FOLDER); out.print(nLine);
        }
        else {
            out.print(getPathReference(goUpside(currentDirectory), "<- Go back"));
            nLine();
        }

        File [] filesInDir = getFilesNames();
        fileNames = new String[filesInDir.length];

        for(int i = 0; i < filesInDir.length; i++){
            fileNames[i] = filesInDir[i].getName();
            out.print(goToFile(filesInDir[i].getName()));
            nLine();
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