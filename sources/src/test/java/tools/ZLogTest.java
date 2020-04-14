package tools;

import org.eustrosoft.providers.LogProvider;
import org.junit.Test;

import java.io.FileNotFoundException;

public class ZLogTest {

    @Test
    public void logMail() throws FileNotFoundException {
        LogProvider provider = new LogProvider("/home/yadzuka/workspace/logging/CMSLoggingTests/test1.txt");
    }
}
