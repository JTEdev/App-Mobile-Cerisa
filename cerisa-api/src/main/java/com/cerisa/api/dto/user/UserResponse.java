package com.cerisa.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO de respuesta con los datos públicos de un usuario.
 * <p>
 * Se utiliza para devolver información de usuarios al cliente
 * sin exponer datos sensibles como la contraseña cifrada.
 * Es retornado por los endpoints de gestión de usuarios (solo ADMIN).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    /** Identificador único del usuario. */
    private Long id;

    /** Nombre completo del usuario. */
    private String nombre;

    /** Correo electrónico del usuario. */
    private String email;

    /** Rol del usuario en el sistema (CLIENTE o ADMIN). */
    private String rol;

    /** Número de teléfono del usuario (puede ser null). */
    private String telefono;

    /** Fecha y hora de registro del usuario. */
    private LocalDateTime creadoEn;

    /** Fecha y hora de la última actualización del perfil. */
    private LocalDateTime actualizadoEn;
}
