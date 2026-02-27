package com.cerisa.api.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filtro de autenticación JWT que se ejecuta una vez por cada solicitud HTTP.
 * <p>
 * Intercepta todas las solicitudes entrantes, extrae el token Bearer del
 * encabezado {@code Authorization}, lo valida y, si es válido, establece
 * la autenticación del usuario en el contexto de seguridad de Spring.
 * </p>
 * <p>
 * Extiende {@link OncePerRequestFilter} para garantizar una única ejecución
 * por solicitud, incluso en cadenas de filtros complejas.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    /** Proveedor JWT para validar tokens y extraer información del usuario. */
    private final JwtTokenProvider jwtTokenProvider;

    /** Servicio para cargar los detalles del usuario desde la base de datos. */
    private final UserDetailsService userDetailsService;

    /**
     * Logica principal del filtro. Se ejecuta en cada solicitud HTTP.
     * <p>
     * 1. Extrae el token del encabezado Authorization (formato "Bearer {token}").
     * 2. Valida el token con {@link JwtTokenProvider}.
     * 3. Si es válido, carga el usuario y establece la autenticación en el
     * contexto.
     * 4. Continúa con la cadena de filtros.
     * </p>
     *
     * @param request     la solicitud HTTP entrante
     * @param response    la respuesta HTTP saliente
     * @param filterChain la cadena de filtros a continuar
     * @throws ServletException si ocurre un error en el servlet
     * @throws IOException      si ocurre un error de entrada/salida
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        // Paso 1: Extraer el token JWT del encabezado Authorization
        String token = getTokenFromRequest(request);

        // Paso 2: Validar el token y establecer la autenticación si es válido
        if (StringUtils.hasText(token) && jwtTokenProvider.validateToken(token)) {
            // Obtener el email del usuario desde el token
            String username = jwtTokenProvider.getUsernameFromToken(token);
            // Cargar los detalles completos del usuario desde la BD
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            // Crear el objeto de autenticación con las autoridades del usuario
            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(userDetails, null,
                    userDetails.getAuthorities());
            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            // Establecer la autenticación en el contexto de seguridad
            SecurityContextHolder.getContext().setAuthentication(authToken);
        }

        // Paso 3: Continuar con la cadena de filtros
        filterChain.doFilter(request, response);
    }

    /**
     * Extrae el token JWT del encabezado Authorization de la solicitud HTTP.
     * El token debe tener el formato "Bearer {token_jwt}".
     *
     * @param request la solicitud HTTP de la cual extraer el token
     * @return el token JWT sin el prefijo "Bearer ", o {@code null} si no se
     *         encuentra
     */
    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        // Verificar que el encabezado existe y tiene el prefijo "Bearer "
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
