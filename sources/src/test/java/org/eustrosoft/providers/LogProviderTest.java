package org.eustrosoft.providers;

import org.junit.Test;

public class LogProviderTest {

    @Test
    public void i() {
        LogProvider log = new LogProvider();
        log.i("HELLO");
        log.i("HELLO");
    }

    @Test
    public void w() {
    }

    @Test
    public void e() {
    }
}
