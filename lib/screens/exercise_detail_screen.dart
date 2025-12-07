import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise.dart';
import '../models/workout_record.dart';
import '../config/theme.dart';
import '../utils/icon_utils.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'add_workout_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor(context).withOpacity(0.3),
                    AppTheme.accentColor(context).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor(context).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconUtils.getMuscleGroupIcon(exercise.muscleGroup),
                      color: AppTheme.primaryColor(context),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise.muscleGroup,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Historial de registros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial de registros',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor(context),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWorkoutScreen(initialExercise: exercise),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de registros dinámica
            if (user != null)
              StreamBuilder<List<WorkoutRecord>>(
                stream: FirestoreService().getWorkoutRecords(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Filtrar solo los records de este ejercicio
                  final allRecords = snapshot.data ?? [];
                  final exerciseRecords = allRecords.where((r) => r.exerciseId == exercise.id).toList();

                  if (exerciseRecords.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No hay registros aún. ¡Añade el primero!'),
                      ),
                    );
                  }

                  // Calcular PR
                  double maxWeight = 0;
                  for (var r in exerciseRecords) {
                    if (r.weight > maxWeight) maxWeight = r.weight;
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exerciseRecords.length,
                    itemBuilder: (context, index) {
                      final record = exerciseRecords[index];
                      final isPR = record.weight == maxWeight && maxWeight > 0;
                      final dateStr = DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(record.date);

                      return _buildRecordCard(
                        context,
                        date: dateStr,
                        weight: '${record.weight.toStringAsFixed(record.weight.truncateToDouble() == record.weight ? 0 : 1)} ${record.unit}',
                        reps: '${record.reps} reps',
                        sets: '${record.sets} sets',
                        isPR: isPR,
                      );
                    },
                  );
                },
              )
            else
               const Center(child: Text('Debes iniciar sesión para ver tu historial')),


            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWorkoutScreen(initialExercise: exercise),
            ),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context, {
    required String date,
    required String weight,
    required String reps,
    required String sets,
    bool isPR = false,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '$weight x $reps x $sets',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isPR)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PR',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
