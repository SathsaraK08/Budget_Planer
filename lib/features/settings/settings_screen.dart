import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';
import 'household_members_screen.dart';
import 'appearance_screen.dart';
import 'categories_manager_screen.dart';
import 'advanced_settings_screen.dart';

/// Settings home — 4 grouped sections, admin-only.
/// Matches Design Batch 4, Screen 1.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final isAdmin = repo.currentMember?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isAdmin)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, color: AppTheme.warning, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Settings are managed by the household admin.',
                      style: TextStyle(fontSize: 13, color: AppTheme.warning),
                    ),
                  ),
                ],
              ),
            ),

          // Household group
          _buildGroupHeader('Household'),
          _buildSettingsTile(
            context,
            icon: Icons.people_outline,
            iconColor: AppTheme.primary,
            title: 'Members & Salaries',
            subtitle: '${repo.members.length} member${repo.members.length != 1 ? "s" : ""}',
            enabled: isAdmin,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HouseholdMembersScreen()),
            ),
          ),

          const SizedBox(height: 20),

          // Appearance group
          _buildGroupHeader('Appearance'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            iconColor: AppTheme.secondary,
            title: 'Theme & App Name',
            subtitle: 'Preset color themes, logo icon',
            enabled: isAdmin,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppearanceScreen()),
            ),
          ),

          const SizedBox(height: 20),

          // Categories group
          _buildGroupHeader('Categories'),
          _buildSettingsTile(
            context,
            icon: Icons.category_outlined,
            iconColor: AppTheme.accent,
            title: 'Manage Categories',
            subtitle: 'BNPL platforms, expense categories, wishlist categories',
            enabled: isAdmin,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesManagerScreen()),
            ),
          ),

          const SizedBox(height: 20),

          // Advanced group
          _buildGroupHeader('Advanced'),
          _buildSettingsTile(
            context,
            icon: Icons.tune_outlined,
            iconColor: AppTheme.warning,
            title: 'Forecast & AI Settings',
            subtitle: 'Safety buffer, AI advisor provider & key',
            enabled: isAdmin,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.download_outlined,
            iconColor: AppTheme.info,
            title: 'Backup & Export',
            subtitle: 'Download household data as JSON',
            enabled: isAdmin,
            onTap: () => _exportData(context, repo),
          ),

          const SizedBox(height: 32),

          // Household info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT SESSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow('Household', repo.household.name),
                const SizedBox(height: 6),
                _infoRow('Acting as', repo.currentMember?.name ?? '—'),
                const SizedBox(height: 6),
                _infoRow('Role', repo.currentMember?.isAdmin == true ? 'Admin' : 'Member'),
                const SizedBox(height: 6),
                _infoRow('Cycle starts', '${repo.household.cycleStartDay}th of each month'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _signOut(context, repo),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, BudgetRepository repo) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing export... Download will start shortly.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await repo.exportToJson(context);
  }

  Future<void> _signOut(BuildContext context, BudgetRepository repo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sign Out'),
        content: const Text('You will need your credentials to log in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await repo.signOut();
    }
  }
}
