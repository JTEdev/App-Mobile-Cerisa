package com.cerisa.api.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * DTO (Data Transfer Object) que representa el formato estándar de error
 * retornado por la API REST de Cerisa.
 * <p>
 * Se utiliza en el manejador global de excepciones
 * ({@code GlobalExceptionHandler})
 * para enviar respuestas de error uniformes al cliente. Los campos nulos
 * se omiten de la serialización JSON gracias a {@link JsonInclude}.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiError {

    /** Código de estado HTTP del error (ej: 400, 401, 403, 500). */
    private int status;

    /** Mensaje descriptivo del error en español. */
    private String mensaje;

    /**
     * Mapa de errores de validación: campo → mensaje de error. Solo presente en
     * errores 400.
     */
    private Map<String, String> errores;

    /**
     * Marca de tiempo del momento en que ocurrió el error. Se establece
     * automáticamente.
     */
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();
}
