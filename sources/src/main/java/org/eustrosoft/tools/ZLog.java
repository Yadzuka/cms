package org.eustrosoft.tools;

import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

public final class ZLog {

    private static final int NORMAL_STATUS = 0;
    private static final int WARNING_STATUS = 1;
    private static final int ERROR_STATUS = 2;

    private static final String PREFIX_NORMAL = "INFO";
    private static final String PREFIX_WARNING = "WARNING!";
    private static final String PREFIX_ERROR = "ERROR!!!";
    private static final String [] PREFIXES = {PREFIX_NORMAL, PREFIX_WARNING, PREFIX_ERROR};

    private static SimpleDateFormat dateFormat;
    private OutputStream []outputStream;

    public void writeLog(String message, int status) {
        if(status < 0 | status > 2 | message == null) {
            System.err.println("Error with log parameters.");
            return;
        }
        String prefix = PREFIXES[status];
        try {
            for (int i = 0; i < outputStream.length; i++) {
                out(outputStream[i], dateFormat.format(new Date()));
                out(outputStream[i], ' ');
                out(outputStream[i], prefix);
                out(outputStream[i], " : ");
                out(outputStream[i], message);
                out(outputStream[i], '\n');
                outputStream[i].flush();
            }
        } catch (IOException ex) {
            System.err.println("Error with message writing." + dateFormat.format(new Date()));
        }
    }

    @Override
    protected void finalize() {
        try {
            for (int i = 0; i < outputStream.length; i++)
                outputStream[i].close();
        } catch (IOException ex) {
            System.err.println(ex.getMessage() + " at " + new Date());
        }
    }

    private void out(OutputStream stream, int character) throws IOException {
        stream.write(character);
    }

    private void out(OutputStream stream, String message) throws IOException {
        stream.write(message.getBytes());
    }

    public ZLog(OutputStream outputStream) {
        this.outputStream = new OutputStream[1];
        this.outputStream[0] = outputStream;
        this.dateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
    }

    public ZLog(OutputStream outputStream, String dateFormat) {
        this(outputStream);
        this.dateFormat = new SimpleDateFormat(dateFormat);
    }

    public ZLog(OutputStream [] outputStream) {
        this.outputStream = outputStream;
        this.dateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
    }

    public ZLog(OutputStream [] outputStream, String dateFormat) {
        this(outputStream);
        this.dateFormat = new SimpleDateFormat(dateFormat);
    }
}
