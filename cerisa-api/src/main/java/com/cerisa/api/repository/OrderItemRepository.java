package com.cerisa.api.repository;

import com.cerisa.api.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repositorio JPA para la entidad {@link OrderItem}.
 * <p>
 * Además de las operaciones CRUD estándar, proporciona una consulta
 * personalizada
 * JPQL para obtener los productos más vendidos agrupados por producto,
 * utilizada en la generación de reportes.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

       /**
        * Consulta JPQL que obtiene los productos más vendidos dentro de un rango de
        * fechas.
        * <p>
        * Agrupa los ítems de pedido por producto, suma las cantidades vendidas
        * y ordena de mayor a menor. Excluye los pedidos cancelados.
        * </p>
        * <p>
        * Cada elemento del resultado es un {@code Object[]} con:
        * <ul>
        * <li>[0] - {@code Long} productoId: ID del producto</li>
        * <li>[1] - {@code String} productoNombre: nombre del producto</li>
        * <li>[2] - {@code Long} totalVendido: cantidad total vendida</li>
        * </ul>
        * </p>
        *
        * @param desde fecha y hora de inicio del rango (inclusiva)
        * @param hasta fecha y hora de fin del rango (inclusiva)
        * @return lista de arreglos de objetos con los productos más vendidos
        */
       @Query("SELECT oi.product.id, oi.product.nombre, SUM(oi.cantidad) as totalVendido " +
                     "FROM OrderItem oi " +
                     "WHERE oi.order.creadoEn >= :desde AND oi.order.creadoEn <= :hasta " +
                     "AND oi.order.estado <> 'CANCELADO' " +
                     "GROUP BY oi.product.id, oi.product.nombre " +
                     "ORDER BY totalVendido DESC")
       List<Object[]> findTopProducts(@Param("desde") LocalDateTime desde,
                     @Param("hasta") LocalDateTime hasta);
}
