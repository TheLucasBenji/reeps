import 'package:flutter/material.dart';
import '../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Perfil
          _SectionHeader(title: 'Perfil'),
          _SettingTile(
            icon: Icons.person_outline,
            title: 'Editar perfil',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await Navigator.pushNamed(
                context,
                '/edit_profile',
              );

              if (result != null) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado')),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Datos
          _SectionHeader(title: 'Datos'),
          _SettingTile(
            icon: Icons.cloud_download_outlined,
            title: 'Exportar datos',
            onTap: () {
              // TODO: Exportar datos
            },
          ),
          _SettingTile(
            icon: Icons.cloud_upload_outlined,
            title: 'Importar datos',
            onTap: () {
              // TODO: Importar datos
            },
          ),
          _SettingTile(
            icon: Icons.backup_outlined,
            title: 'Respaldo en la nube',
            subtitle: 'Último respaldo: Hoy',
            onTap: () {
              // TODO: Configuración de respaldo
            },
          ),

          const SizedBox(height: 24),

          // Acerca de
          _SectionHeader(title: 'Acerca de'),
          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidad',
            onTap: () {
              // TODO: Mostrar política de privacidad
            },
          ),

          const SizedBox(height: 24),

          // Cerrar sesión
          _SectionHeader(title: 'Sesión'),
          _SettingTile(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            titleColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás seguro que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryPurple),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: titleColor ?? AppTheme.primaryPurple,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: titleColor),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
