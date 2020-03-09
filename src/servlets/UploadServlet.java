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

    private String filePath = "/home/yadzuka/workspace/";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        PrintWriter out = null;
        try {
            out = response.getWriter();
            DiskFileItemFactory factory = new DiskFileItemFactory();
            File repository = new File(filePath);
            factory.setRepository(repository);

            ServletFileUpload upload = new ServletFileUpload(factory);
            List files = upload.parseRequest(request);

            for (Object file : files) {
                ((FileItem) file).write(new File(filePath + ((FileItem) file).getName()));
            }
            out.println("File downloaded!");
        }catch (Exception e){ out.println(""); }

    }

}
