package org.eustrosoft.servlets;

import org.eustrosoft.providers.LogProvider;

import java.net.URLEncoder;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@MultipartConfig
public class UploadServletV3 extends HttpServlet {

    private PrintWriter out;
    private String user;
    String className;
    private LogProvider log;

    private InputStream is;
    private OutputStream os;
    String realPath;
    String UPLOAD_PATH = "";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            UPLOAD_PATH = getServletContext().getInitParameter("root") + getServletContext().getInitParameter("user");
            out = response.getWriter();
            log = new LogProvider(getServletContext().getInitParameter("logFilePath"));
            className = this.getClass().getName();
            String user = request.getRemoteAddr();

            realPath = UPLOAD_PATH + request.getParameter("d");

            if(!realPath.startsWith(getServletContext().getInitParameter("root") + getServletContext().getInitParameter("user")))
                return;

            List<Part> fileParts;
            List<Part> list = new ArrayList<Part>();
            for (Part part : request.getParts()) {
                if ("file".equals(part.getName()) && part.getSize() > 0) {
                    list.add(part);
                }
            }

            fileParts = list;

            for (Part filePart : fileParts) {
                is = filePart.getInputStream();
                String filePath = realPath + filePart.getSubmittedFileName();
                os = new FileOutputStream(filePath);
                byte[] buffer = new byte[4096];
                int bytesRead = -1;
                while((bytesRead = is.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
                os.flush();
                log.i(filePart.getName() + " was uploaded by " + user + " to " + filePath  + ". In " + className);
            }
        } catch (Exception ex) {
            log.e(ex + " user:" + user + ". In " + className);
        } finally {
            try {
                os.close();
                is.close();
                response.sendRedirect("index1.jsp?d=" + URLEncoder.encode(realPath.substring(UPLOAD_PATH.length()), StandardCharsets.UTF_8.toString()));
            } catch (Exception ex) { log.e(ex + " user:" + user + ". In " + className); }
        }
    }
}
