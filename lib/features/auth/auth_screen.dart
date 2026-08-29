import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController(text: 'admin@homebudget.lk');
  final _passwordController = TextEditingController(text: 'admin123');
  final _nameController = TextEditingController();
  String _selectedRole = 'husband';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (!SupabaseService.isConfigured) {
        throw Exception('Supabase is not configured. Please add URL and Anon Key in Settings.');
      }
      
      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // In a real app we'd fetch the user's profile from the DB here
      final repo = context.read<BudgetRepository>();
      repo.setUserProfile(
        name: email.contains('wife') || email.contains('dhiyan') ? 'Dhiyan' : 'Sathsara',
        email: email,
        role: email.contains('wife') ? 'wife' : 'husband',
        isAdmin: true,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (!SupabaseService.isConfigured) {
        throw Exception('Supabase is not configured. Please add URL and Anon Key in Settings.');
      }
      
      final authResponse = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        // Automatically claim a new household for the first user
        await SupabaseService.client.rpc('claim_household', params: {
          'new_household_name': '${name}\'s Household',
          'user_name': name,
          'user_role': _selectedRole,
        });

        final repo = context.read<BudgetRepository>();
        repo.setUserProfile(
          name: name,
          email: email,
          role: _selectedRole,
          isAdmin: true,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Household account created for $name!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Authentication'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Log In'),
            Tab(text: 'Sign Up'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to HomeBudget',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Log in to sync your 25th-to-25th household budget.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Log In', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: AppTheme.warning),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Quick Admin Access ready with pre-filled demo credentials.',
                          style: TextStyle(fontSize: 12, color: AppTheme.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sign Up Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Household Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join or create your shared 2-member household workspace.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Your Name (e.g. Sathsara or Dhiyan)', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Role in Household', prefixIcon: Icon(Icons.badge_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'husband', child: Text('Husband / Admin')),
                    DropdownMenuItem(value: 'wife', child: Text('Wife / Member')),
                    DropdownMenuItem(value: 'partner', child: Text('Partner')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSignup,
                    child: const Text('Create Account', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
