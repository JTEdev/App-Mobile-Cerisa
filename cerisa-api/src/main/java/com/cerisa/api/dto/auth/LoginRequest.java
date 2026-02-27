package com.cerisa.api.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO de solicitud para el inicio de sesión de usuarios.
 * <p>
 * Contiene las credenciales necesarias para autenticarse:
 * correo electrónico y contraseña. Ambos campos son obligatorios
 * y se validan mediante anotaciones de Jakarta Validation.
 * </p>
 * <p>
 * Endpoint: {@code POST /api/auth/login}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
public class LoginRequest {

    /** Correo electrónico del usuario. Obligatorio y debe tener formato válido. */
    @NotBlank(message = "El email es obligatorio")
    @Email(message = "Email inválido")
    private String email;

    /** Contraseña del usuario. Obligatoria, mínimo 6 caracteres. */
    @NotBlank(message = "La contraseña es obligatoria")
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String password;
}
