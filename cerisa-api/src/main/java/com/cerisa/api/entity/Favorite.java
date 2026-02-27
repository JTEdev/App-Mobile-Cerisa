package com.cerisa.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/**
 * Entidad JPA que representa un producto marcado como favorito por un usuario.
 * <p>
 * Establece una relación muchos-a-uno con {@link User} y {@link Product}.
 * Un usuario puede tener múltiples favoritos, pero no puede marcar
 * el mismo producto dos veces (restricción UNIQUE compuesta).
 * Se mapea a la tabla {@code favorites} en la base de datos.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Entity
@Table(name = "favorites", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "user_id", "product_id" })
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Favorite {

    /** Identificador único del favorito, generado automáticamente. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Usuario que marcó el producto como favorito. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** Producto marcado como favorito. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    /** Fecha y hora en que se agregó el favorito. */
    @Column(updatable = false)
    private LocalDateTime creadoEn;

    /**
     * Callback de JPA que se ejecuta antes de insertar el registro.
     * Establece la fecha de creación al momento actual.
     */
    @PrePersist
    protected void onCreate() {
        creadoEn = LocalDateTime.now();
    }
}
