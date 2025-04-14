package org.iitj.vcc.major.consumerservice.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;

import java.time.LocalDateTime;

@Entity
@Table(name = "events")
@Data
@Getter
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT")
    private String payload;

    private LocalDateTime receivedAt = LocalDateTime.now();

    public Event() {

    }

    public Event(String payload) {
        this.payload = payload;
    }
}

