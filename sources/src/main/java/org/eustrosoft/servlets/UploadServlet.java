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
    private String className;

    private final static String UPLOAD_PATH = "/home/yadzuka/Downloads/";

    private DiskFileItemFactory diskFactory;
    private File repositoryPath;
    private ServletFileUpload uploadProcess;
    private List filesCollection;

    private String user;

    private FileItem item;
    private OutputStream outputStream;
    private InputStream inputStream;
    private String realPath; // real here means that it is the way, where customer wants to upload his file

    private PrintWriter out;

    @Override
    public void init() throws ServletException {
        super.init();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            log = new LogProvider();
            className = this.getClass().getName();
            user = request.getRemoteUser();
            out = response.getWriter();
            filesCollection = initializeRepository(request);

            if(filesCollection == null)
                log.w("Files counter was null in " + className + " user:" + user + ".");
            realPath = processRealPath();

            if(realPath == null);
                log.w("Real path was null in " + className + " user:" + user + ".");


            for (int i = 1; i < filesCollection.size(); i++) {
                Object f = filesCollection.get(i);
                ((FileItem) f).write(new File(UPLOAD_PATH + ((FileItem) f).getName()));
                log.i(((FileItem)f).getName() + " was uploaded by " + user + " to " + repositoryPath);
            }
        }catch (Exception e){
            log.e(e.getMessage() + " user:" + user + ".");
        }
    }

    private List initializeRepository(HttpServletRequest request) {
        try {
            diskFactory = new DiskFileItemFactory();
            repositoryPath = new File(UPLOAD_PATH);
            diskFactory.setRepository(repositoryPath);
            uploadProcess = new ServletFileUpload(diskFactory);
            return uploadProcess.parseRequest(request);
        } catch (FileUploadException ex) {
            log.e(ex.getMessage() + " user:" + user + ".");
        }
        return null;
    }

    private String processRealPath() {
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
            log.e(ex.getMessage() + " user:" + user + ".");
        }
        return null;
    }

}
