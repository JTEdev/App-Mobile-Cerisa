package com.cerisa.api.controller;

import com.cerisa.api.dto.product.ProductResponse;
import com.cerisa.api.entity.User;
import com.cerisa.api.repository.UserRepository;
import com.cerisa.api.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controlador REST para la gestión de productos favoritos.
 * <p>
 * Permite a los usuarios autenticados agregar, quitar y consultar
 * sus productos favoritos. Todos los endpoints requieren autenticación.
 * </p>
 * <p>
 * Endpoints disponibles:
 * <ul>
 * <li><b>GET /api/favorites</b> - Listar favoritos del usuario actual</li>
 * <li><b>POST /api/favorites/{productId}</b> - Agregar producto a
 * favoritos</li>
 * <li><b>DELETE /api/favorites/{productId}</b> - Quitar producto de
 * favoritos</li>
 * <li><b>GET /api/favorites/{productId}/check</b> - Verificar si un producto es
 * favorito</li>
 * </ul>
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    /** Servicio de favoritos inyectado por Spring. */
    private final FavoriteService favoriteService;

    /** Repositorio de usuarios para obtener el usuario actual. */
    private final UserRepository userRepository;

    /**
     * Obtiene la lista de productos favoritos del usuario autenticado.
     *
     * @return lista de {@link ProductResponse} con código 200 (OK)
     */
    @GetMapping
    public ResponseEntity<List<ProductResponse>> getFavorites() {
        Long userId = getCurrentUserId();
        return ResponseEntity.ok(favoriteService.getFavorites(userId));
    }

    /**
     * Agrega un producto a los favoritos del usuario.
     * <p>
     * Si el producto ya es favorito, la operación es idempotente (no duplica).
     * </p>
     *
     * @param productId el ID del producto a agregar
     * @return mensaje de confirmación con código 200 (OK)
     */
    @PostMapping("/{productId}")
    public ResponseEntity<Map<String, String>> addFavorite(@PathVariable Long productId) {
        Long userId = getCurrentUserId();
        favoriteService.addFavorite(userId, productId);
        return ResponseEntity.ok(Map.of("mensaje", "Producto agregado a favoritos"));
    }

    /**
     * Quita un producto de los favoritos del usuario.
     *
     * @param productId el ID del producto a quitar
     * @return respuesta vacía con código 204 (No Content)
     */
    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeFavorite(@PathVariable Long productId) {
        Long userId = getCurrentUserId();
        favoriteService.removeFavorite(userId, productId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Verifica si un producto está en los favoritos del usuario.
     *
     * @param productId el ID del producto a verificar
     * @return mapa con campo "favorito" (true/false) con código 200 (OK)
     */
    @GetMapping("/{productId}/check")
    public ResponseEntity<Map<String, Boolean>> checkFavorite(@PathVariable Long productId) {
        Long userId = getCurrentUserId();
        boolean isFav = favoriteService.isFavorite(userId, productId);
        return ResponseEntity.ok(Map.of("favorito", isFav));
    }

    /**
     * Obtiene el ID del usuario actualmente autenticado desde el contexto de
     * seguridad.
     *
     * @return el ID del usuario autenticado
     * @throws RuntimeException si el usuario no se encuentra en la base de datos
     */
    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return user.getId();
    }
}
