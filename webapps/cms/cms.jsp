<%--
 ConcepTIS project
 (c) Alex V Eustrop 2009
 see LICENSE at the project's root directory

 $Id: cms.jsp,v 1.2 2020/05/15 22:28:41 eustrop Exp $

 Purpose: PostgreSQL DB access via tiny JSP-based application using
          it's (PGSQL) "trusted login" feature and web server's
          supplied username.
 History:
  2009/11/21 started from the TISExmlDB.java,v 1.1 2009/10/04 14:28:00 eustrop Exp
  2009/11/25 done. size: 271 lines
  2009/11/28 some finishing. CVS import. size 277 line.
--%>
<%@
  page contentType="text/html; charset=UTF-8"
  import="java.util.*"
  import="java.io.*"
  import="java.sql.*"
%>
<%!
//
// Global parameters
//
private final static String CGI_NAME = "cms.jsp";
private final static String CGI_TITLE = "PSQL-like tool via JSP and JDBC";
//private final static String DBSERVER_URL = "jdbc:postgresql:tisexmpldb?user=tisuser1&password=";
private final static String DBSERVER_URL = "jdbc:postgresql:conceptisdb";
private final static String JSP_VERSION = "$Id: cms.jsp,v 1.2 2020/05/15 22:28:41 eustrop Exp $";

private final static String SZ_EMPTY = "";
private final static String SZ_NULL = "<<NULL>>";
private final static String SZ_UNKNOWN = "<<UNKNOWN>>";

private JspWriter out;

//
// static conversion helpful functions
// obj2text(), obj2html(), obj2value() - useful functions
// translate_tokens() - background work for them
//

 /** convert object to text even if object is null.
 */
 public static String obj2text(Object o)
 {
 if(o == null) return(SZ_NULL); return(o.toString());
 }

 /** convert object to html text even if object is null.
 * @see #obj2text
 * @see #text2html
 */
 public static String obj2html(Object o)
 {
 return(text2html(obj2text(o)));
 }

 //
 public static String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
 public static String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","<br>\n"};
 public final static String[] VALUE_CHARACTERS = { "<",">","&","\"","'" };
 public final static String[] VALUE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","&quot;","&#039;"};

 /** convert plain textual data into html code with escaping unsafe symbols.
  * @param text - plain text
  * @return html escaped text
  */
 public static String text2html(String text)
 {
 return(translate_tokens(text,HTML_UNSAFE_CHARACTERS,HTML_UNSAFE_CHARACTERS_SUBST));
 } // text2html()

 /** convert plain textual data into html form value suitable for input or textarea fields.
  * @param text - plain text
  * @return escaped text
  */
 public static String text2value(String text)
 {
 return(translate_tokens(text,VALUE_CHARACTERS,VALUE_CHARACTERS_SUBST));
 } // text2html()

 /** replace all sz's occurrences of 'from[x]' onto 'to[x]' and return the result.
  * Each occurence processed once and result depend on token's order at 'from'. 
  * For instance: translate_tokens("hello",new String[]{"he","hel","hl"}, new String[]{"eh","leh","lh"})
  * give "ehllo", not "lehlo" or "elhlo" (in fact "hel" to "leh" translation never be done).
  */
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
 } // translate_tokens

 //
 // DB interaction & result printing methods
 //

  /** create driver class by its classname (jdbc_driver parameter)
   * and register it via DriverManager.registerDriver().
   * @param jdbc_driver - "org.postgresql.Driver" for postgres,
   * "oracle.jdbc.driver.OracleDriver" for oracle, etc.
   */ 
 public static void register_jdbc_driver(String jdbc_driver)
	throws Exception
  {
   java.sql.Driver d;
   Class dc;
   // get "Class" object for driver's class
   try
   {
    dc = Class.forName(jdbc_driver);
    d = (java.sql.Driver)dc.newInstance();
   }
   catch(ClassNotFoundException e) {
     throw new Exception("register_jdbc_driver:" + "unable to get Class for "
     + jdbc_driver + ":" + e); }
   catch(Exception e) {
     throw new Exception("register_jdbc_driver: unable to get driver " 
     + jdbc_driver + " : " + e); }
   // register driver
   try { DriverManager.registerDriver(d); }
   catch(SQLException e) { throw new Exception(
   "register_jdbc_driver: unable to register driver "+jdbc_driver+" : "+e);}
  } // register_jdbc_driver()

  /** execute sz_sql and print it's ResultSet as html table.
   */
   public void exec_sql(java.sql.Connection dbc,String sz_sql)
    throws java.sql.SQLException, java.io.IOException
   {
    java.sql.Statement st = null;
    java.sql.ResultSet rs = null;
    try
    {
     st = dbc.createStatement();
     rs = st.executeQuery(sz_sql);
     print_sql_rs(rs);
    }
    catch(SQLException e){
     printerrln("sql error during \"" + sz_sql + "\": " + e ); 
    }
    finally{
     try{if(rs != null) rs.close();}catch(SQLException e){}
     try{if(st != null) st.close();}catch(SQLException e){}
    }
   } //exec_sql()

  /** print the whole of rs as html table/
   */
   public void print_sql_rs(java.sql.ResultSet rs)
    throws java.sql.SQLException,  java.io.IOException
   {
   java.sql.ResultSetMetaData rsmd = rs.getMetaData();
   int column_count=rsmd.getColumnCount();
   int i;
    // print column's titles
    out.println("<table>");
    out.println("<tr>");
    for(i=1;i<=column_count;i++)
    {
    out.print("<th>");
    printmsg(obj2html(rsmd.getColumnName(i) +
      "(" + rsmd.getColumnTypeName(i)) + ")");
    out.println("</th>");
    } // for column's titles
    out.println("</tr>");
    while(rs.next())
    {
     // print columns values
     out.println("<tr>");
     for(i=1;i<=column_count;i++)
     {
      out.print("<td>");
      printmsg(obj2html(rs.getObject(i))); // rs.getObject(i).getClass().getName()
      out.println("</td>");
     } // for column's values
    out.println("</tr>");
    } // while(rs.next())
    out.println("</table>");
   } // print_sql_rs

   /** print message to stdout. TISExmlDB.java legacy where have been wrapper to System.out.print */
   public  void printmsg(String msg) throws java.io.IOException {out.print(msg);}
   public  void printmsgln(String msg) throws java.io.IOException {out.println(msg);}
   public  void printmsgln() throws java.io.IOException {out.println();}

   /** print message to stderror. TISExmlDB.java legacy where have been just a wrapper to System.err.print */
   public  void printerr(String msg) throws java.io.IOException {out.print("<b>" + obj2html(msg) + "</b>");}
   public  void printerrln(String msg) throws java.io.IOException {printerr(msg);out.print("<br>");}
   public  void printerrln() throws java.io.IOException {out.println();}
%>
<%

 //
 // some hints for old and buggy browsers like NN4.x
 //

 long enter_time = System.currentTimeMillis();
 long expire_time = enter_time + 24*60*60*1000;
 response.setHeader("Cache-Control","No-cache");
 response.setHeader("Pragma","no-cache");
 response.setDateHeader("Expires",expire_time);
 request.setCharacterEncoding("UTF-8");
 String szSQLRequest=SZ_EMPTY;

%>
<html>
 <head>
  <title><%= CGI_TITLE %></title>
 </head>
<body>
  <h2><%= CGI_TITLE %></h2>
  <form method="POST" action="<%=CGI_NAME%>">
  SQL request:<br>
  <textarea name="SQLRequest" rows="10" cols="72"><%

  //
  // get SQL request from the passed parameters 
  // and display it as <textarea>
  //

  szSQLRequest=request.getParameter("SQLRequest");
  if(SZ_EMPTY.equals(szSQLRequest) || szSQLRequest == null){
   out.println("select SAM.get_user()");
  }else{
   out.print(text2value(szSQLRequest));
  }

  %></textarea><br>
  <input type="submit" value="Execute">
  </form>
 <hr>
 <%

  //
  // passed SQL request executing
  //

  if((!SZ_EMPTY.equals(szSQLRequest)) && szSQLRequest != null)
  {
   this.out = out;
   java.sql.Connection dbc;
   try{
    // register JDBC driver
    register_jdbc_driver("org.postgresql.Driver");
    // open JDBC connection
    dbc=DriverManager.getConnection(DBSERVER_URL,request.getRemoteUser(),"");
    //dbc=DriverManager.getConnection(DBSERVER_URL);
    try{ exec_sql(dbc,szSQLRequest); }
    finally{ dbc.close();}
    }
    catch(Exception e){printerrln(e.toString());}
  }
 out.println("<hr>");

 %>
  <i>timing : <%= ((System.currentTimeMillis() - enter_time) + " ms") %></i>
 <br>
  Hello! your web-server is <%= application.getServerInfo() %><br>
  <i><%= JSP_VERSION %></i>
  <!-- Привет this is just for UTF-8 testing (must be russian word "Privet") -->
</body>
</html>
