import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final borderColor = isDark ? BentoColors.bentoBorderDark : BentoColors.bentoBorderLight;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Title banner
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),

        // Section 1: Preferences
        _buildSectionHeader('PREFERENCIAS'),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              // Toggle 24-hour format
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: const Text(
                  'Formato de 24 Horas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Muestra las horas en formato de 24H (ej. 18:00) o de 12H (ej. 6:00 PM).',
                  style: TextStyle(fontSize: 10, color: BentoColors.bentoSlate500),
                ),
                trailing: Switch(
                  value: provider.use24HourFormat,
                  activeColor: primaryColor,
                  onChanged: (val) => provider.toggleTimeFormat(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section 2: Data Simulation management
        _buildSectionHeader('SIMULACIONES Y DATOS'),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              // Reset Simulator values
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.restore, color: Colors.red),
                title: const Text(
                  'Reiniciar Simulaciones',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                subtitle: const Text(
                  'Borra todos los marcadores simulados, favoritos y selecciones seguidas, restaurando el fixture por defecto.',
                  style: TextStyle(fontSize: 10, color: BentoColors.bentoSlate500),
                ),
                onTap: () => _showResetConfirmation(context, provider),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section 3: About
        _buildSectionHeader('ACERCA DE'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mundial 2026 - Fixture & Simulador',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4),
              Text(
                'Versión 1.0.0 (Flutter Rebuild)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BentoColors.bentoSlate500),
              ),
              SizedBox(height: 12),
              Text(
                'Esta aplicación te permite seguir de cerca el calendario, los estadios y las selecciones de la Copa Mundial de la FIFA 2026 de forma interactiva y offline. Simula marcadores para predecir qué selecciones clasificarán a la siguiente ronda y calcula las posiciones dinámicamente.',
                style: TextStyle(fontSize: 11, height: 1.4, color: BentoColors.bentoSlate500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: BentoColors.bentoSlate500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, FixtureProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('¿Reiniciar aplicación?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Esta acción eliminará de forma permanente todas tus simulaciones de marcadores, favoritos y selecciones. No se puede deshacer.',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                provider.resetSimulation();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aplicación restaurada a sus valores por defecto'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Confirmar Reinicio', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
