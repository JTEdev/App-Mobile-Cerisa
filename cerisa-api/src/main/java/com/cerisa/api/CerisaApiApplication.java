package com.cerisa.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Clase principal de la aplicación Spring Boot para la API REST de Cerisa.
 * <p>
 * Punto de entrada de la aplicación backend que gestiona el catálogo de
 * productos,
 * pedidos, autenticación de usuarios y reportes de ventas para la empresa
 * Cerisa.
 * </p>
 * <p>
 * La anotación {@code @SpringBootApplication} habilita:
 * <ul>
 * <li>Configuración automática de Spring Boot</li>
 * <li>Escaneo de componentes en el paquete {@code com.cerisa.api}</li>
 * <li>Configuración adicional basada en las dependencias del classpath</li>
 * </ul>
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@SpringBootApplication
public class CerisaApiApplication {

	/**
	 * Método principal que inicia la aplicación Spring Boot.
	 * Arranca el servidor embebido y configura todos los componentes
	 * automáticamente.
	 *
	 * @param args argumentos de línea de comandos (opcional)
	 */
	public static void main(String[] args) {
		SpringApplication.run(CerisaApiApplication.class, args);
	}

}
