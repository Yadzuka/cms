<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.charset.Charset" %>
<%!
    JspWriter out;
    private File card;
    private File contract;

    private static String ROOT_PATH;
    private static final String FILL = "fill";
    private static final String FILE_FORM = "ForForm.xml";
    private static final String FILE_ROS = "ROSdocument.xml";

    Map documentData = new Hashtable<String, String>(64);
    String [] fieldNames = { "number", "town", "datum", "executor", "executorsmall", "executorposition", "executorname", "executorlaw", "executorplace", "executormail",
            "executorbank", "executoraccount", "executorbankBIK", "executorbankaccount", "executorINN", "executorKPP", "executorOKPO",
            "executorOKVED", "executoradmtel", "executoradmfax", "executortechmail", "executortechtel", "executortechfax", "client", "clientbank",
            "clientaccount", "clientbankBIK", "clientbankaccount", "clientINN", "clientKPP", "clientOKPO", "clientOKVED", "clientadmname", "clientadmmail",
            "clientadmtel", "clienttechname", "clienttechmail", "clienttechtel", "clientpayname", "clientpaymail", "clientpaytel"};


    private boolean fillData(HttpServletRequest request) {
        try {
            for (int i = 0; i < fieldNames.length; i++) {
                documentData.put(fieldNames[i], request.getParameter(fieldNames[i]));
            }
            return true;
        } catch (Exception ex) {
            w("Exception occurred " + ex.getLocalizedMessage());
            return false;
        }
    }

    private boolean fillFormWithData(String newFileName) {
        try {
            File newFormFile = new File(ROOT_PATH + newFileName);
            if(!newFormFile.exists()) {
                newFormFile.createNewFile();
            }
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(card), Charset.forName("UTF-8")));
            BufferedWriter writer = new BufferedWriter
                    (new OutputStreamWriter
                            (new FileOutputStream(ROOT_PATH + newFileName), Charset.forName("UTF-8")));
            String str = "";
            String changedString = "";
            while((str = reader.readLine()) != null) {
                for(int i = 0; i < fieldNames.length; i++) {
                    str = str.replaceAll(">" + fieldNames[i] + "<", ">"  + documentData.get(fieldNames[i]).toString() + "<");
                }
                writer.write(str);
            }
            writer.close();
            reader.close();
            w("Written!");
            return true;
        } catch (IOException ex) {
            w("Exception occurred " + ex.getLocalizedMessage());
            return false;
        }
    }

    private void initialize(ServletContext context) {

        ROOT_PATH = context.getInitParameter("root");
        card = new File(ROOT_PATH + FILE_FORM);
        contract = new File(ROOT_PATH + FILE_ROS);
    }

    private void w(String str) {
        try {
            out.println(str);
        } catch (Exception ex) { /* Something goes here*/}
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
    initialize(context);

    if(request.getParameter(FILL) != null) {
        if(fillData(request)) {
            fillFormWithData("sdas.xml");
        } else {
            w("Данные не загружены!");
        }
    }
%>


<body>

<form method="post" action="forma.jsp">
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
    <input type="submit" name="fill" value="Создать форму">
</form>

</body>

</html>
