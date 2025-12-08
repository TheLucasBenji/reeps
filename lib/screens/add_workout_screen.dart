import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/workout_record.dart';
import '../config/theme.dart';
import '../utils/search_utils.dart';
import '../utils/icon_utils.dart';
import '../widgets/custom_button.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Exercise? initialExercise;

  const AddWorkoutScreen({super.key, this.initialExercise});

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String _selectedUnit = 'kg';
  late TextEditingController _searchController;
  bool _showExerciseDropdown = false;
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _selectedExercise = widget.initialExercise;
    // Valores por defecto
    _setsController.text = '3';
    _repsController.text = '10';

    // Inicializar controlador de búsqueda
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _filterExercises();
      setState(() {}); // Para actualizar el ícono de clear
    });

    // Listeners para actualizar el resumen en tiempo real
    _weightController.addListener(() => setState(() {}));
    _repsController.addListener(() => setState(() {}));
    _setsController.addListener(() => setState(() {}));
  }

  void _filterExercises() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises = _allExercises
            .where(
              (exercise) => SearchUtils.matchesQueryMultipleFields([
                exercise.name,
                exercise.muscleGroup,
              ], query),
            )
            .toList();
      }
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
        _filteredExercises = _allExercises;
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

  Future<void> _saveWorkout() async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un ejercicio')),
      );
      return;
    }

    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSaving = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener peso ingresado
      double weightValue = double.parse(_weightController.text.replaceAll(',', '.'));
      
      // Si el usuario ingresó en libras, convertir a kilogramos
      // 1 lb = 0.453592 kg
      if (_selectedUnit == 'lb') {
        weightValue = weightValue * 0.453592;
      }
      
      final record = WorkoutRecord(
        id: '', // Firestore genera el ID
        exerciseId: _selectedExercise!.id,
        exerciseName: _selectedExercise!.name,
        weight: weightValue, // Siempre guardado en kg
        reps: int.parse(_repsController.text),
        sets: int.parse(_setsController.text),
        unit: 'kg', // Siempre guardamos en kg internamente
        date: DateTime.now(),
        userId: user.uid,
      );

      await FirestoreService().saveWorkoutRecord(record);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro guardado exitosamente!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fecha formateada con la hora actual del dispositivo (locale español)
    final String formattedDate = DateFormat(
      "dd/MM/y, h:mm a",
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
      body: StreamBuilder<List<Exercise>>(
        stream: FirestoreService().getExercises(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allExercises = snapshot.data!;
            // Si no estamos buscando, actualizar la lista filtrada con todos los datos nuevos
            if (_searchController.text.isEmpty && !_showExerciseDropdown) {
              _filteredExercises = _allExercises;
            } else if (_filteredExercises.isEmpty && _searchController.text.isEmpty) {
               _filteredExercises = _allExercises;
            }
          }

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ejercicio
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
                                  _filteredExercises = _allExercises;
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
                              color: AppTheme.surfaceColor(context),
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
                                            ? AppTheme.textSecondaryColor(context)
                                            : AppTheme.textPrimaryColor(context),
                                      ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppTheme.textSecondaryColor(context),
                                ),
                              ],
                            ),
                          ),
                        ),

                  // Dropdown desplegable con lista de ejercicios
                  if (_showExerciseDropdown)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
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
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredExercises.isEmpty
                              ? Center(
                                  child: Text(
                                    'No se encontraron ejercicios',
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor(context),
                                        ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredExercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise = _filteredExercises[index];
                                    return ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor(
                                            context,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          IconUtils.getMuscleGroupIcon(
                                            exercise.muscleGroup,
                                          ),
                                          color: AppTheme.primaryColor(context),
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(exercise.name),
                                      subtitle: Text(exercise.muscleGroup),
                                      onTap: () => _selectExercise(exercise),
                                      tileColor: _selectedExercise?.id == exercise.id
                                          ? AppTheme.primaryColor(
                                              context,
                                            ).withOpacity(0.1)
                                          : null,
                                    );
                                  },
                                ),
                    ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Peso
                        Text('Peso', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: const InputDecoration(
                                  hintText: 'Ingresa el peso',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Ingresa el peso';
                                  final w = double.tryParse(v.replaceAll(',', '.'));
                                  if (w == null || w <= 0) return 'Peso inválido';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedUnit = 'lb'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedUnit == 'lb'
                                              ? AppTheme.primaryColor(context)
                                              : AppTheme.surfaceColor(context),
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(12),
                                              ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'lb',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedUnit = 'kg'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedUnit == 'kg'
                                              ? AppTheme.primaryColor(context)
                                              : AppTheme.surfaceColor(context),
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(12),
                                              ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'kg',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
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

                        // Repeticiones
                        Text(
                          'Repeticiones',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Botón decrementar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor(context),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: AppTheme.primaryColor(context),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
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
                            // Campo de texto
                            Expanded(
                              child: TextFormField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displaySmall,
                                decoration: const InputDecoration(hintText: '10'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Ingresa repeticiones';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 1)
                                    return 'Repeticiones inválidas';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón incrementar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor(context),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: AppTheme.primaryColor(context),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  int currentValue =
                                      int.tryParse(_repsController.text) ?? 1;
                                  setState(() {
                                    _repsController.text = (currentValue + 1)
                                        .toString();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Sets
                        Text('Sets', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Botón decrementar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor(context),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: AppTheme.primaryColor(context),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
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
                            // Campo de texto
                            Expanded(
                              child: TextFormField(
                                controller: _setsController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displaySmall,
                                decoration: const InputDecoration(hintText: '3'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Ingresa sets';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 1) return 'Sets inválidos';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón incrementar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor(context),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: AppTheme.primaryColor(context),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  int currentValue =
                                      int.tryParse(_setsController.text) ?? 1;
                                  setState(() {
                                    _setsController.text = (currentValue + 1)
                                        .toString();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Resumen del volumen total
                  _buildVolumeSummary(),

                  const SizedBox(height: 32),

                  // Fecha (automática)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor(context).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppTheme.textSecondaryColor(context),
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

                  const SizedBox(height: 48),

                  // Botón Guardar
                  CustomButton(
                    text: 'Guardar',
                    onPressed: _saveWorkout,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          );
        },
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
            AppTheme.primaryColor(context).withOpacity(0.3),
            AppTheme.accentColor(context).withOpacity(0.1),
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
              Icon(
                Icons.fitness_center,
                color: AppTheme.primaryColor(context),
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
              color: AppTheme.primaryColor(context),
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
