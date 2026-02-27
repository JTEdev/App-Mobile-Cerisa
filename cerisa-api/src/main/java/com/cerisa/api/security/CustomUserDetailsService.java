package com.cerisa.api.security;

import com.cerisa.api.entity.User;
import com.cerisa.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Implementación personalizada de {@link UserDetailsService} para Spring
 * Security.
 * <p>
 * Carga los datos del usuario desde la base de datos utilizando el correo
 * electrónico
 * como identificador. Convierte la entidad {@link User} del sistema en un
 * objeto
 * {@link UserDetails} que Spring Security utiliza para la autenticación y
 * autorización.
 * </p>
 * <p>
 * El rol del usuario se convierte al formato esperado por Spring Security
 * con el prefijo "ROLE_" (ej: ROLE_ADMIN, ROLE_CLIENTE).
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    /** Repositorio para acceder a los datos de usuarios en la base de datos. */
    private final UserRepository userRepository;

    /**
     * Carga un usuario desde la base de datos por su correo electrónico.
     * <p>
     * Busca al usuario en la BD y lo convierte a un objeto {@link UserDetails}
     * con su email como username, su contraseña cifrada y su rol con prefijo
     * "ROLE_".
     * </p>
     *
     * @param email el correo electrónico del usuario a buscar
     * @return los detalles del usuario para Spring Security
     * @throws UsernameNotFoundException si no se encuentra un usuario con ese email
     */
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // Buscar el usuario en la base de datos por su email
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado con email: " + email));

        // Construir el objeto UserDetails con el rol en formato Spring Security
        // (ROLE_XXXX)
        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                List.of(new SimpleGrantedAuthority("ROLE_" + user.getRol().name())));
    }
}
