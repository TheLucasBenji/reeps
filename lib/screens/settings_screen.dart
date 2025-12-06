import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'package:provider/provider.dart';
import '../config/theme_provider.dart';
import '../widgets/confirmation_dialog.dart';
import '../services/auth_service.dart';

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

          // Apariencia (tema)
          _SectionHeader(title: 'Apariencia'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor(context).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.color_lens_outlined,
                  color: AppTheme.primaryColor(context),
                  size: 20,
                ),
              ),
              title: Text(
                'Apariencia',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  final current = themeProvider.mode;
                  return DropdownButton<ThemeMode>(
                    value: current,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Sistema'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Oscuro'),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode == null) return;
                      if (mode == ThemeMode.system) {
                        themeProvider.setSystem();
                      } else if (mode == ThemeMode.light) {
                        themeProvider.setLight();
                      } else {
                        themeProvider.setDark();
                      }
                    },
                  );
                },
              ),
              onTap: null,
            ),
          ),

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
                builder: (context) => ConfirmationDialog(
                  title: 'Cerrar sesión',
                  content: '¿Estás seguro que deseas cerrar sesión?',
                  confirmText: 'Cerrar sesión',
                  onConfirm: () async {
                    final authService = Provider.of<AuthService>(
                      context,
                      listen: false,
                    );
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
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
        ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor(context)),
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
            color: AppTheme.primaryColor(context).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: titleColor ?? AppTheme.primaryColor(context),
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
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondaryColor(context),
        ),
        onTap: onTap,
      ),
    );
  }
}
