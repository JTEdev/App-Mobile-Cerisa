package com.cerisa.api.controller;

import com.cerisa.api.dto.report.ReportResponse;
import com.cerisa.api.dto.report.TopProductResponse;
import com.cerisa.api.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Controlador REST que expone los endpoints de reportes de ventas.
 * <p>
 * Todos los endpoints de este controlador están protegidos y requieren
 * rol ADMIN. Proporciona reportes diarios, mensuales y ranking de
 * productos más vendidos.
 * </p>
 * <p>
 * Base URL: {@code /api/reports}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestController
@RequestMapping("/api/reports")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class ReportController {

    /** Servicio que genera los reportes de ventas. */
    private final ReportService reportService;

    /**
     * Obtiene el reporte de ventas del día actual.
     * Incluye total de pedidos, total de ventas y productos más vendidos.
     * <p>
     * Endpoint protegido (ADMIN): {@code GET /api/reports/daily}
     * </p>
     *
     * @return respuesta HTTP 200 con el reporte diario
     */
    @GetMapping("/daily")
    public ResponseEntity<ReportResponse> getDailyReport() {
        return ResponseEntity.ok(reportService.getDailyReport());
    }

    /**
     * Obtiene el reporte de ventas del mes actual.
     * Incluye total de pedidos, total de ventas y productos más vendidos.
     * <p>
     * Endpoint protegido (ADMIN): {@code GET /api/reports/monthly}
     * </p>
     *
     * @return respuesta HTTP 200 con el reporte mensual
     */
    @GetMapping("/monthly")
    public ResponseEntity<ReportResponse> getMonthlyReport() {
        return ResponseEntity.ok(reportService.getMonthlyReport());
    }

    /**
     * Obtiene el ranking de los productos más vendidos del mes actual.
     * <p>
     * Endpoint protegido (ADMIN): {@code GET /api/reports/top-products}
     * </p>
     *
     * @return respuesta HTTP 200 con la lista de productos más vendidos
     */
    @GetMapping("/top-products")
    public ResponseEntity<List<TopProductResponse>> getTopProducts() {
        return ResponseEntity.ok(reportService.getTopProducts());
    }
}
