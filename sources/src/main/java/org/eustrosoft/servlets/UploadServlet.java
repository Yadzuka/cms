package org.eustrosoft.servlets;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.io.FileExistsException;
import org.eustrosoft.providers.LogProvider;

import java.io.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.attribute.PosixFilePermission;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    private LogProvider log;
    private String user;
    private PrintWriter out;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
     List filesCollection;
     String realPath = ""; // real here means that it is the way, where customer wants to upload his file
     String className = "";
     String UPLOAD_PATH = "";
        try {
            UPLOAD_PATH = getServletContext().getInitParameter("root") + getServletConfig().getServletContext().getInitParameter("user");
            log = new LogProvider(getServletContext().getInitParameter("logFilePath"));
            className = this.getClass().getName();
            user = request.getRemoteAddr();
            response.setContentType("text/html;charset=UTF-8");
            request.setCharacterEncoding("UTF-8");
            out = response.getWriter();

            filesCollection = initializeRepository(request, UPLOAD_PATH);

            if(filesCollection == null)
                log.w("Files counter was null in " + className + " user:" + user + ".");

            realPath = processRealPath(filesCollection);
            realPath = UPLOAD_PATH + realPath;

            if(realPath == null)
                log.w("Real path was null in " + className + " user:" + user + ".");
            else if(!realPath.startsWith(getServletContext().getInitParameter("root") + getServletConfig().getServletContext().getInitParameter("user")))
                return;

            try {
                Set<PosixFilePermission> perms = new HashSet<>();
                for (int i = 1; i < filesCollection.size(); i++) {
                    FileItem f = (FileItem) filesCollection.get(i);
                    f.write(new File(realPath + f.getName()));

                    perms.add(PosixFilePermission.OWNER_READ);
                    perms.add(PosixFilePermission.OWNER_WRITE);
                    perms.add(PosixFilePermission.GROUP_WRITE);
                    perms.add(PosixFilePermission.GROUP_READ);
                    perms.add(PosixFilePermission.OTHERS_READ);
                    Files.setPosixFilePermissions(Paths.get(realPath + f.getName()), perms);

                    log.i(f.getName() + " was uploaded by " + user + " to " + realPath);
                }
                response.sendRedirect("index1.jsp?d=" + URLEncoder.encode(realPath.substring(UPLOAD_PATH.length()), StandardCharsets.UTF_8.toString()));
            } catch (FileExistsException ex) {
                out.print("Файл уже существует!");
                out.print("Скоро здесь появится возможность загрузить его новую версию!");
            }
        }catch (FileNotFoundException ex) {
            out.print("Файл(ы) не был(и) выбран(ы).");
            out.print("<button onclick='window.location.href=\"index1.jsp?d=" + URLEncoder.encode(realPath.substring(UPLOAD_PATH.length()))+"\"'>Назад</button>");
            out.flush();
            log.e(ex + " user:" + user + ".");
        } catch (Exception e){
            out.print(e);
            out.flush();
            log.e(e + " user:" + user + ".");
        } finally {

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
