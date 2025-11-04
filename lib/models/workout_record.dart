import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutRecord {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int sets;
  final String unit; // 'kg' o 'lb'
  final DateTime date;
  final String userId;
  final bool isPersonalRecord;

  WorkoutRecord({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    this.unit = 'kg',
    required this.date,
    required this.userId,
    this.isPersonalRecord = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'unit': unit,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'isPersonalRecord': isPersonalRecord,
    };
  }

  factory WorkoutRecord.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutRecord(
      id: id,
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      reps: map['reps'] ?? 0,
      sets: map['sets'] ?? 1,
      unit: map['unit'] ?? 'kg',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      isPersonalRecord: map['isPersonalRecord'] ?? false,
    );
  }

  double get totalWeight => weight * reps * sets;
}
