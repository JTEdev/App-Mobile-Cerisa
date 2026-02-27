package com.cerisa.api.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configuración central de seguridad de la aplicación Cerisa.
 * <p>
 * Define las políticas de acceso a los endpoints de la API REST:
 * <ul>
 * <li><b>Públicos:</b> autenticación ({@code /api/auth/**}) y consulta de
 * productos (GET)</li>
 * <li><b>Solo ADMIN:</b> gestión de productos (POST/PUT/DELETE) y reportes</li>
 * <li><b>Autenticado:</b> pedidos y todo lo demás</li>
 * </ul>
 * </p>
 * <p>
 * La sesión es STATELESS (sin estado) ya que se usa autenticación basada en
 * JWT.
 * Se deshabilita CSRF porque la API no usa cookies de sesión.
 * El filtro JWT ({@link JwtAuthenticationFilter}) se ejecuta antes del filtro
 * estándar de autenticación de Spring.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    /** Filtro JWT que intercepta y valida los tokens en cada solicitud. */
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * Configura la cadena de filtros de seguridad HTTP.
     * <p>
     * Define las reglas de autorización para cada grupo de endpoints
     * y registra el filtro JWT en la cadena de seguridad.
     * </p>
     *
     * @param http el objeto {@link HttpSecurity} para configurar
     * @return la cadena de filtros de seguridad construida
     * @throws Exception si ocurre un error durante la configuración
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Deshabilitar CSRF ya que usamos JWT (sin cookies de sesión)
                .csrf(csrf -> csrf.disable())
                // Política de sesión sin estado (STATELESS) para autenticación basada en tokens
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // --- Auth endpoints: públicos (login y registro) ---
                        .requestMatchers("/api/auth/**").permitAll()

                        // --- Products: GET público, CUD solo admin ---
                        .requestMatchers(HttpMethod.GET, "/api/products/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/products/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/products/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/products/**").hasRole("ADMIN")

                        // --- Orders: requiere autenticación (cualquier rol) ---
                        .requestMatchers("/api/orders/**").authenticated()

                        // --- Favorites: requiere autenticación (cualquier rol) ---
                        .requestMatchers("/api/favorites/**").authenticated()

                        // --- Reports: solo administradores ---
                        .requestMatchers("/api/reports/**").hasRole("ADMIN")

                        // --- Users: solo administradores ---
                        .requestMatchers("/api/users/**").hasRole("ADMIN")

                        // --- Todo lo demás requiere autenticación ---
                        .anyRequest().authenticated())
                // Agregar el filtro JWT antes del filtro estándar de autenticación
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Define el codificador de contraseñas BCrypt utilizado para cifrar
     * y verificar las contraseñas de los usuarios.
     *
     * @return una instancia de {@link BCryptPasswordEncoder}
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Expone el {@link AuthenticationManager} de Spring Security como bean,
     * necesario para el proceso de autenticación manual en el servicio de login.
     *
     * @param config la configuración de autenticación de Spring
     * @return el gestor de autenticación configurado
     * @throws Exception si ocurre un error al obtener el gestor
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
