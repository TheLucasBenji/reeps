# Reeps - Gym Logger App
Reeps es una aplicación móvil desarrollada en Flutter para el seguimiento del progreso en el gimnasio. Permite a los usuarios registrar sus entrenamientos (peso, repeticiones, sets), visualizar su historial y analizar su progreso a través de estadísticas y gráficos.

### Características Principales
* **Autenticación de Usuarios:** Sistema completo de inicio de sesión y registro usando Email/Contraseña y Google Sign-In, gestionado con Firebase Authentication.
 
* **Dashboard (Inicio):** Una pantalla principal (HomeScreen) que saluda al usuario, muestra un resumen de su actividad y un gráfico de progreso semanal usando fl_chart.

* **Registro de Entrenamientos:** Un formulario dedicado (AddWorkoutScreen) para registrar nuevos ejercicios, permitiendo seleccionar peso, repeticiones, sets y unidad (kg/lb).

* **Cálculo de Volumen:** Cálculo automático del volumen total (Sets × Reps × Peso) en la pantalla de registro para dar feedback inmediato al usuario.

* **Biblioteca de Ejercicios:** Una lista completa de ejercicios (ExercisesScreen) que se pueden filtrar por grupo muscular o buscar por nombre.

* **Detalle de Ejercicio:** Visualización del historial de registros para un ejercicio específico (ExerciseDetailScreen).

* **Estadísticas:** Gráficos que muestran la evolución del progreso a lo largo del tiempo (StatisticsScreen).

* **Gestión de Sesión:** Pantalla de configuración (SettingsScreen) con la capacidad de cerrar sesión.

* **Diseño Cohesivo:** Un tema oscuro (AppTheme) personalizado y centralizado que garantiza una estética consistente en toda la aplicación.

### Cómo Probar la Aplicación

Para ejecutar este proyecto en tu entorno local, necesitarás configurar Flutter y Firebase.

**Prerrequisitos**

* SDK de Flutter (versión 3.29.0 o superior).
* Un emulador de Android/iOS o un dispositivo físico.


**Instalación y Ejecución**

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/TheLucasBenji/reeps.git
    cd reeps
    ```

2.  **Obtener dependencias de Flutter:**
    ```bash
    flutter pub get
    ```

4.  **Ejecutar la aplicación:**
    ```bash
    flutter run
    ```


### Decisiones de Diseño
Varias decisiones de arquitectura y diseño se tomaron para dar forma a la aplicación:

**1. Tema y UI**
Dark Mode por Defecto: Se optó por un diseño Dark Mode (lib/config/theme.dart). Esta decisión se basa en que las aplicaciones de fitness se usan frecuentemente en gimnasios, que pueden tener iluminación variable; un tema oscuro reduce la fatiga visual y es estéticamente coherente con el sector.
Tema Centralizado: En lugar de definir colores y estilos en cada pantalla, se creó un AppTheme. Esto asegura que todos los Card, AppBar, Button y fuentes sean consistentes (ej. primaryPurple) y permite un rediseño rápido modificando un solo archivo.



### Dependencias Clave
* **l_chart:** Para los gráficos de progreso en HomeScreen y StatisticsScreen.

* **intl:** Para formateo de fechas (visto en main.dart y add_workout_screen.dart).

* **provider:** Paquete de gestión de estado (disponible para uso futuro).

* **flutter_svg:** Para renderizar el logo en la pantalla de login.