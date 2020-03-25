package org.eustrosoft.tools;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

public final class ZLog {

    private static final String PREFIX_NORMAL = "INFO";
    private static final String PREFIX_WARNING = "WARNING!";
    private static final String PREFIX_ERROR = "ERROR!!!";
    private static final String [] PREFIXES = {PREFIX_NORMAL, PREFIX_WARNING, PREFIX_ERROR};

    private static SimpleDateFormat dateFormat;
    private PrintWriter []outputStream;

    public void writeLog(String message, int status) {
        if(status < 0 | status > 2 | message == null) {
            System.err.println("Error with log parameters.");
            return;
        }
        String prefix = PREFIXES[status];
        try {
            for (int i = 0; i < outputStream.length; i++) {
                out(outputStream[i], dateFormat.format(new Date()) +" " + prefix + " : " + message);
            }
        } catch (IOException ex) {
            System.err.println("Error with message writing." + dateFormat.format(new Date()));
        }
    }

    @Override
    protected void finalize() {
        for (int i = 0; i < outputStream.length; i++)
            outputStream[i].close();
    }

    private void out(PrintWriter stream, String message) throws IOException { stream.println(message); }

    public ZLog(PrintWriter outputStream) {
        this.outputStream = new PrintWriter[1];
        this.outputStream[0] = outputStream;
        this.dateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
    }

    public ZLog(PrintWriter outputStream, String dateFormat) {
        this(outputStream);
        this.dateFormat = new SimpleDateFormat(dateFormat);
    }

    public ZLog(PrintWriter [] outputStream) {
        this.outputStream = outputStream;
        this.dateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
    }

    public ZLog(PrintWriter [] outputStream, String dateFormat) {
        this(outputStream);
        this.dateFormat = new SimpleDateFormat(dateFormat);
    }
}
