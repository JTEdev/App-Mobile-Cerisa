package com.cerisa.api.service;

import com.cerisa.api.dto.user.CreateUserRequest;
import com.cerisa.api.dto.user.UpdateUserRoleRequest;
import com.cerisa.api.dto.user.UserResponse;
import com.cerisa.api.entity.Role;
import com.cerisa.api.entity.User;
import com.cerisa.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio de gestión de usuarios para el panel de administración.
 * <p>
 * Proporciona operaciones para listar, consultar, actualizar el rol
 * y eliminar usuarios del sistema. Solo debe ser accedido por
 * usuarios con rol ADMIN a través del
 * {@link com.cerisa.api.controller.UserController}.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class UserService {

    /** Repositorio para acceder a los datos de usuarios en la base de datos. */
    private final UserRepository userRepository;

    /** Encoder para cifrar contraseñas. */
    private final PasswordEncoder passwordEncoder;

    /**
     * Obtiene la lista de todos los usuarios registrados en el sistema.
     *
     * @return lista de {@link UserResponse} con los datos públicos de cada usuario
     */
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Busca un usuario por su identificador único.
     *
     * @param id el identificador del usuario a buscar
     * @return {@link UserResponse} con los datos del usuario encontrado
     * @throws RuntimeException si no se encuentra un usuario con el ID
     *                          proporcionado
     */
    public UserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + id));
        return toResponse(user);
    }

    /**
     * Actualiza el rol de un usuario existente.
     * <p>
     * Permite cambiar entre los roles ADMIN y CLIENTE.
     * Lanza una excepción si el usuario no existe.
     * </p>
     *
     * @param id      el identificador del usuario a actualizar
     * @param request el DTO con el nuevo rol a asignar
     * @return {@link UserResponse} con los datos actualizados del usuario
     * @throws RuntimeException si no se encuentra el usuario con el ID dado
     */
    public UserResponse updateUserRole(Long id, UpdateUserRoleRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + id));

        user.setRol(Role.valueOf(request.getRol()));
        User updated = userRepository.save(user);
        return toResponse(updated);
    }

    /**
     * Crea un nuevo usuario con rol CLIENTE desde el panel de administración.
     *
     * @param request datos del nuevo cliente
     * @return {@link UserResponse} con los datos del usuario creado
     * @throws RuntimeException si el email ya está registrado
     */
    public UserResponse createUser(CreateUserRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Ya existe un usuario con el email: " + request.getEmail());
        }

        User user = new User();
        user.setNombre(request.getNombre());
        user.setEmail(request.getEmail());
        user.setTelefono(request.getTelefono());
        user.setRol(Role.CLIENTE);

        // Si no se proporciona contraseña, generar una por defecto
        String rawPassword = request.getPassword() != null && !request.getPassword().isBlank()
                ? request.getPassword()
                : "Cerisa2026";
        user.setPassword(passwordEncoder.encode(rawPassword));

        User saved = userRepository.save(user);
        return toResponse(saved);
    }

    /**
     * Actualiza los datos de un usuario existente (nombre, teléfono).
     *
     * @param id      el identificador del usuario
     * @param request datos actualizados
     * @return {@link UserResponse} con los datos actualizados
     */
    public UserResponse updateUser(Long id, CreateUserRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + id));

        user.setNombre(request.getNombre());
        if (request.getTelefono() != null) {
            user.setTelefono(request.getTelefono());
        }
        if (request.getEmail() != null && !request.getEmail().isBlank()) {
            // Verificar que el nuevo email no esté en uso por otro usuario
            userRepository.findByEmail(request.getEmail()).ifPresent(existing -> {
                if (!existing.getId().equals(id)) {
                    throw new RuntimeException("Ya existe un usuario con el email: " + request.getEmail());
                }
            });
            user.setEmail(request.getEmail());
        }

        User updated = userRepository.save(user);
        return toResponse(updated);
    }

    /**
     * Elimina permanentemente un usuario del sistema.
     * <p>
     * ⚠️ Esta operación es irreversible. Se eliminan también los datos
     * asociados según las reglas de cascada de la base de datos.
     * </p>
     *
     * @param id el identificador del usuario a eliminar
     * @throws RuntimeException si no se encuentra el usuario con el ID dado
     */
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("Usuario no encontrado con ID: " + id);
        }
        userRepository.deleteById(id);
    }

    /**
     * Convierte una entidad {@link User} al DTO {@link UserResponse}.
     * <p>
     * Transforma los datos de la entidad JPA al formato de respuesta
     * seguro que no incluye la contraseña del usuario.
     * </p>
     *
     * @param user la entidad de usuario a convertir
     * @return el DTO con los datos públicos del usuario
     */
    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .nombre(user.getNombre())
                .email(user.getEmail())
                .rol(user.getRol().name())
                .telefono(user.getTelefono())
                .creadoEn(user.getCreadoEn())
                .actualizadoEn(user.getActualizadoEn())
                .build();
    }
}
