package org.iitj.vcc.major.consumerservice.service;

import org.iitj.vcc.major.consumerservice.model.Event;
import org.iitj.vcc.major.consumerservice.repository.EventRepository;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class ConsumerService {

    private static final Logger logger = LoggerFactory.getLogger(ConsumerService.class); 

    private final EventRepository eventRepository;

    public ConsumerService(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    @KafkaListener(topics = "event-stream", groupId = "event-consumer")
    public void consume(String eventPayload) {
        Event event = new Event(eventPayload);
        eventRepository.save(event);
        ZonedDateTime utcTime = ZonedDateTime.now(ZoneId.of("UTC"));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
        String time = utcTime.format(formatter);
        System.out.println("[Consumer] Stored: " + eventPayload + " at UTC Time : " + time);
        logger.info("[Consumer] Stored: {} at UTC Time: {}", eventPayload, time);
    }
}
