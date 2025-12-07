import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../models/user_profile.dart';
import '../models/workout_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser?.uid;
  }

  // Estructura para almacenar estadísticas
  Map<String, dynamic> _calculateStats(List<WorkoutRecord> records) {
    if (records.isEmpty) {
      return {
        'currentWeekVolume': 0.0,
        'previousWeekVolume': 0.0,
        'percentChange': 0.0,
        'weeklyExercises': 0,
        'weeklySets': 0,
        'chartSpots': const <FlSpot>[],
        'maxY': 10.0,
      };
    }

    final now = DateTime.now();
    // Encontrar el inicio de la semana (Lunes)
    // weekday: 1 (Lunes) ... 7 (Domingo)
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek =
        startOfWeek.add(const Duration(days: 7)).subtract(
          const Duration(microseconds: 1),
        );
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(const Duration(microseconds: 1));

    double currentWeekVolume = 0;
    double previousWeekVolume = 0;
    int weeklyExercises = 0;
    int weeklySets = 0;

    // Array para acumular volumen por día de la semana (0 = Lunes, 6 = Domingo)
    final List<double> dailyVolume = List.filled(7, 0.0);

    for (var record in records) {
      // Filtrar por fecha
      if (record.date.isAfter(startOfWeek) && record.date.isBefore(endOfWeek)) {
        currentWeekVolume += record.totalWeight;
        weeklyExercises++;
        weeklySets += record.sets;

        // Mapear día de la semana a índice 0-6
        final dayIndex = record.date.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyVolume[dayIndex] += record.totalWeight;
        }
      } else if (record.date.isAfter(startOfLastWeek) &&
          record.date.isBefore(endOfLastWeek)) {
        previousWeekVolume += record.totalWeight;
      }
    }

    // Calcular cambio porcentual
    double percentChange = 0.0;
    if (previousWeekVolume > 0) {
      percentChange =
          ((currentWeekVolume - previousWeekVolume) / previousWeekVolume) * 100;
    } else if (currentWeekVolume > 0) {
      percentChange = 100.0; // Incremento total si antes era 0
    }

    // Generar spots para el gráfico
    List<FlSpot> spots = [];
    double maxY = 10.0;
    for (int i = 0; i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), dailyVolume[i]));
      if (dailyVolume[i] > maxY) maxY = dailyVolume[i];
    }
    // Dar un poco de margen superior al gráfico
    maxY *= 1.2;

    return {
      'currentWeekVolume': currentWeekVolume,
      'previousWeekVolume': previousWeekVolume,
      'percentChange': percentChange,
      'weeklyExercises': weeklyExercises,
      'weeklySets': weeklySets,
      'chartSpots': spots,
      'maxY': maxY,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo con FutureBuilder
            FutureBuilder<UserProfile?>(
              future: _firestoreService.getUserProfile(_userId!),
              builder: (context, snapshot) {
                final userName = snapshot.data?.name ?? 'Usuario';
                return Text(
                  'Hola, $userName',
                  style: Theme.of(context).textTheme.displayMedium,
                );
              },
            ),

            const SizedBox(height: 8),

            // Stream para los datos de entrenamiento
            StreamBuilder<List<WorkoutRecord>>(
              stream: _firestoreService.getWorkoutRecords(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Error loading workout records: ${snapshot.error}');
                  return SelectableText( // Use SelectableText to make it easier to read/copy if needed
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final records = snapshot.data ?? [];
                final stats = _calculateStats(records);
                final currentVolume = stats['currentWeekVolume'] as double;
                final percentChange = stats['percentChange'] as double;
                final weeklyExercises = stats['weeklyExercises'] as int;
                final weeklySets = stats['weeklySets'] as int;
                final chartSpots = stats['chartSpots'] as List<FlSpot>;
                final maxY = stats['maxY'] as double;

                final isPositive = percentChange >= 0;
                final percentColor =
                    isPositive
                        ? AppTheme.successColor(context)
                        : Colors.redAccent;
                final percentIcon =
                    isPositive ? '+' : ''; // El signo menos viene en el valor

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Esta semana has completado $weeklyExercises ejercicios.\n¡Sigue así!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Progreso Semanal',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${currentVolume.toInt()} kg movidos esta\nsemana!',
                                    style:
                                        Theme.of(context).textTheme.displaySmall,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: percentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$percentIcon${percentChange.toStringAsFixed(1)}%',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color: percentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Esta semana',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 150,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          const days = [
                                            'Lu',
                                            'Ma',
                                            'Mi',
                                            'Ju',
                                            'Vi',
                                            'Sa',
                                            'Do',
                                          ];
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < days.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                days[value.toInt()],
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minY: 0,
                                  maxY: maxY,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartSpots,
                                      isCurved: true,
                                      preventCurveOverShooting: true,
                                      color: AppTheme.primaryColor(context),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: AppTheme.primaryColor(
                                          context,
                                        ).withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.fitness_center,
                            value: weeklyExercises.toString(),
                            label: 'Ejercicios',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.repeat,
                            value: weeklySets.toString(),
                            label: 'Sets',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Mensaje motivacional (estático por ahora o aleatorio simple)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor(context).withOpacity(0.25),
                    AppTheme.accentColor(context).withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppTheme.primaryColor(context),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¡Cada set te acerca a tus metas!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor(context), size: 32),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
