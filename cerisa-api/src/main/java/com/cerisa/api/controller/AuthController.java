package com.cerisa.api.controller;

import com.cerisa.api.dto.auth.AuthResponse;
import com.cerisa.api.dto.auth.LoginRequest;
import com.cerisa.api.dto.auth.RegisterRequest;
import com.cerisa.api.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST que expone los endpoints de autenticación.
 * <p>
 * Gestiona el inicio de sesión y el registro de nuevos usuarios.
 * Ambos endpoints son públicos (no requieren autenticación previa)
 * y retornan un token JWT junto con los datos del usuario.
 * </p>
 * <p>
 * Base URL: {@code /api/auth}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    /** Servicio de autenticación que maneja la lógica de login y registro. */
    private final AuthService authService;

    /**
     * Inicia sesión con las credenciales del usuario.
     * <p>
     * Endpoint público: {@code POST /api/auth/login}
     * </p>
     *
     * @param request el DTO con email y contraseña del usuario (validado)
     * @return respuesta HTTP 200 con el token JWT y datos del usuario
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    /**
     * Registra un nuevo usuario en el sistema y retorna su token JWT.
     * <p>
     * Endpoint público: {@code POST /api/auth/register}
     * </p>
     *
     * @param request el DTO con nombre, email, contraseña y teléfono (validado)
     * @return respuesta HTTP 200 con el token JWT y datos del usuario registrado
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }
}
