package com.cerisa.api.repository;

import com.cerisa.api.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

/**
 * Repositorio JPA para la entidad {@link User}.
 * <p>
 * Proporciona operaciones CRUD estándar heredadas de {@link JpaRepository}
 * y métodos personalizados para buscar usuarios por correo electrónico.
 * Es utilizado principalmente por los servicios de autenticación y seguridad.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Busca un usuario por su dirección de correo electrónico.
     *
     * @param email el correo electrónico del usuario a buscar
     * @return un {@link Optional} con el usuario encontrado, o vacío si no existe
     */
    Optional<User> findByEmail(String email);

    /**
     * Verifica si ya existe un usuario registrado con el correo electrónico dado.
     * Se utiliza durante el registro para evitar duplicados.
     *
     * @param email el correo electrónico a verificar
     * @return {@code true} si el email ya está registrado, {@code false} en caso
     *         contrario
     */
    boolean existsByEmail(String email);
}
