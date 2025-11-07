Reeps - Fitness Tracker App
Reeps es una aplicación móvil desarrollada en Flutter para el seguimiento del progreso en el gimnasio. Permite a los usuarios registrar sus entrenamientos (peso, repeticiones, sets), visualizar su historial y analizar su progreso a través de estadísticas y gráficos.

Características Principales
Autenticación de Usuarios: Sistema completo de inicio de sesión y registro usando Email/Contraseña y Google Sign-In, gestionado con Firebase Authentication.

Pantalla de Carga Inteligente: Una pantalla de carga inicial (LoadingScreen) que inicializa Firebase y redirige automáticamente al usuario al Login o al Home según su estado de autenticación.

Dashboard (Inicio): Una pantalla principal (HomeScreen) que saluda al usuario, muestra un resumen de su actividad y un gráfico de progreso semanal usando fl_chart.

Registro de Entrenamientos: Un formulario dedicado (AddWorkoutScreen) para registrar nuevos ejercicios, permitiendo seleccionar peso, repeticiones, sets y unidad (kg/lb).

Cálculo de Volumen: Cálculo automático del volumen total (Sets × Reps × Peso) en la pantalla de registro para dar feedback inmediato al usuario.

Biblioteca de Ejercicios: Una lista completa de ejercicios (ExercisesScreen) que se pueden filtrar por grupo muscular o buscar por nombre.

Detalle de Ejercicio: Visualización del historial de registros para un ejercicio específico (ExerciseDetailScreen).

Estadísticas: Gráficos que muestran la evolución del progreso a lo largo del tiempo (StatisticsScreen).

Gestión de Sesión: Pantalla de configuración (SettingsScreen) con la capacidad de cerrar sesión.

Diseño Cohesivo: Un tema oscuro (AppTheme) personalizado y centralizado que garantiza una estética consistente en toda la aplicación.

Cómo Probar la Aplicación
Para ejecutar este proyecto en tu entorno local, necesitarás configurar Flutter y Firebase.

Prerrequisitos
-SDK de Flutter (versión 3.29.0 o superior).

-Un emulador de Android/iOS o un dispositivo físico.

-Una cuenta de Firebase para configurar el backend.

Instalación y Ejecución
Clonar el repositorio:

Bash

git clone <url-del-repositorio>
cd reeps
Obtener dependencias de Flutter:

Bash

flutter pub get
Configurar Firebase (Paso Crítico): Este proyecto depende de Firebase para la autenticación y la base de datos.

Ve a la Consola de Firebase y crea un nuevo proyecto.

Registra tus aplicaciones (Android, iOS, y/o Web).

Para Android: Descarga el archivo google-services.json y colócalo en la carpeta android/app/.

Para iOS: Descarga el archivo GoogleService-Info.plist y colócalo en la carpeta ios/Runner/ usando Xcode.

En la consola de Firebase, ve a la sección Authentication:

Habilita los proveedores de Email/Contraseña y Google.

En la consola de Firebase, ve a la sección Firestore Database:

Crea una base de datos de Cloud Firestore en modo de prueba o producción.

Ejecutar la aplicación:

Bash

flutter run
Decisiones de Diseño
Varias decisiones de arquitectura y diseño se tomaron para dar forma a la aplicación:

1. Tema y UI
Dark Mode por Defecto: Se optó por un diseño Dark Mode (lib/config/theme.dart). Esta decisión se basa en que las aplicaciones de fitness se usan frecuentemente en gimnasios, que pueden tener iluminación variable; un tema oscuro reduce la fatiga visual y es estéticamente coherente con el sector.

Tema Centralizado: En lugar de definir colores y estilos en cada pantalla, se creó un AppTheme. Esto asegura que todos los Card, AppBar, Button y fuentes sean consistentes (ej. primaryPurple) y permite un rediseño rápido modificando un solo archivo.

2. Flujo de Autenticación y Carga
LoadingScreen como controlador: La adición de lib/screens/loading_screen.dart (y su configuración en main.dart) es una decisión clave. Evita el "parpadeo" de la pantalla de login. Esta pantalla inicializa Firebase y intl, y luego, usando el estado de FirebaseAuth.instance.currentUser, dirige al usuario a MainScreen (si está logueado) o a LoginScreen (si no lo está).

3. Gestión de Datos de Ejercicios
Datos Estáticos vs. Base de Datos: La lista maestra de ejercicios se gestiona estáticamente a través de lib/data/exercise_data.dart.

Justificación: Fue una decisión deliberada para la v1. Almacenar esta lista en Firestore habría requerido una lectura de base de datos costosa y lenta solo para mostrar datos que rara vez cambian. Al mantenerla localmente, la carga es instantánea y el filtrado/búsqueda (lib/utils/search_utils.dart) es inmediato en el lado del cliente.

Diferenciación de Modelos: Se separó el modelo Exercise (datos estáticos) del modelo WorkoutRecord (datos dinámicos del usuario). WorkoutRecord está diseñado para Firestore, incluyendo métodos toMap y fromMap que manejan Timestamp de Firebase.

4. Gestión de Estado
StatefulWidget (Local): Para la mayoría de las vistas (como AddWorkoutScreen, LoginScreen, StatisticsScreen), se utiliza setState para gestionar el estado local de la UI (como mostrar/ocultar contraseña, actualizar el valor de un TextFormField o cambiar el período de un gráfico).

Justificación: Aunque provider está en las dependencias, el estado actual de la app no es lo suficientemente complejo como para requerir un manejo de estado global. Se optó por la solución nativa de Flutter (setState) para mantener la simplicidad en formularios y vistas que no comparten estado activamente.

5. Backend (BaaS)
Firebase (BaaS): Se eligió Firebase como Backend-as-a-Service. Esto elimina la necesidad de gestionar un servidor propio.

Firestore: Ideal para una app de fitness, ya que su modelo NoSQL basado en documentos permite almacenar WorkoutRecord de forma flexible y escalable.

Firebase Auth: Provee una solución segura y robusta para el manejo de usuarios, incluyendo la integración sencilla con Google Sign-In.

Estructura del Proyecto
La estructura del directorio lib/ está organizada por funcionalidad para facilitar el mantenimiento:

lib/
├── config/
│   └── theme.dart          # Tema centralizado (colores, fuentes)
├── data/
│   └── exercise_data.dart  # Lista estática de ejercicios
├── models/
│   ├── exercise.dart       # Modelo para un ejercicio (de la lista)
│   └── workout_record.dart # Modelo para un registro de usuario (Firestore)
├── screens/
│   ├── loading_screen.dart # (NUEVO) Pantalla de carga y routing inicial
│   ├── login_screen.dart   # Inicio de sesión
│   ├── register_screen.dart # Registro
│   ├── main_screen.dart    # Contenedor con BottomNavBar
│   ├── home_screen.dart    # Dashboard principal
│   ├── statistics_screen.dart # Gráficos de progreso
│   ├── exercises_screen.dart # Lista/búsqueda de ejercicios
│   ├── exercise_detail_screen.dart # Historial de un ejercicio
│   ├── add_workout_screen.dart # Formulario para añadir registro
│   └── settings_screen.dart # Configuración y Logout
├── utils/
│   └── search_utils.dart   # Lógica de filtrado de texto
└── main.dart               # Punto de entrada de la app
Dependencias Clave
firebase_core: Para inicializar Firebase.

firebase_auth: Para autenticación de usuarios.

cloud_firestore: Para la base de datos NoSQL.

google_sign_in: Para el login con Google.

fl_chart: Para los gráficos de progreso en HomeScreen y StatisticsScreen.

intl: Para formateo de fechas (visto en main.dart y add_workout_screen.dart).

provider: Paquete de gestión de estado (disponible para uso futuro).

flutter_svg: Para renderizar el logo en la pantalla de login.