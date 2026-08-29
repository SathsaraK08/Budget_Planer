import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/budget_repository.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/admin_cms/admin_cms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initializeFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetRepository()),
      ],
      child: const AdminBudgetApp(),
    ),
  );
}

class AdminBudgetApp extends StatelessWidget {
  const AdminBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Planner Admin CMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AdminCmsScreen(),
    );
  }
}
