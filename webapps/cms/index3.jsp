<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.io.*"
         import="org.eustrosoft.cms.Main"
         import="org.eustrosoft.providers.LogProvider"
         import="org.eustrosoft.htmlmenu.Menu"
%>
<%!
static final String CGI_NAME = "index3.jsp"; // SIC! Replace when the page name renames
static final String PARAM_D = "d"; // d - file or directory path

private JspWriter out;

%><%
    //setMenuOut(out);
    String lang = null;
    lang = request.getParameter("lang");

    //*************************************************************
    Menu menu = new Menu(out);
    menu.CGI_NAME = CGI_NAME;
    String d = request.getParameter(PARAM_D);
    if(d == null) d = "/";

    //************************************************************
    // org.eustrosoft.cms.Main - Class for printing all CMS stuff!
    //************************************************************
    Main main = new Main();
    Main.WARHCMS cms = main.getWARHCMSInstance();
    main.out = out;
    long enter_time = System.currentTimeMillis();
    main.initUser(request);
    request.setCharacterEncoding("UTF-8");
    main.log = new LogProvider(this.getServletContext().getInitParameter("logFilePath"));
    main.CGI_NAME = CGI_NAME;

%>
<!DOCTYPE html>
<html lang="ru">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="contrib/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">  <!-- SIC! external-ref (см выше) -->
    <link href="css/style.css" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
    <title>Menu JSP </title>
  </head>
  <body>
<%
    menu.printMenu(lang, d);

    //printAssertSection();

    // org.eustrosoft.cms.Main process
    cms.process(request, response);
    //********************************
%>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
  </body>
</html>