package org.iitj.vcc.major.alertingservice;

import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@ImportAutoConfiguration(exclude = { KafkaAutoConfiguration.class })
class AlertingServiceApplicationTests {

    @Test
    void contextLoads() {
    }

}
