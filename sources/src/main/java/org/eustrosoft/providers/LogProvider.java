package org.eustrosoft.providers;
import org.eustrosoft.tools.ZLog;

import java.io.*;
import java.util.Date;

public class LogProvider {

    private ZLog logger;
    private PrintWriter fileTarget;
    private PrintWriter consoleTarget;

    public LogProvider(String fileName) {
        try {
            fileTarget = new PrintWriter(new FileOutputStream(fileName , true), true);
        } catch (FileNotFoundException ex) {
            System.err.println("Fail with file finding." + new Date());
        }
        logger = new ZLog(new PrintWriter[]{fileTarget});
    }

    public void i(String message) { logger.writeLog(message, 0); } // INFO
    public void w(String message) { logger.writeLog(message, 1); } // WARNING
    public void e(String message) { logger.writeLog(message, 2); } // ERROR
}
