import '../models/exercise.dart';

class ExerciseData {
  static List<Exercise> getAllExercises() {
    return [
      // Piernas (Cuádriceps)
      Exercise(id: '1', name: 'Sentadillas', muscleGroup: 'Piernas'),
      Exercise(id: '2', name: 'Prensa de piernas', muscleGroup: 'Piernas'),
      Exercise(
        id: '3',
        name: 'Extensiones de piernas',
        muscleGroup: 'Piernas',
      ),
      Exercise(id: '4', name: 'Zancadas', muscleGroup: 'Piernas'),
      Exercise(id: '5', name: 'Sentadilla búlgara', muscleGroup: 'Piernas'),
      Exercise(
        id: '6',
        name: 'Elevación de talones',
        muscleGroup: 'Piernas',
      ),

      // Pecho
      Exercise(id: '7', name: 'Press de banca', muscleGroup: 'Pecho'),
      Exercise(id: '8', name: 'Press inclinado', muscleGroup: 'Pecho'),
      Exercise(id: '9', name: 'Press declinado', muscleGroup: 'Pecho'),
      Exercise(
        id: '10',
        name: 'Aperturas con mancuernas',
        muscleGroup: 'Pecho',
      ),
      Exercise(id: '11', name: 'Fondos en paralelas', muscleGroup: 'Pecho'),
      Exercise(id: '12', name: 'Pullover', muscleGroup: 'Pecho'),

      // Espalda
      Exercise(id: '13', name: 'Peso muerto', muscleGroup: 'Espalda'),
      Exercise(id: '14', name: 'Dominadas', muscleGroup: 'Espalda'),
      Exercise(id: '15', name: 'Remo con barra', muscleGroup: 'Espalda'),
      Exercise(id: '16', name: 'Remo con mancuerna', muscleGroup: 'Espalda'),
      Exercise(id: '17', name: 'Jalón al pecho', muscleGroup: 'Espalda'),
      Exercise(id: '18', name: 'Remo en polea baja', muscleGroup: 'Espalda'),

      // Hombros
      Exercise(id: '19', name: 'Press militar', muscleGroup: 'Hombros'),
      Exercise(id: '20', name: 'Press con mancuernas', muscleGroup: 'Hombros'),
      Exercise(id: '21', name: 'Elevaciones laterales', muscleGroup: 'Hombros'),
      Exercise(id: '22', name: 'Elevaciones frontales', muscleGroup: 'Hombros'),
      Exercise(id: '23', name: 'Pájaros', muscleGroup: 'Hombros'),
      Exercise(id: '24', name: 'Face pull', muscleGroup: 'Hombros'),

      // Bíceps
      Exercise(id: '25', name: 'Curl con barra', muscleGroup: 'Bíceps'),
      Exercise(id: '26', name: 'Curl con mancuernas', muscleGroup: 'Bíceps'),
      Exercise(id: '27', name: 'Curl martillo', muscleGroup: 'Bíceps'),
      Exercise(id: '28', name: 'Curl concentrado', muscleGroup: 'Bíceps'),
      Exercise(id: '29', name: 'Curl en predicador', muscleGroup: 'Bíceps'),

      // Tríceps
      Exercise(id: '30', name: 'Press francés', muscleGroup: 'Tríceps'),
      Exercise(id: '31', name: 'Extensiones en polea', muscleGroup: 'Tríceps'),
      Exercise(id: '32', name: 'Fondos para tríceps', muscleGroup: 'Tríceps'),
      Exercise(id: '33', name: 'Patada de tríceps', muscleGroup: 'Tríceps'),
      Exercise(id: '34', name: 'Press cerrado', muscleGroup: 'Tríceps'),

      // Piernas (general)
      Exercise(id: '35', name: 'Curl femoral', muscleGroup: 'Piernas'),
      Exercise(id: '36', name: 'Hip thrust', muscleGroup: 'Piernas'),
      Exercise(
        id: '37',
        name: 'Elevación de gemelos sentado',
        muscleGroup: 'Piernas',
      ),
      Exercise(
        id: '38',
        name: 'Elevación de gemelos de pie',
        muscleGroup: 'Piernas',
      ),

      // Abdominales
      Exercise(id: '39', name: 'Crunches', muscleGroup: 'Abdominales'),
      Exercise(id: '40', name: 'Plancha', muscleGroup: 'Abdominales'),
      Exercise(
        id: '41',
        name: 'Elevación de piernas',
        muscleGroup: 'Abdominales',
      ),
      Exercise(id: '42', name: 'Russian twist', muscleGroup: 'Abdominales'),
      Exercise(id: '43', name: 'Ab wheel', muscleGroup: 'Abdominales'),

      // Cardio
      Exercise(id: '44', name: 'Burpees', muscleGroup: 'Cardio'),
      Exercise(id: '45', name: 'Saltos de caja', muscleGroup: 'Cardio'),
      Exercise(id: '46', name: 'Mountain climbers', muscleGroup: 'Cardio'),

      // Piernas (Glúteos)
      Exercise(id: '47', name: 'Patada de glúteo', muscleGroup: 'Piernas'),
      Exercise(id: '48', name: 'Abducción de cadera', muscleGroup: 'Piernas'),
      Exercise(id: '49', name: 'Puente de glúteos', muscleGroup: 'Piernas'),
      
      // Combinados
      // Espalda (continuación)
      Exercise(id: '50', name: 'Pull over en polea', muscleGroup: 'Espalda'),
      Exercise(id: '51', name: 'Remo en máquina', muscleGroup: 'Espalda'),

      // Pecho (continuación)
      Exercise(id: '52', name: 'Cristos en polea', muscleGroup: 'Pecho'),
      Exercise(id: '53', name: 'Press en máquina', muscleGroup: 'Pecho'),

      // Piernas (Pantorrillas)
      Exercise(
        id: '54',
        name: 'Elevación de pantorrillas en prensa',
        muscleGroup: 'Piernas',
      ),

      // Piernas (Isquiotibiales)
      Exercise(
        id: '55',
        name: 'Peso muerto rumano',
        muscleGroup: 'Piernas',
      ),
      Exercise(id: '56', name: 'Buenos días', muscleGroup: 'Piernas'),
    ];
  }

  static List<String> getMuscleGroups() {
    return [
      'Todos',
      'Pecho',
      'Espalda',
      'Hombros',
      'Bíceps',
      'Tríceps',
      'Piernas',
      'Abdominales',
      'Cardio',
    ];
  }
}
