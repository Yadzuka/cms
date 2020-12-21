package org.eustrosoft.cms;

import javax.servlet.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspWriter;
import java.io.*;
import java.text.SimpleDateFormat;
import org.eustrosoft.providers.LogProvider;
import org.eustrosoft.tools.AWKTranslator;
import org.eustrosoft.htmlmenu.Menu;
import name.fraser.neil.plaintext.diff_match_patch;

import java.nio.charset.StandardCharsets;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;
import java.util.*;
import java.nio.file.*;
import java.nio.file.attribute.PosixFilePermission;

public class Main {
    public String CGI_NAME = "index1.jsp"; // Page domain name
    private String VERSION = "0.2.3";
    private final String CGI_TITLE = "CMS system"; // Upper page info
    private final String JSP_VERSION = "$id$"; // Id for jsp version
    public JspWriter out;
    public LogProvider log;

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
    private final String PARAM_LANG = "lang";
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
    private final String ACTION_RENAME_DIR = "renamedir";
    private final String ACTION_SEE_HISTORY = "seehistory";

    private final String ACTION_EDIT = "edit";
    private final String ACTION_VIEW_AS_IMG = "image_view";
    private final String ACTION_VIEW_AS_VIDEO = "video_view";
    private final String ACTION_VIEW_AS_TEXT = "text_view";
    private final String ACTION_VIEW_AS_TABLE = "table_view";
    private final String ACTION_VIEW_AS_WIKI = "wiki_view";

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
    public String showedPath;
    private final String unixSlash = "/";

    Map<String, String> references;
    Menu upsideMenu;


    private void printUpsideMenu(HttpServletRequest request) {
        upsideMenu = new Menu(this.out);
        upsideMenu.CGI_NAME = this.CGI_NAME;
        String lang = getRequestParameter(request, PARAM_LANG, "ru");
        String d = getRequestParameter(request, PARAM_D, unixSlash).substring(HOME_DIRECTORY.length());
        upsideMenu.printMenu(lang, d);
    }

    public void initUser(HttpServletRequest request) {
        HTMLElements html = new HTMLElements();
        userIP = request.getRemoteAddr();
        HOME_DIRECTORY = request.getServletContext().getInitParameter("root") + request.getServletContext().getInitParameter("user");
        showedPath = "/";
        currentDirectory = HOME_DIRECTORY;
        try {
            if (!Files.exists(Paths.get(HOME_DIRECTORY))) {
                File newDir = new File(HOME_DIRECTORY);
                newDir.mkdir();
            }
        } catch (Exception ex) {
            try {
                html.wln("Can't create directory!");
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

    public class FileInfo {
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

        private boolean isImage(String path) {
            for(int i = 0; i < IMAGE_DEFINITIONS.length; i++)
                if (path.toLowerCase().endsWith(IMAGE_DEFINITIONS[i]))
                    return true;
            return false;
        }
        private boolean isVideo(String path) {
            for(int i = 0; i < VIDEO_DEFINITIONS.length; i++)
                if (path.toLowerCase().endsWith(VIDEO_DEFINITIONS[i]))
                    return true;
            return false;
        }

        private boolean isDir(String path) {
            Path pathToFile = Paths.get(path);
            return Files.isDirectory(pathToFile);
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

    // Path reference with 'a' tags
    private String getPathReference(String path, String value) {
        return "<a href='" + CGI_NAME + "?" + PARAM_D +"="+ path + "'>" + value + "</a>";
    }
    // Path reference
    private String getPathReference(String path) {
        return CGI_NAME + "?" + PARAM_D +"="+ path;
    }
    // File reference with action
    private String getFileReference(String path, String cmd) {
        return CGI_NAME + "?" + PARAM_D + "=" + path + "&" + PARAM_ACTION + "=" + cmd;
    }

    public class FileOperations {
        private String goToFile(String showedPath, String fileName) {
            FileInfo fileInfo = new FileInfo();
            if(fileInfo.isDir(currentDirectory + fileName)) {
                String targetPath = encodeValue(showedPath + fileName + unixSlash);
                return getPathReference(targetPath, fileName);
            }
            return openFile(fileName);
        }

        private String openFile(String value){ return value; }


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

        private boolean renamedir(String newDirName) {
            File file = new File(currentDirectory);
            File dest = new File(goUpside(currentDirectory) + newDirName);
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
            FileInfo info = new FileInfo();
            File directory = new File(path);
            if(directory.listFiles().length == 0
                    && !info.basename(path).equals(".cms"))
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

        private void reserveVersion(String path) throws IllegalAccessException {
            FileInfo fileInfo = new FileInfo();
            fileInfo.checkAccess(path);
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
            } catch (IOException ex) { }
        }
        private void saveFile(String path, HttpServletRequest request) throws IOException {
            HTMLElements html = new HTMLElements();
            BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter
                    (new FileOutputStream(path, false), StandardCharsets.UTF_8));
            html.wln("Saved");
            String fileText = request.getParameter(FILE_TEXTAREA_NAME);
            bufferedWriter.write(fileText);
            bufferedWriter.flush();
            bufferedWriter.close();

            FileInfo fi = new FileInfo();
            FilesHistory fh = new FilesHistory();
            fh.setup(fi.dirname(path));
            fh.makeDirForAllFiles(fi.dirname(path));
            fh.backupFile(path);
            fh.saveFileState(path);
        }
    }

    public WARHCMS getWARHCMSInstance() {
        return new WARHCMS();
    }
    public class WARHCMS {
        public void process(HttpServletRequest req, HttpServletResponse resp) {
            upsideMenu = new Menu(out);

            FileInfo fileInfo = new FileInfo(); FileOperations fileOperations = new FileOperations();
            String dParameter = getRequestParameter(req, PARAM_D, showedPath);
            String fileParameter = fileInfo.basename(dParameter);
            String fileStatus = getRequestParameter(req, PARAM_ACTION);
            currentDirectory = dParameter;

            references = new LinkedHashMap<>();
            String referenceForSpecialPath = currentDirectory.substring(HOME_DIRECTORY.length());
            while(!referenceForSpecialPath.equals(unixSlash)) {
                references.put(getPathReference(referenceForSpecialPath), fileInfo.basename(referenceForSpecialPath));
                referenceForSpecialPath = fileOperations.goUpside(referenceForSpecialPath);
            }
            references.put(getPathReference(unixSlash), "root");

            boolean isFileAction = fileStatus != null;
            if (isFileAction) {
                processFileRequest(dParameter, fileStatus, req, resp);
            } else {
                printUpsideMenu(req);
                printMainBlock(req);
            }
            printFooter();
        }

        private void printMainBlock(HttpServletRequest request) {
            File actual = null; FileOperations fileOperations = new FileOperations();
            HTMLElements html = new HTMLElements();
            try {
                if(!showedPath.endsWith(unixSlash))
                    showedPath = showedPath + unixSlash;
                actual = new File(currentDirectory);

                printTableHead(request);
                html.startTBody("");
                if (!currentDirectory.equals(HOME_DIRECTORY + "/")) {
                    html.startTr();
                    html.printTd("row", "viewer", "", html.getA(html.getI(".&nbsp;.&nbsp;.", "icon-share"), getPathReference(fileOperations.goUpside(showedPath))));
                    html.endTr();
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
                html.wln("Нераспознанная ошибка: " + e);
                html.wln("попробуйте другую операцию" );
            }
            finally{ }
            html.endTBody();
            html.endTable();
        }

        private void printServerButton()  {
            HTMLElements html = new HTMLElements();
            html.startDiv("col", "", "right");
            html.startDiv("dropright");
            html.printButton("btn btn-light btn-lg dropdown-toggle", "button", "dropdownMenuButton", "dropdown", "true", "false", html.getI("   Сервер", "icon-folder-open") );
            html.startDiv("dropdown-menu", "", "", "dropdownMenuButton");
            html.printH("Обращение к серверу", "dropdown-header", 5);
            html.startDiv("dropdown-divider"); html.endDiv();

            html.startForm("POST", "upload", "multipart/form-data");
            html.printInput("hidden", "", PARAM_D , "", showedPath);
            html.printInput(PARAM_FILE, "dropdown-item", PARAM_FILE, "", true);
            html.printSubmit("Загрузить", "dropdown-item");
            html.endForm();

            html.startDiv("dropdown-divider"); html.endDiv();
            html.endDiv();
            html.endDiv();
            html.endDiv();
        }

        private void printFileInTable(File f) {
            FileOperations fileOperations = new FileOperations(); HTMLElements html = new HTMLElements();
            String ico = "";
            String readwrite = "";
            if (f.isDirectory() & !f.isFile()) {
                ico = html.getI("", "icon-folder");
            } else if (!f.isDirectory() & f.isFile()) {
                ico = html.getI("", "icon-file-text2");
            } else ico = "<i class=\"icon-link\" ></i>";
            if (f.canWrite() & f.canRead()) {
                readwrite = "чтение/запись";
            } else if (!f.canWrite() & f.canRead()) {
                readwrite = "чтение";
            } else {
                readwrite = " ";
            }
            html.startTr();
            html.startTd("viewer", "row");
            if(f.isFile()&f.canRead()) {
                html.printA(ico+" "+f.getName(), getFileReference(encodeValue(showedPath + f.getName()) , ACTION_VIEW));
            } else {
                html.wln(ico + " " + fileOperations.goToFile(showedPath, f.getName()));
            }
            html.endTd();
            html.printTd("row", "", "right", String.format("%d",f.length()));
            html.printTd("row", "", "", readwrite);
            html.printTd("row", "", "center", new SimpleDateFormat("dd.MM.yy HH:mm").format(f.lastModified()));
            html.endTr();
        }

        // path here means FULL/real path - be careful with this | showedPath path, in turn, means showed path and it could be use for showing for the client
        private void processFileRequest(String path, String fileStatus, HttpServletRequest request, HttpServletResponse response) {
            HTMLElements html = new HTMLElements();
            try {
                if (path != null && fileStatus != null) {

                    //*************************************************
                    //  Function to view user rights to create/read/delete and other
                    //  checkUserRights(HttpServletRequest request, String userLogin|ip)
                    //*************************************************

                    FileInfo fileInfo = new FileInfo(); FileOperations fileOperations = new FileOperations();
                    if (fileStatus.equals(ACTION_CREATE)) {
                        String newFileName = getRequestParameter(request, PARAM_FILE);

                        if(request.getParameter(ACTION_MKDIR) != null) {
                            String newDirName = path + newFileName;
                            fileOperations.mkdir(newDirName);
                            try {
                                FilesHistory history0 = new FilesHistory();
                                history0.setup(path);
                                history0.saveFileState(newDirName);
                                history0.makeDirForAllFiles(path);
                                FilesHistory history1 = new FilesHistory();
                                history1.setup(newDirName);
                            }
                            catch (IOException ex ) { html.w(ex.getMessage()); }
                            finally { response.sendRedirect(getPathReference(encodeValue(showedPath))); }
                        }
                        else if(request.getParameter(ACTION_CREATE) != null) {
                            fileOperations.touch(path + newFileName);
                            response.sendRedirect(getPathReference(encodeValue(showedPath)));
                        } else if(request.getParameter(ACTION_RENAME_DIR) != null) {
                            html.wln("I'm in the rmdir section (request)");
                            fileOperations.renamedir(newFileName);
                            response.sendRedirect(getPathReference(encodeValue(fileOperations.goUpside(showedPath) + newFileName + unixSlash)));
                        } else {
                            html.wln("Не удалось создать файл!");
                            html.printA("Вернуться назад", getPathReference(encodeValue(showedPath)));
                        }

                    }

                    if (request.getParameter(ACTION_SAVE) != null) {
                        fileOperations.saveFile(path, request);
                    }

                    if (fileStatus.equals(ACTION_DELETE_DIR)) {
                        if(request.getParameter("yes_delete") != null) {
                            fileOperations.rmdir(path);
                            response.sendRedirect(getPathReference(encodeValue(fileOperations.goUpside(showedPath))));
                        } else if(request.getParameter("no_delete") != null) {
                            response.sendRedirect(getPathReference(encodeValue(showedPath)));
                        } else {
                            acceptDeleteFile("директорию", ACTION_DELETE_DIR);
                        }
                    }

                    if (fileStatus.equals(ACTION_DELETE)) {
                        //SIC!
                        if(request.getParameter("yes_delete") != null) {
                            fileOperations.rm(path);
                            response.sendRedirect(getPathReference(encodeValue(fileOperations.goUpside(showedPath))));
                        } else if(request.getParameter("no_delete") != null) {
                            response.sendRedirect(getFileReference(encodeValue(showedPath), ACTION_VIEW));
                            response.sendRedirect(getPathReference(encodeValue(fileOperations.goUpside(showedPath))));
                        } else {
                            acceptDeleteFile("файл", ACTION_DELETE);
                        }
                    }

                    if(fileStatus.equals(ACTION_VIEW_AS_TEXT)) {
                        html.wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                        BufferedReader bufferedReader = new BufferedReader(
                                new InputStreamReader(
                                        new FileInputStream(path), StandardCharsets.UTF_8));
                        String bufferString = "";
                        html.nLine();
                        while ((bufferString = bufferedReader.readLine()) != null) {
                            bufferString = translate_tokens(bufferString, HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
                            html.wln(bufferString);
                            html.nLine();
                        }
                        bufferedReader.close();
                    }

                    if(fileStatus.equals(ACTION_VIEW_AS_IMG)) {
                        html.wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                        printImage(path, 600, 480);
                    }

                    if(fileStatus.equals(ACTION_VIEW_AS_VIDEO)) {
                        html.wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                        printVideo(path, 600, 480);
                    }

                    if(fileStatus.equals(ACTION_VIEW_AS_TABLE)) {
                        html.wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                        printTable(path);
                    }

                    if(fileStatus.equals(ACTION_VIEW_AS_WIKI)) {
                        html.wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                        printWiki(path);
                    }

                    if(fileStatus.equals(ACTION_VIEW)) {
                        printUpsideMenu(request);
                        html.wln("<style> #left_block { } input { margin: 5px; } .col { max-width: max-content; } </style>");
                        html.startDiv("block", "left_block", "left");
                        html.startDiv("row");
                        html.startDiv("col");
                        html.printH("Документ: ", 5);
                        html.endDiv();
                        html.startDiv("col");
                        printHeadPath(request);
                        html.endDiv();
                        html.endDiv();
                        html.wln("");
                        html.wln("<button onclick='window.location.href=\"" + getPathReference(encodeValue(fileOperations.goUpside(showedPath))) + "\"'>Назад</button>");
                        html.printA("Скачать", "download?d=" + encodeValue(showedPath)); // SIC! maybe download can be framed in constant
                        html.printA("Редактировать", getFileReference(encodeValue(showedPath), ACTION_EDIT));
                        html.printA("Посмотреть историю изменений", getFileReference(encodeValue(showedPath), ACTION_SEE_HISTORY));
                        html.printA("Удалить", getFileReference(encodeValue(showedPath), ACTION_DELETE));
                        html.wln("Посмотреть как: ");
                        html.printA("Текст", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_TEXT));
                        html.printA("Картинку", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_IMG));
                        html.printA("Видео", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_VIDEO));
                        html.printA("Таблицу", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_TABLE));
                        html.printA("Посмотреть в вики формате", getFileReference(encodeValue(showedPath), ACTION_VIEW_AS_WIKI));
                        html.nLine(); html.nLine(); printFileMeta(path);
                        html.nLine();

                        html.startForm("POST", getFileReference(encodeValue(showedPath), ACTION_RENAME));
                        html.wln("Переименовать файл: ");
                        html.printInput("text", "", PARAM_FILE, "Напишите имя файла", "");
                        html.printSubmit("Переименовать");
                        html.endForm();

                        html.startForm("POST", getFileReference(encodeValue(showedPath), ACTION_COPY));
                        html.wln("Скопировать файл (в конце и начале необходимо поставить слеши):");
                        html.printInput("hidden", "", PARAM_FILE, "", fileInfo.basename(showedPath));
                        html.printInput("text", "", PARAM_DIRECTORY, "Напишите папку", "");
                        html.printSubmit("Скопировать");
                        html.endForm();

                        if(!fileInfo.isVideo(path) && !fileInfo.isImage(path)) {
                            html.nLine();
                            BufferedReader bufferedReader = new BufferedReader(
                                    new InputStreamReader(
                                            new FileInputStream(path), StandardCharsets.UTF_8));
                            html.wln("Первые 100 строк файла:"); html.nLine();
                            String buff = "";
                            int numOfStrings = 0;
                            while(numOfStrings != 100 && (buff = bufferedReader.readLine()) != null) {
                                buff = translate_tokens(buff, HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
                                html.wln(buff); html.nLine();
                                numOfStrings++;
                            }
                            bufferedReader.close();
                        }
                    }

                    if(fileStatus.equals(ACTION_RENAME)) {
                        String newFileName = request.getParameter(PARAM_FILE);
                        fileOperations.rename(fileInfo.basename(showedPath), newFileName);
                        response.sendRedirect(getFileReference(fileOperations.goUpside(showedPath) + newFileName, ACTION_VIEW));
                    }

                    if(fileStatus.equals(ACTION_SEE_HISTORY)) {
                        HTMLElements el = new HTMLElements();
                        FileOperations fo = new FileOperations();
                        FileInfo fi = new FileInfo();
                        String historyPath = fo.goUpside(path) + ".cms" + unixSlash + fi.basename(path) + unixSlash;
                        try {
                            File[] allHistoryFiles = new File(historyPath).listFiles();
                            for (int i = 0; i < allHistoryFiles.length; i++) {
                                el.wln(fi.basename(allHistoryFiles[i].toString()));
                                el.wln("<br/>");
                            }
                        } catch (Exception ex) {
                            el.wln("Нет сохранённых файлов в истории.");
                        }
                    }

                    if(fileStatus.equals(ACTION_COPY)) {
                        String targetPath = request.getParameter(PARAM_DIRECTORY) + request.getParameter(PARAM_FILE);
                        String targetDir = currentDirectory.substring(0, currentDirectory.substring(showedPath.length()).length());
                        fileOperations.cp(currentDirectory, targetDir + targetPath);
                        response.sendRedirect(getFileReference(showedPath, ACTION_VIEW));
                    }

                    if(fileStatus.equals(ACTION_EDIT)) {
                        StringBuilder sb = new StringBuilder();
                        String fileBuffer = "";

                        html.wln("<style>  #left_block { } input { margin: 5px; }</style>");
                        html.startDiv("block", "left_block", "left");
                        html.startDiv("row");
                        html.startDiv("col");
                        html.printH("Документ: " + showedPath, 5);
                        html.endDiv();
                        html.endDiv();
                        html.wln("");
                        html.wln("<button onclick='window.location.href=\"" + getFileReference(encodeValue(showedPath), ACTION_VIEW) + "\"'>Назад</button>");
                        if(isViewActions(request)) {  // viewFileAsSomething(request, response, path);
                        } else if(printImageFile(unixSlash + fileInfo.basename(path)) || printVideoFile(unixSlash + fileInfo.basename(path))) {
                            printFormForAnyFile(showedPath, fileStatus);
                        } else {
                            BufferedReader bufferedReader = null;
                            try {
                                bufferedReader = new BufferedReader(
                                        new InputStreamReader(
                                                new FileInputStream(path), StandardCharsets.UTF_8));
                                String readString;
                                while ((readString = bufferedReader.readLine()) != null) {
                                    sb.append(readString).append("\n");
                                }
                            } catch (Exception ex) {
                                html.wln("Cant read file");
                            } finally {
                                try { bufferedReader.close(); } catch (Exception ex) { }
                            }
                            printFileForm(showedPath, fileStatus, sb.toString());
                        }
                    }
                    html.wln("</div>");
                    return;
                }
            } catch (Exception ex) {
                html.w(ex + ": error occured.");
            }
        }

        // File DELETING (ACCEPT) (could be as file and directory as well)
        private void acceptDeleteFile(String deleteWhat, String ACTION) {
            HTMLElements html = new HTMLElements();
            html.wln("Точно хотите удалить " + deleteWhat + "?");
            if(ACTION.equals(ACTION_DELETE))
                html.startForm("POST", getFileReference(showedPath, ACTION_DELETE));
            else if(ACTION.equals(ACTION_DELETE_DIR))
                html.startForm("POST", getFileReference(showedPath, ACTION_DELETE_DIR));
            else
                return;
            html.wln("<input type='submit' name='yes_delete' value='Да'/>");
            html.wln("<input type='submit' name='no_delete' value='Нет'/>");
            html.endForm();
        }

        private void printFileMeta(String file) {
            HTMLElements html = new HTMLElements();
            File showingFile = new File(file);
            FileInfo fi = new FileInfo();
            // SIC! All metadata goes here
            html.startDiv("");
            html.wln("Имя файла: " + fi.basename(showingFile.toString())); html.nLine();
            html.wln("Размер: " + showingFile.length() + " байт."); html.nLine();
            // Права: (чтение, запись)
            html.wln("Права на: " + (showingFile.canRead() ? " чтение" : "") + (showingFile.canWrite() ? " запись" : ""));
            boolean isFileType = false;
            for(int i = 0; i < IMAGE_DEFINITIONS.length; i++) {

            }
            // Тип документа: метод по которому угадываю что это
            //  Категории: 1. текст 2. вики текст 3. хтмл (это все текст - показывать по разному
            // 4. картинка 5 видео 6. бинарный файл 7. csv-файл 8. tcsv
            html.endDiv();
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

        private boolean printImageFile(String path)  {
            FileInfo fileInfo = new FileInfo();
            if (fileInfo.isImage(path)) {
                printImage(path, 680, 400);
                return true;
            } else {
                return false;
            }
        }

        private boolean printVideoFile(String path)  {
            FileInfo fileInfo = new FileInfo();
            if(fileInfo.isVideo(path)) {
                printVideo(path, 680, 400);
                return true;
            } else {
                return false;
            }
        }

        private void printWiki(String path) {
            HTMLElements html = new HTMLElements();
            String str = null;
            try {
                AWKTranslator awk = new AWKTranslator();
                str = "Вывод после dowiki: " + "<br/>" + awk.doWiki(path);
            } catch(IOException ex) {
                str = "Произошла ошибка!";
            }
            html.wln(str);
        }

        private void printVideo(String path, int width, int height)  {
            HTMLElements html = new HTMLElements();
            html.wln("<video width='" + width + "' height='" + height + "' controls='controls'>" +
                    "<source src='download?" + PARAM_D + "=" + encodeValue(showedPath) + "' type='video/ogg'>" +
                    "<source src='download?" + PARAM_D + "=" + encodeValue(showedPath) + "' type='video/webm'>" +
                    "<source src='download?" + PARAM_D + "=" + encodeValue(showedPath) + "' type='video/mp4'> " +
                    "Your browser does not support the video tag. </video>");
        }

        private void printImage(String path, int width, int height)  {
            HTMLElements html = new HTMLElements();
            html.wln("<style> " +
                    " img { object-fit: contain; }"
                    + "</style>"); //SIC! For normal image without stretching
            html.wln("<img src='download?" + PARAM_D + "=" + encodeValue(showedPath)  + "' alt='sample' height='"+height+"' width='"+width+"'>");
        }

        private void printTable(String path) {
            HTMLElements html = new HTMLElements();
            BufferedReader bufferedReader = null;
            try {
                bufferedReader = new BufferedReader(
                        new InputStreamReader(
                                new FileInputStream(path), StandardCharsets.UTF_8));
                String singleLine = "";
                String dilimiter = ";";
                String[] cells;
                html.wln("<br/>");
                html.startTable("table table-borderedce ");
                html.startTBody("");
                while ((singleLine = bufferedReader.readLine()) != null) {
                    cells = singleLine.split(dilimiter);
                    html.startTr();
                    for (int i = 0; i < cells.length; i++) {
                        html.startTd("");
                        cells[i] = translate_tokens(cells[i], HTML_UNSAFE_CHARACTERS, HTML_UNSAFE_CHARACTERS_SUBST);
                        html.wln(cells[i]);
                        html.endTd();
                    }
                    html.endTr();
                }
                html.endTBody();
                html.endTable();
            }catch(IOException ex) {
                html.wln("Не удалось показать таблицу.");
            } finally {
                try { bufferedReader.close(); } catch (Exception ex) { }
            }
        }

        private void printFileEditButtons() {
            HTMLElements html = new HTMLElements();
            html.wln("<input type=\"submit\" name=\""+ACTION_SAVE+"\" value=\"Сохранить\"/>&nbsp;");
            html.wln("<input type=\"submit\" name=\""+ACTION_DELETE+"\" value=\"Удалить\"/>&nbsp;");
            html.wln("<input type=\"submit\" name=\""+ACTION_UPDATE+"\" value=\"Обновить\"/>&nbsp;");
        }

        private void printTableHead(HttpServletRequest request) {

            HTMLElements html = new HTMLElements();
            html.startDiv("row");
            html.startDiv("col");
            html.printH("Содержание директории: ", 5);

            if(!showedPath.equals(unixSlash)) {
                html.startForm("POST", CGI_NAME + "?" + PARAM_D + "=" + encodeValue(showedPath) + "&" + PARAM_ACTION + "=" + ACTION_CREATE);
                html.printInput("text", "dropdown-item", PARAM_FILE, "Название новой директории", false);
                html.wln("<input type=\"submit\" name=\""+ACTION_RENAME_DIR+"\" value=\"Переименовать директорию\"/>&nbsp;");
                html.endForm();
            }
            html.endDiv();
            html.startDiv("col");
            printHeadPath(request);
            html.startForm("POST", CGI_NAME + "?" + PARAM_D + "=" + encodeValue(showedPath) + "&" + PARAM_ACTION + "=" + ACTION_CREATE);
            html.printInput("text", "dropdown-item", PARAM_FILE, "Название создаваемого файла/директории", false);
            html.wln("<input type=\"submit\" name=\""+ACTION_CREATE+"\" value=\"Создать файл\"/>&nbsp;");
            html.wln("<input type=\"submit\" name=\""+ACTION_MKDIR+"\" value=\"Создать директорию\"/>&nbsp;");
            html.endForm();
            html.endDiv();
            printServerButton();
            html.endDiv();
            html.startTable("table");
            html.startTHead("thead-light");
            html.startTr();
            html.printTh("col", "Имя");
            html.printTh("col", "Размер, байт");
            html.printTh("col", "Права");
            html.printTh("col", "Последняя модификация");
            html.endTr();
            html.endTHead();
        }

        private void printHeadPath(HttpServletRequest request) {
            HTMLElements html = new HTMLElements();
            List<String> allKeys = new ArrayList<>(references.keySet());
            Collections.reverse(allKeys);
            Boolean is_view = getRequestParameter(request, PARAM_ACTION, null) != null;
            int size = allKeys.size();
            if(is_view) size--;
            for(int i = 0; i < size; i++) {
                html.printA("/" + references.get(allKeys.get(i)), allKeys.get(i));
            }
        }

        private void printFooter() {
            HTMLElements html = new HTMLElements();
            html.wln("<footer>");
            html.wln("<hr/>");
            html.wln("Version: " + VERSION);
            html.wln("</footer>");
        }
        // Textarea fow file inners
        private void printFileForm(String path, String cmd, String fileText)  {
            HTMLElements html = new HTMLElements();
            html.startForm("POST", getFileReference(encodeValue(path), cmd));
            html.printText(FILE_TEXTAREA_NAME, 72, 10, fileText); html.nLine();
            printFileEditButtons();
            html.endForm();
        }
        private void printFormForAnyFile(String path, String cmd) {
            HTMLElements html = new HTMLElements();
            html.startForm("POST", getFileReference(encodeValue(path), cmd));
            printFileEditButtons();
            html.endForm();
        }
    }
    public class HTMLElements {
        private void w(String s) {
            boolean is_error = false;
            try { out.print(s); }
            catch (Exception e) { is_error = true; }
        }
        private void wln(String s){ w(s);w("\n");}
        private void wln(){w("\n");}
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

    class FilesHistory {

        private final String HISTORY_DIR_NAME = ".cms";
        private final String HISTORY_FILE_NAME = "master.list.csv";

        public FilesHistory() {

        }

        public void setup(String path) throws IOException {
            Path historyDir = Paths.get(path + unixSlash + HISTORY_DIR_NAME);
            Path historyFile = Paths.get(historyDir + unixSlash + HISTORY_FILE_NAME);
            File directory = historyDir.toFile();
            if(!directory.exists()) {
                Files.createDirectory(historyDir);
                Files.createFile(historyFile);
            }
            else {
                if(!Files.exists(historyFile)) Files.createFile(historyFile);
            }
        }

        public void saveFileState(String path) throws IOException {
            FileOperations operations = new FileOperations();
            String historyFilepath = operations.goUpside(path) + HISTORY_DIR_NAME + unixSlash + HISTORY_FILE_NAME;
            String fileState = getFileStateString(path);

            BufferedWriter writer = new BufferedWriter(
                    new OutputStreamWriter(
                            new FileOutputStream(historyFilepath, true), StandardCharsets.UTF_8));
            writer.write(fileState);
            writer.write("\n");
            writer.close();
        }

        public void backupFile(String path) {
            FileOperations fo = new FileOperations();
            FileInfo fi = new FileInfo();
            String dateStamp = getTimeNow();
            String backupFileName = getHistoryFilePath(path);
            fo.cp(path, backupFileName + unixSlash + fi.basename(path) + "_" + dateStamp);
        }

        public void makeDirForAllFiles(String path) {
            try {
                FileOperations fo = new FileOperations();
                FileInfo fi = new FileInfo();
                File[] allFilesInDirectory = new File(path).listFiles();
                Path dirToFile;
                for (int i = 0; i < allFilesInDirectory.length; i++) {
                    dirToFile = Paths.get(getHistoryFilePath(allFilesInDirectory[i].getPath()));
                    if (!Files.exists(dirToFile)
                            && !new File(allFilesInDirectory[i].toURI()).isDirectory()
                            && !dirToFile.endsWith(HISTORY_DIR_NAME)) {
                        Files.createDirectory(Paths.get(dirToFile.toUri()));
                        String dateStamp = getTimeNow();
                        fo.cp(allFilesInDirectory[i].getPath(),
                                getHistoryFilePath(allFilesInDirectory[i].getPath()) +
                                        unixSlash + fi.basename(allFilesInDirectory[i].getPath()) + "_" + dateStamp);
                    }
                }
            } catch (IOException ex) { } //SIC!
        }

        private String getFileStateString(String path) {
            File directory = new File(path);
            String dirName = directory.getName();
            String lastModified = new SimpleDateFormat("dd.MM.yy HH:mm").format(directory.lastModified());
            String space = String.format("%d", directory.length());
            String rights = (directory.canExecute() ? "x" : "-") +
                            (directory.canRead() ? "r" : "-") +
                            (directory.canWrite() ? "w" : "-");
            boolean isDirectory = directory.isDirectory();
            return String.format("%s;%s;%s;%s;%s", dirName, String.valueOf(isDirectory), rights, lastModified, space);
        }

        private String getTimeNow() {
            return new Date().toString();
        }

        private String getHistoryFilePath(String path) {
            FileInfo fi = new FileInfo();
            return new String(fi.dirname(path) + unixSlash + HISTORY_DIR_NAME + unixSlash + fi.basename(path));
        }

    }

}
