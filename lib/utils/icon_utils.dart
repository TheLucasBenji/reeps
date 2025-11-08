import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/exercise_data.dart';
import '../models/exercise.dart';

class IconUtils {
  static IconData getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'Cuádriceps':
      case 'Piernas':
        return FontAwesomeIcons.personRunning;
      case 'Pecho':
        return FontAwesomeIcons.personSwimming;
      case 'Espalda':
      case 'Dorsales':
        return FontAwesomeIcons.weightHanging;
      case 'Hombros':
        return FontAwesomeIcons.person;
      case 'Bíceps':
        return FontAwesomeIcons.handFist;
      case 'Tríceps':
        return FontAwesomeIcons.hand;
      case 'Abdominales':
        return FontAwesomeIcons.heartPulse;
      case 'Cardio':
        return FontAwesomeIcons.bicycle;
      case 'Glúteos':
        return FontAwesomeIcons.personWalking;
      default:
        return FontAwesomeIcons.dumbbell;
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
