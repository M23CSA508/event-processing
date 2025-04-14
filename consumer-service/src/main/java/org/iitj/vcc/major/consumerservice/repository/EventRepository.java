package org.iitj.vcc.major.consumerservice.repository;

import org.iitj.vcc.major.consumerservice.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {
}
