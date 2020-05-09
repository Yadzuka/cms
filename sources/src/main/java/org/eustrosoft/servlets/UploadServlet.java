package org.eustrosoft.servlets;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.eustrosoft.providers.LogProvider;
import org.eustrosoft.tools.ZLog;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.List;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    private LogProvider log;

    private String user;
    //private OutputStream outputStream;

    private PrintWriter out;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
     List filesCollection;
     String realPath; // real here means that it is the way, where customer wants to upload his file
     String className;
     String UPLOAD_PATH;
        try {
            UPLOAD_PATH = "/s/usersdb/" + getServletConfig().getServletContext().getInitParameter("user") + "/.pspn/";
            log = new LogProvider(getServletContext().getInitParameter("logFilePath"));
            className = this.getClass().getName();
            user = request.getRemoteAddr();
            out = response.getWriter();

            filesCollection = initializeRepository(request, UPLOAD_PATH);

            if(filesCollection == null)
                log.w("Files counter was null in " + className + " user:" + user + ".");

            realPath = processRealPath(filesCollection);

            if(realPath == null)
                log.w("Real path was null in " + className + " user:" + user + ".");

            for (int i = 1; i < filesCollection.size(); i++) {
                FileItem f = (FileItem)filesCollection.get(i);
                f.write(new File(UPLOAD_PATH + f.getName()));
                log.i(f.getName() + " was uploaded by " + user + " to " + UPLOAD_PATH);
            }
        }catch (Exception e){
            log.e(e + " user:" + user + ".");
        }
    }

    private List initializeRepository(HttpServletRequest request, String UPLOAD_PATH) {
       DiskFileItemFactory diskFactory;
       File repositoryPath;
       ServletFileUpload uploadProcess;
        try {
            diskFactory = new DiskFileItemFactory();
            repositoryPath = new File(UPLOAD_PATH);
            diskFactory.setRepository(repositoryPath);
            uploadProcess = new ServletFileUpload(diskFactory);
            return uploadProcess.parseRequest(request);
        } catch (FileUploadException ex) {
            log.e(ex + " user:" + user + ".");
        }
        return null;
    }

    private String processRealPath(List filesCollection) {
     InputStream inputStream = null;
     FileItem item;
        try {
            item = (FileItem) filesCollection.get(0);
            inputStream = item.getInputStream();

            int reader = -1;
            StringBuilder path = new StringBuilder();
            while ((reader = inputStream.read()) != -1) {
                path.append((char)reader);
            }
            return path.toString();
        } catch (IOException ex) {
            log.e(ex + " user:" + user + ".");
        }
        finally {
            try {
                inputStream.close();
            } catch (Exception ex) { log.e(ex + " user:" + user + "."); }
        }
        return null;
    }

}
