package com.cerisa.api.service;

import com.cerisa.api.dto.product.ProductResponse;
import com.cerisa.api.entity.Favorite;
import com.cerisa.api.entity.Product;
import com.cerisa.api.entity.User;
import com.cerisa.api.repository.FavoriteRepository;
import com.cerisa.api.repository.ProductRepository;
import com.cerisa.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio de gestión de productos favoritos.
 * <p>
 * Permite a los usuarios agregar, quitar y consultar sus productos favoritos.
 * Los favoritos se almacenan en la tabla {@code favorites} con una relación
 * única entre usuario y producto (no se puede duplicar un favorito).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class FavoriteService {

    /** Repositorio de favoritos. */
    private final FavoriteRepository favoriteRepository;

    /** Repositorio de usuarios para validar existencia. */
    private final UserRepository userRepository;

    /** Repositorio de productos para validar existencia. */
    private final ProductRepository productRepository;

    /**
     * Obtiene la lista de productos favoritos de un usuario.
     *
     * @param userId el ID del usuario autenticado
     * @return lista de {@link ProductResponse} con los productos favoritos
     */
    public List<ProductResponse> getFavorites(Long userId) {
        return favoriteRepository.findByUserId(userId)
                .stream()
                .map(fav -> toProductResponse(fav.getProduct()))
                .collect(Collectors.toList());
    }

    /**
     * Agrega un producto a los favoritos del usuario.
     * <p>
     * Si el producto ya es favorito, no se duplica (no lanza error).
     * </p>
     *
     * @param userId    el ID del usuario autenticado
     * @param productId el ID del producto a agregar
     * @throws RuntimeException si el usuario o producto no existe
     */
    public void addFavorite(Long userId, Long productId) {
        // Verificar que no exista ya
        if (favoriteRepository.existsByUserIdAndProductId(userId, productId)) {
            return; // Ya es favorito, no hacer nada
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

        Favorite favorite = Favorite.builder()
                .user(user)
                .product(product)
                .build();

        favoriteRepository.save(favorite);
    }

    /**
     * Elimina un producto de los favoritos del usuario.
     *
     * @param userId    el ID del usuario autenticado
     * @param productId el ID del producto a quitar de favoritos
     */
    @Transactional
    public void removeFavorite(Long userId, Long productId) {
        favoriteRepository.deleteByUserIdAndProductId(userId, productId);
    }

    /**
     * Verifica si un producto está en los favoritos del usuario.
     *
     * @param userId    el ID del usuario
     * @param productId el ID del producto
     * @return {@code true} si el producto es favorito del usuario
     */
    public boolean isFavorite(Long userId, Long productId) {
        return favoriteRepository.existsByUserIdAndProductId(userId, productId);
    }

    /**
     * Convierte una entidad {@link Product} al DTO {@link ProductResponse}.
     *
     * @param product la entidad de producto
     * @return el DTO de respuesta
     */
    private ProductResponse toProductResponse(Product product) {
        return ProductResponse.builder()
                .id(product.getId())
                .nombre(product.getNombre())
                .descripcion(product.getDescripcion())
                .precio(product.getPrecio())
                .stock(product.getStock())
                .categoria(product.getCategoria())
                .imagenUrl(product.getImagenUrl())
                .activo(product.getActivo())
                .build();
    }
}
