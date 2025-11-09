import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/exercise_detail_screen.dart';
import 'screens/add_workout_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/main_screen.dart';
import 'screens/statistics_screen.dart';
import 'models/exercise.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa los datos de formato de fecha para el locale español (evita LocaleDataException)
  await initializeDateFormatting('es_ES', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Reeps',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.mode,
          home: const LoginScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                );
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              case '/main':
                return MaterialPageRoute(builder: (_) => const MainScreen());
              case '/exercises':
                return MaterialPageRoute(
                  builder: (_) => const ExercisesScreen(),
                );
              case '/exercise_detail':
                final exercise = settings.arguments as Exercise;
                return MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(exercise: exercise),
                );
              case '/add_workout':
                return MaterialPageRoute(
                  builder: (_) => const AddWorkoutScreen(),
                );
              case '/edit_profile':
                return MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                );
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                );
              case '/statistics':
                return MaterialPageRoute(
                  builder: (_) => const StatisticsScreen(),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
