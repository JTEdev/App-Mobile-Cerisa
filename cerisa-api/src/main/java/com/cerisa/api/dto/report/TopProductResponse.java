package com.cerisa.api.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de respuesta que representa un producto dentro del ranking de más
 * vendidos.
 * <p>
 * Contiene el identificador y nombre del producto junto con la cantidad
 * total de unidades vendidas en el período del reporte.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TopProductResponse {

    /** Identificador único del producto. */
    private Long productoId;

    /** Nombre del producto. */
    private String productoNombre;

    /** Cantidad total de unidades vendidas en el período. */
    private Long totalVendido;
}
