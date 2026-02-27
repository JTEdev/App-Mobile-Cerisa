package com.cerisa.api.dto.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

/**
 * DTO de respuesta que contiene los datos de un ítem individual dentro de un
 * pedido.
 * <p>
 * Incluye el identificador y nombre del producto, la cantidad solicitada,
 * el precio unitario al momento de la compra y el subtotal calculado.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderItemResponse {

    /** Identificador del producto. */
    private Long productoId;

    /** Nombre del producto al momento del pedido. */
    private String productoNombre;

    /** Cantidad de unidades del producto en este ítem. */
    private Integer cantidad;

    /** Precio unitario del producto al momento de la compra. */
    private BigDecimal precioUnitario;

    /** Subtotal del ítem: precioUnitario × cantidad. */
    private BigDecimal subtotal;
}
