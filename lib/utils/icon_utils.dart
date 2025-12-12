import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../data/exercise_data.dart';
import '../models/exercise.dart';

class IconUtils {
  static IconData getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'Pecho': // Chest
        return MdiIcons.weightLifter;
      case 'Espalda': // Back
        return MdiIcons.rowing;
      case 'Hombros': // Shoulders
        return MdiIcons.humanHandsup;
      case 'Bíceps': // Biceps
        return MdiIcons.armFlex;
      case 'Tríceps': // Triceps
        return MdiIcons.armFlexOutline;
      case 'Abdominales': // Abs
        return MdiIcons.stomach; 
      case 'Cardio': // Cardio
        return MdiIcons.heartPulse;
      case 'Piernas': // Legs
        return MdiIcons.run;
      default:
        return MdiIcons.dumbbell;
    }
  }

  static IconData getIconForExercise(String exerciseName) {
    final exercises = ExerciseData.getAllExercises();
    final exercise = exercises.firstWhere(
      (e) => e.name == exerciseName,
      orElse: () => Exercise(id: '', name: '', muscleGroup: ''),
    );
    return getMuscleGroupIcon(exercise.muscleGroup);
  }
}
