import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/icon_utils.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
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
                    AppTheme.primaryPurple.withOpacity(0.3),
                    AppTheme.accentPurple.withOpacity(0.1),
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
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconUtils.getMuscleGroupIcon(exercise.muscleGroup),
                      color: AppTheme.primaryPurple,
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
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppTheme.primaryPurple,
                    onPressed: () {
                      // TODO: Añadir nuevo registro
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de registros de ejemplo
            _buildRecordCard(
              context,
              date: '12 de junio de 2025',
              weight: '100 kg',
              reps: '5 reps',
              sets: '3 sets',
              isPR: true,
            ),
            _buildRecordCard(
              context,
              date: '24 de mayo de 2025',
              weight: '95 kg',
              reps: '5 reps',
              sets: '3 sets',
            ),
            _buildRecordCard(
              context,
              date: '16 de mayo de 2025',
              weight: '90 kg',
              reps: '5 reps',
              sets: '3 sets',
            ),
            _buildRecordCard(
              context,
              date: '29 de abril de 2025',
              weight: '75 kg',
              reps: '5 reps',
              sets: '3 sets',
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Añadir nuevo registro
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
        color: AppTheme.cardBackground,
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
                color: AppTheme.primaryPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PR',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
