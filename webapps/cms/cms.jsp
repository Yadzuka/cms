<%--
 ConcepTIS project
 (c) Alex V Eustrop 2009
 see LICENSE at the project's root directory

 $Id: cms.jsp,v 1.4 2020/05/17 00:38:10 eustrop Exp $

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
%>
<%!
//
// Global parameters
//
private final static String CGI_NAME = "cms.jsp";
private final static String CGI_TITLE = "EustroCMS - система управления разнородным ПСПН контентом (РД по TIS/SQL)";
private final static String CMS_ROOT = "/s/QREditDB/";
private final static String JSP_VERSION = "$Id: cms.jsp,v 1.4 2020/05/17 00:38:10 eustrop Exp $";

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

// BEGIN WAMessage section
    /**
     * convert plain textual data into html form value suitable for input or textarea fields.
     *
     * @param text - plain text
     * @return escaped text
     */
    public static String text2value(String text) {
        return (translate_tokens(text, VALUE_CHARACTERS, VALUE_CHARACTERS_SUBST));
    } // text2value()

    public static String obj2value(Object o) {
        return (text2value(obj2text(o)));
    }
// END WAMessage section

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

  /** Инициализация контекста системы, получение параметров для настройки,
   * загрузка в глобальные статические структуры всего того, что желательно
   * иметь под рукой, в процессе работы, сейчас и после.
   * Вызывается перед оработкой каждого запроса.
   * Выполняется один раз, при каждом обнаружении изменений в загружаемых данных.
   * 
   */ 
 public static void init_cms_context() throws Exception
  {

  } // init_cms_context()
  public static void logon(String user,String remote_ws)
  {
   return;
  }
  public static void logoff() { return; }
  public static boolean check_access(String cmd, String d,String d2){return(true);}
  public static void do_log(String msg) {}

  /** выполнение запроса
   */
   public void exec_request(String cmd,String d,String d2,String opts[])
   throws IOException
   {
    try{
     print_exec_result(cmd,d,d2,opts,"Test");
    }
    catch(Exception e){
     printerrln("exec_request: " + e ); 
    }
    finally{ }
   } //exec_request()
   public void print_exec_result(String cmd,String d,String d2,String opts[],String msg)
   throws IOException
   {
   out.println(cmd);
   out.println(d);
   out.println(d2);
   out.println(msg);
   }

  /** print the whole of rs as html table/
   */
   public void print_exec_result_table(String[] header, String[] rows,String footer[])
   {
/*
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
*/
   } // print_exec_result

   /** print message to stdout. TISExmlDB.java legacy where have been wrapper to System.out.print */
   public  void printmsg(String msg) throws java.io.IOException {out.print(msg);}
   public  void printmsgln(String msg) throws java.io.IOException {out.println(msg);}
   public  void printmsgln() throws java.io.IOException {out.println();}

   /** print message to stderror. TISExmlDB.java legacy where have been just a wrapper to System.err.print */
   public  void printerr(String msg) throws java.io.IOException {out.print("<b>" + obj2html(msg) + "</b>");}
   public  void printerrln(String msg) throws java.io.IOException {printerr(msg);out.print("<br>");}
   public  void printerrln() throws java.io.IOException {out.println();}

   public final static String PARAM_CMD="cmd";
   public final static String PARAM_D="d";
   public final static String PARAM_D2="d2";
   public final static String PARAM_OPTS="opts";
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

 String cmd=request.getParameter(PARAM_CMD);
 String d=request.getParameter(PARAM_D);
 String d2=request.getParameter(PARAM_D2);
 String opts=request.getParameter(PARAM_OPTS);

%>
<html>
 <head>
  <title><%= CGI_TITLE %></title>
 </head>
<body>
  <h2><%= CGI_TITLE %></h2>
  <form method="GET" action="<%=CGI_NAME%>">
  cmd : <select name="<%=PARAM_CMD %>">
   <option value="ls">ls</option>
   <option value="mv">mv</option>
   <option value="rename">rename</option>
   <option value="create">create</option>
   <option value="rm">rm</option>
   <option value="cp">cp</option>
   <option value="view">view</option>
   <option value="lock">lock</option>
   <option value="unlock">unlock</option>
   <option value="commit">commit</option>
   <option value="rollback">rollback</option>
   <option value="fetch">fetch</option>
   <option value="chown">chown</option>
  </select>
   <input name="<%=PARAM_CMD %>" type="text" value="<%=obj2value(cmd) %>"><br>
  d : <input name="<%=PARAM_D %>" type="text" value="<%=obj2value(d) %>"><br>
  d2 : <input name="<%=PARAM_D2 %>" type="text" value="<%=obj2value(d2) %>"><br>
  opts : <br>
  <textarea name="<%=PARAM_OPTS %>" rows="2" cols="72"><%
  //
  // get request from the passed parameters 
  // and display it as <textarea>
  //

  if( opts == null){
   out.println("--none");
  }else{
   out.print(text2value(opts));
  }

  %></textarea><br>
  <input type="submit" value="Execute">
  </form>
 <hr>
 <%

  //
  // passed request executing
  //

  if((!SZ_EMPTY.equals(cmd)) && cmd != null)
  {
   this.out = out;
   try{
    // prepare session context if so
    init_cms_context();
    // logon into system with current request's user
    logon(request.getRemoteUser(),"");
    try{ exec_request(cmd,d,d2,new String[]{opts}); }
    finally{ logoff();}
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
