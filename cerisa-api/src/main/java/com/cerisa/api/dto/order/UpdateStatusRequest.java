package com.cerisa.api.dto.order;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO de solicitud para actualizar el estado de un pedido existente.
 * <p>
 * Contiene únicamente el nuevo estado a asignar al pedido.
 * Los valores válidos son: PENDIENTE, CONFIRMADO, EN_PREPARACION,
 * ENVIADO, ENTREGADO, CANCELADO.
 * </p>
 * <p>
 * Endpoint: {@code PUT /api/orders/{id}/status} (solo ADMIN)
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
public class UpdateStatusRequest {

    /**
     * Nuevo estado del pedido. Obligatorio. Debe ser un valor válido de
     * OrderStatus.
     */
    @NotBlank(message = "El estado es obligatorio")
    private String estado;
}
