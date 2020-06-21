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
<%!
    // Page info
    private final static String CGI_NAME = "index1.jsp"; // Page domain name
    private final static String CGI_TITLE = "CMS system"; // Upper page info
    private final static String JSP_VERSION = "$id$"; // Id for jsp version
    private static LogProvider log;
    private JspWriter out;

    public static String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
    public static String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","\n"};
    public final static String[] VALUE_CHARACTERS = { "<",">","&","\"","'" };
    public final static String[] VALUE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","&quot;","&#039;"};

    // Files and directories manipulating
    // Destination param (test)
    private final static String PARAM_D = "d";
    private final static String PARAM_ACTION = "cmd";
    private final static String PARAM_FILE = "file";
    private final static String PARAM_DIRECTORY = "directory";
    private final static String FILE_TEXTAREA_NAME = "file_text";


    // File manipulating (view, save, update, delete)
    private final static String ACTION_VIEW = "view";
    private final static String ACTION_SAVE = "save";
    private final static String ACTION_UPDATE = "update";
    private final static String ACTION_DELETE = "delete";
    private final static String ACTION_CREATE = "create";
    private final static String ACTION_COPY = "cp";
    private final static String ACTION_MKDIR = "mkdir";
    private final static String ACTION_DELETE_DIR = "rmdir";
    private final static String ACTION_RENAME = "rename";

    private final static String ACTION_EDIT = "edit";
    private final static String ACTION_VIEW_AS_IMG = "image_view";
    private final static String ACTION_VIEW_AS_VIDEO = "video_view";
    private final static String ACTION_VIEW_AS_TEXT = "text_view";

    private final static int MAX_FILE_READ_SIZE = 10_000_000;

    private final static String [] IMAGE_DEFINITIONS = { "jpg", "jpeg", "png", "svg", "tiff", "bmp", "bat", "odg", "xps" };
    private final static String [] VIDEO_DEFINITIONS = { "ogg", "mp4", "webm" };
    // File differences class
    private final diff_match_patch diffMatchPatch = new diff_match_patch();

    // User info
    private String userIP;
    private String HOME_DIRECTORY;
    private String currentDirectory = HOME_DIRECTORY;
    private String showedPath;

    Map<String, String> references;

    private final static String unixSlash = "/";

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

    public static String translate_tokens(String sz, String[] from, String[] to)
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

    private boolean isExecutable(String path) {
        Path pathToFile = Paths.get(path);
        return Files.isExecutable(pathToFile);
    }

    private boolean isDir(String path) {
        Path pathToFile = Paths.get(path);
        return Files.isDirectory(pathToFile);
    }

    private boolean checkShellInjection(String param){ return param.contains(".."); }

    private String getRequestParameter(ServletRequest request, String param)  {
        return getRequestParameter(request, param, null);
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
        if(isDir(currentDirectory + fileName)) {
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
        else return directory.mkdir();
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
        File file = new File(fileName);
        try { return file.createNewFile(); } catch (IOException ex) { return false; }
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

    private void process(HttpServletRequest req, HttpServletResponse resp) {
        String dParameter = getRequestParameter(req, PARAM_D, showedPath);
        String fileParameter = basename(dParameter);
        String fileStatus = getRequestParameter(req, PARAM_ACTION);
        currentDirectory = dParameter;

        references = new LinkedHashMap<>();
        String referenceForSpecialPath = currentDirectory.substring(HOME_DIRECTORY.length());
        while(!referenceForSpecialPath.equals(unixSlash)) {
            references.put(getPathReference(referenceForSpecialPath), basename(referenceForSpecialPath));
            referenceForSpecialPath = goUpside(referenceForSpecialPath);
        }
        references.put(getPathReference(unixSlash), "root");

        boolean isFileAction = fileStatus != null;
        if (isFileAction) {
            processFileRequest(dParameter, fileStatus, req, resp);
        } else {
            printMainBlock();
        }
    }

    private void printMainBlock() {
        File actual = null;
        try {
            if(!showedPath.endsWith(unixSlash))
                showedPath = showedPath + unixSlash;
            actual = new File(currentDirectory);

            printTableHead();
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
        wln("<style> a {padding: 5px 7px; cursor: pointer; transition: .3s; color: #000; border-radius: 80px;" +
                "background-color: lightgray; text-align: center; border-style: none; font-weight: 400; box-shadow: inset -7px -4px 7px 0px darkgrey, 5px 5px 10px;} </style>");
        try {
            if (path != null && fileStatus != null) {
                StringBuilder sb = new StringBuilder();
                String fileBuffer = "";

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

               if(fileStatus.equals(ACTION_VIEW)) {
                   wln("<style> #left_block { } input { margin: 5px; }</style>");
                   startDiv("block", "left_block", "left");
                   startDiv("row");
                   startDiv("col");
                   printH("Документ: " + showedPath, 5);
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
                   nLine(); nLine(); printFileMeta(path);
                   nLine();

                   startForm("POST", getFileReference(encodeValue(showedPath), ACTION_RENAME));
                   wln("Переименовать файл: ");
                   printInput("text", "", PARAM_FILE, "Напишите имя файла", "");
                   printSubmit("Переименовать");
                   endForm();

                   startForm("POST", getFileReference(encodeValue(showedPath), ACTION_COPY));
                   wln("Скопировать файл (в конце и начале необходимо поставить слеши):");
                   printInput("hidden", "", PARAM_FILE, "", basename(showedPath));
                   printInput("text", "", PARAM_DIRECTORY, "Напишите папку", "");
                   printSubmit("Скопировать");
                   endForm();
               }

               if(fileStatus.equals(ACTION_RENAME)) {
                   String newFileName = request.getParameter(PARAM_FILE);
                   rename(basename(showedPath), newFileName);
                   response.sendRedirect(getFileReference(goUpside(showedPath) + newFileName, ACTION_VIEW));
               }

               if(fileStatus.equals(ACTION_COPY)) {
                   String targetPath = request.getParameter(PARAM_DIRECTORY) + request.getParameter(PARAM_FILE);
                   String targetDir = currentDirectory.substring(0, currentDirectory.substring(showedPath.length()).length());
                   cp(currentDirectory, targetDir + targetPath);
                   response.sendRedirect(getFileReference(showedPath, ACTION_VIEW));
               }

               if(fileStatus.equals(ACTION_EDIT)) {
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
                   } else if(printImageFile(unixSlash + basename(path)) || printVideoFile(unixSlash + basename(path))) {
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
            w(ex + "Error with opening file");
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
                request.getParameter(ACTION_VIEW_AS_VIDEO) == null)
            return false;
        else
            return true;
    }

    // View file as something (video, text, image)
    /*private void viewFileAsSomething(HttpServletRequest request, HttpServletResponse response, String path) {
        try {
            File f = new File(path);
            if (f.length() > MAX_FILE_READ_SIZE) //SIC! примерно так
                throw new IOException("Большой файл. Необходимо скачать для просмотра.");
            // View file as image
            if(request.getParameter(ACTION_VIEW_AS_IMG) != null) {
                printImage(path, 600, 480);
            }

            // View file as video
            if(request.getParameter(ACTION_VIEW_AS_VIDEO) != null) {
                printVideo(path, 600, 480);
            }
            // View file as text
            if(request.getParameter(ACTION_VIEW_AS_TEXT) != null) {
                FileReader reader = new FileReader(path);
                BufferedReader br = new BufferedReader(reader);
                StringBuilder builder = new StringBuilder();

                char[] symbols = new char[4096];
                while (br.read(symbols) != -1) {
                    builder.append(symbols, 0, symbols.length);
                }
                printText("", 100, 20, builder.toString());
                reader.close();
                br.close();
            }
        }catch (IOException ex) {
            wln(ex.getMessage());
        }
    }*/

    private boolean printImageFile(String path)  {
        for(int i = 0; i < IMAGE_DEFINITIONS.length; i++) {
            if (path.toLowerCase().endsWith(IMAGE_DEFINITIONS[i])) { printImage(path, 680, 400); return true;}
        }
        return false;
    }

    private boolean printVideoFile(String path)  {
        for(int i = 0; i < VIDEO_DEFINITIONS.length; i++) {
            if (path.toLowerCase().endsWith(VIDEO_DEFINITIONS[i])) { printVideo(path, 680, 400);  return true;}
        }
        return false;
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

    private void printTableHead() {
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
        List<String> allKeys = new ArrayList<>(references.keySet());
        Collections.reverse(allKeys);
        for(int i = 0; i < allKeys.size(); i++) {
            printA("/" + references.get(allKeys.get(i)), allKeys.get(i));
        }

        startForm("POST", "index1.jsp?" + PARAM_D + "=" + encodeValue(showedPath) + "&" + PARAM_ACTION + "=" + ACTION_CREATE);
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
%>
<% // этот блок инициализирующего кода выполняется уже в процессе обработки запроса, но в самом начале. я перенес его _до_ тела html документа
    this.out = out;
    long enter_time = System.currentTimeMillis();
    initUser(request);
    request.setCharacterEncoding("UTF-8");
    log = new LogProvider(this.getServletContext().getInitParameter("logFilePath"));
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
    <div class="container" id="main_block">
        <% process(request, response);

            //request.getRequestDispatcher("editqrpage.jsp").forward(request,response); // SIC! редирект
        %>
    </div>

<!--div id="issues" >
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
<li> 09. IOException от wln() - не надо гонять по всему стеку, его надо поймать и проигнорировать в самом низу, метод wln() есть у нас для этого
<li> 10. при загрузке файлов получаю NullPointer Exception, но файлы грузятся... кто-то где-то накосячил
<li> 11. загрузил я видеоролик, большой, 500 Mb, и решил его просмотреть, и посмотрел я на тот, как на сервере кончилась оперативная память, и понял я, что кто-то не понял, что память конечна и, видимо просто грузит весь файл в память, прежде чем отдать его клиенту, и опечалился я, и кончились у меня силы, и выпил я с горя водки, и пошел я спать... ;)
<li> 12. ...но вернулся я, чтобы дописать - строка 495 - зло, 513 - зло, 515 - зло, 523, 525 - зло. Не надо злоупотреблять if-ми вообще, а внутри jsp или php, где вперемешку html и серверная императивная логика - особенно. 
<li> 13. и самое главное, весь код от строки 484, до строки 540 должен превратиться в вызов всего одного метода warh.process(), пример можно посмотреть здесь <a href='https://bitbucket.org/eustrop/conceptis/src/default/src/java/webapps/tisc/tiscui.jsp'>ConcepTIS/src/java/webapps/tisc/tiscui.jsp</a> строки 119-121, также см строки 43-50, а потом здесь : <a href='https://bitbucket.org/eustrop/conceptis/src/default/src/java/webapps/tisc/tisc.jsp'>ConcepTIS/src/default/src/java/webapps/tisc/tisc.jsp</a>. Все порождение html кода содержательной части документа, зависящей от параметров запроса мы переносим в методы, которые затем перенесем в отдельные классы. В JSP остается только обрамляющая часть HTML-кода, общая для любой страницы, все остальное "рисуется" либо java на сервере, либо JavaScript в браузере. Но для прототипирования и отладки внешнего вида мы иногда пишем так, как написано сейчас, главное - вовремя остановиться. И здесь силы меня оставили совсем 13 мая 2020 г 1:53 мин.
</ul>
</div-->
<script src="contrib/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="contrib/nmp/popper.js-1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="contrib/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</body>
</html>
