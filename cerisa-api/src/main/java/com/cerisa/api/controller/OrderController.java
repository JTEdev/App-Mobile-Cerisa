package com.cerisa.api.controller;

import com.cerisa.api.dto.order.OrderRequest;
import com.cerisa.api.dto.order.OrderResponse;
import com.cerisa.api.dto.order.UpdateStatusRequest;
import com.cerisa.api.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST que expone los endpoints de gestión de pedidos.
 * <p>
 * Todos los endpoints requieren autenticación. Los endpoints de administración
 * (listar todos los pedidos y cambiar estado) requieren rol ADMIN.
 * </p>
 * <p>
 * Base URL: {@code /api/orders}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    /** Servicio que gestiona la lógica de negocio de pedidos. */
    private final OrderService orderService;

    /**
     * Crea un nuevo pedido para el usuario autenticado.
     * El stock de los productos se descuenta automáticamente.
     * <p>
     * Endpoint autenticado: {@code POST /api/orders}
     * </p>
     *
     * @param request el DTO con los ítems, dirección y notas del pedido (validado)
     * @return respuesta HTTP 201 (Created) con los datos del pedido creado
     */
    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody OrderRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(orderService.createOrder(request));
    }

    /**
     * Obtiene todos los pedidos del usuario autenticado.
     * <p>
     * Endpoint autenticado: {@code GET /api/orders/my}
     * </p>
     *
     * @return respuesta HTTP 200 con la lista de pedidos del usuario
     */
    @GetMapping("/my")
    public ResponseEntity<List<OrderResponse>> getMyOrders() {
        return ResponseEntity.ok(orderService.getMyOrders());
    }

    /**
     * Obtiene todos los pedidos del sistema (vista administrativa).
     * <p>
     * Endpoint protegido (ADMIN): {@code GET /api/orders}
     * </p>
     *
     * @return respuesta HTTP 200 con la lista completa de todos los pedidos
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<OrderResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    /**
     * Actualiza el estado de un pedido específico.
     * Estados válidos: PENDIENTE, CONFIRMADO, EN_PREPARACION, ENVIADO, ENTREGADO,
     * CANCELADO.
     * <p>
     * Endpoint protegido (ADMIN): {@code PUT /api/orders/{id}/status}
     * </p>
     *
     * @param id      el identificador del pedido a actualizar
     * @param request el DTO con el nuevo estado del pedido (validado)
     * @return respuesta HTTP 200 con los datos actualizados del pedido
     */
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OrderResponse> updateOrderStatus(@PathVariable Long id,
            @Valid @RequestBody UpdateStatusRequest request) {
        return ResponseEntity.ok(orderService.updateOrderStatus(id, request));
    }
}
