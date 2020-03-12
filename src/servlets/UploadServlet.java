package servlets;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.io.*;

import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import java.io.File;
import java.io.PrintWriter;
import java.util.List;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        PrintWriter out = null;
        try {
            response.setContentType("text/html");
            out = response.getWriter();
            String path = request.getParameter("path");
            response.setContentType("multipart/form-data");
            DiskFileItemFactory factory = new DiskFileItemFactory();
            File repository = new File(path);
            factory.setRepository(repository);

            ServletFileUpload upload = new ServletFileUpload(factory);
            List files = upload.parseRequest(request);

            for (Object f : files) {
                ((FileItem) f).write(new File(path + ((FileItem) f).getName()));
            }
            response.setContentType("text/html");
            out.println("<script>>alert('File uploaded!');</script>");
        }catch (Exception e){
            response.setContentType("text/html");
            out.println("<script>alert('Action was failed');</script>");
        }

    }

}
