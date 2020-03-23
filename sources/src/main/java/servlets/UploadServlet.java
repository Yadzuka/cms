package servlets;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.List;
import java.util.logging.*;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    private final static String UPLOAD_PATH = "/home/yadzuka/Downloads/";
    private final static String PATH_PARAMETER = "path";

    private final static char OPENED_BRACE = '(';
    private final static char CLOSED_BRACE = ')';

    private DiskFileItemFactory diskFactory;
    private File repositoryPath;
    private ServletFileUpload uploadProcess;
    private List filesCollection;

    private FileItem item;
    private InputStream inputStream;
    private String realPath; // real here means that it is the way, where customer wants to upload his file

    private PrintWriter out;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            out = response.getWriter();
            filesCollection = initializeRepository(request);

            if(filesCollection == null);
                // Also throw new exception
            realPath = processRealPath();

            if(realPath == null);
                // Exception



            for (int i = 1; i < filesCollection.size(); i++) {
                Object f = filesCollection.get(i);
                ((FileItem) f).write(new File(UPLOAD_PATH + ((FileItem) f).getName()));
            }
        }catch (Exception e){ }
    }

    private List initializeRepository(HttpServletRequest request) {
        try {
            diskFactory = new DiskFileItemFactory();
            repositoryPath = new File(UPLOAD_PATH);
            diskFactory.setRepository(repositoryPath);
            uploadProcess = new ServletFileUpload(diskFactory);
            return uploadProcess.parseRequest(request);
        } catch (FileUploadException ex) {
            /*
            Need to think about right way to throwing exceptions
             */
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
            // Also exception processing
        }
        return null;
    }

}
