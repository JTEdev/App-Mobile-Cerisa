package com.cerisa.api.service;

import com.cerisa.api.dto.order.*;
import com.cerisa.api.entity.*;
import com.cerisa.api.repository.OrderRepository;
import com.cerisa.api.repository.ProductRepository;
import com.cerisa.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * Servicio que gestiona las operaciones de pedidos del sistema Cerisa.
 * <p>
 * Proporciona funcionalidades para:
 * <ul>
 * <li><b>Crear pedido:</b> Valida stock, descuenta inventario, calcula
 * totales.</li>
 * <li><b>Mis pedidos:</b> Lista los pedidos del usuario autenticado.</li>
 * <li><b>Todos los pedidos:</b> Lista todos los pedidos (uso
 * administrativo).</li>
 * <li><b>Actualizar estado:</b> Cambia el estado de un pedido (solo
 * ADMIN).</li>
 * </ul>
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class OrderService {

        /** Repositorio para acceder a los datos de pedidos. */
        private final OrderRepository orderRepository;

        /** Repositorio para acceder y actualizar el stock de productos. */
        private final ProductRepository productRepository;

        /** Repositorio para acceder a los datos de usuarios. */
        private final UserRepository userRepository;

        /**
         * Crea un nuevo pedido para el usuario autenticado.
         * <p>
         * Para cada ítem del pedido:
         * 1. Verifica que el producto exista.
         * 2. Valida que haya stock suficiente.
         * 3. Descuenta el stock del producto.
         * 4. Calcula el subtotal del ítem.
         * Finalmente calcula el total general y guarda el pedido.
         * </p>
         *
         * @param request el DTO con los ítems, dirección de entrega y notas del pedido
         * @return los datos completos del pedido creado
         * @throws RuntimeException si un producto no existe o no tiene stock suficiente
         */
        @Transactional
        public OrderResponse createOrder(OrderRequest request) {
                // Obtener el usuario autenticado desde el contexto de seguridad
                User user = getCurrentUser();

                // Crear el pedido con estado inicial PENDIENTE y total en cero (se calculará)
                Order order = Order.builder()
                                .user(user)
                                .estado(OrderStatus.PENDIENTE)
                                .direccionEntrega(request.getDireccionEntrega())
                                .notas(request.getNotas())
                                .total(BigDecimal.ZERO)
                                .build();

                BigDecimal total = BigDecimal.ZERO;

                // Procesar cada ítem del pedido
                for (OrderItemRequest itemReq : request.getItems()) {
                        // Buscar el producto en la base de datos
                        Product product = productRepository.findById(itemReq.getProductoId())
                                        .orElseThrow(() -> new RuntimeException(
                                                        "Producto no encontrado: " + itemReq.getProductoId()));

                        // Validar que haya stock suficiente para la cantidad solicitada
                        if (product.getStock() < itemReq.getCantidad()) {
                                throw new RuntimeException("Stock insuficiente para: " + product.getNombre()
                                                + ". Disponible: " + product.getStock());
                        }

                        // Descontar la cantidad del stock del producto
                        product.setStock(product.getStock() - itemReq.getCantidad());
                        productRepository.save(product);

                        // Calcular el subtotal del ítem (precio × cantidad)
                        BigDecimal subtotal = product.getPrecio().multiply(BigDecimal.valueOf(itemReq.getCantidad()));
                        total = total.add(subtotal);

                        // Crear el ítem del pedido con el precio actual del producto
                        OrderItem item = OrderItem.builder()
                                        .product(product)
                                        .cantidad(itemReq.getCantidad())
                                        .precioUnitario(product.getPrecio())
                                        .subtotal(subtotal)
                                        .build();

                        // Agregar el ítem al pedido (establece la relación bidireccional)
                        order.addItem(item);
                }

                // Establecer el total calculado y guardar el pedido completo
                order.setTotal(total);
                Order saved = orderRepository.save(order);
                return toResponse(saved);
        }

        /**
         * Obtiene todos los pedidos del usuario autenticado, ordenados del más reciente
         * al más antiguo.
         *
         * @return lista de pedidos del usuario actual
         */
        public List<OrderResponse> getMyOrders() {
                User user = getCurrentUser();
                return orderRepository.findByUserIdOrderByCreadoEnDesc(user.getId()).stream()
                                .map(this::toResponse)
                                .toList();
        }

        /**
         * Obtiene todos los pedidos del sistema, ordenados del más reciente al más
         * antiguo.
         * Solo debe ser accesible por administradores.
         *
         * @return lista completa de todos los pedidos
         */
        public List<OrderResponse> getAllOrders() {
                return orderRepository.findAllByOrderByCreadoEnDesc().stream()
                                .map(this::toResponse)
                                .toList();
        }

        /**
         * Actualiza el estado de un pedido existente.
         * Solo debe ser accesible por administradores.
         *
         * @param id      el identificador del pedido a actualizar
         * @param request el DTO con el nuevo estado del pedido
         * @return los datos actualizados del pedido
         * @throws RuntimeException si el pedido no existe o el estado es inválido
         */
        @Transactional
        public OrderResponse updateOrderStatus(Long id, UpdateStatusRequest request) {
                Order order = orderRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Pedido no encontrado con id: " + id));

                try {
                        // Convertir el texto del estado al enum OrderStatus
                        OrderStatus newStatus = OrderStatus.valueOf(request.getEstado().toUpperCase());
                        order.setEstado(newStatus);
                } catch (IllegalArgumentException e) {
                        // El estado proporcionado no es válido
                        throw new RuntimeException("Estado inválido: " + request.getEstado()
                                        + ". Valores válidos: PENDIENTE, CONFIRMADO, EN_PREPARACION, ENVIADO, ENTREGADO, CANCELADO");
                }

                return toResponse(orderRepository.save(order));
        }

        /**
         * Obtiene el usuario actualmente autenticado desde el contexto de seguridad de
         * Spring.
         *
         * @return la entidad {@link User} del usuario autenticado
         * @throws RuntimeException si el usuario no se encuentra en la base de datos
         */
        private User getCurrentUser() {
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                String email = auth.getName();
                return userRepository.findByEmail(email)
                                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        }

        /**
         * Convierte una entidad {@link Order} a su representación DTO
         * {@link OrderResponse}.
         * Incluye la conversión de cada ítem del pedido a {@link OrderItemResponse}.
         *
         * @param o la entidad pedido a convertir
         * @return el DTO de respuesta con los datos completos del pedido
         */
        private OrderResponse toResponse(Order o) {
                // Convertir cada ítem del pedido a su DTO de respuesta
                List<OrderItemResponse> itemResponses = o.getItems().stream()
                                .map(item -> OrderItemResponse.builder()
                                                .productoId(item.getProduct().getId())
                                                .productoNombre(item.getProduct().getNombre())
                                                .cantidad(item.getCantidad())
                                                .precioUnitario(item.getPrecioUnitario())
                                                .subtotal(item.getSubtotal())
                                                .build())
                                .toList();

                // Construir la respuesta completa del pedido con datos del cliente
                return OrderResponse.builder()
                                .id(o.getId())
                                .estado(o.getEstado().name())
                                .total(o.getTotal())
                                .direccionEntrega(o.getDireccionEntrega())
                                .notas(o.getNotas())
                                .items(itemResponses)
                                .clienteNombre(o.getUser().getNombre())
                                .clienteEmail(o.getUser().getEmail())
                                .creadoEn(o.getCreadoEn())
                                .build();
        }
}
