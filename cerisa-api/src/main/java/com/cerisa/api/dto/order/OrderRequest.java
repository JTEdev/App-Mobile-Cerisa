package com.cerisa.api.dto.order;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;
import java.util.List;

/**
 * DTO de solicitud para crear un nuevo pedido.
 * <p>
 * El cliente envía la lista de productos con sus cantidades,
 * una dirección de entrega opcional y notas adicionales.
 * El total se calcula automáticamente en el servidor.
 * </p>
 * <p>
 * Endpoint: {@code POST /api/orders}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
public class OrderRequest {

    /**
     * Lista de ítems del pedido. Debe contener al menos un producto.
     * Cada ítem se valida individualmente gracias a {@code @Valid}.
     */
    @NotEmpty(message = "Debe incluir al menos un producto")
    @Valid
    private List<OrderItemRequest> items;

    /** Dirección de entrega del pedido. Opcional, máximo 500 caracteres. */
    @Size(max = 500, message = "La dirección no puede exceder 500 caracteres")
    private String direccionEntrega;

    /** Notas adicionales del cliente sobre el pedido. Opcional. */
    private String notas;
}
