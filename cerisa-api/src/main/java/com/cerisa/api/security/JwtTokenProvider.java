package com.cerisa.api.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * Componente encargado de generar, firmar y validar tokens JWT (JSON Web
 * Token).
 * <p>
 * Utiliza el algoritmo HMAC-SHA para firmar los tokens con una clave secreta
 * configurada en las propiedades de la aplicación ({@code app.jwt.secret}).
 * El tiempo de expiración también es configurable
 * ({@code app.jwt.expiration-ms}).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Component
public class JwtTokenProvider {

    /** Clave secreta para firmar y verificar los tokens JWT. */
    private final SecretKey key;

    /** Tiempo de expiración del token en milisegundos. */
    private final long expirationMs;

    /**
     * Constructor que inicializa el proveedor JWT con la clave secreta y el tiempo
     * de expiración.
     *
     * @param secret       la clave secreta en texto plano (se convierte a SecretKey
     *                     HMAC)
     * @param expirationMs el tiempo de expiración del token en milisegundos
     */
    public JwtTokenProvider(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.expiration-ms}") long expirationMs) {
        // Convertir la clave secreta de texto plano a una SecretKey compatible con
        // HMAC-SHA
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs;
    }

    /**
     * Genera un token JWT a partir de la información de autenticación del usuario.
     * <p>
     * El token contiene el email del usuario como subject, la fecha de emisión
     * y la fecha de expiración calculada.
     * </p>
     *
     * @param authentication el objeto de autenticación de Spring Security
     * @return el token JWT firmado como cadena
     */
    public String generateToken(Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expirationMs);

        return Jwts.builder()
                .subject(userDetails.getUsername())
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(key)
                .compact();
    }

    /**
     * Extrae el nombre de usuario (email) del payload de un token JWT.
     *
     * @param token el token JWT del cual extraer el subject
     * @return el email del usuario contenido en el token
     */
    public String getUsernameFromToken(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }

    /**
     * Valida si un token JWT es válido (firma correcta y no expirado).
     *
     * @param token el token JWT a validar
     * @return {@code true} si el token es válido, {@code false} si es inválido o ha
     *         expirado
     */
    public boolean validateToken(String token) {
        try {
            // Intentar parsear y verificar el token; si falla, es inválido
            Jwts.parser().verifyWith(key).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
