package servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;

public class DownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException{
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        String fileName = req.getParameter("file");
        String pathName = req.getParameter("path");
        File f = new File(pathName + fileName);
        if(!f.exists()) {
            out.println("<script>alert('File does not exists!');</script>");
        } else {
            resp.setContentType("APPLICATION/OCTET-STREAM");
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            FileInputStream fis = new FileInputStream(pathName + fileName);
            int i = -1;
            while ((i = fis.read()) != -1) {
                out.write(i);
            }
            fis.close();
            out.close();
        }
    }
}
