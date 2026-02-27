package com.cerisa.api.service;

import com.cerisa.api.dto.auth.AuthResponse;
import com.cerisa.api.dto.auth.LoginRequest;
import com.cerisa.api.dto.auth.RegisterRequest;
import com.cerisa.api.entity.Role;
import com.cerisa.api.entity.User;
import com.cerisa.api.repository.UserRepository;
import com.cerisa.api.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Servicio de autenticación que gestiona el inicio de sesión y registro de
 * usuarios.
 * <p>
 * Proporciona dos operaciones principales:
 * <ul>
 * <li><b>Login:</b> Verifica las credenciales con BCrypt y genera un token
 * JWT.</li>
 * <li><b>Registro:</b> Crea un nuevo usuario con rol CLIENTE y realiza
 * auto-login.</li>
 * </ul>
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class AuthService {

        /** Repositorio para acceder a los datos de usuarios. */
        private final UserRepository userRepository;

        /** Codificador de contraseñas BCrypt. */
        private final PasswordEncoder passwordEncoder;

        /** Gestor de autenticación de Spring Security. */
        private final AuthenticationManager authenticationManager;

        /** Proveedor JWT para generar tokens. */
        private final JwtTokenProvider jwtTokenProvider;

        /**
         * Autentica a un usuario con sus credenciales (email y contraseña).
         * <p>
         * Utiliza el {@link AuthenticationManager} de Spring Security para verificar
         * las credenciales. Si son válidas, genera un token JWT y retorna
         * los datos del usuario autenticado.
         * </p>
         *
         * @param request el DTO con el email y contraseña del usuario
         * @return respuesta con el token JWT y datos del usuario
         * @throws RuntimeException                                                    si
         *                                                                             el
         *                                                                             usuario
         *                                                                             no
         *                                                                             se
         *                                                                             encuentra
         *                                                                             en
         *                                                                             la
         *                                                                             base
         *                                                                             de
         *                                                                             datos
         * @throws org.springframework.security.authentication.BadCredentialsException si
         *                                                                             las
         *                                                                             credenciales
         *                                                                             son
         *                                                                             inválidas
         */
        public AuthResponse login(LoginRequest request) {
                // Autenticar al usuario con Spring Security (verifica contraseña con BCrypt)
                Authentication authentication = authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

                // Generar el token JWT a partir de la autenticación exitosa
                String token = jwtTokenProvider.generateToken(authentication);

                // Obtener los datos del usuario desde la base de datos
                User user = userRepository.findByEmail(request.getEmail())
                                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

                // Construir y retornar la respuesta con el token y datos del usuario
                return AuthResponse.builder()
                                .token(token)
                                .tipo("Bearer")
                                .email(user.getEmail())
                                .nombre(user.getNombre())
                                .rol(user.getRol().name())
                                .build();
        }

        /**
         * Registra un nuevo usuario en el sistema y realiza auto-login.
         * <p>
         * Verifica que el email no esté ya registrado, crea el usuario con
         * la contraseña cifrada con BCrypt y rol CLIENTE, lo guarda en la BD
         * y luego realiza autenticación automática para retornar un token JWT.
         * </p>
         *
         * @param request el DTO con nombre, email, contraseña y teléfono del nuevo
         *                usuario
         * @return respuesta con el token JWT y datos del usuario recién registrado
         * @throws RuntimeException si el email ya está registrado en el sistema
         */
        public AuthResponse register(RegisterRequest request) {
                // Verificar que el email no esté ya en uso
                if (userRepository.existsByEmail(request.getEmail())) {
                        throw new RuntimeException("El email ya está registrado");
                }

                // Construir la entidad usuario con la contraseña cifrada
                User user = User.builder()
                                .nombre(request.getNombre())
                                .email(request.getEmail())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .telefono(request.getTelefono())
                                .rol(Role.CLIENTE)
                                .build();

                // Guardar el usuario en la base de datos
                userRepository.save(user);

                // Auto-login: autenticar al usuario recién registrado para generar su token
                Authentication authentication = authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

                String token = jwtTokenProvider.generateToken(authentication);

                // Retornar la respuesta con el token y datos del usuario
                return AuthResponse.builder()
                                .token(token)
                                .tipo("Bearer")
                                .email(user.getEmail())
                                .nombre(user.getNombre())
                                .rol(user.getRol().name())
                                .build();
        }
}
