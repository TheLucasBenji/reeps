import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/exercise_data.dart';
import '../models/exercise.dart';
import '../config/theme.dart';
import '../utils/search_utils.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  Exercise? _selectedExercise;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController(
    text: '3',
  );
  String _selectedUnit = 'kg';
  late TextEditingController _searchController;
  bool _showExerciseDropdown = false;
  late List<Exercise> _filteredExercises;

  @override
  void initState() {
    super.initState();
    _setsController.text = '3';
    _repsController.text = '10';

    _filteredExercises = ExerciseData.getAllExercises();

    _searchController = TextEditingController();
    _searchController.addListener(() {
      _filterExercises();
      setState(() {});
    });

    _weightController.addListener(() => setState(() {}));
    _repsController.addListener(() => setState(() {}));
    _setsController.addListener(() => setState(() {}));
  }

  void _filterExercises() {
    final query = _searchController.text;
    setState(() {
      _filteredExercises = ExerciseData.getAllExercises()
          .where(
            (exercise) => SearchUtils.matchesQueryMultipleFields([
              exercise.name,
              exercise.muscleGroup,
            ], query),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExerciseDropdown() {
    setState(() {
      _showExerciseDropdown = !_showExerciseDropdown;
      if (_showExerciseDropdown) {
        _searchController.clear();
        _filteredExercises = ExerciseData.getAllExercises();
      }
    });
  }

  void _selectExercise(Exercise exercise) {
    setState(() {
      _selectedExercise = exercise;
      _showExerciseDropdown = false;
      _searchController.clear();
    });
  }

  void _saveWorkout() {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un ejercicio')),
      );
      return;
    }

    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el peso')),
      );
      return;
    }

    if (_repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa las repeticiones')),
      );
      return;
    }

    if (_setsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa los sets')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Registro guardado exitosamente!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      "d 'de' MMMM 'de' y, h:mm a",
      'es_ES',
    ).format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar peso'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ejercicio', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _showExerciseDropdown
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar ejercicio...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showExerciseDropdown = false;
                              _searchController.clear();
                              _filteredExercises =
                                  ExerciseData.getAllExercises();
                            });
                          },
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _toggleExerciseDropdown,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedExercise?.name ??
                                  'Selecciona un ejercicio',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: _selectedExercise == null
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                  ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
              if (_showExerciseDropdown)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: _filteredExercises.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron ejercicios',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return ListTile(
                              title: Text(exercise.name),
                              subtitle: Text(exercise.muscleGroup),
                              onTap: () => _selectExercise(exercise),
                              tileColor: _selectedExercise?.id == exercise.id
                                  ? AppTheme.primaryPurple.withOpacity(0.1)
                                  : null,
                            );
                          },
                        ),
                ),
              const SizedBox(height: 32),
              Text('Peso', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Ingresa el peso',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedUnit = 'lb'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _selectedUnit == 'lb'
                                    ? AppTheme.primaryPurple
                                    : AppTheme.cardBackground,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'lb',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedUnit = 'kg'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _selectedUnit == 'kg'
                                    ? AppTheme.primaryPurple
                                    : AppTheme.cardBackground,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'kg',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Repeticiones',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove,
                        color: AppTheme.primaryPurple,
                      ),
                      onPressed: () {
                        int currentValue =
                            int.tryParse(_repsController.text) ?? 1;
                        if (currentValue > 1) {
                          setState(() {
                            _repsController.text = (currentValue - 1)
                                .toString();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: const InputDecoration(hintText: '10'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: AppTheme.primaryPurple,
                      ),
                      onPressed: () {
                        int currentValue =
                            int.tryParse(_repsController.text) ?? 1;
                        setState(() {
                          _repsController.text = (currentValue + 1).toString();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Sets', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove,
                        color: AppTheme.primaryPurple,
                      ),
                      onPressed: () {
                        int currentValue =
                            int.tryParse(_setsController.text) ?? 1;
                        if (currentValue > 1) {
                          setState(() {
                            _setsController.text = (currentValue - 1)
                                .toString();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: const InputDecoration(hintText: '3'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: AppTheme.primaryPurple,
                      ),
                      onPressed: () {
                        int currentValue =
                            int.tryParse(_setsController.text) ?? 1;
                        setState(() {
                          _setsController.text = (currentValue + 1).toString();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildVolumeSummary(),
              const SizedBox(height: 32),

              // --- INICIO CORRECCIÓN ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),

              // --- FIN CORRECCIÓN ---
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveWorkout,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSummary() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    int reps = int.tryParse(_repsController.text) ?? 0;
    int sets = int.tryParse(_setsController.text) ?? 0;
    double totalVolume = weight * reps * sets;

    if (totalVolume == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.3),
            AppTheme.accentPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center,
                color: AppTheme.primaryPurple,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Volumen Total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${totalVolume.toStringAsFixed(1)} $_selectedUnit',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$sets sets × $reps reps × ${weight.toStringAsFixed(1)} $_selectedUnit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
