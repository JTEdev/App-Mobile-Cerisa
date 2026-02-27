package com.cerisa.api.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO de respuesta que contiene los datos de un producto del catálogo.
 * <p>
 * Se retorna en las consultas de productos (listado, búsqueda por ID,
 * creación y actualización). Incluye todos los campos visibles del producto.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {

    /** Identificador único del producto. */
    private Long id;

    /** Nombre del producto. */
    private String nombre;

    /** Descripción detallada del producto. */
    private String descripcion;

    /** Precio del producto en pesos. */
    private BigDecimal precio;

    /** Cantidad disponible en inventario. */
    private Integer stock;

    /** Categoría a la que pertenece el producto. */
    private String categoria;

    /** URL de la imagen del producto. */
    private String imagenUrl;

    /** Indica si el producto está activo en el catálogo. */
    private Boolean activo;

    /** Fecha y hora en que se creó el producto. */
    private LocalDateTime creadoEn;
}
