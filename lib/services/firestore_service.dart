import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import '../models/workout_record.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener ejercicios (Stream)
  Stream<List<Exercise>> getExercises() {
    return _db.collection('exercises').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Exercise.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Guardar un registro de entrenamiento
  Future<void> saveWorkoutRecord(WorkoutRecord record) async {
    await _db.collection('workout_records').add(record.toMap());
  }

  // Obtener historial de entrenamientos de un usuario
  Stream<List<WorkoutRecord>> getWorkoutRecords(String userId) {
    return _db
        .collection('workout_records')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkoutRecord.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Eliminar un registro
  Future<void> deleteWorkoutRecord(String recordId) async {
    await _db.collection('workout_records').doc(recordId).delete();
  }
}
