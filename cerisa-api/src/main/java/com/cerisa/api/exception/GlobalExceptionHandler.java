package com.cerisa.api.exception;

import com.cerisa.api.dto.ApiError;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

/**
 * Manejador global de excepciones para toda la API REST de Cerisa.
 * <p>
 * Intercepta las excepciones lanzadas por los controladores y las convierte
 * en respuestas HTTP uniformes utilizando el formato {@link ApiError}.
 * Esto asegura que el cliente siempre reciba errores en un formato consistente.
 * </p>
 * <p>
 * Excepciones manejadas:
 * <ul>
 * <li><b>MethodArgumentNotValidException:</b> Errores de validación de campos
 * (400)</li>
 * <li><b>BadCredentialsException:</b> Credenciales inválidas en login
 * (401)</li>
 * <li><b>AccessDeniedException:</b> Acceso denegado por falta de permisos
 * (403)</li>
 * <li><b>RuntimeException:</b> Errores de lógica de negocio (400)</li>
 * <li><b>Exception:</b> Cualquier otro error no previsto (500)</li>
 * </ul>
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Maneja errores de validación de campos (Jakarta Validation).
     * Retorna un mapa con cada campo inválido y su mensaje de error.
     *
     * @param ex la excepción con los errores de validación
     * @return respuesta HTTP 400 con los detalles de cada campo inválido
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException ex) {
        // Recopilar los errores de cada campo en un mapa campo -> mensaje
        Map<String, String> errores = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String campo = ((FieldError) error).getField();
            String mensaje = error.getDefaultMessage();
            errores.put(campo, mensaje);
        });

        ApiError apiError = ApiError.builder()
                .status(HttpStatus.BAD_REQUEST.value())
                .mensaje("Error de validación")
                .errores(errores)
                .build();

        return ResponseEntity.badRequest().body(apiError);
    }

    /**
     * Maneja errores de credenciales inválidas durante el proceso de login.
     *
     * @param ex la excepción de credenciales inválidas
     * @return respuesta HTTP 401 (Unauthorized)
     */
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ApiError> handleBadCredentials(BadCredentialsException ex) {
        ApiError apiError = ApiError.builder()
                .status(HttpStatus.UNAUTHORIZED.value())
                .mensaje("Credenciales inválidas")
                .build();

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(apiError);
    }

    /**
     * Maneja errores de acceso denegado cuando el usuario no tiene permisos
     * suficientes.
     *
     * @param ex la excepción de acceso denegado
     * @return respuesta HTTP 403 (Forbidden)
     */
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiError> handleAccessDenied(AccessDeniedException ex) {
        ApiError apiError = ApiError.builder()
                .status(HttpStatus.FORBIDDEN.value())
                .mensaje("No tienes permiso para realizar esta acción")
                .build();

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(apiError);
    }

    /**
     * Maneja excepciones de tiempo de ejecución (errores de lógica de negocio).
     * Incluye casos como: producto no encontrado, stock insuficiente, email
     * duplicado, etc.
     *
     * @param ex la excepción de runtime con el mensaje descriptivo del error
     * @return respuesta HTTP 400 (Bad Request) con el mensaje del error
     */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiError> handleRuntime(RuntimeException ex) {
        ApiError apiError = ApiError.builder()
                .status(HttpStatus.BAD_REQUEST.value())
                .mensaje(ex.getMessage())
                .build();

        return ResponseEntity.badRequest().body(apiError);
    }

    /**
     * Maneja cualquier excepción no prevista por los demás manejadores.
     * Retorna un mensaje genérico para no exponer detalles internos al cliente.
     *
     * @param ex la excepción general no manejada
     * @return respuesta HTTP 500 (Internal Server Error)
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleGeneral(Exception ex) {
        ApiError apiError = ApiError.builder()
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .mensaje("Error interno del servidor")
                .build();

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(apiError);
    }
}
