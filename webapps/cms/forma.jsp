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
    private static final String FILL = "fill";


    Map documentData = new Hashtable<String, String>(64);

    String [] formFieldNames = {"ABONENT_CODE",
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
    };

    String [] formFieldDesc = {"Код абонента",
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
    };

    String [] fieldNames = { "filename", "newfilename", "number", "town", "datum", "executor", "executorsmall", "executorposition", "executorname", "executorlaw", "executorplace", "executormail",
            "executorbank", "executoraccount", "executorbankBIK", "executorbankaccount", "executorINN", "executorKPP", "executorOKPO",
            "executorOKVED", "executoradmtel", "executoradmfax", "executortechmail", "executortechtel", "executortechfax", "client", "clientbank",
            "clientaccount", "clientbankBIK", "clientbankaccount", "clientINN", "clientKPP", "clientOKPO", "clientOKVED", "clientadmname", "clientadmmail",
            "clientadmtel", "clienttechname", "clienttechmail", "clienttechtel", "clientpayname", "clientpaymail", "clientpaytel"};


    private boolean fillData(HttpServletRequest request) {
        try {
            for (int i = 0; i < formFieldNames.length; i++) {
                documentData.put(formFieldNames[i], request.getParameter(formFieldNames[i]));
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
                for(int i = 0; i < formFieldNames.length; i++) {
                    str = str.replaceAll(">" + formFieldNames[i] + "<", ">"  + documentData.get(formFieldNames[i]).toString() + "<");
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
    }

    private void w(String str) {
        try {
            out.println(str);
        } catch (Exception ex) { /* Something goes here*/ }
    }
%>
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>
        Form
    </title>
</head>
<%
    this.out = out;
    ServletContext context = this.getServletContext();
    response.setCharacterEncoding("UTF-8");
    initialize(context, request);

    if(request.getParameter(FILL) != null) {
        if(fillData(request)) {
            fillFormWithData(request.getParameter("oldFileName"), request.getParameter("newfilename"));
        } else {
            w("Данные не загружены!");
        }
    }
%>
<body>

<form method="post" action="forma.jsp">

    Файл xml для печати (должен находиться в корневой папке): <input type="text" name="filename" value='<% w(request.getParameter(PARAM_OLD_FILE)); %>'/><br> <br>
    Новое имя файла: <input type="text" name="newfilename" value='<% w(request.getParameter(PARAM_NEW_FILE)); %>'/><hr>

    <%
        String value = "";
        for(int i = 0; i < formFieldNames.length; i++) {
            if(request.getParameter(formFieldNames[i]) == null) value = "";
            else value = request.getParameter(formFieldNames[i]);
            w("<br>" + formFieldDesc[i] + ": <input type='text' name='" + formFieldNames[i] + "' value='" + value + "'/><br>");
        }
    %>

    <input type="submit" name="fill" value="Создать форму">
    <!--
    <h1>Введите общие данные договора:</h1>
    Номер:<br><input type="text" name="number"><br>
    Город, в котором заключен договор:<br><input type="text" name="town"><br>
    Дата договора:<br><input type="text" name="datum"><br>

    <h1>Введите данные исполнителя:</h1>
    Полное название:<br><input type="text" name="executor"><br>
    Сокращенное название:<br><input type="text" name="executorsmall"><br>
    Должность подписанта:<br><input type="text" name="executorposition"><br>
    ФИО подписанта:<br><input type="text" name="executorname"><br>
    На основании чего подписант имеет право на подпись:<br><input type="text" name="executorlaw"><br>
    Место нахождения:<br><input type="text" name="executorplace"><br>
    Почтовый адрес:<br><input type="text" name="executormail"><br>
    Наименование банка:<br><input type="text" name="executorbank"><br>
    Расчетный счет:<br><input type="text" name="executoraccount"><br>
    БИК:<br><input type="text" name="executorbankBIK"><br>
    Корреспондентский счет:<br><input type="text" name="executorbankaccount"><br>
    ИНН:<br><input type="text" name="executorINN"><br>
    КПП:<br><input type="text" name="executorKPP"><br>
    ОКПО:<br><input type="text" name="executorOKPO"><br>
    ОКВЭД:<br><input type="text" name="executorOKVED"><br>
    <h2>Представитель по административным вопросам</h2>
    E-mail:<br><input type="text" name="executoradmmail"><br>
    Тел:<br><input type="text" name="executoradmtel"><br>
    Факс:<br><input type="text" name="executoradmfax"><br>
    <h2>Представитель по техническим вопросам использования адресного пространства, ведению договора, решению вопросов оплаты</h2>
    E-mail:<br><input type="text" name="executortechmail"><br>
    Тел:<br><input type="text" name="executortechtel"><br>
    Факс:<br><input type="text" name="executortechfax"><br>

    <h1>Введите данные заказчика:</h1>
    Полное название:<br><input type="text" name="client"><br>
    Сокращенное название:<br><input type="text" name="clientsmall"><br>
    Должность подписанта:<br><input type="text" name="clientposition"><br>
    ФИО подписанта:<br><input type="text" name="clientname"><br>
    На основании чего подписант имеет право на подпись:<br><input type="text" name="clientlaw"><br>
    Место нахождения:<br><input type="text" name="clientplace"><br>
    Почтовый адрес:<br><input type="text" name="clientmail"><br>
    Наименование банка:<br><input type="text" name="clientbank"><br>
    Расчетный счет:<br><input type="text" name="clientaccount"><br>
    БИК:<br><input type="text" name="clientbankBIK"><br>
    Корреспондентский счет:<br><input type="text" name="clientbankaccount"><br>
    ИНН:<br><input type="text" name="clientINN"><br>
    КПП:<br><input type="text" name="clientKPP"><br>
    ОКПО:<br><input type="text" name="clientOKPO"><br>
    ОКВЭД:<br><input type="text" name="clientOKVED"><br>
    <h2>Представитель по административным вопросам</h2>
    ФИО:<br><input type="text" name="clientadmname"><br>
    E-mail:<br><input type="text" name="clientadmmail"><br>
    Тел./факс:<br><input type="text" name="clientadmtel"><br>
    <h2>Представитель по техническим вопросам использования адресного пространства</h2>
    ФИО:<br><input type="text" name="clienttechname"><br>
    E-mail:<br><input type="text" name="clienttechmail"><br>
    Тел./факс:<br><input type="text" name="clienttechtel"><br>
    <h2>Представитель по ведению договора, решению вопросов оплаты</h2>
    ФИО:<br><input type="text" name="clientpayname"><br>
    E-mail:<br><input type="text" name="clientpaymail"><br>
    Тел./факс:<br><input type="text" name="clientpaytel"><br>
     -->
</form>

</body>

</html>
