<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.io.*"
         import="java.text.SimpleDateFormat"
         import="org.eustrosoft.providers.LogProvider"
         import="name.fraser.neil.plaintext.diff_match_patch"
         import="java.nio.charset.StandardCharsets"
         import="java.io.UnsupportedEncodingException"
         import="java.net.URLEncoder"
         import="java.util.Map" %>
<%@ page import="java.util.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.nio.file.attribute.PosixFilePermission" %>
<%@ page import="java.nio.file.attribute.PosixFilePermissions" %>
<%@ page import="java.nio.file.attribute.FileAttribute" %>
<%!
    // Page info
    class Main{
    private String CGI_NAME = "index1.jsp"; // Page domain name
    private String VERSION = "0.1";
    private final String CGI_TITLE = "CMS system"; // Upper page info
    private final String JSP_VERSION = "$id$"; // Id for jsp version
    private LogProvider log;
    private JspWriter out;

    public String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
    public String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","\n"};
    public final String[] VALUE_CHARACTERS = { "<",">","&","\"","'" };
    public final String[] VALUE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","&quot;","&#039;"};

    // Files and directories manipulating
    // Destination param (test)
    private final String PARAM_D = "d";
    private final String PARAM_ACTION = "cmd";
    private final String PARAM_FILE = "file";
    private final String PARAM_DIRECTORY = "directory";
    private final String FILE_TEXTAREA_NAME = "file_text";


    // File manipulating (view, save, update, delete)
    private final String ACTION_VIEW = "view";
    private final String ACTION_SAVE = "save";
    private final String ACTION_UPDATE = "update";
    private final String ACTION_DELETE = "delete";
    private final String ACTION_CREATE = "create";
    private final String ACTION_COPY = "cp";
    private final String ACTION_MKDIR = "mkdir";
    private final String ACTION_DELETE_DIR = "rmdir";
    private final String ACTION_RENAME = "rename";

    private final String ACTION_EDIT = "edit";
    private final String ACTION_VIEW_AS_IMG = "image_view";
    private final String ACTION_VIEW_AS_VIDEO = "video_view";
    private final String ACTION_VIEW_AS_TEXT = "text_view";
    private final String ACTION_VIEW_AS_TABLE = "table_view";

    private final int MAX_FILE_READ_SIZE = 10_000_000;

    private final String [] IMAGE_DEFINITIONS = { "jpg", "jpeg", "png", "svg", "tiff", "bmp", "bat", "odg", "xps" };
    private final String [] VIDEO_DEFINITIONS = { "ogg", "mp4", "webm" };
    private final String CSV_FORMAT = "csv";
    // File differences class
    private final diff_match_patch diffMatchPatch = new diff_match_patch();

    // User info
    private String userIP;
    private String HOME_DIRECTORY;
    private String currentDirectory = HOME_DIRECTORY;
    private String showedPath;
    private final String unixSlash = "/";

    Map<String, String> references;


    private void initUser(HttpServletRequest request) {
        userIP = request.getRemoteAddr();
        HOME_DIRECTORY = getServletConfig().getServletContext().getInitParameter("root") + getServletConfig().getServletContext().getInitParameter("user");
        showedPath = "/";
        currentDirectory = HOME_DIRECTORY;
        try {
            if (!Files.exists(Paths.get(HOME_DIRECTORY))) {
                File newDir = new File(HOME_DIRECTORY);
                newDir.mkdir();
            }
        } catch (Exception ex) {
            try {
                wln("Can't create directory!");
            } catch (Exception e) { log.e("Error in initUser(request) by user " + userIP); }
        }
    }

    public String translate_tokens(String sz, String[] from, String[] to)
    {
        if(sz == null) return(sz);
        StringBuffer sb = new StringBuffer(sz.length() + 256);
        int p=0;
        while(p<sz.length())
        {
            int i=0;
            while(i<from.length) // search for token
            {
                if(sz.startsWith(from[i],p)) { sb.append(to[i]); p=--p +from[i].length(); break; }
                i++;
            }
            if(i>=from.length) sb.append(sz.charAt(p)); // not found
            p++;
        }
        return(sb.toString());
    }

    // Check access
    private boolean checkAccess(String path) throws IllegalAccessException {
        Random rand = new Random();
        double i = rand.nextDouble();
        if(i < 0.3) {
            throw new IllegalAccessException();
        } else {
            return true;
        }
    }

    private void reserveVersion(String path) throws IllegalAccessException {
        checkAccess(path);
    }

    class FileInfo {
    // Get file name
    private String basename(String path) {
        try {
            File file = new File(path);
            return file.getName();
        } catch (Exception ex) {
            return "";
        }
    }

    // Get directory name
    private String dirname(String path) {
        File file = new File(path);
        return file.getParent();
    }

    private boolean isExecutable(String path) {
        Path pathToFile = Paths.get(path);
        return Files.isExecutable(pathToFile);
    }

    private boolean isDir(String path) {
        Path pathToFile = Paths.get(path);
        return Files.isDirectory(pathToFile);
    }
    }
    private boolean checkShellInjection(String param){ return param.contains(".."); }
    private String getRequestParameter(ServletRequest request, String param)  {
        return getRequestParameter(request, param, null);
    }

    private String encodeValue(String value) { // SIC! тут надо в слеши превращать %2F
        String regexForSlashes = "%2F";
        String str;
        try {
            str = URLEncoder.encode(value, StandardCharsets.UTF_8.toString());
            str = str.replaceAll(regexForSlashes, "/");
        } catch (UnsupportedEncodingException ex) {
            throw new RuntimeException(ex.getCause());
        }
        return str;
    }

    private String getRequestParameter(ServletRequest request, String param, String default_value)  { // SIC! Используется только для директорий & при создании одного параметра тут все менять надо
        String value = request.getParameter(param);
        if(value == null) value = default_value;
        if(value == null) return (null);
        // SIC!
        if(PARAM_D.equals(param)) {
            showedPath = value;
            value = HOME_DIRECTORY + value;

            if(!value.startsWith(unixSlash))
                value = unixSlash + value;
            if (checkShellInjection(value))
                throw new RuntimeException("Shell injection");
        }
        if(PARAM_FILE.equals(param) || PARAM_DIRECTORY.equals(param)) {
            if(checkShellInjection(value))
                throw new RuntimeException("Shell injection");
        }

        return value;
    }

    private String goToFile(String showedPath, String fileName) { // SIC! Только для папок - не знаю зачем тут проверка ( на всякий случай), но может потом надо убрать вообще
        FileInfo fileInfo = new FileInfo();
        if(fileInfo.isDir(currentDirectory + fileName)) {
            String targetPath = encodeValue(showedPath + fileName + unixSlash);
            return getPathReference(targetPath, fileName);
        }
        return openFile(fileName);
    }

    private String openFile(String value){ return value; }


    // Path reference with 'a' tags
    private String getPathReference(String path, String value) {
        return "<a href='" + CGI_NAME + "?" + PARAM_D +"="+ path + "'>" + value + "</a>";
    }
    // Path reference
    private String getPathReference(String path) {
        return CGI_NAME + "?" + PARAM_D +"="+ path;
    }

    // SIC! Ссылки снизу поменять либо на path + file, либо заменить на один параметр

    // File reference with action
    private String getFileReference(String path, String cmd) {
        return CGI_NAME + "?" + PARAM_D + "=" + path + "&" + PARAM_ACTION + "=" + cmd;
        // return CGI_NAME + "?" + PARAM_PATH + "=" + path + file + "&" + PARAM_ACTION + "=" + cmd;
    }

    // Go to the top directory
    private String goUpside(String folderName) { // SIC! Тут отрезается только если есть слеш в конце -> если его нет, то ничего не режет (воде починил, но проблем с этим пока не возникало)
        if(folderName.endsWith(unixSlash)) {
            folderName = folderName.substring(0, folderName.length() - 1);
        }
        folderName = folderName.substring(0, folderName.lastIndexOf(unixSlash));
        folderName += unixSlash;
        return folderName;
    }

    // Diff files to get differences
    private List diffFile(String text1, String text2) {
        diff_match_patch diffMatchPatch = new diff_match_patch();
        List<diff_match_patch.Diff> differences = diffMatchPatch.diff_main(text1, text2);
        return differences;
    }

    // Move file
    private boolean mv(String path, String newPath) {
        try {
            Path oldPlacement = Paths.get(path);
            Path newPlacement = Paths.get(newPath);
            File file = oldPlacement.toFile();
            file.renameTo(newPlacement.toFile());
            return true;
        } catch (Exception ex) { return false; }
    }

    // Change filename in specific path
    private boolean rename(String fileName, String newFileName) {
        File file = new File(goUpside(currentDirectory) + fileName);
        File dest = new File(goUpside(currentDirectory) + newFileName);
        if(file.renameTo(dest))
            return true;
        else
            return false;
    }

    // Make directory
    private boolean mkdir(String path/*, String [] params*/) {
        // checkAccess(user); SIC! Тут пока что так, как можно, потому что ограничений никаких нет
        File directory = new File(path);
        if(directory.exists()) return false;
        else {
            directory.mkdir();
            setPermissionsForDir(directory);
            return true;
        }
    }

    // Delete file
    private boolean rm(String fileName) {
        File file = new File(fileName);
        if(file.isDirectory())
            if(!(file.listFiles().length == 0))
                return false;
        return file.delete();
    }

    // Delete directory (with no files)
    private boolean rmdir(String path) {
        File directory = new File(path);
        if(directory.listFiles().length == 0)
            return directory.delete();
        return false;
    }

    private boolean isFilesInDirectory(File directory) {
        File [] filesInDirectory = directory.listFiles();
        if(filesInDirectory.length == 0)
            return false;
        else
            return true;
    }

    // Creating file
    private boolean touch(String fileName) {
        try {
            File file = new File(fileName);
            if(file.exists())
                return false;
            file.createNewFile();
            setPermissionsForFile(file);
            return true;
        } catch (IOException ex) { return false; }
    }

    private String cat(String fileName) {
        try {
            StringBuilder builder = new StringBuilder();
            FileReader stream = new FileReader(fileName);

            char [] buffer = new char[512];
            int c;
            while((c = stream.read(buffer)) > 0){
                builder.append(stream.read(buffer, 0, c));
            }
            return builder.toString();
        } catch (IOException ex) {
            return "Cannot read the file";
        }
    }

    // Copy file with replacing
    private boolean cp(String path, String newPath) {
        try {
            Path placement = Paths.get(path);
            Path copyPlacement = Paths.get(newPath);
            Files.copy(placement, copyPlacement, StandardCopyOption.REPLACE_EXISTING); // SIC! Надо будет посмотреть другие параметры.
                                    // Данный - заменяет файл в целевой папке, если файл с таким именем уже существует
            return true;
        } catch (Exception ex) { return false;}
    }

    private void setPermissionsForFile(File file) {
        try {
            Set<PosixFilePermission> perms = new HashSet<>();
            perms.add(PosixFilePermission.OWNER_READ);
            perms.add(PosixFilePermission.OWNER_WRITE);
            perms.add(PosixFilePermission.GROUP_WRITE);
            perms.add(PosixFilePermission.GROUP_READ);
            perms.add(PosixFilePermission.OTHERS_READ);
            Files.setPosixFilePermissions(file.toPath(), perms);
        } catch (IOException ex) {
        }
    }

    private void setPermissionsForDir(File file) {
        try {
            Set<PosixFilePermission> perms = new HashSet<>();
            perms.add(PosixFilePermission.OWNER_READ);
            perms.add(PosixFilePermission.OWNER_WRITE);
            perms.add(PosixFilePermission.OWNER_EXECUTE);
            perms.add(PosixFilePermission.GROUP_WRITE);
            perms.add(PosixFilePermission.GROUP_READ);
            perms.add(PosixFilePermission.GROUP_EXECUTE);
            perms.add(PosixFilePermission.OTHERS_READ);
            perms.add(PosixFilePermission.OTHERS_EXECUTE);
            Files.setPosixFilePermissions(file.toPath(), perms);
        } catch (IOException ex) {
        }
    }

    private void process(HttpServletRequest req, HttpServletResponse resp) {
        FileInfo fileInfo = new FileInfo();
        String dParameter = getRequestParameter(req, PARAM_D, showedPath);
        String fileParameter = fileInfo.basename(dParameter);
        String fileStatus = getRequestParameter(req, PARAM_ACTION);
        currentDirectory = dParameter;

        references = new LinkedHashMap<>();
        String referenceForSpecialPath = currentDirectory.substring(HOME_DIRECTORY.length());
        while(!referenceForSpecialPath.equals(unixSlash)) {
            references.put(getPathReference(referenceForSpecialPath), fileInfo.basename(referenceForSpecialPath));
            referenceForSpecialPath = goUpside(referenceForSpecialPath);
        }
        references.put(getPathReference(unixSlash), "root");

        boolean isFileAction = fileStatus != null;
        if (isFileAction) {
            processFileRequest(dParameter, fileStatus, req, resp);
        } else {
            printMainBlock(req);
        }
        printFooter();
    }

    private void printMainBlock(HttpServletRequest request) {
        File actual = null;
        try {
            if(!showedPath.endsWith(unixSlash))
                showedPath = showedPath + unixSlash;
            actual = new File(currentDirectory);

            printTableHead(request);
            startTBody("");
            if (!currentDirectory.equals(HOME_DIRECTORY + "/")) {
                startTr();
                printTd("row", "viewer", "", getA(getI(".&nbsp;.&nbsp;.", "icon-share"), getPathReference(goUpside(showedPath))));
                endTr();
            }

            File [] directories = actual.listFiles(File::isDirectory);
            File [] files = actual.listFiles(File::isFile);
            for (File f : directories) {
                printFileInTable(f);
            } //for( File f : actual.listFiles(directories))
            for (File f : files) {
                printFileInTable(f);
            } //for( File f : actual.listFiles(files))
        } catch(Exception e) {
            wln("Нераспознанная ошибка: " + e);
            wln("попробуйте другую операцию" );
        }
        finally{ }
        endTBody();
        endTable();
    }

    // SIC! тут в формах тоже надо менять ссылки (currentDirectory), соответственно это либо в сервлетах надо учитывать либо ещё что
    private void printServerButton()  {
        startDiv("col", "", "right");
        startDiv("dropright");
        printButton("btn btn-light btn-lg dropdown-toggle", "button", "dropdownMenuButton", "dropdown", "true", "false", getI("   Сервер", "icon-folder-open") );
        startDiv("dropdown-menu", "", "", "dropdownMenuButton");
        printH("Обращение к серверу", "dropdown-header", 5);
        startDiv("dropdown-divider"); endDiv();

        startForm("POST", "upload", "multipart/form-data");
        printInput("hidden", "", PARAM_D , "", showedPath);
        printInput(PARAM_FILE, "dropdown-item", PARAM_FILE, "", true);
        printSubmit("Загрузить", "dropdown-item");
        endForm();

        startDiv("dropdown-divider"); endDiv();
        endDiv();
        endDiv();
        endDiv();
    }

    private void printFileInTable(File f) {
        String ico = "";
        String readwrite = "";
        if (f.isDirectory() & !f.isFile()) {
            ico = getI("", "icon-folder");
        } else if (!f.isDirectory() & f.isFile()) {
            ico = getI("", "icon-file-text2");
        } else ico = "<i class=\"icon-link\" ></i>";
        if (f.canWrite() & f.canRead()) {
            readwrite = "чтение/запись";
        } else if (!f.canWrite() & f.canRead()) {
            readwrite = "чтение";
        } else {
            readwrite = " ";
        }
        startTr();
        startTd("viewer", "row");
        if(f.isFile()&f.canRead()) {
            printA(ico+" "+f.getName(), getFileReference(encodeValue(showedPath + f.getName()) , ACTION_VIEW));
        } else {
            wln(ico + " " + goToFile(showedPath, f.getName()));
        }
        endTd();
        printTd("row", "", "right", String.format("%d",f.length()));
        printTd("row", "", "", readwrite);
        printTd("row", "", "center", new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified()));
        endTr();
    }

    // path here means FULL/real path - be careful with this | showedPath path, in turn, means showed path and it could be use for showing for the client
    private void processFileRequest(String path, String fileStatus, HttpServletRequest request, HttpServletResponse response) {
        //wln("<style> a {padding: 5px 7px; cursor: pointer; transition: .3s; color: #000; border-radius: 80px;" +
          //      "background-color: lightgray; text-align: center; border-style: none; font-weight: 400; box-shadow: inset -7px -4px 7px 0px darkgrey, 5px 5px 10px;} </style>");
        try {
            if (path != null && fileStatus != null) {
                FileInfo fileInfo = new FileInfo();
               if (fileStatus.equals(ACTION_CREATE)) {
                    String newFileName = getRequestParameter(request, PARAM_FILE);

                    if(request.getParameter(ACTION_MKDIR) != null) {
                        mkdir(path + newFileName);
                        response.sendRedirect(getPathReference(encodeValue(showedPath)));
                    }
                    else if(request.getParameter(ACTION_CREATE) != null) {
                        touch(path + newFileName);
                        response.sendRedirect(getPathReference(encodeValue(showedPath)));
                    } else {
                        wln("Не удалось создать файл!");
                        printA("Вернуться назад", getPathReference(encodeValue(showedPath)));
                    }

               }

               if (request.getParameter(ACTION_SAVE) != null) {
                    saveFile(path, request);
               }

               if (fileStatus.equals(ACTION_MKDIR)) {
                    String newDirName = getRequestParameter(request, PARAM_FILE);
                    if(mkdir(path + newDirName)) response.sendRedirect(getPathReference(encodeValue(showedPath)));
                    else {
                        wln("Ошибка в создании директории!");
                        printA("Вернуться назад", getPathReference(encodeValue(showedPath)));
                    };
               }

               if (fileStatus.equals(ACTION_DELETE_DIR)) {
                   if(request.getParameter("yes_delete") != null) {
                       wln(showedPath);
                       rmdir(path);
                       response.sendRedirect(getPathReference(encodeValue(goUpside(showedPath))));
                   } else if(request.getParameter("no_delete") != null) {
                       response.sendRedirect(getPathReference(encodeValue(showedPath)));
                   } else {
                       acceptDeleteFile("директорию", ACTION_DELETE_DIR);
                   }
               }

               if (fileStatus.equals(ACTION_DELETE)) {
                   //SIC!
                   if(request.getParameter("yes_delete") != null) {
                       wln(showedPath);
                       rm(path);
                       response.sendRedirect(getPathReference(encodeValue(goUpside(showedPath))));
                   } else if(request.getParameter("no_delete") != null) {
                       response.sendRedirect(getFileReference(encodeValue(showedPath), ACTION_VIEW));
                       response.sendRedirect(getPathReference(encodeValue(goUpside(showedPath))));
                   } else {
                       acceptDeleteFile("файл", ACTION_DELETE);
                   }
               }

               if(fileStatus.equals(ACTION_VIEW_AS_TEXT)) {
                    wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                    BufferedReader br = new BufferedReader(new FileReader(path));
                    String bufferString = "";
                    nLine();
                    while ((bufferString = br.readLine()) != null) {
                        bufferString = translate_tokens(bufferString, HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
                        wln(bufferString);
                        nLine();
                    }
                    br.close();
               }

               if(fileStatus.equals(ACTION_VIEW_AS_IMG)) {
                    wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                    printImage(path, 600, 480);
               }

               if(fileStatus.equals(ACTION_VIEW_AS_VIDEO)) {
                   wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                   printVideo(path, 600, 480);
               }

               if(fileStatus.equals(ACTION_VIEW_AS_TABLE)) {
                   wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                   printTable(path);
               }

               if(fileStatus.equals(ACTION_VIEW)) {
                   wln("<style> #left_block { } input { margin: 5px; } .col { max-width: max-content; } </style>");
                   startDiv("block", "left_block", "left");
                   startDiv("row");
                   startDiv("col");
                   printH("Документ: ", 5);
                   endDiv();
                   startDiv("col");
                   printHeadPath(request);
                   endDiv();
                   endDiv();
                   wln("");
                   wln("<button onclick='window.location.href=\"" + getPathReference(encodeValue(goUpside(showedPath))) + "\"'>Назад</button>");
                   printA("Скачать", "download?d=" + encodeValue(showedPath)); // SIC! maybe download can be framed in constant
                   printA("Редактировать", getFileReference(encodeValue(showedPath), ACTION_EDIT));
                   printA("Удалить", getFileReference(encodeValue(showedPath), ACTION_DELETE));
                   wln("Посмотреть как: ");
                   printA("Текст", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_TEXT));
                   printA("Картинку", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_IMG));
                   printA("Видео", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_VIDEO));
                   printA("Таблицу", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_TABLE));
                   nLine(); nLine(); printFileMeta(path);
                   nLine();

                   startForm("POST", getFileReference(encodeValue(showedPath), ACTION_RENAME));
                   wln("Переименовать файл: ");
                   printInput("text", "", PARAM_FILE, "Напишите имя файла", "");
                   printSubmit("Переименовать");
                   endForm();

                   startForm("POST", getFileReference(encodeValue(showedPath), ACTION_COPY));
                   wln("Скопировать файл (в конце и начале необходимо поставить слеши):");
                   printInput("hidden", "", PARAM_FILE, "", fileInfo.basename(showedPath));
                   printInput("text", "", PARAM_DIRECTORY, "Напишите папку", "");
                   printSubmit("Скопировать");
                   endForm();

                   if(!isVideo(path) && !isImage(path)) {
                       nLine();
                       FileReader fileReader = new FileReader(path);
                       BufferedReader bufferedReader = new BufferedReader(fileReader);
                       wln("Первые 100 строк файла:"); nLine();
                       String buff = "";
                       int numOfStrings = 0;
                       while(numOfStrings != 100 && (buff = bufferedReader.readLine()) != null) {
                           buff = translate_tokens(buff, HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
                           wln(buff); nLine();
                           numOfStrings++;
                       }
                   }
               }

               if(fileStatus.equals(ACTION_RENAME)) {
                   String newFileName = request.getParameter(PARAM_FILE);
                   rename(fileInfo.basename(showedPath), newFileName);
                   response.sendRedirect(getFileReference(goUpside(showedPath) + newFileName, ACTION_VIEW));
               }

               if(fileStatus.equals(ACTION_COPY)) {
                   String targetPath = request.getParameter(PARAM_DIRECTORY) + request.getParameter(PARAM_FILE);
                   String targetDir = currentDirectory.substring(0, currentDirectory.substring(showedPath.length()).length());
                   cp(currentDirectory, targetDir + targetPath);
                   response.sendRedirect(getFileReference(showedPath, ACTION_VIEW));
               }

               if(fileStatus.equals(ACTION_EDIT)) {
                   StringBuilder sb = new StringBuilder();
                   String fileBuffer = "";

                   wln("<style>  #left_block { } input { margin: 5px; }</style>");
                   startDiv("block", "left_block", "left");
                   startDiv("row");
                   startDiv("col");
                   printH("Документ: " + showedPath, 5);
                   endDiv();
                   endDiv();
                   wln("");
                   wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                   if(isViewActions(request)) {  // viewFileAsSomething(request, response, path);
                   } else if(printImageFile(unixSlash + fileInfo.basename(path)) || printVideoFile(unixSlash + fileInfo.basename(path))) {
                       printFormForAnyFile(showedPath, fileStatus);
                   } else {
                       try {
                           FileReader fileReader = new FileReader(path);
                           BufferedReader bufferedReader = new BufferedReader(fileReader);
                           String readString;
                           while ((readString = bufferedReader.readLine()) != null) {
                               sb.append(readString).append("\n");
                           }
                           fileReader.close();
                           bufferedReader.close();
                       } catch (Exception ex) {
                           wln("Cant read file");
                       }
                       printFileForm(showedPath, fileStatus, sb.toString());
                   }
               }
               wln("</div>");
               return;
            }
        } catch (Exception ex) {
            w(ex + ": error occured.");
        }
    }

    // File DELETING (ACCEPT) (could be as file and directory as well)
    private void acceptDeleteFile(String deleteWhat, String ACTION) {
        wln("Точно хотите удалить " + deleteWhat + "?");
        if(ACTION.equals(ACTION_DELETE))
            startForm("POST", getFileReference(showedPath, ACTION_DELETE));
        else if(ACTION.equals(ACTION_DELETE_DIR))
            startForm("POST", getFileReference(showedPath, ACTION_DELETE_DIR));
        else
            return;
        wln("<input type='submit' name='yes_delete' value='Да'/>");
        wln("<input type='submit' name='no_delete' value='Нет'/>");
        endForm();
    }

    private void printFileMeta(String file) {
        File showingFile = new File(file);
        // SIC! All metadata goes here
        startDiv("");
        wln("Размер: " + showingFile.length() + " байт."); nLine();
        // Права: (чтение, запись)
        wln("Права на: " + (showingFile.canRead() ? " чтение" : "") + (showingFile.canWrite() ? " запись" : ""));
        boolean isFileType = false;
        for(int i = 0; i < IMAGE_DEFINITIONS.length; i++) {

        }
        // Тип документа: метод по которому угадываю что это
        //  Категории: 1. текст 2. вики текст 3. хтмл (это все текст - показывать по разному
        // 4. картинка 5 видео 6. бинарный файл 7. csv-файл 8. tcsv
        endDiv();

    }

    private boolean isViewActions(HttpServletRequest request) {
        if(request.getParameter(ACTION_VIEW_AS_IMG) == null &&
                request.getParameter(ACTION_VIEW_AS_TEXT) == null &&
                request.getParameter(ACTION_VIEW_AS_VIDEO) == null &&
                request.getParameter(ACTION_VIEW_AS_TABLE) == null)
            return false;
        else
            return true;
    }

    private boolean isImage(String path) {
        for(int i = 0; i < IMAGE_DEFINITIONS.length; i++)
            if (path.toLowerCase().endsWith(IMAGE_DEFINITIONS[i])) return true;
        return false;
    }

    private boolean isVideo(String path) {
        for(int i = 0; i < VIDEO_DEFINITIONS.length; i++)
            if (path.toLowerCase().endsWith(VIDEO_DEFINITIONS[i])) return true;
        return false;
    }

    private boolean printImageFile(String path)  {
        if (isImage(path)) {
            printImage(path, 680, 400);
            return true;
        } else {
            return false;
        }
    }

    private boolean printVideoFile(String path)  {
        if(isVideo(path)) {
            printVideo(path, 680, 400);
            return true;
        } else {
            return false;
        }
    }

    private void printVideo(String path, int width, int height)  {
        wln("<video width='" + width + "' height='" + height + "' controls='controls'>" +
                "<source src='download?" + PARAM_D + "=" + encodeValue(showedPath) + "' type='video/ogg'>" +
                "<source src='download?" + PARAM_D + "=" + encodeValue(showedPath) + "' type='video/webm'>" +
                "<source src='download?" + PARAM_D + "=" + encodeValue(showedPath) + "' type='video/mp4'> " +
                "Your browser does not support the video tag. </video>");
    }

    private void printImage(String path, int width, int height)  {
        wln("<style> " +
                " img { object-fit: contain; }"
        + "</style>"); //SIC! For normal image without stretching
        wln("<img src='download?" + PARAM_D + "=" + encodeValue(showedPath)  + "' alt='sample' height='"+height+"' width='"+width+"'>");
    }

    private void printTable(String path) {
        try {
            BufferedReader br = new BufferedReader(new FileReader(path));
            String singleLine = "";
            String dilimiter = ";";
            String[] cells;
            wln("<br/>");
            startTable("table table-borderedce ");
            startTBody("");
            while ((singleLine = br.readLine()) != null) {
                cells = singleLine.split(dilimiter);
                startTr();
                for (int i = 0; i < cells.length; i++) {
                    startTd("");
                    cells[i] = translate_tokens(cells[i], HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
                    wln(cells[i]);
                    endTd();
                }
                endTr();
            }
            endTBody();
            endTable();
        }catch(IOException ex) {
            wln("Не удалось показать таблицу.");
        }
    }

    private void saveFile(String path, HttpServletRequest request) throws IOException, IllegalAccessException {
        BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter
                (new FileOutputStream(path, false), StandardCharsets.UTF_8));
        wln("Saved");
        String fileText = request.getParameter(FILE_TEXTAREA_NAME);
        bufferedWriter.write(fileText);
        bufferedWriter.flush();
        bufferedWriter.close();
    }

    private void createFile(String pathParam,  HttpServletResponse response) throws IOException {
        File newFile = new File(pathParam);
        if(!newFile.exists())
            newFile.createNewFile();
        response.sendRedirect(getPathReference(encodeValue(currentDirectory)));
    }

    private void printFileEditButtons() {
        wln("<input type=\"submit\" name=\""+ACTION_SAVE+"\" value=\"Сохранить\"/>&nbsp;");
        wln("<input type=\"submit\" name=\""+ACTION_DELETE+"\" value=\"Удалить\"/>&nbsp;");
        wln("<input type=\"submit\" name=\""+ACTION_UPDATE+"\" value=\"Обновить\"/>&nbsp;");
    }

    private void w(String s) {
        boolean is_error = false;
        try { out.print(s); }
        catch (Exception e) { is_error = true; }
    }
    private void wln(String s){ w(s);w("\n");}
    private void wln(){w("\n");}
    private void setReference(String reference, String insides) { wln("<a href=\""+reference+"\">"); wln(insides); wln("</a>"); }

    private void printTableHead(HttpServletRequest request) {
        startDiv("row");
        startDiv("col");
        printH("Содержание директории: ", 5);

        if(!showedPath.equals(unixSlash)) {
            startForm("POST", getFileReference(showedPath, ACTION_DELETE_DIR));
            printSubmit("Удалить директорию");
            endForm();
        }
        endDiv();
        startDiv("col");
        printHeadPath(request);
        startForm("POST", CGI_NAME + "?" + PARAM_D + "=" + encodeValue(showedPath) + "&" + PARAM_ACTION + "=" + ACTION_CREATE);
        printInput("text", "dropdown-item", PARAM_FILE, "Введите имя", false);
        wln("<input type=\"submit\" name=\""+ACTION_CREATE+"\" value=\"Создать файл\"/>&nbsp;");
        wln("<input type=\"submit\" name=\""+ACTION_MKDIR+"\" value=\"Создать директорию\"/>&nbsp;");
        endForm();
        endDiv();
        printServerButton();
        endDiv();
        startTable("table");
        startTHead("thead-light");
        startTr();
        printTh("col", "Имя");
        printTh("col", "Размер, байт");
        printTh("col", "Права");
        printTh("col", "Последняя модификация");
        endTr();
        endTHead();
    }

    private void printHeadPath(HttpServletRequest request) {
        List<String> allKeys = new ArrayList<>(references.keySet());
        Collections.reverse(allKeys);
        Boolean is_view = getRequestParameter(request, PARAM_ACTION, null) != null;
        int size = allKeys.size();
        if(is_view) size--;
        for(int i = 0; i < size; i++) {
            printA("/" + references.get(allKeys.get(i)), allKeys.get(i));
        }
    }

    private void printFooter() {
        wln("<footer>");
        wln("<hr/>");
        wln("Version: " + VERSION);
        wln("</footer>");
    }

    private void printInput(String type, String classN, String name, String placeholder, boolean multiple)  {
        if(multiple) wln("<input type='" + type + "' class='" + classN + "' name='" + name + "' placeholder='" + placeholder +"' multiple/>");
        else wln("<input type='" + type + "' class='" + classN + "' name='" + name + "' placeholder='" + placeholder +"'/>");
    }
    private void printInput(String type, String classN, String name, String placeholder, String value)  {
        wln("<input type='" + type + "' class='" + classN + "' name='" + name + "' value='" + value + "' placeholder='" + placeholder +"'/>");
    }
    private void printSubmit(String text)  { wln("<input type='submit' value='" + text + "'/>");}
    private void printSubmit(String text, String classN)  { wln("<input type='submit' class='"+classN+"' value='" + text + "'/>");}
    private void startDiv(String classN)  { wln("<div class='" + classN + "'>"); }
    private void startDiv(String classN, String id) { wln("<div class='" + classN + "' id='"+id+"'>"); }
    private void startDiv(String classN, String id, String align)  { wln("<div class='" + classN + "' id='"+id+"' align='" + align + "'>"); }
    private void startDiv(String classN, String id, String align, String aria_labelledby) { wln("<div class='" + classN + "' id='"+id+"' align='" + align + "' aria-labelledby='" + aria_labelledby + "'>"); }
    private void endDiv()  { wln("</div>"); }

    private void startTable(String classN)  { wln("<table class='" + classN + "'>"); }
    private void endTable()  { wln("</table>"); }
    private void startTHead(String classN)  { wln("<thead class='" + classN + "'>"); }
    private void endTHead()  { wln("</thead>"); }
    private void startTBody(String classN)  { wln("<tbody class='" + classN + "'>"); }
    private void endTBody()  { wln("</tbody>"); }
    private void startTr()  { wln("<tr>");}
    private void endTr()  { wln("</tr>");}
    private void printTh(String scope, String text)  { wln("<th scope='"+scope+"'>" + text + "</th>");}
    private void startTd(String classN)  { wln("<td class='"+classN+"'>");}
    private void startTd(String classN, String scope)  { wln("<td class='"+classN+"' scope='" + scope + "'>");}
    private void endTd()  { wln("</td>");}
    private void printTd(String scope, String classN, String align, String text) { wln("<td align='" + align + "' class='" + classN + "' scope='"+scope+"'>" + text + "</td>");}

    private void printI(String text, String classN) { wln("<i class='" + classN + "'>" + text + "</i>"); }
    private void printA(String text, String href) { wln("<a href='" + href + "'>" + text + "</a>"); }
    private String getA(String text, String href) { return String.format("<a href='" + href + "'>" + text + "</a>"); }
    private String getI(String text, String classN)  { return String.format("<i class='" + classN + "'>" + text + "</i>"); }
    private void printH(String text, int size)  { wln("<h" + size + ">" + text + "</h" + size + ">"); }
    private void printH(String text, String classN, int size) { wln("<h" + size + " class='"+classN+"'>" + text + "</h" + size + ">"); }

    private void printButton(String classN, String type, String id, String data_toggle, String aria_haspopup, String aria_expanded, String text)  {
        wln("<button class='"+classN+"' type='" + type + "' id='" + id + "' data-toggle='" + data_toggle + "' aria-haspopup='" + aria_haspopup + "' aria-expanded='"+aria_expanded+ "'>" + text + "</button>");
    }

    // Textarea fow file inners
    private void printFileForm(String path, String cmd, String fileText)  {
        startForm("POST", getFileReference(encodeValue(path), cmd));
        printText(FILE_TEXTAREA_NAME, 72, 10, fileText); nLine();
        printFileEditButtons();
        endForm();
    }

    private void printFormForAnyFile(String path, String cmd) {
        startForm("POST", getFileReference(encodeValue(path), cmd));
        printFileEditButtons();
        endForm();
    }

    private void startForm(String method, String action)  { wln("<form method='" + method +"' action='"+action + "'>"); }
    private void startForm(String method, String action, String enctype)  { wln("<form method='" + method +"' action='"+action + "' enctype='"+enctype+"'>"); }
    private void endForm() { wln("</form>");  }
    private void printText(String name, int cols, int rows, String innerText) {
        wln("<style> textarea { resize: both; } </style>");
        innerText = translate_tokens(innerText, HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
            w("<textarea name='" + name + "' cols=" + cols + " rows=" + rows + ">");
                if(innerText != null)
                    w(innerText);
            wln("</textarea>");
    }
    private void nLine() { wln("<br/>"); }
    }
%>
<% // этот блок инициализирующего кода выполняется уже в процессе обработки запроса, но в самом начале. я перенес его _до_ тела html документа
    Main main = new Main();
    main.out = out;
    long enter_time = System.currentTimeMillis();
    main.initUser(request);
    request.setCharacterEncoding("UTF-8");
    main.log = new LogProvider(this.getServletContext().getInitParameter("logFilePath"));

    boolean is_forwarded = false;
    main.CGI_NAME = "index2.jsp";
    try { is_forwarded = (boolean) request.getAttribute("FORWARD_REQUEST"); }
    catch (Exception ex) { is_forwarded = false; main.CGI_NAME = "index1.jsp"; }

    if(!is_forwarded) {
    //-------------------------INIT SECTION ENDED------------------------//
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
    <% } %>
    <div class="container" id="main_block">
        <%
            main. process(request, response);
        %>
    </div>
    <% if(!is_forwarded) { %>
<script src="contrib/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="contrib/nmp/popper.js-1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="contrib/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</body>
</html>
<%
    }
%>
