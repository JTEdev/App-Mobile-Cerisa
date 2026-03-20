package com.cerisa.api.repository;

import com.cerisa.api.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    List<Notification> findAllByOrderByCreadoEnDesc();

    List<Notification> findByLeidaFalseOrderByCreadoEnDesc();

    long countByLeidaFalse();
}
