import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';

class SettingsScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const SettingsScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF070B19), // Deep midnight blue
              Color(0xFF0F172A), // Dark blue slate
              Color(0xFF1E1B4B), // Deep indigo/violet accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personalizá tu experiencia del Mundial 2026',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 1. Notificaciones de partidos
              _buildSectionHeader('RECORDATORIOS Y NOTIFICACIONES'),
              _buildSettingsContainer(
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'Notificaciones de partidos',
                    subtitle: 'Alertas automáticas en tiempo real al comenzar cada encuentro.',
                    value: true,
                    onChanged: (val) {},
                  ),
                  _buildDivider(),
                  // 2. Recordatorios antes del partido
                  _buildSwitchTile(
                    icon: Icons.alarm_rounded,
                    iconColor: const Color(0xFFFFD700),
                    title: 'Recordatorios antes del partido',
                    subtitle: 'Recibí un aviso 15 minutos antes del pitazo inicial de tus favoritos.',
                    value: true,
                    onChanged: (val) {},
                  ),
                ],
              ),

              // 3. Tema oscuro y preferencias visuales
              _buildSectionHeader('APARIENCIA'),
              _buildSettingsContainer(
                children: [
                  _buildStaticTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: const Color(0xFFFFD700),
                    title: 'Tema oscuro',
                    subtitle: 'Modo oscuro deportivo de alto contraste activado por defecto.',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Text(
                        'OSCURO',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00E5FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  // 24 Hour Format
                  _buildSwitchTile(
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'Formato de 24 Horas',
                    subtitle: 'Muestra los horarios en formato de 24H (19:00) o de 12H (7:00 PM).',
                    value: provider.use24HourFormat,
                    onChanged: (val) => provider.toggleTimeFormat(),
                  ),
                ],
              ),

              // 4. Idioma y Preferencias
              _buildSectionHeader('IDIOMA Y SELECCIÓN'),
              _buildSettingsContainer(
                children: [
                  _buildStaticTile(
                    icon: Icons.translate_rounded,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'Idioma',
                    subtitle: 'Idioma del contenido oficial y de simulación.',
                    trailing: Text(
                      'Español (ES) 🇪🇸',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  // 5. Equipos favoritos
                  _buildInteractiveTile(
                    icon: Icons.flag_rounded,
                    iconColor: const Color(0xFFFFD700),
                    title: 'Equipos favoritos',
                    subtitle: 'Seguí tus selecciones preferidas y administrá tus favoritos.',
                    onTap: () => onNavigate(3), // Jump straight to Teams Screen!
                  ),
                ],
              ),

              // 6. Privacidad y Seguridad
              _buildSectionHeader('SEGURIDAD Y DATOS'),
              _buildSettingsContainer(
                children: [
                  _buildInteractiveTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'Privacidad',
                    subtitle: 'Términos de uso, almacenamiento local Hive y protección de datos.',
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  _buildDivider(),
                  // Data simulation reset
                  _buildInteractiveTile(
                    icon: Icons.restore_rounded,
                    iconColor: Colors.redAccent,
                    title: 'Reiniciar simulaciones',
                    titleColor: Colors.redAccent,
                    subtitle: 'Eliminá los marcadores simulados, favoritos y selecciones seguidas.',
                    onTap: () => _showResetConfirmation(context, provider),
                  ),
                ],
              ),

              // 7. Acerca de la app
              _buildSectionHeader('INFORMACIÓN'),
              _buildSettingsContainer(
                children: [
                  _buildStaticTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.white38,
                    title: 'Acerca de la app',
                    subtitle: 'Mundial 2026 - Versión 1.0.0 (Premium Rebuild)',
                    trailing: Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildStaticTile(
                    icon: Icons.cloud_done_outlined,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'Estado de conexión',
                    subtitle: 'Sincronización completa offline activa y optimizada.',
                    trailing: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120), // Height padding to avoid overlap with bottom navigation bar
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets Builders ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 0, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Color(0xFF00E5FF),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      height: 1,
      indent: 64,
      endIndent: 20,
    );
  }

  Widget _buildIconCapsule({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconCapsule(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.4),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeColor: const Color(0xFF00E5FF),
            activeTrackColor: const Color(0xFF008DDA).withOpacity(0.4),
            inactiveThumbColor: Colors.white30,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconCapsule(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: titleColor ?? Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildIconCapsule(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.4),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, FixtureProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              const Text(
                '¿Reiniciar simulaciones?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: const Text(
            'Esta acción eliminará de forma permanente todas tus simulaciones de marcadores, favoritos y selecciones seguidas, restaurando el fixture oficial por defecto. No se puede deshacer.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.4,
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.resetSimulation();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aplicación restaurada a sus valores oficiales por defecto'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Reiniciar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.privacy_tip_outlined, color: Color(0xFF00E5FF), size: 24),
              const SizedBox(width: 10),
              const Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Esta aplicación no recopila ni transmite información personal. Todos tus datos de simulación de marcadores, equipos favoritos y configuraciones de alertas de notificación se almacenan de manera 100% segura y privada de forma local en tu propio dispositivo utilizando el motor de base de datos Hive de alta velocidad offline.\n\nPara el funcionamiento óptimo de los recordatorios de partidos, se utilizan los servicios del planificador local de notificaciones de iOS. Ninguno de estos datos se envía a servidores externos.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                height: 1.45,
                color: Colors.white70,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
