import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/budget_repository.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';

// Screens
import 'features/landing/landing_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/setup_wizard/setup_wizard_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/daily_spends/daily_spends_screen.dart';
import 'features/fixed_payments/fixed_payments_screen.dart';
import 'features/installments/installments_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/forecast/forecast_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/daily_spends/quick_spend_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initializeFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetRepository()),
      ],
      child: const HouseholdBudgetApp(),
    ),
  );
}

class HouseholdBudgetApp extends StatelessWidget {
  const HouseholdBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeBudget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Named route '/' → AppRouter decides where to go
      home: const AppRouter(),
    );
  }
}

/// AppRouter — session-aware routing with proper guard order.
///
/// Guard chain:
///   1. Is Supabase configured + user authenticated? → If not → LandingScreen
///   2. Is setup_completed = true in DB? → If not → SetupWizardScreen
///   3. Otherwise → MainNavigationShell
///
/// This replaces all previous client-only/localStorage setup-loop patterns.
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _isChecking = true;
  _RouteTarget _target = _RouteTarget.landing;

  @override
  void initState() {
    super.initState();
    _determineRoute();
  }

  Future<void> _determineRoute() async {
    // Check Supabase auth session
    if (!SupabaseService.isConfigured) {
      setState(() {
        _target = _RouteTarget.landing;
        _isChecking = false;
      });
      return;
    }

    final session = SupabaseService.client.auth.currentSession;
    if (session == null) {
      setState(() {
        _target = _RouteTarget.landing;
        _isChecking = false;
      });
      return;
    }

    // Session exists → load household data from DB
    final repo = context.read<BudgetRepository>();
    await repo.loadFromSupabase();

    // Check setup_completed from DB (not local storage — fixes setup-loop bug)
    if (!repo.household.setupCompleted) {
      setState(() {
        _target = _RouteTarget.setupWizard;
        _isChecking = false;
      });
    } else {
      setState(() {
        _target = _RouteTarget.mainApp;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return switch (_target) {
      _RouteTarget.landing => const LandingScreen(),
      _RouteTarget.setupWizard => const SetupWizardScreen(),
      _RouteTarget.mainApp => const MainNavigationShell(),
    };
  }
}

enum _RouteTarget { landing, setupWizard, mainApp }

/// Main navigation shell — clean bottom nav per spec §Design Batch 2.
/// Max 5 bottom nav items. Settings accessible via avatar/icon in header.
/// Floating action button for "Log Expense" on all main screens.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // 5 main screens in bottom nav
  static const List<Widget> _screens = [
    DashboardScreen(),
    DailySpendsScreen(),
    FixedPaymentsScreen(),
    WishlistScreen(),
    ForecastScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_outlined),
      activeIcon: Icon(Icons.receipt),
      label: 'Spends',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined),
      activeIcon: Icon(Icons.receipt_long),
      label: 'Bills',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.checklist_rtl_outlined),
      activeIcon: Icon(Icons.checklist_rtl),
      label: 'Wishlist',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.psychology_outlined),
      activeIcon: Icon(Icons.psychology),
      label: 'Forecast',
    ),
  ];

  void _openQuickSpend() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickSpendDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final isAdmin = repo.currentMember?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_outlined, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              repo.household.appName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Analytics shortcut
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),
          // BNPL Installments shortcut (not in main nav per spec — but still accessible)
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Installments',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InstallmentsScreen()),
              );
            },
          ),
          // Settings (admin only — but always visible, gated inside the screen)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickSpend,
        tooltip: 'Log Expense',
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
