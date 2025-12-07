import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Política de Privacidad', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Última actualización: ${DateTime.now().year}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            _Section(
              title: '1. Información que recopilamos',
              content: 'Recopilamos información que usted nos proporciona directamente, como su nombre, correo electrónico, datos de perfil (altura, peso, fecha de nacimiento) y registros de entrenamiento.',
            ),
             _Section(
              title: '2. Uso de la información',
              content: 'Utilizamos la información recopilada para proporcionar, mantener y mejorar nuestros servicios, así como para personalizar su experiencia de usuario y realizar un seguimiento de su progreso.',
            ),
             _Section(
              title: '3. Almacenamiento de datos',
              content: 'Sus datos se almacenan de forma segura en la nube utilizando servicios de Firebase. Nos esforzamos por proteger su información personal, pero recuerde que ningún método de transmisión por Internet o almacenamiento electrónico es 100% seguro.',
            ),
             _Section(
              title: '4. Contacto',
              content: 'Si tiene alguna pregunta sobre esta política de privacidad, por favor contáctenos a través del soporte de la aplicación.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
