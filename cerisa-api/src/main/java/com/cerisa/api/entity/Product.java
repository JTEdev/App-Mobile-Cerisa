package com.cerisa.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entidad JPA que representa un producto del catálogo de Cerisa.
 * <p>
 * Contiene la información completa del producto incluyendo nombre, descripción,
 * precio, stock disponible, categoría, URL de imagen y estado activo/inactivo.
 * Se mapea a la tabla {@code products} en la base de datos.
 * </p>
 * <p>
 * Los productos no se eliminan físicamente; en su lugar se usa eliminación
 * lógica
 * (soft delete) marcando el campo {@code activo} como {@code false}.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Entity
@Table(name = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {

    /** Identificador único del producto, generado automáticamente. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Nombre del producto. Obligatorio, máximo 200 caracteres. */
    @Column(nullable = false, length = 200)
    private String nombre;

    /**
     * Descripción detallada del producto. Almacenada como TEXT en la BD. Opcional.
     */
    @Column(columnDefinition = "TEXT")
    private String descripcion;

    /**
     * Precio del producto en pesos. Obligatorio, precisión de 10 dígitos con 2
     * decimales.
     */
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal precio;

    /** Cantidad disponible en inventario. Obligatorio. */
    @Column(nullable = false)
    private Integer stock;

    /**
     * Categoría del producto (ej: "Materiales", "Herramientas"). Máximo 100
     * caracteres.
     */
    @Column(length = 100)
    private String categoria;

    /** URL de la imagen del producto. Opcional. */
    private String imagenUrl;

    /**
     * Indica si el producto está activo (visible en catálogo). Se usa para
     * eliminación lógica.
     */
    @Column(nullable = false)
    private Boolean activo;

    /**
     * Fecha y hora de creación del producto. No se puede modificar tras la
     * inserción.
     */
    @Column(updatable = false)
    private LocalDateTime creadoEn;

    /** Fecha y hora de la última actualización del producto. */
    private LocalDateTime actualizadoEn;

    /**
     * Callback de JPA ejecutado antes de insertar un nuevo producto.
     * Establece fechas de auditoría y valores por defecto:
     * {@code activo = true} y {@code stock = 0} si no se especificaron.
     */
    @PrePersist
    protected void onCreate() {
        creadoEn = LocalDateTime.now();
        actualizadoEn = LocalDateTime.now();
        // Valores por defecto: producto activo y stock en cero
        if (activo == null)
            activo = true;
        if (stock == null)
            stock = 0;
    }

    /**
     * Callback de JPA ejecutado antes de actualizar un producto existente.
     * Actualiza la fecha de última modificación.
     */
    @PreUpdate
    protected void onUpdate() {
        actualizadoEn = LocalDateTime.now();
    }
}
