# Cerisa App — Frontend Móvil

Aplicación móvil Android para Cerisa, construida con Flutter 3.41.2 y Dart 3.11.0.

## Tecnologías

- **Flutter 3.41.2** — Framework UI multiplataforma
- **Dart 3.11.0** — Lenguaje de programación
- **Provider 6.1.0** — Gestión de estado (ChangeNotifier + Consumer)
- **http 1.4.0** — Cliente HTTP para comunicación con el API
- **shared_preferences 2.5.0** — Almacenamiento local (token, datos de sesión)
- **intl 0.20.0** — Formateo de fechas y números

## Cómo Ejecutar

```bash
cd cerisa_app

# Instalar dependencias
flutter pub get

# IMPORTANTE: Configurar Gradle cache por Sophos
$env:GRADLE_USER_HOME = "C:\GradleCache"

# Correr en emulador Android
flutter run -d emulator-5554

# Solo compilar APK debug
flutter build apk --debug
```

## Arquitectura

Se usa **Clean Architecture "light"** organizada por features:

```
lib/
├── main.dart           ← Punto de entrada + configuración de Providers
├── app.dart            ← MaterialApp (tema, rutas, auto-login)
├── core/               ← Código compartido
│   ├── constants/      ← URLs del API, constantes de la app
│   ├── routes/         ← Definición y generación de rutas con nombre
│   ├── services/       ← Servicios singleton (HTTP, almacenamiento)
│   ├── theme/          ← Tema Material 3 (colores, tipografía)
│   ├── utils/          ← Utilidades (validadores de formulario)
│   └── widgets/        ← Widgets reutilizables
└── features/           ← Un módulo por funcionalidad
    └── [feature]/
        └── presentation/
            ├── providers/  ← ChangeNotifier (estado + lógica)
            └── screens/    ← Widgets de pantalla (UI)
```

### Gestión de Estado (Provider)

Cada feature tiene su propio `ChangeNotifier` registrado en `MultiProvider` (en `main.dart`):

| Provider                | Responsabilidad                                                  |
| ----------------------- | ---------------------------------------------------------------- |
| `AuthProvider`          | Login, registro, logout, datos de sesión                         |
| `CatalogProvider`       | Lista de productos, búsqueda por ID                              |
| `CartProvider`          | Carrito local, checkout (envío al API)                           |
| `OrdersProvider`        | Pedidos del usuario, todos los pedidos (admin), cambio de estado |
| `AdminProductsProvider` | CRUD de productos (admin)                                        |
| `ReportsProvider`       | Reportes diarios, mensuales, top productos (admin)               |

### Navegación

Se usa **named routes** con `onGenerateRoute`. Las rutas están definidas en `AppRoutes`:

| Ruta              | Pantalla          | Acceso      |
| ----------------- | ----------------- | ----------- |
| `/login`          | Login             | Público     |
| `/register`       | Registro          | Público     |
| `/home`           | Home (con tabs)   | Autenticado |
| `/catalog/detail` | Detalle producto  | Autenticado |
| `/cart`           | Carrito           | Autenticado |
| `/checkout`       | Checkout          | Autenticado |
| `/orders`         | Mis pedidos       | Autenticado |
| `/admin/products` | Gestión productos | ADMIN       |
| `/admin/stock`    | Gestión stock     | ADMIN       |
| `/admin/orders`   | Gestión pedidos   | ADMIN       |
| `/admin/reports`  | Reportes          | ADMIN       |
| `/admin/users`    | Usuarios          | ADMIN       |

### Comunicación con el Backend

- `ApiService` centraliza todas las llamadas HTTP
- El token JWT se inyecta automáticamente en el header `Authorization: Bearer <token>`
- El emulador accede al backend vía `http://10.0.2.2:8081/api` (10.0.2.2 = localhost de la PC)

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
