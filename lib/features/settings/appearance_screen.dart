import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

/// Appearance screen — theme preset picker, app name.
/// Matches Design Batch 4, Screen 3.
/// A small fixed set of presets — NOT a raw color/CSS customizer.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  static const List<_ThemePreset> _presets = [
    _ThemePreset('Emerald', 'emerald', Color(0xFF10B981), Color(0xFF6366F1)),
    _ThemePreset('Sapphire', 'sapphire', Color(0xFF3B82F6), Color(0xFF8B5CF6)),
    _ThemePreset('Amethyst', 'amethyst', Color(0xFF8B5CF6), Color(0xFFEC4899)),
    _ThemePreset('Amber', 'amber', Color(0xFFF59E0B), Color(0xFFEF4444)),
    _ThemePreset('Crimson', 'crimson', Color(0xFFEF4444), Color(0xFF6366F1)),
  ];

  late String _selectedPreset;
  late TextEditingController _appNameCtrl;

  @override
  void initState() {
    super.initState();
    final repo = context.read<BudgetRepository>();
    _selectedPreset = repo.themePreset;
    _appNameCtrl = TextEditingController(text: repo.household.appName);
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        actions: [
          TextButton(
            onPressed: _saveAppearance,
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'THEME',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: _presets.length,
            itemBuilder: (_, i) {
              final preset = _presets[i];
              final isSelected = _selectedPreset == preset.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedPreset = preset.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? preset.primary : AppTheme.cardBorder,
                      width: isSelected ? 2.5 : 1,
                    ),
                    color: AppTheme.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: preset.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: preset.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? preset.primary : AppTheme.textSecondary,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            'APP NAME',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _appNameCtrl,
            decoration: const InputDecoration(
              labelText: 'App Name',
              hintText: 'HomeBudget',
              prefixIcon: Icon(Icons.title_outlined),
              helperText: 'Shown in the app header and landing page.',
            ),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppTheme.textMuted, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Logo icons and further customization can be added in a future update.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAppearance() async {
    final repo = context.read<BudgetRepository>();
    await repo.updateAppearance(
      themePreset: _selectedPreset,
      appName: _appNameCtrl.text.trim().isEmpty ? 'HomeBudget' : _appNameCtrl.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appearance saved.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

class _ThemePreset {
  final String name;
  final String key;
  final Color primary;
  final Color accent;
  const _ThemePreset(this.name, this.key, this.primary, this.accent);
}
