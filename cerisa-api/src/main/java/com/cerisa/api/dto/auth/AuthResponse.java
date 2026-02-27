package com.cerisa.api.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de respuesta de autenticación exitosa.
 * <p>
 * Se retorna tanto en el login como en el registro exitoso.
 * Contiene el token JWT para uso en solicitudes posteriores
 * y los datos básicos del usuario autenticado.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    /** Token JWT generado para el usuario autenticado. */
    private String token;

    /** Tipo de token (siempre "Bearer"). Se usa en el encabezado Authorization. */
    private String tipo;

    /** Correo electrónico del usuario autenticado. */
    private String email;

    /** Nombre completo del usuario autenticado. */
    private String nombre;

    /** Rol del usuario autenticado (CLIENTE o ADMIN). */
    private String rol;
}
