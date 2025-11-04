import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/search_utils.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final List<String> _muscleGroups = ExerciseData.getMuscleGroups();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Exercise> _getFilteredExercises() {
    List<Exercise> exercises = ExerciseData.getAllExercises();

    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where(
            (exercise) => SearchUtils.matchesQueryMultipleFields([
              exercise.name,
              exercise.muscleGroup,
            ], _searchQuery),
          )
          .toList();
    }

    return exercises;
  }

  List<Exercise> _getExercisesByGroup(String group) {
    List<Exercise> exercises = _getFilteredExercises();

    if (group == 'Todos') {
      return exercises;
    }

    return exercises.where((e) => e.muscleGroup == group).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ExerciseSearchDelegate());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Grupos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de todos los ejercicios
          _buildAllExercisesList(),

          // Tab de grupos musculares
          _buildGroupedExercises(),
        ],
      ),
    );
  }

  Widget _buildAllExercisesList() {
    final exercises = _getFilteredExercises();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _ExerciseCard(exercise: exercise);
      },
    );
  }

  Widget _buildGroupedExercises() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _muscleGroups.length - 1, // Excluir "Todos"
      itemBuilder: (context, index) {
        final group = _muscleGroups[index + 1];
        final exercises = _getExercisesByGroup(group);

        if (exercises.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryPurple),
              ),
            ),
            ...exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ExerciseCard(exercise: exercise),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: AppTheme.primaryPurple,
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
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        onTap: () {
        },
      ),
    );
  }
}

class ExerciseSearchDelegate extends SearchDelegate<Exercise?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.darkBackground,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final exercises = ExerciseData.getAllExercises()
        .where(
          (exercise) => SearchUtils.matchesQueryMultipleFields([
            exercise.name,
            exercise.muscleGroup,
          ], query),
        )
        .toList();

    return Container(
      color: AppTheme.darkBackground,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return _ExerciseCard(exercise: exercises[index]);
        },
      ),
    );
  }
}


class ExerciseData {
  static List<Exercise> getAllExercises() {
    return [
      // Cuádriceps
      Exercise(id: '1', name: 'Sentadillas', muscleGroup: 'Cuádriceps'),
      Exercise(id: '2', name: 'Prensa de piernas', muscleGroup: 'Cuádriceps'),
      Exercise(
        id: '3',
        name: 'Extensiones de piernas',
        muscleGroup: 'Cuádriceps',
      ),
      Exercise(id: '4', name: 'Zancadas', muscleGroup: 'Cuádriceps'),
      Exercise(id: '5', name: 'Sentadilla búlgara', muscleGroup: 'Cuádriceps'),
      Exercise(
        id: '6',
        name: 'Elevación de talones',
        muscleGroup: 'Cuádriceps',
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

      // Glúteos
      Exercise(id: '47', name: 'Patada de glúteo', muscleGroup: 'Glúteos'),
      Exercise(id: '48', name: 'Abducción de cadera', muscleGroup: 'Glúteos'),
      Exercise(id: '49', name: 'Puente de glúteos', muscleGroup: 'Glúteos'),

      // Dorsales
      Exercise(id: '50', name: 'Pull over en polea', muscleGroup: 'Dorsales'),
      Exercise(id: '51', name: 'Remo en máquina', muscleGroup: 'Dorsales'),

      // Pectorales
      Exercise(id: '52', name: 'Cristos en polea', muscleGroup: 'Pectorales'),
      Exercise(id: '53', name: 'Press en máquina', muscleGroup: 'Pectorales'),

      // Pantorrillas
      Exercise(
        id: '54',
        name: 'Elevación de pantorrillas en prensa',
        muscleGroup: 'Pantorrillas',
      ),

      // Isquiotibiales
      Exercise(
        id: '55',
        name: 'Peso muerto rumano',
        muscleGroup: 'Isquiotibiales',
      ),
      Exercise(id: '56', name: 'Buenos días', muscleGroup: 'Isquiotibiales'),
    ];
  }

  static List<String> getMuscleGroups() {
    return [
      'Todos',
      'Cuádriceps',
      'Pecho',
      'Espalda',
      'Hombros',
      'Bíceps',
      'Tríceps',
      'Piernas',
      'Abdominales',
      'Cardio',
      'Glúteos',
      'Dorsales',
      'Pectorales',
      'Pantorrillas',
      'Isquiotibiales',
    ];
  }
}

