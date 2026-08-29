import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiKeyController = TextEditingController();
  final _supabaseUrlController = TextEditingController();
  final _supabaseAnonKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = context.read<BudgetRepository>();
    _geminiKeyController.text = repo.household.geminiApiKey ?? '';
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _supabaseUrlController.dispose();
    _supabaseAnonKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Household Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HOUSEHOLD CONFIGURATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.home, color: Colors.white)),
                  title: Text(repo.household.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Monthly Cycle Starts: ${repo.household.cycleStartDay}th of each month\nCurrency: ${repo.household.currencyCode} (${repo.household.currencySymbol})'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gemini Free Tier API Key
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: AppTheme.secondary, size: 20),
                    SizedBox(width: 8),
                    Text('Gemini AI Advisor (Free Tier)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your free Gemini API key to receive intelligent financial summaries. (If left blank, smart local rule-based advice is used).',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _geminiKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Gemini API Key (Free Tier)',
                    hintText: 'AIzaSy...',
                    prefixIcon: Icon(Icons.key),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    repo.updateGeminiApiKey(_geminiKeyController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gemini API Key saved! Refreshing AI insights.')),
                    );
                  },
                  child: const Text('Save API Key'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Supabase Sync Config
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.cloud_sync_outlined, color: AppTheme.info, size: 20),
                    SizedBox(width: 8),
                    Text('Supabase Cloud Sync (Free Tier)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect to your Supabase project to enable real-time sync between husband & wife accounts across Web, iOS, and Android.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _supabaseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Supabase URL',
                    hintText: 'https://xyz.supabase.co',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _supabaseAnonKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Supabase Anon / Public Key',
                    hintText: 'eyJhbGciOi...',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final url = _supabaseUrlController.text.trim();
                    final key = _supabaseAnonKeyController.text.trim();
                    if (url.isNotEmpty && key.isNotEmpty) {
                      await SupabaseService.saveCredentials(url, key);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Supabase credentials saved successfully!')),
                        );
                      }
                    }
                  },
                  child: const Text('Connect Supabase'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
