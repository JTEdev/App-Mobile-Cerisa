package com.cerisa.api.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;

/**
 * DTO de respuesta que contiene los datos de un reporte de ventas.
 * <p>
 * Incluye el período del reporte (diario o mensual), el total de pedidos
 * realizados, el monto total de ventas y la lista de los productos
 * más vendidos en ese período.
 * </p>
 * <p>
 * Endpoints: {@code GET /api/reports/daily}, {@code GET /api/reports/monthly}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportResponse {

    /**
     * Descripción del período del reporte (ej: "Diario - 2026-02-25" o "Mensual -
     * FEBRUARY 2026").
     */
    private String periodo;

    /** Número total de pedidos realizados en el período. */
    private Long totalPedidos;

    /** Monto total de ventas en pesos (excluye pedidos cancelados). */
    private BigDecimal totalVentas;

    /** Lista de los productos más vendidos en el período (top 10). */
    private List<TopProductResponse> topProductos;
}
