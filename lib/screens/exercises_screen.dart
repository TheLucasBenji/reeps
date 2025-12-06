import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/search_utils.dart';
import '../widgets/exercise_card.dart';
import '../services/firestore_service.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  // Los grupos musculares siguen siendo estáticos por ahora, o podrían derivarse de los ejercicios
  final List<String> _muscleGroups = [
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

  List<Exercise> _filterExercises(List<Exercise> allExercises) {
    if (_searchQuery.isEmpty) {
      return allExercises;
    }
    return allExercises
        .where(
          (exercise) => SearchUtils.matchesQueryMultipleFields([
            exercise.name,
            exercise.muscleGroup,
          ], _searchQuery),
        )
        .toList();
  }

  List<Exercise> _getExercisesByGroup(List<Exercise> exercises, String group) {
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
            onPressed: () async {
              showSearch(context: context, delegate: ExerciseSearchDelegate());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor(context),
          labelColor: AppTheme.textPrimaryColor(context),
          unselectedLabelColor: AppTheme.textSecondaryColor(context),
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Grupos'),
          ],
        ),
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: FirestoreService().getExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allExercises = snapshot.data ?? [];
          final filteredExercises = _filterExercises(allExercises);

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab de todos los ejercicios
              _buildAllExercisesList(filteredExercises),

              // Tab de grupos musculares
              _buildGroupedExercises(filteredExercises),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllExercisesList(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return const Center(child: Text('No se encontraron ejercicios'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseCard(exercise: exercise);
      },
    );
  }

  Widget _buildGroupedExercises(List<Exercise> allExercises) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _muscleGroups.length - 1, // Excluir "Todos"
      itemBuilder: (context, index) {
        final group = _muscleGroups[index + 1];
        final exercises = _getExercisesByGroup(allExercises, group);

        if (exercises.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor(context),
                ),
              ),
            ),
            ...exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExerciseCard(exercise: exercise),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ExerciseSearchDelegate extends SearchDelegate<Exercise?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
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
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder<List<Exercise>>(
      stream: FirestoreService().getExercises(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exercises = snapshot.data!
            .where(
              (exercise) => SearchUtils.matchesQueryMultipleFields([
                exercise.name,
                exercise.muscleGroup,
              ], query),
            )
            .toList();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              return ExerciseCard(exercise: exercises[index]);
            },
          ),
        );
      },
    );
  }
}
