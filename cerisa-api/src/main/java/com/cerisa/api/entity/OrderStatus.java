package com.cerisa.api.entity;

/**
 * Enumeración que define los posibles estados de un pedido ({@link Order})
 * en el sistema Cerisa.
 * <p>
 * El flujo normal de un pedido es:
 * PENDIENTE → CONFIRMADO → EN_PREPARACION → ENVIADO → ENTREGADO.
 * Un pedido puede ser CANCELADO en cualquier momento antes de ser ENTREGADO.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public enum OrderStatus {

    /** El pedido fue creado y está esperando confirmación. */
    PENDIENTE,

    /** El pedido ha sido confirmado por el administrador. */
    CONFIRMADO,

    /** El pedido está siendo preparado para su envío. */
    EN_PREPARACION,

    /** El pedido ha sido enviado al cliente. */
    ENVIADO,

    /** El pedido fue entregado exitosamente al cliente. Estado final. */
    ENTREGADO,

    /** El pedido fue cancelado. No se procesará. */
    CANCELADO
}
