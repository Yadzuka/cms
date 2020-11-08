<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.io.*"
         import="java.text.SimpleDateFormat"
         import="org.eustrosoft.cms.Main"
         import="org.eustrosoft.providers.LogProvider"
%>
<% // этот блок инициализирующего кода выполняется уже в процессе обработки запроса, но в самом начале. я перенес его _до_ тела html документа
    Main main = new Main();
    Main.WARHCMS cms = main.getWARHCMSInstance();
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
            cms.process(request, response);
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
