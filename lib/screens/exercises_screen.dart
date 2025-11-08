import 'package:flutter/material.dart';
import '../data/exercise_data.dart';
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/search_utils.dart';
import '../widgets/exercise_card.dart';

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
        return ExerciseCard(exercise: exercise);
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
          return ExerciseCard(exercise: exercises[index]);
        },
      ),
    );
  }
}
