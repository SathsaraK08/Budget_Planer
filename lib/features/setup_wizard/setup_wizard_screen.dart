import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/services/supabase_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

/// First-run setup wizard — shown only when `households.setup_completed = false`.
/// Steps: (1) Add salaries, (2) Confirm and finish.
/// On finish: writes `setup_completed = true` to DB so hard-refresh won't loop.
class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  bool _isSaving = false;

  final List<TextEditingController> _salaryControllers = [];

  @override
  void initState() {
    super.initState();
    final repo = context.read<BudgetRepository>();
    for (final member in repo.members) {
      _salaryControllers.add(
        TextEditingController(
          text: member.regularMonthlySalary > 0
              ? member.regularMonthlySalary.toStringAsFixed(0)
              : '',
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _salaryControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _goNext() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    final repo = context.read<BudgetRepository>();

    // Save salaries for each member
    final members = repo.members;
    for (int i = 0; i < members.length && i < _salaryControllers.length; i++) {
      final salary = double.tryParse(_salaryControllers[i].text.replaceAll(',', '')) ?? 0.0;
      final updated = members[i].copyWith(regularMonthlySalary: salary);
      await SupabaseRepository.updateMember(updated);
      repo.updateMember(updated);
    }

    // Mark setup complete in DB — the fix for the setup-loop bug
    await SupabaseRepository.completeSetup(repo.household.id);
    repo.markSetupComplete();

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Navigate to main app — remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final members = repo.members;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.home_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'HomeBudget Setup',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Step ${_currentStep + 1} of 2',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 2,
                      backgroundColor: AppTheme.surfaceElevated,
                      color: AppTheme.primary,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSalaryStep(members),
                  _buildConfirmStep(repo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryStep(List<dynamic> members) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add your monthly salaries',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This powers the forecast engine. You can always update these in Settings → Household.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 28),

          for (int i = 0; i < members.length && i < _salaryControllers.length; i++) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    child: Text(
                      members[i].name[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          members[i].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _salaryControllers[i],
                          keyboardType: const TextInputType.numberWithOptions(decimal: false),
                          decoration: InputDecoration(
                            labelText: 'Monthly Salary',
                            prefixText: 'Rs. ',
                            prefixStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppTheme.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppTheme.cardBorder),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < members.length - 1) const SizedBox(height: 12),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _goNext,
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _goNext,
              child: const Text(
                "Skip for now — I'll add salaries later",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildConfirmStep(BudgetRepository repo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "You're all set!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${repo.household.name} is ready to track your 25th-to-25th cycle.',
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _summaryRow(Icons.home_outlined, 'Household', repo.household.name),
                const Divider(height: 20, color: AppTheme.cardBorder),
                _summaryRow(
                  Icons.people_outline,
                  'Members',
                  repo.members.map((m) => m.name).join(' & '),
                ),
                const Divider(height: 20, color: AppTheme.cardBorder),
                _summaryRow(Icons.calendar_today_outlined, 'Cycle', '25th of every month'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppTheme.info, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Categories, BNPL platforms, and AI settings can be configured in Settings → Categories & Advanced.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _finish,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Go to Dashboard", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
