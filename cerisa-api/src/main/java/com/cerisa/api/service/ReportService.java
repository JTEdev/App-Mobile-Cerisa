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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
        LocalDateTime desde = LocalDate.now().atStartOfDay();
        LocalDateTime hasta = LocalDate.now().atTime(LocalTime.MAX);
        LocalDateTime desdeAnt = LocalDate.now().minusDays(1).atStartOfDay();
        LocalDateTime hastaAnt = LocalDate.now().minusDays(1).atTime(LocalTime.MAX);
        return buildReport("Diario - " + LocalDate.now(), desde, hasta, desdeAnt, hastaAnt);
    }

    /**
     * Genera el reporte de ventas del mes actual.
     * Calcula el rango desde el primer día hasta el último día del mes.
     *
     * @return el reporte con métricas del mes actual
     */
    public ReportResponse getMonthlyReport() {
        LocalDate now = LocalDate.now();
        LocalDateTime desde = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime hasta = now.withDayOfMonth(now.lengthOfMonth()).atTime(LocalTime.MAX);
        LocalDate prevMonth = now.minusMonths(1);
        LocalDateTime desdeAnt = prevMonth.withDayOfMonth(1).atStartOfDay();
        LocalDateTime hastaAnt = prevMonth.withDayOfMonth(prevMonth.lengthOfMonth()).atTime(LocalTime.MAX);
        return buildReport("Mensual - " + now.getMonth() + " " + now.getYear(), desde, hasta, desdeAnt, hastaAnt);
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
    private ReportResponse buildReport(String periodo, LocalDateTime desde, LocalDateTime hasta,
            LocalDateTime desdeAnt, LocalDateTime hastaAnt) {
        Long totalPedidos = orderRepository.countByFechaRange(desde, hasta);
        BigDecimal totalVentas = orderRepository.sumTotalByFechaRange(desde, hasta);
        BigDecimal ventasAnterior = orderRepository.sumTotalByFechaRange(desdeAnt, hastaAnt);

        List<TopProductResponse> topProducts = orderItemRepository.findTopProducts(desde, hasta).stream()
                .limit(10)
                .map(row -> TopProductResponse.builder()
                        .productoId((Long) row[0])
                        .productoNombre((String) row[1])
                        .totalVendido((Long) row[2])
                        .build())
                .toList();

        return ReportResponse.builder()
                .periodo(periodo)
                .totalPedidos(totalPedidos != null ? totalPedidos : 0L)
                .totalVentas(totalVentas != null ? totalVentas : BigDecimal.ZERO)
                .ventasAnterior(ventasAnterior != null ? ventasAnterior : BigDecimal.ZERO)
                .topProductos(topProducts)
                .build();
    }

    public ReportResponse getYearlyReport() {
        LocalDate now = LocalDate.now();
        LocalDateTime desde = now.withDayOfYear(1).atStartOfDay();
        LocalDateTime hasta = now.withMonth(12).withDayOfMonth(31).atTime(LocalTime.MAX);
        LocalDate prevYear = now.minusYears(1);
        LocalDateTime desdeAnt = prevYear.withDayOfYear(1).atStartOfDay();
        LocalDateTime hastaAnt = prevYear.withMonth(12).withDayOfMonth(31).atTime(LocalTime.MAX);
        return buildReport("Anual - " + now.getYear(), desde, hasta, desdeAnt, hastaAnt);
    }

    public Map<String, Double> getWeeklyTrend() {
        LocalDate today = LocalDate.now();
        LocalDateTime desde = today.minusDays(6).atStartOfDay();
        LocalDateTime hasta = today.atTime(LocalTime.MAX);
        List<Object[]> rows = orderRepository.sumTotalByDay(desde, hasta);
        String[] dayLabels = { "L", "M", "X", "J", "V", "S", "D" };
        Map<String, Double> trend = new LinkedHashMap<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            int dow = day.getDayOfWeek().getValue();
            trend.put(dayLabels[dow - 1], 0.0);
        }
        for (Object[] row : rows) {
            LocalDate day = (LocalDate) row[0];
            BigDecimal total = (BigDecimal) row[1];
            int idx = (int) java.time.temporal.ChronoUnit.DAYS.between(today.minusDays(6), day);
            if (idx >= 0 && idx < 7) {
                int dow = day.getDayOfWeek().getValue();
                String label = dayLabels[dow - 1];
                // rebuild preserving order
                int pos = 0;
                for (var entry : trend.entrySet()) {
                    if (pos == idx) {
                        trend.put(entry.getKey(), total != null ? total.doubleValue() : 0.0);
                        break;
                    }
                    pos++;
                }
            }
        }
        return trend;
    }
}
