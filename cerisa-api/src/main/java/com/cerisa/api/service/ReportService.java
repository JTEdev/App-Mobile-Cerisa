package com.cerisa.api.service;

import com.cerisa.api.dto.report.ReportResponse;
import com.cerisa.api.dto.report.TopProductResponse;
import com.cerisa.api.repository.OrderItemRepository;
import com.cerisa.api.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Servicio que genera reportes de ventas para el panel de administración.
 * <p>
 * Proporciona reportes diarios y mensuales con métricas clave:
 * total de pedidos, monto total de ventas y ranking de productos más vendidos.
 * Todos los reportes excluyen los pedidos cancelados del cálculo de ventas.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class ReportService {

    /** Repositorio de pedidos para consultas de agregación (conteo y suma). */
    private final OrderRepository orderRepository;

    /** Repositorio de ítems de pedido para consulta de productos más vendidos. */
    private final OrderItemRepository orderItemRepository;

    /**
     * Genera el reporte de ventas del día actual.
     * Calcula el rango desde las 00:00:00 hasta las 23:59:59 del día.
     *
     * @return el reporte con métricas del día actual
     */
    public ReportResponse getDailyReport() {
        // Definir el rango del día actual: inicio y fin del día
        LocalDateTime desde = LocalDate.now().atStartOfDay();
        LocalDateTime hasta = LocalDate.now().atTime(LocalTime.MAX);
        return buildReport("Diario - " + LocalDate.now(), desde, hasta);
    }

    /**
     * Genera el reporte de ventas del mes actual.
     * Calcula el rango desde el primer día hasta el último día del mes.
     *
     * @return el reporte con métricas del mes actual
     */
    public ReportResponse getMonthlyReport() {
        LocalDate now = LocalDate.now();
        // Definir el rango del mes: primer día al último día del mes
        LocalDateTime desde = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime hasta = now.withDayOfMonth(now.lengthOfMonth()).atTime(LocalTime.MAX);
        return buildReport("Mensual - " + now.getMonth() + " " + now.getYear(), desde, hasta);
    }

    /**
     * Obtiene el ranking de los productos más vendidos del mes actual.
     * Excluye pedidos cancelados del cálculo.
     *
     * @return lista de productos ordenados por cantidad total vendida (descendente)
     */
    public List<TopProductResponse> getTopProducts() {
        // Calcular el rango del mes actual para el ranking
        LocalDate now = LocalDate.now();
        LocalDateTime desde = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime hasta = now.withDayOfMonth(now.lengthOfMonth()).atTime(LocalTime.MAX);

        // Consultar los productos más vendidos y mapear cada resultado a un DTO
        return orderItemRepository.findTopProducts(desde, hasta).stream()
                .map(row -> TopProductResponse.builder()
                        .productoId((Long) row[0])
                        .productoNombre((String) row[1])
                        .totalVendido((Long) row[2])
                        .build())
                .toList();
    }

    /**
     * Construye un reporte de ventas para un período específico.
     * <p>
     * Consulta el total de pedidos, la suma de ventas (excluyendo cancelados)
     * y los 10 productos más vendidos en el rango de fechas dado.
     * </p>
     *
     * @param periodo descripción textual del período (ej: "Diario - 2026-02-25")
     * @param desde   fecha y hora de inicio del rango
     * @param hasta   fecha y hora de fin del rango
     * @return el reporte completo con todas las métricas
     */
    private ReportResponse buildReport(String periodo, LocalDateTime desde, LocalDateTime hasta) {
        // Obtener el número total de pedidos en el período
        Long totalPedidos = orderRepository.countByFechaRange(desde, hasta);
        // Obtener el monto total de ventas (excluyendo pedidos cancelados)
        BigDecimal totalVentas = orderRepository.sumTotalByFechaRange(desde, hasta);

        // Obtener los 10 productos más vendidos en el período
        List<TopProductResponse> topProducts = orderItemRepository.findTopProducts(desde, hasta).stream()
                .limit(10)
                .map(row -> TopProductResponse.builder()
                        .productoId((Long) row[0])
                        .productoNombre((String) row[1])
                        .totalVendido((Long) row[2])
                        .build())
                .toList();

        // Construir la respuesta con valores por defecto para nulos
        return ReportResponse.builder()
                .periodo(periodo)
                .totalPedidos(totalPedidos != null ? totalPedidos : 0L)
                .totalVentas(totalVentas != null ? totalVentas : BigDecimal.ZERO)
                .topProductos(topProducts)
                .build();
    }
}
