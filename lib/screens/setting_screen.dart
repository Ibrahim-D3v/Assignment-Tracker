import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        children: [
          const SizedBox(height: 32),

          // PREFERENCES SECTION
          _buildSectionHeader('Preferences', theme),
          _buildSettingsCard(
            theme: theme,
            children: [
              // Theme Toggle Tile
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: theme.colorScheme.primary),
                title: Text('Dark Mode', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                trailing: Switch(
                  value: isDark,
                  activeColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                  inactiveThumbColor: theme.colorScheme.onSurfaceVariant,
                  inactiveTrackColor: theme.colorScheme.surface,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                ),
              ),
              Divider(height: 1, indent: 60, color: theme.colorScheme.onSurface.withOpacity(0.05)),

              // Notifications Tile
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Icon(Icons.notifications_none_outlined, color: theme.colorScheme.primary),
                title: Text('Push Notifications', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                trailing: Switch(
                  value: true, // Placeholder for future state
                  activeThumbColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // DATA & PRIVACY SECTION
          _buildSectionHeader('Data & Privacy', theme),
          _buildSettingsCard(
            theme: theme,
            children: [
              Divider(height: 1, indent: 60, color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Clear Local Cache', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 48),

          // FOOTER
          Center(
            child: Text(
              'EduCalm v1.0.0\nDesigned for Focus.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6), fontSize: 12, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Helper for the Cozy Earth 32px radius, flat card look
  Widget _buildSettingsCard({required ThemeData theme, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(32), // High border radius from Cozy Earth spec
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05), width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}