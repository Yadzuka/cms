package servlets;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.io.*;

import javax.servlet.http.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html");
        String path = request.getParameter("path");
        String file = request.getParameter("file");
        response.setContentType("");
        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            File repository = new File(path);
            factory.setRepository(repository);

            ServletFileUpload upload = new ServletFileUpload(factory);
            List files = upload.parseRequest(request);

            for (Object f : files) {
                ((FileItem) f).write(new File(path + ((FileItem) f).getName()));
            }
        }catch (Exception e){  }

    }

}
