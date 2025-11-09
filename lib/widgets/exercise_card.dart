import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/icon_utils.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final Widget? leading;
  final EdgeInsets? margin;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.leading,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading:
            leading ??
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconUtils.getMuscleGroupIcon(exercise.muscleGroup),
                color: AppTheme.primaryColor(context),
              ),
            ),
        title: Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          exercise.muscleGroup,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondaryColor(context),
        ),
        onTap:
            onTap ??
            () {
              Navigator.pushNamed(
                context,
                '/exercise_detail',
                arguments: exercise,
              );
            },
      ),
    );
  }
}
