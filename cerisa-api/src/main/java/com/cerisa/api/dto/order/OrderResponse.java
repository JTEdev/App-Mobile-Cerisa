package com.cerisa.api.dto.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO de respuesta que contiene los datos completos de un pedido.
 * <p>
 * Incluye información del estado, total, dirección de entrega, notas,
 * la lista detallada de ítems y los datos básicos del cliente.
 * Se retorna al crear, consultar o actualizar un pedido.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {

    /** Identificador único del pedido. */
    private Long id;

    /** Estado actual del pedido (PENDIENTE, CONFIRMADO, EN_PREPARACION, etc.). */
    private String estado;

    /** Total del pedido en pesos. */
    private BigDecimal total;

    /** Dirección de entrega proporcionada por el cliente. */
    private String direccionEntrega;

    /** Notas adicionales del pedido. */
    private String notas;

    /** Lista de ítems que componen el pedido con detalle de cada producto. */
    private List<OrderItemResponse> items;

    /** Nombre completo del cliente que realizó el pedido. */
    private String clienteNombre;

    /** Correo electrónico del cliente que realizó el pedido. */
    private String clienteEmail;

    /** Fecha y hora de creación del pedido. */
    private LocalDateTime creadoEn;
}
