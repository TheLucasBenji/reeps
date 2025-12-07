import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importar FaIcon
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/search_utils.dart';
import '../utils/icon_utils.dart'; 
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
  String? _selectedMuscleGroup; // Estado para el grupo seleccionado

  final List<String> _muscleGroups = [
    'Pecho',
    'Espalda',
    'Hombros',
    'Bíceps',
    'Tríceps',
    'Piernas',
    'Abdominales',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Limpiar selección al cambiar de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedMuscleGroup = null;
        });
      }
    });
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
              _buildGroupedExercisesTab(filteredExercises),
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

  Widget _buildGroupedExercisesTab(List<Exercise> allExercises) {
    // Si hay un grupo seleccionado, mostramos la lista de ese grupo
    if (_selectedMuscleGroup != null) {
      final groupExercises = _getExercisesByGroup(allExercises, _selectedMuscleGroup!);
      
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            _selectedMuscleGroup = null;
          });
          return false; // No salir de la pantalla, solo volver al grid
        },
        child: Column(
          children: [
            // Header del grupo con botón volver
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              color: AppTheme.surfaceColor(context),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedMuscleGroup = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Icon(
                        IconUtils.getMuscleGroupIcon(_selectedMuscleGroup!),
                        color: AppTheme.primaryColor(context),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedMuscleGroup!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: groupExercises.isEmpty 
              ? const Center(child: Text("No hay ejercicios para este grupo"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupExercises.length,
                itemBuilder: (context, index) {
                  return ExerciseCard(exercise: groupExercises[index]);
                },
              ),
            ),
          ],
        ),
      );
    }

    // Si no hay selección, mostramos el Grid de Grupos
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _muscleGroups.length,
      itemBuilder: (context, index) {
        final group = _muscleGroups[index];
        return _buildGroupCard(group, allExercises);
      },
    );
  }

  Widget _buildGroupCard(String group, List<Exercise> allExercises) {
     // Contar ejercicios en este grupo (opcional, pero útil)
     final count = allExercises.where((e) => e.muscleGroup == group).length;

     return GestureDetector(
       onTap: () {
         setState(() {
           _selectedMuscleGroup = group;
         });
       },
       child: Container(
         decoration: BoxDecoration(
           color: AppTheme.surfaceColor(context),
           borderRadius: BorderRadius.circular(16),
           border: Border.all(
              color: AppTheme.primaryColor(context).withOpacity(0.1),
           ),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             ),
           ],
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               width: 64,
               height: 64,
               decoration: BoxDecoration(
                 color: AppTheme.primaryColor(context).withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
               alignment: Alignment.center,
               child: FaIcon(
                 IconUtils.getMuscleGroupIcon(group),
                 color: AppTheme.primaryColor(context),
                 size: 28, // Reduced slightly to avoid visual overflow
               ),
             ),
             const SizedBox(height: 12),
             Text(
               group,
               style: Theme.of(context).textTheme.titleMedium,
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 4),
             Text(
               '$count ejercicios',
               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                 color: AppTheme.textSecondaryColor(context),
               ),
             ),
           ],
         ),
       ),
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
