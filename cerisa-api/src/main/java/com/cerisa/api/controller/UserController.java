package com.cerisa.api.controller;

import com.cerisa.api.dto.user.CreateUserRequest;
import com.cerisa.api.dto.user.UpdateUserRoleRequest;
import com.cerisa.api.dto.user.UserResponse;
import com.cerisa.api.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión de usuarios del sistema.
 * <p>
 * Proporciona endpoints CRUD para administración de usuarios.
 * Todos los endpoints requieren rol ADMIN (configurado en
 * {@link com.cerisa.api.security.SecurityConfig}).
 * </p>
 * <p>
 * Endpoints disponibles:
 * <ul>
 * <li><b>GET /api/users</b> - Listar todos los usuarios</li>
 * <li><b>GET /api/users/{id}</b> - Obtener un usuario por ID</li>
 * <li><b>PUT /api/users/{id}/role</b> - Cambiar el rol de un usuario</li>
 * <li><b>DELETE /api/users/{id}</b> - Eliminar un usuario</li>
 * </ul>
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    /** Servicio de gestión de usuarios inyectado por Spring. */
    private final UserService userService;

    /**
     * Obtiene la lista de todos los usuarios registrados.
     * <p>
     * Los datos sensibles (contraseña) no se incluyen en la respuesta.
     * </p>
     *
     * @return lista de {@link UserResponse} con código 200 (OK)
     */
    @GetMapping
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    /**
     * Obtiene los datos de un usuario específico por su ID.
     *
     * @param id el identificador del usuario a consultar
     * @return {@link UserResponse} con código 200 (OK)
     * @throws RuntimeException si el usuario no existe (manejado por
     *                          GlobalExceptionHandler → 400)
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    /**
     * Actualiza el rol de un usuario existente.
     * <p>
     * Permite asignar el rol ADMIN o CLIENTE a cualquier usuario del sistema.
     * Se requiere enviar un JSON con el campo "rol" válido.
     * </p>
     *
     * @param id      el identificador del usuario a actualizar
     * @param request el cuerpo de la solicitud con el nuevo rol
     * @return {@link UserResponse} actualizado con código 200 (OK)
     * @throws RuntimeException si el usuario no existe
     */
    @PutMapping("/{id}/role")
    public ResponseEntity<UserResponse> updateUserRole(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRoleRequest request) {
        return ResponseEntity.ok(userService.updateUserRole(id, request));
    }

    /**
     * Elimina permanentemente un usuario del sistema.
     * <p>
     * ⚠️ Operación irreversible. Solo administradores pueden ejecutarla.
     * </p>
     *
     * @param id el identificador del usuario a eliminar
     * @return respuesta vacía con código 204 (No Content)
     * @throws RuntimeException si el usuario no existe
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Crea un nuevo cliente desde el panel de administración.
     */
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.ok(userService.createUser(request));
    }

    /**
     * Actualiza los datos de un usuario (nombre, teléfono, email).
     */
    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.ok(userService.updateUser(id, request));
    }
}
