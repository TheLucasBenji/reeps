import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/loading_screen.dart'; // Importa la pantalla de carga

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reeps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoadingScreen(), // Cambia esto
    );
  }
}
