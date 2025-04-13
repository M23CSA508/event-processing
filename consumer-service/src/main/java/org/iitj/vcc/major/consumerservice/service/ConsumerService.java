package org.iitj.vcc.major.consumerservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class ConsumerService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @KafkaListener(topics = "event-stream", groupId = "event-consumer", autoStartup = "false")
    public void consume(String event) {
        jdbcTemplate.update("INSERT INTO events (payload) VALUES (?)", event);
        System.out.println("[Consumer] Stored: " + event);
    }
}
