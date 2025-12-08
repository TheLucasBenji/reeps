import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 
import '../config/theme.dart';
import '../utils/icon_utils.dart';
import '../models/workout_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Semana'; // Semana, Mes, Total
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser?.uid;
  }

  // --- Helper Methods for Data Processing ---

  List<WorkoutRecord> _filterRecordsByPeriod(
      List<WorkoutRecord> allRecords, String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (period == 'Semana') {
      // Semana actual (Lunes a Domingo)
      final start = today.subtract(Duration(days: today.weekday - 1));
      // Queremos todo desde el lunes
      return allRecords.where((r) => r.date.isAfter(start.subtract(const Duration(microseconds: 1)))).toList();
    } else if (period == 'Mes') {
      // Mes actual (1 al último día)
      final start = DateTime(today.year, today.month, 1);
      return allRecords.where((r) => r.date.isAfter(start.subtract(const Duration(seconds: 1)))).toList();
    } else {
      // Total (o este año, por simplicidad mostramos todo)
      return allRecords;
    }
  }

  // Generar puntos para el gráfico
  List<FlSpot> _getSpots(List<WorkoutRecord> records, String period) {
    if (records.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<int, double> volumeMap = {}; // index -> volume

    if (period == 'Semana') {
      // X = 0 (Lunes) ... 6 (Domingo)
      for (int i = 0; i < 7; i++) {
        volumeMap[i] = 0;
      }
      // Inicio de la semana (Lunes)
      final start = today.subtract(Duration(days: today.weekday - 1));

      for (var r in records) {
        // Normalizar fecha del registro a medianoche
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        
        // Calcular diferencia en días desde el inicio del periodo
        final dayDiff = rDate.difference(start).inDays;
         // Asegurar que esté en rango 0-6
        if (dayDiff >= 0 && dayDiff <= 6) {
             volumeMap[dayDiff] = (volumeMap[dayDiff] ?? 0) + r.totalWeight;
        }
      }
    } else if (period == 'Mes') {
       // Mes actual: X = día del mes real (1..31)
       // Generar spots para todos los días del mes hasta hoy
       final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
       
       for (int i = 1; i <= daysInMonth; i++) {
         volumeMap[i] = 0;
       }
       
       for (var r in records) {
          if (r.date.month == now.month && r.date.year == now.year) {
             volumeMap[r.date.day] = (volumeMap[r.date.day] ?? 0) + r.totalWeight;
          }
       }

    } else {
      // Total: Agrupar por mes (0-11) del año actual
      for(int i=0; i<12; i++) volumeMap[i] = 0;
      
      for(var r in records) {
        if(r.date.year == now.year) {
          int monthIndex = r.date.month - 1; // 0=Ene
          volumeMap[monthIndex] = (volumeMap[monthIndex] ?? 0) + r.totalWeight;
        }
      }
    }

    // Convertir map a List<FlSpot>
    List<FlSpot> spots = [];
    final sortedKeys = volumeMap.keys.toList()..sort();
    for (var k in sortedKeys) {
      spots.add(FlSpot(k.toDouble(), volumeMap[k]!));
    }
    return spots;
  }

  // Calcular cambio porcentual (Comparar periodo actual con anterior)
  String _calculateGrowth(List<WorkoutRecord> allRecords, String period) {
     // Lógica simplificada: 
     // Semana: comparar sum(esta semana) vs sum(semana pasada)
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     
     DateTime startCurrent;
     DateTime endCurrent = now;
     DateTime startPrevious;
     DateTime endPrevious;

     if (period == 'Semana') {
       startCurrent = today.subtract(Duration(days: today.weekday - 1));
       startPrevious = startCurrent.subtract(const Duration(days: 7));
       endPrevious = startCurrent.subtract(const Duration(microseconds: 1));
     } else if (period == 'Mes') {
       // Comparar este mes vs mes pasado
       startCurrent = DateTime(now.year, now.month, 1);
       startPrevious = DateTime(now.year, now.month - 1, 1);
       // Fin del mes anterior
       endPrevious = startCurrent.subtract(const Duration(seconds: 1));
     } else {
       // Total: comparar este año vs año pasado (o mes actual vs mes pasado global)
       // Simplificación: comparar este mes vs mes pasado
       startCurrent = DateTime(now.year, now.month, 1);
       startPrevious = DateTime(now.year, now.month - 1, 1);
       endPrevious = startCurrent.subtract(const Duration(seconds: 1));
     }

     double currentVol = 0;
     double prevVol = 0;

     for(var r in allRecords) {
       if(r.date.isAfter(startCurrent) && r.date.isBefore(endCurrent.add(const Duration(days: 1)))) {
         currentVol += r.totalWeight;
       } else if (r.date.isAfter(startPrevious) && r.date.isBefore(endPrevious)) {
         prevVol += r.totalWeight;
       }
     }

     if (prevVol == 0) return currentVol > 0 ? '+100%' : '0%';
     final change = ((currentVol - prevVol) / prevVol) * 100;
     return '${change >= 0 ? '+' : ''}${change.toInt()}%';
  }


  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: StreamBuilder<List<WorkoutRecord>>(
        stream: _firestoreService.getWorkoutRecords(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allRecords = snapshot.data ?? [];
          final filteredRecords = _filterRecordsByPeriod(allRecords, _selectedPeriod);
          final spots = _getSpots(allRecords, _selectedPeriod); 

          // Filtrar records para el periodo seleccionado
          
          
          final growthLabel = _calculateGrowth(allRecords, _selectedPeriod);
          final isPositiveGrowth = !growthLabel.startsWith('-');

          // Encontrar maxY para el gráfico
          double maxY = 0;
          for (var spot in spots) {
            if (spot.y > maxY) maxY = spot.y;
          }
          if (maxY == 0) maxY = 10;
          maxY *= 1.2;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de período
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PeriodChip(
                              label: 'Semana',
                              isSelected: _selectedPeriod == 'Semana',
                              onTap: () => setState(() => _selectedPeriod = 'Semana'),
                              fillWidth: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PeriodChip(
                              label: 'Mes',
                              isSelected: _selectedPeriod == 'Mes',
                              onTap: () => setState(() => _selectedPeriod = 'Mes'),
                              fillWidth: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PeriodChip(
                              label: 'Año',
                              isSelected: _selectedPeriod == 'Año',
                              onTap: () => setState(() => _selectedPeriod = 'Año'),
                              fillWidth: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Gráfico
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                                'Volumen de Entrenamiento',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (isPositiveGrowth ? AppTheme.successColor(context) : Colors.redAccent).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                growthLabel,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: isPositiveGrowth ? AppTheme.successColor(context) : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedPeriod == 'Semana' ? 'Esta semana' 
                          : _selectedPeriod == 'Mes' ? DateFormat('MMMM', 'es_ES').format(DateTime.now()).capitalize() : 'Este año',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: spots.isEmpty 
                          ? Center(child: Text("Sin datos", style: Theme.of(context).textTheme.bodyMedium))
                          : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: maxY / 5,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: AppTheme.textSecondaryColor(
                                      context,
                                    ).withOpacity(0.1),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
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
                                    interval: 1, // Force interval to 1 to avoid duplicate labels
                                    getTitlesWidget: (value, meta) {
                                      // Etiquetas eje X
                                      if (_selectedPeriod == 'Semana') {
                                        // 0..6 -> Lun .. Dom
                                        const days = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            value.toInt() >= 0 && value.toInt() < 7 ? days[value.toInt()] : '',
                                            style: Theme.of(context).textTheme.bodySmall, 
                                          ),
                                        );
                                      } else if (_selectedPeriod == 'Mes') {
                                        // 1..31 -> Mostrar cada 5 días y el 1
                                        final day = value.toInt();
                                        if (day == 1 || day % 5 == 0) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                '$day',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            );
                                        }
                                      } else {
                                        // Año -> Mostrar meses: 0=Ene, 1=Feb
                                        if (value >= 0 && value < 12) {
                                          const months = ['En', 'Fe', 'Ma', 'Ab', 'My', 'Jn', 'Jl', 'Ag', 'Se', 'Oc', 'No', 'Di'];
                                          return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                months[value.toInt()],
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                          );
                                        }
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
                                  spots: spots,
                                  isCurved: true,
                                  preventCurveOverShooting: true,
                                  color: AppTheme.primaryColor(context),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: AppTheme.primaryColor(context),
                                        strokeWidth: 2,
                                        strokeColor: Theme.of(context).scaffoldBackgroundColor,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(show: false),
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
                
                // Lista de Historial Reciente (los últimos 10 de lo que se esté mostrando o global)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial Reciente',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                filteredRecords.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No hay registros en este periodo.")),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRecords.take(10).length, // Mostrar max 10
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      // Formato de fecha
                      final dateStr = DateFormat("d MMM, H:mm", 'es_ES').format(record.date);
                      
                      return _buildExerciseRecord(
                        context, 
                        icon: IconUtils.getIconForExercise(record.exerciseName),
                        name: record.exerciseName,
                        details: '${record.weight.toStringAsFixed(0)}${record.unit} × ${record.reps} reps × ${record.sets} sets',
                        date: dateStr,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseRecord(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String details,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name, 
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      date, 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(details, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool fillWidth;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.fillWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fillWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor(context)
              : AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? AppTheme.textPrimaryColor(context)
                : AppTheme.textSecondaryColor(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
