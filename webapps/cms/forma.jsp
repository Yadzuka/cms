<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.charset.Charset" %>
<%@ page import="java.util.zip.*" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%!
    JspWriter out;
    private File fileToWrite;

    private static String ROOT_PATH;
    private static String USER_PATH;
    private static final String PARAM_OLD_FILE = "filename";
    private static final String PARAM_NEW_FILE = "newfilename";
    private static final String PARAM_ACTION = "action";
    private static final String PARAM_TAB = "tabname";
    private static final String FILL = "fill";
    private static final String TAB = "\t";
    private static final String CHANGE_FORM = "change_form";
    private String TAB_FILENAME = "conf.tab";
    private String ACTION = "forma.jsp";

    Map documentData = new Hashtable<String, String>(64);

    ArrayList<String> formField = new ArrayList<>();
    ArrayList<String> formFieldNames = new ArrayList<>();
    ArrayList<String> formFieldDesc = new ArrayList<>();

    String [] fieldNames = { "filename", "newfilename", "number", "town", "datum", "executor", "executorsmall", "executorposition", "executorname", "executorlaw", "executorplace", "executormail",
            "executorbank", "executoraccount", "executorbankBIK", "executorbankaccount", "executorINN", "executorKPP", "executorOKPO",
            "executorOKVED", "executoradmtel", "executoradmfax", "executortechmail", "executortechtel", "executortechfax", "client", "clientbank",
            "clientaccount", "clientbankBIK", "clientbankaccount", "clientINN", "clientKPP", "clientOKPO", "clientOKVED", "clientadmname", "clientadmmail",
            "clientadmtel", "clienttechname", "clienttechmail", "clienttechtel", "clientpayname", "clientpaymail", "clientpaytel"};

    private boolean fillData(HttpServletRequest request) {
        try {
            for (int i = 0; i < formField.size(); i++) {
                documentData.put(formField.get(i), request.getParameter(formField.get(i)));
            }
            return true;
        } catch (Exception ex) {
            w(ex.getMessage());
            return false;
        }
    }

    private boolean fillFormWithData(String oldFileName, String newFileName) {
        try {
            File newFormFile = new File(ROOT_PATH + newFileName);
            if(!newFormFile.exists()) {
                newFormFile.createNewFile();
            } else {
                w("Извините, такой файл уже существует, введите новое имя."); return false;
            }
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(ROOT_PATH + oldFileName), Charset.forName("UTF-8")));
            BufferedWriter writer = new BufferedWriter
                    (new OutputStreamWriter
                            (new FileOutputStream(ROOT_PATH + newFileName), Charset.forName("UTF-8")));

            String str = "";
            while((str = reader.readLine()) != null) {
                for(int i = 0; i < formField.size(); i++) {
                    str = str.replaceAll(formField.get(i), documentData.get(formField.get(i)).toString());
                }
                writer.write(str + "\n");
            }
            writer.close();
            reader.close();
            w("Файл записан!");
            return true;
        } catch (IOException ex) {
            w(ex.getMessage());
            return false;
        }
    }

    private void initialize(ServletContext context, HttpServletRequest request) {
        ROOT_PATH = context.getInitParameter("root") + context.getInitParameter("user") + "/";

        formField = new ArrayList<>();
        formFieldNames = new ArrayList<>();
        formFieldDesc = new ArrayList<>();
        try {
            String pathToConfig = ROOT_PATH + TAB_FILENAME;

            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(pathToConfig), StandardCharsets.UTF_8));

            String str = "";
            String [] fields;
            while((str = reader.readLine()) != null) {
                if(str.startsWith("#"));
                else {
                    fields = str.split("\t");

                    if(fields[0].length() == 2) {
                        formField.add(fields[1]);
                        formFieldNames.add(fields[4]);
                        formFieldDesc.add(fields[5]);
                    }
                }
            }

        } catch (IOException | NullPointerException e) {
            w("Problems with loading configure file." + e.getMessage());
        }
    }

    private String getURLparameter(HttpServletRequest request, String PARAM_NAME) {
        String str = "";
        if(request.getParameter(PARAM_NAME) == null);
        else {
            str = request.getParameter(PARAM_NAME);
        }
        return str;
    }

    private void w(String str) {
        try {
            out.println(str);
        } catch (Exception ex) { /* Something goes here*/ }
    }

    private void wln(String str) {
        w(str);
        w("\n <br/>");
    }
%>
<%
    this.out = out;
    ServletContext context = this.getServletContext();
    response.setCharacterEncoding("UTF-8");
    initialize(context, request);

    if(request.getParameter("change_form") != null) {
        TAB_FILENAME = request.getParameter(PARAM_TAB);
    } else {
        TAB_FILENAME = "conf.tab";
    }

    boolean is_redirected = false;
    try {
        is_redirected = (boolean) request.getAttribute("FORWARD_REQUEST");
    } catch (NullPointerException ex) {

    }
    if(!is_redirected) {
%>
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>
        Form
    </title>
    <meta charset="UTF-8">
</head>
<body>
<%
    } else
        ACTION = "index2.jsp?action=dogen";
    if(request.getParameter(CHANGE_FORM) != null) {
        initialize(context, request);
    }
    else if(request.getParameter(FILL) != null) {
        if(fillData(request)) {
            fillFormWithData(request.getParameter(PARAM_OLD_FILE), request.getParameter(PARAM_NEW_FILE));
        } else {
            w("Данные не загружены!");
        }
    }
%>

<form method="post" action="<%w(ACTION);%>">
    Конфигурационный файл .tab: <input type="text" name="<%=PARAM_TAB%>" value="<% w(TAB_FILENAME); %>"/>
    <input name="change_form" type="submit" value="Создать форму из файла"/> <br/>
    Файл xml для печати (должен находиться в корневой папке): <input type="text" name="filename" value='<% getURLparameter(request, PARAM_ACTION);%>'/><br><br>
    Новое имя файла: <input type="text" name="newfilename" value='<% getURLparameter(request, PARAM_ACTION); %>'/><hr>
    <%
        String value = "";
        for(int i = 0; i < formFieldNames.size(); i++) {
            if(request.getParameter(formFieldNames.get(i)) == null) value = "";
            else value = request.getParameter(formFieldNames.get(i));
            w("<br>" + formFieldNames.get(i) + ": <input type='text' name='" + formField.get(i) + "' value='" + value + "'/>" + formFieldDesc.get(i) + "<br>");
        }
    %>
    <input type="submit" name="fill" value="Создать форму"/>
    </form>
<%
    if(!is_redirected) {
%>
</body>
</html>
<%
    }
%>
