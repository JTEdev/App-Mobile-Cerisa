# Cerisa API — Backend REST

API REST para la aplicación móvil Cerisa, construida con Spring Boot 4.0.3 y Java 17.

## Tecnologías

- **Spring Boot 4.0.3** — Framework web
- **Spring Security** — Autenticación y autorización
- **Spring Data JPA / Hibernate** — ORM y acceso a datos
- **MySQL 8.0** — Base de datos
- **JWT (jjwt 0.12.6)** — Tokens de autenticación
- **Lombok** — Reducción de boilerplate
- **Maven** — Gestión de dependencias

## Configuración

### `application.properties`
```properties
server.port=8081                           # Puerto del servidor
spring.datasource.url=jdbc:mysql://localhost:3306/cerisa_db
spring.datasource.username=root
spring.datasource.password=cerisa2026
spring.jpa.hibernate.ddl-auto=update       # Crea/actualiza tablas automáticamente
app.jwt.secret=<clave-secreta>             # Clave para firmar tokens JWT
app.jwt.expiration=86400000                # Expiración: 24 horas en ms
```

## Cómo Ejecutar

```bash
# Requisito: MySQL corriendo con BD 'cerisa_db' creada
mvn spring-boot:run
# Servidor inicia en http://localhost:8081
```

## Arquitectura

```
Petición HTTP → Controller → Service → Repository → MySQL
                    ↑              ↑
                   DTO          Entity
```

### Capas

1. **Controller**: Recibe peticiones HTTP, valida DTOs, delega al Service.
2. **Service**: Lógica de negocio (autenticación, cálculos, validaciones).
3. **Repository**: Interfaz JPA para queries a la base de datos.
4. **Entity**: Mapeo objeto-relacional (clases Java ↔ tablas MySQL).
5. **DTO**: Objetos de transferencia (lo que entra/sale del API, nunca entidades directas).
6. **Security**: Filtros JWT, configuración de endpoints protegidos.

### Seguridad

- **Endpoints públicos**: `POST /api/auth/*`, `GET /api/products`
- **Endpoints autenticados**: `POST /api/orders`, `GET /api/orders/my`
- **Endpoints ADMIN**: `POST/PUT/DELETE /api/products`, `GET /api/orders`, `GET /api/reports/*`

El filtro `JwtAuthenticationFilter` intercepta cada petición, extrae el token Bearer del header Authorization, lo valida y establece el contexto de seguridad.

### Base de Datos (Tablas)

```
users          ← Usuarios (nombre, email, password_hash, rol)
products       ← Productos (nombre, precio, stock, categoría, activo)
orders         ← Pedidos (usuario_id, estado, total, dirección)
order_items    ← Items de pedido (pedido_id, producto_id, cantidad, precio)
```

### Enums

- **Role**: `CLIENTE`, `ADMIN`
- **OrderStatus**: `PENDIENTE`, `CONFIRMADO`, `EN_PREPARACION`, `ENVIADO`, `ENTREGADO`, `CANCELADO`

## Ejemplos de Peticiones

### Registrar usuario
```json
POST /api/auth/register
{
  "nombre": "Juan Pérez",
  "email": "juan@cerisa.com",
  "password": "miPassword123"
}
// Respuesta: { "token": "eyJ...", "email": "juan@cerisa.com", "nombre": "Juan Pérez", "rol": "CLIENTE" }
```

### Crear producto (requiere token ADMIN)
```json
POST /api/products
Authorization: Bearer eyJ...
{
  "nombre": "Camisa Cerisa",
  "descripcion": "Camisa de algodón premium",
  "precio": 89.90,
  "stock": 50,
  "categoria": "Ropa",
  "imagenUrl": "https://ejemplo.com/camisa.jpg"
}
```

### Crear pedido (requiere token)
```json
POST /api/orders
Authorization: Bearer eyJ...
{
  "direccionEntrega": "Av. Principal 123, Lima",
  "notas": "Entregar en recepción",
  "items": [
    { "productoId": 1, "cantidad": 2 },
    { "productoId": 3, "cantidad": 1 }
  ]
}
```
