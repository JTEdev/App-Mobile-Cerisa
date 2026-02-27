package com.cerisa.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/**
 * Entidad JPA que representa a un usuario del sistema Cerisa.
 * <p>
 * Cada usuario tiene un nombre, correo electrónico único, contraseña cifrada,
 * un rol (CLIENTE o ADMIN), y opcionalmente un número de teléfono.
 * Se mapea a la tabla {@code users} en la base de datos.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    /**
     * Identificador único del usuario, generado automáticamente por la base de
     * datos.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Nombre completo del usuario. Obligatorio, máximo 100 caracteres. */
    @Column(nullable = false, length = 100)
    private String nombre;

    /**
     * Correo electrónico del usuario. Obligatorio y único, máximo 150 caracteres.
     */
    @Column(nullable = false, unique = true, length = 150)
    private String email;

    /** Contraseña del usuario cifrada con BCrypt. Obligatoria. */
    @Column(nullable = false)
    private String password;

    /**
     * Rol del usuario en el sistema (CLIENTE o ADMIN). Se almacena como texto en la
     * BD.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role rol;

    /** Número de teléfono del usuario. Opcional, máximo 20 caracteres. */
    @Column(length = 20)
    private String telefono;

    /**
     * Fecha y hora de creación del registro. No se puede modificar después de
     * crearse.
     */
    @Column(updatable = false)
    private LocalDateTime creadoEn;

    /** Fecha y hora de la última actualización del registro. */
    private LocalDateTime actualizadoEn;

    /**
     * Callback de JPA que se ejecuta antes de insertar un nuevo usuario en la base
     * de datos.
     * Establece las fechas de creación y actualización al momento actual,
     * y asigna el rol CLIENTE por defecto si no se ha especificado uno.
     */
    @PrePersist
    protected void onCreate() {
        creadoEn = LocalDateTime.now();
        actualizadoEn = LocalDateTime.now();
        // Si no se especificó un rol, asignar CLIENTE por defecto
        if (rol == null)
            rol = Role.CLIENTE;
    }

    /**
     * Callback de JPA que se ejecuta antes de actualizar un usuario existente.
     * Actualiza la fecha de última modificación al momento actual.
     */
    @PreUpdate
    protected void onUpdate() {
        actualizadoEn = LocalDateTime.now();
    }
}
