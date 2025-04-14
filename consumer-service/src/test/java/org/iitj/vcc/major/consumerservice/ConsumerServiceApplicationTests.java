package org.iitj.vcc.major.consumerservice;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@TestPropertySource("classpath:application-test.yaml")
class ConsumerServiceApplicationTests {

    @Test
    void contextLoads() {
    }

}
