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
            HOME_DIRECTORY = "/s/usersdb/" + getServletContext().getInitParameter("user") + "/"; // SIC! гвоздями прибито $%^@#$%^
            log = new LogProvider(getServletContext().getInitParameter("logFilePath"));
            className = this.getClass().getName();
            user = req.getRemoteAddr();

            resp.setContentType("text/html");
            out = resp.getOutputStream();
            String fileName = req.getParameter("file"); //SIC! а зачем нам отдельно path и file?
            String pathName = req.getParameter("path");
            if(checkForInjection(pathName)); //SIC! оно не работает, но хорошо, что хоть заглушка есть ;)
            else {
                log.e("User wanted to download " + fileName + " from incorrect path " + pathName + " (" + user + ").");
                return;
            }

            File f = new File(pathName + fileName); //SIC! опять path injection "/s/usersdb/" + "../../etc/passwd"
            if (!f.exists()) {
                log.w(user + " wanted to download nonexistent file.");
            } else {
                String mimeType = getServletContext().getMimeType(pathName + fileName);
                if(mimeType == null) resp.setContentType("Application/Octet-Stream");
                else resp.setContentType(mimeType);

                resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                resp.setHeader("Content-Length", String.format("%d",new File(pathName + fileName).length()));
                FileInputStream fis = new FileInputStream(pathName + fileName);

                byte[] buffer = new byte[4096];
                int bytesRead = -1;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                    out.flush(); //SIC! думал здесь есть проблема, добавил flush(), но нет - можно убрать, потом
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
        if(path.startsWith(HOME_DIRECTORY)) // SIC! /s/userdb/yadzuka/../../../etc/passwd
            return true;
        else
            return false;
    }
}
