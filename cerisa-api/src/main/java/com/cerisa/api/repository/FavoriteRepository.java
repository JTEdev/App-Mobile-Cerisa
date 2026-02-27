package com.cerisa.api.repository;

import com.cerisa.api.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio JPA para la entidad {@link Favorite}.
 * <p>
 * Proporciona métodos para consultar y gestionar los productos
 * favoritos de cada usuario. Las consultas se generan automáticamente
 * a partir de los nombres de los métodos (query derivation).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    /**
     * Obtiene todos los favoritos de un usuario específico.
     *
     * @param userId el ID del usuario
     * @return lista de favoritos del usuario
     */
    List<Favorite> findByUserId(Long userId);

    /**
     * Busca un favorito específico por usuario y producto.
     *
     * @param userId    el ID del usuario
     * @param productId el ID del producto
     * @return un {@link Optional} con el favorito encontrado, o vacío si no existe
     */
    Optional<Favorite> findByUserIdAndProductId(Long userId, Long productId);

    /**
     * Verifica si un usuario ya tiene un producto como favorito.
     *
     * @param userId    el ID del usuario
     * @param productId el ID del producto
     * @return {@code true} si el producto ya es favorito del usuario
     */
    boolean existsByUserIdAndProductId(Long userId, Long productId);

    /**
     * Elimina el favorito de un usuario para un producto específico.
     *
     * @param userId    el ID del usuario
     * @param productId el ID del producto
     */
    void deleteByUserIdAndProductId(Long userId, Long productId);
}
