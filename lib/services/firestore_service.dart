import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import '../models/workout_record.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Guardar perfil de usuario
  Future<void> saveUserProfile(String userId, UserProfile profile) async {
    await _db.collection('users').doc(userId).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  // Obtener perfil de usuario
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

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
  
  // Obtener historial de entrenamientos de un usuario
  Future<List<WorkoutRecord>> getRawWorkoutRecords(String userId) async {
    final snapshot = await _db
        .collection('workout_records')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return WorkoutRecord.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Importar datos
  Future<void> importData(String userId, Map<String, dynamic> data) async {
     final batch = _db.batch();

     // Profile
     if (data['profile'] != null) {
       final profileRef = _db.collection('users').doc(userId);
       batch.set(profileRef, data['profile'], SetOptions(merge: true));
     }

     // Workouts
     if (data['workouts'] != null && data['workouts'] is List) {
       final workouts = data['workouts'] as List;
       final collectionRef = _db.collection('workout_records');
       
       for (var w in workouts) {
         // Asegurarse de que el userId coincida con el usuario actual
         final record = Map<String, dynamic>.from(w);
         record['userId'] = userId; 
         
         // Convertir fecha ISO string a Timestamp para Firestore
         if (record['date'] is String) {
           record['date'] = Timestamp.fromDate(DateTime.parse(record['date']));
         }
         
         // Generar nuevo ID para importar
         final docRef = collectionRef.doc();
         batch.set(docRef, record);
       }
     }
     
     await batch.commit();
  }

  // Eliminar un registro
  Future<void> deleteWorkoutRecord(String recordId) async {
    await _db.collection('workout_records').doc(recordId).delete();
  }
}
