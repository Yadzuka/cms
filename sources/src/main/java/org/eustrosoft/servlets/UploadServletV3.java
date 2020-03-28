package org.eustrosoft.servlets;

import org.eustrosoft.providers.LogProvider;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

@MultipartConfig
public class UploadServletV3 extends HttpServlet {

    private final static String UPLOAD_PATH = "/home/yadzuka/Downloads/";
    private PrintWriter out;
    private LogProvider log;
    private String className;
    private String user;


    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            out = response.getWriter();
            log = new LogProvider();
            className = this.getClass().getName();
            user = request.getRemoteUser();

            List<Part> fileParts; // Retrieves <input type="file" name="file" multiple="true">
            List<Part> list = new ArrayList<Part>();
            for (Part part : request.getParts()) {
                if ("file".equals(part.getName()) && part.getSize() > 0) {
                    list.add(part);
                }
            }
            fileParts = list;

            int read = -1;
            for (Part filePart : fileParts) {
                InputStream is = filePart.getInputStream();
                String filePath = UPLOAD_PATH + filePart.getName();
                OutputStream os = new FileOutputStream(filePath);
                out.println(filePath);
                while ((read = is.read()) != -1) {
                    os.write(read);
                }
                log.i(filePart.getName() + " was uploaded by " + user + " to " + filePath);
                os.flush();
                os.close();
                is.close();
            }
        } catch (Exception ex) {
            log.e(ex.getMessage() + " user:" + user + ".");
        }
    }
}
