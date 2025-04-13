package org.iitj.vcc.major.alertingservice.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class AlertingService {

    @KafkaListener(topics = "event-stream", groupId = "alerting-service", autoStartup = "false")
    public void alert(String event) {
        if (event.contains("ALERT")) {
            System.out.println("[AlertingService] ALERT: " + event);
        }
    }
}