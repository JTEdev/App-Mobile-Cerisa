package com.cerisa.api.dto.product;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;

/**
 * DTO de solicitud para crear o actualizar un producto en el catálogo.
 * <p>
 * Contiene todos los campos editables de un producto con sus respectivas
 * validaciones. Utilizado en los endpoints {@code POST /api/products}
 * y {@code PUT /api/products/{id}} (solo accesibles por ADMIN).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
public class ProductRequest {

    /** Nombre del producto. Obligatorio, máximo 200 caracteres. */
    @NotBlank(message = "El nombre es obligatorio")
    @Size(max = 200, message = "El nombre no puede exceder 200 caracteres")
    private String nombre;

    /** Descripción detallada del producto. Opcional. */
    private String descripcion;

    /** Precio del producto en pesos. Obligatorio, debe ser mayor a 0. */
    @NotNull(message = "El precio es obligatorio")
    @DecimalMin(value = "0.01", message = "El precio debe ser mayor a 0")
    private BigDecimal precio;

    /** Cantidad disponible en inventario. Obligatorio, no puede ser negativo. */
    @NotNull(message = "El stock es obligatorio")
    @Min(value = 0, message = "El stock no puede ser negativo")
    private Integer stock;

    /**
     * Categoría del producto (ej: "Materiales"). Opcional, máximo 100 caracteres.
     */
    @Size(max = 100, message = "La categoría no puede exceder 100 caracteres")
    private String categoria;

    /** URL de la imagen del producto. Opcional. */
    private String imagenUrl;
}
