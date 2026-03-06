package com.cerisa.api.dto.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO para la creación de clientes desde el panel de administración.
 */
@Data
public class CreateUserRequest {

  @NotBlank(message = "El nombre es obligatorio")
  @Size(min = 2, max = 100, message = "El nombre debe tener entre 2 y 100 caracteres")
  private String nombre;

  @NotBlank(message = "El email es obligatorio")
  @Email(message = "Email inválido")
  private String email;

  @Size(max = 20, message = "El teléfono no puede tener más de 20 caracteres")
  private String telefono;

  @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
  private String password;
}
