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
    private String TAB_FILENAME = "conf.tab";

    Map documentData = new Hashtable<String, String>(64);

    ArrayList<String> formFieldNames = new ArrayList<>(); /*{
            "ABONENT_CODE",
            "DOGOVOR_NUM",
            "DOGOVOR_DATE",
            "ABONENT_NAME_FULL",
            "ABONENT_NAME_SHORT",
            "ABONENT_NAME_EN",
            "ABONENT_ADDR_JUR",
            "ABONENT_ADDR_POST",
            "ABONENT_ADDR_SVC",
            "ABONENT_TEL",
            "ABONENT_FAX",
            "ABONENT_EMAIL",
            "ABONENT_WEB",
            "ABONENT_INN",
            "ABONENT_KPP",
            "ABONENT_OGRN",
            "ABONENT_BANK_NAME",
            "ABONENT_BANK_BIK",
            "ABONENT_BANK_KS",
            "ABONENT_RS_NUM",
            "ABONENT_SIGN_DOLZHN",
            "ABONENT_SIGN_DOLZHN_GEN",
            "ABONENT_SIGN_NAME_FULL",
            "ABONENT_SIGN_NAME_FULL_GEN",
            "ABONENT_SIGN_NAME_SHORT",
            "ABONENT_SIGN_NAME_SHORT_GEN",
            "ABONENT_SIGN_NAME_REASON_GEN",
    };*/

    ArrayList<String> formFieldDesc = new ArrayList<>(); /*{"Код абонента",
            "Номер договора",
            "Дата договора",
            "Имя абонента (полное)",
            "Имя абонента (короткое)",
            "Имя абонента (англ.)",
            "Абонент адрес джур",
            "Абонент адрес пост",
            "Абонент адрес ссв",
            "Телефон абонента",
            "Факс абонента",
            "Емайл абонента",
            "Веб абонента",
            "Инн абонента",
            "Кпп абонента",
            "Оргн абонента",
            "Имя банка абонента",
            "Бик банка абонента",
            "КС банка абонента",
            "РС номер абонента",
            "Должность абонента",
            "Ген должность абонента",
            "Полное имя абонента",
            "Полное ген имя абонента",
            "Короткое ген имя абонента",
            "Абонент синг нейм шорт ген",
            "Абонент сигн шорт нейм",
    };*/

    String [] fieldNames = { "filename", "newfilename", "number", "town", "datum", "executor", "executorsmall", "executorposition", "executorname", "executorlaw", "executorplace", "executormail",
            "executorbank", "executoraccount", "executorbankBIK", "executorbankaccount", "executorINN", "executorKPP", "executorOKPO",
            "executorOKVED", "executoradmtel", "executoradmfax", "executortechmail", "executortechtel", "executortechfax", "client", "clientbank",
            "clientaccount", "clientbankBIK", "clientbankaccount", "clientINN", "clientKPP", "clientOKPO", "clientOKVED", "clientadmname", "clientadmmail",
            "clientadmtel", "clienttechname", "clienttechmail", "clienttechtel", "clientpayname", "clientpaymail", "clientpaytel"};

    private boolean fillData(HttpServletRequest request) {
        try {
            for (int i = 0; i < formFieldNames.size(); i++) {
                documentData.put(formFieldNames.get(i), request.getParameter(formFieldNames.get(i)));
            }
            return true;
        } catch (Exception ex) {
            w(ex.getMessage());
            return false;
        }
    }

    private boolean fillFormWithData(String oldFileName, String newFileName, String tabFileName) {
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
                for(int i = 0; i < formFieldNames.size(); i++) {
                    str = str.replaceAll(formFieldNames.get(i), documentData.get(formFieldNames.get(i)).toString());
                }
                writer.write(str);
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

                    formFieldNames.add(fields[0]);
                    formFieldDesc.add(fields[1]);
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
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>
        Form
    </title>
    <meta charset="UTF-8">
</head>
<%
    this.out = out;
    ServletContext context = this.getServletContext();
    response.setCharacterEncoding("UTF-8");
    initialize(context, request);

    if(request.getParameter(FILL) != null) {
        if(fillData(request)) {
            fillFormWithData(request.getParameter(PARAM_OLD_FILE), request.getParameter(PARAM_NEW_FILE), request.getParameter(PARAM_TAB));
        } else {
            w("Данные не загружены!");
        }
    }
%>
<body>

    <form method="post" action="forma.jsp">
        Конфигурационный файл .tab: <input type="text" name="<% w(PARAM_TAB); %>" value="<% w(TAB_FILENAME); %>"/> <br/>
    Файл xml для печати (должен находиться в корневой папке): <input type="text" name="filename" value='<% getURLparameter(request, PARAM_ACTION);%>'/><br><br>
    Новое имя файла: <input type="text" name="newfilename" value='<% getURLparameter(request, PARAM_ACTION); %>'/><hr>
    <%
        String value = "";
        for(int i = 0; i < formFieldNames.size(); i++) {
            if(request.getParameter(formFieldNames.get(i)) == null) value = "";
            else value = request.getParameter(formFieldNames.get(i));
            w("<br>" + formFieldDesc.get(i) + ": <input type='text' name='" + formFieldNames.get(i) + "' value='" + value + "'/><br>");
        }
    %>
    <input type="submit" name="fill" value="Создать форму"/>
    </form>
</body>
</html>
