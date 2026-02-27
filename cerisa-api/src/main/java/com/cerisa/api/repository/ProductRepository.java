package com.cerisa.api.repository;

import com.cerisa.api.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/**
 * Repositorio JPA para la entidad {@link Product}.
 * <p>
 * Proporciona operaciones CRUD estándar y métodos personalizados para consultar
 * productos activos y filtrar por categoría. Los productos inactivos
 * (eliminación
 * lógica) se excluyen de las consultas del catálogo público.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public interface ProductRepository extends JpaRepository<Product, Long> {

    /**
     * Obtiene todos los productos que están activos (no eliminados lógicamente).
     *
     * @return lista de productos activos
     */
    List<Product> findByActivoTrue();

    /**
     * Obtiene todos los productos de una categoría específica (incluye activos e
     * inactivos).
     *
     * @param categoria el nombre de la categoría a filtrar
     * @return lista de productos de esa categoría
     */
    List<Product> findByCategoria(String categoria);

    /**
     * Obtiene todos los productos activos de una categoría específica.
     *
     * @param categoria el nombre de la categoría a filtrar
     * @return lista de productos activos de esa categoría
     */
    List<Product> findByCategoriaAndActivoTrue(String categoria);
}
