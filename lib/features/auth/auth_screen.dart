import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/supabase_repository.dart';
import '../../core/theme/app_theme.dart';
import '../setup_wizard/setup_wizard_screen.dart';

/// Auth screen — handles Register (Tab 0) and Login (Tab 1).
/// Matches Design Batch 1, Screens 2 & 3.
///
/// - Register: name, partner toggle + name, household name. No salary field.
/// - Login: email + password. If 2+ members → identity switcher modal after login.
class AuthScreen extends StatefulWidget {
  final int initialTab;
  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login fields
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Register fields
  final _regNameCtrl = TextEditingController();
  final _regHouseholdCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _partnerNameCtrl = TextEditingController();

  bool _hasPartner = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regHouseholdCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _partnerNameCtrl.dispose();
    super.dispose();
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final password = _loginPasswordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (!SupabaseService.isConfigured) {
        _showError('Supabase is not configured.\nGo to Settings → Advanced to add your project credentials.');
        return;
      }

      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Fetch household and members from DB
      final repo = context.read<BudgetRepository>();
      await repo.loadFromSupabase();

      if (!mounted) return;

      // If 2+ members → show identity switcher, then navigate
      if (repo.members.length >= 2) {
        _showIdentitySwitcher(repo);
      } else {
        _navigateAfterAuth(repo);
      }
    } catch (e) {
      if (mounted) _showError('Login failed: ${_friendlyError(e)}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    final name = _regNameCtrl.text.trim();
    final household = _regHouseholdCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final password = _regPasswordCtrl.text.trim();
    final partner = _hasPartner ? _partnerNameCtrl.text.trim() : null;

    if (name.isEmpty || household.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (!SupabaseService.isConfigured) {
        _showError('Supabase is not configured.\nGo to Settings → Advanced to add your project credentials first.');
        return;
      }

      final authResponse = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        _showError('Registration failed — please try again.');
        return;
      }

      // Atomically create household + member via DB RPC
      await SupabaseRepository.claimHousehold(
        householdName: household,
        userName: name,
        partnerName: partner,
      );

      if (!mounted) return;
      final repo = context.read<BudgetRepository>();
      await repo.loadFromSupabase();

      if (!mounted) return;
      // After registration, always go to setup wizard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) _showError('Registration failed: ${_friendlyError(e)}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Identity Switcher ──────────────────────────────────────────────────────

  void _showIdentitySwitcher(BudgetRepository repo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who are you today?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'This sets who pays for new expenses by default. You can always change it per entry.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ...repo.members.map((member) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  repo.setSelectedMember(member.id);
                  Navigator.pop(ctx);
                  _navigateAfterAuth(repo);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        child: Text(
                          member.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            member.isAdmin ? 'Admin' : 'Member',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _navigateAfterAuth(BudgetRepository repo) {
    if (!mounted) return;

    // Check setup_completed from DB record
    if (!repo.household.setupCompleted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
        (route) => false,
      );
    } else {
      Navigator.pop(context); // Return to app shell
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'Email or password is incorrect.';
    }
    if (msg.contains('email already')) return 'This email is already registered.';
    if (msg.contains('network')) return 'No internet connection.';
    return e.toString();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('HomeBudget'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Sign Up'),
            Tab(text: 'Log In'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRegisterTab(), _buildLoginTab()],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Log in to sync your shared household budget.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginPasswordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Log In', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Create household account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set up your shared 25th-to-25th budget planner.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),

          TextField(
            controller: _regNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'e.g. Sathsara',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _regHouseholdCtrl,
            decoration: const InputDecoration(
              labelText: 'Household Name',
              hintText: 'e.g. Our Household',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 20),

          // Partner toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Does your partner also use this account?',
                style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
              value: _hasPartner,
              activeColor: AppTheme.primary,
              onChanged: (val) => setState(() => _hasPartner = val),
            ),
          ),

          if (_hasPartner) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _partnerNameCtrl,
              decoration: const InputDecoration(
                labelText: "Partner's Name",
                hintText: 'e.g. Dhiyan',
                prefixIcon: Icon(Icons.person_add_outlined),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          TextField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regPasswordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'At least 6 characters',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Account', style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Salaries are entered after account creation in Household Settings.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
