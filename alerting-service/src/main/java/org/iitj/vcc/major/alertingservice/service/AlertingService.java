package org.iitj.vcc.major.alertingservice.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@Service
public class AlertingService {

    private static final Logger logger = LoggerFactory.getLogger(AlertingService.class); 


    @KafkaListener(topics = "event-stream", groupId = "alerting-service")
    public void alert(String event) {
        if (event.contains("ALERT")) {
            ZonedDateTime utcTime = ZonedDateTime.now(ZoneId.of("UTC"));
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
            String time = utcTime.format(formatter);
            System.out.println("[AlertingService] ALERT: " + event + " at UTC Time: " + time);
            logger.info("[AlertingService] ALERT: {} at UTC Time: {}", event, time);
        }
    }
}