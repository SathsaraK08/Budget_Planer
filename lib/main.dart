import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/budget_repository.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/income/income_screen.dart';
import 'features/fixed_payments/fixed_payments_screen.dart';
import 'features/installments/installments_screen.dart';
import 'features/credit_cards/credit_cards_screen.dart';
import 'features/subscriptions/subscriptions_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/daily_spends/daily_spends_screen.dart';
import 'features/forecast/forecast_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/admin_cms/admin_cms_screen.dart';
import 'features/auth/auth_screen.dart';

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
      title: 'Household Budget Planner & Admin CMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DailySpendsScreen(),
    InstallmentsScreen(),
    ForecastScreen(),
    WishlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();

    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppTheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(repo.household.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${repo.userName} (${repo.userRole})', style: const TextStyle(fontSize: 13, color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
                  Text(repo.userEmail, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryLight),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppTheme.warning),
              title: const Text('Admin CMS Control Panel', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warning)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCmsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryLight),
              title: const Text('Income Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppTheme.warning),
              title: const Text('Fixed Bills & Loans'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FixedPaymentsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: AppTheme.warning),
              title: const Text('BNPL / Koko / Mintpay'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppTheme.secondary),
              title: const Text('Credit Cards'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditCardsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions_outlined, color: AppTheme.info),
              title: const Text('Subscriptions & Auto-Pay'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist_rtl_outlined, color: AppTheme.accent),
              title: const Text('Wishlist / Things to Buy'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology_outlined, color: AppTheme.primaryLight),
              title: const Text('Survival Forecasting Engine'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_person_outlined, color: AppTheme.textSecondary),
              title: const Text('Login / Switch Account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
              title: const Text('Settings & Cloud Sync'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Daily Spends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Installments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_outlined),
            activeIcon: Icon(Icons.checklist_rtl),
            label: 'Wishlist',
          ),
        ],
      ),
    );
  }
}
