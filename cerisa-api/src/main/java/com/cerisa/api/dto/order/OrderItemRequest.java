package com.cerisa.api.dto.order;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * DTO de solicitud que representa un ítem individual dentro de un pedido.
 * <p>
 * Contiene el identificador del producto y la cantidad deseada.
 * Se valida que el producto exista y tenga stock suficiente en el servicio.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
public class OrderItemRequest {

    /** Identificador del producto a agregar al pedido. Obligatorio. */
    @NotNull(message = "El id del producto es obligatorio")
    private Long productoId;

    /** Cantidad de unidades del producto. Obligatoria, mínimo 1. */
    @NotNull(message = "La cantidad es obligatoria")
    @Min(value = 1, message = "La cantidad debe ser al menos 1")
    private Integer cantidad;
}
