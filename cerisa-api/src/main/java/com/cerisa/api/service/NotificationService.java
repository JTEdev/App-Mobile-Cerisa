package com.cerisa.api.service;

import com.cerisa.api.entity.Notification;
import com.cerisa.api.entity.Order;
import com.cerisa.api.entity.Product;
import com.cerisa.api.entity.User;
import com.cerisa.api.repository.NotificationRepository;
import com.cerisa.api.repository.OrderRepository;
import com.cerisa.api.repository.ProductRepository;
import com.cerisa.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    private static final int STOCK_CRITICO = 5;

    // ─── CONSULTA ────────────────────────────────────────────

    public List<Notification> getAll() {
        return notificationRepository.findAllByOrderByCreadoEnDesc();
    }

    public long countUnread() {
        return notificationRepository.countByLeidaFalse();
    }

    @Transactional
    public void markAllRead() {
        List<Notification> unread = notificationRepository.findByLeidaFalseOrderByCreadoEnDesc();
        for (Notification n : unread) {
            n.setLeida(true);
        }
        notificationRepository.saveAll(unread);
    }

    @Transactional
    public void markRead(Long id) {
        notificationRepository.findById(id).ifPresent(n -> {
            n.setLeida(true);
            notificationRepository.save(n);
        });
    }

    // ─── GENERACIÓN DE NOTIFICACIONES ────────────────────────

    /** Crea una notificación para un nuevo pedido. */
    @Transactional
    public void onNewOrder(Order order) {
        String titulo = "Nuevo Pedido #" + order.getId();
        String cuerpo = order.getUser().getNombre() + " compró "
                + order.getItems().size() + " producto(s). Total: S/. " + order.getTotal();
        create("PEDIDO", titulo, cuerpo, order.getId());
    }

    /** Crea una notificación cuando se actualiza el estado de un pedido. */
    @Transactional
    public void onOrderStatusChanged(Order order) {
        String titulo = "Pedido #" + order.getId() + " - " + order.getEstado().name();
        String cuerpo = "El pedido de " + order.getUser().getNombre()
                + " cambió a estado: " + order.getEstado().name();
        create("PEDIDO", titulo, cuerpo, order.getId());
    }

    /** Crea una notificación para un nuevo cliente registrado. */
    @Transactional
    public void onNewClient(User user) {
        String titulo = "Nuevo Cliente: " + user.getNombre();
        String cuerpo = user.getEmail() + (user.getTelefono() != null ? " - Tel: " + user.getTelefono() : "");
        create("CLIENTE", titulo, cuerpo, user.getId());
    }

    /** Escaneo periódico de stock bajo (cada 30 min). */
    @Scheduled(fixedRate = 1800000, initialDelay = 10000)
    @Transactional
    public void checkLowStock() {
        List<Product> products = productRepository.findAll();
        for (Product p : products) {
            if (Boolean.TRUE.equals(p.getActivo()) && p.getStock() != null && p.getStock() <= STOCK_CRITICO) {
                // Evitar duplicar si ya existe una notif reciente (últimas 24h) para este producto
                boolean exists = notificationRepository.findAllByOrderByCreadoEnDesc().stream()
                        .anyMatch(n -> "STOCK_CRITICO".equals(n.getTipo())
                                && p.getId().equals(n.getReferenciaId())
                                && n.getCreadoEn().isAfter(LocalDateTime.now().minusHours(24)));
                if (!exists) {
                    String titulo = "Stock Crítico: " + p.getNombre();
                    String cuerpo = "Quedan " + p.getStock() + " unidades en inventario.";
                    create("STOCK_CRITICO", titulo, cuerpo, p.getId());
                }
            }
        }
    }

    /** Genera notificación de pago cuando se confirma un pedido. */
    @Transactional
    public void onPaymentReceived(Order order) {
        String titulo = "Pago Recibido - Pedido #" + order.getId();
        String cuerpo = "S/. " + order.getTotal() + " de " + order.getUser().getNombre() + ".";
        create("PAGO", titulo, cuerpo, order.getId());
    }

    // ─── HELPER ──────────────────────────────────────────────

    private void create(String tipo, String titulo, String cuerpo, Long referenciaId) {
        Notification n = Notification.builder()
                .tipo(tipo)
                .titulo(titulo)
                .cuerpo(cuerpo)
                .referenciaId(referenciaId)
                .leida(false)
                .build();
        notificationRepository.save(n);
    }
}
