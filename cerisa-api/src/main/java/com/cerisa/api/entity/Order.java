package com.cerisa.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entidad JPA que representa un pedido realizado por un cliente en el sistema
 * Cerisa.
 * <p>
 * Un pedido pertenece a un usuario, tiene un estado (ver {@link OrderStatus}),
 * un total calculado, dirección de entrega opcional, notas y una lista de ítems
 * ({@link OrderItem}). Se mapea a la tabla {@code orders}.
 * </p>
 * <p>
 * La relación con los ítems del pedido es bidireccional con cascada completa
 * y eliminación de huérfanos, lo que permite persistir y eliminar ítems
 * automáticamente al operar con el pedido.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

    /** Identificador único del pedido, generado automáticamente. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario (cliente) que realizó el pedido. Relación muchos-a-uno con carga
     * diferida.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** Estado actual del pedido (PENDIENTE, CONFIRMADO, EN_PREPARACION, etc.). */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private OrderStatus estado;

    /**
     * Total del pedido en pesos, calculado como la suma de los subtotales de cada
     * ítem.
     */
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal total;

    /** Dirección de entrega proporcionada por el cliente. Opcional. */
    @Column(columnDefinition = "TEXT")
    private String direccionEntrega;

    /** Notas adicionales del cliente sobre el pedido. Opcional. */
    @Column(columnDefinition = "TEXT")
    private String notas;

    /**
     * Lista de ítems que componen el pedido.
     * Relación uno-a-muchos con cascada total y eliminación de huérfanos.
     */
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> items = new ArrayList<>();

    /**
     * Fecha y hora de creación del pedido. No se puede modificar tras la inserción.
     */
    @Column(updatable = false)
    private LocalDateTime creadoEn;

    /** Fecha y hora de la última actualización del pedido. */
    private LocalDateTime actualizadoEn;

    /**
     * Callback de JPA ejecutado antes de insertar un nuevo pedido.
     * Establece las fechas de auditoría y el estado PENDIENTE por defecto.
     */
    @PrePersist
    protected void onCreate() {
        creadoEn = LocalDateTime.now();
        actualizadoEn = LocalDateTime.now();
        // Estado inicial por defecto: PENDIENTE
        if (estado == null)
            estado = OrderStatus.PENDIENTE;
    }

    /**
     * Callback de JPA ejecutado antes de actualizar un pedido existente.
     * Actualiza la fecha de última modificación.
     */
    @PreUpdate
    protected void onUpdate() {
        actualizadoEn = LocalDateTime.now();
    }

    /**
     * Agrega un ítem al pedido y establece la referencia bidireccional.
     *
     * @param item el ítem de pedido a agregar
     */
    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
    }
}
