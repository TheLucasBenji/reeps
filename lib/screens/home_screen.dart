import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../models/user_profile.dart';
import '../models/workout_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/format_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? _userId;
  String _userName = 'Usuario';
  static const _userNameKey = 'cached_user_name';

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser?.uid;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    // Primero cargar desde cache local (instantáneo)
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString(_userNameKey);
    if (mounted && cachedName != null && cachedName.isNotEmpty) {
      setState(() {
        _userName = cachedName;
      });
    }

    // Luego actualizar desde Firestore (en segundo plano)
    if (_userId != null) {
      final profile = await _firestoreService.getUserProfile(_userId!);
      if (mounted && profile?.name != null && profile!.name!.isNotEmpty) {
        setState(() {
          _userName = profile.name!;
        });
        // Guardar en cache para la próxima vez
        await prefs.setString(_userNameKey, profile.name!);
      }
    }
  }


  // Estructura para almacenar estadísticas
  Map<String, dynamic> _calculateStats(List<WorkoutRecord> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Últimos 7 días: [today-6, ..., today]
    final startDate = today.subtract(const Duration(days: 6));
    final endDate = today
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    // Período anterior (7 días antes del start date)
    final startOfPriorPeriod = startDate.subtract(const Duration(days: 7));
    final endOfPriorPeriod =
        startDate.subtract(const Duration(microseconds: 1));

    // Generar etiquetas para el eje X
    final weekDays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
    List<String> axisLabels = [];
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      axisLabels.add(weekDays[date.weekday - 1]);
    }

    if (records.isEmpty) {
      return {
        'currentWeekVolume': 0.0,
        'previousWeekVolume': 0.0,
        'percentChange': 0.0,
        'weeklyExercises': 0,
        'weeklySets': 0,
        'chartSpots': const <FlSpot>[],
        'maxY': 10.0,
        'axisLabels': axisLabels,
      };
    }

    double currentWeekVolume = 0;
    double previousWeekVolume = 0;
    int weeklyExercises = 0;
    int weeklySets = 0;

    // Array para acumular volumen por día (0 = día 1 de los 7, 6 = hoy)
    final List<double> dailyVolume = List.filled(7, 0.0);

    for (var record in records) {
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );

      // Filtrar por fecha (período actual)
      if (record.date.isAfter(
            startDate.subtract(const Duration(microseconds: 1)),
          ) &&
          record.date.isBefore(endDate)) {
        currentWeekVolume += record.totalWeight;
        weeklyExercises++;
        weeklySets += record.sets;

        // Calcular índice basado en diferencia de días desde startDate
        final dayIndex = recordDate.difference(startDate).inDays;
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyVolume[dayIndex] += record.totalWeight;
        }
      } else if (record.date.isAfter(startOfPriorPeriod) &&
          record.date.isBefore(endOfPriorPeriod)) {
        previousWeekVolume += record.totalWeight;
      }
    }

    // Calcular cambio porcentual
    double percentChange = 0.0;
    if (previousWeekVolume > 0) {
      percentChange =
          ((currentWeekVolume - previousWeekVolume) / previousWeekVolume) * 100;
    } else if (currentWeekVolume > 0) {
      percentChange = 100.0;
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
      'axisLabels': axisLabels,
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
            // Saludo con nombre cacheado
            Text(
              'Hola, $_userName',
              style: Theme.of(context).textTheme.displayMedium,
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
                final axisLabels = stats['axisLabels'] as List<String>;

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
                      'En los últimos 7 días has completado $weeklyExercises ejercicios.\n¡Sigue así!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Últimos 7 días',
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
                                    '${FormatUtils.formatWeight(currentVolume)} movidos en\n7 días!',
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
                              'Volumen',
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
                                          if (value.toInt() >= 0 &&
                                              value.toInt() <
                                                  axisLabels.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                axisLabels[value.toInt()],
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
