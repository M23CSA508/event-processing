package org.iitj.vcc.major.consumerservice.config;

import org.iitj.vcc.major.consumerservice.model.Event;
import org.iitj.vcc.major.consumerservice.repository.EventRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!test") 
public class DbInit implements CommandLineRunner {

    private final EventRepository eventRepository;

    public DbInit(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    @Override
    public void run(String... args) {
        eventRepository.save(new Event("init-event"));
        System.out.println(" Inserted init-event to force table creation.");
    }
}
