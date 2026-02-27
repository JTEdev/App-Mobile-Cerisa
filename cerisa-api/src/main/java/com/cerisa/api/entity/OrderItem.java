package com.cerisa.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

/**
 * Entidad JPA que representa un ítem individual dentro de un pedido
 * ({@link Order}).
 * <p>
 * Cada ítem asocia un producto con una cantidad solicitada, el precio unitario
 * al momento de la compra y el subtotal calculado (precio × cantidad).
 * Se mapea a la tabla {@code order_items}.
 * </p>
 * <p>
 * Se excluye la referencia al pedido padre de {@code toString()} y
 * {@code equals/hashCode}
 * para evitar recursión infinita en la relación bidireccional.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Entity
@Table(name = "order_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem {

    /** Identificador único del ítem de pedido, generado automáticamente. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Pedido al que pertenece este ítem. Relación muchos-a-uno con carga diferida.
     * Excluido de toString y equals/hashCode para evitar recursión bidireccional.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Order order;

    /**
     * Producto asociado a este ítem del pedido. Relación muchos-a-uno con carga
     * diferida.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    /** Cantidad de unidades del producto solicitadas en este ítem. */
    @Column(nullable = false)
    private Integer cantidad;

    /** Precio unitario del producto al momento de realizar el pedido. */
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal precioUnitario;

    /** Subtotal del ítem: precioUnitario × cantidad. */
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;

    /**
     * Callback de JPA ejecutado antes de insertar el ítem en la base de datos.
     * Calcula automáticamente el subtotal multiplicando el precio unitario por la
     * cantidad.
     */
    @PrePersist
    protected void calcularSubtotal() {
        if (precioUnitario != null && cantidad != null) {
            // Calcular subtotal = precioUnitario * cantidad
            subtotal = precioUnitario.multiply(BigDecimal.valueOf(cantidad));
        }
    }
}
