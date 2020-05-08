package org.eustrosoft.servlets;

import org.eustrosoft.providers.LogProvider;
import org.eustrosoft.tools.ZLog;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.io.PrintWriter;

public class DownloadServlet extends HttpServlet {

    private String HOME_DIRECTORY;

    private PrintWriter out;
    private LogProvider log;
    private String className;
    private String user;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) {
        try {
            HOME_DIRECTORY = "/s/usersdb/" + getServletContext().getInitParameter("user") + "/";
            log = new LogProvider(getServletContext().getInitParameter("logFilePath"));
            className = this.getClass().getName();
            user = req.getRemoteAddr();

            resp.setContentType("text/html");
            out = resp.getWriter();
            String fileName = req.getParameter("file");
            String pathName = req.getParameter("path");
            if(checkForInjection(pathName));
            else {
                log.e("User wanted to download " + fileName + " from incorrect path " + pathName + " (" + user + ").");
                return;
            }

            File f = new File(pathName + fileName);
            if (!f.exists()) {
                log.w(user + " wanted to download nonexistent file.");
            } else {
                resp.setCharacterEncoding("UTF-8");
                resp.setContentType("APPLICATION/OCTET-STREAM");
                resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                FileInputStream fis = new FileInputStream(pathName + fileName);
                int i = -1;
                while ((i = fis.read()) != -1) {
                    out.write(i);
                }
                log.i(pathName+fileName + " was downloaded by " + user + ".");
                fis.close();
                out.close();
            }
        } catch (Exception ex) {
            log.e(ex.getMessage() + " (" + user + ").");
        }
    }

    private boolean checkForInjection(String path) {
        if(path.startsWith(HOME_DIRECTORY))
            return true;
        else
            return false;
    }
}
