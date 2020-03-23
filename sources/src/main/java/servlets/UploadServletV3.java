package servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

@MultipartConfig
public class UploadServletV3 extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Part> fileParts; // Retrieves <input type="file" name="file" multiple="true">
        List<Part> list = new ArrayList<Part>();
        for (Part part : request.getParts()) {
            if ("file".equals(part.getName()) && part.getSize() > 0) {
                list.add(part);
            }
        }
        fileParts = list;

        for (Part filePart : fileParts) {
            String fileName; // MSIE fix.
        }
    }

    private void processRequestFromUser(HttpServletRequest request) {



    }
}
