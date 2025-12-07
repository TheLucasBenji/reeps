import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        final profile = await FirestoreService().getUserProfile(user.uid);
        if (profile != null) {
          _nameController.text = profile.name ?? '';
          _emailController.text = profile.email ?? user.email ?? '';
          _avatarController.text = profile.avatar ?? '';
          _heightController.text = profile.height ?? '';
          _weightController.text = profile.weight ?? '';
          if (profile.birthDate != null) {
            _birthDate = DateTime.parse(profile.birthDate!);
          }
          _gender = profile.gender;
        } else {
             _emailController.text = user.email ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es requerido';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null; // email opcional
    final emailReg = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!emailReg.hasMatch(v.trim())) return 'Email inválido';
    return null;
  }

  String? _validateHeight(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    final height = double.tryParse(v.trim());
    if (height == null || height <= 0 || height > 300)
      return 'Altura inválida (cm)';
    return null;
  }

  String? _validateWeight(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    final weight = double.tryParse(v.trim());
    if (weight == null || weight <= 0 || weight > 500)
      return 'Peso inválido (kg)';
    return null;
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        final profile = UserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatar: _avatarController.text.trim(),
          height: _heightController.text.trim(),
          weight: _weightController.text.trim(),
          birthDate: _birthDate?.toIso8601String(),
          gender: _gender,
        );

        await FirestoreService().saveUserProfile(user.uid, profile);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : Column(
            children: [
              _AvatarPreview(controller: _avatarController),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          validator: _validateName,
                          decoration: const InputDecoration(
                            hintText: 'Tu nombre',
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'tu@email.com',
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Avatar (URL)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _avatarController,
                          decoration: const InputDecoration(
                            hintText: 'https://.../avatar.png',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Altura (cm)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _heightController,
                          validator: _validateHeight,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '170'),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Peso (kg)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _weightController,
                          validator: _validateWeight,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '70'),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Fecha de nacimiento',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectBirthDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              hintText: 'Selecciona tu fecha de nacimiento',
                            ),
                            child: Text(
                              _birthDate != null
                                  ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                  : 'No seleccionada',
                              style: TextStyle(
                                color: _birthDate != null
                                    ? null
                                    : AppTheme.textSecondaryColor(context),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Género',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: const InputDecoration(
                            hintText: 'Selecciona género',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Masculino',
                              child: Text('Masculino'),
                            ),
                            DropdownMenuItem(
                              value: 'Femenino',
                              child: Text('Femenino'),
                            ),
                            DropdownMenuItem(
                              value: 'Otro',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _gender = value),
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Guardar', 
                          onPressed: _isLoading ? () {} : _save,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final TextEditingController controller;

  const _AvatarPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final url = controller.text.trim();
    final hasUrl = url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppTheme.surfaceColor(context),
          backgroundImage: hasUrl ? NetworkImage(url) : null,
          child: !hasUrl
              ? Icon(
                  Icons.person,
                  size: 44,
                  color: AppTheme.textSecondaryColor(context),
                )
              : null,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // focus the avatar field by navigating up the tree
            // actual focusing handled by the Editable field when tapped
          },
          child: const Text('Cambiar avatar'),
        ),
      ],
    );
  }
}
