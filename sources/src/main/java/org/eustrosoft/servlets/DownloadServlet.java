package org.eustrosoft.servlets;

import org.eustrosoft.providers.LogProvider;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

public class DownloadServlet extends HttpServlet {

    private String HOME_DIRECTORY;

    private OutputStream out;
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
            HOME_DIRECTORY = getServletContext().getInitParameter("root") + getServletContext().getInitParameter("user");
            log = new LogProvider(getServletContext().getInitParameter("logFilePath"));
            className = this.getClass().getName();
            user = req.getRemoteAddr();

            resp.setContentType("text/html");
            out = resp.getOutputStream();
            String file = req.getParameter("d");
            if(checkForInjection(HOME_DIRECTORY + file)); //SIC! оно не работает, но хорошо, что хоть заглушка есть ;)
            else {
                log.e("User wanted to download " + file + " from incorrect path "  + " (" + user + ").");
                return;
            }

            File f1 = new File(HOME_DIRECTORY + file);
            // File f = new File(pathName + fileName); //SIC! опять path injection "/s/usersdb/" + "../../etc/passwd"
            if (!f1.exists()) {
                log.w(user + " wanted to download nonexistent file.");
            } else {
                String mimeType = getServletContext().getMimeType(f1.getPath());
                if(mimeType == null) resp.setContentType("Application/Octet-Stream");
                else resp.setContentType(mimeType);

                resp.setHeader("Content-Disposition", "attachment; filename=\"" + f1.getName() + "\"");
                resp.setHeader("Content-Length", String.format("%d",f1.length()));
                FileInputStream fis = new FileInputStream(f1.getPath());

                byte[] buffer = new byte[4096];
                int bytesRead = -1;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                    out.flush(); //SIC! думал здесь есть проблема, добавил flush(), но нет - можно убрать, потом
                }
                log.i(f1.getPath() + " was downloaded by " + user + ".");
                fis.close();
                out.close();
            }
        } catch (Exception ex) {
            log.e(ex.getMessage() + " (" + user + ").");
        }
    }

    private boolean checkForInjection(String path) {
        if(path.contains("..")) //             SIC! к вопросу ниже! 
            return false;
        if(path.startsWith(HOME_DIRECTORY)) // SIC! /s/userdb/yadzuka/../../../etc/passwd
            return true;
        else
            return false;
    }
}
