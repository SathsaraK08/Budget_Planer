import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/services/supabase_repository.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/forecast_settings.dart';
import '../../core/theme/app_theme.dart';

/// Advanced Settings — Forecast buffer parameters + AI provider + Backup/Export.
/// Each forecast field has a plain-language help text from spec §7.
class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  // Forecast
  late TextEditingController _bufferDaysCtrl;
  late TextEditingController _reservePctCtrl;

  // AI
  String _aiProvider = 'none';
  late TextEditingController _aiKeyCtrl;

  // Supabase credentials
  late TextEditingController _supabaseUrlCtrl;
  late TextEditingController _supabaseKeyCtrl;

  bool _isSaving = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final repo = context.read<BudgetRepository>();
    final fs = repo.forecastSettings;
    _bufferDaysCtrl = TextEditingController(text: fs.survivalBufferDays.toString());
    _reservePctCtrl = TextEditingController(text: fs.reservePercentage.toStringAsFixed(1));
    _aiProvider = repo.aiProvider;
    _aiKeyCtrl = TextEditingController(text: repo.aiKey ?? '');
    _supabaseUrlCtrl = TextEditingController();
    _supabaseKeyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _bufferDaysCtrl.dispose();
    _reservePctCtrl.dispose();
    _aiKeyCtrl.dispose();
    _supabaseUrlCtrl.dispose();
    _supabaseKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAll,
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Forecast Engine Parameters ────────────────────────────────────
          _sectionHeader('FORECAST SETTINGS'),
          const SizedBox(height: 12),

          _settingsCard(children: [
            // Safety Contingency Reserve
            _labeledField(
              title: 'Safety Contingency Reserve (%)',
              helpText:
                  'A cushion always kept back from your spendable balance, in case income is lower or a bill is higher than expected.',
              child: TextField(
                controller: _reservePctCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  suffixText: '%',
                  hintText: '5.0',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Required Runway Buffer
            _labeledField(
              title: 'Required Runway Buffer (Days)',
              helpText:
                  'How many days ahead the app checks you can survive on committed costs alone.',
              child: TextField(
                controller: _bufferDaysCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'days',
                  hintText: '30',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // ── AI Advisor ────────────────────────────────────────────────────
          _sectionHeader('AI ADVISOR'),
          const SizedBox(height: 12),

          _settingsCard(children: [
            const Text(
              'The AI advisor generates plain-language narrative insights about your cycle. The actual numbers always come from the forecast engine — never the AI.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Provider selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'none', label: Text('None'), icon: Icon(Icons.block, size: 16)),
                ButtonSegment(value: 'gemini', label: Text('Gemini'), icon: Icon(Icons.auto_awesome, size: 16)),
                ButtonSegment(value: 'openai', label: Text('OpenAI'), icon: Icon(Icons.bolt, size: 16)),
              ],
              selected: {_aiProvider},
              onSelectionChanged: (Set<String> sel) {
                setState(() => _aiProvider = sel.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppTheme.primary.withOpacity(0.2);
                  return AppTheme.surfaceElevated;
                }),
              ),
            ),

            if (_aiProvider != 'none') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _aiKeyCtrl,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: _aiProvider == 'gemini' ? 'Gemini API Key' : 'OpenAI API Key',
                  hintText: _aiProvider == 'gemini' ? 'AIzaSy...' : 'sk-...',
                  prefixIcon: const Icon(Icons.key_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your key is stored in the database and only used server-side. '
                'If the key is invalid or the request fails, the AI card is hidden — the app continues working.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
              ),
            ],
          ]),

          const SizedBox(height: 24),

          // ── Supabase Credentials ─────────────────────────────────────────
          _sectionHeader('SUPABASE CONNECTION'),
          const SizedBox(height: 12),

          _settingsCard(children: [
            const Text(
              'Connect to your Supabase project to enable real-time sync across all devices.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _supabaseUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Supabase Project URL',
                hintText: 'https://xyz.supabase.co',
                prefixIcon: Icon(Icons.link_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _supabaseKeyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Anon / Public Key',
                hintText: 'eyJhbGciOi...',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _connectSupabase,
                child: const Text('Connect Supabase'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: SupabaseService.isConfigured ? AppTheme.primary : AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  SupabaseService.isConfigured ? 'Connected' : 'Not connected — running in offline/demo mode',
                  style: TextStyle(
                    fontSize: 12,
                    color: SupabaseService.isConfigured ? AppTheme.primary : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 24),

          // ── Backup / Export ─────────────────────────────────────────────
          _sectionHeader('BACKUP & EXPORT'),
          const SizedBox(height: 12),

          _settingsCard(children: [
            const Text(
              'Download all your household data as a JSON file. Includes income, spends, bills, installments, subscriptions, and wishlist.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download JSON Export'),
              ),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _labeledField({
    required String title,
    required String helpText,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helpText,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    final repo = context.read<BudgetRepository>();

    // Save forecast settings
    final bufferDays = int.tryParse(_bufferDaysCtrl.text) ?? 30;
    final reservePct = double.tryParse(_reservePctCtrl.text) ?? 5.0;
    final newFs = ForecastSettings(
      survivalBufferDays: bufferDays.clamp(1, 365),
      reservePercentage: reservePct.clamp(0, 50),
      committedCategories: repo.forecastSettings.committedCategories,
    );
    await SupabaseRepository.updateForecastSettings(repo.household.id, newFs);
    repo.updateForecastSettings(newFs);

    // Save AI settings
    final key = _aiKeyCtrl.text.trim().isEmpty ? null : _aiKeyCtrl.text.trim();
    await SupabaseRepository.updateAiSettings(repo.household.id, _aiProvider, key);
    repo.updateAiSettings(_aiProvider, key);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _connectSupabase() async {
    final url = _supabaseUrlCtrl.text.trim();
    final key = _supabaseKeyCtrl.text.trim();
    if (url.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Supabase URL and Anon Key.'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await SupabaseService.saveCredentials(url, key);
      if (mounted) {
        setState(() {}); // Refresh connection status indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supabase connected! Restart the app to load your data.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${e.toString()}'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    final repo = context.read<BudgetRepository>();
    await repo.exportToJson(context);
  }
}
