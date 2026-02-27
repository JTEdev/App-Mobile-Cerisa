package com.cerisa.api.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO de solicitud para el registro de nuevos usuarios en el sistema.
 * <p>
 * Contiene los datos necesarios para crear una nueva cuenta:
 * nombre, correo electrónico, contraseña y opcionalmente teléfono.
 * Todos los campos obligatorios se validan con Jakarta Validation.
 * </p>
 * <p>
 * Endpoint: {@code POST /api/auth/register}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
public class RegisterRequest {

    /** Nombre completo del usuario. Obligatorio, entre 2 y 100 caracteres. */
    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 2, max = 100, message = "El nombre debe tener entre 2 y 100 caracteres")
    private String nombre;

    /**
     * Correo electrónico del usuario. Obligatorio, debe tener formato válido y ser
     * único.
     */
    @NotBlank(message = "El email es obligatorio")
    @Email(message = "Email inválido")
    private String email;

    /**
     * Contraseña del usuario. Obligatoria, mínimo 6 caracteres. Se cifrará con
     * BCrypt.
     */
    @NotBlank(message = "La contraseña es obligatoria")
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String password;

    /** Número de teléfono del usuario. Opcional. */
    private String telefono;
}
