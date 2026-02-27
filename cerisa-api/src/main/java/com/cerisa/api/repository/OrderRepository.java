package com.cerisa.api.repository;

import com.cerisa.api.entity.Order;
import com.cerisa.api.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repositorio JPA para la entidad {@link Order}.
 * <p>
 * Además de las operaciones CRUD estándar, proporciona consultas personalizadas
 * para obtener pedidos por usuario, por estado, por rango de fechas,
 * y funciones de agregación (conteo y suma) para la generación de reportes.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public interface OrderRepository extends JpaRepository<Order, Long> {

    /**
     * Obtiene todos los pedidos de un usuario ordenados por fecha de creación
     * descendente.
     *
     * @param userId el identificador del usuario
     * @return lista de pedidos del usuario, del más reciente al más antiguo
     */
    List<Order> findByUserIdOrderByCreadoEnDesc(Long userId);

    /**
     * Obtiene todos los pedidos que se encuentran en un estado específico.
     *
     * @param estado el estado de los pedidos a buscar
     * @return lista de pedidos con el estado indicado
     */
    List<Order> findByEstado(OrderStatus estado);

    /**
     * Obtiene todos los pedidos ordenados por fecha de creación descendente.
     *
     * @return lista completa de pedidos ordenados del más reciente al más antiguo
     */
    List<Order> findAllByOrderByCreadoEnDesc();

    /**
     * Consulta JPQL: obtiene los pedidos creados dentro de un rango de fechas.
     *
     * @param desde fecha y hora de inicio del rango (inclusiva)
     * @param hasta fecha y hora de fin del rango (inclusiva)
     * @return lista de pedidos dentro del rango de fechas
     */
    @Query("SELECT o FROM Order o WHERE o.creadoEn >= :desde AND o.creadoEn <= :hasta")
    List<Order> findByFechaRange(@Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta);

    /**
     * Consulta JPQL: cuenta el número total de pedidos creados dentro de un rango
     * de fechas.
     * Utilizado para generar reportes diarios y mensuales.
     *
     * @param desde fecha y hora de inicio del rango (inclusiva)
     * @param hasta fecha y hora de fin del rango (inclusiva)
     * @return el número total de pedidos en el rango
     */
    @Query("SELECT COUNT(o) FROM Order o WHERE o.creadoEn >= :desde AND o.creadoEn <= :hasta")
    Long countByFechaRange(@Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta);

    /**
     * Consulta JPQL: calcula la suma total de ventas (campo total) de los pedidos
     * creados dentro de un rango de fechas, excluyendo los pedidos cancelados.
     *
     * @param desde fecha y hora de inicio del rango (inclusiva)
     * @param hasta fecha y hora de fin del rango (inclusiva)
     * @return la suma total de ventas, o {@code null} si no hay pedidos en el rango
     */
    @Query("SELECT SUM(o.total) FROM Order o WHERE o.creadoEn >= :desde AND o.creadoEn <= :hasta AND o.estado <> 'CANCELADO'")
    java.math.BigDecimal sumTotalByFechaRange(@Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta);
}
