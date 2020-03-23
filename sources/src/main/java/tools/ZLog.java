package tools;

import org.w3c.dom.CDATASection;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ZLog {

    private InputStream inputStream;
    private OutputStream []outputStream;

    private static SimpleDateFormat dateFormat;

    public void logMail(String message) {
        writeLog(message);
    }

    protected void writeLog(String message) {
        if (message == null)
            return;
        try {
            for (int i = 0; i < outputStream.length; i++) {
                out(outputStream[i], dateFormat.format(new Date()));
                out(outputStream[i], ' ');
                out(outputStream[i], ':');
                out(outputStream[i], ' ');
                out(outputStream[i], message);
                out(outputStream[i], '\n');
            }
        } catch (IOException ex) {
            System.err.println("Error with message writing." + dateFormat.format(new Date()));
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
        this.outputStream = new OutputStream[1];
        this.outputStream[0] = outputStream;
        this.dateFormat = new SimpleDateFormat(dateFormat);
    }

    public ZLog(OutputStream [] outputStream) {
        this.outputStream = outputStream;
        this.dateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
    }

    public ZLog(OutputStream [] outputStream, String dateFormat) {
        this.outputStream = new OutputStream[outputStream.length];
        for(int i = 0; i < outputStream.length; i++)
            this.outputStream[i] = outputStream[i];
        this.dateFormat = new SimpleDateFormat(dateFormat);
    }
}
