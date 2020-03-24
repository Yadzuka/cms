package org.eustrosoft.servlets;

import org.eustrosoft.providers.LogProvider;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.PrintWriter;

public class DownloadServlet extends HttpServlet {

    private PrintWriter out;
    private LogProvider log;
    private String className;
    private String user;

    @Override
    public void init() throws ServletException {
        super.init();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) {
        try {
            log = new LogProvider();
            className = this.getClass().getName();
            user = req.getRemoteUser();
            resp.setContentType("text/html");
            out = resp.getWriter();
            String fileName = req.getParameter("file");
            String pathName = req.getParameter("path");
            File f = new File(pathName + fileName);
            if (!f.exists()) {
                out.println("<script>alert('File does not exists!');</script>");
                log.w(user + " wanted to download nonexistent file.");
            } else {
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
}