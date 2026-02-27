package com.cerisa.api.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de solicitud para cambiar el rol de un usuario.
 * <p>
 * Solo acepta los valores "ADMIN" o "CLIENTE" como rol válido.
 * Se usa en el endpoint PUT /api/users/{id}/role (solo ADMIN).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRoleRequest {

    /**
     * Nuevo rol a asignar al usuario.
     * Debe ser "ADMIN" o "CLIENTE".
     */
    @NotBlank(message = "El rol es obligatorio")
    @Pattern(regexp = "ADMIN|CLIENTE", message = "El rol debe ser ADMIN o CLIENTE")
    private String rol;
}
