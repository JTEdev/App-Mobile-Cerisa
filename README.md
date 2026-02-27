# Cerisa - Aplicación Móvil de Gestión Comercial

## Descripción General

Aplicación móvil Android para la empresa **Cerisa** que permite la gestión de productos, pedidos y reportes de ventas. La app cuenta con dos roles de usuario:

- **CLIENTE**: Puede ver catálogo, agregar al carrito, hacer pedidos y ver su historial.
- **ADMIN**: Puede gestionar productos, stock, pedidos, ver reportes y administrar usuarios.

## Arquitectura del Proyecto

El proyecto se compone de **3 capas**:

```
App-Mobile Cerisa/
├── cerisa-api/          ← Backend REST API (Spring Boot + Java 17)
├── cerisa_app/          ← Frontend Móvil (Flutter + Dart)
└── flutter_windows_*/   ← SDK de Flutter (no editar)
```

### Stack Tecnológico

| Capa                  | Tecnología    | Versión                |
| --------------------- | ------------- | ---------------------- |
| **Backend**           | Spring Boot   | 4.0.3                  |
| **Lenguaje Backend**  | Java          | 17 (Temurin)           |
| **Base de Datos**     | MySQL         | 8.0.x                  |
| **ORM**               | Hibernate/JPA | Auto (via Spring Boot) |
| **Autenticación**     | JWT (jjwt)    | 0.12.6                 |
| **Frontend**          | Flutter       | 3.41.2                 |
| **Lenguaje Frontend** | Dart          | 3.11.0                 |
| **Estado (Frontend)** | Provider      | 6.1.0                  |
| **HTTP Client**       | http (Dart)   | 1.4.0                  |

---

## Requisitos Previos

1. **Java 17** — `JAVA_HOME` configurado
2. **Maven 3.9+** — Para compilar el backend
3. **MySQL 8.0** — Servicio `MySQL80` corriendo
4. **Flutter 3.41+** — En PATH o usando ruta completa
5. **Android SDK 34+** — Con emulador configurado
6. **Android Studio** — Para emulador (Device Manager → Create Virtual Device)

---

## Configuración Inicial

### 1. Base de Datos (MySQL)

```sql
-- Crear la base de datos (solo la primera vez)
CREATE DATABASE cerisa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Credenciales configuradas en `cerisa-api/src/main/resources/application.properties`:
- **Usuario**: `root`
- **Contraseña**: `cerisa2026`
- **Base de datos**: `cerisa_db`
- Las tablas se crean automáticamente con `ddl-auto=update`

### 2. Backend (Spring Boot)

```bash
cd cerisa-api
mvn spring-boot:run
```
- El servidor inicia en **http://localhost:8081**
- Verificar: `GET http://localhost:8081/api/products` → debe devolver `[]`

### 3. Frontend (Flutter)

```bash
cd cerisa_app

# Si es primera vez o después de limpiar:
flutter pub get

# Para correr en emulador:
$env:GRADLE_USER_HOME = "C:\GradleCache"
flutter run -d emulator-5554
```

> **IMPORTANTE (Sophos Intercept X):** Si el build falla con `AccessDeniedException` en Gradle transforms, desactivar temporalmente "Escaneo en tiempo real → Archivos" en Sophos durante el build. Reactivar después.

---

## Endpoints del API

### Autenticación (`/api/auth`)
| Método | Ruta                 | Descripción             | Auth |
| ------ | -------------------- | ----------------------- | ---- |
| POST   | `/api/auth/register` | Registrar usuario nuevo | No   |
| POST   | `/api/auth/login`    | Iniciar sesión          | No   |

### Productos (`/api/products`)
| Método | Ruta                 | Descripción                       | Auth  |
| ------ | -------------------- | --------------------------------- | ----- |
| GET    | `/api/products`      | Listar productos activos          | No    |
| GET    | `/api/products/{id}` | Detalle de producto               | No    |
| POST   | `/api/products`      | Crear producto                    | ADMIN |
| PUT    | `/api/products/{id}` | Actualizar producto               | ADMIN |
| DELETE | `/api/products/{id}` | Desactivar producto (soft delete) | ADMIN |

### Pedidos (`/api/orders`)
| Método | Ruta                      | Descripción       | Auth  |
| ------ | ------------------------- | ----------------- | ----- |
| POST   | `/api/orders`             | Crear pedido      | Sí    |
| GET    | `/api/orders/my`          | Mis pedidos       | Sí    |
| GET    | `/api/orders`             | Todos los pedidos | ADMIN |
| PUT    | `/api/orders/{id}/status` | Cambiar estado    | ADMIN |

### Reportes (`/api/reports`)
| Método | Ruta                        | Descripción            | Auth  |
| ------ | --------------------------- | ---------------------- | ----- |
| GET    | `/api/reports/daily`        | Reporte diario         | ADMIN |
| GET    | `/api/reports/monthly`      | Reporte mensual        | ADMIN |
| GET    | `/api/reports/top-products` | Top productos vendidos | ADMIN |

---

## Estructura del Backend (`cerisa-api`)

```
src/main/java/com/cerisa/api/
├── CerisaApiApplication.java      ← Clase principal Spring Boot
├── controller/                     ← Controladores REST (reciben peticiones HTTP)
│   ├── AuthController.java         ← Login y registro
│   ├── ProductController.java      ← CRUD de productos
│   ├── OrderController.java        ← Gestión de pedidos
│   └── ReportController.java       ← Reportes de ventas
├── service/                        ← Lógica de negocio
│   ├── AuthService.java            ← Autenticación con JWT + BCrypt
│   ├── ProductService.java         ← CRUD productos + soft delete
│   ├── OrderService.java           ← Crear pedidos, reducir stock
│   └── ReportService.java          ← Cálculos de reportes
├── entity/                         ← Entidades JPA (tablas de BD)
│   ├── User.java                   ← Usuario (nombre, email, password, rol)
│   ├── Product.java                ← Producto (nombre, precio, stock, categoría)
│   ├── Order.java                  ← Pedido (usuario, estado, total, dirección)
│   ├── OrderItem.java              ← Ítem de pedido (producto, cantidad, precio)
│   ├── Role.java                   ← Enum: CLIENTE, ADMIN
│   └── OrderStatus.java            ← Enum: PENDIENTE→ENTREGADO, CANCELADO
├── repository/                     ← Interfaces JPA para acceso a BD
│   ├── UserRepository.java
│   ├── ProductRepository.java
│   ├── OrderRepository.java
│   └── OrderItemRepository.java
├── dto/                            ← Objetos de transferencia (request/response)
│   ├── ApiError.java               ← Formato de error estándar
│   ├── auth/                       ← DTOs de autenticación
│   ├── product/                    ← DTOs de productos
│   ├── order/                      ← DTOs de pedidos
│   └── report/                     ← DTOs de reportes
├── security/                       ← Seguridad y JWT
│   ├── SecurityConfig.java         ← Configuración de Spring Security
│   ├── JwtTokenProvider.java       ← Generación y validación de tokens JWT
│   ├── JwtAuthenticationFilter.java← Filtro que intercepta cada petición
│   └── CustomUserDetailsService.java← Carga usuario desde BD para Spring Security
└── exception/
    └── GlobalExceptionHandler.java ← Manejo centralizado de errores
```

---

## Estructura del Frontend (`cerisa_app`)

```
lib/
├── main.dart                       ← Punto de entrada, configura MultiProvider
├── app.dart                        ← Widget raíz, MaterialApp con rutas y tema
├── core/                           ← Código compartido por toda la app
│   ├── constants/
│   │   ├── api_constants.dart      ← URL base del API (10.0.2.2:8081)
│   │   └── app_constants.dart      ← Constantes de la app (nombre, keys)
│   ├── routes/
│   │   └── app_routes.dart         ← Definición de rutas y generador de rutas
│   ├── services/
│   │   ├── api_service.dart        ← Cliente HTTP con inyección de token JWT
│   │   └── storage_service.dart    ← Almacenamiento local (SharedPreferences)
│   ├── theme/
│   │   └── app_theme.dart          ← Tema claro/oscuro Material 3
│   ├── utils/
│   │   └── validators.dart         ← Validadores de formulario
│   └── widgets/
│       └── common_widgets.dart     ← Widgets reutilizables (loading, error, empty)
└── features/                       ← Módulos por funcionalidad
    ├── auth/                       ← Autenticación
    │   └── presentation/
    │       ├── providers/auth_provider.dart    ← Estado de autenticación
    │       └── screens/
    │           ├── login_screen.dart           ← Pantalla de login
    │           └── register_screen.dart        ← Pantalla de registro
    ├── home/                       ← Pantalla principal con navegación
    │   └── presentation/screens/home_screen.dart
    ├── catalog/                    ← Catálogo de productos
    │   └── presentation/
    │       ├── providers/catalog_provider.dart  ← Carga y gestión de productos
    │       └── screens/
    │           ├── catalog_screen.dart          ← Grid de productos
    │           └── product_detail_screen.dart   ← Detalle con agregar al carrito
    ├── cart/                       ← Carrito de compras
    │   └── presentation/
    │       ├── providers/cart_provider.dart     ← Estado del carrito + checkout
    │       └── screens/
    │           ├── cart_screen.dart             ← Lista de ítems del carrito
    │           └── checkout_screen.dart         ← Confirmación de pedido
    ├── orders/                     ← Pedidos del cliente
    │   └── presentation/
    │       ├── providers/orders_provider.dart   ← Carga pedidos del usuario
    │       └── screens/my_orders_screen.dart    ← Historial de pedidos
    ├── profile/                    ← Perfil y navegación admin
    │   └── presentation/screens/profile_screen.dart
    ├── admin_products/             ← CRUD de productos (admin)
    │   └── presentation/
    │       ├── providers/admin_products_provider.dart
    │       └── screens/admin_products_screen.dart
    ├── admin_stock/                ← Gestión de stock (admin)
    │   └── presentation/screens/admin_stock_screen.dart
    ├── admin_orders/               ← Gestión de pedidos (admin)
    │   └── presentation/screens/admin_orders_screen.dart
    ├── admin_reports/              ← Reportes de ventas (admin)
    │   └── presentation/
    │       ├── providers/reports_provider.dart
    │       └── screens/admin_reports_screen.dart
    └── admin_users/                ← Gestión de usuarios (admin) [placeholder]
        └── presentation/screens/admin_users_screen.dart
```

---

## Flujo de la Aplicación

```
Login → ¿Token guardado? → Sí → Home (con tabs)
                          → No → Pantalla de Login

Home (BottomNavigation):
├── Tab 1: Catálogo → Detalle Producto → Agregar al Carrito
├── Tab 2: Carrito → Checkout → Confirmar Pedido
├── Tab 3: Mis Pedidos (historial)
└── Tab 4: Perfil
             ├── Info del usuario
             ├── Cerrar sesión
             └── (Si es ADMIN):
                  ├── Gestión Productos
                  ├── Gestión Stock
                  ├── Gestión Pedidos
                  ├── Reportes
                  └── Usuarios
```

---

## Usuarios de Prueba

| Email           | Rol     | Notas                      |
| --------------- | ------- | -------------------------- |
| jose@cerisa.com | ADMIN   | Cambiado manualmente en BD |
| test@cerisa.com | CLIENTE | Registrado por defecto     |

Para crear un admin nuevo, registrar normalmente y luego ejecutar:
```sql
UPDATE users SET rol = 'ADMIN' WHERE email = 'nuevo@cerisa.com';
```

---

## Notas

1. **Comunicación emulador → backend**: El emulador Android usa `10.0.2.2` para acceder al `localhost` de la PC. Configurado en `api_constants.dart`.

2. **GRADLE_USER_HOME**: Se usa `C:\GradleCache` en vez del default `~/.gradle` para evitar problemas con rutas con espacios.

3. **Estado con Provider**: Cada feature tiene su propio `ChangeNotifier` provider. Se registran en `main.dart` con `MultiProvider`.

4. **JWT**: Token se almacena en `SharedPreferences`. Se inyecta automáticamente en headers HTTP via `ApiService`.

5. **Soft Delete**: Los productos no se eliminan de la BD, solo se marcan como `activo = false`.
