<%--
 EustroCMS project
 cms.jsp - portable, single-JSP, SPA proof of concept for EustroCMS
 $Id: cms.jsp,v 1.7 2020/05/24 21:43:33 eustrop Exp eustrop $
 (c) EustroSoft.org, Alex V Eustrop & Staff, 2020
 LICENSE: BALES, BSD, MIT (on your choice), see http://bales.eustrosoft.org

 EustroStaff (authors) list:
 1. Alex V Eustrop
 2. Pavel Seleznev (yadzuka@)
 3. Alexander B. Shuvalov (ale777@)
 4. <write your name here & move this text to next line>

 Other Contributions & Contributors (projects, sources & authors of code included into this project)
 1. ConcepTIS : some code imported from classes ZSystem,WAMessages,WASkin,WARHMain (see inital contrib notes for repo)
 2. <write the name of project, its source or authors here & move this text to next line>

 Inital contributions & contributors
 1. This code started from Eustrop's ConcepTIS:/src/java/webapps/psql/psql.jsp
    it can be found here : https://bitbucket.org/eustrop/conceptis/src/default/src/java/webapps/psql/psql.jsp

 ###########    HEADER NOTES FROM ConcepTIS psql.jsp :   #################

 ConcepTIS project
 (c) Alex V Eustrop 2009
 see LICENSE at the project's root directory

 Purpose: PostgreSQL DB access via tiny JSP-based application using
          it's (PGSQL) "trusted login" feature and web server's
          supplied username.
 History:
  2009/11/21 started from the TISExmlDB.java,v 1.1 2009/10/04 14:28:00 eustrop Exp
  2009/11/25 done. size: 271 lines
  2009/11/28 some finishing. CVS import. size 277 line.
 ############ END of HEADER NOTES FROM ConcepTIS psql.jsp ##################
--%><%@
  page contentType="text/html; charset=UTF-8"
  import="java.util.*"
  import="java.io.*"
%><%! // Это "><" НЕСПРОСТА! оно чтобы лишнее "\n" в браузер не улетало!
//
// 0. Глобальные параметры и вспомогательные методы JSP
//
private final static String CGI_NAME = "cms.jsp";
private final static String CGI_TITLE = "EustroCMS - система управления разнородным ПСПН контентом (РД по TIS/SQL)";
private final static String CMS_ROOT = "/s/QREditDB/";
private final static String JSP_VERSION = "$Id: cms.jsp,v 1.7 2020/05/24 21:43:33 eustrop Exp eustrop $";

private final static String SZ_EMPTY = "";
private final static String SZ_NULL = "<<NULL>>";
private final static String SZ_UNKNOWN = "<<UNKNOWN>>";

private JspWriter out;

private WAMessages wam = null; // будем пока использовать только статические методы и св-ва

// ################################################################################
//
// 1. Это будет DAO - структуры и логика манипулирования объектами предметной области
//
// ################################################################################
// ###### BEGIN DAO PACKAGE

public abstract class RItem{ abstract public String getKey(); abstract public String getString(); public String toString(){return(getString());} }
public class RList{ public RItem get(int i){return(null);} public int size(){return(0);} }

/** Хранилище определения команды (информационное)
 */
public class CMDDef{
 String cmd; String cmpltn; String d; String opts; String access; String name; String desc; String comment;
 public String getKey(){return(cmd);}
 CMDDef(String cmd, String cmpltn, String d, String opts, String access, String name, String desc, String comment)
 {this.cmd=cmd; this.cmpltn=cmpltn; this.d=d; this.opts=opts; this.access=access; this.name=name; this.desc=desc; this.comment=comment;}
}
public class CMSException extends Exception
{
CMSException(String msg){super(msg);}
}
public class CMSExceptionNotImplemented extends CMSException
{
CMSExceptionNotImplemented(String cmd){super(cmd + " NOT_IMPLEMENTED");}
}
public class CMSExceptionAccessDenied extends CMSException
{
CMSExceptionAccessDenied(String cmd, String d){super(cmd + "(" + d + ") ACCESS_DENIED");}
}


public class CMSystem
{
  //
  // CMD commands
  // 
public static final String CMD_LS="ls";
public static final String CMD_VIEW="view";
public static final String CMD_MV="mv";
public static final String CMD_RENAME="rename";
public static final String CMD_MKDIR="mkdir";
public static final String CMD_RM="rm";
public static final String CMD_CP="cp";
public static final String CMD_EDIT="edit";
public static final String CMD_CREATE="create";
public static final String CMD_OPEN="open";
public static final String CMD_WRITE="write";
public static final String CMD_COMMIT="commit";
public static final String CMD_ROLLBCK="rollbck";
public static final String CMD_UPLOAD="upload";
public static final String CMD_DOWNLD="downld";

//
// 1.1. Это будет корневой DAO класс - логика манипулирования объектами предметной области
//

public void checkAccess(String d, String d2, String[] opts) throws CMSExceptionAccessDenied
{
}

  // CMD

//  RList ls(String d,String[] opts) throws CMSException { throw new CMSExceptionNotImplemented("ls"); }
public RList ls(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_LS);}
//public void view(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_VIEW);}
public void mv(String d, String d2, String[] opts) throws CMSException { checkAccess(d,d2,opts);  throw new CMSExceptionNotImplemented(CMD_MV);}
public void rename(String d, String d2, String[] opts) throws CMSException { checkAccess(d,d2,opts);  throw new CMSExceptionNotImplemented(CMD_RENAME);}
public void mkdir(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_MKDIR);}
public void rm(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_RM);}
public void cp(String d, String d2, String[] opts) throws CMSException { checkAccess(d,d2,opts);  throw new CMSExceptionNotImplemented(CMD_CP);}
//public void edit(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_EDIT);}
public void create(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_CREATE);}
public void open(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_OPEN);}
public void write(String d, Object data, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_WRITE);}
public void commit(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_COMMIT);}
public void rollbck(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_ROLLBCK);}
//public void upload(String d, String d2, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_UPLOAD);}
//public void downld(String d, String[] opts) throws CMSException { checkAccess(d,null,opts);  throw new CMSExceptionNotImplemented(CMD_DOWNLD);}


  /** Инициализация контекста системы, получение параметров для настройки,
   * загрузка в глобальные статические структуры всего того, что желательно
   * иметь под рукой, в процессе работы, сейчас и после.
   * Вызывается перед оработкой каждого запроса.
   * Выполняется один раз, при каждом обнаружении изменений в загружаемых данных.
   * 
   */ 
 public void init_cms_context() throws Exception
  {

  } // init_cms_context()
  public void logon(String user,String remote_ws)
  {
   return;
  }
  public void logoff() { return; }
  public boolean check_access(String cmd, String d,String d2){return(true);}
  public void do_log(String msg) {}
} // END CMSystem class

// ###### END DAO PACKAGE

// ###### BEGIN WEBAPPS PACKAGE

// ################################################################################
//
// 2. Это будет WAMessages - класс-хранилище лексем, сообщений, средств локализации,
//    методов извлечения и формирования [локализованных] сообщений,
//    а также - статических методов манипулирования строками obj2text(), o2html(),..
//
// ################################################################################
public static final class WAMessages
{

   public final static String PARAM_CMD="cmd";
   public final static String PARAM_D="d";
   public final static String PARAM_D2="d2";
   public final static String PARAM_OPTS="opts";
  //
  // CMD commands
  // 
public static final String CMD_LS="ls";
public static final String CMD_VIEW="view";
public static final String CMD_MV="mv";
public static final String CMD_RENAME="rename";
public static final String CMD_MKDIR="mkdir";
public static final String CMD_RM="rm";
public static final String CMD_CP="cp";
public static final String CMD_EDIT="edit";
public static final String CMD_CREATE="create";
public static final String CMD_OPEN="open";
public static final String CMD_WRITE="write";
public static final String CMD_COMMIT="commit";
public static final String CMD_ROLLBCK="rollbck";
public static final String CMD_UPLOAD="upload";
public static final String CMD_DOWNLD="downld";


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

 /** convert object to text but preserve null value if so.
 * @see obj2text
 */
 public static String obj2string(Object o)
 {
 if(o == null) return(null); return(obj2text(o));
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
 public final static String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
 public final static String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","<br>\n"};
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
 //    И где-то там, всего одна строчка, которая вызывает warh.process(), который
 //    разбирает полученный запрос, исполняет его, и рисует в этом месте документ -
 //    - результат исполнения запроса. А может быть он просто рисует один тэг с id=main
 //    и фрагмент JS с литералом объекта, описывающего, что надо нарисовать?
 //    С точки зрения бизнес-логики это абсолютно не важно. Можно и так и эдак,
 //    и даже смешать, главное чтобы в этом можно было потом разобраться, чтобы
 //    поддерживать и развивать.
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
} //END class CMS WAMessages

// ################################################################################
//
// 4. Это будет WASkin - средство порождения визуальных элементов UI
//
// ################################################################################

public class WASkin
{
private String CGI_NAME="cms.jsp";
private javax.servlet.jsp.JspWriter out;
private WAMessages wam;
private boolean is_error=false;
private Exception last_exception = null;
private boolean is_debug=true;

/** set debug mode. if v=true -> display all printDebug() messages, else - ignore them. */
public void setDebug(boolean v){is_debug=v;}
/** display debug messages if setDebug(true). */
public void printDebug(String msg){if(!is_debug)return;printDivDebug(msg);}
public void printDivDebug(String s){w("<div class='TISCUIDebug' title='this is debug message!'><pre>"); w(t2h(s)); w("</pre></div>");}

/** main raw text writing method (all writes comes through). */
private void w(String s)
{
 is_error=false;
 try{out.print(s);}
 catch(Exception e)
  {is_error=true;last_exception=e;}
} // w(String s)
private void wln(String s){w(s);w("\n");}
private void wln(){w("\n");}

public void sendHTTPRedirect(
        javax.servlet.http.HttpServletResponse response, String szURL)
{
 try{
  //if(true) throw(new java.io.IOException("test exception"));
  response.sendRedirect(szURL);
 }
 catch(java.io.IOException e) {
  printDebug(e.toString());
 }
} // sendHTTPRedirect

// error control methods
public boolean checkError(){return(is_error);}
public Exception getLastException(){return(last_exception);}

/** obj2html */
private String t2h(String s){return(WAMessages.obj2html(s));}
/** obj2value */
private String o2v(Object o){return(WAMessages.obj2value(o));}
/** obj2urlvalue (WARNING: must be rewritten) */
private String o2uv(Object o){return(WAMessages.obj2value(o));}
/** obj2text */
private String o2t(Object o){return(WAMessages.obj2text(o));}
/** obj2string */
private String o2s(Object o){return(WAMessages.obj2string(o));}

public void print(String s){w(t2h(s));}
public void println(String s){w(t2h(s));wln("<br>");}
public void println(){wln("<br>");}


// SIC! BEGIN CODE FOR REMOVE
   /** print message to stdout. TISExmlDB.java legacy where have been wrapper to System.out.print */
   public  void printmsg(String msg) throws java.io.IOException {out.print(msg);}
   public  void printmsgln(String msg) throws java.io.IOException {out.println(msg);}
   public  void printmsgln() throws java.io.IOException {out.println();}

   /** print message to stderror. TISExmlDB.java legacy where have been just a wrapper to System.err.print */
   public  void printerr(String msg) {print("<b>" + wam.obj2html(msg) + "</b>");}
   public  void printerrln(String msg) {println(msg);print("<br>");}
// SIC! END CODE FOR REMOVE

//
// properties get/set
//

public void setOut(javax.servlet.jsp.JspWriter out){this.out=out;}
public javax.servlet.jsp.JspWriter getOut(){return(out);}

public String getCGI() { return(CGI_NAME); }
public String setCGI(String CGI) {String s=CGI_NAME; CGI_NAME=CGI; return(s);}

// constructors

public WASkin() {}
public WASkin(javax.servlet.jsp.JspWriter out, WAMessages wam)
{
 setOut(out);
 this.wam=wam;
}

public WASkin(String CGI, javax.servlet.jsp.JspWriter out, WAMessages wam)
{
 setCGI(CGI);
 setOut(out);
 this.wam=wam;
}

} //END CMS WASkin class


// ################################################################################
//
// 5. Это будет WARHCMS extends WARequestHandler - он обрабатывает запросы,
//    исполняет их посредсвом DAO и рисует пользовательский интерфейс посредством
//    WASkin (и только им, никаких других out.print*, никакого HTML, вдруг это
//    вообще не html... Для этого мы просто подключим другой WASkin). А если ему
//    нужно что-то сказать на человеческом языке, он берет это из WAMessages,
//    ибо человеческие языки разные, и только WAMessages знает, как это
//    будет на том языке, который выбрал пользователь.
//
// ################################################################################

public class WARHMain
{
private String CGI_NAME = "cms.jsp";
private String CMS_ROOT = "/s/QREditDB/";

private final static String SZ_EMPTY = "";
private final static String SZ_NULL = "<<NULL>>";
private final static String SZ_UNKNOWN = "<<UNKNOWN>>";

protected WASkin was;
protected WAMessages wam;

protected javax.servlet.jsp.JspWriter out;
protected javax.servlet.http.HttpServletRequest request;
protected javax.servlet.http.HttpServletResponse response;

CMSystem cms = null;

 //
 // DB interaction & result printing methods
 //

  private void exec_cmd_ls(String d,String[] opts) throws CMSException
  {
   // логика работы такова:
   // RList ls = cmd_ls(d,opts); // далее db.ls(d,opts) или pspn.cms(wam.CMD_LS,d,opts);
   // was.beginTabLS(ls)
   // for ( f in ls) { was.printRowLS(f);}
   // was.closeTabLS(ls)
   was.println("exec_ls:" + d + " Ok");
  }

  /** выполнение запроса
   */
   public void exec_request(String cmd,String d,String d2,String opts[])
   throws IOException
   {
    try{
     print_exec_result(cmd,d,d2,opts,"Test");
     switch(cmd)
     {
      case WAMessages.CMD_LS: exec_cmd_ls(cmd,null);
      default:
     }
    }
    catch(Exception e){
     was.printerrln("exec_request: " + e ); 
    }
    finally{ }
   } //exec_request()
   public void print_exec_result(String cmd,String d,String d2,String opts[],String msg)
   throws IOException
   {
   was.println(cmd);
   was.println(d);
   was.println(d2);
   was.println(msg);
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

   public void process()
   {
 String cmd=request.getParameter(wam.PARAM_CMD);
 String d=request.getParameter(wam.PARAM_D);
 String d2=request.getParameter(wam.PARAM_D2);
 String opts=request.getParameter(wam.PARAM_OPTS);
    cms=new CMSystem();
    try{
    // prepare session context if so
    cms.init_cms_context();
    // logon into system with current request's user
    cms.logon(request.getRemoteUser(),"");
    try{ exec_request(cmd,d,d2,new String[]{opts}); }
    finally{ cms.logoff();}
    }
    catch(Exception e){was.printerrln(e.toString());}
   }

   // Constructors


 public WARHMain(
        javax.servlet.http.HttpServletRequest request,
        javax.servlet.http.HttpServletResponse response,
        javax.servlet.jsp.JspWriter out)
 {
  this.request = request;
  this.response = response;
  this.out = out;
  wam = new WAMessages(); was = new WASkin(out,wam);
 } // WARequestHandler(HttpServletRequest,JspWriter)

}// END WARHMain

// ###### END WEBAPPS PACKAGE

%><%
 // ################################################################################
 //
 // 6. START OF JSP, NON-VISUAL SECTION - здесь можно проделать подготовительную работу
 //    пока в браузер не ушло ни одного байта, можно поправить http заголовки,
 //    поменять mime-type, кодировку, перехватить поток идущий из браузера методами
 //    POST/PUT, чтобы самому разобрать их содержимое (например если это JSON
 //    или просто бинарный поток)
 //
 // ################################################################################

 //
 // some hints for old and buggy browsers like NN4.x
 //

 long enter_time = System.currentTimeMillis();
 long expire_time = enter_time + 24*60*60*1000;
 response.setHeader("Cache-Control","No-cache");
 response.setHeader("Pragma","no-cache");
 response.setDateHeader("Expires",expire_time);
 request.setCharacterEncoding("UTF-8");

 String cmd=request.getParameter(wam.PARAM_CMD);
 String d=request.getParameter(wam.PARAM_D);
 String d2=request.getParameter(wam.PARAM_D2);
 String opts=request.getParameter(wam.PARAM_OPTS);

 boolean should_be_jsp_body_printed = true;

%><%
if(should_be_jsp_body_printed) { // возможно, мы уже все сделали, и это тело нам вообще не нужно
%><!-- this MUST be first line of document/это должна быть ПЕРВАЯ строка html документа -->
<!%--
 // ################################################################################
 //
 // 7. START OF JSP, VISUAL SECTION - здесь начинается HTML секция JSP, и мы уже
 //    начали слать содержимое документа в браузер.
 //
 //    НО ЕЩЕ не совсем! Дело в том, что вывод JSP буфферезирован, и еще что-то
 //    можно исправить, если буфер не переполнился и не отправился пользователю.
 //    (буфер где-то 8192 байта, кстати - это JSP комментарий, он в документ не пойдет)
 //    Здесь все рамочное оформление, подгрузка css, JavaScript и т.п., как в обычном
 //    HTML. Именно это позволяет документу выглядеть "прилично", а не так, как я люблю.
 //    И где-то там, всего одна строчка, которая вызывает warh.process(), который
 //    разбирает полученный запрос, исполняет его, и рисует в этом месте документ -
 //    - результат исполнения запроса.
 //
 //    А может быть он просто рисует один тэг с id=main и фрагмент JavaScript с
 //    литералом объекта, описывающего, что-же надо нарисовать?
 //    С точки зрения бизнес-логики это абсолютно не важно. Можно и так и эдак,
 //    и даже смешать, главное чтобы в этом можно было потом разобраться, чтобы
 //    поддерживать и развивать.
 //
 // ################################################################################
 
--%><!-- this is second line/это вторая строка -->
<html>
 <head>
  <title><%= CGI_TITLE %></title>
 </head>
<body>
  <h2><%= CGI_TITLE %></h2>
  <form method="GET" action="<%=CGI_NAME%>">
  cmd : <select name="<%=wam.PARAM_CMD %>">
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
   <input name="<%=wam.PARAM_CMD %>" type="text" value="<%=wam.obj2value(cmd) %>"><br>
  d : <input name="<%=wam.PARAM_D %>" type="text" value="<%=wam.obj2value(d) %>"><br>
  d2 : <input name="<%=wam.PARAM_D2 %>" type="text" value="<%=wam.obj2value(d2) %>"><br>
  opts : <br>
  <textarea name="<%=wam.PARAM_OPTS %>" rows="2" cols="72"><%
  //
  // get request from the passed parameters 
  // and display it as <textarea>
  //

  if( opts == null){
   out.println("--none");
  }else{
   out.print(wam.text2value(opts));
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
   WARHMain warh=new WARHMain(request,response,out);
   warh.process();
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
<!-- HAPPY KONEC OF SINGLE-JSP-APPLICATION -->
<% } // close block of if(should_be_jsp_body_printed) 
%>
