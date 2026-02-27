package com.cerisa.api.entity;

/**
 * Enumeración que define los roles disponibles para los usuarios del sistema
 * Cerisa.
 * <p>
 * Se utiliza en la entidad {@link User} para controlar el acceso a las
 * diferentes funcionalidades de la aplicación.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
public enum Role {

    /**
     * Rol de cliente: puede navegar el catálogo, realizar pedidos y ver su
     * historial.
     */
    CLIENTE,

    /**
     * Rol de administrador: acceso completo a gestión de productos, pedidos,
     * usuarios y reportes.
     */
    ADMIN
}
